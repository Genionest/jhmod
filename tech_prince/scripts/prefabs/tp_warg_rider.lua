local woodies = {"wilsonbeefalo", "woodie", "idle_loop"}
local wargs = {"warg", "warg_build", "idle_loop"}
-- local wargs = {"tp_blue_warg", "tp_blue_warg", "idle"}
local physics = {"char", 1000, 2}
local shadows = {2.5, 1.5}

local function warg_rider_combat_re(inst)
	return WARGON.find(inst, 16*1.33, function(guy)
        return inst.components.combat:CanTarget(guy)
           and guy:HasTag("player")
    end)
end

local function warg_rider_combat_keep(inst, target)
	return inst.components.combat:CanTarget(target)
end

local function warg_rider_on_attacked(inst, data)
	if data.attacker then
		inst.components.combat:SetTarget(data.attacker)
	end
end

local function ride_warg(inst)
	if inst.warg_head == nil then
		inst.warg_head = SpawnPrefab("tp_fx_warg_head")
		inst.warg_head = SpawnPrefab("tp_fx_warg_body")
	end
	if inst.warg_rider == nil then
		inst.warg_rider = SpawnPrefab("tp_fx_woodie_rider")
		inst.warg_rider:anim_object_on("tp_spear_thunder", "swap_object")
	end
	inst:AddChild(inst.warg_rider)
	-- inst.warg_rider:AddChild(inst.warg_head)
	inst:AddChild(inst.warg_head)
	inst.task = inst:per_task(0, function()
		-- local down = TheCamera:GetDownVec()
		-- local angle = math.atan2(down.z, down.x)
		-- local dx = math.cos(angle) > 0 and 1 or -1
		-- local dz = math.sin(angle) > 0 and 1 or -1
		-- local dx = down.x > 0 and 1 or -1
		-- local dz = down.z > 0 and 1 or -1
		local rot = inst.Transform:GetRotation()
		inst.warg_rider.Transform:SetRotation(rot)
		inst.warg_head.Transform:SetRotation(rot)
		-- local angle = rot * DEGREES
		-- local dx = math.cos(angle)
		-- local dz = math.sin(angle)
		-- inst.warg_rider:set_pos(.1*dx, 0, .1*dz)
		-- inst.warg_head:set_pos(.2*dx, 0, .2*dz)
	end)
end
-- local down=TheCamera:GetDownVec();print(down.x, down.z)

local function fn()
	-- local inst = WARGON.make_prefab(wargs, nil, physics, shadows, 4)
	local inst = WARGON.make_prefab(woodies, nil, physics, shadows, 6)
	local anim = inst.AnimState
	-- anim:Hide("beefalo_head")
	-- anim:Hide("beefalo_antler")
	-- anim:Hide("beefalo_body")

	-- anim:Hide("beefalo_hoof")
	-- anim:Hide("beefalo_tail")
	-- anim:Hide("beefalo_facebase")
	-- anim:Hide("beefalo_mouth")
	-- anim:Hide("beefalo_eye")
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		loco = {walk=2, run=7},
		combat = {dmg=150, range={4, 5}, per=2,
			re={time=3, fn=warg_rider_combat_re},
			keep=warg_rider_combat_keep,
			player=.5},
		health = {max=2500, regen={5, 20}, fire=0},
		loot = {loot={"tp_boss_loot",
			"tp_epic", "tp_epic", "tp_epic", "tp_epic", "tp_epic",},
		},
		san_aoe = {value=-TUNING.SANITYAURA_LARGE},
		inv = {},
		})
	-- WARGON.make_map(inst, 'tent.png')
	WARGON.add_tags(inst, {
		"epic", "scarytoprey", "tp_sign_damage",
	})
	WARGON.add_listen(inst, {
		attacked = warg_rider_on_attacked,
		})
	inst:SetBrain(require "brains/tp_sign_rider_brain")
	inst:SetStateGraph('SGtp_warg_rider')
	inst.atk_num = 0
	inst:do_task(0, function()
		ride_warg(inst)
	end)

	return inst
end

return Prefab("common/tp_warg_rider", fn, {})