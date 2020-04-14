local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"

local function AddMorph(inst, body)
	if body ~= inst.components.morph:GetCurrent()
	and inst.components.driver
	and not inst.components.driver:GetIsDriving()
	and inst.components.rider
	and not inst.components.rider:IsRiding()
	and not inst:HasTag("notarget")
	and not inst:HasTag("ironlord") then
		inst.components.morph:Morph(body)
	end
end

local function OriginalMorph(inst)
	if inst.components.morph:GetCurrent() ~= "monkey" then
		inst.components.morph:UnMorph() 
	end
end

local img_atlas = "images/inventoryiamges.xml"
local img_atlas2 = "images/inventoryiamges_2.xml"

local mk_morph = Class(Screen, function(self)
	Screen._ctor(self, "mk_morph")
	self.root = self:AddChild(Widget("ROOT"))
	self.root:SetVAnchor(ANCHOR_TOP)  -- 垂直坐标锚点设置
	self.root:SetHAnchor(ANCHOR_MIDDLE)  -- 水平坐标锚点设置
	self.root:SetPosition(50, -200, 0)  -- 坐标锚点偏移设置
	-- self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)  -- 设置缩放模式
	self.root:SetScale(.5, .5, .5)
	self.bg = self.root:AddChild(  -- 背景图片
		Image("images/fepanels.xml", "panel_saveslots.tex")
	)
	self.bg:SetScale(1.5, .5, 1)

	self.btn0 = self.root:AddChild(ImageButton())
	self.btn0:SetOnClick(function() TheFrontEnd:PopScreen(self) end)
	self.btn0:SetPosition(160, 80, 0)
	self.btn0:SetScale(.8,.8,.8)
	self.txt0 = self.btn0:AddChild(Text(BUTTONFONT, 40))
	self.txt0:SetString("关闭")
	self.txt0:SetVAlign(ANCHOR_MIDDLE)
	self.txt0:SetColour(0,0,0,1)

	self.btn1 = self.root:AddChild(ImageButton())
	self.btn1:SetOnClick(function() AddMorph(GetPlayer(), "bee") end)
	self.btn1:SetPosition(-160, 0, 0)
	self.txt1 = self.btn1:AddChild(Text(BUTTONFONT, 40))
	self.txt1:SetString("蜜蜂")
	self.txt1:SetVAlign(ANCHOR_MIDDLE)
	self.txt1:SetColour(0,0,0,1)

	self.btn2 = self.root:AddChild(ImageButton())
	self.btn2:SetOnClick(function() AddMorph(GetPlayer(), "pigman") end)
	self.btn2:SetPosition(0,0,0)
	self.txt2 = self.btn2:AddChild(Text(BUTTONFONT, 40))
	self.txt2:SetString("猪人")
	self.txt2:SetVAlign(ANCHOR_MIDDLE)
	self.txt2:SetColour(0,0,0,1)

	self.btn3 = self.root:AddChild(ImageButton())
	self.btn3:SetOnClick(function() AddMorph(GetPlayer(), "merm") end)
	self.btn3:SetPosition(160, 0, 0)
	self.txt3 = self.btn3:AddChild(Text(BUTTONFONT, 40))
	self.txt3:SetString("鱼人")
	self.txt3:SetVAlign(ANCHOR_MIDDLE)
	self.txt3:SetColour(0,0,0,1)

	self.btn4 = self.root:AddChild(ImageButton())
	self.btn4:SetOnClick(function() AddMorph(GetPlayer(), "hound") end)
	self.btn4:SetPosition(-160, -80, 0)
	self.txt4 = self.btn4:AddChild(Text(BUTTONFONT, 40))
	self.txt4:SetString("猎犬")
	self.txt4:SetVAlign(ANCHOR_MIDDLE)
	self.txt4:SetColour(0,0,0,1)

	self.btn5 = self.root:AddChild(ImageButton())
	self.btn5:SetOnClick(function() AddMorph(GetPlayer(), "spider") end)
	self.btn5:SetPosition(0, -80, 0)
	self.txt5 = self.btn5:AddChild(Text(BUTTONFONT, 40))
	self.txt5:SetString("蜘蛛")
	self.txt5:SetVAlign(ANCHOR_MIDDLE)
	self.txt5:SetColour(0,0,0,1)

	self.btn6 = self.root:AddChild(ImageButton())
	self.btn6:SetOnClick(function() OriginalMorph(GetPlayer()) end)
	self.btn6:SetPosition(160, -80, 0)
	self.txt6 = self.btn6:AddChild(Text(BUTTONFONT, 40))
	self.txt6:SetString("还原")
	self.txt6:SetVAlign(ANCHOR_MIDDLE)
	self.txt6:SetColour(0,0,0,1)

	self.title = self.root:AddChild(
		Text(TITLEFONT, 60)
	)
	self.title:SetPosition(0, 100, 0)
	self.title:SetRegionSize(500, 500)
	self.title:SetString("七十二变")
	self.title:SetVAlign(ANCHOR_MIDDLE)

end)

return mk_morph