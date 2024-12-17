local EntUtil = require "extension.lib.ent_util"
local Kit = require "extension.lib.wargon"
local cooked_food_dict = require("preparedfoods")
local FxManager = Sample.FxManager
local BuffManager = Sample.BuffManager

local cooked_food_list = {}
for k, v in pairs(cooked_food_dict) do
    table.insert(cooked_food_list, k)
end

local DataManager = require "extension.lib.data_manager"
local FoodEffectManager = DataManager("FoodEffectManager")

local EffectData = Class(function(self)
end)

--[[
创建食物效果类  
(EffectData) 返回此类  
id (string)名称  
eat (func)食用触发函数，function(self, inst, cmp, id, food)inst是食用者，cmp是eater组件  
desc (func/str)描述函数或文字，function(self, id, food)  
data (table)相关数据  
]]
local function Effect(id, eat, desc, data)
    local self = EffectData()
    self.id = id
    self.eat = eat
    self.data = data
    self.desc = desc
    return self
end

function EffectData:GetId()
    return self.id
end

--[[
Effect("", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
end, 
function(self, id, food)
end, {}, 1, 1),
]]


local effects = {
}

FoodEffectManager:AddDatas(effects, "default")
-- FoodEffectManager:AddDatas(bad, "bad")

Sample.FoodEffectManager = FoodEffectManager