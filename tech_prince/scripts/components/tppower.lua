local TpPower = Class(function(self, inst)
	self.inst = inst
	self.power = 0
	self.powered = nil
	self:Init()
end)

local colours = {
	{1, 0, 0, 1},  -- red
	{0, 0, 1, 1},  -- deep blue
	{0, 1, 0, 1},  -- green
	{1, 1, 0, 1},  -- yellow
	{1, 0, 1, 1},  -- pink
	{0, 1, 1, 1},  -- blue
}

local fns = {
	-- heal
	function(inst)
		if inst.components.combat then
			local old_attack = inst.components.onhitotherfn
			inst.components.combat:SetOnHitOther(function(attacker, target, damage, stimuli)
				if damage>0 and attacker.components.health then
					attacker.components.health:DoDelta(damage)
					target.components.health:DoDelta(-damage/2)
				end
				if old_attack then
					old_attack(attacker, target, damage, stimuli)
				end
			end)
		end
	end,
	-- proj
	function(inst)
		if inst.components.combat then
			if inst.components.inventory then
				local damage = inst.components.combat.defaultdamage
				WARGON.EQUIP.equip_temp_weapon(inst, damage, {8, 10}, "tp_bishop_charge")
			else
				inst.components.combat:SetRange(8, 10)
			end
		end
	end,
	-- poison
	function(inst)
		if inst.components.combat then
			local old_attack = inst.components.combat.onhitotherfn
			inst.components.combat:SetOnHitOther(function(attacker, target, damage, stimuli)
				if old_attack then
					old_attack(attacer, target, damage, stimuli)
				end
				WARGON.poison_prefab(target)
			end)
		end
	end,
	-- fire/invincible
	function(inst)
		if inst.components.combat then
			local old_attack = inst.components.combat.onhitotherfn
			inst.components.combat:SetOnHitOther(function(attacker, target, damage, stimuli)
				-- WARGON.fire_prefab(target, attacker)
				if old_attack then
					old_attack(attacer, target, damage, stimuli)
				end
				inst.components.health:SetInvincible(true, "tp_power_yellow")
				WARGON.do_task(inst, 3, function()
					inst.components.health:SetInvincible(false, "tp_power_yellow")
				end)
			end)
		end
	end,
	-- shadow
	function(inst)
		if inst.components.combat then
			local old_attack = inst.components.combat.onhitotherfn
			inst.components.combat:SetOnHitOther(function(attacker, target, damage, stimuli)
				if old_attack then
					old_attack(attacer, target, damage, stimuli)
				end
				local pt = target:GetPosition()
		        local st_pt =  FindWalkableOffset(pt or attacker:GetPosition(), math.random()*2*PI, 2, 3)
		        if st_pt then
		        	if attacker.SoundEmitter then
			            attacker.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
			            attacker.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")            
		        	end
		            st_pt = st_pt + pt
		            local st = SpawnPrefab("shadowtentacle")
		            --print(st_pt.x, st_pt.y, st_pt.z)
		            st.Transform:SetPosition(st_pt.x, st_pt.y, st_pt.z)
		            st.components.combat:SetTarget(target)
		        end
			end)
		end
	end,
	-- ice
	function(inst)
		if inst.components.combat then
			local old_attack = inst.components.combat.onhitotherfn
			inst.components.combat:SetOnHitOther(function(attacker, target, damage, stimuli)
				if old_attack then
					old_attack(attacer, target, damage, stimuli)
				end
				WARGON.frozen_prefab(target, attacker)
			end)
		end
	end,
}

function TpPower:Init()
	local inst = self.inst
	if inst.components.combat then
	
		local old_attack = inst.components.onhitotherfn
		inst.components.combat:SetOnHitOther(function(attacker, target, damage, stimuli)
			if old_attack then
				old_attack(attacker, target, damage, stimuli)
			end
			-- heal
			if self.power == 1 then
				if damage>0 and attacker.components.health then
					attacker.components.health:DoDelta(damage)
					target.components.health:DoDelta(-damage/2)
				end
			end
			-- poison
			if self.power == 3 then
				WARGON.poison_prefab(target)
			end
			-- fire/invincible
			if self.power == 4 then
				-- WARGON.fire_prefab(target, attacker)
				inst.components.health:SetInvincible(true, "tp_power_yellow")
				WARGON.do_task(inst, 3, function()
					inst.components.health:SetInvincible(false, "tp_power_yellow")
				end)
			end
			-- shadow
			if self.power == 5 then
				local pt = target:GetPosition()
		        local st_pt =  FindWalkableOffset(pt or attacker:GetPosition(), math.random()*2*PI, 2, 3)
		        if st_pt then
		        	if attacker.SoundEmitter then
			            attacker.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
			            attacker.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")            
		        	end
		            st_pt = st_pt + pt
		            local st = SpawnPrefab("shadowtentacle")
		            --print(st_pt.x, st_pt.y, st_pt.z)
		            st.Transform:SetPosition(st_pt.x, st_pt.y, st_pt.z)
		            st.components.combat:SetTarget(target)
		        end
		    end
	        -- ice
	        if self.power == 6 then
				WARGON.frozen_prefab(target, attacker)
	        end
		end)

		-- if inst.components.inventory then
		-- 	local damage = inst.components.combat.defaultdamage
		-- 	WARGON.EQUIP.equip_temp_weapon(inst, damage, {8, 10}, "tp_bishop_charge")
		-- else
		-- 	inst.components.combat:SetRange(8, 10)
		-- end
		self.dmg_range = {
			inst.components.combat.attackrange,
			inst.components.combat.hitrange,
		}
	end
end

function TpPower:SetPower(n, extra)
	-- if n > 0 and self.power <= 0 then
	if n > 0 then
		local old_power = self.power
		local colour = colours[n]
		self.inst.AnimState:SetMultColour(unpack(colour))
		-- local fn = fns[n]
		-- fn(self.inst)
		self.power = n
		self.powered = true
		local inst = self.inst
		if self.power == 2 then
			if inst.components.inventory then
				local damage = inst.components.combat.defaultdamage
				WARGON.EQUIP.equip_temp_weapon(inst, damage, {8, 10}, "tp_bishop_charge")
			else
				inst.components.combat:SetRange(8, 10)
			end
		elseif old_power == 2 then
			if inst.components.inventory then
				local weapon = inst:get_equip_item("hand")
				if weapon then
					inst.components.inventory:DropItem(weapon)
				end
			else
				local range = eslf.dmg_range or {}
				inst.components.combat:SetRange(range[1], range[2])
			end
		end
	end
end

function TpPower:OnSave()
	return {
		power = self.power,
		powered = self.powered,
	}
end

-- 因为在prefab的fn之后，所以没法加载
function TpPower:OnLoad(data)
	if data then
		self.powered = data.powered
		self.power = data.power or 0
		self:SetPower(self.power)
	end
end

return TpPower