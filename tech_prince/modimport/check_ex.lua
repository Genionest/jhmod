local function check_info()
	print("get modnames------------")
	-- for k, v in pairs(ModManager.mods) do
	-- 	print(v.modinfo.name)
	-- end
	for k, v in pairs(ModManager.modnames) do
		print(k, v)
	end
end

-- local function check_need()
-- 	local need_mod = {
-- 		["workshop-1435117904"] = 1,
-- 		["workshop-1485194313"] = 1,
-- 	}
-- 	local n = 0
-- 	for k, v in pairs(ModManager.modnames) do
-- 		if need_mod[v] then
-- 			n = n + 1
-- 		end
-- 	end
-- 	-- assert(n>=#need_mod, "error!")
-- end

-- local function check_skin()
-- 	local skin_mod = "workshop-1485194313"
-- 	for k, v in pairs(ModManager.modnames) do
-- 		if v == skin_mod then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- local function check_asset()
-- 	local asset_mod = {
-- 		["workshop-1697390346"] = 'wortox',
-- 	}
-- 	local asset_need= {
-- 		['wortox'] = false,
-- 	}
-- 	local n = 0
-- 	for k, v in pairs(ModManager.modnames) do
-- 		if asset_mod[v] then
-- 			asset_need[asset_mod[v]] = true
-- 		end
-- 	end
-- 	return asset_mod
-- end

GLOBAL.WARGON.CHECK_EX = {
	check_info	= check_info,
	-- check_need	= check_need,
	-- check_asset	= check_asset,
	-- check_skin	= check_skin,
}

GLOBAL.WARGON.CHECK = GLOBAL.WARGON.CHECK_EX