local Util = require "extension.lib.wg_util"
local Kit = require "extension.lib.wargon"
local EntUtil = require "extension.lib.ent_util"
local PrefabUtil = require "extension.lib.prefab_util"
local FxManager = Sample.FxManager
local Info = Sample.Info

local assets =
{
	Asset("ANIM", "anim/daywalker_build.zip"),
	Asset("ANIM", "anim/daywalker_imprisoned.zip"),
	Asset("ANIM", "anim/daywalker_phase1.zip"),
	Asset("ANIM", "anim/daywalker_phase2.zip"),
	Asset("ANIM", "anim/daywalker_defeat.zip"),
}

local function CreateHead(owner)
    if owner.head then
        return owner.head
    end
	local inst = CreateEntity()

	inst:AddTag("FX")
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("daywalker")
	inst.AnimState:SetBuild("daywalker_build")
	inst.AnimState:PlayAnimation("head", true)

    owner.head = inst
    -- inst.entity:SetParent(owner.entity)
    -- owner:AddChild(inst)
    -- inst.Transform:SetPosition(0,0,0)
    inst.entity:AddFollower()
    inst.Follower:FollowSymbol(owner.GUID, "HEAD_follow", 0, 0, 0, true, true)
    inst.Transform:SetRotation(owner.Transform:GetRotation())
	return inst
end

local function RemoveHead(owner)
    if owner.head then
        owner:RemoveChild(owner.head)
        owner.head:Remove()
        owner.head = nil
    end
end

local function common()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    trans:SetFourFaced()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeCharacterPhysics(inst, 1000, 1.2)
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(3.5, 1.5)

    inst.AnimState:SetBank("daywalker")
	inst.AnimState:SetBuild("daywalker_build")
	inst.AnimState:PlayAnimation("idle", true)
    
    inst:AddTag("werepig")
    inst:AddTag("epic")
	-- inst:AddTag("monster")
	inst:AddTag("hostile")
	inst:AddTag("scarytoprey")
	inst:AddTag("largecreature")

    inst:AddComponent("inspectable")

    inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 6
    inst.components.locomotor.runspeed = 6

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(2000)
    inst.components.health:StartRegen(20, 5)
    -- inst.components.health:SetAbsorptionAmount(0)

    inst.atk_num = 0
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(50)
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat:SetRange(4,3)
    -- inst.components.combat.playerdamagepercent=1
    inst.components.combat:SetRetargetFunction(3, function(inst)
        return FindEntity(inst, 16, function(target, inst)
            return true
        end, {"character"}, {"pig"})
    end)
    inst.components.combat:SetKeepTargetFunction(function(inst, target)
        return inst.components.combat:CanTarget(target)
    end)
    inst.components.combat.dmg_type = "slash"
    inst.components.combat:SetDmgTypeAbsorb("strike", .9)
    inst.components.combat:SetDmgTypeAbsorb("slash", .9)
    inst.components.combat:SetDmgTypeAbsorb("thump", .8)
    inst.components.combat:SetDmgTypeAbsorb("fire", 1.3)
    inst.components.combat:SetDmgTypeAbsorb("ice", 1.1)
    inst.components.combat:SetDmgTypeAbsorb("holly", 1.1)
    inst.components.combat:SetDmgTypeAbsorb("electric", 1.2)
    inst.components.combat:SetDmgTypeAbsorb("poison", .9)

    inst:AddComponent("lootdropper")

    inst:AddComponent("tp_creature_equip")

    inst.CreateHead = CreateHead
    inst.RemoveHead = RemoveHead

    inst:ListenForEvent("attacked", function(inst, data)
        if data.attacker then
            local attacker = data.attacker
            inst.components.combat:SetTarget(attacker)
            inst.components.combat:ShareTarget(attacker, 30, function(dude) 
                return dude:HasTag("werepig") 
            end, 5)
            if inst.werepig then
                inst.components.combat:SuggestTarget(attacker)
            end
        end
    end)
    inst.max_spawn = 2
    inst.spawn_werepig = function(inst)
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 20, {"werepig"})
        if #ents < inst.max_spawn then
            local pos = Kit:find_walk_pos(inst, math.random(3))
            if pos then
                local pig = SpawnPrefab("pigman")
                pig.Transform:SetPosition(pos:Get())
                pig.components.werebeast:SetWere()
                -- table.insert(inst.werepigs, pig)
                pig.sg:GoToState('howl')
                FxManager:MakeFx("statue_transition_2", pig)
            end
        end
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 20, {"pig"}, {"werepig"})
        for i, v in pairs(ents) do
            if v.components.werebeast
            and not v.components.werebeast:IsInWereState() then
                v.components.werebeast:SetWere()
            end
        end
    end
    inst.index = 1
    -- inst.death_fn = EntUtil:listen_for_event(inst, "death", function(inst, data)
    --     local king = c_find("pigking")
    --     if king then
    --         local pos = Kit:find_walk_pos(king, 12)
    --         if pos then
    --             FxManager:MakeFx("statue_transition_2", pos)
    --             local pig = SpawnPrefab("tp_werepig_king0")
    --             pig.Transform:SetPosition(pos:Get())
    --             pig.AnimState:PlayAnimation("sleep_pst", false)
    --             pig.AnimState:PushAnimation("idle_creepy", true)
    --             pig.index = inst.index + 1
    --         end
    --     end
    -- end)

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

    inst:SetBrain(require "brains/tp_creature_brain2")
    inst:SetStateGraph("SGtp_werepig_king")

    return inst
end

local function simple()
    local inst = common()
    inst.components.lootdropper:SetLoot({
        -- "tp_advance_chip", 
        "tp_grass_pigking", 
        "meat", "meat", "pigskin", "tp_beast_essence",
        unpack(Info.GeneralBossLoot)
    })
    inst:DoTaskInTime(0, function()
        inst.components.tp_creature_equip:Random()
    end)
    return inst
end

local function blood()
    local inst = common()
    inst.components.lootdropper:SetLoot({
        "meat", "meat", "pigskin", "tp_beast_essence",
        unpack(Info.GeneralBossLoot)
    })
    inst.AnimState:SetMultColour(1, .2, .2, 1)
    inst.index = 2
    inst.max_spawn = inst.index+1
    inst.components.health:SetMaxHealth(2000-250+250*inst.index)
    inst.components.combat:SetDefaultDamage(50-15+15*inst.index)
    inst.components.combat.dmg_type = "blood"
    inst.components.tp_creature_equip.level = 10*(inst.index+1)
    inst.components.tp_creature_equip:SetEquipByIds({
        "goredrinker", "bloodthirster",
    })

    return inst
end

local function poison()
    local inst = common()
    inst.components.lootdropper:SetLoot({
        "meat", "meat", "pigskin", "tp_beast_essence",
        unpack(Info.GeneralBossLoot)
    })
    inst.AnimState:SetMultColour(.2, 1, .2, 1)
    inst.index = 3
    inst.max_spawn = inst.index+1
    inst.components.health:SetMaxHealth(2000-250+250*inst.index)
    inst.components.combat:SetDefaultDamage(50-15+15*inst.index)
    inst.components.combat.dmg_type = "poison"
    inst.components.tp_creature_equip.level = 10*(inst.index+1)
    inst.components.tp_creature_equip:SetEquipByIds({
        "turbo_chemtank", "chempunk_chainsword",
        "executioner_calling",
    })

    return inst
end

local function thunder()
    local inst = common()
    inst.components.lootdropper:SetLoot({
        "meat", "meat", "pigskin", "tp_beast_essence",
        unpack(Info.GeneralBossLoot)
    })
    inst.AnimState:SetMultColour(.2, .2, 1, 1)
    inst.index = 4
    inst.max_spawn = inst.index+1
    inst.components.health:SetMaxHealth(2000-250+250*inst.index)
    inst.components.combat:SetDefaultDamage(50-15+15*inst.index)
    inst.components.combat.dmg_type = "electric"
    inst:AddTag("galeforce_equip")
    inst.components.tp_creature_equip.level = 10*(inst.index+1)
    inst.components.tp_creature_equip:SetEquipByIds({
        "galeforce", "stormrazor", "guardian_angel",
    })

    return inst
end

local function ice()
    local inst = common()
    inst.components.lootdropper:SetLoot({
        "meat", "meat", "pigskin", "tp_beast_essence",
        unpack(Info.GeneralBossLoot)
    })
    inst.AnimState:SetMultColour(.2, 1, 1, 1)
    inst.index = 5
    inst.max_spawn = inst.index+1
    inst.components.health:SetMaxHealth(2000-250+250*inst.index)
    inst.components.combat:SetDefaultDamage(50-15+15*inst.index)
    inst.components.combat.dmg_type = "ice"
    inst.components.tp_creature_equip.level = 10*(inst.index+1)
    inst.components.tp_creature_equip:SetEquipByIds({
        "frostfire_gauntlet", "serylda_grudge", 
        "frozen_heart", "phage"
    })

    return inst
end

local function fire()
    local inst = common()
    inst.components.lootdropper:SetLoot({
        "meat", "meat", "pigskin", "tp_beast_essence",
        unpack(Info.GeneralBossLoot)
    })
    inst.AnimState:SetMultColour(1, 1, .2, 1)
    inst.index = 6
    inst.max_spawn = inst.index+1
    inst.components.health:SetMaxHealth(2000-250+250*inst.index)
    inst.components.combat:SetDefaultDamage(50-15+15*inst.index)
    inst.components.combat.dmg_type = "fire"
    inst.components.tp_creature_equip.level = 10*(inst.index+1)
    inst.components.tp_creature_equip:SetEquipByIds({
        "SunFire_aegis", "locket_IronSolari",
        "rapid_direcannon", "titantic_hydra"
    })

    return inst
end

local function shadow()
    local inst = common()
    inst.components.lootdropper:SetLoot({
        "meat", "meat", "pigskin", "tp_beast_essence",
        unpack(Info.GeneralBossLoot)
    })
    inst.AnimState:SetMultColour(1, .2, 1, 1)
    inst.index = 7
    inst.max_spawn = inst.index+1
    inst.components.health:SetMaxHealth(2000-250+250*inst.index)
    inst.components.combat:SetDefaultDamage(50-15+15*inst.index)
    inst.components.combat.dmg_type = "shadow"
    inst.components.tp_creature_equip.level = 10*(inst.index+1)
    inst.components.tp_creature_equip:SetEquipByIds({
        "eclipse", "duskblade_draktharr",
        "phantom_dancer", "death_dance", "spirit_visage"
    })
    inst.spawn_werepig = function(inst)
        if inst.werepig == nil then
            local pos = Kit:find_walk_pos(inst, math.random(5, 6))
            if pos then
                inst.werepig = SpawnPrefab("tp_werepig_king8")
                inst.werepig.sg:GoToState("howl")
                inst.werepig.Transform:SetPosition(pos:Get())
                local target = inst.components.combat.target
                if target then
                    inst.werepig.components.combat:SetTarget(target)
                end
                for i = 0, 4 do
                    inst.werepig:DoTaskInTime(i*.1, function()
                        local pt = Kit:find_walk_pos(inst.werepig, math.random(2)+math.random())
                        FxManager:MakeFx("statue_transition", pt)
                    end)
                end
                inst.werepig:DoTaskInTime(20, function()
                    if inst.werepig then
                        inst.werepig.components.health:SetInvincible(false)
                        inst.werepig.components.health:Kill()
                        inst.werepig = nil
                    end
                end)
            end
        end
    end
    inst:RemoveEventCallback("death", inst.death_fn)
    inst:ListenForEvent("death", function(inst, data)
        if inst.werepig then
            inst.werepig.components.health:SetInvincible(false)
            inst.werepig.components.health:Kill()
            inst.werepig = nil
        end
        -- local pig = SpawnPrefab("pigman")
        -- pig:AddTag("no_creature_equip")
        -- pig.Transform:SetPosition(inst:GetPosition():Get())
        -- local hat = SpawnPrefab("tp_hat_pigking")
        -- pig.components.inventory:Equip(hat)
        -- pig.components.health:Kill()
    end)

    return inst
end

local function shadow2()
    local inst = common()
    inst.persists = false
    inst.components.lootdropper:SetLoot({})
    inst.AnimState:SetMultColour(1, .2, 1, .6)
    inst.index = 7
    inst.max_spawn = inst.index+1
    inst.components.health:SetInvincible(true)
    inst.components.health:SetMaxHealth(2000-250+250*inst.index)
    inst.components.combat:SetDefaultDamage(50-15+15*inst.index)
    inst.components.combat.dmg_type = "shadow"
    inst.components.tp_creature_equip.level = 10*(inst.index+1)
    inst.components.tp_creature_equip:SetEquipByIds({
        "eclipse", "duskblade_draktharr",
        "phantom_dancer", "death_dance", "spirit_visage"
    })
    inst.spawn_werepig = function(inst) end
    inst:RemoveEventCallback("death", inst.death_fn)

    return inst
end

local function fn2()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    trans:SetFourFaced()
    local anim = inst.entity:AddAnimState()
    inst.AnimState:SetBank("pigman")
    inst.AnimState:SetBuild("pig_build")
    inst.AnimState:PlayAnimation("idle_creepy", true)
    inst.entity:AddSoundEmitter()
    MakeCharacterPhysics(inst, 1000, .5)
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(1.5, .75)
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    inst.AnimState:OverrideSymbol("swap_hat", "beefalohat_pigking", "swap_hat")
    inst:AddComponent("inspectable")
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(function(inst, item, giver)
        return item.prefab == "nightmarefuel"
    end)
    inst.components.trader.onaccept = function(inst, giver, item)
        local boss_name = inst:get_boss()
        inst:become_boss(boss_name)
    end
    inst.components.trader.onrefuse = function(inst, giver, item)end
    inst.index = 1
    inst.OnSave = function(inst, data)
        data.index = inst.index
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.index = data.index or 1
        end
    end
    inst.get_boss = function(inst)
        local boss_name = "tp_werepig_king"
        if inst.index > 1 then
            boss_name = boss_name..tostring(inst.index)
        end
        return boss_name
    end
    inst.become_boss = function(inst, boss_name)
        -- 防止重复召唤
        inst.summonning = true 
        -- 变身动画
        inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/transformToWere")
        inst.AnimState:PlayAnimation("transform_pig_were")
        inst:ListenForEvent("animover", function(inst, data)
            GetPlayer().components.tp_boss_spawner:SpawnBoss(boss_name)
            -- 召唤boss
            local pos = inst:GetPosition()
            inst:Remove()
            local boss = SpawnPrefab(boss_name)
            boss.Transform:SetPosition(pos:Get())
            boss.sg:GoToState("howl")
            for i = 0, 4 do
                boss:DoTaskInTime(i*.1, function()
                    local pt = Kit:find_walk_pos(boss, math.random(2)+math.random())
                    FxManager:MakeFx("statue_transition", pt)
                end)
            end
        end)
    end
    inst:ListenForEvent("nighttime", function(world, data)
        local day = data.day+1
        if inst and inst.index then
            local boss_name = inst:get_boss()
            if GetPlayer().components.tp_boss_spawner:CanSpawnBoss(boss_name) then
                local base = Info.BossAppearDay.WerepigKingBase
                local need = base+Info.BossAppearDay.WerepigKingBonus*(inst.index)
                if day>=need and inst.summonning==nil then
                    inst:become_boss(boss_name)
                end
            end
        end
    end, GetWorld())

    return inst
end

Util:AddString("tp_werepig_king0", "王位觊觎者", "觊觎王位的小猪")
Util:AddString("tp_werepig_king", "野猪王", "觊觎猪王之位的大野猪")
Util:AddString("tp_werepig_king2", "野猪王·残忍", "觊觎王位的大野猪")
Util:AddString("tp_werepig_king3", "野猪王·狂妄", "觊觎王位的大野猪")
Util:AddString("tp_werepig_king4", "野猪王·暴怒", "觊觎王位的大野猪")
Util:AddString("tp_werepig_king5", "野猪王·无情", "觊觎王位的大野猪")
Util:AddString("tp_werepig_king6", "野猪王·野心", "觊觎王位的大野猪")
Util:AddString("tp_werepig_king7", "野猪王·黩武", "觊觎王位的大野猪")
Util:AddString("tp_werepig_king8", "野猪王·黩武", "觊觎王位的大野猪")

local prefs = {}
for i = 1, 8 do

local boss_room = deepcopy(require "prefabs/tp_boss_room")
local boss_name = "tp_werepig_king"
if i > 1 then
    boss_name = boss_name..tostring(i)
end
PrefabUtil:SetPrefabName(boss_room, boss_name.."_room")
PrefabUtil:HookPrefabFn(boss_room, function(inst)
    inst.boss_name = boss_name
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
table.insert(prefs, boss_room)
Util:AddString(boss_room.name, "洞穴", "我该去里面探险一下吗?")

end

return Prefab("tp_werepig_king", simple, assets),
    Prefab("tp_werepig_king2", blood, {}),
    Prefab("tp_werepig_king3", poison, {}),
    Prefab("tp_werepig_king4", thunder, {}),
    Prefab("tp_werepig_king5", ice, {}),
    Prefab("tp_werepig_king6", fire, {}),
    Prefab("tp_werepig_king7", shadow, {}),
    Prefab("tp_werepig_king8", shadow2, {}),
    Prefab("tp_werepig_king0", fn2, {}),
    prefs[1], prefs[2], prefs[3], prefs[4], prefs[5], prefs[6], prefs[7], prefs[8]