local Info = Sample.Info
local Util = require "extension.lib.wg_util"

local function level_gift(inst, data)
    inst.components.health:DoDelta(100)
    inst.components.sanity:DoDelta(100)
    inst.components.hunger:DoDelta(100)

    -- local alloy=SpawnPrefab("tp_alloy_enchant")
    -- alloy:random_enchant()
    local gift = inst.components.inventory:FindItem(function(item, inst)
        return item.prefab == "tp_level_gift"
    end)
    if gift == nil then
        gift = SpawnPrefab("tp_level_gift")
        inst.components.inventory:GiveItem(gift)
    end
    gift:add_loot("tp_alloy_enchant2", 1)

    if data.level == 2 then
        gift:add_loot("cutgrass", 20)
    elseif data.level == 4 then
        gift:add_loot("twigs", 20)
    elseif data.level == 6 then
        gift:add_loot("log", 10)
    elseif data.level == 8 then
        gift:add_loot("goldnugget", 10)
    elseif data.level == 10 then
        gift:add_loot("rocks", 40)
    elseif data.level == 13 then
        gift:add_loot("tp_alloy", 3)
    elseif data.level == 16 then
        gift:add_loot("tp_alloy_red", 3)
    elseif data.level == 19 then
        gift:add_loot("tp_alloy_enchant2", 5)
    elseif data.level == 23 then
        gift:add_loot("livinglog", 2)
        gift:add_loot("gears", 2)
        gift:add_loot("purplegem", 2)
    elseif data.level == 26 then
        gift:add_loot("thulecite", 2)
        gift:add_loot("alloy", 2)
        gift:add_loot("obsidian", 2)
    elseif data.level == 29 then
        gift:add_loot("tp_epic", 1)
    end
end

local Level = Class(function(self, inst)
    self.inst = inst
    self.level = 0
    self.exp = 0
    self.need = 4
    self.phase = 1  -- 进阶
    self.growth_attr = nil
    inst:ListenForEvent("killed", function(inst, data)
        if data and data.victim 
        and data.victim.components.health
        and data.victim.components.tp_creature_equip then
            self:Kill(data.victim)
        end
    end)
    inst:ListenForEvent("oneat", function(inst, data)
        if data and data.food 
        and data.food.components.edible.foodstate == "PREPARED" then
            if data.food.components.edible.healthvalue>=TUNING.HEALING_HUGE then
                self:ExpDelta(Info.Exp.Food)
            end
            if data.food.components.edible.sanityvalue>=TUNING.SANITY_HUGE then
                self:ExpDelta(Info.Exp.Food)
            end
            if data.food.components.edible.hungervalue>=TUNING.CALORIES_HUGE then
                self:ExpDelta(Info.Exp.Food)
            end
        end
    end)
    inst:ListenForEvent("picksomething", function(inst, data)
        if data and data.loot then
            self:ExpDelta(Info.Exp.Pick)
        end
    end)
end)

local function adjust(n)  -- 四舍五入
    n = n*10+5
    n = n/10
    return math.floor(n)
end

function Level:Kill(victim)
    -- 根据装备情况计算经验加成
    local _level = victim.components.tp_creature_equip.level
    local s, m, L = Info.MonsterStrengthenFns.GetEquipNum(victim, _level)
    local mult = 1+s*Info.Exp.SmallEquipExpMult+m*Info.Exp.LargeEquipExpMult+L*Info.Exp.GreatEquipExpMult
    local exp
    if victim:HasTag("world_boss") then
        exp = Info.Exp.WorldBoss
        exp = exp*mult
        -- 击杀boss时，如果boss等级/3>你的等级
        -- 额外提升你达到此等级的经验的2/3
        local dt = math.floor(_level/Info.Exp.MonsterLevelDinominator) - self.level
        local need = self.need
        local reply = 0
        for i = 1, dt do
            reply = reply + need
            need = adjust((need+Info.Exp.GrowthAmount)*Info.Exp.GrowthMult)
        end
        exp = exp + math.floor(reply/Info.Exp.WorldBossReplyExpDinominator)
    elseif victim:HasTag("epic") then
        exp = Info.Exp.Epic
        exp = exp*mult
    elseif victim:HasTag("largecreature") then
        exp = Info.Exp.LargeCreature
        exp = exp*mult
    else
        exp = Info.Exp.Monster
        exp = exp*mult
    end
    self:ExpDelta(exp)
end

function Level:GetPercent()
    return self.exp/self.need
end

function Level:CanLevelUp(dt)
    if self.exp+dt>=self.need 
    and self.level < self.phase*Info.Level.PhaseMaxLevel then
        return true
    end
end

function Level:MakeLevelUp()
    local dt = self.need-self.exp
    self:ExpDelta(dt)
end

function Level:ExpDelta(dt)
    if self:CanLevelUp(dt) then
        self:LevelUp()
        -- dt = self.exp+dt-self.need
        dt = dt-self.need
        -- 需求经验上涨
        self.need = adjust((self.need+Info.Exp.GrowthAmount)*Info.Exp.GrowthMult)
        self:ExpDelta(dt)
        return
    else
        self.exp = math.min(self.need, self.exp+dt)
    end
    self.inst:PushEvent("tp_exp_delta", {exp=dt, new_p=self:GetPercent()})
end

function Level:SetLevelFn(fn)
    self.level_fn = fn
end

function Level:SetAdvancedFn(fn)
    self.advance_fn = fn
end

function Level:SetGrowthAttr(growth_attr)
    self.growth_attr = growth_attr
end

function Level:Upgrade()
    if self.level_fn then
        self.level_fn(self.inst, self.level)
    end
    if self.advance_fn then
        self.advance_fn(self.inst, self.phase)
    end
    -- 魔法值
    local base = Info.Character.common.BaseMana
    local mn_mod = self.level*Info.Character.common.PerLevelMana
    self.inst.components.tp_mana:SetMax(base+mn_mod)
    self.inst.components.tp_mana:DoDelta(0)
    -- 品尝值
    self.inst.components.tp_taste:SetMax(
        Info.Character.common.BaseTaste+math.floor(self.level/Info.Character.common.TasteNeedLevel)
    )
    
    local health = 0
    local sanity = 0
    local hunger = 0
    local dmg_mult = 0
    for i = 1, 3 do
        local pre_level_phase = (i-1)*10
        if self.level >= pre_level_phase then
            local cur = math.min(self.level-pre_level_phase, 10)
            health = health + cur*self.growth_attr.health[i]
            sanity = sanity + cur*self.growth_attr.sanity[i]
            hunger = hunger + cur*self.growth_attr.hunger[i]
            dmg_mult = dmg_mult + cur*self.growth_attr.dmg_mult[i]
            -- print(cur, base, dmg_mult, pre_level_phase)
        end
    end
    self.inst.components.health:WgAddMaxHealthModifier("tp_level", health)
    self.inst.components.sanity:WgAddMaxSanityModifier("tp_level", sanity)
    self.inst.components.hunger:WgAddMaxHungerModifier("tp_level", hunger)
    self.inst.components.combat:AddDamageModifier("tp_level", dmg_mult)
end

function Level:LevelUp()
    SpawnPrefab("sparklefx").Transform:SetPosition(self.inst:GetPosition():Get())
    self.level = self.level+1
    self:Upgrade()
    self.inst:PushEvent("tp_level_up", {level=self.level})
    level_gift(self.inst, {level=self.level})
end

function Level:CanBeAdvanced(n)
    return self.phase == n-1 and self.phase < Info.Level.MaxPhase
        and self.level == self.phase*Info.Level.PhaseMaxLevel
end

function Level:BeAdvanced(n)
    self.phase = n
    self.inst:PushEvent("tp_be_advanced", {phase=n})
    SpawnPrefab("multifirework_fx").Transform:SetPosition(self.inst:GetPosition():Get())
    self.inst.sg:GoToState("celebrate")
end

function Level:OnSave()
    return {
        level = self.level,
        exp = self.exp,
        phase = self.phase,
        need = self.need,
    }
end

function Level:OnLoad(data)
    if data then
        self.phase = data.phase or 1
        self.level = data.level or 0
        self.need = data.need or 4
        self:Upgrade()
        self.exp = data.exp or 0
    end
end

function Level:GetWargonString()
    local s = string.format("等级:%d,经验:%.2f/%d,阶段:%d;", self.level, self.exp, self.need, self.phase)
    if WG_TEST then
        local attr = self.growth_attr
        s = s..string.format("每级提升%d生命,%d理智,%d饥饿,%d%%攻击", 
        attr.health[self.phase], attr.sanity[self.phase], attr.hunger[self.phase], attr.dmg_mult[self.phase]*100)
    end
    s = Util:SplitSentence(s, 17, true)
    return s
end

function Level:GetWargonStringColour()
    return {0/255, 255/255, 255/255, 1}
end

return Level