local Util = require "extension.lib.wg_util"
local AssetUtil = require "extension/lib/asset_util"
local PrefabUtil = require "extension/lib/prefab_util"
local EntUtil = require "extension/lib/ent_util"
local AssetMaster = Sample.AssetMaster
local Info = Sample.Info
local FxManager = Sample.FxManager
local BuffManager = Sample.BuffManager

local prefs = {}

local ArmorAmount = Info.Armor.ArmorAmount

local ArmorAbsorption = Info.Armor.ArmorAbsorption

--[[
创建盔甲预制物  
(Prefab) 返回预制物  
name (string)名字  
armor (number)护甲值  
absorb (number)伤害吸收  
on_attacked (func)受到攻击触发的函数(damage,attacker,weapon,owner,inst)  
equip (func)装备时触发函数  
unequip (func)卸下时触发函数  
fn (func)自定以函数，可以为nil  
not_fixable (bool)是否不可被修复  
]]
local function MakeArmor(name, armor, absorb, on_attacked, equip, unequip, fn, not_fixable)
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
        inst.components.inventoryitem.atlasname = atlas
        if string.find(image, ".tex") then
            assert(nil, "image should not have \".tex\"")
        end
        inst.components.inventoryitem:ChangeImageName(image)
        inst:AddComponent("armor")
        inst.components.armor:InitCondition(armor, absorb) 

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable:SetOnEquip(equip)
        inst.components.equippable:SetOnUnequip(unequip)
        inst.components.equippable.symbol = name
        inst.components.equippable:WgAddEquipAttackedFn(on_attacked)

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

local ArmorHealthConst = {50, 100, 30}
local armor_health = MakeArmor("tp_armor_health", ArmorAmount[1], 
ArmorAbsorption[1], nil, nil, nil, function(inst)
    inst:AddComponent("wg_action_tool")
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(ArmorHealthConst[2])
    inst.components.equippable:WgAddEquipMaxHealthModifier("tp_armor_health", ArmorHealthConst[1])
    inst.components.armor.ontakedamage = function(inst, damage, absorb_dmg, left_dmg)
        inst.components.tp_equip_value:DoDelta(absorb_dmg)
        if inst.components.tp_equip_value:GetPercent()>=1 then
            inst.components.tp_equip_value:SetPercent(0)
            local owner = inst.components.equippable.owner
            if owner and EntUtil:is_alive(owner) then
                owner.components.health:DoDelta(ArmorHealthConst[3])
            end
        end
    end
end)
table.insert(prefs, armor_health)
Util:AddString(armor_health.name, "生命护甲",
string.format("增加%d生命，每吸收%d伤害，回复%d生命", ArmorHealthConst[1], ArmorHealthConst[2], ArmorHealthConst[3]))

local ArmorCloakConst = {0.05, .25}
local armor_cloak = MakeArmor("tp_armor_cloak", ArmorAmount[1], 
ArmorAbsorption[1], nil, nil, nil, function(inst)
    inst.components.armor.ontakedamage = function(inst,damage,absorb_dmg,left_dmg)
        local p = inst.components.armor:GetPercent()
        local ex = (ArmorCloakConst[2]-ArmorCloakConst[2])
        local mult = ArmorCloakConst[1]+ex*(1-p)
        inst.components.equippable.walkspeedmult = mult
        local owner = inst.components.equippable.owner
        if owner then
            EntUtil:add_speed_mod(owner, "equipslot_body", mult)
        end
    end
    inst.components.equippable.walkspeedmult = ArmorCloakConst[1]
end, true)
table.insert(prefs, armor_cloak)
local armor_cloak_desc = "提升%d%%的移速，护甲值越低，移速提升越高，最高达到%d%%移速"
Util:AddString(armor_cloak.name, "游侠披风", 
string.format(armor_cloak_desc, ArmorCloakConst[1]*100, ArmorCloakConst[2]*100))

local ArmorIceConst = {.25, 20, 8}
local armor_ice = MakeArmor("tp_armor_ice", ArmorAmount[2], 
ArmorAbsorption[2], nil, 
function(inst, owner)
    inst.event_fn = EntUtil:listen_for_event(inst, "attacked", function(owner, data)
        if EntUtil:can_thorns(data) then
            if math.random() <= ArmorIceConst[1] then
                EntUtil:frozen(data.attacker)
                if data.attacker.components.freezable
                and data.attacker.components.freezable:IsFrozen()
                and inst.components.wg_recharge:IsRecharged() then
                    owner.components.health:DoDelta(ArmorIceConst[2])
                    inst.components.wg_recharge:SetRechargeTime(ArmorIceConst[3])
                end
            end
        end
    end, owner)
end, 
function(inst, owner)
    if inst.event_fn then
        inst:RemoveEventCallback("attacked", inst.event_fn, owner)
    end
end, 
function(inst)
    inst:AddComponent("wg_recharge")
end)
table.insert(prefs, armor_ice)
Util:AddString(armor_ice.name, "冰霜护甲", 
string.format("受到攻击有%d%%的几率对攻击者施加1层冰冻效果，若其因此冰冻，你回复%d生命(回复效果有%ds的冷却时间)",
ArmorIceConst[1]*100, ArmorIceConst[2], ArmorIceConst[3]))

local ArmorFireConst = {.5, .2, 6, 8}
local armor_fire = MakeArmor("tp_armor_fire", ArmorAmount[2],
ArmorAbsorption[2], nil, 
function(inst, owner)
    inst.event_fn = EntUtil:listen_for_event(inst, "attacked", function(owner, data)
        if EntUtil:can_thorns(data) then
            if math.random() <= ArmorFireConst[1] then
                EntUtil:ignite(data.attacker)
                if data.attacker.components.burnable
                and data.attacker.components.burnable:IsBurning()
                and inst.components.wg_recharge:IsRecharged() then
                    inst.components.wg_recharge:SetRechargeTime(ArmorFireConst[4])
                    inst.components.tp_equip_value:SetPercent(1)
                    inst.components.tp_equip_value:Start()
                    owner.components.combat:AddCritRateMod(inst.prefab, ArmorFireConst[2])
                end
            end
        end
    end, owner)
end, 
function(inst, owner)
    if inst.event_fn then
        inst:RemoveEventCallback("attacked", inst.event_fn, owner)
    end
    owner.components.combat:RmCritRateMod(inst.prefab)
    inst.components.tp_equip_value:Runout()
end, 
function(inst)
    inst:AddComponent("wg_action_tool")
    inst:AddComponent("wg_recharge")
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(ArmorFireConst[3])
    inst.components.tp_equip_value.stop = function(inst)
        local owner = inst.components.equippable.owner
        if owner then
            owner.components.combat:RmCritRateMod(inst.prefab)
        end
    end
end)
table.insert(prefs, armor_fire)
Util:AddString(armor_fire.name, "火焰护甲", 
string.format("受到攻击有%d%%的几率点燃攻击者，若成功点燃，获得%d%%的暴击率%ds(增益效果有%ds的冷却时间)",
ArmorFireConst[1]*100, ArmorFireConst[2]*100, ArmorFireConst[3], ArmorFireConst[4]))

local ArmorAncientConst = {150}
local armor_ancient = MakeArmor("tp_armor_ancient", ArmorAmount[3],
ArmorAbsorption[3], nil, nil, nil, 
function(inst)
    inst.components.equippable:WgAddEquipMaxHealthModifier("tp_armor_ancient", ArmorAncientConst[1])
    inst.components.equippable:WgAddEquipMaxSanityModifier("tp_armor_ancient", ArmorAncientConst[1])
    inst.components.equippable:WgAddEquipMaxHungerModifier("tp_armor_ancient", ArmorAncientConst[1])
end)
table.insert(prefs, armor_ancient)
Util:AddString(armor_ancient.name, "远古护甲", 
string.format("增加%d生命，%d理智，%d饥饿", 
ArmorAncientConst[1], ArmorAncientConst[1], ArmorAncientConst[1]))

local ArmorStrongConst = {150, .2, .2}
local armor_strong = MakeArmor("tp_armor_strong", ArmorAmount[1],
ArmorAbsorption[1], nil, 
function(inst, owner)
    owner.components.health:AddRecoverRateMod("tp_armor_strong", ArmorStrongConst[3])
end, 
function(inst, owner)
    owner.components.health:RmRecoverRateMod("tp_armor_strong")
end, 
function(inst)
    inst.components.equippable:WgAddEquipMaxHealthModifier("tp_armor_strong", ArmorStrongConst[1])
    inst.components.equippable.walkspeedmult = -ArmorStrongConst[2]
end)
table.insert(prefs, armor_strong)
Util:AddString(armor_strong.name, "顽石护甲", 
string.format("增加%d生命，提升%d%%生命回复，降低%d%%移速", ArmorStrongConst[1],
ArmorStrongConst[3]*100, ArmorStrongConst[2]*100))

local ArmorStrong2Const = {200, .2, 100, .3, 20}
local armor_strong2 = deepcopy(armor_strong)
PrefabUtil:SetPrefabName(armor_strong2, "tp_armor_strong2")
PrefabUtil:HookPrefabFn(armor_strong2, function(inst)
    inst.components.armor:InitCondition(ArmorAmount[2], ArmorAbsorption[2]) 
    inst.components.equippable.walkspeedmult = nil
    inst.dmg = ArmorStrong2Const[5]
    inst.components.equippable:SetOnEquip(function(inst, owner)
        owner.components.health:AddRecoverRateMod("tp_armor_strong", ArmorStrong2Const[2])
        inst.event_fn = EntUtil:listen_for_event(inst, 
            "attacked", function(owner, data)
                local can = inst.components.tp_equip_value:GetPercent()>ArmorStrong2Const[4]
                if can then
                    FxManager:MakeFx("bramblefx", owner)
                    EntUtil:get_attacked(data.attacker, owner, 
                        inst.dmg, nil, EntUtil:add_stimuli(nil, "thorns"), 
                        true)
                end
            end, owner
        )
    end)
    inst.components.equippable:SetOnUnequip(function(inst, owner)
        owner.components.health:RmRecoverRateMod("tp_armor_strong")
        if inst.event_fn then
            inst:RemoveEventCallback("attacked", inst.event_fn, owner)
            inst.event_fn = nil
        end
    end)
    inst.components.equippable:WgAddEquipMaxHealthModifier("tp_armor_strong", ArmorStrong2Const[1])
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetRate(5)
    inst.components.tp_equip_value:SetMax(ArmorStrong2Const[3])
    inst.components.armor.ontakedamage = function(inst, damage, absorb_dmg, left_dmg)
        inst.components.tp_equip_value:DoDelta(absorb_dmg)
        inst.components.tp_equip_value:Start()
    end
end)
table.insert(prefs, armor_strong2)
local temp = string.format("增加%d生命，提升%d%%生命回复", ArmorStrong2Const[1],
ArmorStrong2Const[2]*100)
temp = temp..string.format("，吸收的伤害转化为充能，充能大于%d%%时，会令攻击者受到%d点伤害",
ArmorStrong2Const[4]*100, ArmorStrong2Const[5])
local armor_strong2_desc = temp
Util:AddString(armor_strong2.name, "顽石护甲II", 
armor_strong2_desc)

local ArmorStrong3Const = {250, .2, 5, 20, 3, .3, .01}
local armor_strong3 = deepcopy(armor_strong2)
PrefabUtil:SetPrefabName(armor_strong3, "tp_armor_strong3")
PrefabUtil:HookPrefabFn(armor_strong3, function(inst)
    inst.components.armor:InitCondition(ArmorAmount[3]*1.25, ArmorAbsorption[3]) 
    inst.components.equippable:WgAddEquipFn(function(inst, owner)
        owner.components.health:AddRecoverRateMod("tp_armor_strong", ArmorStrong3Const[2])
    end)
    inst.components.equippable:WgAddUnequipFn(function(inst, owner)
        owner.components.health:RmRecoverRateMod("tp_armor_strong")
    end)
    inst.components.equippable:WgAddEquipMaxHealthModifier("tp_armor_strong", ArmorStrong3Const[1])
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:RegisterSkillInfo({})
    inst.components.wg_action_tool.quality = 2
    inst:AddComponent("tp_equip_level")
    inst.components.tp_equip_level:SetMax(10)
    inst.components.tp_equip_level.upgrade = function(inst, level, is_load)
        inst.dmg = ArmorStrong3Const[4]+ArmorStrong3Const[5]*level
        local hp = ArmorStrong3Const[3]*level
        local san = ArmorStrong3Const[3]*level
        local hung = ArmorStrong3Const[3]*level
        inst.components.equippable:WgAddEquipMaxHealthModifier("level", hp)
        inst.components.equippable:WgAddEquipMaxSanityModifier("level", san)
        inst.components.equippable:WgAddEquipMaxHungerModifier("level", hung)
        local owner = inst.components.equippable.owner
        if owner then
            local id = "equipslot_"..inst.components.equippable.equipslot
            owner.components.health:WgAddMaxHealthModifier(id, hp)
            owner.components.sanity:WgAddMaxSanityModifier(id, san)
            owner.components.hunger:WgAddMaxHungerModifier(id, hung)
        end
    end
    inst:ListenForEvent("tp_equip_value_delta", function(inst, data)
        if inst.components.tp_equip_level.level>=10
        and data.new_p > ArmorStrong3Const[6] then
            local owner = inst.components.equippable.owner
            if owner and EntUtil:is_alive(owner) then
                local max = owner.components.health:GetMaxHealth()
                owner.components.health:DoDelta(max*ArmorStrong3Const[7], true)
            end
        end
    end)
end)
table.insert(prefs, armor_strong3)
local temp = string.format("增加%d生命，提升%d%%生命回复", 
ArmorStrong3Const[1], ArmorStrong3Const[2]*100)
temp = temp..string.format("，吸收的伤害转化为充能，充能大于%d%%时，会令攻击者受到%d点伤害",
ArmorStrong3Const[6]*100, ArmorStrong3Const[4])
temp = temp..string.format("，可升级，每级提升%d三围和%d反伤",
ArmorStrong3Const[3], ArmorStrong3Const[5])
temp = temp..string.format("，10级以后，充能大于%d%%时，每s回复%d%%的最大生命值", 
ArmorStrong3Const[6]*100, ArmorStrong3Const[7]*100)
local armor_strong3_desc = temp
Util:AddString(armor_strong3.name, "顽石护甲III", armor_strong3_desc)

local CLOAK_EVADE = 30

local cloak_resist = MakeArmor("tp_cloak_resist", ArmorAmount[2]*.75,
ArmorAbsorption[1], nil, 
function(inst, owner)
    EntUtil:add_tag(owner, "speed_slow_resist")
    owner.components.combat:AddEvadeRateMod(inst.prefab, CLOAK_EVADE)
end, 
function(inst, owner)
    EntUtil:remove_tag(owner, "speed_slow_resist")
    owner.components.combat:RmEvadeRateMod(inst.prefab)
end, nil)
table.insert(prefs, cloak_resist)
Util:AddString(cloak_resist.name, "抵抗披风", 
string.format("受到的减速效果降低50%%，提升%d闪避", CLOAK_EVADE))

local CloakFoodConst = {100, 100}
local cloak_food = MakeArmor("tp_cloak_food", ArmorAmount[2]*.75,
ArmorAbsorption[1], nil, 
function(inst, owner)
    owner.components.combat:AddEvadeRateMod(inst.prefab, CLOAK_EVADE) 
    owner.components.tp_taste:AddTasteMod(inst.prefab, 1)
end, 
function(inst, owner)
    owner.components.combat:RmEvadeRateMod(inst.prefab)
    owner.components.combat:RmTasteMod(inst.prefab)
end, 
function(inst)
    inst.components.equippable:WgAddEquipMaxHealthModifier("tp_cloak_food", CloakFoodConst[2])
    inst.components.equippable:WgAddEquipMaxHungerModifier("tp_cloak_food", CloakFoodConst[2])
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:RegisterSkillInfo()
    inst:AddTag("food_effect_equip")
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(CloakFoodConst[1])
    inst.components.armor.ontakedamage = function(inst, damage, absorb_dmg, left_dmg)
        inst.components.tp_equip_value:DoDelta(absorb_dmg)
        if inst.components.tp_equip_value:GetPercent()>=1 then
            inst.components.tp_equip_value:SetPercent(0)
            local owner = inst.components.equippable.owner
            local food = SpawnPrefab("bonestew")
            -- food.components.tp_food_effect:Random({"small"})
            owner.components.inventory:GiveItem(food)
        end
    end
end)
table.insert(prefs, cloak_food)
Util:AddString(cloak_food.name, "大厨披风", 
string.format("增加1品尝值上限；增加%d生命和饥饿；每吸收%d点伤害，给予你一个炖肉汤；提升%d%%闪避", 
CloakFoodConst[1], CloakFoodConst[2], CLOAK_EVADE))

local CloakFrozenConst = {30, 3}
local cloak_frozen = MakeArmor("tp_cloak_frozen", ArmorAmount[2]*.75,
ArmorAbsorption[1], nil, 
function(inst, owner)
    owner.components.combat:AddEvadeRateMod(inst.prefab, CLOAK_EVADE) 
    inst.event_fn = EntUtil:listen_for_event(inst, 
        "freeze", function(owner, data)
            if inst.components.wg_recharge:IsRecharged()
            and EntUtil:is_alive(owner) then
                owner.components.health:DoDelta(CloakFrozenConst[1])
                inst.components.wg_recharge:SetRechargeTime(CloakFrozenConst[2])
            end
        end, 
    owner)
end, 
function(inst, owner)
    owner.components.combat:RmEvadeRateMod(inst.prefab)
    if inst.event_fn then
        inst:RemoveEventCallback("freeze", inst.event_fn, owner)
    end
end, 
function(inst)
    inst:AddComponent("wg_recharge")
end)
table.insert(prefs, cloak_frozen)
Util:AddString(cloak_frozen.name, "霜冻披风", 
string.format("被冰冻后回复%d生命；提升%d闪避", 
CloakFrozenConst[1], CLOAK_EVADE))

-- local ArmorJarvanIVConst = {9, 15, -.25, 100}
-- local armor_jarvaniv = MakeArmor("tp_armor_jarvaniv", ArmorAmount[1],
-- ArmorAbsorption[1], 
-- function(damage, attacker, weapon, owner, inst)
--     local current = inst.components.tp_equip_value.current
--     inst.components.tp_equip_value:DoDelta(-damage)
--     if current<damage then
--         return damage-current
--     else
--         return 0
--     end
-- end, nil, nil, 
-- function(inst)
--     inst.components.armor.dontremove = true
--     inst.components.equippable.suit = "jarvaniv"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_armor_jarvaniv")
--     inst:AddComponent("tp_equip_value")
--     inst.components.tp_equip_value:SetMax(ArmorJarvanIVConst[4])
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         and doer.components.tp_mana.current >= ArmorJarvanIVConst[2]
--         then
--             return true
--         end
--     end
--     -- inst.components.wg_action_tool.get_action_fn = function(inst, data)
--     --     -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--     -- end
--     inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--         inst.components.wg_recharge:SetRechargeTime(ArmorJarvanIVConst[1])
--         doer.components.tp_mana:DoDelta(-ArmorJarvanIVConst[2])
--         doer.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/vortex_armour/equip_on")
--         local fx = FxManager:MakeFx("vortex_cloak_fx", Vector3(0,0,0))
--         doer:AddChild(fx)
--         FxManager:MakeFx("groundpoundring_fx", doer)
--         -- 减速
--         local x, y, z = doer:GetPosition():Get()
--         local ents = TheSim:FindEntities(x, y, z, 12, nil, EntUtil.not_entity_tags)
--         for k, v in pairs(ents) do
--             if EntUtil:check_combat_target(doer, v) then
--                 EntUtil:add_speed_mod(v, inst.prefab, ArmorJarvanIVConst[3], 5)
--             end
--         end
--         -- 获得护盾
--         inst.components.tp_equip_value:SetPercent(1)
--         if inst.task then
--             inst.task:Cancel()
--             inst.task = nil
--         end
--         inst.task = inst:DoTaskInTime(5, function()
--             inst.components.tp_equip_value:SetPercent(0)
--         end)
--     end
--     -- inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--     --     -- 动作触发时会到达的效果
--     -- end
-- end)
-- table.insert(prefs, armor_jarvaniv)
-- Util:AddString(armor_jarvaniv.name, "王子护甲", 
-- string.format("不会损毁，需要套装释放技能，消耗%d魔法，为你抵挡%d点伤害，并令周围的敌人减速%d%%", 
-- ArmorJarvanIVConst[2], ArmorJarvanIVConst[4], -ArmorJarvanIVConst[3]*100))

-- local ArmorMonkConst = {50, 12, 50}
-- local armor_monk = MakeArmor("tp_armor_monk", ArmorAmount[1],
-- ArmorAbsorption[1], 
-- function(damage, attacker, weapon, owner, inst)
--     local current = inst.components.tp_equip_value.current
--     inst.components.tp_equip_value:DoDelta(-damage)
--     if current<damage then
--         return damage-current
--     else
--         return 0
--     end
-- end, nil, nil, 
-- function(inst)
--     inst.components.armor.dontremove = true
--     inst.components.equippable.suit = "monk"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_armor_monk")
--     inst:AddComponent("tp_equip_value")
--     inst.components.tp_equip_value:SetMax(ArmorMonkConst[3])
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         then
--             local helm = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
--             if helm and helm.components.tp_equip_value.current >= ArmorMonkConst[1] then
--                 return true
--             end
--         end
--     end
--     inst.components.wg_action_tool.click_get_action_fn = function(inst, data)
--         -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--         if data.target 
--         and ((not EntUtil:check_combat_target(data.doer, data.target)) 
--         or data.doer==data.target) then
--             return ACTIONS.TP_ARMOR_MONK
--         end
--     end
--     -- inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--     -- end
--     inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--         -- 动作触发时会到达的效果
--         local helm = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
--         if helm and helm.components.tp_equip_value then
--             helm.components.tp_equip_value:DoDelta(-ArmorMonkConst[1])
--             if target:HasTag("character") then
--                 BuffManager:AddBuff(target, "tp_armor_monk2")
--                 inst.components.wg_recharge:SetRechargeTime(ArmorMonkConst[2]/2)
--             else
--                 inst.components.wg_recharge:SetRechargeTime(ArmorMonkConst[2])
--             end
--             inst.components.tp_equip_value:SetPercent(1)
--             if inst.task then
--                 inst.task:Cancel()
--                 inst.task = nil
--             end
--             inst.task = inst:DoTaskInTime(4, function()
--                 inst.components.tp_equip_value:SetPercent(0)
--             end)
--             BuffManager:AddBuff(doer, "tp_helm_monk")
--             BuffManager:AddBuff(doer, "tp_armor_monk2")
--         end
--     end
-- end)
-- table.insert(prefs, armor_monk)
-- local buff_data = BuffManager:GetDataById("tp_armor_monk2")
-- Util:AddString(armor_monk.name, "武僧护甲", 
-- string.format("不会损毁，需要套装释放技能，消耗%d武僧头盔充能，位移到一个非地方单位处，令自己获得buff(%s)，若目标单位为直立生物，其也获得此buff，此护甲能够抵挡%d点伤害，且冷却减半",
-- ArmorMonkConst[1], buff_data:desc(), ArmorMonkConst[3]))

-- local ArmorZedConst = {10, 14, 6}
-- local armor_zed = MakeArmor("tp_armor_zed", ArmorAmount[1],
-- ArmorAbsorption[1], nil, nil, nil, 
-- function(inst)
--     inst.components.armor.dontremove = true
--     inst.components.equippable.suit = "zed"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_armor_zed")
--     inst:AddComponent("tp_equip_value")
--     inst.components.tp_equip_value:SetMax(ArmorZedConst[3])
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if (inst.components.wg_recharge:IsRecharged()
--         or not inst.components.tp_equip_value:IsEmpty())
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         then
--             local helm = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
--             if helm and helm.components.tp_equip_value.current >= ArmorZedConst[1] then
--                 return true
--             end
--         end
--     end
--     inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--         local data = inst.components.wg_action_tool:GetActionData()
--         local can = nil
--         if (doer:GetIsOnLand(data.pos:Get()) and doer:GetIsOnLand())
--         or (doer:GetIsOnWater(data.pos:Get()) and doer:GetIsOnWater()) then
--             if inst.fx == nil then
--                 local pos = doer:GetPosition()
--                 if distsq(pos, data.pos)<=15*15 then
--                     can = true
--                 end
--             elseif inst.fx:IsNear(data.doer, 15) then
--                 can = true
--             end
--         end
--         if can then
--             local helm = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
--             if helm and helm.components.tp_equip_value then
--                 helm.components.tp_equip_value:DoDelta(-ArmorZedConst[1])
--                 if inst.fx == nil then
--                     if inst.components.wg_recharge:IsRecharged() then
--                         inst.components.wg_recharge:SetRechargeTime(ArmorZedConst[2])
--                         inst.components.tp_equip_value:SetPercent(1)
--                         inst.components.tp_equip_value:Start()
--                         inst.fx = SpawnPrefab("tp_armor_zed_fx")
--                         inst.fx.Transform:SetPosition(data.pos:Get())
--                         FxManager:MakeFx("statue_transition", data.pos)
--                         FxManager:MakeFx("statue_transition_2", data.pos)
--                         inst.fx.owner_armor = inst
--                     end
--                 elseif not inst.components.tp_equip_value:IsEmpty() then
--                     inst.components.tp_equip_value:SetPercent(0)
--                     doer.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
--                     local pos = inst.fx:GetPosition()
--                     local pos2 = doer:GetPosition()
--                     FxManager:MakeFx("statue_transition", pos)
--                     FxManager:MakeFx("statue_transition", pos2)
--                     doer.Transform:SetPosition(pos:Get())
--                     inst.fx.Transform:SetPosition(pos2:Get())
--                 end
--             end
--         end
--     end
-- end)
-- table.insert(prefs, armor_zed)
-- Util:AddString(armor_zed.name, "影子护甲", 
-- string.format("不会损毁，需要套装释放技能，消耗%d影子头盔充能，召唤一个模仿你的影子，再次释放技能会和影子交换位置(不能距离太远)",
-- ArmorZedConst[1]))

-- local armor_zed_fx = Prefab("tp_armor_zed_fx", function()
--     local inst = CreateEntity()
--     local trans = inst.entity:AddTransform()
--     trans:SetFourFaced()
--     local anim = inst.entity:AddAnimState()
--     inst.entity:AddSoundEmitter()
--     inst.AnimState:SetBank("wilson")
--     inst.AnimState:SetBuild("wilson")
--     inst.AnimState:PlayAnimation("idle_loop")

--     inst.AnimState:Hide("ARM_carry")
--     inst.AnimState:Hide("hat")
--     inst.AnimState:Hide("hat_hair")
--     inst.AnimState:Hide("PROPDROP")

--     inst.AnimState:Show("ARM_carry")
--     inst.AnimState:Hide("ARM_normal")
--     inst.AnimState:OverrideSymbol("swap_object", "tp_spear_ice", "swap_object")
--     inst.AnimState:OverrideSymbol("swap_body", "tp_armor_cool", "swap_body")
--     inst.AnimState:Show("HAT")
--     inst.AnimState:Show("HAIR_HAT")
--     inst.AnimState:Hide("HAIR_NOHAT")
--     inst.AnimState:Hide("HAIR")
--     inst.AnimState:Hide("HEAD")
--     inst.AnimState:Show("HEAD_HAIR")
--     inst.AnimState:Hide("HAIRFRONT")
--     inst.AnimState:OverrideSymbol("swap_hat", "tp_hat_cool", "swap_hat")

--     inst:AddComponent("colourtweener")
--     inst.components.colourtweener:StartTween({0,0,0,.5}, 0)

--     inst:DoTaskInTime(0, function()
--         inst.AnimState:SetBuild(GetPlayer().prefab)
--     end)
--     inst:DoTaskInTime(ArmorZedConst[3], function()
--         FxManager:MakeFx("statue_transition", inst)
--         if inst.owner_armor and inst.owner_armor.fx then
--             inst.owner_armor.fx = nil
--         end
--         inst:Remove()
--     end)

--     return inst
-- end)
-- table.insert(prefs, armor_zed_fx)
-- Util:AddString(armor_zed_fx.name, "影子", "会模仿你的动作")

-- local ArmorJaxConst = {3, math.floor(30/3*2), 1.2}
-- local armor_jax = MakeArmor("tp_armor_jax", ArmorAmount[2], 
-- ArmorAbsorption[2], nil, nil, nil, 
-- function(inst)
--     inst.components.armor.dontremove = true
--     inst.components.equippable.suit = "jax"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_armor_jax")
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         and doer.components.tp_mana.current >= ArmorJaxConst[2]
--         then
--             return true
--         end
--     end
--     -- inst.components.wg_action_tool.get_action_fn = function(inst, data)
--     --     -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--     -- end
--     inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--         inst.components.wg_recharge:SetRechargeTime(ArmorJaxConst[1])
--         doer.components.tp_mana:DoDelta(-ArmorJaxConst[2])
--         doer.SoundEmitter:PlaySound("dontstarve/common/chest_positive")
--         local weapon = doer.components.combat:GetWeapon()
--         if weapon then
--             weapon.components.tp_equip_value:SetPercent(1)
--             weapon.components.tp_equip_value:Start()
--             weapon:AddTag("tp_mine_attack")
--         end
--     end
--     -- inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--     --     -- 动作触发时会到达的效果
--     -- end
-- end)
-- table.insert(prefs, armor_jax)
-- Util:AddString(armor_jax.name, "宗师护甲", 
-- string.format("不会损毁，需要套装释放技能，消耗%d魔法，下次攻击额外造成%d%%自身攻击力的伤害",
-- ArmorJaxConst[2], ArmorJaxConst[3]*100))

-- local ArmorDariusConst = {5, math.floor(40/3*2), .5, -.5}
-- local armor_darius = MakeArmor("tp_armor_darius", ArmorAmount[2], 
-- ArmorAbsorption[2], nil, nil, nil, 
-- function(inst)
--     inst.components.armor.dontremove = true
--     inst.components.equippable.suit = "darius"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_armor_darius")
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         and doer.components.tp_mana.current >= ArmorDariusConst[2]
--         then
--             return true
--         end
--     end
--     -- inst.components.wg_action_tool.get_action_fn = function(inst, data)
--     --     -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--     -- end
--     inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--         inst.components.wg_recharge:SetRechargeTime(ArmorDariusConst[1])
--         doer.components.tp_mana:DoDelta(-ArmorDariusConst[2])
--         doer.SoundEmitter:PlaySound("dontstarve/common/chest_positive")
--         local weapon = doer.components.combat:GetWeapon()
--         if weapon then
--             weapon.components.tp_equip_value:SetPercent(1)
--             weapon.components.tp_equip_value:Start()
--             weapon:AddTag("tp_chop_attack")
--         end
--     end
--     -- inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--     --     -- 动作触发时会到达的效果
--     -- end
-- end)
-- table.insert(prefs, armor_darius)
-- Util:AddString(armor_darius.name, "洛克护甲", 
-- string.format("不会损毁，需要套装释放技能，消耗%d魔法，下次攻击额外造成%d%%自身攻击力的伤害，并令目标减速%d%%",
-- ArmorDariusConst[2], ArmorDariusConst[3]*100, -ArmorDariusConst[4]*100))

-- local ArmorGarenConst = {19, 105, .3}
-- local armor_garen = MakeArmor("tp_armor_garen", ArmorAmount[2], 
-- ArmorAbsorption[2], 
-- function(damage, attacker, weapon, owner, inst)
--     if inst.charge then
--         damage = damage-damage*ArmorGarenConst[3]
--     end
--     local current = inst.components.tp_equip_value.current
--     inst.components.tp_equip_value:DoDelta(-damage)
--     if current<damage then
--         return damage-current
--     else
--         return 0
--     end
-- end, nil, nil, 
-- function(inst)
--     inst.components.armor.dontremove = true
--     inst.components.equippable.suit = "garen"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_armor_garen")
--     inst:AddComponent("tp_equip_value")
--     inst.components.tp_equip_value:SetMax(ArmorGarenConst[2])
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.purify = true
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
--         inst.components.wg_recharge:SetRechargeTime(ArmorGarenConst[1])
--         doer.SoundEmitter:PlaySound("dontstarve/common/chest_positive")
--         if EntUtil:is_frozen(doer) then
--             doer.components.freezable:Unfreeze()
--         end
--         inst.components.tp_equip_value:SetPercent(1)
--         inst.charge = true
--         if inst.task then
--             inst.task:Cancel()
--             inst.task = nil
--         end
--         inst.task = inst:DoTaskInTime(5, function()
--             inst.components.tp_equip_value:SetPercent(0)
--             inst.charge = nil
--         end)
--     end
--     -- inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--     --     -- 动作触发时会到达的效果
--     -- end
-- end)
-- table.insert(prefs, armor_garen)
-- Util:AddString(armor_garen.name, "迪玛护甲", 
-- string.format("不会损毁，需要套装释放技能，解冻，降低%d%%你受到的伤害，为你抵挡%d点伤害", 
-- ArmorGarenConst[3]*100, ArmorGarenConst[2]))

return unpack(prefs)