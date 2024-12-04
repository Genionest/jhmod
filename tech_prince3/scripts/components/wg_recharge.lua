local WgRecharge = Class(function(self, inst)
	self.inst = inst
	self.current = 100
	self.max = 100
	self.is_recharge = true
	self:Start()
end)

function WgRecharge:OnRemoveEntity()
	if self.manager then
		self.manager:RemoveItem(self.inst, self.group)
	end
end

function WgRecharge:SetCommon(group)
	if self.manager == nil then
		self.manager = GetPlayer().components.wg_recharge_manager
		self.manager:AddItem(self.inst, group)
		self.group = group
		self.common = true
	end
end

function WgRecharge:IsRecharged()
	return self.is_recharge
end

-- 冷却缩减作用于SetRechargeTime，减少max的值
function WgRecharge:GetRechargeModifier()
	local mod = 1
	if self.inst.components.inventoryitem then
		local owner= self.inst.components.inventoryitem.owner
		if owner and owner.get_recharge_mod  then
			local rate = owner:get_recharge_mod() or 0
			mod = mod - rate
		end
	end
	return mod
end

function WgRecharge:Start()
	self.is_recharge = false
	if self.task == nil and self.manager == nil then
		self.task = self.inst:DoPeriodicTask(.1, function()
			local dt = .07
			self:DoDelta(dt)
		end)
	end
end

function WgRecharge:Stop()
	self.is_recharge = true
	if self.task then
		self.task:Cancel()
		self.task = nil
	end
	if self.on_recharged then
		self.on_recharged(self.inst)
	end
	self.inst:PushEvent("wg_recharged")
end

function WgRecharge:GetPercent()
	return math.min(1, (self.current)/self.max)
	-- return math.min(1, (self.max-self.current)/self.max)
end

function WgRecharge:DoDelta(dt)
	local current = self.current + dt
	self.current = math.max(0, math.min(self.max, current))
	self.inst:PushEvent("wg_recharge_delta", {per = current / self.max})
	if self.current >= self.max then
	-- if self.current <= 0 then
		self:Stop()
	end
end

function WgRecharge:SetRechargeTime(max, group)
	if group and self.manager then
		self.manager:SetRechargeTime(group, max)
	end
	local amount = max or self.max
	self.max = amount * self:GetRechargeModifier()
	self.current = 0
	-- self.current = max
	self:Start()
end

function WgRecharge:OnSave()
	return {
		cur = self.current,
		max = self.max,
	}
end

function WgRecharge:OnLoad(data)
	if data then
		self.current = data.cur or 100
		self.max = data.max or 100
		-- self:SetRechargeTime(data.cur)
	end
end

function WgRecharge:GetWargonString()
	local s = string.format("冷却时间:%.1fs", self.max-self.current )
	if not self.common then
		s = s.."(不共享冷却)"
	end
	return s
end

function WgRecharge:GetWargonStringColour()
	return {.3, 1, 1, 1}
end

return WgRecharge