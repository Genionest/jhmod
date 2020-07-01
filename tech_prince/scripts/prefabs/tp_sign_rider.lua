local sign_riders = {"wilsonbeefalo", "wathgrithr_gladiator", "idle_loop"}
local sign_rider_phy = {'char', 100, .5}
local sign_rider_shadow = {6, 2}
local signs = {"sign_home", "sign_home", "place"}

local function sign_rider_combat_re(inst)
	return WARGON.find(inst, 16*1.33, function(guy)
        return inst.components.combat:CanTarget(guy)
           and (not guy:HasTag("beefalo") or guy:HasTag("player"))
           and not guy:HasTag("alwaysblock")
    end)
end

local function sign_rider_combat_keep(inst, target)
	return inst.components.combat:CanTarget(target)
       and not target:HasTag("beefalo")
end

local function sign_rider_on_hit(inst, data)
	inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
    	return dude:HasTag("beefalo")
    		and not dude:IsInLimbo()
    		and not (dude.components.health:IsDead() or dude:HasTag("player"))
    end, 5)
end

local function sign_rider_san_aoe(inst, observer)
	return -TUNING.SANITYAURA_LARGE
end

local function sign_weapon_drop(inst)
	inst:Remove()
end

local function sign_rider_equip_weapon(inst)
	if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
		local weapon = CreateEntity()
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(75)
        weapon.components.weapon:SetRange(7, 10)
        weapon.components.weapon:SetProjectile("tp_sign_proj")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(sign_weapon_drop)
        weapon:AddComponent("equippable")
        
        inst.components.inventory:Equip(weapon)
	end
end

local function fn()
	local inst = WARGON.make_prefab(sign_riders, nil, sign_rider_phy, sign_rider_shadow, 6)
	inst.AnimState:AddOverrideBuild('beefalo_build')
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		loco = {walk=2, run=7},
		combat = {dmg=75, range=7, per=2,
			re={time=3, fn=sign_rider_combat_re},
			keep=sign_rider_combat_keep},
		health = {max=2500, regen={5, 20}},
		loot = {loot={'tp_sign_staff'}},
		san_aoe = {fn=sign_rider_san_aoe},
		inv = {},
		})
	-- WARGON.make_map(inst, 'tent.png')
	WARGON.add_tags(inst, {
		"beefalo", "epic", "largecreature", "scarytoprey",
		})
	WARGON.add_listen(inst, {
		attacked = sign_rider_on_hit
		})
	WARGON.EQUIP.object_on(inst, "tp_sign_staff", "swap_object")
	inst:SetBrain(require "brains/tp_sign_rider_brain")
	inst:SetStateGraph('SGtp_sign_rider')
	WARGON.do_task(inst, 0, sign_rider_equip_weapon)
	inst.atk_num = 0

	return inst
end

local function sign_proj_hit(inst)
	inst:Remove()
end

local function proj()
	local inst = WARGON.make_prefab({}, nil, 'inv')
	RemovePhysicsColliders(inst)
	inst:AddTag('projectile')
	WARGON.no_save(inst)
	WARGON.CMP.add_cmps(inst, {
		proj = {speed=20, hit=sign_proj_hit},
		})
	inst.components.projectile:SetHitDist(2)
	WARGON.per_task(inst, .1, function()
		local fx = WARGON.make_fx(inst, 'tp_fx_sign')
		WARGON.do_task(fx, .5, function()
			fx:Remove()
		end)
	-- 	local ents = WARGON.finds(inst, .5, nil, {"beefalo", "wall", "FX", "NOCLICK", "INLIMBO"})
	-- 	for i, v in pairs(ents) do
	-- 		if attacker then
	-- 			if v.components.combat and v.components.health
	-- 			and attacker.components.combat:CanTarget(v) then
	-- 				v.components.combat:GetAttacked(attacker, 10, nil, 'tp_sign_rider')
	-- 			end
	-- 		end
	-- 	end
	end)

	return inst
end

return 
	Prefab('common/tp_sign_rider', fn, {}),
	Prefab('common/inventory/tp_sign_proj', proj, {})