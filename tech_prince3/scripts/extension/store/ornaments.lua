local AssetUtil = require "extension/lib/asset_util"
local EntUtil = require "extension/lib/ent_util"
local Util = require "extension.lib.wg_util"
local AssetMaster = Sample.AssetMaster
local BuffManager = Sample.BuffManager
local FxManager = Sample.FxManager
local Info = Sample.Info
-- 如果EquipSkillManager这时还不存在,那么这里就只会为nil
local EquipSkillManager = Sample.EquipSkillManager


local OrnamentData = Class(function(self)
end)

--[[
生成饰品数据类  
(OrnamentData) 返回这个类  
id (string) 标识  
name (string) 名字  
desc (string/func) 描述  
take (function) 获得时函数  
lose (function) 失去时函数  
data (table/number) 数据  
no_click (bool) 是否不可点击卸下  
]]
local function Ornament(id, name, desc, take, lose, data, no_click)
    local self = OrnamentData()
    self.id = id
    self.name = name
    self.desc = desc
    self.take = take
    self.lose = lose
    self.data = data
    self.no_click = no_click
    return self
end

function OrnamentData:GetId()
    return self.id
end

function OrnamentData:GetName()
    return Util:SplitSentence(self.name, 5, true)
end

function OrnamentData:GetDescription()
    local str 
    if type(self.desc) == "function" then
        str = self.desc(self.data)
    else
        str = self.desc
    end
    return Util:SplitSentence(str, nil, true)
end

function OrnamentData:GetImage()
    if self:IsNone() then
        local Uimg = AssetUtil:MakeImg("amulet")
        return AssetUtil:GetImage(Uimg)
    else
        return AssetMaster:GetImage(self.id)
    end
end

function OrnamentData:IsNone()
    return self.id == "none"
end

function OrnamentData:IsDisable()
    return self.no_click
end

function OrnamentData:Take(owner)
    local cmp = owner.components.tp_ornament
    owner.components.tp_ornament:TakeOrnament(self.id)
    self.take(owner, cmp, self.id, self.data)
    -- 护符自己会Remove
end

function OrnamentData:Lose(owner)
    local cmp = owner.components.tp_ornament
    self.lose(owner, cmp, self.id, self.data)
    owner.components.tp_ornament:LoseOrnament(self.id)
    local item = SpawnPrefab(self.id)
    owner.components.inventory:GiveItem(item)
end

local ornaments = {
Ornament("none",
    "",
    function()
        return ""
    end,
    function()
    end,
    function()
    end,
    nil,
    true
),
Ornament("ak_ornament_plain1", 
    "生命树的果实",
    function(self_data)
        return string.format("营养液的回复效果%+d%%", self_data[1]*100)
    end,
    function(inst, cmp, id, self_data)
        inst:AddTag("tp_recover_bottle")
    end,
    function(inst, cmp, id, self_data)
        inst:RemoveTag("tp_recover_bottle")
    end,
    {.35}
),
Ornament("ak_ornament_plain2", 
    "鲁莽果实",
    function(self_data)
        return string.format("%+d攻击力,攻击时会消耗%d理智", self_data[1], self_data[2])
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
                if EntUtil:can_dmg_effect(stimuli) then
                    damage = damage + self_data[1]
                end
                return damage
            end)
        end
        if cmp[id.."_fn2"] == nil then
            cmp[id.."_fn2"] = inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
                if EntUtil:can_dmg_effect(stimuli) then
                    inst.components.sanity:DoDelta(-self_data[2])
                end
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            inst.components.combat:WgRemoveCalcDamageFn(cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
        if cmp[id.."_fn2"] then
            inst.components.combat:WgRemoveOnHitFn(cmp[id.."_fn2"])
            cmp[id.."_fn2"] = nil
        end
    end,
    {20, 10}
),
Ornament("ak_ornament_plain3", 
    "丰饶果实",
    function(self_data)
        return string.format("增加%d%%生命上限", self_data[1]*100)
    end,
    function(inst, cmp, id, self_data)
        inst.components.health:WgAddMaxHealthMultiplier(id, self_data[1], true)
    end,
    function(inst, cmp, id, self_data)
        inst.components.hunger:WgRemoveMaxHealthMultiplier(id, true)
    end,
    {.2}
),
Ornament("ak_ornament_plain4",
    "圣战果实",
    function(self_data)
        return string.format("增加%d%%突刺伤害", self_data[1]*100)
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
                if stimuli and EntUtil:in_stimuli(stimuli, "lunge") then
                    damage = damage*(1+self_data[1])
                end
                return damage
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            inst.components.combat:WgRemoveCalcDamageFn(cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end,
    {.2}
),
Ornament("ak_ornament_plain5",
    "健步饰品",
    function(self_data)
        return string.format("增加%d移速", self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.locomotor:AddSpeedModifier_Additive(id, self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.locomotor:RemoveSpeedModifier_Additive(id)
    end,
    {2}
),
Ornament("ak_ornament_plain6",
    "切斯特果实",
    function(self_data)
        return string.format("增加%d负重上限", self_data[1])
    end,
    function(inst, cmp, id, self_data)
        local n = inst.components.tp_player_attr.load_weight_buff
        inst.components.tp_player_attr.load_weight_buff = n + self_data[1]
    end,
    function(inst, cmp, id, self_data)
        local n = inst.components.tp_player_attr.load_weight_buff
        inst.components.tp_player_attr.load_weight_buff = n - self_data[1]
    end,
    {30}
),
Ornament("ak_ornament_plain7", 
    "狼扑果实",
    "当你使用位移技能后,提升攻击力",
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = EntUtil:listen_for_event(inst, "use_equip_skill", function(inst, data)
                if data.item then
                    if data.item.components.wg_action_tool.move then
                        cmp:AddBuff(inst)
                    end
                end
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            inst:RemoveEventCallback("use_equip_skill", cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end
),
Ornament("ak_ornament_plain8",
    "贪婪之果",
    "杀死敌人时,有几率额外掉落一个物品",
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = EntUtil:listen_for_event(inst, "killed", function(inst, data)
                if data.victim and data.victim.components.lootdropper then
                    if math.random() < .1 then
                        data.victim.components.lootdropper:DropSingleLoot()
                    end
                end
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            inst:RemoveEventCallback("killed", cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end
),
Ornament("ak_ornament_plain9",
    "奇异果实",
    function(self_data)
        return string.format("增加%d法力上限", self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.tp_val_mana:AddMaxMod(id, self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.tp_val_mana:RmMaxMod(id)
    end,
    {50}
),
Ornament("ak_ornament_plain10", 
    "雪域果实",
    "你用寒冰法术造成伤害时,对其施加1层冰冻效果",
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
                if EntUtil:in_stimuli("ice")
                and EntUtil:in_stimuli("magic") then
                    EntUtil:frozen(target)
                end
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            inst.components.combat:WgRemoveOnHitFn(cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end
),
Ornament("ak_ornament_plain11",
    "火海果实",
    "你用火焰法术造成伤害时,有几率生成1个火药桶,火药桶受到火焰攻击后会被引爆",
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
                if EntUtil:in_stimuli("fire")
                and EntUtil:in_stimuli("magic") then
                    if math.random() < .25 then
                        -- EntUtil:frozen(target)
                        local pos = target:GetPosition()
                        SpawnPrefab("tp_powder_keg").Transform:SetPosition(pos:Get())
                    end
                end
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            inst.components.combat:WgRemoveOnHitFn(cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end
),
Ornament("ak_ornament_plain12",
    "魔力果实",
    function(self_data)
        return string.format("增加%d法术伤害", self_data[1]*100)
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            cmp[id.."_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
                if EntUtil:in_stimuli(stimuli, "magic") then
                    damage = damage*(1+self_data[1])
                end
                return damage
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            inst.components.combat:WgRemoveCalcDamageFn(cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end,
    {.1}
),
Ornament("ak_ornament_light1",
    "骑士之灯",
    function(self_data)
        return string.format("增加%d%s", self_data[1], Info.Attr.PlayerAttrStr["strengthen"])
    end,
    function(inst, cmp, id, self_data)
        inst.components.tp_player_attr:AddAttrMod("strengthen", self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.tp_player_attr:RmAttrMod("strengthen")
    end,
    {6}
),
Ornament("ak_ornament_light2", 
    "游侠之灯",
    function(self_data)
        return string.format("增加%d%s", self_data[1], Info.Attr.PlayerAttrStr["agility"])
    end,
    function(inst, cmp, id, self_data)
        inst.components.tp_player_attr:AddAttrMod("agility", self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.tp_player_attr:RmAttrMod("agility")
    end,
    {6}
),
Ornament("ak_ornament_light3", 
    "巫师之灯",
    function(self_data)
        return string.format("增加%d%s", self_data[1], Info.Attr.PlayerAttrStr["intelligence"])
    end,
    function(inst, cmp, id, self_data)
        inst.components.tp_player_attr:AddAttrMod("intelligence", self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.tp_player_attr:RmAttrMod("intelligence")
    end,
    {6}
),
Ornament("ak_ornament_light4", 
    "牧师之灯",
    function(self_data)
        return string.format("增加%d%s", self_data[1], Info.Attr.PlayerAttrStr["faith"])
    end,
    function(inst, cmp, id, self_data)
        inst.components.tp_player_attr:AddAttrMod("faith", self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.tp_player_attr:RmAttrMod("faith")
    end,
    {6}
),
Ornament("ak_ornament_light5", 
    "刺客之灯",
    function(self_data)
        return string.format("增加%d%s", self_data[1], Info.Attr.PlayerAttrStr["lucky"])
    end,
    function(inst, cmp, id, self_data)
        inst.components.tp_player_attr:AddAttrMod("lucky", self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.tp_player_attr:RmAttrMod("lucky")
    end,
    {6}
),
Ornament("ak_ornament_light6", 
    "射手之灯",
    function(self_data)
        return string.format("增加%d远程伤害", self_data[1])
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp["id_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
                if weapon and weapon.components.weapon then
                    local range1 = weapon.components.weapon.attackrange
                    local range2 = weapon.components.weapon.hitrange
                    if range1 and range2 and range1 > 0 and range2 > 0 then
                        damage = damage + self_data[1]
                    end
                end
                return damage
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp["id_fn"] then
            inst.components.combat:WgRemoveCalcDamageFn(cmp["id_fn"])
            cmp["id_fn"] = nil
        end
    end,
    {20}
),
Ornament("ak_ornament_light7", 
    "召唤师之灯",
    function(self_data)
        return string.format("你每拥有1个随从,增加%d伤害", self_data[1])
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp["id_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
                local n = inst.components.leader:CountFollowers()
                damage = damage + self_data[1]*n
                return damage
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp["id_fn"] then
            inst.components.combat:WgRemoveCalcDamageFn(cmp["id_fn"])
            cmp["id_fn"] = nil
        end
    end,
    {5}
),
Ornament("ak_ornament_light8", 
    "炼金师之灯",
    function(self_data)
        return string.format("添加给装备的buff效果延长%d%%", self_data[1]*100)
    end,
    function(inst, cmp, id, self_data)
        inst:AddTag("tp_smear_longer")
    end,
    function(inst, cmp, id, self_data)
        inst:RemoveTag("tp_smear_longer")
    end,
    {.2}
),
Ornament("ak_ornament_fancy1", 
    -- "天琴座奥菲斯",
    "回音海螺",
    function(self_data)
        return string.format("回旋斩击的伤害%+d%%", self_data[1]*100)
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
                if stimuli and EntUtil:in_stimuli(stimuli, "cyclone_slash") then
                    damage = damage*(1+self_data[1])
                end
                return damage
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            inst.components.combat:WgRemoveCalcDamageFn(cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end,
    {.4}
),
Ornament("ak_ornament_fancy2", 
    -- "冈格尼尔饰品海螺",
    "神枪海螺",
    "增加突刺的距离,突刺过程无敌,提升突刺伤害",
    function(inst, cmp, id, self_data)
        inst:AddTag("far_lunge")
        inst:AddTag("lunge_protect")
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
                if stimuli and EntUtil:in_stimuli(stimuli, "lunge") then
                    damage = damage*(1+.1)
                end
                return damage
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        inst:RemoveTag("far_lunge")
        inst:AddTag("lunge_protect")
        if cmp[id.."_fn"] then
            inst.components.combat:WgRemoveCalcDamageFn(cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end
),
Ornament("ak_ornament_fancy3", 
    "该隐的海螺",
    "你造成血属性伤害时会恢复生命值",
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
                if EntUtil:in_stimuli(stimuli, "not_life_steal") 
                and EntUtil:in_stimuli(stimuli, "blood") then
                    inst.components.health:DoDelta(damage*self_data[1], "life_steal", true)
                end
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        inst.components.hunger:WgRemoveMaxHungerModifier(id, true)
    end,
    {.4}
),
Ornament("ak_ornament_fancy4", 
    "宗师的海螺",
    function(self_data)
        return string.format("增加%d%%闪避", self_data[1]*100)
    end,
    function(inst, cmp, id, self_data)
        inst:AddTag("evade_percent_up")
    end,
    function(inst, cmp, id, self_data)
        inst:RemoveTag("evade_percent_up")
    end,
    {.3}
),
Ornament("ak_ornament_fancy5", 
    "暴食的海螺",
    "杀死敌人时,有几率额外掉落一次",
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = EntUtil:listen_for_event(inst, "killed", function(inst, data)
                if data.victim and data.victim.components.lootdropper then
                    if math.random() < .05 then
                        data.victim.components.lootdropper:DropLoot()
                    end
                end
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            inst:RemoveEventCallback("killed", cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end
),
Ornament("ak_ornament_fancy6", 
    "冥界海螺",
    "你用暗影法术对一名敌人造成伤害时,降低其暗属性抗性",
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
                if EntUtil:in_stimuli("shadow")
                and EntUtil:in_stimuli("magic") then
                    BuffManager:AddBuff(target, "shadow", 4)
                end
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            inst.components.combat:WgRemoveOnHitFn(cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end
),

-- Ornament("ak_ornament_festivalevents2", 
--     "火焰之地的加护",
--     function(self_data)
--         return string.format("燃烧中的生物不会影响其掉落的战利品")
--     end,
--     function(inst, cmp, id, self_data)
--         Sample.NO_BURNING_LOOT = true
--     end,
--     function(inst, cmp, id, self_data)
--         Sample.NO_BURNING_LOOT = nil
--     end,
--     {}
-- ),
Ornament("ak_ornament_festivalevents2", 
    "海格力斯的加护",
    function(self_data)
        return string.format("你的装备技能伤害%+d%%", self_data[1]*100)
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
                if stimuli and EntUtil:in_stimuli(stimuli, "skill") then
                    damage = damage*(1+self_data[1])
                end
                return damage
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            inst.components.combat:WgRemoveCalcDamageFn(cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end,
    {.3}
),
Ornament("ak_ornament_festivalevents3", 
    "炎枪伊格伦的加护",
    "大幅强化突刺技能",
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = EntUtil:listen_for_event(inst, "lunge", function(inst, data)
                local fx = FxManager:MakeFx("lunge_dragonfly", inst, {owner=inst})
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            inst:RemoveEventCallback("lunge", cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end
),
Ornament("ak_ornament_festivalevents4", 
    "天使回响",
    "你发动回旋斩击时,会触发身上所有武器的回旋斩击(同名物品只触发一个)",
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = EntUtil:listen_for_event(inst, "cyclone_slash", function(inst, data)
                if data.ignore then
                    return
                end
                local weapons = inst.components.inventory:FindItems(function(item)
                    -- if item.components.weapon 
                    -- and item.cyclone_slash
                    -- and item ~= inst then
                    --     return true
                    -- end
                    if item.components.wg_action_tool
                    and item.components.wg_action_tool.skill_id then
                        local skill_id = item.components.wg_action_tool.skill_id
                        if skill_id == "lunge_cyclone_slash" then
                            skill_id = "cyclone_slash2"
                        end
                        local kind = EquipSkillManager:GetDataKindById(skill_id)
                        if kind == "cyclone_slash" then
                            return true
                        end
                    end
                end)
                local name_list = {}
                for k, v in pairs(weapons) do
                    if not name_list[v.prefab] then
                        name_list[v.prefab] = true
                    end
                end
                local cnt = 1
                for name, _ in pairs(name_list) do
                    inst:DoTaskInTime(0.05*cnt, function()
                        cnt = cnt + 1
                        local item = inst.components.inventory:FindItem(function(item)
                            return item.prefab == name
                        end)
                        if item then
                            -- item:cyclone_slash(inst, true)
                            local skill_id = item.components.wg_action_tool.skill_id
                            if skill_id == "lunge_cyclone_slash" then
                                skill_id = "cyclone_slash2"
                            end
                            local skill_data = EquipSkillManager:GetDataById(skill_id)
                            skill_data:fn(item, item.components.wg_action_tool, skill_id, inst, nil, nil, true)
                        end
                    end)
                end
            end)
        end
    end,
    function(inst, cmp, id, self_data)
        if cmp[id.."_fn"] then
            inst:RemoveEventCallback("cyclone_slash", cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end
),
Ornament("ak_ornament_boss_moose", 
    "春季之王的加护",
    function(self_data)
        return string.format("降低%d%%受到的风属性伤害", self_data[1]*100)
    end,
    function(inst, cmp, id, self_data)
        inst.components.combat:AddDmgTypeAbsorb("wind", -self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.combat:AddDmgTypeAbsorb("wind", self_data[1])
    end,
    {.3}
),
Ornament("ak_ornament_boss_dragonfly", 
    "夏季之王的加护",
    function(self_data)
        return string.format("降低%d%%受到的火属性伤害", self_data[1]*100)
    end,
    function(inst, cmp, id, self_data)
        inst.components.combat:AddDmgTypeAbsorb("fire", -self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.combat:AddDmgTypeAbsorb("fire", self_data[1])
    end,
    {.3}
),
Ornament("ak_ornament_boss_bearger", 
    "秋季之王的加护",
    function(self_data)
        return string.format("降低%d%%受到的打属性伤害", self_data[1]*100)
    end,
    function(inst, cmp, id, self_data)
        inst.components.combat:AddDmgTypeAbsorb("strike", -self_data[1])
        -- inst.components.combat:AddDmgTypeAbsorb("thump", -self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.combat:AddDmgTypeAbsorb("strike", self_data[1])
        -- inst.components.combat:AddDmgTypeAbsorb("thump", self_data[1])
    end,
    {.3}
),
Ornament("ak_ornament_boss_deerclops", 
    "冬季之王的加护",
    function(self_data)
        return string.format("降低%d%%受到的冰属性伤害", self_data[1]*100)
    end,
    function(inst, cmp, id, self_data)
        inst.components.combat:AddDmgTypeAbsorb("ice", -self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.combat:AddDmgTypeAbsorb("ice", self_data[1])
    end,
    {.3}
),
Ornament("ak_ornament_boss_minotaur", 
    "远古守护者的加护",
    function(self_data)
        return string.format("降低%d%%受到的暗属性伤害", self_data[1]*100)
    end,
    function(inst, cmp, id, self_data)
        inst.components.combat:AddDmgTypeAbsorb("shadow", -self_data[1])
    end,
    function(inst, cmp, id, self_data)
        inst.components.combat:AddDmgTypeAbsorb("shadow", self_data[1])
    end,
    {.3}
),
-- Ornament("ak_ornament_boss_wagstaff", 
--     "阿瑞斯的加护",
--     function(self_data)
--         return string.format("无法卸下;获得%d防御;在你到达%d级后,失去此饰品", self_data[1], self_data[2])
--     end,
--     function(inst, cmp, id, self_data)
--         inst.components.combat:AddDefenseMod(id, self_data[1])
--     end,
--     function(inst, cmp, id, self_data)
--         inst.components.combat:RmDefenseMod(id)
--     end,
--     {30, 11},
--     true
-- ),
}

local DataManager = require "extension/lib/data_manager"
local OrnamentManager = DataManager("OrnamentManager")
OrnamentManager:AddDatas(ornaments)

Sample.OrnamentManager = OrnamentManager