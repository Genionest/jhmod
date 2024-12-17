local TpExistTime = Class(function(self, inst)
    self.inst = inst
    self.time = nil
    self.target_time = nil
    self.fn = nil
end)

function TpExistTime:SetTime(time)
    self.time = time
    self.target_time = GetTime() + time
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
    self.task = self.inst:DoTaskInTime(time, function()
        if self.fn then
            self.fn(self.inst)
        end
        self.inst:Remove()
    end)
end

function TpExistTime:GetLeftTime()
    if self.target_time then
        return self.target_time - GetTime()
    end
end

function TpExistTime:OnSave()
    if self.target_time then
        return {
            time = self.target_time - GetTime(),
        }
    end
end

function TpExistTime:OnLoad(data)
    if data then
        self:SetTime(data.time)
    end
end

function TpExistTime:GetWargonString()
    if self.target_time then
        local s = string.format("存在时间:%ds", self.target_time - GetTime())
        return s
    end
end

return TpExistTime