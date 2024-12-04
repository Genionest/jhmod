
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
    Asset("ANIM", "anim/wickerbottom.zip"),
	Asset("SOUND", "sound/wickerbottom.fsb"),
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local function give_gift(inst, loot, n)
    local gift = inst.components.inventory:FindItem(function(item, inst)
        return item.prefab == "tp_level_gift"
    end)
    if gift == nil then
        gift = SpawnPrefab("tp_level_gift")
        inst.components.inventory:GiveItem(gift)
    end
    gift:add_loot(loot, n)
end

local attrs = {
    hp = {200, 500, 850, 1500},
    sp = {200, 300, 400, 500},
    hg = {250, 400, 550, 700},
    dm = {-.2, .5, 1.3, 2.2},
}

local fn = function(inst)
	inst:AddTag("bookreader")
	
    inst.level_data = {
        attrs = attrs,
        level_fn = function(inst, level)
            if level>=2 then
                inst.components.builder.science_bonus = 1
            end
        end,
        advance_fn = function(inst, phase)
            if phase>=2 then
                if not inst:HasTag("insomniac") then
                    inst:AddTag("insomniac")
                    local booktab = {str = "BOOKS", sort=999, icon = "tab_book.tex"}
                    inst.components.builder:AddRecipeTab(booktab)
                
                    Recipe("book_birds", {Ingredient("papyrus", 2), Ingredient("bird_egg", 2)}, booktab, {SCIENCE = 0, MAGIC = 0, ANCIENT = 0})
                    Recipe("book_gardening", {Ingredient("papyrus", 2), Ingredient("seeds", 1), Ingredient("poop", 1)}, booktab, {SCIENCE = 1})
                    Recipe("book_sleep", {Ingredient("papyrus", 2), Ingredient("nightmarefuel", 2)}, booktab, {MAGIC = 2})
                    Recipe("book_brimstone", {Ingredient("papyrus", 2), Ingredient("redgem", 1)}, booktab, {MAGIC = 3})
                
                    if SaveGameIndex:IsModeShipwrecked() then
                        Recipe("book_meteor", {Ingredient("papyrus", 2), Ingredient("obsidian", 2)}, booktab, {SCIENCE = 3})
                    else
                        Recipe("book_tentacles", {Ingredient("papyrus", 2), Ingredient("tentaclespots", 1)}, booktab, {SCIENCE = 3})
                    end
                end
            end
            if phase>=3 then
                inst.components.eater.stale_hunger = TUNING.WICKERBOTTOM_STALE_FOOD_HUNGER
                inst.components.eater.stale_health = TUNING.WICKERBOTTOM_STALE_FOOD_HEALTH
                inst.components.eater.spoiled_hunger = TUNING.WICKERBOTTOM_SPOILED_FOOD_HUNGER
                inst.components.eater.spoiled_health = TUNING.WICKERBOTTOM_SPOILED_FOOD_HEALTH
            end
        end,
        tp_level_up = function(inst, data)
            if data and data.level then
                if data.level == 5 or data.level == 8 then
                    give_gift(inst, "book_birds", 1)
                    give_gift(inst, "book_gardening", 1)
                    give_gift(inst, "book_sleep", 1)
                end
            end
        end,
        tp_be_advanced = function(inst, data)
            if data and data.phase then
                if data.phase == 2 then
                    give_gift(inst, "tp_furnace_bp", 1)
                elseif data.phase == 3 then
                    give_gift(inst, "ak_smithing_table_bp", 1)
                end
            end
        end,
    }
end


return MakePlayerCharacter("wickerbottom", nil, assets, fn, {"papyrus", "papyrus"}) 
