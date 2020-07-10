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

AddRoomPreInit("PigVillage", function(room)
	room.contents.countprefabs.tp_werepig_king = 1
end)

-- AddRoomPreInit("BeefalowPlain", function(room)
-- 	room.contents.countprefabs = {
-- 		tp_sign_rider = 1,
-- 	}
-- end)