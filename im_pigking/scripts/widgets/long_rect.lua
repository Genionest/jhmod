local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local LongRect = Class(Widget, function(self)
	Widget._ctor(self, "LongRect")
	self.image = self:AddChild(Image(
		"images/hud.xml", "craft_bg.tex")
	)
	self.image:SetRotation(90)
	self.image2 = self:AddChild(Image(
		"images/hud.xml", "craft_bg.tex"
	))
	self.image2:SetRotation(270)
	self.image2:SetPosition(0, 48, 0)

	self.anim = self:AddChild(UIAnim())
	self.anim:GetAnimState():SetBank("effigy_topper")
	self.anim:GetAnimState():SetBuild("effigy_topper")
	self.anim:GetAnimState():SetPercent("anim", 0)
	self.anim:SetPosition(-425, 30, 0)
	self.anim:SetScale(3.4, 3.4, 0)

	self.icon = self.anim:AddChild(Image(
		"images/inventoryimages.xml", "log.tex"
	))
	self.word = self.icon:AddChild(Text(TITLEFONT, 20))
	-- self.word:SetPosition(-105, 25, 0)
	self.word:SetPosition(135, 0, 0)
	self.word:SetHAlign(ANCHOR_LEFT)
end)

return LongRect