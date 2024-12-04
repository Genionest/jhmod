
local item_assets = {
	item = {
		ak_candy_bag = {
			img = {"ak_items", "ak_candy_bag"},
			anim = {"candybag", "wg_candybag", "anim"},
		},
		ak_range_ruler = {
			img = "trinket_20",
			anim = {"trinkets", "trinkets", "20", "20_water"},
		},
		ak_heat_rock = {
			img = {"ak_items", "ak_heat_rock"},
			anim = {"ak_heat_rock", "ak_heat_rock", "3", "3_water"},
		},
		ak_gps = {
			img = "tracker",
			anim = {"tracker", "tracker", "idle", "idle_water"},
		},
		ak_eye_turret_item = {
			img = "eyeturret_item",
		},
		tp_epic = {
			img = {"ak_items", "tp_epic", },
			anim = {"tp_epic", "tp_epic", "idle", "idle_water", },
		},
		ak_glass = {
			img = {"ak_items", "ak_glass", },
			anim = {"moonglass", "moonglass", "f1", },
		},
		ak_plastic = {
			img = {"ak_items", "ak_plastic", },
			anim = {"ak_items", "ak_items", "ak_plastic", "ak_plastic_water", },
		},
		ak_rock_ash = {
			img = {"ak_items", "ak_rock_ash", },
			anim = {"ak_items", "ak_items", "ak_rock_ash", },
		},
		ak_ssd = {
			img = {"ak_items", "ak_ssd", },
			anim = {"ak_items", "ak_items", "ak_ssd", "ak_ssd", },
		},
	},
	item_use = {
		ak_dimensional = {
			img = {"ak_items", "ak_dimensional", },
			anim = {"ak_items", "ak_items", "ak_dimensional", },
		},
		ak_fix_powder = {
			img = {"ak_items", "ak_fix_powder", },
			anim = {"ak_fix_powder", "ak_fix_powder", "idle", },
		},
		ak_injector = {
			anim = {"lifepen", "lifepen", "idle", },
		},
		ak_plant_army_seed = {
			img = {"ak_items", "ak_plant_army_seed", },
			anim = {"ak_items", "ak_items", "ak_plant_army_seed", "ak_plant_army_seed", },
		},
		ak_rack_pot_item = {
			img = {"ak_items", "ak_cook_pot", },
			anim = {"cook_pot", "idle_empty", },
		},
		ak_sleeping_pill = {
			img = {"ak_items", "ak_sleeping_pill", },
			anim = {"ak_items", "ak_items", "ak_sleeping_pill", },
		},
		ak_spice_salt = {
			img = {"ak_items", "ak_spice_salt", },
			anim = {"ak_items", "ak_items", "ak_spice_salt", "ak_spice_salt", },
		},
		ak_treasure_map = {
			img = "stash_map",
			anim = {"stash_map", "stash_map", "idle", "idle_water", },
		},
		ak_wormhole_map = {
			img = "stash_map",
			anim = {"stash_map", "stash_map", "idle", "idle_water", },
		},
		ak_knowledge_scroll = {
			img = "blueprint",
			anim = {"blueprint", "blueprint", "idle", "idle_water"},
		},
	},
	blueprint = {
		ak_thumper_bp = {
			img = "blueprint",
			anim = {"blueprint", "blueprint", "idle", "idle_water"},
		},
	},
	tool = {
		ak_staff_star = {
			img = {"ak_staffs", "ak_staff_star"},
			anim = {"ak_staff_star", "ak_staff_star", "idle", "idle_water"},
			override = {"ak_staff_star", "swap_object"},
		},
		ak_staff_wind = {
			img = {"ak_staffs", "ak_staff_wind"},
			anim = {"tp_spear_wind", "tp_spear_wind", "idle", "idle_water"},
			override = {"swap_spear_wind", "swap_object"},
		},
		ak_sign_staff = {
			img = {"ak_staffs", "ak_sign_staff"},
			anim = {"tp_sign_staff", "tp_sign_staff", "idle", "idle_water", },
			override = {"tp_sign_staff", "swap_object"},
		},
		ak_golden_multi_tool = {
			img = "goldenaxe",
			anim = {"goldenaxe", "goldenaxe", "idle", "idle_water"},
			override = {"swap_goldenaxe", "swap_goldenaxe"},
		},
		ak_multi_tool = {
			img = "axe",
			anim = {"axe", "axe", "idle", "idle_water"},
			override = {"swap_axe", "swap_axe"},
		},
		ak_alloy_axe = {
			img = "axe_northern",
			anim = {"axe", "axe_northern", "idle", "idle_water", },
			override = {"swap_axe_northern", "swap_axe", },
		},
		ak_alloy_hammer = {
			img = "hammer_crowbar",
			anim = {"hammer", "hammer_crowbar", "idle", "idle_water", },
			override = {"swap_hammer_crowbar", "swap_hammer", },
		},
		ak_alloy_pickaxe = {
			img = "pickaxe_northern",
			anim = {"pickaxe", "pickaxe_northern", "idle", "idle_water", },
			override = {"swap_pickaxe_northern", "swap_pickaxe", },
		},
		ak_alloy_shovel = {
			img = "shovel_northern",
			anim = {"shovel", "shovel_northern", "idle", "idle_water", },
			override = {"swap_shovel_northern", "swap_shovel", },
		},
		ak_blowing_bat = {
			img = "icestaff_hockey",
			anim = {"staffs", "icestaff_hockey", "bluestaff", "bluestaff_water", },
			override = {"swap_icestaff_hockey", "swap_bluestaff", },
		},
		ak_candy_cane = {
			img = "cane_candycane",
			anim = {"cane", "cane_candycane", "idle", "idle_water", },
			override = {"swap_cane_candycane", "swap_cane", },
		},
		ak_cowboy_saddle = {
			img = "strawhat_cowboy",
			anim = {"strawhat", "strawhat_cowboy", "anim", "idle_water", },
		},
		ak_dodge_cane = {
			img = "cane_ancient",
			anim = {"cane", "cane_ancient", "idle", "idle_water", },
			override = {"swap_cane_ancient", "swap_cane", },
		},
		ak_fire_heat_rock = {
			img = "heatrock_fire",
			anim = {"heat_rock", "heatrock_fire", "3", "3_water", },
		},
		ak_refine_hammer = {
			img = "hammer_mjolnir",
			anim = {"hammer", "hammer_mjolnir", "idle", "idle_water", },
			override = {"swap_hammer_mjolnir", "swap_hammer_mjolnir", },
		},
		ak_road_cane = {
			img = "cane_victorian",
			anim = {"cane", "cane_victorian", "idle", "idle_water", },
			override = {"swap_cane_victorian", "swap_cane", },
		},
		ak_scythe = {
			img = "batbat_scythe",
			anim = {"batbat", "batbat_scythe", "idle", "idle_water", },
			override = {"swap_batbat_scythe", "swap_batbat", },
		},
		ak_spider_bugnet = {
			img = "bugnet_spider",
			anim = {"bugnet", "bugnet_spider", "idle", "idle_water", },
			override = {"swap_bugnet_spider", "swap_bugnet", },
		},
		ak_steel_axe = {
			img = "axe_victorian",
			anim = {"axe", "axe_victorian", "idle", "idle_water", },
			override = {"swap_axe_victorian", "swap_axe", },
		},
		ak_steel_pickaxe = {
			img = "pickaxe_scythe",
			anim = {"pickaxe", "pickaxe_scythe", "idle", "idle_water", },
			override = {"swap_pickaxe_scythe", "swap_pickaxe", },
		},
		ak_steel_shovel = {
			img = "shovel_victorian",
			anim = {"shovel", "shovel_victorian", "idle", "idle_water", },
			override = {"swap_shovel_victorian", "swap_shovel", },
		},
	},
	tool_need_asset = {
		ak_phoenix_cane = {
			img = {"ak_items", "ak_phoenix_cane", },
			anim = {"cane", "ak_phoenix_cane", "idle", "idle_water", },
			override = {"swap_ak_phoenix_cane", "swap_object", },
		},
	},
	chest = {
		ak_combat_chest = {
			img = "treasurechest_monster",
			anim = {"chest", "treasurechest_monster", "closed", },
		},
		ak_food_chest = {
			img = "treasure_chest_gingerbread",
			anim = {"chest", "treasure_chest_gingerbread", "closed", },
		},
		ak_plant_chest = {
			img = "treasure_chest_posh",
			anim = {"chest", "treasure_chest_posh", "closed", },
		},
		ak_potion_chest = {
			img = "treasure_chest_poshprint",
			anim = {"chest", "treasure_chest_poshprint", "closed", },
		},
		ak_scroll_chest = {
			img = "treasurechest_carpetbag",
			anim = {"chest", "treasurechest_carpetbag", "closed", },
		},
		ak_tool_chest = {
			img = "treasurechest_traincase",
			anim = {"chest", "treasurechest_traincase", "closed", },
		},
	},
	metal = {
		ak_alloy = {
			img = {"ak_items", "ak_alloy", },
			anim = {"ak_items", "ak_items", "ak_alloy", "ak_alloy", },
		},
		ak_alloy_blue = {
			img = {"ak_items", "ak_alloy_blue", },
			anim = {"tp_alloy", "tp_alloy", "idle", "idle_water", },
		},
		ak_alloy_purple = {
			img = {"ak_items", "ak_alloy_purple", },
			anim = {"tp_alloy_great", "tp_alloy_great", "idle", "idle_water", },
		},
		ak_alloy_red = {
			img = {"ak_items", "ak_alloy_red", },
			anim = {"tp_alloy_red", "tp_alloy_red", "idle", "idle_water", },
		},
		ak_copper = {
			img = {"ak_items", "ak_copper", },
			anim = {"ak_items", "ak_items", "ak_copper", "ak_copper", },
		},
		ak_copper_ore = {
			img = {"ak_items", "ak_copper_ore", },
			anim = {"ak_items", "ak_items", "ak_copper_ore", },
		},
		ak_gold = {
			img = {"ak_items", "ak_gold", },
			anim = {"ak_items", "ak_items", "ak_gold", "ak_gold", },
		},
		ak_platinum = {
			img = {"ak_items", "ak_platinum", },
			anim = {"ak_platinum", "ak_platinum", "idle", "idle_water", },
		},
		ak_plumbum = {
			img = {"ak_items", "ak_plumbum", },
			anim = {"ak_items", "ak_items", "ak_plumbum", "ak_plumbum", },
		},
		ak_tungsten = {
			img = {"ak_items", "ak_tungsten", },
			anim = {"ak_items", "ak_items", "ak_tungsten", "ak_tungsten", },
		},
		ak_tungsten_ore = {
			img = {"ak_items", "ak_tungsten_ore", },
			anim = {"ak_items", "ak_items", "ak_tungsten_ore", },
		},
	},
	rock = {
		ak_oxy_rock = {
			img = {"ak_items", "ak_oxy_rock", },
			anim = {"ak_items", "ak_items", "ak_oxy_rock", },
		},
		ak_salt_rock = {
			img = {"ak_items", "ak_salt_rock", },
			anim = {"salt", "salt", "idle", "idle", },
		},
	},
	weapon = {
		ak_elf_axe = {
			img = "goldenaxe_northern",
			anim = {"goldenaxe", "goldenaxe_northern", "idle", "idle_water", },
			override = {"swap_goldenaxe_northern", "swap_goldenaxe", },
		},
		ak_elf_hammer = {
			img = "hammer_mjolnir",
			anim = {"hammer", "hammer_mjolnir", "idle", "idle_water", },
			override = {"swap_hammer_mjolnir", "swap_hammer_mjolnir", },
		},
		ak_spear_lance = {
			img = {"ak_weapons", "ak_spear_lance"},
			anim = {"tp_spear_lance", "tp_spear_lance", "idle", "idle_water", },
			override = {"tp_spear_lance", "swap_object", },
		},
		ak_spear_lunge = {
			img = "spear_forge_gungnir",
			anim = {"spear", "spear_forge_gungnir", "idle", "idle_water", },
			override = {"swap_spear_forge_gungnir", "swap_spear_gungnir", },
		},
		ak_spear_wrestle = {
			img = "spear_wathgrithr_wrestle",
			anim = {"spear_wathgrithr", "spear_wathgrithr_wrestle", "idle", "idle_water", },
			override = {"swap_spear_wathgrithr_wrestle", "swap_spear_wathgrithr", },
		},
		ak_sword_heavy = {
			img = "ruins_bat_heavy",
			anim = {"ruins_bat", "ruins_bat_heavy", "idle", },
			override = {"swap_ruins_bat_heavy", "swap_ruins_bat", },
		},
		ak_wyvern_hammer = {
			img = "hammer_mjolnir",
			anim = {"hammer", "hammer_mjolnir", "idle", "idle_water", },
			override = {"swap_hammer_mjolnir", "swap_hammer_mjolnir", },
		},
	},
	weapon_need_asset = {
		ak_blue_alloy_sword = {
			img = {"ak_weapons", "ak_blue_alloy_sword", },
			anim = {"ak_blue_alloy_sword", "ak_blue_alloy_sword", "idle", },
			override = {"ak_blue_alloy_sword", "swap_object", },
		},
		ak_forest_dragon = {
			img = {"ak_weapons", "ak_forest_dragon", },
			anim = {"ak_forest_dragon", "ak_forest_dragon", "idle", "idle_water", },
			override = {"ak_forest_dragon", "swap_object", },
		},
		ak_gun_hammer = {
			anim = {"ak_gun_hammer", "ak_gun_hammer", "idle", },
			override = {"ak_gun_hammer", "swap_object", },
		},
		ak_hammer_gun = {
			img = {"ak_weapons", "ak_hammer_gun", },
			anim = {"ak_hammer_gun", "ak_hammer_gun", "idle", },
			override = {"ak_hammer_gun", "swap_object", },
		},
		ak_spear_blood = {
			img = {"ak_weapons", "ak_spear_blood", },
			anim = {"tp_spear_blood", "tp_spear_blood", "idle", "idle_water", },
			override = {"tp_spear_blood", "swap_object", },
		},
		ak_spear_fire = {
			img = {"ak_weapons", "ak_spear_fire", },
			anim = {"tp_spear_fire", "tp_spear_fire", "idle", "idle_water", },
			override = {"tp_spear_fire", "swap_object", },
		},
		ak_spear_ice = {
			img = {"ak_weapons", "ak_spear_ice", },
			anim = {"tp_spear_cooldown", "tp_spear_cooldown", "idle", "idle_water", },
			override = {"tp_spear_cooldown", "swap_object", },
		},
		ak_spear_poison = {
			img = {"ak_weapons", "ak_spear_poison", },
			anim = {"tp_spear_poison", "tp_spear_poison", "idle", "idle_water", },
			override = {"tp_spear_poison", "swap_object", },
		},
		ak_spear_shadow = {
			img = {"ak_weapons", "ak_spear_shadow", },
			anim = {"tp_spear_shadow", "tp_spear_shadow", "idle", "idle_water", },
			override = {"tp_spear_shadow", "swap_object", },
		},
		ak_spear_thunder = {
			img = {"ak_weapons", "ak_spear_thunder", },
			anim = {"tp_spear_thunder", "tp_spear_thunder", "idle", "idle_water", },
			override = {"tp_spear_thunder", "swap_object", },
		},
		ak_spear_combat = {
			tp_spear_asset = "tp_spear_combat",
		},
		ak_spear_conqueror = {
			tp_spear_asset = "tp_spear_conqueror",
		},
		ak_spear_apm = {
			tp_spear_asset = "tp_spear_shell",
		},
		ak_spear_gold = {
			tp_spear_asset = "tp_spear_gold",
		},
		ak_spear_antivirus = {
			tp_spear_asset = "tp_spear_single",
		},
		ak_spear_alchemist = {
			tp_spear_asset = "tp_spear_potion",
		},
		ak_spear_nature_number = {
			tp_spear_asset = "spear",
		},
		ak_spear_array = {
			tp_spear_asset = "spear",
		},
		ak_spear_epsilon = {
			tp_spear_asset = "spear",
		},
		ak_spear_limit = {
			tp_spear_asset = "spear",
		},
	},
	armor = {
		ak_armor_cloak = {
			img = "armor_grass_cloak",
			anim = {"armor_grass", "armor_grass_cloak", "anim", "idle_water", },
			override = {"armor_grass_cloak", },
		},
		ak_armor_fangedcollar = {
			img = "armor_wood_fangedcollar",
			anim = {"armor_wood_fangedcollar", "armor_wood_fangedcollar", "anim", "idle_water", },
			override = {"armor_wood_fangedcollar", },
		},
		ak_armor_lamellar = {
			img = "armor_wood_lamellar",
			anim = {"armor_wood_lamellar", "armor_wood_lamellar", "anim", "idle_water", },
			override = {"armor_wood_lamellar", },
		},
		ak_armor_tusk = {
			img = "armor_ruins_tusk",
			anim = {"armor_ruins", "armor_ruins_tusk", "anim", },
			override = {"armor_ruins_tusk", },
		},
	},
	armor_need_asset = {
		ak_armor_fire = {
			img = {"ak_armors", "ak_armor_warm", },
			anim = {"armor_wood_lamellar", "tp_armor_warm", "anim", "idle_water", },
			override = {"tp_armor_warm", },
		},
		ak_armor_firm = {
			img = {"ak_armors", "ak_armor_firm", },
			anim = {"armor_wood_lamellar", "tp_armor_firm", "anim", "idle_water", },
			override = {"tp_armor_firm", },
		},
		ak_armor_ice = {
			img = {"ak_armors", "ak_armor_cool", },
			anim = {"armor_wood_lamellar", "tp_armor_cool", "anim", "idle_water", },
			override = {"tp_armor_cool", },
		},
	},
	hat = {
		ak_hat_arcane = {
			img = "ruinshat_arcane",
			anim = {"ruinshat", "ruinshat_arcane", "anim", "idle_water", },
			override = {"ruinshat_arcane", },
		},
		ak_hat_brella_crystal = {
			img = "eyebrellahat_crystal",
			anim = {"eyebrellahat", "eyebrellahat_crystal", "anim", "idle_water", },
			override = {"eyebrellahat_crystal", },
		},
		ak_hat_combathelm = {
			img = "footballhat_combathelm",
			anim = {"footballhat", "footballhat_combathelm", "anim", "idle_water", },
			override = {"footballhat_combathelm", },
		},
		ak_hat_combathelmii = {
			img = "footballhat_combathelm2",
			override = {"footballhat_combathelm2", },
		},
		ak_hat_feather = {
			img = "flowerhat_crown",
			anim = {"flowerhat", "flowerhat_crown", "anim", "idle_water", },
			override = {"flowerhat_crown", },
		},
		ak_hat_holly = {
			img = "flowerhat_holly_wreath",
			anim = {"flowerhat", "flowerhat_holly_wreath", "anim", "idle_water", },
			override = {"flowerhat_holly_wreath", },
		},
		ak_hat_pigking = {
			img = "beefalohat_pigking",
			anim = {"beefalohat", "beefalohat_pigking", "anim", "idle_water", },
			override = {"beefalohat_pigking", },
		},
		ak_hat_sanity = {
			img = "tophat_derby",
			anim = {"tophat", "tophat_derby", "anim", "idle_water", },
			override = {"tophat_derby", },
		},
	},
	hat_need_asset = {
		ak_hat_bag = {
			img = {"ak_hats", "ak_hat_bag", },
			anim = {"tp_hat_bag", "tp_hat_bag", "anim", "anim", },
			override = {"tp_hat_bag", },
		},
		ak_hat_cool = {
			img = {"ak_hats", "ak_hat_cool", },
			anim = {"tp_hat_cool", "tp_hat_cool", "anim", "anim", },
			override = {"tp_hat_cool", },
		},
		ak_hat_oxygen = {
			img = {"ak_items", "ak_hat_oxygen", },
			anim = {"ak_hat_oxygen", "ak_hat_oxygen", "anim", "anim", },
			override = {"ak_hat_oxygen", },
		},
		ak_hat_warm = {
			img = {"ak_hats", "ak_hat_warm", },
			anim = {"tp_hat_warm", "tp_hat_warm", "anim", "anim", },
			override = {"tp_hat_warm", },
		},
	},
	ornament = {
		ak_ornament_boss_antlion = {
			anim = {"winter_ornaments", "winter_ornaments", "boss_antlion", },
			img = {"winter_ornaments", "winter_ornament_boss_antlion", },
		},
		ak_ornament_boss_bearger = {
			anim = {"winter_ornaments", "winter_ornaments", "boss_bearger", },
			img = {"winter_ornaments", "winter_ornament_boss_bearger", },
		},
		ak_ornament_boss_beequeen = {
			anim = {"winter_ornaments", "winter_ornaments", "boss_beequeen", },
			img = {"winter_ornaments", "winter_ornament_boss_beequeen", },
		},
		ak_ornament_boss_celestialchampion1 = {
			anim = {"winter_ornaments2021", "winter_ornaments2021", "boss_celestialchampion1", },
			img = {"winter_ornaments", "winter_ornament_boss_celestialchampion1", },
		},
		ak_ornament_boss_celestialchampion2 = {
			anim = {"winter_ornaments2021", "winter_ornaments2021", "boss_celestialchampion2", },
			img = {"winter_ornaments", "winter_ornament_boss_celestialchampion2", },
		},
		ak_ornament_boss_celestialchampion3 = {
			anim = {"winter_ornaments2021", "winter_ornaments2021", "boss_celestialchampion3", },
			img = {"winter_ornaments", "winter_ornament_boss_celestialchampion3", },
		},
		ak_ornament_boss_celestialchampion4 = {
			anim = {"winter_ornaments2021", "winter_ornaments2021", "boss_celestialchampion4", },
			img = {"winter_ornaments", "winter_ornament_boss_celestialchampion4", },
		},
		ak_ornament_boss_crabking = {
			anim = {"winter_ornaments2020", "winter_ornaments2020", "boss_crabking", },
			img = {"winter_ornaments", "winter_ornament_boss_crabking", },
		},
		ak_ornament_boss_crabkingpearl = {
			anim = {"winter_ornaments2020", "winter_ornaments2020", "boss_crabkingpearl", },
			img = {"winter_ornaments", "winter_ornament_boss_crabkingpearl", },
		},
		ak_ornament_boss_deerclops = {
			anim = {"winter_ornaments", "winter_ornaments", "boss_deerclops", },
			img = {"winter_ornaments", "winter_ornament_boss_deerclops", },
		},
		ak_ornament_boss_dragonfly = {
			anim = {"winter_ornaments", "winter_ornaments", "boss_dragonfly", },
			img = {"winter_ornaments", "winter_ornament_boss_dragonfly", },
		},
		ak_ornament_boss_eyeofterror1 = {
			anim = {"winter_ornaments2021", "winter_ornaments2021", "boss_eyeofterror1", },
			img = {"winter_ornaments", "winter_ornament_boss_eyeofterror1", },
		},
		ak_ornament_boss_eyeofterror2 = {
			anim = {"winter_ornaments2021", "winter_ornaments2021", "boss_eyeofterror2", },
			img = {"winter_ornaments", "winter_ornament_boss_eyeofterror2", },
		},
		ak_ornament_boss_fuelweaver = {
			anim = {"winter_ornaments", "winter_ornaments", "boss_fuelweaver", },
			img = {"winter_ornaments", "winter_ornament_boss_fuelweaver", },
		},
		ak_ornament_boss_hermithouse = {
			anim = {"winter_ornaments2020", "winter_ornaments2020", "boss_hermithouse", },
			img = {"winter_ornaments", "winter_ornament_boss_hermithouse", },
		},
		ak_ornament_boss_klaus = {
			anim = {"winter_ornaments", "winter_ornaments", "boss_klaus", },
			img = {"winter_ornaments", "winter_ornament_boss_klaus", },
		},
		ak_ornament_boss_krampus = {
			anim = {"winter_ornaments", "winter_ornaments", "boss_krampus", },
			img = {"winter_ornaments", "winter_ornament_boss_krampus", },
		},
		ak_ornament_boss_malbatross = {
			anim = {"winter_ornaments2019", "winter_ornaments2019", "boss_malbatross", },
			img = {"winter_ornaments", "winter_ornament_boss_malbatross", },
		},
		ak_ornament_boss_minotaur = {
			anim = {"winter_ornaments2020", "winter_ornaments2020", "boss_minotaur", },
			img = {"winter_ornaments", "winter_ornament_boss_minotaur", },
		},
		ak_ornament_boss_moose = {
			anim = {"winter_ornaments", "winter_ornaments", "boss_moose", },
			img = {"winter_ornaments", "winter_ornament_boss_moose", },
		},
		ak_ornament_boss_noeyeblue = {
			anim = {"winter_ornaments", "winter_ornaments", "boss_noeyeblue", },
			img = {"winter_ornaments", "winter_ornament_boss_noeyeblue", },
		},
		ak_ornament_boss_noeyered = {
			anim = {"winter_ornaments", "winter_ornaments", "boss_noeyered", },
			img = {"winter_ornaments", "winter_ornament_boss_noeyered", },
		},
		ak_ornament_boss_pearl = {
			anim = {"winter_ornaments2020", "winter_ornaments2020", "boss_pearl", },
			img = {"winter_ornaments", "winter_ornament_boss_pearl", },
		},
		ak_ornament_boss_toadstool = {
			anim = {"winter_ornaments", "winter_ornaments", "boss_toadstool", },
			img = {"winter_ornaments", "winter_ornament_boss_toadstool", },
		},
		ak_ornament_boss_toadstool_misery = {
			anim = {"winter_ornaments2020", "winter_ornaments2020", "boss_toadstool_misery", },
			img = {"winter_ornaments", "winter_ornament_boss_toadstool_misery", },
		},
		ak_ornament_boss_wagstaff = {
			anim = {"winter_ornaments2021", "winter_ornaments2021", "boss_wagstaff", },
			img = {"winter_ornaments", "winter_ornament_boss_wagstaff", },
		},
		ak_ornament_fancy1 = {
			anim = {"winter_ornaments", "winter_ornaments", "fancy1", },
			img = {"winter_ornaments", "winter_ornament_fancy1", },
		},
		ak_ornament_fancy2 = {
			anim = {"winter_ornaments", "winter_ornaments", "fancy2", },
			img = {"winter_ornaments", "winter_ornament_fancy2", },
		},
		ak_ornament_fancy3 = {
			anim = {"winter_ornaments", "winter_ornaments", "fancy3", },
			img = {"winter_ornaments", "winter_ornament_fancy3", },
		},
		ak_ornament_fancy4 = {
			anim = {"winter_ornaments", "winter_ornaments", "fancy4", },
			img = {"winter_ornaments", "winter_ornament_fancy4", },
		},
		ak_ornament_fancy5 = {
			anim = {"winter_ornaments", "winter_ornaments", "fancy5", },
			img = {"winter_ornaments", "winter_ornament_fancy5", },
		},
		ak_ornament_fancy6 = {
			anim = {"winter_ornaments", "winter_ornaments", "fancy6", },
			img = {"winter_ornaments", "winter_ornament_fancy6", },
		},
		ak_ornament_fancy7 = {
			anim = {"winter_ornaments", "winter_ornaments", "fancy7", },
			img = {"winter_ornaments", "winter_ornament_fancy7", },
		},
		ak_ornament_fancy8 = {
			anim = {"winter_ornaments", "winter_ornaments", "fancy8", },
			img = {"winter_ornaments", "winter_ornament_fancy8", },
		},
		ak_ornament_festivalevents1 = {
			anim = {"winter_ornaments2018", "winter_ornaments2018", "festivalevents1", },
			img = {"winter_ornaments", "winter_ornament_festivalevents1", },
		},
		ak_ornament_festivalevents2 = {
			anim = {"winter_ornaments2018", "winter_ornaments2018", "festivalevents2", },
			img = {"winter_ornaments", "winter_ornament_festivalevents2", },
		},
		ak_ornament_festivalevents3 = {
			anim = {"winter_ornaments2018", "winter_ornaments2018", "festivalevents3", },
			img = {"winter_ornaments", "winter_ornament_festivalevents3", },
		},
		ak_ornament_festivalevents4 = {
			anim = {"winter_ornaments2018", "winter_ornaments2018", "festivalevents4", },
			img = {"winter_ornaments", "winter_ornament_festivalevents4", },
		},
		ak_ornament_festivalevents5 = {
			anim = {"winter_ornaments2018", "winter_ornaments2018", "festivalevents5", },
			img = {"winter_ornaments", "winter_ornament_festivalevents5", },
		},
		ak_ornament_light1 = {
			anim = {"winter_ornaments", "winter_ornaments", "light1_off", },
			img = {"winter_ornaments", "winter_ornament_light1", },
		},
		ak_ornament_light2 = {
			anim = {"winter_ornaments", "winter_ornaments", "light2_off", },
			img = {"winter_ornaments", "winter_ornament_light2", },
		},
		ak_ornament_light3 = {
			anim = {"winter_ornaments", "winter_ornaments", "light3_off", },
			img = {"winter_ornaments", "winter_ornament_light3", },
		},
		ak_ornament_light4 = {
			anim = {"winter_ornaments", "winter_ornaments", "light4_off", },
			img = {"winter_ornaments", "winter_ornament_light4", },
		},
		ak_ornament_light5 = {
			anim = {"winter_ornaments", "winter_ornaments", "light5_off", },
			img = {"winter_ornaments", "winter_ornament_light5", },
		},
		ak_ornament_light6 = {
			anim = {"winter_ornaments", "winter_ornaments", "light6_off", },
			img = {"winter_ornaments", "winter_ornament_light6", },
		},
		ak_ornament_light7 = {
			anim = {"winter_ornaments", "winter_ornaments", "light7_off", },
			img = {"winter_ornaments", "winter_ornament_light7", },
		},
		ak_ornament_light8 = {
			anim = {"winter_ornaments", "winter_ornaments", "light8_off", },
			img = {"winter_ornaments", "winter_ornament_light8", },
		},
		ak_ornament_plain1 = {
			anim = {"winter_ornaments", "winter_ornaments", "plain1", },
			img = {"winter_ornaments", "winter_ornament_plain1", },
		},
		ak_ornament_plain10 = {
			anim = {"winter_ornaments", "winter_ornaments", "plain10", },
			img = {"winter_ornaments", "winter_ornament_plain10", },
		},
		ak_ornament_plain11 = {
			anim = {"winter_ornaments", "winter_ornaments", "plain11", },
			img = {"winter_ornaments", "winter_ornament_plain11", },
		},
		ak_ornament_plain12 = {
			anim = {"winter_ornaments", "winter_ornaments", "plain12", },
			img = {"winter_ornaments", "winter_ornament_plain12", },
		},
		ak_ornament_plain2 = {
			anim = {"winter_ornaments", "winter_ornaments", "plain2", },
			img = {"winter_ornaments", "winter_ornament_plain2", },
		},
		ak_ornament_plain3 = {
			anim = {"winter_ornaments", "winter_ornaments", "plain3", },
			img = {"winter_ornaments", "winter_ornament_plain3", },
		},
		ak_ornament_plain4 = {
			anim = {"winter_ornaments", "winter_ornaments", "plain4", },
			img = {"winter_ornaments", "winter_ornament_plain4", },
		},
		ak_ornament_plain5 = {
			anim = {"winter_ornaments", "winter_ornaments", "plain5", },
			img = {"winter_ornaments", "winter_ornament_plain5", },
		},
		ak_ornament_plain6 = {
			anim = {"winter_ornaments", "winter_ornaments", "plain6", },
			img = {"winter_ornaments", "winter_ornament_plain6", },
		},
		ak_ornament_plain7 = {
			anim = {"winter_ornaments", "winter_ornaments", "plain7", },
			img = {"winter_ornaments", "winter_ornament_plain7", },
		},
		ak_ornament_plain8 = {
			anim = {"winter_ornaments", "winter_ornaments", "plain8", },
			img = {"winter_ornaments", "winter_ornament_plain8", },
		},
		ak_ornament_plain9 = {
			anim = {"winter_ornaments", "winter_ornaments", "plain9", },
			img = {"winter_ornaments", "winter_ornament_plain9", },
		},
	},
	pack = {
		ak_bearger_pack = {
			img = "backcub",
			anim = {"backcub", "backcub", "anim", "idle_water", },
			override = {"backcub", },
		},
		ak_beefalo_pack = {
			img = "backpack_beefalo",
			anim = {"backpack1", "backpack_beefalo", "anim", "idle_water", },
			override = {"backpack_beefalo", },
		},
		ak_beefalo_pack_item = {
			img = "backpack_beefalo",
			anim = {"backpack1", "backpack_beefalo", "anim", "idle_water", },
			override = {"backpack_beefalo", },
		},
		ak_crab_pack = {
			img = "backpack_crab",
			anim = {"backpack1", "backpack_crab", "anim", "idle_water", },
			override = {"backpack_crab", },
		},
		ak_crab_pack_item = {
			img = "backpack_crab",
			anim = {"backpack1", "backpack_crab", "anim", "idle_water", },
			override = {"backpack_crab", },
		},
		ak_deerclops_pack = {
			img = "backpack_deerclops",
			anim = {"backpack1", "backpack_deerclops", "anim", "idle_water", },
			override = {"backpack_deerclops", },
		},
		ak_dragonfly_pack = {
			img = "backpack_dragonfly",
			anim = {"backpack1", "backpack_dragonfly", "anim", "idle_water", },
			override = {"backpack_dragonfly", },
		},
		ak_hound_pack = {
			img = "backpack_hound",
			anim = {"backpack1", "backpack_hound", "anim", "idle_water", },
			override = {"backpack_hound", },
		},
		ak_hound_pack_item = {
			img = "backpack_hound",
			anim = {"backpack1", "backpack_hound", "anim", "idle_water", },
			override = {"backpack_hound", },
		},
		ak_rabbit_pack = {
			img = "backpack_rabbit",
			anim = {"backpack1", "backpack_rabbit", "anim", "idle_water", },
			override = {"backpack_rabbit", },
		},
		ak_rabbit_pack_item = {
			img = "backpack_rabbit",
			anim = {"backpack1", "backpack_rabbit", "anim", "idle_water", },
			override = {"backpack_rabbit", },
		},
	},
	prefab = {
		ak_gorilla_chariot = {
			img = {"ak_icons", "ak_gorilla_chariot", },
		},
		ak_rook = {
			img = {"ak_icons", "ak_rook_head", },
		},
	},
	structure_other = {
		ak_oil_stone = {
			anim = {"ak_oil_stone", "ak_oil_stone", "off", },
		},
		firesuppressor = {
			anim = {"firefighter_placement", "firefighter_placement", "idle", },
		},
		ak_thumper = {
			img = {"minimap/minimap_data.xml", "thumper.png", origin=true},
		},
	},
	liquid = {
		ak_petroleum_liquid = {
			anim = {"ak_petroleum_liquid", "ak_petroleum_liquid", "idle", },
		},
		ak_tar = {
			anim = {"ink_puddle", "ink_puddle", "idle", },
		},
		ak_water = {
			anim = {"ak_water", "ak_water", "idle", },
		},
		ak_water_polluted = {
			anim = {"ak_water_polluted", "ak_water_polluted", "idle", },
		},
		ak_water_salt = {
			anim = {"ak_water_salt", "ak_water_salt", "idle", },
		},
	},
	liquid_bottle = {
		ak_petroleum = {
			img = {"ak_items", "ak_petroleum", },
			anim = {"ak_items", "ak_items", "ak_petroleum", "ak_petroleum", },
		},
		ak_water_bottle = {
			img = {"ak_items", "ak_water_bottle", },
			anim = {"ak_items", "ak_items", "ak_water_bottle", "ak_water_bottle", },
		},
		ak_water_polluted_bottle = {
			img = {"ak_items", "ak_water_polluted_bottle", },
			anim = {"ak_items", "ak_items", "ak_water_polluted_bottle", "ak_water_polluted_bottle", },
		},
		ak_water_salt_bottle = {
			img = {"ak_items", "ak_water_salt_bottle", },
			anim = {"ak_items", "ak_items", "ak_water_salt_bottle", "ak_water_salt_bottle", },
		},
	},
	gas = {
		ak_gas_carbon_dioxide = {
			anim = {"cropdust_fxa", "ak_gas_carbon_dioxide", "idle_loop", },
		},
		ak_gas_chlorine = {
			anim = {"cropdust_fxa", "ak_gas_chlorine", "idle_loop", },
		},
		ak_gas_hydrogen = {
			anim = {"cropdust_fxa", "ak_gas_hydrogen", "idle_loop", },
		},
		ak_gas_natural = {
			anim = {"cropdust_fxa", "ak_gas_natural", "idle_loop", },
		},
		ak_gas_oxygen = {
			anim = {"cropdust_fxa", "ak_gas_oxygen", "idle_loop", },
		},
		ak_gas_oxygen_polluted = {
			anim = {"cropdust_fxa", "ak_gas_oxygen_polluted", "idle_loop", },
		},
		ak_gas_steam = {
			anim = {"cropdust_fxa", "ak_gas_steam", "idle_loop", },
		},
	},
	gas_tank = {
		ak_gas_carbon_dioxide_tank = {
			img = {"ak_items", "ak_gas_carbon_dioxide_tank", },
		},
		ak_gas_chlorine_tank = {
			img = {"ak_items", "ak_gas_chlorine_tank", },
		},
		ak_gas_hydrogen_tank = {
			img = {"ak_items", "ak_gas_hydrogen_tank", },
		},
		ak_gas_natural_tank = {
			img = {"ak_items", "ak_gas_natural_tank", },
		},
		ak_gas_oxygen_polluted_tank = {
			img = {"ak_items", "ak_gas_oxygen_polluted_tank", },
		},
		ak_gas_oxygen_tank = {
			img = {"ak_items", "ak_gas_oxygen_tank", },
		},
		ak_gas_steam_tank = {
			img = {"ak_items", "ak_gas_steam_tank", },
		},
	},
}

local structures_a = {
	"ak_auto_harvester",
	"ak_battery",
	"ak_calorifier",
	"ak_clear_station",
	"ak_coal_generator",
	"ak_coffee_machine",
	"ak_dispensary",
	"ak_docile_table",
	"ak_egg_desk",
	"ak_electric_wire",
	"ak_fan",
	"ak_farmer_station",
	"ak_farm_brick",
	"ak_fertilizer_maker",
	"ak_food_compressor",
	"ak_fridge",
	"ak_gem_refiner",
	"ak_great_bed",
	"ak_hot_furnace",
	"ak_juicer",
	"ak_kiln",
	"ak_lamp",
	"ak_level_eraser",
	"ak_loader",
	"ak_magic_table",
	"ak_metal_refiner",
	"ak_molecule_furnace",
	"ak_oil_well",
	"ak_oven",
	"ak_pharmacy",
}
local structures_b = {
	"ak_plant_brick",
	"ak_plasticator",
	"ak_refrigerator",
	"ak_research_center",
	"ak_robot_worker",
	"ak_rocket_head",
	"ak_scanner",
	"ak_shadow_bed",
	"ak_shadow_portal",
	"ak_smithing_table",
	"ak_stone_breaker",
	"ak_sun_generator",
	"ak_super_calculator",
	"ak_tar_generator",
	"ak_telescope_mount",
	"ak_textile_machine",
	"ak_transporter",
	"ak_transport_center",
	"ak_triage_table",
	"ak_virtual_orrery",
	"ak_wood_generator",
	"ak_wool_shearing_machine",
	"ak_work_bench",
	"ak_hydrogen_generator",
	"ak_manual_generator",
	"ak_mesh_tile",
	"ak_compost",
	"ak_oil_refinery",
	"ak_ice_maker",
	"ak_power_shutoff",
	"ak_ore_scrubber",
	"ak_desalinator",
	"ak_park_sign",
	"ak_carbon_skimmer",
	"ak_jumbo_battery",
	"ak_liquid_pump",
	"ak_natural_gas_generator",
	"ak_oxygen_diffuser",
	"ak_pitcher_pump",
	"ak_water_sieve",
	"ak_rocket_storage",
	"ak_electrolyzer",
	"ak_algae_distiller",
	"ak_algae_terrarium",
	"ak_planter_box",
}

local scrolls = {
	"ak_scroll",
"ak_scroll_bird",
"ak_scroll_bunnyman",
"ak_scroll_flower",
"ak_scroll_grow",
"ak_scroll_harvest",
"ak_scroll_lightning",
"ak_scroll_pigman",
"ak_scroll_pig_armor",
"ak_scroll_pig_armorex",
"ak_scroll_pig_damage",
"ak_scroll_pig_damage_plus",
"ak_scroll_pig_heal",
"ak_scroll_pig_health",
"ak_scroll_pig_leader",
"ak_scroll_pig_speed",
"ak_scroll_pig_speed_plus",
"ak_scroll_pig_teleport",
"ak_scroll_shadow",
"ak_scroll_sleep",
"ak_scroll_tentacle",
"ak_scroll_volcano",
"ak_scroll_wind",
}
local potions = {
"ak_livingtree_root",
"ak_plantable_flower_cave",
"ak_plantable_grass_water",
"ak_plantable_mangrove",
"ak_plantable_reeds",
"ak_potion_brave_large",
"ak_potion_brave_small",
"ak_potion_cool",
"ak_potion_crazy",
"ak_potion_detoxify",
"ak_potion_dry",
"ak_potion_fire",
"ak_potion_frozen",
"ak_potion_health_large",
"ak_potion_health_small",
"ak_potion_holy",
"ak_potion_horror",
"ak_potion_iron",
"ak_potion_killer",
"ak_potion_metal",
"ak_potion_moon",
"ak_potion_sanity_large",
"ak_potion_sanity_small",
"ak_potion_shadow",
"ak_potion_shine",
"ak_potion_smell",
"ak_potion_warm",
"ak_potion_warth",
}
local injectors = {
"blue_cap",
"fireflies",
"flint",
"goldnugget",
"green_cap",
"iron",
"marble",
"nitre",
"obsidian",
"purplegem",
"red_cap",
"rocks",
"thulecite",
"ak_plant_army_seed",
"ak_copper_ore",
"ak_tungsten_ore",
"ak_plumbum",
}


















item_assets.structures = {}
for k, v in pairs(structures_a) do
	item_assets.structures[v] = {
		img = {"ak_structures", v},
		anim = {v, v, "off"},
	}
end
for k, v in pairs(structures_b) do
	item_assets.structures[v] = {
		img = {"ak_structures", v},
		anim = {v, v, "off"},
	}
end

item_assets.structures["ak_shadow_portal"].anim[3] = "idle"
item_assets.structures["ak_ice_maker"].anim[3] = "ui"
item_assets.structures["ak_rocket_head"].anim[3] = "ui"
item_assets.structures["ak_water_sieve"].anim[3] = "ui"
item_assets.structures["ak_rocket_storage"].anim[3] = "grounded"

local sp_structures_a = {
	"ak_clear_station",
	"ak_juicer",
	"ak_farm_brick",
}



for k, v in pairs(sp_structures_a) do
	item_assets.structures[v].anim = {"ak_structures", "ak_structures", v}
end

local sp_structures_b = {
	"ak_plant_brick",
	"ak_mesh_tile",
	"ak_park_sign",
}
for k, v in pairs(sp_structures_b) do

	item_assets.structures[v].anim = {"ak_structures_b", "ak_structures_b", v}
end
local sp_structures_c = {
	"ak_deodorizer",

	"ak_gas_pump",
	"ak_gas_reservoir",
	"ak_heavi_watt_joint_plate",
	"ak_incubator",
	"ak_large_power_transformer",
	"ak_liquid_reservoir",
	"ak_mini_gas_pump",
	"ak_mini_liquid_pump",
	"ak_smart_battery",
	"ak_smart_storage_bin",
	"ak_atmo_suit_dock",
	"ak_oxygen_mask_dock",

	"ak_rocket_control_station",

	"ak_bottle_emptier",
	"ak_storage_bin",
	"ak_jet_suit_dock",
	"ak_planter_box",
	"ak_feeder",
}
for k, v in pairs(sp_structures_c) do

	if item_assets.structures[v] == nil then
		item_assets.structures[v] = {
			img = {"ak_structures", v}
		}
	end
	item_assets.structures[v].anim = {"ak_structures_c", "ak_structures_c", v}
end


item_assets.scrolls = {}
for k, v in pairs(scrolls) do


	item_assets.scrolls[v] = {
		img = {"ak_scrolls", v},
		anim = {"papyrus", "papyrus", "idle", "idle_water"},
	}
end

item_assets.potions = {}
for k, v in pairs(potions) do


	item_assets.potions[v] = {
		img = {"ak_potions", v},
		anim = {"ak_potions", "ak_potions", v},
	}
end


item_assets.potions["ak_plantable_reeds_water"] = item_assets.potions["ak_plantable_reeds"]

item_assets.injectors = {}
for k, v in pairs(injectors) do
	local name = "ak_injector_"..v


	item_assets.injectors[name] = {
		img = {"ak_injectors", name},
		anim = {"lifepen", "lifepen", "idle"},
	} 
end


for kind, assets_tbl in pairs(item_assets) do
	for name, assets in pairs(assets_tbl) do
		local tmp_assets = {}
		if assets.tp_spear_asset then
			local tp_anim = assets.tp_spear_asset
			if tp_anim == "spear" then
				tmp_assets = {
					img = "spear",
					anim = {"spear", "spear", "idle", "idle_water"},
					override = {"swap_spear"},
				}
			else
				tmp_assets = {
					img = {"ak_weapons", name},
					anim = {tp_anim, tp_anim, "idle", "idle_water"},
					override = {tp_anim, "swap_object"},
				}
			end
			assets_tbl[name] = tmp_assets
		end
	end
end

local function tranverse(t)
	for k, v in pairs(t) do
		print(k)
		for k2, v2 in pairs(v) do
			print(k2, v2)
		end
	end
end

-- tranverse(item_assets.structures)

local function print_data(name, assets)
    local s = string.format("AssetPack(\"%s\",\n", name)
    if assets.anim then
        s = s..string.format("\tAnim(\"%s\", \"%s\", \"%s\"),\n", unpack(assets.anim))
    end
    if assets.img then
		-- local atlas, img = unpack(assets.img)
        s = s..string.format("\tImg(\"%s\", \"%s\")\n", unpack(assets.img))
        -- s = s..string.format("\tImg(\"%s\", \"%s\")\n", "ak_"..string.sub(atlas, 4, -1), "ak_"..string.sub(img, 4, -1))
    end
    s = s..string.format("),")
    print(s)
end

local tt = {
	tp_plantable_reeds={
		anim = {"tp_plantable", "tp_plantable", "reeds", },
		img = {"tp_potions", "tp_plantable_reeds"},
	},
	tp_plantable_reeds_water={
		anim = {"tp_plantable", "tp_plantable", "reeds", },
		img = {"tp_potions", "tp_plantable_reeds"},
	},
	tp_plantable_flower_cave={
		anim = {"tp_plantable", "tp_plantable", "reeds", },
		img = {"tp_potions", "tp_plantable_flower_cave"},
	},
	tp_plantable_grass_water={
		anim = {"tp_plantable", "tp_plantable", "reeds", },
		img = {"tp_potions", "tp_plantable_grass_water"},
	},
	tp_plantable_mangrove={
		anim = {"tp_plantable", "tp_plantable", "reeds", },
		img = {"tp_potions", "tp_plantable_mangrove"},
	},
}

local tt2 = {
	--
	scroll_sleep = {
		anim = {"papyrus", "papyrus", "idle","idle_water",},
		img = {"ak_scrolls", "scroll_sleep",},
	},
	scroll_grow = {
		anim = {"papyrus", "papyrus", "idle","idle_water",},
		img = {"ak_scrolls", "scroll_grow",},
	},
	scroll_lightning = {
		anim = {"papyrus", "papyrus", "idle","idle_water",},
		img = {"ak_scrolls", "scroll_lightning",},
	},
	scroll_bird = {
		anim = {"papyrus", "papyrus", "idle","idle_water",},
		img = {"ak_scrolls", "scroll_bird",},
	},
	scroll_tentacle = {
		anim = {"papyrus", "papyrus", "idle","idle_water",},
		img = {"ak_scrolls", "scroll_tentacle",},
	},
	scroll_volcano = {
		anim = {"papyrus", "papyrus", "idle","idle_water",},
		img = {"ak_scrolls", "scroll_volcano",},
	},
	scroll_pig_heal = {
		anim = {"papyrus", "papyrus", "idle","idle_water",},
		img = {"ak_scrolls", "scroll_pig_heal",},
	},
	scroll_pig_health = {
		anim = {"papyrus", "papyrus", "idle","idle_water",},
		img = {"ak_scrolls", "scroll_pig_health",},
	},
	scroll_pig_armorex = {
		anim = {"papyrus", "papyrus", "idle","idle_water",},
		img = {"ak_scrolls", "scroll_pig_armorex",},
	},
	scroll_pig_speed = {
		anim = {"papyrus", "papyrus", "idle","idle_water",},
		img = {"ak_scrolls", "scroll_pig_speed",},
	},
	scroll_pig_wind = {
		anim = {"papyrus", "papyrus", "idle","idle_water",},
		img = {"ak_scrolls", "scroll_pig_wind",},
	},
	scroll_pig_damage = {
		anim = {"papyrus", "papyrus", "idle","idle_water",},
		img = {"ak_scrolls", "scroll_pig_damage",},
	},
	scroll_wind = {
		anim = {"papyrus", "papyrus", "idle","idle_water",},
		img = {"ak_scrolls", "scroll_wind",},
	},
}

local tt3 = {
	tp_potion_frozen={
		anim = {"tp_potion_frozen", "tp_potion_frozen", "idle", },
		img = {"tp_potions", "tp_potion_frozen"},
	},
	tp_potion_fire={
		anim = {"tp_potion_fire", "tp_potion_fire", "idle", },
		img = {"tp_potions", "tp_potion_fire"},
	},
	tp_potion_holy={
		anim = {"tp_potion_holy", "tp_potion_holy", "idle", },
		img = {"tp_potions", "tp_potion_holy"},
	},
	tp_potion_health_small={
		anim = {"tp_potion", "tp_potion", "health_small", },
		img = {"tp_potions", "tp_potion_health_small"},
	},
	tp_potion_sanity_small={
		anim = {"tp_potion", "tp_potion", "sanity_small", },
		img = {"tp_potions", "tp_potion_sanity_small"},
	},
	tp_potion_brave_small={
		anim = {"tp_potion", "tp_potion", "brave_small", },
		img = {"tp_potions", "tp_potion_brave_small"},
	},
	tp_potion_warth={
		anim = {"tp_potion", "tp_potion", "warth", },
		img = {"tp_potions", "tp_potion_warth"},
	},
	tp_potion_shine={
		anim = {"tp_potion", "tp_potion", "shine", },
		img = {"tp_potions", "tp_potion_shine"},
	},
	tp_potion_crazy={
		anim = {"tp_potion_2", "tp_potion_2", "crazy", },
		img = {"tp_potions", "tp_potion_crazy"},
	},
	tp_potion_dry={
		anim = {"tp_potion_2", "tp_potion_2", "dry", },
		img = {"tp_potions", "tp_potion_dry"},
	},
	tp_potion_smell={
		anim = {"tp_potion_2", "tp_potion_2", "smell", },
		img = {"tp_potions", "tp_potion_smell"},
	},
	tp_potion_iron={
		anim = {"tp_potion_2", "tp_potion_2", "iron", },
		img = {"tp_potions", "tp_potion_iron"},
	},
	tp_potion_metal={
		anim = {"tp_potion_2", "tp_potion_2", "metal", },
		img = {"tp_potions", "tp_potion_metal"},
	},
	tp_potion_killer={
		anim = {"tp_potion_2", "tp_potion_2", "killer", },
		img = {"tp_potions", "tp_potion_killer"},
	},
	tp_potion_shadow={
		anim = {"tp_potion_2", "tp_potion_2", "shadow", },
		img = {"tp_potions", "tp_potion_shadow"},
	},
	tp_potion_cool={
		anim = {"tp_potion_2", "tp_potion_2", "cool", },
		img = {"tp_potions", "tp_potion_cool"},
	},
	tp_potion_warm={
		anim = {"tp_potion_2", "tp_potion_2", "warm", },
		img = {"tp_potions", "tp_potion_warm"},
	},
	tp_potion_detoxify={
		anim = {"tp_potion_2", "tp_potion_2", "detoxify", },
		img = {"tp_potions", "tp_potion_detoxify"},
	},
	tp_potion_horror={
		anim = {"tp_potion_2", "tp_potion_2", "horror", },
		img = {"tp_potions", "tp_potion_horror"},
	},
}

-- for k, v in pairs(tt3) do
-- 	print_data(k, v)
-- end

local helm_tbl2 = {
	"helm_arcane_grey",
	"helm_arcane_pink",
	"helm_arcane_purple",
	"helm_arcane_skyblue",
	"helm_arcane_yellow",
	"helm_arcane_green",
	"helm_arcane_blue",
	"helm_arcane_red",
	"helm_dog_blue",
	"helm_dog_green",
	"helm_dog_grey",
	"helm_dog_orange",
	"helm_dog_pink",
	"helm_dog_purple",
	"helm_dog_red",
	"helm_dog_skyblue",
	"helm_dog_yellow",
}
for k, v in pairs(helm_tbl2) do
	print(string.format([[
	AssetPack("%s",
		Anim("%s", "%s", "anim", "idle_water"),
		Img("sam_helms", "%s"),
		Symbol("swap_hat", "%s", "swap_hat"),
		nil, {
			Asset("ANIM", "anim/%s.zip"),
		}
	),]], v, v, v, v, v, v))
end

WARGON = {}
WARGON.AK_ITEM_IMGS = {}
WARGON.AK_ITEM_ANIMS = {}
WARGON.AK_ITEM_OVERRIDES = {}
WARGON.AK_ASSETS = {}
for kind, assets_tbl in pairs(item_assets) do
	for name, assets in pairs(assets_tbl) do
		-- WARGON.AK_ASSETS[name] = assets
		-- if assets.img then
		-- 	WARGON.AK_ITEM_IMGS[name] = assets.img
		-- end
		-- if assets.anim then
		-- 	WARGON.AK_ITEM_ANIMS[name] = assets.anim
		-- end
		-- if assets.override then
		-- 	WARGON.AK_ITEM_OVERRIDES[name] = assets.override
		-- end
        if kind == "structures" then
            -- print_data(name, assets)
        end
	end
end

