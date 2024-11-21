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

local DATA = WARGON.DATA.sale_panel_data

local TpSalePanel = Class(Screen, function(self)
	-- SetPause(true)
	Screen._ctor(self, "TpSalePanel")
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
			end
		},
		{
			text = "关闭",
			cb = function()
				-- SetPause(false)
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
	-- 文字
	self.title = self.root:AddChild(
		Text(TITLEFONT, 30)
	)
	self.title:SetPosition(0, 200, 0)
	self.title:SetRegionSize(1000, 1000)
	self.title:SetVAlign(ANCHOR_MIDDLE)  -- 垂直对齐
	self:Init()
	self:SetContent()
end)

local uipos = {}
for i = 0, 1 do
	for j = 0, 7 do
		local px, py = 100, -180
		local x, y = -((8-1)*100)/2, 130
		local pos = Vector3( x+j*px, y+i*py, 0 )
		table.insert(uipos, pos)
	end
end
local PAGE_MAX_UI = #uipos

function TpSalePanel:Init()
	self.content = {}
	for k, v in pairs(uipos) do
		self.content[k] = self.root:AddChild(ImageButton(
			"images/inventoryimages.xml", "ash.tex"
		))
		self.content[k]:SetPosition(v)
		self.content[k].name = self.content[k]:AddChild(
			Text(TITLEFONT,30))
		self.content[k].name:SetPosition(0, -70, 0)
		self.content[k].price = self.content[k]:AddChild(
			Text(TITLEFONT, 30))
		self.content[k].price:SetPosition(0, -100, 0)
	end
	self.balance = self.root:AddChild(Text(TITLEFONT, 30))
	self.balance:SetPosition(300, -200, 0)
end

function TpSalePanel:SetContent()
	for k, v in pairs(self.data:get_goods_bar()) do
		if not self.content[k].shown then
			self.content[k]:Show()
		end
		self.content[k]:SetTextures(v.img.atlas, v.img.img)
		self.content[k].name:SetString(v:get_name())
		self.content[k].price:SetString(v:get_price())
		self.content[k]:SetOnClick(function()
			self.data:buy_item(v)
			self.balance:SetString(self.data:get_balance_string())
		end)
	end
	for i = #self.data:get_goods_bar()+1, PAGE_MAX_UI do
		self.content[i]:Hide()
	end
	self.balance:SetString(self.data:get_balance_string())
	self.title:SetString(self.data:get_title())
end

function TpSalePanel:PageTurn(dt)
	self.data:page_turn(dt)
	self:SetContent()
end

return TpSalePanel