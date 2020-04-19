local GROUND = GLOBAL.GROUND
AddRoom("StormWorldRoom", {
colour={r=0.3,g=.8,b=.5,a=.50},
value = GLOBAL.GROUND.BEACH,
contents =  {
				countstaticlayouts={
					["StormWorld"]=1,
				},
            }
})		
AddRoom("BeachClear2", {
colour={r=.5,g=0.6,b=.080,a=.10},
value = GROUND.BEACH,
tags = {"ExitPiece", "Packim_Fishbone"},
contents =  {
                distributepercent = 0,
                distributeprefabs =
                {
                },

                countprefabs = {
					beachresurrector = 1,
				}

            }
})
AddRoom("BeachPalmCasino2", {
colour={r=.5,g=0.6,b=.080,a=.10},
value = GROUND.BEACH,
tags = {"ExitPiece", "Packim_Fishbone"},
contents =  {
				distributepercent = .1, --Lowered a bit
				distributeprefabs=
				{
								seashell_beached=0.025,
								limpetrock = 0.01,
								palmtree = .3,
								rocks = .003, --trying
								beehive = .005, --trying
								--flower = 0.04, --trying
								grass = .3, --trying
								sapling = .2, --trying
								--fireflies = .002, --trying
								flint = .05,
								sandhill =.055,
				},

			}
})
AddRoom("buling_Badlands", {
colour={r=0.3,g=0.2,b=0.1,a=0.3},
value = GROUND.PAINTED, 
contents =  {
				distributepercent = 0.03,
				distributeprefabs =
				{
					pig_ruins_head = .2,
					--pig_ruins_dart_statue = .2,
					pig_ruins_ant = .2,
					pig_ruins_torch = .2,
					ruins_rubble_table = 0.15,
					ruins_rubble_chair = 0.15,
					ruins_rubble_vase = 0.15,
					runis_bowl = 0.15,
					runis_plate = 0.15,
					sandhill = .5,
					cactus = .7,
					dragoonden = .3,
					tumbleweedspawner = .1,
					vampirebatcave = .1,
				},
            }
})		
AddRoom("StormWorldRoom2", {
colour={r=0.3,g=.8,b=.5,a=.50},
value = GLOBAL.GROUND.PAINTED,
contents =  {
				countstaticlayouts={
					["StormWorld"]=1,
				},
				distributepercent = 0.03,
				distributeprefabs =
				{
					pig_ruins_head = .2,
					--pig_ruins_dart_statue = .2,
					pig_ruins_ant = .2,
					pig_ruins_torch = .2,
					ruins_rubble_table = 0.15,
					ruins_rubble_chair = 0.15,
					ruins_rubble_vase = 0.15,
					runis_bowl = 0.15,
					runis_plate = 0.15,
					sandhill = .5,
					cactus = .7,
					dragoonden = .3,
					tumbleweedspawner = .1,
					vampirebatcave = .1,
				},
            }
})
AddRoom("StormWorldRoom3", {
colour={r=0,g=.5,b=.5,a=.10},
value = GLOBAL.GROUND.TIDALMARSH,
tags = {"ExitPiece"},
contents =  {
				countstaticlayouts={
					["EndeWorld"]=1,
					["TidalpoolLarge"]=1,
				},
				distributepercent = 0.03,
				distributeprefabs =
				{
					mermhouse_fisher = 1,
					poisonhole = 5,
					tidalpool = 1,
				},
            }
})
AddRoom("buling_city", {
colour={r=0.3,g=.8,b=.5,a=.50},
value = GLOBAL.GROUND.FOUNDATION,
tags = {"ExitPiece", "City_Foundation", "City1"},
contents =  {
	distributepercent = 0.03,
	distributeprefabs =
	{
		rocks = .2,
		pighouse_city = .5,
		pighouse_farm = .3,
		roc_nest_house = .2,
		pighouse_city = .2,
		hedge_cone = .2,
		--deco_ruins_fountain = .2,
	},
	}
})		