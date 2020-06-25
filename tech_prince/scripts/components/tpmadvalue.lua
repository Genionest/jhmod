local MadValue = Class(function(self, inst)
	self.inst = inst
	self.max  = 100
	self.current = 0
	-- self:Start()
end)

function MadValue:SetPercent(p)
	local delta = self.max*p - self.current
	self:DoDelta(delta, true)
end

function MadValue:GetPercent()
	return self.current/self.max
end

function MadValue:DoDelta(amount, no_flash)
	local old_per = self.current / self.max
	local cur = self.current + amount
	cur = math.min(self.max, cur)
	cur = math.max(0, cur)
	self.current = cur
	local new_per = cur / self.max
	self.inst:PushEvent("tp_madvalue_delta", {
		old_per = old_per,
		new_per = new_per,
		no_flash = no_flash,
	})
	if self.current == 0 then
		self.inst:PushEvent("tp_madvalue_empty")
	end
end

function MadValue:Start()
	if not self.task then
		self.task = WARGON.per_task(self.inst, 1, function()
			if self.current > 0 then
				self:DoDelta(-1, true)
			end
		end)
	end
end

function MadValue:Stop()
	if self.task then
		self.task:Cancel()
		self.task = nil
	end
end

function MadValue:OnSave()
	return {cur=self.current}
end

function MadValue:OnLoad(data)
	if data then
		if data.cur then self.current = data.cur end
		self:DoDelta(0)
	end
end

return MadValue