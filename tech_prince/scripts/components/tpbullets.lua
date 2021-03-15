local TpBullets = Class(function(self, inst)
	self.inst = inst
	self.max = 20
	-- self.cur = 0
	self.cur = 0
	self.bullets = {}
end)

function TpBullets:GetBullet()
	return self.cur > 0 and self.bullets[self.cur] or nil
end

function TpBullets:SetMax(max)
	self.max = max
end

function TpBullets:GetNum()
	return self.cur
end

function TpBullets:IsFull()
	return self.cur >= self.max
end

function TpBullets:Add(amount, bullet)
	local old = self.cur
	local num = amount
	if old <= 0 then
		if self.take_fn then
			self.take_fn(self.inst)
		end
	end
	-- self.cur = math.max(0, math.min(self.cur+num, self.max))
	for i = 1, amount do
		if self.cur >= self.max then
			break
		end
		self.cur = self.cur + 1
		self.bullets[self.cur] = bullet
	end
	-- if self.cur <= 0 then
	-- 	if self.lose_fn then
	-- 		self.lose_fn(self.inst)
	-- 	end
	-- end
	local current = self:GetBullet()
	if self.change_fn then
		self.change_fn(self.inst, current)
	end
	self.inst:PushEvent("tp_bullet_change", {current=current})
	print("TpBullets", current)
end

function TpBullets:Lose(amount)
	for i = 1, amount do
		if self.cur <= 0 then
			break
		end
		self.bullets[self.cur] = nil
		self.cur = self.cur - 1
	end
	if self.cur <= 0 then
		if self.lose_fn then
			self.lose_fn(self.inst)
		end
	end
	local current = self:GetBullet()
	if self.change_fn then
		self.change_fn(self.inst, current)
	end
	self.inst:PushEvent("tp_bullet_change", {current=current})
	print("TpBullets", current)
end

function TpBullets:OnSave()
	return {
		-- cur = self.cur, 
		bullets = self.bullets,
	}
end

function TpBullets:OnLoad(data)
	-- if data and data.cur then
		-- self:DoDelta(data.cur)
	-- end
	if data and data.bullets then
		local bullets = data.bullets or {}
		for k, v in pairs(bullets) do
			self:Add(1, v)
		end
	end
end

return TpBullets