local easing = require "easing"
local MakePlayerCharacter = require "prefabs/player_common"
local Rcp = require "extension.lib.rcp"
local EntUtil = require "extension.lib.ent_util"
local RcpEnv = Sample.RcpEnv
local AssetMaster = Sample.AssetMaster
local Info = Sample.Info

local assets = 
{
    Asset("ANIM", "anim/wolfgang.zip"),
    Asset("ANIM", "anim/wolfgang_skinny.zip"),
    Asset("ANIM", "anim/wolfgang_mighty.zip"),
    Asset("ANIM", "anim/player_mount_wolfgang.zip"),
    Asset("ANIM", "anim/player_wolfgang.zip"),
	Asset("SOUND", "sound/wolfgang.fsb"),
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local function applymightiness(inst)

	local percent = inst.components.hunger:GetPercent()
	
	local damage_mult = TUNING.WOLFGANG_ATTACKMULT_NORMAL
	local hunger_rate = TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL
	local health_max = TUNING.WOLFGANG_HEALTH_NORMAL
	local scale = 1

	local mighty_scale = 1.25
	local wimpy_scale = .9


	if inst.strength == "mighty" then
		local mighty_start = (TUNING.WOLFGANG_START_MIGHTY_THRESH/TUNING.WOLFGANG_HUNGER)	
		local mighty_percent = math.max(0, (percent - mighty_start) / (1 - mighty_start))
		damage_mult = easing.linear(mighty_percent, TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MIN, TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MAX - TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MIN, 1)
		health_max = easing.linear(mighty_percent, TUNING.WOLFGANG_HEALTH_NORMAL, TUNING.WOLFGANG_HEALTH_MIGHTY - TUNING.WOLFGANG_HEALTH_NORMAL, 1)	
		hunger_rate = easing.linear(mighty_percent, TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL, TUNING.WOLFGANG_HUNGER_RATE_MULT_MIGHTY - TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL, 1)	
		scale = easing.linear(mighty_percent, 1, mighty_scale - 1, 1)	
	elseif inst.strength == "wimpy" then
		local wimpy_start = (TUNING.WOLFGANG_START_WIMPY_THRESH/TUNING.WOLFGANG_HUNGER)	
		local wimpy_percent = math.min(1, percent/wimpy_start )
		damage_mult = easing.linear(wimpy_percent, TUNING.WOLFGANG_ATTACKMULT_WIMPY_MIN, TUNING.WOLFGANG_ATTACKMULT_WIMPY_MAX - TUNING.WOLFGANG_ATTACKMULT_WIMPY_MIN, 1)
		health_max = easing.linear(wimpy_percent, TUNING.WOLFGANG_HEALTH_WIMPY, TUNING.WOLFGANG_HEALTH_NORMAL - TUNING.WOLFGANG_HEALTH_WIMPY, 1)	
		hunger_rate = easing.linear(wimpy_percent, TUNING.WOLFGANG_HUNGER_RATE_MULT_WIMPY, TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL - TUNING.WOLFGANG_HUNGER_RATE_MULT_WIMPY, 1)	
		scale = easing.linear(wimpy_percent, wimpy_scale, 1 - wimpy_scale, 1)	
	end

	inst.components.tp_body:AddSizeMod("wolfgang", scale-1)
	-- inst.Transform:SetScale(scale,scale,scale)

	inst.components.hunger:AddBurnRateModifier("wolfgang", hunger_rate)

	inst.components.combat:AddDamageModifier("wolfgang", damage_mult)

	-- local health_percent = inst.components.health:GetPercent()
	-- inst.components.health.maxhealth = health_max
	-- inst.components.health:SetPercent(health_percent)
	-- inst.components.health:DoDelta(0, true)
	
	-- 生命回复收益
	local rcv_rate = Info.Character.wolfgang.NormalRecoverRate
	if inst.strength == "mighty" then
		local mighty_start = (TUNING.WOLFGANG_START_MIGHTY_THRESH/TUNING.WOLFGANG_HUNGER)	
		local mighty_percent = math.max(0, (percent - mighty_start) / (1 - mighty_start))
		local normal_rcv = Info.Character.wolfgang.NormalRecoverRate
		local mighty_rcv = Info.Character.wolfgang.MightyRecoverRate
		rcv_rate = easing.linear(mighty_percent, normal_rcv, mighty_rcv-normal_rcv, 1)
	elseif inst.strength == "wimpy" then
		local wimpy_start = (TUNING.WOLFGANG_START_WIMPY_THRESH/TUNING.WOLFGANG_HUNGER)	
		local wimpy_percent = math.min(1, percent/wimpy_start )
		local wimpy_rcv = Info.Character.wolfgang.WimpyRecoverRate
		local normal_rcv = Info.Character.wolfgang.NormalRecoverRate
		rcv_rate = easing.linear(wimpy_percent, wimpy_rcv, normal_rcv-wimpy_rcv, 1)
	end
	inst.components.health:AddRecoverRateMod("tp_level0", rcv_rate)
end


local function onhungerchange(inst, data)

	local silent = POPULATING

	if inst.strength == "mighty" then
		if inst.components.hunger.current < TUNING.WOLFGANG_END_MIGHTY_THRESH then
			inst.strength = "normal"
			inst.AnimState:SetBuild("wolfgang")
			inst.AnimState:OverrideSymbol("torso_pelvis", "wolfgang", "torso" ) --put the torso in pelvis slot to go behind
			inst.AnimState:OverrideSymbol("torso", "wolfgang", "torso_pelvis" ) --put the pelvis on top of the base torso by putting it in the torso slot

			if not silent then
				inst.components.talker:Say(GetString("wolfgang", "ANNOUNCE_MIGHTYTONORMAL"))
				inst.sg:PushEvent("powerdown")
				inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/shrink_lrgtomed")
			end
			inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_LP"
			inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt"
		end
	elseif inst.strength == "wimpy" then
		if inst.components.hunger.current > TUNING.WOLFGANG_END_WIMPY_THRESH then
			inst.strength = "normal"
			if not silent then
				inst.components.talker:Say(GetString("wolfgang", "ANNOUNCE_WIMPYTONORMAL"))
				inst.sg:PushEvent("powerup")
				inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/grow_smtomed")	
			end
			inst.AnimState:SetBuild("wolfgang")
			inst.AnimState:OverrideSymbol("torso_pelvis", "wolfgang", "torso" ) --put the torso in pelvis slot to go behind
			inst.AnimState:OverrideSymbol("torso", "wolfgang", "torso_pelvis" ) --put the pelvis on top of the base torso by putting it in the torso slot

			inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_LP"
			inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt"
		end
	else
		if inst.components.hunger.current > TUNING.WOLFGANG_START_MIGHTY_THRESH then
			inst.strength = "mighty"
			inst.AnimState:SetBuild("wolfgang_mighty")
			inst.AnimState:OverrideSymbol("torso_pelvis", "wolfgang_mighty", "torso" ) --put the torso in pelvis slot to go behind
			inst.AnimState:OverrideSymbol("torso", "wolfgang_mighty", "torso_pelvis" ) --put the pelvis on top of the base torso by putting it in the torso slot

			if not silent then
				inst.components.talker:Say(GetString("wolfgang", "ANNOUNCE_NORMALTOMIGHTY"))
				inst.sg:PushEvent("powerup")
				inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/grow_medtolrg")
			end
			inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_large_LP"
			inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt_large"

		elseif inst.components.hunger.current < TUNING.WOLFGANG_START_WIMPY_THRESH then
			inst.strength = "wimpy"
			inst.AnimState:SetBuild("wolfgang_skinny")
			inst.AnimState:OverrideSymbol("torso_pelvis", "wolfgang_skinny", "torso" ) --put the torso in pelvis slot to go behind
			inst.AnimState:OverrideSymbol("torso", "wolfgang_skinny", "torso_pelvis" ) --put the pelvis on top of the base torso by putting it in the torso slot

			if not silent then
				inst.sg:PushEvent("powerdown")
				inst.components.talker:Say(GetString("wolfgang", "ANNOUNCE_NORMALTOWIMPY"))
				inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/shrink_medtosml")
			end
			inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_small_LP"
			inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt_small"
		end
	end

	applymightiness(inst)
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
    hp = {600, 1000, 1250, 1500},
    sp = {200, 300, 400, 500},
    hg = {300, 450, 600, 750},
    dm = {-.1, .6, 1.5, 2.1},
}

local fn = function(inst)
	inst.strength = "normal"
    
	inst.level_data = {
        attrs = attrs,
        level_fn = function(inst, level)
			if level>=3 then
				inst.components.health:AddRecoverRateMod("tp_level0", Info.Character.wolfgang.NormalRecoverRate)
			end
			if level>=5 then
				applymightiness(inst)
				inst:ListenForEvent("hungerdelta", onhungerchange)
			end
		end,
        advance_fn = function(inst, phase)
			if phase>=2 then
				inst.components.sanity.night_drain_mult = 1.1
				inst.components.sanity.neg_aura_mult = 1.1
				inst.components.health:AddRecoverRateMod("tp_level2", Info.Character.wolfgang.Phase2RecoverRate)
			end
			if phase>=3 then
				EntUtil:add_hunger_mod(inst, "tp_level0", Info.Character.wolfgang.Phase3HungerRate)
				inst.components.health:AddRecoverRateMod("tp_level2", Info.Character.wolfgang.Phase3RecoverRate)
			end
		end,
        tp_level_up = function(inst, data)
			if data and data.level then
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


return MakePlayerCharacter("wolfgang", nil, assets, fn) 
