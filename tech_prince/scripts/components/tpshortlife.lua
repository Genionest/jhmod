local TpShortLife = Class(function(self, inst)
    self.inst = inst
    self.left_time = 1
    self.use_time = 0
end)

function TpShortLife:Start()
    self.task = self.inst:do_task(self.left_time, function(inst)
        if inst.components.health then
            inst.components.health:Kill()
        else
            inst:Remove()
        end
    end)
end

function TpShortLife:SetTime(time)
    self.use_time = self:GetTime()
    self.left_time = time
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
    self:Start()
end

function TpShortLife:GetTime()
    return self.left_time + self.use_time - inst:GetTimeAlive()
end

function TpShortLife:OnSave()
    local time = self:GetTime()
    return {
        time = time
    }
end

function TpShortLife:OnLoad(data)
    if data.time then
        self:SetTime(data.time)
    end
end

return TpShortLife