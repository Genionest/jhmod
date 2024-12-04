local WgInterableItem = Class(function(self, inst)
	self.inst = inst
end)

function WgInterableItem:SetFn(fn)
	self.interact_fn = fn
end

function WgInterableItem:SetTestFn(fn)
	self.test = fn
end

function WgInterableItem:CanInteract(target, doer)
	if self.test then
		return self.test(self.inst, target, doer)
	end
	return true
end

function WgInterableItem:CollectUseActions(doer, target, actions, right)
	if right and self:CanInteract(target, doer)
	and target.components.wg_interable
	and target.components.wg_interable:CanInteract(self.inst, doer) then
		table.insert(actions, ACTIONS.WG_INTERACT)
	end
end

return WgInterableItem