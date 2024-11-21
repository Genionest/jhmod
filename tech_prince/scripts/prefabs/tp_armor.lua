local Anims = {
	lamellar = {"armor_wood_lamellar", "armor_wood_lamellar", "anim", "idle_water", },
	thunder = {"armor_wood_lamellar", "tp_armor_thunder", "anim", "idle_water", },
	health = {"armor_wood_lamellar", "tp_armor_health", "anim", "idle_water", },
	firm = {"armor_wood_lamellar", "tp_armor_firm", "anim", "idle_water", },
	warm = {"armor_wood_lamellar", "tp_armor_warm", "anim", "idle_water", },
	cool = {"armor_wood_lamellar", "tp_armor_cool", "anim", "idle_water", },
	ruin = {"armor_ruins", "armor_ruins_tusk", "armor_ruins", "anim", "idlw_water", },
	ruin2 = {"armor_ruins", "armor_ruins_bulky", "armor_ruins", "anim", "idlw_water", },
	ruin3 = {"armor_ruins", "armor_ruins_leaf", "armor_ruins", "anim", "idlw_water", },
}

local function common_unequip(inst, owner)
	WARGON.EQUIP.body_off(owner)
end

local function armor_lamellar_equip(inst, owner)
	WARGON.EQUIP.body_on(owner, "armor_wood_lamellar", "swap_body")
end

local function armor_lamellar_unequip(inst, owner)
	common_unequip(inst, owner)
end

local function armor_lamellar_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=armor_lamellar_equip, unequip=armor_lamellar_unequip},
		armor = {armor=TUNING.ARMORWOOD, absorb=.8},
	})
end

local function armor_health_on_attacked(inst, data)
	if inst.components.health and inst.components.health:GetPercent() < .3
	and math.random() < .33 then
		inst.components.health:DoDelta(10, nil, "tp_health_equip")
	end
end

local function armor_health_equip(inst, owner)
	WARGON.EQUIP.body_on(owner, "tp_armor_health", "swap_body")
	owner:ListenForEvent("attacked", armor_health_on_attacked)
	owner:AddTag("tp_armor_health")
	WARGON.EQUIP.tp_health_equip_complete(owner)
end

local function armor_health_unequip(inst, owner)
	common_unequip(inst, owner)
	owner:RemoveEventCallback("attacked", armor_health_on_attacked)
	owner:RemoveTag("tp_armor_health")
	WARGON.EQUIP.tp_health_equip_incomplete(owner)
end

local function armor_health_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=armor_health_equip, unequip=armor_health_unequip},
		armor = {armor=TUNING.ARMORWOOD, absorb=.8},
	})
end

local function armor_firm_equip(inst, owner)
	WARGON.EQUIP.body_on(owner, "tp_armor_firm", "swap_body")
	-- owner:AddTag("not_hit_stunned")
	owner:AddTagNum("not_hit_stunned", 1)
end

local function armor_firm_unequip(inst, owner)
	common_unequip(inst, owner)
	-- owner:RemoveTag("not_hit_stunned")
	owner:AddTagNum("not_hit_stunned", -1)
end

local function armor_firm_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=armor_firm_equip, unequip=armor_firm_unequip},
		armor = {armor=TUNING.ARMORWOOD, absorb=.8},
	})
end

local function armor_warm_heat_fn(inst, owner)
	local c = 0
	if owner and owner:HasTag("tp_armor_warm") and owner:HasTag("tp_hat_warm")
	and owner:HasTag("tp_spear_fire") then
		c = 50
	end
	return c
end

local function armor_warm_on_attacked(inst, data)
	if (data.weapon == nil or (not data.weapon:HasTag("projectile") and data.weapon.projectile == nil))
	and data.attacker and data.attacker.components.combat and data.stimuli ~= "thorns" and not data.attacker:HasTag("thorny")
	and (data.attacker.components.combat == nil or (data.attacker.components.combat.defaultdamage > 0))
	and data.damage and data.damage > 0 and math.random() < .5 then
		WARGON.fire_prefab(data.attacker, inst)
	end
end

local function armor_warm_equip(inst, owner)
	WARGON.EQUIP.body_on(owner, "tp_armor_warm", "swap_body")
	owner:ListenForEvent("attacked", armor_warm_on_attacked)
	owner:AddTag("tp_armor_warm")
end

local function armor_warm_unequip(inst, owner)
	common_unequip(inst, owner)
	owner:RemoveEventCallback("attacked", armor_warm_on_attacked)
	owner:RemoveTag("tp_armor_warm")
end

local function armor_warm_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=armor_warm_equip, unequip=armor_warm_unequip},
		armor = {armor=TUNING.ARMORWOOD, absorb=.8},
		heat = {equip=armor_warm_heat_fn},
	})
end

local function armor_cool_heat_fn(inst, owner)
	local c = 0
	if owner and owner:HasTag("tp_armor_cool") and owner:HasTag("tp_hat_cool")
	and owner:HasTag("tp_spear_ice") then
		c = 10
	end
	return c
end

local function armor_cool_on_attacked(inst, data)
	if (data.weapon == nil or (not data.weapon:HasTag("projectile") and data.weapon.projectile == nil))
	and data.attacker and data.attacker.components.combat and data.stimuli ~= "thorns" and not data.attacker:HasTag("thorny")
	and (data.attacker.components.combat == nil or (data.attacker.components.combat.defaultdamage > 0))
	and data.damage and data.damage > 0 and math.random() < .5 then
		WARGON.frozen_prefab(data.attacker, inst, 1)
	end
end

local function armor_cool_equip(inst, owner)
	WARGON.EQUIP.body_on(owner, "tp_armor_cool", "swap_body")
	owner:ListenForEvent("attacked", armor_cool_on_attacked)
	owner:AddTag("tp_armor_cool")
end

local function armor_cool_unequip(inst, owner)
	common_unequip(inst, owner)
	owner:RemoveEventCallback("attacked", armor_cool_on_attacked)
	owner:RemoveTag("tp_armor_cool")
end

local function armor_cool_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=armor_cool_equip, unequip=armor_cool_unequip},
		armor = {armor=TUNING.ARMORWOOD, absorb=.8},
		heat = {equip=armor_cool_heat_fn, cool=true},
	})
end

-- local function armor_brier_on_attacked(inst, data)
-- 	if (data.weapon == nil or (not data.weapon:HasTag("projectile") and data.weapon.projectile == nil))
-- 		and data.attacker and data.attacker.components.combat and data.stimuli ~= "thorns" and not data.attacker:HasTag("thorny")
-- 		and (data.attacker.components.combat == nil or (data.attacker.components.combat.defaultdamage > 0)) then
		
-- 		data.attacker.components.combat:GetAttacked(inst, 10, nil, "thorns")
-- 		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/armour/cactus")
-- 	end
-- end

-- local function armor_brier_equip(inst, owner)
-- 	WARGON.EQUIP.body_on(owner, "armor_wood_lamellar", "swap_body")
-- 	owner:ListenForEvent("attacked", armor_brier_on_attacked)
-- end

-- local function armor_brier_unequip(inst, owner)
-- 	common_unequip(inst, owner)
-- 	owner:RemoveEventCallback("attacked", armor_brier_on_attacked)
-- end

-- local function armor_brier_fn(inst)
-- 	WARGON.CMP.add_cmps(inst, {
-- 		inspect = {},
-- 		equip = {equip=armor_brier_equip, unequip=armor_brier_unequip},
-- 		armor = {armor=TUNING.ARMORWOOD, absorb=.8},
-- 	})
-- end

local function armor_thunder_turn_on(inst, owner)
	inst.Light:Enable(true)
	local owner = inst.components.inventoryitem.owner
	if owner then
		WARGON.add_speed_rate(owner, "tp_armor_thunder", .25)
	end
end

local function armor_thunder_turn_off(inst, owner)
	inst.Light:Enable(false)
	local owner = inst.components.inventoryitem.owner
	if owner then
		WARGON.remove_speed_rate(owner, "tp_armor_thunder")
	end
end

local function armor_thunder_on_lightning(inst, data)
	if inst.components.health then
		inst.components.health:DoDelta(20)
	end
	if inst.components.sanity then
		inst.components.sanity:DoDelta(-40)
	end
	local armor = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
	if armor and armor:HasTag("tp_armor_thunder") then
		if armor.components.tpvalue then
			armor.components.tpvalue:DoDelta(100)
		end
		armor_thunder_turn_on(armor)
	end
end

local function armor_thunder_on_attacked(inst, data)
	if (data.weapon == nil or (not data.weapon:HasTag("projectile") 
	and data.weapon.projectile == nil)) and data.attacker 
	and data.attacker.components.combat and data.stimuli ~= "thorns" 
	and not data.attacker:HasTag("thorny") 
	and (data.attacker.components.combat == nil 
	or (data.attacker.components.combat.defaultdamage > 0))
	and data.damage and data.damage > 0 then
		local armor = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if armor and armor:HasTag("tp_armor_thunder") 
		and armor.components.tpvalue 
		and not armor.components.tpvalue:IsEmpty() then
			data.attacker.components.combat:GetAttacked(inst, 20, nil, "tp_armor_thunder")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/armour/cactus")
		end
	end
end

local function armor_thunder_equip(inst, owner)
	WARGON.EQUIP.body_on(owner, "tp_armor_thunder", "swap_body")
	owner:ListenForEvent("tp_lightning_strike", armor_thunder_on_lightning)
	owner:ListenForEvent("attacked", armor_thunder_on_attacked)
	inst.components.tpvalue:Start()
	if inst.components.tpvalue:IsEmpty() then
		armor_thunder_turn_off(inst)
	else
		armor_thunder_turn_on(inst)
	end
end

local function armor_thunder_unequip(inst, owner)
	WARGON.EQUIP.body_off(owner)
	inst.components.tpvalue:Stop()
	owner:RemoveEventCallback("tp_lightning_strike", armor_thunder_on_lightning)
	owner:RemoveEventCallback("attacked", armor_thunder_on_attacked)
	armor_thunder_turn_off(inst)
end

local function armor_thunder_drop(inst)
	print("tp_armor_thunder drop")
	armor_thunder_turn_off(inst)
end

local function armor_thunder_fn(inst)
	inst:AddTag("tp_armor_thunder")
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		invitem = {drop=armor_thunder_drop},
		equip = {equip=armor_thunder_equip, unequip=armor_thunder_unequip},
		armor = {armor=TUNING.ARMORWOOD, absorb=.8},
		tpvalue = {},
	})
	inst.components.tpvalue:SetMax(300)
	inst.components.tpvalue.empty = function(inst)
		armor_thunder_turn_off(inst)
	end
	local light = inst.entity:AddLight()
	light:SetFalloff(0.4)
	light:SetIntensity(.7)
	light:SetRadius(2.5)
	light:SetColour(180/255, 195/255, 150/255)
	light:Enable(false)
end

local function ancient_on_attacked(inst, data)
	local chance = math.random()
	-- print("tp_armor_ancient", chance)
	if chance < .1 then
		local armor = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if armor and armor:HasTag("tp_armor_ancient")
		and armor.soldier then
			local pos = inst:around_land(2)
			if pos then
				WARGON.make_fx(pos, "statue_transition")
				WARGON.make_fx(pos, "statue_transition_2")
				local soldier = WARGON.make_spawn(pos, armor.soldier)
				if soldier.components.follower then
					soldier.components.follower:SetLeader(inst)
				end
			end
		end
	end
end

local function create_ancient_fn(inst, build, soldier)
	inst:add_cmps({
		inspect = {},
		equip = {
			equip=function(inst, owner)
				owner:anim_body_on(build, "swap_body")
				owner:ListenForEvent("attacked", ancient_on_attacked)
			end,
			unequip=function(inst, owner)
				common_unequip(inst, owner)
				owner:RemoveEventCallback("attacked", ancient_on_attacked)
			end,
		},
		armor = {armor=TUNING.ARMORRUINS, absorb=.9},
	})
	-- inst:SetPrefabName("tp_armor_ancient")
	inst:AddTag("tp_armor_ancient")
	inst.soldier = soldier
end

local function armor_ancient_fn(inst)
	create_ancient_fn(inst, "armor_ruins_tusk", "knight")
end

local function armor_ancient2_fn(inst)
	create_ancient_fn(inst, "armor_ruins_bulky", "bishop")
end

local function armor_ancient3_fn(inst)
	create_ancient_fn(inst, "armor_ruins_leaf", "rook")
end

local function MakeItem(name, anims, item_fn, atlas, img)
	local function fn()
		local the_atlas = atlas and "images/inventoryimages/"..atlas..".xml" 
		local the_img = img or atlas
	 	local inst = WARGON.make_prefab(anims, anims[4], "inv", nil, nil)
	 	WARGON_CMP_EX.add_cmps(inst, {
	 		invitem = {atlas=the_atlas, img=the_img},
	 		equip = {slot="body"},
	 	})
		inst:AddTag("tp_item")
		inst:AddComponent("tpinter")
		inst.components.tpinter:SetCanFn(function(inst, invitem, doer)
			return invitem:HasTag("tp_fix_powder")
				and not inst:HasTag("tp_not_fix")
		end)
	 	if item_fn then
	 		item_fn(inst)
	 	end

	    return inst
	end
	return Prefab("common/inventory/"..name, fn, {})
end

return
MakeItem("tp_armor_lamellar", Anims.lamellar, armor_lamellar_fn, "armor_wood_lamellar"),
MakeItem("tp_armor_health", Anims.health, armor_health_fn, "tp_armor_health"),
MakeItem("tp_armor_firm", Anims.firm, armor_firm_fn, "tp_armor_firm"),
MakeItem("tp_armor_warm", Anims.warm, armor_warm_fn, "tp_armor_warm"),
MakeItem("tp_armor_cool", Anims.cool, armor_cool_fn, "tp_armor_cool"),
MakeItem("tp_armor_thunder", Anims.thunder, armor_thunder_fn, "tp_armor_thunder"),
MakeItem("tp_armor_ancient", Anims.ruin, armor_ancient_fn, "armor_ruins_tusk"),
MakeItem("tp_armor_ancient2", Anims.ruin2, armor_ancient2_fn, "armor_ruins_bulky"),
MakeItem("tp_armor_ancient3", Anims.ruin3, armor_ancient3_fn, "armor_ruins_leaf")
