local Util = require "extension.lib.wg_util"

local TpForgeLevelArmor = Class(function(self, inst)
    self.inst = inst
    self.level = 1
    self.forge_material = "tp_infused_nugget_black"
end)

function TpForgeLevelArmor:LevelUp()
    local max = self.inst.components.armor.maxcondition
    self.inst.components.armor.maxcondition = max*(self.level+1)/self.level
    self.inst.components.armor:DoDelta(0)
    self.level = self.level + 1
end

function TpForgeLevelArmor:CanForge(material)
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

function TpForgeLevelArmor:OnSave()
    return {
        level = self.level,
        element = self.element,
    }
end

function TpForgeLevelArmor:OnLoad(data)
    if data then
        self.level = data.level or 1
        self.element = data.element
    end
end

function TpForgeLevelArmor:GetWargonString()
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
    s = s..string.format("\n%d倍耐久", self.level)
    return s
end

function TpForgeLevelArmor:GetWargonStringColour()
    return {255/255, 140/255, 0/255, 1}
end

return TpForgeLevelArmor