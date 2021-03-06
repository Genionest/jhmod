local Anims = {
	ruinbat_deerclops = {"tp_ruinbat_deerclops", "tp_ruinbat_deerclops", "idle", },
	ruinbat_dragonfly = {"tp_ruinbat_dragonfly", "tp_ruinbat_dragonfly", "idle", },
	ruinbat_moose = {"tp_ruinbat_moose", "tp_ruinbat_moose", "idle", },
	ruinbat_bearger = {"tp_ruinbat_bearger", "tp_ruinbat_bearger", "idle", },
	ruinbat = {"ruins_bat", "ruins_bat_heavy", "idle", },
}
local ruinbats = {"ruins_bat", "ruins_bat_heavy", "idle", nil}
local ruinbat_beargers = {"tp_ruinbat_bearger", "tp_ruinbat_bearger", "idle"}
local ruinbat_dragonflys = {"tp_ruinbat_dragonfly", "tp_ruinbat_dragonfly", "idle"}
local ruinbat_deerclopses = {"tp_ruinbat_deerclops", "tp_ruinbat_deerclops", "idle"}
local ruinbat_mooses = {"tp_ruinbat_moose", "tp_ruinbat_moose", "idle"}

local function do_area_damage(inst, range, dmg, reason, fn)
	local owner = inst.components.inventoryitem.owner
	WARGON.area_dmg(inst, range, owner, dmg, reason, fn)
end

local function mk_lv_dmg(inst, owner, target)
	-- local level = owner.components.tplevel.level or 1
	-- local dmg = 5*(level-1)
	-- local dmg = owner.components.tplevel.attr.forge
	-- target.components.health:DoDelta(-dmg)
end

local function mk_tp_fx(inst, owner)
	inst.tp_fx = SpawnPrefab("tp_snow_fx")
	inst.tp_fx:AddTag("INTERIOR_LIMBO_IMMUNE")
	local follower = inst.tp_fx.entity:AddFollower()
    follower:FollowSymbol( owner.GUID, "swap_object", 0, -110, 0 )
	inst.tp_atk_num = 0
	inst.tp_has_fx = true
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

local  function ruinbat_weapon_fn(inst, owner, target)
	-- mk_lv_dmg(inst, owner, target)
	WARGON.make_fx(target, "sanity_lower")
	local summonchance = .2
	if math.random() < summonchance then
        local pt = target:GetPosition()
        local st_pt =  FindWalkableOffset(pt or owner:GetPosition(), math.random()*2*PI, 2, 3)
        if st_pt then
            inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
            inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")            
            st_pt = st_pt + pt
            local st = SpawnPrefab("shadowtentacle")
            st.Transform:SetPosition(st_pt.x, st_pt.y, st_pt.z)
            st.components.combat:SetTarget(target)
        end
    end
end

local function common_ruinbat_fn(inst, charge_time, move_fn, equip_fn, unequip_fn)
	WARGON_CMP_EX.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=TUNING.RUINS_BAT_DAMAGE, fn=ruinbat_weapon_fn},
		equip = {equip=equip_fn, unequip=unequip_fn or hand_unequip, effect={speed=TUNING.RUINS_BAT_SPEED_MULT}},
		finite = {use=TUNING.RUINS_BAT_USES, max=TUNING.RUINS_BAT_USES, fn=on_finish},
		})
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_ZA"
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(charge_time)
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(charge_time)
		if move_fn then move_fn(inst) end
	end
	inst:AddTag("tp_forge_weapon")
end

local function ruinbat_uplevel(inst, data)
	local bosses = {
		["moose"] = 1,
		["dragonfly"] = 1,
		["bearger"] = 1,
		["deerclops"] = 1,
	}
	if data and data.victim then
		local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if inst:HasTag("tp_ruinbat") and weapon then
			if bosses[data.victim.prefab] then
				WARGON.make_fx(data.victim, "wathgrithr_spirit")
				local fx = WARGON.make_fx(data.victim, "tp_fx_boss_spirit")
				fx.target = inst
				local new = SpawnPrefab("tp_ruinbat_"..data.victim.prefab)
				inst.components.inventory:GiveItem(new)
				-- if weapon then
					weapon:Remove()
				-- end
			elseif weapon.components.tprecharge:IsRecharged() == false then
				weapon.components.tprecharge:SetRechargeTime(.5)
			end
		end
	end
end

local function ruinbat_equip(inst, owner)
	WARGON_EQUIP_EX.object_on(owner, "swap_ruins_bat_heavy", "swap_ruins_bat")
	owner:AddTag("tp_ruinbat")
	owner:ListenForEvent("killed", ruinbat_uplevel)
end

local function ruinbat_unequip(inst, owner)
	hand_unequip(inst, owner)
	owner:RemoveTag("tp_ruinbat")
	owner:RemoveEventCallback("killed", ruinbat_uplevel)
end

local function ruinbat_fn(inst)
	common_ruinbat_fn(inst, 10, function(inst)
		WARGON.make_fx(inst, "laser_ring")
		do_area_damage(inst, 2, 30, "tp_ruinbat")
	end, ruinbat_equip, ruinbat_unequip)
	-- inst:ListenForEvent("entity_death", function(world, data)
	-- 	ruinbat_uplevel(inst, data)
	-- end, GetWorld())
end

local function boss_equip(owner, build)
	WARGON.EQUIP.object_on(owner, build, "swap_object")
end

local function ruinbat_bearger_equip(inst, owner)
	boss_equip(owner, "tp_ruinbat_bearger")
end

local function ruinbat_bearger_fn(inst)
	common_ruinbat_fn(inst, 30, function(inst)
		local fx = WARGON.make_fx(inst, "tp_fx_bearger")
		local owner = inst.components.inventoryitem.owner
		fx.Transform:SetRotation(owner.Transform:GetRotation())
	end, ruinbat_bearger_equip)
end

local function ruinbat_dragonfly_equip(inst, owner)
	boss_equip(owner, "tp_ruinbat_dragonfly")
end

local function ruinbat_dragonfly_fn(inst)
	common_ruinbat_fn(inst, 5, function(inst)
		local fx = WARGON.make_fx(inst, "tp_fx_dragonfly")
		local owner = inst.components.inventoryitem.owner
		fx.Transform:SetRotation(owner.Transform:GetRotation())
	end, ruinbat_dragonfly_equip)
	inst.components.tpmove.action = "TP_BANGALORE"
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime()
	end
end

local function ruinbat_deerclops_equip(inst, owner)
	boss_equip(owner, "tp_ruinbat_deerclops")
	if inst.tp_has_fx then
		mk_tp_fx(inst, owner)
	end
end

local function ruinbat_deerclops_unequip(inst, owner)
	if inst.tp_fx then
		inst.tp_fx:Remove()
		inst.tp_fx = nil
	end
end

local function ruinbat_deerclops_weapon(inst, owner, target)
	ruinbat_weapon_fn(inst, owner, target)
	if inst.tp_fx then
		inst.tp_fx:Remove()
		inst.tp_fx = nil
		inst.tp_has_fx = false
		WARGON.frozen_prefab(target, owner, 4)
	else
		inst.tp_atk_num = inst.tp_atk_num + 1
		if inst.tp_atk_num >= 4 then
			mk_tp_fx(inst, owner)
			inst.tp_atk_num = 0
			inst.tp_has_fx = true
		end
	end
end

local function ruinbat_deerclops_save(inst, data)
	if data then
		data.tp_atk_num = inst.tp_atk_num
		data.tp_has_fx = inst.tp_has_fx
	end
end

local function ruinbat_deerclops_load(inst, data)
	if data then
		inst.tp_atk_num = data.tp_atk_num or 0
		inst.tp_has_fx = data.tp_has_fx
		if inst.tp_has_fx then
			local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
			if owner then
				mk_tp_fx(inst, owner)
			end
			inst.tp_atk_num = 0
			inst.tp_has_fx = true
		end
	end
end

local function ruinbat_deerclops_fn(inst)
	common_ruinbat_fn(inst, 30, function(inst)
		local fx = WARGON.make_fx(inst, "tp_fx_deerclops")
		local owner = inst.components.inventoryitem.owner
		fx.Transform:SetRotation(owner.Transform:GetRotation())
	end, ruinbat_deerclops_equip)
	WARGON.CMP.add_cmps(inst, {
		weapon = {fn=ruinbat_deerclops_weapon},
		})
	inst.components.tpmove.action = "TP_ROTATE"
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime()
		WARGON.make_fx(inst, "tp_fx_ice_spike")
		if inst.tp_fx then
			inst.tp_fx:Remove()
			inst.tp_fx = nil
			inst.tp_has_fx = false
			do_area_damage(inst, 4, 50, "tp_ruinbat_deerclops", 
				function(inst, attacker, target)
					WARGON.frozen_prefab(target, attacker, 2)
					if target:HasTag("epic") then
						attacker.components.health:DoDelta(30)
					else
						attacker.components.health:DoDelta(20)
					end
				end
			)	
		else
			inst.tp_atk_num = inst.tp_atk_num + 1
			if inst.tp_atk_num >= 4 then
				local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
				if owner then
					mk_tp_fx(inst, owner)
				end
				inst.tp_atk_num = 0
				inst.tp_has_fx = true
			end
			do_area_damage(inst, 4, 30, "tp_ruinbat_deerclops", 
				function(inst, attacker, target)
					WARGON.frozen_prefab(target, attacker)
					if target:HasTag("epic") then
						attacker.components.health:DoDelta(20)
					else
						attacker.components.health:DoDelta(10)
					end
				end
			)
		end
	end
	inst.tp_atk_num = 0
	inst.tp_has_fx = false
	inst.OnSave = ruinbat_deerclops_save
	inst.OnLoad = ruinbat_deerclops_load
end

local function ruinbat_moose_equip(inst, owner)
	boss_equip(owner, "tp_ruinbat_moose")
end

local function ruinbat_moose_fn(inst)
	common_ruinbat_fn(inst, 30, function(inst)
		local fx = WARGON.make_fx(inst, "tp_fx_moose")
		local owner = inst.components.inventoryitem.owner
		fx.Transform:SetRotation(owner.Transform:GetRotation())
	end, ruinbat_moose_equip)
	inst:AddTag("tp_wind_attack")
	inst.components.tpmove.action = "TP_CUI_FENG"
	inst.components.tpmove.onmove = function(inst)
		-- inst.components.tprecharge:SetRechargeTime(30)
		WARGON.make_fx(inst, "laser_ring")
		do_area_damage(inst, 2, 30, "tp_ruinbat_moose")
	end
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
MakeItem("tp_ruinbat", Anims.ruinbat, ruinbat_fn, "ruins_bat_heavy"),
MakeItem("tp_ruinbat_bearger", Anims.ruinbat_bearger, ruinbat_bearger_fn, "tp_ruinbat_bearger"),
MakeItem("tp_ruinbat_dragonfly", Anims.ruinbat_dragonfly, ruinbat_dragonfly_fn, "tp_ruinbat_dragonfly"),
MakeItem("tp_ruinbat_deerclops", Anims.ruinbat_deerclops, ruinbat_deerclops_fn, "tp_ruinbat_deerclops"),
MakeItem("tp_ruinbat_moose", Anims.ruinbat_moose, ruinbat_moose_fn, "tp_ruinbat_moose")

-- return
-- 	MakeItem("tp_ruinbat", ruinbats, ruinbat_fn, "ruins_bat_heavy"),
-- 	MakeItem("tp_ruinbat_bearger", ruinbat_beargers, ruinbat_bearger_fn, "tp_ruinbat_bearger"),
-- 	MakeItem("tp_ruinbat_dragonfly", ruinbat_dragonflys, ruinbat_dragonfly_fn, "tp_ruinbat_dragonfly"),
-- 	MakeItem("tp_ruinbat_deerclops", ruinbat_deerclopses, ruinbat_deerclops_fn, "tp_ruinbat_deerclops"),
-- 	MakeItem("tp_ruinbat_moose", ruinbat_mooses, ruinbat_moose_fn, "tp_ruinbat_moose")