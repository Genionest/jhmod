local FoodEffectManager = Sample.FoodEffectManager
local Util = require "extension.lib.wg_util"

local TpFoodEffect = Class(function(self, inst)
    self.inst = inst
    self.id = nil
    self.quality = 0
    -- inst:ListenForEvent("tp_stackable_get", function(inst, data)
    --     if data and data.source then
    --         self:Imitate(data.source)
    --     end
    -- end)
    inst:ListenForEvent("tp_stackable_put", function(inst, data)
        if data and data.item then
            self:Merge(data.item)
        end
    end)
    self.inst:ListenForEvent("oneaten", function(inst, data)
        if data and data.eater and self.id then
            local D = FoodEffectManager:GetDataById(self.id)
            local cost = D.cost
            if data.eater.components.tp_taste 
            and data.eater.components.tp_taste.current>=cost then
                data.eater.components.tp_taste:DoDelta(-cost)
                self:Effect(data.eater)
                self.id = nil
                self.quality = 0
            end
            -- if data.eater.components.inventory then
            --     for k, v in pairs(self.equipslots) do
            --         if v and v:HasTag("food_effect_equip")
            --         and v.components.tp_equip_value
            --         and not v.components.tp_equip_value:IsEmpty() then
            --             v.components.tp_equip_value:DoDelta(-1)
            --             self:Effect(data.eater)
            --             break
            --         end
            --     end
            -- end
        end
    end)
end)

function TpFoodEffect:Test()
    return self.id == nil
end

function TpFoodEffect:Effect(eater)
    -- if eater:HasTag("epic") then
    --     return
    -- end
    if self.id then
        local D = FoodEffectManager:GetDataById(self.id)
        if D and D.eat then
            D.eat(D, eater, eater.components.eater, D.id, self.inst)
        end
    end
end

function TpFoodEffect:SetDataById(id)
    local data = FoodEffectManager:GetDataById(id)
    self:SetData(data)
end

function TpFoodEffect:SetData(data)
    self.id = data.id
    local D = data
    self.quality = D.quality
    if D.init then
        D.init(D, D.id, self.inst)
    end
end

function TpFoodEffect:Random(kinds)
    if not self:Test() then
        return
    end
    local days = GetClock():GetNumCycles()+1
    if kinds == nil then
        if days>60 then
            kinds = {"large", "med", "small"}
        elseif days>30 then
            kinds = {"med", "small"}
        else
            kinds = {"small"}
        end
    end
    local data = FoodEffectManager:GetRandomData(kinds)
    self:SetData(data)
end

function TpFoodEffect:Imitate(item)
    self.id = item.components.tp_food_effect.id
    self.quality = item.components.tp_food_effect.quality
end

function TpFoodEffect:Merge(item)
    local cmp = item.components.tp_food_effect
    local quality2 = cmp.quality
    if quality2 and (quality2>self.quality 
    or (quality2==self.quality and math.random()<.5)) then
        self.id = cmp.id
        self.quality = cmp.quality
    end
end

function TpFoodEffect:OnSave()
    return {
        id = self.id,
        quality = self.quality,
    }
end

function TpFoodEffect:OnLoad(data)
    if data and data.id then
        self.quality = data.quality
        self:SetDataById(data.id)
    end
end

function TpFoodEffect:GetWargonString()
    if self.id then
        local s = nil
        local D = FoodEffectManager:GetDataById(self.id)
        s = string.format("词条优先级:%d\n", self.quality)
        s = s..string.format("消耗品尝值:%d\n", D.cost)
        s = s..string.format("%s", D.desc(D, D.id, self.inst))
        s = Util:SplitSentence(s, 17, true)
        return s
    else
        -- return string.format("可添加词条")
    end
end

local colours = {
    {1, 1, 1, 1},
    {135/255, 206/255, 235/255, 1},
    {138/255, 43/255, 226/255, 1},
    {255/255, 128/255, 0, 1},
    {255/255, 215/255, 0, 1},
}
function TpFoodEffect:GetWargonStringColour()
    if self.quality == 0 then
        return {1, 1, 1, 1}
    end
    return colours[self.quality or 1]
end

return TpFoodEffect