local AssetUtil = require "extension.lib.asset_util"
local Util = require "extension.lib.wg_util"
local EntUtil = require "extension.lib.ent_util"
local PrefabUtil = require "extension.lib.prefab_util"
local FxManager = Sample.FxManager
local AssetMaster = Sample.AssetMaster
local BuffManager = Sample.BuffManager

local prefs = {}

local function get_sound_path(inst)
    local sound_name = inst.soundsname or inst.prefab
    local path = inst.talker_path_override or "dontstarve/characters/"
    return path..sound_name
end

local function retarget_fn(inst)
    return FindEntity(inst, 16, function(target, inst)
        return inst.components.combat:CanTarget(target)
            and (target:HasTag("player") or target:HasTag("companion"))
    end)
end

local function keep_target_fn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function on_attacked(inst, data)
    if data.attacker then
        inst.components.combat:SetTarget(data.attacker)
    end
end

local function set_retarget_fn(inst)
    inst.components.combat:SetRetargetFunction(3, retarget_fn)
    inst.components.combat:SetKeepTargetFunction(keep_target_fn)

    inst:ListenForEvent("attacked", on_attacked)
end

local function FollowerRetarget(inst)
    local notags = {"FX", "NOCLICK","INLIMBO"}
    local newtarget = FindEntity(inst, 20, function(guy)
            return  guy.components.combat and 
                    inst.components.combat:CanTarget(guy) and
                    (guy.components.combat.target == GetPlayer() or GetPlayer().components.combat.target == guy)
    end, nil, notags)

    return newtarget
end

local function FollowerOnAttacked(inst, data)
    local attacker = data and data.attacker
    if attacker == GetPlayer() then
        return
    end
    inst.components.combat:SetTarget(attacker)
end

local function set_follower_retarget_fn(inst)
    inst.components.combat:SetRetargetFunction(3, FollowerRetarget)
    inst.components.combat:SetKeepTargetFunction(keep_target_fn)
    inst:ListenForEvent("attacked", FollowerOnAttacked)
end

--[[
创建NPC  
(Prefab) 返回这个预制物  
name (string)名字  
creature (bool)是否是生物(会添加locomotor)
build (string)build动画名  
fn (func)定制函数  
]]
local function MakeNpc(name, build, creature, fn)
    return Prefab(name, function()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        trans:SetFourFaced()
        local anim = inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        MakeCharacterPhysics(inst, 75, .5)
        inst.entity:AddDynamicShadow()
        inst.DynamicShadow:SetSize(1.3, .6)
        inst.AnimState:SetBank("wilson")
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("idle_loop")

        inst.AnimState:Hide("ARM_carry")
		inst.AnimState:Hide("hat")
		inst.AnimState:Hide("hat_hair")
		inst.AnimState:Hide("PROPDROP")
        inst.soundsname = build
        inst:AddTag("tp_npc")
        inst:AddTag("like_player")
        inst:AddComponent("inspectable")
        inst:AddComponent("talker")
        if creature then
            inst.creature = true
            inst:AddComponent("locomotor")
            inst.components.locomotor.walkspeed = 4
            inst.components.locomotor.runspeed = 6
        end
        inst:ListenForEvent("ontalk", function(inst, data)
            if math.random() < .33 then
                inst.SoundEmitter:PlaySound(get_sound_path(inst).."/talk_LP", "talk")
            end
            if not inst.creature then
                inst.AnimState:PlayAnimation("dial_loop", true)
                inst:DoTaskInTime(1.5, function()
                    inst.AnimState:PlayAnimation("idle_loop")
                end)
            end
            inst:DoTaskInTime(1.5, function()
                inst.SoundEmitter:KillSound("talk")
            end)
        end)

        MakeMediumBurnableCharacter(inst, "body")
        MakeLargeFreezableCharacter(inst)
        MakePoisonableCharacter(inst, nil, nil, 0, 0, 0)
        inst:AddComponent("sleeper")
        inst.components.sleeper:SetResistance(4)
        inst.components.sleeper:SetSleepTest(function(inst)
            return false
        end)
        inst.components.sleeper:SetWakeTest(function(inst)
            return true
        end)

        if fn then
            fn(inst)
        end
        
        return inst
    end)
end

local function override(inst, weapon, armor, hat)
    if weapon then
        local s1, b1, s12 = AssetMaster:GetSymbol(weapon)
        inst.AnimState:Show("ARM_carry")
        inst.AnimState:Hide("ARM_normal")
        inst.AnimState:OverrideSymbol(s1, b1, s12)
    end
    if armor then
        local s2, b2, s22 = AssetMaster:GetSymbol(armor)
        inst.AnimState:OverrideSymbol(s2, b2, s22)
    end
    if hat then
        local s3, b3, s32 = AssetMaster:GetSymbol(hat)
        inst.AnimState:Show("HAT")
        inst.AnimState:Show("HAIR_HAT")
        inst.AnimState:Hide("HAIR_NOHAT")
        inst.AnimState:Hide("HAIR")
        inst.AnimState:Hide("HEAD")
        inst.AnimState:Show("HEAD_HAIR")
        inst.AnimState:Hide("HAIRFRONT")
        inst.AnimState:OverrideSymbol(s3, b3, s32)
    end
end

local npc_armor = Prefab("tp_npc_armor", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(450, .8) 
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(inst.Remove)

    return inst
end)
table.insert(prefs, npc_armor)

local npc_helm = Prefab("tp_npc_helm", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(450, .8) 
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(inst.Remove)

    return inst
end)
table.insert(prefs, npc_helm)

local npc_staff = Prefab("tp_npc_staff", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(function(inst, owner)
        local dmg = owner.components.combat.defaultdamage
        inst.components.weapon:SetDamage(dmg)
    end)
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(10)
    inst.components.weapon:SetRange(8,10)
    inst.components.weapon:SetProjectile("fire_projectile")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(inst.Remove)

    return inst
end)
table.insert(prefs, npc_staff)

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

local templar = MakeNpc("tp_templar", "wilson", true, function(inst)
    -- override(inst, "tp_spear_lance", "tp_armor_health", "tp_helm_combat")
    override(inst, "tp_spear_fire", "tp_armor_fire", "tp_helm_warm")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(600)
    inst.components.health:StartRegen(20, 5)
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(35)
    inst.components.combat:SetAttackPeriod(3)
    -- inst.components.combat:SetRange(1,1)
    inst.components.combat.onkilledbyother = function(inst, attacker)
        if attacker.components.tp_level then
            attacker.components.tp_level:ExpDelta(10)
        end
    end
    set_retarget_fn(inst)
    inst.components.combat.dmg_type = "spike"
    inst.components.combat:SetDmgTypeAbsorb("fire", 1.2)
    inst.components.combat:SetDmgTypeAbsorb("shadow", 1.5)
    inst.components.combat:SetDmgTypeAbsorb("holly", .7)
    inst.components.combat:SetDmgTypeAbsorb("poison", .7)
    inst.components.combat.hiteffectsymbol = "torso"
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6
    inst:AddComponent("inventory")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({
        -- "ak_ssd", "tp_gift", "tp_alloy_enchant2",
        -- "ak_food_compressor_bp",
        -- "tp_spear_lance", "tp_helm_combat",
        "ak_ssd", "tp_epic", "tp_epic", "tp_epic",
    })
    inst:ListenForEvent("attacked", function(inst, data)
        inst.components.talker:Say("拥抱战斗的荣耀")
        if data and data.attacker then
            inst.components.combat:SetTarget(data.attacker)
        end
    end)
    -- inst.atk_num = 0
    inst.castspell = function(inst)
        local fx = FxManager:MakeFx("templar_magic", inst, {owner=inst})
    end
    inst:ListenForEvent("doattack", function(inst)
        -- inst.atk_num = inst.atk_num + 1
        -- if inst.atk_num >= 3 then
        --     inst.atk_num = 0
        -- end
        if math.random() < .4 then
            inst:DoTaskInTime(2, function()
                inst:PushEvent("castspell")
            end)
        end
    end)
    -- inst:DoTaskInTime(.1, function()
    --     if inst.equipped == nil then
    --         local helm = SpawnPrefab("tp_npc_helm")
    --         helm.Transform:SetPosition(0,0,0)
    --         inst.components.inventory:Equip(helm)
    --         local armor = SpawnPrefab("tp_npc_armor")
    --         armor.Transform:SetPosition(0,0,0)
    --         inst.components.inventory:Equip(armor)
    --         inst.equipped = true
    --     end
    -- end)
    inst:DoTaskInTime(0, function()
        close_door(inst)
    end)
    inst:ListenForEvent("death", open_door)
    inst.OnSave = function(inst, data)
        data.equipped = inst.equipped
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.equipped = data.equipped
        end
    end
    inst:SetStateGraph("SGtp_npc")
    inst:SetBrain(require "brains/tp_creature_brain2")

end)
table.insert(prefs, templar)
Util:AddString(templar.name, "圣堂武士", 
"攻击时有几率召唤一圈战矛，环绕一会后会攻击敌人，并回复自身生命值")

local templar_proj = Prefab("tp_templar_proj", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.AnimState:SetBank("tp_spear_lance")
    inst.AnimState:SetBuild("tp_spear_lance")
    inst.AnimState:PlayAnimation("throw")
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(20)
    inst.components.weapon.dmg_type = "holly"
    inst:AddComponent("wg_projectile")
    inst.components.wg_projectile:SetSpeed(15)
    -- inst.components.wg_projectile:SetOnThrownFn(function(inst, owner, target) end)
    inst.components.wg_projectile:SetOnMissFn(function(inst, owner, target) 
        inst:Remove()
    end)
    inst.components.wg_projectile:SetOnHitFn(function(inst, owner, target)
        if owner:HasTag("player") then
            BuffManager:AddBuff(target, "tp_templar_proj_debuff")
        end
        if owner.components.health then
            local dmg = inst.components.weapon.damage
            owner.components.health:DoDelta(dmg)
        end
        local impactfx = SpawnPrefab("impact")
        if impactfx and owner then
            local follower = impactfx.entity:AddFollower()
            follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
            impactfx:FacePoint(owner.Transform:GetWorldPosition())
        end          
        inst.components.wg_projectile.onmiss(inst, owner, target)
    end)
    inst.components.wg_projectile:SetHoming(false)
    inst.components.wg_projectile:SetLaunchOffset(Vector3(0, 0.2, 0))
    
    return inst
end)
table.insert(prefs, templar_proj)

local templar_room = deepcopy(require "prefabs/tp_boss_room")
PrefabUtil:SetPrefabName(templar_room, "tp_templar_room")
PrefabUtil:HookPrefabFn(templar_room, function(inst)
    inst.boss_name = "tp_templar"
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wilson")
    inst.AnimState:PlayAnimation("sleep")
    -- inst.AnimState:Show("HAT")
    -- inst.AnimState:Show("HAIR_HAT")
    -- inst.AnimState:Hide("HAIR_NOHAT")
    -- inst.AnimState:Hide("HAIR")
    -- inst.AnimState:Hide("HEAD")
    -- inst.AnimState:Show("HEAD_HAIR")
    -- inst.AnimState:Hide("HAIRFRONT")
    -- inst.AnimState:OverrideSymbol("swap_hat", "hat_bandit", "swap_hat")
    -- inst.AnimState:OverrideSymbol("swap_body", "armor_vortex_cloak", "swap_body")
    -- inst.AnimState:Show("ARM_carry")
    -- inst.AnimState:Hide("ARM_normal")
    -- inst.AnimState:OverrideSymbol("swap_object", "tp_spear_lance", "swap_object")
    override(inst, "tp_spear_fire", "tp_armor_fire", "tp_helm_warm")

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
table.insert(prefs, templar_room)
Util:AddString(templar_room.name, "圣堂武士的梦境", "是时候正面击溃他了")

local cave_shadow = MakeNpc("tp_cave_shadow", "wilson", true, function(inst)
    inst:AddComponent("colourtweener")
    inst.components.colourtweener:StartTween({0,0,0,.5}, 0)

    inst.Physics:ClearCollisionMask()
    inst.Physics:SetCollisionGroup(COLLISION.SANITY)
    inst.Physics:CollidesWith(COLLISION.SANITY)
    inst.Physics:CollidesWith(COLLISION.GROUND)

    inst:AddTag("shadowcreature")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(350)
    inst.components.health:StartRegen(10, 5)
    inst.components.health.nofadeout = true

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(25)
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat.onkilledbyother = function(inst, attacker)
        if attacker.components.tp_level then
            attacker.components.tp_level:ExpDelta(3)
        end
    end
    set_retarget_fn(inst)
    inst.components.combat.hiteffectsymbol = "torso"
    
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6
    inst.components.locomotor.pathcaps = { ignorecreep = true }

    inst:AddComponent("inventory")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({
        "nightmarefuel", "nightmarefuel", 
        "livinglog",
    })
    inst.components.lootdropper:AddChanceLoot("livinglog", .3)
    inst:ListenForEvent("attacked", function(inst, data)
        if data and data.attacker then
            inst.components.combat:SetTarget(data.attacker)
        end
    end)
    inst:ListenForEvent("death", function(inst, data)
        inst:DoTaskInTime(1, function()        
            SpawnPrefab("statue_transition").Transform:SetPosition(inst:GetPosition():Get())
            SpawnPrefab("statue_transition_2").Transform:SetPosition(inst:GetPosition():Get())
            inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_despawn")
            inst:Remove()
        end)
    end)
    -- inst.atk_num = 0
    inst.castspell = function(inst)
    end
    inst.OnSave = function(inst, data)
        data.equipped = inst.equipped
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.equipped = data.equipped
        end
    end
    inst:SetStateGraph("SGtp_npc")
    inst:AddTag("tp_not_freezable")
    inst:AddTag("tp_not_fire_damage")
    inst:AddTag("tp_not_burnable")
    inst:AddTag("tp_not_poisonable")
end)
-- table.insert(prefs, cave_shadow)

local cave_shadow2 = deepcopy(cave_shadow)
PrefabUtil:SetPrefabName(cave_shadow2, "tp_cave_shadow2")
PrefabUtil:HookPrefabFn(cave_shadow2, function(inst)
    inst.AnimState:SetBuild("wathgrithr")
    override(inst, "nightsword", nil, "tp_helm_combat")
    inst.components.lootdropper:AddChanceLoot("nightsword", 1)
    inst:SetBrain(require "brains/tp_creature_brain2")
end)
table.insert(prefs, cave_shadow2)
Util:AddString(cave_shadow2.name, "洞穴之影", "黑暗中的生物")

local cave_shadow3 = deepcopy(cave_shadow)
PrefabUtil:SetPrefabName(cave_shadow3, "tp_cave_shadow3")
PrefabUtil:HookPrefabFn(cave_shadow3, function(inst)
    inst.AnimState:SetBuild("willow")
    inst.AnimState:OverrideSymbol("swap_object", "swap_staffs", "bluestaff")
    inst.AnimState:Show("ARM_carry") 
    inst.AnimState:Hide("ARM_normal") 
    inst.components.lootdropper:AddChanceLoot("icestaff", 1)
    inst.components.combat:SetDefaultDamage(10)
    inst.components.combat:SetAttackPeriod(6)
    inst:DoTaskInTime(.1, function()
        if inst.equipped == nil then
            inst.equipped = true
            local weapon = SpawnPrefab("tp_npc_staff")
            weapon.Transform:SetPosition(0,0,0)
            inst.components.inventory:Equip(weapon)
        end
    end)
    inst.castspell = function(inst)
        inst:DoTaskInTime(1, function()
            local target = inst.components.combat.target
            if target and target.components.inventory then
                local weapon = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if weapon then
                    target.components.inventory:DropItem(weapon)
                end
            end
        end)
    end
    inst:ListenForEvent("doattack", function(inst)
        inst:DoTaskInTime(2, function()
            inst:PushEvent("castspell")
        end)
    end)
    inst:SetBrain(require "brains/tp_creature_brain")
end)
table.insert(prefs, cave_shadow3)
Util:AddString(cave_shadow3.name, "洞穴之影", "黑暗中的生物")

local cave_shadow4 = deepcopy(cave_shadow)
PrefabUtil:SetPrefabName(cave_shadow4, "tp_cave_shadow4")
PrefabUtil:HookPrefabFn(cave_shadow4, function(inst)
    inst.AnimState:SetBuild("wolfgang")
    inst.AnimState:OverrideSymbol("swap_object", "swap_peg_leg", "swap_object")
	inst.AnimState:Show("ARM_carry")
	inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_body", "armor_marble", "swap_body")
    inst.components.lootdropper:AddChanceLoot("armormarble", 1)
    inst.components.health:SetMaxHealth(500)
    inst.components.health:StartRegen(20, 5)
    inst.components.combat:SetDefaultDamage(10)
    inst:DoTaskInTime(.1, function()
        if inst.equipped == nil then
            inst.equipped = true
            local armor = SpawnPrefab("tp_npc_armor")
            armor.Transform:SetPosition(0,0,0)
            inst.components.inventory:Equip(armor)
        end
    end)

    inst:SetBrain(require "brains/tp_creature_brain2")
end)
table.insert(prefs, cave_shadow4)
Util:AddString(cave_shadow4.name, "洞穴之影", "黑暗中的生物")

-- 温蒂
local firekeeper = MakeNpc("tp_firekeeper", "wendy", nil, function(inst)
    ChangeToObstaclePhysics(inst)
    -- inst.Physics:ClearCollisionMask()
    -- inst.Physics:SetCollisionGroup(COLLISION.SANITY)
    -- inst.Physics:CollidesWith(COLLISION.SANITY)
    -- inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    if inst:HasTag("player") then
        inst.AnimState:Hide("HEAD")
        inst.AnimState:Show("HEAD_HAIR")
        inst.AnimState:Hide("HAIRFRONT")
    end
    inst.AnimState:OverrideSymbol("swap_hat", "hat_rain", "swap_hat")
    inst.AnimState:OverrideSymbol("swap_body", "torso_rain", "swap_body")

    inst:AddComponent("talker")
    inst:AddComponent("wg_chatable")
    inst.components.wg_chatable.test = function(inst, doer) 
        return true
    end
    inst.msg = 1
    inst.components.wg_chatable.fn = function(inst, doer) 
        inst:ForceFacePoint(doer:GetPosition())
        if inst.msg == 1 then 
            inst.components.talker:SayLines({
                "XXX,你为何会出现在这里",
                "如果你想在这里存活下去",
                "最好带上这个",
            })
            inst.msg = 2
            inst:DoTaskInTime(5, function()
                local item = SpawnPrefab("tp_recover_bottle")
                local pos = Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition()))
                doer.components.inventory:GiveItem(item, nil, pos)
            end)
        elseif inst.msg == 2 then
            inst.components.talker:SayLines({
                "XXX,去找到其他的幸存者吧",
                "他们会帮助你的",
            })
            inst.msg = 2
        end
    end
    inst.OnSave = function(inst, data)
        if data then
            data.msg = inst.msg
        end
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.msg = data.msg
        end
    end

    inst:SetStateGraph("SGtp_npc")
end)
table.insert(prefs, firekeeper)
Util:AddString(firekeeper.name, "卖火堆的小女孩", "像是在等待着什么")

local egg_stealer0 = MakeNpc("tp_egg_stealer0", "wilson", nil, function(inst)
    ChangeToObstaclePhysics(inst)
    -- inst.Physics:ClearCollisionMask()
    -- inst.Physics:SetCollisionGroup(COLLISION.SANITY)
    -- inst.Physics:CollidesWith(COLLISION.SANITY)
    -- inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    if inst:HasTag("player") then
        inst.AnimState:Hide("HEAD")
        inst.AnimState:Show("HEAD_HAIR")
        inst.AnimState:Hide("HAIRFRONT")
    end
    inst.AnimState:OverrideSymbol("swap_hat", "hat_winter", "swap_hat")
    -- inst.AnimState:OverrideSymbol("swap_body", "torso_rain", "swap_body")

    inst:AddComponent("talker")
    inst:AddComponent("wg_chatable")
    inst.components.wg_chatable.test = function(inst, doer) 
        return true
    end
    inst.components.wg_chatable.fn = function(inst, doer) 
        inst:ForceFacePoint(doer:GetPosition())
        inst.components.talker:SayLines({
            "XXX,你好",
            "我是一个生物学家",
            "我做实验需要一些高鸟蛋",
            "但是那些家伙实在是太可怕了",
            "你能给我一个高鸟蛋吗?",
        })
    end
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(function(inst, item, giver)
        if item.prefab == "tallbirdegg" then
            return true
        end
    end)
    inst.components.trader.onaccept = function(inst, giver, item)
        inst.components.talker:SayLines({
            "谢谢你!",
            "这下我可以进行实验了",
            "哦,糟糕!",
            "它们追过来了",
        })
        inst:ListenForEvent("donetalking", function(inst, data)
            local monster = SpawnPrefab("tallbird")
            monster.components.combat:SetTarget(giver)
            monster.Transform:SetPosition(inst.Transform:GetWorldPosition())
            FxManager:MakeFx("collapse_big", inst)
            inst:Hide()
            RemovePhysicsColliders(inst)
            inst:DoTaskInTime(1, inst.Remove)
            local player = GetPlayer()
            if player.components.tp_boss_spawner:CanSpawnBoss("tp_egg_stealer") then
                player.components.tp_boss_spawner:SpawnBoss("tp_egg_stealer")
                local start = c_find("tp_start_point")
                if start then
                    local pos = start:GetPosition()
                    SpawnPrefab("ak_research_center").Transform:SetPosition(pos.x, 0, pos.z+8)
                    SpawnPrefab("tp_egg_stealer").Transform:SetPosition(pos.x, 0, pos.z+8-3)
                end
            end
        end)
    end
    inst.components.trader.onrefuse = function(inst, giver, item)
        inst.components.talker:SayLines({
            "我需要的不是这个",
        })
    end
    
    -- inst:SetStateGraph("SGtp_npc")
end)
table.insert(prefs, egg_stealer0)
Util:AddString(egg_stealer0.name, "威尔", "需要帮助他吗?")

local egg_stealer = MakeNpc("tp_egg_stealer", "wilson", nil, function(inst)
    ChangeToObstaclePhysics(inst)
    -- inst.Physics:ClearCollisionMask()
    -- inst.Physics:SetCollisionGroup(COLLISION.SANITY)
    -- inst.Physics:CollidesWith(COLLISION.SANITY)
    -- inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    if inst:HasTag("player") then
        inst.AnimState:Hide("HEAD")
        inst.AnimState:Show("HEAD_HAIR")
        inst.AnimState:Hide("HAIRFRONT")
    end
    inst.AnimState:OverrideSymbol("swap_hat", "hat_winter", "swap_hat")
    -- inst.AnimState:OverrideSymbol("swap_body", "torso_rain", "swap_body")

    inst:AddComponent("talker")
    inst:AddComponent("wg_chatable")
    inst.components.wg_chatable.test = function(inst, doer) 
        return true
    end
    inst.msg = 1
    inst.components.wg_chatable.fn = function(inst, doer) 
        inst:ForceFacePoint(doer:GetPosition())
        -- if inst.msg == 1 then
        --     inst.components.talker:SayLines({
        --         "感谢你,陌生人",
        --         "这个送给你",
        --         "祝你好运",
        --     })
        --     inst:DoTaskInTime(1, function()
        --         doer.components.inventory:GiveItem(SpawnPrefab("ak_ornament_festivalevents4"))
        --     end)
        --     inst.msg = 2
        -- else
        --     inst.components.talker:SayLines({
        --         "你还要吗?",
        --         "可是我已经没有别的了",
        --     })
        -- end
        inst.components.talker:SayLines({
            "感谢你,我的实验得以进行",
            "你要加入我吗?",
        })
    end
    -- inst.OnSave = function(inst, data)
    --     if data then
    --         data.msg = inst.msg
    --     end
    -- end
    -- inst.OnLoad = function(inst, data)
    --     if data then
    --         inst.msg = data.msg
    --     end
    -- end

    inst:SetStateGraph("SGtp_npc")
end)
table.insert(prefs, egg_stealer)
Util:AddString(egg_stealer.name, "偷鸟蛋的威尔", "或许他在做果腹实验")

local blacksmith0 = MakeNpc("tp_blacksmith0", "maxwell", nil, function(inst)
    -- ChangeToObstaclePhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    if inst:HasTag("player") then
        inst.AnimState:Hide("HEAD")
        inst.AnimState:Show("HEAD_HAIR")
        inst.AnimState:Hide("HAIRFRONT")
    end
    inst.AnimState:OverrideSymbol("swap_hat", "hat_candle", "swap_hat")
    -- inst.AnimState:OverrideSymbol("swap_body", "torso_rain", "swap_body")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_object", "swap_hammer", "swap_hammer")

    inst:AddComponent("talker")
    inst:AddComponent("wg_chatable")
    inst.components.wg_chatable.test = function(inst, doer) 
        return true
    end
    inst.msg = 1
    inst.components.wg_chatable.fn = function(inst, doer) 
        inst:ForceFacePoint(doer:GetPosition())
        if inst.msg == 1 then
            inst.components.talker:SayLines({
                "嘿!朋友,我是铁匠沃尔夫",
                "我的锤子坏了",
                "可否帮我找一个锤子",
            })
        end
    end
    inst.components.trader.onaccept = function(inst, giver, item)
        inst.components.talker:SayLines({
            "太棒了!",
            "现在我能继续敲打那些铁疙瘩了",
        })
        inst:ListenForEvent("donetalking", function(inst, data)
            FxManager:MakeFx("collapse_big", inst)
            inst:Hide()
            RemovePhysicsColliders(inst)
            inst:DoTaskInTime(1, inst.Remove)
            local player = GetPlayer()
            if player.components.tp_boss_spawner:CanSpawnBoss("tp_blacksmith") then
                local start = c_find("tp_start_point")
                if start then
                    player.components.tp_boss_spawner:SpawnBoss("tp_blacksmith")
                    local pos = start:GetPosition()
                    SpawnPrefab("tp_blacksmith").Transform:SetPosition(pos.x, 0, pos.z-8)
                    SpawnPrefab("ak_work_bench").Transform:SetPosition(pos.x, 0, pos.z-8-3)
                end
            end
        end)
    end
    inst.components.trader.onrefuse = function(inst, giver, item)
        inst.components.talker:SayLines({
            "这或许是另一种锤子",
            "但不是我需要的锤子",
        })
    end

    inst:SetStateGraph("SGtp_npc")
end)
table.insert(prefs, blacksmith0)
Util:AddString(blacksmith0.name, "沃尔夫", "看起来有点东西")

local blacksmith = MakeNpc("tp_blacksmith", "wolfgang", nil, function(inst)
    ChangeToObstaclePhysics(inst)
    -- inst.Physics:ClearCollisionMask()
    -- inst.Physics:SetCollisionGroup(COLLISION.SANITY)
    -- inst.Physics:CollidesWith(COLLISION.SANITY)
    -- inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    if inst:HasTag("player") then
        inst.AnimState:Hide("HEAD")
        inst.AnimState:Show("HEAD_HAIR")
        inst.AnimState:Hide("HAIRFRONT")
    end
    inst.AnimState:OverrideSymbol("swap_hat", "hat_candle", "swap_hat")
    -- inst.AnimState:OverrideSymbol("swap_body", "torso_rain", "swap_body")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_object", "swap_hammer", "swap_hammer")

    inst:AddComponent("talker")
    inst:AddComponent("wg_chatable")
    inst.components.wg_chatable.test = function(inst, doer) 
        return true
    end
    inst.msg = 1
    inst.components.wg_chatable.fn = function(inst, doer) 
        inst:ForceFacePoint(doer:GetPosition())
        if inst.msg == 1 then
            inst.components.talker:SayLines({
                "没想到你也在这里,真是太好了",
                "这是我的工作台",
                "我平时用它来锻造工具",
                "现在它也归你了",
            })
            inst.msg = 2
        else
            inst.components.talker:SayLines({
                "或许你需要这个",
            })
            doer.components.inventory:GiveItem(SpawnPrefab("tp_infused_nugget_black"))
        end
    end
    inst.OnSave = function(inst, data)
        if data then
            data.msg = inst.msg
        end
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.msg = data.msg
        end
    end

    inst:SetStateGraph("SGtp_npc")
end)
table.insert(prefs, blacksmith)
Util:AddString(blacksmith.name, "打铁的沃尔夫", "他的手艺应该很棒")

local shadow_fighter = MakeNpc("tp_shadow_fighter", "maxwell", true, function(inst)
    inst:DoTaskInTime(0, function()
        inst.AnimState:SetBuild(GetPlayer().prefab)
    end)
    inst:AddTag("tp_shadow_fighter")
    inst:AddTag("tp_not_freezable")
    inst:AddTag("tp_not_fire_damage")
    inst:AddTag("tp_not_burnable")
    inst:AddTag("tp_not_poisonable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(500)
    inst.components.health:StartRegen(20, 5)
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(40)
    inst.components.combat:SetAttackPeriod(3)
    -- inst.components.combat:SetRange(1,1)
    -- set_retarget_fn(inst)
    set_follower_retarget_fn(inst)
    inst.components.combat.dmg_type = "shadow"
    inst.components.combat:SetDmgTypeAbsorb("shadow", .7)
    inst.components.combat:SetDmgTypeAbsorb("holly", 1.3)
    inst.components.combat.hiteffectsymbol = "torso"
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6
    inst:AddComponent("inventory")

    inst:AddComponent("follower")
    -- inst:ListenForEvent("doattack", function(inst)
    -- end)
    inst:ListenForEvent("start_lunge", function(inst, data)
        inst.enemies = {}
        local dmg = inst.components.combat.defaultdamage
        inst.lunge_task = inst:DoTaskInTime(.1, function()
            EntUtil:make_area_dmg(inst, 3.3, inst, dmg, nil, 
                EntUtil:add_stimuli(nil, "shadow"), 
                {
                    test = function(v,attacker,weapon)
                        return not inst.enemies[v]
                    end,
                    fn = function(v,attacker,weapon)
                        inst.enemies[v] = true
                    end,
                }
            )
        end)
    end)
    inst:ListenForEvent("stop_lunge", function(inst, data)
        inst.enemies = nil
        if inst.lunge_task then
            inst.lunge_task:Cancel()
            inst.lunge_task = nil
        end
    end)
    inst.set_symbol = function(inst, hand_symbol, body_symbol, head_symbol)
        inst.hand_symbol = hand_symbol
        inst.body_symbol = body_symbol
        inst.head_symbol = head_symbol
        override(inst, inst.hand_symbol, inst.body_symbol, inst.head_symbol)
    end
    inst.OnSave = function(inst, data)
        data.hand_symbol = inst.hand_symbol
        data.body_symbol = inst.body_symbol
        data.head_symbol = inst.head_symbol
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst:DoTaskInTime(0, function()
                inst:set_symbol(data.hand_symbol, data.body_symbol, data.head_symbol)
            end)
        end
    end
    inst:SetStateGraph("SGtp_npc")
    inst:SetBrain(require "brains/abigailbrain")
end)
table.insert(prefs, shadow_fighter)
Util:AddString(shadow_fighter.name, "暗影斗士", "看不清楚")

local guide = Prefab("tp_guide", function()
    local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.75, .75 )
    inst.Transform:SetTwoFaced()

    anim:SetBank("maxwell")
    anim:SetBuild("maxwell_build")
    anim:PlayAnimation("appear")
    anim:PushAnimation("idle", true)

    inst:AddTag("notarget")

    inst:AddComponent("named")
    inst.components.named:SetName(STRINGS.NAMES.MAXWELL)

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 40
    inst.components.talker.font = TALKINGFONT
    --inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
    inst.components.talker.offset = Vector3(0,-700,0)

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "maxwell"

    inst:ListenForEvent("ontalk", function(inst, data)
        if math.random() < .33 then
            inst.SoundEmitter:PlaySound("dontstarve/maxwell/talk_LP", "talk")
        end
        inst.AnimState:PlayAnimation("dialog_pre")
        inst.AnimState:PushAnimation("dial_loop")
        inst.AnimState:PushAnimation("dial_pst")
        inst.AnimState:PushAnimation("idle", true)
        inst:DoTaskInTime(1.5, function()
            inst.SoundEmitter:KillSound("talk")
        end)
    end)
    
    return inst
end, {})
table.insert(prefs, guide)

local invisible_man = Prefab("tp_invisible_man", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    trans:SetFourFaced()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("tp_invisible_man")
    inst.AnimState:PlayAnimation("idle_loop")

    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Hide("hat")
    inst.AnimState:Hide("hat_hair")
    inst.AnimState:Hide("PROPDROP")

    -- inst:AddTag("tp_npc")
    inst:AddTag("like_player")

    return inst
end, {
    Asset("ANIM", "anim/tp_invisible_man.zip"),
})
table.insert(prefs, invisible_man)

local start_point = Prefab("tp_start_point", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    -- trans:SetFourFaced()
    -- local anim = inst.entity:AddAnimState()
    -- inst.entity:AddSoundEmitter()
    -- phy
    -- shadow
    -- map
    inst:AddTag("tp_start_point")
    
    return inst
end)
table.insert(prefs, start_point)

local points = {
    "boss",
    "room_boss",
    "cave_boss",
    "ruin_boss",
}
for k, v in pairs(points) do
    local name = "tp_point_postman"
    if k > 1 then
        name = name..tostring(k)
    end
    local point = Prefab(name, function()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        inst:AddTag("tp_point_postman")
        inst:AddComponent("tp_postman")
        inst.components.tp_postman.kind = v
        inst:DoTaskInTime(1, function()
            local pos = inst:GetPosition()
            GetPlayer().components.tp_point_collector:CollectPoint(pos, inst.kind)
            inst:Remove()
        end)
        
        return inst
    end, {})
    table.insert(prefs, point)
end

local walls = {loadfile("prefabs/walls")()}
local wall_wood = deepcopy(walls[5])
PrefabUtil:SetPrefabName(wall_wood, "tp_wall_wood")
PrefabUtil:HookPrefabFn(wall_wood, function(inst)
    -- if inst.MiniMapEntity then
    --     inst.MiniMapEntity:SetIcon("")
    -- end
    inst:AddTag("tp_wall_wood")
    inst.components.lootdropper:SetLoot({})
    inst:Hide()
    inst.Physics:SetCollides(false)
    inst.active = nil
    inst.wake = function(inst)
        inst.active = true
        inst:Show()
        inst.Physics:SetCollides(true)
    end
    inst.OnSave = function(inst, data)
        data.active = inst.active
    end
    local OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if data and data.active then
            inst:wake()
        end
        OnLoad(inst, data)
    end
end)
table.insert(prefs, wall_wood)
Util:AddString(wall_wood.name, "木墙", "似乎不是木墙")

return unpack(prefs)