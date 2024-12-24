local Info = Sample.Info
local Util = require "extension.lib.wg_util"
local EntUtil = require "extension.lib.ent_util"

-- 添加DoDelta
local function fn(self)
	if self.armor_fix then return end self.armor_fix = true
	
	function self:DoDelta(amount)
		local old_val = self.condition
		local new_val = math.min(self.maxcondition, self.condition+amount)
		self:SetCondition(new_val)
	end
	
	-- 不同类型伤害吸收
	self.dmg_type_absorb = nil
	function self:SetDmgTypeAbsorb(dmg_type, percent)
		if self.dmg_type_absorb == nil then
			self.dmg_type_absorb = {}
		end
		self.dmg_type_absorb[dmg_type] = percent
	end
	
	local TakeDamage = self.TakeDamage
	function self:TakeDamage(damage_amount, attacker, weapon)
		local equip = self.inst.components.equippable
		local owner = equip and equip.owner
		-- 无敌时受到攻击护甲不会损失
		if owner and owner.components.health
		and owner.components.health:IsInvincible() then
			return damage_amount
		end
		-- 处理不同类型伤害的吸收
		local can_resist = -1
		if owner.components.inventory
		and owner.components.inventory.temp_stimuli then
			if self:CanResist(attacker, weapon) then
				can_resist = 1
			end
			if can_resist == 1 then
				local stimuli = owner.components.inventory.temp_stimuli
				local dmg_type = EntUtil:get_dmg_stimuli(stimuli)
				if dmg_type then
					if self.dmg_type_absorb and self.dmg_type_absorb[dmg_type] then
						local absorb_percent = self.dmg_type_absorb[dmg_type]
						-- 受到破甲效果后护甲收益减低 HasTag("armor_broken")
						if owner:HasTag("armor_broken") then
							absorb_percent = absorb_percent * Info.ArmorBrokenRate
						end
	
						local leftover = damage_amount
						local max_absorbed = damage_amount * absorb_percent
						local absorbed = math.floor(math.min(max_absorbed, self.condition))
						-- we said we were going to absorb something so we will
						if absorbed < 0 then
							leftover = damage_amount - absorbed
							absorbed = 1
						else
							if absorbed < 1 then
								absorbed = 1
							end
							leftover = damage_amount - absorbed
						end
						ProfileStatsAdd("armor_absorb", absorbed)
						if METRICS_ENABLED then
							FightStat_Absorb(absorbed)
						end
						if self.bonussanitydamage then
							local sanitydamage = absorbed * self.bonussanitydamage
							if self.inst.components.equippable and self.inst.components.equippable:IsEquipped() and self.inst.components.equippable.equipper then
								self.inst.components.equippable.equipper.components.sanity:DoDelta(-sanitydamage)
							end
						end
						-- 降低护甲损失
						owner:PushEvent("armor_absorb", {armor=self.inst, amount = absorbed, stimuli = dmg_type})
						-- if self.inst.components.tp_forge_armor then
						-- 	local level = self.inst.components.tp_forge_armor.level
						-- 	absorbed = absorbed / level
						-- end
						if self.wg_take_dmg_fns then
							for _, fn in pairs(self.wg_take_dmg_fns) do
								fn(absorbed, attacker, weapon, owner, self.inst, stimuli)
							end
						end
						self:SetCondition(self.condition - absorbed)
						if self.ontakedamage then
							local stimuli = owner.components.inventory.temp_stimuli
							self.ontakedamage(self.inst, damage_amount, absorbed, leftover, stimuli)
						end
						self.inst:PushEvent("armorhit")
						if absorb_percent >= 1 then
							return 0
						end
						return leftover
					end
				end
				return damage_amount
			end
		else
			can_resist = 0  -- 表示没有检测
		end
	
		-- if owner and owner:HasTag("armor_broken") then
		-- 	if can_resist == 1 
		-- 	or (can_resist == 0 and self:CanResist(attacker, weapon)) then
		--         local leftover = damage_amount
		--         local max_absorbed = damage_amount * self.absorb_percent*Info.ArmorBrokenRate;
		--         local absorbed = math.floor(math.min(max_absorbed, self.condition))
		--         -- we said we were going to absorb something so we will
		--         if absorbed < 1 then
		--             absorbed = 1
		--         end
		--         leftover = damage_amount - absorbed
		--         ProfileStatsAdd("armor_absorb", absorbed)
		--         if METRICS_ENABLED then
		-- 			FightStat_Absorb(absorbed)
		-- 		end
		--         if self.bonussanitydamage then
		--             local sanitydamage = absorbed * self.bonussanitydamage
		--             if self.inst.components.equippable and self.inst.components.equippable:IsEquipped() and self.inst.components.equippable.equipper then
		--                 self.inst.components.equippable.equipper.components.sanity:DoDelta(-sanitydamage)
		--             end                
		--         end
		--         self:SetCondition(self.condition - absorbed)
		-- 		if self.ontakedamage then
		-- 			self.ontakedamage(self.inst, damage_amount, absorbed, leftover)
		-- 		end
		--         self.inst:PushEvent("armorhit")
		--         if self.absorb_percent >= 1 then
		--             return 0
		--         end
		--         return leftover
		--     else
		--         return damage_amount
		--     end
		-- else
		-- 无属性类型伤害吸收
			return TakeDamage(self, damage_amount, attacker, weapon)
		-- end
		-- return TakeDamage(self, damage_amount, attacker, weapon)
	end

	function self:WgAddTakeDamageFn(fn)
		if self.wg_take_dmg_fns == nil then
			self.wg_take_dmg_fns = {}
		end
		table.insert(self.wg_take_dmg_fns, fn)
	end

	-- 任何时候都返回护甲值
	-- 保存最大护甲值
	-- 保存护甲最大值修改值
	local OnSave = self.OnSave
	function self:OnSave()
		local data = OnSave(self)
		if data == nil then
			data = {condition = self.condition}
		end
		-- data.maxcondition = self.maxcondition
		data.max_modifier = self.max_modifier
		return data
	end
	
	local OnLoad = self.OnLoad
	function self:OnLoad(data)
		-- if data and data.maxcondition then
		-- 	self.maxcondition = data.maxcondition
		-- end
		if data.max_modifier then
			self.max_modifier = data.max_modifier
			self.maxcondition = self.maxcondition + self.max_modifier
		end
		OnLoad(self, data)
	end
	
	function self:AddMaxModifier(val)
		if self.max_modifier == nil then
			self.max_modifier = 0
		end
		self.max_modifier = self.max_modifier + val
		self.maxcondition = self.maxcondition + val
	end
	
	function self:GetWargonString()
		local s = string.format("耐久:%d/%d", self.condition, self.maxcondition)
		s = s.."\n伤害吸收:"
		s = s..string.format("无属性(%d%%),", self.absorb_percent*100)
		if self.dmg_type_absorb then
			for k, v in pairs(Info.DmgTypeList) do
				if self.dmg_type_absorb[v[1]] then
					local val = self.dmg_type_absorb[v[1]]
					s = s .. string.format("%s(%d%%),", v[2], val*100)
				end
			end
		end
		return Util:SplitSentence(s, 17, true)
	end
	
	function self:GetWargonStringColour()
		return {176/255, 196/255, 222/255, 1}
	end
end
AddComponentPostInit("armor", fn)