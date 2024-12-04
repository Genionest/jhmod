local AssetMaster = Sample.AssetMaster
local Util = require "extension.lib.wg_util"
local AssetUtil = require "extension/lib/asset_util"
local WgShelf = require "extension/lib/wg_shelf"

local IngdData = Class(function(self)
end)

--[[
工作台配方材料  
name (string)名字  
num (number)数量  
Uimg (Img)图片资源类，为nil则从资源管理器自动获取  
]]
local function Ingd(name, num, Uimg)
    local self = IngdData()
    self.name = name
    self.num = num
    if Uimg == nil then
        if AssetMaster:HasAssetData(name) then
            Uimg = AssetMaster:GetUimg(name)
        else
            Uimg = AssetUtil:MakeImg(name)
        end
    end
    self.Uimg = Uimg
    
    return self
end

function IngdData:GetName()
    return self.name
end

function IngdData:GetScreenName()
    return Util:GetScreenName(self.name)
end

function IngdData:GetImage()
    return AssetUtil:GetImage(self.Uimg)
end

function IngdData:GetStack()
    return self.num
end

-- 需要的api
-- GetImage 获取图片
-- GetName 获取预制物名
-- GetScreenName 获取名字
-- GetDescription 获取描述
-- GetIngds 获取材料表（包含材料名，图片工具，堆叠数）
-- GetStack 获取堆叠数
-- GetFn 获取点击函数

local RecipeData = Class(function(self)
end)

--[[
工作台配方  
name (string)名字  
ingds (table{WBIngd})工作台配方材料列表  
Uimg (Img)图片资源类，为nil则从资源管理器自动获取  
stack (number)制造完成后的堆叠数量  
]]
local function Recipe(name, ingds, Uimg, stack)
    local self = RecipeData()
    self.name = name
    self.ingds = ingds
    assert(ingds[1]:is_a(IngdData), string.format("ingds of Recipe(%s) must be \"IngdData\"", name))
    if Uimg == nil then
        if AssetMaster:HasAssetData(name) then
            Uimg = AssetMaster:GetUimg(name)
        else
            Uimg = AssetUtil:MakeImg(name)
        end
    end
    self.Uimg = Uimg
    self.stack = stack or 1
    self.fn = function(widget)
        if widget.machine.components.wg_workbench then
            widget.machine.components.wg_workbench:DoWork(
                self.name, self.ingds, self.stack
            )
            widget:SetSpinnerInfo()
        end
    end

    return self
end

function RecipeData:GetImage()
    return AssetUtil:GetImage(self.Uimg)
end

function RecipeData:GetName()
    return self.name
end

function RecipeData:GetScreenName()
    return Util:GetScreenName(self.name)
end

function RecipeData:GetDescription()
    return Util:GetDescription(self.name, true)
end

function RecipeData:GetStack()
    return self.stack
end

function RecipeData:GetFn()
    return self.fn
end

--[[
返回Ingd列表  
(table{Ingd}) 返回这个列表  
]]
function RecipeData:GetIngds()
    return self.ingds
end

local RecipePage = Class(function(self, name, recipes)
    self.name = name
    self.recipes = recipes
end)

local RecipeBook = Class(function(self, name, pages)
    self.name = name
    self.pages = pages
end)


local WBRecipeManager = {
    shelfs = {}
}

--[[
获取工作台配方容器  
(WgShelf)返回这个容器  
name (string)工作台名  
]]
function WBRecipeManager:GetRecipeShelf(name)
    return self.shelfs[name]
end

--[[
添加工作台配方容器  
name (string)容器所属的工作台名  
book (WgShelf)添加的容器  
]]
function WBRecipeManager:AddRecipeShelf(name, shelf)
    self.shelfs[name] = shelf
end

--[[
添加工作台配方书列表到配方管理器中  
workbench_books(table{RecipeBook})配方书列表  
manager(WBRecipeManager)配方管理器  
]]
local function AddWBRecipes(workbench_books, manager)
    for _, book in pairs(workbench_books) do
        local root_shelf = WgShelf(Util:GetScreenName(book.name), 3)
        for _, page in pairs(book.pages) do
            local shelf = WgShelf(page.name, 5)
            for _, recipe in pairs(page.recipes) do
                shelf:AddItem(recipe)
            end
            root_shelf:AddItem(shelf)
        end
        -- 为图鉴ui准备的api
        root_shelf.GetSpinnerInfo = function(self, machine, owner)
            if machine.components.wg_workbench then
                local product = machine.components.wg_workbench.product
                if product then
                    local Uimg = machine.components.wg_workbench:GetProductUimg()
                    
                    return Uimg
                end
            end
        end
        manager:AddRecipeShelf(book.name, root_shelf)
    end
end

local workbench_books = {}

table.insert(workbench_books, RecipeBook("ak_work_bench", {
    RecipePage("物品", {
        -- Recipe("tp_advance_chip", {
        --     Ingd("tp_epic", 2),
        --     Ingd("ak_ssd", 4),
        --     Ingd("deerclops_eyeball", 1),
        -- }),
        -- Recipe("tp_advance_chip2", {
        --     Ingd("tp_advance_chip", 2),
        --     Ingd("tp_alloy_great", 1),
        --     Ingd("minotaurhorn", 1),
        --     Ingd("yellowgem", 1),
        --     Ingd("orangegem", 1),
        --     Ingd("greengem", 1),
        -- }),
        -- Recipe("tp_mult_tool", {
        --     Ingd("rope", 1),
        --     Ingd("silk", 2),
        --     Ingd("goldnugget", 2),
        --     Ingd("twigs", 4+1+1+2+2+4),
        --     Ingd("flint", 1+3+2+2),
        -- }),
        -- Recipe("ak_fix_powder", {
        --     Ingd("goldnugget", 4),
        --     Ingd("flint", 4),
        -- }, nil, 4),
        Recipe("ak_dimensional", {
            Ingd("waxpaper", 1),
            Ingd("transistor", 1),
        }),
        Recipe("ak_candy_bag", {
            Ingd("butterflywings", 4),
            Ingd("taffy", 1),
            Ingd("gears", 1),
        }),
        Recipe("tp_engine", {
            Ingd("gears", 2),
            Ingd("transistor", 2),
        }),
    }),
    RecipePage("装备", {
        Recipe("tp_spear_lance", {
            Ingd("goldnugget", 1),
            Ingd("rope", 1),
            Ingd("twigs", 1),
        }),
        Recipe("tp_spear_night", {
            Ingd("nightmarefuel", 1),
            Ingd("rope", 1),
            Ingd("twigs", 1),
        }),
        Recipe("tp_spear_sharp", {
            Ingd("boneshard", 1),
            Ingd("flint", 1),
            Ingd("rope", 1),
            Ingd("twigs", 1),
        }),
        Recipe("tp_spear_enchant", {
            Ingd("goldnugget", 1),
            Ingd("nightmarefuel", 1),
            Ingd("rope", 2),
            Ingd("twigs", 2),
        }),
        Recipe("tp_spear_conqueror", {
            Ingd("spear", 1),
            Ingd("redgem", 1),
            Ingd("goldnugget", 3),
        }),
        Recipe("tp_spear_resource", {
            Ingd("cutgrass", 4),
            Ingd("flint", 1),
            Ingd("rope", 1),
            Ingd("twigs", 1),
        }),
        -- armor
        Recipe("tp_armor_health", {
            Ingd("bandage", 1),
            Ingd("log", 4),
            Ingd("rope", 2),
        }),
        Recipe("tp_armor_cloak", {
            Ingd("cutreeds", 4),
            Ingd("cutgrass", 10),
            Ingd("twigs", 2),
        }),
        Recipe("tp_armor_strong", {
            Ingd("marble", 10),
            Ingd("rope", 2),
            Ingd("log", 8),
        }),
        -- helm
        Recipe("tp_helm_combat", {
            Ingd("boneshard", 1),
            Ingd("pigskin", 1),
            Ingd("rope", 1),
        }),
        Recipe("tp_helm_baseball", {
            Ingd("goldnugget", 2),
            Ingd("pigskin", 1),
            Ingd("rope", 1),
        }),
        Recipe("tp_hat_winter", {
            Ingd("rope", 1),
            Ingd("twigs", 1),
            Ingd("acorn", 3),
        }),
        Recipe("tp_hat_dodge", {
            Ingd("rope", 1),
            Ingd("twigs", 1),
            Ingd("feather_robin_winter", 3),
        }),
    }),
}))

table.insert(workbench_books, RecipeBook("ak_research_center", {
    RecipePage("蓝图", {
        -- Recipe("tp_desk_bp", {Ingd("ak_ssd", 1)}),
        -- Recipe("tp_lab_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_research_center_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_sun_generator_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_large_power_transformer_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_smart_battery_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_lamp_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_power_shutoff_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_food_compressor_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_compost_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_triage_table_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_farmer_station_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_auto_harvester_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_loader_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_park_sign_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_farm_brick_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_clear_station_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_robot_worker_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_transporter_bp", {Ingd("ak_ssd", 1)}),
        Recipe("ak_transport_center_bp", {Ingd("ak_ssd", 1)}),
    }),
}))

table.insert(workbench_books, RecipeBook("tp_furnace", {
    RecipePage("物品", {
        Recipe("tp_alloy", {
            Ingd("bluegem", 4),
        }, nil, 4),
        Recipe("tp_alloy_red", {
            Ingd("redgem", 4),
        }, nil, 4),
        Recipe("tp_alloy_enchant", {
            Ingd("redgem", 1),
            Ingd("bluegem", 1),
            Ingd("purplegem", 1),
        }),
        Recipe("tp_cane_dodge", {
            Ingd("cane", 1),
            Ingd("thulecite", 4),
            Ingd("goatmilk", 4),
        })
    }),
    RecipePage("装备", {
        Recipe("tp_spear_ice", {
            Ingd("spear", 1),
            Ingd("bluegem", 1),
            Ingd("tp_alloy", 1),
        }),
        Recipe("tp_spear_fire", {
            Ingd("spear", 1),
            Ingd("redgem", 1),
            Ingd("tp_alloy", 1),
        }),
        Recipe("tp_spear_thunder", {
            Ingd("spear", 1),
            Ingd("purplegem", 1),
            Ingd("tp_alloy", 1),
        }),
        Recipe("tp_spear_speed", {
            Ingd("spear", 1),
            Ingd("cactus_meat", 1),
            Ingd("tp_alloy", 1),
        }),
        Recipe("tp_spear_hurt", {
            Ingd("spear", 1),
            Ingd("healingsalve", 1),
            Ingd("tp_alloy", 1)
        }),
        Recipe("tp_flash_knife", {
            Ingd("orangestaff", 1),
            Ingd("flint", 4),
            Ingd("tp_alloy", 4),
        }),
        -- armor
        Recipe("tp_armor_ice", {
            Ingd("armorwood", 1),
            Ingd("bluegem", 1),
            Ingd("tp_alloy_red", 1),
        }),
        Recipe("tp_armor_fire", {
            Ingd("armorwood", 1),
            Ingd("redgem", 1),
            Ingd("tp_alloy_red", 1),
        }),
        Recipe("tp_cloak_resist", {
            Ingd("armorgrass", 1),
            Ingd("cactus_meat", 1),
            Ingd("tp_alloy_red", 1),
        }),
        Recipe("tp_cloak_food", {
            Ingd("armorgrass", 1),
            Ingd("charcoal", 3),
            Ingd("tp_alloy_red", 1),
        }),
        Recipe("tp_cloak_frozen", {
            Ingd("armorgrass", 1),
            Ingd("ice", 4),
            Ingd("tp_alloy_red", 1),
        }),
        -- helm
        Recipe("tp_helm_cool", {
            Ingd("footballhat", 1),
            Ingd("icehat", 1),
            Ingd("tp_alloy", 1),
        }),
        Recipe("tp_helm_warm", {
            Ingd("footballhat", 1),
            Ingd("beefalohat", 1),
            Ingd("tp_alloy", 1),
        }),
    })
}))

table.insert(workbench_books, RecipeBook("ak_smithing_table", {
    RecipePage("物品", {
        Recipe("tp_alloy_great", {
            Ingd("purplegem", 1),
            Ingd("tp_epic", 1),
            Ingd("tp_alloy", 1),
            Ingd("tp_alloy_red", 1),
        }),
    }),
    RecipePage("装备", {
        Recipe("tp_spear_poison", {
            Ingd("greengem", 2),
            Ingd("livinglog", 4),
            Ingd("thulecite", 6),
            Ingd("tp_alloy_great", 1),
        }),
        Recipe("tp_spear_blood", {
            Ingd("orangegem", 2),
            Ingd("livinglog", 4),
            Ingd("thulecite", 6),
            Ingd("tp_alloy_great", 1),
        }),
        Recipe("tp_spear_shadow", {
            Ingd("yellowgem", 2),
            Ingd("livinglog", 4),
            Ingd("thulecite", 6),
            Ingd("tp_alloy_great", 1),
        }),
        Recipe("tp_forest_dragon", {
            Ingd("tp_forest_dragon_bp", 1),
            Ingd("acorn", 20),
            Ingd("livinglog", 6),
            Ingd("greengem", 2),
            Ingd("tp_alloy_great", 2),
        }),
        -- armor
        Recipe("tp_armor_ancient", {
            Ingd("purplegem", 2),
            Ingd("armorruins", 1),
            Ingd("nightmarefuel", 4),
            Ingd("thulecite", 6),
            Ingd("tp_alloy_great", 1),
        }),
        -- helm
        Recipe("tp_helm_ancient", {
            Ingd("redgem", 2),
            Ingd("ruinshat", 1),
            Ingd("nightmarefuel", 4),
            Ingd("thulecite", 6),
            Ingd("tp_alloy_great", 1),
        }),
    })
}))

table.insert(workbench_books, RecipeBook("tp_desk", {
    RecipePage("卷轴", {
        Recipe("tp_scroll_sleep", {
            Ingd("papyrus", 1),
            Ingd("honey", 1),
            Ingd("nightmarefuel", 1),
        }),
        Recipe("tp_scroll_grow", {
            Ingd("papyrus", 1),
            Ingd("honey", 1),
            Ingd("seeds", 2),
        }),
        Recipe("tp_scroll_lightning", {
            Ingd("papyrus", 1),
            Ingd("honey", 1),
            Ingd("redgem", 1),
        }),
        Recipe("tp_scroll_bird", {
            Ingd("papyrus", 1),
            Ingd("honey", 1),
            Ingd("feather_robin", 1),
        }),
        Recipe("tp_scroll_tentacle", {
            Ingd("papyrus", 1),
            Ingd("honey", 1),
            Ingd("tentaclespots", 1),
        }),
        Recipe("tp_scroll_volcano", {
            Ingd("papyrus", 1),
            Ingd("honey", 1),
            Ingd("obsidian", 1),
        }),
    }),
}))

table.insert(workbench_books, RecipeBook("tp_lab", {
    RecipePage("物品", {
        Recipe("tp_potion_health", {
            Ingd("red_cap", 4),
            Ingd("ice", 2),
        }, nil, 2),
        Recipe("tp_potion_mana", {
            Ingd("blue_cap", 1),
            Ingd("ice", 2),
        }, nil, 2),
        Recipe("tp_potion_brave", {
            Ingd("green_cap", 2),
            Ingd("ice", 2),
        }, nil, 2),
        Recipe("tp_plantable_reeds", {
            Ingd("cutreeds", 1),
            Ingd("seeds", 1),
            Ingd("spoiled_food", 1),
        }),
        Recipe("tp_plantable_reeds_water", {
            Ingd("cutreeds", 1),
            Ingd("seeds", 1),
            Ingd("spoiled_food", 1),
        }),
        Recipe("tp_plantable_flower_cave", {
            Ingd("lightbulb", 1),
            Ingd("seeds", 1),
            Ingd("spoiled_food", 1),
        }),
        Recipe("tp_plantable_grass_water", {
            Ingd("cutgrass", 1),
            Ingd("seeds", 1),
            Ingd("spoiled_food", 1),
        }),
        Recipe("tp_plantable_mangrove", {
            Ingd("log", 1),
            Ingd("seeds", 1),
            Ingd("spoiled_food", 1),
        }),
    })
}))

-- table.insert(workbench_books, RecipeBook("ak_research_center_wilson", {
--     RecipePage("物品", {
--         Recipe("tp_spear_speed2", {
--             Ingd("tp_spear_speed", 1),
--             Ingd("cane", 1),
--             Ingd("livinglog", 2),
--             Ingd("tp_alloy_red", 1),
--         }),
--         Recipe("tp_spear_speed3", {
--             Ingd("greengem", 1),
--             Ingd("livinglog", 3),
--             Ingd("tp_spear_speed2", 1),
--             Ingd("tp_alloy_blue", 1),
--         }),
--         Recipe("tp_pack_rabbit", {
--             Ingd("ak_dimensional", 1),
--             Ingd("twigs", 4),
--             Ingd("manrabbit_tail", 1),
--         }),
--         Recipe("ak_ornament_plain1", {
--             Ingd("tp_alloy_red", 1),
--             Ingd("butterflymuffin", 1),
--         }),
--         Recipe("tp_scroll_templar", {
--             Ingd("papyrus", 1),
--             Ingd("tp_alloy", 1),
--             Ingd("tp_spear_lance", 4),
--         }),
--         Recipe("tp_rook_bp", {Ingd("ak_ssd", 1)}),
--     }),
-- }))

-- table.insert(workbench_books, RecipeBook("ak_research_center_wathgrithr", {
--     RecipePage("物品", {
--         Recipe("tp_spear_conqueror2", {
--             Ingd("tp_spear_conqueror", 1),
--             Ingd("spear_wathgrithr", 1),
--             Ingd("tentaclespots", 2),
--         }),
--         Recipe("tp_spear_conqueror3", {
--             Ingd("tp_spear_conqueror2", 1),
--             Ingd("thulecite", 1),
--             Ingd("wormlight", 1),
--             Ingd("nightmarefuel", 6),
--         }),
--         Recipe("tp_pack_beefalo", {
--             Ingd("ak_dimensional", 1),
--             Ingd("beefalowool", 3),
--             Ingd("pigskin", 1),
--         }),
--         Recipe("ak_ornament_plain9", {
--             Ingd("horn", 1),
--             Ingd("goldnugget", 10),
--             Ingd("turkeydinner", 1),
--         }),
--         Recipe("tp_scroll_rider", {
--             Ingd("papyrus", 1),
--             Ingd("honey", 1),
--             Ingd("saddle_basic", 1),
--         }),
--         Recipe("tp_coal_beast_bp", {Ingd("ak_ssd", 1)}),
--     }),
-- }))

-- table.insert(workbench_books, RecipeBook("ak_research_center_wickerbottom", {
--     RecipePage("物品", {
--         Recipe("tp_forest_dragon_bp", {Ingd("ak_ssd", 1)}),
--         -- Recipe("tp_forest_dragon", {
--         --     Ingd("acorn", 40),
--         --     Ingd("livinglog", 3),
--         --     Ingd("tp_epic", 1),
--         --     Ingd("ak_ssd", 1),
--         --     Ingd("greengem", 1),
--         -- }),
--         Recipe("tp_forest_dragon2", {
--             Ingd("tp_forest_dragon", 1),
--             Ingd("pinecone", 60),
--             Ingd("seeds", 60),
--             Ingd("tp_alloy", 4),
--             Ingd("tp_alloy_red", 4),
--             Ingd("greengem", 1),
--         }),
--         Recipe("tp_forest_dragon3", {
--             Ingd("tp_forest_dragon2", 1),
--             Ingd("red_cap", 40),
--             Ingd("blue_cap", 40),
--             Ingd("green_cap", 40),
--             Ingd("tp_alloy_great", 2),
--             Ingd("greengem", 1),
--         }),
--         Recipe("tp_pack_smallbird", {
--             Ingd("ak_dimensional", 1),
--             Ingd("twigs", 4),
--             Ingd("tallbirdegg", 1),
--         }),
--         Recipe("ak_ornament_plain3", {
--             Ingd("lantern", 1),
--             Ingd("fireflies", 1),
--             Ingd("stuffedeggplant", 1),
--         }),
--         Recipe("tp_scroll_harvest", {
--             Ingd("papyrus", 1),
--             Ingd("honey", 1),
--             Ingd("shovel", 1),
--         }),
--         Recipe("tp_fant_bp", {Ingd("ak_ssd", 1)}),
--     }),
-- }))

-- table.insert(workbench_books, RecipeBook("ak_research_center_wolfgang", {
--     RecipePage("物品", {
--         Recipe("tp_armor_strong2", {
--             Ingd("tp_armor_strong", 1),
--             Ingd("rocks", 40),
--             Ingd("nitre", 20),
--             Ingd("boneshard", 5),
--         }),
--         Recipe("tp_armor_strong3", {
--             Ingd("tp_armor_strong2", 1),
--             Ingd("slurtle_shellpieces", 3),
--             Ingd("amulet", 1),
--         }),
--         Recipe("tp_pack_crab", {
--             Ingd("ak_dimensional", 1),
--             Ingd("twigs", 4),
--             Ingd("mandrake", 1),
--         }),
--         Recipe("ak_ornament_plain2", {
--             Ingd("petals", 6),
--             Ingd("spidergland", 4),
--             Ingd("frogglebunwich", 1),
--         }),
--         -- Recipe("tp_scroll_harvest", {
--         --     Ingd("papyrus", 1),
--         --     Ingd("honey", 1),
--         --     Ingd("shovel", 1),
--         -- }),
--         -- Recipe("tp_fant_bp", {Ingd("ak_ssd", 1)}),
--     }),
-- }))

AddWBRecipes(workbench_books, WBRecipeManager)

-- return RecipeManager
Sample.WorkbenchRecipes = WBRecipeManager