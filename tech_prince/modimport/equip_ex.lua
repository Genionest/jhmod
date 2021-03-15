local function get_anim(owner)
	if owner.AnimState then
		return owner.AnimState
	else
		return owner
	end
end

local function hat_on(owner, build, file, is_player)
	local f = file or "swap_hat"
	local anim = get_anim(owner)
	anim:OverrideSymbol("swap_hat", build, f)
	anim:Show("HAT")
	anim:Show("HAIR_HAT")
	anim:Hide("HAIR_NOHAT")
	anim:Hide("HAIR")
	if ( owner.HasTag and owner:HasTag("player") ) or is_player then
		anim:Hide("HEAD")
		anim:Show("HEAD_HAIR")
		anim:Hide("HAIRFRONT")
	end
end

local function hat_open(owner, build, file)
	local f = file or "swap_hat"
	local anim = get_anim(owner)
	anim:OverrideSymbol("swap_hat", build, f)
	anim:Show("HAT")
	anim:Hide("HAIR_HAT")
	anim:Show("HAIR_NOHAT")
	anim:Show("HAIR")
	anim:Show("HAIRFRONT")

	anim:Show("HEAD")
	anim:Hide("HEAD_HAIR")
end

local function hat_off(owner, is_player)
	local anim = get_anim(owner)
	anim:Hide("HAT")
	anim:Hide("HAIR_HAT")
	anim:Show("HAIR_NOHAT")
	anim:Show("HAIR")

	if ( owner.HasTag and owner:HasTag("player") ) or is_player then
		anim:Show("HEAD")
		anim:Hide("HEAD_HAIR")
		anim:Show("HAIRFRONT")
	end
end

local function body_on(owner, build, file)
	local f = file or "swap_body"
	local anim = get_anim(owner)
	anim:OverrideSymbol("swap_body", build, f)
end

local function body_off(owner)
	local anim = get_anim(owner)
	anim:ClearOverrideSymbol("swap_body")
end

local function object_on(owner, build, file)
	local anim = get_anim(owner)
	local f = file or build
	anim:OverrideSymbol("swap_object", build, f)
	anim:Show("ARM_carry")
	anim:Hide("ARM_normal")
end

local function object_off(owner)
	local anim = get_anim(owner)
	anim:Hide("ARM_carry")
	anim:Show("ARM_normal")
end

local function equip_temp_weapon(inst, dmg, dist, proj)
	if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local weapon = CreateEntity()
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(dmg)
        local atk_dist = type(dist) == "table" and dist[1] or dist
        local hit_dist = type(dist) == "table" and (dist[2] or dist[1]) or dist 
        weapon.components.weapon:SetRange(atk_dist, hit_dist)
        weapon.components.weapon:SetProjectile(proj)
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(function(inst)
        	inst:Remove()
        end)
        weapon:AddComponent("equippable")
        
        inst.components.inventory:Equip(weapon)
    end
end

-- local function tp_health_equip_complete(inst)
-- 	if inst:HasTag("tp_hat_health") and inst:HasTag("tp_armor_health")
-- 	and inst:HasTag("tp_spear_blood") then
-- 		if inst.tp_health_equip_task == nil then
-- 			inst.tp_health_equip_task = WARGON.per_task(inst, 4, function()
-- 				if inst.components.health then
-- 					inst.components.health:DoDelta(2, true, "tp_health_equip")
-- 				end
-- 			end)
-- 		end
-- 	end
-- end

-- local function tp_health_equip_incomplete(inst)
-- 	if inst.tp_health_equip_task then
-- 		inst.tp_health_equip_task:Cancel()
-- 		inst.tp_health_equip_task = nil
-- 	end
-- end

GLOBAL.WARGON_EQUIP_EX = {
	hat_on 				= hat_on,
	hat_open 			= hat_open,
	hat_off				= hat_off,
	body_on				= body_on,
	body_off			= body_off,
	object_on			= object_on,
	object_off			= object_off,
	equip_temp_weapon 	= equip_temp_weapon,
	-- tp_health_equip_complete = tp_health_equip_complete,
	-- tp_health_equip_incomplete = tp_health_equip_incomplete,
}

GLOBAL.WARGON.EQUIP = GLOBAL.WARGON_EQUIP_EX