local AttrAlter = {}

AttrAlter.Attrs = {
    max_health = {
        add = function(inst, key, val)
            inst.components.health:WgAddMaxHealthModifier(key, val)
        end,
        remove = function(inst, key)
            inst.components.health:WgRemoveMaxHealthModifier(key)
        end
    },
    recover_rate = {
        add = function(inst, key, val)
            inst.components.health:AddRecoverRateMod(key, val)
        end,
        remove = function(inst, key)
            inst.components.health:RmRecoverRateMod(key)
        end,
    },
    max_sanity = {
        add = function(inst, key, val)
            inst.components.sanity:WgAddMaxSanityModifier(key, val)
        end,
        remove = function(inst, key)
            inst.components.sanity:WgRemoveMaxSanityModifier(key)
        end,
    },
    sanity_rate = {
        add = function(inst, key, val)
            inst.components.sanity:AddRateModifier(key, val)
        end,
        remove = function(inst, key)
            inst.components.sanity:RemoveRateModifier(key)
        end
    },
    sanity_resist = {
        add = function(inst, key, val)
            inst.components.sanity:WgAddNegativeModifier(key, val)
        end,
        remove = function(inst, key)
            inst.components.sanity:WgRemoveNegativeModifier(key)
        end,
    },
    max_hunger = {
        add = function(inst, key, val)
            inst.components.hunger:WgAddMaxHungerModifier(key, val)
        end,
        remove = function(inst, key)
            inst.components.hunger:WgRemoveMaxHungerModifier(key)
        end
    },
    hunger_rate = {
        add = function(inst, key, val)
            inst.components.hunger:AddBurnRateModifier(key, val)
        end,
        remove = function(inst, key)
            inst.components.hunger:RemoveBurnRateModifier(key)
        end,
    },
    speed = {
        add = function(inst, key, val)
            inst.components.locomotor:AddSpeedModifier_Additive(key, val)
        end,
        remove = function(inst, key)
            inst.components.locomotor:RemoveSpeedModifier_Additive(key)
        end,
    },
    spd_mult = {
        add = function(inst, key, val)
            inst.components.locomotor:AddSpeedModifier_Mult(key, val)
        end,
        remove = function(inst, key)
            inst.components.locomotor:RemoveSpeedModifier_Mult(key)
        end,
    },
    dmg_mult = {
        add = function(inst, key, val)
            inst.components.combat:AddDamageModifier(key, val)
        end,
        remove = function(inst, key)
            inst.components.combat:RemoveDamageModifier(key)
        end
    },
    attack_speed = {
        add = function(inst, key, val)
            inst.components.combat:AddPeriodModifier(key, val)
        end,
        remove = function(inst, key)
            inst.components.combat:RemovePeriodModifier(key)
        end
    },
    defense = {
        add = function(inst, key, val)
            inst.components.combat:AddDefenseMod(key, val)
        end,
        remove = function(inst, key)
            inst.components.combat:RmDefenseMod(key)
        end
    },
    penetrate = {
        add = function(inst, key, val)
            inst.components.combat:AddPenetrateMod(key, val)
        end,
        remove = function(inst, key)
            inst.components.combat:RmPenetrateMod(key)
        end
    },
    evade = {
        add = function(inst, key, val)
            inst.components.combat:AddEvadeRateMod(key, val)
        end,
        remove = function(inst, key)
            inst.components.combat:RmEvadeRateMod(key)
        end,
    },
    hit_rate = {
        add = function(inst, key, val)
            inst.components.combat:AddHitRateMod(key, val)
        end,
        remove = function(inst, key)
            inst.components.combat:RmHitRateMod(key)
        end,
    },
    crit = {
        add = function(inst, key, val)
            inst.components.combat:AddCritRateMod(key, val)
        end,
        remove = function(inst, key)
            inst.components.combat:RmCritRateMod(key)
        end
    },
    life_steal = {
        add = function(inst, key, val)
            inst.components.combat:AddLifeStealRateMod(key, val)
        end,
        remove = function(inst, key)
            inst.components.combat:RmLifeStealRateMod(key)
        end
    },

    max_mana = {
        add = function(inst, key, val)
            inst.components.tp_val_mana:AddMaxMod(key, val)
        end,
        remove = function(inst, key)
            inst.components.tp_val_mana:RmMaxMod(key)
        end,
    },
    mana_rate_mod = {
        add = function(inst, key, val)
            inst.components.tp_val_mana:AddRateMod(key, val)
        end,
        remove = function(inst, key)
            inst.components.tp_val_mana:RmRateMod(key)
        end
    },
    mana_rate_mult = {
        add = function(inst, key, val)
            inst.components.tp_val_mana:AddRateMult(key, val)
        end,
        remove = function(inst, key)
            inst.components.tp_val_mana:RmRateMult(key)
        end
    },
    max_vigor = {
        add = function(inst, key, val)
            inst.components.health:AddMaxMod(key, val)
        end,
        remove = function(inst, key)
            inst.components.health:RmMaxMod(key)
        end,
    },
    vigor_rate = {
        add = function(inst, key, val)
            inst.components.health:AddRateMod(key, val)
        end,
        remove = function(inst, key)
            inst.components.health:RmRateMod(key)
        end,
    },
    load_weight = {
        add = function(inst, key, val)
            inst.components.inventory:AddLoadWeightMod(key, val)
        end,
        remove = function(inst, key)
            inst.components.inventory:RmLoadWeightMod(key)
        end,
    },

    fitness = {
        add = function(inst, key, val)
            inst.components.tp_player_attr:AddAttrMod("health", key, val)
        end,
        remove = function(inst, key)
            inst.components.tp_player_attr:RmAttrMod("health", key)
        end,
    },
    endurance = {
        add = function(inst, key, val)
            inst.components.tp_player_attr:AddAttrMod("endurance", key, val)
        end,
        remove = function(inst, key)
            inst.components.tp_player_attr:RmAttrMod("endurance", key)
        end
    },
    stamina = {
        add = function(inst, key, val)
            inst.components.tp_player_attr:AddAttrMod("stamina", key, val)
        end,
        remove = function(inst, key)
            inst.components.tp_player_attr:RmAttrMod("stamina", key)
        end,
    },
    attention = {
        add = function(inst, key, val)
            inst.components.tp_player_attr:AddAttrMod("attention", key, val)
        end,
        remove = function(inst, key)
            inst.components.tp_player_attr:RmAttrMod("attention", key)
        end,
    },
    strengthen = {
        add = function(inst, key, val)
            inst.components.tp_player_attr:AddAttrMod("strengthen", key, val)
        end,
        remove = function(inst, key)
            inst.components.tp_player_attr:RmAttrMod("strengthen", key)
        end,
    },
    agility = {
        add = function(inst, key, val)
            inst.components.tp_player_attr:AddAttrMod("agility", key, val)
        end,
        remove = function(inst, key)
            inst.components.tp_player_attr:RmAttrMod("agility", key)
        end,
    },
    intelligence = {
        add = function(inst, key, val)
            inst.components.tp_player_attr:AddAttrMod("intelligence", key, val)
        end,
        remove = function(inst, key)
            inst.components.tp_player_attr:RmAttrMod("intelligence", key)
        end,
    },
    faith = {
        add = function(inst, key, val)
            inst.components.tp_player_attr:AddAttrMod("faith", key, val)
        end,
        remove = function(inst, key)
            inst.components.tp_player_attr:RmAttrMod("faith", key)
        end
    },
    lucky = {
        add = function(inst, key, val)
            inst.components.tp_player_attr:AddAttrMod("lucky", key, val)
        end,
        remove = function(inst, key)
            inst.components.tp_player_attr:RmAttrMod("lucky", key)
        end,
    },

    damage = {
        delta = function(inst, key, val)
            local n = inst.components.combat.damagebonus or 0
            inst.components.combat.damagebonus = n + val
        end,
    },
    health = {
        delta = function(inst, val, overtime, cause)
            inst.components.health:DoDelta(val, overtime, cause)
        end,
        percent = function(inst, val)
            inst.components.health:SetPercent(val)
        end,
    },
    sanity = {
        delta = function(inst, val, overtime)
            inst.components.sanity:DoDelta(val, overtime)
        end,
        percent = function(inst, val)
            inst.components.sanity:SetPercent(val)
        end,
    },
    hunger = {
        delta = function(inst, val, overtime)
            inst.components.hunger:DoDelta(val, overtime)
        end,
        percent = function(inst, val)
            inst.components.hunger:SetPercent(val)
        end,
    },

    -- 属性伤害吸收
    strike_resist = {
        delta = function(inst, val)
            inst.compnents.combat:AddDmgTypeAbsorb("strike", val)
        end,
    },
    slash_resist = {
        delta = function(inst, val)
            inst.compnents.combat:AddDmgTypeAbsorb("slash", val)
        end,
    },
    spike_resist = {
        delta = function(inst, val)
            inst.compnents.combat:AddDmgTypeAbsorb("spike", val)
        end,
    },
    thump_resist = {
        delta = function(inst, val)
            inst.compnents.combat:AddDmgTypeAbsorb("thump", val)
        end,
    },
    fire_resist = {
        delta = function(inst, val)
            inst.compnents.combat:AddDmgTypeAbsorb("fire", val)
        end,
    },
    ice_resist = {
        delta = function(inst, val)
            inst.compnents.combat:AddDmgTypeAbsorb("ice", val)
        end,
    },
    electric_resist = {
        delta = function(inst, val)
            inst.compnents.combat:AddDmgTypeAbsorb("electric", val)
        end,
    },
    poison_resist = {
        delta = function(inst, val)
            inst.compnents.combat:AddDmgTypeAbsorb("poison", val)
        end,
    },
    wind_resist = {
        delta = function(inst, val)
            inst.compnents.combat:AddDmgTypeAbsorb("wind", val)
        end,
    },
    blood_resist = {
        delta = function(inst, val)
            inst.compnents.combat:AddDmgTypeAbsorb("blood", val)
        end,
    },
    shadow_resist = {
        delta = function(inst, val)
            inst.compnents.combat:AddDmgTypeAbsorb("shadow", val)
        end,
    },
    holly_resist = {
        delta = function(inst, val)
            inst.compnents.combat:AddDmgTypeAbsorb("holly", val)
        end,
    },
}

function AttrAlter:Alter(attr, operator, ...)
    assert(self.Attrs[attr] ~= nil, "Attribute not found: " .. attr)
    assert(self.Attrs[attr][operator] ~= nil, "Operator not found: " .. operator)
    self.Attrs[attr][operator](...)
end

return AttrAlter
