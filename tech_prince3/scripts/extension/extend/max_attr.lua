local Util = require "extension.lib.wg_util"

-- 添加最大生命值的提升，缺损
-- Hook SetInvicible可以由多个开关维持无敌状态
local health_meta = nil
local function fn(self)
	if self.max_attr_fix then return end self.max_attr_fix = true
	rawset(self, "maxhealth", nil)
	rawset(self, "absorb", nil)
	self.wg_max_health = 100
	self.wg_max_health_buff = 0
	self.wg_max_health_mods = {}
	self.wg_max_health_rate = 1
	self.wg_max_health_mult = {}
	
	self.wg_absorb = 0
	self.wg_absorb_buff = 0
	self.wg_absorb_mods = {}
	
	self.wg_penalty_mods = {}
	function self:WgAddMaxHealthModifier(key, mod, save_p)
		local p = self:GetPercent()
		self.wg_max_health_mods[key] = mod
		self.wg_max_health_buff = self:WgGetMaxHealthModifier()
		if save_p then
			self:SetPercent(p)
		else
			self:DoDelta(0, true)
		end
	end
	function self:WgRemoveMaxHealthModifier(key, save_p, no_delta)
		if self.wg_max_health_mods[key] then
			local p = self:GetPercent()
			self.wg_max_health_mods[key] = nil
			self.wg_max_health_buff = self:WgGetMaxHealthModifier()
			if save_p then
				self:SetPercent(p)
			elseif not no_delta then
				self:DoDelta(0, true)
			end
		end
	end
	function self:WgGetMaxHealthModifier()
		local mod = 0
		for k, v in pairs(self.wg_max_health_mods) do
			mod = mod + v
		end
		return mod
	end
	function self:WgAddMaxHealthMultiplier(key, mod, save_p)
		local p = self:GetPercent()
		self.wg_max_health_mult[key] = mod
		self.wg_max_health_rate = self:WgGetMaxHealthMultiplier()
		if save_p then
			self:SetPercent(p)
		else
			self:DoDelta(0, true)
		end
	end
	function self:WgRemoveMaxHealthMultiplier(key, save_p, no_delta)
		if self.wg_max_health_mult[key] then
			local p = self:GetPercent()
			self.wg_max_health_mult[key] = nil
			self.wg_max_health_rate = self:WgGetMaxHealthMultiplier()
			if save_p then
				self:SetPercent(p)
			elseif not no_delta then
				self:DoDelta(0, true)
			end
		end
	end
	function self:WgGetMaxHealthMultiplier()
		local mult = 1
		for k, v in pairs(self.wg_max_health_mult) do
			mult = mult + v
		end
		return mult
	end
	local SetMaxHealth = self.SetMaxHealth
	-- 如果这里amount比实际最大生命值小，就不会是满血，需要修复
	function self:SetMaxHealth(amount)
		SetMaxHealth(self, amount)
		self:SetPercent(1)
	end
	
	function self:WgAddAbsorbModifier(key, mod)
		self.wg_absorb_mods[key] = mod
		self.wg_absorb_buff = self:WgGetAbsorbModifier()
	end
	function self:WgRemoveAbsorbModifier(key, mod)
		self.wg_absorb_mods[key] = nil
		self.wg_absorb_buff = self:WgGetAbsorbModifier()
	end
	function self:WgGetAbsorbModifier()
		local mod = 0
		for k, v in pairs(self.wg_absorb_mods) do
			mod = mod + v
		end
		-- if self.inst:HasTag("armor_broken") then
		-- 	mod = mod/2
		-- end
		if mod > .9 then
			mod = .9
		end
		return mod
	end
	
	function self:WgAddHealthPenaltyModifier(key, mod)
		self.wg_penalty_mods[key] = mod
		self:RecalculatePenalty()
	end
	function self:WgRemoveHealthPenaltyModifier(key)
		if self.wg_penalty_mods[key] then
			self.wg_penalty_mods[key] = nil
		end
		self:RecalculatePenalty()
	end
	function self:WgGetHealthPenaltyModifier()
		local mod = 0
		for k, v in pairs(self.wg_penalty_mods) do
			mod = mod + v
		end
		return mod
	end
	local RecalculatePenalty = self.RecalculatePenalty
	function self:RecalculatePenalty(...)
		RecalculatePenalty(self, ...)
		self.penalty = self.penalty + self:WgGetHealthPenaltyModifier()
		self:DoDelta(0, nil, "resurrection_penalty")
	end
	
	self.wg_invincible_cause = {}
	local SetInvincible = self.SetInvincible
	function self:SetInvincible(val, cause)
		cause = cause or "health"
		self.wg_invincible_cause[cause] = val
		local is_invincible = false
		if val then
			is_invincible = true
		else
			for k, v in pairs(self.wg_invincible_cause) do
				if v then 
					is_invincible = true 
					break
				end
			end
		end
		SetInvincible(self, is_invincible)
	end
	
	-- 回复倍率
	local DoDelta = self.DoDelta
	function self:DoDelta(amount, overtime, cause, ...)
		if self.tp_recover then
			if amount > 0 then
				amount = math.max(0, amount + self.tp_recover*amount)
			end
		end
		DoDelta(self, amount, overtime, cause, ...)
	end
	function self:AddRecoverRateMod(key, mod)
		if self.tp_recover_mods == nil then
			self.tp_recover_mods = {}
		end
		self.tp_recover_mods[key] = mod
		self.tp_recover = self:GetRecoverRate()
	end
	function self:RmRecoverRateMod(key)
		if self.tp_recover_mods then
			self.tp_recover_mods[key] = nil
			self.tp_recover = self:GetRecoverRate()
		end
	end
	function self:GetRecoverRate()
		if self.tp_recover_mods then
			local mod = 0
			for k, v in pairs(self.tp_recover_mods) do
				mod = mod + v
			end
			mod = math.max(mod, -.99)
			return mod
		end
	end
	
	local OnSave = self.OnSave
	function self:OnSave()
		local data = OnSave(self)
		data.save_p = self:GetPercent()
		return data
	end
	local OnLoad = self.OnLoad
	function self:OnLoad(data)
		OnLoad(self, data)
		if data.save_p then
			self:SetPercent(data.save_p, "file_load")
			self:DoDelta(0)
		end
	end
	
	-- function self:GetWargonString()
	-- 	-- local mod = self:WgGetMaxHealthModifier()
	-- 	-- local mult = self:WgGetMaxHealthMultiplier()
	-- 	local recover = self.tp_recover or 0
	-- 	-- local s = string.format("生命加成:+%d,生命比例:%d%%,额外回复:%d%%", 
	-- 	-- 	mod, mult*100, recover*100)
	-- 	local s = string.format("生命:%d/%d,回复:%+d%%", 
	-- 		self.currenthealth, self:GetMaxHealth(), recover*100)
	-- 	s = Util:SplitSentence(s, 17, true)
	-- 	return s
	-- end
	
	-- function self:GetWargonStringColour()
	-- 	return {124/255, 252/255, 0/255, 1}
	-- end
	
	-- 不能直接修改，需要获取原来class的元表
	-- 不重复获取元表和修改元表
	if health_meta then
		return 
	end
	health_meta = true
	local c = getmetatable(self)
	local c_index = c.__index
	local c_newindex = c.__newindex
	c.__newindex = function(t, k, val)
		if k == "maxhealth" then
			return rawset(t, "wg_max_health", val)
		elseif k == "absorb" then
			return rawset(t, "wg_absorb", val)
		else
			return (c_newindex or rawset)(t, k, val)
		end
	end
	c.__index = function(t, k)
		if k == "maxhealth" then
			local amount = (rawget(t, "wg_max_health") or 0)
			local mod = (rawget(t, "wg_max_health_buff") or 0)
			local rate = (rawget(t, "wg_max_health_rate") or 0)
			return (amount+mod)*rate
		elseif k == "absorb" then
			local amount = (rawget(t, "wg_absorb") or 0) +
				(rawget(t, "wg_absorb_buff") or 0)
			amount = math.max(0, math.min(.99, amount))
			return amount
		else
			if type(c_index) == "table" then
				return c_index[k]
			else
				return (c_index or rawget)(t, k)
			end
		end
	end
end
AddComponentPostInit("health", fn)

-- 添加最大理智值的提升，缺损
local sanity_meta = false
local function fn(self)
	if self.max_attr_fix then return end self.max_attr_fix = true
	rawset(self, "max", nil)
	self.wg_max = 100
	self.wg_max_buff = 0
	self.wg_max_sanity_mods = {}
	
	self.wg_penalty_mods = {}
	
	self.wg_negative_buff = 0
	self.wg_negative_mods = {}
	self.wg_night_drain_mult = 1
	self.wg_neg_aura_mult = 1
	
	function self:WgAddMaxSanityModifier(key, mod, save_p)
		local p = self:GetPercent()
		self.wg_max_sanity_mods[key] = mod
		self.wg_max_buff = self:WgGetMaxSanityModifier()
		if save_p then
			self:SetPercent(p)
		else
			self:DoDelta(0, true)
		end
	end
	function self:WgRemoveMaxSanityModifier(key, save_p, no_delta)
		if self.wg_max_sanity_mods[key] then
			local p = self:GetPercent()
			self.wg_max_sanity_mods[key] = nil
			self.wg_max_buff = self:WgGetMaxSanityModifier()
			if save_p then
				self:SetPercent(p)
			elseif not no_delta then
				self:DoDelta(0, true)
			end
		end
	end
	function self:WgGetMaxSanityModifier()
		local mod = 0
		for k, v in pairs(self.wg_max_sanity_mods) do
			mod = mod + v
		end
		return mod
	end
	function self:WgAddSanityPenaltyModifier(key, mod)
		self.wg_penalty_mods[key] = mod
		self:RecalculatePenalty()
	end
	function self:WgRemoveSanityPenaltyModifier(key)
		if self.wg_penalty_mods[key] then
			self.wg_penalty_mods[key] = nil
		end
		self:RecalculatePenalty()
	end
	function self:WgGetSanityPenaltyModifier()
		local mod = 0
		for k, v in pairs(self.wg_penalty_mods) do
			mod = mod + v
		end
		return mod
	end
	local RecalculatePenalty = self.RecalculatePenalty
	function self:RecalculatePenalty(...)
		RecalculatePenalty(self, ...)
		self.penalty = self.penalty + self:WgGetSanityPenaltyModifier()
		self:DoDelta(0)
	end
	function self:WgAddNegativeModifier(key, mod)
		self.wg_negative_mods[key] = mod
		self.wg_negative_buff = self:WgGetNegativeModifier()
	end
	function self:WgRemoveNegativeModifier(key)
		self.wg_negative_mods[key] = nil
		self.wg_negative_buff = self:WgGetNegativeModifier()
	end
	function self:WgGetNegativeModifier()
		local mod = 0
		for k, v in pairs(self.wg_negative_mods) do
			mod = mod + v
		end
		return mod
	end
	
	local OnSave = self.OnSave
	function self:OnSave()
		local data = OnSave(self)
		data.save_p = self:GetPercent()
		return data
	end
	local OnLoad = self.OnLoad
	function self:OnLoad(data)
		OnLoad(self, data)
		if data.save_p then
			self:SetPercent(data.save_p)
			self:DoDelta(0)
		end
	end
	
	-- function self:GetWargonString()
	-- 	local s = string.format("理智:%d/%d", 
	-- 		self.current, self:GetMaxSanity())
	-- 	s = Util:SplitSentence(s, 17, true)
	-- 	return s
	-- end
	
	-- function self:GetWargonStringColour()
	-- 	return {124/255, 252/255, 0/255, 1}
	-- end
	
	-- 不能直接修改，需要获取原来class的元表
	-- 不重复获取元表和修改元表
	if sanity_meta then
		return 
	end
	sanity_meta = true
	local c = getmetatable(self)
	local c_index = c.__index
	local c_newindex = c.__newindex
	c.__newindex = function(t, k, val)
		if k == "max" and val then
			return rawset(t, "wg_max", val)
		elseif k == "night_drain_mult" and val then
			return rawset(t, "wg_night_drain_mult", val)
		else
			return (c_newindex or rawset)(t, k, val)
		end
	end
	c.__index = function(t, k)
		if k == "max" then
			return (rawget(t, "wg_max") or 0) +
				(rawget(t, "wg_max_buff") or 0)
		elseif k == "night_drain_mult" then
			local rate = (rawget(t, "wg_night_drain_mult") or 0) +
				(rawget(t, "wg_negative_buff") or 0)
			return math.max(.1, rate)
		elseif k == "neg_aura_mult" then
			local rate = (rawget(t, "wg_neg_aura_mult") or 0) +
				(rawget(t, "wg_negative_buff") or 0)
			return math.max(.1, rate)
		else
			if type(c_index) == "table" then
				return c_index[k]
			else
				return (c_index or rawget)(t, k)
			end
		end
	end
end
AddComponentPostInit("sanity", fn)

-- 添加最大饥饿值的提升，缺损
local hunger_meta = false
local function fn(self)
	if self.max_attr_fix then return end self.max_attr_fix = true
	rawset(self, "max", nil)
	self.wg_max = 100
	self.wg_max_buff = 0
	self.wg_max_hunger_mods = {}
	function self:WgAddMaxHungerModifier(key, mod, save_p)
		local p = self:GetPercent()
		self.wg_max_hunger_mods[key] = mod
		self.wg_max_buff = self:WgGetMaxHungerModifier()
		if save_p then
			self:SetPercent(p)
		else
			self:DoDelta(0, true)
		end
	end
	function self:WgRemoveMaxHungerModifier(key, save_p, no_delta)
		if self.wg_max_hunger_mods[key] then
			local p = self:GetPercent()
			self.wg_max_hunger_mods[key] = nil
			self.wg_max_buff = self:WgGetMaxHungerModifier()
			if save_p then
				self:SetPercent(p)
			elseif not no_delta then
				self:DoDelta(0, true)
			end
		end
	end
	function self:WgGetMaxHungerModifier()
		local mod = 0
		for k, v in pairs(self.wg_max_hunger_mods) do
			mod = mod + v
		end
		return mod
	end
	function self:GetMaxHunger()
		return self.max
	end
	
	local OnSave = self.OnSave
	function self:OnSave()
		local data = OnSave(self) or {}
		data.save_p = self:GetPercent()
		return data
	end
	local OnLoad = self.OnLoad
	function self:OnLoad(data)
		OnLoad(self, data)
		if data.save_p then
			self:SetPercent(data.save_p)
			self:DoDelta(0)
		end
	end
	
	-- function self:GetWargonString()
	-- 	local s = string.format("饥饿:%d/%d", 
	-- 		self.current, self.max)
	-- 	s = Util:SplitSentence(s, 17, true)
	-- 	return s
	-- end
	
	-- function self:GetWargonStringColour()
	-- 	return {124/255, 252/255, 0/255, 1}
	-- end
	
	-- 不能直接修改，需要获取原来class的元表
	-- 不重复获取元表和修改元表
	if hunger_meta then
		return 
	end
	hunger_meta = true
	local c = getmetatable(self)
	local c_index = c.__index
	local c_newindex = c.__newindex
	c.__newindex = function(t, k, val)
		if k == "max" and val then
			return rawset(t, "wg_max", val)
		else
			return (c_newindex or rawset)(t, k, val)
		end
	end
	c.__index = function(t, k)
		if k == "max" then
			return (rawget(t, "wg_max") or 0) +
				(rawget(t, "wg_max_buff") or 0)
		else
			if type(c_index) == "table" then
				return c_index[k]
			else
				return (c_index or rawget)(t, k)
			end
		end
	end
end
AddComponentPostInit("hunger", fn)