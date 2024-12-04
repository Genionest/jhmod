local Util = require "extension.lib.wg_util"
local AssetUtil = require "extension/lib/asset_util"
local WgShelf = require "extension/lib/wg_shelf"

--[[
工作台配方材料  
name (string)名字  
num (number)数量  
Uimg (Img)图片资源类  
]]
local WBIngd = Class(function(self, name, num, Uimg)
    self.name = name
    self.num = num
    self.Uimg = Uimg
end)

function WBIngd:GetScreenName()
    return Util:GetScreenName(self.name)
end

function WBIngd:GetImage()
    return AssetUtil:GetImage(self.Uimg)
end

function WBIngd:GetStack()
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

--[[
工作台配方  
name (string)名字  
ingds (table{WBIngd})工作台配方材料列表  
Uimg (Img)图片资源类  
stack (number)制造完成后的堆叠数量  
]]
local WBRecipe = Class(function(self, name, ingds, Uimg, stack)
    self.name = name
    self.ingds = ingds
    self.Uimg = Uimg
    self.stack = stack or 1
    self.fn = function(widget)
        if widget.machine.components.wg_workbench then
            widget.machine.components.wg_workbench:DoWork(
                self.name, self.ingd, self.stack
            )
            widget:SetSpinnerInfo()
        end
    end
end)

function WBRecipe:GetImage()
    return AssetUtil:GetImage(self.Uimg)
end

function WBRecipe:GetName()
    return self.name
end

function WBRecipe:GetScreenName()
    return Util:GetScreenName(self.name)
end

function WBRecipe:GetDescription()
    return Util:GetDescription(self.name, true)
end

function WBRecipe:GetStack()
    return self.stack
end

function WBRecipe:GetFn()
    return self.fn
end

--[[
返回WBIngd列表  
(table{WBIngd}) 返回这个列表  
]]
function WBRecipe:GetIngds()
    return self.ingds
end

local WBRecipePage = Class(function(self, name, recipes)
    self.name = name
    self.recipes = recipes
end)

local WBRecipeBook = Class(function(self, name, pages)
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
workbench_books(table{WBRecipeBook})配方书列表  
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

local WBRcp = {
    WBIngd = WBIngd,
    WBRecipe = WBRecipe,
    WBRecipePage = WBRecipePage,
    WBRecipeBook = WBRecipeBook,
    WBRecipeManager = WBRecipeManager,
    AddWBRecipes = AddWBRecipes,
}

--[[
工作台配方图鉴页  
name (string)页标题  
recipes (table{WBRecipe})工作台配方图鉴列表  
]]
function WBRcp:MakePage(name, recipes)
    return WBRecipePage(name, recipes)
end

--[[
工作台配方图鉴
name (string)图鉴名  
pages (table{WBRecipePage})工作台配方图鉴页列表  
]]
function WBRcp:MakeBook(name, pages)
    return WBRecipeBook(name, pages)
end

return WBRcp