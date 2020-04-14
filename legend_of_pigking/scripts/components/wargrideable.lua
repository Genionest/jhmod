local WargRideable = Class(function(self, inst)
	self.inst = inst
end)

function WargRideable:CollectSceneActions(doer, actions, right)
	if right and doer.components.wargrider then 
		if not doer.components.wargrider:IsRiding() then
			table.insert(actions, ACTIONS.RIDE_WARG)
		else
			table.insert(actions, ACTIONS.DISRIDE_WARG)
		end
	end
end

return WargRideable