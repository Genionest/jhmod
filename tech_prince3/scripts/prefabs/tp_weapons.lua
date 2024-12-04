local Util = require "extension.lib.wg_util"
local AssetUtil = require "extension/lib/asset_util"
local PrefabUtil = require "extension/lib/prefab_util"
local EntUtil = require "extension/lib/ent_util"
local Kit = require "extension.lib.wargon"
local AssetMaster = Sample.AssetMaster
local BuffManager = Sample.BuffManager
local Info = Sample.Info
local FxManager = Sample.FxManager
local EnchantmentManager = Sample.EnchantmentManager

local prefs = {}

local WeaponDamage = Info.Weapon.WeaponDamage
local WeaponUse = Info.Weapon.WeaponUse

--[[
创建武器预制物  
(Prefab) 返回预制物  
name (string)名字  
damage (number)伤害  
on_attack (func)攻击触发函数  
equip (func)装备时触发函数  
unequip (func)卸下时触发函数  
use (number)耐久度，可以为nil  
fn (func)自定以函数，可以为nil  
not_fixable (bool)是否不可被修复  
]]
local function MakeWeapon(name, damage, on_attack, equip, unequip, use, fn, not_fixable)
    return Prefab("common/inventory/"..name, function()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        MakeInventoryPhysics(inst)
        local bank, build, animation, water = AssetMaster:GetAnimation(name, true)
        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(animation)
        if water then
            MakeInventoryFloatable(inst, water, animation)
        end
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        local atlas, image = AssetMaster:GetImage(name, true)
        if string.find(image, ".tex") then
            assert(nil, "image should not have \".tex\"")
        end
        inst.components.inventoryitem.atlasname = atlas
        inst.components.inventoryitem:ChangeImageName(image)
        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(damage)
        inst.components.weapon:SetOnAttack(on_attack)
        
        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
        inst.components.equippable:SetOnEquip(equip)
        inst.components.equippable:SetOnUnequip(unequip)
        inst.components.equippable.symbol = name
    
        if use then
            inst:AddComponent("finiteuses")
            inst.components.finiteuses:SetMaxUses(use)
            inst.components.finiteuses:SetUses(use)
            inst.components.finiteuses:SetOnFinished(function(inst)
                inst:Remove()
            end)
        end

        if not not_fixable then
            inst:AddTag("tp_can_fix")
            inst:AddComponent("wg_interable")
        end

        if fn then
            fn(inst)
        end

        return inst
    end, AssetMaster:GetDSAssets(name))
end

local function make_bp(name)
    local scr_name = Util:GetScreenName(name).."蓝图"
    local name = name.."_bp"
    Util:AddString(name, scr_name, "开礼包获得")
    local bp = Prefab(name, function()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        MakeInventoryPhysics(inst)
        local bank, build, animation, water = AssetMaster:GetAnimation(name, true)
        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(animation)
        if water then
            MakeInventoryFloatable(inst, water, animation)
        end
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        local atlas, image = AssetMaster:GetImage(name, true)
        if string.find(image, ".tex") then
            assert(nil, "image should not have \".tex\"")
        end
        inst.components.inventoryitem.atlasname = atlas
        inst.components.inventoryitem:ChangeImageName(image)
        return inst
    end, {})
    table.insert(prefs, bp)
end

local spear_lance = MakeWeapon("tp_spear_lance", WeaponDamage[1], 
    nil, nil, nil, WeaponUse[1], 
function(inst)
    inst:AddComponent("wg_projectile")
    inst.components.wg_projectile:SetSpeed(25)
    inst.components.wg_projectile:SetOnThrownFn(function(inst, owner, target) 
        inst:AddTag("projectile")
        inst.AnimState:PlayAnimation("throw")
    end)
    inst.components.wg_projectile:SetOnMissFn(function(inst, owner, target) 
        inst:RemoveTag("projectile")
        if inst.components.floatable then
            inst.components.floatable:SetAnimationFromPosition()
        end
    end)
    inst.components.wg_projectile:SetOnHitFn(function(inst, owner, target)
        local impactfx = SpawnPrefab("impact")
        if impactfx and owner then
            local follower = impactfx.entity:AddFollower()
            follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
            impactfx:FacePoint(owner.Transform:GetWorldPosition())
        end
        inst.components.wg_projectile.onmiss(inst, owner, target)
    end)
    inst.components.wg_projectile:SetHoming(true)
    inst.components.wg_projectile:SetLaunchOffset(Vector3(0, 0.2, 0))
    inst.components.wg_projectile.test = function(inst, target, doer) 
        return true 
    end
    -- inst.components.wg_projectile:SetOnCaughtFn(function(inst, catcher)
    -- end)
end, true)
table.insert(prefs, spear_lance)
Util:AddString(spear_lance.name, "投掷战矛",
"可以投掷")

local spear_night = MakeWeapon("tp_spear_night", WeaponDamage[1], 
    nil, nil, nil, WeaponUse[1], 
function(inst)
    inst.components.weapon.getdamagefn = function(inst)
        local dmg = inst.components.weapon.damage
        if inst.night then
            dmg = dmg*1.25
        end
        return dmg
    end
    inst:DoTaskInTime(0, function()
        if GetClock():IsNight() then
            inst.night = true
        end
    end)
    inst:ListenForEvent("nighttime", function(world, data)
        inst.night = true
    end, GetWorld())
    inst:ListenForEvent("daytime", function(world, data)
        inst.night = nil
    end, GetWorld())
end, true)
table.insert(prefs, spear_night)
Util:AddString(spear_night.name, "夜之战矛",
"夜晚提升伤害")

local spear_sharp = MakeWeapon("tp_spear_sharp", WeaponDamage[1]*.8, 
    nil, nil, nil, WeaponUse[1], 
function(inst)
    inst.components.weapon.getdamagefn = function(inst)
        local dmg = inst.components.weapon.damage
        local p = inst.components.finiteuses:GetPercent()
        return math.floor((2-p)*dmg)
    end
end, true)
table.insert(prefs, spear_sharp)
Util:AddString(spear_sharp.name, "锋利战矛",
"每失去1%耐久度，提升1%的伤害")

local spear_enchant = MakeWeapon("tp_spear_enchant", WeaponDamage[1], 
nil, nil, nil, 100, 
function(inst)
    inst.components.finiteuses:SetOnFinished(function(inst)
        if inst.components.tp_enchantmentable:Test() then
            local spear = SpawnPrefab("tp_spear_enchant")
            for i = 1, 100 do
                local ids, kinds = EnchantmentManager:GetRandomIds(1, {"all", "weapon"})
                local data = EnchantmentManager:GetDataById(ids[1], kinds[1])
                -- print("a001", data:GetId())
                if spear.components.tp_enchantmentable:TestData(data) then
                    spear.components.tp_enchantmentable:Enchantment({
                        quality = 1,
                        ids = ids,
                    })
                    break
                end
            end
            local owner = inst.components.equippable.owner
            if owner and owner.components.inventory then
                owner.components.inventory:GiveItem(spear)
            else
                Kit:throw_item(spear, inst)
            end
        end
        inst:Remove()
    end)
end, true)
table.insert(prefs, spear_enchant)
Util:AddString(spear_enchant.name, "附魔之刃",
"若该武器未附魔，耐久用完后会给予你一把随机附魔的附魔之刃")

local spear_enchant2 = deepcopy(spear_enchant)
PrefabUtil:SetPrefabName(spear_enchant2, "tp_spear_enchant2")
PrefabUtil:HookPrefabFn(spear_enchant2, function(inst)
    inst:AddComponent("tp_enchantmentable")
    inst.components.tp_enchantmentable:SetQuality(5)
    for i = 1, 100 do
        local ids, kinds = EnchantmentManager:GetRandomIds(3, {"all", "weapon"})
        local can = true
        for i = 1, #ids do
            local data = EnchantmentManager:GetDataById(ids[i], kinds[i])
            if not inst.components.tp_enchantmentable:TestData(data) then
                can = false
                break
            end
        end
        -- print("a001", data:GetId())
        if can then
            inst.components.tp_enchantmentable:Enchantment({
                quality = 5,
                ids = ids,
            })
            break    
        end
    end
end)
table.insert(prefs, spear_enchant2)
Util:AddString(spear_enchant2.name, "附魔之刃", "获得随机附魔")

local SpearSpeedConst = {.25, 5}
local spear_speed = MakeWeapon("tp_spear_speed", WeaponDamage[2], 
function(inst, owner, target)
    local mult = SpearSpeedConst[1]
    local time = SpearSpeedConst[2]
    EntUtil:add_speed_mod(owner, inst.prefab, mult, time) 
end, nil, nil, WeaponUse[1], nil)
table.insert(prefs, spear_speed)
local spear_speed_desc = "攻击敌人后，会增加%d%%的移速%ds"
local spear_speed_str = string.format(spear_speed_desc, SpearSpeedConst[1]*100, SpearSpeedConst[2])
Util:AddString(spear_speed.name, "速度战矛", spear_speed_str)

local SpearSpeed2Const = {.1}
local spear_speed2 = deepcopy(spear_speed)
PrefabUtil:SetPrefabName(spear_speed2, "tp_spear_speed2")
PrefabUtil:HookPrefabFn(spear_speed2, function(inst)
    inst.components.weapon.getdamagefn = function(inst)
        local dmg = inst.components.weapon.damage
        local owner = inst.components.equippable.owner
        if owner then
            local base = owner.components.locomotor.runspeed
            local total = owner.components.locomotor:GetRunSpeed()
            local p = total/base
            if p>1 then
                dmg = dmg + dmg*(p-1)*SpearSpeed2Const[1]
            end
        end
        return dmg
    end
    inst.components.weapon:SetDamage(WeaponDamage[2]*1.5)
    inst.components.finiteuses:SetMaxUses(WeaponUse[2]*1.5)
    inst.components.finiteuses:SetUses(WeaponUse[2]*1.5)
end)
local spear_speed2_desc = "你每增加100%%的速度，提升%d%%的伤害；"
local spear_speed2_str = string.format(spear_speed2_desc, SpearSpeed2Const[1]*100)..spear_speed_str
Util:AddString(spear_speed2.name, "速度战矛II", spear_speed2_str)

local SpearSpeed3Const = {.01, 5, 30, 40}
local spear_speed3 = deepcopy(spear_speed2)
PrefabUtil:HookPrefabFn(spear_speed3, function(inst)
    inst.components.weapon:SetDamage(WeaponDamage[3])
    inst.components.finiteuses:SetMaxUses(WeaponUse[3])
    inst.components.finiteuses:SetUses(WeaponUse[3])
    inst.components.equippable.walkspeedmult = 0
    inst:AddComponent("tp_equip_level")
    inst.components.tp_equip_level:SetMax(20)
    inst.components.tp_equip_level.upgrade = function(inst, level, is_load)
        local spd = SpearSpeed3Const[1]*level
        local hp = SpearSpeed3Const[2]*level
        local san = SpearSpeed3Const[2]*level
        local hung = SpearSpeed3Const[2]*level
        inst.components.equippable.walkspeedmult = spd
        inst.components.equippable:WgAddEquipMaxHealthModifier("level", hp)
        inst.components.equippable:WgAddEquipMaxSanityModifier("level", san)
        inst.components.equippable:WgAddEquipMaxHungerModifier("level", hung)
        local owner = inst.components.equippable.owner
        if owner then
            local id = "equipslot_"..inst.components.equippable.equipslot
            EntUtil:add_speed_mod(inst, id, spd)
            owner.components.health:WgAddMaxHealthModifier(id, hp, not is_load)
            owner.components.sanity:WgAddMaxSanityModifier(id, san, not is_load)
            owner.components.hunger:WgAddMaxHungerModifier(id, hung, not is_load)
        end
    end
    inst:AddComponent("wg_recharge")
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(SpearSpeed3Const[3])
    inst.components.tp_equip_value.stop = function(inst)
        local owner = inst.components.equippable.owner
        if owner then
            EntUtil:rm_speed_mod(owner, inst.prefab.."2")
        end
    end
    inst.components.equippable:WgAddUnequipFn(function(inst, owner)
        EntUtil:rm_speed_mod(owner, inst.prefab.."2")
        inst.components.tp_equip_value:Runout()
    end)
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:RegisterSkillInfo({
        desc=string.format("若武器达到10级，令武器的加速效果翻倍%ds", 
            SpearSpeed3Const[3]),
    })
    inst.components.wg_action_tool.quality = 3
    inst.components.wg_action_tool.test = function(inst, doer)
        if inst.components.wg_recharge:IsRecharged() then
            return inst.components.tp_equip_level.level>=10
        end
    end
    inst.components.wg_action_tool.click_get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_SAIL
        end
    end
    -- inst.components.wg_action_tool.click_fn = function(inst, doer)
    --     -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作  
    -- end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        local rate = inst.components.equippable.walkspeedmult
        EntUtil:add_speed_mod(doer, inst.prefab.."2", rate)
        inst.components.tp_equip_value:SetPercent(1)
        inst.components.tp_equip_value:Start()
        inst.components.wg_recharge:SetRechargeTime(SpearSpeed3Const[4])
        FxManager:MakeFx("firework_fx", doer)
    end
    inst.components.inventoryitem:SetOnPutInInventoryFn(function(inst, owner)
        if inst.fx then
            inst.fx:Hide()
            FxManager:MakeFx("collapse_big", inst)
        end
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end)
    inst.components.inventoryitem:SetOnDroppedFn(function(inst, dropper)
        if inst.components.tp_equip_level.level >= 20 then
            inst.task = inst:DoTaskInTime(3, function()
                if inst.fx == nil then
                    inst.fx = SpawnPrefab("tp_spear_speed3_fx")
                    inst.fx.Transform:SetPosition(Vector3(0,0,0):Get())
                    inst:AddChild(inst.fx)
                    inst.fx:Hide()
                end
                inst.fx:Show()
                FxManager:MakeFx("collapse_big", inst)
            end)
        end
    end)
end)
PrefabUtil:SetPrefabName(spear_speed3, "tp_spear_speed3")
table.insert(prefs, spear_speed3)
local spear_speed3_desc = "可升级，每级提升%.2f%%移速和%d三围；10级以后，可以释放技能；20级以后，置于地面3s会召唤1个自动售货机；"
local spear_speed3_str = string.format(spear_speed3_desc, SpearSpeed3Const[1]*100, SpearSpeed3Const[2])..spear_speed2_str
Util:AddString(spear_speed3.name, "速度战矛III", spear_speed3_str)

local spear_speed3_fx = Prefab("tp_spear_speed3_fx", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    -- trans:SetFourFaced()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    local bank, build, animation  = AssetMaster:GetAnimation("tp_spear_speed3_fx")
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(animation)
    inst.AnimState:SetMultColour(1,1,1,.7)
    -- inst.AnimState:SetScale(2, 2, 2)
    inst:AddComponent("inspectable")
    inst:AddComponent("wg_recharge")
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(function(inst, item, giver)
        if inst.components.wg_recharge:IsRecharged() then
            return item.prefab == "tp_coin"
                and item.components.stackable:StackSize()>=10
        end
    end)
    inst.components.trader.onaccept = function(inst, giver, item)
        if item.components.stackable then
            item = item.components.stackable:Get(10)
        end
        item:Remove()
        local coffee = SpawnPrefab("coffee")
        Kit:throw_item(coffee, inst)
        inst.components.wg_recharge:SetRechargeTime(30*8)
    end
    
    return inst
end)
table.insert(prefs, spear_speed3_fx)
Util:AddString(spear_speed3_fx.name, "自动售货机(速度战矛III)",
"给予10个呼噜假币，返换你1杯咖啡，有半天的冷却")

local SpearIceConst = {.25}
local spear_ice = MakeWeapon("tp_spear_ice", WeaponDamage[2], 
function(inst, owner, target)
    if math.random() < SpearIceConst[1] then
        EntUtil:frozen(target)
    end
end, nil, nil, WeaponUse[2], nil)
table.insert(prefs, spear_ice)
Util:AddString(spear_ice.name, "冰冻战矛", 
string.format("攻击有%d%%的几率对敌人施加1层冰冻效果", SpearIceConst[1]*100))

local SpearFireConst = {.5}
local spear_fire = MakeWeapon("tp_spear_fire", WeaponDamage[2], 
function(inst, owner, target)
    if math.random() < SpearFireConst[1] then
        EntUtil:ignite(target)
    end
end, nil, nil, WeaponUse[2], nil)
table.insert(prefs, spear_fire)
Util:AddString(spear_fire.name, "火焰战矛",
string.format("攻击有%d%%的几率点燃敌人", SpearFireConst[1]*100))

local SpearConquerorConst = {5, 5, 1, .1}
local spear_conqueror = MakeWeapon("tp_spear_conqueror", WeaponDamage[1], 
function(inst, owner, target)
    if target:HasTag("monster") or target:HasTag("largecreature")
    or target:HasTag("epic") then
        inst.components.wg_recharge:SetRechargeTime(inst.const[2])
        inst.components.tp_equip_value:DoDelta(1)
        if inst.components.tp_equip_value:GetPercent()==1 then
            owner.components.combat:AddLifeStealRateMod(inst.prefab, inst.const[4])
        end
    end
end, nil,
function(inst, owner)
    owner.components.combat:RmLifeStealRateMod(inst.prefab)
end, WeaponUse[1], 
function(inst)
    inst.const = SpearConquerorConst
    inst:AddComponent("wg_action_tool")
    inst:AddComponent("wg_recharge")
    inst.components.wg_recharge.on_recharged = function(inst)
        inst.components.tp_equip_value:SetPercent(0)
        local owner = inst.components.equippable.owner
        if owner then
            owner.components.combat:RmLifeStealRateMod(inst.prefab)
        end
    end
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(inst.const[1])
    inst.components.weapon.getdamagefn = function(inst)
        local dmg = inst.components.weapon.damage
        local n = inst.components.tp_equip_value.current
        dmg = dmg + n*inst.const[3]
        return dmg
    end
end)
table.insert(prefs, spear_conqueror)
local spear_conqueror_str = "攻击怪物、大型生物和史诗生物会增加充能，每点充能会提升%d点攻击力，最多%d点充能，充能达到最大时，获得%d%%吸血。攻击后武器会进入冷却，冷却完成后，失去所有充能，期间再次攻击会重新进入冷却"
local spear_conqueror_desc = string.format(spear_conqueror_str, 
    SpearConquerorConst[3], SpearConquerorConst[1], 
    SpearConquerorConst[4]*100)
Util:AddString(spear_conqueror.name, "征服者", spear_conqueror_desc)

local SpearConqueror2Const = {5, 7.5, 3, .15, 5}
local spear_conqueror2 = deepcopy(spear_conqueror)
PrefabUtil:SetPrefabName(spear_conqueror2, "tp_spear_conqueror2")
PrefabUtil:HookPrefabFn(spear_conqueror2, function(inst)
    inst.const = SpearConqueror2Const
    inst.components.weapon:SetDamage(WeaponDamage[1]*1.5)
    inst.components.finiteuses:SetMaxUses(WeaponUse[1]*1.5)
    inst.components.finiteuses:SetUses(WeaponUse[1]*1.5)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner ,target)
        if inst.components.tp_equip_value:GetPercent()==1 then
            owner.components.sanity:DoDelta(inst.const[5])
        end
    end)
end)
table.insert(prefs, spear_conqueror2)
local spear_conqueror2_str = string.format(spear_conqueror_str, 
    SpearConqueror2Const[3], SpearConqueror2Const[1], 
    SpearConqueror2Const[4]*100)
local spear_conqueror2_desc = spear_conqueror2_str..string.format(
    "，充能满后，攻击还会回复%d点理智", SpearConqueror2Const[5])
Util:AddString(spear_conqueror2.name, "征服者II", spear_conqueror2_desc)

local SpearConqueror3Const = {5, 10, 5, .15, 8, 3, .1, .01}
local spear_conqueror3 = deepcopy(spear_conqueror2)
PrefabUtil:SetPrefabName(spear_conqueror3, "tp_spear_conqueror3")
PrefabUtil:HookPrefabFn(spear_conqueror3, function(inst)
    inst.const = deepcopy(SpearConqueror3Const)
    inst.components.weapon:SetDamage(WeaponDamage[2])
    inst.components.finiteuses:SetMaxUses(WeaponUse[2])
    inst.components.finiteuses:SetUses(WeaponUse[2])
    inst.components.wg_action_tool.quality = 2
    inst:AddComponent("tp_equip_level")
    inst.components.tp_equip_level:SetMax(10)
    inst.components.tp_equip_level.upgrade = function(inst, level, is_load)
        inst.const[4] = SpearConqueror3Const[4]+SpearConqueror3Const[8]*level
        local hp = SpearConqueror3Const[6]*level
        local san = SpearConqueror3Const[6]*level
        local hung = SpearConqueror3Const[6]*level
        inst.components.equippable:WgAddEquipMaxHealthModifier("level", hp)
        inst.components.equippable:WgAddEquipMaxSanityModifier("level", san)
        inst.components.equippable:WgAddEquipMaxHungerModifier("level", hung)
        local owner = inst.components.equippable.owner
        if owner then
            local id = "equipslot_"..inst.components.equippable.equipslot
            owner.components.health:WgAddMaxHealthModifier(id, hp, not is_load)
            owner.components.sanity:WgAddMaxSanityModifier(id, san, not is_load)
            owner.components.hunger:WgAddMaxHungerModifier(id, hung, not is_load)
        end
    end
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if inst.components.tp_equip_level.level >= 0 then
            local ex_hp = target.components.health:WgGetMaxHealthModifier()
            local amount = ex_hp*SpearConqueror3Const[7]
            BuffManager:AddBuff(owner, "tp_spear_conqueror3", nil, amount)
        end
    end)
end)
table.insert(prefs, spear_conqueror3)
local spear_conqueror3_str = string.format(spear_conqueror_str, 
    SpearConqueror3Const[3], SpearConqueror3Const[1], 
    SpearConqueror3Const[4]*100)
local spear_conqueror3_str2 = string.format(
    "，充能满后，攻击还会回复%d点理智，", SpearConqueror3Const[5])
local spear_conqueror3_str3 = string.format(
    "可升级，每级提升%d三围和%d%%满充能吸血；10级以后，攻击敌人会获得其额外生命值%d%%的生命加成；", 
    SpearConqueror3Const[6], SpearConqueror3Const[8]*100, 
    SpearConqueror3Const[7]*100)
local spear_conqueror3_desc = spear_conqueror3_str..spear_conqueror3_str2..spear_conqueror3_str3
Util:AddString(spear_conqueror3.name, "征服者III", spear_conqueror3_desc)

local spear_thunder_proj = Prefab("tp_spear_thunder_proj", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("bishop_attack")
    inst.AnimState:SetBuild("bishop_attack")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("projectile")
    inst.persists = false
    RemovePhysicsColliders(inst)
	inst.entity:AddSoundEmitter()
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(10)
	inst:AddComponent("wg_projectile")
	inst.enemies = {}
	inst.max_enemy = 0
	inst.find_target = function(inst, owner)
		if #inst.enemies >= inst.max_enemy then
			return
		end
		local owner = inst.owner
		local new_target = FindEntity(inst, 5, function(guy, inst)
			if owner and EntUtil:check_combat_target(owner, guy) then
				for k, v in pairs(inst.enemies) do
					if v == guy then
						return false
					end
				end
				return true
			end
		end, nil, EntUtil.not_enemy_tags)
		return new_target
	end
	inst.components.wg_projectile:SetSpeed(20)
	inst.components.wg_projectile:SetOnMissFn(function(inst, owner, target) 
		inst:Remove()
	end)
	inst.components.wg_projectile:SetOnHitFn(function(inst, owner, target)
		inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")
		table.insert(inst.enemies, target)
		local new_target = inst:find_target()
		if new_target then
			inst.components.wg_projectile:Throw(owner, new_target, owner)
		else
			inst.components.wg_projectile.onmiss(inst, owner, target)
		end
	end)
	inst.components.wg_projectile:SetLaunchOffset(Vector3(0, 0.2, 0))

    return inst
end, {})
table.insert(prefs, spear_thunder_proj)

local SpearThunderConst = {30, 50, 10}
local spear_thunder = MakeWeapon("tp_spear_thunder", WeaponDamage[2]*.75, 
function(inst, owner, target)
    if inst.components.wg_recharge:IsRecharged() 
    and inst.components.tp_equip_value:GetPercent()<=0 then
        -- 冷却好了，且未激活
        inst.components.tp_equip_value:SetPercent(1)
        inst.components.tp_equip_value:Start()
        inst.components.wg_recharge:SetRechargeTime(SpearThunderConst[2])
    end
    if inst.components.tp_equip_value.current > 0 then
        -- 拥有充能
        local proj = SpawnPrefab("tp_spear_thunder_proj")
        proj.Transform:SetPosition(owner:GetPosition():Get())
        proj.max_enemy = SpearThunderConst[3]
        table.insert(proj.enemies, target)
        proj.owner = owner
        local new_target = proj:find_target()
        if new_target then
            proj.components.wg_projectile:Throw(owner, new_target, owner)
        else
            proj:Remove()
        end 
    end
end, nil, nil, WeaponUse[2], function(inst)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_action_tool")
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(SpearThunderConst[1])
end)
table.insert(prefs, spear_thunder)
local spear_thunder_desc = "如果冷却好了，下次攻击会激活武器%ds，激活状态下攻击会射出电磁炮攻击周围最多%d名敌人，激活有%ds的冷却时间"
Util:AddString(spear_thunder.name, "雷霆战矛",
string.format(spear_thunder_desc, SpearThunderConst[1], SpearThunderConst[3], SpearThunderConst[2]))

local spear_poison_proj = Prefab("tp_spear_poison_proj", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("projectile")
    inst.AnimState:SetBuild("staff_projectile")
    inst.AnimState:PlayAnimation("ice_spin_loop")
    
    inst:AddTag("projectile")
    inst.persists = false

    inst.AnimState:SetMultColour(.6,1,.6,1)
    inst:AddComponent("weapon")
    -- inst.components.weapon:SetDamage()
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(25)
    inst.components.projectile:SetOnMissFn(function(inst) 
        inst:Remove()
    end)
    inst.components.projectile:SetOnHitFn(function(inst, owner, target) 
        BuffManager:AddBuff(target, "poison")
        inst.components.projectile.onmiss(inst)
    end)
    inst.components.projectile:SetLaunchOffset(Vector3(0, 0.2, 0))

    return inst
end, {})
table.insert(prefs, spear_poison_proj)

local SpearPoisonConst = {15, 15, 6, -.15}
local spear_poison = MakeWeapon("tp_spear_poison", WeaponDamage[3], 
function(inst, owner, target)
    if inst.components.weapon.projectile == nil then
        local dt = SpearPoisonConst[1]/SpearPoisonConst[2]
        inst.components.tp_equip_value:DoDelta(dt)
        if inst.components.tp_equip_value:GetPercent() >= 1 then
            inst.components.tp_equip_value:Start()
            local range = SpearPoisonConst[3]
            inst.components.weapon:SetRange(range, range+2)
            inst.components.weapon:SetProjectile("tp_spear_poison_proj")
            EntUtil:add_attack_speed_mod(owner, inst.prefab, SpearPoisonConst[4])
        end
    end
end, nil, 
function(inst, owner)
    inst.components.tp_equip_value:Runout()
    EntUtil:rm_attack_speed_mod(owner, inst.prefab)
end, WeaponUse[3], 
function(inst)
    inst:AddComponent("wg_action_tool")
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(SpearPoisonConst[1])
    inst.components.tp_equip_value.stop = function(inst)
        inst.components.weapon:SetRange(nil)
        inst.components.weapon:SetProjectile(nil)
        local owner = inst.components.equippable.owner
        if owner then
            EntUtil:rm_attack_speed_mod(owner, inst.prefab)
        end
    end
end)
table.insert(prefs, spear_poison)
local buff_data = BuffManager:GetDataById("poison")
local spear_poison_str = buff_data.desc(buff_data)
Util:AddString(spear_poison.name, "毒刺战矛", 
string.format("攻击%d后，接下来%ds内，武器攻击距离提升至%d，攻速提升%d%%，攻击会对目标施加debuff(%s)",
SpearPoisonConst[2], SpearPoisonConst[1], SpearPoisonConst[3], -SpearPoisonConst[4]*100, spear_poison_str))

local SpearBloodConst = {.5, .1, 1.5, 40}
local spear_blood = MakeWeapon("tp_spear_blood", WeaponDamage[3], 
function(inst, owner, target)
    if owner.components.health:GetPercent()>SpearBloodConst[1] then
        local hp = owner.components.health.currenthealth
        owner.components.health:DoDelta(-hp*SpearBloodConst[2])
    else
        local hp = owner.components.health.currenthealth
        local max = owner.components.health:GetMaxHealth()
        local dt = (max-hp)*SpearBloodConst[2]
        owner.components.health:DoDelta(math.min(dt, SpearBloodConst[4]))
    end
end, nil, nil, WeaponUse[3], 
function(inst)
    inst.components.weapon.getdamagefn = function(inst)
        local dmg = inst.components.weapon.damage
        local owner = inst.components.equippable.owner
        if owner 
        and owner.components.health:GetPercent()<=SpearBloodConst[1] then
            dmg = dmg*1.5
        end
        return dmg
    end
end)
table.insert(prefs, spear_blood)
Util:AddString(spear_blood.name, "咳血战矛", 
string.format("生命值大于%d%%时，攻击会损失%d%%的当前生命值；当生命小于%d%%时，攻击会造成%d%%的伤害，并回复%d%%的已损失生命值(最多%d)",
SpearBloodConst[1]*100, SpearBloodConst[2]*100, SpearBloodConst[1]*100, SpearBloodConst[3]*100, SpearBloodConst[2]*100, SpearBloodConst[4]))

local SpearShadowConst = {150, 1.5, 10}
local spear_shadow = MakeWeapon("tp_spear_shadow", WeaponDamage[3], 
nil, nil, nil, WeaponUse[3], 
function(inst)
    inst.components.equippable.dapperfn = function(inst, owner)
        local dapperness = -TUNING.DAPPERNESS_HUGE
        local cur = owner.components.sanity.current
        local rate = cur/SpearShadowConst[1]
        return dapperness*rate
    end
    inst.components.weapon.getdamagefn = function(inst)
        local dmg = 0
        local owner = inst.components.equippable.owner
        if owner and owner.components.sanity then
            dmg = owner.components.sanity:GetPercent()*100*SpearShadowConst[2]
        end
        return dmg
    end
    inst:ListenForEvent("wg_owner_killed", function(inst, data)
        if data.owner.components.sanity then
            data.owner.components.sanity:DoDelta(SpearShadowConst[3])
        end
    end)
end)
table.insert(prefs, spear_shadow)
Util:AddString(spear_shadow.name, "理智战矛", 
string.format("你每有1%%的理智，武器获得%.2f点攻击力；改武器会降低理智，理智降低效果随你当前理智值增加而增加，击杀单位回复%d理智",
SpearShadowConst[2], SpearShadowConst[3]))

local flash_knife = MakeWeapon("tp_flash_knife", 27, 
nil, nil, nil, 120, 
function(inst)
    inst:AddComponent("tp_enchantmentable")
    inst.components.tp_enchantmentable:Enchantment({
        quality = 3,
        ids = {"flash_weapon"},
    })
end, true)
table.insert(prefs, flash_knife)
Util:AddString(flash_knife.name, "闪烁匕首", "拥有附魔闪烁")

local ForestDragonConst = {20}
local forest_dragon = MakeWeapon("tp_forest_dragon", 10,
function(inst, owner, target)
    inst.components.tp_equip_value:DoDelta(-1)
    if inst.components.tp_equip_value:IsEmpty() then
        inst:done()    
    end
end, nil, nil, nil, 
function(inst)
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:RegisterSkillInfo({
        desc="充能代表子弹数量",
    })
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(ForestDragonConst[1])
    inst:AddComponent("wg_interable")
    inst.components.wg_interable.test = function(inst, item, doer) 
        return item.prefab == "acorn"
    end
    inst.components.wg_interable:SetFn(function(inst, item, doer) 
        local stack = item.components.stackable:StackSize()
        local cost = inst.components.tp_equip_value:GetCost()
        local dt = math.min(stack, cost)
        inst.components.tp_equip_value:DoDelta(dt)
        item.components.stackable:Get(dt):Remove()
        inst:wake()
    end)
    inst:DoTaskInTime(0, function()
        if not inst.components.tp_equip_value:IsEmpty() then
            inst:wake()
        end
    end)
    inst.wake = function(inst)
        inst:AddTag("blunderbuss")
        inst.components.weapon:SetDamage(WeaponDamage[2])
        inst.components.weapon:SetRange(10, 12)
        inst.components.weapon:SetProjectile("tp_forest_dragon_proj")
    end
    inst.done = function(inst)
        inst:RemoveTag("blunderbuss")
        inst.components.weapon:SetDamage(10)
        inst.components.weapon:SetRange(0,0)
        inst.components.weapon:SetProjectile(nil)  
    end
end)
table.insert(prefs, forest_dragon)
Util:AddString(forest_dragon.name, "森林之龙", 
string.format("用橡果作为子弹，子弹容量%d", ForestDragonConst[1]))
make_bp(forest_dragon.name)

local forest_dragon_proj = Prefab("tp_forest_dragon_proj", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    -- trans:SetFourFaced()
    local anim = inst.entity:AddAnimState()
    -- inst.entity:AddSoundEmitter()
    inst.AnimState:SetBank("acorn")
    inst.AnimState:SetBuild("acorn")
    inst.AnimState:PlayAnimation("idle")
    
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    inst:AddTag("projectile")
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetOnHitFn(function(inst, attacker, target, weapon)
        inst.components.projectile.onmiss(inst, attacker, target)
    end)
    inst.components.projectile:SetOnMissFn(function(inst, owner, target)
        inst:Remove()
    end)
    inst.components.projectile.offset = Vector3(.5,0,0)
    inst:DoPeriodicTask(.05, function()
        FxManager:MakeFx("forest_dragon_acorn", inst)
    end)

    return inst
end, {})
table.insert(prefs, forest_dragon_proj)

local ForestDragon2Const = {40}
local forest_dragon2 = deepcopy(forest_dragon)
PrefabUtil:SetPrefabName(forest_dragon2, "tp_forest_dragon2")
PrefabUtil:HookPrefabFn(forest_dragon2, function(inst)
    inst.components.tp_equip_value:SetMax(ForestDragon2Const[1])
    inst.wake = function(inst)
        inst:AddTag("blunderbuss")
        inst.components.weapon:SetDamage(WeaponDamage[3])
        inst.components.weapon:SetRange(10, 12)
        inst.components.weapon:SetProjectile("tp_forest_dragon_proj")
    end
    local tree_seeds = {
        "acorn", "pinecone", "jungletreeseed", "teatree_nut", "coconut",
    }
    inst.components.wg_interable.test = function(inst, item, doer) 
        if table.contains(tree_seeds, item.prefab) then
            return true
        end
    end
end)
table.insert(prefs, forest_dragon2)
local forest_dragon2_str = "可以将其他树果转为像果，子弹容量%d"
Util:AddString(forest_dragon2.name, "森林之龙II", 
string.format(forest_dragon2_str, ForestDragon2Const[1]))

local ForestDragon3Const = {80, 0.01, 0.01, WeaponDamage[2]/30, .6}
local forest_dragon3 = deepcopy(forest_dragon2)
PrefabUtil:SetPrefabName(forest_dragon3, "tp_forest_dragon3")
PrefabUtil:HookPrefabFn(forest_dragon3, function(inst)
    inst.components.wg_action_tool:RegisterSkillInfo({
        desc="森林之龙的咆哮:可以连续射击,充能代表子弹数量",
    })
    inst.components.wg_action_tool.quality = 4
    inst.components.tp_equip_value:SetMax(ForestDragon3Const[1])
    inst.wake = function(inst)
        inst:AddTag("tp_forest_dragon")
        inst.components.weapon:SetDamage(WeaponDamage[3]+WeaponDamage[1])
        inst.components.weapon:SetRange(10, 12)
        inst.components.weapon:SetProjectile("tp_forest_dragon_proj")
    end
    inst.done = function(inst)
        inst:RemoveTag("tp_forest_dragon")
        inst.components.weapon:SetDamage(10)
        inst.components.weapon:SetRange(0,0)
        inst.components.weapon:SetProjectile(nil)  
    end
    inst:AddComponent("tp_equip_level")
    inst.components.tp_equip_level:SetMax(30)
    inst.components.tp_equip_level.upgrade = function(inst, level, is_load)
        local owner = inst.components.equippable.owner
        if owner then
            local id = "equipslot_"..inst.components.equippable.equipslot
            inst:equip(owner)
        end
    end
    inst.equip = function(inst, owner)
        local level = inst.components.tp_equip_level.level
        owner.components.combat:AddPenetrateMod(inst.prefab, level*ForestDragon3Const[2])
        owner.components.combat:AddHitRateMod(inst.prefab, level*ForestDragon3Const[3])
    end
    inst.components.equippable:WgAddEquipFn(function(inst, owner)
        inst:equip(owner)
    end)
    inst.components.equippable:WgAddUnequipFn(function(inst, owner)
        owner.components.combat:RmPenetrateMod(inst.prefab)
        owner.components.combat:RmHitRateMod(inst.prefab)    
    end)
    inst.components.weapon:WgAddWeaponDamageFn(function(inst, dmg)
        if inst.components.weapon.projectile then
            local level = inst.components.tp_equip_level.level
            dmg = dmg + level*ForestDragon3Const[4]
        end
        return dmg
    end)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if inst.components.tp_equip_level.level>=30 then
            FxManager:MakeFx("hacking_bamboo_fx", target)
            EntUtil:make_area_dmg(target, 4, owner, 0, inst, 
                nil, {
                    test = function(v, attacker, weapon)
                        return v~=target
                    end,
                    calc = true,
                    mult = ForestDragon3Const[5],
                })
        end
    end)
end)
table.insert(prefs, forest_dragon3)
local temp = string.format(forest_dragon2_str, ForestDragon3Const[1])
temp = temp..string.format("，可以连发，可升级，每级提升%.2f攻击、%d%%穿透和%d%%命中率",
    ForestDragon3Const[4], ForestDragon3Const[2]*100, ForestDragon3Const[3]*100)
temp = temp..string.format("，30级以后，攻击会造成%d%%的范围伤害", ForestDragon3Const[5]*100)
local forest_dragon3_desc = temp
Util:AddString(forest_dragon3.name, "森林之龙III", forest_dragon3_desc)

local SpearResourceConst = {34*25}
local spear_resource = MakeWeapon("tp_spear_resource", WeaponDamage[1],
nil, 
function(inst, owner)
    inst.event_fn = EntUtil:listen_for_event(inst, 
        "onhitother", function(owner, data)
            if data and data.damage then
                inst.components.tp_equip_value:DoDelta(data.damage)
                if inst.components.tp_equip_value:GetPercent()>=1 then
                    inst.components.tp_equip_value:SetPercent(0)
                    local item = SpawnPrefab(inst.resource)
                    item.components.stackable:SetStackSize()
                    owner.components.inventory:GiveItem(item)
                end
            end
        end,
    owner)
end, 
function(inst, owner)
    if inst.event_fn then
        inst:RemoveEventCallback("onhitother", inst.event_fn, owner)
    end
end, WeaponUse[1], 
function(inst)
    inst.res_tbl = {
        {"cutgrass", 20},
        {"twigs", 20},
        {"log", 15},
        {"rocks", 10},
        {"goldnugget", 5},
    }
    inst.resource = 1
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(SpearResourceConst[1])
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:RegisterSkillInfo({
        desc=function(inst)
            local data = inst.res_tbl[inst.resource]
            return string.format("可以改变获得的资源；当前充能满后获得%d个%s", 
                data[2], Util:GetScreenName(data[1]))
        end,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测 
    -- end
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.resource = inst.resource%(#inst.res_tbl)+1
    end
    inst.OnSave = function(inst, data)
        data.resource = inst.resource
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.resource = data.resource
        end
    end
end)
table.insert(prefs, spear_resource)
Util:AddString(spear_resource.name, "收集战矛", "攻击会增加充能，充能满后会获得一定的资源")

local SpearHurtConst = {5, 10}
local spear_hurt = MakeWeapon("tp_spear_hurt", WeaponDamage[1],
function(inst, owner, target)
    if inst:HasTag("ak_multithrust") then
        inst:RemoveTag("ak_multithrust")
        BuffManager:AddBuff(target, "tp_spear_hurt")
    end
end, 
nil, nil, WeaponUse[1], 
function(inst)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(SpearHurtConst[1])
    inst.components.tp_equip_value.stop = function(inst)
        inst:RemoveTag("ak_multithrust")
    end
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:RegisterSkillInfo({desc="",})
    inst.components.wg_action_tool.test = function(inst, doer)
        --检测
        if inst.components.wg_recharge:IsRecharged() then
            return true
        end
    end
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst:AddTag("ak_multithrust")
        inst.components.tp_equip_value:SetPercent(1)
        inst.components.tp_equip_value:Start()
        inst.components.wg_recharge:SetRechargeTime(SpearHurtConst[2])
    end
end)
table.insert(prefs, spear_hurt)
Util:AddString(spear_hurt.name, "制裁战矛", "释放技能，下次攻击会令敌人回复效果降低")

-- local SpearJarvanIVConst = {8, 28, 40, .4}
-- local spear_jarvaniv = MakeWeapon("tp_spear_jarvaniv", 
-- WeaponDamage[1], nil, nil, nil, WeaponUse[1], 
-- function(inst)
--     inst.components.weapon.getdamagefn = function(inst)
--         if inst.components.finiteuses:GetPercent()<=0 then
--             return 0
--         end
--         return WeaponDamage[1]
--     end
--     inst.components.finiteuses.onfinished = nil
--     inst.components.equippable.suit = "jarvaniv"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_spear_jarvaniv")
--     inst:AddComponent("wg_reticule")
--     -- inst.components.wg_reticule.reticule_prefab = "wg_reticuleaoesmall"
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool.check = true
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         and doer.components.tp_mana.current >= SpearJarvanIVConst[2]
--         then
--             return true
--         end
--     end
--     inst.components.wg_action_tool.get_action_fn = function(inst, data)
--         -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--         if inst.components.wg_reticule:IsShown() then
--             if data.pos or data.target then
--                 -- return ACTIONS.TP_SAIL
--                 return ACTIONS.TP_ATK
--             end
--         end
--     end
--     inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--         inst.components.wg_reticule:Toggle()
--     end
--     inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--         -- 动作触发时会到达的效果
--         inst.components.wg_recharge:SetRechargeTime(SpearJarvanIVConst[1])
--         doer.components.tp_mana:DoDelta(-SpearJarvanIVConst[2])
--         -- doer.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
--         local anchor = nil
--         if inst.charge then
--             inst.charge = nil
--             anchor = doer
--         else
--             local fx = SpawnPrefab("tp_spear_jarvaniv_fx")
--             fx.Transform:SetPosition(doer:GetPosition():Get())
--             fx.Transform:SetRotation(doer.Transform:GetRotation())
--             anchor = fx
--         end
--         inst.enemies = {}
--         for i = 1, 3 do
--             doer:DoTaskInTime(.1*i, function()
--                 EntUtil:make_area_dmg(anchor, 2, doer, SpearJarvanIVConst[3], 
--                     doer.components.combat:GetWeapon(), nil, {
--                     fn = function(v, attacker, weapon)
--                         inst.enemies[v] = true
--                         BuffManager:AddBuff(v, "tp_spear_jarvaniv_debuff")
--                     end,
--                     test = function(v, attacker, weapon)
--                         return inst.enemies[v] == nil
--                     end,
--                     mult = SpearJarvanIVConst[4],
--                 })
--             end)
--         end
--     end
-- end)
-- table.insert(prefs, spear_jarvaniv)
-- local buff_data = BuffManager:GetDataById("tp_spear_jarvaniv")
-- Util:AddString(spear_jarvaniv.name, "王子战矛", 
-- string.format("不会损毁，需要套装释放技能，消耗%d魔法，召唤一个王子鼓舞战矛，提供buff(%s)", 
-- SpearJarvanIVConst[2], buff_data.desc(buff_data)))

-- local spear_jarvaniv_fx = Prefab("tp_spear_jarvaniv_fx", function()
--     local inst = CreateEntity()
--     local trans = inst.entity:AddTransform()
--     trans:SetFourFaced()
--     local anim = inst.entity:AddAnimState()
--     inst.entity:AddSoundEmitter()
--     MakeGhostPhysics(inst, 0, 0)
--     RemovePhysicsColliders(inst)
--     inst.Physics:SetMotorVel(30, 0, 0)

--     inst.AnimState:SetBank("wilson")
--     inst.AnimState:SetBuild("wilson")
--     inst.AnimState:SetPercent("atk", .4)

--     inst.AnimState:Hide("ARM_carry")
--     inst.AnimState:Hide("hat")
--     inst.AnimState:Hide("hat_hair")
--     inst.AnimState:Hide("PROPDROP")

--     inst.AnimState:Show("ARM_carry")
--     inst.AnimState:Hide("ARM_normal")
--     inst.AnimState:OverrideSymbol("swap_object", "tp_spear_combat", "swap_object")
--     inst.AnimState:OverrideSymbol("swap_body", "tp_armor_health", "swap_body")
--     inst.AnimState:Show("HAT")
--     inst.AnimState:Show("HAIR_HAT")
--     inst.AnimState:Hide("HAIR_NOHAT")
--     inst.AnimState:Hide("HAIR")
--     inst.AnimState:Hide("HEAD")
--     inst.AnimState:Show("HEAD_HAIR")
--     inst.AnimState:Hide("HAIRFRONT")
--     inst.AnimState:OverrideSymbol("swap_hat", "tp_hat_health", "swap_hat")

--     inst:AddComponent("colourtweener")
--     inst.components.colourtweener:StartTween({0,0,0,.5}, 0)

--     inst:DoTaskInTime(0, function()
--         inst.AnimState:SetBuild(GetPlayer().prefab)
--     end)
--     inst:DoTaskInTime(.4, function()
--         inst:Remove()
--     end)
--     inst:AddTag("fx")

--     return inst
-- end)
-- table.insert(prefs, spear_jarvaniv_fx)

-- local SpearMonkConst = {50, 8, 30, .15}
-- local spear_monk = MakeWeapon("tp_spear_monk", WeaponDamage[1],
-- function(inst, owner, target)
--     if owner:HasTag("tp_helm_monk") then
--         local helm = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
--         if helm and helm.prefab == "tp_helm_monk" then
--             helm.components.tp_equip_value:DoDelta(10)
--         end
--     end 
-- end, nil, nil, WeaponUse[1], 
-- function(inst)
--     inst.components.weapon.getdamagefn = function(inst)
--         if inst.components.finiteuses:GetPercent()<=0 then
--             return 0
--         end
--         return WeaponDamage[1]
--     end
--     inst.components.finiteuses.onfinished = nil
--     inst.components.equippable.suit = "monk"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_spear_monk")
--     inst:AddComponent("wg_reticule")
--     inst:AddComponent("tp_equip_value")
--     inst.components.tp_equip_value:SetMax(4)
--     inst.components.tp_equip_value.stop = function(inst)
--         inst.target = nil
--         if inst.fx then
--             inst.fx:WgRecycle()
--             inst.fx = nil
--         end
--         inst.components.wg_recharge:SetRechargeTime(SpearMonkConst[2])
--     end
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         then
--             local helm = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
--             local cost = SpearMonkConst[1]
--             if not inst.components.tp_equip_value:IsEmpty() then
--                 cost = cost/2
--             end
--             if helm and helm.components.tp_equip_value.current >= cost then
--                 return true
--             end
--         end
--     end
--     inst.components.wg_action_tool.get_action_fn = function(inst, data)
--         -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--         if inst.target == nil or not EntUtil:is_alive(inst.target) then
--             if inst.components.wg_reticule:IsShown() then
--                 if data.pos or data.target then
--                     return ACTIONS.TP_CHOP
--                 end
--             end
--         end
--     end
--     inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--         if inst.target and EntUtil:is_alive(inst.target)
--         and inst.target:IsNear(doer, 30) then
--             inst.components.wg_recharge:SetRechargeTime(SpearMonkConst[2])
--             local ba = BufferedAction(doer, inst.target, ACTIONS.TP_SPEAR_MONK, inst, nil)
--             doer:PushBufferedAction(ba)
--         elseif inst.components.tp_equip_value:IsEmpty() then
--             inst.components.wg_reticule:Toggle()
--         end
--     end
--     inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--         -- 动作触发时会到达的效果
--         local helm = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
--         if helm and helm.components.tp_equip_value then
--             helm.components.tp_equip_value:DoDelta(-SpearMonkConst[1])
--             if inst.target and EntUtil:is_alive(inst.target) then
--                 local p = 2-inst.target.components.health:GetPercent()
--                 EntUtil:get_attacked(inst.target, doer, SpearMonkConst[3]*p, inst, 
--                     nil, true, SpearMonkConst[4]*p)
--                 inst.components.tp_equip_value:Runout()
--             else
--                 inst.components.wg_recharge:SetRechargeTime(SpearMonkConst[2])
--                 local beam = SpawnPrefab("tp_spear_monk_fx")
--                 beam.Transform:SetPosition(doer:GetPosition():Get())
--                 if target then
--                     pos = target:GetPosition()
--                 end
--                 beam:ForceFacePoint(pos:Get())
--                 beam.owner = doer
--                 beam.weapon = inst
--             end
--             BuffManager:AddBuff(doer, "tp_helm_monk")
--         end
--     end
-- end)
-- table.insert(prefs, spear_monk)
-- Util:AddString(spear_monk.name, "武僧战矛", 
-- string.format("不会损毁，需要套装释放技能，消耗%d武僧头盔充能，发射一个光波，造成%d+%d%%自身攻击力的伤害，命中敌人后可再次释放，突进到目标敌人处并对其造成%d+%d%%自身攻击力的伤害，目标生命值越低造成伤害越高，最高2倍", 
-- SpearMonkConst[1], SpearMonkConst[3], SpearMonkConst[4]*100, SpearMonkConst[3], SpearMonkConst[4]*100))

-- local spear_monk_fx = Prefab("tp_spear_monk_fx", function()
--     local inst = CreateEntity()
--     local trans = inst.entity:AddTransform()
--     local anim = inst.entity:AddAnimState()
--     inst.entity:AddSoundEmitter()

--     MakeGhostPhysics(inst, 0, 0)
--     RemovePhysicsColliders(inst)

--     anim:SetBank("metal_hulk_projectile")
-- 	anim:SetBuild("metal_hulk_projectile")
-- 	anim:PlayAnimation("spin_loop", true)
--     inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/pugalisk/gaze_LP","gaze")
    
--     inst:ListenForEvent("animover", function(inst, data)
--         inst.AnimState:PlayAnimation("loop_pst")
--         inst.SoundEmitter:KillSound("gaze")
-- 	end)
--     inst:DoTaskInTime(0, function()
--         inst.Physics:SetMotorVel(30, 0, 0)
--     end)
--     inst:DoTaskInTime(1, inst.Remove)
--     inst.task = inst:DoPeriodicTask(.1, function()
--         local ent = FindEntity(inst, 2, function(target, inst)
--             if EntUtil:check_combat_target(inst.owner, target) then
--                 return true
--             end
--         end, {}, {})
--         if ent then
--             EntUtil:get_attacked(ent, inst.owner, SpearMonkConst[3], inst.weapon, 
--                 nil, true, SpearMonkConst[4])
--             inst.weapon.target = ent
--             inst.weapon.components.tp_equip_value:SetPercent(1)
--             inst.weapon.components.tp_equip_value:Start()
--             inst.weapon.components.wg_recharge:SetRechargeTime(.1)
--             local fx = FxManager:MakeFx("sign2", Vector3(0,0,0))
--             ent:AddChild(fx)
--             inst.weapon.fx = fx
--             -- fx:DoTaskInTime(5, fx.WgRecycle)
--             inst:Remove()
--         end
--     end)

--     return inst
-- end)
-- table.insert(prefs, spear_monk_fx)

-- local SpearZedConst = {60, 6, 35, .1}
-- local spear_zed = MakeWeapon("tp_spear_zed", WeaponDamage[1], 
-- nil, nil, nil, WeaponUse[1], 
-- function(inst)
--     inst.components.weapon.getdamagefn = function(inst)
--         if inst.components.finiteuses:GetPercent()<=0 then
--             return 0
--         end
--         return WeaponDamage[1]
--     end
--     inst.components.finiteuses.onfinished = nil
--     inst.components.equippable.suit = "zed"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_spear_zed")
--     inst:AddComponent("wg_reticule")
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         then
--             local helm = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
--             if helm and helm.components.tp_equip_value.current >= SpearZedConst[1] then
--                 return true
--             end
--         end
--     end
--     inst.components.wg_action_tool.get_action_fn = function(inst, data)
--         -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--         if inst.components.wg_reticule:IsShown() then
--             if data.pos or data.target then
--                 return ACTIONS.TP_SPEAR_ZED
--             end
--         end
--     end
--     inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--         inst.components.wg_reticule:Toggle()
--     end
--     inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--         -- 动作触发时会到达的效果
--         local helm = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
--         if helm and helm.components.tp_equip_value then
--             helm.components.tp_equip_value:DoDelta(-SpearZedConst[1])
--             inst.components.wg_recharge:SetRechargeTime(SpearZedConst[2])
--             if target then
--                 pos = target:GetPosition()
--             end
--             local beam = SpawnPrefab("tp_spear_zed_fx")
--             beam.Transform:SetPosition(doer:GetPosition():Get())
--             beam:ForceFacePoint(pos:Get())
--             beam.owner = doer
--             beam.weapon = inst
--             local armor = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
--             if armor and armor.fx then
--                 local beam = SpawnPrefab("tp_spear_zed_fx")
--                 beam.Transform:SetPosition(armor.fx:GetPosition():Get())
--                 beam:ForceFacePoint(pos:Get())
--                 beam.owner = doer
--                 beam.weapon = inst
--                 beam.shadow = true
--             end
--         end
--     end
-- end)
-- table.insert(prefs, spear_zed)
-- Util:AddString(spear_zed.name, "影子之刃", 
-- string.format("不会损毁，需要套装释放技能，消耗%d影子头盔充能，掷出一个飞镖，对首个敌人造成%d+%d%%自身攻击力的伤害，对后续敌人造成一半的伤害", 
-- SpearZedConst[1], SpearZedConst[3], SpearZedConst[4]*100))

-- local spear_zed_fx = Prefab("tp_spear_zed_fx", function()
--     local inst = CreateEntity()
--     local trans = inst.entity:AddTransform()
--     local anim = inst.entity:AddAnimState()

--     MakeGhostPhysics(inst, 0, 0)
--     RemovePhysicsColliders(inst)
    
--     anim:SetBank("boomerang")
--     anim:SetBuild("boomerang")
--     inst.AnimState:PlayAnimation("spin_loop", true)
--     anim:SetMultColour(0, 0, 0, 1)
--     anim:SetRayTestOnBB(true)

--     inst:DoTaskInTime(0, function()
--         inst.Physics:SetMotorVel(20, 0, 0)
--     end)
--     inst:DoTaskInTime(1, inst.Remove)
--     inst.enemies = {}
--     inst.task = inst:DoPeriodicTask(.1, function()
--         local dmg, mult = SpearZedConst[3], SpearZedConst[4]
--         if inst.hit then
--             dmg, mult = dmg/2, mult/2
--         end
--         EntUtil:make_area_dmg(inst, 1.5, inst.owner, dmg, inst.weapon, 
--             nil, {
--                 fn = function(v, attacker, weapon)
--                     if inst.hit == nil then
--                         inst.hit = true
--                         local helm = inst.owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
--                         if inst.shadow and helm and helm.prefab == "tp_helm_zed" then
--                             helm.components.tp_equip_value:DoDelta(20)
--                         end
--                     end
--                     inst.enemies[v] = true
--                 end,
--                 test = function(v, attacker, weapon)
--                     return inst.enemies[v] == nil
--                 end,
--                 mult = mult,
--             })
--     end)

--     return inst
-- end)
-- table.insert(prefs, spear_zed_fx)

-- local SpearJaxConst = {8, math.floor(65/3*2), math.floor(65/3*2), 1, 5, 1.2}
-- local spear_jax = MakeWeapon("tp_spear_jax", WeaponDamage[2],
-- function(inst, owner, target)
--     inst.components.tp_equip_value:Runout()
-- end, nil, nil, WeaponUse[2], 
-- function(inst)
--     inst.components.weapon.getdamagefn = function(inst)
--         if inst.components.finiteuses:GetPercent()<=0 then
--             return 0
--         end
--         if not inst.components.tp_equip_value:IsEmpty() then
--             return WeaponDamage[2]*(1+SpearJaxConst[6])
--         end
--         return WeaponDamage[2]
--     end
--     inst.components.finiteuses.onfinished = nil
--     inst.components.equippable.suit = "jax"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_spear_jax")
--     inst:AddComponent("tp_equip_value")
--     inst.components.tp_equip_value.stop = function(inst)
--         inst:RemoveTag("tp_mine_attack")
--     end
--     inst.components.tp_equip_value:SetMax(SpearJaxConst[5])
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         and doer.components.tp_mana.current >= SpearJaxConst[2]
--         then
--             return true
--         end
--     end
--     inst.components.wg_action_tool.click_get_action_fn = function(inst, data)
--         -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--         if data.target then
--             return ACTIONS.TP_SPEAR_JAX
--         end
--     end
--     -- inst.components.wg_action_tool.click_fn = function(inst, doer)
--     --     -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--     -- end
--     inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--         -- 动作触发时会到达的效果
--         inst.components.wg_recharge:SetRechargeTime(SpearJaxConst[1])
--         doer.components.tp_mana:DoDelta(-SpearJaxConst[2])
--         if EntUtil:check_combat_target(doer, target) then
--             EntUtil:get_attacked(target, doer, SpearJaxConst[3], inst, 
--                 nil, true, SpearJaxConst[4])
--         end
--     end
-- end)
-- table.insert(prefs, spear_jax)
-- Util:AddString(spear_jax.name, "宗师战矛", 
-- string.format("不会损毁，需要套装释放技能，消耗%d魔法，向目标单位进行跳斩，若为合适的攻击目标，对其造成%d+%d%%自身攻击力的伤害", 
-- SpearJaxConst[2], SpearJaxConst[3], SpearJaxConst[4]*100))

-- local SpearDariusConst = {8, math.floor(30/3*2), math.floor(80/3*2), 1, 15, .35, .13, 5, .5, -.5}
-- local spear_darius = MakeWeapon("tp_spear_darius", WeaponDamage[2],
-- function(inst, owner, target)
--     inst.components.tp_equip_value:Runout()
--     EntUtil:add_speed_mod(target, "tp_armor_darius", SpearDariusConst[10], 5)
-- end, nil, nil, WeaponUse[2], 
-- function(inst)
--     inst.components.weapon.getdamagefn = function(inst)
--         if inst.components.finiteuses:GetPercent()<=0 then
--             return 0
--         end
--         if not inst.components.tp_equip_value:IsEmpty() then
--             return WeaponDamage[2]*(SpearDariusConst[9]+1)
--         end
--         return WeaponDamage[2]
--     end
--     inst.components.finiteuses.onfinished = nil
--     inst.components.equippable.suit = "darius"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_spear_darius")
--     inst:AddComponent("tp_equip_value")
--     inst.components.tp_equip_value.stop = function(inst)
--         inst:RemoveTag("tp_chop_attack")
--     end
--     inst.components.tp_equip_value:SetMax(SpearDariusConst[8])
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         and doer.components.tp_mana.current >= SpearDariusConst[2]
--         then
--             return true
--         end
--     end
--     inst.components.wg_action_tool.click_get_action_fn = function(inst, data)
--         -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--         return ACTIONS.TP_SPEAR_DARIUS
--     end
--     -- inst.components.wg_action_tool.click_fn = function(inst, doer)
--     --     -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--     -- end
--     inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--         -- 动作触发时会到达的效果
--         inst.components.wg_recharge:SetRechargeTime(SpearDariusConst[1])
--         doer.components.tp_mana:DoDelta(-SpearDariusConst[2])
--         inst.enemies = {}
--         inst.hit = nil
--         EntUtil:make_area_dmg(doer, 3, doer, SpearDariusConst[5], 
--             inst, nil, {
--                 mult = SpearDariusConst[6],
--                 fn = function(v, attacker, weapon)
--                     inst.enemies[v] = true
--                 end,
--             }
--         )
--         EntUtil:make_area_dmg(doer, 5, doer, SpearDariusConst[3], 
--             inst, nil, {
--                 mult = SpearDariusConst[4],
--                 fn = function(inst, attacker, weapon)
--                     if inst.hit == nil then
--                         inst.hit = true
--                         local max = doer.components.health:GetMaxHealth()
--                         local cur = doer.components.health.currenthealth
--                         local dt = (max-cur)*SpearDariusConst[7]
--                         doer.components.health:DoDelta(dt)
--                     end
--                 end,
--                 test = function(v, attacker, weapon)
--                     return inst.enemies[v] == nil
--                 end,
--             }
--         )
--     end
-- end)
-- table.insert(prefs, spear_darius)
-- local spear_darius_str = string.format("不会损毁，需要套装释放技能，消耗%d魔法，",
-- SpearDariusConst[2])
-- spear_darius_str = spear_darius_str..string.format("旋转武器，对周围较近的敌人造成%d+%d%%自身攻击力的伤害，",
-- SpearDariusConst[5], SpearDariusConst[6]*100)
-- spear_darius_str = spear_darius_str..string.format("较远的敌人造成%d+%d%%自身攻击力的伤害(第一次击中较远的敌人回复%d%%已损失生命值)",
-- SpearDariusConst[3], SpearDariusConst[4]*100, SpearDariusConst[7]*100)
-- Util:AddString(spear_darius.name, "洛克战矛", spear_darius_str)

-- local SpearGarenConst = {8, math.floor(90/3*2), .5, 5, .35}
-- local spear_garen = MakeWeapon("tp_spear_garen", WeaponDamage[2],
-- function(inst, owner, target)
--     inst.components.tp_equip_value:Runout()
--     BuffManager:AddBuff(target, "slience", 3)
-- end, nil, nil, WeaponUse[2], 
-- function(inst)
--     inst.components.weapon.getdamagefn = function(inst)
--         if inst.components.finiteuses:GetPercent()<=0 then
--             return 0
--         end
--         if not inst.components.tp_equip_value:IsEmpty() then
--             return WeaponDamage[2]*(SpearGarenConst[3]+1)+SpearGarenConst[2]
--         end
--         return WeaponDamage[2]
--     end
--     inst.components.finiteuses.onfinished = nil
--     inst.components.equippable.suit = "garen"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_spear_garen")
--     inst:AddComponent("tp_equip_value")
--     inst.components.tp_equip_value.stop = function(inst)
--         inst:RemoveTag("tp_heavy_attack")
--     end
--     inst.components.tp_equip_value:SetMax(SpearGarenConst[4])
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         then
--             return true
--         end
--     end
--     -- inst.components.wg_action_tool.get_action_fn = function(inst, data)
--     --     -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--     -- end
--     inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--         inst.components.wg_recharge:SetRechargeTime(SpearGarenConst[1])
--         inst.components.tp_equip_value:SetPercent(1)
--         inst.components.tp_equip_value:Start()
--         inst:AddTag("tp_heavy_attack")
--         EntUtil:add_speed_mod(doer, "tp_spear_garen", SpearGarenConst[5], 3)
--     end
--     -- inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--     --     -- 动作触发时会到达的效果
--     -- end
-- end)
-- table.insert(prefs, spear_garen)
-- Util:AddString(spear_garen.name, "迪玛战矛", 
-- string.format("不会损毁，需要套装释放技能，获得%d%%加速，下次攻击额外造成%d+%d%%自身攻击力的伤害，并令敌人沉默", 
-- SpearGarenConst[5]*100, SpearGarenConst[2], SpearGarenConst[3]*100))

return unpack(prefs)