local EquipValue = Class(function(self, inst)
	self.inst = inst
	self.max = 100
	self.current = 0
    self.period = 1
    self.rate = 1
    -- 装备时显示装备充能
    self.inst:ListenForEvent("equipped", function()
        self:DoDelta(0)
    end)
end)

function EquipValue:Calc(dt)
    self:DoDelta(-self.rate*dt)
    if self.current <= 0 then
        self:Stop()
    end
end

function EquipValue:DoDelta(delta)
	local old = self.current
	self.current = math.max(0, math.min(self.max, self.current+delta))
	self.inst:PushEvent("tp_equip_value_delta", {
		old_p = old/self.max,
		new_p = self.current/self.max,
	})
end

function EquipValue:IsFull()
	return self.current >= self.max
end

function EquipValue:GetCost()
	return self.max - self.current
end

function EquipValue:IsEmpty()
	return self.current <= 0
end

function EquipValue:SetRate(rate, period)
    self.rate = rate
    self.period = period or 1
end

function EquipValue:SetValue(amount)
    self.current = amount
    self:DoDelta(0)
end

function EquipValue:SetMax(max)
    self.max = max
end

function EquipValue:Start()
    -- self.runing = true
    if self.task == nil then
        self.runing = true 
        self.task = self.inst:DoPeriodicTask(self.period, function()
            self:DoDelta(-self.rate)
            if self.current <= 0 then
                self:Stop()
            end
        end)
    end
end

function EquipValue:Stop(owner)
    self.inst:PushEvent("tp_equip_value_stop")
    owner = owner or (self.inst.components.equippable and self.inst.components.equippable.owner)
    if self.stop then
        self.stop(self.inst, owner)
    end
    self.runing = nil
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function EquipValue:Runout()
    self:DoDelta(-self.current)
    self:Stop()
end

function EquipValue:SetPercent(p)
	local dt = p*self.max - self.current
	self:DoDelta(dt)
end

function EquipValue:GetPercent()
	return self.current/self.max
end

function EquipValue:OnSave()
	return {
        current=self.current,
        -- max = self.max,
        runing = self.runing,
    }
end

function EquipValue:OnLoad(data)
	if data then
		self.current = data.current or 0
        -- self.max = data.max or 100
        if data.runing then
            self:Start()
        end
	end
end

function EquipValue:GetWargonString()
    local s = string.format("装备能量:%d/%d", self.current, self.max)
    if self.runing then
        s = s..string.format(",衰减速度:%d/%ds", self.rate, self.period)
    end
    return s
end

function EquipValue:GetWargonStringColour()
    return {1, .3, .3, 1}
end

return EquipValue