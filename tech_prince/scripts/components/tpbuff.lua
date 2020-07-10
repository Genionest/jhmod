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
		time = 30,
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
	scroll_pig_armorex = {
		time = 50,
		add = function(inst)
			inst.components.health.absorb = .8
			if inst.scroll_pig_armorex_fx == nil then
				inst.scroll_pig_armorex_fx = SpawnPrefab('tp_fx_scroll_pig_buff')
				inst.scroll_pig_armorex_fx.fx_name = "tp_fx_scroll_pig_armorex"
				inst:AddChild(inst.scroll_pig_armorex_fx)
				inst.scroll_pig_armorex_fx.Transform:SetPosition(0,0,0)
			end
		end,
		rm = function(inst)
			inst.components.health.absorb = 0
			if inst.scroll_pig_armorex_fx then
				inst.scroll_pig_armorex_fx:Remove()
				inst.scroll_pig_armorex_fx = nil
			end
		end,
	},
	scroll_pig_damage = {
		time = 50,
		add = function(inst)
			inst.components.combat:AddDamageModifier('scroll_pig_damage', 1)
			if inst.scroll_pig_damage_fx == nil then
				inst.scroll_pig_damage_fx = SpawnPrefab('tp_fx_scroll_pig_buff')
				inst.scroll_pig_damage_fx.fx_name = 'tp_fx_scroll_pig_damage'
				inst:AddChild(inst.scroll_pig_damage_fx)
				inst.scroll_pig_damage_fx.Transform:SetPosition(0,0,0)
			end
		end,
		rm = function(inst)
			inst.components.combat:RemoveDamageModifier('scroll_pig_damage')
			if inst.scroll_pig_damage_fx then
				inst.scroll_pig_damage_fx:Remove()
				inst.scroll_pig_damage_fx = nil
			end
		end,
	},
	scroll_pig_speed = {
		time = 50,
		add = function(inst)
			inst.components.locomotor:AddSpeedModifier_Mult('scroll_pig_speed', .5)
			if inst.scroll_pig_speed_fx == nil then
				inst.scroll_pig_speed_fx = SpawnPrefab('tp_fx_scroll_pig_buff')
				inst.scroll_pig_speed_fx.fx_name = 'tp_fx_scroll_pig_speed'
				inst:AddChild(inst.scroll_pig_speed_fx)
				inst.scroll_pig_speed_fx.Transform:SetPosition(0,0,0)
			end
		end,
		rm = function(inst)
			inst.components.locomotor:RemoveSpeedModifier_Mult('scroll_pig_speed')
			if inst.scroll_pig_speed_fx then
				inst.scroll_pig_speed_fx:Remove()
				inst.scroll_pig_speed_fx = nil
			end
		end,
	},
	scroll_pig_heal = {
		time = 50,
		add = function(inst)
			inst.components.health:DoDelta(500)
			inst.components.health:StartRegen(50, 1)
			if inst.scroll_pig_heal_fx == nil then
				inst.scroll_pig_heal_fx = SpawnPrefab('tp_fx_scroll_pig_buff')
				inst.scroll_pig_heal_fx.fx_name = 'tp_fx_scroll_pig_heal'
				inst:AddChild(inst.scroll_pig_heal_fx)
				inst.scroll_pig_heal_fx.Transform:SetPosition(0,0,0)
			end
		end,
		rm = function(inst)
			inst.components.health:StopRegen()
			if inst.scroll_pig_heal_fx then
				inst.scroll_pig_heal_fx:Remove()
				inst.scroll_pig_heal_fx = nil
			end
		end,
	},
	scroll_pig_health = {
		time = 180,
		add = function(inst)
			inst.components.health:SetMaxHealth(600)
			inst.components.health:DoDelta(0)
			if inst.scroll_pig_health_fx == nil then
				inst.scroll_pig_health_fx = SpawnPrefab('tp_fx_scroll_pig_buff')
				inst.scroll_pig_health_fx.fx_name = 'tp_fx_scroll_pig_health'
				inst:AddChild(inst.scroll_pig_health_fx)
				inst.scroll_pig_health_fx.Transform:SetPosition(0,0,0)
			end
		end,
		rm = function(inst)
			local cur = inst.components.health.currenthealth
			local max_hp = 350
			if inst:HasTag("werepig") then
				max_hp = 450
			end
			inst.components.health:SetMaxHealth(max_hp)
			inst.components.health.currenthealth = cur
			inst.components.health:DoDelta(0)
			if inst.scroll_pig_health_fx then
				inst.scroll_pig_health_fx:Remove()
				inst.scroll_pig_health_fx = nil
			end
		end,
	},
}

function TpBuff:GetInfo()
	for k, v in pairs(self.buff) do
		for k1, v1 in pairs(v) do
			-- print("tpbuff", k, k1, v1)
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