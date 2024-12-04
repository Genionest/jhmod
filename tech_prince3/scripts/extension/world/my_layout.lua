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

Layouts["TpBase"] = {
	type = LAYOUT.STATIC,
	start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
	fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
	layout_position = LAYOUT_POSITION.CENTER,
	disable_transform = true,
	ground_types = {GROUND.ROAD, GROUND.CARPET},
	ground = {
		{1, 1, 1, 1, 1, 1, 1, 1},
		{1, 2, 2, 2, 2, 2, 2, 1},
		{1, 2, 2, 2, 2, 2, 2, 1},
		{1, 2, 2, 2, 2, 2, 2, 1},
		{1, 2, 2, 2, 2, 2, 2, 1},
		{1, 2, 2, 2, 2, 2, 2, 1},
		{1, 2, 2, 2, 2, 2, 2, 1},
		{1, 1, 1, 1, 1, 1, 1, 1},
	},
	count = {},
	layout = {
		tp_campfire = {
			{x=0, y=0, properties={data={ak_editor={text="FireShrine"}}}},
		},
		tp_blacksmith = {
			{x=0, y=1-3/8},
		},
		tp_furnace = {
			{x=0, y=1},
		},
		tp_egg_stealer = {
			{x=-1+3/8, y=0},
		},
		ak_research_center = {
			{x=-1, y=0},
		},
		tp_firekeeper = {
			{x=1-3/8, y=0},
		},
		ak_level_eraser = {
			{x=1, y=0}
		},
		ak_electric_wire = {
			{x=1, y=1}
		},
		ak_manual_generator = {
			{x=1, y=-1}
		},
		wall_pig_ruins_repaired = {
			-- 坐标不是墙体中心位置, 而是左上角
			{x=2.5, y=2.5},
			{x=2.5, y=-2.5},
			{x=-2.5, y=-2.5},
			{x=-2.5, y=2.5},
		},
		wall_pig_ruins = {},
	}
}
for i = -12, 12, 2 do
	local idx = i * .125
	table.insert(Layouts["TpBase"].layout.wall_pig_ruins, {x=2.5, y=idx})
	table.insert(Layouts["TpBase"].layout.wall_pig_ruins, {x=idx, y=2.5})
	table.insert(Layouts["TpBase"].layout.wall_pig_ruins, {x=-2.5, y=idx})
	table.insert(Layouts["TpBase"].layout.wall_pig_ruins, {x=idx, y=-2.5})
end
