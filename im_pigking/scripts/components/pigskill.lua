local function equip_weapon(inst)
	if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local weapon = CreateEntity()
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
        weapon.components.weapon:SetRange(8, 12)
        weapon.components.weapon:SetProjectile("bishop_charge")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(function()
        	weapon:Remove()
        end)
        weapon:AddComponent("equippable")
        inst.components.inventory:Equip(weapon)
    end
end

local skills = {
	thunder_fist = {
		add = function(inst, cmp)
			equip_weapon(inst)
		end,
		rm = function(inst, cmp)
			local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if weapon then
				inst.components.inventory:DropItem(weapon)
			end			
		end,
		time = 5,
		cooldown = 20,
	},
	sheild = {
		add = function(inst, cmp)
			if cmp.fxs["sheild"] == nil then
				cmp.fxs["sheild"] = SpawnPrefab("forcefieldfx")
				local fx = cmp.fxs["sheild"]
				inst:AddChild(fx)
				fx.Transform:SetPosition(0, 0, 0)
			end
			inst.components.health:SetInvincible(true)
		end,
		rm = function(inst, cmp)
			inst.components.health:SetInvincible(false)
			if cmp.fxs["sheild"] then
				local fx = cmp.fxs["sheild"]
				fx.kill_fx(fx)
				cmp.fxs["sheild"] = nil
			end
		end,
		time = 5,
		cooldown = 20,
	},
}

local PigSkill = Class(function(self, inst)
	self.inst = inst
	self.fxs = {}
	self.cooldown = {}
	self.tasks = {}
	self.time = {}
	self.inst:StartUpdatingComponent(self)
end)

function PigSkill:UseSkill(name)
	if self.inst.components.health
	and not self.inst.components.health:IsDead()
	and self.cooldown[name] == nil then
		local skill = skills[name]
		self.cooldown[name] = skill.cooldown
		skill.add(self.inst, self)
		self.time[name] = skill.time
	else
		self.inst.components.talker:Say("技能还未冷却")
	end
end

function PigSkill:DoneSkill(name)
	local skill = skills[name]
	skill.rm(self.inst, self)
end

function PigSkill:OnUpdate(dt)
	for k, v in pairs(self.cooldown) do
		self.cooldown[k] = self.cooldown[k] - dt
		if self.cooldown[k] <= 0 then
			self.cooldown[k] = nil
		end
	end
	for k, v in pairs(self.time) do
		self.time[k] = self.time[k] - dt
		if self.time[k] <= 0 then
			self:DoneSkill(k)
			self.time[k] = nil
		end
	end
end

function PigSkill:OnSave()
	return {
		cooldown = deepcopy(self.cooldown),
		time = deepcopy(self.time),
	}
end

function PigSkill:OnLoad(data)
	if data then
		if data.cooldown then
			self.cooldown = deepcopy(data.cooldown)
		end
		if data.time then
			self.time = deepcopy(data.time)
		end
	end
end

return PigSkill