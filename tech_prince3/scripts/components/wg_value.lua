local WgValue = Class(function(self, inst)
	self.inst = inst
	self.max = 100
	self.current = self:GetMax()
	self.rate = 1
	self.period = 1
	self.temp = 0
	self.event = "wg_value_delta"
	self.delta_fns = nil
	self.t_max_mod = nil
	self.max_mods = nil
end)

function WgValue:AddDeltaFn(fn)
	if self.delta_fns == nil then
		self.delta_fns = {}
		table.insert(self.delta_fns, fn)
	end
end

function WgValue:DoDelta(delta)
	local old = self:GetCurrent()
	self.current = math.max(0, math.min(self:GetMax(), self:GetCurrent()+delta))
	-- print("WgValue current", self:GetCurrent())
	if self.delta_fns then
		for k, v in pairs(self.delta_fns) do
			v(self, delta, old)
		end
	end
	self.inst:PushEvent(self.event, {
		old_p = old/self:GetMax(),
		new_p = self:GetCurrent()/self:GetMax(),
		-- delta = old-self:GetCurrent(),
	})
end

function WgValue:Start()
	if self.task == nil then
		self.task = self.inst:DoPeriodicTask(self.period, function()
			-- 满足消耗条件
			if self.test == nil or self.test(self.inst) then
				self:DoDelta(-self.rate)
				-- 推送消耗事件
				if self.consume_event then
					self.inst:PushEvent(self.consume_event)
				end
				-- 执行消耗函数
				if self.consume then
					self.consume(self.inst)
				end
				-- 执行消耗运行函数
				if self.run_start then
					if self.running == nil then
						self.running = true
						self.run_start(self.inst)
						-- self.inst:PushEvent(self.running_event.."_start")
					end
				end
			else
				-- 停止消耗运行函数
				if self.run_stop then
					if self.running then
						self.running = nil
						self.run_stop(self.inst)
						-- self.inst:PushEvent(self.running_event.."_stop")
					end
				end
			end
		end)
		-- print("WgValue Start")
	end
end

function WgValue:Stop()
	if self.task then
		self.task:Cancel()
		self.task = nil
		if self.run_stop then
			if self.running then
				self.inst:DoTaskInTime(0, function()
					self.running = nil
					self.run_stop(self.inst)
					-- self.inst:PushEvent(self.running_event.."_stop")
				end)
			end
		end
	end
end

function WgValue:IsFull()
	return self:GetCurrent() >= self:GetMax()
end

function WgValue:GetCost()
	return self:GetMax() - self:GetCurrent()
end

function WgValue:IsEmpty()
	return self:GetCurrent() <= 0
end

function WgValue:SetMax(max)
	self.max = max
	self.current = self:GetMax()
end

function WgValue:GetMax()
	local max = self.max
	if self.t_max_mod then
		max = max + self.t_max_mod
	end
	return max
end

function WgValue:AddMaxMod(key, mod)
	if self.max_mods == nil then
		self.max_mods = {}
	end
	self.max_mods[key] = mod
	self.t_max_mod = self:GetMaxMods()
	self:DoDelta(0)
end

function WgValue:RmMaxMod(key)
	if self.max_mods then
		self.max_mods[key] = nil
	end
	self.t_max_mod = self:GetMaxMods()
	self:DoDelta(0)
end

function WgValue:GetMaxMods()
	local max = 0
	if self.max_mods then
		for k, v in pairs(self.max_mods) do
			max = max + v
		end
	end
	return self.t_max_mod
end

function WgValue:GetCurrent()
	return self.current
end

function WgValue:SetPercent(p)
	local dt = p*self:GetMax() - self:GetCurrent()
	self:DoDelta(dt)
end

function WgValue:GetPercent()
	return self:GetCurrent()/self:GetMax()
end

function WgValue:SetRate(rate, period)
	self.rate = rate
	if period then
		self.period = period
	end
end

function WgValue:OnSave()
	return {current=self:GetCurrent()}
end

function WgValue:OnLoad(data)
	if data and data.current then
		self.current = data.current
		self:DoDelta(0)
	end
end

-- function WgValue:GetWargonString()
-- 	return string.format("特殊值：%d/%d\n速率：%d，%d", self:GetCurrent(), self:GetMax(), self.period, self.rate)
-- end

return WgValue