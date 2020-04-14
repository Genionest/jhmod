local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local ManaBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "beaver_meter", owner)
	
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

	self:StartUpdating()
end)

function ManaBadge:SetPercent(val, max, penaltypercent)
	Badge.SetPercent(self, val, max)

	penaltypercent = penaltypercent or 0
	self.topperanim:GetAnimState():SetPercent("anim", 1-penaltypercent)
end

function ManaBadge:OnUpdate(dt)
	local rate = self.owner.components.monkeymana:GetRate()
	
	local small_down = 1
	local med_down = 2
	local large_down = 3
	local small_up = 1
	local med_up = 2
	local large_up = 3
	local anim = nil
	anim = "neutral"
	if rate > 0 and self.owner.components.monkeymana:GetPercent() < 1 then
		if rate >= large_up then
			anim = "arrow_loop_increase_most"
		elseif rate >= med_up then
			anim = "arrow_loop_increase_more"
		elseif rate >= small_up then
			anim = "arrow_loop_increase"
		end
	elseif rate < 0 and self.owner.components.monkeymana:GetPercent() > 0 then
		if rate <= -large_down then
			anim = "arrow_loop_decrease_most"
		elseif rate <= -med_down then
			anim = "arrow_loop_decrease_more"
		elseif rate <= -small_down then
			anim = "arrow_loop_decrease"
		end
	end
	
	if anim and self.arrowdir ~= anim then
		self.arrowdir = anim
		self.sanityarrow:GetAnimState():PlayAnimation(anim, true)
	end
	
end

return ManaBadge