local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"


local Blackboard = Class(Widget, function(self)
	Widget._ctor(self, "Blackboard")
	self.data = {}
	self.back_ground = self:AddChild(Image(
		"images/hud.xml", "craftingsubmenu_fullvertical.tex"
	))
	self.back_ground:SetScale(1.7, 1.2, 0)
	-- self.text = self:AddChild(Text(TITLEFONT, 30))
	self.text = self:AddChild(Text(NUMBERFONT, 30))
	self.text:SetPosition(0, -40, 0)
	self.text:SetRegionSize(390, 1000)
	self.text:SetHAlign(ANCHOR_LEFT)
	self.page_up = self:AddChild(ImageButton(
		"images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex",
		"scroll_arrow_disabled.tex"
	))
	self.page_up:SetRotation(180)
	self.page_up:SetPosition(-250, -40, 0)
	self.page_down = self:AddChild(ImageButton(
		"images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex",
		"scroll_arrow_disabled.tex"
	))
	self.page_down:SetRotation(0)
	self.page_down:SetPosition(250, -40, 0)





end)

function Blackboard:SetString(str)
	self.text:SetString(str)
end

function Blackboard:Test()




































































































































end

return Blackboard