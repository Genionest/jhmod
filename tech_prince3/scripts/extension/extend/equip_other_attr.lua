local BuffManager = Sample.BuffManager

--[[
装备重量
武器的精力值消耗
武器攻击力的属性收益
]]

-- 装备重量
local equip_weight = {
    armorwood = 2,
    armormarble = 5,
    armorslurper = 2,
    armorruins = 4,
    armordragonfly = 2,

    footballhat = 2,
    wathgrithrhat = 2,
    slurtlehat = 2,
    ruinshat = 4,
    beefalohat = 2,
    watermelonhat = 2,
    minerhat = 2,
    spiderhat = 2,
    eyebrellahat = 2,

    piggyback = 4,
    icepack = 2,
    krampus_sack = 6,

    hambat = 2,
    tentacle_spike = 2,
    ruins_bat = 4,
    multitool_axe_pickaxe = 3,

}
for k, v in pairs(equip_weight) do
    AddPrefabPostInit(k, function(inst)
        if inst.components.equippable then
            inst.components.equippable:SetEquipWeight(v)
        end
    end)
end
AddPrefabPostInit("piggyback", function(inst)
    inst.components.equippable.walkspeedmult = nil
end)
AddPrefabPostInit("armormarble", function(inst)
    inst.components.equippable.walkspeedmult = nil
end)


-- 武器的精力值消耗
local weapon_cost_vigor = {
    axe = 1,
    pickaxe = 1,
    shovel = 1,
    machete = 1,
    hammer = 1,
    spear = 1.5,
    spear_wathgrithr = 1.5,
    hambat = 3,
    nightstick = 3,
    tentacle_spike = 3,
    batbat = 3,
    boomerang = 1,
    nightsword = 2,
    ruins_bat = 5,
    blowdart_pipe = 1,
    blowdart_fire = 1,
}
for k, v in pairs(weapon_cost_vigor) do
    AddPrefabPostInit(k, function(inst)
        inst.components.weapon:SetAttackCostVigor(v)
    end)
end

-- 武器攻击力的属性收益
local weapon_attr_factor = {
    spear = {agility = .3},
    spear_wathgrithr = {agility = .3},
    hambat = {strengthen = .25},
    nightstick = {faith = .4},
    tentacle_spike = {lucky = .4},
    batbat = {faith = .4},
    nightsword = {intelligence = .4},
    ruins_bat = {strengthen = .3},
}
for k, v in pairs(weapon_attr_factor) do
    AddPrefabPostInit(k, function(inst)
        for k2, v2 in pairs(v) do 
            inst:AddComponent("tp_forge_level")
            inst.components.tp_forge_level:SetAttrFactor(k2, v2)
        end
    end)
end

-- 武器的质变属性
local weapon_forge_element = {
    batbat = "blood",
    nightstick = "electric",
}
for k, v in pairs(weapon_forge_element) do
    AddPrefabPostInit(k, function(inst)
        inst.components.tp_forge_level:SetElement(v)
    end)
end

-- 护甲锻造
local armors = {
    "armorgrass",
    "armorwood",
    "footballhat ",
    "wathgrithrhat",
    "armormarble",
    "armorslurper",
    "slurtlehat",
    "armor_sanity",
    "armorruins",
    "ruinshat",
    "armordragonfly",
}
for k, v in pairs(armors) do
    AddPrefabPostInit(v, function(inst)
        inst:AddComponent("tp_forge_level_armor")
    end)
end

