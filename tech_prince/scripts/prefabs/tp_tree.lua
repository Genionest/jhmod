local trees = {}
local function add_trees(new_trees)
	for k, v in pairs(new_trees) do
		table.insert(trees, v)
	end
end

local function kill_fx(inst)
	if inst.fx then
		inst.fx:kill(inst.fx)
		inst.fx = nil
	end
end

local function spawn_fx(inst)
	if not inst.fx then
		inst.fx = WARGON.make_fx(inst, "tp_fx_spore_three")
		inst.fx.num = inst.components.growable.stage
	end
end

local function spawn_blue_fx(inst)
	if not inst.fx then
		inst.fx = WARGON.make_fx(inst, "tp_fx_spore_three")
		inst.fx.num = inst.components.growable.stage
		inst:AddTag("spore_blue")
	end
end

local function growth_tree(inst, last_stage, stage)
	kill_fx(inst)
	spawn_fx(inst)
end

local function on_ignite_tree(inst)
	kill_fx(inst)
end

local function on_extinguish_tree(inst)
	spawn_fx(inst)
end

local function growth_gingko(inst, last_stage, stage)
	kill_fx(inst)
	spawn_blue_fx(inst)
end

local function on_extinguish_gingko(inst)
	spawn_blue_fx(inst)
end

local gingko_builds =
{
	normal = {
		file="tp_gingko_tree",
		prefab_name="tp_gingko_tree",
		normal_loot = {"log", "log", "tp_gingko"}, -- "jungletreeseed"
		short_loot = {"log"},
		tall_loot = {"log", "log", "log", "tp_gingko", "tp_gingko"}, -- "jungletreeseed", "jungletreeseed"
	},
}
local function gingko_fn(inst)
	WARGON.do_task(inst, 0, function()
		spawn_blue_fx(inst)
	end)
	WARGON.add_listen(inst, {
		onignite = on_ignite_tree,
		onextinguish = on_extinguish_gingko,
		})
	inst.components.growable:SetOnGrowthFn(growth_gingko)
end

local function gingko_on_chop(inst)
end

local function gingko_on_chop_down(inst)
	kill_fx(inst)
	WARGON.make_fx(inst, "fall_mangrove_blue")
end

-- name, builds, bank, fix_fn, on_chop_fn, on_chop_down_fn, chop_fx, minimap, inspect_fn, stump_loot, growth_stages, on_burnt_fn
local gingko_trees = 
WARGON.TREE.create_trees("tp_gingko_tree", gingko_builds, "clawtree", gingko_fn, gingko_on_chop, gingko_on_chop_down, "chop_mangrove_blue", "tp_gingko_tree.tex", "nil")

local war_tree_builds = {
	normal = {
		file="evergreen_new",
		prefab_name="tp_war_tree",
		normal_loot = {"log", "log", "tp_war_tree_seed"},
		short_loot = {"log"},
		tall_loot = {"log", "log", "log", "tp_war_tree_seed", "tp_war_tree_seed"},
    },
}

local function war_tree_trader_test(inst, item)
	if inst.components.growable and inst.components.growable.stage >= 3 then
		return item:HasTag("tp_gingko")
	end
end

local function war_tree_trader_accept(inst, giver, item)
	local leif = WARGON.make_spawn(inst, "leif")
	local scale = 1.25
	WARGON.set_scale(leif, scale)
	local r, g, b, a = inst.AnimState:GetMultColour()
	leif.AnimState:SetMultColour(r,g,b,a)
	leif.components.locomotor.walkspeed = leif.components.locomotor.walkspeed*scale
	leif.components.combat.defaultdamage = leif.components.combat.defaultdamage*scale
	leif.components.health.maxhealth = leif.components.health.maxhealth*scale
	leif.components.health.currenthealth = leif.components.health.currenthealth*scale
	leif.components.combat.hitrange = leif.components.combat.hitrange*scale
	leif.components.combat.attackrange = leif.components.combat.attackrange*scale
	leif.sg:GoToState('spawn')

	leif:AddTag("tp_war_tree")
	leif.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
	giver.components.leader:AddFollower(leif)
    leif.components.follower:AddLoyaltyTime(30*16)
	
	kill_fx(inst)
	inst:Remove()
end

local function war_tree_fn(inst)
	inst.components.growable.loopstages = false
	WARGON.CMP.add_cmps(inst, {
		trader = {test=war_tree_trader_test, accept=war_tree_trader_accept},	
	})
	WARGON.do_task(inst, 0, function()
		spawn_fx(inst)
	end)
	WARGON.add_listen(inst, {
		onignite = on_ignite_tree,
		onextinguish = on_extinguish_tree,
		})
	inst.components.growable:SetOnGrowthFn(growth_tree)
end

local function war_tree_on_chop(inst)
end

local function war_tree_on_chop_down(inst)
	kill_fx(inst)
end

local war_trees = 
WARGON.TREE.create_trees("tp_war_tree", war_tree_builds, "evergreen_short", war_tree_fn, war_tree_on_chop, war_tree_on_chop_down, "pine_needles_chop", "evergreen.png", "nil")

local defense_tree_builds = {
	normal = { --Green
		file="tree_leaf_trunk_build",
		prefab_name="tp_defense_tree",
		normal_loot = {"log", "log", "tp_defense_tree_seed"},
		short_loot = {"log"},
		tall_loot = {"log", "log", "log", "tp_defense_tree_seed", "tp_defense_tree_seed"},
    },
}

local function defense_tree_spawn_nuter(inst, enemy)
	local pt = inst:GetPosition()
	WARGON.make_fx(inst, "bramblefx")
	-- for i = 1, math.random(2) do
		local pos = WARGON.around_land(inst, math.random(3))
		if pos then
			if WARGON.on_water(inst, pos) then
				WARGON.make_fx(pos, "splash_water_drop")
			else
				local nuter = SpawnPrefab("birchnutdrake")
				if enemy and nuter.components.combat:CanTarget(enemy) then
					nuter.Transform:SetPosition(pos:Get())
					nuter.components.combat:SetTarget(enemy)
					nuter.spawner_tree = inst
					nuter:AddTag("tp_defense_tree_nut")
					nuter.components.lootdropper.numrandomloot = 0
					WARGON.no_save(nuter)
				else
					nuter:Remove()
				end
			end
		end
	-- end
end

local function defense_tree_target(item, inst)
	return WARGON.is_monster(item) or item:HasTag("werepig")
end

local function defense_tree_near(inst)
	if inst.task == nil then
		inst.task = WARGON.per_task(inst, 3, function()
			if inst.components.growable.stage >= 3
			and not (inst:HasTag("fire") or inst:HasTag("burnt")) then
				local nuts = WARGON.finds(inst, 20, {"birchnutdrake", "tp_defense_tree_nut"})
				local num = 0
				for k, v in pairs(nuts) do
					if v.spawner_tree == inst then
						num = num + 1
					end
				end
				if num < 3 and #nuts < 8 then
					local ent = WARGON.find(inst, 15, defense_tree_target, nil, 
						{"birchnutdrake", "birchnut", "birchnutroot", "tree", "player"})
					if ent then
						defense_tree_spawn_nuter(inst, ent)
					end
				end
			end
		end)
	end
end

local function defense_tree_far(inst)
	if inst.task then
		inst.task:Cancel()
		inst.task = nil
	end
end

local function defense_tree_fn(inst)
	inst.AnimState:OverrideSymbol("swap_leaves", "tree_leaf_green_build", "swap_leaves")
	inst.components.growable.loopstages = false
	inst:AddTag("tp_defense_tree")
	WARGON.CMP.add_cmps(inst, {
		near = {dist={12,15}, near=defense_tree_near, far=defense_tree_far}	
	})
	WARGON.do_task(inst, 0, function()
		spawn_fx(inst)
	end)
	WARGON.add_listen(inst, {
		onignite = on_ignite_tree,
		onextinguish = on_extinguish_tree,
		})
	inst.components.growable:SetOnGrowthFn(growth_tree)
end

local function defense_tree_on_chop(inst)
end

local function defense_tree_on_chop_down(inst)
	if inst.task then
		inst.task:Cancel()
		inst.task = nil
	end
	kill_fx(inst)
end

local defense_trees = 
WARGON.TREE.create_trees("tp_defense_tree", defense_tree_builds, "tree_leaf", defense_tree_fn, defense_tree_on_chop, defense_tree_on_chop_down, "green_leaves_chop", "tree_leaf.png", "nil")

add_trees(gingko_trees)
add_trees(war_trees)
add_trees(defense_trees)

return unpack(trees)