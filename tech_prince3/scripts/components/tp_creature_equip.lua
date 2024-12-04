local CreatureEquipManager = Sample.CreatureEquipManager
local EntUtil = require "extension/lib/ent_util"
local Util = require "extension.lib.wg_util"
local Info = Sample.Info
local Hard = Sample.HARD

local CreatureEquip = Class(function(self, inst)
    self.inst = inst
    self.init = nil
    self.equips = {}
    self.attr_data = nil
    self.damage = 0
    inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        return damage + self.damage
    end)
    inst:AddComponent("tp_creature_equip2")
end)

function CreatureEquip:Test()
    if self.inst:HasTag("no_creature_equip") then
        return 
    end
    return not self.init
end

function CreatureEquip:Random()
    if not self:Test() then
        return
    end
    local day = GetClock():GetNumCycles()+1  -- 因为第一天是0，所以+1
    -- 洞穴内增加30天
    if GetWorld():IsCave() then
        day = day+Info.MonsterStrengthen.CaveAddDay
    end
    day = math.min(Info.MonsterStrengthen.MaxDay, day)
    -- 等级，根据难度进行天数补正
    if self.level == nil then
        self.level = math.max(1, math.floor(day*Info.MonsterStrengthen.Corrections[Hard]))
    end
    -- 小装备，大装备, 神话装备
    local s, m, L = Info.MonsterStrengthenFns.GetEquipNum(self.inst, self.level)
    -- 平均分配攻击装和防御装
    local s1, s2, m1, m2, L1, L2 = 0, 0, 0, 0, 0, 0
    local flag = math.random()<.5 and 1 or -1
    for i = 1, s do
        if flag == 1 then
            s1 = s1+1
        else
            s2 = s2+1
        end
        flag = -flag
    end
    for i = 1, m do
        if flag == 1 then
            m1 = m1+1
        else
            m2 = m2+1
        end
        flag = -flag
    end
    for i = 1, L do
        if flag == 1 then
            L1 = L1+1
        else
            L2 = L2+1
        end
        flag = -flag
    end
    local equip_ids = {}
    local ids = CreatureEquipManager:GetRandomIds(s1, {"small_equips_atk"})
    for k, v in pairs(ids) do
        table.insert(equip_ids, v)
    end
    local ids = CreatureEquipManager:GetRandomIds(s2, {"small_equips_def"})
    for k, v in pairs(ids) do
        table.insert(equip_ids, v)
    end
    local ids = CreatureEquipManager:GetRandomIds(m1, {"equips_atk"})
    for k, v in pairs(ids) do
        table.insert(equip_ids, v)
    end
    local ids = CreatureEquipManager:GetRandomIds(m2, {"equips_def"})
    for k, v in pairs(ids) do
        table.insert(equip_ids, v)
    end
    local ids = CreatureEquipManager:GetRandomIds(L1, {"large_equips_atk"})
    for k, v in pairs(ids) do
        table.insert(equip_ids, v)
    end
    local ids = CreatureEquipManager:GetRandomIds(L2, {"large_equips_def"})
    for k, v in pairs(ids) do
        table.insert(equip_ids, v)
    end
    -- 指定id, 键值对
    if self.include_ids then
        -- 不重复添加id
        for k, v in pairs(self.equips) do
            if self.include_ids[v] then
                self.include_ids[v] = nil
            end
        end
        for k, v in pairs(self.include_ids) do
            table.insert(equip_ids, k)
        end
    end
    self:SetEquipByIds(equip_ids)
end

function CreatureEquip:SetLevelAttr(is_load)
    if self.inst.components.health then
        self.inst.components.health:WgAddMaxHealthMultiplier("MS", self.attr_data.hp_mod, not is_load)
    end
    if self.inst.components.combat then
        self.inst.components.combat:AddDefenseMod("MS", self.attr_data.absorb)
        self.inst.components.combat:AddDamageModifier("MS", self.attr_data.dmg_mod)
        self.inst.components.combat:AddPenetrateMod("MS", self.attr_data.penetrate)
    end
    self.damage = self.damage + self.attr_data.ex_dmg
end

function CreatureEquip:SetEquipByIds(ids)
    for k, v in pairs(ids) do
        self:SetEquipById(v)
    end
    -- 后置的函数
    if self.post then
        self:SetPost()
    end
    -- 属性增强
    if self.attr_data == nil then
        self.attr_data = {
            hp_mod = Info.MonsterStrengthenFns.HpFunc(self.inst, self.level),
            absorb = Info.MonsterStrengthenFns.AbsorbFunc(self.inst, self.level),
            ex_dmg = Info.MonsterStrengthenFns.DamageFunc(self.inst, self.level),
            dmg_mod = Info.MonsterStrengthenFns.DmgModFunc(self.inst, self.level),
            penetrate = Info.MonsterStrengthenFns.PenetrateFunc(self.inst, self.level),
        }
    end
    self:SetLevelAttr()

    self.init = true
end

function CreatureEquip:SetEquipById(id)
    local data = CreatureEquipManager:GetDataById(id)
    self:SetEquip(data)
end

function CreatureEquip:SetEquip(equip)
    if equip then
        local id = equip:GetId()
        table.insert(self.equips, id)
        local equip_data = equip.data
        -- print("equip_id ", id)
        if self.inst.components.health then
            if equip_data.hp then
                -- if self.inst:HasTag("epic") then
                --     local dt = equip_data.hp*Info.MonsterStrengthen.EpicEquipHpRate
                --     self.inst.components.health:WgAddMaxHealthModifier(id, dt, true)
                -- else
                    self.inst.components.health:WgAddMaxHealthModifier(id, equip_data.hp, true)
                -- end
            end
            if equip_data.recover then
                self.inst.components.health:AddRecoverRateMod(id, equip_data.recover)
            end
        end
        if equip_data.speed then
            EntUtil:add_speed_mod(self.inst, id, equip_data.speed)
        end
        if equip_data.dmg then
            -- if self.inst:HasTag("epic") then
            --     -- EntUtil:add_damage_mod(self.inst, id, equip_data.dmg*0.01)
            --     self.damage = self.damage + equip_data.dmg*Info.MonsterStrengthen.EpicEquipDmgRate
            -- else
                self.damage = self.damage + equip_data.dmg
            -- end
        end
        if equip_data.dmg_mod then
            EntUtil:add_damage_mod(self.inst, id, equip_data.dmg_mod)
        end
        if equip_data.attack_speed then
            EntUtil:add_attack_speed_mod(self.inst, id, equip_data.attack_speed)
        end
        if self.inst.components.combat then
            if equip_data.absorb then
                self.inst.components.combat:AddDefenseMod(id, equip_data.absorb)
            end
            if equip_data.crit then
                self.inst.components.combat:AddCritRateMod(id, equip_data.crit)
            end
            if equip_data.evade then
                self.inst.components.combat:AddEvadeRateMod(id, equip_data.evade)
            end
            if equip_data.life_steal then
                self.inst.components.combat:AddLifeStealRateMod(id, equip_data.life_steal)
            end
            if equip_data.penetrate then
                self.inst.components.combat:AddPenetrateMod(id, equip_data.penetrate)
            end
            if equip_data.hit_rate then
                self.inst.components.combat:AddHitRateMod(id, equip_data.hit_rate)
            end
        end
        if equip_data.init then
            equip_data.init(equip_data, self.inst, self, id)
        end
        if equip_data.attack then
            self.inst:ListenForEvent("onhitother", function(inst, data)
                if data and EntUtil:can_dmg_effect(data.stimuli) then
                    equip_data.attack(equip_data, inst, self, id, data)
                end
            end)
        end
        if equip_data.hit then
            self.inst:ListenForEvent("attacked", function(inst, data)
                if data and not EntUtil:in_stimuli(data.stimuli, "pure") then
                    equip_data.hit(equip_data, inst, self, id, data)
                end
            end)
        end
        if equip_data.remove then
            self.inst:ListenForEvent("onremove", function(inst, data)
                equip_data.remove(equip_data, inst, self, id, data)
            end)
        end
        if equip_data.post then
            if self.post == nil then
                self.post = {}
            end
            table.insert(self.post, equip)
        end
    end
end

function CreatureEquip:SetPost()
    -- 计算中装备的数量
    -- self.med_equip_num = 0
    -- for _, id in pairs(self.equips) do
    --     local kind = CreatureEquipManager:GetDataKindById(id)
    --     if kind == "equips" then
    --         self.med_equip_num = self.med_equip_num + 1
    --     end
    -- end
    for _, equip in pairs(self.post) do
        local id = equip:GetId()
        local equip_data = equip.data
        equip_data.post(equip_data, self.inst, self, id)
    end
end

function CreatureEquip:OnEntityWake()
    if self.is_sleep then
        for k, id in pairs(self.equips) do
            local data = CreatureEquipManager:GetDataById(id)
            if data.wake then
                data.wake(data, self.inst, self, id)
            end
        end
        self.is_sleep = nil
    end
end

function CreatureEquip:OnEntitySleep()
    self.is_sleep = true
    for k, id in pairs(self.equips) do
        local data = CreatureEquipManager:GetDataById(id)
        if data.sleep then
            data.sleep(data, self.inst, self, id)
        end
    end
end

function CreatureEquip:OnSave()
    return {
        equips = self.equips,
        init = self.init,
        attr_data = self.attr_data,
        level = self.level,
    }
end

function CreatureEquip:OnLoad(data)
    if data then
        self.init = data.init
        self.attr_data = data.attr_data
        self.level = data.level
        if data.equips then
            for k, v in pairs(data.equips) do
                self:SetEquipById(v)
            end
            -- 后置的函数
            if self.post then
                self:SetPost()
            end
            -- 等级属性
            self:SetLevelAttr(true)
        end
    end
end

function CreatureEquip:GetWargonString()
    local str = ""
    for k, v in pairs(self.equips) do
        local equip = CreatureEquipManager:GetDataById(v)
        if equip then
            -- if info_complex then
            --     s = split_sentence(equip_data.desc)
            -- else
            --     s = string.format("【%s】", equip_data.name)
            -- end
            local desc_fn = equip:GetDesc()
            local equip_data = equip.data
            local s = desc_fn(equip_data, self.inst, self, equip:GetId())
            str = str.."\n"..s
        end
    end
    -- str = Util:SplitSentence(str, 18, true)
    str = Util:SplitSentence(str, 20, true)
    return str
end

function CreatureEquip:GetWargonStringColour()
    return {1, .6, .3, 1}
end

function CreatureEquip:GetWargonStringFont()
    return 23
end

return CreatureEquip