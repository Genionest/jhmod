local Util = require "extension.lib.wg_util"
local EntUtil = require "extension.lib.ent_util"
local Sounds = require "extension.datas.sounds"
local BuffManager = Sample.BuffManager
local Info = Sample.Info
local ScrollLibrary = Sample.ScrollLibrary

local TpForgeScroll = Class(function(self, inst)
    self.inst = inst
    self.level = 1
    self.forge_level_dmg = 10
    self.forge_material = "tp_infused_nugget_black"
    self.factors = nil
end)

function TpForgeScroll:GetAttrIncome()
    local dmg = 0
    dmg = dmg + (self.level-1) * self.forge_level_dmg
    if self.factors then
        local owner = self.inst.components.equippable and self.inst.components.equippable.owner
        if owner and owner.components.tp_player_attr then
            for attr, factor in pairs(self.factors) do
                local amt = owner.components.tp_player_attr:GetAttrFactor(attr)
                dmg = dmg + (amt * factor * self.level)
            end
        end
    end
    return dmg
end

function TpForgeScroll:SetAttrFactor(attr, factor)
    if self.factors == nil then
        self.factors = {}
    end
    self.factors[attr] = factor
end

function TpForgeScroll:LevelUp()
    self.level = self.level + 1
end

function TpForgeScroll:CanForge(material)
    if material.prefab == self.forge_material then
        if self.level < 4 then
            local n = 1
            if self.forge_material == "tp_infused_nugget_black" then
                n = self.level
            end
            if material.components.stackable:StackSize() >= n then
                return true
            end
        end
    end
end

function TpForgeScroll:Forge(material)
    local n = 1
    if self.forge_material == "tp_infused_nugget_black" then
        n = self.level
    end
    material.components.stackable:Get(n):Remove()
    self:LevelUp()
end

function TpForgeScroll:OnSave()
    return {
        level = self.level,
    }
end

function TpForgeScroll:OnLoad(data)
    if data then
        self.level = data.level or 1
    end
end

function TpForgeScroll:GetWargonString()

    local s = string.format("锻造:%d级,", self.level)
    if self.level >= 4 then
        s = s .. "材料:无"
    else
        if self.forge_material == "tp_infused_nugget_black" then
            s = s .. string.format("材料:%sx%d", 
                Util:GetScreenName(self.forge_material), self.level)
        else
            s = s .. string.format("材料:%sx1", 
                Util:GetScreenName(self.forge_material))
        end
    end
    if self.factors then
        s = s .. "\n属性收益:"
        for attr, factor in pairs(self.factors) do
            local rate = factor*self.level
            if self.element then
                rate = rate * .6
            end
            s = s .. string.format("%s(%d%%),", 
                Info.Attr.PlayerAttrStr[attr], rate*100)
        end
    end
    return s
end

function TpForgeScroll:GetWargonStringColour()
    return {255/255, 140/255, 0/255, 1}
end

return TpForgeScroll