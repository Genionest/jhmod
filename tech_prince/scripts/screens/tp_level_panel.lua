local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"
local AnimButton = require "widgets/animbutton"
local TpImageButton = require "widgets/tp_image_button"

local DATA = WARGON.DATA.tp_data_level

local TpLevelPanel = Class(Screen, function(self)
	SetPause(true)
	Screen._ctor(self, "TpLevelPanel")
	self.data = DATA
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
			end,
		},
		{
			text = "确认",
			cb = function()
				SetPause(false)
				-- level_up(self)
				self:LevelUp()
				TheFrontEnd:PopScreen(self)
			end
		},
		{
			text = "取消",
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
	self.button_menu:SetPosition(-220*(#menuitems-1)/2, -250, 0)
	self.button_menu:SetScale(1)
	
	self:Init()
	self:SetContent()
end)

local uipos = {}
for i = 0, 1 do
	for j = 0, 7 do
		local px, py = 100, -180
		local x, y = -((8-1)*px)/2, 150
		local pos = Vector3( x+j*px, y+i*py, 0 )
		table.insert(uipos, pos)
	end
end
local PAGE_MAX_UI = #uipos

function TpLevelPanel:Init()
	self.title = self.root:AddChild(Text(TITLEFONT, 60))
	self.title:SetPosition(0, 230, 0)
	self.title:SetRegionSize(1000, 1000)
	self.title:SetVAlign(ANCHOR_MIDDLE)  -- 垂直对齐
	self.essence = self.root:AddChild(Text(TITLEFONT, 30))
	self.essence:SetPosition(300, -170, 0)
	self.level = self.root:AddChild(Text(TITLEFONT, 30))
	self.level:SetPosition(300, -200, 0)
	self.tip = self.root:AddChild(Text(TITLEFONT, 20))
	self.tip:SetPosition(-280, -200, 0)
	self.content = {}
	self.data:init()
end

function TpLevelPanel:Clear()
	if type(self.content) == "table" then
		for k, v in pairs(self.content) do
			if v then
				self.root:RemoveChild(v)
				v:Kill()
			end
		end
	end
	self.content = {}
end

function TpLevelPanel:SetContent()
	self:Clear()
	for k, v in pairs(self.data:get_attrs()) do
		local img_path = {v:get_img()}
		self.content[k] = self.root:AddChild(
			TpImageButton(img_path[1], img_path[2], v:get_anim()))
		self.content[k]:SetPosition(uipos[k])
		self.content[k]:SetOnClick(function()
			if TheInput:IsKeyDown(KEY_CTRL) then
				self.data:on_click_dec(k)
				self.content[k]:SetString(self.data:get_attr_num(k))
				self.essence:SetString(self.data:get_essence_string())
				self.level:SetString(self.data:get_level_string())
			else
				self.data:on_click_add(k)
				self.content[k]:SetString(self.data:get_attr_num(k))
				self.essence:SetString(self.data:get_essence_string())
				self.level:SetString(self.data:get_level_string())
			end
		end)
		self.content[k]:SetString(self.data:get_attr_num(k))
		self.content[k]:SetString2(self.data:get_attr_tip(k))
	end
	self.essence:SetString(self.data:get_essence_string())
	self.level:SetString(self.data:get_level_string())
	self.title:SetString(self.data:get_title())
	self.tip:SetString(self.data:get_tip())
end

function TpLevelPanel:PageTurn(dt)
	self.data:page_turn(dt)
	self:SetContent()
end

function TpLevelPanel:LevelUp(dt)
	self.data:level_up()
	self:SetContent()
end

return TpLevelPanel