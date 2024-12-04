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

local boss_tbl = {
    -- survival
    ["tp_templar"] = "Dig that rock",
    ["tp_sign_rider"] = "Great Plains",
    ["tp_hornet"] = "Beeeees!",
    ["tp_soul_student2"] = "Squeltch",
    ["tp_combat_lord4"] = "Forest hunters",
    ["tp_blue_warg"] = "Badlands",
    ["tp_werepig_king"] = "Speak to the king",
    -- cave
    ["tp_fake_knight"] = "Cavern",
    -- ["tp_red_warg"] = "RabbitsAndFungs",
    -- ["tp_werepig_king2"] = "BatCaves",
    ["tp_werepig_king2"] = "FungalBatCave",
    ["tp_werepig_king3"] = "TentacledCave",
    -- ["tp_werepig_king4"] = "SingleBatCaveTask",
    ["tp_werepig_king4"] = "RabbitsAndFungs",
    ["tp_werepig_king5"] = "FungalPlain",
    -- ruins
    ["tp_werepig_king6"] = "TheLabyrinth",
    ["tp_werepig_king7"] = "Residential",
    ["tp_werepig_king8"] = "Residential3",
    -- ["tp_werepig_king8"] = "Military",
    -- ["tp_werepig_king8"] = "Sacred",  -- 犀牛后面
    -- ["tp_soul_student"] = "Military2",  -- 不一定生成
    ["tp_soul_student"] = "SacredDanger",  -- 不一定生成
    ["tp_combat_lord"] = "Sacred2",  -- 不一定生成
}
for boss_name, task_name in pairs(boss_tbl) do
    Layouts[boss_name] = {
        type = LAYOUT.CIRCLE_EDGE,
        start_mask = PLACE_MASK.NORMAL,
        fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        layout_position = LAYOUT_POSITION.CENTER,
        ground_types = { GROUND.ROCKY },
        defs =
        {
            rocks = { boss_name .. "_room" },
        },
        count =
        {
            rocks = 1,
        },
        scale = 1.0,
    }
    -- 添加boss关卡
    AddRoom(boss_name, MakeSetpieceBlockerRoom(boss_name))
    -- 添加进地图里
    AddTaskPreInit(task_name, function(task)
        task.entrance_room = boss_name
    end)
end

