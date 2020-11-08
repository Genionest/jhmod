local rafts = {"raft", "raft_log_build", "run_loop"}
local grass_waters = {"grass_inwater", "grass_inwater", "idle"}
local mangroves = {"tree_mangrove", "tree_mangrove_build", "idle_short"}
local reedses = {"grass", "reeds", "idle"}
local bulb_plants = {"bulb_plant_single", "bulb_plant_single", "idle"}
local lily_pads = {"lily_pad", "lily_pad", "small_idle"}

local function onhit(inst, worker)
	-- inst.AnimState:PlayAnimation("hit")
	-- inst.AnimState:PushAnimation("run_loop", true)
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
    if inst.components.container then
        inst.components.container:DropEverything()
    end
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function common_place_test(inst, pt, tags, no_tags, any_tags)
	local range = 4
	local canbuild = true
	
	local x, z = math.floor(pt.x), math.floor(pt.z)
	pt.x = x
	pt.z = z
	inst.Transform:SetPosition(x, pt.y, z)
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, range, tags, no_tags)
	if #ents > 0 then
		if any_tags then
			if WARGON.has_tag(inst, any_tags) then
				canbuild = false
			end
		else
			canbuild = false
		end
	end
	return canbuild
end

-- local function placeTestFn(inst, pt)
-- 	local range = 4
-- 	local canbuild = true
	
-- 	local x, z = math.floor(pt.x), math.floor(pt.z)
-- 	pt.x = x
-- 	pt.z = z
-- 	inst.Transform:SetPosition(x, pt.y, z)
-- 	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, range, {"tp_structure_pot", 'structure'})
-- 	if #ents > 0 then
-- 		canbuild = false
-- 	end
-- 	-- if canbuild then

-- 	-- end
-- 	return canbuild
-- end

local function raft_place_test(inst, pt)
	return common_place_test(inst, pt, {"tp_structure_pot"}, nil)
end

local function raft_fn()
	local inst = WARGON.make_prefab(lily_pads, nil, nil, nil, nil, nil)
	-- local inst = WARGON.make_prefab(rafts, nil, nil, nil, nil, nil)
	inst.AnimState:PlayAnimation("small_idle", true)
	inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
	-- inst.Transform:SetRotation(math.random(360))
	inst:AddTag("NOCLICK")
	--
	inst.AnimState:SetLayer(2.5)
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	-- minimap:SetIcon("lograft.png" )
	minimap:SetIcon("lily_pad.png")
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	inst:AddComponent("lootdropper")
	inst:AddTag("tp_structure_pot")

	return inst
end

-- local function grass_place_test(inst, pt)
-- 	return common_place_test(inst, pt, {'tp_grass_water'}, nil)
-- end

-- local function mangrove_place_test(inst, pt)
-- 	return common_place_test(inst, pt, {'tp_mangrovetree'}, nil)
-- end

return 
	Prefab("common/object/tp_raft", raft_fn, {}),
	-- MakePlacer("common/tp_grass_water_placer", grass_waters[1], grass_waters[2], 
	-- 	grass_waters[3], nil, nil, nil, nil, nil, nil, nil, nil, nil,
	-- 	grass_place_test),
	-- MakePlacer("common/tp_mangrovetree_normal_placer", mangroves[1],
	-- 	mangroves[2], mangroves[3], nil, nil, nil, nil, nil, nil, 
	-- 	nil, nil, nil, mangrove_place_test),
	-- MakePlacer("common/tp_reeds_placer", reedses[1], reedses[2], 
	-- 	reedses[3]),
	-- MakePlacer("common/tp_flower_cave_placer", bulb_plants[1], bulb_plants[2], bulb_plants[3]),
	
	MakePlacer("common/tp_raft_placer", lily_pads[1], lily_pads[2], lily_pads[3],
	-- MakePlacer("common/tp_raft_placer", rafts[1], rafts[2], rafts[3],
	true, nil, nil, nil, nil, nil, nil, nil, nil, raft_place_test)
	-- nil, nil, nil, nil, nil, nil, nil, nil, nil, raft_place_test)