-- local UIAnim = require "widgets/uianim"
-- local Widget = require "widgets/widget"
-- local Text = require "widgets/text"
-- local Button = require "widgets/button"
local Sample = require "widgets/mk_sample_ui"

local function spawnJGB(inst)
    if inst.prefab == 'monkey_king'
    and not inst.components.inventory:Has('mk_jgb',1) 
    and not inst.components.inventory:EquipHasTag('mk_jgb')
    and inst.components.monkeymana:EnoughMana(100) then
        SpawnPrefab("mk_jgb_rec").Transform:SetPosition(inst:GetPosition():Get())
        -- fx
        inst:mk_do_magic()
        -- ui
        inst.components.mkjgbsptimer:SetPercent(0)
    end
end

local Mk_JGBsp_UI = Class(Sample, function(self, owner)
    Sample._ctor(self, owner, "jgb")
    self.name:SetString("一柱擎天")
    self.mk_fn = function()
        spawnJGB(self.owner)
    end
end)

function Mk_JGBsp_UI:IsEnabled()
    return self.owner.components.mkjgbsptimer:GetPercent() >= 1
end
-- local Mk_JGBsp_UI = Class(Widget, function(self, owner)
-- 	Widget._ctor(self, "Mk_JGBsp_UI")
-- 	self.owner = owner
-- 	self.badge = self:AddChild(UIAnim())
--     self.badge:GetAnimState():SetBank("mk_skill_ui")
--     self.badge:GetAnimState():SetBuild("mk_skill_ui")
--     self.badge:GetAnimState():PlayAnimation("jgb")
--     -- self.badge:SetScale(.26)
--     SetDebugEntity(self.badge.inst)
--     self.name = self:AddChild(Text(BODYTEXTFONT,20,("一柱擎天")))
--     self.name:SetPosition(0,-30,0)
-- end)

-- function Mk_JGBsp_UI:OnControl(control, down) 
--     if not self:IsEnabled() or not self.focus then return end
--     if control == CONTROL_ACCEPT then
--         if down then
--             self:ScaleTo(1,0.9,1/15)
--             self.down = true
--             TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
--         elseif self.down then
--             self:ScaleTo(0.9,1,1/15)
--             self.down = false
--             spawnJGB(self.owner)
--         end
--         return true
--     end
-- end

return Mk_JGBsp_UI