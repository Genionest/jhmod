local _B = WARGON.BRAIN
_B.need_bh({
	'chaseandattack', 'wander', 'faceentity', 'follow', 'standstill',
	})

local min_follow_dist = 2
local max_follow_dist = 9
local target_follow_dist = (max_follow_dist+min_follow_dist)/2
local max_chase_time = 10
local trade_dist = 20
local see_food_dist = 15
local find_food_hunger_percent = .75
local start_run_dist = 4
local stop_run_dist = 6

local function is_hunger(inst)
	return inst.components.hunger and inst.components.hunger:GetPercent() < find_food_hunger_percent
end

local function is_starving(inst)
	return inst.components.hunger and inst.components.hunger:IsStarving()
end

local function should_stand_still(inst)
	return inst:HasTag('tp_small_bird_stand')
end

local function has_food(inst)
	local notags = {"FX", "NOCLICK", "DECOR","INLIMBO", "hydrofarm"}
    local target = WARGON.find(inst, see_food_dist, function(item) 
    	return inst.components.eater:CanEat(item) 
    end, nil, notags)
    if target then
	    return target
    end
end

local function find_food(inst)
	local target = has_food(inst)
	if target then
		return BufferedAction(inst, target, ACTIONS.EAT)
	end
end

local function get_trader(inst)
	local leader = inst.components.follower and inst.components.follower.leader
	if leader and inst.components.trader:IsTryingToTradeWithMe(leader) then
		return leader
	end
end

local function keep_trade(inst, target)
	return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function get_leader(inst)
	if inst.components.follower then
		return inst.components.follower.leader
	end
end

local function get_leader_pos(inst)
	local leader = get_leader(inst)
	if leader then
		return leader:GetPosition()
	end
end

local TpSmallBirdBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function TpSmallBirdBrain:OnStart()
	local root = PriorityNode({
		FaceEntity(self.inst, get_trader, keep_trade),
		StandStill(self.inst, should_stand_still),
		DoAction(self.inst, find_food, 'find_food', true),
		ChaseAndAttack(self.inst, max_chase_time),
		RunAway(self.inst, 'tallbird', start_run_dist, stop_run_dist),
		Follow(self.inst, get_leader, min_follow_dist-1.5, target_follow_dist, max_follow_dist),
		Wander(self.inst, get_leader_pos, max_follow_dist-1, 
			{minwalktime=.5, randwalktime=.5, minwaittime=6, randwaittime=3}),
	}, .25)
	self.bt = BT(self.inst, root)
end

return TpSmallBirdBrain