local Util = require "extension.lib.wg_util"
local EntUtil = require "extension.lib.ent_util"
local PrefabUtil = require "extension.lib.prefab_util"
local AssetMaster = Sample.AssetMaster
local FxManager = Sample.FxManager

local BossConst = {
    2000, -- max_hp
    60, -- dmg
    30, -- exp
}

local assets = {}

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    trans:SetSixFaced()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.AnimState:SetBank("wilsonbeefalo")
    inst.AnimState:SetBuild("wathgrithr")
    inst.AnimState:AddOverrideBuild("beefalo_build")
    inst.AnimState:Hide("HEAT")
    MakeCharacterPhysics(inst, 100, .5)
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(6, 2)

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeLargeFreezableCharacter(inst, "beefalo_body")
    MakePoisonableCharacter(inst)

    inst:AddTag("beefalo")
    inst:AddTag("largecreature")
    inst:AddTag("epic")
    inst:AddTag("scarytoprey")
    inst:AddComponent("inspectable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(BossConst[1])
    inst.components.health:StartRegen(20, 5)
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({
        "ak_ssd", "tp_gift", 
        -- "tp_alloy_enchant2",
        "saddle_war", "tp_sign_staff",
        "tp_epic",
        "tp_beast_essence",
    })
    inst:AddComponent("locomotor")
    inst:AddComponent("inventory")
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.runspeed = 7
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(BossConst[2])
    inst.components.combat:SetAttackPeriod(3)
    -- inst.components.combat:SetRange(0,0)
    inst.components.combat:SetRetargetFunction(3, function(inst)
        -- return FindEntity(inst, 16, function(target, inst)
        --     return true
        -- end, {"character"}, {"beefalo"})
    end)
    inst.components.combat:SetKeepTargetFunction(function(inst, target)
        return inst.components.combat:CanTarget(target)
    end)
    inst.components.combat.onkilledbyother = function(inst, attacker)
        if attacker.components.tp_level then
            attacker.components.tp_level:ExpDelta(BossConst[3])
        end
    end
    inst.components.combat.dmg_type = "strike"
    inst.components.combat:SetDmgTypeAbsorb("strike", .9)
    inst.components.combat:SetDmgTypeAbsorb("slash", .9)
    inst.components.combat:SetDmgTypeAbsorb("thump", .9)
    inst.components.combat:SetDmgTypeAbsorb("fire", 1.2)
    inst.components.combat:SetDmgTypeAbsorb("ice", .8)
    inst.components.combat:SetDmgTypeAbsorb("electric", 1.1)
    inst.components.combat:SetDmgTypeAbsorb("poison", 1.2)
    inst.components.combat:SetDmgTypeAbsorb("blood", 1.2)
    inst:DoTaskInTime(0, function()
        local weapon = CreateEntity()
        weapon.entity:AddTransform()
        weapon:AddTag("cantdrop")
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
        weapon.components.weapon:SetRange(8, 10)
        weapon.components.weapon:SetProjectile("tp_sign_proj")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(inst.Remove)
        weapon:AddComponent("equippable")
        
        inst.components.inventory:Equip(weapon)
    end)
    inst:ListenForEvent("attacked", function(inst, data)
        if data.attacker then
            inst.components.combat:SetTarget(data.attacker)
            inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
                return dude:HasTag("beefalo")
                    and not dude:IsInLimbo()
                    and not (dude.components.health:IsDead() or dude:HasTag("player"))
            end, 5)
            if math.random() < .3 then
                FxManager:MakeFx("sign_six_line", inst)
                EntUtil:make_area_dmg2(inst, 6, inst, 30, nil, 
                    EntUtil:add_stimuli(nil, "pure"), {
                        test = function(v, attacker, weapon)
                            if v:HasTag("beefalo") then
                                if not v:HasTag("player") then
                                    return false
                                end
                            end
                            return true
                        end,
                    }
                )
            end
        end
    end)
    -- 动画
    local s1, b1, s12 = AssetMaster:GetSymbol("tp_sign_staff")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol(s1, b1, s12)
    local s3, b3, s32 = AssetMaster:GetSymbol("tp_helm_combat")
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    inst.AnimState:Hide("HEAD")
    inst.AnimState:Show("HEAD_HAIR")
    inst.AnimState:Hide("HAIRFRONT")
    inst.AnimState:OverrideSymbol(s3, b3, s32)
    -- 鞍
    inst.AnimState:OverrideSymbol("swap_saddle", "saddle_war", "swap_saddle")

    inst.atk_num = 0
    inst.castspell = function(inst)
        local target = inst.components.combat.target or inst
        FxManager:MakeFx("sign_magic_circle", target)
    end

    -- boss房门
    inst:DoTaskInTime(0, function()
        local door = FindEntity(inst, 100, nil, {"interior_door"})
        if door then
            door:AddTag("NOCLICK")
        end
    end)
    inst:ListenForEvent("death", function(inst, data)
        local door = FindEntity(inst, 100, nil, {"interior_door"})
        if door then
            door:RemoveTag("NOCLICK")
        end
    end)
    
    inst:SetBrain(require "brains.tp_creature_brain2")
    inst:SetStateGraph("SGtp_sign_rider")

    return inst
end

local function proj()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    -- inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    inst:AddTag("projectile")
    inst.persists = false
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(20)
    -- inst.components.projectile:SetOnThrownFn(function(inst, owner, target)end)
    inst.components.projectile:SetOnHitFn(function(inst, attacker, target, weapon)
        inst.components.projectile.onmiss(inst, attacker, target)
    end)
    inst.components.projectile:SetOnMissFn(function(inst, owner, target)
        inst:Remove()
    end)
    inst.components.projectile:SetHitDist(2)
    inst:DoPeriodicTask(.1, function()
        FxManager:MakeFx("sign", inst)
    end)

    return inst
end
Util:AddString("tp_sign_rider", "路牌骑士", "牦牛的首领")

local boss_room = deepcopy(require "prefabs/tp_boss_room")
PrefabUtil:SetPrefabName(boss_room, "tp_sign_rider_room")
PrefabUtil:HookPrefabFn(boss_room, function(inst)
    inst.boss_name = "tp_sign_rider"
    inst.AnimState:SetBank("vampbat_den")
    inst.AnimState:SetBuild("vamp_bat_entrance")
    inst.AnimState:PlayAnimation("idle")
    inst.cave = true
    inst:DoTaskInTime(0, function()
        inst.components.wg_start:AddFn(function()
            -- SpawnPrefab("tp_boss_obstacle_spawner").Transform:SetPosition(inst:GetPosition():Get())
        end)
    end)
end)
-- table.insert(prefs, boss_room)
Util:AddString(boss_room.name, "洞穴", "我该去里面探险一下吗?")

return Prefab("tp_sign_rider", fn, assets),
    Prefab("tp_sign_proj", proj, {}),
    boss_room