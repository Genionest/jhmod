local WgValue = require "components.wg_value"
local Info = Sample.Info

local Taste = Class(WgValue, function(self, inst)
    WgValue._ctor(self, inst)
    self.event = "tp_taste_delta"
    self.max = Info.Character.common.BaseTaste
    self.mods = {}
    self.inst:ListenForEvent("daytime", function()
        self:SetPercent(1)
    end, GetWorld())
    self.inst:ListenForEvent("dusktime", function()
        self:SetPercent(1)
    end, GetWorld())
    self.inst:ListenForEvent("nighttime", function()
        self:SetPercent(1)
    end, GetWorld())
end)

function Taste:AddTasteMod(key, mod)
    self.mods[key] = mod
end

function Taste:RmTasteMod(key, mod)
    self.mods[key] = nil
end

function Taste:GetMax()
    local max = self.max
    for k, v in pairs(self.mods) do
        max = max + v
    end
    return max
end

function Taste:GetWargonString()
    local s = string.format("品尝值:%d/%d", self.current, self:GetMax())
    return s
end

function Taste:GetWargonStringColour()
    return {237/255, 145/255, 33/255, 1}
end

return Taste