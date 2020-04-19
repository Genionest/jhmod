-- local UIAnim = require "widgets/uianim"
-- local Widget = require "widgets/widget"
-- local Text = require "widgets/text"
-- local Button = require "widgets/button"
local Sample = require "widgets/mk_sample_ui"

local function BackMonkey(inst)
    if inst.components.monkeyspawner then
        inst.components.monkeyspawner:BackMonkeys()
    end
end

local Mk_Back_UI = Class(Sample, function(self, owner)
    Sample._ctor(self, owner, "back")
    self.name:SetString("回来吧")
    self.name:SetSize(18)
    self.name:SetPosition(0,-25,0)
    self.badge:SetScale(.8)
    self.topperanim:SetScale(.8)
    self.mk_fn = function()
        BackMonkey(self.owner)
    end
end)

function Mk_Back_UI:IsEnabled()
    return self.owner.components.mkbacktimer:GetPercent() >= 1
end

-- local Mk_Back_UI = Class(Widget, function(self, owner)
-- 	Widget._ctor(self, "Mk_Back_UI")
-- 	self.owner = owner
-- 	self.badge = self:AddChild(UIAnim())
--     self.badge:GetAnimState():SetBank("mk_skill_ui")
--     self.badge:GetAnimState():SetBuild("mk_skill_ui")
--     self.badge:GetAnimState():PlayAnimation("back")
--     self.badge:SetScale(.8)
--     SetDebugEntity(self.badge.inst)
--     self.name = self:AddChild(Text(BODYTEXTFONT,18,("回来吧")))
--     self.name:SetPosition(0,-25,0)
-- end)

-- function Mk_Back_UI:OnControl(control, down) 
--     if not self:IsEnabled() or not self.focus then return end
--     if control == CONTROL_ACCEPT then
--         if down then
--             self:ScaleTo(1,0.9,1/15)
--             self.down = true
--             TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
--         elseif self.down then
--             self:ScaleTo(0.9,1,1/15)
--             self.down = false
--             BackMonkey(self.owner)
--         end
--         return true
--     end
-- end


return Mk_Back_UI