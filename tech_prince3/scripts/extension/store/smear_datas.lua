local EntUtil = require "extension.lib.ent_util"
local Kit = require "extension.lib.wargon"
local EntUtil = require "extension.lib.ent_util"
local Info = Sample.Info
local FxManager = Sample.FxManager
local BuffManager = Sample.BuffManager

local SmearData = Class(function(self)
end)

--[[
创建附魔类  
(SmearData) 返回  
id (string) 名字  
time (number) 持续时间  
add (func) 执行函数  
rm (func) 移除函数  
test (func) 条件函数  
desc (func) 描述函数  
]]
local function Smear(id, time, add, rm, test, desc)
    local self = SmearData()
    self.id = id
    self.time = time
    self.add = add
    self.rm = rm
    self.test = test
    self.desc = desc
    return self
end

function SmearData:GetId()
    return self.id
end

function SmearData:__tostring()
    return string.format("SmearData(%s)", self.id)
end

local datas = {
Smear("", 100,
    function(self, inst, cmp, id)
    end,
    function(self, inst, cmp, id)
    end,
    function(self, inst, cmp, id)
    end,
    function(self, inst, cmp, id)
    end
),
Smear("upkeep", 20, 
    function(self, inst, cmp, id)
        if cmp[id.."_task"] == nil then
            cmp[id.."_task"] = inst:DoPeriodicTask(1, function()
                local total = inst.components.finiteuses.total
                local current = inst.components.finiteuses:GetUses()
                inst.components.finiteuses:SetUses(math.min(total, current + 10))
            end)
        end
    end,
    function(self, inst, cmp, id)
        if cmp[id.."_task"] then
            cmp[id.."_task"]:Cancel()
            cmp[id.."_task"] = nil
        end
    end,
    function(self, inst, cmp, id)
        return inst.components.finiteuses ~= nil
    end,
    function(self, inst, cmp, id)
        return "每秒增加10点耐久"
    end
),
Smear("infinity_use", 120,
    function(self, inst, cmp, id)
        if inst.components.finiteuses then
            cmp[id.."_tag"] = inst.components.finiteuses.unlimited_uses
            inst.components.finiteuses.finiteuses.unlimited_uses = true
        end
    end,
    function(self, inst, cmp, id)
        if inst.components.finiteuses then
            inst.components.finiteuses.unlimited_uses = cmp[id.."_tag"]
            cmp[id.."_tag"] = nil
        end
    end,
    function(self, inst, cmp, id)
        return inst.components.finiteuses ~= nil
    end,
    function(self, inst, cmp, id)
        return string.format("无限耐久")
    end
),
Smear("dmg_up", 180, 
    function(self, inst, cmp, id)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = inst.components.weapon.WgAddWeaponDamageFn(function(inst, damage)
                return damage + 20
            end)
        end
    end,
    function(self, inst, cmp, id)
        if cmp[id.."_fn"] then
            inst.components.weapon:WgRemoveWeaponDamageFn(cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end,
    function(self, inst, cmp, id)
        return inst.components.weapon ~= nil
    end,
    function(self, inst, cmp, id)
        return string.format("武器伤害增加20点")
    end
),
Smear("easy_atk_weapon", 180,
    function(self, inst, cmp, id)
        if inst.components.weapon.cost_vigor then
            inst.components.weapon.cost_vigor = inst.components.weapon.cost_vigor - 1
        end
    end,
    function(self, inst, cmp, id)
        if inst.components.weapon.cost_vigor then
            inst.components.weapon.cost_vigor = inst.components.weapon.cost_vigor + 1
        end 
    end,
    function(self, inst, cmp, id)
        return inst.components.weapon ~= nil
    end,
    function(self, inst, cmp, id)
        return string.format("武器攻击消耗的精力降低")
    end
),
Smear("drop_smallmeat", 30,
    function(self, inst, cmp, id)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
                local max = target.components.health:GetMaxHealth()
                local n = math.max(0, max-100)
                local rate = (1-500/(500+n))/3
                if math.random() < rate then
                    local meat = SpawnPrefab("smallmeat")
                    Kit:throw_item(meat, owner)
                end
            end)
        end
    end,
    function(self, inst, cmp, id)
        if cmp[id.."_fn"] then
            inst.components.weapon:WgRemoveWeaponAttackFn(cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end,
    function(self, inst, cmp, id)
        return inst.components.weapon ~= nil
    end,
    function(self, inst, cmp, id)
        return "攻击有几率掉落小肉,生命越高的单位掉率越高"
    end
),
Smear("skill_wake", 180, 
    function(self, inst, cmp, id)
        inst:AddTag(id)
    end,
    function(self, inst, cmp, id)
        inst:RemoveTag(id)
    end,
    function(self, inst, cmp, id)
        return inst.components.wg_action_tool
            and inst.components.wg_action_tool.sleep == true
    end,
    function(self, inst, cmp, id)
        return "激活装备的技能"
    end
),
Smear("fire_lunge", 100,
    function(self, inst, cmp, id)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = EntUtil:listen_for_event(inst, "weapon_start_lunge", function(inst, data)
                if cmp[id.."_task"] == nil then
                    cmp[id.."_task"] = inst:DoPeriodicTask(1, function()
                        FxManager:MakeFx("lunge_fire", data.owner, {owner=data.owner,weapon=inst})
                    end)
                end
            end) 
        end
        if cmp[id.."_fn2"] == nil then
            cmp[id.."_fn2"] = EntUtil:listen_for_event(inst, "weapon_stop_lunge", function(inst, data)
                if cmp[id.."_task"] then
                    cmp[id.."_task"]:Cancel()
                    cmp[id.."_task"] = nil
                end
            end)
        end
    end,
    function(self, inst, cmp, id)
        if cmp[id.."_fn"] then
            inst:RemoveEventCallback("weapon_start_lunge", cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
        if cmp[id.."_fn2"] then
            inst:RemoveEventCallback("weapon_stop_lunge", cmp[id.."_fn2"])
            cmp[id.."_fn2"] = nil
        end
    end,
    function(self, inst, cmp, id)
        return "突刺附带火焰"
    end
),
Smear("ice_lunge", 100,
    function(self, inst, cmp, id)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = EntUtil:listen_for_event(inst, "weapon_start_lunge", function(inst, data)
                if cmp[id.."_task"] == nil then
                    cmp[id.."_task"] = inst:DoPeriodicTask(1, function()
                        FxManager:MakeFx("lunge_ice", data.owner, {owner=data.owner,weapon=inst})
                    end)
                end
            end) 
        end
        if cmp[id.."_fn2"] == nil then
            cmp[id.."_fn2"] = EntUtil:listen_for_event(inst, "weapon_stop_lunge", function(inst, data)
                if cmp[id.."_task"] then
                    cmp[id.."_task"]:Cancel()
                    cmp[id.."_task"] = nil
                end
            end)
        end
    end,
    function(self, inst, cmp, id)
        if cmp[id.."_fn"] then
            inst:RemoveEventCallback("weapon_start_lunge", cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
        if cmp[id.."_fn2"] then
            inst:RemoveEventCallback("weapon_stop_lunge", cmp[id.."_fn2"])
            cmp[id.."_fn2"] = nil
        end
    end,
    function(self, inst, cmp, id)
        return "突刺附带火焰"
    end
),
Smear("shadow_lunge", 100,
    function(self, inst, cmp, id)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = EntUtil:listen_for_event(inst, "weapon_start_lunge", function(inst, data)
                FxManager:MakeFx("statue_transition", data.owner)
                local fighter = SpawnPrefab("tp_shadow_fighter")
                fighter.Transform:SetPosition(data.owner:GetPosition())
                fighter.Transform:SetRotation(data.owner.Transform:GetRotation())
                fighter:PushEvent("start_lunge")
                data.owner.components.leader:AddFollower(fighter)
                BuffManager:AddBuff(fighter, "summon", 20)
            end)
        end
    end,
    function(self, inst, cmp, id)
        if cmp[id.."_fn"] then
            inst:RemoveEventCallback("weapon_start_lunge", cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end,
    function(self, inst, cmp, id)
        return "突刺时会召唤一个暗影突刺者"
    end
),
Smear("double_cyclone", 100,
    function(self, inst, cmp, id)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = EntUtil:listen_for_event(inst, "cyclone_slash", function(inst, data)
                if data.ignore then
                    return
                end
                inst:DoTaskInTime(0.15, function()
                    local item = data.owner.components.combat:GetWeapon()
                    local skill_id = item.components.wg_action_tool.skill_id
                    if skill_id == "lunge_cyclone_slash" then
                        skill_id = "cyclone_slash2"
                    end
                    local EquipSkillManager = Sample.EquipSkillManager
                    if EquipSkillManager:GetDataKindById(skill_id) == "cyclone_slash" then
                        local skill_data = EquipSkillManager:GetDataById(skill_id)
                        skill_data:fn(item, item.components.wg_action_tool, skill_id, data.owner, nil, nil, true)
                    end
                    -- if item == inst and item.cyclone_slash then
                    --     item:cyclone_slash(inst, true)
                    -- end
                end)
            end)
        end
    end,
    function(self, inst, cmp, id)
        if cmp[id.."_fn"] then
            inst:RemoveEventCallback("cyclone_slash", cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end,
    function(self, inst, cmp, id)
        return "回旋斩击会额外触发1次"
    end
),
}

for k, v in pairs(Info.DmgTypeList) do
    local dmg_type, str = v[1], v[2]
    local data = Smear(dmg_type.."_weapon", 180, 
        function(self, inst, cmp, id)
            if cmp[id.."_fn"] == nil then
                cmp[id.."_fn"] = inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
                    local element = dmg_type
                    local level = inst.components.tp_forge_weapon.level
                    local base_dmg = inst.components.tp_forge_weapon.forge_level_dmg
                    EntUtil:get_attacked(target, owner, base_dmg*level, nil, 
                        EntUtil:add_stimuli(nil, element, "pure") )
                end)
            end
            inst:AddTag("element_weapon")
            local owner = inst.components.equippable.owner
            if owner and owner.tp_fx then
                owner.tp_fx:Show()
                if v[1] == "fire" then
                    owner.tp_fx.AnimState:SetAddColour(255/255,165/255,0/255,1)
                elseif v[1] == "ice" then
                    owner.tp_fx.AnimState:SetAddColour(0/255,255/255,255/255,1)
                elseif v[1] == "electric" then
                    owner.tp_fx.AnimState:SetAddColour(0/255,0/255,255/255,1)
                elseif v[1] == "shadow" then
                    owner.tp_fx.AnimState:SetAddColour(255/255,0/255,255/255,1)
                elseif v[1] == "poison" then
                    owner.tp_fx.AnimState:SetAddColour(0/255,255/255,0/255,1)
                elseif v[1] == "blood" then
                    owner.tp_fx.AnimState:SetAddColour(255/255,0/255,0/255,1)
                elseif v[1] == "wind" then
                    owner.tp_fx.AnimState:SetAddColour(0/255,250/255,154/255,1)
                elseif v[1] == "holly" then
                    owner.tp_fx.AnimState:SetAddColour(0/255,255/255,255/255,1)
                end
            end
            -- if cmp[id.."_fn2"] == nil then
            --     cmp[id.."_fn2"] = EntUtil:listen_for_event(inst, "unequipped", function(inst, data)
            --         inst.components.tp_smearable:Clear(id)
            --     end)
            -- end
        end,
        function(self, inst, cmp, id)
            if cmp[id.."_fn"] then
                inst.components.weapon:WgRemoveWeaponAttackFn(cmp[id.."_fn"])
                cmp[id.."_fn"] = nil
            end
            inst:RemoveTag("element_weapon")
            local owner = inst.components.equippable.owner
            if owner and owner.tp_fx then
                owner.tp_fx:Hide()
            end
            -- if cmp[id.."_fn2"] then
            --     inst:RemoveEventCallback("unequipped", cmp[id.."_fn2"])
            --     cmp[id.."_fn2"] = nil
            -- end
        end,
        function(self, inst, cmp, id)
            return inst.components.weapon 
                and inst.components.tp_forge_weapon
                and inst.components.tp_forge_weapon.element == nil
                and not inst:HasTag("element_weapon")
        end,
        function(self, inst, cmp, id)
            return string.format("武器攻击附带%s属性伤害", str)
        end
    )
    table.insert(datas, data)
end

local DataManager = require "extension.lib.data_manager"
local SmearManager = DataManager("SmearManager")
SmearManager:AddDatas(datas, "default")

Sample.SmearManager = SmearManager
