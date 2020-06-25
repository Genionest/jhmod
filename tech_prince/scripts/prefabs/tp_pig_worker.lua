local pigs = {"pigman", "pig_build", "idle_loop"}
local pig_phy = {'char', 50, .5}
local pig_shadow = {1.5, 7.5}

local function pig_on_talk(inst, script)
	inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
end

local function pig_on_attacked(inst, data)
	inst.components.talker:Say("我不干了")
	inst:PushEvent("gohome")
end

local function pig_on_night(inst, data)
	inst.components.talker:Say("下班啦")
	inst:PushEvent("gohome")
end

local function MakeWorker(name, pig_fn)
	local function fn()
		local inst = WARGON.make_prefab(pigs, nil, pig_phy, pig_shadow, 4)
		WARGON.CMP.add_cmps(inst, {
			inspect = {},
			loco = {walk=TUNING.PIG_WALK_SPEED, run=TUNING.PIG_RUN_SPEED},
			loot = {loot={}, rand={meat=3, pigskin=1}, ranum=1},
			health = {max=TUNING.PIG_HEALTH},
			combat = {dmg=TUNING.PIG_DAMAGE, per=TUNING.PIG_ATTACK_PERIOD},
			talk = {talk=pig_on_talk, size=35, font=TALKINGFONT, offset=Vector3(0,-400,0)},
			inv = {},
		})
		WARGON.make_poi(inst)
		WARGON.make_burn(inst, "c_med", "pig_torso")
		WARGON.make_free(inst, "c_med", 'pig_torso')
		WARGON.add_tags(inst, {
			"character", "scarytoprey", "tp_pig_worker",
		})
		inst.AnimState:Show("HAT")
		inst.AnimState:Show("HAIR_HAT")
		inst.AnimState:Hide("HAIR_NOHAT")
		inst.AnimState:Hide("HAIR")
		-- inst:AddComponent("wargonbrain")
		-- inst.components.wargonbrain:AddTags({
		-- 	"leash", "on_fire", "wander", "go_home", "pick_up",
		-- })
		WARGON.add_listen(inst, {
			attacked = pig_on_attacked,
			nighttime = pig_on_night,
		})
		if pig_fn then
			pig_fn(inst)
		end
		inst:SetBrain(WARGON.BRAIN.worker_brain())
		inst:SetStateGraph("SGtp_worker_pig")

		return inst
	end
	return Prefab("common/character/"..name, fn, {})
end

local function chop_pig_fn(inst)
	inst:AddTag("tp_chop_pig")
	inst.brain_pick_tags = {'tp_chop_pig_item'}
	-- inst.components.wargonbrain:AddTag("chop")
	-- inst.components.wargonbrain.pick_tags = {'tp_chop_pig_item'}
	inst.AnimState:OverrideSymbol("swap_hat", "hat_straw", "swap_hat")
end

local function hack_pig_fn(inst)
	inst:AddTag("tp_hack_pig")
	inst.brain_pick_tags = {'tp_hack_pig_item'}
	-- inst.components.wargonbrain:AddTag("hack")
	-- inst.components.wargonbrain.pick_tags = {'tp_hack_pig_item'}
	inst.AnimState:OverrideSymbol("swap_hat", "hat_straw", "swap_hat")
end

-- local function is_farm(item, inst)
-- 	if item.prefab == "fast_farmplot" or item.prefab == "slow_farmplot" then
-- 		if item.components.grower and item.components.grower:IsEmpty() then
-- 			return true
-- 		end
-- 	end
-- end

-- local function do_farm(inst)
-- 	local target = WARGON.find(inst, 20, is_farm, nil, {"burnt", "fire"})
-- 	if target then
-- 		local seed = inst.components.inventory:FindItem(function(item)
-- 			return string.find(item.prefab, "seeds")
-- 		end)
-- 		if seed then
-- 			return BufferedAction(inst, target, ACTIONS.PLANT, seed)
-- 		end
-- 	end
-- end

local function farm_pig_fn(inst)
	inst:AddTag("tp_farm_pig")
	inst.brain_pick_tags = {'tp_farm_pig_item'}
	-- inst.components.wargonbrain:AddTag("speical")
	-- inst.components.wargonbrain.pick_tags = {'tp_farm_pig_item'}
	-- inst.components.wargonbrain:SetBehaviour("speical", do_farm)
	inst.AnimState:OverrideSymbol("swap_hat", "hat_straw", "swap_hat")
end

return
	MakeWorker("tp_chop_pig", chop_pig_fn),
	MakeWorker("tp_hack_pig", hack_pig_fn),
	MakeWorker("tp_farm_pig", farm_pig_fn)