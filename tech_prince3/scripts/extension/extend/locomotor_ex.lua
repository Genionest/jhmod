local function fn(self)
    local GetSpeedMultiplier = self.GetSpeedMultiplier
    -- 至少为0
    function self:GetSpeedMultiplier(...)
        return math.max(0.01, GetSpeedMultiplier(self, ...))
    end
    -- 防止放技能时乱动
    local GetWalkSpeed = self.GetWalkSpeed
    function self:GetWalkSpeed()
        if self.wg_no_speed then
            return 0
        end
        return GetWalkSpeed(self)
    end
    local GetRunSpeed = self.GetRunSpeed
    function self:GetRunSpeed(...)
        if self.wg_no_speed then
            return 0
        end
        return GetRunSpeed(self, ...)
    end
    function self:AddNoSpeedMark()
        -- 不想额外的被SetMotorVel
        if self.wg_no_speed == nil then
            self.wg_no_speed = 1
        else
            self.wg_no_speed = self.wg_no_speed + 1
        end
    end
    function self:RemoveNoSpeedMark()
        if self.wg_no_speed then
            self.wg_no_speed = self.wg_no_speed - 1
            if self.wg_no_speed <= 0 then
                self.wg_no_speed = nil
            end
        end
    end
    local StopMoving = self.StopMoving
    function self:StopMoving(...)
        -- 不想被Stop()
        if self.inst:HasTag("not_stop_moving") then
            self.isrunning = false
            self.slowing = false 
        else
            return StopMoving(self, ...)
        end
    end
end
AddComponentPostInit("locomotor", fn)