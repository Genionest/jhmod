name = "Sample"
author = "wargon"
version = "3.002"
description = name.." v"..version.." Test"
forumthread = ""
priority = -5
api_version = 6
-- modinfo可不能加密
icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

dont_starve_compatible = false
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true

local alpha_set = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local alpha_options = {}
local A = 97
for i = 0, 25 do
    alpha_options[i+1] = {
        description = alpha_set[i+1],
        data = A+i,
    }
end
local new_set = {"RSHIFT", "LSHIFT", "RCTRL", "LCTRL", "RALT", "LALT"}
local CTRL = 303
for i = 0, 5 do
    alpha_options[i+26] = {
        description = new_set[i+1],
        data = CTRL+i,
    }
end

configuration_options = {
    {
        name = "hands_key",
        label = "武器技能键",
        options = alpha_options,
        default = 114,  -- r KEY_R
    },
    {
        name = "body_key",
        label = "护甲技能键",
        options = alpha_options,
        default = 103,  -- g KEY_G
    },
    {
        name = "head_key",
        label = "头盔技能键",
        options = alpha_options,
        default = 122,  -- z KEY_Z
    },
    {
        name = "hard",
        label = "难度",
        options = {
            {description = "简单", data = 1},
            {description = "普通", data = 2},
            {description = "困难", data = 3},
            -- {description = "极难", data = 4},
        },
        default = 2,
    },
    {
        name = "info_pos",
        label = "信息位置",
        options = {
            {description = "左下", data=1},
            {description = "跟随", data=2},
        },
        default = 1,
    },
    {
        name = "extra_info",
        label = "更多信息",
        options = {
            {description = "关闭", data=false},
            {description = "显示", data=true},
        },
        default = true,
    },
    {
        name = "mouse_info",
        label = "鼠标信息",
        options = {
            {description = "关闭", data=false},
            {description = "显示", data=true},
        },
        default = false,
    },
    {
        name = "health_bar",
        label = "显示血条",
        options = {
            {description = "显示", data=true},
            {description = "关闭", data=false},
        },
        default = true,
    },
    -- {
    --     name = "info_complex",
    --     label = "详细信息",
    --     options = {
    --         {description = "是", data=true},
    --         {description = "否", data=false},
    --     },
    --     default = false,
    -- },
}