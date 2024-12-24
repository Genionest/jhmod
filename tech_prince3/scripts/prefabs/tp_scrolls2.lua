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
local EquipSkillManager = Sample.EquipSkillManager
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
        local data = EquipSkillManager:GetDataById(name, "scroll")
        local str, desc
        local n = string.find(data.desc, ":")
        if n then
            str = string.sub(data.desc, 1, n-1)
            desc = string.sub(data.desc, n+1)
        end
        Util:AddString(name, str, desc)
        ScrollLibrary:Add(scroll.name, v)
    end
end

ScrollLibrary:Submit()

return unpack(prefs)