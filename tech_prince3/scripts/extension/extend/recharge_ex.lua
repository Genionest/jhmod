-- 冷却ui
local UIAnim = require "widgets/uianim"
AddClassPostConstruct("widgets/itemtile", function(self)
	if self.recharge_fix then return end self.recharge_fix = true
	-- 冷却ui
	if self.item.components.wg_recharge then
		self.wg_recharge_frame = self:AddChild(UIAnim())
		self.wg_recharge_frame:GetAnimState():SetBank("recharge_meter_wargon")
		self.wg_recharge_frame:GetAnimState():SetBuild("recharge_meter_wargon")
		self.wg_recharge_frame:GetAnimState():PlayAnimation("frame")
		self.wg_recharge_frame:Hide()

		self.wg_recharge = self:AddChild(UIAnim())
		self.wg_recharge:GetAnimState():SetBank("recharge_meter_wargon")
		self.wg_recharge:GetAnimState():SetBuild("recharge_meter_wargon")
		self.wg_recharge:SetClickable(false)

		self.inst:ListenForEvent("wg_recharge_delta", function(item, data)
			self:SetWgRechargePercent(data.per)
		end, self.item)
	end
	function self:SetWgRechargePercent(p)
		if p < 1 then
			self.wg_recharge:GetAnimState():SetPercent("recharge", p)
			local owner = self.item.components.inventoryitem:GetGrandOwner()
			if self.item and owner.components.inventory 
			and not self.item == owner.components.inventory.activeitem then
				self.wg_recharge_frame:Show()
			end
		else
			if not self.wg_recharge:GetAnimState():IsCurrentAnimation("frame_pst") then
				self.wg_recharge:GetAnimState():PlayAnimation("frame_pst")
			end
			self.wg_recharge_frame:Hide()
		end
	end
	local old_fn = self.StartDrag
	function self:StartDrag(...)
		old_fn(self, ...)
		if self.wg_recharge then
			self.wg_recharge:Hide()
		end
		if self.wg_recharge_frame then
			self.wg_recharge_frame:Hide()
		end
	end
end)

-- 对于一些公用的cd
AddPlayerPostInit(function(inst)
	inst:AddComponent("wg_recharge_manager")
end)