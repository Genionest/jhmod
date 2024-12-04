local TpSmearItem = Class(function(self, inst)
    self.inst = inst
    self.id = nil
end)

function TpSmearItem:Test(target, doer)
    if target.components.tp_smearable
	and target.components.tp_smearable:CanSmear(self.inst, doer) then
        return true
    end
end

function TpSmearItem:CollectUseActions(doer, target, actions, right)
	if right and self:Test(target, doer) then
		table.insert(actions, ACTIONS.TP_SMEAR)
	end
end

return TpSmearItem