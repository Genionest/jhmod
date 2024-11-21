local TpInterable = Class(function(self, inst)
	self.inst = inst
end)

function TpInterable:SetFn(fn)
	self.interable_fn = fn
end

function TpInterable:CollectUseActions(doer, target, actions, right)
	if target.components.tpinter
	and target.components.tpinter:CanInter(self.inst, doer) then
		table.insert(actions, ACTIONS.TP_INTER)
	end
end

return TpInterable