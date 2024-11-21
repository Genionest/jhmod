local Anims = {
	health = {"tp_hat_health", "tp_hat_health", "anim", "idle_water"},
	ruin = {"ruinshat", "ruinshat_arcane", "anim", "idle"},
	warm = {"tp_hat_warm", "tp_hat_warm", "anim", "idle_water"},
	antitoxin = {"tp_hat_antitoxin", "tp_hat_antitoxin", "anim", "idle_water"},
	cool = {"tp_hat_cool", "tp_hat_cool", "anim", "idle_water"},
	combathelm2 = {"footballhat", "footballhat_combathelm2", "anim", "idle_water"},
}

local function common_unequip(inst, owner)
	WARGON.EQUIP.hat_off(owner)
end

local function helm_equip(inst, owner)
	WARGON.EQUIP.hat_on(owner, "footballhat_combathelm2")
end

local function helm_unequip(inst, owner)
	common_unequip(inst, owner)
end

local function helm_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=helm_equip, unequip=helm_unequip},
		armor = {armor=TUNING.ARMOR_FOOTBALLHAT, absorb=.8},
	})
end

local function warm_equip(inst, owner)
	WARGON.EQUIP.hat_on(owner, "tp_hat_warm")
	owner:AddTag("tp_hat_warm")
end

local function warm_unequip(inst, owner)
	common_unequip(inst, owner)
	owner:RemoveTag("tp_hat_warm")
end

local function warm_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=warm_equip, unequip=warm_unequip},
		armor = {armor=TUNING.ARMOR_FOOTBALLHAT, absorb=.8},
		insu = {value=TUNING.INSULATION_LARGE, typ="winter"},
	})
end

local function cool_equip(inst, owner)
	WARGON.EQUIP.hat_on(owner, "tp_hat_cool")
	owner:AddTag("tp_hat_cool")
end

local function cool_unequip(inst, owner)
	common_unequip(inst, owner)
	owner:RemoveTag("tp_hat_cool")
end

local function cool_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=cool_equip, unequip=cool_unequip},
		armor = {armor=TUNING.ARMOR_FOOTBALLHAT, absorb=.8},
		insu = {value=TUNING.INSULATION_MED, typ="summer"},
	})
end

local function hat_health_on_health_delta(inst, data)
	if data.cause and data.cause ~= "tp_health_equip" then
		if data.oldpercent < data.newpercent then
			local dt_p = data.newpercent - data.oldpercent
			local dt = inst.components.health.maxhealth * dt_p
			local recover = dt/5
			inst.components.health:DoDelta(recover, true, "tp_health_equip")
		end
	end
end

local function health_equip(inst, owner)
	WARGON.EQUIP.hat_on(owner, "tp_hat_health")
	owner:AddTag("tp_hat_health")
	owner:ListenForEvent("healthdelta", hat_health_on_health_delta)
	WARGON.EQUIP.tp_health_equip_complete(owner)
end

local function health_unequip(inst, owner)
	common_unequip(inst, owner)
	owner:RemoveTag("tp_hat_health")
	owner:RemoveEventCallback(owner, hat_health_on_health_delta)
	WARGON.EQUIP.tp_health_equip_incomplete(owner)
end

local function health_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=health_equip, unequip=health_unequip},
		armor = {armor=TUNING.ARMOR_FOOTBALLHAT, absorb=.8},
	})
end

local function antitoxin_equip(inst, owner)
	owner:anim_hat_on("tp_hat_antitoxin")
end

local function antitoxin_unequip(inst, owner)
	common_unequip(inst, owner)
end

local function antitoxin_fn(inst)
	inst:add_cmps({
		inspect = {},
		equip = {equip=antitoxin_equip, unequip=antitoxin_unequip},
		armor = {armor=TUNING.ARMOR_FOOTBALLHAT, absorb=.8},
	})
	inst.components.equippable.poisongasblocker = true
	inst.components.equippable.poisonblocker = true
end

local function ancient_on_attack(inst, data)
	if data and data.target and data.target.components.health then
		local max = data.target.components.health:GetMaxHealth()
		if max > 4000 then
			local dmg = max/20
			data.target.components.health:DoDelta(-dmg)
		end
	end
end

local function ancient_equip(inst, owner)
	owner:anim_hat_open("ruinshat_arcane")
	owner:ListenForEvent("onhitother", ancient_on_attack)
end

local function ancient_unequip(inst, owner)
	common_unequip(inst, owner)
	owner:RemoveEventCallback("onhitother", ancient_on_attack)
end

local function ancient_fn(inst)
	inst:add_cmps({
		inspect = {},
		equip = {equip=ancient_equip, unequip=ancient_unequip},
		armor = {armor=TUNING.ARMOR_RUINSHAT, absorb=.9},
	})
end

local function MakeItem(name, anims, item_fn, atlas, img)
	local function fn()
		local the_atlas = atlas and "images/inventoryimages/"..atlas..".xml" 
		local the_img = img or atlas
	 	local inst = WARGON.make_prefab(anims, anims[4], "inv", nil, nil)
	 	WARGON_CMP_EX.add_cmps(inst, {
	 		invitem = {atlas=the_atlas, img=the_img},
	 		equip = {slot="head"},
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
MakeItem("tp_hat_helm", Anims.combathelm2, helm_fn, "footballhat_combathelm2"),
MakeItem("tp_hat_warm", Anims.warm, warm_fn, "tp_hat_warm"),
MakeItem("tp_hat_cool", Anims.cool, cool_fn, "tp_hat_cool"),
MakeItem("tp_hat_health", Anims.health, health_fn, "tp_hat_health"),
MakeItem("tp_hat_antitoxin", Anims.antitoxin, antitoxin_fn, "tp_hat_antitoxin"),
MakeItem("tp_hat_ancient", Anims.ruin, ancient_fn, "ruinshat_arcane")
