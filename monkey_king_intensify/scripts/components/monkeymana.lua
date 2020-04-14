local MonkeyMana = Class(function(self, inst)
	self.inst = inst
	self.max = 100
	self.current = self.max

	self.period = 1
	self.rate = 1
	self.task = self.inst:DoPeriodicTask(self.period, function(inst)
		self:DoDelta(self.rate, true)
	end)
end)

function MonkeyMana:OnSave()
	return {
		current = self.current,
		rate = self.rate,
	}
end

function MonkeyMana:OnLoad(data)
	if data.current then
		self.current = data.current
		self:DoDelta(0)
	end
	if data.rate then
		self.rate = data.rate
	end
end

function MonkeyMana:DoDelta(amount, overtime)
	local old = self.current
	self.current = self.current + amount
	if self.current < 0 then
		self.current = 0
	elseif self.current > self.max then
		self.current = self.max
	end

	self.inst:PushEvent("monkey_mana_delta", {
			oldpercent = old/self.max, 
			newpercent = self.current/self.max,
			overtime = overtime,
		})
end

function MonkeyMana:EnoughMana(amount)
	if self:GetCurrent() >= amount then
		self:DoDelta(-amount)
		return true
	else
		return false
	end
end

function MonkeyMana:GetPercent()
	return self.current / self.max
end

function MonkeyMana:SetPercent(p)
	local old = self.current
	self.current = p * self.max
	self.inst:PushEvent("monkey_mana_delta", {
		oldpercent = old/self.max,
		newpercent = p,
	})
end

function MonkeyMana:GetRate()
	return self.rate
end

function MonkeyMana:SetRate(rate)
	self.rate = rate
end

function MonkeyMana:GetCurrent()
	return self.current
end

function MonkeyMana:GetMax()
	return self.max
end

function MonkeyMana:SetMax(amount)
	self.max = amount
	self.current = amount
end

function MonkeyMana:GetDebugString()
	return string.format("%2.2f / %2.2f at %2.2f", self.current, self.max, self.rate)
end

return MonkeyMana