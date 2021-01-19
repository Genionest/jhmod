local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local uipos = {}
for i = 0, 1 do
	for j = 0, 7 do
		local x = -(7*80)/2 + 80*j
		local y = (1*80)/2 - 80*i
		local pos = Vector3(x, y, 0)
		table.insert(uipos, pos)
	end
end

local techs = {
	{
		name = "max_hp",
		img = "health_max.tex",
		desc = "血量提升",
	},
	{
		name = "armor",
		img = "footballhat.tex",
		desc = "防御提升",
	},
	{
		name = "dmg",
		img = "spear.tex",
		desc = "攻击提升"
	},
	{
		name = "speed",
		img = "cane.tex",
		desc = "移速提升",
	},
}

local TechButton = Class(ImageButton, function(self, atlas, img)
	ImageButton._ctor(self, atlas, img)
	self.tip = self:AddChild(Text(TITLEFONT, 30))
	-- self.tip:SetPosition(0, -30, 0)
	self.tip:Hide()
end)

function TechButton:OnGainFocus()
	TechButton._base.OnGainFocus(self)
	self.tip:Show()
end

function TechButton:OnLoseFocus()
	TechButton._base.OnLoseFocus(self)
	self.tip:Hide()
end

function TechButton:SetTip(txt)
	self.tip:SetString(txt)
end

local PigTechTreeScreen = Class(Screen, function(self)
	SetPause(true)
	Screen._ctor(self, "PigTechTreeScreen")
	self.owner = GetPlayer()

	-- 底板
	self.root = self:AddChild(Widget("ROOT"))
	-- 垂直居中
	self.root:SetVAnchor(ANCHOR_MIDDLE)
	-- 水平居中
	self.root:SetHAnchor(ANCHOR_MIDDLE)
	self.root:SetPosition(0, 0, 0)
	-- 设置缩放模式
	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	  -- 背景图片
	self.bg = self.root:AddChild(
		Image("images/fepanels.xml", "panel_saveslots.tex")
	)
	self.bg:SetScale(2, 1, 1)

	self.buttons = {}
	for k, v in pairs(uipos) do
		self.buttons[k] = self.root:AddChild(TechButton(
			"images/inventoryimages.xml", "ash.tex"
		))
		self.buttons[k]:SetPosition(v)
		-- self:Hide()
	end
	self.exit = self.root:AddChild(ImageButton())
	self.exit:SetText("EXIT")
	self.exit:SetPosition(-300, 300, 0)
	self.exit:SetOnClick(function()
		TheFrontEnd:PopScreen(self)
		SetPause(false)
	end)

	self:SetContent()
	self:Test()
end)

function PigTechTreeScreen:SetContent()
	for k, v in pairs(techs) do
		self.buttons[k]:SetTextures(
			v.atlas or "images/inventoryimages.xml", v.img
		)
		self.buttons[k]:SetTip(v.desc)
		self.buttons[k]:SetOnClick(function()
			GetWorld().components.pigtechtree:AddAttr(v.name)
		end)
		self.buttons[k]:Show()
	end
end

function PigTechTreeScreen:Test()
	self.data = {
		80
	}
	local function test()
		local pad = self.data[1]
		local uipos = {}
		for i = 0, 1 do
			for j = 0, 7 do
				local x = -(7*pad)/2 + pad*j
				local y = (1*pad)/2 - pad*i
				local pos = Vector3(x, y, 0)
				table.insert(uipos, pos)
			end
		end
	end
	for k, v in pairs(self.buttons) do
		self.buttons[k]:SetPosition(v)
	end
	self.test_btn = self:AddChild(ImageButton())
	self.test_btn:SetText("Test")
	self.test_btn:SetPosition(300, 300, 0)
	self.test_btn:SetOnClick(function()
		if TheInput:IsKeyDown(KEY_CTRL) then
			self.data[1] = self.data[1] - 10
		else
			self.data[1] = self.data[1] + 10
		end
		test()
	end)
end

return PigTechTreeScreen