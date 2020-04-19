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
--DESERTPLANET
AddLevel(GLOBAL.LEVELTYPE.CUSTOM, {
		id="DESERTPLANET",
		name="shamoxingqiu",
		nomaxwell=true,
		overrides={
			{"world_size", 		"default"},
			{"day", 			"onlyday"}, 	
			{"weather_start", 	"wet"},		
			{"frograin",		"often"},
			
			{"start_setpeice", 	"WinterStartEasy"},	
			{"start_node", 		"Forest"},	

			{"season", 			"autumn"}, 
			{"season_start", 	"autumn"}, 
			
			{"berrybush", 		"never"},
			{"start_node",		"buling_Badlands"},
		},
		tasks = {
			"buling_Desert",
			"buling_Desert2",
			"buling_Desert3",
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
--
