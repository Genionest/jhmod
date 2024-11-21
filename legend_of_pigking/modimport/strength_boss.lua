AddStategraphPostInit("dragonfly", function(sg)
	local old_fn = sg.states["taunt"].onenter
	sg.states["taunt"].onenter = function(inst)
		old_fn(inst)
		local delay = 0	
		for i = 1, 8 do
			inst:DoTaskInTime(delay, function(inst)
				local x, y, z = GetPlayer():GetPosition():Get()
				local firerain = SpawnPrefab("firerain")
				firerain.Transform:SetPosition(x,y,z)
				firerain:StartStep()
			end)
			delay = delay + 0.5
		end
		inst.components.groundpounder:GroundPound()
        GetPlayer().components.playercontroller:ShakeCamera(inst, "FULL", 0.7, 0.02, 2, 40)
	end
end)

AddPrefabPostInit("dragonfly", function(inst)
	-- local old_fn = inst.event_listeners["attacked"][inst]
	inst:AddTag("groundpoundimmune")
	inst:AddComponent("groundpounder")
  	inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 2
    inst.components.groundpounder.destructionRings = 3
    inst.components.groundpounder.numRings = 3
	-- inst:ListenForEvent("attacked", function(inst, data)
	-- 	if data.attacker and data.attacker.prefab == "firerain" then
	-- 		if inst:IsValid() and (inst.components.health 
 --            and not inst.components.health:IsDead()) then
	-- 			inst.components.health:DoDelta(500)
	-- 		end
	-- 	end
	-- end)
end)

local function isdragonfly(item, inst)
	if item.prefab == "dragonfly" then
		if item:IsValid() and item.components.health
		and not item.components.health:IsDead() then
			return true
		end
	end
end

AddPrefabPostInit("firerain", function(inst)
	local old_fn = inst.DoStep
	inst.DoStep = function(inst)
		old_fn(inst)
		local fly = FindEntity(inst, 3, isdragonfly)
		if fly then
			fly.components.health:DoDelta(100)
		end
	end
	-- inst:DoPeriodicTask(1, function()
	-- end, 0)
end)