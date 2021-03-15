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
local PigRect = require "widgets/pig_rect"
local LongRect = require "widgets/long_rect"

local labels = {
	-- {
	-- 	img = "onemanband.tex",
	-- 	txt = "让周围的猪人跟随你",
	-- },
	-- {
	-- 	img = "axe.tex",
	-- 	txt = "指挥周围的猪人去砍树或竹子",
	-- },
	-- {
	-- 	img = "spear.tex",
	-- 	txt = "让周围的猪人进入进攻状态，会\n主动攻击更多目标",
	-- },
	-- {
	-- 	img = "bushhat.tex",
	-- 	txt = "让周围的猪人放弃攻击和砍树",
	-- },
	{
		img = "panflute.tex",
		txt = "让周围的猪人不再跟随，带着船\n长帽可作用于海豚",
	},
	{
		img = "captainhat.tex",
		txt = "戴着船长帽时可以让周围的海豚\n跟随你",
	},
}

local PagePoster = Class(Screen, function(self)
	Screen._ctor(self, "PagePoster")
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
	-- 背景尺寸
	self.bg:SetScale(2, 1, 1)

	-- 海报
	self.main_bg = self.root:AddChild(UIAnim())
	self.main_bg:GetAnimState():SetBank("ui_chest_3x3")
	self.main_bg:GetAnimState():SetBuild("ui_chest_3x3")
	self.main_bg:GetAnimState():PlayAnimation("open")
	-- self.main_bg:SetScale(3, 3, 0)
	-- self.main = self.main_bg:AddChild(
		-- Image("images/pigking_poster.xml", "pigking_poster.tex")
	-- )

	-- 标题
	self.title = self.root:AddChild(PigRect())
	-- self.title:SetPosition(0, 0, 0)
	-- self.title_txt = self.title:AddChild(Text(TITLEFONT, 50))
	self.title_txt = self.root:AddChild(Text(TITLEFONT, 50))
	-- self.title_txt:SetString("惊现！另一位猪王")
	self.title_txt:SetString("激战！海上的巨妖")

	-- 技能
	self.labels = {}
	local _x, _y = 0, 0
	local pad = 80
	local scale = .5
	local len = #labels
	for k, v in pairs(labels) do
		self.labels[k] = self.root:AddChild(LongRect())
		self.labels[k].icon:SetTexture(
			v.atlas or "images/inventoryimages.xml", v.img
		)
		self.labels[k].word:SetString(v.txt)
		self.labels[k]:SetScale(scale, scale, 0)
		self.labels[k]:SetPosition(_x, _y+(pad*(len-1)/2)-pad*k, 0)
	end

	self:SetContent()
end)

local function test(self)
	local D = {}
	for k, v in pairs(self.data) do
		D[k] = self.data[k][2]
	end
	self.main_bg:SetScale(D[1], D[1], 0)
	self.main_bg:SetPosition(D[11], D[12], 0)
	-- self.main:SetScale(D[2], D[2], 0)
	self.title:SetPosition(D[3], D[4], 0)
	self.title_txt:SetPosition(D[3], D[4]+24*D[6], 0)
	self.title:SetScale(D[5], D[6], 0)
	local len = #self.labels
	local x, y = D[8], D[9]
	local pad = D[10]
	for k, v in pairs(self.labels) do
		v:SetScale(D[7], D[7], 0)
		v:SetPosition(x, y+(pad*(len-1)/2)-pad*k, 0)
		v.word:SetPosition(D[13], 0, 0)
	end
end

function PagePoster:SetContent()
	self.data = {
		{ "MBgSize", 1.5, .1 },
		{ "MImgSize", 1.2, .05 },
		{ "TitleX", -185, 5 },
		{ "TitleY", 190, 5 },
		{ "TSizeX", .5, .1 },
		{ "TSizeY", .4, .1 },
		{ "IconSize", .4, .1 },
		{ "IconX", 245, 5 },
		{ "IconY", 65, 5 },
		{ "IconPad", 100, 5 },
		{ "MainBgX", -185, 5 },
		{ "MainBgY", -40, 5 },
		{ "IconTxtX", 135, 5 },
	}
	local function click(n)
		local dt = self.data[n][3]
		local data = self.data[n]
		if TheInput:IsKeyDown(KEY_CTRL) then
			data[2] = data[2] - dt
		else
			data[2] = data[2] + dt
		end
		test(self)
	end
	local menuitems = {}
	for k, v in pairs(self.data) do
		menuitems[k] = {
			text = v[1],
			cb = function()
				click(k)
			end,
		}
	end
	table.insert(menuitems, {
		text = "OutPut",
		cb = function()
			print("OutPut")
			for k, v in pairs(self.data) do
				print(v[1], v[2])
			end
		end,
	})
	table.insert(menuitems, {
		text = "Exit",
		cb = function()
			TheFrontEnd:PopScreen(self)
		end
	})
	self.menu = self:AddChild(Menu(menuitems, 50, false))
	local n = #menuitems
	local s_x = (n-1)*30/2
	-- local s_x = 0
	self.menu:SetPosition(200, s_x, 0)
	-- self.menu:Hide()
	-- self.main:Hide()
	test(self)
end

return PagePoster