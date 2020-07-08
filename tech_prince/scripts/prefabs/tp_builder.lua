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
		end
	end)
end

return 
	Prefab("common/bigfoot_sp", bigfoot_fn, {}),
	Prefab("common/morph_sp", morph_fn, {}),
	Prefab("common/callbeast_sp", callbeast_fn, {}),
	Prefab("common/beefalo_sp", beefalo_fn, {})