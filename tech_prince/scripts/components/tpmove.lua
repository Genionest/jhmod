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
	return table.insert(actions, ACTIONS[act])
end

function TpMove:CollectPointActions(doer, pos, actions, right)
    if right and self:CanAction() then
    	return get_action(actions, self.action)
	end
end

function TpMove:CollectEquippedActions(doer, target, actions, right)
	if right and self:CanAction() then
		return get_action(actions, self.action)
	end
end

return TpMove