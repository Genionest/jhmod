local assets = {

}

local wendys = {'wilson', 'wendy', 'idle_loop'}
local phys = {"char", 75, .5}
local shadows = {1.3, .6}
local spear_lances = {'tp_spear_lance', 'tp_spear_lance', 'throw'}

local function hornet_combat_re(inst)
	return WARGON.find(inst, 16*1.33, function(guy)
        return inst.components.combat:CanTarget(guy)
           and guy:HasTag("player")
    end)
end

local function hornet_combat_keep(inst, target)
	return inst.components.combat:CanTarget(target)
       and target:HasTag("player")
end

local function hornet_on_attacked(inst, data)
	if data.attacker then
		inst.components.combat:SetTarget(data.attacker)
	end
end

local function hornet_on_hit_other(inst, data)
	if math.random() < .33 and data.target.components.tpbuff then
		data.target.components.tpbuff:AddBuff("tp_hurt")
	end
end

local function hornet_weapon_drop(inst)
	inst:Remove()
end

local function hornet_equip_weapon(inst)
	inst:AddTag("tp_hornet_fast")
	if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
		local weapon = CreateEntity()
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(150)
        weapon.components.weapon:SetRange(7, 10)
        weapon.components.weapon:SetProjectile("tp_hornet_proj")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(hornet_weapon_drop)
        weapon:AddComponent("equippable")
        
        inst.components.inventory:Equip(weapon)
	end
end

local function hornet_on_health_delta(inst)
	if inst.components.health:GetPercent() < .3 then
		hornet_equip_weapon(inst)
	end
end

local function fn()
	local inst = WARGON.make_prefab(wendys, nil, phys, shadows, 4)
	inst:AddTag("tp_sign_damage")
	inst:AddTag("epic")
	inst:AddTag("tp_only_player_attack")
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		health = {max=2250, fire=0, regen={20, 5}},
		loco = {walk=4, run=6},
		combat = {
			dmg=150, player=.5, per=3,
			re={time=3, fn=hornet_combat_re},
			keep=hornet_combat_keep,
		},
		loot = {loot={
			"tp_epic", "tp_epic", "tp_epic", "tp_epic", "tp_epic", 
			"tp_cane"}, },
		inv = {},
	})
	WARGON.EQUIP.body_on(inst, "armor_vortex_cloak", "swap_body")
	WARGON.EQUIP.hat_on(inst, "hat_bandit", nil, true)
	WARGON.EQUIP.object_on(inst, "tp_spear_lance", "swap_object")
	WARGON.add_listen(inst, {
		attacked = hornet_on_attacked,
		onhitother = hornet_on_hit_other,
		healthdelta = hornet_on_health_delta,
	})
	WARGON.do_task(inst, 0, function()
		hornet_on_health_delta(inst)
	end)
	inst:SetBrain(require "brains/tp_fake_knight_brain")
	inst:SetStateGraph("SGtp_hornet")

	return inst
end

local function hornet_proj_hit(inst)
	inst:Remove()
end

local function proj()
	local inst = WARGON.make_prefab(spear_lances, nil, 'inv')
	RemovePhysicsColliders(inst)
	inst:AddTag('projectile')
	WARGON.no_save(inst)
	WARGON.CMP.add_cmps(inst, {
		proj = {speed=20, hit=hornet_proj_hit},
		})
	inst.components.projectile:SetHitDist(3)
	-- WARGON.per_task(inst, .1, function()
		-- local fx = WARGON.make_fx(inst, 'tp_fx_sign')
		-- WARGON.do_task(fx, .5, function()
		-- 	fx:Remove()
		-- end)
	-- end)

	return inst
end

return 
	Prefab("common/tp_hornet", fn, assets),
	Prefab("tp_hornet_proj", proj, {})