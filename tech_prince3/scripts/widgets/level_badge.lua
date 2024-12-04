local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local Image = require "widgets/image"

local LevelBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "", owner)
	
	self.sanityarrow = self.underNumber:AddChild(UIAnim())
	self.sanityarrow:GetAnimState():SetBank("sanity_arrow")
	self.sanityarrow:GetAnimState():SetBuild("sanity_arrow")
	self.sanityarrow:GetAnimState():PlayAnimation("neutral")
	self.sanityarrow:SetClickable(false)

	self.topperanim = self.underNumber:AddChild(UIAnim())
	self.topperanim:GetAnimState():SetBank("effigy_topper")
	self.topperanim:GetAnimState():SetBuild("effigy_topper")
	-- self.topperanim:GetAnimState():PlayAnimation("anim")
	self.topperanim:SetClickable(false)

	self.bg = self.anim:AddChild(Image(
		"images/inventoryimages/badge_bg.xml", "badge_bg.tex"
	))
	self.bg:SetTint(135/255, 206/255, 235/255, 1)

	self.img = self.anim:AddChild(Image(
		"images/inventoryimages.xml", "accomplishment_shrine.tex"
	))
	self.img:SetScale(.6, .6, .6)
end)

function LevelBadge:SetPercent(val, max, penaltypercent)
	Badge.SetPercent(self, val, max)
	-- val是百分比

	-- penaltypercent = penaltypercent or 0
	penaltypercent = 1-val
	self.topperanim:GetAnimState():SetPercent("anim", penaltypercent)
end

return LevelBadge