local FxManager = Sample.FxManager
local Info = Sample.Info
local Kit = require "extension.lib.wargon"

local BossConst = {
    4000, -- max_hp
    125, -- dmg
    80, -- exp
    4,
}
local BossConst2 = {
    1750,
    50,
    40,
    1,
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
        if not inst.sg:HasStateTag("attack") then
			local target = FindEntity(inst, 100, nil, {"tp_soul_student_point"})
			if target and inst:IsNear(target, 5) then
				local pos = Kit:find_walk_pos(target, 7)
				if pos then
					FxManager:MakeFx("statue_transition", inst)
					FxManager:MakeFx("statue_transition_2", pos)
					inst.Transform:SetPosition(pos:Get())
				end
			end
		end
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

local function soul_student_on_health_delta(inst, data)
	if inst.components.health:GetPercent() < .5 then
		inst:AddTag("tp_soul_student_warth")
	end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    trans:SetFourFaced()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeCharacterPhysics(inst, 75, .5)
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("waxwell")
    inst.AnimState:PlayAnimation("idle")
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(1.3, .6)
    
    MakeMediumBurnableCharacter(inst, "body")
    MakeLargeFreezableCharacter(inst)
    MakePoisonableCharacter(inst, nil, nil, 0, 0, 0)

    inst:AddTag("epic")
    inst:AddTag("tp_room_boss")
    inst:AddComponent("inspectable")
    
    inst:AddTag("noauradamage")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(BossConst[1])
    inst.components.health:StartRegen(20, 5)
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(0)
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat:SetRange(10,12)
    inst.components.combat:SetRetargetFunction(3, combat_re)
    inst.components.combat:SetKeepTargetFunction(combat_keep)
    inst.components.combat.dmg_type = "electric"
    inst.components.combat:SetDmgTypeAbsorb("strike", 1.3)
    inst.components.combat:SetDmgTypeAbsorb("spike", 1.3)
    inst.components.combat:SetDmgTypeAbsorb("slash", 1.3)
    inst.components.combat:SetDmgTypeAbsorb("thump", 1.3)
    inst.components.combat:SetDmgTypeAbsorb("fire", .8)
    inst.components.combat:SetDmgTypeAbsorb("ice", .8)
    inst.components.combat:SetDmgTypeAbsorb("electric", .8)
    inst.components.combat:SetDmgTypeAbsorb("poison", 1.2)
    inst.proj = "tp_soul_charge"
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({
        unpack(Info.GeneralBossLoot)
    })
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    inst.AnimState:Hide("HEAD")
    inst.AnimState:Show("HEAD_HAIR")
    inst.AnimState:Hide("HAIRFRONT")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_top", "swap_hat")
    inst.AnimState:OverrideSymbol("swap_body", "armor_sanity", "swap_body")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_object", "swap_satffs", "redstaff")
    
    inst:ListenForEvent("attacked", on_attacked)
    inst:ListenForEvent("healthdelta", soul_student_on_health_delta)
    inst:DoTaskInTime(0, soul_student_on_health_delta)
    inst.max_soul = BossConst[4]
    inst.task = inst:DoPeriodicTask(1, function()
        local x, y, z = inst:GetPosition():Get()
		local souls = TheSim:FindEntities(x, y, z, 100, {"ghost"})
		if #souls < inst.max_soul then
			SpawnPrefab("ghost").Transform:SetPosition(inst:GetPosition():Get())
		end
	end)
    inst:SetBrain(require "brains/tp_creature_brain")
	inst:SetStateGraph("SGtp_soul_student")
    inst:DoTaskInTime(0, function()
		close_door(inst)
	end)
	inst:ListenForEvent("death", open_door)    

    inst.components.combat.onkilledbyother = function(inst, attacker)
        if attacker.components.tp_level then
            attacker.components.tp_level:ExpDelta(BossConst[3])
        end
    end

    return inst
end

local fn2 = function()
    local inst = fn()
    inst.components.health:SetMaxHealth(BossConst2[1])
    inst.proj = "tp_soul_charge2"
    inst.max_soul = BossConst2[4]
    inst.components.combat.onkilledbyother = function(inst, attacker)
        if attacker.components.tp_level then
            attacker.components.tp_level:ExpDelta(BossConst2[3])
        end
    end

    return inst
end

local function proj()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.AnimState:SetBank("bishop_attack")
    inst.AnimState:SetBuild("bishop_attack")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
	inst:AddTag('projectile')
    inst.persists = false
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(BossConst[2])
    inst.components.weapon.dmg_type = "electric"
    inst:AddComponent("wg_projectile")
    inst.components.wg_projectile:SetSpeed(20)
    -- inst.components.wg_projectile:SetOnThrownFn(function(inst, owner, target) end)
    inst.components.wg_projectile:SetOnMissFn(function(inst, owner, target) 
        inst:Remove()
    end)
    inst.components.wg_projectile:SetOnHitFn(function(inst, owner, target)
        inst.components.wg_projectile.onmiss(inst, owner, target)
    end)
    inst.components.wg_projectile:SetLaunchOffset(Vector3(0, -1, 0))
    -- inst.components.wg_projectile.test = function(inst, target, doer)
    --     return true
    -- end
    -- inst.components.wg_projectile:SetOnCaughtFn(function(inst, catcher)
    -- end)
	-- inst.components.wg_projectile:SetHitDist(3)

    return inst
end

local function proj2()
    local inst = proj()
    inst.components.weapon:SetDamage(BossConst2[2])
    return inst
end

local function point()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()

    inst:DoTaskInTime(0, function()
        SpawnPrefab("tp_soul_student").Transform:SetPosition(inst:GetPosition():Get())
        SpawnPrefab("tp_soul_student_anchor").Transform:SetPosition(inst:GetPosition():Get())
        inst:Remove()
    end)
    
    return inst
end

local function point2()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()

    inst:DoTaskInTime(0, function()
        SpawnPrefab("tp_soul_student2").Transform:SetPosition(inst:GetPosition():Get())
        SpawnPrefab("tp_soul_student_anchor").Transform:SetPosition(inst:GetPosition():Get())
        inst:Remove()
    end)
    
    return inst
end

local function anchor()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()

    inst:AddTag("tp_soul_student_anchor")
    
    return inst
end


local PrefabUtil = require "extension.lib.prefab_util"
local room = deepcopy(require "prefabs/tp_boss_room")
PrefabUtil:SetPrefabName(room, "tp_soul_student_room")
PrefabUtil:HookPrefabFn(room, function(inst)
    inst.boss_name = "tp_soul_student_point"
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("waxwell")
    inst.AnimState:PlayAnimation("sleep")
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    inst.AnimState:Hide("HEAD")
    inst.AnimState:Show("HEAD_HAIR")
    inst.AnimState:Hide("HAIRFRONT")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_top", "swap_hat")
    inst.AnimState:OverrideSymbol("swap_body", "armor_sanity", "swap_body")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_object", "swap_staffs", "redstaff")

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

local room2 = deepcopy(room)
PrefabUtil:SetPrefabName(room2, "tp_soul_student2_room")
PrefabUtil:HookPrefabFn(room2, function(inst)
    inst.boss_name = "tp_soul_student2_point"
end)

local Util = require "extension.lib.wg_util"
Util:AddString("tp_soul_student", "灵魂老师", "灵魂的老师")
Util:AddString("tp_soul_student2", "灵魂学徒", "灵魂的学徒")
Util:AddString("tp_soul_student_room", "灵魂老师的梦境", "里面应该有什么大宝贝")
Util:AddString("tp_soul_student2_room", "灵魂学徒的梦境", "里面应该有什么大宝贝")



return Prefab("tp_soul_student", fn, {}),
    Prefab("tp_soul_student2", fn2, {}),
    Prefab("tp_soul_charge", proj, {}),
    Prefab("tp_soul_charge2", proj2, {}),
    Prefab("tp_soul_student_point", point, {}),
    Prefab("tp_soul_student2_point", point2, {}),
    Prefab("tp_soul_student_anchor", anchor, {}),
    room, room2