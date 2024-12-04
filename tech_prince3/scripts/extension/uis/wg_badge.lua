local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Badge = require "widgets/badge"
local ImageButton = require "widgets/imagebutton"
local UIAnim = require "widgets/uianim"
local Util = require "extension/lib/wg_util"

local WgBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "tp_badge", owner)
	-- self.anim:GetAnimState():Hide("stomach") -- stomach
	self.anim:GetAnimState():SetBank("health", 0)
	self.anim:GetAnimState():SetPercent("anim", 0)

	self.sanityarrow = self.underNumber:AddChild(UIAnim())
	self.sanityarrow:GetAnimState():SetBank("sanity_arrow")
	self.sanityarrow:GetAnimState():SetBuild("sanity_arrow")
	self.sanityarrow:GetAnimState():PlayAnimation("neutral")
	self.sanityarrow:SetClickable(false)

	self.topperanim = self.underNumber:AddChild(UIAnim())
	self.topperanim:GetAnimState():SetBank("effigy_topper")
	self.topperanim:GetAnimState():SetBuild("effigy_topper")
	self.topperanim:GetAnimState():PlayAnimation("anim")
	self.topperanim:SetClickable(false)

    self.str = self:AddChild(Text(NUMBERFONT, 20))
    self.str:SetPosition(0, 35, 0)

	self:StartUpdating()
end)

function WgBadge:SetPercent(p, max)
	Badge.SetPercent(self, p, max)
	-- self.num:SetString(tostring(math.ceil(p*max)))
    local percent = 1-p
	-- self.topperanim:GetAnimState():SetPercent("anim", percent)
	-- self.anim:GetAnimState():SetPercent("anim", 0)
	self.topperanim:GetAnimState():SetPercent("anim", 0)
	if self.wg_img then
		self.wg_img:SetTint(1,1,1,p/2+.5)
	elseif self.wg_btn then
		self.wg_btn.image:SetTint(1,1,1,p/2+.5)
	end
end

function WgBadge:SetImage(atlas, image)
    self.wg_img = self.anim:AddChild(Image(atlas, image))
	self.wg_img:SetScale(.6)
end

function WgBadge:SetImageButton(atlas, image, fn)
    self.wg_fn = fn
    self.wg_btn = self.anim:AddChild(ImageButton(atlas, image))
    self.wg_btn:SetOnClick(function()
        self.wg_fn(self.owner)
    end)
	self.wg_btn:SetScale(.6)
end

function WgBadge:SetString(str)
    self.str:SetString(str)
end

function WgBadge:SetDescription(desc)
	if self.wg_img then
		self.wg_img.GetWargonString = function()
			return Util:SplitSentence(desc, nil, true)
		end
	end
	if self.wg_btn then
		self.wg_btn.GetWargonString = function()
			return Util:SplitSentence(desc, nil, true)
		end
	end
end

function WgBadge:OnUpdate(dt)
-- 	local rate = self.owner.components.sanity:GetRate()
	
-- 	local small_down = .02
-- 	local med_down = .1
-- 	local large_down = .3
-- 	local small_up = .01
-- 	local med_up = .1
-- 	local large_up = .2
-- 	local anim = nil
-- 	anim = "neutral"
-- 	if rate > 0 and self.owner.components.sanity:GetPercent(true) < 1 then
-- 		if rate > large_up then
-- 			anim = "arrow_loop_increase_most"
-- 		elseif rate > med_up then
-- 			anim = "arrow_loop_increase_more"
-- 		elseif rate > small_up then
-- 			anim = "arrow_loop_increase"
-- 		end
-- 	elseif rate < 0 and self.owner.components.sanity:GetPercent(true) > 0 then
-- 		if rate < -large_down then
-- 			anim = "arrow_loop_decrease_most"
-- 		elseif rate < -med_down then
-- 			anim = "arrow_loop_decrease_more"
-- 		elseif rate < -small_down then
-- 			anim = "arrow_loop_decrease"
-- 		end
-- 	end
	
-- 	if anim and self.arrowdir ~= anim then
-- 		self.arrowdir = anim
-- 		self.sanityarrow:GetAnimState():PlayAnimation(anim, true)
-- 	end
	
end

function WgBadge:SetOwner(owner)
	self.owner = owner
end

-- function WgBadge:GetId()
-- 	return self.id
-- end

return WgBadge

--[[
GetPlayer():DoTaskInTime(.5, function() 
	local c = TheInput:GetHUDEntityUnderMouse();
	print(c)
	if c then
		print(c.widget)
		print(c.widget.parent)
		print(c.widget.parent.GetWargonString)
	end
end)
]]