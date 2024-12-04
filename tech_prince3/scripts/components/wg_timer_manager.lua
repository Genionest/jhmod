local BuffManager = Sample.BuffManager
local SmearManager = Sample.SmearManager

local WgTimerManager = Class(function(self, inst)
    self.inst = inst
    self.buff_mgr = {}
    self.smear_mgr = {}
end)

function WgTimerManager:CalculateTime(dt)
    for pref, buff_timer in pairs(self.buff_mgr) do
        for buff_id, time in pairs(buff_timer) do
            local new_time = math.max(0, time-dt)
            local cmp =  pref.components.wg_simple_buff
            if cmp.forever_buffs[buff_id] then
                new_time = 100
            end
            self.buff_mgr[pref][buff_id] = new_time
            if new_time <= 0 then
                local buff_data = BuffManager:GetDataById(buff_id)
                if buff_data:IsFadeOut() then
                    if cmp.stacks[buff_id] and cmp.stacks[buff_id] > 1 then
                        -- 层层消退时
                        local on_fade = buff_data.handler.on_fade
                        if on_fade then
                            on_fade(buff_data, cmp.inst, cmp, buff_id)
                        end
                        new_time = buff_data.time or 0
                        self.buff_mgr[pref][buff_id] = new_time
                        cmp:SetBuffStack(buff_id, cmp.stacks[buff_id] - 1)
                        return
                    end
                end
                cmp:ClearBuff(buff_id)
            end
        end
    end
    for pref, smear_timer in pairs(self.smear_mgr) do
        for smear_id, time in pairs(smear_timer) do
            local cmp =  pref.components.tp_smearable
            local new_time = math.max(0, time-dt)
            self.smear_mgr[pref][smear_id] = new_time
            if new_time <= 0 then
                cmp:Clear(smear_id)
            end
        end
    end
end

function WgTimerManager:SetBuffTime(pref, buff_id, time)
    if self.buff_mgr[pref] == nil then
        self.buff_mgr[pref] = {}
    end
    self.buff_mgr[pref][buff_id] = time
end

function WgTimerManager:GetBuffTime(pref, buff_id)
    return self.buff_mgr[pref] and self.buff_mgr[pref][buff_id] or 0
end

function WgTimerManager:RemoveBuffTimer(pref)
    if self.buff_mgr and self.buff_mgr[pref] then
        self.buff_mgr[pref] = nil
    end
end

function WgTimerManager:SetSmearTime(pref, smear_id, time)
    if self.smear_mgr[pref] == nil then
        self.smear_mgr[pref] = {}
    end
    self.smear_mgr[pref][smear_id] = time
end

function WgTimerManager:GetSmearTime(pref, smear_id)
    return self.smear_mgr[pref] and self.smear_mgr[pref][smear_id] or 0
end

function WgTimerManager:RemoveSmearTimer(pref)
    if self.smear_mgr and self.smear_mgr[pref] then
        self.smear_mgr[pref] = nil
    end
end

function WgTimerManager:OnUpdate(dt)
	self:CalculateTime(dt)
end

function WgTimerManager:Start()
	self.inst:StartUpdatingComponent(self)
end

function WgTimerManager:Stop()
	self.inst:StopUpdatingComponent(self)
end

-- function WgTimerManager:AddBuff(pref, buff, time)
--     if not self.buff_mgr[pref] then
--         self.buff_mgr[pref] = {}
--         self.buff_mgr[pref][buff] = time
--     end
-- end

return WgTimerManager