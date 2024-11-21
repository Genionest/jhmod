GLOBAL.setmetatable(env, {__index = function(t, k)
	return GLOBAL.rawget(GLOBAL, k)
end,})

require("map/tasks")  -- import AddTask
require("modutil")  -- import AddTaskPreInit, AddRoomPreInit
require("map/rooms")  -- import AddRoom
require("map/terrain")  -- import all ground
require("constants")
require("map/level")  -- import constant LEVELTYPE
require("map/lockandkey") -- import LOCKS and KEYS
StaticLayout = require("map/static_layout")  -- import StaticLayout
layouts = require("map/layouts").Layouts  -- import Layouts Table

-- layouts["PigLord"] = StaticLayout.Get("map/static_layouts/pig_island")
layouts["DefaultPigking"] = StaticLayout.Get("map/static_layouts/pig_island")

-- AddRoom("PigOfLord", {
-- 	colour={r=0.8,g=.8,b=.1,a=.50},
-- 	value = GROUND.GRASS,
-- 	contents = {
-- 		countstaticlayouts = {
-- 			["PigLord"] = 1,
-- 		},
-- 		-- countprefabs = {
-- 		-- 	pighouse = 1,
-- 		-- }
-- 	}
-- })

-- AddRoomPreInit("PigKingdom", function(room)
-- 	room.contents.countstaticlayouts.DefaultPigking = 0
-- end)

-- AddTask("WargonTask", {
-- 	locks = LOCKS.NONE,
-- 	keys_given = KEYS.MEAT,
-- 	-- entrance_room = "ForceDisconnectedRoom",
-- 	room_choices = {
-- 		["PigOfLord"] = 1,
-- 	},
-- 	room_bg = GROUND.DIRT,
-- 	background_room = "BGGrass",
-- 	colour={r=math.random(),g=math.random(),b=math.random(),a=math.random()},
-- })

AddLevelPreInit("SURVIVAL_DEFAULT", function(level)
	level.overrides[1] = {"start_setpeice", "DefaultPlusStart"}
	-- table.insert(level.overrides, {"islands", "always"})
	-- table.insert(level.tasks, "WargonTask")
	-- level.overrides = {
	-- 	{"islands", 		"always"},	
	-- 	{"start_setpeice", 	"DefaultPlusStart"},
	-- 	{"season_start",	"autumn"},
	-- 	{"cave_entrance",	"never"},
	-- }
	-- level.tasks = {
	-- 	"IslandHop_Start",
	-- 	"IslandHop_Hounds",
	-- 	"IslandHop_Forest",
	-- 	"IslandHop_Savanna",
	-- 	"IslandHop_Rocky",
	-- 	"IslandHop_Merm",
	-- }
	-- level.numoptionaltasks = 0
	-- level.optionaltasks = {
	-- }
	-- level.set_pieces = {
	-- 	["WesUnlock"] = { restrict_to="background", tasks={ "IslandHop_Start", "IslandHop_Hounds", "IslandHop_Forest", "IslandHop_Savanna", "IslandHop_Rocky", "IslandHop_Merm" } },
	-- }
	-- level.ordered_story_setpieces = {
	-- 	"TeleportatoRingLayout",
	-- 	"TeleportatoBoxLayout",
	-- 	"TeleportatoCrankLayout",
	-- 	"TeleportatoPotatoLayout",
	-- 	"TeleportatoBaseAdventureLayout",
	-- }
	-- level.required_prefabs = {
	-- 	"teleportato_ring",  "teleportato_box",  "teleportato_crank", "teleportato_potato", "teleportato_base", "chester_eyebone"
	-- }
end)

-- AddLevelPreInit("SHIPWRECKED_DEFAULT", function(level)
-- 	level.overrides[1] = {"start_setpeice", "DefaultPlusStart"}
-- end)

-- AddRoom("WargonRoom", {
-- 	colour = {r=0, g=0, b=0, a=0},
-- 	value = GROUND.GRASS,
-- 	contents = {
-- 		countprefabs = {
-- 			tent = 1,
-- 		}
-- 	}
-- })

-- AddTaskPreInit("Make a pick", function(task)
-- 	task.room_choices["WargonRoom"] = 1
-- end)


--[[ 这个可以成功
local a = terrain.rooms["PigKingdom"]
if a.contents then
	if a.contents.countprefabs then
		a.contents.countprefabs.tent = 1
	end
end
]]