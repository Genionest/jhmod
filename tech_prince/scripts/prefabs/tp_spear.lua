
local spear_lances = {"spear", "spear_forge_lance", "idle", "idle_water"}
local spear_ices = {"tp_spear_ice", "tp_spear_ice", "idle", "idle_water"}
local spear_fires = {"tp_spear_fire", "tp_spear_fire", "idle", "idle_water"}
local spear_thunders = {"tp_spear_thunder", "tp_spear_thunder", "idle", "idle_water"}
local spear_gungnirs = {"spear", "spear_forge_gungnir", "idle", "idle_water"}
local spear_poisons = {"tp_spear_poison", "tp_spear_poison", "idle", "idle_water"}
local spear_shadows = {"tp_spear_shadow", "tp_spear_shadow", "idle", "idle_water"}
local spear_bloods = {"tp_spear_blood", "tp_spear_blood", "idle", "idle_water"}
local spear_roses = {"spear", "spear_rose", "idle", "idle_water"}
local spear_winds = {'tp_spear_wind', 'tp_spear_wind', 'idle', 'idle_water'}

local function do_area_damage(inst, range, dmg, reason)
	local owner = inst.components.inventoryitem.owner
	WARGON.area_dmg(inst, range, owner, dmg, reason)
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
	local level = owner.components.tplevel.level or 1
	local dmg = 5*(level-1)
	target.components.health:DoDelta(-dmg)
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

local function spear_lance_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "swap_spear_forge_lance", "swap_spear")
end

local function spear_throw(inst)
	inst:AddTag("projectile")
end

local function spear_drop(inst)
	inst:RemoveTag("projectile")
	if inst.components.floatable then
		inst.components.floatable:SetAnimationFromPosition()
	end
end

local function spear_hit(inst, owner, target)
	WARGON.FX.impact_fx(inst, target)
	spear_drop(inst)
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
end

local function spear_ice_unequip(inst, owner)
	hand_unequip(inst, owner)
	spear_ice_fx_remove(inst)
end

local function spear_ice_weapon_fn(inst, owner, target)
	mk_lv_dmg(inst, owner, target)
	WARGON.frozen_prefab(target)
	WARGON.make_fx(target, "icespike_fx_"..math.random(1, 4))
end

local function spear_ice_proj_throw(inst)
	inst:AddTag("projectile")
	spear_throw(inst)
	if inst.fx == nil then
		inst.fx = SpawnPrefab("tp_fx_snow_line")
		inst:AddChild(inst.fx)
	end
end

local function spear_ice_proj_drop(inst)
	inst:RemoveTag("projectile")
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

local function spear_ice_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34, fn=spear_ice_weapon_fn},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		equip = {equip=spear_ice_equip, unequip=hand_unequip},
		inv = {drop=spear_ice_inv_drop, put=spear_ice_inv_put},
	})
	inst:AddComponent("tpproj")
	inst.components.tpproj:SetSpeed(25)
	inst.components.tpproj:SetOnThrownFn(spear_ice_proj_throw)
	inst.components.tpproj:SetOnHitFn(spear_ice_proj_hit)
	inst.components.tpproj:SetOnMissFn(spear_ice_proj_drop)
	inst.components.tpproj:SetLaunchOffset(Vector3(0, 0.2, 0))
	inst:AddTag("tp_catcoon_spear")
end

local function spear_fire_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_fire", "swap_object")
end

local function spear_fire_weapon_fn(inst, owner, target)
	mk_lv_dmg(inst, owner, target)
	WARGON.fire_prefab(target)
	local fx = WARGON.make_fx(target, "firesplash_fx")
	local s = .5
	fx.Transform:SetScale(s,s,s)
end

local function spear_fire_throw(inst)
	inst:AddTag("projectile")
	spear_throw(inst)
	if inst.fx == nil then
		inst.fx = SpawnPrefab("tp_fx_fire_line")
		inst:AddChild(inst.fx)
	end
end

local function spear_fire_drop(inst)
	inst:RemoveTag("projectile")
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

local function spear_fire_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34, fn=spear_fire_weapon_fn},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		equip = {equip=spear_fire_equip, unequip=hand_unequip},
	})
	inst:AddComponent("tpproj")
	inst.components.tpproj:SetSpeed(25)
	inst.components.tpproj:SetOnThrownFn(spear_fire_throw)
	inst.components.tpproj:SetOnHitFn(spear_fire_hit)
	inst.components.tpproj:SetOnMissFn(spear_fire_drop)
	inst.components.tpproj:SetLaunchOffset(Vector3(0, 0.2, 0))
	inst:AddTag("tp_catcoon_spear")
end

local function spear_thunder_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_thunder", "swap_object")
end

local function spear_thunder_weapon_fn(inst, owner, target)
	local function is_target(target, inst)
        if target.components.combat and target.components.health
        and owner.components.combat:CanTarget(target) then
            return true
        end
	end
	WARGON.FX.sparks_fx(inst, target)
    local new_target = WARGON.find(target, 5, is_target, nil, 
        {"player", "wall", "FX", "NOCLICK", "INLIMBO"})
    if new_target then
        local proj = WARGON.make_spawn(target, "tp_charge_proj")
        proj.master = owner
        table.insert(proj.no_targets, target)
        proj.components.tpproj:Throw(owner, new_target)
    end
end

local function spear_thunder_throw(inst)
	inst:AddTag("projectile")
	spear_throw(inst)
	inst.fx = SpawnPrefab("shock_fx")
	inst:AddChild(inst.fx)
	inst.fx.Transform:SetPosition(0, -1, 0)
end

local function spear_thunder_drop(inst)
	inst:RemoveTag("projectile")
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
	inst:AddTag("tp_catcoon_spear")
end

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
				do_area_damage(inst, 1.5, 10, "tp_spear_gungnir")
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
	mk_lv_dmg(inst, owner, target)
	WARGON.poison_prefab(target)
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
				do_area_damage(inst, 1.5, 10, "tp_spear_poison")
				local fx = WARGON.make_fx(inst, "tp_fx_poison_bubble")
				-- local s = .5
				-- fx.Transform:SetScale(s,s,s)
				Sleep(0.1)
			end
		end)
	end
	-- inst:AddTag("tp_catcoon_spear")
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
	else
		local per = owner.components.sanity:GetPercent()
		local amount = per * 100
		target.components.health:DoDelta(-amount)
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
				do_area_damage(inst, 1.5, 10, "tp_spear_shadow")
				local fx = WARGON.make_fx(inst, "statue_transition")
				Sleep(0.1)
			end
		end)
	end
	-- inst:AddTag("tp_catcoon_spear")
end

local function spear_blood_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_spear_blood", "swap_object")
end

local function spear_blood_weapon_fn(inst, owner, target)
	-- local owner = inst.components.inventoryitem.owner
	mk_lv_dmg(inst, owner, target)
	if target:HasTag('epic') then
		owner.components.health:DoDelta(15)
	elseif target:HasTag("largecreature") then
		owner.components.health:DoDelta(10)
	else
		owner.components.health:DoDelta(5)
	end
	WARGON.make_fx(owner, "tp_fx_blood")
	WARGON.make_fx(target, "feathers_packim_fire")
end

local function spear_blood_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34, fn=spear_blood_weapon_fn},
		finite = {max=300, use=300, fn=on_finish},
		equip = {equip=spear_blood_equip, unequip=hand_unequip},
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
					owner.components.health:DoDelta(2)
				end
				do_area(inst, 1.5, area_blood)
				do_area_damage(inst, 1.5, 10, "tp_spear_blood")
				local fx = WARGON.make_fx(inst, "tp_blood_fx")
				-- local fx2= WARGON.make_fx(inst, "feathers_packim_fire")
				Sleep(0.1)
			end
		end)
	end
	-- inst:AddTag("tp_catcoon_spear")
end

local function spear_wind_throw(inst, owner, target)
	inst:AddTag("projectile")
	if inst.task == nil then
		inst.task = WARGON.per_task(inst, .1, function()
			WARGON.make_fx(inst, "tp_fx_leaf_"..math.random(4))
		end)
	end
end

local function spear_wind_drop(inst)
	inst:RemoveTag("projectile")
	if inst.task then
		inst.task:Cancel()
		inst.task = nil
	end
	if inst.components.floatable then
		inst.components.floatable:SetAnimationFromPosition()
	end
end

local function spear_wind_hit(inst, owner, target)
	WARGON_FX_EX.impact_fx(inst, target)
	spear_wind_drop(inst)
end

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
		weapon = {dmg=34, fn=spear_wind_weapon_fn, },
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		equip = {equip=spear_wind_equip, unequip=spear_wind_unequip},
		water = {value=TUNING.WATERPROOFNESS_SMALL},
	})
	inst:AddComponent("tpproj")
	inst.components.tpproj:SetSpeed(25)
	inst.components.tpproj:SetOnThrownFn(spear_wind_throw)
	inst.components.tpproj:SetOnHitFn(spear_wind_hit)
	inst.components.tpproj:SetOnMissFn(spear_wind_drop)
	inst.components.tpproj:SetLaunchOffset(Vector3(0, 0.2, 0))
	-- WARGON.add_tags(inst, {"thrown", "projectile"})
end

local function MakeItem(name, anims, item_fn, atlas, img)
	local function fn()
		local the_atlas = atlas and "images/inventoryimages/"..atlas..".xml" 
		local the_img = img or atlas
	 	local inst = WARGON.make_prefab(anims, anims[4], "inv", nil, nil, item_fn)
	 	WARGON_CMP_EX.add_cmps(inst, {
	 		invitem = {atlas=the_atlas, img=the_img},
	 	})

	    return inst
	end
	return Prefab("common/inventory/"..name, fn, {})
end

return
	MakeItem("tp_spear_lance", spear_lances, spear_lance_fn, "spear_forge_lance"),
	MakeItem("tp_spear_ice", spear_ices, spear_ice_fn, "tp_spear_ice"),
	MakeItem("tp_spear_fire", spear_fires, spear_fire_fn, "tp_spear_fire"),
	MakeItem("tp_spear_thunder", spear_thunders, spear_thunder_fn, "tp_spear_thunder"),
	MakeItem("tp_spear_gungnir", spear_gungnirs, spear_gungnir_fn, "spear_forge_gungnir"),
	MakeItem("tp_spear_poison", spear_poisons, spear_poison_fn, "tp_spear_poison"),
	MakeItem("tp_spear_shadow", spear_shadows, spear_shadow_fn, "tp_spear_shadow"),
	MakeItem("tp_spear_blood", spear_bloods, spear_blood_fn, "tp_spear_blood"),
	MakeItem("tp_spear_wind", spear_winds, spear_wind_fn, "tp_spear_wind")
