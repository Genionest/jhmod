local DragonflyCage = Class(function(self, inst)
	self.inst = inst
	self.fly = nil
end)

function DragonflyCage:SetFly()
	local fly = SpawnPrefab("")
	self.fly = true
end

function DragonflyCage:OnSave()
	return {fly = self.fly}
end

return DragonflyCage