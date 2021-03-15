local _B = WARGON.BRAIN

_B.need_bh({'wander', 'runaway', 'doaction', 'panic'})
-- cmp:inv, ex:eater, health, homeseeker
local stop_run_dist = 10
local see_player_dist = 5
local see_food_dist = 20
local see_plant_dist = 40
local max_wander_dist = 80

local function is_plant(item)
	return item.components.pickable
       and item.components.pickable:CanBePicked()
       and (item.components.pickable.product == "twigs"
       or item.components.pickable.product == "cutgrass"
       or item.components.pickable.product == "berries")
end

local function is_bush(item)
	return item:HasTag('bush')
end

local function get_home(inst)
	local home = WARGON.find(inst, see_plant_dist, is_bush)
	return home or (inst.components.homeseeker and inst.components.homeseeker.home)
end

local function home_pos(inst)
	local home = get_home(inst)
	if home then
		return Vector3(home.Transform:GetWorldPosition())
	end
end

local function store_home(inst)
	local home = get_home(inst)
	if home and #inst.components.inventory.itemslots > 0 then
		return BufferedAction(inst, home, ACTIONS.TP_PERD_STORE)
	end
end

local function eat_food(inst)
	local target = nil
	if inst.components.eater then
		if inst.components.inventory then
			target = inst.components.inventory:FindItem(function(item)
				return inst.components.eater:CanEat(item)
			end)
		end
		if not target then
			target = WARGON.find(inst, see_food_dist, function(item)
				return inst.components.eater:CanEat(item)
			end)
			if target then
				local predator = WARGON.find_close(target, "scarytoprey", see_player_dist)
				if predator and not predator:HasTag("player") then target = nil end
			end
		end
		if target then
			return BufferedAction(inst, target, ACTIONS.EAT)
		end
	end
end

local function pick_plant(inst)
	local target = WARGON.find(inst, see_food_dist, is_plant)
	if target then
		local scary_tag = "scarytoprey"
		-- 	if type(scary_test) == "string" then
		-- 		scary_tag = scary_test
		-- 	end
		local predator = WARGON.find_close(inst, scary_tag, see_player_dist)
		if predator and not predator:HasTag("player") then target = nil end
	end
	if target then
		return BufferedAction(inst, target, ACTIONS.PICK)
	end
end

local TpPerdBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function TpPerdBrain:OnStart()
	local clock = GetClock()

	local root = PriorityNode(
	{
		WhileNode(function()
			return self.inst.components.health and self.inst.components.health.takingfiredamage
		end, "OnFire", Panic(self.inst)),
		WhileNode(function()
			return clock and not clock:IsDay()
		end, "IsNight", DoAction(self.inst, store_home, "Store Home", true)),
		EventNode(self.inst, 'perd store',
			DoAction(self.inst, store_home, 'store_home', true)),
		DoAction(self.inst, eat_food, "Eat Food"),
		RunAway(self.inst, "scarytoprey", see_player_dist, stop_run_dist),
		DoAction(self.inst, pick_plant, "Pick Plant", true),
		Wander(self.inst, home_pos, max_wander_dist),
	}, .25)
	self.bt = BT(self.inst, root)
end

return TpPerdBrain