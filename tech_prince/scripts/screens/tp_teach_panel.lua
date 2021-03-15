local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"

local DATA = WARGON.DATA.teach_panel_data

local TpTeachPanel = Class(Screen, function(self)
	SetPause(true)
	self.data = DATA
	Screen._ctor(self, "TpTeachPanel")
	self.root = self:AddChild(Widget("ROOT"))  -- 底板
	self.root:SetVAnchor(ANCHOR_MIDDLE)  -- 垂直坐标锚点设置
	self.root:SetHAnchor(ANCHOR_MIDDLE)  -- 水平坐标锚点设置
	self.root:SetPosition(0, 0, 0)  -- 坐标锚点偏移设置
	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)  -- 设置缩放模式
	self.bg = self.root:AddChild(  -- 背景图片
		Image("images/fepanels.xml", "panel_saveslots.tex")
	)
	self.bg:SetScale(2, 1, 1)
	-- x/2=400, y/2=300
	-- 菜单按钮
	local menuitems = {
		{
			text = "上一页",
			cb = function()
				self:PageTurn(-1)
			end
		},
		{
			text = "关闭",
			cb = function()
				SetPause(false)
				TheFrontEnd:PopScreen(self)
			end
		},
		{
			text = "下一页",
			cb = function()
				self:PageTurn(1)
			end
		},
	}
	self.button_menu = self.root:AddChild(
		Menu(menuitems, 220, true)  -- 菜单列表,按钮间距,是否横着
	)
	self.button_menu:SetPosition(-220*(#menuitems-1)/2, -200, 0)
	self.button_menu:SetScale(1)

	self:Init()
	self:SetContent()
end)

function TpTeachPanel:Init()
	self.title = self.root:AddChild(Text(TITLEFONT, 60))
	self.title:SetPosition(0, 300, 0)
	self.content = self.root:AddChild(Text(TITLEFONT, 30))
	self.content:SetPosition(200, 60, 0)
	self.content:SetRegionSize(1000, 1000)
	self.content:SetHAlign(ANCHOR_LEFT)
end

function TpTeachPanel:SetContent()
	self.content:SetString(self.data:get_sentence())
	self.title:SetString(self.data:get_title())
end

function TpTeachPanel:PageTurn(dt)
	self.data:page_turn(dt)
	self:SetContent()
end

return TpTeachPanel