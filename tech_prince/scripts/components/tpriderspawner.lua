local TpRiderSpawner = Class(function(self, inst)
	self.inst = inst
	self.inst:ListenForEvent("killed", function(inst, data)
		if data.victim and data.victim:HasTag("beefalo") then
			self:Trigger(data)
		end
	end)
end)

function TpRiderSpawner:Trigger()
	local days = GetClock().numcycles
	local rand = math.min(days, 10) * 0.09
	local judge = math.random()
	print("TpRiderSpawner", judge)
	if judge > .99-rand then
		local rider = c_find('tp_sign_rider')
		if rider == nil then
			local inst = self.inst
			local radius = 25 + math.random(5)
			local pos = WARGON.around_land(inst, radius)
			if pos and WARGON.on_land(inst, pos) then
				local new = WARGON.make_spawn(pos, "tp_sign_rider")
			end
		end
	end
end

return TpRiderSpawner