local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local Mk_Sample_UI = Class(Widget, function(self, owner, anim)
	Widget._ctor(self, "Mk_Sample_UI")
    self.mk_anim_name = anim
	self.owner = owner
	self.badge = self:AddChild(UIAnim())
    self.badge:GetAnimState():SetBank("mk_skill_ui")
    self.badge:GetAnimState():SetBuild("mk_skill_ui")
    self.badge:GetAnimState():PlayAnimation(anim)

    self.topperanim = self:AddChild(UIAnim())
    self.topperanim:GetAnimState():SetBank("effigy_topper")
    self.topperanim:GetAnimState():SetBuild("effigy_topper")
    self.topperanim:GetAnimState():PlayAnimation("anim")
    self.topperanim:SetClickable(false)

    SetDebugEntity(self.badge.inst)
    self.name = self:AddChild(Text(BODYTEXTFONT,20,("样板")))
    self.name:SetPosition(0,-30,0)
    
    self.mk_fn = nil
end)

function Mk_Sample_UI:IsEnabled()
    return true
end

function Mk_Sample_UI:SetPercent(p)
    print("mk_"..self.mk_anim_name.."_ui set percent", p)
    self.topperanim:GetAnimState():SetPercent("anim", 1-p)
end

function Mk_Sample_UI:OnControl(control, down)
    if not self:IsEnabled() or not self.focus then return end
    if control == CONTROL_ACCEPT then
        if down then
            self:ScaleTo(1,0.9,1/15)
            self.down = true
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        elseif self.down then
            self:ScaleTo(0.9,1,1/15)
            self.down = false
            print("self.owner is", self.owner.prefab)
            if self.mk_fn then
                self:mk_fn(self.owner)
            end
        end
        return true
    end
end

return Mk_Sample_UI