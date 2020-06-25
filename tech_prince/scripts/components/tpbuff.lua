local TpBuff = Class(function(self, inst)
	self.inst = inst
	self.buff = {}
	self.timer = {}
	WARGON.per_task(inst, 1, function()
		self:GetInfo()
	end)
end)

local buff_tbl = {
	tp_ballhat = {
		time = 10,
		add = function(inst)
			inst.components.combat:AddDamageModifier("tp_ballhat", .2)
			if inst.tp_ballhat_fx == nil then
				inst.tp_ballhat_fx = WARGON.make_fx(inst, "tp_fx_alive_sparklefx", true)
			end
		end,	
		rm = function(inst)
			inst.components.combat:RemoveDamageModifier("tp_ballhat")
			if inst.tp_ballhat_fx then
				inst.tp_ballhat_fx:Remove()
				inst.tp_ballhat_fx = nil
			end
		end,
	},
}

function TpBuff:GetInfo()
	for k, v in pairs(self.buff) do
		for k1, v1 in pairs(v) do
			print("tpbuff", k, k1, v1)
		end
	end
end

function TpBuff:DoneBuff(reason)
	self.buff[reason].task = nil
	self.buff[reason].left = nil
	local fn = buff_tbl[reason].rm
	fn(self.inst)
end

function TpBuff:AddBuff(reason, time)
	if self.buff[reason] == nil then
		self.buff[reason] = {}
	end
	local add_buff = self.buff[reason]
	local buff_time = time or buff_tbl[reason].time
	add_buff.left = buff_time + GetTime()
	if add_buff.task then
		add_buff.task:Cancel()
	end
	local fn = buff_tbl[reason].add
	fn(self.inst)
	add_buff.task = WARGON.do_task(self.inst, buff_time, function()
		self:DoneBuff(reason)
	end)
end

function TpBuff:GetBuff(reason)
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