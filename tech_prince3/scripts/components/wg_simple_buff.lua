local BuffManager = Sample.BuffManager
local Util = require "extension.lib.wg_util"

local WgSimpleBuff = Class(function(self, inst)
	self.inst = inst
	self.buffs = {}
	-- self.timer = {}
	-- self.max_time_list = {}
	self.forever_buffs = {}
	self.stacks = {}
	-- self.fxs = {}
	-- self.tasks = {}
    self.mgr = nil
	-- self.buff_task = self.inst:DoPeriodicTask(1, function()
	-- 	self:CaculateTime()
	-- end)
	-- self.inst:AddTag("wg_buff")
end)

-- function WgSimpleBuff:OnUpdate(dt)
-- 	self:CaculateTime(dt)
-- end

-- function WgSimpleBuff:Start()
-- 	self.inst:StartUpdatingComponent(self)
-- end

-- function WgSimpleBuff:Stop()
-- 	self.inst:StopUpdatingComponent(self)
-- end

-- function WgSimpleBuff:CaculateTime(dt)
-- 	for k, v in pairs(self.timer) do
-- 		-- self.timer[k] = math.max(0, v-1)
-- 		-- self.inst:PushEvent("wg_buff_time_delta", {
-- 		-- 	id = k,
-- 		-- 	percent = self.timer[k]/self.max_time_list[k],
-- 		-- 	time = self.timer[k],
-- 		-- 	-- max_time = self.max_time_list[k],
-- 		-- })
-- 		local time = math.max(0, v-dt)
-- 		if self.forever_buffs[k] then
-- 			time = 100
-- 		end
-- 		self:SetBuffTime(k, time)
-- 		-- if self.timer[k] <= 0 then
-- 		if time <= 0 then
-- 			local buff_data = BuffManager:GetDataById(k)
-- 			if buff_data:IsFadeOut() then
-- 				if self.stacks[k] and self.stacks[k] > 1 then
-- 					-- 层层消退时
-- 					local on_fade = buff_data.handler.on_fade
-- 					if on_fade then
-- 						on_fade(buff_data, self.inst, self, k)
-- 					end
-- 					local time = buff_data.time or 0
-- 					self:SetBuffTime(k, time)
-- 					self:SetBuffStack(k, self.stacks[k] - 1)
-- 					return
-- 				end
-- 			end
-- 			self:ClearBuff(k)
-- 		end
-- 	end
-- end

function WgSimpleBuff:AddBuff(id, max_time, data)
	local buff_data = BuffManager:GetDataById(id)
	if buff_data:IsDebuff() and self.inst:HasTag("wg_not_debuff") then
		return
	end
	local time = buff_data.time or 0
	local on_add = buff_data.handler.on_add
	if self.buffs[id] == nil then
		self.buffs[id] = true
	else
		-- 重复获得buff时
		on_add = buff_data.handler.on_repeat or on_add
	end
    -- local save_time = self.timer[id] or 0
    self:GetManager()
    local save_time = self.mgr:GetBuffTime(self.inst, id)
    -- 当前存在此buff
	max_time = max_time or 0
	-- 取三个中最大的那个
	time = math.max(time, max_time, save_time)
	if buff_data:IsForever() then
		self.forever_buffs[id] = true
		time = 100
	end
	self:SetBuffTime(id, time)
	-- self.max_time_list[id] = time
	-- 这里的on_add可能是on_repeat
	if on_add then
		on_add(buff_data, self.inst, self, id, data)
	end
	-- self.inst:PushEvent("wg_add_buff", {id = id})
end

function WgSimpleBuff:GetManager()
    self.mgr = self.mgr or GetPlayer().components.wg_timer_manager
    return self.mgr
end

function WgSimpleBuff:SetBuffTime(id, time)
    self:GetManager()
    self.mgr:SetBuffTime(self.inst, id, time)
end

function WgSimpleBuff:SetBuffStack(id, stack)
    self.stacks[id] = stack
	-- if self.stacks[id] then
		-- self.inst:PushEvent("wg_buff_stack_delta", {
		-- 	id = id,
		-- 	stack = stack,
		-- })
	-- end
end

function WgSimpleBuff:ClearBuff(id)
	local buff_data = BuffManager:GetDataById(id)
	local on_rm = buff_data.handler.on_rm
	self.buffs[id] = nil
	-- self.timer[id] = nil
	-- self.max_time_list[id] = nil
	self.forever_buffs[id] = nil
	if on_rm then
		on_rm(buff_data, self.inst, self, id)
	end
	-- 需要mgr把该id下的time清空
	-- self.inst:PushEvent("wg_rm_buff", {id=id})
end

function WgSimpleBuff:ClearAllBuff()
	for k, v in pairs(self.buffs) do
		self:ClearBuff(k)
	end
end

function WgSimpleBuff:ClearAllDebuff()
	for k, v in pairs(self.buffs) do
		local buff_data = BuffManager:GetDataById(k)
		if buff_data:IsDebuff() then
			self:ClearBuff(k)
		end
	end
end

-- function WgSimpleBuff:GetBuffPercent(id)
-- 	if self.timer[id] and self.max_time_list[id] then
-- 		return self.timer[id]/self.max_time_list[id]
-- 	end
-- end

function WgSimpleBuff:GetBuffStack(id)
	return self.stacks[id]
end

function WgSimpleBuff:GetBuffDescription(id)
	local buff_data = BuffManager:GetDataById(id)
	local desc
	if type(buff_data.desc) == "function" then
		desc = buff_data.desc(buff_data, self.inst, self, id)
	else
		desc = buff_data.desc
	end
	desc = Util:SplitSentence(desc, nil, true)
	return desc
end

function WgSimpleBuff:HasBuff(id)
	return self.buffs[id]
end

function WgSimpleBuff:OnRemoveEntity()
	self:ClearAllBuff()
	self:GetManager()
	self.mgr:RemoveBuffTimer(self.inst)
end

function WgSimpleBuff:OnSave()
	local data = {}
	data.buffs = {}
	data.timer = {}
	-- data.max_time_list = {}
	data.stacks = {}
	for k, v in pairs(self.buffs) do
		data.buffs[k] = v
	end
    self:GetManager()
    if self.mgr[self.inst] then
        data.timer = self.mgr[self.inst]
    end
	-- for k, v in pairs(self.timer) do
	-- 	data.timer[k] = v
	-- end
	-- for k, v in pairs(self.max_time_list) do
	-- 	data.max_time_list[k] = v
	-- end
	for k, v in pairs(self.stacks) do
		data.stacks[k] = v
	end
	return data
end

function WgSimpleBuff:OnLoad(data)
	if data then
		data.buffs = data.buffs or {}
		-- data.max_time_list = data.max_time_list or {}
		-- data.timer = data.timer or {}
		data.stacks = data.stacks or {}
        
		-- for k, v in pairs(data.buffs) do
		-- 	self:AddBuff(k, data.max_time_list[k])
		-- end
		-- 在添加buff之后设置时间和层数
        
        -- self:GetManager()  -- SetBuffTime里有这一步
		for k, v in pairs(data.timer) do
			-- self.timer[k] = v
			self:SetBuffTime(k, v)
		end
		for k, v in pairs(self.stacks) do
			self.stacks[k] = v
		end
	end
end

-- function WgSimpleBuff:GetWargonString()
-- 	local str = "BuffTimer:"
-- 	for k, v in pairs(self.timer) do
-- 		local desc = string.format("\n%s(%ds)", k, v)
-- 		str = str..desc
-- 	end
-- 	return str
-- end

return WgSimpleBuff