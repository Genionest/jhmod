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
        inst.components.combat:AddDefenseMod("beard", 10)
    end)
    
    inst.components.beard:AddCallback(beard_days[2], function()
        -- if inst.components.tp_level.level<5 then
        --     return 
        -- end
        inst.AnimState:OverrideSymbol("beard", "beard", "beard_medium")
        inst.components.beard.bits = beard_bits[2]
        inst.components.combat:AddDefenseMod("beard", 20)
    end)
    
    inst.components.beard:AddCallback(beard_days[3], function()
        -- if inst.components.tp_level.level<5 then
        --     return 
        -- end
        inst.AnimState:OverrideSymbol("beard", "beard", "beard_long")
        inst.components.beard.bits = beard_bits[3]
        inst.components.combat:AddDefenseMod("beard", 30)
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
    -- inst.level_data = {
    --     attrs = attrs,
    --     level_fn = function(inst, level)
    --         if level>=5 then
    --             if inst.components.beard == nil then
    --                 beard_fn(inst)
    --             end
    --         end
    --     end,
    --     advance_fn = function(inst, phase)
    --         if phase>=2 then
    --             EntUtil:add_hunger_mod(inst, "tp_level0", Info.Character.wilson.Phase2HungerRate)
    --             local CalcDamage = inst.components.combat.CalcDamage
    --             function inst.components.combat:CalcDamage(target, weapon, multiplier)
    --                 multiplier = multiplier or 1
    --                 local base = inst.components.locomotor.runspeed
    --                 local total = inst.components.locomotor:GetRunSpeed()
    --                 local p = total/base
    --                 if p>1 then
    --                     local mult = (p-1)*Info.Character.wilson.SpeedDmgMod
    --                     print(mult)
    --                     multiplier = multiplier+mult
    --                 end
    --                 return CalcDamage(self, target, weapon, multiplier)
    --             end
    --         end
    --         if phase>=3 then
    --             EntUtil:add_sanity_mod(inst, "tp_level0", Info.Character.wilson.Phase3SanityRate)
    --             inst.components.builder.science_bonus = 1
    --             inst.components.builder.magic_bonus = 1
    --         end
    --     end,
    --     tp_level_up = function(inst, data)
    --         if data and data.level then
    --         end
    --     end,
    --     tp_be_advanced = function(inst, data)
    --         if data and data.phase then
    --             if data.phase == 2 then
    --                 -- give_gift(inst, "tp_furnace_bp", 1)
    --             elseif data.phase == 3 then
    --                 -- give_gift(inst, "ak_smithing_table_bp", 1)
    --             end
    --         end
    --     end,
    -- }
end

return MakePlayerCharacter("wilson", prefabs, assets, fn) 
