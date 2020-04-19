local require = GLOBAL.require
require("map/level") -- for LEVELTYPE
local LEVELTYPE = GLOBAL.LEVELTYPE
local Layouts = require("map/layouts").Layouts
local StaticLayout = require("map/static_layout")
local GROUND = GLOBAL.GROUND
GLOBAL.require("map/terrain")
GLOBAL.require("map/tasks")
GLOBAL.require("constants")
GLOBAL.require("map/lockandkey")
local LOCKS = GLOBAL.LOCKS
local KEYS = GLOBAL.KEYS
--世界
Layouts["StormWorld"] = StaticLayout.Get("map/static_layouts/fengbaoxingqiu", 
{
	start_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
	fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
	layout_position = GLOBAL.LAYOUT_POSITION.CENTER,
	disable_transform = true
})
Layouts["EndeWorld"] = StaticLayout.Get("map/static_layouts/buling_lilypad", 
{
	start_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
	fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
	layout_position = GLOBAL.LAYOUT_POSITION.CENTER,
	disable_transform = true
})
modimport("scripts/map/rooms/buling_rooms.lua")
modimport("scripts/map/tasks/buling_tasks.lua")
modimport("scripts/map/levels/buling_levels.lua")
