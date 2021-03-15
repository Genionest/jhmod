local TpMove = Class(function(self, inst)
	self.inst = inst
	self.action = "TP_CI"
end)

function TpMove:CanAction()
	if self.inst.components.tprecharge then
        return self.inst.components.tprecharge:IsRecharged()
    end
    return true
end

local function get_action(actions, act)
	table.insert(actions, ACTIONS[act])
end

function TpMove:CollectPointActions(doer, pos, actions, right)
    if right and self:CanAction() then
    	return get_action(actions, self.action)
	end
end

function TpMove:CollectEquippedActions(doer, target, actions, right)
	if right and self:CanAction() then
		if self.inst:HasTag("tp_move_no_target") then
			return
		end
		if not (self.inst:HasTag("tp_move_combat")
		and target.components.combat
		and target.components.health 
		and doer.components.combat
		and doer.components.combat:CanTarget(target)) then
			return
		end
		get_action(actions, self.action)
	end
end

return TpMove