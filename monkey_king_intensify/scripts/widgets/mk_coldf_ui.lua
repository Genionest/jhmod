local Sample = require "widgets/mk_sample_ui"

local function BackMonkey(inst)
    if inst.components.monkeyspawner then
        inst.components.monkeyspawner:BackMonkeys()
    end
end

local Mk_ColdF_UI = Class(Sample, function(self, owner)
    Sample._ctor(self, owner, "coldf")
    self.name:SetString("避寒决")
    self.name:SetSize(18)
    self.name:SetPosition(0,-25,0)
    self.badge:SetScale(.8)
    self.topperanim:SetScale(.8)
    self.mk_fn = function()
        -- BackMonkey(self.owner)
    end
end)

-- function Mk_ColdF_UI:IsEnabled()
--     return self.owner.components.mkbacktimer:GetPercent() >= 1
-- end

return Mk_ColdF_UI