local Util = require "extension.lib.wg_util"
local AssetUtil = require "extension/lib/asset_util"
local PrefabUtil = require "extension/lib/prefab_util"
local EntUtil = require "extension/lib/ent_util"
local AssetMaster = Sample.AssetMaster
local BuffManager = Sample.BuffManager
local EnchantmentManager = Sample.EnchantmentManager
local FxManager = Sample.FxManager
local OrnamentManager = Sample.OrnamentManager

local prefs = {}

-- 需要在extension.datas.ornaments文件里创建饰品的效果
--[[
创建饰品预制物  
(Prefab) 返回这个预制物  
name (string)名字  
fn (func)定制函数  
str (string)中文名字  
desc (string)描述
]]
local function MakeOrnament(name, fn, str, desc)
    local item = Prefab("common/inventory/"..name, function()
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
        
        if fn then
            fn(inst)
        end

        return inst
    end, nil)
    table.insert(prefs, item)
    if str == nil then
        local data = OrnamentManager:GetDataById(name)
        str = data:GetName()
    end
    if desc == nil then
        local data = OrnamentManager:GetDataById(name)
        desc = data:GetDescription()
    end
    Util:AddString(item.name, str, desc)
end
local function common(inst)
    inst:AddComponent("wg_useable")
    inst.components.wg_useable.test = function(inst, doer) 
        if doer.components.tp_ornament:Test(inst.prefab) then
            return true
        end
    end
    inst.components.wg_useable.use = function(inst, doer) 
        doer.components.tp_ornament:TakeOrnament(inst.prefab)
        doer.components.tp_ornament:EffectOrnament(inst.prefab)
        inst:Remove()
    end
end

-- MakeOrnament("ak_ornament_boss_antlion", common)
-- MakeOrnament("ak_ornament_boss_bearger", common)
-- MakeOrnament("ak_ornament_boss_beequeen", common)
-- MakeOrnament("ak_ornament_boss_celestialchampion1", common)
-- MakeOrnament("ak_ornament_boss_celestialchampion2", common)
-- MakeOrnament("ak_ornament_boss_celestialchampion3", common)
-- MakeOrnament("ak_ornament_boss_celestialchampion4", common)
-- MakeOrnament("ak_ornament_boss_crabking", common)
-- MakeOrnament("ak_ornament_boss_crabkingpearl", common)
-- MakeOrnament("ak_ornament_boss_deerclops", common)
-- MakeOrnament("ak_ornament_boss_dragonfly", common)
-- MakeOrnament("ak_ornament_boss_eyeofterror1", common)
-- MakeOrnament("ak_ornament_boss_eyeofterror2", common)
-- MakeOrnament("ak_ornament_boss_fuelweaver", common)
-- MakeOrnament("ak_ornament_boss_hermithouse", common)
-- MakeOrnament("ak_ornament_boss_klaus", common)
-- MakeOrnament("ak_ornament_boss_krampus", common)
-- MakeOrnament("ak_ornament_boss_malbatross", common)
-- MakeOrnament("ak_ornament_boss_minotaur", common)
-- MakeOrnament("ak_ornament_boss_moose", common)
-- MakeOrnament("ak_ornament_boss_noeyeblue", common)
-- MakeOrnament("ak_ornament_boss_noeyered", common)
-- MakeOrnament("ak_ornament_boss_pearl", common)
-- MakeOrnament("ak_ornament_boss_toadstool", common)
-- MakeOrnament("ak_ornament_boss_toadstool_misery", common)
-- MakeOrnament("ak_ornament_boss_wagstaff", common)
MakeOrnament("ak_ornament_fancy1", common)
MakeOrnament("ak_ornament_fancy2", common)
MakeOrnament("ak_ornament_fancy3", common)
MakeOrnament("ak_ornament_fancy4", common)
MakeOrnament("ak_ornament_fancy5", common)
MakeOrnament("ak_ornament_fancy6", common)
-- MakeOrnament("ak_ornament_fancy7", common)
-- MakeOrnament("ak_ornament_fancy8", common)
-- MakeOrnament("ak_ornament_festivalevents1", common)
MakeOrnament("ak_ornament_festivalevents2", common)
MakeOrnament("ak_ornament_festivalevents3", common)
MakeOrnament("ak_ornament_festivalevents4", common)
-- MakeOrnament("ak_ornament_festivalevents5", common)
MakeOrnament("ak_ornament_light1", common)
MakeOrnament("ak_ornament_light2", common)
MakeOrnament("ak_ornament_light3", common)
MakeOrnament("ak_ornament_light4", common)
MakeOrnament("ak_ornament_light5", common)
MakeOrnament("ak_ornament_light6", common)
MakeOrnament("ak_ornament_light7", common)
MakeOrnament("ak_ornament_light8", common)
MakeOrnament("ak_ornament_plain1", common)
MakeOrnament("ak_ornament_plain2", common)
MakeOrnament("ak_ornament_plain3", common)
MakeOrnament("ak_ornament_plain4", common)
MakeOrnament("ak_ornament_plain5", common)
MakeOrnament("ak_ornament_plain6", common)
MakeOrnament("ak_ornament_plain7", common)
MakeOrnament("ak_ornament_plain8", common)
MakeOrnament("ak_ornament_plain9", common)
MakeOrnament("ak_ornament_plain10", common)
MakeOrnament("ak_ornament_plain11", common)
MakeOrnament("ak_ornament_plain12", common)


return unpack(prefs)