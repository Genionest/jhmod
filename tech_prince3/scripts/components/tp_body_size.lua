local BodySize = Class(function(self, inst)
    self.inst = inst
    self.mods = {}
end)

function BodySize:AddSizeMod(id, key)
    self.mods[id] = key
    local mod = self:GetSizeMod()
    self.inst.Transform:SetScale(mod, mod, mod)
end

function BodySize:RmSizeMod(id)
    self.mods[id] = nil
    local mod = self:GetSizeMod()
    self.inst.Transform:SetScale(mod, mod, mod)
end

function BodySize:GetSizeMod()
    local mod = 1
    for k, v in pairs(self.mods) do
        mod = mod + v
    end
    return mod
end

return BodySize