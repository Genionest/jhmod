local MonkeySpawner = Class(function(self, inst)
	self.inst = inst
	self.max = 3
	self.num = 0
end)

function MonkeySpawner:Clear()
	print("spawn monkey have been cleared")
	for k,v in pairs(Ents) do
		if v.prefab == "primeape" and v:HasTag("spawn_monkey") then
			v:Remove()
		end
	end
	self.num = 0
end

function MonkeySpawner:DoDelta(dt)
	print("monkey spawn num change", dt)
	self.num = self.num + dt
	self.num = math.max(0, math.min(3, self.num))
end

function MonkeySpawner:Spawn()
	local can = true
	local inst = self.inst
	if not inst.components.inventory:Has("monkey_beardhair", 1) then
        if inst.components.talker then
            inst.components.talker:Say("俺的毛都拔光了") 
        end
        can = false
    end
    if can and self.num < self.max
   	and self.inst.components.monkeymana:EnoughMana(10) then
   		inst.components.inventory:ConsumeByName("monkey_beardhair", 1)
		-- inst.components.hunger:DoDelta(-1)
		local theta = math.random() * 2 * PI
	    local pt = inst:GetPosition()
	    local radius = math.random(3, 6)
	    local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	    if offset then
	        local image = SpawnPrefab("primeape")
	        local pos = pt + offset
	        image.Transform:SetPosition(pos:Get())
	    	self:DoDelta(1)
	    	-- self.num = math.min(3, self.num+1)
	        inst.components.leader:AddFollower(image)
        	image.components.follower:AddLoyaltyTime(35)
        	if image.components.monkeyspawn then
        		image.components.monkeyspawn:SetTime(30)
        	end
	        SpawnPrefab("statue_transition").Transform:SetPosition(pos:Get())
	    	SpawnPrefab("statue_transition_2").Transform:SetPosition(pos:Get())
	        if image:GetIsOnWater() then
	            image.components.monkeyspawn:Back()
	            inst.components.talker:Say("孩儿们不会水")
	        end
	        inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_appear")
	    	-- fx
	    	inst:mk_do_magic()
	    	-- ui
	    	self.inst.components.mkmonkeytimer:SetPercent(0)
	    end
    end
end

function MonkeySpawner:BackMonkeys()
	if not self.inst.components.monkeymana:EnoughMana(20) then
		return
	end
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 15, {"primeape", "spawn_monkey"})
	for i, v in pairs(ents) do
		if v.components.monkeyspawn then
			v.components.monkeyspawn:Back()
		end
	end
	-- fx
	self.inst:mk_do_magic()
	-- ui
	self.inst.components.mkbacktimer:SetPercent(0)
end

function MonkeySpawner:OnSave()
	return {num = self.num}
end

function MonkeySpawner:OnLoad(data)
	if data then
		self.num = data.num or 0
	end
end

return MonkeySpawner