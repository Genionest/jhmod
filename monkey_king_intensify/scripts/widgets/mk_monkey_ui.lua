-- local UIAnim = require "widgets/uianim"
-- local Widget = require "widgets/widget"
-- local Text = require "widgets/text"
-- local Button = require "widgets/button"
local Sample = require "widgets/mk_sample_ui"

local function SpawnMonkey(inst)
    inst.components.monkeyspawner:Spawn()
end

local Mk_Monkey_UI = Class(Sample, function(self, owner)
    Sample._ctor(self, owner, "monkey")
    self.name:SetString("猴子猴孙")
    self.mk_fn = function()
        SpawnMonkey(self.owner)
    end
end)

function Mk_Monkey_UI:IsEnabled()
    return self.owner.components.mkmonkeytimer:GetPercent() >= 1
end
-- local Mk_Monkey_UI = Class(Widget, function(self, owner)
-- 	Widget._ctor(self, "Mk_Monkey_UI")
-- 	self.owner = owner
-- 	self.badge = self:AddChild(UIAnim())
--     self.badge:GetAnimState():SetBank("mk_skill_ui")
--     self.badge:GetAnimState():SetBuild("mk_skill_ui")
--     self.badge:GetAnimState():PlayAnimation("monkey")
--     -- self.badge:SetScale(.26)
--     SetDebugEntity(self.badge.inst)
--     self.name = self:AddChild(Text(BODYTEXTFONT,20,("猴子猴孙")))
--     self.name:SetPosition(0,-30,0)

-- end)

-- function Mk_Monkey_UI:OnControl(control, down)
--     if not self:IsEnabled() or not self.focus then return end
--     if control == CONTROL_ACCEPT then
--         if down then
--             self:ScaleTo(1,0.9,1/15)
--             self.down = true
--             TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
--         elseif self.down then
--             self:ScaleTo(0.9,1,1/15)
--             self.down = false
--             -- self.inst.components.mkuitimer:SetMax()
--             -- self.badge:GetAnimState():PlayAnimation("none")
--             SpawnMonkey(self.owner)
--         end
--         return true
--     end
-- end

return Mk_Monkey_UI