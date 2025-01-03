local Info = Sample.Info

-- 增加函数方便攻击时进行更多的操作WgAddWeaponAttackFn/WgAddPreWeaponAttackFn
-- 增加函数方便修改伤害WgAddWeaponDamageFn
local function fn(self)
	if self.wg_fix then return end self.wg_fix = true
	
	local OnAttack = self.OnAttack
	function self:OnAttack(...)
		if self.wg_pre_attack_fns then
			for k, v in pairs(self.wg_pre_attack_fns) do
				v(self.inst, ...)
			end	
		end
		OnAttack(self, ...)
		if self.wg_attack_fns then
			for k, v in pairs(self.wg_attack_fns) do
				v(self.inst, ...)
			end	
		end
	end
	function self:WgAddWeaponAttackFn(fn)
		if self.wg_attack_fns == nil then
			self.wg_attack_fns = {}
		end
		table.insert(self.wg_attack_fns, fn)
		return fn
	end
	function self:WgRemoveWeaponAttackFn(fn)
		local tbl = self.wg_attack_fns
		if tbl then
			for k, v in pairs(tbl) do
				if fn == v then
					table.remove(tbl, k)
				end
			end
		end
	end
	function self:WgAddPreWeaponAttackFn(fn)
		if self.wg_pre_attack_fns == nil then
			self.wg_pre_attack_fns = {}
		end
		table.insert(self.wg_pre_attack_fns, fn)
	end
	-- 伤害获取
	local GetDamage = self.GetDamage
	function self:GetDamage()
		local dmg = GetDamage(self)
		if self.weapon_dmg_buff then
			dmg = dmg + self.weapon_dmg_buff
		end
		if self.wg_damage_fns then
			for k, v in pairs(self.wg_damage_fns) do
				dmg = v(self.inst, dmg)
			end
		end
		return dmg
	end
	function self:WgAddWeaponDamageFn(fn)
		if self.wg_damage_fns == nil then
			self.wg_damage_fns = {}
		end
		table.insert(self.wg_damage_fns, fn)
	end
	-- 攻击力修改
	function self:AddWeaponDmgMod(key, val)
		if self.weapon_dmg_mod == nil then
			self.weapon_dmg_mod = {}
		end
		self.weapon_dmg_mod[key] = val
		self.weapon_dmg_buff = self:GetWeaponDmgMod()
	end
	function self:RmWeaponDmgMod(key)
		if self.weapon_dmg_mod then
			self.weapon_dmg_mod[key] = nil
			self.weapon_dmg_buff = self:GetWeaponDmgMod()
			if self.weapon_dmg_buff == 0 then
				self.weapon_dmg_mod = nil
				self.weapon_dmg_buff = nil
			end
		end
	end
	function self:GetWeaponDmgMod()
		local val = 0
		if self.weapon_dmg_mod then
			for k, v in pairs(self.weapon_dmg_mod) do
				val = val + v
			end
		end
		return val
	end
	-- 伤害类型
	self.dmg_type = nil
	-- 精力消耗
	self.cost_vigor = nil
	function self:SetDmgType(dmg_type)
		self.dmg_type = dmg_type
	end
	function self:SetAttackCostVigor(cost_vigor)
		self.cost_vigor = cost_vigor
	end
	
	function self:GetWargonString()
		local dmg = self:GetDamage()
		local s = string.format("攻击:%d", dmg)
		if self.weapon_dmg_buff then
			s = s .. string.format("{%+d}", self.weapon_dmg_buff)
		end
		s = s..string.format("(%s)", 
			STRINGS.TP_DMG_TYPE[self.dmg_type] or "无")
		if self.cost_vigor then
			s = s .. string.format("耗精:%.1f,", self.cost_vigor)
		end
		return s
	end
	function self:GetWargonStringColour()
		return {255/255, 60/255, 0/255, 1}
	end
end
AddComponentPostInit("weapon", fn)