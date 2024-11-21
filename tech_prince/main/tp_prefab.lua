local ImageButton = require "widgets/imagebutton"

AddPrefabPostInit("wilson", function(inst)
	inst:AddComponent("sciencemorph")
	inst:AddComponent("tpcallbeast")
	inst:AddComponent("tpmadvalue")
	inst:AddComponent("tpbuff")
	inst:AddComponent("tpbody")
	inst:AddComponent("tplevel")
	inst.components.tplevel:Apply()
	inst:AddComponent("tpbuy")
	-- inst.components.tplevel:ApplyUpGrade()
	-- inst:AddComponent("tptech")
	-- inst:AddComponent("tpriderspawner")
	inst:AddComponent("tpreportspawner")
	inst:AddComponent("tpprefabspawner")
	-- inst.components.tpprefabspawner:AddPrefab("tp_warg")
	-- inst.components.tpprefabspawner:AddPrefab("tp_sign_rider")
	-- inst.components.tpprefabspawner:AddPrefab("tp_grass_pigking")
	inst.components.tpprefabspawner:AddPrefab("tp_hornet")
	inst.components.tpprefabspawner:AddPrefab("tp_combat_lord")
	inst.components.tpprefabspawner:AddPrefab("tp_soul_student")
	inst.components.tpprefabspawner:AddPrefab("tp_werepig_king")
	inst.components.tpprefabspawner:AddPrefab("tp_blood_lord")
	inst.components.tpprefabspawner:AddPrefab("tp_thunder_lord")
	inst.components.tpprefabspawner:AddPrefab("tp_ice_lord")
	inst.components.tpprefabspawner:AddPrefab("tp_fire_lord")
	inst.components.tpprefabspawner:AddPrefab("tp_poison_lord")
	inst.components.tpprefabspawner:AddPrefab("tp_shadow_lord")
	inst.components.tpprefabspawner:AddPrefab("tp_pig_book")
	-- inst:AddComponent("tpangry")
	-- inst:AddComponent("tpnutspawner")
	-- inst:AddComponent("tptagnum")
	local old_light_fn = inst.components.playerlightningtarget.onstrikefn
	inst.components.playerlightningtarget:SetOnStrikeFn(function(inst)
		if old_light_fn then
			old_light_fn(inst)
		end
		inst:PushEvent("tp_lightning_strike")
	end)
	local old_save = inst.OnSave
	inst.OnSave = function(inst, data)
		old_save(inst, data)
		data.tp_morph = inst.components.sciencemorph.cur
	end
	local old_load = inst.OnLoad
	inst.OnLoad = function(inst, data)
		old_load(inst, data)
		if data.tp_morph then
			inst.components.sciencemorph:Morph(data.tp_morph)
		end
	end
	local gifts = {'tp_gift'}
	inst.components.inventory.starting_inventory = gifts
	WARGON.do_task(inst, 0, function()
		if inst.components.tpreportspawner then
			inst.components.tpreportspawner:Spawn()
		end
	end)
	WARGON.key_down(KEY_R, function()
	end)
end)

AddPrefabPostInit("sewing_kit", function(inst)
	local old_fn = inst.components.sewing.onsewn
	inst.components.sewing.onsewn = function(inst, target, doer)
		old_fn(inst, target, doer)
		if target:HasTag("tp_tent") then
			local use = target.components.finiteuses:GetUses()
			local total = target.components.finiteuses.total
			if use <= target.components.finiteuses.total then
				target.components.finiteuses:SetUses(math.min(use+5, total))
			end
			target.components.fueled:SetPercent(.9)
		end
	end
end)
 
-- 防止和Wilson一起在天上
-- AddPrefabPostInit("flower", function(inst)
-- 	WARGON.do_task(inst, 0, function()
-- 		local pt = inst:GetPosition()
-- 		inst.Transform:SetPosition(pt.x, 0, pt.z)
-- 	end)
-- end)

local tree_seeds = {
	"acorn",
	"pinecone",
	"jungletreeseed",
	"teatree_nut",
	"coconut",
}
for k, v in pairs(tree_seeds) do
	AddPrefabPostInit(v, function(inst)
		inst:AddComponent('tpammo')
	end)
end

AddPrefabPostInit("birchnutdrake", function(inst)
	local old_target_fn = inst.components.combat.targetfn
	inst.components.combat.targetfn = function(inst)
		local guy = old_target_fn(inst)
		if guy and not guy:HasTag("tp_oak_armor") 
		and not (inst:HasTag("tp_defense_tree_nut") and guy:HasTag("player")) then
			return guy
		end
	end
end)

AddPrefabPostInit("pigman", function(inst)
	inst:AddComponent("tpbuff")
end)

AddPrefabPostInit("hound", function(inst)
	inst:AddComponent("tpbuff")
end)

local function add_prefab_tag(name, tag)
	local function add_tag(name, tag)
		AddPrefabPostInit(name, function(inst)
			if type(tag) == "table" then
				for k, v in pairs(tag) do
					inst:AddTag(v)
				end
			else
				inst:AddTag(tag)
			end
		end)
	end
	if type(name) == "table" then
		for k, v in pairs(name) do
			add_tag(v, tag)
		end
	else
		add_tag(name, tag)
	end
end

add_prefab_tag("log", "tp_chop_pig_item")
add_prefab_tag("cork", "tp_chop_pig_item")
add_prefab_tag("livinglog", "tp_chop_pig_item")
add_prefab_tag("bamboo", "tp_hack_pig_item")
add_prefab_tag("vine", "tp_hack_pig_item")
add_prefab_tag("cutgrass", "tp_hack_pig_item")
-- add_prefab_tag("seeds", "tp_farm_pig_item")
AddPrefabPostInitAny(function(inst)
	if string.find(inst.prefab, 'seeds') then
		inst:AddTag("tp_farm_pig_item")
	end
	if inst:HasTag("smallcreature") and inst:HasTag("canbetrapped") then
		inst:AddTag("tp_strawhat_target")
	end
end)

local trees = {
	"evergreen", "evergreen_sparse",
	"deciduoustree", "rainforesttree", "teatree",
	"clawpalmtree", "jungletree", "palmtree", 
	"gingko_tree",
}
for k, v in pairs(trees) do
	add_prefab_tag(v, 'tp_chop_pig_target')
end

local hackables = {
	"bambootree", "bush_vine", "grass_tall",
}
for k, v in pairs(hackables) do
	add_prefab_tag(v, 'tp_hack_pig_target')
end

local farms = {
	'fast_farmplot', 'slow_farmplot',
}
for k, v in pairs(farms) do
	add_prefab_tag(v, 'tp_farm_pig_target')
end

local strawhat_targets = {
	"pigman", "bunnyman", "perd", "beefalo", "primeape", "wildbore",
}
for k, v in pairs(strawhat_targets) do
	add_prefab_tag(v, 'tp_strawhat_target')
end
add_prefab_tag('perd', 'tp_strawhat_perd')
add_prefab_tag('beefalo', 'tp_strawhat_beefalo')

AddPrefabPostInit('rowboat', function(inst)
	inst:ListenForEvent('onbuilt', function()
		if GetPlayer():HasTag("tech_prince") then
			local sail = SpawnPrefab("sail")
			local torch = SpawnPrefab("boat_torch")
			inst.components.container:Equip(sail)
			inst.components.container:Equip(torch)
		end
	end)
end)

AddPrefabPostInit("armouredboat", function(inst)
	inst:ListenForEvent("onbuilt", function()
		if GetPlayer():HasTag("tech_prince") then
			local sail = SpawnPrefab("clothsail")
			local torch = SpawnPrefab("boatcannon")
			inst.components.container:Equip(sail)
			inst.components.container:Equip(torch)
		end
	end)
end)

AddPrefabPostInit('pigking', function(inst)
	inst:AddTag("pigking")
	inst:AddComponent("tpwerekingspawner")
	-- inst:AddTag("tp_defense_sign")
	-- inst:AddTag("werepig")
	-- inst:AddComponent("tptechmachine")
	-- inst.components.tptechmachine.tech = "pigking"
	-- local old_test = inst.components.trader.test 
	-- inst.components.trader.test = function(inst, item, giver)
		-- if c_find("tp_werepig_king") == nil
		-- and inst.components.tpwerekingspawner.days <= 0 
	-- 	if item
	-- 	and (item.components.edible 
	-- 	and item.components.edible.foodtype=="MEAT"
	-- 	and item.components.edible:GetHealth()<0) then
	-- 		return true
	-- 	end
	-- 	return old_test(inst, item, giver)
	-- end
	-- inst:AddComponent("health")
	-- inst.components.health:SetMaxHealth(3000)
	-- inst.components.health:StartRegen(5, 50)
	-- inst:AddComponent("combat")
	-- inst.components.combat:SetDefaultDamage(0)
	-- inst:ListenForEvent("attacked", function(inst, data)
	-- 	inst.AnimState:PlayAnimation("unimpressed")
	-- 	inst.AnimState:PushAnimation("idle", true)
	-- 	local attacker = data.attacker
	-- 	if attacker then
 --            inst.components.combat:ShareTarget(attacker, 30, function(dude) 
 --            	return dude:HasTag("pig") and not dude:HasTag("werepig") end,
 --            5)
	-- 	end
	-- end)
	-- inst:ListenForEvent("death", function()
	-- 	inst.AnimState:PlayAnimation("sleep_pre")
	-- 	inst.AnimState:PushAnimation("sleep_loop")
	-- 	local loot = WARGON.make_spawn(inst, "tp_loot")
	-- 	loot.loot_prefab = "tp_pigking_hat"
	-- end)
end)

local life_tree_plants = {
	"carrot_planted",
	"lichen",
	"sweet_potato_planted",
	"asparagus_planted",
}
add_prefab_tag(life_tree_plants, "life_tree_plant")

add_prefab_tag('snakebonesoup', 'tplevel_food_small')

add_prefab_tag('pinecone', 'tp_war_tree_gift')

AddPrefabPostInit('leif', function(inst)
	local function leif_test(inst, item)
		return item:HasTag("tp_war_tree_gift") and inst:HasTag("tp_war_tree")
	end
	local function leif_accept(inst, giver, item)
		if giver == inst.components.combat.target then
			inst.components.combat:SetTarget(nil)
		else
			inst.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
			giver.components.leader:AddFollower(inst)
		    inst.components.follower:AddLoyaltyTime(30*16)
		end
	end
    WARGON.CMP.add_cmps(inst, {
    	follow = {max=TUNING.PIG_LOYALTY_MAXTIME},
    	trader = {accept=leif_accept, test=leif_test},
    	})
    local old_save = inst.OnSave
    local old_load = inst.OnLoad
    inst.OnSave = function(inst, data)
    	if old_save then old_save(inst, data) end
    	if data and inst:HasTag("tp_war_tree") then
    		data.war_tree = true
    	end
	end
	inst.OnLoad = function(inst, data)
		if old_load then old_load(inst, data) end
		if data and data.war_tree then
			inst:AddTag("tp_war_tree")
		end
	end
end)

AddPrefabPostInit("perd", function(inst)
	local old_save = inst.OnSave
    local old_load = inst.OnLoad
    inst.OnSave = function(inst, data)
    	if old_save then old_save(inst, data) end
    	if data and inst.tp_perd then
    		data.tp_perd = inst.tp_perd
    	end
	end
	inst.OnLoad = function(inst, data)
		if old_load then old_load(inst, data) end
		if data and data.tp_perd then
			inst.tp_perd = data.tp_perd
			inst:SetBrain(require "brains/tp_perd_brain")
			inst.AnimState:Show("HAT")
			inst.AnimState:OverrideSymbol("swap_hat", "strawhat_cowboy", "swap_hat")
		end
	end
end)

-- AddPrefabPostInit("beefalo", function(inst)
-- end)

local bosses = {
	"deerclops",
	"moose",
	"dragonfly",
	"bearger",
	"minotaur",
	"twister",
	"tigershark",
	"kraken",
	"pugalisk",
	"antqueen",
	"ancient_herald",
	"ancient_hulk",
	-- "tp_werepig_king",
	-- "tp_sign_rider",
}

for k, v in pairs(bosses) do
	AddPrefabPostInit(v, function(inst)
		-- inst:AddTag("tp_level_epic")
		inst:AddTag("tp_sign_damage")
		inst.components.lootdropper:AddLoot("tp_boss_loot")
		inst.components.lootdropper:AddLoot("tp_epic")
		inst.components.lootdropper:AddLoot("tp_treasure_map")
		-- if _G.WARGON.CONFIG.diff == 1 then
		-- 	inst:AddTag("tp_only_player_attack")
		-- 	if inst.components.combat 
		-- 	and inst.components.combat.playerdamagepercent < 1 then
		-- 		inst.components.combat.playerdamagepercent = 1
		-- 	end
		-- end
	end)
end

-- AddPrefabPostInit("twister", function(inst)
-- end)

AddPrefabPostInit("deerclops", function(inst)
	inst:AddTag("tp_snow_power")
	local function spawn_snow(inst)
		if inst.tp_task == nil then
			inst.tp_task = WARGON.per_task(inst, .2, function()
				WARGON.make_fx(inst, "tp_fx_snow_ball_shoot")
			end)
			WARGON.do_task(inst, 2, function()
				if inst.tp_task then
					inst.tp_task:Cancel()
					inst.tp_task = nil
				end
			end)
		end
	end
	inst:ListenForEvent("attacked", spawn_snow)
	inst:ListenForEvent("firedamage", spawn_snow)
end)

AddPrefabPostInit("dragonfly", function(inst)
	inst.components.groundpounder.destroyer = true
	inst.components.groundpounder.destructionRings = 1
	inst:AddTag("groundpoundimmune")
	inst.components.lootdropper:AddChanceLoot("tp_dragon_cage_bp", .2)
	-- if inst.components.sleeper then
	-- 	inst:RemoveComponent("sleeper")
	-- end
	-- inst.Physics:ClearCollisionMask()
	-- inst.Physics:CollidesWith(GetWorldCollision())
 --    inst.Physics:CollidesWith(GetWaterCollision())
    -- inst.Physics:CollidesWith(COLLISION.OBSTACLES)
 --    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	-- inst.Physics:CollidesWith(COLLISION.WAVES)
 --    inst.Physics:CollidesWith(COLLISION.INTWALL)
end)

-- AddPrefabPostInit("bearger", function(inst)
-- end)

AddPrefabPostInit("moose", function(inst)
	inst:AddTag("tp_tornado_power")
end)


local season_bosses = {
	"dragonfly",
	"deerclops",
	"moose",
	"bearger",
}
for k, v in pairs(season_bosses) do
	AddPrefabPostInit(v, function(inst)
		inst.components.lootdropper:AddChanceLoot("tp_"..v.."_ice_statue_bp", .33)
		WARGON.make_map(inst, "tp_"..v.."_ice_statue.tex")
	end)
end

-- AddPrefabPostInit("minotaur", function(inst)
-- end)

AddPrefabPostInit("kraken", function(inst)
	-- local health = _G.WARGON.CONFIG.diff==1 and 5000 or 3000
	local health = 2000
	inst.components.health:SetMaxHealth(health)
end)


-- AddPrefabPostInit("tigershark", function(inst)
-- end)

AddPrefabPostInit("pugalisk", function(inst)
	inst:ListenForEvent("healthdelta", function(inst, data)
		inst.components.health:SetInvincible(true)
		WARGON.do_task(inst, .5, function()
			inst.components.health:SetInvincible(false)
		end)
	end)
end)

AddPrefabPostInit("pugalisk_body", function(inst)
	local function redirect_health(inst, amount, overtime, cause, ignore_invincible)
	    local originalinst = inst
	    if inst.startpt then
	        inst = inst.startpt
	    end
	    if amount < 0 and( (inst.components.segmented and inst.components.segmented.vulnerablesegments == 0) or inst:HasTag("tail") or inst:HasTag("head") ) then
	        print("invulnerable",cause,GetPlayer().prefab)
	        if cause == GetPlayer().prefab then
	            GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_PUGALISK_INVULNERABLE"))        
	        end
	        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal",nil,.25)
	        inst.SoundEmitter:PlaySound("dontstarve/wilson/hit_metal")

	    elseif amount and inst.host and not inst.host.tp_invincible then

	        local fx = SpawnPrefab("snake_scales_fx")
	        fx.Transform:SetScale(1.5,1.5,1.5)
	        local pt= Vector3(originalinst.Transform:GetWorldPosition())
	        fx.Transform:SetPosition(pt.x,pt.y + 2 + math.random()*2,pt.z)

	        inst:PushEvent("dohitanim")
	        inst.host.components.health:DoDelta(amount, overtime, cause, false, true)
	        inst.host:PushEvent("attacked")
	    end    
	end
	inst.components.health.redirect = redirect_health
end)

local epic_creatures = {
	"leif",
	"leif_sparse",
	"spiderqueen",
	"treeguard",
}
for k, v in pairs(bosses) do
	table.insert(epic_creatures, v)
end
for k, v in pairs(epic_creatures) do
	AddPrefabPostInit(v, function(inst)
		if inst.components.lootdropper then
			inst.components.lootdropper:AddLoot("tp_epic", 1)
		end
	end)
end

AddPrefabPostInit("pillar_ruins", function(inst)
	local function on_hammered(inst, worker)
		-- local shadow = WARGON.make_spawn(inst, "fissure_lower")
		local shadow = WARGON.make_spawn(inst, "nightmarebeak")
		-- shadow:AddTag("tp_shadow_light")
		SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst:Remove()
	end
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(on_hammered)
end)

AddPrefabPostInit("campfire", function(inst)
	local function onhammered(inst, worker)
		local ash = SpawnPrefab("ash")
		ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
		SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst:Remove()
	end
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
end)

-- AddPrefabPostInit("fissure_lower", function(inst)
	-- local function spawnchildren(inst)
	--     if inst.components.childspawner then
	--         inst.components.childspawner:StartSpawning()
	--         inst.components.childspawner:StopRegen()
	--     end 
	-- end
	-- local function spawnfx(inst)
	--     if not inst.fx then
	--         inst.fx = SpawnPrefab(inst.fxprefab)
	--         local pos = inst:GetPosition()
	--         inst.fx.Transform:SetPosition(pos.x, -0.1, pos.z)
	--     end
	-- end
	-- local function nightmare_state(inst, instant)
 --        ChangeToObstaclePhysics(inst)
 --        inst.Light:Enable(true)
 --        inst.components.lighttweener:StartTween(nil, 5, nil, nil, nil, (instant and 0) or 0.5)
 --        inst.SoundEmitter:KillSound("loop")
 --        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open")
 --        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_LP", "loop")
 --        if not instant then
 --            inst.AnimState:PlayAnimation("open_2")
 --            inst.AnimState:PushAnimation("idle_open")

 --            inst.fx.AnimState:PlayAnimation("open_2")
 --            inst.fx.AnimState:PushAnimation("idle_open")
 --            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open")
 --        else
 --            inst.AnimState:PlayAnimation("idle_open")

 --            inst.fx.AnimState:PlayAnimation("idle_open")
 --        end
 --        spawnchildren(inst)
 --    end
	-- WARGON.do_task(inst, 0, function()
	-- 	if inst:HasTag("tp_shadow_light") then
	-- 		spawnfx(inst)
	-- 	    inst.state = "nightmare"
	-- 	    inst:DoTaskInTime(math.random() * 2, nightmare_state)
	-- 	end
	-- end)
-- end)

AddPrefabPostInit("beefalohat", function(inst)
	local old_equip = inst.components.equippable.onequipfn
	local old_unequip = inst.components.equippable.onunequipfn
	inst.components.equippable:SetOnEquip(function(inst, owner)
		old_equip(inst, owner)
		owner:AddTagNum("beefalo", 1)
	end)
	inst.components.equippable:SetOnUnequip(function(inst, owner)
		old_unequip(inst, owner)
		owner:AddTagNum("beefalo", -1)
	end)
end)

AddPrefabPostInit("armorvortexcloak", function(inst)
	local old_equip = inst.components.equippable.onequipfn
	local old_unequip = inst.components.equippable.onunequipfn
	inst.components.equippable:SetOnEquip(function(inst, owner)
		old_equip(inst, owner)
		owner:AddTagNum("not_hit_stunned", 1)
	end)
	inst.components.equippable:SetOnUnequip(function(inst, owner)
		old_unequip(inst, owner)
		owner:AddTagNum("not_hit_stunned", -1)
	end)
end)

add_prefab_tag("trap_teeth", "tp_trap_teeth")
add_prefab_tag('tent', 'tp_sea_sleep')
add_prefab_tag('meatrack', 'tp_sea_dryer')
add_prefab_tag('grass_water', 'tp_grass_water')

AddPrefabPostInit("ice", function(inst)
	local anim = inst.animname or "f"..math.random(3)
	MakeInventoryFloatable(inst, anim, anim)
end)

AddPrefabPostInit("octopusking", function(inst)
	inst:AddComponent("tptechmachine")
	inst.components.tptechmachine.tech = 'octopus'
end)

local mangrovetrees = {
	"mangrovetree",
	"mangrovetree_normal",
	"mangrovetree_tall",
	"mangrovetree_short",
	"mangrovetree_burnt",
	"mangrovetree_stump",
}

add_prefab_tag(mangrovetrees, 'tp_mangrovetree')

AddPrefabPostInit("octopuschest", function(inst)
	WARGON.do_task(inst, 0, function()
		if c_find("tp_octopus") == nil then
			local container = inst.components.container
			if container and container:Has("boatcannon", 1) then
				local doll = SpawnPrefab("tp_octopus")
				-- container:GiveItem(doll, nil, nil, true, false)
				container:GiveItem(doll)
			end
		end
	end)
end)

AddPrefabPostInit("tornado", function(inst)
	inst:AddComponent("tpwindattack")
end)

add_prefab_tag("pinecone", "tp_gingko")

-- AddPrefabPostInit("koalefant_summer", function(inst)
-- 	WARGON.do_task(inst, 0, function()
-- 		local days = GetClock():GetNumCycles()
-- 		if GetPlayer().components.tpprefabspawner:CanSpawn("tp_warg")
-- 		and days > 40 then
-- 			WARGON.make_spawn(inst, "tp_red_warg")
-- 			GetPlayer().components.tpprefabspawner:TriggerPrefab("tp_warg")
-- 			inst:Remove()
-- 		end
-- 	end)
-- end)

-- AddPrefabPostInit("koalefant_winter", function(inst)
	-- WARGON.do_task(inst, 0, function()
	-- 	local days = GetClock():GetNumCycles()
	-- 	if GetPlayer().components.tpprefabspawner:CanSpawn("tp_warg")
	-- 	and days > 40 then
	-- 		WARGON.make_spawn(inst, "tp_blue_warg")
	-- 		GetPlayer().components.tpprefabspawner:TriggerPrefab("tp_warg")
	-- 		inst:Remove()
	-- 	end
	-- end)
-- end)

-- AddPrefabPostInit("tornado", function(inst)
	-- inst:AddComponent("thief")
	-- inst:SetStateGraph("tp_tornado")
-- end)

local ponds = {
	"pond",
	-- "pond_mos",
}

AddPrefabPostInit("pond", function(inst)
	inst:AddTag("tp_diving_target")
	inst:AddComponent("tpdivable")
	if GetWorld().tp_pools == nil then
		GetWorld().tp_pools = {}
		GetWorld().tp_pool_start = inst
	end
	-- for k, v in pairs(GetWorld().tp_pools) do
	-- 	if v.tp_pool_last == nil then
	-- 		v.tp_pool_last = inst
	-- 	end
	-- end
	table.insert(GetWorld().tp_pools, inst)
	inst.tp_pool_id = #GetWorld().tp_pools
end)

-- for k, v in pairs(ponds) do
-- 	AddPrefabPostInit(v, function(inst)
-- 		MakeLargeBurnable(inst, nil, nil, true)
-- 		MakeLargePropagator(inst)
-- 		inst.components.burnable.onburnt = function(inst)
-- 			inst:Remove()
-- 		end
-- 	end)
-- end

-- AddPrefabPostInit("panflute", function(inst)
-- 	local old_heard = inst.components.instrument.onheard
-- 	inst.components.instrument:SetOnHeardFn(function(inst, musician, instrument)
-- 		if inst.components.sleeper and not inst:HasTag("epic") then
-- 		    inst.components.sleeper:AddSleepiness(10, TUNING.PANFLUTE_SLEEPTIME, inst)
-- 		end
-- 	end)
-- end)

add_prefab_tag({"bonestaff", "hambat"}, "tp_must_spoilsh")

AddPrefabPostInit("pigman", function(inst)
	inst:AddComponent("tppower")
	inst.components.tppower:SetPower(math.random(6))
end)

AddPrefabPostInit("pigguard", function(inst)
	inst:AddComponent("tppower")
	inst.components.tppower:SetPower(math.random(6))
end)

-- local element_power = {
-- 	"bee",
-- 	"killerbee",
-- 	"hound",
-- 	"firehound",
-- 	"icehound",
-- 	"spider",
-- 	"spider_hider",
-- 	"spider_spitter",
-- 	"spider_warrior",
-- 	"spider_dropper",
-- 	"tallbird",
-- 	"tentacle",
-- 	"merm",
-- 	"worm",
-- 	"bat",
-- }

-- for k, v in pairs(element_power) do
-- 	if _G.WARGON.CONFIG.diff == 0 then
-- 		break
-- 	end
-- 	AddPrefabPostInit(v, function(inst)
-- 		inst:AddComponent("tppower")
-- 		inst.components.tppower:SetPower(math.random(6))
-- 	end)
-- end

-- AddPrefabPostInit("spiderqueen", function(inst)
-- 	inst:ListenForEvent("death", function(inst)
-- 		local rock = WARGON.find(inst, 20, nil, {"tp_unreal_rock"})
-- 		local player = GetPlayer()
-- 		local pool = GetPlayer().tp_pool_node
-- 		if pool then
-- 			local pos = WARGON.around_land(pool, 2)
-- 			if pos then
-- 				WARGON.do_task(player, 1, function()
-- 					TheFrontEnd:Fade(true, 1)
-- 					player.Transform:SetPosition(pos:Get())
-- 					player.sg:GoToState("wakeup")
-- 				end)
-- 			end
-- 		end
-- 	end)
-- end)

AddPrefabPostInit("meat", function(inst)
	inst:AddComponent("tpinterable")
	inst:AddTag("tp_hambat_fuel")
end)

AddPrefabPostInit("beefalo", function(inst)
	inst.components.lootdropper:AddChanceLoot("tp_horn", .08)
end)

local monkeys = {"primeape", "monkey"}
for k, v in pairs(monkeys) do
	AddPrefabPostInit(v, function(inst)
		if math.random() < .1 then
			inst.AnimState:SetMultColour(1, 1, .1, 1)
			inst:AddTag("tp_gold_primeape")
			inst.components.lootdropper:AddLoot("tp_treasure_map")
			inst.components.lootdropper:AddChanceLoot("tp_bench_bp", .05)
			inst.nameoverride = "GOLD_PRIMEAPE"
		end
	end)
end

-- compatibility "Cook Stack Food"
AddPrefabPostInit("tp_cook_pot", function(inst)
	if TUNING.IAI_COOK then
		inst.components.container.acceptsstacks = TUNING.IAI_COOK
		inst:AddTag("iai_cook")
	end
end)

-- Some Beefalo Has Container
local beefalos = {
	"beefalo",
	-- "babybeefalo",
}
for k, v in pairs(beefalos) do
	AddPrefabPostInit(v, function(inst)
		local slotpos = {}
		for y = 2, 0, -1 do
			for x = 0, 2 do
				table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
			end
		end
		inst:AddComponent("container")
		inst.components.container:SetNumSlots(#slotpos)
		-- inst.components.container.onopenfn = function(inst)
		-- end
		-- inst.components.container.onclosefn = function(inst)
		-- end
		inst.components.container.widgetslotpos = slotpos
		inst.components.container.widgetanimbank = "ui_chest_3x3"
		inst.components.container.widgetanimbuild = "ui_chest_3x3"
		inst.components.container.widgetpos = Vector3(0,200,0)
		inst.components.container.side_align_tip = 160
		inst.components.container.canbeopened = false
		inst:add_listener("saddlechanged", function(inst, data)
			if data.saddle 
			and data.saddle:HasTag("tp_open_beefalo_container") then
				inst.components.container.canbeopened = true
			else
				inst.components.container.canbeopened = false
			end
		end)
		inst:add_listener("riderchanged", function(inst, data)
			inst.components.container:Close()
		end)
		-- inst.tp_with_bag = false
		-- local old_save = inst.OnSave
		-- local old_load = inst.OnLoad
		-- inst.OnSave = function(inst, data)
		-- 	data.tp_with_bag = inst.tp_with_bag
		-- end
		-- inst.OnLoad = function(inst, data)
		-- 	inst.tp_with_bag = data.tp_with_bag
		-- end
	end)
end

AddPrefabPostInit("krampus", function(inst)
	inst.components.lootdropper:AddChanceLoot("tp_red_dragon_sack_dropper", .2)
end)
