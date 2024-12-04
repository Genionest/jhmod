require "behaviours/chaseandattack"
require "behaviours/wander"

local max_wander_dist = 20
local max_chase_time = 10
local max_chase_dist = 30
local see_target_dist = 20

-- 莽夫
local TpCreatureBrain2 = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function TpCreatureBrain2:OnStart()
	local root = PriorityNode({
		ChaseAndAttack(self.inst, max_chase_time, max_chase_dist),
		Wander(self.inst, nil, max_wander_dist),
		}, .5)
	self.bt = BT(self.inst, root)
end

return TpCreatureBrain2