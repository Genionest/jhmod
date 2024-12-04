local Util = require "extension.lib.wg_util"
local Kit = require "extension.lib.wargon"
local Info = Sample.Info

local BossConst = {
    2000, -- max_hp
    100, -- dmg
    40, -- exp
}

local function combat_re(inst)
	return FindEntity(inst, 16*1.33, function(guy)
        return inst.components.combat:CanTarget(guy)
           and guy:HasTag("player")
    end)
end

local function combat_keep(inst, target)
	return inst.components.combat:CanTarget(target)
       -- and target:HasTag("player")
end

local function on_attacked(inst, data)
	if data.attacker then
		inst.components.combat:SetTarget(data.attacker)
	end
end

local function close_door(inst)
	local door = FindEntity(inst, 100, nil, {"interior_door"})
	if door then
		door:AddTag("NOCLICK")
	end
end

local function open_door(inst)
	local door = FindEntity(inst, 100, nil, {"interior_door"})
	if door then
		door:RemoveTag("NOCLICK")
	end
end

local function fake_knight_on_hit_other(inst, data)
    
end

local function fake_knight_on_health_delta(inst, data)
	if inst.components.health:GetPercent() < .8 then
        inst.components.health:SetAbsorptionAmount(0)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_armour_break")
	end
end

local function UpdateShadowSize(inst, height)
	if inst.shadow then
		local scaleFactor = Lerp(0.5, 1.5, height/35)
		inst.shadow.Transform:SetScale(scaleFactor, scaleFactor, scaleFactor)
	end
end

local function GiveDebrisShadow(inst)
	local pt = Vector3(inst.Transform:GetWorldPosition())
	inst.shadow = SpawnPrefab("warningshadow")
	UpdateShadowSize(inst, 35)
	inst.shadow.Transform:SetPosition(pt.x, 0, pt.z)
end

local function PlayFallingSound(inst, volume)
	volume = volume or 1	
    local sound = inst.SoundEmitter
    if sound then
        local tile, tileinfo = inst:GetCurrentTileType()        
        if tile and tileinfo then
			local x, y, z = inst.Transform:GetWorldPosition()			
			local size_affix = "_small"			
			sound:PlaySound(tileinfo.walksound .. size_affix, nil, volume)
        end
    end
end

local function grounddetection_update(inst)
	local pt = Point(inst.Transform:GetWorldPosition())
	
	if not inst.shadow then
		GiveDebrisShadow(inst)
	else
		UpdateShadowSize(inst, pt.y)
	end

	if pt.y < 2 then
		inst.fell = true
		inst.Physics:SetMotorVel(0,0,0)
    end

	if pt.y <= .2 then
		PlayFallingSound(inst)
		if inst.shadow then
			inst.shadow:Remove()
		end

		local ents = TheSim:FindEntities(pt.x, 0, pt.z, 2, nil, {'smashable'})
	    for k,v in pairs(ents) do
	    	if v and v.components.combat and v ~= inst then  -- quakes shouldn't break the set dressing
	    		v.components.combat:GetAttacked(inst, 20, nil)
	    	end
	   	end
	   	--play hit ground sound


	   	inst.Physics:SetDamping(0.9)	   	

	    if inst.updatetask then
			inst.updatetask:Cancel()
			inst.updatetask = nil
		end

		-- if math.random() < 0.75 and not (inst.prefab == "mole" or inst.prefab == "rabbit") then
			--spawn break effect
			inst.SoundEmitter:PlaySound("dontstarve/common/stone_drop")
			local pt = Vector3(inst.Transform:GetWorldPosition())
			local breaking = SpawnPrefab("ground_chunks_breaking")
			breaking.Transform:SetPosition(pt.x, 0, pt.z)
			inst:Remove()
		-- end
	end

	-- Failsafe: if the entity has been alive for at least 1 second, hasn't changed height significantly since last tick, and isn't near the ground, remove it and its shadow
	if inst.last_y and pt.y > 2 and inst.last_y > 2 and (inst.last_y - pt.y  < 1) and inst:GetTimeAlive() > 1 and not inst.fell then
		if inst.shadow then
			inst.shadow:Remove()
		end
		inst:Remove()
	end
	inst.last_y = pt.y
end

local function start_grounddetection(inst)
	inst.updatetask = inst:DoPeriodicTask(0.1, grounddetection_update, 0.05)
end

local function spawn_fall_stone(inst)
	inst:StartThread(function()
		for i = 1, 10 do
			local pos = Kit:find_walk_pos(inst, math.random(4,8))
			if pos then
				pos.y = 35
				local rock = SpawnPrefab("rocks")
                rock.Transform:SetPosition(pos:Get())
				start_grounddetection(rock)
			end
			Sleep(.2)
		end
	end)
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    trans:SetFourFaced()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeCharacterPhysics(inst, 75, .5)
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wes")
    inst.AnimState:PlayAnimation("idle")
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(1.3, .6)
    
    MakeMediumBurnableCharacter(inst, "body")
    MakeLargeFreezableCharacter(inst)
    MakePoisonableCharacter(inst, nil, nil, 0, 0, 0)

    inst:AddTag("epic")
    inst:AddTag("tp_room_boss")
    inst:AddComponent("inspectable")

    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    inst.AnimState:Hide("HEAD")
    inst.AnimState:Show("HEAD_HAIR")
    inst.AnimState:Hide("HAIRFRONT")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_metalplate", "swap_hat")
    inst.AnimState:OverrideSymbol("swap_body", "armor_metalplate", "swap_body")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_object", "swap_hammer", "swap_hammer")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(BossConst[1])
    inst.components.health:StartRegen(10, 5)
    inst.components.health:SetAbsorptionAmount(.8)
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(BossConst[2])
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat:SetRetargetFunction(3, combat_re)
    inst.components.combat:SetKeepTargetFunction(combat_keep)
    inst.components.combat.dmg_type = "thump"
    inst.components.combat:SetDmgTypeAbsorb("strike", .8)
    inst.components.combat:SetDmgTypeAbsorb("spike", .8)
    inst.components.combat:SetDmgTypeAbsorb("slash", .8)
    inst.components.combat:SetDmgTypeAbsorb("thump", .8)
    inst.components.combat:SetDmgTypeAbsorb("fire", 1.2)
    inst.components.combat:SetDmgTypeAbsorb("ice", 1.2)
    inst.components.combat:SetDmgTypeAbsorb("electric", 1.3)
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({
        -- "metalplatehat", "armor_metalplate", "hammer",
        unpack(Info.GeneralBossLoot)
    })

    inst:ListenForEvent("attacked", on_attacked)
    inst:ListenForEvent("onhitother", fake_knight_on_hit_other)
    inst:ListenForEvent("healthdelta", fake_knight_on_health_delta)
	inst:ListenForEvent("death", open_door)

    inst.spawn_fall_stone = spawn_fall_stone
    inst:DoTaskInTime(0, fake_knight_on_health_delta)
	inst:DoTaskInTime(0, function()
		close_door(inst)
	end)

    inst:SetBrain(require "brains/tp_creature_brain")
	inst:SetStateGraph("SGtp_fake_knight")

    inst.components.combat.onkilledbyother = function(inst, attacker)
        if attacker.components.tp_level then
            attacker.components.tp_level:ExpDelta(BossConst[3])
        end
    end

    return inst
end

local PrefabUtil = require "extension.lib.prefab_util"
local room = deepcopy(require "prefabs/tp_boss_room")
PrefabUtil:SetPrefabName(room, "tp_fake_knight_room")
PrefabUtil:HookPrefabFn(room, function(inst)
    inst.boss_name = "tp_fake_knight"
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wes")
    inst.AnimState:PlayAnimation("sleep")
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    inst.AnimState:Hide("HEAD")
    inst.AnimState:Show("HEAD_HAIR")
    inst.AnimState:Hide("HAIRFRONT")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_metalplate", "swap_hat")
    inst.AnimState:OverrideSymbol("swap_body", "armor_metalplate", "swap_body")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_object", "swap_halberd", "swap_halberd")

    inst:DoTaskInTime(0, function()
        local pos = inst:GetPosition()
        SpawnPrefab("tp_boss_room_hut").Transform:SetPosition(inst:GetPosition():Get())
        SpawnPrefab("tp_boss_room_rug").Transform:SetPosition(inst:GetPosition():Get())
        inst.components.wg_start:AddFn(function()
            -- SpawnPrefab("tp_boss_obstacle_spawner").Transform:SetPosition(inst:GetPosition():Get())
        end)
        pos.y = pos.y+.1
        inst.Transform:SetPosition(pos:Get())
    end)
end)

Util:AddString("tp_fake_knight", "伪骑士", "伪装的骑士")
Util:AddString("tp_fake_knight_room", "伪骑士的梦境", "里面应该有什么大宝贝")

return Prefab("tp_fake_knight", fn, {}),
	room