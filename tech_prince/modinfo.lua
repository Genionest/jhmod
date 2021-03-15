name = "Tech Prince"
author = "wargon"
version = "1.103"
description = "Tech Prince"..version
forumthread = ""
priority = -5
api_version = 6

icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

dont_starve_compatible = false
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true

configuration_options = 
{

	{
		name = "language",
		label = "Language/语言",
		options = 
		{
			{description = "English", data=true},
			{description = "中文", data=false},
		},
		default = false,
	},

	{
		name = "difficulty",
		label = "Difficulty/难度",
		options = {
			{description = "Easy/简单", data=0},
			{description = "Hard/暴毙", data=1},
			-- {description = "", data=},
		},
		default = 0,
	},

	-- {
	-- 	name = "fast"
	-- 	label = "Fast/快速模式",
	-- 	options = {
	-- 		{description = "Enabled/启用", data=true},
	-- 		{description = "Disenabled/禁用", data=false},
	-- 	},
	-- 	default = false,
	-- },
}

--[[
local boss=c_find("tp_farm_pile");GetPlayer():set_pos(boss:GetPosition():Get())
]]