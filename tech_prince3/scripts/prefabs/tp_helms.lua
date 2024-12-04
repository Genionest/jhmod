local Util = require "extension.lib.wg_util"
local AssetUtil = require "extension/lib/asset_util"
local PrefabUtil = require "extension/lib/prefab_util"
local EntUtil = require "extension/lib/ent_util"
local AssetMaster = Sample.AssetMaster
local Info = Sample.Info
local BuffManager = Sample.BuffManager
local EntUtil = require "extension.lib.ent_util"
local FxManager = Sample.FxManager
local BuffManager = Sample.BuffManager

local prefs = {}

local ArmorAmount = Info.Armor.ArmorAmount

local ArmorAbsorption = Info.Armor.ArmorAbsorption

--[[
创建头盔预制物  
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
local function MakeHelm(name, armor, absorb, on_attacked, equip, unequip, fn, not_fixable)
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
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
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

local HelmCombatConst = {150, 5, .1, .2}
local helm_combat = MakeHelm("tp_helm_combat", ArmorAmount[1], 
ArmorAbsorption[1], nil, 
function(inst, owner)
    inst.event_fn = EntUtil:listen_for_event(inst, "tp_equip_value_delta", function(inst, data)
        -- 充能变化时改变攻击力加成
        local p = inst.components.tp_equip_value:GetPercent()
        local owner = inst.components.equippable.owner
        if owner then
            local ex = (HelmCombatConst[4]-HelmCombatConst[3])*p
            local mult = HelmCombatConst[3]+ex
            EntUtil:add_damage_mod(owner, "tp_helm_combat", mult)
        end
    end)
end, 
function(inst, owner)
    if inst.event_fn then
        inst:RemoveEventCallback("tp_equip_value_delta", inst.event_fn)
    end
    inst.components.tp_equip_value:Runout()
    -- 这时候inst.components.equippable.owner并未清空
    -- 但我们依然要在这里消除buff，因为装备损坏时不会触发tp_equip_value.stop
    EntUtil:rm_damage_mod(owner, "tp_helm_combat")
end, 
function(inst)
    inst:AddComponent("wg_action_tool")
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(HelmCombatConst[1])
    inst.components.tp_equip_value:SetRate(HelmCombatConst[2])
    inst.components.tp_equip_value.stop = function(inst)
        local owner = inst.components.equippable.owner
        if owner then
            EntUtil:rm_damage_mod(owner, "tp_helm_combat")
        end
    end
    inst.components.armor.ontakedamage = function(inst,damage,absorb_dmg,left_dmg)
        inst.components.tp_equip_value:DoDelta(absorb_dmg)
        inst.components.tp_equip_value:Start()
        local p = inst.components.tp_equip_value:GetPercent()
        local owner = inst.components.equippable.owner
        if owner then
            local ex = (HelmCombatConst[4]-HelmCombatConst[3])*p
            local mult = HelmCombatConst[3]+ex
            EntUtil:add_damage_mod(owner, "tp_helm_combat", mult)
        end
    end
end)
table.insert(prefs, helm_combat)
local helm_combat_desc = "吸收的伤害转为不断衰减的充能，充能会提升攻击力，充能越高，攻击提升越高，最高%d%%"
Util:AddString(helm_combat.name, "战斗头盔",
string.format(helm_combat_desc, HelmCombatConst[4]*100))

local HelmBaseballConst = {4, 8}
local helm_baseball = MakeHelm("tp_helm_baseball", ArmorAmount[1], 
ArmorAbsorption[1],
function(damage, attacker, weapon, owner, inst)
    local cur = inst.components.tp_equip_value.current
    return damage - cur
end, nil, 
function(inst, owner)
    inst.components.tp_equip_value:SetPercent(0)
end, function(inst)
    inst:AddComponent("wg_action_tool")
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(HelmBaseballConst[2])
    inst.components.armor.ontakedamage = function(inst,damage,absorb_dmg,left_dmg)
        inst.components.tp_equip_value:DoDelta(HelmBaseballConst[1])
        inst.components.tp_equip_value:Start()
    end
end)
table.insert(prefs, helm_baseball)
Util:AddString(helm_baseball.name, "棒球头盔", 
string.format("受到攻击会增加充能，充能会不断衰减，充能会提供伤害减免，充能越高减免越多，最多减免%d点", HelmBaseballConst[2]))

local helm_cool = MakeHelm("tp_helm_cool", ArmorAmount[2],
ArmorAbsorption[2], nil, nil, nil, 
function(inst)
    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
    inst.components.insulator:SetSummer()
end)
table.insert(prefs, helm_cool)
Util:AddString(helm_cool.name, "清凉头盔", 
string.format("拥有清凉效果(等同于清凉夏装)"))

local helm_warm = MakeHelm("tp_helm_warm", ArmorAmount[2],
ArmorAbsorption[2], nil, nil, nil, 
function(inst)
    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
end)
table.insert(prefs, helm_warm)
Util:AddString(helm_warm.name, "保暖头盔", 
string.format("拥有保暖和防雨效果(等同于牛帽)"))

local HelmAncientConst = {250, 5000, 0.05, 8}
local helm_ancient = MakeHelm("tp_helm_ancient", ArmorAmount[3], 
ArmorAbsorption[3], nil, 
function(inst, owner)
    if owner.components.combat then
        inst.calc_fn = owner.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
            local data = {damage=damage, inst=inst, target=target, weapon=weapon}
            local damage = data.damage
            if inst.components.wg_recharge:IsRecharged() 
            and inst.components.tp_equip_value:GetPercent()>=1 then
                inst.components.wg_recharge:SetRechargeTime(HelmAncientConst[4])
                inst.components.tp_equip_value:SetPercent(0)
                local max_hp = data.target.components.health:GetMaxHealth()
                if max_hp>=HelmAncientConst[2] then
                    damage = damage + max_hp*HelmAncientConst[3]
                end
            end
            return damage
        end)
    end
    -- inst.event_fn = EntUtil:listen_for_event(inst, "onhitother", function(owner, data)
    --     if inst.components.wg_recharge:IsRecharged() 
    --     and inst.components.tp_equip_value:GetPercent()>=1 then
    --         inst.components.wg_recharge:SetRechargeTime(HelmAncientConst[4])
    --     end
    -- end, owner)
end,
function(inst, owner)
    if owner.components.combat then
        owner.components.combat:WgRemoveCalcDamageFn(inst.calc_fn)
    end
end, 
function(inst)
    inst:AddTag("hat_open")
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_action_tool")
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(HelmAncientConst[1])
    inst.components.armor.ontakedamage = function(inst,damage,absorb_dmg,left_dmg)
        inst.components.tp_equip_value:DoDelta(absorb_dmg)        
    end
end)
table.insert(prefs, helm_ancient)
Util:AddString(helm_ancient.name, "远古头盔",
string.format("吸收%d点伤害后，下次攻击对生命值大于%d的敌人，额外造成其最大生命值%d%%的伤害(此效果有%ds冷却)", 
HelmAncientConst[1], HelmAncientConst[2], HelmAncientConst[3]*100, HelmAncientConst[4]))

-- local HelmJarvanIVConst = {11, 22, 40, .4, 8, 28}
-- local helm_jarvaniv = MakeHelm("tp_helm_jarvaniv", ArmorAmount[1],
-- ArmorAbsorption[1], nil, nil, nil, 
-- function(inst)
--     inst.components.armor.dontremove = true
--     inst.components.equippable.suit = "jarvaniv"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_helm_jarvaniv")
--     inst:AddComponent("tp_equip_value")
--     inst.components.tp_equip_value:SetMax(HelmJarvanIVConst[5])
--     inst.components.tp_equip_value.stop = function(inst)
--         if inst.fx then
--             inst.fx:Remove()
--             inst.fx = nil
--         end
--     end
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         if inst.fx == nil
--         and inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         and doer.components.tp_mana.current >= HelmJarvanIVConst[2]
--         then
--             return true
--         end
--         if inst.fx
--         and doer.components.tp_suit.suit == inst.components.equippable.suit then
--             local spear = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
--             if spear and spear.components.wg_recharge
--             and spear.components.wg_recharge:IsRecharged()
--             and doer.components.tp_mana.current >= HelmJarvanIVConst[6] then
--                 if inst.fx and inst.fx:IsNear(doer, 12) then
--                     return true
--                 end
--             end
--         end
--     end
--     -- inst.components.wg_action_tool.get_action_fn = function(inst, data)
--     --     -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--     -- end
--     inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--         if inst.fx then
--             local data = inst.components.wg_action_tool:GetActionData()
--             local spear = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
--             if spear then
--                 spear.charge = true
--                 local ba = BufferedAction(data.doer, inst.fx, ACTIONS.TP_HELM_JARVANIV, spear, nil)
--                 doer:PushBufferedAction(ba)
--             end
--         else
--             inst.components.wg_recharge:SetRechargeTime(HelmJarvanIVConst[1])
--             doer.components.tp_mana:DoDelta(-HelmJarvanIVConst[2])
--             inst.components.tp_equip_value:SetPercent(1)
--             inst.components.tp_equip_value:Start()
--             local data = inst.components.wg_action_tool:GetActionData()
--             local pos = data.pos or data.target:GetPosition()
--             local fx = SpawnPrefab("tp_helm_jarvaniv_fx")
--             pos.y = 20
--             fx.Transform:SetPosition(pos:Get())
--             inst.fx = fx
--         end
--     end
--     -- inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--     --     -- 动作触发时会到达的效果
--     -- end
-- end)
-- table.insert(prefs, helm_jarvaniv)
-- local buff_data = BuffManager:GetDataById("tp_spear_jarvaniv_debuff")
-- Util:AddString(helm_jarvaniv.name, "王子头盔", 
-- string.format("不会损毁，需要套装释放技能，消耗%d魔法，朝王子鼓舞战矛突刺(须在其buff范围内)，对经过的敌人造成%d+%d%%自身攻击力的伤害，并令获得buff(%s)",
-- HelmJarvanIVConst[2], HelmJarvanIVConst[3], HelmJarvanIVConst[4]*100, buff_data:desc()))

-- local helm_jarvaniv_fx = Prefab("tp_helm_jarvaniv_fx", 
-- function()
--     local inst = CreateEntity()
--     local trans = inst.entity:AddTransform()
--     local anim = inst.entity:AddAnimState()
--     inst.AnimState:SetBank("tp_spear_combat")
--     inst.AnimState:SetBuild("tp_spear_combat")
--     inst.AnimState:PlayAnimation("idle")

--     inst:AddTag("tp_helm_jarvaniv_fx")

--     MakeInventoryPhysics(inst)
--     RemovePhysicsColliders(inst)

--     inst:DoPeriodicTask(.5, function()
--         local player = GetPlayer()
--         if player:IsNear(inst, 12) then
--             BuffManager:AddBuff(player, "tp_spear_jarvaniv")
--         end
--     end)
--     inst:DoTaskInTime(10, inst.Remove)

--     return inst
-- end)
-- table.insert(prefs, helm_jarvaniv_fx)
-- local buff_data = BuffManager:GetDataById("tp_spear_jarvaniv")
-- Util:AddString(helm_jarvaniv_fx.name, "王子鼓舞战矛", 
-- string.format("玩家在周围获得buff(%s)", buff_data.desc(buff_data)))

-- local HelmMonkConst = {50, 9, 35, 1, -.25}
-- local helm_monk = MakeHelm("tp_helm_monk", ArmorAmount[1],
-- ArmorAbsorption[1], nil, nil, nil, 
-- function(inst)
--     inst.components.armor.dontremove = true
--     inst.components.equippable.suit = "monk"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_helm_monk")
--     inst:AddComponent("tp_equip_value")
--     inst.components.tp_equip_value:SetMax(200)
--     inst.task = inst:DoPeriodicTask(1, function()
--         inst.components.tp_equip_value:DoDelta(7.5)
--     end)
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({
--         desc = string.format("消耗%d充能，猛击地面，对周围的敌人造成%d+%d%%自身攻击力的伤害，并令其减速%d%%",
--             HelmMonkConst[1], HelmMonkConst[3], HelmMonkConst[4]*100, -HelmMonkConst[5]*100)
--     })
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         then
--             if inst.components.tp_equip_value.current >= HelmMonkConst[1] then
--                 return true
--             end
--         end
--     end
--     inst.components.wg_action_tool.click_get_action_fn = function(inst, data)
--         -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--         return ACTIONS.TP_ATK
--     end
--     -- inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--     -- end
--     inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--         -- 动作触发时会到达的效果
--         inst.components.tp_equip_value:DoDelta(-HelmMonkConst[1])
--         inst.components.wg_recharge:SetRechargeTime(HelmMonkConst[2])
--         FxManager:MakeFx("groundpound_fx", doer)
--         EntUtil:make_area_dmg(doer, 4, doer, HelmMonkConst[3], 
--             doer.components.combat:GetWeapon(), nil, {
--             fn = function(v, attacker, weapon)
--                 EntUtil:add_speed_mod(v, inst.prefab, HelmMonkConst[5], 5)
--                 FxManager:MakeFx("sanity_raise", v)
--             end,
--             mult = HelmMonkConst[4],
--         })
--         BuffManager:AddBuff(doer, "tp_helm_monk")
--     end
-- end)
-- table.insert(prefs, helm_monk)
-- Util:AddString(helm_monk.name, "武僧头盔", 
-- string.format("不会损毁，自身会不断回复充能；使用该套装的技能后攻击会回复充能；需要套装释放技能"))

-- local HelmZedConst = {40, 4, 25, .4, -.3}
-- local helm_zed = MakeHelm("tp_helm_zed", ArmorAmount[1],
-- ArmorAbsorption[1], nil, nil, nil, 
-- function(inst)
--     inst.components.armor.dontremove = true
--     inst.components.equippable.suit = "zed"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_helm_zed")
--     inst:AddComponent("tp_equip_value")
--     inst.components.tp_equip_value:SetMax(200)
--     inst.task = inst:DoPeriodicTask(1, function()
--         inst.components.tp_equip_value:DoDelta(7.5)
--     end)
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({
--         desc = string.format("消耗%d充能，引爆暗影能量，对自身和影子周围的敌人造成%d+%d%%自身攻击力的伤害，并令影子周围的敌人减速%d%%",
--             HelmZedConst[1], HelmZedConst[3], HelmZedConst[4]*100, -HelmZedConst[5]*100)
--     })
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         then
--             if inst.components.tp_equip_value.current >= HelmZedConst[1] then
--                 return true
--             end
--         end
--     end
--     -- inst.components.wg_action_tool.get_action_fn = function(inst, data)
--     --     -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--     -- end
--     inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--         inst.components.tp_equip_value:DoDelta(-HelmZedConst[1])
--         inst.components.wg_recharge:SetRechargeTime(HelmZedConst[2])
--         local armor = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
--         FxManager:MakeFx("statue_transition_2", doer)
--         FxManager:MakeFx("bramblefx", doer)
--         local hit = nil
--         EntUtil:make_area_dmg(doer, 4, doer, HelmZedConst[3], 
--             doer.components.combat:GetWeapon(), nil, {
--             fn = function(v, attacker, weapon)
--                 if hit == nil then
--                     hit = true
--                     armor.components.wg_recharge:DoDelta(2)
--                 end
--             end,
--             mult = HelmZedConst[4],
--         })
--         if armor and armor.fx then
--             FxManager:MakeFx("statue_transition_2", armor.fx)
--             FxManager:MakeFx("bramblefx", armor.fx)
--             local hit = nil
--             EntUtil:make_area_dmg(armor.fx, 4, doer, HelmZedConst[3], 
--                 doer.components.combat:GetWeapon(), nil, {
--                 fn = function(v, attacker, weapon)
--                     if hit == nil then
--                         hit = true
--                         inst.components.tp_equip_value:DoDelta(20)
--                         armor.components.wg_recharge:DoDelta(2)
--                     end
--                     EntUtil:add_speed_mod(v, inst.prefab, HelmZedConst[5], 5)
--                 end,
--                 mult = HelmZedConst[4],
--             })
--         end
--     end
--     -- inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--     --     -- 动作触发时会到达的效果
--     -- end
-- end)
-- table.insert(prefs, helm_zed)
-- Util:AddString(helm_zed.name, "影子头盔", 
-- string.format("不会损毁，自身会不断回复充能，影子的技能命中第一个敌人时会回复充能；该物品的技能命中第一个敌人时会降低影子护甲2s冷却；需要套装释放技能"))

-- local HelmJaxConst = {12, math.floor(70/3*2)}
-- local helm_jax = MakeHelm("tp_helm_jax", ArmorAmount[2],
-- ArmorAbsorption[2], nil, nil, nil, 
-- function(inst)
--     inst.components.armor.dontremove = true
--     inst.components.equippable.suit = "jax"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_helm_jax")
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         and doer.components.tp_mana.current >= HelmJaxConst[2]
--         then
--             return true
--         end
--     end
--     -- inst.components.wg_action_tool.get_action_fn = function(inst, data)
--     --     -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--     -- end
--     inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--         inst.components.wg_recharge:SetRechargeTime(HelmJaxConst[1])
--         doer.components.tp_mana:DoDelta(-HelmJaxConst[2])
--         doer.SoundEmitter:PlaySound("dontstarve/common/chest_positive")
--         BuffManager:AddBuff(doer, "tp_helm_jax")
--     end
--     -- inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--     --     -- 动作触发时会到达的效果
--     -- end
-- end)
-- table.insert(prefs, helm_jax)
-- local buff_data = BuffManager:GetDataById("tp_helm_jax")
-- Util:AddString(helm_jax.name, "宗师头盔", 
-- string.format("不会损毁，需要套装释放技能，消耗%d魔法，获得buff(%s)", 
-- HelmJaxConst[2], buff_data:desc()))

-- local HelmDariusConst = {19, math.floor(50/3*2), -.5}
-- local helm_darius = MakeHelm("tp_helm_darius", ArmorAmount[2],
-- ArmorAbsorption[2], nil, nil, nil, 
-- function(inst)
--     inst.components.armor.dontremove = true
--     inst.components.equippable.suit = "darius"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_helm_darius")
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if inst.components.wg_recharge:IsRecharged()
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         and doer.components.tp_mana.current >= HelmDariusConst[2]
--         then
--             return true
--         end
--     end
--     inst.components.wg_action_tool.click_get_action_fn = function(inst, data)
--         -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--         if data.pos or data.target then
--             return ACTIONS.TP_ATTACK_PROP
--         end
--     end
--     -- inst.components.wg_action_tool.click_fn = function(inst, doer)
--     --     -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--     -- end
--     inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--         -- 动作触发时会到达的效果
--         inst.components.wg_recharge:SetRechargeTime(HelmDariusConst[1])
--         doer.components.tp_mana:DoDelta(-HelmDariusConst[2])
--         if target then
--             pos = target:GetPosition()
--         end
--         local pos2 = doer:GetPosition()
--         local dx, dz = pos.x-pos2.x, pos.z-pos2.z
--         local mult = math.sqrt( (2*2)/(dx*dx+dz*dz) )
--         local pt = pos2+Vector3(dx*mult, 0, dz*mult)
--         local x, y, z = pt:Get()
--         local ents = TheSim:FindEntities(x, y, z, 3, nil, EntUtil.not_enemy_tags)
--         for k, v in pairs(ents) do
--             if EntUtil:check_combat_target(doer, v) then
--                 BuffManager:AddBuff(v, "tp_helm_darius_debuff")
--                 EntUtil:add_speed_mod(v, "tp_helm_darius", HelmDariusConst[3], 3)
--                 FxManager:MakeFx("sanity_raise", v)
--             end
--         end
--     end
-- end)
-- table.insert(prefs, helm_darius)
-- local buff_data = BuffManager:GetDataById("tp_helm_darius_debuff")
-- Util:AddString(helm_darius.name, "洛克头盔", 
-- string.format("不会损毁，需要套装释放技能，消耗%d魔法，挥舞武器，令前方的敌人减速%d%%并令其获得buff(%s)", 
-- HelmDariusConst[2], -HelmDariusConst[3]*100, buff_data:desc()))

-- local HelmGarenConst = {9, 20, .4, 3}
-- local helm_garen = MakeHelm("tp_helm_garen", ArmorAmount[2],
-- ArmorAbsorption[2], nil, nil, nil, 
-- function(inst)
--     inst.components.armor.dontremove = true
--     inst.components.equippable.suit = "garen"
--     inst:AddComponent("wg_recharge")
--     inst.components.wg_recharge:SetCommon("tp_helm_garen")
--     inst:AddComponent("tp_equip_value")
--     inst.components.tp_equip_value:SetMax(HelmGarenConst[4])
--     inst:AddComponent("wg_action_tool")
--     inst.components.wg_action_tool:RegisterSkillInfo({})
--     inst.components.wg_action_tool.test = function(inst, doer)
--         --检测
--         if (inst.components.wg_recharge:IsRecharged()
--         or not inst.components.tp_equip_value:IsEmpty())
--         and doer.components.tp_suit.suit == inst.components.equippable.suit 
--         then
--             return true
--         end
--     end
--     -- inst.components.wg_action_tool.click_get_action_fn = function(inst, data)
--     --     -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
--     --     return ACTIONS.TP_HELM_GAREN
--     -- end
--     inst.components.wg_action_tool.click_fn = function(inst, doer)
--         -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
--         if inst.components.wg_recharge:IsRecharged() then
--             inst.components.wg_recharge:SetRechargeTime(HelmGarenConst[1])
--             inst.components.tp_equip_value:SetPercent(1)
--             inst.components.tp_equip_value:Start()
--             local ba = BufferedAction(doer, nil, ACTIONS.TP_HELM_GAREN, inst, nil)
--             doer:PushBufferedAction(ba)
--         else
--             inst.components.tp_equip_value:Runout()
--         end
--     end
--     -- inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
--     --     -- 动作触发时会到达的效果
--     -- end
-- end)
-- table.insert(prefs, helm_garen)
-- Util:AddString(helm_garen.name, "迪玛头盔", 
-- string.format("不会损毁，需要套装释放技能，不断旋转武器，每次旋转对周围的敌人造成%d+%d%%自身攻击力的伤害",
-- HelmGarenConst[2], HelmGarenConst[3]*100))

return unpack(prefs)