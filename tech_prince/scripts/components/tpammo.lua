local TpAmmo = Class(function(self, inst)
	self.inst = inst
end)

function TpAmmo:CollectUseActions(doer, target, actions)
	if target.components.tpbullets
	and not target.components.tpbullets:IsFull() then
		table.insert(actions, ACTIONS.TP_LOAD_AMMO)
	end
end

return TpAmmo