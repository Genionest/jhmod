name = "I'm PigKing"
author = "Wargon"
version = "0.004"
description = "I'm PigKing v"..version
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
		name = "pighouse",
		label = "PigHouse/猪人房",
		options = {
			{description = "1 day", data=1},
			{description = "2 day", data=2},
			{description = "3 day", data=3},
			{description = "4 day", data=4},
			{description = "5 day", data=5},
			{description = "6 day", data=6},
			{description = "7 day", data=7},
		},
		default = 4,
	},
	{
		name = "time",
		label = "Time/命令时长",
		options = {
			{description = "10 s", data=10},
			{description = "20 s", data=20},
			{description = "30 s", data=30},
			{description = "40 s", data=40},
		},
		default = 20,
	},
}

--[[
猪人晚上不会回家，
检查猪人房会把猪叫出来
猪人添加了两个技能：
雷霆一击：攻击时会射出光球，持续5s，冷却20s
神圣庇护：召唤一个护盾并处于无敌状态，持续5s，冷却20s
检查猪人时会显示这两个技能，点击即可触发（考验微操的时候到了）

第一章：惊现！饥荒大陆的另一位猪王
第二章：激战！海洋上的巨大妖怪
]]