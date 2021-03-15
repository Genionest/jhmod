local GiftDialog = require("screens/gift_select")

local Anims = {
	strawhat = {"strawhat", "strawhat_cowboy", "anim", "idle_water", },
	fix_powder = {"tp_fix_powder", "tp_fix_powder", "idle", "idle_water", },
	tall_bird_egg = {"egg", "tallbird_egg", "egg", "idle_water", },
	teatree_nut = {"teatree_nut", "teatree_nut", "idle", },
	book_maxwell = {"book_maxwell", "book_maxwell", "idle", "idle_water", },
	soft_wood = {"armor_wood_haramaki", "armor_wood_haramaki", "anim", "idle_water", },
	gasmask = {"gasmaskhat", "hat_gasmask", "anim", "idle_water", },
	map = {"stash_map", "stash_map", "idle", "idle_water", },
	acorn = {"acorn", "acorn", "idle", },
	ballhat = {"footballhat", "footballhat_combathelm", "anim", "idle_water", },
	ham = {"ham_bat", "ham_bat_spiralcut", "idle", "idle_water", },
	cutlass = {"tp_cutlass", "tp_cutlass", "idle", "idle_water", },
	ice_staff = {"staffs", "icestaff_bee", "bluestaff", "bluestaff_water", },
	pigking_hat = {"beefalohat", "beefalohat_pigking", "anim", "idle_water", },
	egg_tool = {"tp_egg_tool", "tp_egg_tool", "idle", "idle_water", },
	epic = {"tp_epic", "tp_epic", "idle", "idle_water", },
	rocket = {"trinkets", "trinkets", "5", "5_water", },
	books = {"books", "books", "book_sleep", "book_sleep_water", },
	gingko_leaf = {"tp_gingko_leaf", "tp_gingko_leaf", "idle", },
	gift = {"tp_gift", "tp_gift", "idle", },
	spear = {"spear", "spear_bee", "idle", "idle_water", },
	grass_pigking = {"topiary", "topiary_pigking_build", "idle", },
	octopus = {"tp_octopus", "tp_octopus", "idle", "idle_water", },
	horn = {"horn", "horn", "idle", "idle_water", },
	gun = {"tp_forest_gun", "tp_forest_gun", "idle", "idle_water", },
	wortox_soul = {"wortox_soul_ball", "wortox_soul_ball", "idle_loop", "idle_loop", },
	coconut = {"coconut", "coconut", "idle", },
	amulet = {"amulets", "amulet_red_occulteye", "redamulet", "redamulet_water", },
	alloy = {"tp_alloy", "tp_alloy", "idle", "idle_water", },
	sword = {"nightmaresword", "nightsword_sharp", "idle", "idle_water", },
	jungletreeseed = {"jungletreeseed", "jungletreeseed", "idle", },
	pinecone = {"pinecone", "pinecone", "idle", },
	strawhat_trap = {"tp_strawhat_trap", "tp_strawhat_trap", "idle", "idle_water", },
	pig_lamp = {"pig_lamp", "pig_lamp", "idle_on", "idle_on_water", },
	pig_book = {"pig_book", "pig_book", "idle", "idle_water", },
	cane = {"cane", "cane_ancient", "idle", "idle_water", },
	wood = {"armor_wood_fangedcollar", "armor_wood_fangedcollar", "anim", "idle_water", },
	sign = {"tp_sign_staff", "tp_sign_staff", "idle", "idle_water", },
	flare = {"tp_flare", "tp_flare", "idle", },
	ash = {"ash", "ash", "idle", },
	fire_staff = {"staffs", "firestaff_bee", "redstaff", "redstaff_water", },
	bat_scythe = {"batbat", "batbat_scythe", "idle", "idle_water"},
}

local function MakeItem(name, anims, item_fn, atlas, img)
	local function fn()
		local the_atlas = atlas and "images/inventoryimages/"..atlas..".xml" 
		local the_img = img or atlas
	 	local inst = WARGON.make_prefab(anims, anims[4], "inv", nil, nil)
	 	WARGON_CMP_EX.add_cmps(inst, {
	 		invitem = {atlas=the_atlas, img=the_img},
	 	})
	 	inst:AddTag("tp_item")
	 	if item_fn then
	 		item_fn(inst)
	 	end

	    return inst
	end
	return Prefab("common/inventory/"..name, fn, {})
end

local function do_area_damage(inst, range, dmg, reason)
	local owner = inst.components.inventoryitem.owner
	WARGON.area_dmg(inst, range, owner, dmg, reason)
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

local function strawhat_equip(inst, owner)
	-- WARGON_EQUIP_EX.object_on(owner, "strawhat_cowboy", "swap_hat")
	WARGON_EQUIP_EX.object_on(owner, "tp_strawhat", "swap_object")
end

local function strawhat_score(inst, giver)
	local pos = inst:GetPosition()
	if pos.y <= 0.1 then
		print("score")
		inst.components.tphatball:Trigger(giver)
		if inst.tp_per_task then
			inst.tp_per_task:Cancel()
			inst.tp_per_task = nil
		end
	end
end

local function strawhat_throw(inst, thrower, pt)
	print("throw", 1)
	inst.Physics:SetFriction(.2)
	if inst.tp_per_task == nil then
		print("throw", 2)
		inst.tp_per_task = WARGON.per_task(inst, .1, function() 
			strawhat_score(inst, thrower) 
		end)
	end
end

local function strawhat_fn(inst)
	WARGON_CMP_EX.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=1},
		finite = {max=TUNING.SPEAR_USES, use=TUNING.SPEAR_USES, fn=on_finish},
		equip = {equip=strawhat_equip, unequip=hand_unequip},
		throw = {throw=strawhat_throw},
		tphatball = {},
	})
end

local function strawhat2_equip(inst, owner)
	WARGON.EQUIP.hat_on(owner, "strawhat_cowboy")
	inst.components.fueled:StartConsuming()
end

local function strawhat2_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=strawhat2_equip, unequip=head_unequip, slot='head'},
		water = {value=TUNING.WATERPROOFNESS_SMALL},
		insu = {value=TUNING.INSULATION_SMALL, typ="summer"},
		fueled = {time=TUNING.STRAWHAT_PERISHTIME, typ="usage", fn={finish=on_finish}},
	})
end

local function strawhat_saddle_finish(inst)
	on_finish(inst)
end

local function strawhat_saddle_fn(inst)
	inst:add_tags({
		"tp_open_beefalo_container",
	})
	inst.mounted_foleysound = "dontstarve/beefalo/saddle/regular_foley"
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		finite = {max=10, use=10, fn=strawhat_saddle_finish},
		saddler = {},
		})
	inst.components.saddler:SetBonusDamage(1)
    inst.components.saddler:SetBonusSpeedMult(1)
    inst.components.saddler:SetSwaps("strawhat_cowboy", "swap_hat")
    inst.components.saddler:SetDiscardedCallback(function() end)
end

local function strawhat_trap_harvest(inst)
	inst.components.finiteuses:Use()
end

local function strawhat_trap_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		trap = {},
		finite = {use=10, max=10, fn=on_finish},
		})
	WARGON.add_tags(inst, {
		"trap",
		})
	inst.components.trap.targettag = "canbetrapped"
	inst.components.trap:SetOnHarvestFn(strawhat_trap_harvest)
	inst.components.trap.baitsortorder = 1
	inst:SetStateGraph("SGtrap")
	inst.sounds = {
		close = "dontstarve/common/trap_close",
		rustle = "dontstarve/common/trap_rustle",
	}
	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon("strawhat_cowboy.tex")
end

local function ballhat_attacked(owner, data)
	local pt = owner:GetPosition()
	pt.y = pt.y + 1.5
	WARGON.make_fx(pt, "boat_hit_fx")
	if math.random() < .3 then
		if owner.components.tpbuff then
			owner.components.tpbuff:AddBuff("tp_ballhat")
		end
	end
end

local function ballhat_equip(inst, owner)
	WARGON.EQUIP.hat_on(owner, "footballhat_combathelm")
	-- owner:ListenForEvent("attacked", function(inst, data)
	-- 	ballhat_attacked(owner, data)
	-- end)
	owner:ListenForEvent("attacked", ballhat_attacked)
end

local function ballhat_unequip(inst, owner)
	WARGON.EQUIP.hat_off(owner)
	owner:RemoveEventCallback("attacked", ballhat_attacked)
	-- inst:RemoveEventCallback("attacked", ballhat_attacked, owner)
end

local function ballhat_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		armor = {armor=TUNING.ARMOR_FOOTBALLHAT, absorb=.8},
		equip = {slot="head", equip=ballhat_equip, unequip=ballhat_unequip},
		water = {value=TUNING.WATERPROOFNESS_SMALL},
		})
end

local function wood_equip(inst, owner)
	WARGON_EQUIP_EX.object_on(owner, "armor_wood_fangedcollar", "swap_body")
end

local function wood_fn(inst)
	WARGON_CMP_EX.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34*1.5},
		equip = {equip=wood_equip, unequip=hand_unequip},
		armor = {armor=TUNING.ARMORWOOD , absorb=.8},
		fuel = {value=TUNING.LARGE_FUEL},
	})
	WARGON.make_burn(inst, "small", TUNING.SMALL_BURNTIME)
	WARGON.make_prop(inst, "small")
	inst.components.burnable:MakeDragonflyBait(3)
	WARGON.add_tags(inst, {"slowattack"})
end

local function ham_update(inst)
	if inst.components.perishable and inst.components.weapon then
		local dmg = 34*1.75 * inst.components.perishable:GetPercent()
        dmg = Remap(dmg, 0, 34*1.75, TUNING.HAMBAT_MIN_DAMAGE_MODIFIER*34*1.75, 34*1.75)
        inst.components.weapon:SetDamage(dmg)
	end
end

local function ham_weapon_fn(inst, owner, target)
	ham_update(inst)
	local fx = WARGON.make_fx(target, "tp_fx_many_small_meat")
	fx.rand = inst.components.perishable:GetPercent()
end

local function ham_equip(inst, owner)
	WARGON_EQUIP_EX.object_on(owner, "swap_ham_bat_spiralcut", "swap_ham_bat")
end

-- local function ham_throw(inst, owner, pt)
-- 	WARGON.do_task(inst, .5, function()
-- 		local function stop_task(inst)
-- 			if inst.no_drop then
-- 				inst.no_drop:Cancel()
-- 				inst.no_drop = nil
-- 			end
-- 			if inst.drop_task then
-- 				inst.drop_task:Cancel()
-- 				inst.drop_task = nil
-- 			end
-- 		end
-- 		inst.Transform:SetPosition(pt.x, pt.y+20, pt.z)
-- 		inst.drop_task = WARGON.per_task(inst, .1, function()
-- 			local pos = inst:GetPosition()
-- 			if pos.y <= .1 then
-- 				WARGON.make_fx(inst, "tp_fx_ham_ground_pound")
-- 				stop_task(inst)
-- 			end
-- 		end)
-- 		inst.no_drop = WARGON.do_task(inst, 2.5, function()
-- 			local pos = inst:GetPosition()
-- 			inst.Transform:SetPosition(pos.x, 0, pos.z)
-- 			WARGON.make_fx(inst, "tp_fx_ham_ground_pound")
-- 			stop_task(inst)
-- 		end)
-- 	end)
-- end

local function ham_onload(inst, data)
	ham_update(inst)
end

local function ham_fn(inst)
	WARGON_CMP_EX.add_cmps(inst, {
		perish = {time=TUNING.PERISH_MED, spoil="spoiled_food"},
		weapon = {dmg=34*1.75, fn=ham_weapon_fn},
		equip = {equip=ham_equip, unequip=hand_unequip},
		-- combat = {dmg=30},
	})
	WARGON.add_tags(inst, {
		"show_spoilage", "icebox_valid", "tp_must_spoilsh"
	})
	-- inst:AddComponent("tpthrow")
	-- inst.components.tpthrow.onthrown = ham_throw
	-- inst.components.tpthrow.speed = 40
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(20)
	-- inst:AddTag("tp_move_no_target")
	inst:AddTag("tp_move_combat")
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_TOU"
	inst.components.tpmove.onmove = function()
		inst.components.tprecharge:SetRechargeTime()
		WARGON.make_fx(inst, "tp_fx_ham_ground_pound")
	end
	inst:AddComponent("tpinter")
	inst.components.tpinter:SetFn(function(inst, item, doer)
		local delta = 0
		local item = item.components.stackable:Get()
		if item.components.perishable then
			delta = item.components.perishable.perishremainingtime
		end
		local current = item.components.perishable.perishremainingtime
		local max = item.components.perishable.perishtime
		local percent = (current + delta)/max
		inst.components.perishable:SetPercent(percent)
		item:Remove()
	end)
	inst.components.tpinter:SetCanFn(function(inst, item, doer)
		return item:HasTag("tp_hambat_fuel")
	end)
	inst.OnLoad = ham_onload
end

local function staff_trinity_equip(inst, owner)
	local bank, build = inst.components.tptrinity:GetBuild()
	WARGON.EQUIP.object_on(owner, bank, build)
end

local function staff_trinity_use_test(inst)
	return inst.components.equippable:IsEquipped()
end

local function staff_trinity_use_use(inst)
	inst.components.tptrinity:Change()
end

local function staff_trinity_spear(inst)
	WARGON.CMP.add_cmps(inst, {
		weapon = {dmg=34, fn="nil", fx='nil', range={nil,nil}},
	})
	WARGON.add_tags(inst, {"sharp"})
	WARGON.remove_tags(inst, {'rangedlighter', 'extinguisher'})
end

local function staff_trinity_ice_weapon_fn(inst, owner, target)
    -- if target.sg ~= nil and not target.sg:HasStateTag("frozen") then
    --     target:PushEvent("attacked", { attacker = owner, damage = 0 })
    -- end
	WARGON.frozen_prefab(target, owner)
	if owner and owner.components.sanity then
		owner.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY)
	end
end

local function staff_trinity_ice(inst)
	WARGON.CMP.add_cmps(inst, {
		weapon = {dmg=0, fn=staff_trinity_ice_weapon_fn, fx='ice_projectile',
			range={8,10} },
	})
	WARGON.add_tags(inst, {'extinguisher'})
	WARGON.remove_tags(inst, {"sharp", 'rangedlighter'})
end

local function staff_trinity_fire_weapon_fn(inst, owner, target)
	WARGON.fire_prefab(target, owner)
    if owner and owner.components.sanity then
        owner.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY)
    end
    owner.SoundEmitter:PlaySound("dontstarve/wilson/fireball_explo")
    target:PushEvent("attacked", { attacker = owner, damage = 0 })
end

local function staff_trinity_fire(inst)
	WARGON.CMP.add_cmps(inst, {
		weapon = {dmg=0, fn=staff_trinity_fire_weapon_fn, fx='fire_projectile',
			range={8,10} },	
	})
	WARGON.add_tags(inst, {'rangedlighter'})
	WARGON.remove_tags(inst, {"sharp", 'extinguisher'})
end

local function staff_trinity_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=34},
		equip = {equip=staff_trinity_equip, unequip=hand_unequip},
		finite = {use=150, max=150},
		use = {str="切换", test=staff_trinity_use_test, use=staff_trinity_use_use},
	})
	inst:AddComponent("tptrinity")
	inst.components.tptrinity:SetBuild({
		{'swap_spear_bee', 'swap_spear'},
		{'swap_icestaff_bee', 'swap_bluestaff'},
		{'swap_firestaff_bee', 'swap_redstaff'},
	})
	inst.components.tptrinity:SetImage({
		'spear_bee',
		'icestaff_bee',
		'firestaff_bee',
	})
	inst.components.tptrinity:SetFn({
		staff_trinity_spear,
		staff_trinity_ice,
		staff_trinity_fire,
	})
end

local function rocket_on(inst)
	inst:RemoveComponent("inventoryitem")
	WARGON.do_task(inst, .5, function()
		inst.Physics:SetMotorVel(0, 40, 0)
		WARGON.do_task(inst, 1, function()
			WARGON.do_task(GetPlayer(), 2, function()
				if GetWorld().components.seasonmanager.precip then
			       GetWorld().components.seasonmanager:StopPrecip()
			    else
			       GetWorld().components.seasonmanager:ForcePrecip()
			    end
			end)
			inst:Remove()
		end)
	end)
end

local function rocket_machine_test(inst)
	if inst.components.inventoryitem then
		return inst.components.inventoryitem.owner == nil
	end
end

local function rocket_drop(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", false)
end

local function rocket_ignite(inst)
	-- rocket_on(inst)
	-- inst.fx = SpawnPrefab("torchfire")
	-- inst:AddChild(inst.fx)
	-- inst.fx.Transform:SetPosition(0, -.3, 0)
	inst.AnimState:PlayAnimation("fire")
	inst:ListenForEvent("animover", function()
	-- WARGON.do_task(inst, .5, function()
		WARGON.do_task(GetPlayer(), 2, function()
			if GetWorld().components.seasonmanager.precip then
		       GetWorld().components.seasonmanager:StopPrecip()
		    else
		       GetWorld().components.seasonmanager:ForcePrecip()
		    end
		end)
		inst:Remove()
	end)
end

local function rocket_fn(inst)
	WARGON_CMP_EX.add_cmps(inst, {
		inspect = {},
		-- machine = {on=rocket_on, time=1, test=rocket_machine_test},
		invitem = {drop=rocket_drop},
		burnable = {},
	})
	WARGON.add_listen(inst, {
		onignite = rocket_ignite
	})
end

local function cane_equip(inst, owner)
	WARGON_EQUIP_EX.object_on(owner, "swap_cane_ancient", "swap_cane")
	if inst.fx == nil then
		inst.fx = SpawnPrefab("tp_sparkle_fx")
		inst.fx.entity:AddFollower()
	end
	inst.fx.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -110, 0)
end

local function cane_unequip(inst, owner)
	hand_unequip(inst, owner)
	if inst.fx then
		inst.fx:Remove()
		inst.fx = nil
	end
end

local function cane_fn(inst)
	WARGON_CMP_EX.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=10},
		equip = {equip=cane_equip, unequip=cane_unequip, effect={speed=0.25}},
		})
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(1)
	inst:AddTag("tp_move_no_target")
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_HUA"
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(1)
	end
end

local function mk_lv_dmg(inst, owner, target)
	-- local level = owner.components.tplevel.level or 1
	-- local dmg = 5*(level-1)
	-- target.components.health:DoDelta(-dmg)
end

local function cutlass_weapon_fn(inst, attacker, target)
	if target:HasTag("epic") then
        target.components.health:DoDelta(-TUNING.CUTLASS_BONUS_DAMAGE)
    end
    -- mk_lv_dmg(inst, attacker, target)
    local pt = target:GetPosition()
    pt.y = pt.y + 2
    WARGON.make_fx(pt, "splash_water_drop")
end

local function cutlass_equip(inst, owner)
	WARGON_EQUIP_EX.object_on(owner, "tp_cutlass", "swap_object")
	if inst.task == nil then
		inst.task = WARGON.per_task(inst, 6*FRAMES, function()
			if owner.sg:HasStateTag("moving") then
				local pos = inst:GetPosition()
				if GetWorld().Flooding and GetWorld().Flooding:OnFlood(pos.x, 0, pos.z) then 
					local fx = WARGON.make_fx(owner, "splash_water_sink")
					-- local s = .6
					-- fx.Transform:SetScale(s,s,s)
					WARGON.set_scale(fx, .6)
				else
					local fx = WARGON.make_fx(owner, "splash_footstep")
					local rot = inst.Transform:GetRotation()
			        local CameraRight = TheCamera:GetRightVec()
			        local CameraDown = TheCamera:GetDownVec()
			        local displacement = CameraRight:Cross(CameraDown) * .15
			        local pos = pos - displacement 
			        fx.Transform:SetPosition(pos.x,pos.y, pos.z)
			        fx.Transform:SetRotation(rot)
				end
			end
		end, 2*FRAMES)
	end
end

local function cutlass_unequip(inst, owner)
	hand_unequip(inst, owner)
	if inst.task then
		inst.task:Cancel()
		inst.task = nil
	end
end

local function cutlass_fn(inst)
	WARGON_CMP_EX.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=TUNING.CUTLASS_DAMAGE, fn=cutlass_weapon_fn},
		equip = {equip=cutlass_equip, unequip=cutlass_unequip},
		finite = {use=TUNING.CUTLASS_USES, max=TUNING.CUTLASS_USES, fn=on_finish},
		})
	inst:AddTag("tp_forge_weapon")
	inst.components.weapon.getdamagefn = function(inst)
		local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
		local dmg = owner and owner.components.tplevel.attr.forge or 0
		return inst.components.weapon.damage + dmg
	end
	inst.AnimState:SetMultColour(1, 1, 1, .6)
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_CI"
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(10)
		inst:StartThread(function()
			for i = 1, 3 do
				do_area_damage(inst, 1.5, 50, "cutlass")
				WARGON.make_fx(inst, "splash_water_sink")
				Sleep(0.1)
			end
		end)
	end
end

local function sign_staff_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "tp_sign_staff", "swap_object")
end

local function sign_staff_spell(staff, target, pos)
	WARGON.make_fx(pos, "tp_fx_sign_wan")
	staff.components.tprecharge:SetRechargeTime(30)
	staff.components.finiteuses:Use()
	local caster = staff.components.inventoryitem.owner
	if caster and caster.components.sanity then
		caster.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
	end
end

local function sign_staff_test(staff, caster, target, pos)
	if staff.components.tprecharge then
		return staff.components.tprecharge:IsRecharged()
	end
end

local function sign_staff_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=sign_staff_equip, unequip=hand_unequip},
		finite = {use=5, max=5, fn=on_finish},
		caster = {spell=sign_staff_spell, test=sign_staff_test, can={point=true, inv=false}},
		})
	WARGON.add_tags(inst, {"nosteal", "nopunch"})
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(30)
	inst.fxcolour = {223/255, 208/255, 69/255}
	inst.castsound = "dontstarve/common/staffteleport"
end

local function forest_gun_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "swap_forest_gun", "swap_object")
	if inst.fx == nil then
		inst.fx = SpawnPrefab("tp_spirit_fx")
		inst.fx:AddTag("INTERIOR_LIMBO_IMMUNE")
        local follower = inst.fx.entity:AddFollower()
        follower:FollowSymbol( owner.GUID, "swap_object", 0, -110, 0 )
	end
end

local function forest_gun_unequip(inst, owner)
	hand_unequip(inst, owner)
	if inst.fx then
		inst.fx:Remove()
		inst.fx = nil
	end
end

local function forest_gun_weapon_fn(inst, owner, target)
	if inst.components.tpbullets:GetNum() > 0 then
		-- inst.components.tpbullets:DoDelta(-1)
		inst.components.tpbullets:Lose(1)
		if math.random() < .01 then
			local pos = WARGON.around_land(inst, 2)
			if pos then
				WARGON.make_spawn(pos, "tp_reporter6")
			end
		end
	end
end

local function forest_gun_take_bullet(inst)
	WARGON.CMP.add_cmps(inst, {
		weapon = {dmg=48, fx="tp_tree_seed_bullet", range={11, 13}},
	})
	WARGON.add_tags(inst, {"projectile", "speargun", "tp_forest_gun"})
end

local function forest_gun_lose_bullet(inst)
	WARGON.CMP.add_cmps(inst, {
		weapon = {dmg=10, fx="nil", range={nil, nil}},
	})
	WARGON.remove_tags(inst, {"projectile", "speargun", "tp_forest_gun"})
end

local function forest_gun_change_bullet(inst, current)
	if current == "pinecone" then
		WARGON.CMP.add_cmps(inst, {
			weapon = {dmg=68, fx="tp_tree_seed_bullet_2", range={15, 17}},
		})
	elseif current == "acorn" then
		WARGON.CMP.add_cmps(inst, {
			weapon = {dmg=48, fx="tp_tree_seed_bullet", range={11, 13}},	
		})
	elseif current == "jungletreeseed" then
		WARGON.CMP.add_cmps(inst, {
			weapon = {dmg=68, fx="tp_tree_seed_bullet_3", range={11, 13}},	
		})
	elseif current == "teatree_nut" then
		WARGON.CMP.add_cmps(inst, {
			weapon = {dmg=68, fx="tp_tree_seed_bullet_4", range={11, 13}},	
		})
	elseif current == "coconut" then
		WARGON.CMP.add_cmps(inst, {
			weapon = {dmg=68, fx="tp_tree_seed_bullet_5", range={11, 13}},
		})
	end
end

local function forest_gun_trader_test(inst, item)
	local tree_seeds = {
		["pinecone"] = 1,
		["acorn"] = 1,
		["jungletreeseed"] = 1,
		["teatree_nut"] = 1,
		["coconut"] = 1,
		-- ["tp_gingko"] = 1,
	}
	if tree_seeds[item.prefab] and not inst.components.tpbullets:IsFull() then
		return true
	end
end

local function forest_gun_trader_accept(inst, giver, item)
	if not inst.components.tpbullets:IsFull() then
		-- inst.components.tpbullets:DoDelta(1)
		inst.components.tpbullets:Add(1, item.prefab)
	end
end

local function forest_gun_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=10, fn=forest_gun_weapon_fn, },
		equip = {equip=forest_gun_equip, unequip=forest_gun_unequip},
		-- trader = {test=forest_gun_trader_test, accept=forest_gun_trader_accept},
	})
	-- inst.components.trader.enabled = true
	inst:AddComponent("tpbullets")
	inst.components.tpbullets.take_fn = forest_gun_take_bullet
	inst.components.tpbullets.lose_fn = forest_gun_lose_bullet
	inst.components.tpbullets.change_fn = forest_gun_change_bullet
end

local function tree_seed_bullet_hit(inst, attacker, target, weapon)
	local leaf_fxs = {
		"red_leaves",
		"green_leaves",
		"fall_mangrove_blue",
	}
	local leaf_fx = WARGON.make_fx(target, leaf_fxs[inst.colour])
	local s = 2
	leaf_fx.Transform:SetScale(s,s,s)
	WARGON.make_fx(target, "tp_fx_many_tree_seed")
	WARGON.area_dmg(inst, 5, attacker, 20, inst.prefab)
	inst:Remove()
end

local function tree_seed_bullet_fn(inst)
	inst.colour = math.random(3)
	local colours = {0,0,0,.5}
	WARGON.do_task(inst, 0, function()
		local pt = inst:GetPosition()
		inst.Transform:SetPosition(pt.x, 1, pt.z)
	end)
	WARGON.per_task(inst, .05, function()
		local fx = WARGON.make_fx(inst, "tp_fx_tree_seed_shadow_1")
		colours[inst.colour] = 1
		fx.AnimState:SetMultColour(unpack(colours))
	end)
	WARGON.CMP.add_cmps(inst, {
		proj = {speed=30, hit=tree_seed_bullet_hit},
	})
	WARGON.add_tags(inst, {"projectile"})
	inst:RemoveComponent("inventoryitem")
end

local function tree_seed_bullet_hit_2(inst, attacker, target, weapon)
	local leaf_fxs = {
		"red_leaves",
		"green_leaves",
		"fall_mangrove_blue",
	}
	-- local leaf_fx = WARGON.make_fx(target, leaf_fxs[inst.colour])
	-- local s = 2
	-- leaf_fx.Transform:SetScale(s,s,s)
	local fx = WARGON.make_fx(target, 'pine_needles')
	WARGON.set_scale(fx, 2)
	-- WARGON.make_fx(target, "tp_fx_many_tree_seed")
	inst:Remove()
end

local function tree_seed_bullet_fn_2(inst)
	inst.colour = math.random(3)
	local colours = {0,0,0,.5}
	WARGON.do_task(inst,0, function()
		local pt = inst:GetPosition()
		inst.Transform:SetPosition(pt.x, 1, pt.z)
	end)
	WARGON.per_task(inst, .05, function()
		local fx = WARGON.make_fx(inst, "tp_fx_tree_seed_shadow_2")
		colours[inst.colour] = 1
		fx.AnimState:SetMultColour(unpack(colours))
	end)
	WARGON.CMP.add_cmps(inst, {
		proj = {speed=35, hit=tree_seed_bullet_hit_2},
	})
	WARGON.add_tags(inst, {"projectile"})
	inst:RemoveComponent("inventoryitem")
end

local function tree_seed_bullet_hit_3(inst, attacker, target, weapon)
	local leaf_fxs = {
		"red_leaves",
		"green_leaves",
		"fall_mangrove_blue",
	}
	-- local leaf_fx = WARGON.make_fx(target, leaf_fxs[inst.colour])
	-- local s = 2
	-- leaf_fx.Transform:SetScale(s,s,s)
	-- WARGON.make_fx(target, "tp_fx_many_tree_seed")
	local fx = WARGON.make_fx(target, "feathers_packim_fire")
	WARGON.set_scale(fx, 2)
	if attacker.components.health then
		attacker.components.health:DoDelta(10)
	end
	inst:Remove()
end

local function tree_seed_bullet_fn_3(inst)
	inst.colour = math.random(3)
	local colours = {0,0,0,.5}
	WARGON.do_task(inst,0, function()
		local pt = inst:GetPosition()
		inst.Transform:SetPosition(pt.x, 1, pt.z)
	end)
	WARGON.per_task(inst, .05, function()
		local fx = WARGON.make_fx(inst, "tp_fx_tree_seed_shadow_3")
		colours[inst.colour] = 1
		fx.AnimState:SetMultColour(unpack(colours))
	end)
	WARGON.CMP.add_cmps(inst, {
		proj = {speed=30, hit=tree_seed_bullet_hit_3},
	})
	WARGON.add_tags(inst, {"projectile"})
	inst:RemoveComponent("inventoryitem")
end

local function tree_seed_bullet_hit_4(inst, attacker, target, weapon)
	local leaf_fxs = {
		"red_leaves",
		"green_leaves",
		"fall_mangrove_blue",
	}
	local leaf_fx = WARGON.make_fx(target, leaf_fxs[inst.colour])
	local s = 2
	leaf_fx.Transform:SetScale(s,s,s)
	-- WARGON.make_fx(target, "tp_fx_many_tree_seed")
	local pt = target:GetPosition()
	pt.x = pt.x + 1
	local fx = WARGON.make_fx(pt, "tp_fx_teatree_nut_surround")
	fx.master = target
	WARGON.do_task(target, .5, function()
		if target.components.sleeper then
            target.components.sleeper:AddSleepiness(10, 20)
        end
        WARGON.make_fx(target, "sanity_lower")
	end)
	inst:Remove()
end

local function tree_seed_bullet_fn_4(inst)
	inst.colour = math.random(3)
	local colours = {0,0,0,.5}
	WARGON.do_task(inst,0, function()
		local pt = inst:GetPosition()
		inst.Transform:SetPosition(pt.x, 1, pt.z)
	end)
	WARGON.per_task(inst, .05, function()
		local fx = WARGON.make_fx(inst, "tp_fx_tree_seed_shadow_4")
		colours[inst.colour] = 1
		fx.AnimState:SetMultColour(unpack(colours))
	end)
	WARGON.CMP.add_cmps(inst, {
		proj = {speed=25, hit=tree_seed_bullet_hit_4},
	})
	WARGON.add_tags(inst, {"projectile"})
	inst:RemoveComponent("inventoryitem")
end

local function tree_seed_bullet_hit_5(inst, attacker, target, weapon)
	local leaf_fxs = {
		"red_leaves",
		"green_leaves",
		"fall_mangrove_blue",
	}
	local leaf_fx = WARGON.make_fx(target, leaf_fxs[inst.colour])
	local s = 2
	leaf_fx.Transform:SetScale(s,s,s)
	-- WARGON.make_fx(target, "tp_fx_many_tree_seed")
	-- local dist_mult = math.max( 1, distsq(attacker:GetPosition(), target:GetPosition()) )
	local dist_mult = math.max(1, attacker:GetDistanceSqToPoint(target:GetPosition()) )
	-- print("tp_forest_gun", dist_mult)
	local ex_dmg = 14*7 / dist_mult
	if target.components.health then
		target.components.health:DoDelta(-ex_dmg)
	end
	if math.random() < .2 then
        local pt = target:GetPosition()
        local st_pt =  FindWalkableOffset(pt or attacker:GetPosition(), math.random()*2*PI, 2, 3)
        if st_pt then
            inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
            inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")            
            st_pt = st_pt + pt
            local st = SpawnPrefab("shadowtentacle")
            --print(st_pt.x, st_pt.y, st_pt.z)
            st.Transform:SetPosition(st_pt.x, st_pt.y, st_pt.z)
            st.components.combat:SetTarget(target)
        end
    end
	inst:Remove()
end

local function tree_seed_bullet_fn_5(inst)
	inst.colour = math.random(3)
	local colours = {0,0,0,.5}
	WARGON.do_task(inst,0, function()
		local pt = inst:GetPosition()
		inst.Transform:SetPosition(pt.x, 1, pt.z)
	end)
	WARGON.per_task(inst, .05, function()
		local fx = WARGON.make_fx(inst, "tp_fx_tree_seed_shadow_5")
		colours[inst.colour] = 1
		fx.AnimState:SetMultColour(unpack(colours))
	end)
	WARGON.CMP.add_cmps(inst, {
		proj = {speed=35, hit=tree_seed_bullet_hit_5},
	})
	WARGON.add_tags(inst, {"projectile"})
	inst:RemoveComponent("inventoryitem")
end

local function unreal_sword_weapon_fn(inst, owner, target)
	inst.fx.target = target
	inst.fx:start_task(inst)
end

local function unreal_sword_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "swap_nightsword_sharp", "swap_nightmaresword")
	if inst.fx == nil then
		inst.fx = SpawnPrefab("tp_fx_shadow_arc_creater")
		inst:AddChild(inst.fx)
	end
end

local function unreal_sword_unequip(inst, owner)
	hand_unequip(inst, owner)
	if inst.fx then
		inst.fx:Remove()
		inst.fx = nil
	end
end

local function unreal_sword_spell(staff, target, pos)
	local owner = staff.components.inventoryitem.owner
	if target then
		local pt = owner:GetPosition()
		local pt2 = target:GetPosition()
		owner.Transform:SetPosition(pt2:Get())
		target.Transform:SetPosition(pt:Get())
	else
		owner.components.inventory:ConsumeByName("nightmarefuel", 1)
		WARGON.make_fx(pos, "tp_fx_shadow_spawn")
		WARGON.do_task(staff, .5, function()
			local shadow = WARGON.make_spawn(pos, "tp_unreal_wilson")
			if WARGON.on_water(shadow) then
				shadow:SpawnShadowBoat(pos)
			end
			shadow.components.follower:SetLeader(owner)
			owner.components.health:DoDelta(-TUNING.SHADOWWAXWELL_HEALTH_COST)
		    owner.components.sanity:RecalculatePenalty()
		    owner.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_appear")
		end)
	end
end

local function unreal_sword_test(staff, caster, target, pos)
	if target and target:HasTag("tp_unreal_wilson") then
		-- return caster.components.rider:IsRiding() == false
		-- 	and caster.components.driver:GetIsDriving() == target.components.driver:GetIsDriving()
		return true
	end
	if caster.components.inventory:Has("nightmarefuel", 1) then
		return caster.components.sanity:GetMaxSanity() >= TUNING.SHADOWWAXWELL_SANITY_PENALTY
	end
end

local function unreal_sword_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=TUNING.NIGHTSWORD_DAMAGE, fn=unreal_sword_weapon_fn,
			effect={san=-TUNING.DAPPERNESS_SMALL}},
		equip = {equip=unreal_sword_equip, unequip=unreal_sword_unequip},
		finite = {use=TUNING.NIGHTSWORD_USES, max=TUNING.NIGHTSWORD_USES},
		caster = {spell=unreal_sword_spell, test=unreal_sword_test, 
			can={point=true, inv=false, target=true}},
	})
end

local function oak_armor_spawn_nuter(inst, data)
	WARGON.make_fx(inst, "boat_hit_fx_raft_bamboo")
	local pt = inst:GetPosition()
	for i = 1, math.random(2, 4) do
		local pos = WARGON.around_land(inst, math.random(3))
		if pos then
			if WARGON.on_water(inst, pos) then
				WARGON.make_fx(pos, "splash_water_drop")
			else
				local nuter = SpawnPrefab("birchnutdrake")
				if data.attacker and nuter.components.combat:CanTarget(data.attacker) then
					nuter.Transform:SetPosition(pos:Get())
					nuter.components.combat:SetTarget(data.attacker)
					nuter.components.lootdropper.numrandomloot = 0
					WARGON.no_save(nuter)
				else
					nuter:Remove()
				end
			end
		end
	end
end

local function oak_armor_equip(inst, owner)
	WARGON.EQUIP.body_on(owner, "armor_wood_haramaki", "swap_body")
	owner:AddTag("tp_oak_armor")
	owner:AddTag("birchnut")
	-- inst:ListenForEvent("attacked", function(inst, data)
	-- 	oak_armor_spawn_nuter(owner, data)
	-- 	WARGON.make_fx(owner, "boat_hit_fx_raft_bamboo")
	-- end, owner)
	owner:ListenForEvent("attacked", oak_armor_spawn_nuter)
end

local function oak_armor_unequip(inst, owner)
	WARGON.EQUIP.body_off(owner)
	owner:RemoveTag("tp_oak_armor")
	owner:RemoveTag("birchnut")
	-- inst:RemoveEventCallback('attacked', oak_armor_spawn_nuter, owner)
	owner:RemoveEventCallback("attacked", oak_armor_spawn_nuter)
end

local function oak_armor_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=oak_armor_equip, unequip=oak_armor_unequip, slot="body"},
		armor = {armor=TUNING.ARMORWOOD, absorb=.8},
		fuel = {value=TUNING.LARGE_FUEL},
	})
	WARGON.make_burn(inst, "small", TUNING.SMALL_BURNTIME)
	WARGON.make_prop(inst, "small")
	inst.components.burnable:MakeDragonflyBait(3)
end

local function pig_book_read_test(inst, reader)
	local inv = reader.components.inventory
	if inv:Has("meat", 1) or inv:Has("pigskin", 1) then
		return reader.components.sanity.current > 10
	end
end

local function pig_book_read_fn(inst, reader)
	local inv = reader.components.inventory
	if inv:Has("meat", 1) then
		inv:ConsumeByName("meat", 1)
	else
		inv:ConsumeByName("pigskin", 1)
	end
	reader.components.sanity:DoDelta(-10)
	-- reader.components.health:DoDelta(-10)
	local pos = WARGON.around_land(reader, math.random(3, 6))
	if pos then
		local pig = WARGON.make_spawn(pos, "pigman")
		if WARGON.on_water(pig) then
			WARGON.make_fx(pos, "splash_water_sink")
			pig:Remove()
		else
			WARGON.make_fx(pos, "tp_fx_shadow_bat")
			WARGON.make_fx(pos, "statue_transition")
			-- WARGON.make_fx(pos, "statue_transition_2")
			WARGON.make_fx(pos, "vortex_cloak_fx")
			reader.components.leader:AddFollower(pig)
			pig.components.follower:AddLoyaltyTime(1200)
		end
		return true
	end
end

local function pig_book_fn(inst)
	inst:AddTag("irreplaceable")
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		book = {fn=pig_book_read_fn, test=pig_book_read_test},
	})
end

local function brave_amulet_on_hunger_delta(inst, data)
	local p = inst.components.hunger:GetPercent()
	WARGON.add_hunger_rate(inst, "tp_brave_amulet", p)
	WARGON.add_dmg_rate(inst, "tp_brave_amulet", .4*p)
	if inst.components.tpbody then
		inst.components.tpbody:AddAbsorbModifier("tp_brave_amulet", .6*p)
	end
end

local function brave_amulet_equip(inst, owner)
	WARGON.EQUIP.body_on(owner, "amulet_red_occulteye", "swap_body")
	owner:ListenForEvent("hungerdelta", brave_amulet_on_hunger_delta)
	-- WARGON.add_hunger_rate(owner, "tp_brave_amulet", 1)
	-- WARGON.add_dmg_rate(owner, "tp_brave_amulet", .4)
	-- if owner.components.tpbody then
	-- 	owner.components.tpbody:AddAbsorbModifier("tp_brave_amulet", .6)
	-- end
	inst.components.fueled:StartConsuming()
end

local function brave_amulet_unequip(inst, owner)
	WARGON.EQUIP.body_off(owner)
	owner:RemoveEventCallback("hungerdelta", brave_amulet_on_hunger_delta)
	WARGON.remove_hunger_rate(owner, "tp_brave_amulet")
	WARGON.remove_dmg_rate(owner, "tp_brave_amulet")
	if owner.components.tpbody then
		owner.components.tpbody:RemoveAbsorbModifier("tp_brave_amulet")
	end
	inst.components.fueled:StopConsuming()
end

local function brave_amulet_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=brave_amulet_equip, unequip=brave_amulet_unequip, 
			slot=EQUIPSLOTS.NECK or EQUIPSLOTS.BODY, 
			effect={san=-TUNING.DAPPERNESS_SMALL} },
		fueled = {time=30*16, typ='nightmare', accept=true, 
			fn={finish=on_finish} },
	})
end

local function pig_lamp_put(inst, owner)
	inst.Light:Enable(false)
end

local function pig_lamp_drop(inst, dropper)
	inst.Light:Enable(true)
end

local function pig_lamp_test(inst)
	return GetClock():IsNight() and inst.components.cooldown:IsCharged()
end

local function pig_lamp_search_ents(name)
	for k,v in pairs(Ents) do
		if v.prefab == name then
			return v
		end
	end
end

local function pig_lamp_use(inst)
	if not pig_lamp_search_ents("tp_pig_spirit") then
		GetPlayer().components.sanity:DoDelta(-TUNING.SANITY_HUGE)
	    local spirit = WARGON.make_spawn(inst, "tp_pig_spirit")
	    inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
	end
    inst:Remove()
end

local function pig_lamp_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		invitem = {put=pig_lamp_put, drop=pig_lamp_drop},
		use = {str="wipe", test=pig_lamp_test, use=pig_lamp_use},
		cd = {time=1},
	})
	-- falloff, intensity, radius, colour, enable
	WARGON.make_light(inst, 0.5, .75, 2, {197/255,197/255,50/255}, true)
	inst.components.cooldown:StartCharging()
	WARGON.do_task(inst, 0, function()
		if c_countprefabs('tp_pig_lamp') > 1 then
			inst:Remove()
		end
	end)
end

local function bird_egg_hatched(inst)
	local bird = WARGON.make_spawn(inst, 'tp_small_bird')
	bird.sg:GoToState('hatch')
	inst:Remove()
end

local function bird_egg_check_hatch(inst)
	if inst.player_near and inst.components.hatchable.state == 'hatch' then
		bird_egg_hatched(inst)
	end
end

local function bird_egg_uncomfy_snd(inst)
	inst.SoundEmitter:KillSound("uncomfy")
    if inst.components.hatchable.toohot then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_hot_steam_LP", "uncomfy")
    elseif inst.components.hatchable.toocold then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_cold_shiver_LP", "uncomfy")
    end
end


local function bird_egg_loot_drop(inst)
	inst:AddComponent("lootdropper")
	if inst.components.hatchable.toohot then
        inst.components.lootdropper:SetLoot({"cookedsmallmeat"})
    else
        inst.components.lootdropper:SetLoot({'wetgoop'})
    end
    inst.components.lootdropper:DropLoot()
end

local function bird_egg_hatch_state(inst, state)
	inst.SoundEmitter:KillSound("uncomfy")

    if inst.components.floatable.onwater then
    	WARGON.do_task(inst, 15*FRAMES, function()
    		inst.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_cold_freeze")
    	end)
    	WARGON.do_task(inst, 30*FRAMES, bird_egg_loot_drop)
        inst.AnimState:PlayAnimation("idle_cold_water")

        inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    end

    if state == "crack" then
        local cracked = WARGON.make_spawn(inst, 'tp_bird_egg_cracked')
        cracked.AnimState:PlayAnimation("crack")
        cracked.AnimState:PushAnimation("idle_happy", true)
        cracked.components.floatable:UpdateAnimations("idle_crack_water", "idle_happy")
        cracked.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_hatch_crack")
        inst:Remove()
    elseif state == "uncomfy" then
        if inst.components.hatchable.toohot then
            inst.AnimState:PlayAnimation("idle_hot", true)
            inst.components.floatable:UpdateAnimations("idle_hot_water", "idle_hot")
        elseif inst.components.hatchable.toocold then
            inst.AnimState:PlayAnimation("idle_cold", true)
            inst.components.floatable:UpdateAnimations("idle_cold_water", "idle_cold")
        end
        bird_egg_uncomfy_snd(inst)
    elseif state == "comfy" then
        inst.AnimState:PlayAnimation("idle_happy", true)
        inst.components.floatable:UpdateAnimations("idle_crack_water", "idle_happy")
    elseif state == "hatch" then
        bird_egg_check_hatch(inst)
    elseif state == "dead" then
        if inst.components.hatchable.toohot then
            inst.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_hot_jump")
            WARGON.do_task(inst, 20*FRAMES, function()
            	inst.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_hot_explo")
            end)
            WARGON.do_task(inst, 20*FRAMES, bird_egg_loot_drop)
            inst.AnimState:PlayAnimation("toohot")
        elseif inst.components.hatchable.toocold then
        	WARGON.do_task(inst, 15*FRAMES, function()
        		inst.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_cold_freeze")
        	end)
        	WARGON.do_task(inst, 30*FRAMES, bird_egg_loot_drop)
            inst.AnimState:PlayAnimation("toocold")
        end
        
        inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    end
end

local function bird_egg_drop(inst)
	inst.components.hatchable:StartUpdating()
	bird_egg_check_hatch(inst)
	bird_egg_uncomfy_snd(inst)
end

local function bird_egg_put(inst)
	inst.components.hatchable:StopUpdating()
    inst.SoundEmitter:KillSound("uncomfy")
end

local function bird_egg_fn(inst)
	MakeInventoryFloatable(inst, "idle_water", "egg")
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		hatch = {state=bird_egg_hatch_state, 
			crake=TUNING.SMALLBIRD_HATCH_CRACK_TIME,
			hatch=30*16*1,
			-- hatch = 10,
			fail=TUNING.SMALLBIRD_HATCH_FAIL_TIME},
		invitem = {drop=bird_egg_drop, put=bird_egg_put},
	})
	inst.components.hatchable:StartUpdating()
	inst.player_near = false
end

local function bird_egg_cracked_near(inst)
	bird_egg_check_hatch(inst)
	inst.player_near = true
end

local function bird_egg_cracked_far(inst)
	inst.player_near = false
end

local function bird_egg_cracked_fn(inst)
	bird_egg_fn(inst)
	inst.components.hatchable.state = 'comfy'
	inst.components.floatable:UpdateAnimations("idle_crack_water", "idle_happy")
	WARGON.CMP.add_cmps(inst, {
		near = {dist={4,6}, near=bird_egg_cracked_near, far=bird_egg_cracked_far},
	})
end

local function pigking_hat_on_attacked(inst, data)
	if data.attacker then
		inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
			return dude:HasTag('pig') and not dude:HasTag("guard")
				and not dude:HasTag("werepig") 
		end, 5)
	end
end

local function pigking_hat_equip(inst, owner)
	WARGON.EQUIP.hat_on(owner, "beefalohat_pigking")
	if owner:HasTag('player') then
		owner:ListenForEvent('attacked', pigking_hat_on_attacked)
		owner:AddTag("pigroyalty")
	end
end

local function pigking_hat_unequip(inst, owner)
	WARGON.EQUIP.hat_off(owner)
	if owner:HasTag("player") then
		owner:RemoveEventCallback('attacked', pigking_hat_on_attacked)
		owner:RemoveTag("pigroyalty")
	end
end

local function pigking_hat_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {slot="head", equip=pigking_hat_equip, unequip=pigking_hat_unequip},
		-- trade = {},
		})
end

local function alloy_shine(inst)
	inst.task = nil
	if inst.onwater then
		inst.AnimState:PlayAnimation("sparkle_water")
		inst.AnimState:PushAnimation("idle_water")
	else
		inst.AnimState:PlayAnimation("sparkle")
		inst.AnimState:PushAnimation("idle")
    end
	inst.task = inst:DoTaskInTime(4+math.random()*5, function() alloy_shine(inst) end)
end

local function alloy_entity_wake(inst)
	inst.components.tiletracker:Start()
end

local function alloy_entity_sleep(inst)
	inst.components.tiletracker:Stop()
end

local function alloy_water_change(inst, onwater)
	inst.onwater = onwater
end

local function alloy_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		stack = {},
		})
	inst:AddComponent("tiletracker")
	inst.components.tiletracker:SetOnWaterChangeFn(alloy_water_change)
	inst.onwater = false
	inst.OnEntityWake = alloy_entity_wake
	inst.OnEntitySleep = alloy_entity_sleep
	alloy_shine(inst)
end

local function gift_use(inst)
	TheFrontEnd:PushScreen(GiftDialog( {
		{text=STRINGS.TP_STR.tp_gift_pigking, cb = function()
			local item = SpawnPrefab("tp_thumper_bp")
			GetPlayer().components.inventory:GiveItem(item)
		end},
		{text=STRINGS.TP_STR.tp_gift_gingko, cb = function()
			local item = SpawnPrefab("tp_egg_tool_bp")
			GetPlayer().components.inventory:GiveItem(item)
		end},
		{text=STRINGS.TP_STR.tp_gift_alloy, cb = function()
			local item = SpawnPrefab("tp_diving_mask")
			GetPlayer().components.inventory:GiveItem(item)
		end},
		{text=STRINGS.TP_STR.tp_gift_4, cb = function()
			local item = SpawnPrefab("tp_dragon_cage_bp")
			GetPlayer().components.inventory:GiveItem(item)
		end},
		{text=STRINGS.TP_STR.tp_gift_5, cb = function()
			local item = SpawnPrefab("tp_farm_pile_bp")
			GetPlayer().components.inventory:GiveItem(item)
		end},
	}))
	-- remove_gifts()
	inst:Remove()
end

local function gift_use_test(inst)
	return true
end

local function gift_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		use = {str="open", use=gift_use, test=gift_use_test},
	})
end

local function gingko_leaf_fn(inst)
	WARGON.set_scale(inst, .33)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		stack = {max=40},
		trade = {},
		})
	WARGON.make_burn(inst, "small", TUNING.SMALL_BURNTIME)
	WARGON.make_prop(inst, "small")
	WARGON.burn_bait(inst, 3)
	WARGON.make_blow(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
end

local function grass_pigking_accept(inst, giver, item)
	if item.components.tradable 
	and item.components.tradable.goldvalue > 0 then
		-- inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingThrowGold")
		WARGON.make_fx(inst, "tp_fx_pigking")
		if inst.components.tppigtask then
			inst.components.tppigtask:Trigger()
		end
		for i = 1, item.components.tradable.goldvalue do
			-- inst.components.lootdropper:SpawnLootPrefab("goldnugget")
			local nug = SpawnPrefab("goldnugget")
			WARGON.pigking_throw(inst, nug)
		end
		-- WARGON.do_task(inst, 1.5, function()
		-- 	inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingThrowGold")
		-- end)
	end
end

local function grass_pigking_test(inst, item, giver)
	if item.components.tradable then
		if item.components.tradable.goldvalue > 0 then
			return true
		end
	end
end

local function grass_pigking_fn(inst)
	inst:AddTag("irreplaceable")
	WARGON.set_scale(inst, .33)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		-- loot = {},
		-- tptechmachine = {},
		trader = {accept=grass_pigking_accept, test=grass_pigking_test},
		tppigtask = {},
		})
	-- inst.components.tptechmachine.tech = "pigking"
	inst.AnimState:Hide("snow")
end

local function octopus_fn(inst)
	WARGON.set_scale(inst, 2)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		-- invitem = {drop=octopus_drop, put=octopus_put},
		-- tptechmachine = {},
	})
	-- inst.components.tptechmachine.tech = "octopus"
end

local function boss_loot_fn(inst)
	local weapons = {
		"tp_hambat", "tp_spear_lance", "tp_spear_gungnir",
		"tp_staff_trinity", "tp_spear_fire", "tp_spear_ice",
		"tp_spear_thunder", "tp_spear_wind", "tp_oak_armor",
		"tp_ballhat", "tp_pig_lamp",
		"tp_spear_wrestle", "tp_spear_earth", "tp_spear_speed",
		"tp_spear_lightning", "tp_cane",
		"tp_armor_lamellar", "tp_hat_helm",
		"tp_gift", "tp_treasure_map", "tp_spear_diamond",
	}
	WARGON.do_task(inst, 0, function()
		local item = WARGON.make_spawn(inst, weapons[math.random(#weapons)])
		local loot = WARGON.make_spawn(inst, "tp_epic")
		loot.components.stackable:SetStackSize(math.random(6))
		inst:Remove()
	end)
end

local function loot_fn(inst)
	inst:AddComponent('lootdropper')
	WARGON.do_task(inst, 0, function()
		if inst.loot_prefab then
			inst.components.lootdropper:SpawnLootPrefab(inst.loot_prefab)
		end
		inst:Remove()
	end)
end

local function epic_fn(inst)
	inst:AddTag("tp_level_epic")
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		stack = {max=40},
		trade = {},
		})
	-- inst:AddComponent("edible")
 --    inst.components.edible.foodtype = "VEGGIE"
 --    inst.components.edible.healthvalue = 1
 --    inst.components.edible.hungervalue = 1
 --    inst.components.edible.sanityvalue = 1
end

local function rider_spawner_fn(inst)
	WARGON.do_task(inst, 0, function()
		-- local pos = inst:GetPosition()
		if c_findtag("tp_sign_rider", 9001) == nil then
			for i = 1, 4 do
				local radius = 10
				local pos = WARGON.around_land(inst, radius)
				if pos then
					if i <= 1 then
						WARGON.make_spawn(pos, "tp_sign_rider")
						
					else
						WARGON.make_spawn(pos, "tp_sign_rider_"..i)
					end
					WARGON.make_fx(pos, "statue_transition")
					WARGON.make_fx(pos, "statue_transition_2")
				end
			end
		end
		inst:Remove()
	end)
end

local function angry_remove_fn(inst)
	WARGON.do_task(inst, 0, function()
		local player = GetPlayer()
		if player.components.tpangry then
			player.components.tpangry:ReTime()
		end
		player.components.talker:Say(STRINGS.TP_STR.tp_curse)
		inst:Remove()
	end)
end

local function egg_tool_accept(inst, giver, item)
	if item.components.stackable then
		local size = item.components.stackable:StackSize()
		c_give("rottenegg", size)
		c_give("bird_egg_cooked", size)
		inst.components.finiteuses:Use()
	end
end

local function egg_tool_test(inst, item, giver)
	return item.prefab == "bird_egg"
end

local function egg_tool_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		trader = {accept=egg_tool_accept, test=egg_tool_test},
		finite = {max=5, use=5, fn=on_finish},
	})
end

-- local TpComposed = require "screens/tp_composed_panel"

local function intro_inspect(inst)
	-- TheFrontEnd:PushScreen(TpComposed())
end

local function intro_fn(inst)
	MakeInventoryFloatable(inst, "book_meteor_water", "book_meteor")
	WARGON.CMP.add_cmps(inst, {
		inspect = {fn=intro_inspect},
	})
end

-- local TpUpdate = require "screens/tp_update_panel"

local function update_inspect(inst)
	-- TheFrontEnd:PushScreen(TpUpdate())
end

local function update_fn(inst)
	MakeInventoryFloatable(inst, "book_brimstone_water", "book_brimstone")
	WARGON.CMP.add_cmps(inst, {
		inspect = {fn=update_inspect},
	})
end

local function diving_mask_equip(inst, owner)
	owner:AddTag("tp_diver")
	WARGON.EQUIP.hat_open(owner, "hat_gasmask")
end

local function diving_mask_unequip(inst, owner)
	owner:RemoveTag("tp_diver")
	WARGON.EQUIP.hat_off(owner)
end

local function diving_mask_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=diving_mask_equip, unequip=diving_mask_unequip, slot='head'}
		})
end

local function horn_use_test(inst)
	return true
end

local function horn_use(inst)
	GetPlayer().sg:GoToState("tp_spawn_beefalo")
	WARGON.make_spawn(inst, "rider_sp")
	inst:Remove()
end

local function horn_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		use = {use=horn_use, test=horn_use_test},
	})
end

local function magic_book_test(inst, item, slot)
    return item:HasTag("tp_scroll")
end

local function magic_book_fn(inst)
    WARGON.CMP.add_cmps(inst, {
    	inspect = {},
        cont = {test=magic_book_test},
        })
    local slotpos = {}
    for y = 0, 6 do
        table.insert(slotpos, Vector3(-162, -y*75 + 240 ,0))
        table.insert(slotpos, Vector3(-162 +75, -y*75 + 240 ,0))
    end
    inst.components.container:SetNumSlots(#slotpos)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_krampusbag_2x8"
    inst.components.container.widgetanimbuild = "ui_krampusbag_2x8"
    inst.components.container.widgetpos = Vector3(-5,-120,0)
    inst.components.container.side_widget = true    
    inst.components.container.type = "scroll_container"
end

local function treasure_map_book_fn(inst, reader)
	for tries = 1, 100 do
		-- tries = tries + 1
		local pt = reader:GetPosition()
		local pos = nil
		-- if WARGON.is_dlc(1) or WARGON.is_dlc(3) then
			-- pos = reader:around_land(math.random(100, 700), math.random(6, 9)*2)
		-- elseif WARGON.is_dlc(2) then
			pos = FindGroundOffset(pt, math.random() * 2 * math.pi, math.random(100, 700), 18)
		-- end
		if pos then
			local pb = SpawnPrefab("buriedtreasure")
			-- pb:set_pos(pos:Get())
			local spawn_pos = pt + pos
			pb:set_pos(spawn_pos:Get())

			pb:SetRandomTreasure()
			pb:Reveal(pb)
			pb:RevealFog(pb)
			pb:FocusMinimap(pb)
			inst:Remove()
			return true
		end
	end
end

local function treasure_map_fn(inst)
	inst:add_cmps({
		inspect = {},
		book = {fn = treasure_map_book_fn, act="map"},
	})
end

local function fix_powder_fn(inst)
	inst:add_cmps({
		inspect = {},
		stack = {max=40},
		tpinterable = {},
	})
	inst:AddTag("tp_fix_powder")
	inst.components.tpinterable:SetFn(function(inst, target, doer)
		local finiteuses = target and target.components.finiteuses
		if finiteuses and finiteuses:GetUses() < finiteuses.total then
			local item = inst.components.stackable:Get()
			item:Remove()
			local uses = math.min(finiteuses:GetUses()+30, finiteuses.total)
			finiteuses:SetUses(uses)
		end
		local armor = target and target.components.armor
		if armor and armor:GetPercent() < 1 then
			local item = inst.components.stackable:Get()
			item:Remove()
			local condition = target.components.armor.condition
			local p = math.min((condition+200)/target.components.armor.maxcondition,1)
			armor:SetPercent(p)
		end
	end)
end

local function red_dragon_sack_dropper_fn(inst)
	-- inst:RemoveComponent("inventoryitem")
	inst:do_task(0, function()
		-- print("red_dragon_sack_dropper")
		local can_spawn = true
		for k,v in pairs(Ents) do
			if v.prefab == "tp_red_dragon_sack" then
				can_spawn = false
				break
			end
		end
		if can_spawn then
			WARGON.make_spawn(inst, "tp_red_dragon_sack")
		end
		inst:Remove()
	end)
end

local function transport_plane_fn(inst)
	inst:RemoveComponent("inventoryitem")
	inst:do_task(0, function()
		inst.fx = SpawnPrefab("torchfire")
		inst:AddChild(inst.fx)
		inst.fx.Transform:SetPosition(0, -.3, 0)
		inst.Physics:SetMotorVel(0, 30, 0)
	end)
	inst:do_task(2, function()
		inst:Remove()
		local box = c_find("bundle")
		if box and box.components.inventoryitem.owner == nil then
			local pt = GetPlayer():GetPosition()
			pt.y = pt.y + 20
			WARGON.make_fx(box, "collapse_small")
			box:set_pos(pt:Get())
			box.components.inventoryitem:OnDropped()
		else
			GetPlayer().components.talker:Say(STRINGS.TP_STR.tp_transport_plane_announce)
		end
	end)
end

local function bat_scythe_equip(inst, owner)
	WARGON.EQUIP.object_on(owner, "swap_batbat_scythe", "swap_batbat")
	owner:AddTag("tp_bat_scythe")
end

local function bat_scythe_unequip(inst, owner)
	hand_unequip(inst, owner)
	owner:RemoveTag("tp_bat_scythe")
end

local function bat_scythe_fn(inst)
	inst:add_cmps({
		inspect = {},
		weapon = {dmg=10},
		equip = {equip=bat_scythe_equip, unequip=bat_scythe_unequip, },
		finite = {max=100, use=100},
	})
end

return
MakeItem("tp_strawhat", Anims.strawhat, strawhat_fn, "strawhat_cowboy"),
MakeItem("tp_strawhat2", Anims.strawhat, strawhat2_fn, "strawhat_cowboy"),
MakeItem("tp_strawhat_saddle", Anims.strawhat, strawhat_saddle_fn, "strawhat_cowboy"),
MakeItem("tp_strawhat_trap", Anims.strawhat_trap, strawhat_trap_fn, "strawhat_cowboy"),
MakeItem("tp_ballhat", Anims.ballhat, ballhat_fn, "footballhat_combathelm"),
MakeItem("tp_woodarmor", Anims.wood, wood_fn, "armor_wood_fangedcollar"),
MakeItem("tp_hambat", Anims.ham, ham_fn, "ham_bat_spiralcut"),
MakeItem("tp_staff_trinity", Anims.spear, staff_trinity_fn, "spear_bee"),
MakeItem("tp_rocket", Anims.flare, rocket_fn, "tp_flare"),
MakeItem("tp_cane", Anims.cane, cane_fn, "cane_ancient"),
MakeItem("tp_cutlass", Anims.cutlass, cutlass_fn, "tp_cutlass"),
MakeItem("tp_sign_staff", Anims.sign, sign_staff_fn, "tp_sign_staff"),
MakeItem("tp_forest_gun", Anims.gun, forest_gun_fn, "tp_forest_gun"),
MakeItem("tp_tree_seed_bullet", Anims.acorn, tree_seed_bullet_fn, nil, "acorn"),
MakeItem("tp_tree_seed_bullet_2", Anims.pinecone, tree_seed_bullet_fn_2, nil, "acorn"),
MakeItem("tp_tree_seed_bullet_3", Anims.jungletreeseed, tree_seed_bullet_fn_3, nil, "acorn"),
MakeItem("tp_tree_seed_bullet_4", Anims.teatree_nut, tree_seed_bullet_fn_4, nil, "acorn"),
MakeItem("tp_tree_seed_bullet_5", Anims.coconut, tree_seed_bullet_fn_5, nil, "acorn"),
MakeItem("tp_unreal_sword", Anims.sword, unreal_sword_fn, "nightsword_sharp"),
MakeItem("tp_oak_armor", Anims.soft_wood, oak_armor_fn, "armor_wood_haramaki"),
MakeItem("tp_pig_book", Anims.pig_book, pig_book_fn, "pig_book"),
MakeItem("tp_brave_amulet", Anims.amulet, brave_amulet_fn, "amulet_red_occulteye"),
MakeItem("tp_pig_lamp", Anims.pig_lamp, pig_lamp_fn, "pig_lamp"),
MakeItem('tp_bird_egg', Anims.tall_bird_egg, bird_egg_fn, nil, 'tallbirdegg'),
MakeItem('tp_bird_egg_cracked', Anims.tall_bird_egg, bird_egg_cracked_fn, nil, 'tallbirdegg_cracked'),
MakeItem('tp_pigking_hat', Anims.pigking_hat, pigking_hat_fn, 'beefalohat_pigking'),
MakeItem('tp_alloy', Anims.alloy, alloy_fn, 'tp_alloy'),
MakeItem('tp_gift', Anims.gift, gift_fn, 'tp_gift'),
MakeItem('tp_gingko_leaf', Anims.gingko_leaf, gingko_leaf_fn, 'tp_gingko_leaf'),
MakeItem('tp_grass_pigking', Anims.grass_pigking, grass_pigking_fn, 'tp_grass_pigking'),
MakeItem('tp_octopus', Anims.octopus, octopus_fn, 'tp_octopus'),
MakeItem('tp_boss_loot', {}, boss_loot_fn, 'tp_gift'),
MakeItem('tp_loot', {}, loot_fn, 'tp_gift'),
MakeItem('tp_epic', Anims.epic, epic_fn, 'tp_epic'),
MakeItem('tp_egg_tool', Anims.egg_tool, egg_tool_fn, 'tp_egg_tool'),
MakeItem('tp_intro', Anims.books, intro_fn, nil, 'book_meteor'),
MakeItem('tp_update', Anims.books, update_fn, nil, 'book_brimstone'),
MakeItem('tp_diving_mask', Anims.gasmask, diving_mask_fn, nil, 'gasmaskhat'),
MakeItem("tp_magic_book", Anims.book_maxwell, magic_book_fn, nil, "waxwelljournal"),
MakeItem("tp_treasure_map", Anims.map, treasure_map_fn, nil, "stash_map"),
MakeItem("tp_fix_powder", Anims.fix_powder, fix_powder_fn, "tp_fix_powder"),
MakeItem("tp_red_dragon_sack_dropper", {}, red_dragon_sack_dropper_fn, nil, "ash"),
MakeItem("tp_transport_plane", Anims.rocket, transport_plane_fn, nil, "ash"),
MakeItem("tp_bat_scythe", Anims.bat_scythe, bat_scythe_fn, "batbat_scythe"),

MakeItem("tp_horn", Anims.horn, horn_fn, nil, "horn")