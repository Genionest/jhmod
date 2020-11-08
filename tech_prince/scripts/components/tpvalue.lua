local TpValue = Class(function(self, inst)
	self.inst = inst
	self.max = 100
	self.current = self.max
	self.rate = 1
	self.period = 1
	self.task = WARGON.per_task(self.inst, self.period, function()
		self:DoDelta(-self.rate)
	end)
end)

function TpValue:DoDelta(delta)
	local old = self.current
	self.current = math.max(0, math.min(self.max, self.current+delta))
	-- print("TpValue current", self.current)
	if self.current > 0 and old <= 0 then
		if self.income then
			self.income(self.inst)
		end
	end
	if self.current <= 0 and old > 0 then
		if self.run_out then
			self.run_out(self.inst)
		end
	end
	if self.current <= 0 then
		if self.empty then
			self.empty(self.inst)
		end
	end
	if self.current > 0 then
		if self.have then
			self.have(self.inst)
		end
	end
	if self.current > old then
		if self.up then
			self.up(self.inst)
		end
	end
	if self.current < old then
		if self.down then
			self.down(self.inst)
		end
	end
	-- print('TpValue', self.current)
	self.inst:PushEvent("tp_value_delta", {
		old_p = old/self.max,
		new_p = self.current/self.max,
	})
end

function TpValue:Start()
	if self.task == nil then
		self.task = WARGON.per_task(self.inst, self.period, function()
			self:DoDelta(-self.rate)
		end)
		print("TpValue Start")
	end
end

function TpValue:Stop()
	if self.task then
		self.task:Cancel()
		self.task = nil
		print("TpValue Stop")
	end
end

function TpValue:IsEmpty()
	return self.current <= 0
end

function TpValue:SetMax(max)
	self.max = max
	self.current = self.max
end

function TpValue:SetPercent(p)
	local dt = p*self.max - self.current
	self:DoDelta(dt)
end

function TpValue:SetRate(rate, period)
	self.rate = rate
	if self.period then
		self.period = period
	end
end

function TpValue:OnSave()
	return {current=self.current}
end

function TpValue:OnLoad(data)
	if data and data.current then
		self.current = data.current
		self:DoDelta(0)
	end
end

return TpValue