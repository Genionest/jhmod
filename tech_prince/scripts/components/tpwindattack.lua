local TpWindAttack = Class(function(self, inst)
	self.inst = inst
end)

function TpWindAttack:CollectSceneActions(doer, actions, right)
	if doer and right and self.inst:HasTag("tp_wind_attack_target") then
		local weapon = doer.components.inventory 
			and doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if weapon and weapon:HasTag("tp_wind_attack") then
			table.insert(actions, ACTIONS.TP_WIND_ATTACK)
		end
	end
end

return TpWindAttack