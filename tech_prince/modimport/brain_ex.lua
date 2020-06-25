local function need_bh(files)
	for i, v in pairs(files) do
		require("behaviours/"..v)
	end
end

local function animal_brain(plant_fn, home_fn, scary_test)
	need_bh({'wander', 'runaway', 'doaction', 'panic'})
	-- cmp:inv, ex:eater, health, homeseeker
	local stop_run_dist = 10
	local see_player_dist = 5
	local see_food_dist = 20
	local see_plant_dist = 40
	local max_wander_dist = 80

	local function get_home(inst)
		local home = WARGON.find(inst, see_plant_dist, home_fn)
		-- if inst.components.homeseeker and inst.components.homeseeker.home then
		-- 	home = inst.components.homeseeker.home
		-- end
		return home or (inst.components.homeseeker and inst.components.homeseeker.home)
	end

	local function home_pos(inst)
		local home = get_home(inst)
		if home then
			return Vector3(home.Transform:GetWorldPosition())
		end
	end

	local function go_home(inst)
		local home = get_home(inst)
		if home then
			return BufferedAction(inst, home, ACTIONS.GOHOME, nil, home_pos(inst))
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
					local scary_tag = "scarytoprey"
					if type(scary_test) == "string" then
						scary_tag = scary_test
					end
					local predator = WARGON.find_close(target, scary_tag, see_player_dist)
					if predator and not predator:HasTag("player") then target = nil end
				end
			end
			if target then
				return BufferedAction(inst, target, ACTIONS.EAT)
			end
		end
	end

	local function pick_plant(inst)
		local ddebug = WARGON.add_print
		local target = WARGON.find(inst, see_food_dist, plant_fn)
		if target then
			local scary_tag = "scarytoprey"
				if type(scary_test) == "string" then
					scary_tag = scary_test
				end
			local predator = WARGON.find_close(inst, scary_tag, see_player_dist)
			if predator and not predator:HasTag("player") then target = nil end
		end
		if target then
			return BufferedAction(inst, target, ACTIONS.PICK)
		end
	end

	local AnimalBrain = Class(Brain, function(self, inst)
		Brain._ctor(self, inst)
	end)

	function AnimalBrain:OnStart()
		local clock = GetClock()

		local root = PriorityNode(
		{
			WhileNode(function()
				return self.inst.components.health and self.inst.components.health.takingfiredamage
			end, "OnFire", Panic(self.inst)),
			WhileNode(function()
				return clock and not clock:IsDay()
			end, "IsNight", DoAction(self.inst, go_home, "Go Home", true)),
			DoAction(self.inst, eat_food, "Eat Food"),
			RunAway(self.inst, scary_test, see_player_dist, stop_run_dist),
			DoAction(self.inst, pick_plant, "Pick Plant", true),
			Wander(self.inst, home_pos, max_wander_dist),
		}, .25)
		self.bt = BT(self.inst, root)
	end

	return AnimalBrain
end

local function create_brain()
	need_bh({'wander', 'runaway', 'doaction', 'panic', 'follow', 'chaseandattack'})
	local min_follow_dist = 2
	local target_follow_dist = 5
	local max_follow_dist = 9
	local max_wander_dist = 20
	local leash_return_dist = 10
	local leash_max_dist = 30
	local start_run_dist = 3
	local stop_run_dist = 5
	local max_chase_time = 10
	local max_chase_dist = 30
	local trade_dist = 20
	local see_target_dist = 20
	local see_food_dist = 10
	local run_away_dist = 5
	local stop_run_away_dist = 8

	local SampleBrain = Class(Brain, function(self, inst)
		Brain._ctor(self, inst)
	end)

	function SampleBrain:OnStart()
		local function get_brain_fn(behaviours)
			return self.inst.components.wargonbrain:GetFn(behaviours)
		end 

		local function action_node(behaviours)
			return WhileNode(function()
				return self.inst.components.wargonbrain:Can(behaviours)
			end, behaviours,
			DoAction(self.inst, get_brain_fn(behaviours), behaviours))
		end

		local root = PriorityNode({
			WhileNode(function()
				if self.inst.components.wargonbrain:Can("on_fire") then
					return self.inst.components.health and self.inst.components.health.takingfiredamage
				end
			end, 'OnFire', Panic(self.inst)),
			WhileNode(function() 
				return self.inst.components.wargonbrain:Can("chase_and_attack")
			end, "ChaseAndAttack", 
			ChaseAndAttack(self.inst, max_chase_time, max_chase_dist)),
			WhileNode(function()
				return self.inst.components.wargonbrain:Can("go_home")
			end, "go_home", EventNode(self.inst, "gohome", 
				DoAction(self.inst, get_brain_fn("go_home"), "go_home"))),
			action_node("find_food"),
			action_node("pick_up"),
			action_node("chop"),
			action_node("hack"),
			action_node("mine"),
			action_node("special"),
			WhileNode(function()
				return self.inst.components.wargonbrain:Can("follow")
			end, "Follow", 
			Follow(self.inst, get_brain_fn("follow"), min_follow_dist, target_follow_dist, max_follow_dist)),
			WhileNode(function()
				return self.inst.components.wargonbrain:Can("leash")
			end, "Leash", 
			Leash(self.inst, get_brain_fn("leash"), leash_max_dist, leash_return_dist)),
			WhileNode(function()
				return self.inst.components.wargonbrain:Can("run_away")
			end, "RunAway", 
			RunAway(self.inst, function(guy)
				local fn = get_brain_fn("run_away")
				return fn(self.inst, guy)
			end, start_run_dist, stop_run_dist)),
			WhileNode(function()
				return self.inst.ccmponents.wargonbrain:Can("wander")
			end, "Wander", 
			Wander(self.inst, get_brain_fn("wander"), max_wander_dist)),
		}, .5)
		self.bt = BT(self.inst, root)
	end

	return SampleBrain
end

local function worker_brain()
	need_bh({'wander', 'leash', 'runaway', 'doaction', 'panic'})
	local max_wander_dist = 20
	local leash_return_dist = 10
	local leash_max_dist = 30
	local see_target_dist = 20
	-- 伐木，回家，捡东西，拴住，乱跑
	local function pick_up(inst)
		-- local tags = inst.components.wargonbrain.pick_tags
		local tags = inst.brain_pick_tags
		local target = WARGON.find(inst, see_target_dist, nil, tags)
		if target and target.components.inventoryitem then
			return BufferedAction(inst, target, ACTIONS.PICKUP)
		end
	end

	local function chop_tree(inst)
		if not inst:HasTag("tp_chop_pig") then
			return
		end
		local function find_tree(item, inst)
			if item.components.workable 
			and item.components.workable.action == ACTIONS.CHOP then
				if item.components.growable and not item:HasTag("stump")
				and item.components.growable.stage == 3 then
					return true
				end
			end
		end
		local target = WARGON.find(inst, see_target_dist, find_tree)
		if target then
			return BufferedAction(inst, target, ACTIONS.CHOP)
		end
	end

	local function hack_action(inst)
		if not inst:HasTag("tp_hack_pig") then
			return
		end
		local function find_hackable(item, inst)
			if item.components.hackable and item.components.hackable:CanBeHacked() then
				return true
			end
		end
		local target = WARGON.find(inst, see_target_dist, find_hackable)
		if target then
			return BufferedAction(inst, target, ACTIONS.HACK)
		end
	end

	local function plant_farm(inst)
		if not inst:HasTag("tp_farm_pig") then
			return
		end
		local function find_farm(item, inst)
			if item.prefab == "fast_farmplot" or item.prefab == "slow_farmplot" then
				if item.components.grower and item.components.grower:IsEmpty() then
					return true
				end
			end
		end
		local target = WARGON.find(inst, see_target_dist, find_farm)
		if target then
			return BufferedAction(inst, targret, ACTIONS.PLANT)
		end
	end

	local function get_home_pos(inst)
		local home = nil
		if inst.components.homeseeker then
			home = inst.components.homeseeker.home
		end
		if home and home:IsValid() then
			if home.components.burnable and inst.components.burnable:IsBurning() then
				if not home:HasTag("burnt") then
					return inst.components.homeseeker:GetHomePos()
				end
			end
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
			EventNode(self.inst, "gohome", 
				DoAction(self.inst, get_home_pos, "go_home", true)),
			DoAction(self.inst, pick_up, 'pick_up', true),
			DoAction(self.inst, chop_tree, 'chop_tree', true),
			DoAction(self.inst, hack_action, 'hack_action', true),
			DoAction(self.inst, plant_farm, 'plant_fram', true),
			Leash(self.inst, get_home_pos, leash_max_dist, leash_return_dist),
			Wander(self.inst, get_home_pos, max_wander_dist),
		}, .5)
		self.bt = BT(self.inst, root)
	end

	return WorkerBrain
end

local function character_brain(day_active, scary_test)
	need_bh({'wander', 'follow', 'chaseandattack', 'runaway', 'doaction', 'panic'})

	local min_follow_dist = 2
	local target_follow_dist = 5
	local max_follow_dist = 9
	local max_wander_dist = 20
	local leash_return_dist = 10
	local leash_max_dist = 30
	local start_run_dist = 3
	local stop_run_dist = 5
	local max_chase_time = 10
	local max_chase_dist = 30
	local trade_dist = 20
	local see_target_dist = 20
	local see_food_dist = 10
	local run_away_dist = 5
	local stop_run_away_dist = 8

	local function can_run_away(inst, target)
		if inst.components.trader then
			return not inst.components.trader:IsTryingToTradeWithMe(target)
		end
	end

	local function get_trader(inst)
		if inst.components.trader then
			return WARGON.find(inst, trade_dist, function(target)
				return inst.components.trader:IsTryingToTradeWithMe(target)
			end, {'player'})
		end
	end

	local function keep_trader(inst, target)
		if inst.components.trader then
			return inst.components.trader:IsTryingToTradeWithMe(target)
		end
	end

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

	local CharacterBrain = Class(Brain, function(self, inst)
		Brain._ctor(self, inst)
	end)

	function CharacterBrain:OnStart()
		local clock = GetClock()
		local active = WhileNode(function()
			if clock then
				return clock:IsDay() == day_active
			end
		end, "IsActive",
			PriorityNode{
				DoAction(self.inst, find_food, 'find food'),
				Follow(self.inst, get_leader, min_follow_dist, target_follow_dist, max_follow_dist),
				Leash(self.inst, no_leader_home_pos, leash_max_dist, leash_return_dist),
				RunAway(self.inst, scary_test, start_run_dist, stop_run_dist),
				Wander(self.inst, no_leader_home_pos, max_wander_dist),
			}, .5)
		local passive = WhileNode(function()
			if clock then
				return not (clock:IsDay() == day_active)
			end
		end, "IsPassive",
			PriorityNode{
				DoAction(self.inst, find_food, 'find food'),
				RunAway(self.inst, scary_test, start_run_dist, stop_run_dist, function(target)
					can_run_away(self.inst, target)
				end),
				DoAction(self.inst, go_home, 'go home', true),
				Panic(self.inst),
			}, 1)
		local root = PriorityNode({
			WhileNode(function()
				return self.inst.components.health and self.inst.components.health.takingfiredamage
			end, 'OnFire', Panic(self.inst)),
			ChaseAndAttack(self.inst, max_chase_time, max_chase_dist),
			FaceEntity(self.inst, get_trader, keep_trader),
			active,
			passive,
		}, .5)
		self.bt = BT(self.inst, root)
	end

	return CharacterBrain
end

local function herd_brain()
	need_bh("wander", "doaction", "chaseandattack", "standstill")
	local stop_run_dist = 10
	local see_player_dist = 5
	local max_wander_dist = 20
	local see_target_dist = 6
	local max_chase_dist = 7
	local max_chase_time = 8
	local see_bait_dist = 20

	local function go_home(inst)
		if inst.components.homeseeker and inst.components.homeseeker.home
		and inst.components.homeseeker.home:IsValid() then
			return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
		end
	end
end

GLOBAL.WARGON_BRAIN_EX = {
	need_bh 		= need_bh,
	animal_brain 	= animal_brain,
	member_brain 	= character_brain,
	character_brain = character_brain,
	create_brain 	= create_brain,
	worker_brain	= worker_brain,
}

GLOBAL.WARGON.BRAIN = GLOBAL.WARGON_BRAIN_EX