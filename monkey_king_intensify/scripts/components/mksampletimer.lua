local SampleTimer = Class(function(self, inst)
	self.inst = inst
	self.max = 10
	self.current = self.max
	self.name = "sample"
	inst:DoPeriodicTask(1, function()
		self:DoDelta(1)
	end)
end)

function SampleTimer:GetCurrent()
	return self.current
end

function SampleTimer:GetPercent()
	return self.current/self.max
end

function SampleTimer:SetPercent(p)
	p = math.min(1, math.max(0, p))
	self.current = self.max * p
	self.inst:PushEvent("mk_timer_delta", {
			percent = self.current/self.max,
			name = self.name,
		})
	print("mk_"..self.name.." setpercent", self.current/self.max)
	print("mk_"..self.name.." push event", self.current/self.max)
end

function SampleTimer:DoDelta(amount)
	local old = self.current
	self.current = old + amount
	self.current = math.min(self.max, math.max(0, self.current))
	self.inst:PushEvent("mk_timer_delta", {
			percent = self.current/self.max,
			name = self.name,
		})
	print("mk_"..self.name.." dodelta")
	print("mk_"..self.name.." push event", self.current/self.max)
end

function SampleTimer:OnSave()
	return {current = self.current}
end

function SampleTimer:OnLoad(data)
	if data.current then
		self.current = data.current
		self:DoDelta(0)
	end
end

return SampleTimer