local assets = {
	Asset("ANIM", "anim/wes.zip")
}

local Anims = {
	wes = {"wilson", "wes", "idle_loop"},
}
local weses = {"wilson", "wes", "idle_loop"}
local phys = {"char", 75, .5}
local shadows = {1.3, .6}

local function fake_knight_combat_re(inst)
	return WARGON.find(inst, 16*1.33, function(guy)
        return inst.components.combat:CanTarget(guy)
           and guy:HasTag("player")
    end)
end

local function fake_knight_combat_keep(inst, target)
	return inst.components.combat:CanTarget(target)
       -- and target:HasTag("player")
end

local function fake_knight_on_attacked(inst, data)
	if data.attacker then
		inst.components.combat:SetTarget(data.attacker)
	end
end

local function fake_knight_on_hit_other(inst, data)
	if data.target.components.tpbuff then
		data.target.components.tpbuff:AddBuff("tp_armor_broken")
	end
end

local function fake_knight_on_health_delta(inst, data)
	if inst.components.health:GetPercent() < .9 then
		WARGON.CMP.add_cmps(inst, {
			health = {absorb=0},
		})
	end
end

local function fn()
	local inst = WARGON.make_prefab(Anims.wes, nil, phys, shadows, 4)
	-- local inst = WARGON.make_prefab(weses, nil, phys, shadows, 4)
	inst:AddTag("tp_sign_damage")
	inst:AddTag("epic")
	inst:AddTag("tp_only_player_attack")
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		health = {max=1500, fire=0, absorb=.8},
		loco = {walk=4, run=6},
		combat = {
			dmg=150, player=.5, per=2,
			re={time=3, fn=fake_knight_combat_re},
			keep=fake_knight_combat_keep,
		},
		loot = {loot={
			"tp_epic", "tp_epic", "tp_epic", "tp_epic", "tp_epic", 
			-- "tp_alloy", "redgem", "redgem",
			"tp_gift"}, },
	})
	WARGON.EQUIP.body_on(inst, "armor_metalplate", "swap_body")
	WARGON.EQUIP.hat_on(inst, "hat_metalplate", nil, true)
	WARGON.EQUIP.object_on(inst, "swap_halberd", "swap_halberd")
	WARGON.add_listen(inst, {
		attacked = fake_knight_on_attacked,
		onhitother = fake_knight_on_hit_other,
		healthdelta = fake_knight_on_health_delta,
	})
	WARGON.do_task(inst, 0, function()
		fake_knight_on_health_delta(inst)
	end)
	inst:SetBrain(require "brains/tp_fake_knight_brain")
	inst:SetStateGraph("SGtp_fake_knight")

	return inst
end

return Prefab("common/tp_fake_knight", fn, assets)
