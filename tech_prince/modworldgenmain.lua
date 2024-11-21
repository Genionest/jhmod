GLOBAL.setmetatable(env, {__index = function(t, k)
	return GLOBAL.rawget(GLOBAL, k)
end,})

require("map/tasks")  -- import AddTask
require("modutil")  -- import AddTaskPreInit, AddRoomPreInit
require("map/rooms")  -- import AddRoom
require("map/terrain")  -- import all ground
require("constants")  -- import constant
require("map/level")  -- import constant LEVELTYPE
require("map/lockandkey") -- import LOCKS and KEYS
StaticLayout = require("map/static_layout")  -- import StaticLayout
layouts = require("map/layouts").Layouts  -- import Layouts Table

local function complete_room(room)
	if room.contents == nil then
		room.contents = {}
	end
	if room.contents.distributeprefabs == nil then
		room.contents.distributeprefabs = {}
	end
	if room.contents.countprefabs == nil then
		room.contents.countprefabs = {}
	end
	if room.contents.countstaticlayouts == nil then
		room.contents.countstaticlayouts = {}
	end
end

AddRoomPreInit("PigVillage", function(room)
	-- room.contents.countprefabs.tp_werepig_king = 1
	-- room.contents.countprefabs.tp_grass_pigking = 1
end)

-- AddRoomPreInit("BeefalowPlain", function(room)
-- 	room.contents.countprefabs = {
-- 		tp_sign_rider = 1,
-- 	}
-- end)

AddRoomPreInit("HoundyBadlands", function(room)
	if room.contents.countprefabs == nil then
		room.contents.countprefabs = {}
	end
	room.contents.countprefabs.tp_blue_warg_spawner = 1
	room.contents.countprefabs.tp_red_warg_spawner = 1
end)

layouts["TpWerepigLand"] = StaticLayout.Get("map/static_layouts/tp_werepig_land")
layouts["TpBase"] = StaticLayout.Get("map/static_layouts/tp_base")
layouts["TpMoonSea"] = StaticLayout.Get("map/static_layouts/tp_moon_sea")

AddRoomPreInit("PigKingdom", function(room)
	complete_room(room)
	-- room.contents.countstaticlayouts["TpWerepigLand"] = 1
	room.contents.countprefabs.tp_chest = 1
	room.contents.countprefabs.tp_grass_pigking_spawner = 1
	-- room.contents.countprefabs.tp_werepig_start = 1
end)

local deciduous_rooms = {
	"BGDeciduous",
	"DeepDeciduous",
	-- "MagicalDeciduous",
	"DeciduousMole",
	"DeciduousClearing",
}

for k, v in pairs(deciduous_rooms) do
	AddRoomPreInit(v, function(room)
		complete_room(room)
		-- room.contents.distributeprefabs.tp_gingko_tree = 6
		room.contents.countprefabs.tp_gingko_tree = 5
	end)
end

AddLevelPreInit("SURVIVAL_DEFAULT", function(level)
	level.set_pieces["TpBase"] = {
		count = 1,
		tasks = {
			"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs", "Badlands",
		}
	}
	level.set_pieces["TpMoonSea"] = {
		count = 1,
		tasks = {
			"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs", "Badlands",
		}
	}
end)

local forest_rooms = {
	"BGCrappyForest",
	"BGForest",
	"BGDeepForest",
	"BurntForest",
	"CrappyDeepForest",
	"DeepForest",
	"Forest",
	"CrappyForest",
	"SpiderForest",
	"BurntClearing",
	"Clearing",
}

for k, v in pairs(forest_rooms) do
	AddRoomPreInit(v, function(room)
		complete_room(room)
		room.contents.countprefabs.tp_leif_spawner = 1
		room.contents.countprefabs.tp_boss_spawner = 1
		room.contents.countprefabs.tp_boss_spawner2 = 1
	end)
end

local rocky_rooms = {
	"BGChessRocky",
	"BGRocky",
	"Rocky",
	"TallbirdNests",
}
for k, v in pairs(rocky_rooms) do
	AddRoomPreInit(v, function(room)
		complete_room(room)
		room.contents.countprefabs.tp_pot_bird_egg_spawner = 1
	end)
end