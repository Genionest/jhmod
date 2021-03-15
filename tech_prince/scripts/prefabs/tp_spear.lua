local Anims = {
	spear_lance = {"tp_spear_lance", "tp_spear_lance", "idle", "idle_water"},
	spear_ice = {"tp_spear_ice", "tp_spear_ice", "idle", "idle_water"},
	spear_fire = {"tp_spear_fire", "tp_spear_fire", "idle", "idle_water"},
	spear_thunder = {"tp_spear_thunder", "tp_spear_thunder", "idle", "idle_water"},
	spear_gungnir = {"spear", "spear_forge_gungnir", "idle", "idle_water"},
	spear_poison = {"tp_spear_poison", "tp_spear_poison", "idle", "idle_water"},
	spear_shadow = {"tp_spear_shadow", "tp_spear_shadow", "idle", "idle_water"},
	spear_blood = {"tp_spear_blood", "tp_spear_blood", "idle", "idle_water"},
	spear_rose = {"spear", "spear_rose", "idle", "idle_water"},
	spear_wind = {'tp_spear_wind', 'tp_spear_wind', 'idle', 'idle_water'},
	spear_wrestle = {'spear_wathgrithr', "spear_wathgrithr_wrestle", "idle", "idle_water"},
	spear_lightning = {'tp_spear_lightning', 'tp_spear_lightning', 'idle', 'idle_water'},
	spear_speed = {'tp_spear_speed', 'tp_spear_speed', 'idle', 'idle_water'},
	spear_earth = {'tp_spear_earth', 'tp_spear_earth', 'idle', 'idle_water'},
	spear_shine = {'tp_spear_shine', 'tp_spear_shine', 'idle', 'idle_water'},
	spear_northern = {'spear', 'spear_northern', 'idle', 'idle_water'},
	spear_simple = {"spear", "spear_simple", "idle", "idle_water"},
	spear_bag = {"tp_spear_bag", "tp_spear_bag", "idle", "idle_water"},
	spear_beefalo = {"tp_spear_beefalo", "tp_spear_beefalo", "idle", "idle_water"},
	spear_combat = {"tp_spear_combat", "tp_spear_combat", "idle", "idle_water"},
	spear_diamond = {"tp_spear_diamond", "tp_spear_diamond", "idle", "idle_water"},
	spear_gold = {"tp_spear_gold", "tp_spear_gold", "idle", "idle_water"},
	spear_tornado = {"tp_spear_tornado", "tp_spear_tornado", "idle", "idle_water"},
	spear_conqueror = {"tp_spear_conqueror", "tp_spear_conqueror", "idle", "idle_water"},
	spear_hockey = {"spear", "spear_hockey", "idle", "idle_water"},
}

local function do_area_damage(inst, range, dmg, reason, fn)
	local owner = inst.components.inventoryitem.owner
	WARGON.area_dmg(inst, range, owner, dmg, reason, fn)
end

local function do_area(inst, range, fn)
	local owner = inst.components.inventoryitem.owner
	local ents = WARGON.finds(inst, range, nil, {"player", "wall", "FX", "NOCLICK", "INLIMBO"})
	for i, v in pairs(ents) do
		if not v.components.follower or v.components.follower.leader ~= owner then
			if v.components.combat and v.components.health
			and owner.components.combat:CanTarget(v) then
				fn(inst, v)
			end
		end
	end
end

local function mk_lv_dmg(inst, owner, target)
	-- local dmg = owner.components.tplevel.attr.forge
	-- target.components.health:DoDelta(-dmg)
end

local function on_finish(inst)
	inst:Remove()
end

local function head_unequip(inst, owner)
	WARGON.EQUIP.hat_off(owner)
	if inst.components.fueled then
		inst.components.fueled:StopConsuming()
	end
end

local function hand_unequip(inst, owner)
	WARGON_EQUIP_EX.object_off(owner)
end

-- spear lance
local function spear_lance_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "swap_spear_forge_lance", "swap_spear")
end

local function spear_throw(inst)
	inst:AddTag("projectile")
	inst.AnimState:PlayAnimation("throw")
	-- if inst.components.floatable then
	-- 	inst.components.floatable:UpdateAnimations("idle_water", "BUILD")
	-- end
end

local function spear_drop(inst)
	inst:RemoveTag("projectile")
	if inst.components.floatable then
		-- inst.components.floatable:UpdateAnimations("idle_water", "idle")
		inst.components.floatable:SetAnimationFromPosition()
	end
end

local function spear_hit(inst, owner, target)
	WARGON.FX.impact_fx(inst, target)
	spear_drop(inst)
end

local function spear_catch(inst, owner)
	inst:RemoveTag("projectile")
	if owner.components.inventory then
		if owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil then
			owner.components.inventory:Equip(inst)
		else
			owner.components.inventory:GiveItem(inst)
		end
	end
	if owner.components.tpbuff then
		owner.components.tpbuff:AddBuff("tp_pack_catcoon")
	end
end

local function set_spear_proj(inst)
	inst:AddComponent("tpproj")
	inst.components.tpproj:SetSpeed(25)
	inst.components.tpproj:SetOnThrownFn(spear_throw)
	inst.components.tpproj:SetOnHitFn(function(...)
		inst.components.weapon.onattack(...)
		spear_hit(...)
	end)
	inst.components.tpproj:SetOnMissFn(spear_drop)
	inst.components.tpproj:SetLaunchOffset(Vector3(0, 0.2, 0))
end

local function set_spear_lunge(inst)
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_CI"
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(10)
		inst:StartThread(function()
			for i = 1, 3 do
				do_area_damage(inst, 1.5, 34, inst.prefab)
				local fx = WARGON.make_fx(inst, "tp_fx_wilson_lunge")
				local owner = inst.components.inventoryitem.owner
				fx.AnimState:SetBuild(owner.components.sciencemorph:GetBuild())
				fx.Transform:SetRotation(owner.Transform:GetRotation())
				WARGON.EQUIP.object_on(fx, "swap_spear_forge_gungnir", "swap_spear_gungnir")
				Sleep(0.1)
			end
		end)
	end
end

local function spear_lance_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34, },
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		equip = {equip=spear_lance_equip, unequip=hand_unequip},
	})
	inst:AddComponent("tpproj")
	inst.components.tpproj:SetSpeed(25)
	inst.components.tpproj:SetOnThrownFn(spear_throw)
	inst.components.tpproj:SetOnHitFn(spear_hit)
	inst.components.tpproj:SetOnMissFn(spear_drop)
	inst.components.tpproj:SetLaunchOffset(Vector3(0, 0.2, 0))
	inst.components.tpproj.oncatch = spear_catch
end

local function spear_ice_fx_add(inst)
	-- if inst.fx == nil then
	-- 	inst.fx = SpawnPrefab("tp_snow_fx")
	-- 	inst:AddChild(inst.fx)
	-- 	inst.fx.Transform:SetPosition(0, 1, 0)
	-- end
end

local function spear_ice_fx_remove(inst)
	-- if inst.fx then
	-- 	inst.fx:Remove()
	-- 	inst.fx = nil
	-- end
end

local function spear_ice_inv_drop(inst)
	spear_ice_fx_add(inst)
end

local function spear_ice_inv_put(inst)
	spear_ice_fx_remove(inst)
end

local function spear_ice_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_ice", "swap_object")
	spear_ice_fx_add(inst)
	owner:AddTag("tp_spear_ice")
end

local function spear_ice_unequip(inst, owner)
	hand_unequip(inst, owner)
	spear_ice_fx_remove(inst)
	owner:RemoveTag("tp_spear_ice")
end

local function spear_ice_weapon_fn(inst, owner, target)
	-- mk_lv_dmg(inst, owner, target)
	WARGON.frozen_prefab(target, owner)
	WARGON.make_fx(target, "icespike_fx_"..math.random(1, 4))
end

local function spear_ice_proj_throw(inst)
	-- inst:AddTag("projectile")
	spear_throw(inst)
	if inst.fx == nil then
		inst.fx = SpawnPrefab("tp_fx_snow_line")
		inst:AddChild(inst.fx)
	end
end

local function spear_ice_proj_drop(inst)
	-- inst:RemoveTag("projectile")
	spear_drop(inst)
	if inst.fx then
		inst.fx:kill(inst.fx)
		inst.fx = nil
	end
end

local function spear_ice_proj_hit(inst, owner, target)
	WARGON.FX.impact_fx(inst, target)
	spear_ice_proj_drop(inst)
	spear_ice_weapon_fn(inst, owner, target)
end

local function spear_ice_proj_catch(inst, owner)
	if owner.components.inventory
	and owner.components.inventory:IsFull() == false then
		spear_catch(inst, owner)
		if inst.fx then
			inst.fx:kill(inst.fx)
			inst.fx = nil
		end
	else
		spear_ice_proj_drop(inst)
	end
end

local function spear_ice_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34, fn=spear_ice_weapon_fn},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		equip = {equip=spear_ice_equip, unequip=spear_ice_unequip},
		inv = {drop=spear_ice_inv_drop, put=spear_ice_inv_put},
	})
	inst:AddComponent("tpproj")
	inst.components.tpproj:SetSpeed(25)
	inst.components.tpproj:SetOnThrownFn(spear_ice_proj_throw)
	inst.components.tpproj:SetOnHitFn(spear_ice_proj_hit)
	inst.components.tpproj:SetOnMissFn(spear_ice_proj_drop)
	inst.components.tpproj:SetLaunchOffset(Vector3(0, 0.2, 0))
	inst.components.tpproj.oncatch = spear_ice_proj_catch
	inst:AddTag("tp_catcoon_spear")
	inst:AddTag("tp_forge_weapon")
end

local function spear_fire_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_fire", "swap_object")
	owner:AddTag("tp_spear_fire")
end

local function spear_fire_unequip(inst, owner)
	hand_unequip(inst, owner)
	owner:RemoveTag("tp_spear_fire")
end

local function spear_fire_weapon_fn(inst, owner, target)
	-- mk_lv_dmg(inst, owner, target)
	WARGON.fire_prefab(target, owner)
	local fx = WARGON.make_fx(target, "firesplash_fx")
	local s = .5
	fx.Transform:SetScale(s,s,s)
end

local function spear_fire_throw(inst)
	-- inst:AddTag("projectile")
	spear_throw(inst)
	if inst.fx == nil then
		inst.fx = SpawnPrefab("tp_fx_fire_line")
		inst:AddChild(inst.fx)
	end
end

local function spear_fire_drop(inst)
	-- inst:RemoveTag("projectile")
	spear_drop(inst)
	if inst.fx then
		inst.fx:Remove()
		inst.fx = nil
	end
end

local function spear_fire_hit(inst, owner, target)
	WARGON.FX.impact_fx(inst, target)
	spear_fire_drop(inst)
	spear_fire_weapon_fn(inst, owner, target)
end

local function spear_fire_catch(inst, owner)
	if owner.components.inventory
	and owner.components.inventory:IsFull() == false then
		spear_catch(inst, owner)
		if inst.fx then
			inst.fx:Remove()
			inst.fx = nil
		end
	else
		spear_fire_drop(inst)
	end
end

local function spear_fire_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34, fn=spear_fire_weapon_fn},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		equip = {equip=spear_fire_equip, unequip=spear_fire_unequip},
	})
	inst:AddComponent("tpproj")
	inst.components.tpproj:SetSpeed(25)
	inst.components.tpproj:SetOnThrownFn(spear_fire_throw)
	inst.components.tpproj:SetOnHitFn(spear_fire_hit)
	inst.components.tpproj:SetOnMissFn(spear_fire_drop)
	inst.components.tpproj:SetLaunchOffset(Vector3(0, 0.2, 0))
	inst.components.tpproj.oncatch = spear_fire_catch
	inst:AddTag("tp_catcoon_spear")
	inst:AddTag("tp_forge_weapon")
end

local function spear_thunder_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_thunder", "swap_object")
end

local function spear_thunder_weapon_fn(inst, owner, target)
	local function is_target(target, inst)
        if target.components.combat and target.components.health
        and owner.components.combat:CanTarget(target)
        and target.components.follower
        and target.components.follower.leader ~= owner then
            return true
        end
	end
	WARGON.FX.sparks_fx(inst, target)
    local new_target = WARGON.find(target, 5, is_target, nil, 
        {"player", "wall", "companion", "FX", "NOCLICK", "INLIMBO"})
    if new_target then
        local proj = WARGON.make_spawn(target, "tp_charge_proj")
        proj.master = owner
        table.insert(proj.no_targets, target)
        proj.components.tpproj:Throw(owner, new_target, owner)
    end
end

local function spear_thunder_throw(inst)
	-- inst:AddTag("projectile")
	spear_throw(inst)
	inst.fx = SpawnPrefab("shock_fx")
	inst:AddChild(inst.fx)
	inst.fx.Transform:SetPosition(0, -1, 0)
end

local function spear_thunder_drop(inst)
	-- inst:RemoveTag("projectile")
	spear_drop(inst)
	if inst.fx then
		inst.fx:Remove()
		inst.fx = nil
	end
end

local function spear_thunder_hit(inst, owner, target)
	WARGON.FX.impact_fx(inst, target)
	spear_thunder_weapon_fn(inst, owner, target)
	spear_thunder_drop(inst)
end

local function spear_thunder_catch(inst, owner)
	if owner.components.inventory
	and owner.components.inventory:IsFull() == false then
		spear_catch(inst, owner)
		if inst.fx then
			inst.fx:Remove()
			inst.fx = nil
		end
	else
		spear_thunder_drop(inst)
	end
end

local function spear_thunder_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34*.75, fn=spear_thunder_weapon_fn},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		equip = {equip=spear_thunder_equip, unequip=hand_unequip},
	})
	inst.components.weapon:SetElectric()
	inst:AddComponent("tpproj")
	inst.components.tpproj:SetSpeed(25)
	inst.components.tpproj:SetOnThrownFn(spear_thunder_throw)
	inst.components.tpproj:SetOnHitFn(spear_thunder_hit)
	inst.components.tpproj:SetOnMissFn(spear_thunder_drop)
	inst.components.tpproj:SetLaunchOffset(Vector3(0, 0.2, 0))
	inst.components.tpproj.oncatch = spear_thunder_catch
	inst:AddTag("tp_catcoon_spear")
end

local function spear_trap_weapon_fn(inst, owner, target)
	-- mk_lv_dmg(inst, owner, target)
	if math.random() < .25 then
		if not target:wg_find(1.5, nil, {"tp_trap_teeth"})
		and target:on_land() then
			local trap = WARGON.make_spawn(target, "trap_teeth")
			trap.AnimState:SetBuild("trap_teeth_tiger")
			trap.components.dsskins.skin = "trap_teeth_tiger"
			trap.components.mine:Reset()
		end
	end
end

local function spear_trap_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "swap_spear_rose", "swap_spear")
end

local function spear_trap_unequip(inst, owner)
	hand_unequip(inst, owner)
end

local function spear_trap_throw(inst)
	inst:AddTag("projectile")
	spear_throw(inst)
end

local function spear_trap_drop(inst)
	inst:RemoveTag("projectile")
	spear_drop(inst)
end

local function spear_trap_hit(inst, owner, target)
	WARGON.FX.impact_fx(inst, target)
	spear_trap_weapon_fn(inst, owner, target)
	spear_trap_drop(inst)
end

local function spear_trap_catch(inst, owner)
	if owner.components.inventory
	and owner.components.inventory:IsFull() == false then
		spear_catch(inst, owner)
	else
		spear_trap_drop(inst)
	end
end

local function spear_trap_fn(inst)
	inst:add_cmps({
		inspect = {},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		weapon = {dmg=34, fn=spear_trap_weapon_fn},
		equip = {equip=spear_trap_equip, unequip=spear_trap_unequip},
	})
	set_spear_proj(inst)
	inst:AddTag("tp_catcoon_spear")
	inst:AddTag("tp_forge_weapon")
end

local function spear_combat_weapon_fn(inst, owner, target)
	-- mk_lv_dmg(inst, owner, target)
	if owner.components.tpbuff then
		owner.components.tpbuff:AddBuff("tp_spear_combat")
	end
end

local function spear_combat_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_combat", "swap_object")
end

local function spear_combat_unequip(inst, owner)
	hand_unequip(inst, owner)
end

local function spear_combat_throw(inst)
	inst:AddTag("projectile")
	spear_throw(inst)
end

local function spear_combat_drop(inst)
	inst:RemoveTag("projectile")
	spear_drop(inst)
end

local function spear_combat_hit(inst, owner, target)
	WARGON.FX.impact_fx(inst, target)
	spear_combat_weapon_fn(inst, owner, target)
	spear_combat_drop(inst)
end

local function spear_combat_catch(inst, owner)
	if owner.components.inventory
	and owner.components.inventory:IsFull() == false then
		spear_catch(inst, owner)
	else
		spear_combat_drop(inst)
	end
end

local function spear_combat_fn(inst)
	inst:add_cmps({
		inspect = {},
		weapon = {dmg=34, fn=spear_combat_weapon_fn},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		equip = {equip=spear_combat_equip, unequip=spear_combat_unequip},
	})
	set_spear_proj(inst)
	inst:AddTag("tp_catcoon_spear")
	inst:AddTag("tp_forge_weapon")
end

-- spear gungnir
local function spear_gungnir_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "swap_spear_forge_gungnir", "swap_spear_gungnir")
end

local function spear_gungnir_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34, },
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		equip = {equip=spear_gungnir_equip, unequip=hand_unequip},
	})
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_CI"
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(10)
		inst:StartThread(function()
			for i = 1, 3 do
				do_area_damage(inst, 1.5, 34, "tp_spear_gungnir")
				local fx = WARGON.make_fx(inst, "tp_fx_wilson_lunge")
				local owner = inst.components.inventoryitem.owner
				fx.AnimState:SetBuild(owner.components.sciencemorph:GetBuild())
				fx.Transform:SetRotation(owner.Transform:GetRotation())
				WARGON.EQUIP.object_on(fx, "swap_spear_forge_gungnir", "swap_spear_gungnir")
				Sleep(0.1)
			end
		end)
	end
end

local function spear_poison_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_poison", "swap_object")
end

local function spear_poison_weapon_fn(inst, owner, target)
	-- mk_lv_dmg(inst, owner, target)
	WARGON.poison_prefab(target)
	WARGON.add_speed_rate(target, "tp_spear_poison", -.25)
	local pt = target:GetPosition()
	pt.y = pt.y + 1
	WARGON.make_fx(pt, "spat_splash_fx_full")
end

local function spear_poison_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34, fn=spear_poison_weapon_fn},
		finite = {max=300, use=300, fn=on_finish},
		equip = {equip=spear_poison_equip, unequip=hand_unequip},
	})
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_CI"
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(10)
		inst:StartThread(function()
			for i = 1, 3 do
				local function area_poison(inst, target)
					WARGON.poison_prefab(target)
				end
				do_area(inst, 1.5, area_poison)
				do_area_damage(inst, 1.5, 34, "tp_spear_poison")
				local fx = WARGON.make_fx(inst, "tp_fx_poison_bubble")
				-- local s = .5
				-- fx.Transform:SetScale(s,s,s)
				Sleep(0.1)
			end
		end)
	end
	-- inst:AddTag("tp_catcoon_spear")
	inst:AddTag("tp_forge_weapon")
end

local function spear_shadow_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_shadow", "swap_object")
end

local function spear_shadow_weapon_fn(inst, owner, target)
	-- mk_lv_dmg(inst, owner, target)
	if target:HasTag("shadowcreature") then
		if target.components.health then
			target.components.health:Kill()
			owner.components.sanity:DoDelta(20)
		end
		WARGON.make_fx(owner, "sanity_raise")
	-- else
	-- 	local per = owner.components.sanity:GetPercent()
	-- 	local amount = per * 100
	-- 	target.components.health:DoDelta(-amount)
	end
	WARGON.make_fx(target, "statue_transition_2")
end

local function spear_shadow_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=1, fn=spear_shadow_weapon_fn},
		finite = {max=300, use=300, fn=on_finish},
		equip = {equip=spear_shadow_equip, unequip=hand_unequip, effect={san=-TUNING.SANITYAURA_LARGE}},
	})
	inst.components.weapon.getdamagefn = function(inst)
		local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
		local dmg = 1
		if owner then
			local p = owner.components.sanity:GetPercent()
			dmg = 1 + p * 100
		end
		return dmg
	end
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_CI"
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(10)
		inst:StartThread(function()
			for i = 1, 3 do
				local function area_shadow(inst, target)
					local owner = inst.components.inventoryitem.owner
					owner.components.sanity:DoDelta(5)
				end
				do_area(inst, 1.5, area_shadow)
				do_area_damage(inst, 1.5, 34, "tp_spear_shadow", 
					function(inst, attacker, target)
						if target:HasTag("shadowcreature") then
							if target.components.health then
								target.components.health:Kill()
								if attacker.components.sanity then
									attacker.components.sanity:DoDelta(20)
								end
							end
						end
					end
				)
				local fx = WARGON.make_fx(inst, "statue_transition")
				Sleep(0.1)
			end
		end)
	end
	-- inst:AddTag("tp_catcoon_spear")
end

local function spear_blood_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_blood", "swap_object")
	owner:AddTag("tp_spear_blood")
	WARGON.EQUIP.tp_health_equip_complete(owner)
end

local function spear_blood_unequip(inst, owner)
	hand_unequip(inst, owner)
	owner:RemoveTag("tp_spear_blood")
	WARGON.EQUIP.tp_health_equip_incomplete(owner)
end

local function spear_blood_weapon_fn(inst, owner, target)
	-- local owner = inst.components.inventoryitem.owner
	-- mk_lv_dmg(inst, owner, target)
	if target:HasTag('epic') then
		owner.components.health:DoDelta(20, nil, "tp_health_equip")
	elseif target:HasTag("largecreature") then
		owner.components.health:DoDelta(15, nil, "tp_health_equip")
	else
		owner.components.health:DoDelta(10, nil, "tp_health_equip")
	end
	WARGON.make_fx(owner, "tp_fx_blood")
	WARGON.make_fx(target, "feathers_packim_fire")
end

local function spear_blood_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34, fn=spear_blood_weapon_fn},
		finite = {max=300, use=300, fn=on_finish},
		equip = {equip=spear_blood_equip, unequip=spear_blood_unequip},
	})
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_CI"
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(10)
		inst:StartThread(function()
			for i = 1, 3 do
				local function area_blood(inst, target)
					local owner = inst.components.inventoryitem.owner
					owner.components.health:DoDelta(10, nil, "tp_health_equip")
				end
				do_area(inst, 1.5, area_blood)
				do_area_damage(inst, 1.5, 34, "tp_spear_blood")
				local fx = WARGON.make_fx(inst, "tp_blood_fx")
				-- local fx2= WARGON.make_fx(inst, "feathers_packim_fire")
				Sleep(0.1)
			end
		end)
	end
	-- inst:AddTag("tp_catcoon_spear")
end

local function spear_gold_kill_reward(inst, data)
	if data.victim then
		if data.victim:HasTag("epic") then
			c_give("oinc10", 5)
		elseif data.victim:HasTag("largecreature") then
			c_give("oinc10")
		elseif data.victim:HasTag("monster") then
			c_give("oinc")
		end
	end
end

local function spear_gold_weapon_fn(inst, owner, target)
	-- mk_lv_dmg(inst, owner, target)
end

local function spear_gold_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_gold", "swap_object")
	owner:add_listener("killed", spear_gold_kill_reward)
end

local function spear_gold_unequip(inst, owner)
	hand_unequip(inst, owner)
	owner:rm_listener("killed", spear_gold_kill_reward)
end

local function spear_gold_fn(inst)
	inst:add_cmps({
		inspect = {},
		weapon = {dmg=34, fn=spear_gold_weapon_fn},
		finite = {max=300, use=300, fn=on_finish},
		equip = {equip=spear_gold_equip, unequip=spear_gold_unequip},
	})
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_CI"
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	set_spear_lunge(inst)
	inst:AddTag("tp_forge_weapon")
end

-- spear wrestle
local function spear_wrestle_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "swap_spear_wathgrithr_wrestle", "swap_spear_wathgrithr")
end

local function spear_wrestle_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34, },
		finite = {max=150, use=150, fn=on_finish},
		equip = {equip=spear_wrestle_equip, unequip=hand_unequip},
	})
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_ZHUAN"
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(10)
		do_area_damage(inst, 3.5, 34, "tp_spear_wrestle")
	end
end

local function spear_lightning_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_lightning", "swap_object")
end

local function spear_lightning_weapon_fn(inst, owner, target)
	-- mk_lv_dmg(inst, owner, target)
	if math.random() < .33 then
		-- WARGON.make_fx(target, "lightning")
        local pos = Vector3(target.Transform:GetWorldPosition())
        GetSeasonManager():DoLightningStrike(pos, false, target) 
	end
end

local function spear_lightning_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34, fn=spear_lightning_weapon_fn,},
		finite = {max=150, use=150, fn=on_finish},
		equip = {equip=spear_lightning_equip, unequip=hand_unequip},
	})
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_ZHUAN"
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(10)
		do_area_damage(inst, 3.5, 34, "tp_spear_lightning")
		local num_lightnings =  3
	    inst:StartThread(function()
	        for k = 0, num_lightnings do
	            local rad = math.random(3, 15)
	            local angle = k*((4*PI)/num_lightnings)
	            local pos = Vector3(inst.Transform:GetWorldPosition()) + Vector3(rad*math.cos(angle), 0, rad*math.sin(angle))
	            GetSeasonManager():DoLightningStrike(pos)
	            Sleep(math.random( .3, .5))
	        end
	    end)
	end
	inst:AddTag("tp_forge_weapon")
end

local function spear_speed_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, 'tp_spear_speed', 'swap_object')
end

local function spear_speed_weapon_fn(inst, owner, target)
	if owner and owner.components.tpbuff then
		owner.components.tpbuff:AddBuff("tp_spear_speed")
	end
end

local function spear_speed_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34, fn=spear_speed_weapon_fn},
		finite = {max=150, use=150, fn=on_finish},
		equip = {equip=spear_speed_equip, unequip=hand_unequip},
	})
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_ZHUAN"
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(10)
		do_area_damage(inst, 3.5, 34, "tp_spear_speed", 
			function(inst, attacker, target)
				if attacker and attacker.components.tpbuff then
					attacker.components.tpbuff:AddBuff("tp_spear_speed")
				end
			end)
	end
end

local function spear_earth_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, 'tp_spear_earth', 'swap_object')
end

local function spear_earth_weapon_fn(inst, owner, target)
	inst.components.tpgroundpounder:GroundPound()
end

local function spear_earth_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		combat = {dmg=17.5,},
		weapon = {dmg=34, fn=spear_earth_weapon_fn},
		finite = {max=150, use=150, fn=on_finish},
		equip = {equip=spear_earth_equip, unequip=hand_unequip},
	})
	inst:AddComponent("tpgroundpounder")
	inst.components.tpgroundpounder.destroyer = true
    inst.components.tpgroundpounder.damageRings = 1
    inst.components.tpgroundpounder.destructionRings = 1
    inst.components.tpgroundpounder.numRings = 1
    inst.components.tpgroundpounder.groundpoundfx = "tp_fx_small_ground_pound"
    inst.components.tpgroundpounder.groundpoundringfx = "tp_fx_small_ground_pound_ring"
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_ZHUAN"
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(10)
		do_area_damage(inst, 3.5, 34, "tp_spear_earth")
		inst.components.tpgroundpounder:GroundPound()
	end
end

local function spear_shine_turn_on(inst)
	if not inst.components.fueled:IsEmpty() then
		inst.components.fueled:StartConsuming()
		inst.Light:Enable(true)
	end
end

local function spear_shine_turn_off(inst)
	inst.components.fueled:StopConsuming()
	inst.Light:Enable(false)
end

local function spear_shine_perish(inst)
	spear_shine_turn_off(inst)
	inst:Remove()
end

local function spear_shine_unequip(inst, owner)
	hand_unequip(inst, owner)
	spear_shine_turn_off(inst)
end

local function spear_shine_add_fuel(inst)
	inst.components.fueled:DoDelta(60)
	spear_shine_turn_on(inst)
end

local function spear_shine_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, 'tp_spear_shine', 'swap_object')
	spear_shine_turn_on(inst)
end

local function spear_shine_weapon_fn(inst, owner, target)
	-- mk_lv_dmg(inst, owner, target)
	spear_shine_add_fuel(inst)
end

local function spear_shine_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34, fn=spear_shine_weapon_fn},
		-- finite = {max=150, use=150, fn=on_finish},
		equip = {equip=spear_shine_equip, unequip=hand_unequip},
		invitem = {drop=spear_shine_turn_off},
	})
	
	local light = inst.entity:AddLight()
	light:SetFalloff(0.4)
	light:SetIntensity(.7)
	light:SetRadius(2.5)
	light:SetColour(180/255, 195/255, 150/255)
	light:Enable(false)

	inst:AddComponent("fueled")
	inst.components.fueled:InitializeFuelLevel(TUNING.MINERHAT_LIGHTTIME)
	inst.components.fueled:SetDepletedFn(spear_shine_perish)

	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_ZHUAN"
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(10)
		do_area_damage(inst, 3.5, 34, "tp_spear_shine", 
			function(inst, attacker, target)
				spear_shine_add_fuel(inst)
			end)
		-- spear_shine_add_fuel(inst)
	end
	inst:AddTag("tp_forge_weapon")
end

local function spear_tornado_weapon_fn(inst, owner, target)
	if math.random() < .15 then
		WARGON.spawn_tornado(owner, target)
	end
	-- mk_lv_dmg(inst, owner, target)
end

local function spear_tornado_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_tornado", "swap_object")
end

local function spear_tornado_unequip(inst, owner)
	hand_unequip(inst, owner)
end

local function spear_tornado_fn(inst)
	inst:add_cmps({
		inspect = {},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		weapon = {dmg=34, fn=spear_tornado_weapon_fn},
		equip = {equip=spear_tornado_equip, unequip=spear_tornado_unequip},
	})
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_ZHUAN"
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(10)
		local owner = inst.components.inventoryitem.owner
		WARGON.spawn_tornado(owner)
	end
	inst:AddTag("tp_forge_weapon")
end

local function spear_shoot_weapon_fn(inst, owner, target)
end

local function spear_shoot_ball(inst, owner)
	local player = owner
    local rotation = player.Transform:GetRotation()
    local beam = SpawnPrefab("tp_spear_shoot_ball")
    local pt = Vector3(player.Transform:GetWorldPosition())
    local angle = rotation * DEGREES
    local radius = 2.5
    local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
    local newpt = pt+offset

    beam.Transform:SetPosition(newpt.x,1,newpt.z)
    beam.host = player
    beam.Transform:SetRotation(rotation)
    beam.AnimState:PlayAnimation("idle",true) 
    beam.components.combat.proxy = inst
end

local function spear_shoot_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "swap_spear_hockey", "swap_spear")
end

local function spear_shoot_unequip(inst, owner)
	WARGON.EQUIP.object_off(owner)
end

local function spear_shoot_fn(inst)
	inst:add_cmps({
		inspect = {},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		weapon = {dmg=34, fn=spear_shoot_weapon_fn},
		equip = {equip=spear_shoot_equip, unequip=spear_shoot_unequip},
	})
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(2)
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_ZHUAN"
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(2)
		local owner = inst.components.inventoryitem.owner
		if owner.components.inventory:Has("lightbulb", 1) then
			owner.components.inventory:ConsumeByName("lightbulb", 1)
			spear_shoot_ball(inst, owner)
		end
	end
end

-- local function spear_wind_throw(inst, owner, target)
-- 	inst:AddTag("projectile")
-- 	if inst.task == nil then
-- 		inst.task = WARGON.per_task(inst, .1, function()
-- 			WARGON.make_fx(inst, "tp_fx_leaf_"..math.random(4))
-- 		end)
-- 	end
-- end

-- local function spear_wind_drop(inst)
-- 	inst:RemoveTag("projectile")
-- 	if inst.task then
-- 		inst.task:Cancel()
-- 		inst.task = nil
-- 	end
-- 	if inst.components.floatable then
-- 		inst.components.floatable:SetAnimationFromPosition()
-- 	end
-- end

-- local function spear_wind_hit(inst, owner, target)
-- 	WARGON_FX_EX.impact_fx(inst, target)
-- 	spear_wind_drop(inst)
-- end

local function spear_wind_equip(inst, owner)
	WARGON_EQUIP_EX.object_on(owner, "swap_spear_wind", "swap_object")
	if inst.fx == nil then
		local pt = owner:GetPosition()
		pt.x = pt.x + 5
		inst.fx = WARGON.make_fx(pt, "tp_fx_leaf_circle")
		inst.fx.master = owner
		inst.fx:start_task(inst.fx)
	end
	owner:AddTag("tp_spear_wind")
end

local function spear_wind_unequip(inst, owner)
	hand_unequip(inst, owner)
	if inst.fx then
		inst.fx:Remove()
		inst.fx = nil
	end
	owner:RemoveTag("tp_spear_wind")
end

local function spear_wind_weapon_fn(inst, owner, target)
	if inst.fx then
		inst.fx:stop_task(inst.fx)
		inst.fx:ForceFacePoint(target:GetPosition())
		inst.fx:start_task2(inst.fx)
	end
end

local function spear_wind_fn(inst)
	WARGON_CMP_EX.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=0, fn=spear_wind_weapon_fn, range={8,10}},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		equip = {equip=spear_wind_equip, unequip=spear_wind_unequip},
		water = {value=TUNING.WATERPROOFNESS_SMALL},
	})
	-- inst:AddComponent("tpproj")
	-- inst.components.tpproj:SetSpeed(25)
	-- inst.components.tpproj:SetOnThrownFn(spear_wind_throw)
	-- inst.components.tpproj:SetOnHitFn(spear_wind_hit)
	-- inst.components.tpproj:SetOnMissFn(spear_wind_drop)
	-- inst.components.tpproj:SetLaunchOffset(Vector3(0, 0.2, 0))
	-- WARGON.add_tags(inst, {"thrown", "projectile"})
end

local function spear_mix_weapon_fn(inst, owner, target, projectile)
end

local function spear_mix_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "swap_spear_northern", "swap_spear")
end

local function spear_mix_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=1, fn=spear_mix_weapon_fn},
		finite = {max=1, use=1, fn=on_finish},
		equip = {equip=spear_mix_equip, unequip=hand_unequip},
		tpmixweapon = {},
	})
	-- inst.components.tpmixweapon:SetWeapons({'spear', 'hambat', 'ruins_bat'})
end

local function spear_diamond_weapon_fn(inst, owner, target)
	-- mk_lv_dmg(inst, owner, target)
end

local function spear_diamond_broke(inst, data)
	if inst.components.health then
		inst:do_task(.1, function()
			inst.components.health:Kill()
		end)
	end
end

local function spear_diamond_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_diamond", "swap_object")
	owner:add_listener("armorbroke", spear_diamond_broke)
end

local function spear_diamond_unequip(inst, owner)
	hand_unequip(inst, owner)
	owner:rm_listener("armorbroke", spear_diamond_broke)
end

local function spear_diamond_fn(inst)
	inst:AddTag("tp_not_fix")
	inst:add_cmps({
		inspect = {},
		weapon = {dmg=34, fn=spear_diamond_weapon_fn},
		equip = {equip=spear_diamond_equip, unequip=spear_diamond_unequip},
		armor = {armor=800, absorb=1},
	})
	inst:AddTag("tp_forge_weapon")
end

local function spear_bag_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_bag", "swap_object")
end

local function spear_bag_unequip(inst, owner)
	hand_unequip(inst, owner)
end

local function spear_bag_fn(inst)
	inst:add_cmps({
		inspect = {},
		weapon = {dmg=34},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		equip = {equip=spear_bag_equip, unequip=spear_bag_unequip},
		cont = {typ="1x4"},
	})
end

local function spear_beefalo_weapon_fn(inst, owner, target)
	if target and target:HasTag("beefalo") then
		if target.components.health then
			target.components.health:DoDelta(-25)
		end
	end
end

local function spear_beefalo_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_beefalo", "swap_object")
end

local function spear_beefalo_unequip(inst, owner)
	hand_unequip(inst, owner)
end

local function spear_beefalo_fn(inst)
	inst:add_cmps({
		inspect = {},
		weapon = {dmg=34, fn=spear_beefalo_weapon_fn},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		equip = {equip=spear_beefalo_equip, unequip=spear_beefalo_unequip},
	})
end

local function spear_conqueror_weapon_fn(inst, owner, target)
	if owner.components.tpbuff then
		owner.components.tpbuff:AddBuff("tp_spear_conqueror")
	end
	if owner:HasTag("tp_spear_conqueror") then
		if owner.components.health then
			owner.components.health:DoDelta(5)
		end
		if owner.components.sanity then
			owner.components.sanity:DoDelta(5)
		end
		if target.components.health then
			target.components.health:DoDelta(-5)
		end
	end
end

local function spear_conqueror_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_conqueror", "swap_object")
end

local function spear_conqueror_unequip(inst, owner)
	hand_unequip(inst, owner)
end

local function spear_conqueror_fn(inst)
	inst:add_cmps({
		inspect = {},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		weapon = {dmg=34, fn=spear_conqueror_weapon_fn},
		equip = {equip=spear_conqueror_equip, unequip=spear_conqueror_unequip},
	})
end

local function MakeItem(name, anims, item_fn, atlas, img)
	local function fn()
		local the_atlas = atlas and "images/inventoryimages/"..atlas..".xml" 
		local the_img = img or atlas
	 	local inst = WARGON.make_prefab(anims, anims[4], "inv", nil, nil, item_fn)
	 	WARGON_CMP_EX.add_cmps(inst, {
	 		invitem = {atlas=the_atlas, img=the_img},
	 	})
		inst:AddTag("tp_item")
		inst:AddComponent("tpinter")
		inst.components.tpinter:SetCanFn(function(inst, invitem, doer)
			return invitem:HasTag("tp_fix_powder") 
				and not inst:HasTag("tp_not_fix")
		end)
		if inst.components.weapon and inst:HasTag("tp_forge_weapon") then
			inst.components.weapon.getdamagefn = function(inst)
				local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
				local dmg = owner and owner.components.tplevel.attr.forge or 0
				return inst.components.weapon.damage + dmg
			end
		end

	    return inst
	end
	return Prefab("common/inventory/"..name, fn, {})
end

return
MakeItem("tp_spear_lance", Anims.spear_lance, spear_lance_fn, "spear_forge_lance"),
MakeItem("tp_spear_ice", Anims.spear_ice, spear_ice_fn, "tp_spear_ice"),
MakeItem("tp_spear_fire", Anims.spear_fire, spear_fire_fn, "tp_spear_fire"),
MakeItem("tp_spear_thunder", Anims.spear_thunder, spear_thunder_fn, "tp_spear_thunder"),
MakeItem("tp_spear_gungnir", Anims.spear_gungnir, spear_gungnir_fn, "spear_forge_gungnir"),
MakeItem("tp_spear_poison", Anims.spear_poison, spear_poison_fn, "tp_spear_poison"),
MakeItem("tp_spear_shadow", Anims.spear_shadow, spear_shadow_fn, "tp_spear_shadow"),
MakeItem("tp_spear_blood", Anims.spear_blood, spear_blood_fn, "tp_spear_blood"),
MakeItem("tp_spear_wind", Anims.spear_wind, spear_wind_fn, "tp_spear_wind"),
MakeItem("tp_spear_wrestle", Anims.spear_wrestle, spear_wrestle_fn, "spear_wathgrithr_wrestle"),
MakeItem("tp_spear_lightning", Anims.spear_lightning, spear_lightning_fn, "tp_spear_lightning"),
MakeItem("tp_spear_speed", Anims.spear_speed, spear_speed_fn, "tp_spear_speed"),
MakeItem("tp_spear_earth", Anims.spear_earth, spear_earth_fn, "tp_spear_earth"),
MakeItem("tp_spear_shine", Anims.spear_shine, spear_shine_fn, "tp_spear_shine"),
MakeItem("tp_spear_gold", Anims.spear_gold, spear_gold_fn, "tp_spear_gold"),
MakeItem("tp_spear_combat", Anims.spear_combat, spear_combat_fn, "tp_spear_combat"),
MakeItem("tp_spear_beefalo", Anims.spear_beefalo, spear_beefalo_fn, "tp_spear_beefalo"),
MakeItem("tp_spear_bag", Anims.spear_bag, spear_bag_fn, "tp_spear_bag"),
MakeItem("tp_spear_diamond", Anims.spear_diamond, spear_diamond_fn, "tp_spear_diamond"),
MakeItem("tp_spear_trap", Anims.spear_rose, spear_trap_fn, "spear_rose"),
MakeItem("tp_spear_tornado", Anims.spear_tornado, spear_tornado_fn, "tp_spear_tornado"),
MakeItem("tp_spear_conqueror", Anims.spear_conqueror, spear_conqueror_fn, "tp_spear_conqueror"),
MakeItem("tp_spear_shoot", Anims.spear_hockey, spear_shoot_fn, "spear_hockey"),

MakeItem("tp_spear_mix", Anims.spear_northern, spear_mix_fn, "spear_northern")
