local WgValue = require "components.wg_value"
local Info = Sample.Info

local Mana = Class(WgValue, function(self, inst)
    WgValue._ctor(self, inst)
    self.event = "tp_mana_delta"
    self.max = Info.Character.common.PerPhaseMagic
    self.mods = {}
    self.inst:ListenForEvent("level_up", function(inst, data)
        self:DoDelta(100)
    end)
end)

function Mana:AddManaMod(key, mod)
    self.mods[key] = mod
end

function Mana:RmManaMod(key, mod)
    self.mods[key] = nil
end

function Mana:GetMax()
    local max = self.max
    for k, v in pairs(self.mods) do
        max = max + v
    end
    return max
end

function Mana:GetWargonString()
    local s = string.format("魔法值:%d/%d", self.current, self:GetMax())
    return s
end

function Mana:GetWargonStringColour()
    return {.3, .3, 1, 1}
end

return Mana