local Util = require "extension.lib.wg_util"
local AssetUtil = require "extension/lib/asset_util"
local PrefabUtil = require "extension/lib/prefab_util"
local EntUtil = require "extension/lib/ent_util"
local Kit = require "extension.lib.wargon"
local Sounds = require "extension.datas.sounds"
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

        inst:AddComponent("tp_forge_weapon")
    
        if use then
            inst:AddComponent("finiteuses")
            inst.components.finiteuses:SetMaxUses(use)
            inst.components.finiteuses:SetUses(use)
            inst.components.finiteuses:SetOnFinished(function(inst)
                inst:Remove()
            end)
        end

        inst:AddComponent("tp_exist_time")

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




local function do_attack_leap(inst, doer)
    doer.SoundEmitter:PlaySound(Sounds.attack_leap)
end

local Const = {50}
local spear_fall_light = MakeWeapon("tp_spear_fall_light", Const[1], 
nil, nil, nil, 100, function(inst)
    inst.components.weapon.getdamagefn = function(inst)
        local use = inst.components.finiteuses:GetUses()
        local total = inst.components.finiteuses.total
        return Const[1] + (total - use)/3
    end
    inst.components.weapon.dmg_type = "spike"
    inst.components.weapon:SetAttackCostVigor(2)
    inst.components.equippable:SetEquipWeight(2)
    inst.components.tp_forge_weapon:SetAttrFactor("agility", .4)
    -- inst.components.tp_forge_weapon:SetElements("fire")
end)
table.insert(prefs, spear_fall_light)
Util:AddString(spear_fall_light.name, "光陨", "损失的耐久越多,攻击力越高")

local Const = {20, 30}
local spear_moon_light = MakeWeapon("tp_spear_moon_light", Const[2], 
nil, nil, nil, 220, function(inst)
    inst.components.weapon.getdamagefn = function(inst)
        local cnt = 0
        local ids = inst.components.tp_smearable.ids
        if ids then
            for k, v in pairs(ids) do
                cnt = cnt + 1
            end
        end
        return Const[2] + cnt * Const[1]
    end
    inst.components.weapon.dmg_type = "spike"
    inst.components.weapon:SetAttackCostVigor(2)
    inst.components.equippable:SetEquipWeight(2)
    inst.components.tp_forge_weapon:SetAttrFactor("intelligence", .2)
    inst.components.tp_forge_weapon:SetAttrFactor("agility", .2)
    -- inst.components.tp_forge_weapon:SetElements("fire")
end)
table.insert(prefs, spear_moon_light)
Util:AddString(spear_moon_light.name, "月华", 
    string.format("该武器每拥有一个buff效果,便增加%d攻击力", Const[1]))

local spear_vortex = MakeWeapon("tp_spear_vortex", 46, 
nil, nil, nil, 170, function(inst)
    inst.components.weapon.dmg_type = "spike"
    inst.components.weapon:SetAttackCostVigor(2)
    inst.components.equippable:SetEquipWeight(2)
    inst.components.tp_forge_weapon:SetAttrFactor("agility", .3)
    -- inst.components.tp_forge_weapon:SetElements("fire")
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 5,
        mana = 20,
        vigor = 3,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        return ACTIONS.TP_CHOP_START
    end
    -- inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.no_catch_action = true
    inst.components.wg_action_tool:SetDefaultClickFn()
    -- inst.components.wg_action_tool.click_fn = function(inst, doer)
    --     -- -- 技能栏里释放技能会触发的效果,默认会出发get_action_fn的动作
    -- end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        inst:cyclone_slash(doer)
    end
    inst.cyclone_slash = function(inst, doer, ignore)
        FxManager:MakeFx("cyclone_slash", doer, {angle=doer.Transform:GetRotation()})
        EntUtil:do_cyclone_slash(inst, doer, 5, 10, 
            EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "cyclone_slash"),
            { calc = true },
            ignore
        )
    end
end)
table.insert(prefs, spear_vortex)
Util:AddString(spear_vortex.name, "涡流", "释放技能造成1次回旋斩击")

local spear_flow_shine = MakeWeapon("tp_spear_flow_shine", 66, 
nil, nil, nil, 400, function(inst)
    inst.components.weapon.dmg_type = "spike"
    inst.components.weapon:SetAttackCostVigor(2)
    inst.components.equippable:SetEquipWeight(2)
    inst.components.tp_forge_weapon:SetAttrFactor("agility", .3)
    inst.components.equippable:WgAddEquipAttackedFn(function(damage, attacker, weapon, owner, item)
        if owner.sg and owner.sg:HasStateTag("attack")
        and owner.sg:HasStateTag("busy") then
            if owner.sg:HasStateTag("abouttoattack") then
                damage = damage * .7
            else
                damage = damage * .1
            end
        end
        return damage
    end)
    -- inst.components.tp_forge_weapon:SetElements("fire")
end)
table.insert(prefs, spear_flow_shine)
Util:AddString(spear_flow_shine.name, "浮光", "攻击时降低受到的伤害,前摇时降低的伤害较少")

local spear_rebuild = MakeWeapon("tp_spear_rebuild", 42, 
nil, 
function(inst, owner)
    inst.event_fn = EntUtil:listen_for_event(inst, "stop_lunge,", function(owner, data)
        if data.weapon == inst then
            inst:cyclone_slash(owner)
        end
    end, owner)
end, 
function(inst, owner)
    if inst.event_fn then
        inst:RemoveEventCallback("stop_lunge", inst.event_fn, owner)
        inst.event_fn = nil
    end
end, 
200, function(inst)
    inst.components.equippable:SetSomeAttr(2, "slash", 2)
    inst.components.tp_forge_weapon:SetAttrFactor("strengthen", .3)
    -- inst.components.tp_forge_weapon:SetElements("fire")
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType("move")
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 7,
        mana = 25,
        vigor = 4,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_LUNGE
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        -- inst:PushEvent("lunge", {weapon=inst})
        -- inst.enemies = {}
        -- for i = 1, 3 do
        --     inst:DoTaskInTime(i * 0.1, function()
        --         EntUtil:make_area_dmg(doer, 3.3, doer, 0, inst, 
        --             EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "lunge"),
        --             {
        --                 calc=true,
        --                 fn = function(v, attacker, weapon)
        --                     inst.enemies[v] = true
        --                 end,
        --                 test = function(v, attacker, weapon)
        --                     return not inst.enemies[v]
        --                 end
        --             }
        --         )
        --     end)
        -- end
        EntUtil:do_lunge(inst, doer, 3.3, 10, 
            EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "lunge"),
            {
                calc=true,
                fn = function(v, attacker, weapon)
                    inst.enemies[v] = true
                end,
                test = function(v, attacker, weapon)
                    return not inst.enemies[v]
                end
            }
        )
    end
    inst.cyclone_slash = function(inst, doer, ignore)
        FxManager:MakeFx("cyclone_slash2", doer, {angle=doer.Transform:GetRotation()})
        EntUtil:do_cyclone_slash(inst, doer, 5, 10, 
            EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "slkill", "cyclone_slash"),
            { calc = true }, 
            ignore
        )
    end
end)
table.insert(prefs, spear_rebuild)
Util:AddString(spear_rebuild.name, "重构", "技能:向前突刺,结束时释放回旋斩击")

local spear_broken_star = MakeWeapon("tp_spear_broken_star", 50, 
function(inst, owner)
    inst.components.tp_equip_value:DoDelta(1)
end, 
nil, 
nil, 
200, 
function(inst)
    inst.components.weapon.dmg_type = "strike"
    inst.components.weapon:SetAttackCostVigor(2)
    inst.components.equippable:SetEquipWeight(2)
    inst.components.tp_forge_weapon:SetAttrFactor("strengthen", .2)
    inst.components.tp_forge_weapon:SetAttrFactor("lucky", .15)
    -- inst.components.tp_forge_weapon:SetElements("fire")
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(5)
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        vigor = 3,
        mana = 15,
    })
    inst.components.wg_action_tool.test = function(inst, doer)
        --检测
        if inst.components.tp_equip_value:IsFull() then
            return true
        end
    end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        return ACTIONS.TP_CHOP_START
    end
    -- inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.no_catch_action = true
    inst.components.wg_action_tool:SetDefaultClickFn()
    -- inst.components.wg_action_tool.click_fn = function(inst, doer)
    --     -- -- 技能栏里释放技能会触发的效果,默认会出发get_action_fn的动作
    -- end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        inst.components.tp_equip_value:SetPercent(0)
        inst:cyclone_slash(doer)
    end
    inst.cyclone_slash = function(inst, doer, ignore)
        FxManager:MakeFx("cyclone_slash3", doer, {angle=doer.Transform:GetRotation()})
        EntUtil:do_cyclone_slash(inst, doer, 5, 20, 
            EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "cyclone_slash"),
            { calc = true },
            ignore
        )
    end
end)
table.insert(prefs, spear_broken_star)
Util:AddString(spear_broken_star.name, "破碎之星", "攻击获得充能,充能满后可使用回旋斩击")

local spear_overload = MakeWeapon("tp_spear_overload", 100, 
nil, nil, nil, 200, function(inst)
    inst.components.equippable:SetSomeAttr(2, "slash", 2)
    inst.components.tp_forge_weapon:SetAttrFactor("agility", .3)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("tp_equip_value")
    inst.components.tp_equip_value:SetMax(10)
    inst.components.wg_recharge:SetRechargeTime(20)
    inst.components.wg_recharge.on_recharged = function(inst)
        inst.components.tp_equip_value:SetPercent(1)
        inst.components.tp_equip_value:Start()
    end
    inst.components.tp_equip_value.stop = function(inst)
        inst.components.wg_recharge:SetRechargeTime(20)
    end
    inst:AddComponent("wg_reticule")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription("突刺,并获得攻击和攻速加成")
    inst.components.wg_action_tool:SetSkillType("move")
    inst.components.wg_action_tool:RegisterSkillInfo({
        vigor = 3,
        mana = 15,
        cd = 30,
    })
    inst.components.wg_action_tool.test = function(inst, doer)
        --检测
        if not inst.components.tp_equip_value:IsEmpty() then
            return true
        end
    end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_LUNGE
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        BuffManager:AddBuff(doer, "tp_spear_overload")
        EntUtil:do_lunge(inst, doer, 3.3, 50, 
            EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "lunge"),
            {
                calc=true,
                fn = function(v, attacker, weapon)
                    inst.enemies[v] = true
                end,
                test = function(v, attacker, weapon)
                    return not inst.enemies[v]
                end
            }
        )
    end
end)
table.insert(prefs, spear_overload)
Util:AddString(spear_overload.name, "超载", "会不段在冷却和充能之间切换,充能状态下可以使用技能")

local spear_thunder_scream = MakeWeapon("tp_spear_thunder_scream", 55, 
function(inst, owner, target)
    if target:HasTag("conductive") then
        BuffManager:AddBuff(target, "defense_down", 50)
    end
end, nil, nil, 150, function(inst)
    inst.components.equippable:SetSomeAttr(2, "slash", 2)
    inst.components.tp_forge_weapon:SetAttrFactor("strengthen", .4)
    inst.components.tp_forge_weapon:SetElement("electric")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription("在周围召唤一圈落雷,对周围的敌人造成伤害,并令其进入导电状态")
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        vigor = 3,
        mana = 15,
        cd = 15,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        return ACTIONS.TP_LUNGE_PRE
    end
    -- inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.no_catch_action = true
    -- inst.components.wg_action_tool.click_fn = function(inst, doer)
    --     -- 技能栏里释放技能会触发的效果,默认会出发get_action_fn的动作
    -- end
    inst.components.wg_action_tool:SetDefaultClickFn()
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        for i = 1, 6 do
            local angle = i * 360/6
            local x = math.cos(angle) * 4
            local z = math.sin(angle) * 4
            local pos = doer:GetPosition() + Vector3(x, 0, z)
            local fx = FxManager:MakeFx("hit_fx6", pos)
        end
        doer.SoundEmitter:PlaySound(Sounds.thunder)
        EntUtil:make_area_dmg(doer, 4, doer, 10, inst, 
            EntUtil:add_stimuli(nil, "electric", "skill"), 
            {
                calc = true,
                fn = function(v, attacker, weapon)
                    BuffManager:AddBuff(v, "electric")
                end,
            }
        )
    end
end)
table.insert(prefs, spear_thunder_scream)
Util:AddString(spear_thunder_scream.name, "嘶吼", "攻击会降低导电状态敌人的防御")

local spear_flame_shine = MakeWeapon("tp_spear_flame_shine", 30, 
nil, nil, nil, 300, function(inst)
    inst.components.equippable:SetSomeAttr(2, "slash", 2)
    inst.components.tp_forge_weapon:SetAttrFactor("agility", .4)
    inst.components.tp_forge_weapon:SetElement("fire")
    
end)
table.insert(prefs, spear_flame_shine)
Util:AddString(spear_flame_shine.name, "晚霞", "")

local scroll_holly_sword = MakeWeapon("tp_scroll_holly_sword", 130, 
nil, 
function(inst, owner)
    BuffManager:AddBuff(owner, "tp_scroll_holly2", nil, {owner=owner})
end, 
function(inst, owner)
    BuffManager:ClearBuff(owner, "tp_scroll_holly2")
end, 
nil, function(inst)
    inst.components.tp_forge_weapon:SetAttrFactor("faith", .5)
    inst.components.weapon:SetRange(2,2)
    inst.components.equippable:SetSomeAttr(1, "holly", 3)
    inst.components.tp_exist_time:SetTime(50)
end)
table.insert(prefs, scroll_holly_sword)
Util:AddString(scroll_holly_sword.name, "光之守护剑", "装备时会提升物理抗性和神圣抗性")

return unpack(prefs)