local EntUtil = require "extension.lib.ent_util"
local BuffManager = Sample.BuffManager
local Info = Sample.Info
local Util = require "extension.lib.wg_util"

local Profession = Class(function(self, inst)
    self.inst = inst
    self.id = nil
end)

local Data = {
    red = {
        colour = {1, .1, .1, 1},
        data = 1,
        init = function(self, inst, cmp, id)
            inst:ListenForEvent("onhitother", function(inst, data)
                if data and data.damage and EntUtil:is_alive(inst) then
                    inst.components.health:DoDelta(data.damage*self.data)
                end
            end)
        end,
        desc = function(self, inst, cmp, id)
            return string.format("红色元素:获得%d%%的吸血效果", self.data*100)
        end,
    },
    blue = {
        colour = {.1, .1, 1, 1},
        data = 6,
        init = function(self, inst, cmp, id)
            local weapon = CreateEntity()
            weapon.entity:AddTransform()
            weapon:AddComponent("weapon")
            weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
            weapon.components.weapon:SetRange(self.data, self.data+4)
            weapon.components.weapon:SetProjectile("bishop_charge")
            weapon.persists = false
            weapon:AddComponent("inventoryitem")
            weapon.components.inventoryitem:SetOnDroppedFn(inst.Remove)
            weapon:AddComponent("equippable")
            if inst.components.inventory then
                inst.components.inventory:Equip(weapon)
            else
                weapon.components.inventoryitem.owner = inst
                inst:AddChild(weapon)
                weapon.Transform:SetPosition(0, 0, 0)
                weapon:RemoveFromScene()
                inst.components.combat.tp_weapon = weapon
            end
        end,
        desc = function(self, inst, cmp, id)
            return string.format("蓝色元素:装备一个攻击距离为%d的武器", self.data)
        end,
    },
    green = {
        colour = {.1, 1, .1, 1},
        init = function(self, inst, cmp, id)
            inst:ListenForEvent("onhitother", function(inst, data)
                if data and data.target then
                    BuffManager:AddBuff(data.target, "poison")
                end
            end)
        end,
        desc = function(self, inst, cmp, id)
            local buff_data = BuffManager:GetDataById("poison")
            local s = buff_data.desc(buff_data)
            return string.format("绿色元素:攻击使目标获得debuff(%s)", s)
        end,
    },
    yellow = {
        colour = {1, 1, .1, 1},
        data = {5},
        init = function(self, inst, cmp, id)
            inst:ListenForEvent("onhitother", function(inst, data)
                if not inst:HasTag(id.."_tag") then
                    inst:AddTag(id.."_tag")
                    BuffManager:AddBuff(inst, "defense")
                    inst:DoTaskInTime(self.data[1], function()
                        inst:RemoveTag(id.."_tag")
                    end)
                end
            end)
        end,
        desc = function(self, inst, cmp, id)
            local buff_data = BuffManager:GetDataById("defense")
            local s = buff_data.desc(buff_data)
            return string.format("黄色元素:攻击后获得buff(%s)，有%ds的冷却", 
                s, self.data[1])
        end,
    },
    pink = {
        colour = {1, .1, 1, 1},
        data = {.33, 3},
        init = function(self, inst, cmp, id)
            inst:ListenForEvent("onhitother", function(inst, data)
                if data and data.target and math.random() < self.data[1] then
                    local target = data.target
                    local attacker = inst
                    local pt = target:GetPosition()
                    local st_pt =  FindWalkableOffset(pt or attacker:GetPosition(), math.random()*2*PI, 2, 3)
                    if st_pt then
                        if attacker.SoundEmitter then
                            attacker.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
                            attacker.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")            
                        end
                        st_pt = st_pt + pt
                        local st = SpawnPrefab("shadowtentacle")
                        --print(st_pt.x, st_pt.y, st_pt.z)
                        st.Transform:SetPosition(st_pt.x, st_pt.y, st_pt.z)
                        st.components.combat:SetTarget(target)
                        st.components.combat:SetRange(self.data[2])
                    end
                end
            end)
        end,
        desc = function(self, inst, cmp, id)
            return string.format("紫色元素:攻击有%d%%几率召唤一个攻击距离为%d的暗影出售", self.data[1]*100, self.data[2])
        end,
    },
    cyan = {
        colour = {.1, 1, 1, 1},
        data = 1,
        init = function(self, inst, cmp, id)
            inst:ListenForEvent("onhitother", function(inst, data)
                if data and data.target then
                    EntUtil:frozen(data.target, nil, self.data)
                end
            end)
        end,
        desc = function(self, inst, cmp, id)
            return string.format("青色元素:攻击施加%d层冰冻效果", self.data)
        end,
    },
}

function Profession:Test()
    return self.id == nil
end

function Profession:SetId(id)
    self.id = id
    local prf_data = Data[id]
    if prf_data then
        if prf_data.colour then
            self.inst.AnimState:SetMultColour(unpack(prf_data.colour))
        end
        if prf_data.init then
            prf_data.init(prf_data, self.inst, self, id)
        end
    end
end

local ids = {"red", "blue", "green", "yellow", "pink", "cyan",}
function Profession:Random()
    if not self:Test() then
        return 
    end
    local id
    local day = GetClock():GetNumCycles()
    local ProfessionGetRate = Info.MonsterStrengthen.ProfessionGetRate
    if day>=50 or math.random() < day*ProfessionGetRate then
        id = ids[math.random(#ids)]
        self:SetId(id)
    else
        id = "none"
    end
end

function Profession:OnSave()
    return {
        id = self.id,
    }
end

function Profession:OnLoad(data)
    if data then
        if data.id then
            self:SetId(data.id)
        end
    end
end

function Profession:GetWargonString()
    if self.id then
        local prf_data = Data[self.id]
        if prf_data then
            -- if info_complex then
            --     return string.format("<%s>:%s", prf_data.name, WARGON:split_sentence(prf_data.desc))
            -- else
            --     return string.format("<%s>", prf_data.name)
            -- end
            local str = prf_data.desc(prf_data, self.inst, self, self.id)
            str = Util:SplitSentence(str, 17, true)
            return str
        end
    end
end

function Profession:GetWargonStringColour()
    return {1, .4, 1, 1}
end

return Profession