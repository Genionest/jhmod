local Info = Sample.Info

local BossConst = {
    1500, -- max_hp
    100, -- dmg
    40, -- exp
    300, -- proj_dmg
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

local function hornet_on_hit_other(inst, data)
    if math.random() < .3 then

    end
end

local function catch_spear(inst)
	if not inst:HasTag("sliding") then
        inst.AnimState:Show("ARM_carry")
        inst.AnimState:Hide("ARM_normal")
        inst.AnimState:OverrideSymbol("swap_object", "tp_spear_lance", "swap_object")
    end
	inst:RemoveTag("spear_thrown")
end

local function start_slide(inst)
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_object", "swap_cane_ancient", "swap_cane")
end

local function stop_slide(inst)
	if inst:HasTag("spear_thrown") then
        inst.AnimState:Hide("ARM_carry")
        inst.AnimState:Show("ARM_normal")
        inst.AnimState:ClearOverrideSymbol("swap_object")
	else
        inst.AnimState:Show("ARM_carry")
        inst.AnimState:Hide("ARM_normal")
        inst.AnimState:OverrideSymbol("swap_object", "tp_spear_lance", "swap_object")
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
    inst.AnimState:SetBuild("wendy")
    inst.AnimState:PlayAnimation("idle")
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(1.3, .6)
    
    MakeMediumBurnableCharacter(inst, "body")
    MakeLargeFreezableCharacter(inst)
    MakePoisonableCharacter(inst, nil, nil, 0, 0, 0)

    inst:AddTag("epic")
    inst:AddTag("tp_room_boss")
    inst:AddComponent("inspectable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(BossConst[1])
    inst.components.health:StartRegen(10, 5)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(BossConst[2])
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat:SetRetargetFunction(3, combat_re)
    inst.components.combat:SetKeepTargetFunction(combat_keep)
    inst.components.combat.dmg_type = "spike"
    inst.components.combat:SetDmgTypeAbsorb("strike", .9)
    inst.components.combat:SetDmgTypeAbsorb("spike", .9)
    inst.components.combat:SetDmgTypeAbsorb("thump", 1.1)
    inst.components.combat:SetDmgTypeAbsorb("shadow", .9)
    inst.components.combat:SetDmgTypeAbsorb("holly", 1.2)
    inst.components.combat:SetDmgTypeAbsorb("poison", .9)
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({
        -- "tp_cane_dodge",
        unpack(Info.GeneralBossLoot)
    })
    inst:AddComponent("inventory")

    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    inst.AnimState:Hide("HEAD")
    inst.AnimState:Show("HEAD_HAIR")
    inst.AnimState:Hide("HAIRFRONT")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_bandit", "swap_hat")
    inst.AnimState:OverrideSymbol("swap_body", "armor_vortex_cloak", "swap_body")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_object", "tp_spear_lance", "swap_object")

    inst:ListenForEvent("attacked", on_attacked)
    inst:ListenForEvent("onhitother", hornet_on_hit_other)
    inst:DoTaskInTime(0, function()
        close_door(inst)
    end)
    inst:ListenForEvent("death", open_door)
    inst.catch_spear = catch_spear
	inst.start_slide = start_slide
	inst.stop_slide = stop_slide
    local can_attack = inst.components.combat.CanAttack
	inst.components.combat.CanAttack = function(cmp, target)
		if inst:HasTag("spear_thrown") then
			return false
		end
		return can_attack(cmp, target)
	end
    inst:SetBrain(require "brains/tp_creature_brain")
    inst:SetStateGraph("SGtp_hornet")

    inst.components.combat.onkilledbyother = function(inst, attacker)
        if attacker.components.tp_level then
            attacker.components.tp_level:ExpDelta(BossConst[3])
        end
    end

    return inst
end

local proj = function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.AnimState:SetBank("tp_spear_lance")
    inst.AnimState:SetBuild("tp_spear_lance")
    inst.AnimState:PlayAnimation("throw")
    MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
	inst:AddTag('projectile')
    inst.persists = false
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(BossConst[4])
    inst.components.weapon.dmg_type = "spike"
    inst:AddComponent("wg_projectile")
    inst.components.wg_projectile:SetSpeed(20)
    inst.components.wg_projectile:SetOnThrownFn(function(inst, owner, target) end)
    inst.components.wg_projectile:SetOnMissFn(function(inst, owner, target) 
        -- inst:Remove()
        inst.components.wg_projectile:Throw(owner, owner)
    end)
    inst.components.wg_projectile:SetOnHitFn(function(inst, owner, target)
        inst.components.wg_projectile.onmiss(inst, owner, target)
    end)
    inst.components.wg_projectile:SetLaunchOffset(Vector3(0, 0.2, 0))
    inst.components.wg_projectile.test = function(inst, target, doer)
        return true
    end
    inst.components.wg_projectile:SetOnCaughtFn(function(inst, catcher)
        if catcher.catch_spear then
            catcher:catch_spear()
        end
        inst:Remove()
    end)
	-- inst.components.wg_projectile:SetHitDist(3)

	return inst
end

local PrefabUtil = require "extension.lib.prefab_util"
local room = deepcopy(require "prefabs/tp_boss_room")
PrefabUtil:SetPrefabName(room, "tp_hornet_room")
PrefabUtil:HookPrefabFn(room, function(inst)
    inst.boss_name = "tp_hornet"
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wendy")
    inst.AnimState:PlayAnimation("sleep")
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    inst.AnimState:Hide("HEAD")
    inst.AnimState:Show("HEAD_HAIR")
    inst.AnimState:Hide("HAIRFRONT")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_bandit", "swap_hat")
    inst.AnimState:OverrideSymbol("swap_body", "armor_vortex_cloak", "swap_body")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_object", "tp_spear_lance", "swap_object")

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

local Util = require "extension.lib.wg_util"
Util:AddString("tp_hornet", "小黄蜂", "小的黄蜂")
Util:AddString("tp_hornet_room", "小黄蜂的梦境", "里面应该有什么大宝贝")

return Prefab("tp_hornet", fn, {}),
    Prefab("tp_hornet_proj", proj, {}),
    room