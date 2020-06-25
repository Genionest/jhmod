local function fn()
	local inst = WARGON.make_prefab()
	WARGON.do_task(inst, 0, function()
		if GetWorld().components.bigfooter then
			GetWorld().components.bigfooter:SummonFoot(GetPlayer():GetPosition())
		end

		inst:Remove()
	end)

	return inst
end

local function fn2()
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

local function fn3()
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

return Prefab("common/bigfoot_sp", fn, {}),
	Prefab("common/morph_sp", fn2, {}),
	Prefab("common/callbeast_sp", fn3, {})