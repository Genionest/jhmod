local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"
local WgMenu = require "extension.uis.wg_menu"

local AkTransporterScreen = Class(Screen, function(self, data)
    self.data = data
    SetPause(true)
    Screen._ctor(self, "AkTransporterScreen")

    self.root = self:AddChild(Widget("ROOT"))  -- 底板
	self.root:SetVAnchor(ANCHOR_MIDDLE)  -- 垂直坐标锚点设置
	self.root:SetHAnchor(ANCHOR_MIDDLE)  -- 水平坐标锚点设置
	self.root:SetPosition(0, 0, 0)  -- 坐标锚点偏移设置
	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)  -- 设置缩放模式
	self.bg = self.root:AddChild(  -- 背景图片
		Image("images/fepanels.xml", "panel_saveslots.tex")
	)
	self.bg:SetScale(1, 1, 1)

    self.menu = self.root:AddChild(WgMenu(), 8)
	-- self.menu:SetScale(.6)
	self.menu:SetPosition(-50, 0, 0)

    self.exit = self.root:AddChild(
        ImageButton("minimap/minimap_data.xml", "xspot.png")
    )
    self.exit:SetPosition(100,200)
    self.exit:SetOnClick(function()
        self:Exit()
    end)
    self:Init()
end)

function AkTransporterScreen:Init()
    self.menu.page_up:SetOnClick(function()
		self:MenuPageTurn(-1)
	end)
	self.menu.page_down:SetOnClick(function()
		self:MenuPageTurn(1)
	end)
    self:MenuPageTurn(0)
end

function AkTransporterScreen:Exit()
    TheFrontEnd:PopScreen(self)
    SetPause(false)
end

function AkTransporterScreen:MenuPageTurn(dt)
	self.data:PageTurn(dt)
	self:SetMenu()
end

function AkTransporterScreen:SetMenu()
    local shelfs = self.data:GetItems()
	for k, v in pairs(shelfs) do
		local button = self.menu.buttons[k]
		if button then
			button:SetText(v.title)
			button:SetOnClick(function()
				self.data:SetPoint(k)
                self:Transport(v.machine)
			end)
			if not button.shown then
				button:Show()
			end
		end
	end
	for i = #shelfs+1, 8 do
		local button = self.menu.buttons[i]
		if button then
			button:Hide()
		end
	end
	-- 在这里设置，因为也是属于这个界面的更新
	if self.data.cur <= 1 then
		self.menu.page_up:Disable()
	else
		self.menu.page_up:Enable()
	end
	if self.data.cur >= self.data.max then
		self.menu.page_down:Disable()
	else
		self.menu.page_down:Enable()
	end
end

function AkTransporterScreen:Transport(machine)
	if machine.components.ak_transporter then
		machine.components.ak_transporter:GoMyPoint()
	end
	if machine.components.tp_transporter then
		machine.components.tp_transporter:GoMyPoint()
	end
    self:Exit()
end

return AkTransporterScreen