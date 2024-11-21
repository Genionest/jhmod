local TpUse = Class(function(self, inst)
	self.inst = inst
end)

function TpUse:CanUse()
	if self.can then
		return self.can(self.inst)
	end
	return true
end

function TpUse:Use(doer)
	if self.use then
		self.use(self.inst, doer)
	end
end

function TpUse:CollectSceneActions(doer, actions, right)
	if right and self:CanUse() then
		return table.insert(actions, ACTIONS.TP_USE)
	end
end

return TpUse