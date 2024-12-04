local Util = require "extension.lib.wg_util"
local AssetUtil = require "extension/lib/asset_util"
local PrefabUtil = require "extension/lib/prefab_util"
local EntUtil = require "extension/lib/ent_util"
local AssetMaster = Sample.AssetMaster
local BuffManager = Sample.BuffManager
local EnchantmentManager = Sample.EnchantmentManager
local FxManager = Sample.FxManager

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
    end, AssetMaster:GetDSAssets(name))
    table.insert(prefs, item)
    Util:AddString(item.name, str, desc)
end

MakeOrnament("ak_ornament_boss_antlion", nil, "", "")
MakeOrnament("ak_ornament_boss_bearger", nil, "", "")
MakeOrnament("ak_ornament_boss_beequeen", nil, "", "")
MakeOrnament("ak_ornament_boss_celestialchampion1", nil, "", "")
MakeOrnament("ak_ornament_boss_celestialchampion2", nil, "", "")
MakeOrnament("ak_ornament_boss_celestialchampion3", nil, "", "")
MakeOrnament("ak_ornament_boss_celestialchampion4", nil, "", "")
MakeOrnament("ak_ornament_boss_crabking", nil, "", "")
MakeOrnament("ak_ornament_boss_crabkingpearl", nil, "", "")
MakeOrnament("ak_ornament_boss_deerclops", nil, "", "")
MakeOrnament("ak_ornament_boss_dragonfly", nil, "", "")
MakeOrnament("ak_ornament_boss_eyeofterror1", nil, "", "")
MakeOrnament("ak_ornament_boss_eyeofterror2", nil, "", "")
MakeOrnament("ak_ornament_boss_fuelweaver", nil, "", "")
MakeOrnament("ak_ornament_boss_hermithouse", nil, "", "")
MakeOrnament("ak_ornament_boss_klaus", nil, "", "")
MakeOrnament("ak_ornament_boss_krampus", nil, "", "")
MakeOrnament("ak_ornament_boss_malbatross", nil, "", "")
MakeOrnament("ak_ornament_boss_minotaur", nil, "", "")
MakeOrnament("ak_ornament_boss_moose", nil, "", "")
MakeOrnament("ak_ornament_boss_noeyeblue", nil, "", "")
MakeOrnament("ak_ornament_boss_noeyered", nil, "", "")
MakeOrnament("ak_ornament_boss_pearl", nil, "", "")
MakeOrnament("ak_ornament_boss_toadstool", nil, "", "")
MakeOrnament("ak_ornament_boss_toadstool_misery", nil, "", "")
MakeOrnament("ak_ornament_boss_wagstaff", nil, "", "")
MakeOrnament("ak_ornament_fancy1", nil, "", "")
MakeOrnament("ak_ornament_fancy2", nil, "", "")
MakeOrnament("ak_ornament_fancy3", nil, "", "")
MakeOrnament("ak_ornament_fancy4", nil, "", "")
MakeOrnament("ak_ornament_fancy5", nil, "", "")
MakeOrnament("ak_ornament_fancy6", nil, "", "")
MakeOrnament("ak_ornament_fancy7", nil, "", "")
MakeOrnament("ak_ornament_fancy8", nil, "", "")
MakeOrnament("ak_ornament_festivalevents1", nil, "", "")
MakeOrnament("ak_ornament_festivalevents2", nil, "", "")
MakeOrnament("ak_ornament_festivalevents3", nil, "", "")
MakeOrnament("ak_ornament_festivalevents4", nil, "护身符", "")
MakeOrnament("ak_ornament_festivalevents5", nil, "", "")
MakeOrnament("ak_ornament_light1", nil, "", "")
MakeOrnament("ak_ornament_light2", nil, "", "")
MakeOrnament("ak_ornament_light3", nil, "", "")
MakeOrnament("ak_ornament_light4", nil, "", "")
MakeOrnament("ak_ornament_light5", nil, "", "")
MakeOrnament("ak_ornament_light6", nil, "", "")
MakeOrnament("ak_ornament_light7", nil, "", "")
MakeOrnament("ak_ornament_light8", nil, "", "")
MakeOrnament("ak_ornament_plain1", nil, "", "")
MakeOrnament("ak_ornament_plain2", nil, "", "")
MakeOrnament("ak_ornament_plain3", nil, "", "")
-- local OrnamentPlain1Const = {4500, 3}
-- MakeOrnament("ak_ornament_plain1", 
-- function(inst)
--     inst.components.inventoryitem:SetOnPutInInventoryFn(function(inst, owner)
--         if owner:HasTag("chester") then
--             owner.components.health:WgAddMaxHealthModifier(inst.prefab, OrnamentPlain1Const[1], true)
--             owner.components.health:AddRecoverRateMod(inst.prefab, OrnamentPlain1Const[2])
--         end
--     end)
--     inst.components.inventoryitem:SetOnRemovedFn(function(inst, owner)
--         if owner:HasTag("chester") then
--             owner.components.health:WgRemoveMaxHealthModifier(inst.prefab, true)
--             owner.components.health:RmRecoverRateMod(inst.prefab)
--         end
--     end)
-- end, "切斯特心之果", string.format("放入切斯特等容器生物中，令其提升%d生命上限，生命回复效果提升%d%%", 
-- OrnamentPlain1Const[1], OrnamentPlain1Const[2]*100))
-- local OrnamentPlain2Const = {3000, 7.5}
-- MakeOrnament("ak_ornament_plain2", 
-- function(inst)
--     inst.components.inventoryitem:SetOnPutInInventoryFn(function(inst, owner)
--         if owner:HasTag("chester") then
--             owner.components.health:WgAddMaxHealthModifier(inst.prefab, OrnamentPlain1Const[1], true)
--             owner.components.health:AddRecoverRateMod(inst.prefab, OrnamentPlain1Const[2])
--         end
--     end)
--     inst.components.inventoryitem:SetOnRemovedFn(function(inst, owner)
--         if owner:HasTag("chester") then
--             owner.components.health:WgRemoveMaxHealthModifier(inst.prefab, true)
--             owner.components.health:RmRecoverRateMod(inst.prefab)
--         end
--     end)
-- end, "切斯特愈之果", string.format("放入切斯特等容器生物中，令其提升%d生命上限，提升%d%%生命回复收益", 
-- OrnamentPlain2Const[1], OrnamentPlain2Const[2]*100))
-- local OrnamentPlain3Const = {3000, 2.5}
-- MakeOrnament("ak_ornament_plain3", 
-- function(inst)
--     inst.components.inventoryitem:SetOnPutInInventoryFn(function(inst, owner)
--         if owner:HasTag("chester") then
--             owner.components.health:WgAddMaxHealthModifier(inst.prefab, OrnamentPlain3Const[1], true)
--             owner.components.health:AddRecoverRateMod(inst.prefab, OrnamentPlain3Const[2])
--             if inst.fx == nil then
--                 -- inst.fx = FxManager:MakeFx("city_lamp", Vector3(0,0,0))
--                 -- owner:AddChild(inst.fx)
--             end
--             if inst.fx2 == nil then
--                 inst.fx2 = FxManager:MakeFx("city_lamp", Vector3(0,0,0))
--                 local leader = owner.components.follower.leader
--                 if leader then
--                     leader:AddChild(inst.fx2)
--                 end
--             end
--         end
--     end)
--     inst.components.inventoryitem:SetOnRemovedFn(function(inst, owner)
--         if owner:HasTag("chester") then
--             owner.components.health:WgRemoveMaxHealthModifier(inst.prefab, true)
--             owner.components.health:RmRecoverRateMod(inst.prefab)
--             if inst.fx then
--                 inst.fx:WgRecycle()
--                 inst.fx = nil
--             end
--             if inst.fx2 then
--                 inst.fx2:WgRecycle()
--                 inst.fx2 = nil
--             end
--         end
--     end)
-- end, "切斯特眼之果", string.format("放入切斯特等容器生物中，令其提升%d生命上限，生命回复效果提升%d%%，并令眼骨发光", 
-- OrnamentPlain3Const[1], OrnamentPlain3Const[2]*100))
MakeOrnament("ak_ornament_plain4", nil, "", "")
MakeOrnament("ak_ornament_plain5", nil, "", "")
MakeOrnament("ak_ornament_plain6", nil, "", "")
MakeOrnament("ak_ornament_plain7", nil, "", "")
MakeOrnament("ak_ornament_plain8", nil, "", "")
MakeOrnament("ak_ornament_plain9", nil, "", "")
-- local OrnamentPlain9Const = {2500, 2, .55, 30}
-- MakeOrnament("ak_ornament_plain9", 
-- function(inst)
--     inst.components.inventoryitem:SetOnPutInInventoryFn(function(inst, owner)
--         if owner:HasTag("chester") then
--             owner.components.health:WgAddMaxHealthModifier(inst.prefab, OrnamentPlain9Const[1], true)
--             owner.components.health:AddRecoverRateMod(inst.prefab, OrnamentPlain9Const[2])
--             owner.components.combat:AddDefenseMod(inst.prefab, OrnamentPlain9Const[3])            
--             inst.event_fn = EntUtil:listen_for_event(inst, 
--                 "attacked", function(owner, data)
--                     if EntUtil:can_thorns(data) then
--                         EntUtil:get_attacked(data.attacker, owner, 
--                             OrnamentPlain9Const[4], nil, 
--                             EntUtil:add_stimuli(nil, "thorns"))
--                     end
--                 end, owner
--             )
--         end
--     end)
--     inst.components.inventoryitem:SetOnRemovedFn(function(inst, owner)
--         if owner:HasTag("chester") then
--             owner.components.health:WgRemoveMaxHealthModifier(inst.prefab, true)
--             owner.components.health:RmRecoverRateMod(inst.prefab)
--             owner.components.combat:RmDefenseMod(inst.prefab)
--             if inst.event_fn then
--                 inst:RemoveEventCallback("attacked", inst.event_fn, owner)
--                 inst.event_fn = nil
--             end
--         end
--     end)
-- end, "切斯特角之果", string.format("放入切斯特等容器生物中，令其提升%d生命上限，生命回复效果提升%d%%，防御提升%d%%，受到攻击反伤%d", 
-- OrnamentPlain9Const[1], OrnamentPlain9Const[2]*100, OrnamentPlain9Const[3]*100, OrnamentPlain9Const[4]))
MakeOrnament("ak_ornament_plain10", nil, "", "")
MakeOrnament("ak_ornament_plain11", nil, "", "")
MakeOrnament("ak_ornament_plain12", nil, "", "")


return unpack(prefs)