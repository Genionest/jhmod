local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"

local AssetUtil = require "extension/lib/asset_util"

local WgBlackboard = require "extension/uis/wg_blackboard"

local WgItem = Class(ImageButton, function(self, atlas, normal)
	ImageButton._ctor(self, atlas, normal)
	self.anim = self:AddChild(UIAnim())
	self.word = self:AddChild(Text(TITLEFONT, 30))
	self.word:SetPosition(0, -50, 0)
end)

function WgItem:OnGainFocus()
	WgItem._base.OnGainFocus(self)
	if self.anim then
		self.anim:SetScale(1.2, 1.2, 1.2)
	end


	if self.gain_focus_fn then
		self.gain_focus_fn(self)
	end
end

function WgItem:OnLoseFocus()
	WgItem._base.OnLoseFocus(self)
	if self.anim then
		self.anim:SetScale(1, 1, 1)
	end

	if self.lose_focus_fn then
		self.lose_focus_fn(self)
	end
end

function WgItem:SetAnim(anims)
	if anims then



		self.anim:GetAnimState():SetBank(anims[1])
		self.anim:GetAnimState():SetBuild(anims[2])
		self.anim:GetAnimState():PlayAnimation(anims[3])
		self.anim:Show()





	else
		self.anim:Hide()
	end
end

function WgItem:SetString(str)
	self.word:SetString(str)
end

function WgItem:Test()
	self.word:SetString(1000)
	local strs = {
		"ChildPosY",
		"TextSize",
		"IconPosX",
		"IconSize",
	}
	local test_data = {
		-30, 30, -20, .4,
	}
	local dts = {
		10, 10, 10, .1,
	}
	local function test_fn()
		self.word:SetPosition(0, self.test_menu.data[1], 0)
		self.word:SetSize(self.test_menu.data[2])
		self.icon:SetPosition(self.test_menu.data[3], self.test_menu.data[1], 0)
		self.icon:SetScale(self.test_menu.data[4])
	end


end

local InfoBoard = Class(WgBlackboard, function(self)
	WgBlackboard._ctor(self)
	self.back_ground:SetTexture(
		"images/hud.xml", "craftingsubmenu_fullvertical.tex"
	)
	self.back_ground:SetRotation(270)
	self.back_ground:SetScale(.9, 0.7, 0)
	self.page_up:SetPosition(-260, 20, 0)
	self.page_up:SetScale(.6)
	self.page_up:Hide()
	self.page_down:SetPosition(260, 20, 0)
	self.page_down:SetScale(.6)
	self.page_down:Hide()
	self.text:SetPosition(110, -20, 0)
	self.text:SetSize(25)
	self.text:SetRegionSize(450, 450, 0)
	self.label = self:AddChild(Image(
		"images/hud.xml", "craft_slot.tex"
	))
	self.name = self:AddChild(Text(TITLEFONT, 45))
	self.name:SetPosition(30, 50, 0)
	self.label:SetPosition(30, 50, 0)
	self.label:SetScale(1, 1, 0)


end)

function InfoBoard:SetName(str)
	local len = string.len(str)/3
	local scale = math.min(2.8, math.max(1, len/2 ) )
	self.label:SetScale(scale, 1, 0)
	self.name:SetString(str)
end

function InfoBoard:TestItem()

end

local WgItemBoard = Class(WgBlackboard, function(self)
	WgBlackboard._ctor(self)
	self.back_ground:SetTexture(
		"images/hud.xml", "craftingsubmenu_fullhorizontal.tex"
	)
	self.back_ground:SetScale(2.2, 1.4, 0)
	self.page_up:SetPosition(-235, 0, 0)
	self.page_down:SetPosition(370, 0, 0)

	self.slots = {}
	self.items = {}
	local count = 1
	local slot_x = 150
	local slot_y = 170
	local slot_pad = 110
	for i = 0, 3  do
		for j = 0, 4 do
			self.slots[count] = self:AddChild(Image(
				"images/hud.xml", "inventory_bg_single.tex"
			))
			self.slots[count]:SetScale(.8)
			self.slots[count]:SetPosition(-slot_x+slot_pad*j, slot_y-slot_pad*i)
			self.slots[count]:Hide()
			self.items[count] = self:AddChild(WgItem(
				"images/inventoryimages.xml", "ash.tex"
			))
			self.items[count]:SetScale(.8)
			self.items[count]:SetPosition(-slot_x+slot_pad*j, slot_y-slot_pad*i)
			self.items[count]:Hide()
			self.items[count].gain_focus_fn = function()


			end
			self.items[count].lose_focus_fn = function()

			end
			count = count + 1
		end
	end

	self.item_word = self:AddChild(Text(TITLEFONT, 30))
	self.item_word:Hide()

end)

function WgItemBoard:Test()


end

function WgItemBoard:TestItem()

end


local TpOrnamentScreen = Class(Screen, function(self, data, owner)
	SetPause(true)
	self.data = data
    self.owner = owner
	Screen._ctor(self, "TpOrnamentScreen")
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

	self.item_board = self.root:AddChild(WgItemBoard())
	self.item_board:SetPosition(0, -20, 0)

















	self.balance_bg = self.root:AddChild(Image(
		"images/hud.xml", "inventory_bg_single.tex"
	))
	self.balance_bg:SetPosition(-330, 0, 0)
	local Uimg = AssetUtil:MakeImg("piggyback")
	self.balance_bg:AddChild(Image(
		AssetUtil:GetImage(Uimg)
	))
	self.balance = self.balance_bg:AddChild(Text(TITLEFONT, 40))
	self.balance:SetPosition(0, -40, 0)
	self.balance_tip = self.balance_bg:AddChild(Text(TITLEFONT, 30))

	-- self.balance_tip:SetString("精华")

	self.balance_tip3 = self.balance_bg:AddChild(Text(TITLEFONT, 30))
	self.balance_tip3:SetPosition(0, 150, 0)
	self.balance_tip3:SetString("鼠标悬停图标\n时，可在左下\n角观察信息")

	-- self.level_bg = self.root:AddChild(Image(
	-- 	"images/hud.xml", "inventory_bg_single.tex"
	-- ))
	-- self.level_bg:SetPosition(-330, -140, 0)
	-- self.level_icon = self.level_bg:AddChild(Image(
	-- 	"images/inventoryimages.xml", "accomplishment_shrine.tex"
	-- ))

	self.balance_tip2 = self.balance_bg:AddChild(Text(TITLEFONT, 30))
	self.balance_tip2:SetPosition(0, -150, 0)
	self.balance_tip2:SetString("点击可以卸下\n目标饰品")

	-- self.level = self.level_bg:AddChild(Text(TITLEFONT, 40))
	-- self.level:SetPosition(0, -40, 0)
	-- self.level_tip = self.level_bg:AddChild(Text(TITLEFONT, 30))
	-- self.level_tip:SetString("等级")








	self:Init()

    self.info_root = self:AddChild(Widget("InfoRoot"))
	self.info_root:SetVAnchor(ANCHOR_BOTTOM)
	self.info_root:SetHAnchor(ANCHOR_LEFT)
end)

function TpOrnamentScreen:Init()

	self:ItemBoardPageTurn(0)






	self.item_board.page_up:SetOnClick(function()
		self:ItemBoardPageTurn(-1)
	end)
	self.item_board.page_down:SetOnClick(function()
		self:ItemBoardPageTurn(1)
	end)


end






function TpOrnamentScreen:ItemBoardPageTurn(dt)

	self.data:PageTurn(dt)
	self:SetItemBoard()
end




































function TpOrnamentScreen:SetItemBoard()

    self:SetBalance()

    self:SetLevel()
	local item_shelf = self.data:GetItem():GetItems()


    for i = 1, self.data.unit do
		local item = self.item_board.items[i]
		local slot = self.item_board.slots[i]
		if item then
			item:Hide()
		end
		if slot then
			slot:Hide()
		end
	end
	for k, v in pairs(item_shelf) do

		local item = self.item_board.items[k]
		local slot = self.item_board.slots[k]

		if slot and item then

			item:SetTextures(v:GetImage())
			-- item:SetAnim(v:GetAnims())
			item:SetString(v:GetName())
			if v:IsDisable() then
				item:Disable()
			end
			if v:IsNone() then
				item.image:SetTint(0, 0, 0, .3)
			end
			
			item:SetOnClick(function()
                item.image:SetTint(1, 1, 1, .3)
                item:Disable()
                v:Lose(self.owner)
                -- self:SetItemBoard()

			end)
			item.gain_focus_fn = function()

				if self.owner and self.owner.HUD
				and self.owner.HUD.WgGetTool then
					local info_sign = self.owner.HUD:WgGetTool()

					if self.info_sign == nil then
						self.info_sign = info_sign
						self.info_root:AddChild(self.info_sign)

					end
					if self.info_sign then
						local info = Text(NUMBERFONT, 25)
						info:SetString(v:GetDescription())
						self.owner.HUD:WgShowInfo({info})
					end
				end
			end
			item.lose_focus_fn = function()

				if self.owner and self.owner.HUD then
					if self.info_sign then
						self.owner.HUD:AddChild(self.info_sign)

						self.info_sign = nil
					end
				end
			end
			if not item.shown then
				item:Show()
			end
			if not slot.shown then
				slot:Show()
			end
		end
	end

	local shelf = self.data
	if shelf.cur <= 1 then
		self.item_board.page_up:Disable()
	else
		self.item_board.page_up:Enable()
	end
	if shelf.cur >= shelf.max then
		self.item_board.page_down:Disable()
	else
		self.item_board.page_down:Enable()
	end
end

function TpOrnamentScreen:SetBalance()



    -- local balance = self.data:GetBalance(self)
    -- self.balance:SetString(balance)
end

function TpOrnamentScreen:SetLevel()
	-- local level = self.data:GetLevel(self)
	-- self.level:SetString(level)
end

function TpOrnamentScreen:Test()

end

return TpOrnamentScreen