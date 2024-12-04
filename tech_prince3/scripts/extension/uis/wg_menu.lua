local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"


local WgMenu = Class(Widget, function(self, num)
	Widget._ctor(self, "WgMenu")
	self.num = num or 6
	self.pad = 60
	self.border = self:AddChild(Image(
		"images/ui.xml", "textbox_short_over.tex"
	))
	self.border:SetRotation(90)
	self.border:SetScale(1.8, (self.num+1)*.2, 0)
	self.buttons = {}
	for i = 1, self.num do
		self.buttons[i] = self:AddChild(ImageButton())
		local y = self.pad*(self.num-1)/2-(i-1)*self.pad
		self.buttons[i]:SetPosition(0, y, 0)
		self.buttons[i]:SetScale(.9)
		self.buttons[i]:Hide()
	end
	self.page_up = self:AddChild(ImageButton(
		"images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex",
		"scroll_arrow_disabled.tex"
	))
	self.page_up:SetRotation(270)
	self.page_up:SetPosition(0, (self.pad*(self.num-1)/2+60), 0)
	self.page_down = self:AddChild(ImageButton(
		"images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex",
		"scroll_arrow_disabled.tex"
	))
	self.page_down:SetRotation(90)
	self.page_down:SetPosition(0, -(self.pad*(self.num-1)/2+60), 0)





end)

function WgMenu:Test()































































































end

return WgMenu