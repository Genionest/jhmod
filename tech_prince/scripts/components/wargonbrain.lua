local function find_food(inst)
	local target = nil 
	if inst.sg:HasStateTag("busy") then return end
	if inst.components.inventory and inst.components.eater then
		target = inst.components.inventory:FindItem(function(item) 
			return inst.components.eater:CanEat(item) 
		end)
	end
	if not target then
		target = WARGON.find(inst, see_food_dist, function(item)
			return inst.components.eater:CanEat(item) 
		end)
	end
	if target then
		return BufferedAction(inst, target, ACTIONS.EAT)
	end
end

local function get_home(inst)
	if inst.components.homeseeker and inst.components.homeseeker.home and
	inst.components.homeseeker.home:IsValid() then
		return inst.components.homeseeker.home
	end
end

local function go_home(inst)
	if inst.components.follower and inst.components.follower.leader then
		return
	end
	if inst.components.combat and inst.components.combat.target then
		return
	end
	local home = get_home(inst)
	if home then
		return BufferedAction(inst, home, ACTIONS.GOHOME)
	end
end

local function get_leader(inst)
	if inst.components.follower then
		return inst.components.follower.leader
	end
end

local function home_pos(inst)
	if get_home(inst) then
		return inst.components.homeseeker:GetHomePos()
	end
end

local function no_leader_home_pos(inst)
	if not get_leader(inst) then
		return home_pos(inst)
	end
end

local function run_away(inst, guy)
	for k, v in pairs(inst.components.wargonbrain.scary_tags) do
		return guy:HasTag(v)
	end
end

local function find_workable(item, inst, action)
		print("wargonbrain find", 1)
	if item.components.workable 
	and item.components.workable.action == action then
		print("wargonbrain find", 2)
		return true
	end
end

local function do_work(inst, fn, action)
	print("wargonbrain work", 1)
	local target = WARGON.find(inst, 10, fn)
	print("wargonbrain work", 2)
	if target then
		print("wargonbrain work", 3)
		return BufferedAction(inst, target, action)
	end
end

local function find_chop(item, inst)
	print("wargonbrain chop", 1)
	if not inst.components.wargonbrain:HasTag("chop") then 
	print("wargonbrain chop", 2)
		return 
	end
	print("wargonbrain chop", 3)
	return find_workable(item, inst, ACTIONS.CHOP) and inst.components.growable
		and inst.components.growable.stage == 3
end

local function chop(inst)
	return do_work(inst, find_chop, ACTIONS.CHOP)
end

local function find_hack(item, inst)
	return find_workable(item, inst, ACTIONS.HACK) 
		and inst.components.hackable:CanBeHacked()
end

local function hack(inst)
	return do_work(inst, find_hack, ACTIONS.HACK)
end

local function find_mine(item, inst)
	return find_workable(item, inst, ACTIONS.MINE)
end

local function mine(inst)
	return do_work(inst, find_mine, ACTIONS.MINE)
end

local function pick_up(inst)
	local pick_tags = inst.components.wargonbrain.pick_tags
	local target = WARGON.find(inst, 10, nil, pick_tags)
	if target then
		return BufferedAction(inst, target, ACTIONS.PICKUP)
	end
end

local fns = {
	find_food = find_food,
	follow = get_leader,
	leash = no_leader_home_pos,
	wander = no_leader_home_pos,
	run_away = run_away,
	chop = chop,
	hack = hack,
	mine = mine,
	pick_up = pick_up,
	go_home = go_home,
	-- speical = speical,
}

local WargonBrain = Class(function(self, inst)
	self.inst = inst
	self.tags = {}
	self.fns = fns
	self.pick_tags = {}
	self.scary_tags = {}
end)

function WargonBrain:HasTag(tag)
	for k, v in pairs(self.tags) do
		if v == tag then
			return true
		end
	end
	return false
end

function WargonBrain:AddTag(tag)
	if not self:HasTag(tag) then
		table.insert(self.tags, tag)
	end
end

function WargonBrain:AddTags(tags)
	for k, v in pairs(tags) do
		self:AddTag(v)
	end
end

function WargonBrain:RemoveTag(tag)
	if self:HasTag(tag) then
		for i, v in pairs(self.tags) do
			if v == tag then
				table.remove(self.tags, i)
			end
		end
	end
end

function WargonBrain:RemoveTags(tags)
	for k, v in pairs(tags) do
		self:RemoveTag(v)
	end
end

function WargonBrain:Can(tag)
	return self:HasTag(tag)
end

function WargonBrain:GetFn(tag)
	return self.fns[tag]
end

function WargonBrain:SetBehaviour(tag, fn)
	self.fns[tag] = fn
end

return WargonBrain