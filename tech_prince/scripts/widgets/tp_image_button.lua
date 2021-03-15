local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Button = require "widgets/button"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local UIAnim = require "widgets/uianim"

local TpImageButton = Class(ImageButton, function(self, atlas, normal, anims)
	ImageButton._ctor(self, atlas, normal)
	self.tp_anim = self:AddChild(UIAnim())
	if anims then
		self.tp_anim:GetAnimState():SetBank(anims[1])
		self.tp_anim:GetAnimState():SetBuild(anims[2])
		self.tp_anim:GetAnimState():PlayAnimation(anims[3])
	end
	self.tp_text = self:AddChild(Text(TITLEFONT, 30))
	self.tp_text:SetPosition(0, -80, 0)
	self.tp_text2 = self:AddChild(Text(BUTTONFONT, 20))
	self.tp_text2:Hide()
end)

function TpImageButton:OnGainFocus()
	TpImageButton._base.OnGainFocus(self)
	self.tp_anim:SetScale(1.2, 1.2, 1.2)
	self.tp_text2:Show()
end

function TpImageButton:OnLoseFocus()
	TpImageButton._base.OnLoseFocus(self)
	self.tp_anim:SetScale(1, 1, 1)
	self.tp_text2:Hide()
end

function TpImageButton:SetString(txt)
	self.tp_text:SetString(txt)
end

function TpImageButton:SetString2(txt)
	self.tp_text2:SetString(txt)
end

return TpImageButton