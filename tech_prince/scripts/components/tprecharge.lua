local TpRecharge = Class(function(self, inst)
	self.inst = inst
	self.current = 0
	self.max = 255
	self.is_recharge = true
	self:Start()
end)

function TpRecharge:IsRecharged()
	return self.is_recharge
end

function TpRecharge:Start()
	self.is_recharge = false
	if self.task == nil then
		self.task = WARGON.per_task(self.inst, .1, function()
			self:DoDelta(.1)
		end)
	end
end

function TpRecharge:Stop()
	self.is_recharge = true
	if self.task then
		self.task:Cancel()
		self.task = nil
	end
end

function TpRecharge:GetPercent()
	return math.min(1, self.current/self.max)
end

function TpRecharge:DoDelta(dt)
	local current = self.current + dt
	self.current = math.max(0, math.min(self.max, current))
	self.inst:PushEvent("tp_recharge_change", {per = current / self.max})
	if self.current >= self.max then
		self:Stop()
	end
end

function TpRecharge:SetRechargeTime(max)
	self.max = max or self.max
	self.current = 0
	self:Start()
end

function TpRecharge:OnSave()
	return {cur = self.current}
end

function TpRecharge:OnLoad(data)
	if data and data.cur then
		self.current = data.cur
	end
end

return TpRecharge