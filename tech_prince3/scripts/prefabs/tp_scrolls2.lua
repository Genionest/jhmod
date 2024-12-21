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
local ScrollLibrary = Sample.ScrollLibrary

ScrollLibrary:MakeTempTable()

local prefs = {}

local SCROLL_SMALL_MANA1 = 5
local SCROLL_SMALL_MANA2 = 10
local SCROLL_SMALL_MANA3 = 15
local SCROLL_MED_MANA1 = 20
local SCROLL_MED_MANA2 = 25
local SCROLL_LARGE_MANA = 40
local SCROLL_MANA_LIST = {
    _bean = SCROLL_SMALL_MANA1,
    _arrow = SCROLL_SMALL_MANA2,
    _bolt = SCROLL_SMALL_MANA3,
    ["1"] = SCROLL_MED_MANA1,
    ["2"] = SCROLL_MED_MANA2,
    ["3"] = SCROLL_LARGE_MANA,
}

--[[
创建卷轴预制物  
(Prefab) 返回预制物  
name (string)名字  
equip (func)装备时触发函数  
unequip (func)卸下时触发函数  
fn (func)自定以函数，可以为nil  
]]
local function MakeScroll(name, equip, unequip, fn)
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
        
        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
        inst.components.equippable:SetOnEquip(equip)
        inst.components.equippable:SetOnUnequip(unequip)
        inst.components.equippable.symbol = name
        inst.components.equippable.equipstack = true
    
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = 40

        if fn then
            fn(inst)
        end

        return inst
    end, nil)
end

--[[
创建武器卷轴预制物  
需要自己写施法消耗,施法效果  
(Prefab) 返回预制物  
name (string)名字  
fn (func)自定以函数，可以为nil  
]]
local function MakeScrollWeapon(name, fn)
    return MakeScroll(name, nil, nil, function(inst)
        inst:AddComponent("wg_action_tool")
        inst.components.wg_action_tool:SetSkillId(name)
        if fn then
            fn(inst)
        end
    end)
end

local scroll_template = MakeScroll("tp_scroll_template", nil, nil, function(inst)
    -- inst:AddComponent("wg_action_tool")
    -- inst.components.wg_action_tool:SetSkillId("")
    -- inst.components.wg_action_tool:RegisterSkillInfo({
    --     mana = 10,
    --     vigor = 1,
    --     -- cd = 10,
    -- })
end)
PrefabUtil:SetPrefabAssets(scroll_template, AssetMaster:GetDSAssets(scroll_template.name))
table.insert(prefs, scroll_template)
Util:AddString(scroll_template.name, "《模板》", "这是一个模板")

local scroll_hollow = MakeScrollWeapon("tp_scroll_hollow", function(inst)
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = 100,
        vigor = 2,
        -- cd = 10,
    })
    local GetRequire = inst.components.wg_action_tool.GetRequire
    function inst.components.wg_action_tool:GetRequire(attr, doer)
        local val = GetRequire(self, attr, doer)
        if attr == "mana" and doer:HasTag("hollow_evade") then
            val = val * .2
        end
        return val
    end
end)
table.insert(prefs, scroll_hollow)
Util:AddString(scroll_hollow.name, "《顺时针法术·苍蓝》", "发射一个能量球,飞行一段距离后会停止,能量球会造成伤害,停止后造成的伤害更高;与赫碰撞会发生大爆炸")
ScrollLibrary:Add(scroll_hollow.name, "electric")

local scroll_hollow2 = MakeScrollWeapon("tp_scroll_hollow2", function(inst)
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = 100,
        vigor = 2,
        -- cd = 10,
    })
    local GetRequire = inst.components.wg_action_tool.GetRequire
    function inst.components.wg_action_tool:GetRequire(attr, doer)
        local val = GetRequire(self, attr, doer)
        if attr == "mana" and doer:HasTag("hollow_evade") then
            val = val * .2
        end
        return val
    end
end)
table.insert(prefs, scroll_hollow2)
Util:AddString(scroll_hollow2.name, "《逆时针法术·红赫》", "发射一个能量球,飞行一段距离后会停止,能量球会造成伤害,飞行时造成的伤害更高;与苍碰撞会发生大爆炸")
ScrollLibrary:Add(scroll_hollow2.name, "electric")

local scroll_hollow3 = MakeScrollWeapon("tp_scroll_hollow3", function(inst)
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = 80,
        vigor = 2,
        -- cd = 8,
    })
    local GetRequire = inst.components.wg_action_tool.GetRequire
    function inst.components.wg_action_tool:GetRequire(attr, doer)
        local val = GetRequire(self, attr, doer)
        if attr == "mana" and doer:HasTag("hollow_evade") then
            val = val * .2
        end
        return val
    end
end)
table.insert(prefs, scroll_hollow3)
Util:AddString(scroll_hollow3.name, "《反转有下限法术》", "回复六目能量")
ScrollLibrary:Add(scroll_hollow3.name, "electric")

-- 基础的三个法术
for elem, data in pairs({
    fire = {
        name = "火焰",
        dmg = {40, 60, 90},
        factor = {
            {faith=.2, strengthen=.1},
            {faith=.3, strengthen=.1},
            {faith=.4, strengthen=.1},
        },
    },
    ice = {
        name = "寒冰",
        dmg = {30, 45, 70},
        factor = {
            {intelligence=.25},
            {intelligence=.35},
            {intelligence=.45},
        },
    },
    shadow = {
        name = "暗影",
        dmg = {20, 35, 55},
        factor = {
            {intelligence=.2, faith=.1},
            {intelligence=.3, faith=.1},
            {intelligence=.3, faith=.2},
        },
    },
    wind = {
        name = "风暴",
        dmg = {30, 45, 60},
        factor = {
            {intelligence=.2, agility=.1},
            {intelligence=.3, agility=.1},
            {intelligence=.4, agility=.1},
        },
    },
    blood = {
        name = "血液",
        dmg = {40, 50, 60},
        factor = {
            {faith=.1, lucky=.2},
            {faith=.2, lucky=.2},
            {faith=.3, lucky=.2},
        },
    },
    poison = {
        name = "毒素",
        dmg = {30, 40, 50},
        factor = {
            {intelligence=.1, strengthen=.2},
            {intelligence=.2, strengthen=.2},
            {intelligence=.3, strengthen=.2},
        },
    },
    electric = {
        name = "雷电",
        dmg = {30, 50, 70},
        factor = {
            {faith=.2, intelligence=.1},
            {faith=.3, intelligence=.1},
            {faith=.4, intelligence=.1},
        },
    },
    holly = {
        name = "神圣",
        dmg = {10, 20, 30},
        factor = {
            {faith=.3, },
            {faith=.4, },
            {faith=.5, },
        },
    }
}) do
    local elemName = data.name
    local magicCircle = elem.."_magic"
    local beanName = elem.."_bean"
    local arrowName = elem.."_arrow"
    local ballName = elem.."_ball"
    local beanDmg, arrowDmg, ballDmg = unpack(data.dmg)
    local scroll_bean = MakeScroll(string.format("tp_scroll_%s_bean", elem), nil, nil,
    function(inst)
        inst:AddComponent("tp_forge_scroll")
        for attr, factor in pairs(data.factor[1]) do
            inst.components.tp_forge_scroll:SetAttrFactor(attr, factor)
        end
        inst:AddComponent("wg_recharge")
        inst:AddComponent("wg_reticule")
        inst:AddComponent("wg_action_tool")
        inst:AddTag("wg_equip_skill")
        inst.components.wg_action_tool:SetDescription()
        inst.components.wg_action_tool:SetSkillType()
        inst.components.wg_action_tool:RegisterSkillInfo({
            mana = 5,
            vigor = 1,
            -- cd = 3,
        })
        -- inst.components.wg_action_tool.test = function(inst, doer)
        --     --检测
        -- end
        inst.components.wg_action_tool.get_action_fn = function(inst, data)
            -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
            if data.pos or data.target then
                return ACTIONS.TP_SCROLL_WEAPON
            end
        end
        inst.components.wg_action_tool.click_no_action = true
        inst.components.wg_action_tool.click_fn = function(inst, doer)
            -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
            inst.components.wg_reticule:Toggle()
        end
        inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
            -- 动作触发时会到达的效果
            FxManager:MakeFx(magicCircle, doer)
            doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
            if target then
                pos = target:GetPosition()
            end
            local damage = beanDmg + inst.components.tp_forge_scroll:GetAttrIncome()
            local fx = FxManager:MakeFx(beanName, doer, {pos=pos,owner=doer,damage=damage})
        end
    end)
    table.insert(prefs, scroll_bean)
    local scroll_arrow = MakeScroll(string.format("tp_scroll_%s_arrow", elem), nil, nil,
    function(inst)
        inst:AddComponent("tp_forge_scroll")
        for attr, factor in pairs(data.factor[2]) do
            inst.components.tp_forge_scroll:SetAttrFactor(attr, factor)
        end
        inst:AddComponent("wg_reticule")
        inst:AddComponent("wg_action_tool")
        inst:AddTag("wg_equip_skill")
        inst.components.wg_action_tool:SetDescription()
        inst.components.wg_action_tool:SetSkillType()
        inst.components.wg_action_tool:RegisterSkillInfo({
            mana = 10,
            vigor = 1,
            -- cd = 3,
        })
        -- inst.components.wg_action_tool.test = function(inst, doer)
        --     --检测
        -- end
        inst.components.wg_action_tool.get_action_fn = function(inst, data)
            -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
            if data.pos or data.target then
                return ACTIONS.TP_SCROLL_WEAPON
            end
        end
        inst.components.wg_action_tool.click_no_action = true
        inst.components.wg_action_tool.click_fn = function(inst, doer)
            -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
            inst.components.wg_reticule:Toggle()
        end
        inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
            -- 动作触发时会到达的效果
            FxManager:MakeFx(magicCircle, doer)
            doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
            if target then
                pos = target:GetPosition()
            end
            local damage = arrowDmg + inst.components.tp_forge_scroll:GetAttrIncome()
            local fx = FxManager:MakeFx(arrowName, doer, {pos=pos,owner=doer,damage=damage})
        end
    end)
    table.insert(prefs, scroll_arrow)
    local scroll_ball = MakeScroll(string.format("tp_scroll_%s_ball", elem), nil, nil,
    function(inst)
        inst:AddComponent("tp_forge_scroll")
        for attr, factor in pairs(data.factor[3]) do
            inst.components.tp_forge_scroll:SetAttrFactor(attr, factor)
        end
        inst:AddComponent("wg_recharge")
        inst:AddComponent("wg_reticule")
        inst:AddComponent("wg_action_tool")
        inst:AddTag("wg_equip_skill")
        inst.components.wg_action_tool:SetDescription()
        inst.components.wg_action_tool:SetSkillType()
        inst.components.wg_action_tool:RegisterSkillInfo({
            mana = 15,
            vigor = 1,
            -- cd = 3,
        })
        -- inst.components.wg_action_tool.test = function(inst, doer)
        --     --检测
        -- end
        inst.components.wg_action_tool.get_action_fn = function(inst, data)
            -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
            if data.pos or data.target then
                return ACTIONS.TP_SCROLL_WEAPON
            end
        end
        inst.components.wg_action_tool.click_no_action = true
        inst.components.wg_action_tool.click_fn = function(inst, doer)
            -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
            inst.components.wg_reticule:Toggle()
        end
        inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
            -- 动作触发时会到达的效果
            FxManager:MakeFx(magicCircle, doer)
            doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
            if target then
                pos = target:GetPosition()
            end
            local damage = ballDmg + inst.components.tp_forge_scroll:GetAttrIncome()
            local fx = FxManager:MakeFx(ballName, doer, {pos=pos,owner=doer,damage=damage})
        end
    end)
    table.insert(prefs, scroll_ball)
    Util:AddString(scroll_bean.name, string.format("《%s拳》", elemName), 
        string.format("发射%s拳", elemName))
    Util:AddString(scroll_arrow.name, string.format("《%s箭》", elemName), 
        string.format("发射%s箭", elemName))
    Util:AddString(scroll_ball.name, string.format("《%s波》", elemName), 
        string.format("发射%s波", elemName))
    ScrollLibrary:Add(scroll_bean.name, elem)
    ScrollLibrary:Add(scroll_arrow.name, elem)
    ScrollLibrary:Add(scroll_ball.name, elem)
end

local scroll_fire1 = MakeScroll("tp_scroll_fire1", nil, nil, function(inst)
    inst:AddComponent("tp_forge_scroll")
    inst.components.tp_forge_scroll:SetAttrFactor("faith", .5)
    inst.components.tp_forge_scroll:SetAttrFactor("strengthen", .1)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA1,
        vigor = 1,
        -- cd = 5,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_SCROLL_WEAPON
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("fire_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 150 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("fire_pulse", doer, {pos=pos,owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_fire1)
Util:AddString(scroll_fire1.name, "《火焰脉冲》", "发射火焰脉冲对路径上的敌人造成伤害")
ScrollLibrary:Add(scroll_fire1.name, "fire")

local scroll_fire2 = MakeScroll("tp_scroll_fire2", nil, nil, function(inst)
    inst:AddComponent("tp_forge_scroll")
    inst.components.tp_forge_scroll:SetAttrFactor("faith", .6)
    inst.components.tp_forge_scroll:SetAttrFactor("strengthen", .1)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst.components.wg_reticule.reticule_prefab = "wg_reticulearc"
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA2,
        vigor = 1,
        -- cd = 5,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_SCROLL_WEAPON
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("fire_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 150 + inst.components.tp_forge_scroll:GetAttrIncome()
        local angle = doer.Transform:GetRotation()
        local friends = {}
        for i = -1, 1 do
            local rot = angle + 30*i
            local fx = FxManager:MakeFx("fire_pulse", doer, {angle=rot,owner=doer,damage=damage})
            table.insert(friends, fx)
            fx.friends = friends
        end
    end
end)
table.insert(prefs, scroll_fire2)
Util:AddString(scroll_fire2.name, "《火焰三尖枪》", "发射3道火焰脉冲对路径上的敌人造成伤害")
ScrollLibrary:Add(scroll_fire2.name, "fire")

local scroll_fire3 = MakeScroll("tp_scroll_fire3", nil, nil, 
function(inst)
    inst:AddComponent("tp_forge_scroll")
    inst.components.tp_forge_scroll:SetAttrFactor("faith", 1.5)
    inst.components.tp_forge_scroll:SetAttrFactor("strengthen", .2)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst.components.wg_reticule.reticule_prefab = "wg_reticulearc"
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_LARGE_MANA,
        vigor = 1,
        -- cd = 10,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_SCROLL_WEAPON
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("fire_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        if target then
            pos = target:GetPosition()
        end
        local damage = 300 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("solar_pieces", doer, {pos=pos,owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_fire3)
Util:AddString(scroll_fire3.name, "《太阳碎片》", "朝着目标方向引爆能量造成大范围伤害")
ScrollLibrary:Add(scroll_fire3.name, "fire")

local scroll_ice1 = MakeScroll("tp_scroll_ice1", nil, nil, function(inst)
    inst:AddComponent("tp_forge_scroll")
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", .45)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA1,
        vigor = 1,
        -- cd = 3,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_SCROLL_WEAPON
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("ice_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 85 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("ice_super_ball", doer, {pos=pos,owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_ice1)
Util:AddString(scroll_ice1.name, "《寒冰散华》", "发射一个超级寒冰波,超级寒冰波会不断发射寒冰拳或寒冰箭")
ScrollLibrary:Add(scroll_ice1.name, "ice")

local scroll_ice2 = MakeScroll("tp_scroll_ice2", nil, nil, function(inst)
    inst:AddComponent("tp_forge_scroll")
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", .6)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA2,
        vigor = 1,
        -- cd = 3,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        return ACTIONS.TP_SCROLL_WEAPON
    end
    -- inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.no_catch_action = true
    inst.components.wg_action_tool:SetDefaultClickFn()
    -- inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
    -- end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("ice_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 120 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("ice_flower", doer, {pos=pos,owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_ice2)
Util:AddString(scroll_ice2.name, "《寒冰新星》", "朝周围释放冰柱,造成伤害并冰冻周围敌人")
ScrollLibrary:Add(scroll_ice2.name, "ice")

local scroll_ice3 = MakeScroll("tp_scroll_ice3", nil, nil, function(inst)
    inst:AddComponent("tp_forge_scroll")
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", 1.3)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst.components.wg_reticule.reticule_prefab = "wg_reticule_range"
    inst.components.wg_reticule.reticule_fn = function(fx)
        fx.Transform:SetScale(1.2, 1.2, 1.2)
    end
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_LARGE_MANA,
        vigor = 1,
        -- cd = 3,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_SCROLL_WEAPON
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("ice_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        if target then
            pos = target:GetPosition()
        end
        local damage = 200 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("ice_storm", pos, {pos=pos,owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_ice3)
Util:AddString(scroll_ice3.name, "《冰冻彗星》", "在指定区域召唤一阵冰冻彗星")
ScrollLibrary:Add(scroll_ice3.name, "ice")

local scroll_shadow1 = MakeScroll("tp_scroll_shadow1", nil, nil, function(inst)
    inst:AddComponent("tp_forge_scroll")
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", .3)
    inst.components.tp_forge_scroll:SetAttrFactor("faith", .2)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst.components.wg_reticule.reticule_prefab = "wg_reticuleaoesmall"
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA1,
        vigor = 1,
        -- cd = 3,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_SCROLL_WEAPON
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("shadow_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 30 + inst.components.tp_forge_scroll:GetAttrIncome()
        local rot = doer:GetAngleToPoint(pos:Get())
        for k, v in pairs({-120, -90, 90, 120}) do
            local angle = rot + v
            print(angle)
            local fx = FxManager:MakeFx("shadow_burst", doer, {pos=pos,angle=angle,owner=doer,damage=damage})
        end
    end
end)
table.insert(prefs, scroll_shadow1)
Util:AddString(scroll_shadow1.name, "《暗影迸发》", "发射多个暗影波朝目标地点移动")
ScrollLibrary:Add(scroll_shadow1.name, "shadow")

local scroll_shadow2 = MakeScroll("tp_scroll_shadow2", nil, nil, function(inst)
    inst:AddComponent("tp_forge_scroll")
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", .3)
    inst.components.tp_forge_scroll:SetAttrFactor("faith", .2)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst.components.wg_reticule.reticule_prefab = "wg_reticulearc"
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA2,
        vigor = 1,
        -- cd = 10,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_SCROLL_WEAPON
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("shadow_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 30 + inst.components.tp_forge_scroll:GetAttrIncome()
        local rot = doer.Transform:GetRotation()
        for i = 0, 11 do
            inst:DoTaskInTime(0.05 * i, function()
                local angle = rot + (i%3-1) * 15
                local fx = FxManager:MakeFx("shadow_bean", doer, {angle=angle,owner=doer,damage=damage})
            end)
        end
    end
end)
table.insert(prefs, scroll_shadow2)
Util:AddString(scroll_shadow2.name, "《暗影连射》", "发射多发暗影拳")
ScrollLibrary:Add(scroll_shadow2.name, "shadow")

local scroll_shadow3 = MakeScroll("tp_scroll_shadow3", nil, nil, function(inst)
    inst:AddComponent("tp_forge_scroll")
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", 1.2)
    inst.components.tp_forge_scroll:SetAttrFactor("faith", .8)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst.components.wg_reticule.reticule_prefab = "wg_reticulearc"
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_LARGE_MANA,
        vigor = 1,
        -- cd = 10,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_ATTACK_PROP
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("shadow_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        if target then
            pos = target:GetPosition()
        end
        local damage = 280 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("shadow_sword", doer, {owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_shadow3)
Util:AddString(scroll_shadow3.name, "《冥王之剑》", "用魔法形成挥动的巨剑攻击目标")
ScrollLibrary:Add(scroll_shadow3.name, "shadow")

local scroll_wind1 = MakeScroll("tp_scroll_wind1", nil, nil, function(inst)
    inst:AddComponent("tp_forge_scroll")
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", .2)
    inst.components.tp_forge_scroll:SetAttrFactor("agility", .1)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = 10,
        vigor = 1,
        -- cd = 3,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        return ACTIONS.TP_SCROLL_WEAPON
    end
    -- inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.no_catch_action = true
    inst.components.wg_action_tool:SetDefaultClickFn()
    -- inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
    -- end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("wind_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        local damage = 30 + inst.components.tp_forge_scroll:GetAttrIncome()
        for i = 1, 3 do
            doer:DoTaskInTime(.1*i, function()
                    local angle = i*360/3
                    local fx = FxManager:MakeFx("scroll_wind1", doer, 
                    {pos=doer:GetPosition(),owner=doer,angle=angle,damage=damage}
                )
            end)
        end
    end
end)
table.insert(prefs, scroll_wind1)
Util:AddString(scroll_wind1.name, "《巡回之风》", "召唤3个来回的旋风")
ScrollLibrary:Add(scroll_wind1.name, "wind")

local scroll_wind2 = MakeScroll("tp_scroll_wind2", nil, nil, function(inst)
    inst:AddComponent("tp_forge_scroll")
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", .6)
    inst.components.tp_forge_scroll:SetAttrFactor("agility", .1)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = 10,
        vigor = 1,
        -- cd = 3,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        return ACTIONS.TP_SCROLL_WEAPON
    end
    -- inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.no_catch_action = true
    inst.components.wg_action_tool:SetDefaultClickFn()
    -- inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
    -- end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("wind_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        local damage = 100 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("scroll_wind2", doer, 
            {pos=doer:GetPosition(),owner=doer,damage=damage}
        )
    end
end)
table.insert(prefs, scroll_wind2)
Util:AddString(scroll_wind2.name, "《林地之风》", "召唤一阵强风围绕自身旋转并造对敌人造成伤害")
ScrollLibrary:Add(scroll_wind2.name, "wind")

local scroll_wind3 = MakeScroll("tp_scroll_wind3", nil, nil, function(inst)
    inst:AddComponent("tp_forge_scroll")
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", .7)
    inst.components.tp_forge_scroll:SetAttrFactor("agility", .2)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_LARGE_MANA,
        vigor = 1,
        -- cd = 3,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_SCROLL_WEAPON
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("wind_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        if target then
            pos = target:GetPosition()
        end
        local damage = 130 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("scroll_wind3", doer, {pos=pos,owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_wind3)
Util:AddString(scroll_wind3.name, "《8级大狂风》", "召唤1个强力龙卷风,龙卷风会不断加速和变大攻击范围")
ScrollLibrary:Add(scroll_wind3.name, "wind")

local scroll_blood1 = MakeScrollWeapon("tp_scroll_blood1", true, function(inst)
    inst.components.tp_forge_scroll:SetAttrFactor("faith", .4)
    inst.components.tp_forge_scroll:SetAttrFactor("lucky", .2)
    inst.components.wg_reticule.reticule_prefab = "wg_reticule_target"
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA1,
        vigor = 1,
    })
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        if data.target and EntUtil:check_combat_target(data.doer, data.target) then
            return ACTIONS.TP_SCROLL_WEAPON
        end 
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        FxManager:MakeFx("blood_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        local damage = 30 + inst.components.tp_forge_scroll:GetAttrIncome()
        EntUtil:get_attacked(target, doer, damage, nil, 
            EntUtil:add_stimuli(nil, "blood", "magic")
        )
        BuffManager:AddBuff(target, "tp_scroll_blood1")
    end
end)
table.insert(prefs, scroll_blood1)
Util:AddString(scroll_blood1.name, "《血肉之咒》", "造成伤害并诅咒一名敌人,其受到血属性伤害时会失去生命以治疗攻击者")
ScrollLibrary:Add(scroll_blood1.name, "blood")

local scroll_blood2 = MakeScrollWeapon("tp_scroll_blood2", true, function(inst)
    inst.components.tp_forge_scroll:SetAttrFactor("faith", .4)
    inst.components.tp_forge_scroll:SetAttrFactor("lucky", .3)
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA2,
        vigor = 1,
    })
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        FxManager:MakeFx("blood_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 75 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("scroll_blood2", doer, 
            {pos=pos,owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_blood2)
Util:AddString(scroll_blood2.name, "《血之飞轮》", "发射1个会返回的飞轮,对敌人造成伤害")
ScrollLibrary:Add(scroll_blood2.name, "blood")

local scroll_blood3 = MakeScrollWeapon("tp_scroll_blood3", nil, function(inst)
    inst.components.equippable:WgAddEquipFn(function(inst, owner)
        if inst.event_fn == nil then 
            inst.event_fn = EntUtil:listen_for_event(owner, "onhitother", function(inst, data)
                if EntUtil:in_stimuli(data.stimuli, "blood")
                and EntUtil:in_stimuli(data.stimuli, "magic")
                and EntUtil:in_stimuli(data.stimuli, "scroll_blood3") then
                    if data.damage > 0 then
                        owner.components.health:DoDelta(data.damage/3, nil, "life_steal")
                    end
                end
            end)
        end
    end)
    inst.components.equippable:WgAddUnequipFn(function(inst, owner)
        if inst.event_fn then
            owner:RemoveEventCallback("onhitother", inst.event_fn)
            inst.event_fn = nil
        end
    end)
    inst.components.tp_forge_scroll:SetAttrFactor("faith", 1)
    inst.components.tp_forge_scroll:SetAttrFactor("lucky", .4)
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_LARGE_MANA,
        vigor = 1,
    })
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        FxManager:MakeFx("blood_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        local damage = 1000 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("scroll_blood3", doer, 
            {owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_blood3)
Util:AddString(scroll_blood3.name, "《鲜血征收》", "对周围的敌人造成伤害,伤害由所有受伤敌人分摊,并附带吸血效果")
ScrollLibrary:Add(scroll_blood3.name, "blood")

local scroll_poison1 = MakeScrollWeapon("tp_scroll_poison1", true, function(inst)
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", .4)
    inst.components.tp_forge_scroll:SetAttrFactor("strengthen", .2)
    inst.components.wg_reticule.reticule_prefab = "wg_reticulearc"
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA1,
        vigor = 1,
    })
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        FxManager:MakeFx("poison_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 50 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("scroll_poison1", doer, 
            {pos=pos,owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_poison1)
Util:AddString(scroll_poison1.name, "《喷洒毒雾》", "朝前方喷洒毒雾,毒雾会造成伤害并令敌人进入毒害状态")
ScrollLibrary:Add(scroll_poison1.name, "poison")

local scroll_poison2 = MakeScrollWeapon("tp_scroll_poison2", true, function(inst)
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", .5)
    inst.components.tp_forge_scroll:SetAttrFactor("strengthen", .2)
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA2,
        vigor = 1,
    })
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        FxManager:MakeFx("poison_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 100 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("scroll_poison2", doer, 
            {pos=pos,owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_poison2)
Util:AddString(scroll_poison2.name, "《剧毒箭》", "发射剧毒箭,如果带毒或中毒的目标造成更高伤害")
ScrollLibrary:Add(scroll_poison2.name, "poison")

local scroll_poison3 = MakeScrollWeapon("tp_scroll_poison3", nil, function(inst)
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", .9)
    inst.components.tp_forge_scroll:SetAttrFactor("strengthen", .5)
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_LARGE_MANA,
        vigor = 1,
    })
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        FxManager:MakeFx("poison_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        local damage = 270 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("scroll_poison3", doer, 
            {owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_poison3)
Util:AddString(scroll_poison3.name, "《毒性发作》", "对周围中毒的敌人造成伤害,并结束其中毒状态")
ScrollLibrary:Add(scroll_poison3.name, "poison")

local scroll_electric1 = MakeScrollWeapon("tp_scroll_electric1", true, function(inst)
    inst.components.tp_forge_scroll:SetAttrFactor("faith", .5)
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", .1)
    inst.components.wg_reticule.reticule_prefab = "wg_reticuleaoesmall"
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA1,
        vigor = 1,
    })
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        FxManager:MakeFx("electric_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 90 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("scroll_electric1", pos, 
            {owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_electric1)
Util:AddString(scroll_electric1.name, "《电能之柱》", "召唤一个持续造成伤害的雷柱")
ScrollLibrary:Add(scroll_electric1.name, "electric")

local scroll_electric2 = MakeScrollWeapon("tp_scroll_electric2", nil, function(inst)
    inst.components.tp_forge_scroll:SetAttrFactor("faith", .3)
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", .1)
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA2,
        vigor = 1,
    })
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        FxManager:MakeFx("electric_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        local damage = 20 + inst.components.tp_forge_scroll:GetAttrIncome()
        -- local fx = FxManager:MakeFx("scroll_electric2", doer, 
        --     {owner=doer,damage=damage})
        BuffManager:AddBuff(doer, "tp_scroll_electric2", nil, {
            owner=doer,damage=damage
        })
    end
end)
table.insert(prefs, scroll_electric2)
Util:AddString(scroll_electric2.name, "《电能环绕》", "装备后获得雷属性伤害")
ScrollLibrary:Add(scroll_electric2.name, "electric")

local scroll_electric3 = MakeScrollWeapon("tp_scroll_electric3", true, function(inst)
    inst.components.tp_forge_scroll:SetAttrFactor("faith", 1.4)
    inst.components.tp_forge_scroll:SetAttrFactor("intelligence", .4)
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_LARGE_MANA,
        vigor = 1,
    })
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        FxManager:MakeFx("electric_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        if target then
            pos = target:GetPosition()
        end
        local damage = 400 + inst.components.tp_forge_scroll:GetAttrIncome()
        local fx = FxManager:MakeFx("scroll_electric3", doer, 
            {pos=pos,owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_electric3)
Util:AddString(scroll_electric3.name, "《雷霆震荡》", "引下天雷,对敌人造成伤害")
ScrollLibrary:Add(scroll_electric3.name, "electric")

local scroll_holly1 = MakeScrollWeapon("tp_scroll_holly1", true, function(inst)
    inst.components.tp_forge_scroll:SetAttrFactor("faith", .5)
    inst.components.wg_reticule.reticule_prefab = "wg_reticule_target"
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA1,
        vigor = 1,
    })
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        if data.target then
            if EntUtil:is_alive(data.target) then
                if data.target.components.health:GetPercent() < 1 then
                    return ACTIONS.TP_SCROLL_WEAPON
                end
            end
        end
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        FxManager:MakeFx("holly_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        local damage = 50 + inst.components.tp_forge_scroll:GetAttrIncome()
        if target then
            -- print("a001", target)
            if EntUtil:is_alive(target) then
                -- print("a002")
                if target.components.health:GetPercent() < 1 then
                    -- print("a003", target.components.health:GetPercent())
                    target.components.health:DoDelta(damage, nil, "holly_magic")
                    local fx = FxManager:MakeFx("recover_fx", target)
                    return
                end
            end
        end
        doer.components.health:DoDelta(damage, nil, "holly_magic")
        local fx = FxManager:MakeFx("recover_fx", doer)
    end
end)
table.insert(prefs, scroll_holly1)
Util:AddString(scroll_holly1.name, "《圣光疗愈》", "选中一个受伤的单位,为其治疗;如果没有有效的单位,为自己治疗")
ScrollLibrary:Add(scroll_holly1.name, "holly")

local scroll_holly2 = MakeScrollWeapon("tp_scroll_holly2", nil, function(inst)
    inst.components.tp_forge_scroll:SetAttrFactor("faith", .5)
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_MED_MANA2,
        vigor = 1,
    })
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        FxManager:MakeFx("holly_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        -- local damage = 50 + inst.components.tp_forge_scroll:GetAttrIncome()
        -- target.components.health:DoDelta(damage, nil, "holly_magic")
        -- local fx = FxManager:MakeFx("recover_fx", target)
        doer.components.inventory:GiveItem(
            SpawnPrefab("tp_scroll_holly_sword"), 
            nil, 
            Vector3(TheSim:GetScreenPos(doer.Transform:GetWorldPosition()))
        )
    end
end)
table.insert(prefs, scroll_holly2)
Util:AddString(scroll_holly2.name, "《光之守护剑》", "获得一把光之守护剑")
ScrollLibrary:Add(scroll_holly2.name, "holly")

local scroll_holly3 = MakeScrollWeapon("tp_scroll_holly3", true, function(inst)
    inst.components.tp_forge_scroll:SetAttrFactor("faith", 1.5)
    inst.components.wg_reticule.reticule_prefab = "wg_reticuleaoesmall"
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = SCROLL_LARGE_MANA,
        vigor = 1,
    })
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        FxManager:MakeFx("holly_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        if target then
            pos = target:GetPosition()
        end
        local damage = 300 + inst.components.tp_forge_scroll:GetAttrIncome()
        -- damage = 10
        local fx = FxManager:MakeFx("holly_meteor", pos, 
            {owner=doer,damage=damage})
    end
end)
table.insert(prefs, scroll_holly3)
Util:AddString(scroll_holly3.name, "《神圣流星》", "召唤一个神圣流星,神圣流行爆炸后会分裂出能量束")
ScrollLibrary:Add(scroll_holly3.name, "holly")

for k, v in pairs({
	"fire", "ice", "shadow", "wind", "blood", "poison", "electric", "holly"
}) do
	for k2, v2 in pairs({
		"_bean", "_arrow", "_ball", "1", "2", "3",
	}) do
        local name = string.format("tp_scroll_%s%s", v, v2)
        local scroll = MakeScrollWeapon(name, function(inst)
            inst.components.wg_action_tool:RegisterSkillInfo({
                mana = SCROLL_MANA_LIST[v2],
                vigor = 1,
            })
        end)
        table.insert(prefs, scroll)
        ScrollLibrary:Add(scroll.name, v)
    end
end

ScrollLibrary:Submit()

return unpack(prefs)