local function check_asset()
	-- local asset_mod = {
	-- 	["workshop-1697390346"] = 'wortox',
	-- }
	-- local asset_need= {
	-- 	['wortox'] = false,
	-- }
	-- local n = 0
	-- for k, v in pairs(ModManager.modnames) do
	-- 	if asset_mod[v] then
	-- 		asset_need[asset_mod[v]] = true
	-- 	end
	-- end
    -- return asset_mod
    local mods = {
        ["workshop-1697390346"] = "wortox",
        ["workshop-1485194313"] = "player_skin",
    }
    local assets = {
        ["wortox"] = {
            {"wortox_soul_heal_fx", "anim"},
            -- {"wortox_soul_ball", "anim"},
            -- {"inventoryimages/wortox_soul", "atlas"},
        },
        ["player_skin"] = {
            -- {"wathgrithr", "anim"},
            -- {"wolfgang", "anim"},
            -- {"wolfgang_skinny", "anim"},
            -- {"wolfgang_mighty", "anim"},
            -- {"player_mount_wolfgang", "anim"},
            -- {"player_wolfgang", "anim"},
            -- {"waxwell", "anim"},
            -- {"woodie", "anim"},
        },
    }
    for k, v in pairs(ModManager.modnames) do
        if mods[v] then
            assets[mods[v]] = nil
        end
    end
    return assets
end

GLOBAL.WARGON.NEED_ASSETS = check_asset()