local function frog_fix(inst)
	local old_fn = inst.components.combat.targetfn
	inst.components.combat.targetfn = function(inst)
		local target = old_fn(inst)
		if target and target:HasTag("frog") then
			return nil
		end
		return target
	end
end

AddPrefabPostInit("frog", frog_fix)
AddPrefabPostInit("frog_poison", frog_fix)

local function thief_mk(inst)
	local old_fn = inst.components.combat.onhitotherfn
	inst.components.combat.onhitotherfn = function(inst, target, ...)
		if inst.components.thief and inst:HasTag("monkey_king_thief") then
			if math.random() < .05 then
				inst.components.thief:StealItem(target)
			end
		end
		old_fn(inst, target, ...)
	end
end

AddPrefabPostInit("monkey_king", thief_mk)

local function temperature_fix(self)
	local old_fn = self.GetInsulation
	function self:GetInsulation()
		local winter, summer = old_fn(self)
		local mkinsulator = self.inst.components.mkmorphinsulator
		if mkinsulator then
			winter = winter + mkinsulator:GetWinterInsulation()
			summer = summer - mkinsulator:GetSummerInsulation()
		end
		return winter, summer
	end
end

AddComponentPostInit("temperature", temperature_fix)

-- local function combat_fix(self)
-- 	local old_fn = self.CanAttack
-- 	function self:CanAttack(...)
-- 		if self.inst.prefab == "monkey_king"
-- 		and self.inst:HasTag("monkey_king_cant_attack") then
-- 			return false
-- 		end
-- 		return old_fn(self, ...)
-- 	end
-- end

-- AddComponentPostInit("combat", combat_fix)

-- local function set_attack_range(inst)
-- 	inst:AddTag("monkey_king_cant_attack")
-- end

-- AddPrefabPostInit("monkey_king", set_attack_range)