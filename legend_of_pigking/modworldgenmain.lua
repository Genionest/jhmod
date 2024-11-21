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

layouts["DefaultPigking"] = StaticLayout.Get("map/static_layouts/pig_island")

AddLevelPreInit("SURVIVAL_DEFAULT", function(level)
	level.overrides[1] = {"start_setpeice", "DefaultPlusStart"}
end)

AddRoomPreInit("PigKingdom", function(room)
	room.contents.countprefabs.tent = 1
	room.contents.countprefabs.orangestaff = 1
end)