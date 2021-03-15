local function bigfoot_fn()
	local inst = WARGON.make_prefab()
	WARGON.do_task(inst, 0, function()
		if GetWorld().components.bigfooter then
			GetWorld().components.bigfooter:SummonFoot(GetPlayer():GetPosition())
		end

		inst:Remove()
	end)

	return inst
end

local function morph_fn()
	local inst = WARGON.make_prefab()
	WARGON.do_task(inst, 0, function()
		local player = GetPlayer()
		if player.components.sciencemorph then
			player.components.sciencemorph:Morph()
		end
		inst:Remove()
	end)
	return inst
end

local function callbeast_fn()
	local inst = WARGON.make_prefab()
	WARGON.do_task(inst, 0, function()
		local player = GetPlayer()
		if player.components.tpcallbeast then
			player.components.tpcallbeast:CallBeast()
		end
		inst:Remove()
	end)
	return inst
end

local function beefalo_fn()
	local inst = WARGON.make_prefab()
	WARGON.do_task(inst, 0, function()
		local pos = WARGON.around_land(inst, math.random(2,4))
		if pos then
			if WARGON.on_water(inst, pos) then
				WARGON.make_fx(pos, "splash_water_drop")
			else
				WARGON.make_spawn(pos, "tp_beefalo")
				-- local nuter = SpawnPrefab("birchnutdrake")
				-- if data.attacker and nuter.components.combat:CanTarget(data.attacker) then
				-- 	nuter.Transform:SetPosition(pos:Get())
				-- 	nuter.components.combat:SetTarget(data.attacker)
				-- else
				-- 	nuter:Remove()
				-- end
			end
			inst:Remove()
		end
	end)
	return inst
end

local function rider_fn()
	local inst = WARGON.make_prefab()
	inst.riders = {"tp_sign_rider"}
	WARGON.do_task(inst, 0, function()
		local player = GetPlayer()
		if c_findtag("tp_sign_rider", 9001) == nil then
			for k, v in pairs(inst.riders) do
				local radius = 10
				local pos = WARGON.around_land(player, radius)
				if pos then
					WARGON.make_spawn(pos, v)
					WARGON.make_fx(pos, "statue_transition")
					WARGON.make_fx(pos, "statue_transition_2")
				end
			end
			-- for i = 1, 4 do
			-- 	local radius = 10
			-- 	local pos = WARGON.around_land(player, radius)
			-- 	if pos then
			-- 		if i <= 1 then
			-- 			WARGON.make_spawn(pos, "tp_sign_rider")
			-- 			if WARGON.CONFIG.diff == 0 then
			-- 				break
			-- 			end
			-- 		else
			-- 			WARGON.make_spawn(pos, "tp_sign_rider_"..i)
			-- 		end
			-- 		WARGON.make_fx(pos, "statue_transition")
			-- 		WARGON.make_fx(pos, "statue_transition_2")
			-- 	end
			-- end
		end
		inst:Remove()
	end)
	return inst
end

local function perd_fn()
	local inst = WARGON.make_prefab()
	inst:do_task(0, function()
		local perd = WARGON.make_spawn(inst, "perd")
		perd.tp_perd = true
		perd:SetBrain(require "brains/tp_perd_brain")
		perd.AnimState:Show("HAT")
		perd.AnimState:OverrideSymbol("swap_hat", "strawhat_cowboy", "swap_hat")
		perd:no_save()
		perd:ListenForEvent("nighttime", function()
			local player = GetPlayer()
			perd.components.inventory:TransferInventory(player)
			perd:Remove()
		end)
		perd:Remove()
		inst:Remove()
	end)
	return inst
end

local function shadow_fn()
	local inst = WARGON.make_prefab()
	inst:do_task(0, function()
		if GetPlayer().components.sanity:GetMaxSanity() >= TUNING.SHADOWWAXWELL_SANITY_PENALTY then
			local pos = inst:around_land(math.random(3))
			if pos then
				WARGON.make_fx(pos, "statue_transition")
				WARGON.make_fx(pos, "statue_transition_2")
				local shadow = WARGON.make_spawn(pos, "tp_unreal_short_wilson")
				if shadow:on_water() then
					shadow:SpawnShadowBoat(pos)
				end
				shadow.components.follower:SetLeader(GetPlayer())
				GetPlayer().components.sanity:RecalculatePenalty()
			end
		end
		inst:Remove()
	end)
	return inst
end

return 
	Prefab("common/bigfoot_sp", bigfoot_fn, {}),
	Prefab("common/morph_sp", morph_fn, {}),
	Prefab("common/callbeast_sp", callbeast_fn, {}),
	Prefab("common/beefalo_sp", beefalo_fn, {}),
	Prefab("common/rider_sp", rider_fn, {}),
	Prefab("common/shadow_sp", shadow_fn, {}),

	Prefab("common/perd_sp", perd_fn, {})