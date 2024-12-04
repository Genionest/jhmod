local WgBookShelf = require "extension.lib.wg_book_shelf"
local EntUtil = require "extension.lib.ent_util"
local Info = Sample.Info

local function OnPlayerWeightChange(inst, data)
    local weight = inst.components.tp_player_attr:GetPlayerWeight()
    local load_weight = inst.components.tp_player_attr.load_weight
    if weight/load_weight > 1 then
        -- self.inst.components.locomotor
        EntUtil:add_speed_mod(inst, "load_weight", -.5)
        EntUtil:add_attack_speed_mod(inst, "load_weight", -.2)
    elseif weight/load_weight > .8 then
        EntUtil:add_speed_mod(inst, "load_weight", -.3)
        EntUtil:add_attack_speed_mod(inst, "load_weight", -.1)
    elseif weight/load_weight > .5 then
        EntUtil:add_speed_mod(inst, "load_weight", -.2)
        EntUtil:add_attack_speed_mod(inst, "load_weight", -.05)
    elseif weight/load_weight > .3 then
        EntUtil:add_speed_mod(inst, "load_weight", -.1)
    else
        EntUtil:rm_speed_mod(inst, "load_weight")
    end
end

local TpPlayerAttr = Class(function(self, inst)
    self.inst = inst
    self.attr = {
        -- 健康值, 提高生命值, 食物收益
        health = 0,
        -- 耐力值, 提高精力值, 移动速度
        endurance = 0,
        -- 体力值, 提高负重值, 饱食度 
        stamina = 0,
        -- 专注值, 提高法力值, 理智值 
        attention = 0,
        -- 强壮值, 提高攻击力, 饥饿抗性
        strengthen = 0,
        -- 敏捷值, 提高攻击速度, 消化速度
        agility = 0,
        -- 信仰值, 提高生命恢复率, 暗抗
        faith = 0,
        -- 智力值, 提高法力恢复, 理智抗性
        intelligence = 0,
        -- 幸运值, 提高掉落率, 暴击伤害
        lucky = 0,
    }
    self.attr_mods = {}
    self.factors = {
        health = 0,
        endurance = 0,
        stamina = 0,
        attention = 0,
        strengthen = 0,
        agility = 0,
        faith = 0,
        intelligence = 0,
        lucky = 0,
    }
    self.attr_rate = {}
    self.power = 0
    self.inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        return damage + self.power
    end)
    -- 负重
    self.load_weight = Info.Attr.BaseLoadWeight
    self.inst:ListenForEvent("itemget", OnPlayerWeightChange)
    self.inst:ListenForEvent("itemlose", OnPlayerWeightChange)
    self.inst:ListenForEvent("take_ornament", OnPlayerWeightChange)
    self.inst:ListenForEvent("lose_ornament", OnPlayerWeightChange)
    self.loot_chance = 0
    self.crit_dmg_mod = 0
    -- 升级相关
    self.buffer = {}
    self.essence = 0
end)

function TpPlayerAttr:GetEssence()
    return self.inst.components.inventory:Count("tp_epic") 
end

function TpPlayerAttr:GetAttr(attr)
    local val = self.attr[attr]
    if self.attr_mods[attr] then
        val = val + self.attr_mods[attr]
    end
    return val
end

function TpPlayerAttr:SetAttr(attr, value)
    self.attr[attr] = value
end

function TpPlayerAttr:AddAttr(attr, value)
    self.attr[attr] = self.attr[attr] + value
end

function TpPlayerAttr:AddAttrMod(attr, mod)
    local n = self.attr_mods[attr] or 0
    self.attr_mods[attr] = mod + n
end

function TpPlayerAttr:SetAttrRate(attr, rate)
    self.attr_rate[attr] = rate
end

function TpPlayerAttr:GetAttrRate(attr)
    return self.attr_rate[attr] or 1
end

function TpPlayerAttr:GetAttrArgs(attr, attr_val)
    if attr == "health" then
        -- health
        local rate = self:GetAttrRate("health")
        -- 生命
        local hp = math.min(attr_val, 40) * 10 * rate  -- 400
        hp = hp + math.max(0, math.min(attr_val-40, 20)) * 5 * rate
        hp = hp + math.max(0, attr_val-60) * 3 * rate
        -- 食物收益
        local eat_val = math.min(attr_val, 60) * .005 * rate
        eat_val = eat_val + math.max(0, attr_val-60) * .003 * rate
        
        return hp, eat_val
    end
    if attr == "endurance" then
        -- endurance
        local rate = self:GetAttrRate("endurance")
        -- 精力
        local vigor = math.min(attr_val, 40) * 1 * rate  -- 80
        vigor = vigor + math.max(0, math.min(attr_val-40, 20)) * .5 * rate
        vigor = vigor + math.max(0, attr_val-60) * .3 * rate
        -- 速度
        local spd = math.min(attr_val, 40) * .005 * rate  
        spd = spd + math.max(0, math.min(attr_val-40, 20)) * .003 * rate
        spd = spd + math.max(0, attr_val-60) * .001 * rate

        return vigor, spd
    end

    if attr == "stamina" then
        -- stamina
        local rate = self:GetAttrRate("stamina")
        -- 负重
        local load_weight = math.min(attr_val, 40) * 1 * rate
        load_weight = load_weight + math.max(0, math.min(attr_val-40, 20)) * .5 * rate
        load_weight = load_weight + math.max(0, attr_val-60) * .3 * rate
        -- 饱食度
        local hg = math.min(attr_val, 40) * 5 * rate 
        hg = hg + math.max(0, math.min(attr_val-40, 20)) * 3 * rate
        hg = hg + math.max(0, attr_val-60) * 1 * rate

        return load_weight, hg
    end

    if attr == "attention" then
        -- attention
        local rate = self:GetAttrRate("attention")
        -- 法力
        local mana = math.min(attr_val, 40) * 5 * rate  -- 200
        mana = mana + math.max(0, math.min(attr_val-40, 20)) * 3 * rate
        mana = mana + math.max(0, attr_val-60) * 1 * rate
        -- 理智
        local san = math.min(attr_val, 40) * 5 * rate 
        san = san + math.max(0, math.min(attr_val-40, 20)) * 3 * rate
        san = san + math.max(0, attr_val-60) * 1 * rate

        return mana, san
    end

    if attr == "strengthen" then
        -- strengthen
        local rate = self:GetAttrRate("strengthen")
        -- 攻击力
        local power = math.min(attr_val, 40) * .75 * rate  -- 30
        power = power + math.max(0, math.min(attr_val-40, 20)) * .3 * rate
        power = power + math.max(0, attr_val-60) * .1 * rate
        -- 饥饿抗性
        local hg_resist = math.min(attr_val, 40) * .005 * rate  -- .2
        hg_resist = hg_resist + math.max(0, math.min(attr_val-40, 20)) * .003 * rate
        hg_resist = hg_resist + math.max(0, attr_val-60) * .001 * rate
        -- strengthen factor
        local factor = math.min(attr_val, 40)
        factor = factor + math.max(0, math.min(attr_val-40, 20)) * .5 * rate
        factor = factor + math.max(0, attr_val-60) * .25 * rate

        return power, hg_resist, factor
    end
    
    if attr == "agility" then
        -- agility
        local rate = self:GetAttrRate("agility")
        -- 攻速
        local atk_spd = math.min(attr_val, 60) * .005 * rate -- .3
        atk_spd = atk_spd + math.max(0, attr_val-60) * .001 * rate
        -- 消化速度
        local eat_time = math.min(attr_val, 40) * .2 * rate -- 8
        eat_time = eat_time + math.max(0, attr_val-40) * .02 * rate
        -- agility factor
        local factor = math.min(attr_val, 40)
        factor = factor + math.max(0, math.min(attr_val-40, 20)) * .5 * rate
        factor = factor + math.max(0, attr_val-60) * .25 * rate

        return atk_spd, eat_time, factor
    end
    
    if attr == "faith" then
        -- faith
        local rate = self:GetAttrRate("faith")
        -- 生命恢复率
        local recover = math.min(attr_val, 40) * .015 * rate  -- .6
        recover = recover + math.max(0, math.min(attr_val-40, 20)) * .005 * rate
        recover = recover + math.max(0, attr_val-60) * .003 * rate
        -- 暗属性抗性
        local shadow_dmg_absorb = math.min(attr_val, 40) * .005 * rate 
        shadow_dmg_absorb = shadow_dmg_absorb + math.max(0, math.min(attr_val-40, 20)) * .003 * rate
        shadow_dmg_absorb = shadow_dmg_absorb + math.max(0, attr_val-60) * .001 * rate
        -- faith factor
        local factor = math.min(attr_val, 20) * .5
        factor = factor + math.max(0, math.min(attr_val-20, 60)) * 1 * rate
        factor = factor + math.max(0, attr_val-80) * .3 * rate

        return recover, shadow_dmg_absorb, factor
    end
    
    if attr == "intelligence" then
        -- intelligence
        local rate = self:GetAttrRate("intelligence")
        -- 法力恢复
        local mana_rate = math.min(attr_val, 40) * .05 * rate  -- 2.0
        mana_rate = mana_rate + math.max(0, math.min(attr_val-40, 20)) * .03 * rate
        mana_rate = mana_rate + math.max(0, attr_val-60) * .01 * rate
        -- 理智抗性
        local san_resist = math.min(attr_val, 40) * .005 * rate 
        san_resist = san_resist + math.max(0, math.min(attr_val-40, 20)) * .003 * rate
        san_resist = san_resist + math.max(0, attr_val-60) * .001 * rate
        -- intelligence factor
        local factor = math.min(attr_val, 20) * .5
        factor = factor + math.max(0, math.min(attr_val-20, 60)) * 1 * rate
        factor = factor + math.max(0, attr_val-80) * .3 * rate

        return mana_rate, san_resist, factor
    end

    if attr == "lucky" then
        -- lucky
        local rate = self:GetAttrRate("lucky")
        -- 掉落率
        local chance_loot = math.min(attr_val, 30)*0.01*rate
        chance_loot = chance_loot + math.max(attr_val-30, 0)*0.003*rate
        -- 暴击伤害
        local crit = math.min(attr_val, 40)*0.01*rate  -- 40
        crit = crit + math.max(attr_val-40, 0)*0.003*rate
        -- lucky factor
        local factor = math.min(attr_val, 20) * 1.5
        factor = factor + math.max(0, attr_val-20) * .4 * rate

        return chance_loot, crit, factor
    end
end

function TpPlayerAttr:Review(attr, val)
    -- 模拟
    if attr == "health" then
        -- health
        local hp, eat_val = self:GetAttrArgs("health", val)
        return string.format("%s:%d\n生命值:%d\n食物收益:%.1f%%", 
            Info.Attr.PlayerAttrStr[attr], val, hp, eat_val*100)
    end
    
    if attr == "endurance" then
        -- endurance
        local vigor, spd = self:GetAttrArgs(attr, val)
        return string.format("%s:%d\n精力值:%d\n移动速度:%.1f%%",
            Info.Attr.PlayerAttrStr[attr], val, vigor, spd*100)
    end

    if attr == "stamina" then
        -- stamina
        local load_weight, hg = self:GetAttrArgs(attr, val)
        return string.format("%s:%d\n负重值:%.1d\n饱食度:%d",
            Info.Attr.PlayerAttrStr[attr], val, Info.Attr.BaseLoadWeight+load_weight, hg)
    end

    if attr == "attention" then
        -- attention
        local mana, san = self:GetAttrArgs(attr, val)
        return string.format("%s:%d\n法力值:%d\n理智值:%d",
            Info.Attr.PlayerAttrStr[attr], val, mana, san)
    end

    if attr == "strengthen" then
        -- strengthen
        local power, hg_resist = self:GetAttrArgs(attr, val)
        return string.format("%s:%d\n攻击力:%.1f\n饥饿抗性:%.1f%%",
            Info.Attr.PlayerAttrStr[attr], val, power, hg_resist*100)
    end
    
    if attr == "agility" then
        -- agility
        local atk_spd, eat_time = self:GetAttrArgs(attr, val)
        return string.format("%s:%d\n攻速:%.1f%%\n消化加速:%.1fs",
            Info.Attr.PlayerAttrStr[attr], val, atk_spd*100, eat_time)
    end
    
    if attr == "faith" then
        -- faith
        local recover, shadow_dmg_absorb = self:GetAttrArgs(attr, val)
        return string.format("%s:%d\n生命恢复率:%.1f%%\n暗属性抗性:%.1f%%",
            Info.Attr.PlayerAttrStr[attr], val, recover*100, shadow_dmg_absorb*100)
    end
    
    if attr == "intelligence" then
        -- intelligence
        local mana_rate, san_resist = self:GetAttrArgs(attr, val)
        return string.format("%s:%d\n法力恢复:%.1f%%\n理智抗性:%.1f%%",
            Info.Attr.PlayerAttrStr[attr], val, mana_rate*100, san_resist*100)
    end

    if attr == "lucky" then
        -- lucky
        local chance_loot, crit = self:GetAttrArgs(attr, val)
        return string.format("%s:%d\n掉落率:%.1f%%\n暴击增伤:%.1f%%",
            Info.Attr.PlayerAttrStr[attr], val, chance_loot*100, crit*100)
    end
end

function TpPlayerAttr:UpdateAttr()
    -- health
    local hp, eat_val = self:GetAttrArgs("health", self:GetAttr("health"))
    -- 生命
    self.inst.components.health:WgAddMaxHealthModifier("level", hp)
    self.hp = hp
    -- 食物收益
    self.inst.components.eater:AddHealthAbsorptionMod("level", eat_val)
    self.inst.components.eater:AddHungerAbsorptionMod("level", eat_val)
    self.inst.components.eater:AddSanityAbsorptionMod("level", eat_val)
    self.eat_val = eat_val
    
    -- endurance
    local vigor, spd = self:GetAttrArgs("endurance", self:GetAttr("endurance"))
    -- 精力
    self.inst.components.tp_val_vigor:AddMaxMod("level", vigor)
    self.vigor = vigor
    -- 速度
    -- self.inst.components.locomotor:AddSpeedModifier_Mult("level", vigor)
    EntUtil:add_speed_mod(self.inst, "level", spd)
    self.spd = spd

    -- stamina
    local load_weight, hg = self:GetAttrArgs("stamina", self:GetAttr("stamina"))
    -- 负重
    self.load_weight = Info.Attr.BaseLoadWeight + load_weight
    -- 饱食度
    self.inst.components.hunger:WgAddMaxHungerModifier("level", hg)
    self.hg = hg

    -- attention
    local mana, san = self:GetAttrArgs("attention", self:GetAttr("attention"))
    -- 法力
    self.inst.components.tp_val_mana:AddMaxMod("level", mana)
    self.mana = mana
    -- 理智
    self.inst.components.sanity:WgAddMaxSanityModifier("level", san)
    self.san = san

    -- strengthen
    local power, hg_resist, factor = self:GetAttrArgs("strengthen", self:GetAttr("strengthen"))
    -- 攻击力
    self.power = power
    -- 饥饿抗性
    EntUtil:add_hunger_mod(self.inst, "level", .2-hg_resist)
    self.hg_resist = hg_resist
    -- 系数
    self.factors.strengthen = factor
    
    -- agility
    local atk_spd, eat_time, factor = self:GetAttrArgs("agility", self:GetAttr("agility"))
    -- 攻速
    EntUtil:add_attack_speed_mod(self.inst, "level", -atk_spd)
    self.atk_spd = atk_spd
    -- 消化速度
    self.inst.components.eater.tp_eat_time_max = Info.Attr.EatTime - eat_time
    self.eat_time = eat_time
    -- 系数
    self.factors.agility = factor
    
    -- faith
    local recover, shadow_dmg_absorb, factor = self:GetAttrArgs("faith", self:GetAttr("faith"))
    -- 生命恢复率
    self.inst.components.health:AddRecoverRateMod("level", recover)
    self.recover = recover
    -- 暗属性抗性
    self.inst.components.combat:SetDmgTypeAbsorb("shadow", 1-shadow_dmg_absorb)
    self.shadow_dmg_absorb = shadow_dmg_absorb
    -- 系数
    self.factors.faith = factor
    
    -- intelligence
    local mana_rate, san_resist, factor = self:GetAttrArgs("intelligence", self:GetAttr("intelligence"))
    -- 法力恢复
    -- -- 法力上限带来的法力恢复
    -- local max = self.inst.components.tp_val_mana.max_mods["level"]
    -- local mana_rate2 = max/100*.5
    -- self.inst.components.tp_val_mana:SetRate(-(1+mana_rate2)*(1+mana_rate))
    -- self.mana_rate = mana_rate + mana_rate2
    self.inst.components.tp_val_mana:SetRate(-1*(1+mana_rate))
    self.mana_rate = mana_rate
    -- 理智抗性
    self.inst.components.sanity:WgAddNegativeModifier("level", -san_resist)  
    self.san_resist = san_resist
    -- 系数
    self.factors.intelligence = factor

    -- lucky
    local chance_loot, crit, factor = self:GetAttrArgs("lucky", self:GetAttr("lucky"))
    -- 掉落率
    self.chance_loot = chance_loot
    -- 暴击伤害
    self.crit_dmg_mod = crit
    -- 系数
    self.factors.lucky = factor
end

function TpPlayerAttr:GetAttrFactor(attr)
    return self.factors[attr]
end

function TpPlayerAttr:GetLootChance()
    return self.chance_loot
end

function TpPlayerAttr:GetCritDmgMod()
    return self.crit_dmg_mod
end

function TpPlayerAttr:GetPlayerWeight()
    local inv = self.inst.components.inventory
    local n = 0
    for k,v in pairs(inv.itemslots) do
        n = n + 1
    end
    for k, v in pairs(inv.equipslots) do
        if v.components.container then
            n = n + v.components.container:NumItems()
        end
        if v.components.equippable.weight then
            n = n + v.components.equippable.equip_weight
        else
            n = n + 1
        end
    end
    n = n + #self.inst.components.tp_ornament.ids
    return n
end

function TpPlayerAttr:GetScreenData()
    local strs = {"人物属性",}
    table.insert(strs, {
        "升级点",
        string.format("%s:%d(生命值:%d,食物收益:%.1f%%)", 
            Info.Attr.PlayerAttrStr.health, self:GetAttr("health"), 
            self.hp, self.eat_val*100),
        string.format("%s:%d(精力值:%.1f,移速:%.1f%%)", 
            Info.Attr.PlayerAttrStr.endurance, self:GetAttr("endurance"), 
            self.vigor, self.spd),
        string.format("%s:%d(负重:%.1f,饱食度:%d)",
            Info.Attr.PlayerAttrStr.stamina, self:GetAttr("stamina"), 
            self.load_weight, self.hg),
        string.format("%s:%d(法力值:%d,理智值:%d)", 
            Info.Attr.PlayerAttrStr.attention, self:GetAttr("attention"), 
            self.mana, self.san),
        string.format("%s:%d(攻击力:%.1f,饥饿抗性:%.1f%%)", 
            Info.Attr.PlayerAttrStr.strengthen, self:GetAttr("strengthen"), 
            self.power, self.hg_resist*100),
        string.format("%s:%d(攻速:%.1f%%,消化加速:%.1fs)", 
            Info.Attr.PlayerAttrStr.agility, self:GetAttr("agility"), 
            self.atk_spd*100, self.eat_time),
        string.format("%s:%d(生命恢复:%.1f%%,暗抗:%.1f%%)", 
            Info.Attr.PlayerAttrStr.faith, self:GetAttr("faith"), 
            self.recover*100, self.shadow_dmg_absorb*100),
        string.format("%s:%d(法力恢复:%.1f%%,理智抗性:%.1f%%)", 
            Info.Attr.PlayerAttrStr.intelligence, self:GetAttr("intelligence"), 
            self.mana_rate*100, self.san_resist*100),
        string.format("%s:%d(掉落率:%.1f%%,暴击加伤:%.1f%%)", 
            Info.Attr.PlayerAttrStr.lucky, self:GetAttr("lucky"), 
            self.chance_loot*100, self.crit_dmg_mod*100),
    })
    table.insert(strs, {
        "属性系数",
        string.format("%s:%d", Info.Attr.PlayerAttrStr.strengthen, self.factors.strengthen),
        string.format("%s:%d", Info.Attr.PlayerAttrStr.agility, self.factors.agility),
        string.format("%s:%d", Info.Attr.PlayerAttrStr.faith, self.factors.faith),
        string.format("%s:%d", Info.Attr.PlayerAttrStr.intelligence, self.factors.intelligence),
        string.format("%s:%d", Info.Attr.PlayerAttrStr.lucky, self.factors.lucky),
    })
    local recover = self.inst.components.health.tp_recover or 0
    table.insert(strs, {
        "三围",
        string.format("生命上限:%d", self.inst.components.health:GetMaxHealth()),
        string.format("生命回复率:%d%%",  100+recover*100),
        string.format("饱食度:%d", self.inst.components.hunger:GetMaxHunger()),
        string.format("饥饿速度:%d%%", self.inst.components.hunger:GetBurnRate()*100),
        string.format("食物收益:%d%%(生命),%d%%(理智),%d%%(饥饿)", 
            self.inst.components.eater:GetHealthAbsorptionMod()*100,
            self.inst.components.eater:GetSanityAbsorptionMod()*100,
            self.inst.components.eater:GetHungerAbsorptionMod()*100
        ),
        string.format("消化速度:%ds", Info.Attr.EatTime-self.eat_time),
        string.format("理智值:%d", self.inst.components.sanity:GetMaxSanity()),
        string.format("理智抗性:%d%%", -self.inst.components.sanity:WgGetNegativeModifier()*100),
    })
    local combat = self.inst.components.combat
    local defense = combat.tp_defense or 0
    local def_ab = 1-100/(100+defense)
    local dmg_mult = combat:GetDamageModifier()
    local penetrate = combat.tp_penetrate or 0
    -- local atk_spd = combat:GetPeriodModifier()
    local crit = combat.tp_crit or 0
    local evade = combat.tp_evade or 0
    local evd_ab = 1-150/(150+evade)
    local hit_rate = combat.tp_hit_rate or 0
    local life_steal = combat.tp_life_steal or 0
    local weapon = combat:GetWeapon()
    local dmg
    if weapon then
        dmg = weapon.components.weapon:GetDamage() * dmg_mult
    else
        dmg = combat.defaultdamage * dmg_mult
    end
    table.insert(strs, {
        "攻击相关",
        string.format("强壮增加攻击:%d", self.power),
        string.format("攻击速度:%d%%", (-self.inst.components.combat:GetPeriodModifier())*100),
        string.format("暴击伤害:%d%%", self.crit_dmg_mod*100+200),
        string.format("攻击力:%d", dmg),
        string.format("暴击率:%d%%", crit*100),
        string.format("防御值:%d(%d%%)", defense, def_ab*100),
        string.format("闪避值:%d(%d%%)", evade, evd_ab*100),
        string.format("穿透值:%d", penetrate),
        string.format("命中值:%d", hit_rate),
        string.format("吸血率:%d%%", life_steal*100),
        -- string.format("暗属性抗性:%d%%", self.inst.components.combat:GetDmgTypeAbsorb("shadow")*100),
    })
    local dmg_type_absorb_strs = {"伤害吸收"}
    for k, v in pairs(Info.DmgTypeList) do
        local dmg_type = v[1]
        local dmg_str = v[2]
        local resist = self.inst.components.combat:GetDmgTypeAbsorb(dmg_type) or 1
        table.insert(dmg_type_absorb_strs, string.format("%s属性:%d%%", 
            dmg_str, resist*100))
    end
    table.insert(strs, dmg_type_absorb_strs)
    table.insert(strs, {
        "其他",
        string.format("精力值:%d", self.inst.components.tp_val_vigor:GetMax()),
        string.format("法力值:%d", self.inst.components.tp_val_mana:GetMax()),
        string.format("法力恢复:%.2f/s", -self.inst.components.tp_val_mana.rate),
        string.format("移动速度:%d%%", self.inst.components.locomotor:GetSpeedMultiplier()*100),
        string.format("负重:%d/%d(%d%%)", self:GetPlayerWeight(), self.load_weight, 
            self:GetPlayerWeight()/self.load_weight*100),
        string.format("掉落率增加:%d%%", self.chance_loot*100),
    })
    local shelfs = {
        strs
    }
    local book_shelf = WgBookShelf("属性")
    book_shelf:AddShelfs(shelfs)
    return book_shelf
end

function TpPlayerAttr:OnSave()
    return {
        attr = self.attr
    }
end

function TpPlayerAttr:OnLoad(data)
    if data and data.attr then
        self.attr = data.attr
        self:UpdateAttr()
    end
end


-- function TpPlayerAttr:GetWargonString()
    -- local s = string.format("健康:%d,耐力:%d,强壮:%d,敏捷:%d,",
    --     self.attr.health, self.attr.endurance, self.attr.strengthen, self.attr.agility)
    -- s = s..string.format("\n信仰:%d,智力:%d,幸运:%d,", 
    --     self.attr.faith, self.attr.intelligence, self.attr.lucky)
    -- if WG_TEST then
    --     s = s.."\n"
    --     s = s..string.format("生命:%.2f%%,食物收益:%.2f%%,", self.hp, self.eat_val*100)
    --     s = s..string.format("饱食:%.2f%%,攻击力:%.2f%%", self.hg, self.power)
    --     s = s.."\n"
    --     s = s..string.format("精力:%.2f%%,速度:%.2f%%,", self.vigor, self.spd*100)
    --     s = s..string.format("攻速:%.2f%%,消化速度:%.2f%%,", self.atk_spd*100, self.eat_time)
    --     s = s.."\n"
    --     s = s..string.format("理智:%.2f%%,生命恢复:%.2f%%,", self.san, self.recover*100)
    --     s = s..string.format("法力:%.2f%%,理智抗性:%.2f%%,", self.mana, self.san_resist*100)
    --     s = s.."\n"
    --     s = s..string.format("掉落率:%.2f%%,暴击伤害:%.2f%%,", self.chance_loot*100,self.crit_dmg_mod*100)
    -- end
    -- return s
-- end

-- function TpPlayerAttr:GetWargonStringColour()
--     return {50/255, 205/255, 205/255, 1}
-- end

return TpPlayerAttr