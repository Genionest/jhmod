local Rcp = require "extension.lib.rcp"
local RcpEnv = Sample.RcpEnv
local AssetMaster = Sample.AssetMaster

local function MakeRecipe(name, ingds, tab, tech)
    local atlas, image
    atlas, image = AssetMaster:GetImage(name)
    Rcp:AddRecipe(name, ingds, tab, tech, 
    7, name.."_placer", nil, atlas, image, RcpEnv)
end

-- 不是第一时间GetImage，所以不需要通过Uimg缓解析
AddPlayerPostInit(function(inst)
    local tab = {
        str = "base_menu", sort=12, icon="ak_menu_base.tex",
        icon_atlas = "images/inventoryimages/ak_menus.xml",
        crafting_station=true, priority=3,
        modname = "",
    }
    RECIPETABS[tab.str] = tab
    inst.tp_tabs = {}
    inst.tp_tabs.base = tab  -- 锚定tabs
    -- inst.components.builder:AddRecipeTab(tab)
    local atlas, image
    atlas, image = AssetMaster:GetImage("tp_furnace")
    Rcp:AddRecipe("tp_furnace", {
        {"redgem", 1},
        {"goldnugget", 10},
        {"cutstone", 3},
    }, tab, Rcp.tech.lost, 7, "tp_furnace_placer", nil, 
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_research_center")
    Rcp:AddRecipe("ak_research_center", {
        {"boards", 4},
    }, tab, Rcp.tech.science2, 7, "ak_research_center_placer", nil, 
    atlas, image, RcpEnv)
    
    atlas, image = AssetMaster:GetImage("ak_work_bench")
    Rcp:AddRecipe("ak_work_bench", {
        {"boards", 3},
        {"goldnugget", 2},
        {"twigs", 4},
    }, tab, Rcp.tech.science1, 7, "ak_work_bench_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_smithing_table")
    Rcp:AddRecipe("ak_smithing_table", {
        {"transistor", 4},
        {"gears", 2},
        {"cutstone", 4},
    }, tab, Rcp.tech.lost, 7, "ak_smithing_table_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_smithing_table")
    Rcp:AddRecipe("ak_smithing_table", {
        {"transistor", 4},
        {"gears", 2},
        {"cutstone", 4},
    }, tab, Rcp.tech.lost, 7, "ak_smithing_table_placer", nil,
    atlas, image, RcpEnv)

    MakeRecipe("tp_desk", {
        {"boards", 4},
    }, tab, Rcp.tech.lost)

    MakeRecipe("tp_lab", {
        {"livinglog", 1},
        {"goldnugget", 3},
        {"cutstone", 2},
    }, tab, Rcp.tech.lost)

    MakeRecipe("ak_food_compressor", {
        {"charcoal", 3},
        {"cutstone", 1},
        {"transistor", 1},
    }, tab, Rcp.tech.lost)

    MakeRecipe("ak_level_eraser", {
        {"purplegem", 1},
        {"cutstone", 2},
        {"tp_alloy", 1, AssetMaster:GetImage("tp_alloy")},
    }, tab, Rcp.tech.lost)

    MakeRecipe("tp_rook", {
        {"tp_engine", 2, AssetMaster:GetImage("tp_engine")},
        {"horn", 1}
    }, tab, Rcp.tech.lost)

    MakeRecipe("tp_coal_beast", {
        {"tp_engine", 2, AssetMaster:GetImage("tp_engine")},
        {"meat", 4},
        {"boards", 4},
    }, tab, Rcp.tech.lost)

    MakeRecipe("tp_fant", {
        {"tp_engine", 2, AssetMaster:GetImage("tp_engine")},
        {"trunk_summer", 1},
        {"goldenpickaxe", 1},
        {"goldenshovel", 1},
    }, tab, Rcp.tech.lost)
    -- power
    local tab = {
        str = "power_menu", sort=12, icon="ak_menu_power.tex",
        icon_atlas = "images/inventoryimages/ak_menus.xml",
        crafting_station=true, priority=3,
        modname = "",
    }
    RECIPETABS[tab.str] = tab
    inst.tp_tabs.power = tab

    atlas, image = AssetMaster:GetImage("ak_manual_generator")
    Rcp:AddRecipe("ak_manual_generator", {
        {"transistor", 2},
        {"boards", 2},
    }, tab, Rcp.tech.science1, 7, "ak_manual_generator_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_wood_generator")
    Rcp:AddRecipe("ak_wood_generator", {
        {"transistor", 2},
        {"cutstone", 2},
    }, tab, Rcp.tech.science1, 7, "ak_wood_generator_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_sun_generator")
    Rcp:AddRecipe("ak_sun_generator", {
        {"transistor", 4},
        {"thulecite", 4},
    }, tab, Rcp.tech.lost, 7, "ak_sun_generator_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_electric_wire")
    Rcp:AddRecipe("ak_electric_wire", {
        {"goldnugget", 2},
        {"cutstone", 1},
    }, tab, Rcp.tech.science1, 7, "firesuppressor_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_large_power_transformer")
    Rcp:AddRecipe("ak_large_power_transformer", {
        {"transistor", 2},
        {"cutstone", 3},
    }, tab, Rcp.tech.lost, 7, "firesuppressor_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_battery")
    Rcp:AddRecipe("ak_battery", {
        {"nitre", 1},
        {"cutstone", 2},
    }, tab, Rcp.tech.science1, 7, "ak_battery_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_smart_battery")
    Rcp:AddRecipe("ak_smart_battery", {
        {"gears", 1},
        {"nitre", 1},
        {"transistor", 2},
    }, tab, Rcp.tech.lost, 7, "ak_smart_battery_placer", nil,
    atlas, image, RcpEnv)
    -- util
    local tab = {
        str = "util_menu", sort=12, icon="ak_menu_util.tex",
        icon_atlas = "images/inventoryimages/ak_menus.xml",
        crafting_station=true, priority=3,
        modname = "",
    }
    RECIPETABS[tab.str] = tab
    inst.tp_tabs.util = tab

    atlas, image = AssetMaster:GetImage("ak_lamp")
    Rcp:AddRecipe("ak_lamp", {
        {"fireflies", 1},
        {"transistor", 1},
    }, tab, Rcp.tech.lost, 7, "ak_lamp_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_power_shutoff")
    Rcp:AddRecipe("ak_power_shutoff", {
        {"trap_teeth", 1},
        {"cutstone", 1},
    }, tab, Rcp.tech.lost, 7, "ak_power_shutoff_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_compost")
    Rcp:AddRecipe("ak_compost", {
        {"boards", 3},
        {"twigs", 4},
    }, tab, Rcp.tech.lost, 7, "ak_compost_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_triage_table")
    Rcp:AddRecipe("ak_triage_table", {
        {"gears", 1},
        {"boards", 3},
    }, tab, Rcp.tech.lost, 7, "ak_triage_table_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_farmer_station")
    Rcp:AddRecipe("ak_farmer_station", {
        {"fertilizer", 1},
        {"transistor", 2},
        {"cutstone", 3},
    }, tab, Rcp.tech.lost, 7, "ak_farmer_station_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_auto_harvester")
    Rcp:AddRecipe("ak_auto_harvester", {
        {"goldenaxe", 1},
        {"transistor", 2},
        {"cutstone", 3},
    }, tab, Rcp.tech.lost, 7, "ak_auto_harvester_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_loader")
    Rcp:AddRecipe("ak_loader", {
        {"goldenshovel", 1},
        {"transistor", 2},
        {"cutstone", 3},
    }, tab, Rcp.tech.lost, 7, "ak_loader_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_park_sign")
    Rcp:AddRecipe("ak_park_sign", {
        {"boards", 1},
    }, tab, Rcp.tech.lost, 7, "ak_park_sign_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_farm_brick")
    Rcp:AddRecipe("ak_farm_brick", {
        {"boards", 1},
        {"poop", 1},
    }, tab, Rcp.tech.lost, 7, "ak_farm_brick_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_clear_station")
    Rcp:AddRecipe("ak_clear_station", {
        {"plantmeat", 1},
        {"boards", 2},
        {"transistor", 2},
    }, tab, Rcp.tech.lost, 7, "ak_clear_station_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_robot_worker")
    Rcp:AddRecipe("ak_robot_worker", {
        {"goldenpickaxe", 1},
        {"transistor", 2},
        {"cutstone", 3},
    }, tab, Rcp.tech.lost, 7, "ak_robot_worker_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_transporter")
    Rcp:AddRecipe("ak_transporter", {
        {"transistor", 1},
        {"boards", 2},
        {"rope", 1},
    }, tab, Rcp.tech.lost, 7, "ak_transporter_placer", nil,
    atlas, image, RcpEnv)

    atlas, image = AssetMaster:GetImage("ak_transport_center")
    Rcp:AddRecipe("ak_transport_center", {
        {"gears", 1},
        {"lightninggoathorn", 2},
        {"cutstone", 4},
    }, tab, Rcp.tech.lost, 7, "ak_transport_center_placer", nil,
    atlas, image, RcpEnv)

end)