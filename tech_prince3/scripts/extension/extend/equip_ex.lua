local AssetUtil = require "extension/lib/asset_util"
local AssetMaster = Sample.AssetMaster

local cur_ver = 1

local function override(inst, equip, symbol, slot)
	if slot == EQUIPSLOTS.HEAD then
		if equip:HasTag("hat_open") then
			inst.AnimState:Show("HAT")
			inst.AnimState:Hide("HAIR_HAT")
			inst.AnimState:Show("HAIR_NOHAT")
			inst.AnimState:Show("HAIR")
			inst.AnimState:Show("HAIRFRONT")
			inst.AnimState:Show("HEAD")
			inst.AnimState:Hide("HEAD_HAIR")
		else
			inst.AnimState:Show("HAT")
			inst.AnimState:Show("HAIR_HAT")
			inst.AnimState:Hide("HAIR_NOHAT")
			inst.AnimState:Hide("HAIR")
			if inst:HasTag("player") or inst:HasTag("like_player") then
				inst.AnimState:Hide("HEAD")
				inst.AnimState:Show("HEAD_HAIR")
				inst.AnimState:Hide("HAIRFRONT")
			end
		end
	elseif slot == EQUIPSLOTS.HANDS then
		inst.AnimState:Show("ARM_carry")
		inst.AnimState:Hide("ARM_normal")
	end
	local symbol, build, symbol2 = AssetMaster:GetSymbol(symbol)
	inst.AnimState:OverrideSymbol(symbol, build, symbol2)
end

local function clear_override(inst, equip, symbol, slot)
	if slot == EQUIPSLOTS.HEAD then
		inst.AnimState:Hide("HAT")
		inst.AnimState:Hide("HAIR_HAT")
		inst.AnimState:Show("HAIR_NOHAT")
		inst.AnimState:Show("HAIR")
		if inst:HasTag("player") or inst:HasTag("like_player") then
			inst.AnimState:Show("HEAD")
			inst.AnimState:Hide("HEAD_HAIR")
			inst.AnimState:Show("HAIRFRONT")
		end
	elseif slot == EQUIPSLOTS.HANDS then
		inst.AnimState:Hide("ARM_carry")
		inst.AnimState:Show("ARM_normal")
	end
	local symbol, build, symbol2 = AssetMaster:GetSymbol(symbol)
	inst.AnimState:ClearOverrideSymbol(symbol)
end

-- equippable.Usymbol设置后,装备是可以自动修改贴图
local function fn(self)
	if self.equip_fix and cur_ver <= self.equip_fix then
		return
	end
	self.equip_fix = cur_ver
	-- 不能用ListenForEvent的方式自动换贴图，
	-- 装备消失时，贴图不能取消
	
	-- 装备可以提升最大属性
	-- 添加函数方便装备和卸下时进行更多的操作 WgAddEquipFn/WgAddUnequipFn
	-- 添加函数方便对受到攻击时进行的处理 WgAddEquipAttackedFn
	self.wg_not_fix_attr = nil
	self.wg_max_health_mods = nil
	self.wg_max_sanity_mods = nil
	self.wg_max_hunger_mods = nil
	function self:WgAddEquipMaxHealthModifier(key, mod)
		if self.wg_max_health_mods == nil then
			self.wg_max_health_mods = {}
		end
		self.wg_max_health_mods[key] = mod
	end
	function self:WgRemoveEquipMaxHealthModifier(key)
		if self.wg_max_health_mods then
			self.wg_max_health_mods[key] = nil
		end
	end
	function self:WgGetEquipMaxHealthModifer()
		if self.wg_max_health_mods then
			local mod = 0
			for k, v in pairs(self.wg_max_health_mods) do
				mod = mod + v
			end
			return mod
		end
	end
	function self:WgAddEquipMaxSanityModifier(key, mod)
		if self.wg_max_sanity_mods == nil then
			self.wg_max_sanity_mods = {}
		end
		self.wg_max_sanity_mods[key] = mod
	end
	function self:WgRemoveEquipMaxSanityModifier(key)
		if self.wg_max_sanity_mods then
			self.wg_max_sanity_mods[key] = nil
		end
	end
	function self:WgGetEquipMaxSanityModifer()
		if self.wg_max_sanity_mods then
			local mod = 0
			for k, v in pairs(self.wg_max_sanity_mods) do
				mod = mod + v
			end
			return mod
		end
	end
	function self:WgAddEquipMaxHungerModifier(key, mod)
		if self.wg_max_hunger_mods == nil then
			self.wg_max_hunger_mods = {}
		end
		self.wg_max_hunger_mods[key] = mod
	end
	function self:WgRemoveEquipMaxHungerModifier(key)
		if self.wg_max_hunger_mods then
			self.wg_max_hunger_mods[key] = nil
		end
	end
	function self:WgGetEquipMaxHungerModifer()
		if self.wg_max_hunger_mods then
			local mod = 0
			for k, v in pairs(self.wg_max_hunger_mods) do
				mod = mod + v
			end
			return mod
		end
	end
	local Equip = self.Equip
	function self:Equip(owner, slot, ...)
		Equip(self, owner, slot, ...)
		-- 自动换贴图
		if self.symbol then
			override(owner, self.inst, self.symbol, self.equipslot)
		end
		-- 
		local max_health_mod = self:WgGetEquipMaxHealthModifer()
		if max_health_mod then
			if owner.components.health then
				local k = "equipslot_"..self.equipslot
				owner.components.health:WgAddMaxHealthModifier(k, max_health_mod, true)
				-- owner.components.health:WgAddMaxHealthModifier(k, max_health_mod, not self.wg_not_fix_attr)
				-- self.wg_not_fix_attr = nil
			end
		end
		local max_sanity_mod = self:WgGetEquipMaxSanityModifer()
		if max_sanity_mod then
			if owner.components.sanity then
				local k = "equipslot_"..self.equipslot
				owner.components.sanity:WgAddMaxSanityModifier(k, max_sanity_mod, true)
				-- owner.components.sanity:WgAddMaxSanityModifier(k, max_sanity_mod, not self.wg_not_fix_attr)
				-- self.wg_not_fix_attr = nil
			end
		end
		local max_hunger_mod = self:WgGetEquipMaxHungerModifer()
		if max_hunger_mod then
			if owner.components.hunger then
				local k = "equipslot_"..self.equipslot
				owner.components.hunger:WgAddMaxHungerModifier(k, max_hunger_mod, true)
				-- owner.components.hunger:WgAddMaxHungerModifier(k, max_hunger_mod, not self.wg_not_fix_attr)
				-- self.wg_not_fix_attr = nil
			end
		end
		
		if owner.components.combat then
			-- 战斗属性
			local data = self.combat_data
			if data then
				local k = "equipslot_"..self.equipslot
				if data.defense then
					owner.components.combat:AddDefenseMod(k, data.defense)	
				end
				if data.evade then
					owner.components.combat:AddEvadeRateMod(k, data.evade)
				end
				if data.penetrate then
					owner.components.combat:AddPenetrateMod(k, data.penetrate)
				end
				if data.hit_rate then
					owner.components.combat:AddHitRateMod(k, data.hit_rate)
				end
				if data.dmg_mult then
					owner.components.combat:AddDamageModifier(k, data.dmg_mult)
				end
				if data.crit then
					owner.components.combat:AddCritRateMod(k, data.crit)
				end
				if data.attack_speed then
					owner.components.combat:AddPeriodModifier(k, data.attack_speed)
				end
				if data.recover_rate then
					owner.components.combat:AddRecoverRateMod(k, data.recover_rate)
				end
				if data.add_speed then
					owner.components.locomotor:AddSpeedModifier_Additive(k, data.add_speed)
				end
			end
			-- 各类型伤害吸收
			local data = self.dmg_resist
			if data then
				-- local k = "equipslot_"..self.equipslot
				for k2, v2 in pairs(data) do
					owner.components.combat:AddDmgTypeAbsorb(k2, v2)
				end
			end
		end
		-- 人物属性
		if owner.components.tp_player_attr then
			local data = self.attr_data
			if data then
				local k = "equipslot_"..self.equipslot
				for k2, v2 in pairs(data) do
					owner.components.tp_player_attr:AddAttrMod(k, k2, v2)
				end
			end
		end
		if self.wg_equip_fns then
			for k, v in pairs(self.wg_equip_fns) do
				v(self.inst, owner)
			end
		end
	end
	local Unequip = self.Unequip
	function self:Unequip(owner, slot, ...)
		Unequip(self, owner, slot, ...)
		-- 自动换贴图
		if self.symbol then
			clear_override(owner, self.inst, self.symbol, self.equipslot)
		end
		-- 
		if owner.components.health then
			local k = "equipslot_"..self.equipslot
			owner.components.health:WgRemoveMaxHealthModifier(k, true, true)
		end
		if owner.components.sanity then
			local k = "equipslot_"..self.equipslot
			owner.components.sanity:WgRemoveMaxSanityModifier(k, true, true)
		end
		if owner.components.hunger then
			local k = "equipslot_"..self.equipslot
			owner.components.hunger:WgRemoveMaxHungerModifier(k, true, true)
		end

		if owner.components.combat then
			-- 战斗属性
			local data = self.combat_data
			if data then
				local k = "equipslot_"..self.equipslot
				if data.defense then
					owner.components.combat:RmDefenseMod(k)	
				end
				if data.evade then
					owner.components.combat:RmEvadeRateMod(k)
				end
				if data.penetrate then
					owner.components.combat:RmPenetrateMod(k)
				end
				if data.hit_rate then
					owner.components.combat:RmHitRateMod(k)
				end
				if data.dmg_mult then
					owner.components.combat:RemoveDamageModifier(k)
				end
				if data.crit then
					owner.components.combat:RmCritRateMod(k)
				end
				if data.attack_speed then
					owner.components.combat:RemovePeriodModifier(k)
				end
				if data.recover_rate then
					owner.components.combat:RmRecoverRateMod(k)
				end
				if data.add_speed then
					owner.components.locomotor:RemoveSpeedModifier_Additive(k)
				end
			end
			-- 各类型伤害吸收
			local data = self.dmg_resist
			if data then
				-- local k = "equipslot_"..self.equipslot
				for k2, v2 in pairs(data) do
					owner.components.combat:AddDmgTypeAbsorb(k2, -v2)
				end
			end
		end
		-- 人物属性
		if owner.components.tp_player_attr then
			local data = self.attr_data
			if data then
				local k = "equipslot_"..self.equipslot
				for k2, v2 in pairs(data) do
					owner.components.tp_player_attr:RmAttrMod(k, k2)
				end
			end
		end
		if self.wg_unequip_fns then
			for k, v in pairs(self.wg_unequip_fns) do
				v(self.inst, owner)
			end
		end
	end
	function self:WgAddEquipFn(fn)
		if self.wg_equip_fns == nil then
			self.wg_equip_fns = {}
		end
		table.insert(self.wg_equip_fns, fn)
	end
	function self:WgAddUnequipFn(fn)
		if self.wg_unequip_fns == nil then
			self.wg_unequip_fns = {}
		end
		table.insert(self.wg_unequip_fns, fn)
	end
	-- function(damage, attacker, weapon, owner, equip)
	function self:WgAddEquipAttackedFn(fn)
		if self.wg_attacked_fns == nil then
			self.wg_attacked_fns = {}
		end
		table.insert(self.wg_attacked_fns, fn)
	end
	local OnLoad = self.OnLoad
	function self:OnLoad(...)
		if OnLoad then
			OnLoad(...)
		end
		-- if self.inst.components.equippable.owner then
			self.wg_not_fix_attr = true
		-- end
	end
	
	local GetDapperness = self.GetDapperness
	function self:GetDapperness(owner)
		local dapperness = GetDapperness(self, owner)
		if self.enchant_dapper then
			dapperness = dapperness+self.enchant_dapper
		end
		return dapperness
	end
	
	-- 穿戴重量
	self.equip_weight = nil
	function self:SetEquipWeight(weight)
		self.equip_weight = weight
	end

	function self:SetSomeAttr(weight, dmg_type, vigor_cost)
		self:SetEquipWeight(weight)
		if dmg_type then
			assert(self.inst.components.weapon, string.format("%s don't have component weapon", tostring(self.inst)))
			self.inst.components.weapon.dmg_type = dmg_type
		end
		if vigor_cost then
			assert(self.inst.components.weapon, string.format("%s don't have component weapon", tostring(self.inst)))
			self.inst.components.weapon:SetAttackCostVigor(vigor_cost)
		end
	end
	
	function self:GetWargonString()
		local s = ""
		local health = self:WgGetEquipMaxHealthModifer()
		if health then
			s = s..string.format("生命+%d,", health)
		end
		local sanity = self:WgGetEquipMaxSanityModifer()
		if sanity then
			s = s..string.format("理智+%d,", sanity)
		end
		local hunger = self:WgGetEquipMaxHungerModifer()
		if hunger then
			s = s..string.format("饥饿+%d,", hunger)
		end
		if self.equip_weight then
			s = s..string.format("\n重量:%d", self.equip_weight)
		end
		if #s>0 then
			return s
		end
	end
	function self:GetWargonStringColour()
		return {128/255, 128/255, 0/255, 1}
	end
end
AddComponentPostInit("equippable", fn)

-- 让装备在受到攻击时可以触发函数
local function fn(self)
	if self.equip_fix and cur_ver <= self.equip_fix then
		return
	end
	
	local ApplyDamage = self.ApplyDamage
	-- 检测是否有受到攻击时触发的函数
	function self:ApplyDamage(damage, attacker, weapon)	
		local stimuli = self.temp_stimuli
		-- 添加附加
		for k,v in pairs(self.equipslots) do
			if v.components.equippable.wg_attacked_fns then
				for k2, v2 in pairs(v.components.equippable.wg_attacked_fns) do
					-- local data = {damage=damage, attacker=attacker, weapon=weapon, owner=self.inst, item=v}
					damage = v2(damage, attacker, weapon, self.inst, v, stimuli)
					assert(type(damage) == "number", string.format("equip_attacked_fn[%s] return value must be number, but got %s", tostring(v), type(damage)))
					-- damage = v2(data) or damage
				end
			end
		end
	
		return ApplyDamage(self, damage, attacker, weapon)
	end
end
AddComponentPostInit("inventory", fn)