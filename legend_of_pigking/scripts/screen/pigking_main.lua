local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"

local pigking_game = require "pigking_game"

local pigking_main = Class(Screen, function(self)
	SetPause(true)  -- 启动窗口暂停
	Screen._ctor(self, "pigking")
	self.root = self:AddChild(Widget("ROOT"))  -- 底板
	self.root:SetVAnchor(ANCHOR_MIDDLE)  -- 垂直坐标锚点设置
	self.root:SetHAnchor(ANCHOR_MIDDLE)  -- 水平坐标锚点设置
	self.root:SetPosition(0, 0, 0)  -- 坐标锚点偏移设置
	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)  -- 设置缩放模式
	self.bg = self.root:AddChild(  -- 背景图片
		Image("images/fepanels.xml", "panel_saveslots.tex")
	)
	self.bg:SetScale(2, 1, 1)
	-- 菜单按钮
	local menuitems = {
		{
			text = "关闭",
			cb = function()
				SetPause(false)  -- 取消暂停
				TheFrontEnd:PopScreen(self)
			end
		},
		{
			text = "浏览",
			cb = function()
				self.title:SetString("你去帮我杀6个鱼人")
			end
		},
		{
			text = "金子",
			cb = function()
				SetPause(false)
				TheFrontEnd:PopScreen(self)
				pigking_game()
			end
		},
	}
	self.button_menu = self.root:AddChild(
		Menu(menuitems, 220, true)  -- 菜单列表,按钮间距,是否横着
	)
	self.button_menu:SetPosition(-220*(#menuitems-1)/2, -200, 0)
	self.button_menu:SetScale(1)
	-- 文字
	self.title = self.root:AddChild(
		Text(TITLEFONT, 60)
	)
	self.title:SetPosition(0, 100, 0)
	self.title:SetRegionSize(500, 500)
	self.title:SetString("我需要你做一点任务")
	self.title:SetVAlign(ANCHOR_MIDDLE)  -- 垂直对齐
	-- self.title:SetColour(1, 0, 0, 1)
end)

return pigking_main