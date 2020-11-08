local TpBody = Class(function(self, inst)
	self.inst = inst
	self.absorb_mods = {}
	self.fire = 1
	self.lucky = 0
	-- if inst.components.eater then
	-- 	local old_fn = inst.components.eater.gethealthmultfn
	-- 	inst.components.eater.gethealthmultfn = function(inst, food, value)
	-- 		local mult = 1
	-- 		if old_fn then
	-- 			mult = mult * old_fn(inst, food, value)
	-- 		end
	-- 		if inst:HasTag("tp_wound") then
	-- 			mult = mult * .5
	-- 		end
	-- 		return mult
	-- 	end
	-- end
end)

function TpBody:AddWound(time)
	time = time or 1
	if self.fx == nil then
		self.fx = SpawnPrefab("poisonbubble")
		self.inst:AddChild(self.fx)
		self.fx.Transform:SetPosition(0, 0, 0)
		self.fx.AnimState:SetMultColour(1, .1, .1, 1)
	end
	self.inst:AddTag("tp_wound")
	if self.task then
		self.task:Cancel()
		self.task = nil
	end
	self.task = WARGON.do_task(self.inst, time, function()
		if self.fx then
			self.fx:Remove()
			self.fx = nil
		end
		self.inst:RemoveTag("tp_wound")
	end)
end

-- function TpBody:SetArmor(p)
-- 	self.absorb = p
-- end

function TpBody:AddAbsorbModifier(key, mod)
	self.absorb_mods[key] = mod
end

function TpBody:RemoveAbsorbModifier(key)
	self.absorb_mods[key] = nil
end

function TpBody:GetAbsorbModifier()
	local mod = 0
	for k, v in pairs(self.absorb_mods) do
		mod = mod + v
	end
	return mod
end

function TpBody:SetFire(p)
	self.fire = p
end

function TpBody:SetLucky(amount)
	self.lucky = amount
end

function TpBody:GetLucky()
	return self.lucky/100
end

return TpBody