local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"

local DATA = WARGON.DATA.check_panel_data

local TpCheckPanel = Class(Screen, function(self)
	SetPause(true)
	self.data = DATA
	Screen._ctor(self, "TpCheckPanel")
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

local uipos = {}
for i = 0, 1 do
	for j = 0, 3 do
		local px, py = 200, -180
		local x, y = -((4-1)*px)/2, 100
		local pos = Vector3( x+j*px, y+i*py, 0 )
		table.insert(uipos, pos)
	end
end
local PAGE_MAX_UI = #uipos

function TpCheckPanel:Clear()
	if type(self.content) == "table" then
		for k, v in pairs(self.content) do
			if v then
				self.root:RemoveChild(v)
				v:Kill()
			end
			if v.word then
				self.root:RemoveChild(v.word)
				v.word:Kill()
			end
		end
	end
	self.content = {}
end

function TpCheckPanel:Init()
	self.title = self.root:AddChild(Text(TITLEFONT, 60))
	self.title:SetPosition(0, 300, 0)
	self.content = {}
end

function TpCheckPanel:SetContent()
	self:Clear()
	for k, v in pairs(self.data:get_anims()) do
		local pos = uipos[k]
		self.content[k] = self.root:AddChild(UIAnim())
		self.content[k]:SetPosition(pos)
		self.content[k].word = self.root:AddChild(
			Text(TITLEFONT, 30))
		self.content[k].word:SetPosition(pos.x, pos.y-30, pos.z)
		v:set_anim(self.content[k]:GetAnimState())
		local scale = v.scale or .3
		self.content[k].inst.UITransform:SetScale(scale, scale, scale)
		v:fix(self.content[k]:GetAnimState())
		self.content[k].word:SetString(v:get_string())
	end
	self.title:SetString(self.data:get_title())
end

function TpCheckPanel:SetUIPosition(child, idx)
	if child then
		local pad_x, pad_y = 200, 180
		local len = 4
		local x, y = -((len-1)*pad_x)/2, 100
		local pos_x = x + (idx%len)*pad_x
		local pos_y = y + math.floor(idx/len)*-pad_y
		child:SetPosition(pos_x, pos_y, 0)
		child.word:SetPosition(pos_x, pos_y-30, 0)
		-- print("TpCheckPanel pos", pos_x, pos_y, idx)
	end
end

function TpCheckPanel:PageTurn(dt)
	self.data:page_turn(dt)
	self:SetContent()
end

return TpCheckPanel