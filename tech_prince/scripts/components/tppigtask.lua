local TpPigTask = Class(function(self, inst)
	self.inst = inst
	self.num = 0
	self.max = 11
end)

function TpPigTask:ThrowItem(item)
	local nug = SpawnPrefab(item)
	WARGON.pigking_throw(self.inst, nug)	
end

function TpPigTask:Throw(item)
	if type(item) == "table" then
		for k, v in pairs(item) do
			self:ThrowItem(v)
		end
	else
		self:ThrowItem(item)
	end
end

function TpPigTask:Trigger()
	self.num = math.min(self.num + 1, self.max)
	if self.num == 1 then
		-- self:Throw("tp_desk_bp")
	elseif self.num == 5 then
		-- self:Throw("tp_chest_bp")
	elseif self.num == 10 then
		self:Throw({
			"tp_chop_pig_home_bp",
			"tp_hack_pig_home_bp",
			"tp_farm_pig_home_bp",
		})
	end
end

function TpPigTask:OnSave()
	return {num = self.num}
end

function TpPigTask:OnLoad(data)
	if data then
		self.num = data.num or 0
	end
end

return TpPigTask