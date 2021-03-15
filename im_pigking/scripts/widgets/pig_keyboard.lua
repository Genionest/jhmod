local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local DragImage = require "widgets/drag_image"

local btns = {
	{
		img = "onemanband.tex",
		fn = function()
			local player = GetPlayer()
			local x, y, z = player:GetPosition():Get()
			local ents = TheSim:FindEntities(x, y, z, 12, {"pig"}, {"werepig", "pigguard", "city_pig"})
			for k, v in pairs(ents) do
				if v.components.pigcontroller then
					v.components.pigcontroller:Follow(player)
				end
			end
			player.components.talker:Say(STRINGS.STR_PIGKING.follow_txt)
		end,
		txt = STRINGS.STR_PIGKING.follow,
	},
	{
		img = "axe.tex",
		fn = function()
			local player = GetPlayer()
			local x, y, z = player:GetPosition():Get()
			local ents = TheSim:FindEntities(x, y, z, 12, {"pig"}, {"werepig", "pigguard", "city_pig"})
			for k, v in pairs(ents) do
				if v.components.pigcontroller then
					v.components.pigcontroller:AddTagInTime("must_chop_tree", TUNING.PIGKING.time)
				end
			end
			player.components.talker:Say(STRINGS.STR_PIGKING.axe_txt)
		end,
		txt = STRINGS.STR_PIGKING.axe,
	},
	{
		img = "spear.tex",
		fn = function()
			local player = GetPlayer()
			local x, y, z = player:GetPosition():Get()
			local ents = TheSim:FindEntities(x, y, z, 12, {"pig"}, {"werepig", "pigguard", "city_pig"})
			for k, v in pairs(ents) do
				if v.components.pigcontroller then
					v.components.pigcontroller:AddTagInTime("must_attack", TUNING.PIGKING.time)
				end
			end
			player.components.talker:Say(STRINGS.STR_PIGKING.spear_txt)
		end,
		txt = STRINGS.STR_PIGKING.spear,
	},
	{
		img = "bushhat.tex",
		fn = function()
			local player = GetPlayer()
			local x, y, z = player:GetPosition():Get()
			local ents = TheSim:FindEntities(x, y, z, 12, {"pig"}, {"werepig", "pigguard", "city_pig"})
			for k, v in pairs(ents) do
				if v.components.pigcontroller then
					v.components.pigcontroller:GiveUp()
				end
			end
			player.components.talker:Say(STRINGS.STR_PIGKING.giveup_txt)
		end,
		txt = STRINGS.STR_PIGKING.giveup,
	},
	{
		img = "panflute.tex",
		fn = function()
			local player = GetPlayer()
			local x, y, z = player:GetPosition():Get()
			local ents = TheSim:FindEntities(x, y, z, 12, {"pig"}, {"werepig", "pigguard", "city_pig"})
			for k, v in pairs(ents) do
				if v.components.pigcontroller then
					v.components.pigcontroller:NoFollow()
				end
			end
			local hat = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
			if hat and hat.prefab == "captainhat" then
				local x, y, z = player:GetPosition():Get()
				local ents = TheSim:FindEntities(x, y, z, 12, {"ballphin"})
				for k, v in pairs(ents) do
					if v.components.follower then
						v.components.follower:SetLeader(nil)
					end
				end
			end
			player.components.talker:Say(STRINGS.STR_PIGKING.dissolve_txt)
		end,
		txt = STRINGS.STR_PIGKING.dissolve,
	},
	{
		img = "captainhat.tex",
		fn = function()
			local player = GetPlayer()
			local hat = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
			if hat and hat.prefab == "captainhat" then
				local x, y, z = player:GetPosition():Get()
				local ents = TheSim:FindEntities(x, y, z, 12, {"ballphin"})
				for k, v in pairs(ents) do
					if v.components.follower then
						player.components.leader:AddFollower(v)
						v.components.follower:AddLoyaltyTime(1200)
					end
				end
				player.components.talker:Say(STRINGS.STR_PIGKING.captain_txt2)
			else
				player.components.talker:Say(STRINGS.STR_PIGKING.captain_txt1)
			end
		end,
		txt = STRINGS.STR_PIGKING.captain,
	},
	-- {
	-- 	img = "hogusporkusator.tex",
	-- 	fn = function()
	-- 		TheFrontEnd:PushScreen(PigTechTreeScreen())
	-- 	end,
	-- 	txt = STRINGS.STR_PIGKING.pigtech,
	-- },
}

local PigKeyboard = Class(Widget, function(self)
	Widget._ctor(self, "PigKeyboard")

	self.bg = self:AddChild(Image(
		"images/hud.xml", "craftingsubmenu_fullvertical.tex"
	))
	self.bg:SetRotation(180)
	-- self.bg:SetScale(.6, .5, 0)
	self.slots = {}
	self.btns = {}
	self.words = {}
	local n = 1
	for i = 0, 1 do
		for j = 0, 1 do
			self.slots[n] = self:AddChild(Image(
				"images/hud.xml", "inventory_bg_single.tex"
			))
			-- self.slots[n]:SetPosition(35-70*j, 20+35-70*i, 0)
			-- self.slots[n]:SetScale(.6)

			self.btns[n] = self:AddChild(ImageButton(
				"images/inventoryimages.xml", "ash.tex"
			))
			-- self.btns[n]:SetPosition(35-70*j, 20+35-70*i, 0)
			-- self.btns[n]:SetScale(.6)
			self.words[n] = self:AddChild(Text(TITLEFONT, 30))
			-- self.words[n]:SetString("")
			n = n + 1
		end
	end
	self.left_arrow = self:AddChild(ImageButton(
		"images/ui.xml", "scroll_arrow.tex"
	))
	self.left_arrow:SetRotation(180)
	self.left_arrow:SetOnClick(function()
		self:PageTurn(-1)
	end)
	self.right_arrow = self:AddChild(ImageButton(
		"images/ui.xml", "scroll_arrow.tex"
	))
	self.right_arrow:SetOnClick(function()
		self:PageTurn(1)
	end)
	self.anchor = self:AddChild(DragImage(
		"images/inventoryimages.xml", "minisign_drawn.tex"
	))
	self.anchor:SetPosition(0, -120, 0)
	self.anchor:SetMaster(self, Vector3(0, 120, 0))
	self.data = {
		{ "BgSizeX", .8, .05 },
		{ "BgSizeY", .65, .05 },
		{ "StartX", 50, 5 },
		{ "StartY", 75, 5 },
		{ "PadX", 105, 5 },
		{ "PadY", 110, 5 },
		{ "IconSize", .8, .1 },
		{ "ArrowX", 125, 0 },
		{ "ArrowY", 20, 0 },
	}
	-- 章节管理
	self.total = #btns
	self.cur = 1
	self.max = math.ceil(self.total/4)
	self:SetContent()
	self:PageTurn(0)
	-- self:Test()
end)

local function set_content(self)
	local D = {}
	for k, v in pairs(self.data) do
		D[k] = self.data[k][2]
	end
	self.bg:SetScale(D[1], D[2], 0)
	local n = 1
	for i = 0, 1 do
		for j = 0, 1 do
			self.slots[n]:SetPosition(D[3]-D[5]+D[5]*j, D[4]-D[6]*i, 0)
			self.slots[n]:SetScale(D[7])

			self.btns[n]:SetPosition(D[3]-D[5]+D[5]*j, D[4]-D[6]*i, 0)
			self.btns[n]:SetScale(D[7])

			self.words[n]:SetPosition(D[3]-D[5]+D[5]*j, D[4]-D[6]*i-30, 0)

			self.left_arrow:SetPosition(-D[8], D[9], 0)
			self.left_arrow:SetScale(D[7])
			self.right_arrow:SetPosition(D[8], D[9], 0)
			self.right_arrow:SetScale(D[7])
			n = n + 1
		end
	end
end

function PigKeyboard:PageTurn(dt)
	self.cur = math.min(self.max, math.max(1, self.cur+dt))
	-- for k, v in pairs(btns) do
	-- for k = 4*self.cur-3, 4*self.cur do
	for k = 1, 4 do
		local idx = 4*(self.cur-1) + k
		if idx <= self.total then
			local v = btns[idx]
			self.btns[k]:SetTextures(
				v.atlas or "images/inventoryimages.xml", v.img
			)
			self.btns[k]:SetOnClick(function()
				v.fn()
			end)
			self.words[k]:SetString(v.txt)
			self.btns[k]:Show()
			self.words[k]:Show()
		else
			self.btns[k]:Hide()
			self.words[k]:Hide()
		end
	end
	-- self:SetContent()
end

function PigKeyboard:SetContent()
	set_content(self)
end

-- function PigKeyboard:Test()
-- 	local function click(n)
-- 		-- print(n)
-- 		if TheInput:IsKeyDown(KEY_CTRL) then
-- 			self.data[n][2] = self.data[n][2] - self.data[n][3]
-- 		else
-- 			self.data[n][2] = self.data[n][2] + self.data[n][3]
-- 		end
-- 	end
-- 	for k, v in pairs(self.data) do
-- 		self.data[k][4] = k
-- 	end
-- 	local menuitems = {}
-- 	for k, v in pairs(self.data) do
-- 		menuitems[k] = {
-- 			text = v[1],
-- 			cb = function()
-- 				-- click(v[4])
-- 				click(k)
-- 				-- tent()
-- 				self:SetContent()
-- 			end,
-- 		}
-- 	end
-- 	table.insert(menuitems, {
-- 		text = "OutPut",
-- 		cb = function()
-- 			print("OutPut")
-- 			for k, v in pairs(self.data) do
-- 				print(v[1], v[2])
-- 			end
-- 		end,	
-- 	})
-- 	self.test = self:AddChild(Menu(menuitems, 50, false))
-- 	self.test:SetPosition(200, 0, 0)
-- end

return PigKeyboard