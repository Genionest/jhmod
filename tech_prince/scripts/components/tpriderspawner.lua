local TpRiderSpawner = Class(function(self, inst)
	self.inst = inst
	self.inst:ListenForEvent("killed", function(inst, data)
		if data.victim and data.victim:HasTag("beefalo") then
			self:Trigger()
		end
	end)
end)

function TpRiderSpawner:Trigger()
	-- local days = GetClock().numcycles
	-- local rand = math.min(days, 10) * 0.09
	local judge = math.random()
	local days = GetClock():GetNumCycles()
	local must = GetPlayer().components.tpprefabspawner:CanSpawn("tp_sign_rider") and days > 40
	print("TpRiderSpawner", judge)
	if judge <= 1/40 or must then
		if must then
			GetPlayer().components.tpprefabspawner:TriggerPrefab("tp_sign_rider")
		end
		local rider = c_find('tp_sign_rider')
		if rider == nil then
			local inst = self.inst
			inst.SoundEmitter:PlaySound("dontstarve/creatures/krampus/beenbad_lvl3")
			local radius = 25 + math.random(5)
			local pos = WARGON.around_land(inst, radius)
			if pos and WARGON.on_land(inst, pos) then
				local new = WARGON.make_spawn(pos, "tp_sign_rider")
			end
		end
	end
end

return TpRiderSpawner