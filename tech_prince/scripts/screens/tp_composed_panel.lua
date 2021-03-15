local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"

local DATA = WARGON.DATA.composed_panel_data

local slotpos = {108,36,-36,-108}

local TpComposedPanel = Class(Screen, function(self)
	self.data = DATA
	SetPause(true)
	Screen._ctor(self, "TpComposedPanel")
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
	-- 文字
	self.title = self.root:AddChild(
		Text(TITLEFONT, 60)
	)
	self.title:SetPosition(0, 200, 0)
	self.title:SetRegionSize(500, 500)
	self.title:SetVAlign(ANCHOR_MIDDLE)  -- 垂直对齐
	-- self.title:SetColour(1, 0, 0, 1)

	self:Init()
	self:SetContent()
	self.slots = {}
	self.ingds = {}
	for i = 1, 4 do
		self.slots[i] = self.root:AddChild(
			Image("images/hud.xml", "inv_slot.tex")
		)
		self.slots[i]:SetPosition(slotpos[i], -120, 0)
		self.ingds[i] = self.root:AddChild(
			Image("images/hud.xml", "inv_slot.tex")
		)
		self.ingds[i]:SetPosition(slotpos[i], -120, 0)
	end
	self.item_name = self.root:AddChild(Text(TITLEFONT, 50))
	self.item_name:SetPosition(-250, -120, 0)
	self.item_desc = self.root:AddChild(Text(TITLEFONT, 30))
	self.item_desc:SetPosition(280, -120, 0)
end)

local uipos = {}
for i = 0, 2 do
	for j = 0, 9 do
		local px, py = 80, -80
		local x, y = -((10-1)*px)/2, 150
		local pos = Vector3( x+j*px, y+i*py, 0 )
		table.insert(uipos, pos)
	end
end
local PAGE_MAX_UI = #uipos

function TpComposedPanel:Init()
	self.content = {}
	for k, v in pairs(uipos) do
		self.content[k] = self.root:AddChild(ImageButton(
			"images/inventoryimages.xml", "ash.tex"
		))
		self.content[k]:SetPosition(v)
		self.content[k]:SetScale(.8, .8, .8)
	end
end

function TpComposedPanel:Clear()
	if type(self.content) == "table" then
		for k, v in pairs(self.content) do
			if v then
				self:RemoveChild(v)
				v:Kill()
			end
		end
	end
	self.content = {}
end

function TpComposedPanel:SetContent()
	for k, v in pairs(self.data:get_items()) do
		if not self.content[k].shown then
			self.content[k]:Show()
		end
		self.content[k]:SetTextures(v:get_img())
		self.content[k]:SetOnClick(function()
			self:SetSlots(v)
			self:SetText(v)
		end)
	end
	for i = #self.data:get_items()+1, PAGE_MAX_UI do
		self.content[i]:Hide()
	end
	self.title:SetString(self.data:get_title())
end

function TpComposedPanel:SetUIPosition(child, idx)
	if child and idx <= PAGE_MAX_UI then
		child:SetPosition(uipos[idx])
	end
end

function TpComposedPanel:SetSlots(arg)
	for k, v in pairs(arg:get_ingds()) do
		self.ingds[k]:SetTexture(v.atlas, v.img)
	end
end

function TpComposedPanel:SetText(arg)
	self.item_name:SetString(arg:get_prefab_name())
	self.item_desc:SetString(arg:get_desc_string())
end

function TpComposedPanel:PageTurn(dt)	
	self.data:page_turn(dt)
	self:SetContent()
end

return TpComposedPanel