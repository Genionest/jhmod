--[[local require = GLOBAL.require
require("map/level")
local levels = require("map/levels")

local LEVELTYPE = GLOBAL.LEVELTYPE

--- add entrance to above world
for _, level in pairs(levels.sandbox_levels) do 
table.insert(level.tasks, "EntranceToReef")
end]]
local require = GLOBAL.require
require("map/level")
--STORMPLANET
AddLevel(GLOBAL.LEVELTYPE.CUSTOM, {
		id="stormplanet",
		name="fengbaoxingqiu",
		nomaxwell=true,
		overrides={
			{"world_size", 		"huge"},
			{"location",		"shipwrecked"},
			{"day", 			"onlyday"}, 
			--{"season", 			"onlysummer"},
			--{"weather", 		"always"},
			{"traps", 			"never"},
			{"creepyeyes", 		"always"},
			{"protected", 		"never"},
			{"boons",			"never"},
			{"poi", 			"never"},
			{"roads", 			"never"},
			{"loop",			"never"},
			{"season", 			"onlysummer"}, 
			{"start_node",		"StormWorldRoom"},
			{"season_start",	"wet"},
			{"season_mode",	"tropical"},
			{"mild_season",     0},
			{"wet_season",     40},
			{"green_season",     0},
			{"dry_season",     0},
		},	
		--[[start_tasks = {
			["WorldTask"] = {
				weight = .1,
				start_setpiece = "ShipwreckedStart",
				start_node = "BeachPalmCasino2"
			},
		},]]
		tasks = {
			"buling_Island2",
			"buling_Island3",
			"buling_Island4",
			"buling_Island5",
			"buling_Island6",
		},
		background_node_range = {0, 1},
		numoptionaltasks =0,
		--hideminimap = true,
		teleportaction = "restart",
		optionaltasks = {
		},
		override_triggers = {
			["WorldTask"] = {	
				{"areaambient", "VOID"}, 
			},
		},
		required_prefabs = {},
})
--DESERTPLANET
AddLevel(GLOBAL.LEVELTYPE.CUSTOM, {
		id="desertplanet",
		name="shamoxingqiu",
		nomaxwell=true,
		overrides={
			{"roads", 			"never"},
			{"world_size", 		"medium"},
			{"day",			 	"longday"}, 
			{"start_node",		"StormWorldRoom2"},
			{"season", 			"onlysummer"}, 
			{"season_start", 	"summer"},
			{"waves", 			"off"},
			{"branching",		"default"},
			{"loop",			"never"},
			{"loop_percent",	"never"},
			{"weather", 		"never"},
			{"boons", 			"never"},
			{"poi", 			"never"},
			{"traps", 			"never"},
			{"protected", 		"never"},
		},
		tasks = {
			"buling_Desert",
		},
		background_node_range = {0, 0},
		--hideminimap = true,
		teleportaction = "restart",
})
--EDENPLANET
AddLevel(GLOBAL.LEVELTYPE.CUSTOM, {
		id="edenplanet",
		name="yidianxingqiu",
		nomaxwell=true,
		overrides={
				{"roads", 			"never"},
				--{"world_size", 		"mini"},
				{"loop_percent",	"always"},
				--{"start_setpeice", 	"PorklandStart"},		
				{"start_node",		"StormWorldRoom3"},
				{"spring",			"noseason"},
				{"summer",			"noseason"},
				{"branching",		"least"},
				{"location",		"porkland"},
				{"flowers_rainforest",		"never"},
				{"humid_season",		"40"},
				{"lush_season",		"0"},
				{"temperate_season",		"0"},
				{"glowflycycle",		"never"},
				{"roc",		"never"},
		},
		tasks = {
				"buling_civilization",

		},
		background_node_range = {0, 0},
		--hideminimap = true,
		teleportaction = "restart",
})
