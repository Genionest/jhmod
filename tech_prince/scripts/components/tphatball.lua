local TpHatBall = Class(function(self, inst)
	self.inst = inst
end)

function TpHatBall:Trigger()
	local inst = self.inst
	local guy = WARGON.find(inst, 1, nil, {"tp_strawhat_target"})
	if guy then
		if guy:HasTag("tp_strawhat_perd") then
			-- local perd = WARGON.make_spawn(guy, 'tp_perd')
			-- guy:Remove()
			guy.tp_perd = true
			guy:SetBrain(require "brains/tp_perd_brain")
			guy.AnimState:Show("HAT")
			guy.AnimState:OverrideSymbol("swap_hat", "strawhat_cowboy", "swap_hat")
		elseif guy:HasTag("tp_strawhat_beefalo") then
			-- local beefalo = WARGON.make_spawn(guy, "tp_beefalo")
			-- guy:Remove()
			guy.components.domesticatable:DeltaObedience(1)
	        GetPlayer():PushEvent("saddle", { target = guy })
	        local item = SpawnPrefab("tp_strawhat_saddle")
	        guy.components.rideable:SetSaddle(GetPlayer(), item)
		elseif guy:HasTag("canbetrapped") and guy:HasTag("smallcreature") then
			local trap = WARGON.make_spawn(guy, "tp_strawhat_trap")
			trap.components.trap:Set()
		else
			local item = SpawnPrefab("tp_strawhat2")
			local percent = inst.components.finiteuses:GetPercent()
			item.components.fueled:SetPercent(percent)
			local current = guy.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
			if current then
				guy.components.inventory:DropItem(current)
			end
			guy.components.inventory:Equip(item)
			guy.AnimState:Show('hat')
			if giver.components.leader then
				guy.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
				giver.components.leader:AddFollower(guy)
				guy.components.follower:AddLoyaltyTime(30 * 16)
			end
		end
		inst:Remove()
	end
end

return TpHatBall
