local MakePlayerCharacter = require "prefabs/player_common"
local Rcp = require "extension.lib.rcp"
local EntUtil = require "extension.lib.ent_util"
local PlayerCommonFn = require "extension.datas.player_common_fn"
local RcpEnv = Sample.RcpEnv
local AssetMaster = Sample.AssetMaster
local Info = Sample.Info

local assets = 
{
    Asset("ANIM", "anim/wathgrithr.zip"),
	--Asset("SOUND", "sound/wathgrithr.fsb"),
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs = 
{
	"spear_wathgrithr",	
	"wathgrithrhat",
	"wathgrithr_spirit",
}

local start_inv = 
{
	"spear_wathgrithr",	
	"wathgrithrhat",
	-- "meat",
	-- "meat",
	-- "meat",
	-- "meat",
}

local smallScale = 0.5
local medScale = 0.7
local largeScale = 1.1

local function onkill(inst, data)
	if data.cause == inst.prefab 
		and not data.inst:HasTag("prey") 
		and not data.inst:HasTag("veggie") 
		and not data.inst:HasTag("structure") then
		local delta = (data.inst.components.combat.defaultdamage) * 0.25
        inst.components.health:DoDelta(delta, false, "battleborn")
        inst.components.sanity:DoDelta(delta)

        if math.random() < .1 and not data.inst.components.health.nofadeout then
        	local time = data.inst.components.health.destroytime or 2
        	inst:DoTaskInTime(time, function()
        		local s = medScale
        		if data.inst:HasTag("smallcreature") then
        			s = smallScale
    			elseif data.inst:HasTag("largecreature") then
    				s = largeScale
    			end
        		local fx = SpawnPrefab("wathgrithr_spirit")
        		fx.Transform:SetPosition(data.inst:GetPosition():Get())
        		fx.Transform:SetScale(s,s,s)
    		end)
        end

	end
end

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
    hp = {450, 800, 1050, 1300},
    sp = {120, 220, 320, 420},
    hg = {120, 270, 420, 570},
    dm = {0, 1, 1.4, 1.8},
}

local function custom_init(inst)
    PlayerCommonFn(inst)
    inst.components.health:SetMaxHealth(400)

	inst.soundsname = "wathgrithr"
	inst.talker_path_override = "dontstarve_DLC001/characters/"

	if Profile:IsWathgrithrFontEnabled() then
		inst.components.talker.font = TALKINGFONT_WATHGRITHR
	else
		inst.components.talker.font = TALKINGFONT
	end
	inst:ListenForEvent("continuefrompause", function()
		if Profile:IsWathgrithrFontEnabled() then
			inst.components.talker.font = TALKINGFONT_WATHGRITHR
		else
			inst.components.talker.font = TALKINGFONT
		end
	end, GetWorld())

    local spear_recipe = Recipe("spear_wathgrithr", {Ingredient("twigs", 2), Ingredient("flint", 2), Ingredient("goldnugget", 2)}, RECIPETABS.WAR, TECH.NONE, RECIPE_GAME_TYPE.COMMON)
    local helm_recipe = Recipe("wathgrithrhat", {Ingredient("goldnugget", 2), Ingredient("rocks", 2)}, RECIPETABS.WAR, TECH.NONE, RECIPE_GAME_TYPE.COMMON)
    spear_recipe.sortkey = 1
    helm_recipe.sortkey = 2
    inst.components.eater:SetCarnivore(true)
    -- inst:ListenForEvent("entity_death", function(wrld, data) onkill(inst, data) end, GetWorld())

    inst.components.wg_start:AddFn(function(inst)
        -- skill
        inst.components.tp_skill_tree:UnlockSkill("SKcombat_blood")
        inst.components.tp_skill_tree:UnlockSkill("SKdesire_fighting")
        inst.components.tp_skill_tree:UnlockSkill("brute")
    end)
end

return MakePlayerCharacter("wathgrithr", prefabs, assets, custom_init, start_inv) 
