local attr_tbl = {
	health = 100,
	sanity = 100,
	hunger = 100,
	damage = -.25,
	speed  = -.1,
	eater  = .9,
	hungry = .1,
	absorb = -.1,
	horror = 1.1,
	nature = 1.1,
	forge  = 0,
	madval = 100,
	lucky  = 0,
	attack_period = 0,
}

local TpLevel = Class(function(self, inst)
	self.inst = inst
	self.level = 1
	self.max = 10
	self.exp = 0
	self.gifted = false
	self.gifted2 = false
	self.gifted3 = false

	self.cur_lv = 0
	self.attr = attr_tbl
end)

function TpLevel:Apply(is_load, old_save)
	local inst = self.inst
	if self.attr.health then
		-- print("TpLevel", 1, self.attr.health)
		if not is_load then
			inst.components.health:SetPercent(1)
		end
		inst.components.health:SetMaxHealth(self.attr.health)
		inst.components.health:DoDelta(0)
	end
	if self.attr.hunger then
		-- print("TpLevel", 2, self.attr.hunger)
		if not is_load then
			inst.components.hunger:SetPercent(1)
		end
		inst.components.hunger:SetMax(self.attr.hunger)
		inst.components.hunger:DoDelta(0)
	end
	if self.attr.sanity then
		-- print("TpLevel", 3, self.attr.sanity)
		if not is_load then
			inst.components.sanity:SetPercent(1)
		end
		inst.components.sanity:SetMax(self.attr.sanity)
		inst.components.sanity:DoDelta(0)
	end
	if self.attr.damage then
		-- print("TpLevel", 4, self.attr.damage)
		inst.components.combat:AddDamageModifier("tplevel", self.attr.damage)
	end
	if self.attr.speed then
		-- print("TpLevel", 5, self.attr.speed)
		inst.components.locomotor:AddSpeedModifier_Mult("tplevel", self.attr.speed)
		if old_save then
			WARGON.do_task(self.inst, 0, function()
				-- inst.components.talker:Say("重载")
				inst.components.locomotor:AddSpeedModifier_Mult("tplevel", self.attr.speed)
			end)
		end	
	end
	if self.attr.eater then
		-- print("TpLevel", 6, self.attr.speed)
		local rate = self.attr.eater
		inst.components.eater:SetAbsorptionModifiers(math.sqrt(rate), rate, rate)
	end
	if self.attr.hungry then
		-- print("TpLevel", 7, self.attr.hungry)
		inst.components.hunger:AddBurnRateModifier("tplevel", self.attr.hungry)
	end
	if self.attr.horror then
		-- print("TpLevel", 9, self.attr.horror)
		inst.components.sanity.night_drain_mult = self.attr.horror
	    inst.components.sanity.neg_aura_mult = self.attr.horror
	end
	if self.attr.forge then
		-- print("TpLevel",11, self.attr.forge)
	end
	if self.attr.madval then
		-- print("TpLevel",12, self.attr.madval)
		if inst.components.tpmadvalue then
			inst.components.tpmadvalue:SetMax(self.attr.madval)
		end
	end
	if self.attr.attack_period then
		local rate = -self.attr.attack_period/100
		inst.components.combat:AddPeriodModifier("tplevel", rate)
		-- if old_save then
		-- 	WARGON.do_task(self.inst, 0, function()
		-- 		inst.components.combat:SetAttackPeriod("tplevel", rate)
		-- 	end)
		-- end	
	end
	if inst.components.tpbody then
		if self.attr.absorb then
			-- print("TpLevel", 8, self.attr.absorb)
			-- inst.components.tpbody.absorb = self.attr.absorb
			inst.components.tpbody:AddAbsorbModifier("tplevel", self.attr.absorb)
		end
		if self.attr.nature then
			-- print("TpLevel",10, self.attr.nature)
			-- inst.components.health.fire_damage_scale = self.attr.nature
			inst.components.tpbody.fire = self.attr.nature
			inst.components.health.poison_damage_scale = self.attr.nature
			inst.components.health.gas_damage_scale = self.attr.nature
		end
		if self.attr.lucky then
			inst.components.tpbody.lucky = self.attr.lucky
		end
	end
end

function TpLevel:GetLevel()
	return self.cur_lv
end

function TpLevel:LevelUp(level)
	self.cur_lv = self.cur_lv+level
end

function TpLevel:OnSave()
	return {
		level = self.level, 
		exp = self.exp, 
		gifted2 = self.gifted2,
		gifted3 = self.gifted3,
		cur_lv = self.cur_lv,
		attr = self.attr,
	}
end

function TpLevel:OnLoad(data)
	if data then
		self.cur_lv = data.cur_lv or 0
		local old_save = false
		if data.attr == nil then
			old_save = true
		end
		-- self.attr = data.attr or attr_tbl
		for k, v in pairs(data.attr) do
			self.attr[k] = v
		end
		self:Apply(true, old_save)
	end
end

function TpLevel:GetEssence()
	return self.inst.components.inventory:Count("tp_epic")
end

return TpLevel