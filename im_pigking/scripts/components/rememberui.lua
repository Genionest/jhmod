local RememberUI = Class(function(self, inst)
	self.inst = inst
	self.pos = Vector3(1400, 880, 0)
end)

function RememberUI:OnSave()
	return {
		x = self.pos.x,
		y = self.pos.y,
	}
end

function RememberUI:OnLoad(data)
	if data then
		if data.x then
			self.pos.x = data.x
		end
		if data.y then
			self.pos.y = data.y
		end
	end
end

return RememberUI