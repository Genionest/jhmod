
local WgChatable = Class(function(self, inst)
	self.inst = inst
    self.fn = nil
end)

function WgChatable:CanChat(doer)
	if self.test then
		return self.test(self.inst, doer)
	end
	return true
end

function WgChatable:Chat(doer)
	if self.fn then
		self.fn(self.inst, doer)
	end
end

function WgChatable:CollectSceneActions(doer, actions, right)
	if right and self:CanChat(doer) then
		table.insert(actions, ACTIONS.WG_CHAT)
	end
end

return WgChatable