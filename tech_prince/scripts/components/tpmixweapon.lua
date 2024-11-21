local TpMixWeapon = Class(function(self, inst)
	self.inst = inst
	self.weapons = {}
end)

function TpMixWeapon:SetWeapons(weapons)
	self.weapons = weapons
	for k, v in pairs(weapons) do
		-- Create
		local item = SpawnPrefab(v)
		-- tool
		if item.components.tool then
			for k1, v1 in pairs(item.components.tool.action) do
				if self.inst.components.tool == nil then
					self.inst:AddComponent("tool")
				end
				if not (self.inst.components.tool.action 
				and self.inst.components.tool.action[k1]
				and self.inst.components.tool.action[k1] > v1) then
					self.inst.components.tool:SetAction(k1, v1)
				end
			end
		end
		-- weapon
		if item.components.weapon then
			if item.components.weapon.damage
			and item.components.weapon.damage > self.inst.components.weapon.damage then
				self.inst.components.weapon.damage = item.components.weapon.damage
			end
			if item.components.weapon.onattack then
				local old_attack = self.inst.components.weapon.onattack
				local new_attack = item.components.weapon.onattack
				self.inst.components.weapon.onattack = function(...)
					old_attack(...)
					new_attack(...)
				end
			end
			if item.components.weapon.stimuli then
				self.inst.components.weapon.stimuli = item.components.weapon.stimuli
			end
			if item:HasTag("slowattack") then
				self.inst:AddTag("slowattack")
			end
		end
		-- finiteuses
		if item.components.finiteuses then
			-- print("TpMixWeapon", 1)
			if not self.inst.components.perishable then
				-- print("TpMixWeapon", 2)
				local max = item.components.finiteuses.total
				-- print("TpMixWeapon", 3)
				if max > self.inst.components.finiteuses.total then
					-- print("TpMixWeapon", 4)
					self.inst.components.finiteuses:SetMaxUses(max)
					-- print("TpMixWeapon", 5)
					self.inst.components.finiteuses:SetUses(max)
				end
				for k1, v1 in pairs(item.components.finiteuses.consumption) do
					if not (self.inst.components.finiteuses.consumption[k1]
					and self.inst.components.finiteuses.consumption[k1] < v1) then
						self.inst.components.finiteuses:SetConsumption(k1, v1)
					end
				end
			end
		end
		-- perishable
		if item.components.perishable then
			if self.inst.components.perishable == nil then
				self.inst:AddComponent("perishable")
			end
			if self.inst.components.finiteuses then
				self.inst:RemoveComponent("finiteuses")
			end
			local max = item.components.perishable.perishtime
			if not (self.inst.components.perishable.perishtime
			and self.inst.components.perishable.perishtime >= max) then
				self.inst.components.perishable:SetPerishTime(max)
				self.inst.components.perishable:StartPerishing()
				local wet = item.components.perishable.onperishreplacement
				self.inst.components.perishable.onperishreplacement = wet
			end
			if item:HasTag("show_spoilage") then
				self.inst:AddTag("show_spoilage")
			end
		end
		-- equippable
		if item.components.equippable then
			if item.components.equippable.dapperness then
				local new_dap = item.components.equippable.dapperness
				local old_dap = self.inst.components.equippable.dapperness
				if old_dap == nil then
					self.inst.components.equippable.dapperness = new_dap
				else
					self.inst.components.equippable.dapperness = old_dap + new_dap
				end
			end
			if item.components.equippable.walkspeedmult then
				local new_mult = item.components.equippable.walkspeedmult
				local old_mult = self.inst.components.equippable.walkspeedmult
				if old_mult == nil then
					self.inst.components.equippable.walkspeedmult = new_mult
				else
					self.inst.components.equippable.walkspeedmult = old_mult + new_mult
				end
			end
		end
		-- terraformer
		if item.components.terraformer then
			if self.inst.components.terraformer == nil then
				self.inst:AddComponent("terraformer")
				self.inst:AddInherentAction(ACTIONS.TERRAFORM)
			end
		end
		-- Release
		item:Remove()
	end
end

function TpMixWeapon:OnSave()
	return {weapons = self.weapons}
end

function TpMixWeapon:OnLoad(data)
	if data then
		self.weapons = data.weapons or {}
		self:SetWeapons(self.weapons)
	end
end

return TpMixWeapon