local fns = {
	max_hp = function(inst, value, is_load)
		if is_load then
			inst.components.health:SetMaxHealth(value)
		else
			inst.components.health.maxhealth = value
		end
	end,
	armor = function(inst, value)
		inst.components.health.absorb = value
	end,
	dmg = function(inst, value)
		inst.components.combat:AddDamageModifier("pig_tech_tree", value)
	end,
	speed = function(inst, value)
		inst.components.locomotor:AddSpeedModifier_Mult("pig_tech_tree", value)
	end,
}

local PigAttr = Class(function(self, inst)
	self.inst = inst
	self.init = true
	self.inst:ListenForEvent("pig_tech_tree_change", function(world, data)
		self:SetAttr(data.name, data.value)
	end, GetWorld())
	self.inst:DoTaskInTime(0, function()
		self:Init()
	end)
end)

function PigAttr:Init()
	self.init = nil
	for k, v in pairs(fns) do
		local cmp = GetWorld().components.pigtechtree 
		if cmp then
			self:SetAttr(k, cmp:GetAttr(k), true)
		end
	end
end

function PigAttr:SetAttr(name, value)
	local fn = fns[name]
	if fn then
		fn(self.inst, value)
	end
end

function PigAttr:OnSave()
	return {
		init = self.init,
	}
end

function PigAttr:OnLoad(data)
	if data then
		self.init = data.init
	end
end

return PigAttr