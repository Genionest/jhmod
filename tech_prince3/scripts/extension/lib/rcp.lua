local AssetUtil = require "extension/lib/asset_util"

local Rcp = {
}

Rcp.tabs = {
    light = "LIGHT",
    town = "TOWN",  -- 建筑
    farm = "FARM",
    surival = "SURVIVAL",
    tool = "TOOLS",
    science = "SCIENCE",
    magic = "MAGIC",
    refine = "REFINE",
    war = "WAR",
    dress = "DRESS",
    ancient = "ANCIENT",
    nautical = "NAUTICAL",	-- 航海
    archaeology = "ARCHAEOLOGY",  -- 考古
    city = "CITY",
    obsidian = "OBSIDIAN",  -- 黑曜石
}

Rcp.tech = {
    none = "NONE",
    science1 = "SCIENCE_ONE",
    science2 = "SCIENCE_TWO",
    science3 = "SCIENCE_THREE",
    -- science9 = {SCIENCE=9},
    magic2 = "MAGIC_TWO",
    magic3 = "MAGIC_THREE",
    ancient2 = "ANCIENT_TWO",
    ancient3 = "ANCIENT_THREE",
    ancient4 = "ANCIENT_FOUR",
    obsidian = "OBSIDIAN_TWO",
    home = "HOME_TWO",
    city = "CITY",
    lost = "LOST",
}

Rcp.game_type = {
    "ROG", -- 001
    "SHIPWRECKED", -- 010
    {"ROG", "SHIPWRECKED"}, -- 011
    "PORKLAND", -- 100
    {"ROG", "PORKLAND"}, -- 101
    {"SHIPWRECKED", "PORKLAND"}, -- 110
    "COMMON", -- 111
}

--[[
创键Ingredient  
(Ingredient) 返回这个Ingredient  
item 物品名  
num 物品数量  
atlas (string)图片资源1,可以为nil  
image (string)图片资源2，可以为nil  
env (table)环境，由它携带Ingredient  
]]
function Rcp:CreateIngd(item, num, atlas, image, env)
    assert(type(item)=="string", string.format("argument \"item\"(%s) must be string.", tostring(item)))
    assert(type(num)=="number", string.format("argument \"num\"(%s) must be number.", tostring(num)))

    local ingd = env.Ingredient(item, num, atlas)
    -- 需要其他地方帮助修复
    ingd.fix_image = image
    return ingd
end

--[[
创造Ingredient列表  
(table) 返回这个列表
ingds 特定列表{{"a", 1}, {"b", 1}}  
env (table)环境，由它携带Ingredient  
]]
function Rcp:CreateIngds(ingds, env)
    local ingd_t = {}
    for k, v in pairs(ingds) do
        local ingd = self:CreateIngd(v[1], v[2], v[3], v[4], env)
        assert(ingd:is_a(env.Ingredient), string.format("variable \"ingd\"(%s) is not Ingredient.", tostring(ingd)))

        table.insert(ingd_t, ingd)
    end
    return ingd_t
end

--[[
用于传入Rcp.AddRecipe里作为ingds参数  
]]
Rcp.Ingds = Class(function(self, ingds)
    self.ingds = ingds
end)

--[[
获取材料(Ingredient)列表  
(table) 返回这个列表
]]
function Rcp.Ingds:GetIngds()
    local ingd_t = Rcp:CreateIngds(self.ingds)
    return ingd_t
end

--[[
创建Recipe  
(Recipe) 返回这个Recipe  
name 建筑名  
ingds(table) 配方材料表，{{"a", 1}, {"b", 1}}  
tab 建造栏，可用Rcp.tabs获取  
tech 科技要求，可用Rcp.tech获取  
game_type 兼容的DLC,1(001)表ROG,3(011)表ROG|SW  
placer 建筑放置蓝本  
aquatic 为true表示水上建筑  
atlas (string)图片资源1  
image (string)图片资源2  
env (table)环境，由它携带RECIPE, TECH等  
]]
function Rcp:AddRecipe(name, ingds, tab, tech, game_type, placer, aquatic, atlas, image, env)
    assert(type(name)=="string", "arguments \"name\" must be string.")
    assert(type(ingds)=="table", "arguments \"Ringds\" must be Rcp.Ingds.")
    assert(type(game_type)=="number", "arguments \"game_type\" must be number.")
    assert(type(placer)=="string", "arguments \"placer\" must be string.")

    local ingredients = self:CreateIngds(ingds, env)
    tab = env.RECIPETABS[tab] or tab  -- 如果不在RECIPETABS里，就是新创建的tab
    tech = env.TECH[tech]
    local gtype
    if type(game_type) == "table" then
        gtype = {}
        for k, v in pairs(game_type) do
            table.insert(gtype, env.RECIPE_GAME_TYPE[v])
        end
    else
        gtype = env.RECIPE_GAME_TYPE[game_type]
    end
    local rcp = nil
    if aquatic then
        rcp = env.Recipe(name, ingredients, tab, tech, gtype, placer, nil, nil, nil, true, 4)
    else
        rcp = env.Recipe(name, ingredients, tab, tech, gtype, placer)
    end
    rcp.atlas = atlas
    rcp.image = image

	return rcp
end



return Rcp