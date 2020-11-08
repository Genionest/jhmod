local TpInter = Class(function(self, inst)
	self.inst = inst
end)

function TpInter:SetFn(fn)
	self.inter_fn = fn
end

function TpInter:SetCanFn(fn)
	self.can_inter = fn
end

function TpInter:CanInter(item, doer)
	if self.can_inter then
		return self.can_inter(self.inst, item, doer)
	end
	return true
end

function TpInter:Interact(item, doer)
	if self.inter_fn then
		self.inter_fn(self.inst, item, doer)
	end
	if item.components.tpinterable
	and item.components.tpinterable.interable_fn then
		item.components.tpinterable.interable_fn(item, self.inst, doer)
	end
end

return TpInter