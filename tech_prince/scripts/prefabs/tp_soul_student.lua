local assets = {

}

local waxwells = {"wilson", "waxwell", "idle_loop"}
local phys = {"char", 75, .5}
local shadows = {1.3, .6}

local function soul_student_combat_re(inst)
	return WARGON.find(inst, 16*1.33, function(guy)
        return inst.components.combat:CanTarget(guy)
           and guy:HasTag("player")
    end)
end

local function soul_student_combat_keep(inst, target)
	return inst.components.combat:CanTarget(target)
       -- and target:HasTag("player")
end

local function soul_student_on_attacked(inst, data)
	if data.attacker then
		inst.components.combat:SetTarget(data.attacker)
		if inst:HasTag("tp_soul_student_warth") and math.random() < .3
		and inst:IsNear(data.attacker, 3) then
			inst.components.groundpounder:GroundPound()
		end
	end
end

local function soul_student_on_attack(inst, data)
	local target = inst.components.combat.target
	if target and inst:IsNear(target, 5) then
		local pos = WARGON.around_land(target, 12)
		if pos then
			WARGON.make_fx(inst, "statue_transition")
			WARGON.make_fx(pos, "statue_transition_2")
			inst.Transform:SetPosition(pos:Get())
		end
	end
	local ents = WARGON.finds(inst, 20, {"ghost"})
	local count = 0
	for k, v in pairs(ents) do
		count = count + 1
		if count >= 8 then
			inst.sg:GoToState("staff")
			break
		end
	end
end

local function soul_student_on_hit_other(inst, data)
	if data.target.components.tpmadvalue then
		data.target.components.tpmadvalue:DoDelta(5)
	end
end

local function soul_student_on_health_delta(inst, data)
	if inst.components.health:GetPercent() < .5 then
		inst:AddTag("tp_soul_student_warth")
	end
end

local function soul_student_weapon_drop(inst)
	inst:Remove()
end

local function soul_student_equip_weapon(inst)
	WARGON.EQUIP.equip_temp_weapon(inst, 0, {7, 10}, "tp_soul_student_proj")
end

local function fn()
	local inst = WARGON.make_prefab(waxwells, nil, phys, shadows, 4)
	WARGON.add_tags(inst, {
		"tp_sign_damage", "epic", "tp_only_player_attack", "noauradamage",
	})
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		health = {max=1500, fire=0,},
		loco = {walk=4, run=6},
		combat = {
			dmg=150, player=.5, per=2, 
			re={time=3, fn=soul_student_combat_re},
			keep=soul_student_combat_keep,
		},
		loot = {loot={
			"tp_epic", "tp_epic", "tp_epic", "tp_epic", "tp_epic", 
			"tp_hambat"}, },
		inv = {},
	})
	inst:AddComponent("groundpounder")
    -- inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 3
    -- inst.components.groundpounder.destructionRings = 4
    inst.components.groundpounder.numRings = 3
	-- WARGON.EQUIP.body_on(inst, "armor_metalplate", "swap_body")
	WARGON.EQUIP.hat_on(inst, "tophat_witch_pyre", nil, true)
	WARGON.EQUIP.object_on(inst, "swap_firestaff_meteor", "swap_redstaff")
	WARGON.add_listen(inst, {
		attacked = soul_student_on_attacked,
		onhitother = soul_student_on_hit_other,
		healthdelta = soul_student_on_health_delta,
		doattack = soul_student_on_attack,
	})
	WARGON.do_task(inst, 0, function()
		soul_student_on_health_delta(inst)
		soul_student_equip_weapon(inst)
	end)
	inst:SetBrain(require "brains/tp_fake_knight_brain")
	inst:SetStateGraph("SGtp_soul_student")

	return inst
end

local function proj_remove(inst)
	inst:Remove()
end

local function proj_hit(inst, owner, target)
	local n = math.random(4)
	local pos = target:GetPosition()
	for i = 1, 4 do
		-- local angle = i * 90 * PI/180
		-- local radius = 12
		-- local dx = math.cos(angle) * radius
		-- local dz = math.sin(angle) * radius
		local fx = SpawnPrefab("tp_fx_charge_surround")
		if n == i then
			fx:AddTag("tp_fx_charge_surround_attack")
		end
		-- fx.Transform:SetPosition(pos.x+dx, 0, pos.z+dz)
		fx.Transform:SetPosition(pos:Get())
		fx.Transform:SetRotation(i*90)
		fx.master = owner
		fx.target = target
	end
    inst:Remove()
end

local function proj()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.Transform:SetFourFaced()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    anim:SetBank("bishop_attack")
    anim:SetBuild("bishop_attack")
    anim:PlayAnimation("idle")
    
    inst:AddTag("projectile")
    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(20)
    -- inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(2)
    inst.components.projectile:SetOnHitFn(proj_hit)
    inst.components.projectile:SetOnMissFn(proj_remove)
    inst.components.projectile.speed_z = 15
    
    return inst
end

return Prefab("common/tp_soul_student", fn, assets),
	Prefab("common/tp_soul_student_proj", proj, {})