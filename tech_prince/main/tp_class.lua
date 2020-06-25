local Badge = require "widgets/badge"

local MadBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "beaver_meter", owner)
end)

AddClassPostConstruct("widgets/statusdisplays", function(self)
	self.madvalue = self:AddChild(MadBadge(self.owner))
    self.madvalue:SetPosition(-80, -115, 0)
    self.madvalue:SetPercent(self.owner.components.tpmadvalue:GetPercent(), 
    	self.owner.components.tpmadvalue.max)
    self.inst:ListenForEvent("tp_madvalue_delta", function(inst, data)
    	self:MadValueDelta(data)
    end, self.owner)

    function self:MadValueDelta(data)
    	self.madvalue:SetPercent(data.new_per, self.owner.components.tpmadvalue.max) 
		if not data.no_flash then
			if data.new_per > data.old_per then
				self.madvalue:PulseGreen()
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_up")
			elseif data.new_per < data.old_per then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_down")
				self.madvalue:PulseRed()
			end
		end
    end
end)

AddClassPostConstruct("widgets/itemtile", function(self)
	local UIAnim = require "widgets/uianim"
	if self.item.components.tprecharge then
		self.tp_recharge_frame = self:AddChild(UIAnim())
		self.tp_recharge_frame:GetAnimState():SetBank("recharge_meter")
		self.tp_recharge_frame:GetAnimState():SetBuild("recharge_meter_wargon")
		self.tp_recharge_frame:GetAnimState():PlayAnimation("frame")
		self.tp_recharge_frame:Hide()

		self.tp_recharge = self:AddChild(UIAnim())
		self.tp_recharge:GetAnimState():SetBank("recharge_meter")
		self.tp_recharge:GetAnimState():SetBuild("recharge_meter_wargon")
		self.tp_recharge:SetClickable(false)

		self.inst:ListenForEvent("tp_recharge_change", function(item, data)
			self:SetTpRechargePercent(data.per)
		end, self.item)
	end
	if self.item.components.tpbullets then
		self:SetQuantity(self.item.components.tpbullets:GetNum())
		self.inst:ListenForEvent("tp_bullet_change", function(item, data)
			self:SetQuantity(self.item.components.tpbullets:GetNum())
			self:ScaleTo(self.basescale*2, self.basescale, .25)
		end, self.item)
	end
	function self:SetTpRechargePercent(p)
		if p < 1 then
			self.tp_recharge:GetAnimState():SetPercent("recharge", p)
			local owner = self.item.components.inventoryitem:GetGrandOwner()
			if self.item and not self.item == owner.components.inventory.activeitem then
				self.tp_recharge_frame:Show()
			end
		else
			if not self.tp_recharge:GetAnimState():IsCurrentAnimation("frame_pst") then
				self.tp_recharge:GetAnimState():PlayAnimation("frame_pst")
			end
			-- if self.tp_recharge_frame.shown then
			-- end
			self.tp_recharge_frame:Hide()
		end
	end
	local old_fn = self.StartDrag
	function self:StartDrag(...)
		old_fn(self, ...)
		if self.tp_recharge then
			self.tp_recharge:Hide()
		end
		if self.tp_recharge_frame then
			self.tp_recharge_frame:Hide()
		end
	end
end)