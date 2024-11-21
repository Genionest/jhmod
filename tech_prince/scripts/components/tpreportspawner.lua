local TpReportSpawner = Class(function(self, inst)
	self.inst = inst
	self.aaa = nil
	self.aaf = nil
end)

function TpReportSpawner:Spawn()
	-- if self.aaa and not self.aad and c_find("tp_update") == nil then
	-- 	local pos = WARGON.around_land(self.inst, math.random(3,4))
	-- 	if pos then
	-- 		WARGON.make_spawn(pos, "tp_reporter7")
	-- 		self.aad = true
	-- 	end
	-- end
	if not self.aaf then
		local pos = WARGON.around_land(self.inst, math.random(3,4))
		if pos then
			WARGON.make_spawn(pos, "tp_reporter7")
			self.aaf = true
		end
	end
end

function TpReportSpawner:OnSave()
	return {
		aaa = self.aaa,
		aaf = self.aaf,
	}
end

function TpReportSpawner:OnLoad(data)
	if data then
		self.aaa = data.aaa or nil
		self.aaf = data.aaf or nil
	end
end

return TpReportSpawner