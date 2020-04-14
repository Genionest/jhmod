local MonkeySpawn = Class(function(self, inst)
	self.inst = inst
	self.is_spawn = nil
	self.time = 0

	inst:AddTag("spawn_monkey")
	inst:ListenForEvent("death", function()
		if inst:HasTag("spawn_monkey") then
			local ms = GetPlayer().components.monkeyspawner
			if ms then
				ms:DoDelta(-1)
			end
		end
	end)
end)

function MonkeySpawn:IsSpawn()
	return self.is_spawn
end

function MonkeySpawn:Back()
	if not self:IsSpawn() then
		return
	end
	local leader = self.inst.components.follower.leader
	if leader then
		local beard = SpawnPrefab("monkey_beardhair")
		leader.components.inventory:GiveItem(beard)
		leader.components.monkeyspawner:DoDelta(-1)
		-- ms.num = math.max(0, ms.num-1)
		local inv = self.inst.components.inventory
		-- self.inst.components.inventory:TransferInventory(leader)
		for k,v in pairs(inv.itemslots) do
			if v.prefab ~= "poop" then
		        leader.components.inventory:GiveItem(inv:RemoveItemBySlot(k))
		    end
	    end
	end
	SpawnPrefab("statue_transition").Transform:SetPosition(self.inst.Transform:GetWorldPosition())
	self.inst:Remove()
end

function MonkeySpawn:SetTime(time)
	self.time = time
	self.is_spawn = true
	self.inst:DoTaskInTime(self.time, function()
		self:Back()
	end)
end

function MonkeySpawn:OnSave()
	self.time = self.time - self.inst:GetTimeAlive()
	return {time = self.time, is_spawn = self.is_spawn}
end

function MonkeySpawn:OnLoad(data)
	if data then
		self.time = data.time or 0
		self.is_spawn = data.is_spawn or nil
	end
	if self.is_spawn then
		self.inst:DoTaskInTime(self.time, function()
			self:Back()
		end)
	end
end

return MonkeySpawn