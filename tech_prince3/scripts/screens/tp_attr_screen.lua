local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"

local WgMenu = require "extension.uis.wg_menu"
local WgBlackboard = require "extension.uis.wg_blackboard"

-- local DATA = Sample.Intro

local TpAttrScreen = Class(Screen, function(self, Data)
	SetPause(true)
	Screen._ctor(self, "TpAttrScreen")
	self.data = Data
	self.root = self:AddChild(Widget("ROOT"))
	self.root:SetVAnchor(ANCHOR_MIDDLE)
	self.root:SetHAnchor(ANCHOR_MIDDLE)
	self.root:SetPosition(0, 0, 0)
	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.bg = self.root:AddChild(
		Image("images/fepanels.xml", "panel_saveslots.tex")
	)
	self.bg:SetScale(2, 1, 1)

	self.exit = self.root:AddChild(ImageButton(
		"minimap/minimap_data.xml", "xspot.png"
	))
	self.exit:SetPosition(350, 300)
	self.exit:SetOnClick(function()
		TheFrontEnd:PopScreen(self)
		SetPause(false)
	end)
	self.label = self.root:AddChild(Image(
		"images/ui.xml", "update_banner.tex"
	))
	self.label:SetPosition(0, 300, 0)
	self.title = self.label:AddChild(Text(TITLEFONT, 40))
	self.title:SetString(self.data.title)
	self.title:SetPosition(0, 10, 0)

	self.menu = self.root:AddChild(WgMenu(8))
	self.menu:SetPosition(-330, 0, 0)
	self.menu:SetScale(.8)

	self.mini_menu = self.root:AddChild(WgMenu(10))
	self.mini_menu:SetPosition(-200, 0, 0)
	self.mini_menu:SetScale(.6)

	self.blackboard = self.root:AddChild(WgBlackboard())
	self.blackboard:SetPosition(150, -20, 0)	
	self:Init()
end)

function TpAttrScreen:Init()

	self:MenuPageTurn(0)
	self:MiniMenuPageTurn(0)
	self:BookPageTurn(0)
	self.menu.page_up:SetOnClick(function()
		self:MenuPageTurn(-1)
	end)
	self.menu.page_down:SetOnClick(function()
		self:MenuPageTurn(1)
	end)
	self.mini_menu.page_up:SetOnClick(function()
		self:MiniMenuPageTurn(-1)
	end)
	self.mini_menu.page_down:SetOnClick(function()
		self:MiniMenuPageTurn(1)
	end)
	self.blackboard.page_up:SetOnClick(function()
		self:BookPageTurn(-1)
	end)
	self.blackboard.page_down:SetOnClick(function()
		self:BookPageTurn(1)
	end)
end

function TpAttrScreen:MenuPageTurn(dt)
	self.data:PageTurn(dt)
	self:SetMenu()
end

function TpAttrScreen:MiniMenuPageTurn(dt)
	local shelf = self.data:GetItem()
	shelf:PageTurn(dt)
	self:SetMiniMenu()
end

function TpAttrScreen:BookPageTurn(dt)
	local book = self.data:GetItem():GetItem()
	book:PageTurn(dt)
	self:SetBlackboard()
end

function TpAttrScreen:SetMenu()
	local shelfs = self.data:GetItems()
	for k, v in pairs(shelfs) do
		local button = self.menu.buttons[k]
		if button then
			button:SetText(v.title)
			button:SetOnClick(function()

				self.data:SetPoint(k)
				self:SetMiniMenu()
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
	self:SetMiniMenu()
end

function TpAttrScreen:SetMiniMenu()
	local book_shelf = self.data:GetItem():GetItems()
	for k, v in pairs(book_shelf) do
		local button = self.mini_menu.buttons[k]
		if button then
			button:SetText(v.title)
			button:SetOnClick(function()

				self.data:GetItem():SetPoint(k)
				self:SetBlackboard()
			end)
			if not button.shown then
				button:Show()
			end
		end
	end
	for i = #book_shelf+1, 11 do
		local button = self.mini_menu.buttons[i]
		if button then
			button:Hide()
		end
	end
	local shelf = self.data:GetItem()
	if shelf.cur <= 1 then
		self.mini_menu.page_up:Disable()
	else
		self.mini_menu.page_up:Enable()
	end
	if shelf.cur >= shelf.max then
		self.mini_menu.page_down:Disable()
	else
		self.mini_menu.page_down:Enable()
	end
	self:SetBlackboard()
end

function TpAttrScreen:SetBlackboard()
	local book = self.data:GetItem():GetItem()
	self.blackboard:SetString(book:GetString())
	if book.cur <= 1 then
		self.blackboard.page_up:Disable()
	else
		self.blackboard.page_up:Enable()
	end
	if book.cur >= book.max then
		self.blackboard.page_down:Disable()
	else
		self.blackboard.page_down:Enable()
	end
end

return TpAttrScreen