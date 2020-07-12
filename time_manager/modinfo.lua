name = "Time Manager"
description = "Time Manager"
author = "wargon"
version = "1.000"

forumthread = ""

dst_compatible = true
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true
api_version = 6

icon_atlas = "modicon.xml"
icon = "modicon.tex"

local alpha = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local key_list = {}
for i =1, #alpha do
	key_list[i+1] = {description=alpha[i], data=97+i-1}
end

configuration_options = 
{

	{
		name = "key",
		label = "TimeManager",
		options = key_list,
		default = 18,
	},

	{
		name = "scale",
		label = "TimeScale",
		options = {
			{description="1", data=1},
			{description="1.5", data=1.5},
			{description="2", data=2},
			{description="3", data=3},
			{description="4", data=4},
		},
		default = 1.5,
	},

}
