local acorns = {"acorn", "acorn", "idle", nil}
local pinecones = {"pinecone", "pinecone", "idle", nil}
local gingkos = {"tp_gingko", "tp_gingko", "idle", nil}
local gingko_spalings ={"tp_gingko_spaling", "tp_gingko_spaling", "idle_planted", nil}
local war_spalings = {"pinecone", "pinecone", "idle_planted", nil}
local defense_spalings = {'acorn', 'acorn', 'idle_planted', nil}
local life_spalings = war_spalings
local plantables = {'tp_plantable', 'tp_plantable', 'reeds', nil}
local grass_waters = {"grass_inwater", "grass_inwater", "idle"}
local mangroves = {"tree_mangrove", "tree_mangrove_build", "idle_short"}
local reedses = {"grass", "reeds", "idle"}
local bulb_plants = {"bulb_plant_single", "bulb_plant_single", "idle"}

local function common_treeseed_save(inst, data)
	WARGON.seed_save(inst, data)
end

local function common_treeseed_load(inst, data)
	WARGON.seed_load(inst, data)
end

local function common_treeseed_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},	
		stack = {max=TUNING.STACK_SIZE_SMALLITEM},
	})
	WARGON.make_burn(inst, "small", TUNING.SMALL_BURNTIME)
	WARGON.make_prop(inst, "small")
	WARGON.burn_bait(inst, 3)
	WARGON.make_blow(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
	WARGON.add_listen(inst, {
		onignite = WARGON.TREE.treeseed_stop,
		onextinguish = WARGON.TREE.treeseed_start,
	})
	inst.OnSave = common_treeseed_save
	inst.OnLoad = common_treeseed_load
end

local function common_deploy_test(inst, pt)
	return WARGON.TREE.treeseed_test(inst, pt, 4)
end

local function gingko_deploy(inst, pt)
	WARGON.TREE.treeseed_deploy(inst, pt, "tp_gingko_tree")
end

local function gingko_fn(inst)
	common_treeseed_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		dep = {test=common_deploy_test, deploy=gingko_deploy},
		trade = {},
	})
	inst.tree = "tp_gingko_tree"
	WARGON.add_tags(inst, {"tp_gingko"})
end

local function war_tree_seed_deploy(inst, pt)
	WARGON.TREE.treeseed_deploy(inst, pt, "tp_war_tree")
end

local function war_tree_seed_fn(inst)
	common_treeseed_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		dep = {test=common_deploy_test, deploy=war_tree_seed_deploy}	
	})
	inst.tree = "tp_war_tree"
end

local function defense_tree_seed_deploy(inst, pt)
	WARGON.TREE.treeseed_deploy(inst, pt, "tp_defense_tree")
end

local function defense_tree_seed_fn(inst)
	common_treeseed_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		dep = {test=common_deploy_test, deploy=defense_tree_seed_deploy}
		})
	inst.tree = "tp_defense_tree"
end

local function life_tree_seed_deploy(inst, pt)
	WARGON.TREE.treeseed_deploy(inst, pt, "tp_life_tree")
end

local function life_tree_seed_fn(inst)
	common_treeseed_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		dep = {test=common_deploy_test, deploy=life_tree_seed_deploy}
		})
	inst.tree = "tp_life_tree"
end

local function common_spaling_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},	
		stack = {max=TUNING.STACK_SIZE_SMALLITEM},
	})
	WARGON.make_burn(inst, "small", TUNING.SMALL_BURNTIME)
	WARGON.make_prop(inst, "small")
	WARGON.burn_bait(inst, 3)
	WARGON.add_listen(inst, {
		onignite = WARGON.TREE.treeseed_stop,
		onextinguish = WARGON.TREE.treeseed_start,
	})
	inst:RemoveComponent("inventoryitem")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
	WARGON.TREE.treeseed_start(inst)
	inst.OnSave = common_treeseed_save
	inst.OnLoad = common_treeseed_load
end

local function gingko_sapling_fn(inst)
	common_spaling_fn(inst)
	inst.tree = "tp_gingko_tree"
end

local function war_spaling_fn(inst)
	common_spaling_fn(inst)
	inst.tree = "tp_war_tree"
end

local function defense_spaling_fn(inst)
	common_spaling_fn(inst)
	inst.tree = "tp_defense_tree"
end

local function life_spaling_fn(inst)
	common_spaling_fn(inst)
	inst.tree = "tp_life_tree"
end

local function common_aquatic_deploy_test(inst, pt)
	return WARGON.TREE.treeseed_test(inst, pt, 4, true)
end

local function common_plantable_deploy(inst, pt)
	inst = inst.components.stackable:Get()
	inst:Remove()
	local tree = SpawnPrefab(inst.tree)
	tree:set_pos(pt:Get())
end

local function common_plantable_fn(inst, aquatic)
	inst:add_cmps({
		inspect = {},
		stack = {max=40},
		dep = {test=aquatic and common_aquatic_deploy_test or common_deploy_test, 
			deploy=common_plantable_deploy},
	})
end

local function plantable_reeds_fn(inst)
	common_plantable_fn(inst)
	inst.components.deployable.placer = "tp_reeds_placer"
	inst.tree = "reeds"
end

local function plantable_flower_cave_fn(inst)
	common_plantable_fn(inst)
	inst.components.deployable.placer = "tp_flower_cave_placer"
	inst.tree = "flower_cave"
end

local function plantable_mangrove_fn(inst)
	common_plantable_fn(inst, true)
	inst.components.deployable.placer = "tp_mangrovetree_normal_placer"
	inst.tree = "mangrovetree_normal"
end

local function plantable_grass_water_fn(inst)
	common_plantable_fn(inst, true)
	inst.components.deployable.placer = "tp_grass_water_placer"
	inst.tree = "grass_water"
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
	-- MakeItem("tp_gingko", gingkos, gingko_fn, 'tp_gingko'),
	-- MakePlacer("common/tp_gingko_placer", gingkos[1], gingkos[2], 'idle_planted'),
	-- MakeItem("tp_war_tree_seed", pinecones, war_tree_seed_fn, nil, "pinecone"),
	-- MakePlacer("common/tp_war_tree_seed_placer", pinecones[1], pinecones[2], "idle_planted"),
	-- MakeItem("tp_defense_tree_seed", acorns, defense_tree_seed_fn, nil, "acorn"),
	-- MakePlacer("common/tp_defense_tree_seed_placer", acorns[1], acorns[2], "idle_planted"),

	MakeItem("tp_gingko", gingko_spalings, gingko_fn, 'tp_gingko_spaling'),
	MakePlacer("common/tp_gingko_placer", gingkos[1], gingkos[2], 'idle_planted'),
	MakeItem("tp_war_tree_seed", war_spalings, war_tree_seed_fn, "tp_war_tree_spaling"),
	MakePlacer("common/tp_war_tree_seed_placer", pinecones[1], pinecones[2], "idle_planted"),
	MakeItem("tp_defense_tree_seed", defense_spalings, defense_tree_seed_fn, "tp_defense_tree_spaling"),
	MakePlacer("common/tp_defense_tree_seed_placer", acorns[1], acorns[2], "idle_planted"),
	MakeItem("tp_life_tree_seed", war_spalings, life_tree_seed_fn, "tp_war_tree_spaling"),
	MakePlacer("common/tp_life_tree_seed_placer", pinecones[1], pinecones[2], "idle_planted"),
	
	MakeItem("tp_gingko_spaling", gingko_spalings, gingko_sapling_fn, "tp_gingko"),
	MakeItem("tp_war_tree_spaling", war_spalings, war_spaling_fn, "tp_gingko"),
	MakeItem("tp_defense_tree_spaling", defense_spalings, defense_spaling_fn, "tp_gingko"),
	MakeItem("tp_life_tree_spaling", life_spalings, life_spaling_fn, "tp_gingko"),
	MakePlacer("common/tp_gingko_spaling_placer", gingko_spalings[1], 
		gingko_spalings[2], gingko_spalings[3]),
	MakePlacer("common/tp_war_tree_spaling_placer", war_spalings[1], 
		war_spalings[2], war_spalings[3]),
	MakePlacer("common/tp_defense_tree_spaling_placer", defense_spalings[1], 
		defense_spalings[2], defense_spalings[3]),
	MakePlacer("common/tp_life_tree_spaling_placer", life_spalings[1],
		life_spalings[2], life_spalings[3]),
	MakeItem("tp_plantable_reeds", plantables, plantable_reeds_fn, 
		"tp_plantable_reeds"),
	MakeItem("tp_plantable_flower_cave", plantables, 
		plantable_flower_cave_fn, "tp_plantable_flower_cave"),
	MakeItem("tp_plantable_grass_water", plantables, 
		plantable_grass_water_fn, "tp_plantable_grass_water"),
	MakeItem("tp_plantable_mangrove", plantables,
		plantable_mangrove_fn, "tp_plantable_mangrove"),
	MakePlacer("common/tp_reeds_placer", reedses[1], reedses[2], 
		reedses[3]),
	MakePlacer("common/tp_flower_cave_placer", bulb_plants[1], bulb_plants[2], 
		bulb_plants[3]),
	MakePlacer("common/tp_grass_water_placer", grass_waters[1],
		grass_waters[2], grass_waters[3]),
	MakePlacer("common/tp_mangrovetree_normal_placer", mangroves[1],
		mangroves[2], mangroves[3])