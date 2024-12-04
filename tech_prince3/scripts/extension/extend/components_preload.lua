--[[
让component有机会使用OnPreLoad
]]
Sample.listener = {}
Sample.task = {}
AddGlobalClassPostConstruct("entityscript", "EntityScript", function(self)
    local SetPersistData = self.SetPersistData
    function self:SetPersistData(data, newents)
        if data then
            for k,v in pairs(data) do
                local cmp = self.components[k]
                if cmp and cmp.OnPreLoad then
                    cmp:OnPreLoad(v, newents)
                end
            end
        end
        SetPersistData(self, data, newents)
    end
    local ListenForEvent = self.ListenForEvent
    function self:ListenForEvent(...)
        ListenForEvent(self, ...)
        if Sample.listener[self] == nil then
            Sample.listener[self] = 0
        end
        Sample.listener[self] = Sample.listener[self]+1
    end
    local RemoveEventCallback = self.RemoveEventCallback
    function self:RemoveEventCallback(...)
        RemoveEventCallback(self, ...)
        if Sample.listener[self] then
            Sample.listener[self] = Sample.listener[self]-1
        end
    end
    local DoTaskInTime = self.DoTaskInTime
    function self:DoTaskInTime(...)
        if Sample.task[self] == nil then
            Sample.task[self] = 0
        end
        Sample.task[self] = Sample.task[self]+1
        local per = DoTaskInTime(self, ...)
        per.inst = self
        return per
    end
    local DoPeriodicTask = self.DoPeriodicTask
    function self:DoPeriodicTask(...)
        if Sample.task[self] == nil then
            Sample.task[self] = 0
        end
        Sample.task[self] = Sample.task[self]+1
        local per = DoPeriodicTask(self, ...)
        per.inst = self
        return per
    end
end)

AddGlobalClassPostConstruct("scheduler", "Periodic", function(self)
    local Cancel = self.Cancel
    function self:Cancel()
        Cancel(self)
        if Sample.task[self.inst] then
            Sample.task[self.inst] = Sample.task[self.inst]-1
        end
    end
end)