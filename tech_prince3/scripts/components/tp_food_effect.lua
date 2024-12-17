local Util = require "extension.lib.wg_util"
local cooking = require "cooking"
local FoodEffectManager = Sample.FoodEffectManager
local BuffManager = Sample.BuffManager

local effects = {
    "sweetener", "monster", 
    "magic", "decoration", 
    "fat", "dairy", "frozen", "jellybug", "antihistamine", "bone",
    "jellyfish", "fish", "egg", "fruit", "meat", "veggie",
}
local aliases=
{
	cookedsmallmeat = "smallmeat_cooked",
	cookedmonstermeat = "monstermeat_cooked",
	cookedmeat = "meat_cooked"
}

local null_ingredient = {tags={}}
local function GetIngredientData(prefabname)
	local name = aliases.prefabname or prefabname

	return cooking.ingredients[name] or null_ingredient
end

local TpFoodEffect = Class(function(self, inst)
    self.inst = inst
    self.wake = nil
    self.inst:ListenForEvent("oneaten", function(inst, data)
        if data and data.eater and self.wake then
            self:Effect(data.eater)
        end
    end)
    inst:ListenForEvent("tp_stackable_put", function(inst, data)
        if data and data.item then
            self:Merge(data.item)
        end
    end)
end)

function TpFoodEffect:Test()
    return self.wake == nil
end

function TpFoodEffect:Effect(eater)
    if eater:HasTag("food_effect") then
        return
    end
    if cooking.IsCookingIngredient(self.inst.prefab) then
        local idata = GetIngredientData(self.inst.prefab)
        for k, v in pairs(effects) do
            if idata.tags[v] then
                BuffManager:AddBuff(eater, v)
                break
            end
        end
    else
        if self.inst.components.foodtype then
            for k, v in pairs(effects) do
                if self.inst.components.foodtype == v then
                    BuffManager:AddBuff(eater, v)
                end
            end
        end
    end
end

function TpFoodEffect:Merge(item)
    local cmp = item.components.tp_food_effect
    if cmp.wake == nil then
        self.wake = nil
    end
end

function TpFoodEffect:GetWargonString()
    if self.wake then
        return "已添加调料"
    end
end

return TpFoodEffect