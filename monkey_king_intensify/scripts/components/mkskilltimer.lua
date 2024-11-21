-- local timer_tbl = {
-- 	morph = 20,
-- 	monkey = 20,
-- 	back = 10,
-- 	cloud = 200,
-- 	jgbsp = 60,
-- 	frozen = 50,
-- 	-- coldf = 200,
-- 	firef = 200,
-- 	war = 200,
-- }

local SkillTimer = Class(function(self, inst)
	self.inst = inst
	self.max = {}
	self.current = {}
	inst:DoPeriodicTask(1, function()
		self:DoDelta(1)
	end)
end)

function SkillTimer:AddTimer(k, max)
	self.max[k] = max
	self.current[k] = self.max[k]
end

function SkillTimer:GetPercent(k)
	local p = self.current[k]/self.max[k]
	-- print("skilltimer getpercent:", k, p)
	return p
end

function SkillTimer:SetPercent(k, p)
	p = math.max(0, math.min(1, p))
	self.current[k] = self.max[k] * p
	-- print("skilltimer setpercent:", k, p)
	self.inst:PushEvent("mk_skill_delta", {
			percent = p,
			name = k
		})
end

function SkillTimer:DoDelta(amount)
	for k, v in pairs(self.current) do
		self.current[k] = self.current[k] + amount
		-- self.current[k] = math.max(0, math.min(self.max[k], self.current[k]))
		if self.current[k] < 0 then
			self.current[k] = 0
		elseif self.current[k] > self.max[k] then
			self.current[k] = self.max[k]
		end
		local p = self.current[k]/self.max[k]
		-- print("skilltimer dodelta:", k, self.current[k], self.max[k])
		self.inst:PushEvent("mk_skill_delta", {
				percent = p,
				name = k
			})
	end
end

function SkillTimer:OnSave()
	return {current = self.current}
end

function SkillTimer:OnLoad(data)
	-- print("skilltimer onload")
	if data.current then
		self.current = data.current or {}
		-- for k, v in pairs(self.max) do
		-- 	self.current[k] = data.current[k] or self.max[k]
		-- end
	end
end

return SkillTimer