local _B = WARGON.BRAIN
_B.need_bh({
	'wander', 'runaway', 'doaction', 'panic', 'follow', 'chaseandattack'
	})
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