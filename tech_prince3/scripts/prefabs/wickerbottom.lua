
local MakePlayerCharacter = require "prefabs/player_common"
local PlayerCommonFn = require "extension.datas.player_common_fn"

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
    PlayerCommonFn(inst)
    inst.components.health:SetMaxHealth(300)
	inst:AddTag("bookreader")
    inst.components.builder.science_bonus = 1
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
    
    inst.components.eater.stale_hunger = TUNING.WICKERBOTTOM_STALE_FOOD_HUNGER
    inst.components.eater.stale_health = TUNING.WICKERBOTTOM_STALE_FOOD_HEALTH
    inst.components.eater.spoiled_hunger = TUNING.WICKERBOTTOM_SPOILED_FOOD_HUNGER
    inst.components.eater.spoiled_health = TUNING.WICKERBOTTOM_SPOILED_FOOD_HEALTH

    inst.components.wg_start:AddFn(function(inst)
        -- skill
        inst.components.tp_skill_tree:UnlockSkill("library_wind")
        inst.components.tp_skill_tree:UnlockSkill("wind_comfortable")
        inst.components.tp_skill_tree:UnlockSkill("wind_caster")
    end)
end


return MakePlayerCharacter("wickerbottom", nil, assets, fn, {"papyrus", "papyrus"}) 
