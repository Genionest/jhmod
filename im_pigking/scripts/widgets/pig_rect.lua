local Image = require "widgets/image"
local Widget = require "widgets/widget"

local PigRect = Class(Widget, function(self)
	Widget._ctor(self, "PigRect")
	self.image = self:AddChild(Image(
		"images/hud.xml", "craft_bg.tex")
	)
	self.image:SetRotation(90)
	self.image2 = self:AddChild(Image(
		"images/hud.xml", "craft_bg.tex"
	))
	self.image2:SetRotation(270)
	self.image2:SetPosition(0, 48, 0)
end)

return PigRect