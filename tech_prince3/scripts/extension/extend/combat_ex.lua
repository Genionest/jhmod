local EntUtil = require "extension.lib.ent_util"
local Util = require "extension.lib.wg_util"
local Info = Sample.Info
local FxManager = Sample.FxManager

-- 伤害类型翻译
STRINGS.TP_DMG_TYPE = {}
for k, v in pairs(Info.DmgTypeList) do
    local dmg_type = v[1]
    local str = v[2]
    STRINGS.TP_DMG_TYPE[dmg_type] = str
end

-- 战斗相关
--[[
Combat:GetAttacked(attacker, damage, weapon, stimuli)
    判断是否毒气伤害,是则中毒,并return
    船体伤害(TUNING.DO_SEA_DAMAGE_TO_BOAT=false可以关闭)
    如果没有伤害转移
        Inventory:ApplyDamage
        判断是否抵消 blocked(伤害>0, 是否无敌), 如果没有, 执行下列内容
        生命值降低, cause == attacker.prefab or "NIL"
        低于0, PushEvent("killed", data)
        Combat.onkilledbyother
    有伤害转移
        伤害转移对象执行上述内容
        PushEvent("mountattacked")
        PushEvent("mounthurt")
        PushEvent("attacked", data)
        抵消伤害 blocked=true
    如果没有抵消伤害 blocked=false
        PushEvent("attacked", data)
        Combat.onhitfn
        如果有attacker
            attacker:PushEvent("onhitother", data)
            attacker.Combat.onhitotherfn
            判断中毒
    如果抵消伤害
        PushEvent("blocked", data)
    return not blocked
]]
--[[
Combat:CalcDamage(target, weapon, multiplier)

]]
-- Inventory:ApplyDamage
local function fn(self)
    -- 攻击时减少精力值, 无论集中与否
    local DoAttack = self.DoAttack
    function self:DoAttack(target_override, weapon, projectile, stimuli, instancemult)
        self.inst:PushEvent("tp_do_attack")
        local stimuli = EntUtil:add_stimuli(stimuli, "atk")
        DoAttack(self, target_override, weapon, projectile, stimuli, instancemult)
    end
    local GetAttacked = self.GetAttacked
    function self:GetAttacked(attacker, damage, weapon, stimuli)
        -- 黑夜伤害没有伤害来源
        if attacker == nil then
            attacker = FxManager:MakeFx("combat_fx", Vector3(0,0,0))
            attacker:DoTaskInTime(1, attacker.WgRecycle)
        end
        -- 伤害类型设置
        local dmg_type = EntUtil:get_dmg_stimuli(stimuli)
        if dmg_type == nil then
            if weapon and weapon.components.weapon 
            and weapon.components.weapon.dmg_type then
                dmg_type = weapon.components.weapon.dmg_type
            elseif attacker.components.combat.get_dmg_type_fn then
                dmg_type = attacker.components.combat.get_dmg_type_fn(attacker)
            elseif attacker.components.combat.dmg_type then
                dmg_type = attacker.components.combat.dmg_type
            end
            if dmg_type then
                stimuli = EntUtil:add_stimuli(stimuli, dmg_type)
            end
        end
        -- 真实伤害(不受伤害吸收, 防御, 闪避, 暴击影响)
        if not EntUtil:in_stimuli(stimuli, "true") then
            -- 不同类型伤害吸收
            if stimuli and self.tp_dmg_type_absorb then
                for key, val in pairs(self.tp_dmg_type_absorb) do
                    if EntUtil:in_stimuli(stimuli, key) then
                        damage = damage * val
                        break
                    end
                end
            end
            -- 闪避
            if self.tp_evade
            and not EntUtil:in_stimuli(stimuli, "not_evade")
            then
                local hit_rate = attacker.components.combat.tp_hit_rate or 0
                local evade = self.tp_evade - hit_rate
                local rate = 1-150/(150+evade)
                if math.random() < rate then
                    self.inst:PushEvent("tp_evade", {attacker=attacker, weapon=weapon})
                    FxManager:MakeFx("evade", self.inst)
                    return true
                end
            end
            -- 减少攻击伤害
            if self.tp_defense then
                local penetrate = attacker.components.combat.tp_penetrate or 0
                local defense = math.max(0, self.tp_defense-penetrate)
                local rate = 1-100/(100+defense)
                damage = damage - damage*rate
            end
            -- 暴击
            if attacker and attacker.components.combat
            and attacker.components.combat.tp_crit
            and not EntUtil:in_stimuli(stimuli, "pure")
            and not EntUtil:in_stimuli(stimuli, "not_crit") then
                if math.random() < attacker.components.combat.tp_crit then
                    FxManager:MakeFx("crit", self.inst)
                    attacker:PushEvent("tp_crit", {damage = damage, target=self.inst})
                    local dmg_crit_mod = 2
                    if attacker.components.tp_player_attr then
                        dmg_crit_mod = dmg_crit_mod + attacker.components.tp_player_attr:GetCritDmgMod()
                    end
                    if attacker:HasTag("infinity_edge") then
                        dmg_crit_mod = dmg_crit_mod + .5
                    end
                    damage = damage*dmg_crit_mod
                end
            end
        end
        -- 护盾
        if self.inst.components.tp_val_sheild 
        and not self.inst.components.tp_val_sheild:IsEmpty() then
            local cur = self.inst.components.tp_val_sheild:GetCurrent()
            if damage > cur then
                self.inst.components.tp_val_sheild:DoDelta(-cur)
                damage = damage - cur
            else
                self.inst.components.tp_val_sheild:DoDelta(-damage)
                -- 希望造成仇恨
                if self.inst.components.combat.target == nil then
                    damage = 1
                else
                    -- 格挡
                    return true
                end
            end
        end
        -- 计算伤害或受到伤害触发函数
        if not EntUtil:in_stimuli(stimuli, "pure") then
            if self.attacked_calc_fns then
                for k, v in pairs(self.attacked_calc_fns) do
                    -- damage = v({damage=damage, attacker=attacker, target=self.inst, weapon=weapon, stimuli=stimuli})
                    damage = v(damage, attacker, self.inst, weapon, stimuli)
                    assert(damage~=nil, "attacked_calc_fns member function return nil value")
                end
            end
        end
        -- 攻击触发函数
        if not EntUtil:in_stimuli(stimuli, "pure") then
            local fns = attacker.components.combat.wg_on_hit_fns
            if fns then
                for k, v in pairs(fns) do
                    v(damage, attacker, self.inst, weapon, stimuli)
                end
            end
        end
        -- 将stimuli记录起来, 好让其能传到inventory:ApplyDamage
        if stimuli and self.inst.components.inventory then
            self.inst.components.inventory.temp_stimuli = stimuli
        end
        return GetAttacked(self, attacker, damage, weapon, stimuli)
    end
    -- 增加防御
    function self:AddDefenseMod(key, mod)
        if self.tp_defense_mods == nil then
            self.tp_defense_mods = {}
        end
        self.tp_defense_mods[key] = mod
        self.tp_defense = self:GetDefense()
    end
    function self:RmDefenseMod(key)
        if self.tp_defense_mods then
            self.tp_defense_mods[key] = nil
            self.tp_defense = self:GetDefense()
        end
    end
    function self:GetDefense()
        if self.tp_defense_mods then
            local mod = 0
            for k, v in pairs(self.tp_defense_mods) do
                mod = mod + v
            end
            -- 考虑到像反甲这种是基于防御系数计算伤害的
            return math.max(0, mod)  
        end
    end
    -- 护甲穿透
    function self:AddPenetrateMod(key, mod)
        if self.tp_penetrate_mods == nil then
            self.tp_penetrate_mods = {}
        end
        self.tp_penetrate_mods[key] = mod
        self.tp_penetrate = self:GetPenetrateRate()
    end
    function self:RmPenetrateMod(key)
        if self.tp_penetrate_mods then
            self.tp_penetrate_mods[key] = nil
            self.tp_penetrate = self:GetPenetrateRate()
        end
    end
    function self:GetPenetrateRate()
        if self.tp_penetrate_mods then
            local mod = 0
            for k, v in pairs(self.tp_penetrate_mods) do
                mod = mod + v
            end
            return math.max(0, mod)
        end
    end
    -- 增加暴击率
    function self:AddCritRateMod(key, mod)
        if self.tp_crit_mods == nil then
            self.tp_crit_mods = {}
        end
        self.tp_crit_mods[key] = mod
        self.tp_crit = self:GetCritRate()
    end
    function self:RmCritRateMod(key)
        if self.tp_crit_mods then
            self.tp_crit_mods[key] = nil
            self.tp_crit = self:GetCritRate()
        end
    end
    function self:GetCritRate()
        if self.tp_crit_mods then
            local mod = 0
            for k, v in pairs(self.tp_crit_mods) do
                mod = mod + v
            end
            return mod
        end
    end
    -- 增加闪避率
    function self:AddEvadeRateMod(key, mod)
        if self.tp_evade_mods == nil then
            self.tp_evade_mods = {}
        end
        self.tp_evade_mods[key] = mod
        self.tp_evade = self:GetEvadeRate()
    end
    function self:RmEvadeRateMod(key)
        if self.tp_evade_mods then
            self.tp_evade_mods[key] = nil
            self.tp_evade = self:GetEvadeRate()
        end
    end
    function self:GetEvadeRate()
        if self.tp_evade_mods then
            local mod = 0
            for k, v in pairs(self.tp_evade_mods) do
                mod = mod + v
            end
            return mod
        end
    end
    -- 命中
    function self:AddHitRateMod(key, mod)
        if self.tp_hit_rate_mods == nil then
            self.tp_hit_rate_mods = {}
        end
        self.tp_hit_rate_mods[key] = mod
        self.tp_hit_rate = self:GetHitRate()
    end
    function self:RmHitRateMod(key)
        if self.tp_hit_rate_mods then
            self.tp_hit_rate_mods[key] = nil
            self.tp_hit_rate = self:GetHitRate()
        end
    end
    function self:GetHitRate()
        if self.tp_hit_rate_mods then
            local mod = 0
            for k, v in pairs(self.tp_hit_rate_mods) do
                mod = mod + v
            end
            mod = math.min(mod, 0.99)
            return mod
        end
    end
    -- 生命偷取
    self.inst:ListenForEvent("onhitother", function(inst, data)
        if data and data.damage and data.damage>0
        and not EntUtil:in_stimuli(data.stimuli, "pure") 
        and not EntUtil:in_stimuli(data.stimuli, "not_life_steal") then
            if self.tp_life_steal then
                local amount = data.damage*self.tp_life_steal
                inst.components.health:DoDelta(amount, true, "life_steal")
                inst:PushEvent("life_steal", {amount=amount})
            end
        end
    end)
    function self:AddLifeStealRateMod(key, val)
        if self.tp_life_steal_mods == nil then
            self.tp_life_steal_mods = {}
        end
        self.tp_life_steal_mods[key] = val
        self.tp_life_steal = self:GetLifeStealRate()
    end
    function self:RmLifeStealRateMod(key)
        if self.tp_life_steal_mods then
            self.tp_life_steal_mods[key] = nil
            self.tp_life_steal = self:GetLifeStealRate()
        end
    end
    function self:GetLifeStealRate()
        if self.tp_life_steal_mods then
            local mod = 0
            for k, v in pairs(self.tp_life_steal_mods) do
                mod = mod + v
            end
            return mod
        end
    end
    -- 攻击距离buff
    local GetAttackRange = self.GetAttackRange
    function self:GetAttackRange(...)
        local range = GetAttackRange(self, ...)
        if self.tp_range_buff then
            range = range + self.tp_range_buff
        end
        return range
    end
    -- 命中距离buff
    local GetHitRange = self.GetHitRange
    function self:GetHitRange(...)
        local range = GetHitRange(self, ...)
        if self.tp_range_buff then
            range = range + self.tp_range_buff
        end
        return range
    end
    -- 不同类型的伤害吸收
    self.inst:AddComponent("combat2")
    self.tp_dmg_type_absorb = nil
    
    function self:AddDmgTypeAbsorb(key, val)
        if self.tp_dmg_type_absorb == nil then
            self.tp_dmg_type_absorb = {}
        end
        if self.tp_dmg_type_absorb[key] == nil then
            self.tp_dmg_type_absorb[key] = 1
        end
        self.tp_dmg_type_absorb[key] = self.tp_dmg_type_absorb[key]+val
    end
    function self:SetDmgTypeAbsorb(key, val)
        if self.tp_dmg_type_absorb == nil then
            self.tp_dmg_type_absorb = {}
        end
        self.tp_dmg_type_absorb[key] = val
    end
    function self:GetDmgTypeAbsorb(dmg_type)
        if self.tp_dmg_type_absorb then
            return self.tp_dmg_type_absorb[dmg_type]
        end
    end
    
    local CalcDamage = self.CalcDamage
    function self:CalcDamage(target, weapon, multiplier)
        local retDamage = 0
        retDamage = CalcDamage(self, target, weapon, multiplier)
        if self.wg_calc_damage_fns then
            for k, v in pairs(self.wg_calc_damage_fns) do
                retDamage = v(retDamage, self.inst, target, weapon)
                assert(retDamage~=nil, "wg_calc_damage_fns member function return nil value")
            end
        end
        return retDamage
    end
    -- 增加伤害计算函数 func(damage,inst,target,weapon)
    function self:WgAddCalcDamageFn(fn)
        if self.wg_calc_damage_fns == nil then
            self.wg_calc_damage_fns = {}
        end
        table.insert(self.wg_calc_damage_fns, fn)
        return fn
    end
    -- 删除伤害计算函数
    function self:WgRemoveCalcDamageFn(fn)
        local tbl = self.wg_calc_damage_fns
        if tbl then
            for k, v in pairs(tbl) do
                if fn == v then
                    table.remove(tbl, k)
                end
            end
        end
    end
    -- 增加受伤计算函数
    function self:AddAttackedCalcFn(fn)
        if self.attacked_calc_fns == nil then
            self.attacked_calc_fns = {}
        end
        table.insert(self.attacked_calc_fns, fn)
        return fn
    end
    -- 删除受伤计算函数
    function self:RemoveAttackedCalcFn(fn)
        local tbl = self.attacked_calc_fns
        if tbl then
            for k, v in pairs(tbl) do
                if fn == v then
                    table.remove(tbl, k)
                end
            end
        end
    end
    -- 增加攻击触发函数 func(damage, inst,target,weapon)
    function self:WgAddOnHitFn(fn)
        if self.wg_on_hit_fns == nil then
            self.wg_on_hit_fns = {}
        end
        table.insert(self.wg_on_hit_fns, fn)
        return fn
    end
    -- 删除攻击触发函数
    function self:WgRemoveOnHitFn(fn)
        local tbl = self.wg_on_hit_fns
        if tbl then
            for k, v in pairs(tbl) do
                if fn == v then
                    table.remove(tbl, k)
                end
            end
        end
    end
    -- 设置简单的retargetfn和keeptargetfn
    function self:SimpleTargetFn(tags, no_tags)
        self:SetRetargetFunction(3, function(inst)
            return FindEntity(inst, 16, function(target)
                if tags then
                    for k, v in pairs(tags) do
                        if not target:HasTag(v) then
                            return
                        end
                    end
                end
                if no_tags then
                    for k, v in pairs(no_tags) do
                        if target:HasTag(v) then
                            return
                        end
                    end
                end
                return inst.components.combat:CanTarget(target)
            end)
        end)
        self:SetKeepTargetFunction(function(inst, target)
            if tags then
                for k, v in pairs(tags) do
                    if not target:HasTag(v) then
                        return
                    end
                end
            end
            if no_tags then
                for k, v in pairs(no_tags) do
                    if target:HasTag(v) then
                        return
                    end
                end
            end
            return inst.components.combat:CanTarget(target)
        end)
    end
    -- 可以给没有物品栏的生物添加装备
    local GetWeapon = self.GetWeapon
    function self:GetWeapon()
        if self.tp_weapon then
            return self.tp_weapon
        end
        return GetWeapon(self)
    end
    -- 不可被选取
    local CanTarget = self.CanTarget
    function self:CanTarget(target)
        if target and target:HasTag("wg_cant_target") then
            return false
        end
        return CanTarget(self, target)
    end
    
    -- function self:GetWargonString()
    --     if self.inst:HasTag("wall") then
    --         return
    --     end
    --     local defense = self.tp_defense or 0
    --     local def_ab = 1-100/(100+defense)
    --     local dmg_mult = self:GetDamageModifier()
    --     local penetrate = self.tp_penetrate or 0
    --     local atk_spd = self:GetPeriodModifier()
    --     local crit = self.tp_crit or 0
    --     -- local evade = self.tp_evade or 0
    --     -- local evd_ab = 1-150/(150+evade)
    --     -- local hit_rate = self.tp_hit_rate or 0
    --     -- local life_steal = self.tp_life_steal or 0
    --     local weapon = self:GetWeapon()
    --     local dmg
    --     if weapon then
    --         dmg = weapon.components.weapon:GetDamage() * dmg_mult
    --     else
    --         dmg = self.defaultdamage * dmg_mult
    --     end
    --     local s = string.format("伤害:%d,攻速:%d%%",
    --         dmg, atk_spd*100, crit*100)
    --     s = s..string.format("\n防御:%d(%d%%),穿透:%d",
    --         defense, def_ab*100, penetrate)
    --     -- local s = string.format("伤害:%d%%,攻速:%d%%,暴击:%d%%,", 
    --     --     dmg_mult*100, -atk_spd*100, crit*100 )
    --     -- s = s..string.format("\n防御:%d(%d%%),闪避:%d(%d%%),吸血:%d%%,", 
    --     --     defense, def_ab*100, evade, evd_ab*100, life_steal*100)
    --     -- s = s..string.format("\n命中:%d,穿透:%d,", 
    --     --     hit_rate, penetrate)
    
    --     -- if self.inst:HasTag("world_boss") then
    --     --     s = s.."(世界Boss)"
    --     -- elseif self.inst:HasTag("epic") then
    --     --     s = s.."(史诗)"
    --     -- elseif self.inst:HasTag("largecreature") then
    --     --     s = s.."(大型生物)"
    --     -- elseif self.inst:HasTag("monster") then
    --     --     s = s.."(怪物)"
    --     -- end
    --     s = Util:SplitSentence(s, 17, true)
    --     return s
    -- end
    
    -- function self:GetWargonStringColour()
    --     return {255/255, 69/255, 0/255, 1}
    -- end
end
AddComponentPostInit("combat", fn)

-- 玩家攻速
local function fn(sg)
    local attack_onenter = sg.states.attack.onenter
    sg.states.attack.onenter = function(inst, ...)
        attack_onenter(inst, ...)
        -- 慢武器不加攻速
        if not inst.sg.statemem.slow and not inst.sg.statemem.slowweapon
        and inst.components.combat:GetWeapon() then
            inst.sg.statemem.wg_fix_timeline = true
            local mod = inst.components.combat and inst.components.combat:GetPeriodModifier()
            if mod<0 then
                -- local cooldown = math.max(8, 13*(1-mod)) * FRAMES
                local cooldown = 13*(1+mod) * FRAMES
                inst.sg:SetTimeout(cooldown)
                inst.AnimState:SetDeltaTimeMultiplier(1-mod)
                local timeline = sg.states.attack.timeline
                timeline[1].time = 8*(1+mod)*FRAMES
                timeline[2].time = 12*(1+mod)*FRAMES
            end
        end
    end
    local attack_onexit = sg.states.attack.onexit
    sg.states.attack.onexit = function(inst, ...)
        if attack_onexit then
            attack_onexit(inst, ...)
        end
        -- inst.sg:RemoveStateTag("attack")
        if inst.sg.statemem.wg_fix_timeline then
            inst.AnimState:SetDeltaTimeMultiplier(1)
            local timeline = sg.states.attack.timeline
            timeline[1].time = 8*FRAMES
            timeline[2].time = 12*FRAMES
        end
    end
end
AddStategraphPostInit("wilson", fn)
AddStategraphPostInit("wilsonboating", fn)