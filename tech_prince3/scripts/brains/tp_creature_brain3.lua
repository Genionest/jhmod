require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
local EntUtil = require "extension.lib.ent_util"

local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5
local SEE_FOOD_DIST = 20
local SEE_BUSH_DIST = 40
local MAX_WANDER_DIST = 80

-- 胆小鬼
local TpCreatureBrain3 = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function HomePos(inst)
    -- local bush = FindNearestBush(inst)
    -- if bush then
    --     return Vector3(bush.Transform:GetWorldPosition() )
    -- end
end

local function ShouldRunAway(inst)
    local tags = {
        "scarytoprey", "monster", "hostile",
    }
    local target = FindEntity(inst, SEE_PLAYER_DIST, function(target)
        if target.components.combat and target.components.combat.target == inst then
            return true
        end
        for k, v in pairs(tags) do
            if target:HasTag(v) then
                return true
            end
        end
    end, nil, EntUtil.not_entity_tags)
    return target
end

function TpCreatureBrain3:OnStart()
    local clock = GetClock()
    
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        RunAway(self.inst, ShouldRunAway, SEE_PLAYER_DIST, STOP_RUN_DIST),
        Wander(self.inst, HomePos, MAX_WANDER_DIST),
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return TpCreatureBrain3