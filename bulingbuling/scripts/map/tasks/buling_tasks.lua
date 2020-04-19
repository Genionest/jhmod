GLOBAL.require("map/lockandkey")
GLOBAL.require("map/tasks/island")
local LOCKS = GLOBAL.LOCKS
local KEYS = GLOBAL.KEYS
local GROUND = GLOBAL.GROUND
AddTask("WorldTask", {
	lock=GLOBAL.LOCKS.NONE,
	key_given=GLOBAL.KEYS.ISLAND5,
	room_choices={
		["BeachClear2"] = 1, --was 5
		--["WorldRoom2"] = 5,
		--["WorldRoom4"] = 1,
		--["WorldRoom5"] = 15,
	},
	room_bg=GLOBAL.GROUND.BEACH,
	--background_room={"BeachSand", "BeachGravel", "BeachUnkept", "Jungle"},
	colour={r=1,g=1,b=0,a=1}
})
AddTask("WorldTask", {
	lock=GLOBAL.LOCKS.NONE,
	key_given=GLOBAL.KEYS.ISLAND1,
	room_choices={
		["BeachClear2"] = 1, 
	},
	room_bg=GLOBAL.GROUND.BEACH,
	colour={r=1,g=1,b=0,a=1}
})
AddTask("StormIslandCasino2", {
	locks=LOCKS.ISLAND4,
	keys_given={KEYS.ISLAND5},
	crosslink_factor=1, --math.random(0,1),
	make_loop=true, --math.random(0, 100) < 50,
	room_choices={
		["BeachClear2"] = 1, -- MR went from 1-5
		["Mangrove"] = math.random(1, 2)
	}, 
	set_pieces={
		{name="Casino"}
	},
	room_bg=GROUND.OCEAN_SHALLOW,
	background_room="OceanShallow",
	colour={r=1,g=1,b=0,a=1}
})
---
AddTask("buling_Island2", {
	locks=LOCKS.ISLAND4,
	keys_given={GLOBAL.KEYS.ISLAND1},
	room_choices={
		["Mangrove"] = math.random(1, 2),
		--["WorldRoom4"] = 1,
		--["BeachClear2"] = 1,
	},
	room_bg=GLOBAL.GROUND.BEACH,
	--background_room={"BeachSand"},
	colour={r=1,g=1,b=0,a=1}
})
AddTask("buling_Island3", {
	locks=LOCKS.ISLAND1,
	keys_given={GLOBAL.KEYS.ISLAND2},
	room_choices={
		["Mangrove"] = math.random(1, 2),
		--["WorldRoom4"] = 1,
		--["BeachClear2"] = 1,
	},
	room_bg=GLOBAL.GROUND.BEACH,
	--background_room={"BeachSand"},
	colour={r=1,g=1,b=0,a=1}
})
AddTask("buling_Island4", {
	locks=LOCKS.ISLAND2,
	keys_given={GLOBAL.KEYS.ISLAND3},
	room_choices={
		["Mangrove"] = math.random(1, 2),
		--["WorldRoom4"] = 1,
		--["BeachClear2"] = 1,
	},
	room_bg=GLOBAL.GROUND.BEACH,
	--background_room={"BeachSand"},
	colour={r=1,g=1,b=0,a=1}
})
AddTask("buling_Island5", {
	locks=LOCKS.ISLAND3,
	keys_given={GLOBAL.KEYS.ISLAND4},
	room_choices={
		["Mangrove"] = math.random(1, 2),
		--["WorldRoom4"] = 1,
		--["BeachClear2"] = 1,
	},
	room_bg=GLOBAL.GROUND.BEACH,
	--background_room={"BeachSand"},
	colour={r=1,g=1,b=0,a=1}
})
AddTask("buling_Island6", {
	locks=LOCKS.ISLAND4,
	keys_given={GLOBAL.KEYS.ISLAND5},
	room_choices={
		["Mangrove"] = math.random(1, 2),
	},
	room_bg=GLOBAL.GROUND.BEACH,
	colour={r=1,g=1,b=0,a=1}
})
AddTask("buling_Desert", {
		locks=LOCKS.NONE,
		keys_given={KEYS.NONE},
		make_loop = true,
		crossLinkFactor = 0,
		room_choices={
			["buling_Badlands"] = 48,
		}, 
		room_bg=GLOBAL.GROUND.PLAINS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
})
AddTask("buling_civilization", {
		locks=LOCKS.NONE,
		keys_given=KEYS.ISLAND1,
		make_loop = true,
		crossLinkFactor = 0,
		gen_method = "volcano",
		room_choices={
			{
				["buling_city"] = 6 + math.random(0, 1),
				["city_base_2"] = 1,
				["city_base_1"] = 1,
				["suburb_base_2"] = 1,
				["cultivated_base_2"] = 1,
			},
			{
				["rainforest_lillypond"] = 12,
			},
			{
				["rainforest_lillypond"] = 14,
				["Mangrove"] = 6,
			},
			{
				
				["rainforest_lillypond"] = 24,
			},
		},
		room_bg=GROUND.FIELDS,
		--background_room="BG_rainforest_base",
		colour={r=1,g=1,b=1,a=0.3}
}) 