local Util = require "extension.lib.wg_util"
local BuffManager = Sample.BuffManager
local AssetMaster = Sample.AssetMaster

--[[
创建植物种子  
(Prefab) 返回这个Prefab  
name (string)名字  
eat_fn (func)食用函数  
fn (func)定制函数  
no_eat (boolean)是否不能食用  
]]
local function MakePotion(name, eat_fn, fn, no_eat)
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

        if not no_eat then
            inst:AddComponent("edible")
            -- inst.components.edible.foodtype = "RAW"
            inst.components.edible.healthvalue = 0
            inst.components.edible.hungervalue = 0
            inst.components.edible.sanityvalue = 0
            inst.components.edible:SetOnEatenFn(eat_fn)
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = 40

        if fn then
            fn(inst)
        end

        return inst
    end, AssetMaster:GetDSAssets(name))
end

local PotionRecoverConst = {30, 50}
local prefs = {
-- 恢复道具
MakePotion("tp_potion_health", function(inst, eater)
    if eater.components.health then
        -- local max = eater.components.health:GetMaxHealth()
        local dt = PotionRecoverConst[1]
        eater.components.health:DoDelta(dt)
    end
end),
MakePotion("tp_potion_mana", function(inst, eater)
    if eater.components.tp_mana then
        -- local max = eater.components.tp_mana:GetMax()
        local dt = PotionRecoverConst[2]
        eater.components.tp_mana:DoDelta(dt)
    end
end),
MakePotion("tp_potion_brave", function(inst, eater)
    local cmp = eater.components.wg_buff
    if cmp then
        if cmp:HasBuff("curse") then
            if cmp.stacks["curse"] > 5 then
                BuffManager:AddBuff(eater, "curse", nil, -5)
            else
                BuffManager:ClearBuff(eater, "curse")
            end
        end
    end
end),
-- 强化
MakePotion("tp_potion_vigor", function(inst, eater)
    BuffManager:AddBuff(eater, "tp_potion_vigor")
end),
MakePotion("tp_potion_warth", function(inst, eater)
    BuffManager:AddBuff(eater, "tp_potion_warth")
end),
MakePotion("tp_potion_defense", function(inst, eater)
    BuffManager:AddBuff(eater, "tp_potion_defense")
end),
-- 武器附魔
MakePotion("tp_potion_fire_atk", nil, function(inst)
    inst:AddComponent("tp_smear_item")
    inst.components.tp_smear_item.id = "fire_weapon"
end, true),
MakePotion("tp_potion_ice_atk", nil, function(inst)
    inst:AddComponent("tp_smear_item")
    inst.components.tp_smear_item.id = "ice_weapon"
end, true),
MakePotion("tp_potion_electric_atk", nil, function(inst)
    inst:AddComponent("tp_smear_item")
    inst.components.tp_smear_item.id = "electric_weapon"
end, true),
MakePotion("tp_potion_shadow_atk", nil, function(inst)
    inst:AddComponent("tp_smear_item")
    inst.components.tp_smear_item.id = "shadow_weapon"
end, true),
MakePotion("tp_potion_poison_atk", nil, function(inst)
    inst:AddComponent("tp_smear_item")
    inst.components.tp_smear_item.id = "poison_weapon"
end, true),
MakePotion("tp_potion_blood_atk", nil, function(inst)
    inst:AddComponent("tp_smear_item")
    inst.components.tp_smear_item.id = "blood_weapon"
end, true),
}

Util:AddString("tp_potion_health", "生命药剂", 
    string.format("回复%d生命值", PotionRecoverConst[1]))
Util:AddString("tp_potion_mana", "魔法药剂", 
    string.format("回复%d的魔法值", PotionRecoverConst[2]))
Util:AddString("tp_potion_brave", "镇静药剂", "降低诅咒")
local buff = BuffManager:GetDataById("tp_potion_vigor")
Util:AddString("tp_potion_vigor", "活力药剂", buff:desc())
local buff = BuffManager:GetDataById("tp_potion_warth")
Util:AddString("tp_potion_warth", "暴怒药剂", buff:desc())
local buff = BuffManager:GetDataById("tp_potion_defense")
Util:AddString("tp_potion_defense", "防护药剂", buff:desc())
Util:AddString("tp_potion_fire_atk", "火刀药剂", "涂抹武器以使其额外造成火属性伤害")
Util:AddString("tp_potion_ice_atk", "冰刀药剂", "涂抹武器以使其额外造成冰属性伤害")
Util:AddString("tp_potion_electric_atk", "雷刀药剂", "涂抹武器以使其额外造成雷属性伤害")
Util:AddString("tp_potion_shadow_atk", "暗刀药剂", "涂抹武器以使其额外造成暗属性伤害")
Util:AddString("tp_potion_poison_atk", "毒刀药剂", "涂抹武器以使其额外造成毒属性伤害")
Util:AddString("tp_potion_blood_atk", "血刀药剂", "涂抹武器以使其额外造成血属性伤害")

return unpack(prefs)