local Info = Sample.Info
local Util = require "extension.lib.wg_util"

local Level = Class(function(self, inst)
    self.inst = inst
    self.level = 0
    self.exp = 0
    self.need = 4
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

function Level:CanGiveEssence(dt)
    return self.exp<self.need and self.exp+dt>=self.need
end

function Level:CanLevelUp(dt)
    -- if self.exp+dt>=self.need 
    -- and self.level < self.phase*Info.Level.PhaseMaxLevel then
    if self.exp+dt>=self.need then 
        return true
    end
end

-- function Level:ExpDelta(dt)
--     if self:CanLevelUp(dt) then
--         self:LevelUp()
-- --         dt = self.exp+dt-self.need
--         dt = dt-self.need
--         -- 需求经验上涨
--         self.need = adjust((self.need+Info.Exp.GrowthAmount)*Info.Exp.GrowthMult)
--         self:ExpDelta(dt)
--         self.inst.components.inventory:GiveItem(SpawnPrefab("tp_epic"))
--         return
--     else
--         self.exp = math.min(self.need, self.exp+dt)
--     end
--     self.inst:PushEvent("tp_exp_delta", {exp=dt, new_p=self:GetPercent()})
-- end

function Level:ExpDelta(dt)
    -- if self.inst:HasTag("plain8") and self.inst:HasTag("plain9") then
    --     dt = dt+dt*.1
    -- end
    if self:CanLevelUp(dt) then
        dt = dt-self.need
        self:LevelUp(1)
        -- self.need = adjust((self.need+Info.Exp.GrowthAmount)*Info.Exp.GrowthMult)
        self:ExpDelta(dt)
        -- 给予精华
        self.inst.components.inventory:GiveItem(SpawnPrefab("tp_epic"))
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
    -- 升级后永久拥有的效果, 可以加tag用于判断是否需要获得
    -- if self.level_fn then
    --     self.level_fn(self.inst, self.level)
    -- end

    
    -- local health = 0
    -- local sanity = 0
    -- local hunger = 0
    -- local dmg_mult = 0
    -- for i = 1, 3 do
    --     local pre_level_phase = (i-1)*10
    --     if self.level >= pre_level_phase then
    --         local cur = math.min(self.level-pre_level_phase, 10)
    --         health = health + cur*self.growth_attr.health[i]
    --         sanity = sanity + cur*self.growth_attr.sanity[i]
    --         hunger = hunger + cur*self.growth_attr.hunger[i]
    --         dmg_mult = dmg_mult + cur*self.growth_attr.dmg_mult[i]
    --         -- print(cur, base, dmg_mult, pre_level_phase)
    --     end
    -- end
    -- self.inst.components.health:WgAddMaxHealthModifier("tp_level", health)
    -- self.inst.components.sanity:WgAddMaxSanityModifier("tp_level", sanity)
    -- self.inst.components.hunger:WgAddMaxHungerModifier("tp_level", hunger)
    -- self.inst.components.combat:AddDamageModifier("tp_level", dmg_mult)
end

function Level:LevelUp(dt)
    -- SpawnPrefab("sparklefx").Transform:SetPosition(self.inst:GetPosition():Get())
    self.level = self.level+dt
    for i = 1, dt do
        self.need = adjust((self.need+Info.Exp.GrowthAmount)*Info.Exp.GrowthMult) 
    end
    -- self:Upgrade()
    -- 升级时才拥有的奖励
    self.inst:PushEvent("tp_level_up", {level=self.level})
    -- level_gift(self.inst, {level=self.level})
end

function Level:OnSave()
    return {
        level = self.level,
        exp = self.exp,
        -- phase = self.phase,
        need = self.need,
    }
end

function Level:OnLoad(data)
    if data then
        self.level = data.level or 0
        self.need = data.need or 4
        self:Upgrade()
        self.exp = data.exp or 0
    end
end

function Level:GetWargonString()
    local s = string.format("等级:%d,经验:%.2f/%d;", self.level, self.exp, self.need)
    if WG_TEST then
        -- local attr = self.growth_attr
        -- s = s..string.format("每级提升%d生命,%d理智,%d饥饿,%d%%攻击", 
        -- attr.health[self.phase], attr.sanity[self.phase], attr.hunger[self.phase], attr.dmg_mult[self.phase]*100)
    end
    s = Util:SplitSentence(s, 17, true)
    return s
end

function Level:GetWargonStringColour()
    return {0/255, 255/255, 255/255, 1}
end

return Level