local AssetUtil = require "extension/lib/asset_util"
local EntUtil = require "extension.lib.ent_util"
local Kit = require "extension.lib.wargon"
local Info = Sample.Info
local FxManager = Sample.FxManager
local AssetMaster = Sample.AssetMaster

local DataManager = require "extension/lib/data_manager"
-- BuffManager:SetName("BuffManager")
local BuffManager = DataManager("BuffManager")
BuffManager:SetUniqueIdMode()

local BuffData = Class(function(self)
end)

--[[
创建buff类,包含buff相关的各类数据
(BuffData) 返回buff类
name (string)buff名
time (number)持续时间
buff_handler (table{func})buff函数处理器{on_add,on_rm,on_repeat,on_fade}
Uimg (Img)图片资源
desc (func/string)描述文字或描述函数
data (table)buff的一些具体数值
is_debuff (bool)是否debuff
is_forever (bool)是否永续buff
fade_out (bool)是否层层消退
is_hidden (bool)是否不显示在buff栏
]]
local function Buff(name, time, buff_handler, Uimg, desc, data, is_debuff, is_forever, fade_out, is_hidden)
    local self = BuffData()
    self.name = name
    self.time = time
    self.handler = buff_handler
    self.img = Uimg
    self.desc = desc
    self.data = data
    self.is_debuff = is_debuff
    self.is_forever = is_forever
    self.fade_out = fade_out
    self.is_hidden = is_hidden
    return self
end

function BuffData:GetId()
    return self.name
end

--[[
获取时间
(number) 返回这个时间
buff (Buff)buff类
]]
function BuffData:GetTime()
    return self.time
end

--[[
判断是否debuff
(bool) 返回bool
buff (Buff)buff类
]]
function BuffData:IsDebuff()
    return self.is_debuff
end

--[[
判断是否永续
(bool) 返回bool
buff (Buff)buff类
]]
function BuffData:IsForever()
    return self.is_forever
end

--[[
判断是否逐渐消退
(bool) 返回bool
buff (Buff)buff类
]]
function BuffData:IsFadeOut()
    return self.fade_out
end

function BuffData:IsHidden()
    return self.is_hidden or self.img == nil
end

function BuffData:__tostring()
    return string.format("Buff(%s-%s)", self.name, tostring(self.img))
end

local buffs = {
    Buff("auto_move_attack", 10, {
            on_add = function(self, inst, cmp, id)
                inst:AddTag(id)
            end,
            on_rm = function(self, inst, cmp, id)
                inst:AddTag(id)
            end,
        }, AssetUtil:MakeImg("cane"),
        function(self, inst, cmp, id)
            return "自动切换武器和手杖"
        end
    ),
    Buff("not_reflection", 2, {
            on_add = function(self, inst, cmp, id)
                inst:AddTag(id)
            end,
            on_rm = function(self, inst, cmp, id)
                inst:RemoveTag(id)
            end,
        }, AssetUtil:MakeImg("armorcactus"),
        function(self, inst, cmp, id)
            return "不受到反伤"
        end
    ),
    Buff("invincible", 5, {
            on_add = function(self, inst, cmp, id)
                inst.components.health:SetInvincible(true, id)
                if cmp[id .. "_fx"] == nil then
                    cmp[id .. "_fx"] = FxManager:MakeFx("force_field", Vector3(0, 0, 0))
                    inst:AddChild(cmp[id .. "_fx"])
                end
            end,
            on_rm = function(self, inst, cmp, id)
                inst.components.health:SetInvincible(false, id)
                if cmp[id .. "_fx"] then
                    cmp[id .. "_fx"]:WgRecycle()
                    cmp[id .. "_fx"] = nil
                end
            end,
        }, AssetUtil:MakeImg("ruinshat"),
        function(self, inst, cmp, id)
            return "进入无敌状态"
        end
    ),
    Buff("defense", 3, {
            on_add = function(self, inst, cmp, id)
                if cmp[id .. "_fx"] == nil then
                    cmp[id .. "_fx"] = FxManager:MakeFx("defense_fx2", Vector3(0, 0, 0))
                    inst:AddChild(cmp[id .. "_fx"])
                end
                if inst.components.combat then
                    inst.components.combat:AddDefenseMod(id, self.data[1])
                end
            end,
            on_rm = function(self, inst, cmp, id)
                if cmp[id .. "_fx"] then
                    cmp[id .. "_fx"]:WgRecycle()
                    cmp[id .. "_fx"] = nil
                end
                if inst.components.combat then
                    inst.components.combat:RmDefenseMod(id)
                end
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_58"),
        function(self, inst, cmp, id)
            return string.format("防御提升%d", self.data[1])
        end, { 100 }
    ),
    Buff("summon", 30, {
            on_add = function(self, inst, cmp, id)
                inst:AddTag("not_drop_loot")
            end,
            on_rm = function(self, inst, cmp, id)
                if inst.components.health then
                    inst.components.health:Kill()
                end
            end,
        }, AssetUtil:MakeImg("ash"),
        function(self, inst, cmp, id)
            return string.format("不会掉落战利品,buff结束后死亡")
        end
    ),
    Buff("no_loot", 100, {
        on_add = function(self, inst, cmp, id)
            inst:AddTag("not_drop_loot")
        end,
        on_rm = function(self, inst, cmp, id)
        end,
    }, AssetUtil:MakeImg("ash"), 
        function(self, inst, cmp, id)
            return string.format("不会掉落战利品")
        end, nil, nil, true
    ),
    Buff("lantern", 100, {
        on_add = function(self, inst, cmp, id)
            if cmp[id.."_fx"] == nil then
                cmp[id.."_fx"] = FxManager:MakeFx("lantern", Vector3(0, 0, 0))
                inst:AddChild(cmp[id.."_fx"])
            end
        end, 
        on_rm = function(self, inst, cmp, id)
            if cmp[id.."_fx"] then
                cmp[id.."_fx"]:WgRecycle()
                cmp[id.."_fx"] = nil
            end
        end,
    }, AssetUtil:MakeImg("lantern"),
        function(self, inst, cmp, id)
            return string.format("发光")
        end, {}, nil, true
    ),
    Buff("fire_immune", 10, {
        on_add = function(self, inst, cmp, id)
            inst:AddTag("tp_not_fire_damage")
            inst:AddTag("tp_not_burnable")
        end, 
        on_rm = function(self, inst, cmp, id)
            inst:RemoveTag("tp_not_fire_damage")
            inst:RemoveTag("tp_not_burnable")
        end,
    }, AssetUtil:MakeImg("armordragonfly"),
        function(self, inst, cmp, id)
            return string.format("免疫燃烧")
        end
    ),
    Buff("poison_immune", 10, {
        on_add = function(self, inst, cmp, id)
            inst:AddTag("tp_not_poison_damage")
            inst:AddTag("tp_not_poisonable")
        end, 
        on_rm = function(self, inst, cmp, id)
            inst:RemoveTag("tp_not_poison_damage")
            inst:RemoveTag("tp_not_poisonable")
        end,
    }, AssetUtil:MakeImg("oxhat"),
        function(self, inst, cmp, id)
            return string.format("免疫中毒")
        end
    ),
    Buff("frozen_immune", 10, {
        on_add = function(self, inst, cmp, id)
            inst:AddTag("tp_not_freezable")
        end, 
        on_rm = function(self, inst, cmp, id)
            inst:RemoveTag("tp_not_freezable")
        end,
    }, AssetUtil:MakeImg("blueamulet"),
        function(self, inst, cmp, id)
            return string.format("免疫冰冻")
        end
    ),
    Buff("attack_speed_up", 10, {
        on_add = function(self, inst, cmp, id, data)
            EntUtil:add_attack_speed_mod(inst, id, data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.attack_period_modifiers[id] or 0
            if data > n then
                EntUtil:add_attack_speed_mod(inst, id, data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            EntUtil:rm_attack_speed_mod(inst, id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_56"),
        function(self, inst, cmp, id, data)
            return string.format("提高%d%%攻速", data*100)
        end, {}
    ),
    Buff("damage_up", 10, {
        on_add = function(self, inst, cmp, id, data)
            cmp[id.."_data"] = data
            if cmp[id.."_fn"] == nil then
                cmp[id.."_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
                    return damage + cmp[id.."_data"]
                end)
            end
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            if data > cmp[id.."_data"] then
                cmp[id.."_data"] = data
            end
        end,
        on_rm = function(self, inst, cmp, id)
            if cmp[id.."_fn"] then
                inst.components.combat:WgRemoveCalcDamageFn(cmp[id.."_fn"])
                cmp[id.."_fn"] = nil
            end
            cmp[id.."_data"] = nil
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_68"),
        function(self, inst, cmp, id, data)
            return string.format("提高%d攻击", data)
        end, {}
    ),
    Buff("dmg_mult_up", 10, {
        on_add = function(self, inst, cmp, id, data)
            EntUtil:add_damage_mod(inst, id, data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.attack_damage_modifiers[id] or 0
            if data > n then
                EntUtil:add_damage_mod(inst, id, data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            EntUtil:rm_damage_mod(inst, id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_68"),
        function(self, inst, cmp, id, data)
            return string.format("提高%d%%攻击", data*100)
        end, {}
    ),
    Buff("speed_up", 6, {
        on_add = function(self, inst, cmp, id, data)
            -- EntUtil:add_speed_mod(inst, id, data)
            if inst.components.locomotor then
                inst.components.locomotor:AddSpeedModifier_Additive(id, data)
            end
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.locomotor.speed_modifiers_add[id] or 0
            if data > n then
                -- EntUtil:add_speed_mod(inst, id, data)
                if inst.components.locomotor then
                    inst.components.locomotor:AddSpeedModifier_Additive(id, data)
                end
            end
        end,
        on_rm = function(self, inst, cmp, id)
            -- EntUtil:rm_speed_mod(inst, id)
            if inst.components.locomotor then
                inst.components.locomotor:RemoveSpeedModifier_Additive(id)
            end
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_70"),
        function(self, inst, cmp, id, data)
            return string.format("提高%d移速", data)
        end, {}
    ),
    Buff("speed_mult_up", 6, {
        on_add = function(self, inst, cmp, id, data)
            EntUtil:add_speed_mod(inst, id, data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.locomotor.speed_modifiers_mult[id] or 0
            if data > n then
                EntUtil:add_speed_mod(inst, id, data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            EntUtil:rm_speed_mod(inst, id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_70"),
        function(self, inst, cmp, id, data)
            return string.format("提高%d%%移速", data*100)
        end, {}
    ),
    Buff("defense_up", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.combat:AddDefenseMod(id, data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.tp_defense_mods[id] or 0
            if data > n then
                inst.components.combat:AddDefenseMod(id, data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.combat:RmDefenseMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_52"),
        function(self, inst, cmp, id, data)
            return string.format("提高%d防御", data)
        end, {}
    ),
    Buff("penetrate_up", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.combat:AddPenetrateMod(id, data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.tp_penetrate_mods[id] or 0
            if data > n then
                inst.components.combat:AddPenetrateMod(id, data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.combat:RmPenetrateMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_73"),
        function(self, inst, cmp, id, data)
            return string.format("提高%d穿透", data)
        end, {}
    ),
    Buff("evade_up", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.combat:AddEvadeRateMod(id, data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.tp_evade_mods[id] or 0
            if data > n then
                inst.components.combat:AddEvadeRateMod(id, data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.combat:RmEvadeRateMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_61"),
        function(self, inst, cmp, id, data)
            return string.format("提高%d闪避", data)
        end, {}
    ),
    Buff("hit_rate_up", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.combat:AddHitRateMod(id, data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.tp_hit_rate_mods[id] or 0
            if data > n then
                inst.components.combat:AddHitRateMod(id, data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.combat:RmHitRateMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_59"),
        function(self, inst, cmp, id, data)
            return string.format("提高%d命中", data)
        end, {}
    ),
    Buff("crit_up", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.combat:AddCritRateMod(id, data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.tp_crit_mods[id] or 0
            if data > n then
                inst.components.combat:AddCritRateMod(id, data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.combat:RmCritRateMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_63"),
        function(self, inst, cmp, id, data)
            return string.format("提高%d%%暴击", data*100)
        end, {}
    ),
    Buff("life_steal_up", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.combat:AddLifeStealRateMod(id, data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.tp_life_steal_mods[id] or 0
            if data > n then
                inst.components.combat:AddLifeStealRateMod(id, data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.combat:RmLifeStealRateMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_76"),
        function(self, inst, cmp, id, data)
            return string.format("提高%d%%吸血", data*100)
        end, {}
    ),
    Buff("recover_up", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.health:AddRecoverRateMod(id, data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.health.tp_recover_mods[id] or 0
            if data > n then
                inst.components.health:AddRecoverRateMod(id, data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.health:RmRecoverRateMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_72"),
        function(self, inst, cmp, id, data)
            return string.format("提高%d%%生命恢复效果", data*100)
        end, {}
    ),
    Buff("torch", 120, {
        on_add = function(self, inst, cmp, id)
            if cmp[id.."_fx"] == nil then
                local fx = SpawnPrefab("torchfire")
                inst:AddChild(fx)
                fx.Transform:SetPosition(0,0,0)
                cmp[id.."_fx"] = fx
            end
        end,
        on_rm = function(self, inst, cmp, id)
            if cmp[id.."_fx"] then
                cmp[id.."_fx"]:Remove()
                cmp[id.."_fx"] = nil
            end
        end,
    }, AssetUtil:MakeImg("torch"), 
        function(self, inst, cmp, id)
            return string.format("燃起一束火焰在你的脚下")
        end
    ),
    Buff("willow_skill", 20, {
        on_add = function(self, inst, cmp, id)
            if cmp[id.."_fn"] == nil then
                cmp[id.."_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
                    if EntUtil:in_stimuli(stimuli, "fire") 
                    and EntUtil:in_stimuli(stimuli, "magic") then
                        damage = damage + self.data[1]
                    end
                    return damage
                end) 
            end
        end, 
        on_rm = function(self, inst, cmp, id)
            if cmp[id.."_fn"] then
                inst.components.combat:WgRemoveCalcDamageFn(cmp[id.."_fn"])
                cmp[id.."_fn"] = nil
            end
        end,
    }, AssetUtil:MakeImg("tp_scrolls2", "tp_scroll_fire1"),
        function(self, inst, cmp, id)
            return string.format("你的火魔法伤害%+d", self.data[1])
        end, {30}
    ),
    Buff("tp_spear_overload", 10, {
        on_add = function(self, inst, cmp, id)
            EntUtil:add_attack_speed_mod(inst, id, self.data[1])
            EntUtil:add_damage_mod(inst, id, self.data[2])
        end,
        on_rm = function(self, inst, cmp, id)
            EntUtil:rm_attack_speed_mod(inst, id)
            EntUtil:rm_damage_mod(inst, id)
        end,
    }, AssetMaster:GetUimg("tp_spear_overload"),
        function(self, inst, cmp, id)
            return string.format("增加%d%%攻击力和攻速", self.data[1]*100)
        end, {.2}
    ),
    Buff("tp_spear_conqueror3", 5, {
            on_add = function(self, inst, cmp, id, data)
                cmp[id .. "_data"] = data
                inst.components.health:WgAddMaxHealthModifier(id, data, true)
            end,
            on_repeat = function(self, inst, cmp, id)
            end,
            on_rm = function(self, inst, cmp, id)
                inst.components.health:WgRemoveMaxHealthModifier(id)
                cmp[id .. "_data"] = nil
            end,
        }, AssetMaster:GetUimg("tp_spear_conqueror"),
        function(self, inst, cmp, id)
            local n = cmp[id .. "_data"] or 0
            return string.format("提升%d生命", n)
        end
    ),
    -- lol
    Buff("tp_spear_jarvaniv", 1, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_attack_speed_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_attack_speed_mod(inst, id)
            end,
        }, AssetMaster:GetUimg("tp_spear_jarvaniv"),
        function(self, inst, cmp, id)
            return string.format("增加%d%%攻速", -self.data[1] * 100)
        end, { -.15 }
    ),
    Buff("tp_helm_monk", 2, {
            on_add = function(self, inst, cmp, id)
                inst:AddTag(id)
            end,
            on_rm = function(self, inst, cmp, id)
                inst:RemoveTag(id)
            end,
        }, AssetMaster:GetUimg("tp_helm_monk"),
        function(self, inst, cmp, id)
            return string.format("攻击增加武僧头盔充能")
        end
    ),
    Buff("tp_armor_monk2", 4, {
            on_add = function(self, inst, cmp, id)
                inst.components.combat:AddLifeStealRateMod(id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                inst.components.combat:RmLifeStealRateMod(id)
            end,
        }, AssetMaster:GetUimg("tp_armor_monk"),
        function(self, inst, cmp, id)
            return string.format("增加%d%%吸血", self.data[1] * 100)
        end, { .15 }
    ),
    Buff("tp_helm_jax", 4, {
            on_add = function(self, inst, cmp, id)
                inst.components.combat:AddEvadeRateMod(id, self.data[1])
                if cmp[id .. "_fx"] == nil then
                    cmp[id .. "_fx"] = FxManager:MakeFx("tp_armor_jax_fx", Vector3(0, 0, 0), { owner = inst })
                end
            end,
            on_rm = function(self, inst, cmp, id)
                inst.components.combat:RmEvadeRateMod(id)
                if cmp[id .. "_fx"] then
                    cmp[id .. "_fx"]:WgRecycle()
                    cmp[id .. "_fx"] = nil
                end
            end,
        }, AssetMaster:GetUimg("tp_helm_jax"),
        function(self, inst, cmp, id)
            return string.format("增加%d闪避", self.data[1] * 100)
        end, { 1 }
    ),
    -- lol over
    Buff("tp_armor_strong3", 5, {
            on_add = function(self, inst, cmp, id)
                if cmp[id .. "_task"] == nil then
                    cmp[id .. "_task"] = inst:DoPeriodicTask(1, function()
                        local max = inst.components.health:GetMaxHealth()
                        inst.components.health:DoDelta(max * self.data[1])
                    end)
                end
            end,
            on_rm = function(self, inst, cmp, id)
                if cmp[id .. "_task"] then
                    cmp[id .. "_task"]:Cancel()
                    cmp[id .. "_task"] = nil
                end
            end,
        }, AssetMaster:GetUimg("tp_armor_strong"),
        function(self, inst, cmp, id)
            return string.format("每秒回复%d%%最大生命值", self.data[1] * 100)
        end, { 0.01 }
    ),
    Buff("tp_scroll_electric2", 50, {
        on_add = function(self, inst, cmp, id, data)
            if cmp[id.."_fx"] == nil then
                cmp[id.."_fx"] = FxManager:MakeFx("scroll_electric2", inst, data)
            end
            inst.components.combat:AddDmgTypeAbsorb("electric", -self.data[1])
            inst.components.combat:AddDmgTypeAbsorb("spike", -self.data[1])
        end, 
        on_rm = function(self, inst, cmp, id)
            if cmp[id.."_fx"] then
                cmp[id.."_fx"]:WgRecycle()
                cmp[id.."_fx"] = nil
            end
            inst.components.combat:AddDmgTypeAbsorb("electric", self.data[1])
            inst.components.combat:AddDmgTypeAbsorb("spike", self.data[1])
        end,
    }, AssetUtil:MakeImg("tp_scrolls2", "tp_scroll_electric2"),
        function(self, inst, cmp, id)
            return string.format("召唤3个电球环绕自身,受到的刺和雷属性伤害降低%d%%", self.data[1]*100)
        end, {.2}
    ),
    Buff("tp_scroll_holly2", 50, {
        on_add = function(self, inst, cmp, id, data)
            if cmp[id.."_fx"] == nil then
                cmp[id.."_fx"] = FxManager:MakeFx("scroll_holly2", inst, data)
            end
            inst.components.combat:AddDmgTypeAbsorb("holly", -self.data[1])
            inst.components.combat:AddDmgTypeAbsorb("slash", -self.data[1])
        end, 
        on_rm = function(self, inst, cmp, id)
            if cmp[id.."_fx"] then
                cmp[id.."_fx"]:WgRecycle()
                cmp[id.."_fx"] = nil
            end
            inst.components.combat:AddDmgTypeAbsorb("holly", self.data[1])
            inst.components.combat:AddDmgTypeAbsorb("slash", self.data[1])
        end,
    }, AssetUtil:MakeImg("tp_scrolls2", "tp_scroll_holly2"),
        function(self, inst, cmp, id)
            return string.format("受到的斩和圣属性伤害降低%d%%", self.data[1]*100)
        end, {.3}
    ),

    Buff("tp_scroll_templar", 300, {
            on_add = function(self, inst, cmp, id)
                cmp[id .. "_fn"] = EntUtil:listen_for_event(inst, "onhitother", function(inst, data)
                    if cmp[id .. "_task"] == nil then
                        cmp[id .. "_task"] = inst:DoTaskInTime(self.data[3], function()
                            cmp[id .. "_task"] = nil
                        end)
                        local fx = FxManager:MakeFx("templar_magic", inst, { owner = inst, target = data.target })
                    end
                end)
            end,
            on_rm = function(self, inst, cmp, id)
                if cmp[id .. "_fn"] then
                    inst:RemoveEventCallback("onhitother", cmp[id .. "_fn"])
                end
                if cmp[id .. "_task"] then
                    cmp[id .. "_task"]:Cancel()
                    cmp[id .. "_task"] = nil
                end
            end,
        }, AssetMaster:GetUimg("tp_spear_lance"),
        function(self, inst, cmp, id)
            local buff = Sample.BuffManager:GetDataById("tp_templar_proj_debuff")
            return string.format("攻击时召唤一圈战矛,环绕一会后会攻击敌人,令其获得debuff(%s),有%ds的冷却",
                buff:desc(nil, { stacks = {} }, buff:GetId()), self.data[3])
        end, { .2, .2, 6 }
    ),
    -- equip buff
    Buff("chase_target", 6, {
        on_add = function(self, inst, cmp, id)
            if cmp[id.."_fx"] == nil then
                cmp[id.."_fx"] = FxManager:MakeFx("strong_fx", Vector3(0,0,0))
                inst:AddChild(cmp[id.."_fx"])
            end
            EntUtil:add_speed_mod(inst, id, self.data[1])
        end, 
        on_rm = function(self, inst, cmp, id)
            if cmp[id.."_fx"] then
                cmp[id.."_fx"]:WgRecycle()
                cmp[id.."_fx"] = nil
            end
            EntUtil:rm_speed_mod(inst, id)
        end,
    }, AssetUtil:MakeImg("ash"),
        function(self, inst, cmp, id)
            return string.format("增加%d%%移速", self.data[1]*100)
        end, {.5}
    ),
    Buff("ask_flag_buff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_damage_mod(inst, id, self.data[1])
                EntUtil:add_speed_mod(inst, id, self.data[2])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_damage_mod(inst, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("spear"),
        function(self, inst, cmp, id)
            return string.format("增加%d%%的攻击力,%d的移速",
                self.data[1] * 100, self.data[2])
        end, { .1, .2 }
    ),
    Buff("iron_solari_buff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
                inst.components.combat:AddDefenseMod(id, self.data[2])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
                inst.components.combat:RmDefenseMod(id)
            end,
        }, AssetUtil:MakeImg("cane"),
        function(self, inst, cmp, id)
            return string.format("增加%d%%的移速,%d的防御力",
                self.data[1] * 100, self.data[2])
        end, { .1, 20 }
    ),
    Buff("sterakgage_buff", 8, {
        on_add = function(self, inst, cmp, id)
            EntUtil:add_damage_mod(inst, id, self.data[1])
        end,
        on_rm = function(self, inst, cmp, id)
            EntUtil:rm_damage_mod(inst, id)
        end,
    }, AssetUtil:MakeImg("spear"),
        function(self, inst, cmp, id)
            return string.format("增加%d%%的攻击",
                self.data[1]*100)
        end, {.2}
    ),
    Buff("phantom_dancer_buff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
                inst.components.combat:AddEvadeRateMod(id, self.data[2])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
                inst.components.combat:RmEvadeRateMod(id)
            end,
        }, AssetUtil:MakeImg("spear"),
        function(self, inst, cmp, id)
            return string.format("增加%d%%的移速,%d%%的闪避",
                self.data[1] * 100, self.data[2])
        end, { .25, 50 }
    ),
    Buff("nature_force_buff", 8, {
            on_add = function(self, inst, cmp, id)
                local n = cmp.stacks[id] or 0
                n = math.min(self.data[1], n + 1)
                cmp.stacks[id] = n
                if n >= self.data[1] then
                    inst.components.combat:AddDefenseMod(id, self.data[2])
                end
            end,
            on_rm = function(self, inst, cmp, id)
                cmp.stacks[id] = nil
                inst.components.combat:RmDefenseMod(id)
            end,
        }, AssetUtil:MakeImg("armorwood"),
        function(self, inst, cmp, id)
            local n = cmp.stacks[id] or 1
            return string.format("叠加至5层时,增加%d防御,当前层数(%d)",
                self.data[2], n)
        end, { 5, 30 }
    ),
    Buff("malmortius_maw_buff", 10, {
            on_add = function(self, inst, cmp, id)
                if cmp[id.."_fx"] == nil then
                    cmp[id.."_fx"] = FxManager:MakeFx("elem_defense_fx2", Vector3(0,0,0))
                    inst:AddChild(cmp[id.."_fx"])
                end
                inst.components.combat:AddDmgTypeAbsorb("fire", self.data[1])
                inst.components.combat:AddDmgTypeAbsorb("ice", self.data[1])
                inst.components.combat:AddDmgTypeAbsorb("poison", self.data[1])
                inst.components.combat:AddDmgTypeAbsorb("electric", self.data[1])
                inst.components.combat:AddLifeStealRateMod(id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                if cmp[id.."_fx"] then
                    cmp[id.."_fx"]:WgRecycle()
                    cmp[id.."_fx"] = nil
                end
                inst.components.combat:AddDmgTypeAbsorb("fire", -self.data[1])
                inst.components.combat:AddDmgTypeAbsorb("ice", -self.data[1])
                inst.components.combat:AddDmgTypeAbsorb("poison", -self.data[1])
                inst.components.combat:AddDmgTypeAbsorb("electric", -self.data[1])
                inst.components.combat:RmLifeStealRateMod(id)
            end,
        }, AssetUtil:MakeImg("batbat"),
        function(self, inst, cmp, id)
            return string.format("获得%d%%吸血,提高%d%%冰火毒雷抗性", 
                self.data[1] * 100, self.data[2]*100)
        end, { .5, .3 }
    ),
    Buff("wit_end_buff", 8, {
            on_add = function(self, inst, cmp, id)
                local n = cmp.stacks[id] or 0
                n = math.min(self.data[1], n + 1)
                cmp.stacks[id] = n
                inst.components.combat:AddEvadeRateMod(id, self.data[2] * n)
            end,
            on_rm = function(self, inst, cmp, id)
                cmp.stacks[id] = nil
                inst.components.combat:RmEvadeRateMod(id)
            end,
        }, AssetUtil:MakeImg("armorwood"),
        function(self, inst, cmp, id)
            local n = cmp.stacks[id] or 1
            return string.format("每层提供%d的闪避,最多%d层,当前层数(%d)",
                self.data[2], self.data[1], n)
        end, { 6, 15, }
    ),
    Buff("death_dance_buff", 10, {
            on_add = function(self, inst, cmp, id)
                if inst.components.health then
                    local max_hp = inst.components.health:GetPercent()
                    inst.components.health:DoDelta(max_hp * self.data[1])
                end
                if inst.components.combat then
                    inst.components.combat:AddDefenseMod(id, self.data[2])
                end
            end,
            on_rm = function(self, inst, cmp, id)
                if inst.components.combat then
                    inst.components.combat:RmDefenseMod(id)
                end
            end,
        }, AssetUtil:MakeImg("bandage"),
        function(self, inst, cmp, id)
            return string.format("回复%d%%最大生命值,并提升%d防御",
                self.data[1] * 100, self.data[2])
        end, { .15, 30 }
    ),
    Buff("navori_quickblades_buff", 6, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
                inst.components.combat:AddEvadeRateMod(id, self.data[2])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
                inst.components.combat:RmEvadeRateMod(id)
            end,
        }, AssetUtil:MakeImg("cane"),
        function(self, inst, cmp, id)
            return string.format("提升%d%%移速,并提升%d闪避",
                self.data[1] * 100, self.data[2])
        end, { .3, 40 }
    ),
    Buff("rageknife_buff", 5, {
            on_add = function(self, inst, cmp, id)
                local n = cmp.stacks[id] or 0
                n = math.min(self.data[1], n + 1)
                cmp.stacks[id] = n
                EntUtil:add_attack_speed_mod(inst, id, self.data[2] * n)
            end,
            on_rm = function(self, inst, cmp, id)
                cmp.stacks[id] = nil
                EntUtil:rm_attack_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("cutlass"),
        function(self, inst, cmp, id)
            local n = cmp.stacks[id] or 1
            return string.format("每层提供%d%%的攻速,最多%d层,当前层数(%d)",
                -self.data[2] * 100, self.data[1], n)
        end, { 3, -.05, }
    ),
    Buff("hexdrinker_buff", 10, {
        on_add = function(self, inst, cmp, id)
            if cmp[id.."_fx"] == nil then
                cmp[id.."_fx"] = FxManager:MakeFx("elem_defense_fx", Vector3(0,0,0))
                inst:AddChild(cmp[id.."_fx"])
            end
            inst.components.combat:AddDmgTypeAbsorb("fire", self.data[1])
            inst.components.combat:AddDmgTypeAbsorb("ice", self.data[1])
            inst.components.combat:AddDmgTypeAbsorb("poison", self.data[1])
            inst.components.combat:AddDmgTypeAbsorb("electric", self.data[1])
        end, 
        on_rm = function(self, inst, cmp, id)
            if cmp[id.."_fx"] then
                cmp[id.."_fx"]:WgRecycle()
                cmp[id.."_fx"] = nil
            end
            inst.components.combat:AddDmgTypeAbsorb("fire", -self.data[1])
            inst.components.combat:AddDmgTypeAbsorb("ice", -self.data[1])
            inst.components.combat:AddDmgTypeAbsorb("poison", -self.data[1])
            inst.components.combat:AddDmgTypeAbsorb("electric", -self.data[1])
        end,
    }, AssetUtil:MakeImg("ash"),
        function(self, inst, cmp, id)
            return string.format("提高%d%%冰火毒雷抗性", self.data[1]*100)
        end, {-.2}
    ),
    Buff("hearthbound_axe_buff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("cane"),
        function(self, inst, cmp, id)
            return string.format("提升%d%%移速",
                self.data[1] * 100)
        end, { .2 }
    ),
    Buff("aegis_legion_buff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_damage_mod(inst, id, self.data[1])
                inst.components.combat:AddDefenseMod(id, self.data[2])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_damage_mod(inst, id)
                inst.components.combat:RmDefenseMod(id)
            end,
        }, AssetUtil:MakeImg("spear"),
        function(self, inst, cmp, id)
            return string.format("增加%d%%的攻击力,%d的防御力",
                self.data[1] * 100, self.data[2])
        end, { .05, 10 }
    ),
    Buff("duskblade_draktharr_buff", 4, {
            on_add = function(self, inst, cmp, id)
                inst:Hide()
                inst:AddTag("wg_cant_target")
            end,
            on_rm = function(self, inst, cmp, id)
                inst:Show()
                inst:RemoveTag("wg_cant_target")
            end,
        }, AssetUtil:MakeImg("bushhat"),
        function(self, inst, cmp, id)
            return "你不被选取为攻击目标"
        end, nil
    ),
    Buff("eclipse_buff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("cane"),
        function(self, inst, cmp, id)
            return string.format("提升%d%%移速",
                self.data[1] * 100)
        end, { .15 }
    ),
    Buff("immortal_shieldbow_buff", 8, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_damage_mod(inst, id, self.data[1])
                inst.components.combat:AddLifeStealRateMod(id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_damage_mod(inst, id)
                inst.components.combat:RmLifeStealRateMod(id)
            end,
        }, AssetUtil:MakeImg("batbat"),
        function(self, inst, cmp, id)
            return string.format("提升%d%%吸血和攻击",
                self.data[1] * 100)
        end, { .25 }
    ),
    Buff("kraken_slayer_buff", 2, {
            on_add = function(self, inst, cmp, id)
                inst.components.combat:AddPenetrateMod(id, self.data[1])
                inst.components.combat:AddHitRateMod(id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                inst.components.combat:RmPenetrateMod(id)
                inst.components.combat:RmHitRateMod(id)
            end,
        }, AssetUtil:MakeImg("tentaclespike"),
        function(self, inst, cmp, id)
            return string.format("提升%d穿透和命中",
                self.data[1])
        end, { 100 }
    ),
    Buff("stride_breaker_buff", 3, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("cane"),
        function(self, inst, cmp, id)
            return string.format("提升%d%%移速",
                self.data[1] * 100)
        end, { .2 }
    ),
    Buff("trinity_force_buff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[3])
                local n = cmp.stacks[id] or 0
                n = math.min(self.data[1], n + 1)
                cmp.stacks[id] = n
                EntUtil:add_damage_mod(inst, id, self.data[2] * n)
            end,
            on_rm = function(self, inst, cmp, id)
                cmp.stacks[id] = nil
                EntUtil:rm_damage_mod(inst, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("cane"),
        function(self, inst, cmp, id)
            local n = cmp.stacks[id] or 1
            return string.format("提升%d%%移速,每层提供%d%%的攻击,最多%d层,当前层数(%d)",
                self.data[3] * 100, self.data[2] * 100, self.data[1], n)
        end, { 5, .06, .25 }
    ),
    Buff("locket_IronSolari_buff", 8, {
            on_add = function(self, inst, cmp, id)
                inst.components.combat:AddDefenseMod(id, self.data[1])
                inst.components.combat:AddEvadeRateMod(id, self.data[2])
                -- inst.components.health:WgAddMaxHealthModifier(id, self.data[3], true)
            end,
            on_rm = function(self, inst, cmp, id)
                inst.components.combat:RmDefenseMod(id)
                inst.components.combat:RmEvadeRateMod(id)
                -- inst.components.health:WgRemoveMaxHealthModifier(id, true)
            end,
        }, AssetUtil:MakeImg("armorwood"),
        function(self, inst, cmp, id)
            return string.format("提升%d防御,提升%d闪避",
                self.data[1], self.data[2])
        end, { 30, 30, 250 }
    ),
    Buff("heart_steel_buff", 100, {
            on_add = function(self, inst, cmp, id)
                local n = cmp.stacks[id] or 0
                n = math.min(self.data[1], n + 1)
                local max_hp = inst.components.health.wg_max_health
                local dt = max_hp * self.data[2] + self.data[3]
                cmp.stacks[id] = n
                inst.components.health:WgAddMaxHealthModifier(id, n * dt)
                inst.components.health:DoDelta(dt)
            end,
            on_rm = function(self, inst, cmp, id)
                cmp.stacks[id] = nil
                inst.components.health:WgRemoveMaxHealthModifier(id)
            end,
        }, AssetUtil:MakeImg("amulet"),
        function(self, inst, cmp, id)
            local n = cmp.stacks[id] or 1
            return string.format("回复基础最大生命%d%%+%d的生命值,并提升等量最大生命,可叠加,当前层数(%d)",
                self.data[2] * 100, self.data[3], n)
        end, { 9999, .1, 50 }, nil, true
    ),
    Buff("gear_core_wake", 300, {
        on_add = function(self, inst, cmp, id)
            inst:AddTag(id)
            EntUtil:add_attack_speed_mod(inst, id, -0.3)
            EntUtil:add_speed_mod(inst, id, .3)
        end, 
        on_rm = function(self, inst, cmp, id)
            inst:RemoveTag(id)
            EntUtil:rm_attack_speed_mod(inst, id)
            EntUtil:rm_speed_mod(inst, id)
        end,
    }, AssetUtil:MakeImg("gear"),
        function(self, inst, cmp, id)
            return string.format("增加%d%%攻速和移速", self.data[1]*100)
        end, {.3}
    ),

    -- equip buff over
    Buff("determination", 10, {
            on_add = function(self, inst, cmp, id, _data)
                if cmp[id .. "_fn"] == nil then
                    cmp[id .. "_data"] = _data
                    cmp[id .. "_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
                        local data = { damage = damage, inst = inst, target = target, weapon = weapon }
                        local dmg = data.damage
                        BuffManager:ClearBuff(inst, id)
                        dmg = dmg + dmg * _data
                        return dmg
                    end)
                end
            end,
            on_rm = function(self, inst, cmp, id)
                if cmp[id .. "_fn"] then
                    inst.components.combat:WgRemoveCalcDamageFn(cmp[id .. "_fn"])
                end
                cmp[id .. "_fn"] = nil
                cmp[id .. "_data"] = nil
            end,
        }, AssetUtil:MakeImg("spear"),
        function(self, inst, cmp, id)
            local rate = cmp[id .. "_data"] or 0
            return string.format("下次攻击提升%d%%攻击力", rate * 100)
        end
    ),
    Buff("guardian", 10, {
            on_add = function(self, inst, cmp, id, _data)
                cmp[id .. "_data"] = _data
                inst.components.combat:AddDefenseMod(id, _data)
                if cmp[id .. "_fn"] == nil then
                    cmp[id .. "_fn"] = EntUtil:listen_for_event(inst,
                        "attacked", function(inst, data)
                            BuffManager:ClearBuff(inst, id)
                        end
                    )
                end
                local fx = FxManager:MakeFx("guardian", Vector3(0, 0, 0))
                inst:AddChild(fx)
            end,
            on_rm = function(self, inst, cmp, id)
                cmp[id .. "_data"] = nil
                if cmp[id .. "_fn"] then
                    inst:RemoveEventCallback("attacked", cmp[id .. "_fn"])
                    cmp[id .. "_fn"] = nil
                end
                inst.components.combat:RmDefenseMod(id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_58"),
        function(self, inst, cmp, id)
            local rate = cmp[id .. "_data"] or 0
            return string.format("提升%d的防御", rate)
        end
    ),
    -- potion
    Buff("tp_potion_vigor", 180, {
        on_add = function(self, inst, cmp, id)
            if inst.components.tp_val_vigor then
                inst.components.tp_val_vigor:AddRateMod(id, self.data[1])
            end
        end, 
        on_rm = function(self, inst, cmp, id)
            if inst.components.tp_val_vigor then
                inst.components.tp_val_vigor:RmRateMod(id)
            end
        end,
    }, AssetMaster:GetUimg("tp_potion_vigor"),
        function(self, inst, cmp, id)
            return string.format("增加精力恢复速度", self.data[1])
        end, {.15}
    ),
    Buff("tp_potion_warth", 180, {
        on_add = function(self, inst, cmp, id)
            EntUtil:add_damage_mod(inst, id, self.data[1])
            if cmp[id .. "_task"] == nil then
                cmp[id .. "_task"] = inst:DoPeriodicTask(1, function()
                    inst.components.health:DoDelta(-1, nil, true)
                end)
            end
        end, 
        on_rm = function(self, inst, cmp, id)
            EntUtil:rm_damage_mod(inst, id)
            if cmp[id .. "_task"] then
                cmp[id .. "_task"]:Cancel()
                cmp[id .. "_task"] = nil
            end
        end,
    }, AssetMaster:GetUimg("tp_potion_warth"),
        function(self, inst, cmp, id)
            return string.format("增加攻击力,不断流失生命", self.data[1])
        end, {.2}
    ),
    Buff("tp_potion_defense", 180, {
        on_add = function(self, inst, cmp, id)
            inst.components.combat:AddDefenseMod(id, self.data[1])
            EntUtil:add_speed_mod(inst, id, self.data[2])
        end, 
        on_rm = function(self, inst, cmp, id)
            inst.components.combat:RmDefenseMod(id)
            EntUtil:rm_speed_mod(inst, id)
        end,
    }, AssetMaster:GetUimg("tp_potion_defense"),
        function(self, inst, cmp, id)
            return string.format("提供防御,轻微降低移速", self.data[1])
        end, {40, .1}
    ),
    -- Buff("tp_potion_fire_atk", 180, {
    --     on_add = function(self, inst, cmp, id)
    --         if cmp[id .. "_fn"] == nil then
    --             cmp[id .. "_fn"] = inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
    --                 if not EntUtil:in_stimuli(stimuli, "pure") then
    --                     EntUtil:get_attacked(target, inst, self.data[1], nil, EntUtil:add_stimuli(nil, "pure", "fire"))
    --                 end
    --             end)
    --         end
    --         cmp[id.."_fn2"] = EntUtil:listen_for_event(inst, "unequip", function(inst, data)
    --             if data and data.eslot == EQUIPSLOTS.HANDS then
    --                 BuffManager:ClearBuff(inst, id)
    --             end
    --         end)
    --     end, 
    --     on_rm = function(self, inst, cmp, id)
    --         if cmp[id .. "_fn"] then
    --             inst.components.combat:WgRemoveOnHitFn(cmp[id .. "_fn"])
    --             cmp[id .. "_fn"] = nil
    --         end
    --         inst:RemoveEventCallback("unequip", cmp[id.."_fn2"])
    --     end,
    -- }, AssetMaster:GetUimg("tp_potion_fire_atk"),
    --     function(self, inst, cmp, id)
    --         return string.format("你当前的武器攻击会额外造成%d点火属性伤害", self.data[1])
    --     end, {40}
    -- ),
    -- potion over
    -- food effect
    -- Buff("atk_spd_food", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             EntUtil:add_attack_speed_mod(inst, id, self.data[1])
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             EntUtil:rm_attack_speed_mod(inst, id)
    --         end,
    --     }, AssetUtil:MakeImg("cutlass"),
    --     function(self, inst, cmp, id)
    --         return string.format("增加%d%%攻速", self.data[1] * 100)
    --     end, { .15 }
    -- ),
    -- Buff("max_attr_food", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.health:WgAddMaxHealthModifier(self.data[1], true)
    --             inst.components.sanity:WgAddMaxSanityModifier(self.data[1], true)
    --             inst.components.hunger:WgAddMaxHungerModifier(self.data[1], true)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             inst.components.health:WgRemoveMaxHealthModifier(true)
    --             inst.components.sanity:WgRemoveMaxSanityModifier(true)
    --             inst.components.hunger:WgRemoveMaxHungerModifier(true)
    --         end,
    --     }, AssetUtil:MakeImg("dragonpie"),
    --     function(self, inst, cmp, id)
    --         return string.format("增加%d三围上限", self.data[1])
    --     end, { 100 }
    -- ),
    -- Buff("giant_hunter", 20, {
    --         on_add = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] == nil then
    --                 cmp[id .. "_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
    --                     local data = { damage = damage, inst = inst, target = target, weapon = weapon }
    --                     local dmg = data.damage
    --                     if data.target and (data.target:HasTag("largecreature")
    --                             or data.target:HasTag("epic")) then
    --                         dmg = dmg + self.data[1]
    --                         BuffManager:ClearBuff(inst, id)
    --                     end
    --                     return dmg
    --                 end)
    --             end
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] then
    --                 inst.components.combat:WgRemoveCalcDamageFn(cmp[id .. "_fn"])
    --                 cmp[id .. "_fn"] = nil
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("hambat"),
    --     function(self, inst, cmp, id)
    --         return string.format("下次攻击对大型生物或史诗生物额外造成%d点伤害", self.data[1])
    --     end, { 40 }
    -- ),
    -- Buff("other_max_hg+2", 10, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.hunger:WgAddMaxHungerModifier(id, self.data[1])
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             inst.components.hunger:WgRemoveMaxHungerModifier(id)
    --         end,
    --     }, AssetUtil:MakeImg("ak_icons", "ak_half_hunger"),
    --     function(self, inst, cmp, id)
    --         return string.format("提升%d饥饿上限", self.data[1])
    --     end, { 20 }
    -- ),
    -- Buff("taste_give_food", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] == nil then
    --                 cmp[id .. "_fn"] = EntUtil:listen_for_event(inst,
    --                     "tp_taste_delta", function(inst, data)
    --                         local food2 = SpawnPrefab("carrot")
    --                         food2.components.tp_food_effect:Random()
    --                         inst.components.inventory:GiveItem(food2)
    --                     end
    --                 )
    --             end
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] then
    --                 inst:RemoveEventCallback("tp_taste_delta", cmp[id .. "_fn"])
    --                 cmp[id .. "_fn"] = nil
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("cookpot"),
    --     function(self, inst, cmp, id)
    --         return string.format("消耗品尝值时，获得1个随机词条的胡萝卜")
    --     end, {}
    -- ),
    -- Buff("skill_sp1", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] == nil then
    --                 cmp[id .. "_fn"] = EntUtil:listen_for_event(inst,
    --                     "tp_equip_skill", function(inst, data)
    --                         inst.components.sanity:DoDelta(self.data[1])
    --                     end
    --                 )
    --             end
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] then
    --                 inst:RemoveEventCallback("tp_equip_skill", cmp[id .. "_fn"])
    --                 cmp[id .. "_fn"] = nil
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("green_cap"),
    --     function(self, inst, cmp, id)
    --         return string.format("释放技能时回复%d理智", self.data[1])
    --     end, { 5 }
    -- ),
    -- Buff("skill_many_pog", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] == nil then
    --                 cmp[id .. "_fn"] = EntUtil:listen_for_event(inst,
    --                     "tp_equip_skill", function(inst, data)
    --                         local pos = Kit:find_walk_pos(inst, math.random(3, 5))
    --                         if pos then
    --                             FxManager:MakeFx("statue_transition_2", pos)
    --                             local pet = SpawnPrefab("pog")
    --                             pet.Transform:SetPosition(pos:Get())
    --                             inst.components.leader:AddFollower(pet)
    --                             pet.components.follower:AddLoyaltyTime(9999)
    --                             BuffManager:AddBuff(pet, "summon", 20)
    --                         end
    --                     end
    --                 )
    --             end
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] then
    --                 inst:RemoveEventCallback("tp_equip_skill", cmp[id .. "_fn"])
    --                 cmp[id .. "_fn"] = nil
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("monkeyball"),
    --     function(self, inst, cmp, id)
    --         return string.format("释放技能时召唤一只哈巴狸")
    --     end, {}
    -- ),
    -- Buff("next_dmg_up1", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] == nil then
    --                 cmp[id .. "_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
    --                     local data = { damage = damage, inst = inst, target = target, weapon = weapon }
    --                     BuffManager:ClearBuff(inst, id)
    --                     local dmg = data.damage
    --                     return dmg + self.data[1]
    --                 end)
    --             end
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] then
    --                 inst.components.combat:WgRemoveCalcDamageFn(cmp[id .. "_fn"])
    --                 cmp[id .. "_fn"] = nil
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("peg_leg"),
    --     function(self, inst, cmp, id)
    --         return string.format("下次攻击提升%d攻击力", self.data[1])
    --     end, { 5 }
    -- ),
    -- Buff("food_next_def1", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] == nil then
    --                 cmp[id .. "_fn"] = inst.components.combat:AddAttackedCalcFn(function(damage, attacker, inst, weapon,
    --                                                                                      stimuli)
    --                     BuffManager:ClearBuff()
    --                     local dmg = damage
    --                     return dmg - dmg * self.data[1]
    --                 end)
    --             end
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] then
    --                 inst.components.combat:RemoveAttackedCalcFn(cmp[id .. "_fn"])
    --                 cmp[id .. "_fn"] = nil
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("armorgrass"),
    --     function(self, inst, cmp, id)
    --         return string.format("受到的下次攻击降低%d%%", self.data[1] * 100)
    --     end, { .3 }
    -- ),
    -- Buff("food_next_def2", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] == nil then
    --                 cmp[id .. "_fn"] = inst.components.combat:AddAttackedCalcFn(function(damage, attacker, inst, weapon,
    --                                                                                      stimuli)
    --                     BuffManager:ClearBuff()
    --                     local dmg = damage
    --                     return dmg - dmg * self.data[1]
    --                 end)
    --             end
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] then
    --                 inst.components.combat:RemoveAttackedCalcFn(cmp[id .. "_fn"])
    --                 cmp[id .. "_fn"] = nil
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("armorwood"),
    --     function(self, inst, cmp, id)
    --         return string.format("受到的下次攻击降低%d%%", self.data[1] * 100)
    --     end, { .6 }
    -- ),
    -- Buff("weapon_dmg_up1", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] == nil then
    --                 cmp[id .. "_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
    --                     local data = { damage = damage, inst = inst, target = target, weapon = weapon }
    --                     local dmg = data.damage
    --                     if inst.components.combat:GetWeapon() then
    --                         dmg = dmg + self.data[1]
    --                     end
    --                     return dmg
    --                 end)
    --             end
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] then
    --                 inst.components.combat:WgRemoveCalcDamageFn(cmp[id .. "_fn"])
    --                 cmp[id .. "_fn"] = nil
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("peg_leg"),
    --     function(self, inst, cmp, id)
    --         return string.format("若你持有武器，则提升%d攻击力", self.data[1])
    --     end, { 3 }
    -- ),
    -- Buff("wound_dmg_up", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] == nil then
    --                 cmp[id .. "_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
    --                     local data = { damage = damage, inst = inst, target = target, weapon = weapon }
    --                     local dmg = data.damage
    --                     if inst.components.health:GetPercent() < self.data[2] then
    --                         dmg = dmg + self.data[1]
    --                     end
    --                     return dmg
    --                 end)
    --             end
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] then
    --                 inst.components.combat:WgRemoveCalcDamageFn(cmp[id .. "_fn"])
    --                 cmp[id .. "_fn"] = nil
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("spear"),
    --     function(self, inst, cmp, id)
    --         return string.format("若你的生命值低于%d%%，则提升%d攻击力",
    --             self.data[2] * 100, self.data[1])
    --     end, { 25, .7 }
    -- ),
    -- Buff("meat_hp_sp", 20, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.eater:AddOnEatFn(id, function(inst, food)
    --                 if food.components.edible.foodtype == "MEAT" then
    --                     if EntUtil:is_alive(inst) then
    --                         inst.components.health:DoDelta(self.data[1])
    --                     end
    --                     inst.components.sanity:DoDelta(self.data[1])
    --                 end
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             inst.components.eater:RmOnEatFn(id)
    --         end,
    --     }, AssetUtil:MakeImg("meat"),
    --     function(self, inst, cmp, id)
    --         return string.format("食用肉类食物会额外回复%d生命和理智", self.data[1])
    --     end, { 4 }, nil, nil, nil, nil),
    -- Buff("pet_dmg_up1", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             EntUtil:add_damage_mod(inst, id, self.data[1])
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             EntUtil:rm_damage_mod(inst, id)
    --         end,
    --     }, AssetUtil:MakeImg("spear"),
    --     function(self, inst, cmp, id)
    --         return string.format("提升%d%%攻击", self.data[1] * 100)
    --     end, { .1 }),
    -- Buff("pet2_dmg_hp_up1", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.health:WgAddMaxHealthMultiplier(id, self.data[1])
    --             EntUtil:add_damage_mod(inst, id, self.data[1])
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             inst.components.health:WgRemoveMaxHealthMultiplier(id)
    --             EntUtil:rm_damage_mod(inst, id)
    --         end,
    --     }, AssetUtil:MakeImg("meatballs"),
    --     function(self, inst, cmp, id)
    --         return string.format("提升%d%%攻击和生命上限", self.data[1] * 100)
    --     end, { .2 }),
    -- Buff("atk_pet_dmg_hp_up1", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] == nil then
    --                 cmp[id .. "_fn"] = EntUtil:listen_for_event(inst,
    --                     "onhitother", function(inst, data)
    --                         for k, v in pairs(inst.components.leader.followers) do
    --                             BuffManager:AddBuff(k, "pet2_dmg_hp_up1")
    --                         end
    --                     end
    --                 )
    --             end
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] then
    --                 inst:RemoveEventCallback("onhitother", cmp[id .. "_fn"])
    --                 cmp[id .. "_fn"] = nil
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("horn"),
    --     function(self, inst, cmp, id)
    --         local buff = BuffManager:GetDataById("pet2_dmg_hp_up1")
    --         return string.format("每当你攻击时，令你的随从获得buff(%s)", buff:desc())
    --     end, {}),
    -- Buff("kill_dmg_up1", 60, {
    --         on_add = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] == nil then
    --                 cmp[id .. "_fn"] = EntUtil:listen_for_event(inst,
    --                     "killed", function(inst, data)
    --                         local n = cmp.stacks[id] or 0
    --                         n = math.min(n + 1, self.data[2])
    --                         cmp.stacks[id] = n
    --                         EntUtil:add_damage_mod(inst, id, n * self.data[1])
    --                     end
    --                 )
    --             end
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if cmp[id .. "_fn"] then
    --                 inst:RemoveEventCallback("killed", cmp[id .. "_fn"])
    --                 cmp[id .. "_fn"] = nil
    --                 EntUtil:rm_damage_mod(inst, id)
    --                 cmp.stacks[id] = nil
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("spear"),
    --     function(self, inst, cmp, id)
    --         return string.format("杀死一个单位提升%d%%攻击(最多%d层)", self.data[1] * 100, self.data[2])
    --     end, { .02, 5 }),
    -- Buff("murake", 40, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.health:WgAddMaxHealthModifier(id, self.data[1], true)
    --             inst.components.hunger:WgAddMaxHungerModifier(id, self.data[1], true)
    --             if cmp[id .. "_fn"] == nil then
    --                 cmp[id .. "_fn"] = EntUtil:listen_for_event(inst,
    --                     "attacked", function(inst, data)
    --                         if data.attacker then
    --                             BuffManager:AddBuff(data.attacker, "murake2")
    --                         end
    --                     end
    --                 )
    --             end
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             inst.components.health:WgRemoveMaxHealthModifier(id, true)
    --             inst.components.hunger:WgRemoveMaxHungerModifier(id, true)
    --             if cmp[id .. "_fn"] then
    --                 inst:RemoveEventCallback("attacked", cmp[id .. "_fn"])
    --                 cmp[id .. "_fn"] = nil
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("meatballs"),
    --     function(self, inst, cmp, id)
    --         local buff = BuffManager:GetDataById("murake2")
    --         return string.format("增加%d生命上限和饥饿上限，攻击你的单位会获得buff(%s)",
    --             self.data[1], buff:desc())
    --     end, { 200 }),
    -- Buff("murake2", 20, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.health:WgAddMaxHealthMultiplier(id, self.data[1], true)
    --             EntUtil:add_damage_mod(inst, id, self.data[1])
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             inst.components.health:WgRemoveMaxHealthMultiplier(id, true)
    --             EntUtil:rm_damage_mod(inst, id)
    --         end,
    --     }, AssetUtil:MakeImg("spear"),
    --     function(self, inst, cmp, id)
    --         return string.format("增加%d%%生命上限和攻击力", self.data[1] * 100)
    --     end, { .1 }),
    -- Buff("meat_hp", 10, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.eater:AddOnEatFn(id, function(inst, food)
    --                 if food.components.edible.foodtype == "MEAT"
    --                     and food.components.edible.foodstate == "PREPARED" then
    --                     if EntUtil:is_alive(inst) then
    --                         inst.components.health:DoDelta(self.data[1])
    --                     end
    --                 end
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             inst.components.eater:RmOnEatFn(id)
    --         end,
    --     }, AssetUtil:MakeImg("meat"),
    --     function(self, inst, cmp, id)
    --         return string.format("食用肉类菜肴会额外回复%d生命", self.data[1])
    --     end, { 3 }, nil, nil, nil, nil),
    -- Buff("meat_sp", 10, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.eater:AddOnEatFn(id, function(inst, food)
    --                 if food.components.edible.foodtype == "MEAT"
    --                     and food.components.edible.foodstate == "PREPARED" then
    --                     if inst.components.sanity then
    --                         inst.components.sanity:DoDelta(self.data[2])
    --                     end
    --                 end
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             inst.components.eater:RmOnEatFn(id)
    --         end,
    --     }, AssetUtil:MakeImg("meat"),
    --     function(self, inst, cmp, id)
    --         return string.format("食用肉类菜肴会额外回复%d理智", self.data[1])
    --     end, { 3 }, nil, nil, nil, nil),
    -- Buff("meat_hg", 10, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.eater:AddOnEatFn(id, function(inst, food)
    --                 if food.components.edible.foodtype == "MEAT"
    --                     and food.components.edible.foodstate == "PREPARED" then
    --                     if inst.components.hunger then
    --                         inst.components.hunger:DoDelta(self.data[2])
    --                     end
    --                 end
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             inst.components.eater:RmOnEatFn(id)
    --         end,
    --     }, AssetUtil:MakeImg("meat"),
    --     function(self, inst, cmp, id)
    --         return string.format("食用肉类菜肴会额外回复%d饥饿", self.data[1])
    --     end, { 3 }, nil, nil, nil, nil),
    -- Buff("food_sleep", 10, {
    --         on_add = function(self, inst, cmp, id)
    --             local mushrooms = {
    --                 "red_cap",
    --                 "red_cap_cooked",
    --                 "green_cap",
    --                 "green_cap_cooked",
    --                 "blue_cap",
    --                 "blue_cap_cooked",
    --             }
    --             inst.components.eater:AddOnEatFn(id, function(inst, food)
    --                 if inst:HasTag("player") then
    --                     for k, v in pairs(mushrooms) do
    --                         if food.prefab == v then
    --                             TheFrontEnd:Fade(true, 1)
    --                             GetClock():NextPhase()
    --                         end
    --                     end
    --                 end
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             inst.components.eater:RmOnEatFn(id)
    --         end,
    --     }, AssetUtil:MakeImg("red_cap"),
    --     function(self, inst, cmp, id)
    --         return string.format("食用蘑菇会将时间跳入下一阶段")
    --     end, nil, nil, nil, nil, nil),
    -- Buff("differ_food_hp", 10, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.eater:AddOnEatFn(id, function(inst, food)
    --                 local eater = inst.components.eater
    --                 local foodtype = food.components.edible.foodtype
    --                 if eater[id .. "_type"] ~= foodtype then
    --                     if EntUtil:is_alive(inst) then
    --                         inst.components.health:DoDelta(self.data[1])
    --                     end
    --                 end
    --                 eater[id .. "__type"] = foodtype
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             local eater = inst.components.eater
    --             eater[id .. "_type"] = nil
    --             inst.components.eater:RmOnEatFn(id)
    --         end,
    --     }, AssetUtil:MakeImg("cookpot"),
    --     function(self, inst, cmp, id)
    --         return string.format("食用的食物类型不同于你上一个食用的食物类型时,额外回复%d点生命",
    --             self.data[1])
    --     end, { 2 }, nil, nil, nil, nil),
    -- Buff("differ_food_sp", 10, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.eater:AddOnEatFn(id, function(inst, food)
    --                 local eater = inst.components.eater
    --                 local foodtype = food.components.edible.foodtype
    --                 if eater[id .. "_type"] ~= foodtype then
    --                     if inst.components.sanity then
    --                         inst.components.sanity:DoDelta(self.data[1])
    --                     end
    --                 end
    --                 eater[id .. "__type"] = foodtype
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             local eater = inst.components.eater
    --             eater[id .. "_type"] = nil
    --             inst.components.eater:RmOnEatFn(id)
    --         end,
    --     }, AssetUtil:MakeImg("cookpot"),
    --     function(self, inst, cmp, id)
    --         return string.format("食用的食物类型不同于你上一个食用的食物类型时,额外回复%d点理智",
    --             self.data[1])
    --     end, { 2 }, nil, nil, nil, nil),
    -- Buff("differ_food_hg", 10, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.eater:AddOnEatFn(id, function(inst, food)
    --                 local eater = inst.components.eater
    --                 local foodtype = food.components.edible.foodtype
    --                 if eater[id .. "_type"] ~= foodtype then
    --                     if inst.components.hunger then
    --                         inst.components.hunger:DoDelta(self.data[1])
    --                     end
    --                 end
    --                 eater[id .. "__type"] = foodtype
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             local eater = inst.components.eater
    --             eater[id .. "_type"] = nil
    --             inst.components.eater:RmOnEatFn(id)
    --         end,
    --     }, AssetUtil:MakeImg("cookpot"),
    --     function(self, inst, cmp, id)
    --         return string.format("食用的食物类型不同于你上一个食用的食物类型时,额外回复%d点饥饿",
    --             self.data[1])
    --     end, { 2 }, nil, nil, nil, nil),
    -- Buff("food_dmg_stk", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.eater:AddOnEatFn(id, function(inst, food)
    --                 local n = cmp.stacks[id] or (self.data[2] + 1)
    --                 n = math.max(1, n - 1)
    --                 cmp.stacks[id] = n
    --                 EntUtil:add_damage_mod(inst, id, self.data[1] * n)
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             cmp.stacks[id] = nil
    --             EntUtil:rm_damage_mod(inst, id)
    --             inst.components.eater:RmOnEatFn(id)
    --         end,
    --     }, AssetUtil:MakeImg("hambat"),
    --     function(self, inst, cmp, id)
    --         local n = cmp.stacks[id] or 0
    --         local s = string.format("食用食物后,获得%d层buff(每层提升%d%%攻击力),之后食用食物则会降低1层(最低1层),当前层数(%d)",
    --             self.data[1] * 100, self.data[2], n)
    --         return s
    --     end, { .2, 6 }),
    -- Buff("food_spd_stk", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.eater:AddOnEatFn(id, function(inst, food)
    --                 local n = cmp.stacks[id] or (self.data[2] + 1)
    --                 n = math.max(1, n - 1)
    --                 cmp.stacks[id] = n
    --                 EntUtil:add_speed_mod(inst, id, self.data[1] * n)
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             cmp.stacks[id] = nil
    --             EntUtil:rm_speed_mod(inst, id)
    --             inst.components.eater:RmOnEatFn(id)
    --         end,
    --     }, AssetUtil:MakeImg("coffeebeans"),
    --     function(self, inst, cmp, id)
    --         local n = cmp.stacks[id] or 0
    --         local s = string.format("食用食物后,获得%d层buff(每层提升%d%%移速),之后食用食物则会降低1层(最低1层),当前层数(%d)",
    --             self.data[1] * 100, self.data[2], n)
    --         return s
    --     end, { .3, 5 }),
    -- Buff("food_def_stk", 20, {
    --         on_add = function(self, inst, cmp, id)
    --             inst.components.eater:AddOnEatFn(id, function(inst, food)
    --                 local n = cmp.stacks[id] or (self.data[2] + 1)
    --                 n = math.max(1, n - 1)
    --                 cmp.stacks[id] = n
    --                 if inst.components.combat then
    --                     inst.components.combat:AddDefenseMod(id, self.data[1] * n)
    --                 end
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             cmp.stacks[id] = nil
    --             if inst.components.combat then
    --                 inst.components.combat:RmDefenseMod(id)
    --             end
    --             inst.components.eater:RmOnEatFn(id)
    --         end,
    --     }, AssetUtil:MakeImg("lotus_flower_cooked"),
    --     function(self, inst, cmp, id)
    --         local n = cmp.stacks[id] or 0
    --         local s = string.format("食用食物后,获得%d层buff(每层提升%d%%防御),之后食用食物则会降低1层(最低1层),当前层数(%d)",
    --             self.data[1] * 100, self.data[2], n)
    --         return s
    --     end, { .2, 4 }),
    -- Buff("food_spear", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             if inst.components.combat == nil then
    --                 return
    --             end
    --             if cmp[id .. "_fn"] then
    --                 return
    --             end
    --             cmp[id .. "_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
    --                 local data = { damage = damage, inst = inst, target = target, weapon = weapon }
    --                 local dmg = data.damage
    --                 if data.weapon and data.weapon.prefab == "spear" then
    --                     dmg = dmg + self.data[1]
    --                 end
    --                 return dmg
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if inst.components.combat == nil then
    --                 return
    --             end
    --             if cmp[id .. "_fn"] then
    --                 inst.components.combat:WgRemoveCalcDamageFn(cmp[id .. "_fn"])
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("spear"),
    --     function(self, inst, cmp, id)
    --         return string.format("你使用长矛进行攻击时,伤害+%d",
    --             self.data[1])
    --     end, { 5 }),
    -- Buff("food_spear2", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             if inst.components.combat == nil then
    --                 return
    --             end
    --             if cmp[id .. "_fn"] then
    --                 return
    --             end
    --             cmp[id .. "_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
    --                 local data = { damage = damage, inst = inst, target = target, weapon = weapon }
    --                 local dmg = data.damage
    --                 if data.weapon and data.weapon.prefab == "spear" then
    --                     if math.random() < self.data[1] then
    --                         dmg = dmg + dmg * self.data[2]
    --                         if inst.components.sanity then
    --                             inst.components.sanity:DoDelta(self.data[3])
    --                         end
    --                     end
    --                 end
    --                 return dmg
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if inst.components.combat == nil then
    --                 return
    --             end
    --             if cmp[id .. "_fn"] then
    --                 inst.components.combat:WgRemoveCalcDamageFn(cmp[id .. "_fn"])
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("spear"),
    --     function(self, inst, cmp, id)
    --         return string.format("你使用长矛进行攻击时,有%d%%几率造成%d%%的伤害,并回复%d理智",
    --             self.data[1] * 100, self.data[2] * 100, self.data[3])
    --     end, { .15, 1.25, 5 }),
    -- Buff("food_spear3", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             if inst.components.combat == nil then
    --                 return
    --             end
    --             if cmp[id .. "_fn"] then
    --                 return
    --             end
    --             cmp[id .. "_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
    --                 local data = { damage = damage, inst = inst, target = target, weapon = weapon }
    --                 local dmg = data.damage
    --                 if data.weapon and data.weapon.prefab == "spear" then
    --                     if data.target and data.target.components.health
    --                         and data.target.components.health:GetPercent() <= self.data[1] then
    --                         dmg = dmg + dmg * self.data[2]
    --                     end
    --                 end
    --                 return dmg
    --             end)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             if inst.components.combat == nil then
    --                 return
    --             end
    --             if cmp[id .. "_fn"] then
    --                 inst.components.combat:WgRemoveCalcDamageFn(cmp[id .. "_fn"])
    --             end
    --         end,
    --     }, AssetUtil:MakeImg("spear"),
    --     function(self, inst, cmp, id)
    --         return string.format("你使用长矛攻击生命值不大于%d%%的敌人时,造成%d%%的伤害",
    --             self.data[1] * 100, self.data[2] * 100)
    --     end, { .1, 1.3 }),
    -- Buff("food_armor_wood", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             inst:AddTag(id)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             inst:RemoveTag(id)
    --         end,
    --     }, AssetUtil:MakeImg("armorwood"),
    --     function(self, inst, cmp, id)
    --         return string.format("你穿戴木甲时,受到的伤害-%d", Info.FoodArmorWoodConst[1])
    --     end, nil),
    -- Buff("food_armor_wood2", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             inst:AddTag(id)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             inst:RemoveTag(id)
    --         end,
    --     }, AssetUtil:MakeImg("armorwood"),
    --     function(self, inst, cmp, id)
    --         return string.format("你穿戴木甲时,有%d%%几率抵消受到的伤害,并回复你%d理智",
    --             Info.FoodArmorWood2Const[1] * 100, Info.FoodArmorWood2Const[2])
    --     end, nil),
    -- Buff("food_armor_wood3", 30, {
    --         on_add = function(self, inst, cmp, id)
    --             inst:AddTag(id)
    --         end,
    --         on_rm = function(self, inst, cmp, id)
    --             inst:RemoveTag(id)
    --         end,
    --     }, AssetUtil:MakeImg("armorwood"),
    --     function(self, inst, cmp, id)
    --         return string.format("你穿戴木甲时,若你的生命值不大于%d%%,受到的伤害-%d",
    --             Info.FoodArmorWood3Const[1] * 100, Info.FoodArmorWood3Const[2])
    --     end, nil),

    
    -- food effect over
    -- origin item
    Buff("hollow_evade", 100, {
        on_add = function(self, inst, cmp, id)
            inst:AddTag(id)
            inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/grow_medtolrg")
            if cmp[id .. "_fx"] == nil then
                cmp[id .. "_fx"] = FxManager:MakeFx("hollow_evade", Vector3(0, 0, 0))
                inst:AddChild(cmp[id .. "_fx"])
            end
            inst.components.combat:AddEvadeRateMod(id, self.data[1])
            inst.components.locomotor:AddSpeedModifier_Additive(id, self.data[2])
            -- EntUtil:add_speed_mod(inst, id, self.data[2])
            inst.components.tp_val_hollow:SetRate(1)
            inst.components.tp_val_mana:AddRateMod(id, -self.data[3])
            if cmp[id.."_fn"] == nil then
                cmp[id.."_fn"] = EntUtil:listen_for_event(inst, "val_hollow_delta", function(inst, data)
                    if data.new_p <= 0 then
                        BuffManager:ClearBuff(inst, id)
                    end 
                end) 
            end
        end, 
        on_rm = function(self, inst, cmp, id)
            inst:RemoveTag(id)
            if cmp[id .. "_fx"] then
                cmp[id .. "_fx"]:WgRecycle()
                cmp[id .. "_fx"] = nil
            end
            inst.components.combat:RmEvadeRateMod(id)
            inst.components.locomotor:RemoveSpeedModifier_Additive(id)
            -- EntUtil:rm_speed_mod(inst, id)
            inst.components.tp_val_hollow:SetRate(-1)
            inst.components.tp_val_mana:RmRateMod(id)
            if cmp[id.."_fn"] then
                inst:RemoveEventCallback("val_hollow_delta", cmp[id.."_fn"])
                cmp[id.."_fn"] = nil
            end
        end,
    }, AssetUtil:MakeImg("tp_icons2", "hollow_evade"),
        function(self, inst, cmp, id)
            return string.format("无量空洞:获得%d闪避,增加%d点移速,法力回复+%.2f,增加80%%防雨,大幅降低苍,赫,有下限的法力消耗;但会不断消耗六目值", 
                self.data[1], self.data[2], self.data[3])
        end, {800, 8, .88}, nil, true
    ),
}

local debuffs = {
    Buff("slience", 5, {
            on_add = function(self, inst, cmp, id)
                if cmp[id .. "_fx"] == nil then
                    cmp[id .. "_fx"] = FxManager:MakeFx("slience", Vector3(0, 0, 0))
                    inst:AddChild(cmp[id .. "_fx"])
                end
                EntUtil:add_tag(inst, "wg_slience")
            end,
            on_rm = function(self, inst, cmp, id)
                if cmp[id .. "_fx"] then
                    cmp[id .. "_fx"]:WgRecycle()
                    cmp[id .. "_fx"] = nil
                end
                EntUtil:remove_tag(inst, "wg_slience")
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_50"),
        function(self, inst, cmp, id)
            return string.format("沉默")
        end, {}, true
    ),
    Buff("attack_speed_down", 10, {
        on_add = function(self, inst, cmp, id, data)
            EntUtil:add_attack_speed_mod(inst, id, -data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.attack_period_modifiers[id] or 0
            if data > n then
                EntUtil:add_attack_speed_mod(inst, id, -data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            EntUtil:rm_attack_speed_mod(inst, id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_56"),
        function(self, inst, cmp, id, data)
            return string.format("降低%d%%攻速", data*100)
        end, {}, true
    ),
    Buff("damage_down", 10, {
        on_add = function(self, inst, cmp, id, data)
            cmp[id.."_data"] = data
            if cmp[id.."_fn"] == nil then
                cmp[id.."_fn"] = inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
                    return damage - cmp[id.."_data"]
                end)
            end
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            if data > cmp[id.."_data"] then
                cmp[id.."_data"] = data
            end
        end,
        on_rm = function(self, inst, cmp, id)
            if cmp[id.."_fn"] then
                inst.components.combat:WgRemoveCalcDamageFn(cmp[id.."_fn"])
                cmp[id.."_fn"] = nil
            end
            cmp[id.."_data"] = nil
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_68"),
        function(self, inst, cmp, id, data)
            return string.format("降低%d攻击", data)
        end, {}
    ),
    Buff("dmg_mult_down", 10, {
        on_add = function(self, inst, cmp, id, data)
            EntUtil:add_damage_mod(inst, id, -data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.attack_damage_modifiers[id] or 0
            if data > n then
                EntUtil:add_damage_mod(inst, id, -data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            EntUtil:rm_damage_mod(inst, id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_68"),
        function(self, inst, cmp, id, data)
            return string.format("降低%d%%攻击", data*100)
        end, {}, true
    ),
    Buff("speed_down", 6, {
        on_add = function(self, inst, cmp, id, data)
            if inst.components.locomotor then
                inst.components.locomotor:AddSpeedModifier_Additive(id, -data)
            end
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.locomotor.speed_modifiers_add[id] or 0
            if data > n then
                -- EntUtil:add_speed_mod(inst, id, data)
                if inst.components.locomotor then
                    inst.components.locomotor:AddSpeedModifier_Additive(id, -data)
                end
            end
        end,
        on_rm = function(self, inst, cmp, id)
            if inst.components.locomotor then
                inst.components.locomotor:RemoveSpeedModifier_Additive(id)
            end
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_70"),
        function(self, inst, cmp, id, data)
            return string.format("降低%d移速", data)
        end, {}, true
    ),
    Buff("speed_mult_down", 6, {
        on_add = function(self, inst, cmp, id, data)
            EntUtil:add_speed_mod(inst, id, -data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.locomotor.speed_modifiers_mult[id] or 0
            if data > n then
                EntUtil:add_speed_mod(inst, id, -data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            EntUtil:rm_speed_mod(inst, id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_70"),
        function(self, inst, cmp, id, data)
            return string.format("降低%d%%移速", data*100)
        end, {}, true
    ),
    Buff("defense_down", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.combat:AddDefenseMod(id, -data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.tp_defense_mods[id] or 0
            if data > n then
                inst.components.combat:AddDefenseMod(id, -data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.combat:RmDefenseMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_52"),
        function(self, inst, cmp, id, data)
            return string.format("降低%d防御", data)
        end, {}, true
    ),
    Buff("penetrate_down", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.combat:AddPenetrateMod(id, -data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.tp_penetrate_mods[id] or 0
            if data > n then
                inst.components.combat:AddPenetrateMod(id, -data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.combat:RmPenetrateMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_73"),
        function(self, inst, cmp, id, data)
            return string.format("降低%d穿透", data)
        end, {}, true
    ),
    Buff("evade_down", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.combat:AddEvadeRateMod(id, -data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.tp_evade_mods[id] or 0
            if data > n then
                inst.components.combat:AddEvadeRateMod(id, -data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.combat:RmEvadeRateMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_61"),
        function(self, inst, cmp, id, data)
            return string.format("降低%d闪避", data)
        end, {}, true
    ),
    Buff("hit_rate_down", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.combat:AddHitRateMod(id, -data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.tp_hit_rate_mods[id] or 0
            if data > n then
                inst.components.combat:AddHitRateMod(id, -data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.combat:RmHitRateMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_59"),
        function(self, inst, cmp, id, data)
            return string.format("降低%d命中", data)
        end, {}, true
    ),
    Buff("crit_down", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.combat:AddCritRateMod(id, -data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.tp_crit_mods[id] or 0
            if data > n then
                inst.components.combat:AddCritRateMod(id, -data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.combat:RmCritRateMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_63"),
        function(self, inst, cmp, id, data)
            return string.format("降低%d%%暴击", data*100)
        end, {}, true
    ),
    Buff("life_steal_down", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.combat:AddLifeStealRateMod(id, -data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.combat.tp_life_steal_mods[id] or 0
            if data > n then
                inst.components.combat:AddLifeStealRateMod(id, -data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.combat:RmLifeStealRateMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_76"),
        function(self, inst, cmp, id, data)
            return string.format("降低%d%%吸血", data*100)
        end, {}, true
    ),
    Buff("recover_down", 10, {
        on_add = function(self, inst, cmp, id, data)
            inst.components.health:AddRecoverRateMod(id, -data)
        end, 
        on_repeat = function(self, inst, cmp, id, data)
            local n = inst.components.health.tp_recover_mods[id] or 0
            if data > n then
                inst.components.health:AddRecoverRateMod(id, -data)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            inst.components.health:RmRecoverRateMod(id)
        end,
    }, AssetUtil:MakeImg("tp_icons", "badge_72"),
        function(self, inst, cmp, id, data)
            return string.format("降低%d%%生命恢复效果", data*100)
        end, {}, true
    ),
    Buff("poison", 20, {
            on_add = function(self, inst, cmp, id)
                if cmp[id .. "_task"] == nil then
                    cmp[id .. "_task"] = inst:DoPeriodicTask(1, function()
                        -- 有health的实体才会被添加wg_simple_buff
                        -- inst.components.health:DoPoisonDamage(self.data[1])
                        local rate = 1
                        if inst.components.combat.tp_dmg_type_absorb
                        and inst.components.combat.tp_dmg_type_absorb.poison then
                            rate = inst.components.combat.tp_dmg_type_absorb.poison
                        end
                        inst.components.health:DoDelta(-self.data[1]*rate, false, "poison")
                        FxManager:MakeFx("poison_debuff_fx", inst)
                    end)
                end
                if inst.components.eater then
                    inst.components.eater:AddHealthAbsorptionMod(id, self.data[2])
                    inst.components.eater:AddHungerAbsorptionMod(id, self.data[2])
                    inst.components.eater:AddSanityAbsorptionMod(id, self.data[2])
                end
                -- if cmp[id.."_fn"] == nil then
                -- cmp[id.."_fn"] = inst.components.combat:AddAttackedCalcFn(function(damage, attacker, inst, weapon, stimuli)
                --     if EntUtil:in_stimuli(stimuli, "poison") then
                --         damage = damage * (1+self.data[2])
                --     end
                --     return damage
                -- end)
                -- inst.components.combat:AddAttackedCalcFn(cmp[id.."_fn"])
                -- end
            end,
            on_rm = function(self, inst, cmp, id)
                if cmp[id .. "_task"] then
                    cmp[id .. "_task"]:Cancel()
                    cmp[id .. "_task"] = nil
                end
                if inst.components.eater then
                    inst.components.eater:RmHealthAbsorptionMod(id)
                    inst.components.eater:RmHungerAbsorptionMod(id)
                    inst.components.eater:RmSanityAbsorptionMod(id)
                end
                -- if cmp[id.."_fn"] then
                --     inst.components.combat:RemoveAttackedCalcFn(cmp[id.."_fn"])
                --     cmp[id.."_fn"] = nil
                -- end
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_47"),
        function(self, inst, cmp, id)
            return string.format("毒害:每秒受到%d点毒属性伤害,你的食物收益%d%%", self.data[1], self.data[2] * 100)
        end, { 1, -.4 }, true
    ),
    Buff("ice", 20, {
            on_add = function(self, inst, cmp, id)
                if inst.components.freezable
                and inst.components.freezable.coldness < 1 then
                    EntUtil:frozen(inst)
                end
                EntUtil:add_speed_mod(inst, id, self.data[1])
                EntUtil:add_attack_speed_mod(inst, id, self.data[2])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
                EntUtil:rm_attack_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "ice_debuff"),
        function(self, inst, cmp, id)
            return string.format("寒冷:移动速度%d%%,攻击速度%d%%,若未受到冰冻效果,施加1层冰冻效果", self.data[1] * 100, self.data[2] * 100)
        end, { -.15, -.15 }, true
    ),
    Buff("fire", 20, {
            on_add = function(self, inst, cmp, id)
                if cmp[id .. "_task"] == nil then
                    cmp[id .. "_task"] = inst:DoPeriodicTask(1, function()
                        -- 有health的实体才会被添加wg_simple_buff
                        -- inst.components.health:DoFireDamage(self.data[1])
                        local rate = 1
                        if inst.components.combat.tp_dmg_type_absorb
                        and inst.components.combat.tp_dmg_type_absorb.fire then
                            rate = inst.components.combat.tp_dmg_type_absorb.fire
                        end
                        inst.components.health:DoDelta(-self.data[1]*rate, false, "fire")
                    end)
                end
                if cmp[id .. "_fn"] == nil then
                    cmp[id .. "_fn"] = inst.components.combat:AddAttackedCalcFn(
                        function(damage, attacker, inst, weapon, stimuli)
                            if EntUtil:in_stimuli(stimuli, "fire") then
                                BuffManager:AddBuff(inst, "burning")
                                damage = damage + 4
                            end
                            return damage
                        end
                    )
                end
                if cmp[id.."_fx"] == nil then
                    cmp[id .. "_fx"] = FxManager:MakeFx("fire_debuff_fx", Vector3(0, 0, 0))
                    inst:AddChild(cmp[id .. "_fx"])
                end
            end,
            on_rm = function(self, inst, cmp, id)
                if cmp[id .. "_task"] then
                    cmp[id .. "_task"]:Cancel()
                    cmp[id .. "_task"] = nil
                end
                if cmp[id .. "_fn"] then
                    inst.components.combat:RemoveAttackedCalcFn(cmp[id .. "_fn"])
                    cmp[id .. "_fn"] = nil
                end
                if cmp[id .. "_fx"] then
                    cmp[id .. "_fx"]:WgRecycle()
                    cmp[id .. "_fx"] = nil
                end
            end,
        }, AssetUtil:MakeImg("tp_icons2", "fire_debuff"),
        function(self, inst, cmp, id)
            return string.format("灼烧:每秒受到%d点烧伤,受到的火属性伤害+%d,受到火属性伤害时刷新持续时间", self.data[1], self.data[2])
        end, { 1, 4 }, true
    ),
    Buff("wind", 20, {
            on_add = function(self, inst, cmp, id, data)
                cmp.stacks[id] = cmp.stacks[id] or 0
                cmp.stacks[id] = cmp.stacks[id] + 1
                if cmp.stacks[id] >= self.data[1] then
                    cmp.stacks[id] = 0
                    EntUtil:get_attacked(inst, data.attacker, self.data[2], nil, "wind")
                    if inst.components.inventory then
                        inst.components.inventory:DropEverything()
                    end
                    EntUtil:add_speed_mod(data.attacker, id, self.data[3], self.data[4])
                end
            end,
            on_rm = function(self, inst, cmp, id)
                cmp.stacks[id] = nil
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_45"),
        function(self, inst, cmp, id)
            return string.format("风扰:叠到%d层时,buff来源对你造成%d风属性伤害,增加%d%%移速%ds,然后令你掉落所有物品",
                self.data[1], self.data[2], self.data[3] * 100, self.data[4])
        end, { 3, 40, .4, 10 }, true
    ),
    Buff("electric", 20, {
        on_add = function(self, inst, cmp, id)
            if not inst:HasTag("player") then
                inst:AddTag("electric")
                if cmp[id .. "_fn"] == nil then
                    cmp[id .. "_fn"] = inst.components.combat:AddAttackedCalcFn(function(damage, attacker, inst, weapon, stimuli)
                        if EntUtil:in_stimuli(stimuli, "electric") then
                            BuffManager:AddBuff(inst, "electric")
                            local owner = attacker
                            local proj = SpawnPrefab("tp_electric_proj")
                            proj.components.weapon:SetDamage(damage * self.data[1])
                            proj.Transform:SetPosition(owner:GetPosition():Get())
                            proj.max_enemy = 10
                            table.insert(proj.enemies, inst)
                            proj.owner = owner
                            local new_target = proj:find_target()
                            if new_target then
                                proj.components.wg_projectile:Throw(owner, new_target, owner)
                            else
                                proj:Remove()
                            end
                        end
                        return damage
                    end)
                end
            else
                inst.components.combat:AddDmgTypeAbsorb("electric", .2)
            end
            if cmp[id .. "_fx"] == nil then
                cmp[id .. "_fx"] = FxManager:MakeFx("conductive", Vector3(0, 0, 0))
                inst:AddChild(cmp[id .. "_fx"])
            end
        end,
        on_rm = function(self, inst, cmp, id)
            if inst:HasTag("player") then
                inst.components.combat:AddDmgTypeAbsorb("electric", -.2)
            else
                inst:RemoveTag("electric")
                if cmp[id .. "_fn"] then
                    inst.components.combat:RemoveAttackedCalcFn(cmp[id .. "_fn"])
                end
            end
            if cmp[id .. "_fx"] then
                cmp[id .. "_fx"]:WgRecycle()
                cmp[id .. "_fx"] = nil
            end
        end,
    }, AssetUtil:MakeImg("ak_icons", "ak_over_load"),
        function(self, inst, cmp, id)
            if inst:HasTag("player") then
                return string.format("导电:增加%d%%受到的电属性伤害", self.data[2]*100)
            else
                return string.format("导电:受到电属性伤害会发射电磁炮攻击周围处于导电的目标,造成%d%%的伤害", 
                    self.data[1] * 100)
            end
        end, { .2, .2 }, true
    ),
    Buff("shadow", 20, {
        on_add = function(self, inst, cmp, id)
            local n = cmp.stacks[id] or 0
            n = math.min(20, n + 1)
            inst.components.combat:AddDmgTypeAbsorb("shadow", n*self.data[1])
            cmp.stacks[id] = n
        end,
        on_repeat = function(self, inst, cmp, id)
            local n = cmp.stacks[id] or 0
            n = math.min(20, n + 1)
            inst.components.combat:AddDmgTypeAbsorb("shadow", n*self.data[1])
            cmp.stacks[id] = n
        end,
        on_rm = function(self, inst, cmp, id)
            local n = cmp.stacks[id]
            inst.components.combat:AddDmgTypeAbsorb("shadow", -n*self.data[1])
        end,
    }, AssetUtil:MakeImg("tp_icons2", "shadow_debuff"),
        function(self, inst, cmp, id)
            local n = cmp.stacks[id] or 0
            return string.format("受到的暗影伤害%+d%%", self.data[1]*100*n)
        end, {.05}, true
    ),
    Buff("blood", 20, {
        on_add = function(self, inst, cmp, id, data)
            FxManager:MakeFx("hit_fx7", inst)
            local n = cmp.stacks[id] or 0
            local dt = data or 1
            n = math.min(self.data[1], n + dt)
            cmp.stacks[id] = n
            if n >= self.data[1] then
                BuffManager:AddBuff(inst, "blooding")
            end
        end,
        on_fade = function(self, inst, cmp, id)
            -- 这里不需要减少
            FxManager:MakeFx("hit_fx7", inst)
        end,
        on_rm = function(self, inst, cmp, id)
            cmp.stacks[id] = nil
        end,
    }, AssetUtil:MakeImg("tp_icons2", "badge_48"),
        function(self, inst, cmp, id)
            return string.format("出血:叠加至%d层时,进入流血状态", self.data[1])
        end, { 5 }, true
    ),
    Buff("blooding", 10, {
        on_add = function(self, inst, cmp, id)
            local rate = 1
            if inst.components.combat.tp_dmg_type_absorb
            and inst.components.combat.tp_dmg_type_absorb.blood then
                rate = inst.components.combat.tp_dmg_type_absorb.blood
            end
            if cmp[id.."_task"] == nil then
                cmp[id .. "_task"] = inst:DoPeriodicTask(2, function()
                    local cur = inst.components.health.currenthealth
                    local dt = cur*self.data[1]*rate
                    inst.components.health:DoDelta(-dt, nil, id)
                end)
            end
            if cmp[id.."_fx"] == nil then
                cmp[id.."_fx"] = FxManager:MakeFx("blood_bubble", Vector3(0, 0, 0))
                inst:AddChild(cmp[id.."_fx"])
            end
        end,
        on_rm = function(self, inst, cmp, id)
            if cmp[id .. "_task"] then
                cmp[id .. "_task"]:Cancel()
                cmp[id .. "_task"] = nil
            end
            if cmp[id.."_fx"] then
                cmp[id.."_fx"]:kill()  -- 播放动画,然后回收
                cmp[id.."_fx"] = nil
            end
        end,
    }, nil,
        function(self, inst, cmp, id)
            return string.format("流血:每秒降低%d%%当前生命值的生命,受血属性抗性影响", 
                self.data[1]*100)
        end, {.01}, true
    ),
    Buff("virtual", 240, {
        on_add = function(self, inst, cmp, id)
            if cmp[id.."_fn"] == nil then
                cmp[id.."_fn"] = inst.components.combat:AddAttackedCalcFn(function(damage, attacker, inst, weapon, stimuli)
                    if EntUtil:is_physics_dmg(stimuli) then
                        damage = damage * (1 - self.data[1])
                    elseif EntUtil:is_element_dmg(stimuli) then
                        damage = damage * (1 + self.data[2])
                    end
                    return damage
                end)
            end
            if cmp[id.."_fn2"] == nil then
                cmp[id.."_fn2"] = inst.components.combat:WgAddOnHitFn(function(damage, owner, target, weapon, stimuli)
                    EntUtil:get_attacked(target, owner, self.data[3], nil, 
                        EntUtil:add_stimuli(nil, "pure", "shadow") )
                end)
            end
        end,
        on_rm = function(self, inst, cmp, id)
            if cmp[id.."_fn"] then
                inst.components.combat:RemoveAttackedCalcFn(cmp[id.."_fn"])
                cmp[id.."_fn"] = nil
            end
            if cmp[id.."_fn2"] then
                inst.components.combat:WgRemoveOnHitFn(cmp[id.."_fn2"])
                cmp[id.."_fn2"] = nil
            end
        end
    },  AssetUtil:MakeImg("purpleamulet"),
        function(self, inst, cmp, id)
            return string.format("虚无:受到的物理伤害降低%d%%,受到的元素伤害提高%d%%,攻击额外造成%d暗属性伤害",
                self.data[1] * 100, self.data[2] * 100, self.data[3])
        end, { .2, .3, 25 }, true
    ),
    Buff("conductive_ice", 20, {
        on_add = function(self, inst, cmp, id)
            inst:AddTag(id)
        end, 
        on_rm = function(self, inst, cmp, id)
            inst:RemoveTag(id)
        end,
    }, AssetUtil:MakeImg("ak_icons", "ak_over_load"),
        function(self, inst, cmp, id)
            return string.format("被感电电磁炮攻击会进入寒冷状态")
        end, {}, true
    ),
    Buff("conductive_fire", 20, {
        on_add = function(self, inst, cmp, id)
            inst:AddTag(id)
        end, 
        on_rm = function(self, inst, cmp, id)
            inst:RemoveTag(id)
        end,
    }, AssetUtil:MakeImg("ak_icons", "ak_over_load"),
        function(self, inst, cmp, id)
            return string.format("被感电电磁炮攻击会进入灼烧状态")
        end, {}, true
    ),
    Buff("armor_broken", 5, {
            on_add = function(self, inst, cmp, id)
                local fx = FxManager:MakeFx("armor_broken", Vector3(0, 0, 0))
                inst:AddChild(fx)
                inst:AddTag("armor_broken")
            end,
            on_rm = function(self, inst, cmp, id)
                inst:RemoveTag("armor_broken")
            end,
        }, AssetUtil:MakeImg("ak_icons", "ak_armor_broken"),
        function(self, inst, cmp, id)
            return string.format("护甲的伤害吸收降低为原本的%d%%", Info.ArmorBrokenRate * 100)
        end, nil, true
    ),
    Buff("recover_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                if inst.components.health then
                    inst.components.health:AddRecoverRateMod(id, self.data[1])
                end
            end,
            on_rm = function(self, inst, cmp, id)
                if inst.components.health then
                    inst.components.health:RmRecoverRateMod(id)
                end
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_72"),
        function(self, inst, cmp, id)
            return string.format("生命回复效果降低%d%%", -self.data[1] * 100)
        end, { -.9 }, true
    ),
    Buff("curse", 5, {
            on_add = function(self, inst, cmp, id, data)
                local n = cmp.stacks[id] or 0
                local dt = data or 1
                n = math.min(self.data[1], n + dt)
                cmp.stacks[id] = n
                if n >= self.data[1] then
                    if inst.components.health then
                        inst.components.health:Kill()
                    end
                end
            end,
            on_fade = function(self, inst, cmp, id)
                local n = cmp.stacks[id] -- 这里不需要减少
            end,
            on_rm = function(self, inst, cmp, id)
                cmp.stacks[id] = nil
            end,
        }, AssetUtil:MakeImg("skull_wilton"),
        function(self, inst, cmp, id)
            local n = cmp.stacks[id] or 0
            return string.format("达到%d层时,直接死亡,当前层数(%d)", self.data[1], n)
        end, { 20 }, true, nil, true
    ),
    Buff("tp_scroll_blood1", 30, {
        on_add = function(self, inst, cmp, id)
            if cmp[id .. "_fn"] == nil then
                cmp[id .. "_fn"] = inst.components.combat:AddAttackedCalcFn(function(damage, attacker, owner, weapon, stimuli)
                    if EntUtil:in_stimuli(stimuli, "blood") then
                        owner.components.health:DoDelta(-self.data[1])
                        if attacker.components.health then
                            attacker.components.health:DoDelta(self.data[1])
                        end
                    end
                    return damage
                end)
            end
            if cmp[id.."_fx"] == nil then
                cmp[id.."_fx"] = FxManager:MakeFx("scroll_blood1", Vector3(0, 0, 0))
                inst:AddChild(cmp[id.."_fx"])
            end
        end, 
        on_rm = function(self, inst, cmp, id)
            if cmp[id .. "_fn"] then
                inst.components.combat:RemoveAttackedCalcFn(cmp[id .. "_fn"])
                cmp[id .. "_fn"] = nil
            end
            if cmp[id.."_fx"] then
                inst:RemoveChild(cmp[id.."_fx"])
                cmp[id.."_fx"] = nil
            end
        end,
    }, AssetUtil:MakeImg("ash"),
        function(self, inst, cmp, id)
            return string.format("受到血属性伤害时,失去%d生命值以治愈攻击者", self.data[1])
        end, {10}, true
    ),

    Buff("tp_templar_proj_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                local n = cmp.stacks[id] or 0
                n = math.min(self.data[1], n + 1)
                cmp.stacks[id] = n
                if inst.components.combat then
                    inst.components.combat:AddDefenseMod(id, self.data[2] * n)
                end
            end,
            on_fade = function(self, inst, cmp, id)
                local n = cmp.stacks[id] -- 这里不需要减少
                if inst.components.combat then
                    inst.components.combat:AddDefenseMod(id, self.data[2] * n)
                end
            end,
            on_rm = function(self, inst, cmp, id)
                cmp.stacks[id] = nil
                if inst.components.combat then
                    inst.components.combat:RmDefenseMod(id)
                end
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_52"),
        function(self, inst, cmp, id)
            local n = cmp.stacks[id] or 1
            return string.format("每层降低%d防御,最多%d层,会逐层衰退,当前层数(%d)",
                -self.data[2], self.data[1], n)
        end, { 4, -15 }, true, nil, true
    ),
    Buff("tp_spear_hurt", 5, {
            on_add = function(self, inst, cmp, id)
                if inst.components.health then
                    inst.components.health:AddRecoverRateMod(id, self.data[1])
                end
            end,
            on_rm = function(self, inst, cmp, id)
                if inst.components.health then
                    inst.components.health:RmRecoverRateMod(id)
                end
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_72"),
        function(self, inst, cmp, id)
            return string.format("生命回复效果降低%d%%", -self.data[1] * 100)
        end, { -.5 }, true
    ),
    Buff("tp_spear_jarvaniv_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                inst.components.combat:AddDefenseMod(id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                inst.components.combat:RmDefenseMod(id)
            end,
        }, AssetMaster:GetUimg("tp_spear_jarvaniv"),
        function(self, inst, cmp, id)
            return string.format("降低%d防御", -self.data[1] * 100)
        end, { -3 }, true
    ),
    Buff("tp_helm_darius_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                inst.components.combat:AddDefenseMod(id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                inst.components.combat:RmDefenseMod(id)
            end,
        }, AssetMaster:GetUimg("tp_helm_darius"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%防御", -self.data[1])
        end, { -.15 }, true
    ),
    -- equip debuff
    Buff("sharp_horn_debuff", 15, {
            on_add = function(self, inst, cmp, id)
                inst.components.combat:AddDefenseMod(id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                inst.components.combat:RmDefenseMod(id)
            end,
        }, AssetUtil:MakeImg("horn"),
        function(self, inst, cmp, id)
            return string.format("降低%d防御", -self.data[1])
        end, { -40 }, true
    ),
    Buff("randuin_omen_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_damage_mod(inst, id, self.data[1])
                EntUtil:add_attack_speed_mod(inst, id, self.data[2])
                EntUtil:add_speed_mod(inst, id, self.data[3])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_damage_mod(inst, id)
                EntUtil:rm_attack_speed_mod(inst, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("armor_metalplate"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%的攻击,%d%%的攻速,%d%%的移速",
                -self.data[1] * 100, self.data[1] * 100, -self.data[1] * 100)
        end, { -.15, .3, -.15 }, true
    ),
    Buff("dead_plate_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_70"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%的移速", -self.data[1] * 100)
        end, { -.3 }, true
    ),
    Buff("iceborn_gauntlet_debuff", 5, {
            on_add = function(self, inst, cmp, id, data)
                local max_hp = data.target.components.health.wg_max_health
                local rate = self.data[1] + max_hp * self.data[2]
                EntUtil:frozen(inst)
                EntUtil:add_speed_mod(inst, id, rate)
                EntUtil:add_damage_mod(inst, id, self.data[3])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
                EntUtil:rm_damage_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("icestaff"),
        function(self, inst, cmp, id)
            return string.format("施加1层冰冻效果,降低你的移速(基于来源基础生命%.2f%%+%d%%),并降低你%d%%的攻击",
                -self.data[1] * 100, -self.data[2] * 100, -self.data[3] * 100)
        end, { -.15, -0.00001, -.1 }, true
    ),
    Buff("black_cleaver_debuff", 8, {
            on_add = function(self, inst, cmp, id)
                local n = cmp.stacks[id] or 0
                n = math.min(self.data[1], n + 1)
                cmp.stacks[id] = n
                inst.components.combat:AddDefenseMod(id, self.data[2] * n)
            end,
            on_rm = function(self, inst, cmp, id)
                cmp.stacks[id] = nil
                inst.components.combat:RmDefenseMod(id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_52"),
        function(self, inst, cmp, id)
            local n = cmp.stacks[id] or 1
            return string.format("每层降低%d的防御,最高%d层,当前层数(%d)",
                -self.data[2], self.data[1], n)
        end, { 5, -12 }, true
    ),
    Buff("frozen_heart_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_attack_speed_mod(inst, id, self.data[1])
                EntUtil:add_damage_mod(inst, id, self.data[2])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_attack_speed_mod(inst, id)
                EntUtil:rm_damage_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("metalplatehat"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%攻速,降低%d%%攻击力",
                self.data[1] * 100, -self.data[2] * 100)
        end, { .4, -.15 }, true
    ),
    Buff("righteous_glory_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_70"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%移速", -self.data[1] * 100)
        end, { -.4 }, true
    ),
    Buff("stormrazor_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_70"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%的移速",
                -self.data[1] * 100)
        end, { -.3 }, true
    ),
    Buff("serylda_grudge_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_70"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%的移速",
                -self.data[1] * 100)
        end, { -.2 }, true
    ),
    Buff("serpent_fang_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                inst.components.health:WgAddMaxHealthMultiplier(id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                inst.components.health:WgRemoveMaxHealthMultiplier(id)
            end,
        }, AssetUtil:MakeImg("decrease_health"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%最大生命值",
                -self.data[1] * 100)
        end, { -.3 }, true
    ),
    Buff("executioner_calling_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                inst.components.health:AddRecoverRateMod(id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                inst.components.health:RmRecoverRateMod(id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_72"),
        function(self, inst, cmp, id)
            return string.format("生命回复效果降低%d%%",
                -self.data[1] * 100)
        end, { -.35 }, true
    ),
    Buff("warden_mail_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_damage_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_damage_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_68"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%攻击",
                -self.data[1] * 100)
        end, { -.1 }, true
    ),
    Buff("phage_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_70"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%移速",
                -self.data[1] * 100)
        end, { -.2 }, true
    ),
    Buff("duskblade_draktharr_debuff", 2, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_70"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%移速",
                -self.data[1] * 100)
        end, { -.75 }, true
    ),
    Buff("frostfire_gauntlet_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                local max_hp = inst.components.health.wg_max_health
                local rate = self.data[1] + max_hp * self.data[2]
                -- EntUtil:frozen(inst)
                EntUtil:add_speed_mod(inst, id, rate)
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("icestaff"),
        function(self, inst, cmp, id, data)
            return string.format("降低你的移速(基于来源基础生命%.2f%%+%d%%)",
                -self.data[2] * 100, -self.data[1] * 100)
        end, { -.3, -0.0001 }, true
    ),
    Buff("prowler_claw_debuff", 2, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_70"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%移速",
                -self.data[1] * 100)
        end, { -.75 }, true
    ),
    Buff("stride_breaker_debuff", 3, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_70"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%移速",
                -self.data[1] * 100)
        end, { -.4 }, true
    ),
    Buff("turbo_chemtank_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                EntUtil:add_speed_mod(inst, id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                EntUtil:rm_speed_mod(inst, id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_70"),
        function(self, inst, cmp, id)
            return string.format("降低%d%%移速", -self.data[1] * 100)
        end, { -.4 }, true
    ),
    Buff("SunFire_aegis_debuff", 5, {
            on_add = function(self, inst, cmp, id)
                inst.components.combat:AddDefenseMod(id, self.data[1])
            end,
            on_rm = function(self, inst, cmp, id)
                inst.components.combat:RmDefenseMod(id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_52"),
        function(self, inst, cmp, id)
            return string.format("降低%d防御", -self.data[1])
        end, { -30 }, true
    ),
    Buff("broken_heavy_attack_debuff", 10, {
            on_add = function(self, inst, cmp, id, _data)
                cmp[id .. "_data"] = _data
                inst.components.combat:AddDefenseMod(id, -_data)
            end,
            on_rm = function(self, inst, cmp, id)
                cmp[id .. "_data"] = nil
                inst.components.combat:RmDefenseMod(id)
            end,
        }, AssetUtil:MakeImg("tp_icons2", "badge_52"),
        function(self, inst, cmp, id)
            local rate = cmp[id .. "_data"] or 0
            return string.format("降低%d的防御", rate)
        end, {}, true)
}

local function make_food_effect_buff(name, img, data)
    table.insert(buffs, Buff(name, 80, {
        on_add = function(self, inst, cmp, id)
            inst:AddTag("food_effect")
            if inst.components.tp_player_attr then
                for k, v in pairs(self.data) do
                    inst.components.tp_player_attr:AddAttrMod(k, v)
                end
            end
        end, 
        on_rm = function(self, inst, cmp, id)
            inst:RemoveTag("food_effect")
            if inst.components.tp_player_attr then
                for k, v in pairs(self.data) do
                    inst.components.tp_player_attr:RmAttrMod(k)
                end
            end
        end,
    }, AssetUtil:MakeImg(img),
        function(self, inst, cmp, id)
            local s = ""
            for k, v in pairs(self.data) do
                s = s..string.format("%+d%s,", v, Info.Attr.PlayerAttrStr[k])
            end
            return s
        end, data
    ))
end
make_food_effect_buff("meat", "meat", {strengthen=5})
make_food_effect_buff("veggie", "carrot", {agility=5, strengthen=-3})
make_food_effect_buff("sweetener", "honey", {intelligence=5, health=-5})
make_food_effect_buff("fruit", "watermelon", {health=5, stamina=1})
make_food_effect_buff("monster", "monstermeat", {health=-6, agility=-6})
make_food_effect_buff("fish", "fish", {attention=5})
make_food_effect_buff("jellyfish", "fish", {attention=3})
make_food_effect_buff("magic", "mandrake", {intelligence=8, strengthen=-4})
make_food_effect_buff("egg", "bird_egg", {endurance=2, faith=2})
make_food_effect_buff("seed", "seeds", {agility=1})
make_food_effect_buff("decoration", "butterflywings", {agility=3, attention=-1})
make_food_effect_buff("fat", "butter", {lucky=5, endurance=-2})
make_food_effect_buff("dairy", "goatmilk", {intelligence=5, faith=3})
make_food_effect_buff("frozen", "ice", {stamina=2, lucky=-2})
make_food_effect_buff("jellybug", "bug", {stamina=2, lucky=-5})
make_food_effect_buff("antihistamine", "cutnettle", {faith=3, agility=-3, strengthen=-3})
make_food_effect_buff("bone", "snake_bone", {strengthen=5, agility=5, intelligence=5, faith=5, lucky=5})

BuffManager:AddDatas(buffs, "buff")
BuffManager:AddDatas(debuffs, "debuff")


function BuffManager:AddBuff(inst, buff, time, data)
    if inst.components.wg_buff then
        inst.components.wg_buff:AddBuff(buff, time, data)
    elseif inst.components.wg_simple_buff then
        inst.components.wg_simple_buff:AddBuff(buff, time, data)
    else
        print(string.format("BuffManager can't add buff to %s", tostring(inst)))
    end
end

function BuffManager:ClearBuff(inst, buff)
    if inst.components.wg_buff then
        inst.components.wg_buff:ClearBuff(buff)
    elseif inst.components.wg_simple_buff then
        inst.components.wg_simple_buff:ClearBuff(buff)
    end
end

function BuffManager:HasBuff(inst, buff)
    if inst.components.wg_buff then
        return inst.components.wg_buff:HasBuff(buff)
    elseif inst.components.wg_simple_buff then
        return inst.components.wg_simple_buff:HasBuff(buff)
    end
end

Sample.BuffManager = BuffManager
