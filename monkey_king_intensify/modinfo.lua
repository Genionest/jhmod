name = "Intensify Monkey King(test)"
description = "intensify monkey king"
author = "wargon"
version = "1.004"
forumthread = ""
icon_atlas = "modicon.xml"
icon = "modicon.tex"
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true

-- this setting is dumb; this mod is likely compatible with all future versions
api_version = 6

-- local key_tbl = {}
-- for i = 1, 26 do
-- 	key_tbl[i] = 97+i-1
-- end
-- local des_tbl = {}
-- for i = 1, 26 do
-- 	des_tbl[i] = 65+i-1
-- end
local alpha = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local key_list = {{description="no", data=0}}
for i =1, #alpha do
	key_list[i+1] = {description=alpha[i], data=97+i-1}
end
-- local function setOpts()
-- 	local tbl = {}
-- 	for i = 1, 26 do
-- 		tbl[i] = {description = string.char(des_tbl[i]), data = key_tbl[i]}
-- 	end
-- 	return tbl
-- end

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
		default = true,
	},

	{
		name = "else_enable",
		label = "其他能力",
		options = {
			{description = "启用", data = true},
			{description = "禁用", data = false},
		},
		default = true,
	},

	{
		name = "morph_key",
		label = "七十二变",
		options = key_list,
		default = 0,
	},

	{
		name = "cloud_key",
		label = "腾云驾雾",
		options = key_list,
		default = 0,
	},

	{
		name = "spawn_key",
		label = "猴子猴孙",
		options = key_list,
		default = 0,
	},

	{
		name = "back_key",
		label = "回来吧",
		options = key_list,
		default = 0,
	},
}
