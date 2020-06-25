local pigs = {"pigman", "pig_build", "idle_loop"}
local pig_phy = {'char', 50, .5}
local pig_shadow = {1.5, 7.5}

local fire_randloot = {
	meat = 3,
	ash = 1,
}
local ice_randloot = {
	meat = 3,
	ice = 1,
}
local poison_randloot = {
	meat = 3,
	venomgland = 1,
}

local share_target_dist = 30
local max_target_share = 5

local function pig_talk(inst, script)
	inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
end

local function pig_trader_test(inst, item)
	if inst.components.sleeper:IsAsleep() then return false end
	if item.components.equippable and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
		return true
	end
	if item.components.edible then
		local typ = item.components.edible.foodtype
		if typ == "MEAT" or typ == "HORRIBLE" or typ == "VEGGIE" then
			return true
		end
	end
end

local function pig_accept(inst, giver, item)
	if item.components.edible then
		local typ = item.components.edible.foodtype
		if typ == "MEAT" or typ == "HORRIBLE" then
			if inst.components.combat.target == giver then
				inst.components.combat:SetTarget(nil)
			elseif giver.components.leader then
				inst.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
				giver.components.leader:AddFollower(inst)
				inst.components.follower:AddLoyaltyTime(item.components.edible:GetHunger() * TUNING.PIG_LOYALTY_PER_HUNGER)
			end
		end
		if inst.components.sleeper:IsAsleep() then
			inst.components.sleeper:WakeUp()
		end
	end
	if item.components.equippable and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
		local current = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		if current then
			inst.components.inventory:DropItem(current)
		end
		inst.components.inventory:Equip(item)
		inst.AnimState:Show('hat')
	end
end

local function pig_refuse(inst, giver, item)
	inst.sg:GoToState("refuse")
	if inst.components.sleeper:IsAsleep() then
		inst.components.sleeper:WakeUp()
	end
end

local function pig_san_fn(inst, observer)
	if inst.components.follower and inst.components.follower.leader == observer then
		return TUNING.SANITYAURA_SMALL
	end
	return 0
end

local function pig_attacked(inst, data)
	local attacker = data.attacker
	inst:ClearBufferedAction()
	if attacker then
		inst.components.combat:SetTarget(attacker)
		if not attacker:HasTag("tp_pig") then
			inst.components.combat:ShareTarget(attacker, share_target_dist, function(guy)
				return guy:HasTag("tp_pig")
			end, max_target_share)
		end
	end
end

local function pig_newcombattarget(inst, data)
	inst.components.combat:ShareTarget(data.target, share_target_dist, function(guy)
		return guy:HasTag("tp_pig")
	end, max_target_share)
end

local function pig_keep(inst, target)
	return inst.components.combat:CanTarget(target)
end

local function pig_retarget(inst, target)
	return WARGON.find(inst, TUNING.PIG_TARGET_DIST, function(guy)
		return guy:HasTag("monster") and guy.components.health 
		and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy)
	end)
end

local function fire_atk(inst, target, damage)
	if target.components.burnable and not target.components.burnable:IsBurning() then
        if target.components.freezable and target.components.freezable:IsFrozen() then           
            target.components.freezable:Unfreeze()            
        else
            target.components.burnable:Ignite(true)
        end   
    end

    if target.components.freezable then
        target.components.freezable:AddColdness(-1) --Does this break ice staff?
        if target.components.freezable:IsFrozen() then
            target.components.freezable:Unfreeze()            
        end
    end

    if target.components.sleeper and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end
end

local function ice_atk(inst, target, damage)
    if target.components.freezable then
        target.components.freezable:AddColdness(1)
        target.components.freezable:SpawnShatterFX()
    end
    if target.components.sleeper and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end
    if target.components.burnable and target.components.burnable:IsBurning() then
        target.components.burnable:Extinguish()
    end
end

local function poison_atk(inst, target, damage)
	if target.components.poisonable and target:HasTag("poisonable") then
        target.components.poisonable:Poison()
    end 
end

local function MakeChar(name, anims, randloot, block_poison, atk_fn, colour)
	local function fn()
		local inst = WARGON.make_prefab(anims, nil, pig_phy, pig_shadow, 4)
		local ddebug = WARGON.add_print
		WARGON_CMP_EX.add_cmps(inst, {
			talk = {talk=pig_talk},
			loco = {run=5, walk=3},
			eater = {typ='all', hor=true},
			combat = {symbol='pig_torso', dmg=TUNING.PIG_DAMAGE, per=TUNING.PIG_ATTACK_PERIOD,
				keep=pig_keep, re={time=3, fn=pig_retarget}, atk=atk_fn},
			follow = {max = TUNING.PIG_LOYALTY_MAXTIME},
			health = {max=TUNING.PIG_HEALTH},
			inv = {},
			loot = {rand=randloot, ranum=1},
			trader = {test=pig_trader_test, accept=pig_accept, refuse=pig_refuse},
			san_aoe = {fn=pig_san_fn},
			sleep = {resist=2},
			inspect = {},
		})
		if not block_poison then WARGON.make_poi(inst) end
		WARGON.add_tags(inst, {'character', 'tp_pig', 'scarytopery'})
		inst.AnimState:Hide('hat')
		WARGON.make_burn(inst, 'med', 'pig_torso')
		WARGON.make_free(inst, 'med', 'pig_torso')
		WARGON.add_listen(inst, {
			attacked = pig_attacked,
			newcombattarget = pig_newcombattarget,
		})
		inst.AnimState:SetMultColour(colour[1], colour[2], colour[3], colour[4])
		inst:SetBrain(WARGON_BRAIN_EX.member_brain(true, 'player'))
		inst:SetStateGraph("SGtp_pig")

		return inst
	end

	return Prefab("common/character/"..name, fn, {})
end

return MakeChar("tp_pig_fire", pigs, fire_randloot, false, fire_atk, {1, .1, .1, 1}),
	MakeChar("tp_pig_ice", pigs, ice_randloot, false, ice_atk, {.1, .1, 1, 1}),
	MakeChar("tp_pig_poison", pigs, poison_randloot, false, poison_atk, {.1, 1, .1, 1})