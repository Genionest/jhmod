local small_birds = {'smallbird', 'tp_small_bird', 'idle'}
local small_bird_phy = {'char', 10, .25}
local small_bird_shadow = {1.25, .75}
local teen_birds = {'tallbird', 'tp_teen_bird', 'idle'}
local teen_bird_phy = {'char', 10, .25}
local teen_bird_shadow = {2.75, 1}
local krampuses = {'krampus', "krampus_hawaiian_build", "run_loop"}
local krampus_phy = {'char', 10, .5}
local krampus_shadow = {3, 1}

local function bird_on_save(inst, data)
	local ents
	if inst.leader then
		data.leader = inst.leader.GUID
		ents = {data.leader}
	end
	return ents
end

local function bird_on_load(inst, data)
end

local function bird_load_post_pass(inst, ents, data)
	if data.leader then
		local leader = ents[data.leader]
		if leader then
			inst.leader = leader.entity
		end
	end
end

local function bird_sleep_test(inst)
    return DefaultWakeTest(inst) or inst.components.hunger:IsStarving(inst) or not inst.components.follower:IsNearLeader(10)
end

local function bird_wake_test(inst)
    return DefaultSleepTest(inst) and not inst.components.hunger:IsStarving(inst) and inst.components.follower:IsNearLeader(7)
end

local function bird_trader_test(inst, item)
	if item.components.edible and inst.components.hunger and inst.components.eater then
        return inst.components.eater:CanEat(item) and inst.components.hunger:GetPercent() < .9
    end
end

local function bird_trader_accept(inst, giver, item)
	if inst.components.sleeper then
        inst.components.sleeper:WakeUp()
    end
    if item.components.edible then
        if inst.components.combat.target and inst.components.combat.target == giver then
            inst.components.combat:SetTarget(nil)
        end
		inst.components.eater:Eat(item)
    end
end

local function bird_eat(inst, food)
	if inst:HasTag("teenbird") then
        inst.components.health:DoDelta(inst.components.health.maxhealth * .33, nil, food.prefab)
        inst.components.combat:SetTarget(nil)
    else
        inst.components.health:DoDelta(inst.components.health.maxhealth, nil, food.prefab)
    end
end

local function bird_follow_leader(inst)
	local leader = GetPlayer()
	if leader and leader.components.leader then
		leader.components.leader:AddFollower(inst)
	end
end

local function bird_get_peep_chance(inst)
	local peep_percent = 0.1
    if inst.components.hunger then
        if inst.components.hunger:IsStarving() then
            peep_percent = 1
        elseif inst.components.hunger:GetPercent() < .25 then
            peep_percent = 0.9
        elseif inst.components.hunger:GetPercent() < .5 then
            peep_percent = 0.75
        end
    end
    return peep_percent
end

local function bird_spawn_teen(inst)
    local bird = WARGON.make_spawn(inst, 'tp_teen_bird')
    bird.sg:GoToState("idle")

    if inst.components.follower.leader then
        bird.components.follower:SetLeader(inst.components.follower.leader)
    end

    inst:Remove()
end

local function bird_combat_re(inst)
	local notags = {"FX", "NOCLICK","INLIMBO"}
    return WARGON.find(inst, TUNING.TEENBIRD_TARGET_DIST, function(guy)
        if inst.components.combat:CanTarget(guy) then
            return guy:HasTag("monster")
        end
    end, nil, notags)
end

local function bird_combat_keep(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function bird_on_attacked(inst, data)
	-- if data.attacker and inst.components.follower.leader ~= data.attacker then
	if data.attacker then
		inst.components.combat:SuggestTarget(data.attacker)
	end
end

local function bird_on_death(inst, data)
	if inst.components.container then
		inst.components.container:DropEverything()
	end
end

local function bird_fn(inst, fn)
	WARGON.add_tags(inst, {
		'animal', 'companion', 'character',
	})
	WARGON.make_poi(inst)
	inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(GetWorldCollision())
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.WAVES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
    WARGON.CMP.add_cmps(inst, {
    	inspect = {},
    	loco = {walk=6},
    	follow = {},
    	eat = {typ='all', eat=bird_eat},
    	-- sleep = {resist=3, sleep=bird_sleep_test, wake=bird_wake_test},
    	trader = {test=bird_trader_test, accept=bird_trader_accept},
    	combat = {symbol='head', range=TUNING.SMALLBIRD_ATTACK_RANGE,
			dmg=TUNING.SMALLBIRD_DAMAGE, per=TUNING.SMALLBIRD_ATTACK_PERIOD,
			-- re={time=3, fn=bird_combat_re},
			keep=bird_combat_keep},
		loot = {loot={'tp_bird_egg'}},
	})
	inst.OnSave = bird_on_save
	inst.OnLoad = bird_on_load
	inst.LoadPostPass = bird_load_post_pass
	inst.user_fn = {
		follow_leader = bird_follow_leader,
		get_peep_chance = bird_get_peep_chance,
		spawn_teen = bird_spawn_teen,
	}
	inst.userfunctions = {
		FollowLeader = bird_follow_leader,
		GetPeepChance = bird_get_peep_chance,
		SpawnTeen = bird_spawn_teen,
		SpawnAdult = function() end,
	}
	WARGON.add_listen(inst, {
		attacked = bird_on_attacked,
		death = bird_on_death,
		})

	if fn then fn(inst) end
    inst:SetBrain(require 'brains/tp_small_bird_brain')
end

local function small_bird_eater_test(inst, item)
	return (item.components.edible.foodtype == "SEEDS") 
		or (item.prefab == "berries")
end

-- slotpos, bank, build, pos, align
-- local small_bird_slotpos = {
-- 	Vector3(0,64+32+8+4,0), 
-- 	Vector3(0,32+4,0),
-- 	Vector3(0,-(32+4),0), 
-- 	Vector3(0,-(64+32+8+4),0),
-- }

-- local function small_bird_open(inst)
-- 	inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/wings")
-- 	inst.brain:Stop()
-- end

-- local function small_bird_close(inst)
-- 	inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/wings")
-- 	inst.brain:Start()
-- end

local function small_bird_fn(inst)
	bird_fn(inst)
	inst:AddTag("smallcreature")
	WARGON.make_burn(inst, 'c_small', 'head')
	WARGON.make_free(inst, 'c_small', 'head')
	WARGON.CMP.add_cmps(inst, {
		health = {max=250},
		hunger = {max=TUNING.SMALLBIRD_HUNGER, 
			rate=TUNING.SMALLBIRD_HUNGER/TUNING.SMALLBIRD_STARVE_TIME, 
			over=function() end},
		eat = {test=small_bird_eater_test},
		})
	local growth_stages = {
        -- {name="small", time = TUNING.SMALLBIRD_GROW_TIME, fn = function() end },
        {name="small", time = function() return 30*16*5 end, fn = function() end },
        {name="tall", fn = function() inst.sg:GoToState("growup") end}
    }

	inst:AddComponent("growable")
    inst.components.growable.stages = growth_stages
    inst.components.growable:SetStage(1)
    inst.components.growable:StartGrowing()

	inst:SetStateGraph('SGtp_small_bird')
end

local function teen_bird_fn(inst)
	bird_fn(inst)
	WARGON.set_scale(inst, .8)
	inst.AnimState:Hide('beakfull')
	inst:AddTag("teenbird")
	inst.Physics:SetCylinder(.5, 1)
	WARGON.make_burn(inst, 'c_large', 'head')
	WARGON.make_free(inst, 'c_med', 'head')
	WARGON.CMP.add_cmps(inst, {
		health = {max=500},
		hunger = {max=TUNING.TEENBIRD_HUNGER,
			rate=TUNING.TEENBIRD_HUNGER/TUNING.TEENBIRD_STARVE_TIME,
			over=function() end},
		combat = {symbol='head', range=TUNING.TEENBIRD_ATTACK_RANGE,
			re={time=3, fn=bird_combat_re}},
		loot = {loot={'meat'}},
		tpbepot = {},
		})
	inst:SetStateGraph('SGtallbird')
end

local function pot_bird_fn(inst)
	teen_bird_fn(inst)
	inst:add_cmps({
		loot = {},
	})
	inst:AddTag("tp_pot_bird")
	inst:DoTaskInTime(1.5, function(inst)
        if not TheSim:FindFirstEntityWithTag("tp_pot_bird_egg") then
            inst:Remove()
        end
	end)
	inst.OnSave = nil
	inst.OnLoad = nil
end

local function on_red_dragon_death(inst, data)
	if inst.components.container then
		inst.components.container:Close()
		inst.components.container:DropEverything()
	end
end

local function red_dragon_fn(inst)
	inst.AnimState:Hide("ARM")
	local slotpos = {}
	for y = 0, 6 do
		table.insert(slotpos, Vector3(-162, -y*75 + 240 ,0))
		table.insert(slotpos, Vector3(-162 +75, -y*75 + 240 ,0))
	end
	inst:add_tags({
		"scarytoprey", "monster", "scary_to_pig_guards", "krampus",
		"INTERIOR_LIMBO_IMMUNE", "tp_red_dragon", "companion",
	})
	inst:add_cmps({
		inspect = {},
		follow = {},
		cont = {},
		loco = {run=TUNING.KRAMPUS_SPEED},
		sleep = {},
		health = {max=400,
			regen={TUNING.CHESTER_HEALTH_REGEN_AMOUNT, 
				TUNING.CHESTER_HEALTH_REGEN_PERIOD}, },
		combat = {symbol="krampus_torso", dmg=TUNING.KRAMPUS_DAMAGE,
			per=TUNING.KRAMPUS_ATTACK_PERIOD},
		loot = {},
		knownlocations = {},
	})
    inst.components.container:SetNumSlots(#slotpos)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_krampusbag_2x8"
    inst.components.container.widgetanimbuild = "ui_krampusbag_2x8"
    inst.components.container.widgetpos = Vector3(0,200,0)
	inst.components.container.side_align_tip = 160 
	inst:add_listener("death", on_red_dragon_death)
	inst:SetStateGraph("SGkrampus")
	inst:SetBrain(require "brains/chesterbrain")
end

local function MakePet(name, anims, phys, shadows, faced, pet_fn)
	local function fn()
		local inst = WARGON.make_prefab(anims, nil, phys, shadows, faced)
		WARGON.add_tags(inst, {
			'tp_pet',
		})

		if pet_fn then pet_fn(inst) end

		return inst
	end
	return Prefab('common/'..name, fn, {}) 
end

return 
	MakePet('tp_small_bird', small_birds, small_bird_phy, small_bird_shadow, 
		4, small_bird_fn),
	MakePet('tp_pot_bird', teen_birds, teen_bird_phy, teen_bird_shadow, 
		4, pot_bird_fn),
	MakePet('tp_red_dragon', krampuses, krampus_phy, krampus_shadow, 
		4, red_dragon_fn),
	MakePet('tp_teen_bird', teen_birds, teen_bird_phy, teen_bird_shadow, 4, teen_bird_fn)