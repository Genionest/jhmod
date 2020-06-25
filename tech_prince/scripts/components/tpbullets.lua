local TpBullets = Class(function(self, inst)
	self.inst = inst
	self.max = 20
	self.cur = 0
end)

function TpBullets:SetMax(max)
	self.max = max
end

function TpBullets:GetNum()
	return self.cur
end

function TpBullets:IsFull()
	return self.cur >= self.max
end

function TpBullets:DoDelta(amount)
	local old = self.cur
	local num = amount
	if old <= 0 then
		if self.take_fn then
			self.take_fn(self.inst)
		end
	end
	self.cur = math.max(0, math.min(self.cur+num, self.max))
	if self.cur <= 0 then
		if self.lose_fn then
			self.lose_fn(self.inst)
		end
	end
	self.inst:PushEvent("tp_bullet_change")
end

function TpBullets:OnSave()
	return {cur = self.cur}
end

function TpBullets:OnLoad(data)
	if data and data.cur then
		self:DoDelta(data.cur)
	end
end

return TpBullets