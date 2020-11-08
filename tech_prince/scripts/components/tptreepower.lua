local TpTreePower = Class(function(self, inst)
	self.inst = inst
	self.power = 0
	self.powered = nil
end)

function TpTreePower:SetPower(n)
	if n > 0 and self.power <= 0 then
		
	end
end

function TpTreePower:OnSave()
	return {
		power = self.power,
		powered = self.powered,
	}
end

function TpTreePower:OnLoad(data)
	if data then
		self.powered = data.powered
		self.power = data.power or 0
		self:SetPower(self.power)
	end
end

return TpTreePower

--[[
光照
回san
哨兵
落叶
荆棘
温暖
]]