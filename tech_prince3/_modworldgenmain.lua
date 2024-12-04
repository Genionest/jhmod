GLOBAL.setmetatable(env, {__index = function(t, k)
	return GLOBAL.rawget(GLOBAL, k)
end,})

-- import AddTask
require("map/tasks")  
-- import AddTaskPreInit, AddRoomPreInit
require("modutil")  
-- import AddRoom
require("map/rooms")  
-- import all ground
require("map/terrain")  
-- import constant
require("constants")  
-- import constant LEVELTYPE
require("map/level")  
-- import LOCKS and KEYS
require("map/lockandkey") 
-- import StaticLayout
StaticLayout = require("map/static_layout")  
-- import Layouts Table
local layouts = require("map/layouts").Layouts  

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

-- AddRoomPreInit("PigVillage", function(room)
	-- room.contents.countprefabs.tp_werepig_king = 1
	-- room.contents.countprefabs.tp_grass_pigking = 1
-- end)

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

-- layouts["TpWerepigLand"] = StaticLayout.Get("map/static_layouts/tp_werepig_land")
layouts["TpBase"] = StaticLayout.Get("map/static_layouts/tp_base")
-- layouts["TpMoonSea"] = StaticLayout.Get("map/static_layouts/tp_moon_sea")
layouts["TpNpcBase"] = StaticLayout.Get("map/static_layouts/tp_npc_base")

AddRoomPreInit("PigKingdom", function(room)
	complete_room(room)
	room.contents.countprefabs.tp_werepig_king0 = 1
	room.contents.countprefabs.ak_transporter2 = 1
	-- room.contents.countstaticlayouts["TpWerepigLand"] = 1
	-- room.contents.countprefabs.tp_chest = 1
	-- room.contents.countprefabs.tp_grass_pigking_spawner = 1
	-- room.contents.countprefabs.tp_werepig_start = 1
end)

-- local deciduous_rooms = {
-- 	"BGDeciduous",
-- 	"DeepDeciduous",
-- 	"MagicalDeciduous",
-- 	"DeciduousMole",
-- 	"DeciduousClearing",
-- }

-- for k, v in pairs(deciduous_rooms) do
-- 	AddRoomPreInit(v, function(room)
-- 		complete_room(room)
-- 		-- room.contents.distributeprefabs.tp_gingko_tree = 6
-- 		room.contents.countprefabs.tp_gingko_tree = 5
-- 	end)
-- end



AddLevelPreInit("SURVIVAL_DEFAULT", function(level)
	level.set_pieces["TpBase"] = {
		count = 1,
		tasks = {
			"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs", "Badlands",
		}
	}
	level.set_pieces["TpNpcBase"] = {
		count = 8,
		tasks = {
			"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs", "Badlands",
		}
	}
	-- level.set_pieces["TpMoonSea"] = {
	-- 	count = 1,
	-- 	tasks = {
	-- 		"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs", "Badlands",
	-- 	}
	-- }
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
		room.contents.countprefabs.tp_point_postman2 = 1
	end)
end

-- local rocky_rooms = {
-- 	"BGChessRocky",
-- 	"BGRocky",
-- 	"Rocky",
-- 	"TallbirdNests",
-- }
-- for k, v in pairs(rocky_rooms) do
-- 	AddRoomPreInit(v, function(room)
-- 		complete_room(room)
-- 		room.contents.countprefabs.tp_pot_bird_egg_spawner = 1
-- 	end)
-- end

local atlar_rooms = {
	"BGSacredGround",
	"Altar",
	"Barracks",
	"Bishops",
	"Spiral",
	"BrokenAltar",
}
-- for k, v in pairs(atlar_rooms) do
-- 	AddRoomPreInit(v, function(room)
-- 		complete_room(room)
-- 		room.contents.countprefabs.tp_point_postman4 = 1
-- 	end)
-- end

-- AddLevelPreInit("SHIPWRECKED_DEFAULT", function(level)
-- 	level.set_pieces["TpBase"] = { 
-- 		count=1, 
-- 		tasks={ 
-- 			"IslandParadise", "VerdantMost", "AllBeige", 
-- 			"NoGreen B", "Florida Timeshare", "PiggyParadise",
-- 			"JungleDRockyland", "JungleDRockyMarsh",
-- 			"JungleDSavRock", "IslandJungleRockyDrop", 
-- 		} 
-- 	}
-- end)

local jungle_rooms = {
	"SampleRoom", "JungleClearing", "Jungle", 
	"JungleSparse", "JungleSparseHome", "JungleDense", 
	"JungleDenseHome", "JungleDenseMed", "JungleDenseBerries", 
	"JungleDenseMedHome", "JungleDenseVery", "JunglePigs", 
	"JunglePigGuards", "JungleBees", "JungleFlower", 
	"JungleSpidersDense", "JungleSpiderCity", 
	"JungleBamboozled", "JungleMonkeyHell", 
	"JungleCritterCrunch", "JungleDenseCritterCrunch", 
	"JungleFrogSanctuary", "JungleShroomin", 
	"JungleRockyDrop", "JungleEyeplant", "JungleGrassy", 
	"JungleSappy", "JungleEvilFlowers", 
	"JungleParrotSanctuary", "JungleNoBerry", 
	"JungleNoRock", "JungleNoMushroom", "JungleNoFlowers", 
	"JungleMorePalms", "JungleSkeleton", "SW_Graveyard",
}

for k, v in pairs(jungle_rooms) do
	AddRoomPreInit(v, function(room)
		complete_room(room)
		-- room.contents.countprefabs.tp_leif_spawner = 1
		-- room.contents.countprefabs.tp_boss_spawner = 1
		-- room.contents.countprefabs.tp_boss_spawner2 = 1
	end)
end

-- AddLevelPreInit("PORKLAND_DEFAULT", function(level)
-- 	level.set_pieces["TpBase"] = { 
-- 		count=1, 
-- 		tasks={
-- 			"Deep_rainforest",
-- 			"Deep_rainforest_2",
-- 			"Deep_rainforest_3",
-- 			"Deep_lost_ruins4",
-- 			"Deep_wild_ruins4",
-- 			"wild_ancient_ruins",
-- 		}
-- 	}	
-- end)

-- local rainforest_rooms = {
-- 	"BG_rainforest_base",
-- 	"rainforest_ruins",
-- 	"rainforest_lillypond",
-- 	"rainforest_pugalisk",
-- 	"rainforest_base_nobatcave",
-- }

local deeprainforest_rooms = {
	"BG_deeprainforest_base",
	"deeprainforest_spider_monkey_nest",
	"deeprainforest_flytrap_grove",
	"deeprainforest_fireflygrove",
	"deeprainforest_gas",
	"deeprainforest_gas_flytrap_grove",
	"deeprainforest_ruins_entrance",
	"deeprainforest_ruins_exit",
	"deeprainforest_anthill",
	"deeprainforest_mandrakeman",
	"deeprainforest_anthill_exit",
	"deeprainforest_base_nobatcave",
}

for k, v in pairs(deeprainforest_rooms) do
	AddRoomPreInit(v, function(room)
		complete_room(room)
		-- room.contents.countprefabs.tp_leif_spawner = 1
		-- room.contents.countprefabs.tp_boss_spawner = 1
		-- room.contents.countprefabs.tp_boss_spawner2 = 1
	end)
end