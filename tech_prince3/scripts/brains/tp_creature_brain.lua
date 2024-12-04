require "behaviours/chaseandattack"
require "behaviours/wander"
require "behaviours/runaway"

local max_wander_dist = 20
local max_chase_time = 10
local max_chase_dist = 30
local see_target_dist = 20
local run_away_dist = 5
local stop_run_away_dist = 8

-- 走位战士
local TpCreatureBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function TpCreatureBrain:OnStart()
	local root = PriorityNode({
		 WhileNode( function() 
		 	return self.inst.components.combat.target == nil 
		 		or not self.inst.components.combat:InCooldown() 
		 	end, "need attack",
            ChaseAndAttack(self.inst, max_chase_time, max_chase_dist )
        ),
        WhileNode( function() 
        	return self.inst.components.combat.target 
        		and self.inst.components.combat:InCooldown() 
        	end, "need run away",
            RunAway(self.inst, function() 
            	return self.inst.components.combat.target 
            end, run_away_dist, stop_run_away_dist) 
        ),
		Wander(self.inst, nil, max_wander_dist),
		}, .5)
	self.bt = BT(self.inst, root)
end

return TpCreatureBrain