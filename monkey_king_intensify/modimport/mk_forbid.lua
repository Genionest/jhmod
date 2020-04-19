--避
-- local function fire_forbid(inst)
-- 	local rcp1 = Recipe(
-- 		"fire_forbid_scroll",
-- 		{Ingredient("bluegem", 1), Ingredient("papyrus", 1)},
-- 		RECIPETABS.MAGIC,
-- 		TECH.NONE,
-- 		RECIPE_GAME_TYPE.COMMON
-- 	)
-- 	rcp1.atlas = "images/inventoryimages/fire_forbid_scroll.xml"
-- 	rcp1.image = "fire_forbid_scroll.tex"
-- end

-- local function cold_forbid(inst)
-- 	local rcp2 = Recipe(
-- 		"cold_forbid_scroll",
-- 		{Ingredient("redgem", 1), Ingredient("papyrus", 1)},
-- 		RECIPETABS.MAGIC,
-- 		TECH.NONE,
-- 		RECIPE_GAME_TYPE.COMMON
-- 	)
-- 	rcp2.atlas = "images/inventoryimages/cold_forbid_scroll.xml"
-- 	rcp2.image = "cold_forbid_scroll.tex"
-- end

local function health_fix(self)
	local old_fn = self.DoDelta
	function self:DoDelta(amount, overtime, cause, ...)
		if self.inst:HasTag("monkey_king_fire_forbid")
		and (cause == "hot" or cause == "fire") then
			return
		end
		if self.inst:HasTag("monkey_king_cold_forbid")
		and cause == "cold" then
			return
		end
		old_fn(self, amount, overtime, cause, ...)
	end
end

local function freezable_fix(self)
	local old_fn = self.AddColdness
	function self:AddColdness(...)
		if self.inst:HasTag("monkey_king_cold_forbid") then
			return 
		end
		old_fn(...)
	end
end

AddPrefabPostInit("monkey_king", fire_forbid)
AddPrefabPostInit("monkey_king", cold_forbid)
AddComponentPostInit("health", health_fix)
AddComponentPostInit("freezable", freezable_fix)