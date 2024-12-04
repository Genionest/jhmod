local EntUtil = require "extension.lib.ent_util"
local Kit = require "extension.lib.wargon"
local FxManager = Sample.FxManager
local BuffManager = Sample.BuffManager

local EnchantmentData = Class(function(self)
end)

--[[
创建附魔类  
(EnchantmentData) 返回  
id (string) 名字  
init (func) 初始函数  
fn (func) 执行函数  
test (func) 条件函数  
desc (func) 描述函数  
]]
local function Enchantment(id, init, fn, test, desc)
    local self = EnchantmentData()
    self.id = id
    self.init = init
    self.fn = fn
    self.test = test
    self.desc = desc
    return self
end

function EnchantmentData:GetId()
    return self.id
end

function EnchantmentData:__tostring()
    return string.format("EnchantmentData(%s)", self.id)
end

local enchant_weapon = {
    Enchantment(
        "giant_chop",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 6, 5 * cmp.quality, 1.3, 30, 8 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("巨人劈砍:消耗%d魔法,增大体型,对敌人造成%d+%d%%自身攻击力的伤害,对小型单位额外造成%d点伤害",
                    cmp.datas[id][5], cmp.datas[id][2], cmp.datas[id][3] * 100, cmp.datas[id][4])
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][5] then
                        return true
                    end
                end
            end
            -- inst.components.wg_action_tool.get_action_fn = function(inst, data)
            --     -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
            -- end
            inst.components.wg_action_tool.click_fn = function(inst, doer)
                -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
                local data = inst.components.wg_action_tool:GetActionData()
                if data.pos or data.target then
                    local ba = BufferedAction(data.doer, data.target, ACTIONS.TP_CHOP, inst, data.pos)
                    doer:PushBufferedAction(ba)
                    doer.components.tp_body_size:AddSizeMod(id, .2)
                end
            end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][5])
                EntUtil:make_area_dmg(doer, 4, doer, cmp.datas[id][2],
                    inst, EntUtil:add_stimuli(nil, "pure"), {
                        calc = true,
                        mult = cmp.datas[id][3],
                        fn = function(v, attacker, weapon)
                            if v:HasTag("smallcreature") then
                                EntUtil:get_attacked(v, attacker, cmp.datas[id][4], nil,
                                    EntUtil:add_stimuli(nil, "pure", "not_evade"))
                            end
                        end,
                    })
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
                inst:DoTaskInTime(.5, function()
                    doer.components.tp_body_size:RmSizeMod(id)
                end)
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and inst.components.wg_action_tool == nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:无技能武器]获得技能巨人劈砍")
        end
    ),
    Enchantment(
        "frozen_route",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 10 - cmp.quality, cmp.quality * 30, 15 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_reticule")
            inst.components.wg_reticule.reticule_prefab = "wg_reticulearc"
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("霜冻路径:消耗%d魔法,释放一段扇形的前进的冰锥,对经过的敌人造成%d的伤害并施加1层冰冻效果",
                    cmp.datas[id][3], cmp.datas[id][2])
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][3] then
                        return true
                    end
                end
            end
            inst.components.wg_action_tool.get_action_fn = function(inst, data)
                -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
                if inst.components.wg_reticule:IsShown() then
                    if data.pos or data.target then
                        return ACTIONS.TP_SHOVEL
                    end
                end
            end
            inst.components.wg_action_tool.click_fn = function(inst, doer)
                -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
                inst.components.wg_reticule:Toggle()
            end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][3])
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
                if target then
                    pos = target:GetPosition()
                end
                FxManager:MakeFx("frozen_route", doer, {
                    pos = pos, owner = doer, damage = cmp.datas[id][2]
                })
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and inst.components.wg_action_tool == nil
            -- and cmp.quality and cmp.quality>=3
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:无技能武器]获得技能霜冻路径")
        end
    ),
    Enchantment(
        "sleep_fire",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 7, cmp.quality * 15, 12 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_reticule")
            inst.components.wg_reticule.reticule_prefab = "wg_reticulearc"
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("催眠火焰:消耗%d魔法,释放多个火焰,催眠命中的敌人,并造成%d点伤害",
                    cmp.datas[id][3], cmp.datas[id][2])
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][3] then
                        return true
                    end
                end
            end
            inst.components.wg_action_tool.get_action_fn = function(inst, data)
                -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
                if inst.components.wg_reticule:IsShown() then
                    if data.pos or data.target then
                        return ACTIONS.TP_ATTACK_PROP
                    end
                end
            end
            inst.components.wg_action_tool.click_fn = function(inst, doer)
                -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
                inst.components.wg_reticule:Toggle()
            end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][3])
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
                if target then
                    pos = target:GetPosition()
                end
                FxManager:MakeFx("sleep_fire", doer, {
                    pos = pos, owner = doer, damage = cmp.datas[id][2]
                })
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and inst.components.wg_action_tool == nil
            -- and cmp.quality and cmp.quality>=3
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:无技能武器]获得技能催眠火焰")
        end
    ),
    Enchantment(
        "thunder_rain",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 15, cmp.quality * 10, .75, 15 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("雷霆之雨:消耗%d魔法,召唤闪电攻击周围的敌人(最多8名),造成%d+%d%%自身攻击力的伤害",
                    cmp.datas[id][4], cmp.datas[id][2], cmp.datas[id][3] * 100)
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][4] then
                        return true
                    end
                end
            end
            inst.components.wg_action_tool.click_get_action_fn = function(inst, data)
                -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
                if data.pos or data.target then
                    return ACTIONS.TP_SAIL
                end
            end
            -- inst.components.wg_action_tool.click_fn = function(inst, doer)
            --     -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
            -- end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][4])
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
                local n = 0
                EntUtil:make_area_dmg(doer, 8, doer, cmp.datas[id][2], inst,
                    EntUtil:add_stimuli(nil, "pure"), {
                        calc = true,
                        mult = cmp.datas[id][3],
                        fn = function(v, attacker, weapon)
                            FxManager:MakeFx("lightning", v)
                            n = n + 1
                        end,
                        test = function(v, attacker, weapon)
                            return n < 8
                        end,
                    })
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and inst.components.wg_action_tool == nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:无技能武器]获得技能雷霆之雨")
        end
    ),
    Enchantment(
        "broken_heavy_attack",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 8, cmp.quality * 10, 1.35, 10 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("破碎重击:消耗%d魔法,对周围的敌人造成%d%%自身攻击力的伤害,并降低其防御",
                    cmp.datas[id][4], cmp.datas[id][3] * 100)
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][4] then
                        return true
                    end
                end
            end
            -- inst.components.wg_action_tool.get_action_fn = function(inst, data)
            --     -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
            -- end
            inst.components.wg_action_tool.click_fn = function(inst, doer)
                -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
                local data = inst.components.wg_action_tool:GetActionData()
                if data.pos or data.target then
                    local ba = BufferedAction(data.doer, data.target, ACTIONS.TP_MINE, inst, data.pos)
                    doer:PushBufferedAction(ba)
                end
            end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][4])
                EntUtil:make_area_dmg(doer, 3, doer, 0,
                    inst, EntUtil:add_stimuli(nil, "pure"), {
                        calc = true,
                        mult = cmp.datas[id][3],
                        fn = function(v, attacker, weapon)
                            BuffManager:AddBuff(v, id .. "_debuff", nil, cmp.datas[id][2])
                        end,
                    })
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and inst.components.wg_action_tool == nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:无技能武器]获得技能破碎重击")
        end
    ),
    Enchantment(
        "lunge",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 6, 1 + .1 * cmp.quality, 4 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_reticule")
            inst.components.wg_reticule.reticule_prefab = "wg_reticuleline"
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("突刺:消耗%d魔法,向前突刺,对沿途敌人造成%d%%自身攻击力的伤害",
                    cmp.datas[id][3], cmp.datas[id][2] * 100)
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][3] then
                        return true
                    end
                end
            end
            inst.components.wg_action_tool.get_action_fn = function(inst, data)
                -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
                if inst.components.wg_reticule:IsShown() then
                    if data.pos or data.target then
                        return ACTIONS.TP_LUNGE
                    end
                end
            end
            inst.components.wg_action_tool.click_fn = function(inst, doer)
                -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
                inst.components.wg_reticule:Toggle()
            end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][3])
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
                local enemies = {}
                for i = 1, 3 do
                    doer:DoTaskInTime(.1 * i, function()
                        EntUtil:make_area_dmg(doer, 3, doer, 0, inst,
                            EntUtil:add_stimuli(nil, "pure"), {
                                calc = true,
                                mult = cmp.datas[id][2],
                                fn = function(v, attacker, weapon)
                                    enemies[v] = true
                                end,
                                test = function(v, attacker, weapon)
                                    return enemies[v] == nil
                                end,
                            })
                    end)
                end
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and inst.components.wg_action_tool == nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:无技能武器]获得技能突刺")
        end
    ),
    Enchantment(
        "fire_lunge",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 7, .5 + .3 * cmp.quality, 6 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_reticule")
            inst.components.wg_reticule.reticule_prefab = "wg_reticuleline"
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("烈焰突刺:消耗%d魔法,向前突刺,对沿途敌人造成%d%%自身攻击力的伤害并点燃",
                    cmp.datas[id][3], cmp.datas[id][2] * 100)
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][3] then
                        return true
                    end
                end
            end
            inst.components.wg_action_tool.get_action_fn = function(inst, data)
                -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
                if inst.components.wg_reticule:IsShown() then
                    if data.pos or data.target then
                        return ACTIONS.TP_LUNGE
                    end
                end
            end
            inst.components.wg_action_tool.click_fn = function(inst, doer)
                -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
                inst.components.wg_reticule:Toggle()
            end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][3])
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
                local enemies = {}
                for i = 1, 3 do
                    doer:DoTaskInTime(.1 * i, function()
                        EntUtil:make_area_dmg(doer, 3, doer, 0, inst,
                            EntUtil:add_stimuli(nil, "pure"), {
                                calc = true,
                                mult = cmp.datas[id][2],
                                fn = function(v, attacker, weapon)
                                    enemies[v] = true
                                    EntUtil:ignite(v)
                                end,
                                test = function(v, attacker, weapon)
                                    return enemies[v] == nil
                                end,
                            })
                    end)
                end
                if target then
                    pos = target:GetPosition()
                end
                local fx = FxManager:MakeFx("laser_line", doer, { pos = pos })
                fx:DoTaskInTime(.4, fx.WgRecycle)
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and inst.components.wg_action_tool == nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:无技能武器]获得技能烈焰突刺")
        end
    ),
    Enchantment(
        "mult_blowdart",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 10, .1 + .05 * cmp.quality, 10 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_reticule")
            inst.components.wg_reticule.reticule_prefab = "wg_reticuleline"
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("多重吹箭:消耗%d魔法,射出多个吹箭,每个吹箭对敌人造成%d%%自身攻击力的伤害",
                    cmp.datas[id][3], cmp.datas[id][2] * 100)
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][3] then
                        return true
                    end
                end
            end
            inst.components.wg_action_tool.get_action_fn = function(inst, data)
                -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
                if inst.components.wg_reticule:IsShown() then
                    if data.pos or data.target then
                        return ACTIONS.TP_BLOWDART
                    end
                end
            end
            inst.components.wg_action_tool.click_fn = function(inst, doer)
                -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
                inst.components.wg_reticule:Toggle()
            end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][3])
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
                if target then
                    pos = target:GetPosition()
                end
                FxManager:MakeFx("mult_blowdart", doer, {
                    pos = pos, owner = doer, weapon = inst, dmg_mod = cmp.datas[id][2]
                })
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and inst.components.wg_action_tool == nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:无技能武器]获得技能多重吹箭")
        end
    ),
    Enchantment(
        "flash_weapon",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 5 - .2 * cmp.quality, 5 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("闪烁:消耗%d魔法,位移到目标位置",
                    cmp.datas[id][2])
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][2] then
                        return true
                    end
                end
            end
            inst.components.wg_action_tool.click_get_action_fn = function(inst, data)
                -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
                if data.pos then
                    return ACTIONS.TP_ATK
                end
            end
            -- inst.components.wg_action_tool.click_fn = function(inst, doer)
            -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
            -- end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][2])
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
                FxManager:MakeFx("statue_transition", doer)
                doer.SoundEmitter:PlaySound("dontstarve/common/staff_blink")
                doer:Hide()
                if doer.components.health then
                    doer.components.health:SetInvincible(true, id)
                end
                doer:DoTaskInTime(0.25, function()
                    FxManager:MakeFx("statue_transition_2", pos)
                    if doer.components.health then
                        doer.components.health:SetInvincible(false, id)
                    end
                    doer.Transform:SetPosition(pos:Get())
                    doer:Show()
                    doer.SoundEmitter:PlaySound("dontstarve/common/staff_blink")
                end)
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and inst.components.wg_action_tool == nil
                and cmp.quality and cmp.quality >= 3
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:无技能武器,品质达到3]获得技能闪烁")
        end
    ),
    Enchantment(
        "dodge_weaopn",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 3 - .2 * cmp.quality, 3 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("滑铲:消耗%d魔法,进行滑铲",
                    cmp.datas[id][2])
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][2] then
                        return true
                    end
                end
            end
            inst.components.wg_action_tool.click_get_action_fn = function(inst, data)
                -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
                if data.pos or data.target then
                    return ACTIONS.WG_DODGE
                end
            end
            -- inst.components.wg_action_tool.click_fn = function(inst, doer)
            -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
            -- end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][2])
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and inst.components.wg_action_tool == nil
                and cmp.quality and cmp.quality >= 3
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:无技能武器,品质达到3]获得技能滑铲")
        end
    ),
    Enchantment(
        "counterattack_spiral",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 8, cmp.quality * 20, 12 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("反击螺旋:消耗%d魔法,旋转武器,获得100%%闪避,(闪避攻击增加移速)旋转结束后对周围的敌人造成%d伤害",
                    cmp.datas[id][3], cmp.datas[id][2])
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][2] then
                        return true
                    end
                end
            end
            inst.components.wg_action_tool.click_get_action_fn = function(inst, data)
                -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
                if data.pos or data.target then
                    return ACTIONS.TP_SPIRAL
                end
            end
            -- inst.components.wg_action_tool.click_fn = function(inst, doer)
            -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
            -- end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][3])
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
                EntUtil:make_area_dmg(doer, 4, doer, cmp.datas[id][2], nil,
                    EntUtil:add_stimuli(nil, "pure"))
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and inst.components.wg_action_tool == nil
                and cmp.quality and cmp.quality >= 2
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:无技能武器,品质达到2]获得技能反击螺旋")
        end
    ),
    Enchantment(
        "determination",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 5, cmp.quality * .15, 5 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
            end
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("决心:消耗%d魔法,下次攻击提升%d%%攻击",
                    cmp.datas[id][3], cmp.datas[id][2] * 100)
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][3] then
                        return true
                    end
                end
            end
            inst.components.wg_action_tool.click_get_action_fn = function(inst, data)
                -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
                if data.pos or data.target then
                    return ACTIONS.TP_SAIL
                end
            end
            -- inst.components.wg_action_tool.click_fn = function(inst, doer)
            --     -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
            -- end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                FxManager:MakeFx("firework_fx", doer)
                doer.components.tp_mana:DoDelta(-cmp.datas[id][3])
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1])
                BuffManager:AddBuff(doer, id, nil, cmp.datas[id][2])
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and inst.components.wg_action_tool == nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:无技能武器]获得技能决心")
        end
    ),
    Enchantment(
        "penetrate_up",
        function(self, inst, cmp, id)
            cmp.datas[id] = { cmp.quality * .03 + .05 }
        end,
        function(self, inst, cmp, id)
            inst.components.equippable:WgAddEquipFn(function(inst, owner)
                local key = inst.components.equippable.equipslot .. "_slot"
                owner.components.combat:AddPenetrateMod(key, cmp.datas[id][1])
            end)
            inst.components.equippable:WgAddUnequipFn(function(inst, owner)
                local key = inst.components.equippable.equipslot .. "_slot"
                owner.components.combat:RmPenetrateMod(key)
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            local datas = cmp.datas
            return string.format("[要求:武器]增加%d%%穿透", datas[id][1] * 100)
        end
    ),
    Enchantment(
        "hit_rate_up",
        function(self, inst, cmp, id)
            cmp.datas[id] = { cmp.quality * .03 + .05 }
        end,
        function(self, inst, cmp, id)
            inst.components.equippable:WgAddEquipFn(function(inst, owner)
                local key = inst.components.equippable.equipslot .. "_slot"
                owner.components.combat:AddHitRateMod(key, cmp.datas[id][1])
            end)
            inst.components.equippable:WgAddUnequipFn(function(inst, owner)
                local key = inst.components.equippable.equipslot .. "_slot"
                owner.components.combat:RmHitRateMod(key)
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            local datas = cmp.datas
            return string.format("[要求:武器]增加%d%%命中率", datas[id][1] * 100)
        end
    ),
    Enchantment(
        "damage",
        function(self, inst, cmp, id)
            local min, max = 10 + cmp.quality * 2, 15 + cmp.quality * 3
            cmp.datas[id] = { math.random(min, max) }
        end,
        function(self, inst, cmp, id)
            if inst.components.weapon then
                inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
                    local datas = cmp.datas
                    return damage + (datas[id][1] or 0)
                end)
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            local datas = cmp.datas
            return string.format("[要求:武器]增加%d点伤害", datas[id][1] or 0)
        end
    ),
    Enchantment(
        "damage_percent",
        function(self, inst, cmp, id)
            cmp.datas[id] = { .02 + .006 * cmp.quality, 50, 200 }
        end,
        function(self, inst, cmp, id)
            if inst.components.weapon then
                inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
                    local dmg = math.min(cmp.datas[id][3], damage)
                    local p = (dmg / cmp.datas[id][2]) * cmp.datas[id][1]
                    damage = damage + damage * p
                    return damage
                end)
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:武器]武器每有%d点攻击(大于%d视为%d),增加%.1f%%攻击",
                D[2], D[3], D[3], D[1] * 100)
        end
    ),
    Enchantment(
        "crit_weapon",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 100, .02 + .006 * cmp.quality, 300 }
        end,
        function(self, inst, cmp, id)
            if inst.components.weapon then
                inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
                    local dmg = math.min(damage, cmp.datas[id][3])
                    local rate = (dmg / cmp.datas[id][1]) * cmp.datas[id][2]
                    if math.random() < rate then
                        damage = damage * 2
                    end
                    return damage
                end)
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:武器]武器每有%d攻击(大于%d视为%d),便有%.2f%%的几率造成双倍伤害",
                D[1], D[3], D[3], D[2] * 100)
        end
    ),
    Enchantment(
        "frozen_weapon",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 2, cmp.quality * 5
            cmp.datas[id] = { math.random(min, max) / 100 }
        end,
        function(self, inst, cmp, id)
            inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
                if math.random() < cmp.datas[id][1] then
                    EntUtil:frozen(target)
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:武器]攻击有%d%%几率对敌人施加1层冰冻效果", D[1] * 100)
        end
    ),
    Enchantment(
        "ignite_weapon",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 3, cmp.quality * 6
            cmp.datas[id] = { math.random(min, max) / 100 }
        end,
        function(self, inst, cmp, id)
            inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
                if math.random() < cmp.datas[id][1] then
                    EntUtil:ignite(target)
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:武器]攻击有%d%%几率点燃敌人", D[1] * 100)
        end
    ),
    Enchantment(
        "poison_weapon",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 3, cmp.quality * 6
            cmp.datas[id] = { math.random(min, max) / 100 }
        end,
        function(self, inst, cmp, id)
            inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
                if math.random() < cmp.datas[id][1] then
                    EntUtil:poison(target)
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:武器]攻击有%d%%几率令敌人中毒", D[1] * 100)
        end
    ),
    Enchantment(
        "attack_fire",
        function(self, inst, cmp, id)
            local arg = cmp.quality
            local min, max = arg * 3 + 5, arg * 5 + 10
            cmp.datas[id] = { math.random(min, max) }
        end,
        function(self, inst, cmp, id)
            inst.components.equippable:WgAddEquipFn(function(inst, owner)
                if cmp[id .. "_fn"] == nil then
                    cmp[id .. "_fn"] = owner.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
                        local data = { damage = damage, inst = inst, target = target, weapon = weapon }
                        local damage = data.damage
                        if data.target
                            and EntUtil:is_burning(data.target) then
                            damage = damage + cmp.datas[id][1]
                        end
                        return damage
                    end)
                end
            end)
            inst.components.equippable:WgAddUnequipFn(function(inst, owner)
                if cmp[id .. "_fn"] then
                    owner.components.combat:WgRemoveCalcDamageFn(cmp[id .. "_fn"])
                    cmp[id .. "_fn"] = nil
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:武器]攻击燃烧的敌人额外造成%d点伤害", D[1])
        end
    ),
    Enchantment(
        "attack_frozen",
        function(self, inst, cmp, id)
            local arg = cmp.quality
            local min, max = arg * 3 + 10, arg * 5 + 20
            cmp.datas[id] = { math.random(min, max) }
        end,
        function(self, inst, cmp, id)
            inst.components.equippable:WgAddEquipFn(function(inst, owner)
                if cmp[id .. "_fn"] == nil then
                    cmp[id .. "_fn"] = owner.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
                        local data = { damage = damage, inst = inst, target = target, weapon = weapon }
                        local damage = data.damage
                        if data.target
                            and EntUtil:is_frozen(data.target) then
                            damage = damage + cmp.datas[id][1]
                        end
                        return damage
                    end)
                end
            end)
            inst.components.equippable:WgAddUnequipFn(function(inst, owner)
                if cmp[id .. "_fn"] then
                    owner.components.combat:WgRemoveCalcDamageFn(cmp[id .. "_fn"])
                    cmp[id .. "_fn"] = nil
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:武器]攻击冰冻的敌人额外造成%d点伤害", cmp.datas[id][1])
        end
    ),
    Enchantment(
        "attack_poison",
        function(self, inst, cmp, id)
            local arg = cmp.quality
            local min, max = arg * 2 + 5, arg * 4 + 10
            cmp.datas[id] = { math.random(min, max) }
        end,
        function(self, inst, cmp, id)
            inst.components.equippable:WgAddEquipFn(function(inst, owner)
                if cmp[id .. "_fn"] == nil then
                    cmp[id .. "_fn"] = owner.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
                        local data = { damage = damage, inst = inst, target = target, weapon = weapon }
                        local damage = data.damage
                        if data.target
                            and EntUtil:is_poisoned(data.target) then
                            damage = damage + cmp.datas[id][1]
                        end
                        return damage
                    end)
                end
            end)
            inst.components.equippable:WgAddUnequipFn(function(inst, owner)
                if cmp[id .. "_fn"] then
                    owner.components.combat:WgRemoveCalcDamageFn(cmp[id .. "_fn"])
                    cmp[id .. "_fn"] = nil
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:武器]攻击中毒的敌人额外造成%d点伤害", cmp.datas[id][1])
        end
    ),
    Enchantment(
        "frozen_spread_weapon",
        function(self, inst, cmp, id)
            -- cmp.quality = 3
        end,
        function(self, inst, cmp, id)
            inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
                if EntUtil:is_frozen(target) then
                    FxManager:MakeFx("thorns_blue", target)
                    local x, y, z = target:GetPosition():Get()
                    local ents = TheSim:FindEntities(x, y, z, 6, nil, EntUtil.constants.not_enemy_tags)
                    for k, v in pairs(ents) do
                        if v ~= target then
                            EntUtil:frozen(v)
                        end
                    end
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and cmp.quality and cmp.quality >= 3
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:武器,品质达到3]攻击冰冻的敌人会对冰冻周围的敌人施加1层冰冻效果")
        end
    ),
    Enchantment(
        "fire_spread_weapon",
        function(self, inst, cmp, id)
            -- cmp.quality = 3
        end,
        function(self, inst, cmp, id)
            inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
                if EntUtil:is_burning(target) then
                    FxManager:MakeFx("firesplash_fx", target)
                    EntUtil:make_area_dmg2(target, 6, owner, 30, nil,
                        EntUtil:add_stimuli(nil, "pure"))
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and cmp.quality and cmp.quality >= 3
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:武器,品质达到3]攻击燃烧的敌人会对周围的敌人造成伤害并点燃")
        end
    ),
    Enchantment(
        "poison_spread_weapon",
        function(self, inst, cmp, id)
            -- cmp.quality = 3
        end,
        function(self, inst, cmp, id)
            inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
                if WARGON:is_poison(target) then
                    FxManager:MakeFx("thorns_green", target)
                    EntUtil:make_area_dmg2(target, 6, owner, 10, nil,
                        EntUtil:add_stimuli(nil, "pure"), {
                            fn = function(v, attacker, weapon)
                                EntUtil:poison(v)
                            end,
                        })
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
                and cmp.quality and cmp.quality >= 3
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:武器,品质达到3]攻击中毒的敌人会对周围的敌人造成伤害并令其中毒")
        end
    ),
    Enchantment(
        "slow_down_weapon",
        function(self, inst, cmp, id)
            local min, max = cmp.quality + 15, cmp.quality + 35
            local min2, max2 = cmp.quality * 3 + 10, cmp.quality * 5 + 15
            cmp.datas[id] = { math.random(min, max) / 100, math.random(min2, max2) / 100 }
        end,
        function(self, inst, cmp, id)
            inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
                if math.random() < cmp.datas[id][1] then
                    EntUtil:add_speed_mod(target, id, -cmp.datas[id][2], 5)
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:武器]攻击有%d%%几率令敌人减速%d%%", cmp.datas[id][1] * 100, cmp.datas[id][2] * 100)
        end
    ),
    Enchantment(
        "speed_weapon",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 2 + 20, cmp.quality * 3 + 35
            local min2, max2 = cmp.quality * 3 + 5, cmp.quality * 5 + 10
            cmp.datas[id] = { math.random(min, max) / 100, math.random(min2, max2) / 100 }
        end,
        function(self, inst, cmp, id)
            inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
                if math.random() < cmp.datas[id][1] then
                    EntUtil:add_speed_mod(owner, id, cmp.datas[id][2], 5)
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:武器]攻击有%d%%几率增加%d%%移速", cmp.datas[id][1] * 100, cmp.datas[id][2] * 100)
        end
    ),
    Enchantment(
        "blood_weapon",
        function(self, inst, cmp, id)
            local min, max = cmp.quality + 10, cmp.quality + 25
            cmp.datas[id] = { math.random(min, max) / 100, math.random(min, max) }
        end,
        function(self, inst, cmp, id)
            cmp[id .. "_fn"] = function(owner, data)
                if data and data.damage then
                    if math.random() < cmp.datas[id][1] and EntUtil:is_alive(owner) then
                        owner.components.health:DoDelta(cmp.datas[id][2])
                    end
                end
            end
            inst.components.equippable:WgAddEquipFn(function(inst, owner)
                inst:ListenForEvent("onhitother", cmp[id .. "_fn"], owner)
            end)
            inst.components.equippable:WgAddUnequipFn(function(inst, owner)
                inst:RemoveEventCallback("onhitother", cmp[id .. "_fn"], owner)
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            local data = cmp.datas[id]
            return string.format("[要求:武器]攻击有%d%%的几率回复%d的血量", data[1] * 100, data[2])
        end
    ),
    Enchantment(
        "sanity_weapon",
        function(self, inst, cmp, id)
            local min, max = cmp.quality + 10, cmp.quality + 25
            cmp.datas[id] = { math.random(min, max) / 100, math.random(min, max) }
        end,
        function(self, inst, cmp, id)
            cmp[id .. "_fn"] = function(owner, data)
                if data and data.damage then
                    if math.random() < cmp.datas[id][1] and owner.components.sanity then
                        owner.components.sanity:DoDelta(cmp.datas[id][2])
                    end
                end
            end
            inst.components.equippable:WgAddEquipFn(function(inst, owner)
                inst:ListenForEvent("onhitother", cmp[id .. "_fn"], owner)
            end)
            inst.components.equippable:WgAddUnequipFn(function(inst, owner)
                inst:RemoveEventCallback("onhitother", cmp[id .. "_fn"], owner)
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            local data = cmp.datas[id]
            return string.format("[要求:武器]攻击有%d%%的几率回复%d的理智", data[1] * 100, data[2])
        end
    ),
    Enchantment(
        "boom_weapon",
        function(self, inst, cmp, id)
            local min, max = cmp.quality + 10, cmp.quality * 2 + 15
            cmp.datas[id] = { math.random(min, max) / 100, cmp.quality * 15 + 25 }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
                if math.random() < D[1] then
                    local pos = Kit:find_ground_pos(owner, math.random(3, 6))
                    if pos then
                        local cannon = SpawnPrefab("tp_cannon_shot")
                        cannon.Transform:SetPosition(owner.Transform:GetPosition():Get())
                        cannon.components.explosive.explosivedamage = cmp.datas[id][2]
                        cannon.components.throwable:Throw(pos, owner)
                    end
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:武器]攻击时有%d%%几率丢出一枚炸弹，造成%d点伤害", D[1] * 100, D[2])
        end
    ),
    Enchantment(
        "kill_boom",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 3 + 10, cmp.quality * 6 + 15
            local min2, max2 = cmp.quality * 3 + 10, cmp.quality * 6 + 15
            cmp.datas[id] = { math.random(min, max) / 100, math.random(min2, max2) }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            cmp[id .. "_fn"] = function(owner, data)
                if math.random() < D[1] and data and data.victim then
                    if data.victim:RemoveTag("wall") then
                        FxManager:MakeFx("explodering_fx", data.victim)
                        EntUtil:make_area_dmg2(data.victim, 4, owner, D[2], nil,
                            EntUtil:add_stimuli(nil, "pure"))
                    end
                end
            end
            inst.components.equippable:WgAddEquipFn(function(inst, owner)
                inst:ListenForEvent("killed", cmp[id .. "_fn"], owner)
            end)
            inst.components.equippable:WgAddUnequipFn(function(inst, owner)
                inst:RemoveEventCallback("killed", cmp[id .. "_fn"], owner)
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:武器]杀死敌人有%d%%几率爆炸造成%d点伤害", D[1] * 100, D[2])
        end
    ),
    -- Enchantment(
    --     "fire_elem",
    --     function(self, inst, cmp, id)
    --         cmp.datas[id] = { 10 + cmp.quality * 10 }
    --     end,
    --     function(self, inst, cmp, id)
    --         local D = cmp.datas[id]
    --         inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
    --             return math.max(0, damage - D[1])
    --         end)
    --         inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
    --             EntUtil:get_attacked(target, owner, D[1], nil, 
    --                 EntUtil:add_stimuli(nil, "fire", "pure") )
    --             if math.random() < .1 then
    --                 EntUtil:ignite(target)
    --             end
    --         end)
    --     end,
    --     function(self, inst, cmp, id)
    --         return inst.components.weapon ~= nil
    --             and inst.compoents.tp_forge_level ~= nil
    --     end,
    --     function(self, inst, cmp, id)
    --         local D = cmp.datas[id]
    --         return string.format("[要求:武器,锻造]造成%d点火属性伤害,减少%d点伤害;5%%概率点燃敌人", D[1], D[1])
    --     end
    -- ),
    -- Enchantment(
    --     "ice_elem",
    --     function(self, inst, cmp, id)
    --         cmp.datas[id] = { 10 + cmp.quality * 10 }
    --     end,
    --     function(self, inst, cmp, id)
    --         local D = cmp.datas[id]
    --         inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
    --             return math.max(0, damage - D[1])
    --         end)
    --         inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
    --             EntUtil:get_attacked(target, owner, D[1], nil, 
    --                 EntUtil:add_stimuli(nil, "ice", "pure") )
    --             if math.random() < .1 then
    --                 EntUtil:frozen(target)
    --             end
    --         end)
    --     end,
    --     function(self, inst, cmp, id)
    --         return inst.components.weapon ~= nil
    --             and inst.compoents.tp_forge_level ~= nil
    --     end,
    --     function(self, inst, cmp, id)
    --         local D = cmp.datas[id]
    --         return string.format("[要求:武器,锻造]造成%d点冰属性伤害,减少%d点伤害;10%%概率冰冻敌人", D[1], D[1])
    --     end
    -- ),
    -- Enchantment(
    --     "electric_elem",
    --     function(self, inst, cmp, id)
    --         cmp.datas[id] = { 10 + cmp.quality * 10 }
    --     end,
    --     function(self, inst, cmp, id)
    --         local D = cmp.datas[id]
    --         inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
    --             return math.max(0, damage - D[1])
    --         end)
    --         inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
    --             EntUtil:get_attacked(target, owner, D[1], nil, 
    --                 EntUtil:add_stimuli(nil, "electric", "pure") )
    --             if math.random() < .1 then
    --                 BuffManager:AddBuff(target, "electric")
    --             end
    --         end)
    --     end,
    --     function(self, inst, cmp, id)
    --         return inst.components.weapon ~= nil
    --             and inst.compoents.tp_forge_level ~= nil
    --     end,
    --     function(self, inst, cmp, id)
    --         local D = cmp.datas[id]
    --         return string.format("[要求:武器,锻造]造成%d点雷属性伤害,减少%d点伤害;10%%概率令敌人导电", D[1], D[1])
    --     end
    -- ),
    -- Enchantment(
    --     "blood_elem",
    --     function(self, inst, cmp, id)
    --         cmp.datas[id] = { 10 + cmp.quality * 10 }
    --     end,
    --     function(self, inst, cmp, id)
    --         local D = cmp.datas[id]
    --         inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
    --             return math.max(0, damage - D[1])
    --         end)
    --         inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
    --             EntUtil:get_attacked(target, owner, D[1], nil, 
    --                 EntUtil:add_stimuli(nil, "blood", "pure") )
    --             if math.random() < .1 then
    --                 BuffManager:AddBuff(target, "blood")
    --             end
    --         end)
    --     end,
    --     function(self, inst, cmp, id)
    --         return inst.components.weapon ~= nil
    --             and inst.compoents.tp_forge_level ~= nil
    --     end,
    --     function(self, inst, cmp, id)
    --         local D = cmp.datas[id]
    --         return string.format("[要求:武器,锻造]造成%d点冰属性伤害,减少%d点伤害;10%%概率令敌人叠加出血层数", D[1], D[1])
    --     end
    -- ),
    -- Enchantment(
    --     "shadow_elem",
    --     function(self, inst, cmp, id)
    --         cmp.datas[id] = { 10 + cmp.quality * 10 }
    --     end,
    --     function(self, inst, cmp, id)
    --         local D = cmp.datas[id]
    --         inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
    --             return math.max(0, damage - D[1])
    --         end)
    --         inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
    --             EntUtil:get_attacked(target, owner, D[1], nil, 
    --                 EntUtil:add_stimuli(nil, "shadow", "pure") )
    --             if math.random() < .05 then
    --                 local pt = target:GetPosition()
    --                 local st_pt =  FindWalkableOffset(pt or owner:GetPosition(), math.random()*2*PI, 2, 3)
    --                 if st_pt then
    --                     inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
    --                     inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")            
    --                     st_pt = st_pt + pt
    --                     local st = SpawnPrefab("shadowtentacle")
    --                     --print(st_pt.x, st_pt.y, st_pt.z)
    --                     st.Transform:SetPosition(st_pt.x, st_pt.y, st_pt.z)
    --                     st.components.combat:SetTarget(target)
    --                 end
    --             end
    --         end)
    --     end,
    --     function(self, inst, cmp, id)
    --         return inst.components.weapon ~= nil
    --             and inst.compoents.tp_forge_level ~= nil
    --     end,
    --     function(self, inst, cmp, id)
    --         local D = cmp.datas[id]
    --         return string.format("[要求:武器,锻造]造成%d点暗属性伤害,减少%d点伤害;5%%概率召唤暗影触手", D[1], D[1])
    --     end
    -- ),
}
-- weapon over
local enchant_all = {
    Enchantment(
        "speed_equip",
        function(self, inst, cmp, id)
            cmp.datas[id] = { cmp.quality * 0.05 }
        end,
        function(self, inst, cmp, id)
            local slot = inst.components.equippable.equipslot
            inst.components.equippable:WgAddEquipFn(function(inst, owner)
                EntUtil:add_speed_mod(owner, id .. slot, cmp.datas[id][1])
            end)
            inst.components.equippable:WgAddUnequipFn(function(inst, owner)
                EntUtil:rm_speed_mod(owner, id .. slot)
            end)
        end,
        function(self, inst, cmp, id)
            return true
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("增加%d%%的移速", D[1] * 100)
        end
    ),
    Enchantment(
        "max_health_equip",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * cmp.quality + 20, cmp.quality * 10 + 50
            cmp.datas[id] = { math.random(min, max) }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            inst.components.equippable:WgAddEquipMaxHealthModifier(id, D[1])
        end,
        function(self, inst, cmp, id)
            return true
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("增加%d最大生命值", D[1])
        end
    ),
    Enchantment(
        "max_sanity_equip",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * cmp.quality + 20, cmp.quality * 10 + 50
            cmp.datas[id] = { math.random(min, max) }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            inst.components.equippable:WgAddEquipMaxSanityModifier(id, D[1])
        end,
        function(self, inst, cmp, id)
            return true
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("增加%d最大理智值", D[1])
        end
    ),
    Enchantment(
        "max_hunger_equip",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * cmp.quality + 20, cmp.quality * 10 + 50
            cmp.datas[id] = { math.random(min, max) }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            inst.components.equippable:WgAddEquipMaxHungerModifier(id, D[1])
        end,
        function(self, inst, cmp, id)
            return true
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("增加%d最大饥饿值", D[1])
        end
    ),
    Enchantment(
        "lighter",
        function(self, inst, cmp, id)
        end,
        function(self, inst, cmp, id)
            cmp[id .. "_switch"] = false
            if cmp[id .. "_fx"] == nil then
                local fx = CreateEntity()
                fx.entity:AddTransform()
                Kit:make_light(fx, "lantern")
                fx.Light:Enable(cmp[id .. "_switch"])
                fx:AddTag("FX")
                cmp.inst:AddChild(fx)
                cmp[id .. "_fx"] = fx
            end
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = "开关灯",
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                return true
            end
            inst.components.wg_action_tool.click_fn = function(inst, doer)
                local switch = not cmp[id .. "_switch"]
                cmp[id .. "_fx"].Light:Enable(switch)
                cmp[id .. "_switch"] = switch
            end
            inst:ListenForEvent("equipped", function(inst, data)
                cmp[id .. "_switch"] = false
                if cmp[id .. "_fx"] then
                    cmp[id .. "_fx"].Light:Enable(cmp[id .. "_switch"])
                end
            end)
            -- inst:ListenForEvent("unequipped", function(inst, data)
            -- end)
            inst:ListenForEvent("ondropped", function(inst, data)
                cmp[id .. "_switch"] = false
                if cmp[id .. "_fx"] then
                    cmp[id .. "_fx"].Light:Enable(cmp[id .. "_switch"])
                end
            end)
            inst:ListenForEvent("onputininventory", function(inst, data)
                cmp[id .. "_switch"] = false
                if cmp[id .. "_fx"] then
                    cmp[id .. "_fx"].Light:Enable(cmp[id .. "_switch"])
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.wg_action_tool == nil
                and cmp.quality and cmp.quality >= 3
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:无技能装备,品质达到3]获得技能(开关灯)")
        end
    ),
    Enchantment(
        "dress",
        function(self, inst, cmp, id)
            cmp.datas[id] = { TUNING.DAPPERNESS_SMALL * cmp.quality }
        end,
        function(self, inst, cmp, id)
            local GetDapperness = inst.components.equippable.GetDapperness
            inst.components.equippable.GetDapperness = function(self, owner)
                local dapperness = GetDapperness(self, owner)
                return dapperness + cmp.datas[id][1]
            end
        end,
        function(self, inst, cmp, id)
            return true
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("回复理智效果增加%.2f", D[1])
        end
    ),
}

local enchant_cloth = {
    Enchantment(
        "evade_equip",
        function(self, inst, cmp, id)
            local min, max = cmp.quality + 10, cmp.quality * 3 + 10
            cmp.datas[id] = { math.random(min, max)*2 }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            inst.components.equippable:WgAddEquipFn(function(inst, owner)
                owner.components.combat:AddEvadeRateMod(id, D[1])
            end)
            inst.components.equippable:WgAddUnequipFn(function(inst, owner)
                owner.components.combat:RmEvadeRateMod(id)
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.equippable.equipslot ~= EQUIPSLOTS.HANDS
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:非手持]受到攻击时，有%d几率抵消此攻击", D[1])
        end
    ),
    Enchantment(
        "summer_insulation",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 30 * cmp.quality }
        end,
        function(self, inst, cmp, id)
            if inst.components.insulator == nil then
                inst:AddComponent("insulator")
                inst.components.insulator:SetInsulation(0)
            end
            inst.components.insulator.summer_insulation = cmp.datas[id][1]
        end,
        function(self, inst, cmp, id)
            return inst.components.equippable.equipslot ~= EQUIPSLOTS.HANDS
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:非手持]增加%ds夏季的降温效果", D[1])
        end
    ),
    Enchantment(
        "winter_insulation",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 30 * cmp.quality }
        end,
        function(self, inst, cmp, id)
            if inst.components.insulator == nil then
                inst:AddComponent("insulator")
                inst.components.insulator:SetInsulation(0)
            end
            inst.components.insulator.winter_insulation = cmp.datas[id][1]
        end,
        function(self, inst, cmp, id)
            return inst.components.equippable.equipslot ~= EQUIPSLOTS.HANDS
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:非手持]增加%ds冬季的保暖效果", D[1])
        end
    ),
    Enchantment(
        "umbrella",
        function(self, inst, cmp, id)
            cmp.datas[id] = { cmp.quality * .15 }
        end,
        function(self, inst, cmp, id)
            if inst.components.waterproofer == nil then
                inst:AddComponent("waterproofer")
            end
            local GetEffectiveness = inst.components.waterproofer.GetEffectiveness
            inst.components.waterproofer.GetEffectiveness = function(self)
                local effectiveness = GetEffectiveness(self)
                return math.min(1, effectiveness + cmp.datas[id][1])
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.equippable.equipslot ~= EQUIPSLOTS.HANDS
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:非手持]增加%d%%防雨效果", D[1] * 100)
        end
    ),
    Enchantment(
        "fire_defence",
        function(self, inst, cmp, id)
            cmp.datas[id] = { .1 * cmp.quality }
        end,
        function(self, inst, cmp, id)
            inst.components.equippable:WgAddEquipFn(function(inst, owner)
                if owner.components.health then
                    owner.components.health.fire_damage_scale = owner.components.health.fire_damage_scale -
                    cmp.datas[id][1]
                end
            end)
            inst.components.equippable:WgAddUnequipFn(function(inst, owner)
                if owner.components.health then
                    owner.components.health.fire_damage_scale = owner.components.health.fire_damage_scale +
                    cmp.datas[id][1]
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.equippable.equipslot ~= EQUIPSLOTS.HANDS
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:非手持]降低%d%%火焰伤害", D[1] * 100)
        end
    ),
    Enchantment(
        "poison_blocker",
        function(self, inst, cmp, id)
        end,
        function(self, inst, cmp, id)
            inst.components.equippable.poisonblocker = true
        end,
        function(self, inst, cmp, id)
            return inst.components.equippable.equipslot ~= EQUIPSLOTS.HANDS
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:非手持]防毒")
        end
    ),
    Enchantment(
        "poison_gas_blocker",
        function(self, inst, cmp, id)
        end,
        function(self, inst, cmp, id)
            inst.components.equippable.poisongasblocker = true
        end,
        function(self, inst, cmp, id)
            return inst.components.equippable.equipslot ~= EQUIPSLOTS.HANDS
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:非手持]防毒气")
        end
    ),
}

local enchant_armor = {
    Enchantment(
        "spear_magic_circle",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 30, cmp.quality * 5 + 5, 30 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("长矛阵:消耗%d魔法,召唤一阵环绕你的长矛,对周围的敌人周期性造成%d点伤害",
                    cmp.datas[id][3], cmp.datas[id][2])
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][3] then
                        return true
                    end
                end
            end
            inst.components.wg_action_tool.click_get_action_fn = function(inst, data)
                -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
                if data.pos or data.target then
                    return ACTIONS.TP_BATTLE_CRY
                end
            end
            -- inst.components.wg_action_tool.click_fn = function(inst, doer)
            --     -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
            -- end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][3])
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
                local fx = FxManager:MakeFx("spear_magic_circle", doer, {
                    owner = doer, damage = cmp.datas[id][2]
                })
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
                and inst.components.wg_action_tool == nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:护甲]获得技能长矛阵")
        end
    ),
    Enchantment(
        "guardian",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 20, cmp.quality * 10 + 10, 10 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("守护者:消耗%d魔法,提升%d防御以抵挡下一次攻击",
                    cmp.datas[id][3], cmp.datas[id][2])
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][3] then
                        return true
                    end
                end
            end
            inst.components.wg_action_tool.get_action_fn = function(inst, data)
                -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
                if data.pos or data.target then
                    return ACTIONS.TP_SAIL
                end
            end
            -- inst.components.wg_action_tool.click_fn = function(inst, doer)
            --     -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
            -- end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][3])
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
                FxManager:MakeFx("firework_fx", doer)
                BuffManager:AddBuff(doer, id, nil, cmp.datas[id][2])
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
                and inst.components.wg_action_tool == nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:护甲]获得技能守护者")
        end
    ),
    Enchantment(
        "high_jump",
        function(self, inst, cmp, id)
            cmp.datas[id] = { 7.5, 5 }
        end,
        function(self, inst, cmp, id)
            if inst.components.wg_recharge == nil then
                inst:AddComponent("wg_recharge")
                inst.components.wg_recharge:SetCommon(id)
            end
            inst:AddComponent("wg_action_tool")
            inst.components.wg_action_tool:RegisterSkillInfo({
                desc = string.format("跳高:消耗%d魔法,原地起跳,并获得100%%闪避",
                    cmp.datas[id][2])
            })
            inst.components.wg_action_tool.test = function(inst, doer)
                --检测
                if inst.components.wg_recharge:IsRecharged() then
                    if doer.components.tp_mana
                        and doer.components.tp_mana.current >= cmp.datas[id][2] then
                        return true
                    end
                end
            end
            inst.components.wg_action_tool.get_action_fn = function(inst, data)
                -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
                if data.pos or data.target then
                    return ACTIONS.TP_HIGH_JUMP
                end
            end
            -- inst.components.wg_action_tool.click_fn = function(inst, doer)
            --     -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
            -- end
            inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
                -- 动作触发时会到达的效果
                doer.components.tp_mana:DoDelta(-cmp.datas[id][2])
                inst.components.wg_recharge:SetRechargeTime(cmp.datas[id][1], id)
                -- FxManager:MakeFx("firework_fx", doer)
                -- BuffManager:AddBuff(doer, id, nil, cmp.datas[id][2])
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
                and inst.components.wg_action_tool == nil
                and cmp.quality and cmp.quality >= 2
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:护甲,品质达到2]获得技能跳高")
        end
    ),
    Enchantment(
        "ice_armor",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 2 + 10, cmp.quality * 4 + 15
            cmp.datas[id] = { math.random(min, max) / 100 }
        end,
        function(self, inst, cmp, id)
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local attacker = data.attacker
                local damage = data.damage
                local owner = data.owner
                if EntUtil:can_thorns({ damage = damage, attacker = attacker })
                    and math.random() < cmp.datas[id][1] then
                    EntUtil:frozen(attacker)
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:护甲]受到攻击有%d%%几率冰冻敌人", cmp.datas[id][1] * 100)
        end
    ),
    Enchantment(
        "fire_armor",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 2 + 15, cmp.quality * 4 + 20
            cmp.datas[id] = { math.random(min, max) / 100 }
        end,
        function(self, inst, cmp, id)
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local attacker = data.attacker
                local damage = data.damage
                local owner = data.owner
                if EntUtil:can_thorns({ damage = damage, attacker = attacker })
                    and math.random() < cmp.datas[id][1] then
                    EntUtil:ignite(attacker)
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:护甲]受到攻击有%d%%几率点燃敌人", cmp.datas[id][1] * 100)
        end
    ),
    Enchantment(
        "poison_armor",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 2 + 15, cmp.quality * 4 + 20
            cmp.datas[id] = { math.random(min, max) / 100 }
        end,
        function(self, inst, cmp, id)
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local attacker = data.attacker
                local damage = data.damage
                local owner = data.owner
                if EntUtil:can_thorns({ damage = damage, attacker = attacker })
                    and math.random() < cmp.datas[id][1] then
                    EntUtil:poison(attacker)
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            return string.format("[要求:护甲]受到攻击有%d%%几率令敌人中毒", cmp.datas[id][1] * 100)
        end
    ),
    Enchantment(
        "area_ice_armor",
        function(self, inst, cmp, id)
            local min, max = cmp.quality + 10, cmp.quality * 2 + 15
            cmp.datas[id] = { math.random(min, max) / 100 }
        end,
        function(self, inst, cmp, id)
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local D = cmp.datas[id]
                if math.random() < D[1] then
                    local owner = data.owner
                    FxManager:MakeFx("thorns_blue", owner)
                    local x, y, z = owner:GetPosition():Get()
                    local ents = TheSim:FindEntities(x, y, z, 6, nil, EntUtil.constants.not_enemy_tags)
                    for k, v in pairs(ents) do
                        EntUtil:frozen(v)
                    end
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:护甲]受到攻击有%d%%几率冰冻周围的敌人", D[1] * 100)
        end
    ),
    Enchantment(
        "area_fire_armor",
        function(self, inst, cmp, id)
            local min, max = cmp.quality + 10, cmp.quality * 3 + 15
            cmp.datas[id] = { math.random(min, max) / 100 }
        end,
        function(self, inst, cmp, id)
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local D = cmp.datas[id]
                if math.random() < D[1] then
                    local owner = data.owner
                    FxManager:MakeFx("firesplash_fx", owner)
                    local x, y, z = owner:GetPosition():Get()
                    local ents = TheSim:FindEntities(x, y, z, 6, nil, EntUtil.constants.not_enemy_tags)
                    for k, v in pairs(ents) do
                        EntUtil:ignite(v)
                    end
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:护甲]受到攻击有%d%%几率点燃周围的敌人", D[1] * 100)
        end
    ),
    Enchantment(
        "area_poison_armor",
        function(self, inst, cmp, id)
            local min, max = cmp.quality + 10, cmp.quality * 3 + 15
            cmp.datas[id] = { math.random(min, max) / 100 }
        end,
        function(self, inst, cmp, id)
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local D = cmp.datas[id]
                if math.random() < D[1] then
                    local owner = data.owner
                    FxManager:MakeFx("thorns_green", owner)
                    local x, y, z = owner:GetPosition():Get()
                    local ents = TheSim:FindEntities(x, y, z, 6, nil, EntUtil.constants.not_enemy_tags)
                    for k, v in pairs(ents) do
                        EntUtil:poison(v)
                    end
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:护甲]受到攻击有%d%%几率令周围的敌人中毒", D[1] * 100)
        end
    ),
    Enchantment(
        "speed_armor",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 3 + 10, cmp.quality * 5 + 15
            local min2, max2 = cmp.quality * 5, cmp.quality * 6 + 10
            cmp.datas[id] = { math.random(min, max) / 100, math.random(min2, max2) / 100 }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local owner = data.owner
                if math.random() < D[1] then
                    EntUtil:add_speed_mod(owner, id, D[2], 5)
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            local data = cmp.datas[id]
            return string.format("[要求:护甲]受到攻击有%d%%几率增加%d%%移速", data[1] * 100, data[2] * 100)
        end
    ),
    Enchantment(
        "slow_down_armor",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 3 + 10, cmp.quality * 5 + 15
            local min2, max2 = cmp.quality * 3 + 10, cmp.quality * 6 + 20
            cmp.datas[id] = { math.random(min, max) / 100, math.random(min2, max2) / 100 }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local attacker = data.attacker
                if attacker and math.random() < D[1] then
                    EntUtil:add_speed_mod(attacker, id, D[2], 5)
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:护甲]受到攻击有%d%%几率减低敌人%d%%移速", D[1] * 100, D[2] * 100)
        end
    ),
    Enchantment(
        "absorb_amount",
        function(self, inst, cmp, id)
            local min, max = cmp.quality + 5, cmp.quality * 2 + 5
            cmp.datas[id] = { math.random(min, max) }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local damage = data.damage - D[1]
                return math.max(1, damage)
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:护甲]降低%d点伤害", D[1])
        end
    ),
    Enchantment(
        "absorb_percent",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 0.5 + 3, cmp.quality + 5
            cmp.datas[id] = { math.random(min, max) / 100 }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local damage = data.damage - data.damage * D[1]
                return damage
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:护甲]降低%d%%受到的伤害", D[1] * 100)
        end
    ),
    Enchantment(
        "absorb_random",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 2 + 10, cmp.quality * 5 + 10
            local min2, max2 = cmp.quality + 5, cmp.quality * 3 + 15
            cmp.datas[id] = { math.random(min, max) / 100, math.random(min2, max2) / 100 }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local damage = data.damage
                if math.random() < D[2] then
                    damage = damage - damage * D[1]
                end
                return damage
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:护甲]有%d%%的几率降低%d%%的伤害", D[2] * 100, D[1] * 100)
        end
    ),
    Enchantment(
        "thorns_amount_armor",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 3 + 15, cmp.quality * 5 + 20
            local min2, max2 = cmp.quality * 2, cmp.quality * 5 + 10
            cmp.datas[id] = { math.random(min, max) / 100, math.random(min2, max2) }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local attacker = data.attacker
                local damage = data.damage
                local owner = data.owner
                if math.random() < D[1] then
                    if EntUtil:can_thorns({ damage = damage, attacker = attacker }) then
                        FxManager:MakeFx("thorns", owner)
                        BuffManager:AddBuff(attacker, "not_reflection")
                        EntUtil:get_attacked(attacker, owner, D[2], nil,
                            EntUtil:add_stimuli(nil, "pure"))
                    end
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:护甲]受到攻击有%d%%几率返还%d点伤害", D[1] * 100, D[2])
        end
    ),
    Enchantment(
        "thorns_percent_armor",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 3 + 15, cmp.quality * 5 + 20
            local min2, max2 = cmp.quality + 5, cmp.quality * 2 + 5
            cmp.datas[id] = { math.random(min, max) / 100, math.random(min2, max2) / 100 }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local attacker = data.attacker
                local damage = data.damage
                local owner = data.owner
                if math.random() < D[1] then
                    if EntUtil:can_thorns(data) then
                        FxManager:MakeFx("thorns", owner)
                        BuffManager:AddBuff(attacker, "not_reflection")
                        EntUtil:get_attacked(attacker, owner, damage * D[2], nil,
                            EntUtil:add_stimuli(nil, "pure"))
                    end
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:护甲]受到攻击有%d%%几率返还伤害的%d%%", D[1] * 100, D[2] * 100)
        end
    ),
    Enchantment(
        "reduce_damage_armor",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 3 + 15, cmp.quality * 5 + 20
            local min2, max2 = cmp.quality + 10, cmp.quality * 2 + 10
            cmp.datas[id] = { math.random(min, max) / 100, math.random(min2, max2) / 100 }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            inst.components.equippable:WgAddEquipAttackedFn(function(data)
                local attacker = data.attacker
                if attacker and math.random() < D[1] then
                    EntUtil:add_damage_mod(attacker, id, D[2], 6)
                end
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.armor ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:护甲]受到攻击有%d%%几率降低敌人%d%%攻击力", D[1] * 100, D[2] * 100)
        end
    ),
    Enchantment(
        "armor_max",
        function(self, inst, cmp, id)
            local arg = cmp.quality
            local min, max = arg * 5 + 10, arg * 15 + 25
            cmp.datas[id] = { math.random(min, max) }
            local D = cmp.datas[id]
            local max = inst.components.armor.maxcondition
            inst.components.armor.maxcondition = max + math.floor(max * D[1])
            inst.components.armor:SetCondition(max + math.floor(max * D[1]))
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            local max = inst.components.armor.maxcondition
            inst.components.armor.maxcondition = max + math.floor(max * D[1])
        end,
        function(self, inst, cmp, id)
            return inst.components.finiteuses ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:护甲]增加%d%%最大护甲值", D[1])
        end
    ),
}
-- armor over
local enchant_tool = {
    Enchantment(
        "finite_use_recycle",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 3 + 10, cmp.quality * 5 + 25
            cmp.datas[id] = { math.random(min, max) / 100 }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            -- inst:ListenForEvent("percentusedchange", function(inst, data)
            --     inst.components.finiteuses:DoDelta(1)
            -- end)  -- 会导致死循环
            local Use = inst.components.finiteuses.Use
            inst.components.finiteuses.Use = function(self, num)
                if math.random() < D[1] then
                else
                    Use(self, num)
                end
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.finiteuses ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:耐久]有%d%%几率不消耗耐久度", D[1] * 100)
        end
    ),
    Enchantment(
        "finite_use_regen",
        function(self, inst, cmp, id)
            local time = 480
            local arg = cmp.quality * 3 + 10
            local min, max = time / (arg), time / (arg * 3)
            cmp.datas[id] = { math.random(min, max) }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            cmp[id .. "_task"] = inst:DoPeriodicTask(D[1], function()
                local p = inst.components.finiteuses:GetPercent()
                inst.components.finiteuses:SetPercent(math.min(1, p + .01))
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.finiteuses ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:耐久]每%ds回复1%%的耐久", D[1])
        end
    ),
    Enchantment(
        "max_finite_use",
        function(self, inst, cmp, id)
            local arg = cmp.quality
            local min, max = (arg * 5 + 10), (arg * 15 + 25)
            cmp.datas[id] = { math.random(min, max) * 0.01 }
            local D = cmp.datas[id]
            local max = inst.components.finiteuses.total
            inst.components.finiteuses:SetUses(max + math.floor(max * D[1]))
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            local max = inst.components.finiteuses.total
            inst.components.finiteuses:SetMaxUses(max + math.floor(max * D[1]))
        end,
        function(self, inst, cmp, id)
            return inst.components.finiteuses ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:耐久]增加%d%%最大耐久", D[1] * 100)
        end
    ),
    Enchantment(
        "more_work",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 3 + 15, cmp.quality * 5 + 20
            cmp.datas[id] = { math.random(min, max) / 100 }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            local GetEffectiveness = inst.components.tool.GetEffectiveness
            inst.components.tool.GetEffectiveness = function(self, act)
                local n = GetEffectiveness(self, act)
                if n > 0 and math.random() < D[1] then
                    n = n + 1
                end
                return n
            end
        end,
        function(self, inst, cmp, id)
            return inst.components.tool ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:工具]有%d几率令工作效率+1", D[1] * 100)
        end
    ),
    Enchantment(
        "happy_work",
        function(self, inst, cmp, id)
            local min, max = cmp.quality * 3 + 15, cmp.quality * 5 + 20
            local min2, max2 = 1, cmp.quality
            cmp.datas[id] = { math.random(min, max) / 100, math.random(min2, max2) }
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            cmp[id .. "_fn"] = function(owner, data)
                if owner.components.sanity and math.random() < D[1] then
                    owner.components.sanity:DoDelta(D[2])
                end
            end
            inst.components.equippable:WgAddEquipFn(function(inst, owner)
                inst:ListenForEvent("working", cmp[id .. "_fn"], owner)
            end)
            inst.components.equippable:WgAddUnequipFn(function(inst, owner)
                inst:RemoveEventCallback("working", cmp[id .. "_fn"], owner)
            end)
        end,
        function(self, inst, cmp, id)
            return inst.components.tool ~= nil
        end,
        function(self, inst, cmp, id)
            local D = cmp.datas[id]
            return string.format("[要求:工具]工作时有%d几率回复%d点理智", D[1] * 100, D[2])
        end
    ),
}

local DataManager = require "extension.lib.data_manager"
local EnchantmentManager = DataManager("EnchantmentManager")
EnchantmentManager:AddDatas(enchant_weapon, "weapon")
EnchantmentManager:AddDatas(enchant_all, "all")
EnchantmentManager:AddDatas(enchant_cloth, "cloth")
EnchantmentManager:AddDatas(enchant_armor, "armor")
EnchantmentManager:AddDatas(enchant_tool, "tool")

Sample.EnchantmentManager = EnchantmentManager
