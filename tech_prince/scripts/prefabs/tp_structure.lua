local tent_phy = {1, nil}
local ham_phy = {.5, nil}
local bench_phy = {2, 1.2}
local obelisk_phy = {1, nil}
local birdcage_phy = {.5, nil}
local ice_statue_phy = {1.5, nil}
local tent_map = 'tent_circus.tex'
local bench_map = 'workbench_obsidian.png'
local box_map = 'treasure_chest_sacred.tex'
local cork_chest_map = 'cork_chest.png'
local lake_map = "tp_moon_lake.tex"
local tents = {"tent", "tent_circus", "idle"}
local hams = {"ham_bat", "ham_bat", "idle"}
local benchs = {"workbench_obsidian", "workbench_obsidian", "idle"}
local boxes = {"chest", "treasure_chest_sacred", "closed"}
local cork_chests = {"treasure_chest_cork", "treasure_chest_cork", "closed"}
local lakes = {"oasis_tile", "oasis_tile", "idle"}
local wathgrithrs = {"wilson", "wathgrithr", "sleep"}
local wendys = {"wilson", "wendy", "sleep"}
local weses = {"wilson", "wes", "sleep"}
local waxwells = {"wilson", "waxwell", "sleep"}
local birdcages = {"birdcage", "birdcage_curly", "idle"}
local beargers = {"bearger", "bearger_build", "idle_loop"}
local dragonflys = {"dragonfly", "dragonfly_fire_build", "idle"}
local deerclopses = {"deerclops", "deerclops_build", "idle_loop"}
local mooses = {"goosemoose", "goosemoose_build", "idle"}
local mole_moves = {"mole_fx", "mole_move_fx", "move"}
local fertilizers = {"fertilizer", "fertilizer", "idle"}
local shadow_statues = {"tp_shadow_statue", "tp_shadow_statue", "idle_full"}
local shadow_statue_map = 'tp_shadow_statue.tex'
local sanityrocks = {"blocker_sanity", "blocker_sanity", "idle_inactive"}
local Phys = {
	tent = {1, nil},
	ham = {.5, nil},
	bench = {2, 1.2},
	obelisk = {1, nil},
	birdcage = {.5, nil},
	ice_statue = {1.5, nil},
}
local Maps = {
	tent = 'tent_circus.tex',
	bench = 'workbench_obsidian.png',
	box = 'treasure_chest_sacred.tex',
	cork_chest = 'cork_chest.png',
	lake = "tp_moon_lake.tex",
	shadow_statue = 'tp_shadow_statue.tex',
}
local Anims = {
	tent = {"tent", "tent_circus", "idle"},
	ham = {"ham_bat", "ham_bat", "idle"},
	bench = {"workbench_obsidian", "workbench_obsidian", "idle"},
	box = {"chest", "treasure_chest_sacred", "closed"},
	cork_chest = {"treasure_chest_cork", "treasure_chest_cork", "closed"},
	lake = {"oasis_tile", "oasis_tile", "idle"},
	wathgrithr = {"wilson", "wathgrithr", "sleep"},
	wendy = {"wilson", "wendy", "sleep"},
	wes = {"wilson", "wes", "sleep"},
	waxwell = {"wilson", "waxwell", "sleep"},
	birdcage = {"birdcage", "birdcage_curly", "idle"},
	bearger = {"bearger", "bearger_build", "idle_loop"},
	dragonfly = {"dragonfly", "dragonfly_fire_build", "idle"},
	deerclops = {"deerclops", "deerclops_build", "idle_loop"},
	moose = {"goosemoose", "goosemoose_build", "idle"},
	mole_move = {"mole_fx", "mole_move_fx", "move"},
	fertilizer = {"fertilizer", "fertilizer", "idle"},
	shadow_statue = {"tp_shadow_statue", "tp_shadow_statue", "idle_full"},
	sanityrock = {"blocker_sanity", "blocker_sanity", "idle_inactive"},
}

local function tent_ham(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function tent_hit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("idle", true)
	end
end

local function tent_finish(inst)
	if not inst:HasTag("burnt") then
		-- inst.AnimState:PlayAnimation("destroy")
		-- inst:ListenForEvent("animover", function(inst, data) inst:Remove() end)
		inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_pre")
		-- inst.persists = false
		inst:DoTaskInTime(16*FRAMES, function() inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_twirl") end)
	end
end

local function tent_built(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", true)
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/tent")
end

local function tent_save(inst, data)
	WARGON.burn_save(inst, data)
end

local function tent_load(inst, data)
	WARGON.burn_load(inst, data)
end

local function tent_sleep(inst, sleeper)
	if inst.components.finiteuses:GetUses() <= 0 then
		return
	else
		WARGON_SLEEP_EX.sleep_tent(inst, sleeper)
	end
end

local function tent_fn(inst)
	inst:AddTag("structure")
	WARGON_CMP_EX.add_cmps(inst, {
		inspect = {},
		loot = {},
		work = {act=ACTIONS.HAMMER, num=4, ham=tent_ham, hit=tent_hit},
		finite = {max=10, use=10, fn=tent_finish},
		sleepingbag = {},
		fueled = {time=100, typ="USAGE"},
	})
	inst.components.sleepingbag.onsleep = tent_sleep 
	WARGON.add_listen(inst, {
		onbuilt = tent_built,
		})
	inst.components.fueled:SetPercent(.9)
	inst.components.fueled:StopConsuming()
	WARGON.make_burn(inst, "large", nil, nil, true)
	WARGON.make_prop(inst, "large")
	WARGON.add_tags(inst, {'tp_tent', 'tp_sea_sleep'})
	local size = 1.2
	inst.Transform:SetScale(size, size, size)
	inst.OnSave = tent_save
	inst.OnLoad = tent_load
end

local function bench_fn(inst)
	
end

local function chest_open(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("open")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
		if WARGON.is_full_moon() then
			WARGON.make_fx(inst, "statue_transition")
			local nightmares = {
				"rawlingnightmare", "nightmarebeak",
			}
			for i = 1, math.random(5) do
				local pos = inst:around_land(math.random(2,4))
				if pos then
					WARGON.make_spawn(pos, nightmares[math.random(2)])
				end
			end
		end
	end
end

local function chest_close_update(inst)
	-- local items = {
	-- 	"cutgrass", "twigs", "log",
	-- 	"goldnugget", "nightmarefuel", "pigskin",
	-- 	"livinglog", "cutreeds", "flint",
	-- }
	-- local container = inst.components.container
	-- for i = 1, 9 do
	-- 	local item = SpawnPrefab(items[i])
	-- 	container.slots[i] = item
	-- end
end

local function chest_close(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("close")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
		chest_close_update(inst)
	end
end

local function chest_test(inst, item, slot)
	return false
end

local function chest_ham(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	-- inst.components.lootdropper:DropLoot()
	WARGON.make_fx(inst, "collapse_small")
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")	
	inst:Remove()
end

local function chest_hit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("closed", true)
		if inst.components.container then 
			inst.components.container:Close()
		end
	end
end

local function chest_built(inst, data)
	chest_close_update(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", true)
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/chest")
end

local function chest_item_lose(inst, data)
	local player = GetPlayer()
	player.components.health:DoDelta(-15)
end

local function chest_save(inst, data)
end

local function chest_load(inst, data)
	chest_close_update(inst)
end

local function chest_fn(inst)
	inst:AddTag("structure")
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		cont = {num=9, open=chest_open, close=chest_close, widgets={}, test=chest_test},
		work = {act=ACTIONS.HAMMER, num=2, ham=chest_ham, hit=chest_hit},
		loot = {},
	})
	WARGON.add_tags(inst, {'chest', 'tp_chest'})
	-- WARGON.add_listen(inst, {
	-- 	onbuilt = chest_built,
	-- 	itemlose = chest_item_lose,
	-- })
	MakeSnowCovered(inst, 0.01)	
	inst.OnSave = chest_save
	inst.OnLoad = chest_load
	-- WARGON.do_task(inst, 0, function()
	-- 	local pos = inst:GetPosition()
	-- 	WARGON.make_spawn(pos, "tp_bench")
	-- 	inst:Remove()
	-- end)
end

local function bangalore_ham(inst)
	-- inst.components.explosive:OnBurnt()
	inst:boom(inst)
end

local function bangalore_onignite(inst)
	-- inst.components.explosive:OnBurnt()
	inst:boom(inst)
end

local function bangalore_built(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed")
	inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/cork_chest/place")
end

local function bangalore_explode(inst, scale)
	scale = scale or 1
	local pos = Vector3(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")

	local explode = SpawnPrefab("explode_large")
	local ring = SpawnPrefab("explodering_fx")
	local pos = inst:GetPosition()

	ring.Transform:SetPosition(pos.x, pos.y, pos.z)
	ring.Transform:SetScale(scale, scale, scale)

	explode.Transform:SetPosition(pos.x, pos.y, pos.z)
	explode.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
	explode.AnimState:SetLightOverride(1)
	explode.Transform:SetScale(scale, scale, scale)
end

local function bangalore_boom(inst)
	WARGON.do_task(inst, .3, function()
		inst.components.explosive:OnBurnt()
	end)
end

local function bangalore_fn(inst)
	inst.AnimState:SetMultColour(1,.1,.1,1)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		-- work = {act=ACTIONS.HAMMER, num=1, ham=bangalore_ham},
	})
	inst:AddComponent("burnable")
	inst.components.burnable.onignite = bangalore_onignite
	inst.components.burnable.nofx = true
	inst:AddComponent("explosive")
	inst.components.explosive:SetOnExplodeFn(bangalore_explode)
	inst.components.explosive.explosivedamage = 100
	inst.components.explosive.explosiverange = TUNING.COCONADE_EXPLOSIONRANGE
	inst.components.explosive.buildingdamage = TUNING.COCONADE_BUILDINGDAMAGE
	WARGON.make_prop(inst, "small")
	WARGON.add_tags(inst, {'tp_bangalore'})
	WARGON.add_listen(inst, {
		onbuilt = bangalore_built,
		})
	WARGON.do_task(inst, 60, function()
		inst.components.explosive:OnBurnt()
	end)
	MakeSnowCovered(inst, 0.01)
	inst.boom = bangalore_boom
end

local function common_spawn_fn(inst, spawn_prefab)
	WARGON.do_task(inst, 0, function(inst)
		if c_find(spawn_prefab) == nil then
			WARGON.make_spawn(inst, spawn_prefab)
		end
		inst:Remove()
	end)
end

local function start_base_fn(inst)
	WARGON.do_task(inst, 0, function()
		WARGON.make_spawn(inst, "tp_fake_knight_sleep")
		inst:Remove()
	end)
end

local function werepig_start_fn(inst)
	local function crt_rock(x, z)
		local rock = SpawnPrefab("wall_stone")
		rock.Transform:SetPosition(x, 0, z)
	end
	WARGON.do_task(inst, 0, function()
		-- WARGON.make_spawn(inst, "tp_werepig_king")
		WARGON.make_spawn(inst, "tp_grass_pigking")
		inst:Remove()
	end)
end

local function unreal_rock_fn(inst)
	inst:AddTag("tp_unreal_rock")
end

local function moon_sea_point_fn(inst)
	local function crt_rock(pos, x, z)
		local rock = SpawnPrefab("tp_unreal_rock")
		rock.Transform:SetPosition(pos.x+x, 0, pos.z+z)
	end
	inst:AddTag("tp_moon_sea_point")
	WARGON.do_task(inst, 0, function()
		-- local pos = inst:GetPosition()
		-- for i = 1, 19 do
		-- 	crt_rock(pos, 10, i-10)
		-- 	crt_rock(pos,-10, i-10)
		-- 	crt_rock(pos, i-10, 10)
		-- 	crt_rock(pos, i-10,-10)
		-- end
		WARGON.make_spawn(inst, "tp_moon_sea_handler")
		inst:Remove()
	end)
end

local function moon_sea_handler_near(inst)
	local pos = WARGON.around_land(inst, 3)
	if pos then
		WARGON.make_spawn(pos, "tp_fool_spider")
		inst:Remove()
	end
end

local function moon_sea_handler_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		near = {dist={2,3}, near=moon_sea_handler_near}
	})
end

local function leif_spawner_fn(inst)
	-- WARGON.do_task(inst, 0, function(inst)
	-- 	if c_find("tp_leif") == nil then
	-- 		WARGON.make_spawn(inst, "tp_leif")
	-- 	end
	-- 	inst:Remove()
	-- end)
	common_spawn_fn(inst, "tp_leif")
end

local function pot_bird_egg_spawner_fn(inst)
	common_spawn_fn(inst, "tp_pot_bird_egg")
end

local function moon_lake_fn(inst)
	inst.AnimState:PlayAnimation("idle", true)
	inst:AddTag("tp_moon_lake")
	inst:AddTag("NOCLICK")
	inst:AddTag("FX")
	inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
	inst.AnimState:SetLayer( LAYER_BACKGROUND )
	inst.AnimState:SetSortOrder( 3 )
	local s = 1.5
	inst.Transform:SetScale(s, s, s)
end

local function moon_rock_fn(inst)
	inst:ListenForEvent("nighttime", function()
		if WARGON.is_full_moon() then
			WARGON.make_fx(inst, "sanity_lower")
			inst:Remove()
		end
	end, GetWorld())
end

local function boss_sleep_wake(inst)
	inst.AnimState:PlayAnimation("wakeup")
	inst:ListenForEvent("animover", function()
		if inst.boss then
			WARGON.make_spawn(inst, inst.boss)
		end
		inst:Remove()
	end)
end

local function boss_sleep_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
	})
	inst:AddComponent("tpuse")
	inst.components.tpuse.use = function()
		boss_sleep_wake(inst)
	end
end

local function combat_lord_sleep_fn(inst)
	boss_sleep_fn(inst)
	inst.boss = "tp_combat_lord"
	WARGON.EQUIP.body_on(inst, "armor_wood_fangedcollar", "swap_body")
	WARGON.EQUIP.hat_on(inst, "footballhat_combathelm", nil, true)
	WARGON.EQUIP.object_on(inst, "swap_spear_forge_gungnir", "swap_spear_gungnir")
end

local function hornet_sleep_fn(inst)
	boss_sleep_fn(inst)
	inst.boss = "tp_hornet"
	WARGON.EQUIP.body_on(inst, "armor_vortex_cloak", "swap_body")
	WARGON.EQUIP.hat_on(inst, "hat_bandit", nil, true)
	WARGON.EQUIP.object_on(inst, "tp_spear_lance", "swap_object")
end

local function soul_student_sleep_fn(inst)
	boss_sleep_fn(inst)
	inst.boss = "tp_soul_student"
	WARGON.EQUIP.hat_on(inst, "tophat_witch_pyre", nil, true)
	WARGON.EQUIP.object_on(inst, "swap_firestaff_meteor", "swap_redstaff")
end

local function fake_knight_sleep_fn(inst)
	inst.boss = "tp_fake_knight"
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		near = {dist={4,6}, near=boss_sleep_wake},
	})
	WARGON.EQUIP.body_on(inst, "armor_metalplate", "swap_body")
	WARGON.EQUIP.hat_on(inst, "hat_metalplate", nil, true)
	WARGON.EQUIP.object_on(inst, "swap_halberd", "swap_halberd")
end

local function boss_spawner_fn(inst)
	if not inst.checked then
		inst:do_task(0, function()
			inst.pos_list = inst.pos_list or {}
			for k, v in pairs(Ents) do
				if v.prefab == inst.prefab and v ~= inst then
					table.insert(inst.pos_list, v:GetPosition())
					v:Remove()
				end
			end
			inst.checked = true
		end)
	end
	local function check_boss(boss)
		if c_find(boss) == nil
		and GetPlayer().components.tpprefabspawner:CanSpawn(boss) then
			if #inst.pos_list > 0 then	
				local n = math.random(#inst.pos_list)
				print("boss_spawner random", n)
				local pos = inst.pos_list[n]
				table.remove(inst.pos_list, n)
				WARGON.make_spawn(pos, boss.."_sleep")
				GetPlayer().components.tpprefabspawner:TriggerPrefab(boss)
			end
		end
	end
	inst:do_task(0, function()
		check_boss("tp_hornet")
		check_boss("tp_combat_lord")
		check_boss("tp_soul_student")
	end)
	inst.OnSave = function(inst, data)
		data.pos_list = inst.pos_list
		data.checked = inst.checked
	end
	inst.OnLoad = function(inst, data)
		if data then
			if data.pos_list then
				inst.pos_list = data.pos_list or {}
			end
			inst.checked = data.checked
		end
	end
	-- WARGON.do_task(inst, 0, function()
	-- 	if c_find("tp_hornet") == nil
	-- 	and GetPlayer().components.tpprefabspawner:CanSpawn("tp_hornet") then
	-- 		WARGON.make_spawn(inst, "tp_hornet_sleep")
	-- 		GetPlayer().components.tpprefabspawner:TriggerPrefab("tp_hornet")
	-- 		inst:Remove()
	-- 	elseif c_find("tp_combat_lord_sleep") == nil
	-- 	and GetPlayer().components.tpprefabspawner:CanSpawn("tp_combat_lord") then
	-- 		WARGON.make_spawn(inst, "tp_combat_lord_sleep")
	-- 		GetPlayer().components.tpprefabspawner:TriggerPrefab("tp_combat_lord")
	-- 		inst:Remove()
	-- 	elseif c_find("tp_soul_student_sleep") == nil
	-- 	and GetPlayer().components.tpprefabspawner:CanSpawn("tp_soul_student") then
	-- 		WARGON.make_spawn(inst, "tp_soul_student_sleep")
	-- 		GetPlayer().components.tpprefabspawner:TriggerPrefab("tp_soul_student")
	-- 		inst:Remove()
	-- 	end
	-- end)
end

local function boss_spawner_fn_2(inst)

end

local function dragon_cage_hit(inst)
	inst.AnimState:PlayAnimation("hit_idle")
	inst.AnimState:PushAnimation("idle")
	if inst.fx_front then
		inst.fx_front.AnimState:PlayAnimation("hit_idle")
		inst.fx_front.AnimState:PushAnimation("idle")
	end
	if inst.fx_fly then
		inst.fx_fly.AnimState:PlayAnimation("hit")
		inst.fx_fly.AnimState:PushAnimation("idle")
	end
end

local function dragon_cage_ham(inst)
	WARGON.make_fx(inst, "collapse_small")
	inst.components.lootdropper:DropLoot()
	if inst.fx_fly then
		inst.fx_fly:Remove()
		inst.fx_fly = nil
	end
	if inst.fx_front then
		inst.fx_front:Remove()
		inst.fx_front = nil
	end
	inst:Remove()
end

local function dragon_cage_accept(inst, giver, item)	
	local seedspawnprefab = "seeds_cooked"

	if inst.fx_fly then
		inst.fx_fly.AnimState:PlayAnimation("taunt_pre")
		inst.fx_fly.AnimState:PushAnimation("taunt")
		inst.fx_fly.AnimState:PushAnimation("taunt_pst")
		inst.fx_fly.AnimState:PushAnimation("idle", true)
	end
	inst:DoTaskInTime(60*FRAMES, function()
		local loots = {
			bird_egg = 50,
			tallbirdegg = 35,
			flint = 1,
			obsidian = 1,
			nitre = 1,
			rocks = 1,
			marble = 1,
			iron = 1,
			redgem = 1,
			bluegem = 1,
			purplegem = 1,
			orangegem = 1,
			yellowgem = 1,
			thulecite = 1,
			thulecite_pieces = 1,
			goldnugget = 1,
			dragonfruit_seeds = 1,
			greengem = 1,
		}
		local loot = weighted_random_choice(loots)
		if item.components.edible.foodtype == "MEAT" then
			inst.components.lootdropper:SpawnLootPrefab(loot)
		else
			inst.components.lootdropper:SpawnLootPrefab(seedspawnprefab)
		end
	end)
end

local function dragon_cage_test(inst, item, giver)
	local seed_name = string.lower(item.prefab .. "_seeds")
	local can_accept = item.components.edible and (Prefabs[seed_name] or item.prefab == "seeds" or item.components.edible.foodtype == "MEAT") 
	
	if item.prefab == "egg" or item.prefab == "bird_egg" 
	or item.prefab == "rottenegg" or item.prefab == "monstermeat"
	or item.prefab == "tallbirdegg" then
		can_accept = false
	end
	
	return can_accept
end

local function dragon_cage_add_fx(inst)
	if inst.fx_fly == nil then
		inst.fx_fly = SpawnPrefab("tp_fx_dragon_cage_fly")
		inst:AddChild(inst.fx_fly)
		inst.fx_fly.Transform:SetPosition(0, 0, 0)
	end
	if inst.fx_front == nil then
		inst.fx_front = SpawnPrefab("tp_fx_dragon_cage_front")
		inst:AddChild(inst.fx_front)
		inst.fx_front.Transform:SetPosition(0, 0, 0)
	end
end

local function dragon_cage_on_built(inst, data)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/birdcage_craft")
	dragon_cage_add_fx(inst)
	if inst.fx_front then
		inst.fx_front.AnimState:PlayAnimation("place")
		inst.fx_front.AnimState:PushAnimation("idle")
	end
end

-- snow, crow_eye, crow_wings, crow_body, crow_beak, crow_leg, tail_feather, back
-- front
local function dragon_cage_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		work = {act=ACTIONS.HAMMER, num=2, ham=dragon_cage_ham, hit=dragon_cage_hit},
		loot = {},
		trader = {accept=dragon_cage_accept, test=dragon_cage_test},
	})
	inst.AnimState:Hide("front")
	WARGON.do_task(inst, 0, function()
		dragon_cage_add_fx(inst)
	end)
	inst:ListenForEvent("onbuilt", dragon_cage_on_built)
end

local function ice_statue_fn(inst)
	inst:AddTag("tp_boss_ice_statue")
	inst.AnimState:PlayAnimation("frozen", true)
	inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
end

-- 1
local function bearger_ice_statue_fn(inst)
	ice_statue_fn(inst)
	WARGON.set_scale(inst, 1/1.65)
end

-- 1.3
local function dragonfly_ice_statue_fn(inst)
	ice_statue_fn(inst)
	WARGON.set_scale(inst, 1.3/1.65)
end

-- 1.55
local function moose_ice_statue_fn(inst)
	ice_statue_fn(inst)
	WARGON.set_scale(inst, 1.55/1.65)
end

-- 1.65
local function deerclops_ice_statue_fn(inst)
	ice_statue_fn(inst)
	WARGON.set_scale(inst, 1)
end

function farm_pile_ham(inst, worker)
	WARGON.make_fx(inst, "collapse_small")
	inst:Remove()
end

function farm_pile_hit(inst, worker)
end

local function farm_pile_set_fertility_fn(inst, fert_percent)
	-- if not inst:HasTag("burnt") then
	-- 	local anim = "full"
	-- 	if fert_percent <= 0 then
	-- 		anim = "empty"
	-- 	elseif fert_percent <= 0.33 then
	-- 		anim = "med2"
	-- 	elseif fert_percent <= 0.66 then
	-- 		anim = "med1"
	-- 	end
	-- 	inst.AnimState:PlayAnimation(anim)
	-- end	
end

local function farm_pile_fn(inst)
	local anim = inst.AnimState
	-- inst:do_task(0, function()
		anim:SetPercent("move", .5)
	-- end)
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
	inst:add_cmps({
		inspect = {},
		grower = {},
		work = {act=ACTIONS.HAMMER, num=1, ham=farm_pile_ham, hit=farm_pile_hit},
	})
	inst:AddTag("structure")
	inst.components.grower.level = 3
    inst.components.grower.onplantfn = function() 
    	inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_seeds") 
   	end
    inst.components.grower.croppoints = {Vector3(0,0,0)}
    inst.components.grower.growrate = TUNING.FARM3_GROW_BONUS
    inst.components.grower.max_cycles_left = 30
    inst.components.grower.cycles_left = inst.components.grower.max_cycles_left
	inst.components.grower.setfertility = farm_pile_set_fertility_fn
end

local function grass_pigking_spawner_fn(inst)
	inst:do_task(0, function()
		WARGON.make_spawn(inst, "tp_grass_pigking")
		local pos = inst:GetPosition()
		for i = -1, 1, 1 do
			-- local pt = Vector3(0, 0, 0) + pos
			WARGON.make_spawn(Vector3(i, 0, -2)+pos, "tp_moon_rock")
			WARGON.make_spawn(Vector3(i, 0, 2)+pos, "tp_moon_rock")
			WARGON.make_spawn(Vector3(2, 0, i)+pos, "tp_moon_rock")
			WARGON.make_spawn(Vector3(-2, 0, i)+pos, "tp_moon_rock")
		end
		inst:Remove()
	end)
end

local function shadow_statue_hit(inst, worker)
end

local function shadow_statue_ham(inst, worker)
	inst.components.lootdropper:DropLoot()
	WARGON.make_fx(inst, "collapse_small")
	inst:Remove()
end

local function shadow_statue_update(inst)
	if WARGON.is_full_moon() then
		if inst.tp_per_task == nil then
			inst.tp_per_task = inst:per_task(5, function()
				local nightmares = {"crawlingnightmare", "nightmarebeak"}
				WARGON.make_spawn(inst, nightmares[math.random(2)])
			end)
		end
	else
		if inst.tp_per_task then
			inst.tp_per_task:Cancel()
			inst.tp_per_task = nil
		end
	end
end

local function shadow_statue_fn(inst)
	inst:add_cmps({
		inspect = {},
		loot = {},
		work = {act=ACTIONS.HAMMER, num=4, 
			ham=shadow_statue_ham, hit=shadow_statue_hit},
	})
	inst:ListenForEvent("nighttime", function()
		shadow_statue_update(inst)
	end, GetWorld())
	inst:ListenForEvent("daytime", function()
		shadow_statue_update(inst)
	end, GetWorld())
	inst.OnLoad = function(inst, data)
		shadow_statue_update(inst)
	end
end

local function MakeStructure(name, anims, structure_fn, phy, map)
	local function fn()
		local the_phy = nil
		if phy then
			the_phy = {'obs', phy[1], phy[2]}
		end
		local inst = WARGON.make_prefab(anims, nil, the_phy, nil, nil, nil)
		if type(map) == "table" then
			WARGON.make_map(inst, map[1], map[2])
		elseif map ~= nil then
			WARGON.make_map(inst, map)
		end
		-- WARGON.add_tags(inst, {"structure"})
		if structure_fn then
			structure_fn(inst)
		end

		return inst
	end

	return Prefab("common/objects/"..name, fn, {})
end

return 
MakeStructure("tp_tent", Anims.tent, tent_fn, Phys.tent, Maps.tent),
MakePlacer("common/tp_tent_placer", Anims.tent[1], Anims.tent[2], Anims.tent[3], nil, nil, nil, 1.2),
MakeStructure("tp_chest", Anims.box, chest_fn, nil, Maps.box),
MakePlacer("common/tp_chest_placer", Anims.box[1], Anims.box[2], Anims.box[3]),
MakeStructure("tp_bangalore", Anims.cork_chest, bangalore_fn, nil, Maps.cork_chest),
MakeStructure("tp_start_base", {}, start_base_fn, nil, nil),
MakeStructure("tp_unreal_rock", {}, unreal_rock_fn, Phys.obelisk, nil),
MakeStructure("tp_moon_rock", Anims.sanityrock, moon_rock_fn, Phys.obelisk, nil),
MakeStructure("tp_moon_sea_point", {}, moon_sea_point_fn, nil, nil),
MakeStructure("tp_moon_sea_handler", {}, moon_sea_handler_fn, nil, nil),
MakeStructure("tp_leif_spawner", {}, leif_spawner_fn, nil, nil),
MakeStructure("tp_boss_spawner", {}, boss_spawner_fn),
MakeStructure("tp_boss_spawner2", {}, boss_spawner_fn_2),
MakeStructure("tp_werepig_start", {}, werepig_start_fn),
MakeStructure("tp_moon_lake", Anims.lake, moon_lake_fn, nil, Maps.lake),
MakeStructure("tp_combat_lord_sleep", Anims.wathgrithr, combat_lord_sleep_fn),
MakeStructure("tp_hornet_sleep", Anims.wendy, hornet_sleep_fn),
MakeStructure("tp_fake_knight_sleep", Anims.wes, fake_knight_sleep_fn),
MakeStructure("tp_soul_student_sleep", Anims.waxwell, soul_student_sleep_fn),
MakeStructure("tp_dragon_cage", Anims.birdcage, dragon_cage_fn, Phys.birdcage, nil),
MakePlacer("common/tp_dragon_cage_placer", Anims.birdcage[1], Anims.birdcage[2], Anims.birdcage[3]),
MakeStructure("tp_bearger_ice_statue", Anims.bearger, bearger_ice_statue_fn, Phys.ice_statue, nil),
MakePlacer("common/tp_bearger_ice_statue_placer", Anims.bearger[1], Anims.bearger[2], "frozen", nil, nil, nil, 1/1.65),
MakeStructure("tp_moose_ice_statue", Anims.moose, ice_statue_fn, Phys.ice_statue, nil),
MakePlacer("common/tp_moose_ice_statue_placer", Anims.moose[1], Anims.moose[2], "frozen", nil, nil, nil, 1.55/1.65),
MakeStructure("tp_dragonfly_ice_statue", Anims.dragonfly, ice_statue_fn, Phys.ice_statue, nil),
MakePlacer("common/tp_dragonfly_ice_statue_placer", Anims.dragonfly[1], Anims.dragonfly[2], "frozen", nil, nil, nil, 1.3/1.65),
MakeStructure("tp_deerclops_ice_statue", Anims.deerclops, ice_statue_fn, Phys.ice_statue, nil),
MakePlacer("common/tp_deerclops_ice_statue_placer", Anims.deerclops[1], Anims.deerclops[2], "frozen", nil, nil, nil, 1),
MakeStructure("tp_farm_pile", Anims.mole_move, farm_pile_fn),
MakePlacer("common/tp_farm_pile_placer", Anims.fertilizer[1], Anims.fertilizer[2], Anims.fertilizer[3]),
MakeStructure("common/tp_grass_pigking_spawner", {}, grass_pigking_spawner_fn),
MakeStructure("common/tp_shadow_statue", Anims.shadow_statue, shadow_statue_fn, Phys.obelisk, Maps.shadow_statue),
MakePlacer("common/tp_shadow_statue_placer", Anims.shadow_statue[1], Anims.shadow_statue[2], Anims.shadow_statue[3]),
MakeStructure("tp_pot_bird_egg_spawner", {}, pot_bird_egg_spawner_fn)