local tents = {"tent", "tent_circus", "idle"}
local tent_phy = {1, nil}
local tent_map = {'tent', 'png'}
local hams = {"ham_bat", "ham_bat", "idle"}
local ham_phy = {.5, nil}
local benchs = {"workbench_obsidian", "workbench_obsidian", "idle"}
local bench_phy = {2, 1.2}
local boxes = {"chest", "treasure_chest_sacred", "closed"}
local box_map = {'treasure_chest', 'png'}

local function tent_ham(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function tent_hit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("idle", true)
	end
end

local function tent_finish(inst)
	if not inst:HasTag("burnt") then
		-- inst.AnimState:PlayAnimation("destroy")
		-- inst:ListenForEvent("animover", function(inst, data) inst:Remove() end)
		inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_pre")
		-- inst.persists = false
		inst:DoTaskInTime(16*FRAMES, function() inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_twirl") end)
	end
end

local function tent_built(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", true)
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/tent")
end

local function tent_save(inst, data)
	WARGON.burn_save(inst, data)
end

local function tent_load(inst, data)
 	WARGON.burn_load(inst, data)
end

local function tent_sleep(inst, sleeper)
	if inst.components.finiteuses:GetUses() <= 0 then
		return
	else
		WARGON_SLEEP_EX.sleep_tent(inst, sleeper)
	end
end

-- local function tent_trader_test(inst, item)
-- 	if string.find(item.prefab, "gem") then
-- 		return true
-- 	end
-- end

-- local function tent_trader_aceept(inst, give, item)
-- 	if item.prefab == "redgem" then
-- 		inst.tent_colour.r = inst.tent_colour.r + .1
-- 	elseif item.prefab == "bluegem" then
-- 		inst.tent_colour.b = inst.tent_colour.b + .1
-- 	elseif item.prefab == "greengem" then
-- 		inst.tent_colour.g = inst.tent_colour.g + .1
-- 	else
-- 		inst.tent_colour.r = .1
-- 		inst.tent_colour.g = .1
-- 		inst.tent_colour.b = .1
-- 	end
-- 	print("colour is", inst.tent_colour.r, inst.tent_colour.g, inst.tent_colour.b)
-- 	inst.AnimState:SetMultColour(inst.tent_colour.r, inst.tent_colour.g, inst.tent_colour.b, 1)
-- end

local function tent_fn(inst)
	WARGON_CMP_EX.add_cmps(inst, {
		inspect = {},
		loot = {},
		work = {act=ACTIONS.HAMMER, num=4, ham=tent_ham, hit=tent_hit},
		finite = {max=10, use=10, fn=tent_finish},
		sleepingbag = {},
		fueled = {time=100, typ="USAGE"},
		loot = {},
		-- trader = {test=tent_trader_test, accept=tent_trader_aceept},
	})
	inst.components.sleepingbag.onsleep = tent_sleep 
	WARGON.add_listen(inst, {
		onbuilt = tent_built,
		})
	inst.components.fueled:SetPercent(.9)
	inst.components.fueled:StopConsuming()
	WARGON.make_burn(inst, "large", nil, nil, true)
	WARGON.make_prop(inst)
	WARGON.add_tags(inst, {'tp_tent'})
	local size = 1.2
	inst.Transform:SetScale(size, size, size)
	-- inst.AnimState:SetMultColour(.4, .9, 1, 1)
	inst.OnSave = tent_save
	inst.OnLoad = tent_load
	-- inst.tent_colour = {r=.1, g=.1, b=.1}
end

-- local function ham_on(inst)
-- 	local item = SpawnPrefab("tp_hambat")
-- 	item.components.perishable:SetPercent(inst.components.perishable:GetPercent())
-- 	item.Transform:SetPosition(inst:GetPosition():Get())
-- 	SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
-- 	inst:Remove()
-- end

-- local function ham_on_drop(inst)
-- 	inst.components.groundpounder:GroundPound()
-- 	local perishable = inst.components.perishable
-- 	if perishable:IsFresh() then
-- 		perishable:SetPercent(.49)
-- 	elseif perishable:IsStale() then
-- 		perishable:SetPercent(.15)
-- 	elseif perishable:IsSpoiled() then
-- 		perishable.perishremainingtime = 1
-- 	end
--     -- GetPlayer().components.playercontroller:ShakeCamera(inst, "FULL", 0.7, 0.02, 2, 40)
-- end

-- local function ham_fn(inst)
-- 	WARGON_CMP_EX.add_cmps(inst, {
-- 		inspect = {},
-- 		machine = {time=0, on=ham_on},
-- 		perish = {time=TUNING.PERISH_MED, spoil="spoiled_food"},
-- 		pounder = {destroy=true, rings={dmg=0, destroy=1}, num=1},
-- 	})
-- 	inst.Transform:SetScale(1.6,1.6,1.6)
-- 	inst.on_drop = ham_on_drop
-- end

local function bench_fn(inst)
	
end

local function chest_open(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("open")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
	end
end

local function chest_close_update(inst)
	local items = {
		"cutgrass", "twigs", "log",
		"goldnugget", "nightmarefuel", "pigskin",
		"livinglog", "cutreeds", "flint",
	}
	local container = inst.components.container
	-- container:RemoveAllItems()
	for i = 1, 9 do
		local item = SpawnPrefab(items[i])
		-- container:GiveItem(item, i)
		container.slots[i] = item
	end
end

local function chest_close(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("close")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
		chest_close_update(inst)
	end
end

local function chest_test(inst, item, slot)
	return false
end

local function chest_ham(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	-- if inst.components.container then inst.components.container:DropEverything() end
	-- SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	WARGON.make_fx(inst, "collapse_small")
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")	
	inst:Remove()
end

local function chest_hit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("closed", true)
		if inst.components.container then 
			-- inst.components.container:DropEverything()
			inst.components.container:Close()
		end
	end
end

local function chest_built(inst, data)
	chest_close_update(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", true)
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/chest")
end

local function chest_item_lose(inst, data)
	local player = GetPlayer()
	player.components.health:DoDelta(-15)
end

local function chest_save(inst, data)
end

local function chest_load(inst, data)
	chest_close_update(inst)
end

local function chest_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		cont = {num=9, open=chest_open, close=chest_close, widgets={}, test=chest_test},
		work = {act=ACTIONS.HAMMER, num=2, ham=chest_ham, hit=chest_hit},
		loot = {},
	})
	WARGON.add_tags(inst, {'chest', 'tp_chest'})
	WARGON.add_listen(inst, {
		onbuilt = chest_built,
		itemlose = chest_item_lose,
	})
	MakeSnowCovered(inst, 0.01)	
	-- WARGON.make_burn(inst, 'small', nil, nil, true)
	-- WARGON.make_prop(inst, 'small')
	inst.OnSave = chest_save
	inst.OnLoad = chest_load
end

local function MakeStructure(name, anims, structure_fn, phy, map)
	local function fn()
		local the_phy = nil
		if phy then
			the_phy = {'obs', phy[1], phy[2]}
		end
		local inst = WARGON.make_prefab(anims, nil, the_phy, nil, nil, structure_fn)
		if type(map) == "table" then
			WARGON.make_map(inst, map[1], map[2])
		elseif map ~= nil then
			WARGON.make_map(inst, map)
		end
		WARGON.add_tags(inst, {"structure"})
		return inst
	end

	return Prefab("common/objects/"..name, fn, {})
end

return 
	-- MakeStructure("tp_hambat_wall", hams, ham_fn, ham_phy),
	MakeStructure("tp_tent", tents, tent_fn, tent_phy, tent_map),
	MakePlacer("common/tp_tent_placer", tents[1], tents[2], tents[3], nil, nil, nil, 1.2),
	MakeStructure("tp_chest", boxes, chest_fn, nil, box_map),
	MakePlacer("common/tp_chest_placer", boxes[1], boxes[2], boxes[3])