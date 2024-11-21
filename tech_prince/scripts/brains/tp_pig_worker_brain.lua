local _B = WARGON.BRAIN
_B.need_bh({
	'wander', 'leash', 'runaway', 'doaction', 'panic',
	})
local max_wander_dist = 20
local leash_return_dist = 10
local leash_max_dist = 30
local see_target_dist = 20
-- 伐木，回家，捡东西，拴住，乱跑
local function home_near(inst, item)
	local home = inst.components.homeseeker and inst.components.homeseeker.home
	if home then
		return item:IsNear(home, see_target_dist)
	end
	return true
end

local function pick_up(inst)
	local tags = inst.brain_pick_tags
	local target = WARGON.find(inst, see_target_dist, nil, tags, {'fire'})
	if target and target.components.inventoryitem
	and not inst.components.inventory:IsFull()
	and home_near(inst, target) then
		return BufferedAction(inst, target, ACTIONS.PICKUP)
	end
end

local function chop_tree(inst)
	if inst:HasTag("tp_chop_pig") then
		local function find_tree(item, inst)
			if not home_near(inst, item) then 
				return 
			end
			if item.components.workable
			and item.components.workable.action == ACTIONS.CHOP then
				if item.components.growable 
				and item.components.growable.stage == 3 then
					return true
				end
			end
		end
		local target = WARGON.find(inst, see_target_dist, find_tree, {'tp_chop_pig_target'}, {'fire', 'burnt', 'stump'})
		if target then
			return BufferedAction(inst, target, ACTIONS.CHOP)
		end
	end
end

local function hack_action(inst)
	if inst:HasTag("tp_hack_pig") then
		local function find_hackable(item, inst)
			if not home_near(inst, item) then 
				return 
			end
			if item.components.hackable and item.components.hackable:CanBeHacked() then
				return true
			end
		end
		local target = WARGON.find(inst, see_target_dist, find_hackable, {'tp_hack_pig_target'}, {'fire', 'burnt'})
		if target then
			return BufferedAction(inst, target, ACTIONS.HACK)
		end
	end
end

local function plant_farm(inst)
	if inst:HasTag("tp_farm_pig") then
		local function find_farm(item, inst)
			if not home_near(inst, item) then 
				return 
			end
			if item.components.grower and item.components.grower:IsEmpty() then
				return true
			end
		end
		local target = WARGON.find(inst, see_target_dist, find_farm, {'tp_farm_pig_target'}, {'burnt', 'fire'})
		if target then
			local seed = inst.components.inventory:FindItem(function(item)
				return string.find(item.prefab, 'seeds')
			end)
			if seed then
				return BufferedAction(inst, target, ACTIONS.PLANT, seed)
			end
		end
	end
end

local function has_home(inst)
	local home = nil
	if inst.components.homeseeker then
		home = inst.components.homeseeker.home
	end
	if home and home:IsValid() then
		if home.components.burnable and not inst.components.burnable:IsBurning() then
			if not home:HasTag("burnt") then
				return home
			end
		end
	end
end

local function get_home_pos(inst)
	if has_home(inst) then
		return inst.components.homeseeker:GetHomePos()
	end
end

local function go_home(inst)
	local home = has_home(inst)
	if home then
		return BufferedAction(inst, home, ACTIONS.GOHOME)
	end
end

local WorkerBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function WorkerBrain:OnStart()
	local root = PriorityNode({
		WhileNode(function()
			return self.inst.components.health and self.inst.components.health.takingfiredamage
		end, 'OnFire', Panic(self.inst)),
		EventNode(self.inst, 'gohome',
			DoAction(self.inst, go_home, 'go_home', true)),
		DoAction(self.inst, chop_tree, 'chop_tree', true),
		DoAction(self.inst, hack_action, 'hack_action', true),
		DoAction(self.inst, plant_farm, 'plant_farm', true),
		DoAction(self.inst, pick_up, 'pick_up', true),
		Leash(self.inst, get_home_pos, leash_max_dist, leash_return_dist),
		Wander(self.inst, get_home_pos, max_wander_dist),
	}, .25)
	self.bt = BT(self.inst, root)
end

return WorkerBrain