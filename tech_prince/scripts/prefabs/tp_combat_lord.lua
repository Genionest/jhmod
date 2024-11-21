local assets = {
	Asset("ANIM", "anim/willow.zip"),
}

local Anims = {
	willow = {"wilson", "willow", "idle_loop", },
	wendy = {"wilson", "wendy", "idle_loop", },
	wathgrithr = {"wilson", "wathgrithr", "idle_loop", },
}
local wathgrithrs = {"wilson", "wathgrithr", "idle_loop"}
local willows = {"wilson", "willow", "idle_loop"}
local wendys = {"wilson", "wendy", "idle_loop"}
local phys = {"char", 75, .5}
local shadows = {1.3, .6}

local function combat_lord_combat_re(inst)
	return WARGON.find(inst, 16*1.33, function(guy)
        return inst.components.combat:CanTarget(guy)
           and guy:HasTag("player")
    end)
end

local function combat_lord_combat_keep(inst, target)
	return inst.components.combat:CanTarget(target)
       -- and target:HasTag("player")
end

local function combat_lord_on_attacked(inst, data)
	if data.attacker then
		inst.components.combat:SetTarget(data.attacker)
		inst.components.combat:ShareTarget(data.attacker, 30, function(dude) 
	    	return dude:HasTag("tp_combat_lord") 
	    end, 5)
	end
end

local function combat_lord_on_hit_other(inst, data)
	if data.target.components.tpbuff then
		data.target.components.tpbuff:AddBuff("tp_wound")
	end
end

local function combat_lord_on_health_delta(inst, data)
	-- if inst.prefab == "tp_combat_lord"
	-- and inst.components.health:GetPercent() < .3
	-- and inst.spawn_friend then
	-- 	for i = 1, 2 do
	-- 		WARGON.do_task(inst, i, function()
	-- 			local pos = WARGON.around_land(inst, 4)
	-- 			if pos then
	-- 				WARGON.make_fx(pos, "statue_transition")
	-- 				local lord = WARGON.make_spawn(pos, "tp_combat_lord"..i)
	-- 				local target = inst.components.combat.target
	-- 				if target then
	-- 					lord.components.combat:SetTarget(target)
	-- 				end
	-- 			end
	-- 		end)
	-- 	end
	-- 	inst.spawn_friend = false
	-- end
end

local function combat_lord_on_death(inst, data)
	if inst.prefab == "tp_combat_lord" and inst.spawn_friend then
		for i = 1, 2 do
			WARGON.do_task(inst, i, function()
				local pos = WARGON.around_land(inst, 4)
				if pos then
					WARGON.make_fx(pos, "statue_transition")
					local lord = WARGON.make_spawn(pos, "tp_combat_lord"..i)
					local target = inst.components.combat.target
					if target then
						lord.components.combat:SetTarget(target)
					end
				end
			end)
		end
		inst.spawn_friend = false
	end
end

local function combat_lord_can_attacked(inst, attacker)
	return (not inst.components.health:IsInvincible())
		or (not attacker:HasTag("tp_combat_lord"))
end

local function MakeLord(name, anims)
	local function fn()
		local inst = WARGON.make_prefab(anims, nil, phys, shadows, 4)
		inst:AddTag("tp_sign_damage")
		inst:AddTag("epic")
		inst:AddTag("tp_only_player_attack")
		inst:AddTag("tp_combat_lord")
		WARGON.CMP.add_cmps(inst, {
			inspect = {},
			health = {max=1250, fire=0, regen={20, 5}},
			loco = {walk=4, run=6},
			combat = {
				dmg=150, player=.5, per=2, range={10, 3},
				re={time=3, fn=combat_lord_combat_re},
				keep=combat_lord_combat_keep,
			},
			loot = {loot={
				"tp_epic", "tp_epic", "tp_epic", "tp_epic", "tp_epic", 
				"tp_bench_bp"}, },
		})
		inst.components.combat.canbeattackedfn = combat_lord_can_attacked
		inst:AddTag("groundpoundimmune")
	    inst:AddComponent("groundpounder")
	    inst.components.groundpounder.damageRings = 3
	    inst.components.groundpounder.numRings = 5
		WARGON.EQUIP.body_on(inst, "armor_wood_fangedcollar", "swap_body")
		WARGON.EQUIP.hat_on(inst, "footballhat_combathelm", nil, true)
		WARGON.EQUIP.object_on(inst, "swap_spear_forge_gungnir", "swap_spear_gungnir")
		WARGON.add_listen(inst, {
			attacked = combat_lord_on_attacked,
			onhitother = combat_lord_on_hit_other,
			healthdelta = combat_lord_on_health_delta,
			death = combat_lord_on_death,
		})
		if name == "tp_combat_lord" then
			inst.spawn_friend = true
		end
		-- inst:SetPrefabName("tp_combat_lord")
		inst:SetBrain(require "brains/tp_sign_rider_brain")
		inst:SetStateGraph("SGtp_combat_lord")
		inst.OnSave = function(inst, data)
			if data then
				data.spawn_friend = inst.spawn_friend
			end
		end
		inst.OnLoad = function(inst, data)
			if data then
				inst.spawn_friend = data.spawn_friend
			end
		end

		return inst
	end
	return Prefab("common/"..name, fn, assets)
end

return
MakeLord("tp_combat_lord", Anims.wathgrithr),
MakeLord("tp_combat_lord1", Anims.willow),
MakeLord("tp_combat_lord2", Anims.wendy)
-- return 
-- 	MakeLord("tp_combat_lord", wathgrithrs),
-- 	MakeLord("tp_combat_lord1", willows),
-- 	MakeLord("tp_combat_lord2", wendys)
