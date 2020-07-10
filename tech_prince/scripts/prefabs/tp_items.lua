local GiftDialog = require("screens/gift_select")

local ashs = {"ash", "ash", "idle", nil}
local strawhats = {"strawhat", "strawhat_cowboy", "anim", "idle_water"}
local strawhat_traps = {"tp_strawhat_trap", "tp_strawhat_trap", "idle", "idle_water"}
local ballhats = {"footballhat", "footballhat_combathelm", "anim", "idle_water"}
local woods = {"armor_wood_fangedcollar", "armor_wood_fangedcollar", "anim", "idle_water"}
local hams = {"ham_bat", "ham_bat_spiralcut", "idle", "idle_water"}
local rockets = {"trinkets", "trinkets", "5", "5_water"}
local canes = {"cane", "cane_ancient", "idle", "idle_water"}
local cutlasses = {"tp_cutlass", "tp_cutlass", "idle", "idle_water"}
local signs = {"tp_sign_staff", "tp_sign_staff", "idle", "idle_water"}
local guns = {"tp_forest_gun", "tp_forest_gun", "idle", "idle_water"}
local acorns = {"acorn", "acorn", "idle", nil}
local swords = {"nightmaresword", "nightsword_sharp", "idle", "idle_water"}
local spears = {"spear", "spear_bee", "idle", "idle_water"}
local ice_staffs = {"staffs", "icestaff_bee", "bluestaff", "bluestaff_water"}
local fire_staffs = {"staffs", "firestaff_bee", "redstaff", "redstaff_water"}
local soft_woods = {"armor_wood_haramaki", "armor_wood_haramaki", "anim", 'idle_water'}
local pig_books = {"pig_book", "pig_book", "idle", "idle_water"}
local pig_lamps = {"pig_lamp", "pig_lamp", "idle_on", "idle_on_water"}
local amulets = {"amulets", "amulet_red_occulteye", "redamulet", "redamulet_water"}
local pinecones = {"pinecone", "pinecone", "idle", nil}
local tall_bird_eggs = {'egg', 'tallbird_egg', 'egg', "idle_water"}
local pigking_hats = {'beefalohat', 'beefalohat_pigking', 'anim', 'idle_water'}
local alloys = {'tp_alloy', 'tp_alloy', 'idle', 'idle_water'}
local gifts = {'tp_gift', 'tp_gift', 'idle', nil}
local flares = {'tp_flare', 'tp_flare', 'idle', nil}
local gingko_leafs = {'tp_gingko_leaf', 'tp_gingko_leaf', 'idle', nil}

local function do_area_damage(inst, range, dmg, reason)
	local owner = inst.components.inventoryitem.owner
	WARGON.area_dmg(inst, range, owner, dmg, reason)
end

local function ash_fn(inst)
	WARGON_CMP_EX.add_cmps(inst, {
		stack = {max=40},
		inspect = {},
	})
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
		inst.components.tphatball:Trigger()
	end
end

local function strawhat_throw(inst, thrower, pt)
	inst.Physics:SetFriction(.2)
	inst.per_task = WARGON.per_task(inst, .1, function() strawhat_score(inst, thrower) end)
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
	if math.random() < .8 then
		if owner.components.tpbuff then
			owner.components.tpbuff:AddBuff("tp_ballhat")
		end
	end
end

local function ballhat_equip(inst, owner)
	WARGON.EQUIP.hat_on(owner, "footballhat_combathelm")
	inst:ListenForEvent("attacked", function(inst, data)
		ballhat_attacked(owner, data)
	end, owner)
end

local function ballhat_unequip(inst, owner)
	WARGON.EQUIP.hat_off(owner)
	inst:RemoveEventCallback("attacked", ballhat_attacked, owner)
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
	WARGON.make_fx(target, "tp_fx_many_small_meat")
end

local function ham_equip(inst, owner)
	WARGON_EQUIP_EX.object_on(owner, "swap_ham_bat_spiralcut", "swap_ham_bat")
end

local function ham_throw(inst, owner, pt)
	WARGON.do_task(inst, .5, function()
		local function stop_task(inst)
			if inst.no_drop then
				inst.no_drop:Cancel()
				inst.no_drop = nil
			end
			if inst.drop_task then
				inst.drop_task:Cancel()
				inst.drop_task = nil
			end
		end
		inst.Transform:SetPosition(pt.x, pt.y+20, pt.z)
		inst.drop_task = WARGON.per_task(inst, .1, function()
			local pos = inst:GetPosition()
			if pos.y <= .1 then
				WARGON.make_fx(inst, "tp_fx_ham_ground_pound")
				stop_task(inst)
			end
		end)
		inst.no_drop = WARGON.do_task(inst, 2.5, function()
			local pos = inst:GetPosition()
			inst.Transform:SetPosition(pos.x, 0, pos.z)
			WARGON.make_fx(inst, "tp_fx_ham_ground_pound")
			stop_task(inst)
		end)
	end)
end

local function ham_onload(inst, data)
	ham_update(inst)
end

local function ham_fn(inst)
	WARGON_CMP_EX.add_cmps(inst, {
		perish = {time=TUNING.PERISH_MED, spoil="spoiled_food"},
		weapon = {dmg=34*1.75, fn=ham_weapon_fn},
		equip = {equip=ham_equip, unequip=hand_unequip},
		combat = {dmg=30},
	})
	WARGON.add_tags(inst, {"show_spoilage", "icebox_valid"})
	inst:AddComponent("tpthrow")
	inst.components.tpthrow.onthrown = ham_throw
	inst.components.tpthrow.speed = 40
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
end

local function staff_trinity_ice_weapon_fn(inst, owner, target)
    if target.sg ~= nil and not target.sg:HasStateTag("frozen") then
        target:PushEvent("attacked", { attacker = owner, damage = 0 })
    end
	WARGON.frozen_prefab(target)
	if owner and owner.components.sanity then
		owner.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY)
	end
end

local function staff_trinity_ice(inst)
	WARGON.CMP.add_cmps(inst, {
		weapon = {dmg=0, fn=staff_trinity_ice_weapon_fn, fx='ice_projectile',
			range={8,10} },
	})
	WARGON.remove_tags(inst, {"sharp"})
end

local function staff_trinity_fire_weapon_fn(inst, owner, target)
	WARGON.fire_prefab(target)
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
	WARGON.remove_tags(inst, {"sharp"})
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
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_HUA"
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(1)
	end
end

local function mk_lv_dmg(inst, owner, target)
	local level = owner.components.tplevel.level or 1
	local dmg = 5*(level-1)
	target.components.health:DoDelta(-dmg)
end

local function cutlass_weapon_fn(inst, attacker, target)
    if target:HasTag("epic") then
        target.components.health:DoDelta(-TUNING.CUTLASS_BONUS_DAMAGE)
    end
    mk_lv_dmg(inst, atttacker, target)
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
	inst.AnimState:SetMultColour(1, 1, 1, .6)
	inst:AddComponent("tpmove")
	inst.components.tpmove.action = "TP_CI"
	inst:AddComponent("tprecharge")
	inst.components.tprecharge:SetRechargeTime(10)
	inst.components.tpmove.onmove = function(inst)
		inst.components.tprecharge:SetRechargeTime(10)
		inst:StartThread(function()
			for i = 1, 3 do
				do_area_damage(inst, 1.5, 30, "cutlass")
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
		inst.components.tpbullets:DoDelta(-1)
	end
end

local function forest_gun_take_bullet(inst)
	WARGON.CMP.add_cmps(inst, {
		weapon = {dmg=68, fx="tp_tree_seed_bullet", range={11, 13}},
	})
	WARGON.add_tags(inst, {"projectile", "speargun", "tp_forest_gun"})
end

local function forest_gun_lose_bullet(inst)
	WARGON.CMP.add_cmps(inst, {
		weapon = {dmg=10, fx="nil", range={nil, nil}},
	})
	WARGON.remove_tags(inst, {"projectile", "speargun", "tp_forest_gun"})
end

local function forest_gun_trader_test(inst, item)
	local tree_seeds = {
		-- ["pinecone"] = 1,
		["acorn"] = 1,
		-- ["jungletreeseed"] = 1,
		-- ["teatree_nut"] = 1,
		-- ["tp_gingko"] = 1,
	}
	if tree_seeds[item.prefab] and not inst.components.tpbullets:IsFull() then
		return true
	end
end

local function forest_gun_trader_accept(inst, giver, item)
	if not inst.components.tpbullets:IsFull() then
		inst.components.tpbullets:DoDelta(1)
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

local function unreal_sword_test(staff, caster, target, pos)
	if caster.components.inventory:Has("nightmarefuel", 1) then
		return caster.components.sanity:GetMaxSanity() >= TUNING.SHADOWWAXWELL_SANITY_PENALTY
	end
end

local function unreal_sword_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		weapon = {dmg=TUNING.NIGHTSWORD_DAMAGE, fn=unreal_sword_weapon_fn,
			effect={san=TUNING.DAPPERNESS_SMALL}},
		equip = {equip=unreal_sword_equip, unequip=unreal_sword_unequip},
		finite = {use=TUNING.NIGHTSWORD_USES, max=TUNING.NIGHTSWORD_USES},
		caster = {spell=unreal_sword_spell, test=unreal_sword_test, can={point=true, inv=false}},
	})
end

local function oak_armor_spawn_nuter(inst, data)
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
	inst:ListenForEvent("attacked", function(inst, data)
		oak_armor_spawn_nuter(owner, data)
		WARGON.make_fx(owner, "boat_hit_fx_raft_bamboo")
	end, owner)
end

local function oak_armor_unequip(inst, owner)
	WARGON.EQUIP.body_off(owner)
	owner:RemoveTag("tp_oak_armor")
	inst:RemoveEventCallback('attacked', oak_armor_spawn_nuter, owner)
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
		return reader.components.sanity.current > 20
	end
end

local function pig_book_read_fn(inst, reader)
	local inv = reader.components.inventory
	if inv:Has("meat", 1) then
		inv:ConsumeByName("meat", 1)
	else
		inv:ConsumeByName("pigskin", 1)
	end
	reader.components.sanity:DoDelta(-20)
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
			pig.components.follower:AddLoyaltyTime(30 * 16)
		end
		return true
	end
end

local function pig_book_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		book = {fn=pig_book_read_fn, test=pig_book_read_test},
	})
end

local function brave_amulet_equip(inst, owner)
	WARGON.EQUIP.body_on(owner, "amulet_red_occulteye", "swap_body")
	WARGON.add_hunger_rate(owner, "tp_brave_amulet", 1)
	WARGON.add_dmg_rate(owner, "tp_brave_amulet", .4)
	owner.components.health:SetAbsorptionAmount(.6)
	inst.components.fueled:StartConsuming()
end

local function brave_amulet_unequip(inst, owner)
	WARGON.EQUIP.body_off(owner)
	WARGON.remove_hunger_rate(owner, "tp_brave_amulet")
	WARGON.remove_dmg_rate(owner, "tp_brave_amulet")
	owner.components.health:SetAbsorptionAmount(0)
	inst.components.fueled:StopConsuming()
end

local function brave_amulet_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		equip = {equip=brave_amulet_equip, unequip=brave_amulet_unequip, slot='body',
			effect={san=TUNING.DAPPERNESS_SMALL} },
		fueled = {time=TUNING.BLUEAMULET_FUEL, typ='nightmare', accept=true, 
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
			-- hatch=30*16*1,
			hatch = 10,
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
			if WARGON.is_dlc(1) then
				local pigking = c_find('pigking')
				if pigking then
					-- pigking.pig_builder = true
					GetPlayer().components.tptech.unlock = true
				end
			else
				local item = SpawnPrefab("tp_gingko")
				GetPlayer().components.inventory:GiveItem(item)
			end
		end},
		{text=STRINGS.TP_STR.tp_gift_gingko, cb = function()
			local item = SpawnPrefab("tp_gingko_leaf")
			GetPlayer().components.inventory:GiveItem(item)
		end},
		{text=STRINGS.TP_STR.tp_gift_alloy, cb = function()
			local item = SpawnPrefab("tp_alloy")
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
		})
	WARGON.make_burn(inst, "small", TUNING.SMALL_BURNTIME)
	WARGON.make_prop(inst, "small")
	WARGON.burn_bait(inst, 3)
	WARGON.make_blow(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
end

local function MakeItem(name, anims, item_fn, atlas, img)
	local function fn()
		local the_atlas = atlas and "images/inventoryimages/"..atlas..".xml" 
		local the_img = img or atlas
	 	local inst = WARGON.make_prefab(anims, anims[4], "inv", nil, nil)
	 	WARGON_CMP_EX.add_cmps(inst, {
	 		invitem = {atlas=the_atlas, img=the_img},
	 	})
	 	if item_fn then
	 		item_fn(inst)
	 	end

	    return inst
	end
	return Prefab("common/inventory/"..name, fn, {})
end

return 
	-- MakeItem("tp_ash", ashs, ash_fn, nil, "ash"),
	MakeItem("tp_strawhat", strawhats, strawhat_fn, "strawhat_cowboy"),
	MakeItem("tp_strawhat2", strawhats, strawhat2_fn, "strawhat_cowboy"),
	MakeItem("tp_strawhat_saddle", strawhats, strawhat_saddle_fn, "strawhat_cowboy"),
	MakeItem("tp_strawhat_trap", strawhat_traps, strawhat_trap_fn, "strawhat_cowboy"),
	MakeItem("tp_ballhat", ballhats, ballhat_fn, "footballhat_combathelm"),
	MakeItem("tp_woodarmor", woods, wood_fn, "armor_wood_fangedcollar"),
	MakeItem("tp_hambat", hams, ham_fn, "ham_bat_spiralcut"),
	MakeItem("tp_staff_trinity", spears, staff_trinity_fn, "spear_bee"),
	MakeItem("tp_rocket", flares, rocket_fn, "tp_flare"),
	MakeItem("tp_cane", canes, cane_fn, "cane_ancient"),
	MakeItem("tp_cutlass", cutlasses, cutlass_fn, "tp_cutlass"),
	MakeItem("tp_sign_staff", signs, sign_staff_fn, "tp_sign_staff"),
	MakeItem("tp_forest_gun", guns, forest_gun_fn, "tp_forest_gun"),
	MakeItem("tp_tree_seed_bullet", acorns, tree_seed_bullet_fn, nil, "acorn"),
	MakeItem("tp_unreal_sword", swords, unreal_sword_fn, "nightsword_sharp"),
	MakeItem("tp_oak_armor", soft_woods, oak_armor_fn, "armor_wood_haramaki"),
	MakeItem("tp_pig_book", pig_books, pig_book_fn, "pig_book"),
	MakeItem("tp_brave_amulet", amulets, brave_amulet_fn, "amulet_red_occulteye"),
	MakeItem("tp_pig_lamp", pig_lamps, pig_lamp_fn, "pig_lamp"),
	MakeItem('tp_bird_egg', tall_bird_eggs, bird_egg_fn, nil, 'tallbirdegg'),
	MakeItem('tp_bird_egg_cracked', tall_bird_eggs, bird_egg_cracked_fn, nil, 'tallbirdegg_cracked'),
	MakeItem('tp_pigking_hat', pigking_hats, pigking_hat_fn, 'beefalohat_pigking'),
	MakeItem('tp_alloy', alloys, alloy_fn, 'tp_alloy'),
	MakeItem('tp_gift', gifts, gift_fn, 'tp_gift'),
	MakeItem('tp_gingko_leaf', gingko_leafs, gingko_leaf_fn, 'tp_gingko_leaf')