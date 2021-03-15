local TpPrefabSpawner = Class(function(self, inst)
	self.inst = inst
	self.prefabs = {}
end)

function TpPrefabSpawner:AddPrefab(name)
	self.prefabs[name] = false
end

function TpPrefabSpawner:TriggerPrefab(name)
	self.prefabs[name] = true
end

function TpPrefabSpawner:CanSpawn(name)
	return not self.prefabs[name]
end

function TpPrefabSpawner:GetPrefab(name)
	return self.prefabs[name]
end

function TpPrefabSpawner:OnSave()
	return {prefabs = self.prefabs}
end

function TpPrefabSpawner:OnLoad(data)
	if data then
		self.prefabs = data.prefabs or {}
	end
end

return TpPrefabSpawner