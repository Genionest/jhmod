local TpBuff = Class(function(self, inst)
	self.inst = inst
	self.buff = {}
	self.timer = {}
	self.fxs = {}
	self.tasks = {}
	-- WARGON.per_task(inst, 1, function()
	-- 	self:GetInfo()
	-- end)
end)

local buff_tbl = WARGON.DATA.tp_data_buff.buffs
local buff_manager = WARGON.DATA.tp_data_buff.buff_manager

function TpBuff:GetInfo()
	for k, v in pairs(self.buff) do
		for k1, v1 in pairs(v) do
			-- print("tpbuff", k, k1, v1)
		end
	end
end

function TpBuff:NoBuff()
	local empty = true
	for k, v in pairs(self.buff) do
		if k then
			empty = false
		end
	end
	return empty
end

function TpBuff:DoneBuff(reason)
	if self.buff[reason].task then
		self.buff[reason].task:Cancel()
		self.buff[reason].task = nil
	end
	self.buff[reason].left = nil
	-- local fn = buff_tbl[reason].rm
	-- fn(self.inst, self)
	buff_manager:call_buff_rm(reason, self.inst, self)
	self.inst:PushEvent("tp_done_buff", {buff=reason})
end

function TpBuff:AddBuff(reason, time)
	-- if buff_tbl[reason] == nil then
	-- 	return
	-- end
	if buff_manager:get_buff(reason) == nil then
		return
	end
	if self.buff[reason] == nil then
		self.buff[reason] = {}
	end
	local add_buff = self.buff[reason]
	-- local buff_time = time or buff_tbl[reason].time
	local buff_time = time or buff_manager:get_buff_time(reason)
	-- local debuff = buff_tbl[reason].debuff
	-- if debuff and self.inst.components.tplevel then
	-- 	local mult = self.inst.components.tplevel.attr.nature
	-- 	buff_time = mult * buff_time
	-- end
	add_buff.left = buff_time + GetTime()
	if add_buff.task then
		add_buff.task:Cancel()
	end
	-- local fn = buff_tbl[reason].add
	-- fn(self.inst, self)
	buff_manager:call_buff_add(reason, self.inst, self)
	add_buff.task = WARGON.do_task(self.inst, buff_time, function()
		self:DoneBuff(reason)
	end)
	-- local buff_img = buff_tbl[reason].img
	-- local is_debuff = buff_tbl[reason].debuff
	local buff_img = buff_manager:get_buff_img_table(reason)
	local is_debuff = buff_manager:is_debuff(reason)
	self.inst:PushEvent("tp_add_buff", {
		buff=reason, img=buff_img, time=buff_time, debuff=is_debuff,
	})
end

function TpBuff:HasBuff(reason)
	return self.buff[reason] ~= nil
end

function TpBuff:OnSave()
	local save = {}
	for k, v in pairs(self.buff) do
		if v.task then
			save[k] = v.left - GetTime()
		end
	end
	return save
end

function TpBuff:OnLoad(data)
	if data then
		for k, v in pairs(data) do
			self:AddBuff(k, v)
		end
	end
end

return TpBuff