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
local Layouts = require("map/layouts").Layouts  

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

modimport("scripts/extension/world/place_room_boss.lua")
modimport("scripts/extension/world/my_layout.lua")
-- local fn = require "extension.world.my_layout"
-- fn(Layouts)

-- 添加无尽营火
for k, v in pairs({
	"Sinkhole",
	-- "GrassySinkhole",
	"PigKingdom",
	-- "Graveyard",
	"BeeClearing",
	"WalrusHut_Grassy",
	"Lightning",
	"PigVillage",
	"PondyGrass",
}) do
	AddRoomPreInit(v, function(room)
		complete_room(room)
		room.contents.countprefabs.tp_campfire = 1
		if room.contents.prefabdata == nil then
			room.contents.prefabdata = {}
		end
		room.contents.prefabdata.tp_campfire = {ak_editor={text=v}}
	end)
end

-- fire shrine
AddRoom("FireShrine", {
	colour = { r = .5, g = .8, b = .5, a = .50 },
	value = GROUND.GRASS,
	tags = { "ExitPiece", "Chester_Eyebone" },
	contents = {
		countstaticlayouts =
		{
			["TpBase"] = 1,
		},
		distributepercent = .275,
		distributeprefabs =
		{
			rock2 = .03,
			flower = 0.112,
			grass = 0.2, --raised from.2
			carrot_planted = 0.05,
			flint = 0.05,
			berrybush = 0.05,
			sapling = 0.2,
			evergreen = .05,
		},
	}
})
AddTaskPreInit("Make a pick", function(task)
	task.room_choices["FireShrine"] = 1
end)

AddLevelPreInit("SURVIVAL_DEFAULT", function(level)
	-- level.set_pieces.TpBase = {
	-- 	restrict_to="background", tasks={"Make a pick"}
	-- }
	table.insert(level.required_prefabs, "tp_firekeeper")
end)