local MakePlayerCharacter = require "prefabs/player_common"
local Rcp = require "extension.lib.rcp"
local EntUtil = require "extension.lib.ent_util"
local RcpEnv = Sample.RcpEnv
local AssetMaster = Sample.AssetMaster
local Info = Sample.Info
local PlayerCommonFn = require "extension.datas.player_common_fn"

local assets = 
{
    Asset("ANIM", "anim/wilson.zip"),
	Asset("ANIM", "anim/beard.zip"),
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs = 
{
    "beardhair",
}

local beard_fn = function(inst)

    inst:AddComponent("beard")
    inst.components.beard.onreset = function()
        inst.AnimState:ClearOverrideSymbol("beard")
        inst.components.combat:RmDefenseMod("beard")
    end
    inst.components.beard.prize = "beardhair"
    
    --tune the beard economy...
	local beard_days = {4, 8, 16}
	local beard_bits = {1, 3,  9}
    
    inst.components.beard:AddCallback(beard_days[1], function()
        -- if inst.components.tp_level.level<5 then
        --     return 
        -- end
        inst.AnimState:OverrideSymbol("beard", "beard", "beard_short")
        inst.components.beard.bits = beard_bits[1]
        -- inst.components.combat:AddDefenseMod("beard", 10)
    end)
    
    inst.components.beard:AddCallback(beard_days[2], function()
        -- if inst.components.tp_level.level<5 then
        --     return 
        -- end
        inst.AnimState:OverrideSymbol("beard", "beard", "beard_medium")
        inst.components.beard.bits = beard_bits[2]
        -- inst.components.combat:AddDefenseMod("beard", 20)
    end)
    
    inst.components.beard:AddCallback(beard_days[3], function()
        -- if inst.components.tp_level.level<5 then
        --     return 
        -- end
        inst.AnimState:OverrideSymbol("beard", "beard", "beard_long")
        inst.components.beard.bits = beard_bits[3]
        -- inst.components.combat:AddDefenseMod("beard", 30)
    end)
    
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
    hp = {300, 600, 900, 1200},
    sp = {200, 300, 400, 500},
    hg = {150, 300, 450, 600},
    dm = {-.1, .6, 1.5, 2.1},
}

local function fn(inst)
    PlayerCommonFn(inst)
    beard_fn(inst)
    inst.components.health:SetMaxHealth(300)
    inst.components.wg_start:AddFn(function(inst)
        -- skill
        inst.components.tp_skill_tree:UnlockSkill("SKbeard_defense")
    end)
end

return MakePlayerCharacter("wilson", prefabs, assets, fn) 
