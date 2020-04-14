require "recipe"
if ( GLOBAL.IsDLCEnabled(3) ) then
	require "recipecategory"
end

PrefabFiles = {
	"pigking_sign",
	"pigking_gamer",
	"ride_warg",
	"sign_staff",
}

local pigking_main = require "screen/pigking_main"

modimport "modimport/lop_chinese.lua"
modimport "modimport/ride_warg.lua"
modimport "modimport/strength_boss.lua"

Recipe("pigskin",
	{Ingredient("decrease_health", 20)},
	RECIPETABS.MAGIC,
	{MAGIC = 4}
)

AddPrefabPostInit("pigking", function(inst)
	inst:AddTag("prototyper")
	inst:AddComponent("prototyper")
	inst.components.prototyper.trees = {
    	SCIENCE = 0,MAGIC = 1,ANCIENT = 0,OBSIDIAN = 0,
    	WATER = 0,HOME = 0,CITY = 0,LOST = 0,
	}
	inst.components.prototyper.onturnon = function(inst)
		GetRecipe("pigskin").level.MAGIC = 0
	end
	inst.components.prototyper.onturnoff = function(inst)
		GetRecipe("pigskin").level.MAGIC = 4
	end
	local old_fn = inst.components.trader.onaccept
	inst.components.trader.onaccept = function(inst, giver, item)
		-- old_fn(inst, giver, item)
		if item.prefab == "pigskin" then
			TheFrontEnd:PushScreen(pigking_main())
		end
	end

end)
