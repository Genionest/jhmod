local werepigs = {'pigman', 'werepig_build', 'idle_loop'}
local werepig_phy = {'char', 50, .5}
local werepig_shadow = {1.5, 7.5}

local function werepig_king_combat_re(inst)
	return WARGON.find(inst, 16*1.33, function(guy)
        return inst.components.combat:CanTarget(guy)
           and not guy:HasTag("werepig")
           and not (guy.sg and guy.sg:HasStateTag("transform") )
           and not guy:HasTag("alwaysblock")
    end)
end

local function werepig_king_combat_keep(inst, target)
	return inst.components.combat:CanTarget(target)
       and not target:HasTag("werepig")
       and not (target.sg and target.sg:HasStateTag("transform") )
end

local function werepig_king_on_hit(inst, data)
	local attacker = data.attacker
    inst:ClearBufferedAction()

    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, 30, function(dude) 
    	return dude:HasTag("werepig") 
    end, 5)
end

local function werepig_king_on_new_target(inst, data)
	if data.target then
		inst.components.combat:ShareTarget(data.target, 30, function(dude)
			return dude:HasTag("werepig")
		end, 5)
	end
end

local function werepig_king_attack(inst, data)
	if inst.diff and data.target then
	-- if WARGON.CONFIG.diff and data.target then
		if data.target.components.health then
			local max = data.target.components.health.maxhealth
			data.target.components.health:DoDelta(-max/10)
			if inst.components.health then
				inst.components.health:DoDelta(max/10)
			end
		end
	end
end

local function werepig_king_san_aoe(inst, observer)
	return -TUNING.SANITYAURA_LARGE
end

local function werepig_king_update(inst)
	local clock = GetClock()
	if clock:IsDay() then
		WARGON.CMP.add_cmps(inst, {
			combat = {dmg=150, range={3}},
			health = {regen={5, 20}, absorb=0},
		})
		WARGON.set_scale(inst, 1.5)
	elseif clock:IsDusk() then
		WARGON.CMP.add_cmps(inst, {
			combat = {dmg=200, range={3}},
			health = {regen={5, 50}, absorb=.3},
		})
		WARGON.set_scale(inst, 1.7)
	elseif clock:IsNight() then
		if clock:GetMoonPhase() == "full" then
			WARGON.CMP.add_cmps(inst, {
				combat = {dmg=300, range={4}},
				health = {regen={5,200}, absorb=.8},
			})
			WARGON.set_scale(inst, 2)
		else
			WARGON.CMP.add_cmps(inst, {
				combat = {dmg=250, range={3}},
				health = {regen={5,100}, absorb=.5},	
			})
			WARGON.set_scale(inst, 1.9)
		end
	end
end

local function werepig_king_on_save(inst, data)
	if data then
		-- data.can_trans = inst.can_trans
	end
end

local function werepig_king_on_load(inst, data)
	-- werepig_king_update(inst)
	if data then
		-- inst.can_trans = data.can_trans
	end
end

local function werepig_king_load_post_pass(inst, ents, data)
end

local function MakeKing(name, king_fn, sp_loot)
	local function fn()
		local inst = WARGON.make_prefab(werepigs, nil, werepig_phy, werepig_shadow, 4)
		WARGON.CMP.add_cmps(inst, {
			loco = {run=7, walk=4},
			combat = {dmg=150, range={3},
				symbol='pig_torso', per=3,
				re={time=3, fn=werepig_king_combat_re},
				keep=werepig_king_combat_keep,
				player=.5},
			health = {max=2250, regen={5, 20}, absorb=0, fire=0},
			loot = {loot={sp_loot, 
				"tp_epic", "tp_epic", "tp_epic", "tp_epic", "tp_epic", }},
			san_aoe = {fn=werepig_king_san_aoe},
			inspect = {},
			tpwerepigspawner = {},
			leader = {},
			tpmadmaker = {},
		})
		
		WARGON.add_tags(inst, {
			'character', 'pig', 'scarytopery', 'werepig', 'epic',
			"tp_sign_damage", "tp_werepig_king", "monster",
			})
		WARGON.add_listen(inst, {
			attacked = werepig_king_on_hit,
			newcombattarget = werepig_king_on_new_target,
			-- onhitother = werepig_king_attack,
		})
		-- inst.AnimState:Show('hat')
		WARGON.EQUIP.hat_on(inst, 'beefalohat_pigking')
		WARGON.set_scale(inst, 1.5)
		inst.atk_num = 1
		-- inst.can_trans = true
		-- inst.OnSave = werepig_king_on_save
		-- inst.OnLoad = werepig_king_on_load
		-- inst.LoadPostPass = werepig_king_load_post_pass
		inst:SetBrain(require 'brains/tp_werepig_king_brain')
		inst:SetStateGraph('SGtp_werepig_king')

		if king_fn then
			king_fn(inst)
		end

		return inst
	end

	return Prefab('common/monster/'..name, fn, {})
end

local function moon_lord_fn(inst)
	inst.components.tpwerepigspawner.pigs = {
		tp_pig_fire = 1, tp_pig_ice = 1, tp_pig_poison = 1,
		tp_pig_blood = 1, tp_pig_thunder = 1, tp_pig_shadow = 1,
	}
	inst:ListenForEvent("nighttime", function()
		werepig_king_update(inst)
	end, GetWorld())
	inst:ListenForEvent("dusktime", function()
		werepig_king_update(inst)
	end, GetWorld())
	inst:ListenForEvent("daytime", function()
		werepig_king_update(inst)
	end, GetWorld())
	WARGON.do_task(inst, 0, function()
		werepig_king_update(inst)
	end)
end

local function blood_lord_on_health_delta(inst)
	local p = inst.components.health:GetPercent()
	WARGON.add_dmg_rate(inst, "tp_blood_lord", 10-p*10)
end

local function blood_lord_fn(inst)
	inst.AnimState:SetMultColour(1, .1, .1, 1)
	inst.components.tpwerepigspawner.pigs = {
		tp_pig_blood = 6,
	}
	inst:ListenForEvent("healthdelta", function()
		blood_lord_on_health_delta(inst)
	end)
	inst:ListenForEvent("onhitother", function(inst, data)
		if data and data.damage then
			inst.components.health:DoDelta(data.damage)
		end	
	end)
	WARGON.do_task(inst, 0, function()
		blood_lord_on_health_delta(inst)
	end)
end

local function thunder_lord_fn(inst)
	inst.AnimState:SetMultColour(.1, .1, 1, 1)
	inst.components.tpwerepigspawner.pigs = {
		tp_pig_thunder = 6,
	}
	inst:ListenForEvent("attacked", function(inst, data)
		if data and data.attacker and data.attacker.components.health then
            if (data.weapon == nil or (not data.weapon:HasTag("projectile") and data.weapon.projectile == nil)) 
            and (data.attacker ~= GetPlayer() or (data.attacker == GetPlayer() and not GetPlayer().components.inventory:IsInsulated())) then
                data.attacker.components.health:DoDelta(-TUNING.LIGHTNING_GOAT_DAMAGE)
                if data.attacker == GetPlayer() then
                    data.attacker.sg:GoToState("electrocute")
                end
            end
        end
	end)
	WARGON.do_task(inst, 0, function()
		WARGON.EQUIP.equip_temp_weapon(inst, 150, {8, 11}, "bishop_charge")
	end)
end

local function fire_lord_fn(inst)
	inst.AnimState:SetMultColour(1, 1, .1, 1)
	inst.components.tpwerepigspawner.pigs = {
		tp_pig_fire = 6,
	}
	inst:ListenForEvent("onhitother", function(inst, data)
		if data and data.target then
			WARGON.fire_prefab(data.target, inst)
		end
	end)
	inst:ListenForEvent("attacked", function(inst, data)
		if data and data.attacker then
			WARGON.fire_prefab(data.attacker, inst)
		end
	end)
	WARGON.per_task(inst, 1, function()
		local ents = WARGON.finds(inst, 4, nil, {"pig", "werepig", "tp_pig", "wall"})
		for k, v in pairs(ents) do
			if v and v:IsValid() and v.components.health 
			and not v.components.health:IsDead() then
				v.components.health:DoDelta(-3)
			end
		end
	end)
end

local function ice_lord_fn(inst)
	inst.AnimState:SetMultColour(.1, 1, 1, 1)
	inst.components.tpwerepigspawner.pigs = {
		tp_pig_ice = 6,
	}
	inst:ListenForEvent("onhitother", function(inst, data)
		if data and data.target then
			WARGON.frozen_prefab(data.target, inst, 4)
		end
	end)
	inst:ListenForEvent("attacked", function(inst, data)
		if data and data.attacker then
			WARGON.frozen_prefab(data.attacker, inst, 4)
		end
	end)
	WARGON.per_task(inst, 1, function()
		local ents = WARGON.finds(inst, 4, nil, {"pig", "werepig", "tp_pig", "wall"})
		for k, v in pairs(ents) do
			if v and v:IsValid() and v.components.temperature then
				local temp = v.components.temperature:GetCurrent()
        		v.components.temperature:SetTemperature(temp - 3)
			end
		end
	end)
end

local function poison_lord_fn(inst)
	inst.AnimState:SetMultColour(.1, 1, .1, 1)
	inst.components.tpwerepigspawner.pigs = {
		tp_pig_poison = 6,
	}
	inst:ListenForEvent("onhitother", function(inst, data)
		if data and data.target then
			if data.target.components.poisonable
			and data.target.components.poisonable:IsPoisoned() then
				if data.target.components.health then
					local max = data.target.components.health.maxhealth
					data.target.components.health:DoDelta(-max/10)
				end
			end
			WARGON.poison_prefab(data.target)
		end
	end)
	inst:ListenForEvent("onhitother", function(inst, data)
		if data and data.target then
			WARGON.poison_prefab(data.target)
		end
	end)
end

local function shadow_lord_fn(inst)
	inst.AnimState:SetMultColour(1, .1, 1, 1)
	inst.components.tpwerepigspawner.pigs = {
		tp_pig_shadow = 6,
	}
	inst:ListenForEvent("entity_death", function(world, data)
		if data.inst.prefab == "tp_shadow_lord" then
			if inst:HasTag("tp_shadow_lord_spawned") then
				inst:RemoveTag("tp_shadow_lord_spawned")
				inst.components.health:SetInvincible(false)
				inst.AnimState:SetMultColour(1, .1, 1, 1)
				WARGON.make_fx(inst, "statue_transition")
				inst:Remove()
			end
		end
	end, GetWorld())
	WARGON.do_task(inst, 0, function()
		if not inst:HasTag("tp_shadow_lord_spawned") then
			if c_countprefabs("tp_shadow_lord", true) <= 1 then
				local pos = WARGON.around_land(inst, 4)
				if pos then
					local lord = WARGON.make_spawn(pos, "tp_shadow_lord")
					lord.AnimState:SetMultColour(1, .1, 1, .5)
					lord.components.health:SetInvincible(true)
					lord:AddTag("tp_shadow_lord_spawned")
				end
			else
				local lord = c_find("tp_shadow_lord")
				lord.AnimState:SetMultColour(1, .1, 1, .5)
				lord.components.health:SetInvincible(true)
				lord:AddTag("tp_shadow_lord_spawned")
			end
		end
	end)
end

return 
	MakeKing("tp_werepig_king", moon_lord_fn, 'tp_desk_bp'),
	MakeKing("tp_blood_lord", blood_lord_fn, 'tp_boss_loot'),
	MakeKing("tp_thunder_lord", thunder_lord_fn, 'tp_boss_loot'),
	MakeKing("tp_fire_lord", fire_lord_fn, 'tp_boss_loot'),
	MakeKing("tp_ice_lord", ice_lord_fn, 'tp_boss_loot'),
	MakeKing("tp_poison_lord", poison_lord_fn, 'tp_boss_loot'),
	MakeKing("tp_shadow_lord", shadow_lord_fn, 'tp_boss_loot')