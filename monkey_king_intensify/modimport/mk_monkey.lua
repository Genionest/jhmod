local spawn_key = GetModConfigData("spawn_key")
local back_key = GetModConfigData("back_key")
-- 猴子猴孙
local function canSpawnMonkey(inst)
	-- 猴儿们
	if spawn_key ~= 0 then
		TheInput:AddKeyDownHandler(spawn_key, function()
			inst.components.monkeyspawner:Spawn()
		end)
	end
end

local function canRemoveMonkey(inst)
	-- 收
	if back_key then
		TheInput:AddKeyDownHandler(back_key, function()
			inst.components.monkeyspawner:BackMonkeys()
		end)
	end
end

local function manyMonkey(inst)
	inst:AddComponent("monkeyspawner")
	canSpawnMonkey(inst)
	canRemoveMonkey(inst)
    local rcp = Recipe("monkey_beardhair",
    	{Ingredient("decrease_health", 5)},
    	RECIPETABS.SURVIVAL, 
    	TECH.NONE, 
    	RECIPE_GAME_TYPE.COMMON)
    rcp.atlas = "images/inventoryimages/monkey_beardhair.xml"
    rcp.image = "monkey_beardhair.tex"
end

local function setPrimeape(inst)
	inst:AddComponent("monkeyspawn")
end

AddPrefabPostInit("primeape", setPrimeape)
AddPrefabPostInit("monkey_king", manyMonkey)