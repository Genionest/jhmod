require "behaviours/follow"
require "behaviours/wander"
require "behaviours/runaway"

local TpBullDozerBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local MIN_FOLLOW = 4
local MAX_FOLLOW = 11
local MED_FOLLOW = 6
local MAX_WANDER_DIST = 10
local MAX_CHASE_TIME = 6

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function CreatePile(inst)
	local fertilizer = inst:wg_find("fertilizer")
	if fertilizer then

	end
end

function TpBullDozerBrain:OnStart()

    local root = PriorityNode(
    {
		ChaseAndAttack(self.inst, MAX_CHASE_TIME),
		Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW, MED_FOLLOW, MAX_FOLLOW, true),
        -- Wander(self.inst, function() return Point(GetPlayer().Transform:GetWorldPosition()) end , MAX_WANDER_DIST)        
    }, .5)
        
    self.bt = BT(self.inst, root)
         
end


return TpBullDozerBrain