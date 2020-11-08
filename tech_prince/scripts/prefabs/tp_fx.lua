local easing = require("easing")

local chop_leafs = {"pine_needles", "pine_needles", "chop"}
local fall_leafs = {"pine_needles", "pine_needles", "fall"}
local chop_jungles = {"chop_jungle", "chop_jungle", "chop"}
local fall_jungles = {"chop_jungle", "chop_jungle", "fall"}
local green_leafs = {"tree_leaf_fx", "tree_leaf_fx_green", "fall"}
local green_leafs2 = {"tree_leaf_fx", "tree_leaf_fx_green", "chop"}
local green_leafs3 = {"chop_mangrove", "chop_mangrove", "chop"}
local green_leafs4 = {"chop_mangrove", "chop_mangrove", "fall"}
local small_meats = {"meat_small", "meat_small", "raw"}
local beargers = {"bearger", "bearger_build", "ground_pound"}
local dragonflys = {"dragonfly", "dragonfly_fire_build", "taunt_pre"}
local deerclopses = {"deerclops", "deerclops_build", "atk"}
local mooses = {"goosemoose", "goosemoose_build", "honk"}
local wilson_lunges = {"wilson", "wilson", "lunge_pst"}
local bloods = {"wortox_soul_heal_fx", "wortox_soul_heal_fx", "heal"}
local signs = {"sign_home", "sign_home", "place"}
local acorns = {"acorn", "acorn", "idle"}
local pinecones = {"pinecone", "pinecone", "idle"}
local jungletreeseeds = {"jungletreeseed", "jungletreeseed", "idle"}
local teatree_nuts = {"teatree_nut", "teatree_nut", "idle"}
local coconuts = {"coconut", "coconut", "idle"}
local poison_holes = {'poison_hole', 'poison_hole', 'pop'}
local spores = {"tp_spore", "tp_spore", "cough_out"} -- idle_flight_loop, flight_cycle, land
local spore_blues = {"tp_spore_blue", "tp_spore_blue", 'cough_out'}
local stafflights = {"star", "star", "appear"}
local snow_balls = {"firefighter_projectile", "firefighter_projectile", "spin_loop", nil}
local footballs = {"footballhat", "hat_football", "anim"}
local armorwoods = {"armor_wood", "armor_wood", "anim"}
local hambats = {"ham_bat", "ham_bat", "idle"}
local coffeebeanses = {'coffeebeans', 'coffeebeans', 'idle'}
local bandages = {'bandage', 'bandage', 'idle'}
local dragonfruits = {'dragonfruit', 'dragonfruit', 'idle'}
local meats = {'meat', 'meat', 'raw'}
local catcoons = {'catcoon', 'catcoon_build', 'taunt_pst'}
local sparkles = {"sparklefx", "sparklefx", "sparkle"}
local pigkings = {'Pig_King', 'Pig_King', 'idle'}
local has_items = {"tp_has_item", "tp_has_item", "idle"}
local bishop_charges = {"bishop_attack", "bishop_attack", "idle"}
local birdcages = {"birdcage", "birdcage_curly", "idle"}
local wargs = {"warg", "warg_build", "idle_loop"}
local woodies = {"wilsonbeefalo", "woodie", "idle_loop"}
-- local wargs = {"tp_blue_warg", "tp_blue_warg", "idle_loop"}
-- local logs = {"log", "log", "idle"}
local Anims = {
	pigking = {"Pig_King", "Pig_King", "idle", },
	bearger = {"bearger", "bearger_build", "ground_pound", },
	moose = {"goosemoose", "goosemoose_build", "honk", },
	dragonfly = {"dragonfly", "dragonfly_fire_build", "taunt_pre", },
	deerclops = {"deerclops", "deerclops_build", "atk", },
	teatree_nut = {"teatree_nut", "teatree_nut", "idle", },
	jungletreeseed = {"jungletreeseed", "jungletreeseed", "idle", },
	pinecone = {"pinecone", "pinecone", "idle", },
	coconut = {"coconut", "coconut", "idle", },
	acorn = {"acorn", "acorn", "idle", },
	green_leaf = {"tree_leaf_fx", "tree_leaf_fx_green", "fall", },
	green_leaf2 = {"tree_leaf_fx", "tree_leaf_fx_green", "chop", },
	green_leaf3 = {"chop_mangrove", "chop_mangrove", "chop", },
	green_leaf4 = {"chop_mangrove", "chop_mangrove", "fall", },
	fall_jungle = {"chop_jungle", "chop_jungle", "fall", },
	fall_leaf = {"pine_needles", "pine_needles", "fall", },
	chop_leaf = {"pine_needles", "pine_needles", "chop", },
	chop_jungle = {"chop_jungle", "chop_jungle", "chop", },
	dragonfruit = {"dragonfruit", "dragonfruit", "idle", },
	hambat = {"ham_bat", "ham_bat", "idle", },
	armorwood = {"armor_wood", "armor_wood", "anim", },
	coffeebeans = {"coffeebeans", "coffeebeans", "idle", },
	bandage = {"bandage", "bandage", "idle", },
	football = {"footballhat", "hat_football", "anim", },
	has_item = {"tp_has_item", "tp_has_item", "idle", },
	meat = {"meat", "meat", "raw", },
	catcoon = {"catcoon", "catcoon_build", "taunt_pst", },
	blood = {"wortox_soul_heal_fx", "wortox_soul_heal_fx", "heal", },
	sparkle = {"sparklefx", "sparklefx", "sparkle", },
	stafflight = {"star", "star", "appear", },
	small_meat = {"meat_small", "meat_small", "raw", },
	wilson_lunge = {"wilson", "wilson", "lunge_pst", },
	poison_hole = {"poison_hole", "poison_hole", "pop", },
	woodie = {"wilsonbeefalo", "woodie", "idle_loop", },
	snow_ball = {"firefighter_projectile", "firefighter_projectile", "spin_loop", },
	warg = {"warg", "warg_build", "idle_loop", },
	bishop_charge = {"bishop_attack", "bishop_attack", "idle", },
	spore_blue = {"tp_spore_blue", "tp_spore_blue", "cough_out", },
	spore = {"tp_spore", "tp_spore", "cough_out", },
	birdcage = {"birdcage", "birdcage_curly", "idle", },
	sign = {"sign_home", "sign_home", "place", },
}

local function animover_fn(inst, over_fn)
	inst:ListenForEvent("animover", over_fn)
end

local function common_fn(inst)
	animover_fn(inst, function()
		inst:Remove()
	end)
end

local function add_physics(inst, phy)
	if phy == 'inv' then
		MakeInventoryPhysics(inst)
	elseif phy == 'obs' then
		MakeObstaclePhysics(inst, .5)
	else
		MakeCharacterPhysics(inst, 1, .5)
	end
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function make_dmg(inst, target, attacker, damage)
	if target and target:IsValid() and target.components.health
	and not target.components.health:IsDead() and target.components.combat then
		-- local x1,y1,z1 = inst:GetPosition():Get()
		-- local x2,y2,z2 = target:GetPosition():Get()
		-- if (x1-x2)<.1 and (z1-z2)<.1 then
		local dist = target.Physics and target.Physics:GetRadius()+2 or 2
		if inst:IsNear(target, dist) then
			target.components.combat:GetAttacked(attacker, damage or 0, inst, inst.prefab)
			return true
		end
	end
end

local function MakeFx(name, anims, fx_fn)
	local function fn()
		local inst = WARGON.make_prefab(anims)
		if fx_fn then
			fx_fn(inst)
		end
		WARGON.no_save(inst)
		WARGON.add_tags(inst, {"FX", "NOCLICK"})	

		return inst
	end

	return Prefab(name, fn, {})
end

local function null_fn(inst)
	WARGON.do_task(inst, 1, function()
		inst:Remove()
	end)
end

local function leaf_fn(inst)
	common_fn(inst)
	inst.Transform:SetScale(1.5,1.5,1.5)
end

local function leaf_line_fn(inst)
	add_physics(inst)
	WARGON.per_task(inst, .1, function()
		WARGON.make_fx(inst, "tp_fx_leaf_"..math.random(4))
		if inst.owner then
			WARGON.area_dmg(inst, 1.5, inst.owner, 10, "tp_fx_leaf")
		end
	end)
	WARGON.do_task(inst, .4, function()
		inst:Remove()
	end)
end

local function leaf_circle_fn(inst)
	add_physics(inst)
	inst.start_task = function(inst)
		-- 请绑定master
		-- inst.Physics:SetMotorVel(1, 0, 10)
		if inst.task1 == nil then
			inst.task1 = WARGON.per_task(inst, 0, function()
				if inst.master then
					local master = inst.master
					inst:ForceFacePoint(master:GetPosition())
					if inst:IsNear(inst.master, 5) then
						inst.Physics:SetMotorVel(0, 0, 10)
					elseif inst:IsNear(inst.master, 10) then
						inst.Physics:SetMotorVel(2, 0, 10)
					elseif inst:IsNear(inst.master, 30) then
						inst.Physics:SetMotorVel(10, 0, 10)
					else
						inst.Transform:SetPosition(inst.master:GetPosition():Get())
					end
				end
			end)
		end
		if inst.task2 == nil then
			inst.task2 = WARGON.per_task(inst, .2, function()
				WARGON.make_fx(inst, "tp_fx_leaf_"..math.random(4))
			end)
		end
	end
	inst.stop_task = function(inst)
		if inst.task1 then
			inst.task1:Cancel()
			inst.task1 = nil
		end
		if inst.task2 then
			inst.task2:Cancel()
			inst.task2 = nil
		end
	end
	inst.start_task2 = function(inst)
		-- 请事先瞄准
		inst.Physics:SetMotorVel(20, 0, 0)
		if inst.task3 == nil then
			inst.task3 = WARGON.per_task(inst, .1, function()
				WARGON.make_fx(inst, "tp_fx_leaf_"..math.random(4))
				if inst.master then
					WARGON.area_dmg(inst, 3, inst.master, 10, "tp_fx_leaf")
				end
			end)
		end
		WARGON.do_task(inst, 1, function()
			if inst.task3 then
				inst.task3:Cancel()
				inst.task3 = nil
			end
			inst:start_task(inst)
		end)
	end
end

local function one_sparklefx_fn(inst)
	-- inst.AnimState:PlayAnimation("sparks_"..math.random(3))
	-- WARGON.set_scale(inst, .5)
	common_fn(inst)
end

local function alive_sparklefx_fn(inst)
	WARGON.per_task(inst, 1, function()
		-- local fx = WARGON.make_fx(inst, "sparklefx")
		local fx = WARGON.make_fx(inst, "tp_fx_one_sparklefx")
		-- fx.Transform:SetScale(3, 3, 3)
	end)
end

local function small_meat_fn(inst)
	local s = math.random()*.6 + 0.4
	inst.Transform:SetScale(s, s, s)
	-- MakeInventoryPhysics(inst)
	-- inst.Physics:ClearCollisionMask()
	-- inst.Physics:CollidesWith(COLLISION.GROUND)
	add_physics(inst, "inv")
	WARGON.do_task(inst, .5, function()
		local judge = math.random() < (inst.rand and inst.rand*.1+.05 or .05)
		if s > .9 and judge then
			-- print("smallmeat", judge)
			WARGON.make_spawn(inst, "smallmeat")
		end
		inst:Remove()
	end)
end

local function many_small_meat_fn(inst)
	WARGON.do_task(inst, 0, function()
		for i = 1, 4 do
			local fx = WARGON.make_fx(inst, "tp_fx_small_meat")
			local angle = PI/180 * 90 * i + math.random() * 10
			local sp = 4
			fx.Physics:SetVel(sp*math.cos(angle), 10, sp*math.sin(angle))
			if inst.rand then
				fx.rand = inst.rand
			end
		end
		inst:Remove()
	end)
end

local function bearger_fn(inst)
	inst.Transform:SetFourFaced()
	inst.AnimState:SetMultColour(1,1,1,.5)
	WARGON.set_scale(inst, 1)
	-- inst:AddComponent("health")
 --    inst.components.health:SetMaxHealth(TUNING.BEARGER_HEALTH)
	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.BEARGER_DAMAGE)
    inst:AddComponent("tpgroundpounder")
	inst:AddComponent("groundpounder")
	-- if inst:HasTag("tp_boss_angry") then
	-- 	inst.components.combat:SetDefaultDamage(75)
 --    else
    -- end
    local cmp = inst.components.tpgroundpounder
    cmp.destroyer = true
    cmp.damageRings = 3
    cmp.destructionRings = 4
    cmp.numRings = 5
    local cmp2 = inst.components.groundpounder
    cmp2.destroyer = true
    cmp2.damageRings = 3
    cmp2.destructionRings = 4
    cmp2.numRings = 5
    WARGON.do_task(inst, 20*FRAMES, function()
	    local cmp = inst.components.tpgroundpounder
	    if inst:HasTag("tp_boss_angry") then
	    	-- cmp = inst.components.groundpounder
	    	inst.components.combat:SetDefaultDamage(75)
	    	cmp.destroyer = false
	    	cmp.tags = {"player"}
	    	cmp.noTags = nil
	    elseif inst:HasTag("tp_boss_shadow") then
	    	cmp = inst.components.groundpounder
	    	cmp.damageRings = 0
	    	local x, y, z = inst:GetPosition():Get()
	        local ents = TheSim:FindEntities(x, y, z, 12, nil, {
	                "FX", "NOCLICK", "DECOR", "INLIMBO", "groundpoundimmune", "bearger",
	            })
	        if ents then
	            for k2,v2 in pairs(ents) do
	                if v2 and v2.components.health and not v2.components.health:IsDead() and 
	                inst.components.combat:CanTarget(v2) then
	                    -- inst.components.combat:DoAttack(v2, nil, nil, nil, 1)
	                    local dmg = inst.components.combat.defaultdamage
	                    v2.components.combat:GetAttacked(inst, dmg, nil, nil)
	                end
	            end
	        end
	    end
		cmp:GroundPound()
		WARGON.shake_camera(inst)
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
	end)
	common_fn(inst)
end

local function bearger_line_fn(inst)
	add_physics(inst)
	inst.Physics:SetMotorVel(35, 0, 0)
	for i = 1, 2 do
		WARGON.do_task(inst, .3*i, function()
			local fx = WARGON.make_fx(inst, "tp_fx_bearger")
            fx:AddTag("tp_boss_shadow")
            if inst.master then
            	local rot = inst.master:GetRotation()
	            fx.Transform:SetRotation(rot)
	        end
	        if i == 2 then
	        	inst:Remove()
	        end
		end)
	end
end

local function dragonfly_fn(inst)
	inst.Transform:SetFourFaced()
	inst.AnimState:SetMultColour(1,1,1,.5)
	inst.AnimState:PushAnimation("taunt", false)
	WARGON.set_scale(inst, 1.3)
	-- inst:AddComponent("health")
 --    inst.components.health:SetMaxHealth(TUNING.DRAGONFLY_HEALTH)
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.DRAGONFLY_DAMAGE)
    inst:AddComponent("tpgroundpounder")
	inst:AddComponent("groundpounder")
    -- if inst:HasTag("tp_boss_angry") then
	    -- inst.components.combat:SetDefaultDamage(25)
    -- else
    -- end
    local cmp = inst.components.tpgroundpounder
    cmp.numRings = 2
    cmp.burner = true
    cmp.groundpoundfx = "firesplash_fx"
    cmp.groundpounddamagemult = .5
    cmp.groundpoundringfx = "firering_fx"
    local cmp2 = inst.components.groundpounder
    cmp2.numRings = 2
    cmp2.burner = true
    cmp2.groundpoundfx = "firesplash_fx"
    cmp2.groundpounddamagemult = .5
    cmp2.groundpoundringfx = "firering_fx"
    local function do_gp(time)
    	WARGON.do_task(inst, time, function()
		    local cmp = inst.components.tpgroundpounder
		    if inst:HasTag("tp_boss_angry") then
		    	-- cmp = inst.components.groundpounder
		    	inst.components.combat:SetDefaultDamage(25)
		    	cmp.tags = {"player"}
		    	cmp.noTags = nil
		    end
	    	cmp:GroundPound()
	        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp")
	        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp_voice")
		end)
    end
    
    inst:ListenForEvent("animover", function()
	    WARGON.do_task(inst, 0, function()
	    	local tauntfx = SpawnPrefab("tauntfire_fx")
	        tauntfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	        tauntfx.Transform:SetRotation(inst.Transform:GetRotation())
	    end)
	    do_gp(2*FRAMES)
	    do_gp(9*FRAMES)
	    do_gp(20*FRAMES)
		inst:ListenForEvent("animqueueover", function()
			inst:Remove()
		end)
    end)
end

local function deerclops_fn(inst)
	inst.Transform:SetFourFaced()
	inst.AnimState:SetMultColour(1,1,1,.5)
	local s = 1.65
	inst.Transform:SetScale(s, s, s)
	-- inst:AddComponent("health")
 --    inst.components.health:SetMaxHealth(TUNING.DEERCLOPS_HEALTH)
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.DEERCLOPS_DAMAGE)  -- 150

    local function do_attack()
    	local tags = nil
    	local no_tags = {"player", "wall", "FX", "NOCLICK", "INLIMBO"}
    	if inst:HasTag("tp_boss_angry") then
    		tags = {"player"}
    		no_tags = nil
    	end
	    local ents = WARGON.finds(inst, 6, tags, no_tags)
		local attacker = inst
		for i, v in pairs(ents) do
			if attacker then
				if v.components.combat and v.components.health then
					v.components.combat:GetAttacked(attacker, 75, inst, "tp_fx_deerclops")
				end
				if v.components.freezable then
					v.components.freezable:AddColdness(2)
					v.components.freezable:SpawnShatterFX()
				end
			end
		end
	end
	local function spawn_ice_fx(inst, target)
	    if not inst or not target then return end
	    local numFX = math.random(15,20)
	    local pos = inst:GetPosition()
	    local targetPos = target:GetPosition()
	    local vec = targetPos - pos
	    vec = vec:Normalize()
	    local dist = pos:Dist(targetPos)
	    local angle = inst:GetAngleToPoint(targetPos:Get())

	    for i = 1, numFX do
	        inst:DoTaskInTime(math.random() * 0.25, function(inst)
	            local prefab = "icespike_fx_"..math.random(1,4)
	            local fx = SpawnPrefab(prefab)
	            if fx then
	                local x = GetRandomWithVariance(0, 3)
	                local z = GetRandomWithVariance(0, 3)
	                local offset = (vec * math.random(dist * 0.25, dist)) + Vector3(x,0,z)
	                fx.Transform:SetPosition((offset+pos):Get())
	            end
	        end)
	    end
	end

	WARGON.do_task(inst, 29*FRAMES, function()
		do_attack()
		spawn_ice_fx(inst, inst)
	end)
	WARGON.do_task(inst, 39*FRAMES, function()
		WARGON.shake_camera(inst)
	end)
	common_fn(inst)
end

local function moose_fn(inst)
	inst.Transform:SetFourFaced()
	inst.AnimState:SetMultColour(1,1,1,.5)
	WARGON.set_scale(inst, 1.55)
	-- inst:AddComponent("health")
 --    inst.components.health:SetMaxHealth(TUNING.MOSSLING_HEALTH)
	-- inst:AddComponent("combat")
 --    inst.components.combat:SetDefaultDamage(TUNING.MOSSLING_DAMAGE)  -- 50
    local function play_snd(time, name)
    	WARGON.do_task(inst, 2*FRAMES, function()
	    	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/"..name)
	    end)
    end
    play_snd(2*FRAMES, "flap")
    play_snd(10*FRAMES, "flap")
    play_snd(11*FRAMES, "swhoosh")
    play_snd(12*FRAMES, "honk")
    WARGON.do_task(inst, 12*FRAMES, function()
    	WARGON.shake_camera(inst)
    end)
    local function disarm_target(inst, target)
	    local item = nil
	    if target and target.components.inventory then
	        item = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    end
	    if item and item.Physics then
	        target.components.inventory:DropItem(item)
	        -- local x, y, z = item:GetPosition():Get()
	        -- y = .1
	        -- item.Physics:Teleport(x,y,z)
	        -- local hp = target:GetPosition()
	        -- local pt = inst:GetPosition()
	        -- local vel = (hp - pt):GetNormalized()     
	        -- local speed = 5 + (math.random() * 2)
	        -- local angle = math.atan2(vel.z, vel.x) + (math.random() * 20 - 10) * DEGREES
	        -- item.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)
	    end
	end
    WARGON.do_task(inst, 15*FRAMES, function()
    	local tags = nil
    	local no_tags = {"player", "INLIMBO", "FX", "NOCLICK"}
    	if inst:HasTag("tp_boss_angry") then
    		tags = {"player"}
    		no_tags = nil
    	end
    	local ents = WARGON.finds(inst, 4, tags, no_tags)
    	for i, v in pairs(ents) do
    		disarm_target(inst, v)
    	end
    end)
    common_fn(inst)
end

local function ham_ground_pound_fn(inst)
	WARGON.CMP.add_cmps(inst, {
		combat = {dmg=1},
		})
    WARGON.do_task(inst, 0, function()
    	WARGON.make_fx(inst, "tp_fx_many_small_meat")
    	local fx = WARGON.make_fx(inst, "groundpoundring_fx")
    	local s = 1
    	fx.Transform:SetScale(s,s,s)
    	WARGON.area_dmg(inst, 4, nil, 20, "tp_hambat")
    	inst:Remove()
    end)
end

local function wilson_lunge_fn(inst)
	inst.AnimState:SetMultColour(.1, .1, 1, .8)
	inst.Transform:SetFourFaced()
	WARGON.do_task(inst, .3, function()
		inst:Remove()
	end)
end

local function snow_line_fn(inst)
	inst.fxs = {}
	WARGON.per_task(inst, .1, function()
		local fx = WARGON.make_fx(inst, "tp_snow_fx")
		table.insert(inst.fxs, fx)
	end)
	inst.kill = function(inst)
		for i, v in pairs(inst.fxs) do
			v:Remove()
		end
		inst:Remove()
	end
end

local function fire_line_fn(inst)
	WARGON.per_task(inst, .1, function()
		WARGON.make_fx(inst, "dragoon_charge_fx")
	end)
end

local function blood_fn(inst)
	local s = 2
	inst.Transform:SetScale(s, s, s)
	common_fn(inst)
end

local function sign_fn(inst)
	inst.AnimState:PushAnimation("idle")
end

local function sign_3_fn(inst)
	inst.AnimState:PushAnimation("idle")
	WARGON.do_task(inst, .5, function()
		inst:Remove()
	end)
end

local function sign_line_fn(inst)
	add_physics(inst)
	WARGON.do_task(inst, 0, function()
		inst.Physics:SetMotorVel(10, 0, 0)
	end)
	WARGON.do_task(inst, .5, function()
		inst.Physics:SetMotorVel(0, 0, 10)
	end)
	WARGON.do_task(inst, 1, function()
		inst:Remove()
	end)
	WARGON.per_task(inst, .1, function()
		local fx = WARGON.make_fx(inst, "tp_fx_sign")
		if inst.master then
			table.insert(inst.master.fxs, fx)
		end
	end)
end

local function sign_circle_point_fn(inst)
	add_physics(inst)
	inst.Physics:SetMotorVel(8, 0, 0)
	WARGON.do_task(inst, 1, function()
		local fx = WARGON.make_fx(inst, "tp_fx_sign")
		if inst.master then
			table.insert(inst.master.fxs, fx)
		end
		inst:Remove()
	end)
end

local function sign_circle_fn(inst)
	inst:StartThread(function()
		for i = 1, 36 do
			local rot = i * 10
			local point_fx = WARGON.make_fx(inst, "tp_fx_sign_circle_point")
			point_fx.Transform:SetRotation(rot)
			if inst.master then
				point_fx.master = inst.master
			end
			Sleep(.1)
		end
	end)
	WARGON.do_task(inst, 4, function()
		inst:Remove()
	end)
end

local function sign_2_fn(inst)
	common_fn(inst)
end

local function sign_surround_fn(inst)
	inst.AnimState:PlayAnimation("idle")
	add_physics(inst)
	inst.Physics:SetMotorVel(0, 0, 10)
	inst.task = WARGON.per_task(inst, 0, function()
		if inst.master then
			inst:ForceFacePoint(inst.master:GetPosition())
			if inst:IsNear(inst.master, 10) then
				inst.Physics:SetMotorVel(0, 0, 20)
			end
		else
			inst:Remove()
		end
	end)
	WARGON.do_task(inst, 3, function()
		if inst.task then
			inst.task:Cancel()
			inst.task = nil
		end
		inst.Physics:SetMotorVel(10, 0, 0)
		inst.task = WARGON.per_task(inst, 0, function()
			if inst.target then
				inst:ForceFacePoint(inst.target:GetPosition())
				if make_dmg(inst, inst.target, inst.master, 50) then
					WARGON.make_fx(inst, "boat_hit_fx_raft_log")
					inst:Remove()
				end
			else
				inst:Remove()
			end
		end)
		WARGON.do_task(inst, 1, function()
			inst.Physics:SetMotorVel(15, 0, 0)
		end)
		WARGON.do_task(inst, 2, function()
			inst.Physics:SetMotorVel(20, 0, 0)
		end)
	end)
	WARGON.per_task(inst, .15, function()
		local fx = WARGON.make_fx(inst, 'tp_fx_sign_2')
		-- fx.AnimState:PlayAnimation('idle')
		fx.AnimState:SetMultColour(1, 1, 1, .3)
	end)
end

local function sign_three_fn(inst)
	WARGON.do_task(inst, 0, function()
		local pos = inst:GetPosition()
		for i = 1, 3 do
			local angle = PI/180 * i * 360/3
			local radius = 1
			local pt = pos
			pt.x = pt.x + math.cos(angle) * radius
			pt.z = pt.z + math.sin(angle) * radius
			local fx = WARGON.make_fx(pt, "tp_fx_sign_surround")
			fx.master = inst.master
			fx.target = inst.target
		end
	end)
	WARGON.do_task(inst, .1, function()
		inst:Remove()
	end)
end

local function sign_wan_fn(inst)
	inst.fxs = {}
	WARGON.do_task(inst, 0, function()
		for i = 1, 4 do
			local fx = WARGON.make_fx(inst, "tp_fx_sign_line")
			fx.Transform:SetRotation(i*90)
			fx.master = inst
		end
		local pt = inst:GetPosition()
		local circle_fx = WARGON.make_fx(pt, "tp_fx_sign_circle")
		circle_fx.master = inst
	end)
	WARGON.do_task(inst, 4.6, function()
		WARGON.make_fx(inst, "groundpoundring_fx")
	end)
	WARGON.do_task(inst, 5, function()
		for i, v in pairs(inst.fxs) do
			v:Remove()
		end
		local kill_tags = {"monster","spider_monkey","werepig","shadowcreature","epic"}
		local ents = WARGON.finds(inst, 8, nil, {"player", "tp_defense_sign"})
		for i2, v2 in pairs(ents) do
			for i3, v3 in pairs(kill_tags) do
				if v2:HasTag(v3) then
					if v2.components.health then
						-- if v2:HasTag("epic") and v2.components.health.maxhealth>=3000 then
						if v2:HasTag("tp_sign_damage") then
							if v2.components.combat then
								v2.components.combat:GetAttacked(nil, 500, inst, "tp_fx_sign_wan")
							end
						else
							v2.components.health:Kill()
						end
						WARGON.make_fx(v2, "wathgrithr_spirit")
					end
					break
				end
			end
		end
		inst:Remove()
	end)
end

local function sign_wall_fn(inst)
	MakeObstaclePhysics(inst, .5)
	inst.AnimState:PushAnimation("idle")
end

local function sign_circle_wall_fn(inst)
	local function set_wall(angle)
		local radius = 8
		local pos = inst:GetPosition()
		pos.x = pos.x + math.cos(angle)*radius
		pos.z = pos.z + math.sin(angle)*radius
		local fx = WARGON.make_fx(pos, 'tp_fx_sign_wall')
		if inst.master then
			table.insert(inst.master.fxs, fx)
		end
	end
	inst:StartThread(function()
		local start = math.random(18)
		for i = 1, 18 do
			local angle = (start+i) * 10 * PI/180
			local angle2 = PI + angle
			set_wall(angle)
			set_wall(angle2)
			Sleep(.1)
		end
	end)
	WARGON.do_task(inst, 4, function()
		inst:Remove()
	end)
end

local function sign_line_wall_fn(inst)
	add_physics(inst)
	WARGON.do_task(inst, 0, function()
		inst.Physics:SetMotorVel(5, 0, 0)
	end)
	WARGON.do_task(inst, 1, function()
		inst:Remove()
	end)
	WARGON.per_task(inst, .2, function()
		local fx = WARGON.make_fx(inst, "tp_fx_sign_wall")
		if inst.master then
			table.insert(inst.master.fxs, fx)
		end
	end)
end

local function sign_killer_fn(inst)
	inst.fxs = {}
	WARGON.do_task(inst, 0, function()
		for i = 1, 4 do
			local fx = WARGON.make_fx(inst, "tp_fx_sign_line_wall")
			fx.Transform:SetRotation(i*90)
			fx.master = inst
		end
		local pt = inst:GetPosition()
		local circle_fx = WARGON.make_fx(pt, "tp_fx_sign_circle_wall")
		circle_fx.master = inst
	end)
	WARGON.do_task(inst, 4.6, function()
		WARGON.make_fx(inst, "groundpoundring_fx")
	end)
	WARGON.do_task(inst, 5, function()
		for i, v in pairs(inst.fxs) do
			v:Remove()
		end
		local no_tags = {"epic", "beefalo", "ironlord", "tp_defense_sign"}
		local ents = WARGON.finds(inst, 8, nil, no_tags)
		for i2, v2 in pairs(ents) do
			if v2:HasTag("player") and v2.components.tpmadvalue then
				v2.components.tpmadvalue:DoDelta(50)
			end
			if v2.components.health and not v2:HasTag("player") then
				v2.components.health:Kill()
				WARGON.make_fx(v2, "wathgrithr_spirit")
			end
		end
		local ents = WARGON.finds(inst, 8, {"tp_sign_rider"})
		for i2, v2 in pairs(ents) do
			if v2.components.health then
				v2.components.health:DoDelta(200)
			end
		end
		inst:Remove()
	end)
end

local function tree_seed_shadow_fn(inst)
	WARGON.do_task(inst, .2, function()
		inst:Remove()
	end)
end

local function tree_seed_fn(inst)
	local scale = math.random()*0.6+0.4
	WARGON.set_scale(inst, scale)
	add_physics(inst, "inv")
	WARGON.do_task(inst, 1, function()
		if WARGON.on_land(inst) and scale > .9 and math.random() < .1 then
			local ents = WARGON.finds(inst, .5, {"tree"})
			if #ents <= 0 then
				-- local num = string.sub(inst.prefab, -1)
				-- num = tonumber(num)
				-- local trees = {
				-- 	"evergreen",
				-- 	"deciduoustree",
				-- 	"jungletree",
				-- 	"teatree",
				-- 	"coconut",
				-- }
				-- local tree_name = trees[num]
				-- local tree = WARGON.make_spawn(inst, tree_name)
				-- if tree then
				-- 	tree:growfromseed()
				-- end
			else
				local fx = WARGON.make_fx(inst, "splash_clouds_drop")
				WARGON.set_scale(fx, scale)
			end
		else
			local fx = WARGON.make_fx(inst, "splash_clouds_drop")
			WARGON.set_scale(fx, scale)
		end
		inst:Remove()
	end)
	WARGON.per_task(inst, .1, function()
		local num = string.sub(inst.prefab, -1)
		local fx = WARGON.make_fx(inst, "tp_fx_tree_seed_shadow_"..num)
		fx.AnimState:SetMultColour(1,1,1,.5)
		WARGON.set_scale(fx, scale)
	end)
end

local function many_tree_seed_fn(inst)
	WARGON.do_task(inst, 0, function()
		local adjust = math.random(35)
		for i = 1, 10 do
			local fx = WARGON.make_fx(inst, "tp_fx_tree_seed_"..math.random(5))
			local angle = PI/180 * 36 * i + adjust
			local sp = 4
			fx.Physics:SetVel(sp*math.cos(angle), 15, sp*math.sin(angle))
		end
		inst:Remove()
	end)
end

local function teatree_nut_surround_fn(inst)
	add_physics(inst)
	inst.Physics:SetMotorVel(0, 0, 5)
	WARGON.do_task(inst, 0, function()
		local pt = inst:GetPosition()
		pt.y = 1
		inst.Transform:SetPosition(pt:Get())
	end)
	WARGON.per_task(inst, 0, function()
		if inst.master then
			inst:ForceFacePoint(inst.master:GetPosition())
		end
	end)
	WARGON.per_task(inst, .2, function()
		local fx = WARGON.make_fx(inst, "tp_fx_tree_seed_shadow_4")
		fx.AnimState:SetMultColour(1,1,1,.5)
	end)
	WARGON.do_task(inst, 1.5, function()
		inst:Remove()
	end)
end

local function shadow_arc_fn(inst)
	add_physics(inst)
	local dz = math.random(3)-2
	local speed_z = (dz)*20
	inst.Physics:SetMotorVel(15, 0, speed_z)
	WARGON.per_task(inst, 0, function()
		local target = inst.target
		-- if target and target:IsValid() and target.components.health
		-- and not target.components.health:IsDead() and target.components.combat then
			-- local x1,y1,z1 = inst:GetPosition():Get()
			-- local x2,y2,z2 = inst.target:GetPosition():Get()
			-- if (x1-x2)<.1 and (z1-z2)<.1 then
			-- 	target.components.combat:GetAttacked(nil, 10, inst, "tp_fx_shadow_arc")
			-- 	inst:Remove()
			-- end
		if target then
			if make_dmg(inst, target, nil, 10) then
				inst:Remove()
			end
			inst:ForceFacePoint(inst.target:GetPosition())
		else
			inst:Remove()
		end
	end)
	WARGON.per_task(inst, .05, function()
		local pos = inst:GetPosition()
		pos.y = pos.y + .5
		local fx = WARGON.make_fx(pos, "statue_transition_2")
		WARGON.set_scale(fx, .5)
	end)
	WARGON.do_task(inst, 0, function()
		local pt = inst:GetPosition()
		pt.y = pt.y + 1
		inst.Transform:SetPosition(pt:Get())
	end)
end

local function shadow_arc_creater(inst)
	inst.start_task = function(inst)
		if inst.task == nil then
			inst.task = WARGON.per_task(inst, 1, function()
				local target = inst.target
				if target and target:IsValid() and target.components.health
				and not target.components.health:IsDead() 
				and target.components.combat then
					local fx = WARGON.make_fx(inst, "tp_fx_shadow_arc")
					fx.target = target
				end
			end)
		end
		WARGON.do_task(inst, 3, function()
			if inst.task then
				inst.task:Cancel()
				inst.task = nil
			end
		end)
	end
end

local function shadow_line_fn(inst)
	add_physics(inst)
	inst.Physics:SetMotorVel(10, 0, 0)
	WARGON.per_task(inst, .1, function()
		WARGON.make_fx(inst, "tp_shadow_fx")
	end)
	WARGON.do_task(inst, .5, function()
		inst:Remove()
	end)
end

local function shadow_line_2_fn(inst)
	add_physics(inst)
	inst.Physics:SetMotorVel(2, 0, 0)
	WARGON.per_task(inst, .5, function()
		WARGON.make_fx(inst, "tp_shadow_fx")
	end)
	WARGON.do_task(inst, 2, function()
		inst:Remove()
	end)
end

local function shadow_spawn_fn(inst)
	WARGON.do_task(inst, 0, function()
		local pt = inst:GetPosition()
		for i = 1, 6 do
			local angle = PI/180 * 360/6 * i
			local radius = 5
			local offset = Vector3(math.cos(angle)*radius, 0, math.sin(angle)*radius)
			local fx = WARGON.make_fx(pt+offset, "tp_fx_shadow_line")
			fx:ForceFacePoint(pt)
		end
	end)
	WARGON.do_task(inst, .5, function()
		local pt = inst:GetPosition()
		for i = 1, 18 do
			local angle = PI/180 * 360/18 * i
			local radius = 10  -- 无所谓是多少
			local offset = Vector3(math.cos(angle)*radius, 0, math.sin(angle)*radius)
			local fx = WARGON.make_fx(pt, "tp_fx_shadow_line_2")
			fx:ForceFacePoint(pt+offset)
		end
		WARGON.make_fx(inst, "statue_transition_2")
		inst:Remove()
	end)
end

local function shadow_bat_fn(inst)
	WARGON.do_task(inst, 0, function()
		for i = 1, 3 do
			local fx = WARGON.make_fx(inst, "tp_bat_fx")
			fx:OnBatFXSpawned(inst)
		end
		inst:Remove()
	end)
end

local function shadow_spiral_fn(inst)
	add_physics(inst)
	WARGON.do_task(inst, 0, function()
		inst.Physics:SetMotorVel(0, 0, 15)
	end)
	WARGON.per_task(inst, 0, function()
		if inst.master then
			local pos = inst.master:GetPosition()
			inst:ForceFacePoint(pos)
		end
	end)
	WARGON.per_task(inst, .1, function()
		WARGON.make_fx(inst, 'tp_shadow_fx')
	end)
	WARGON.do_task(inst, 3, function()
		inst:Remove()
	end)
end

local function shadow_spiral_point_fn(inst)
	WARGON.do_task(inst, 0, function()
		local x, y, z = inst:GetPosition():Get()
		for i = -1, 1, 2 do
			local fx = SpawnPrefab('tp_fx_shadow_spiral')
			fx.Transform:SetPosition(x+i, y, z)
			fx.master = inst
		end
	end)
	WARGON.do_task(inst, 3.1, function()
		inst:Remove()
	end)
end

local function poison_bubble_fn(inst)
	inst.AnimState:Hide('Layer 165')
	common_fn(inst)
end

local function spore_fn(inst)
	local light = inst.entity:AddLight()
	inst.scale = 2
    light:SetFalloff(1)
    light:SetIntensity(.5)
    light:SetRadius(inst.scale or 1)
    light:SetColour(180/255, 195/255, 150/255)
    light:Enable(true)
	add_physics(inst)
	inst.height = 0
	WARGON.do_task(inst, 0, function()
		local pt = inst:GetPosition()
		inst.Transform:SetPosition(pt.x, inst.height, pt.z)
		WARGON.set_scale(inst, inst.scale)
		inst.AnimState:PushAnimation('idle_flight_loop')
		inst.task = WARGON.per_task(inst, 1, function()
			inst.Physics:SetMotorVel(math.random(2), 0, math.random(2))
			if inst.master then
				if not inst:IsNear(inst.master, 2) then
					inst:ForceFacePoint(inst.master:GetPosition())
					inst.Physics:SetMotorVel(math.random(2), 0, 0)
				end
			end
		end)
	end)
	inst.kill = function(inst)
		if inst.task then
			inst.task:Cancel()
			inst.task = nil
		end
		if inst.task2 then
			inst.task2:Cancel()
			inst.task2 = nil
		end
		inst.AnimState:PlayAnimation("land", false)
		inst:ListenForEvent("animover", function()
			inst:Remove()
		end)
	end
end

local function spore_three_fn(inst)
	inst.fxs = {}
	inst.num = 3
	WARGON.do_task(inst, 0, function()
		local pos = inst:GetPosition()
		local pts = WARGON.get_divide_point(inst, inst.num)
		-- for i = 1, inst.num do
			local i = inst.num
			local fx = nil
			if inst:HasTag('spore_blue') then
				fx = SpawnPrefab("tp_fx_spore_blue")
			else
				fx = SpawnPrefab("tp_fx_spore")
			end
			fx.Transform:SetPosition(pts[i]:Get())
			fx.master = inst
			fx.scale = i
			if i == 1 then
				inst.height = 4
			elseif i == 3 then
				inst.height = 1.5
			end
			table.insert(inst.fxs, fx)
		-- end
	end)
	inst.kill = function(inst)
		for k, v in pairs(inst.fxs) do
			v:kill(v)
		end
		inst:Remove()
	end
end

local function has_alloy_fn(inst)
	WARGON.set_scale(inst, 2)
end

local function has_fn(inst)
end

local function boss_spirit_fn(inst)
	inst.AnimState:PushAnimation("idle_loop", true)
	add_physics(inst)
	WARGON.do_task(inst, 1, function()
		inst.Physics:SetMotorVel(5, 0, 0)
		WARGON.do_task(inst, 2, function()
			inst.Physics:SetMotorVel(10, 0, 0)
		end)
		if inst.target then
			WARGON.per_task(inst, 0, function()
				inst:ForceFacePoint(inst.target:GetPosition())
				if inst.target and inst.target:IsValid() then
					local x1,y1,z1 = inst:GetPosition():Get()
					local x2,y2,z2 = inst.target:GetPosition():Get()
					if (x1-x2)<.1 and (z1-z2)<.1 then
						inst.AnimState:PlayAnimation("disapper")
						WARGON.do_task(inst, .5, function()
							inst:Remove()
						end)
					end
				end
			end)
			WARGON.per_task(inst, .1, function()
				WARGON.make_fx(inst, "tp_fx_boss_spirit_shadow")
			end)
		end
	end)
end

local function boss_spirit_shadow_fn(inst)
	inst.AnimState:PlayAnimation("idle_loop", false)
	-- inst.AnimState:PushAnimation("disapper", false)
	inst.AnimState:SetMultColour(1, 1, 1, .5)
	-- inst:ListenForEvent("animqueueover", function()
	-- 	inst:Remove()
	-- end)
	inst.scale = 1
	WARGON.per_task(inst, .1, function()
		inst.scale = math.max(.1, inst.scale-1)
		WARGON.set_scale(inst, inst.scale)
	end)
	WARGON.do_task(inst, 1, function()
		inst:Remove()
	end)
end

local function snow_ball_hit(inst)
	local dist = 4
	local x,y,z = inst:GetPosition():Get()
	local ents = TheSim:FindEntities(x,y,z, dist, nil, 
		{"FX", "DECOR", "INLIMBO"})
	for k,v in pairs(ents) do
		if v then
			print("testing",v.prefab)
			if v.components.burnable then
				print("testing 2",v.prefab)
				if v.components.burnable:IsBurning() then
					print("testing 3",v.prefab)
					v.components.burnable:Extinguish(true, TUNING.FIRESUPPRESSOR_EXTINGUISH_HEAT_PERCENT)
				elseif v.components.burnable:IsSmoldering() then
					print("testing 4",v.prefab)
					v.components.burnable:Extinguish(true)
				end
			end
			if not v:HasTag("tp_snow_power") then
				if v.components.freezable then
					print("testing 5",v.prefab)
					v.components.freezable:AddColdness(2) 
				end
				if v.components.temperature then
					print("testing 6",v.prefab)
					local temp = v.components.temperature:GetCurrent()
	        		v.components.temperature:SetTemperature(temp - TUNING.FIRE_SUPPRESSOR_TEMP_REDUCTION)
				end
				if inst.diff and v.components.health then
				-- if WARGON.CONFIG.diff == 1 and v.components.health then
					local delta = v:HasTag("player") and 10 or 20
					v.components.health:DoDelta(-delta)
				end
			end
			if inst.diff and v:HasTag("tp_snow_power") then
			-- if WARGON.CONFIG.diff == 1 and v:HasTag("tp_snow_power") then
				if v.components.health and not v.components.health:IsDead() then
					v.components.health:DoDelta(20)
				end
			end
		end
	end
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_impact")
	SpawnPrefab("splash_snow_fx").Transform:SetPosition(inst:GetPosition():Get())	
	inst:Remove()
end

local function snow_ball_fn(inst)
	local physics = inst.entity:AddPhysics()
    physics:SetMass(1)
    physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetFriction(10)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(GetWorldCollision())
    inst.Physics:CollidesWith(COLLISION.INTWALL)

    inst:AddComponent("locomotor")
	inst:AddComponent("complexprojectile")
	inst.components.complexprojectile:SetOnHit(snow_ball_hit)
	inst.components.complexprojectile.yOffset = 2.5
end

local function snow_ball_shoot_fn(inst)
	local function launch_projectile(inst, targetpos)
		local x, y, z = inst.Transform:GetWorldPosition()
	    local projectile = SpawnPrefab("tp_fx_snow_ball")
	    projectile.Transform:SetPosition(x, y, z)
	    local dx = targetpos.x - x
	    local dz = targetpos.z - z
	    local rangesq = dx * dx + dz * dz
	    local maxrange = TUNING.FIRE_DETECTOR_RANGE
	    local speed = easing.linear(rangesq, 15, 3, maxrange * maxrange)
	    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
	    projectile.components.complexprojectile:SetGravity(-25)
	    projectile.components.complexprojectile:Launch(targetpos, inst, inst)
	    projectile.owner = inst
	end
	WARGON.do_task(inst, 0, function()
		local pt = inst:GetPosition()
		inst.Transform:SetPosition(pt.x, 4, pt.z)
		local pos = WARGON.around_land(inst, 
			math.random(TUNING.FIRE_DETECTOR_RANGE/2)+math.random())
		if pos then
			launch_projectile(inst, pos)
		end
		inst:Remove()
	end)
end

local function scroll_pig_buff_fn(inst)
	WARGON.do_task(inst, 0, function()
		inst.task = WARGON.per_task(inst, 2, function()
			local master = inst.master or inst.entity:GetParent() or inst
			if inst.fx_name and master then
				local pos = master:GetPosition()
				-- pos.y = pos.y + 2
				local fx = WARGON.make_fx(pos, inst.fx_name)
			end
		end)
	end)
end

local function scroll_pig_effect_fn(inst)
	add_physics(inst)
	inst.AnimState:SetMultColour(1,1,1,.8)
	inst.Physics:SetMotorVel(0, 5, 0)
	WARGON.do_task(inst, 0, function()
		local pos = inst:GetPosition()
		pos.y = pos.y + 2
		inst.Transform:SetPosition(pos:Get())
	end)
	WARGON.do_task(inst, .5, function()
		inst:Remove()
	end)
end

local function catcoon_pick_fn(inst)
	inst.AnimState:SetMultColour(1,1,1,.5)
	inst.Transform:SetFourFaced()
	WARGON.do_task(inst, 0, function()
		local player = GetPlayer() or inst
		inst:ForceFacePoint(player:GetPosition())
	end)
	inst:ListenForEvent("animover", function(inst, data)
		WARGON.make_fx(inst, "collapse_small")
		inst:Remove()
	end)
end

local function wilson_run_fn(inst)
	inst.AnimState:PlayAnimation("run_loop")
	inst.AnimState:SetMultColour(1,.1,1,.5)
	inst.Transform:SetFourFaced()
	WARGON.do_task(inst, 0, function()
		if inst.master then
			if inst.master.components.sciencemorph then
				local build = inst.master.components.sciencemorph:GetBuild()
				inst.AnimState:SetBuild(build)
				inst.Transform:SetRotation(inst.master.Transform:GetRotation())
			end
		end
	end)
	WARGON.do_task(inst, .3, function()
		inst:Remove()
	end)
end

local function ice_spike_fn(inst)
	local function spawn_ice_fx(inst, target)
	    if not inst or not target then return end
	    local numFX = math.random(15,20)
	    local pos = inst:GetPosition()
	    local targetPos = target:GetPosition()
	    local vec = targetPos - pos
	    vec = vec:Normalize()
	    local dist = pos:Dist(targetPos)
	    local angle = inst:GetAngleToPoint(targetPos:Get())

	    for i = 1, numFX do
	        inst:DoTaskInTime(math.random() * 0.25, function(inst)
	            local prefab = "icespike_fx_"..math.random(1,4)
	            local fx = SpawnPrefab(prefab)
	            if fx then
	                local x = GetRandomWithVariance(0, 3)
	                local z = GetRandomWithVariance(0, 3)
	                local offset = (vec * math.random(dist * 0.25, dist)) + Vector3(x,0,z)
	                fx.Transform:SetPosition((offset+pos):Get())
	            end
	        end)
	    end
	end
	WARGON.do_task(inst, 0, function()
		spawn_ice_fx(inst, inst)
	end)
	WARGON.do_task(inst, 1, function()
		inst:Remove()
	end)
end

local function pigking_fn(inst)
	inst.AnimState:SetMultColour(1, 1, 1, .5)
	inst.AnimState:PlayAnimation("cointoss")
	inst.AnimState:PushAnimation("happy", false)
	WARGON.do_task(inst, 20/30, function()
		inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingThrowGold")
	end)
	WARGON.do_task(inst, 1.5, function()
		inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingHappy")
	end)
	inst:ListenForEvent("animqueueover", function()
		inst:Remove()
	end)
end

local function has_item_fn(inst)
	WARGON.set_scale(inst, 4)
	inst:AddComponent("tpfollowimage")
end

local function follow_image_fn(inst)
	inst:AddComponent("tpfollowimage")
end

local function armor_broken_fn(inst)
	follow_image_fn(inst)
	inst.components.tpfollowimage.offset = Vector3(0, -500, 0)
end

local function ground_pound_fn(inst)
	WARGON.do_task(inst, 0, function()
		WARGON.make_fx(inst, "groundpoundring_fx")
		local ent = WARGON.find(inst, 3, nil, {"player"})
		if ent and ent.components.combat and ent.components.health
		and not ent.components.health:IsDead() then
			ent.components.combat:GetAttacked(nil, 50, inst, inst.prefab)
		end
		inst:Remove()
	end)
end

local function splash_ground_pound_fn(inst)
	WARGON.do_task(inst, 0, function()
		local fx = WARGON.make_fx(inst, "splash")
		WARGON.set_scale(fx, 3)
		WARGON.do_task(inst, 1.5, function()
			WARGON.make_fx(inst, "tp_fx_ground_pound")
			inst:Remove()
		end)
	end)
end

local function charge_surround_fn(inst)
	inst.AnimState:PlayAnimation("idle", true)
	add_physics(inst)
	inst.Physics:SetMotorVel(12, 0, 0)
	WARGON.do_task(inst, 1, function()
		inst.Physics:SetMotorVel(0, 0, 6)
		WARGON.per_task(inst, 0, function()
			if inst.target then
				WARGON.face_target(inst, inst.target)
			else
				inst:Remove()
			end
		end)
	end)
	WARGON.do_task(inst, 2.5, function()
		if inst:HasTag("tp_fx_charge_surround_attack") then
			if inst.target then
				local proj = WARGON.make_spawn(inst, "tp_soul_charge")
		        proj.components.tpproj:Throw(inst.master, inst.target)
			end
		end
		inst:Remove()
	end)
end

local function light_fn(inst)
	local light = inst.entity:AddLight()
    light:SetFalloff(.5)
    light:SetIntensity(.7)
    light:SetRadius(2.5)
    light:SetColour(180/255, 195/255, 220/255)
    light:Enable(true)
end

local function speech_fn(inst)
	inst:AddComponent("talker")
	inst.components.talker.offset = Vector3(15, -180, 0)
    inst.components.talker.fontsize = 50
    WARGON.do_task(inst, 0, function()
    	if inst.tp_colour then
	    	inst.components.talker.colour = inst.tp_colour
    	end
    	if inst.tp_str then
	    	inst.components.talker:Say(inst.tp_str)
    	end
    end)
    WARGON.do_task(inst, 1, function()
    	inst:Remove()
    end)
end

local function dragon_cage_fly_fn(inst)
	inst.Transform:SetFourFaced()
	inst.AnimState:PlayAnimation("idle", true)
	WARGON.set_scale(inst, .5)
end

local function dragon_cage_front_fn(inst)
	-- local hide_anims = {
	-- 	"snow", "crow_eye", "crow_wings", "crow_body", "crow_beak", "crow_leg", 
	-- 	"tail_feather", "back",
	-- }
	-- for k, v in pairs(hide_anims) do
	-- 	inst.AnimState:Hide(v)
	-- end
	inst.AnimState:Hide("back")
	inst.AnimState:PlayAnimation("idle")
end

local function warm_fn(inst)
	inst:add_cmp("heat", {heat=100})
end

local function cool_fn(inst)
	inst:add_cmp("heat", {heat=-30, cool=true})
end

local function warg_head_fn(inst)
	inst.Transform:SetFourFaced()
	-- inst.Transform:SetSixFaced()
	local anim = inst.AnimState
	-- anim:Hide("beefalo_hoof")
	-- anim:Hide("beefalo_tail")
	-- anim:Hide("beefalo_facebase")
	-- anim:Hide("beefalo_mouth")
	-- anim:Hide("beefalo_eye")
end

local function warg_body_fn(inst)
	inst.Transform:SetFourFaced()
	-- inst.Transform:SetSixFaced()
	local anim = inst.AnimState
	anim:Hide("beefalo_head")
	anim:Hide("beefalo_antler")
	anim:Hide("beefalo_body")
end

local function warg_fn(inst)
	inst.Transform:SetFourFaced()
end

local function woodie_rider_fn(inst)
	inst.Transform:SetSixFaced()
end

local function small_ground_pound_fn(inst)
	inst:do_task(0, function()
		local fx = WARGON.make_fx(inst, "groundpound_fx")
		fx:set_scale(inst.scale or .5)
	end)
end

local function small_ground_pound_ring_fn(inst)
	inst:do_task(0, function()
		local fx = WARGON.make_fx(inst, "groundpoundring_fx")
		fx:set_scale(inst.scale or .5)
	end)
end

return
MakeFx("tp_fx_null", {}, null_fn),
MakeFx("tp_fx_leaf_1", Anims.green_leaf, leaf_fn),
MakeFx("tp_fx_leaf_2", Anims.green_leaf2, leaf_fn),
MakeFx("tp_fx_leaf_3", Anims.green_leaf3, leaf_fn),
MakeFx("tp_fx_leaf_4", Anims.green_leaf4, leaf_fn),
MakeFx("tp_fx_leaf_line", {}, leaf_line_fn),
MakeFx("tp_fx_leaf_circle", {}, leaf_circle_fn),
MakeFx("tp_fx_one_sparklefx", Anims.sparkle, one_sparklefx_fn),
MakeFx("tp_fx_alive_sparklefx", {}, alive_sparklefx_fn),
MakeFx("tp_fx_small_meat", Anims.small_meat, small_meat_fn),
MakeFx("tp_fx_many_small_meat", {}, many_small_meat_fn),
MakeFx("tp_fx_bearger", Anims.bearger, bearger_fn),
MakeFx("tp_fx_bearger_line", {}, bearger_line_fn),
MakeFx("tp_fx_dragonfly", Anims.dragonfly, dragonfly_fn),
MakeFx("tp_fx_deerclops", Anims.deerclops, deerclops_fn),
MakeFx("tp_fx_moose", Anims.moose, moose_fn),
MakeFx("tp_fx_ham_ground_pound", {}, ham_ground_pound_fn),
MakeFx("tp_fx_wilson_lunge", Anims.wilson_lunge, wilson_lunge_fn),
MakeFx("tp_fx_snow_line", {}, snow_line_fn),
MakeFx("tp_fx_fire_line", {}, fire_line_fn),
MakeFx("tp_fx_blood", Anims.blood, blood_fn),
MakeFx("tp_fx_sign", Anims.sign, sign_fn),
MakeFx("tp_fx_sign_line", {}, sign_line_fn),
MakeFx("tp_fx_sign_circle_point", {}, sign_circle_point_fn),
MakeFx("tp_fx_sign_circle", {}, sign_circle_fn),
MakeFx("tp_fx_sign_wan", {}, sign_wan_fn),
MakeFx("tp_fx_sign_2", Anims.sign, sign_2_fn),
MakeFx("tp_fx_sign_surround", Anims.sign, sign_surround_fn),
MakeFx("tp_fx_sign_three", {}, sign_three_fn),
MakeFx("tp_fx_tree_seed_shadow_1", Anims.acorn, tree_seed_shadow_fn),
MakeFx("tp_fx_tree_seed_shadow_2", Anims.pinecone, tree_seed_shadow_fn),
MakeFx("tp_fx_tree_seed_shadow_3", Anims.jungletreeseed, tree_seed_shadow_fn),
MakeFx("tp_fx_tree_seed_shadow_4", Anims.teatree_nut, tree_seed_shadow_fn),
MakeFx("tp_fx_tree_seed_shadow_5", Anims.coconut, tree_seed_shadow_fn),
MakeFx("tp_fx_tree_seed_1", Anims.acorn, tree_seed_fn),
MakeFx("tp_fx_tree_seed_2", Anims.pinecone, tree_seed_fn),
MakeFx("tp_fx_tree_seed_3", Anims.jungletreeseed, tree_seed_fn),
MakeFx("tp_fx_tree_seed_4", Anims.teatree_nut, tree_seed_fn),
MakeFx("tp_fx_tree_seed_5", Anims.coconut, tree_seed_fn),
MakeFx("tp_fx_many_tree_seed", {}, many_tree_seed_fn),
MakeFx("tp_fx_teatree_nut_surround", Anims.teatree_nut, teatree_nut_surround_fn),
MakeFx("tp_fx_shadow_arc", {}, shadow_arc_fn),
MakeFx("tp_fx_shadow_arc_creater", {}, shadow_arc_creater),
MakeFx("tp_fx_shadow_line", {}, shadow_line_fn),
MakeFx("tp_fx_shadow_line_2", {}, shadow_line_2_fn),
MakeFx("tp_fx_shadow_spawn", {}, shadow_spawn_fn),
MakeFx("tp_fx_shadow_bat", {}, shadow_bat_fn),
MakeFx("tp_fx_sign_wall", Anims.sign, sign_wall_fn),
MakeFx("tp_fx_sign_circle_wall", {}, sign_circle_wall_fn),
MakeFx("tp_fx_sign_line_wall", {}, sign_line_wall_fn),
MakeFx("tp_fx_sign_killer", {}, sign_killer_fn),
MakeFx("tp_fx_shadow_spiral", {}, shadow_spiral_fn),
MakeFx("tp_fx_shadow_spiral_point", {}, shadow_spiral_point_fn),
MakeFx("tp_fx_poison_bubble", Anims.poison_hole, poison_bubble_fn),
MakeFx("tp_fx_spore", Anims.spore, spore_fn),
MakeFx("tp_fx_spore_blue", Anims.spore_blue, spore_fn),
MakeFx("tp_fx_spore_three", {}, spore_three_fn),
MakeFx("tp_fx_boss_spirit", Anims.stafflight, boss_spirit_fn),
MakeFx("tp_fx_boss_spirit_shadow", Anims.stafflight, boss_spirit_shadow_fn),
MakeFx("tp_fx_snow_ball", Anims.snow_ball, snow_ball_fn),
MakeFx("tp_fx_snow_ball_shoot", {}, snow_ball_shoot_fn),
MakeFx("tp_fx_scroll_pig_damage", Anims.hambat, scroll_pig_effect_fn),
MakeFx("tp_fx_scroll_pig_armorex", Anims.armorwood, scroll_pig_effect_fn),
MakeFx("tp_fx_scroll_pig_speed", Anims.coffeebeans, scroll_pig_effect_fn),
MakeFx("tp_fx_scroll_pig_heal", Anims.bandage, scroll_pig_effect_fn),
MakeFx("tp_fx_scroll_pig_armor", Anims.football, scroll_pig_effect_fn),
MakeFx("tp_fx_scroll_pig_leader", Anims.meat, scroll_pig_effect_fn),
MakeFx("tp_fx_scroll_pig_health", Anims.dragonfruit, scroll_pig_effect_fn),
MakeFx("tp_fx_scroll_pig_buff", {}, scroll_pig_buff_fn),
MakeFx("tp_fx_catcoon_pick", Anims.catcoon, catcoon_pick_fn),
MakeFx("tp_fx_wilson_run", Anims.wilson_lunge, wilson_run_fn),
MakeFx("tp_fx_ice_spike", {}, ice_spike_fn),
MakeFx("tp_fx_pigking", Anims.pigking, pigking_fn),
MakeFx("tp_fx_has_item", Anims.has_item, has_item_fn),
MakeFx("tp_fx_armor_broken", {}, armor_broken_fn),
MakeFx("tp_fx_ground_pound", {}, ground_pound_fn),
MakeFx("tp_fx_splash_ground_pound", {}, splash_ground_pound_fn),
MakeFx("tp_fx_charge_surround", Anims.bishop_charge, charge_surround_fn),
MakeFx("tp_fx_light", {}, light_fn),
MakeFx("tp_fx_speech", {}, speech_fn),
MakeFx("tp_fx_dragon_cage_fly", Anims.dragonfly, dragon_cage_fly_fn),
MakeFx("tp_fx_dragon_cage_front", Anims.birdcage, dragon_cage_front_fn),
MakeFx("tp_fx_warm", {}, warm_fn),
MakeFx("tp_fx_cool", {}, cool_fn),
MakeFx("tp_fx_warg_head", Anims.warg, warg_head_fn),
MakeFx("tp_fx_warg_body", Anims.warg, warg_body_fn),
MakeFx("tp_fx_woodie_rider", Anims.woodie, woodie_rider_fn),
MakeFx("tp_fx_warg", Anims.warg, warg_fn),
MakeFx("tp_fx_small_ground_pound", {}, small_ground_pound_fn),
MakeFx("tp_fx_small_ground_pound_ring", {}, small_ground_pound_ring_fn)
-- return 
	-- MakeFx("tp_fx_null", {}, null_fn),
	-- MakeFx("tp_fx_leaf_1", green_leafs, leaf_fn),
	-- MakeFx("tp_fx_leaf_2", green_leafs2, leaf_fn),
	-- MakeFx("tp_fx_leaf_3", green_leafs3, leaf_fn),
	-- MakeFx("tp_fx_leaf_4", green_leafs4, leaf_fn),
	-- MakeFx("tp_fx_leaf_line", {}, leaf_line_fn),
	-- MakeFx("tp_fx_leaf_circle", {}, leaf_circle_fn),
	-- MakeFx("tp_fx_one_sparklefx", sparkles, one_sparklefx_fn),
	-- MakeFx("tp_fx_alive_sparklefx", {}, alive_sparklefx_fn),
	-- MakeFx("tp_fx_small_meat", small_meats, small_meat_fn),
	-- MakeFx("tp_fx_many_small_meat", {}, many_small_meat_fn),
	-- MakeFx("tp_fx_bearger", beargers, bearger_fn),
	-- MakeFx("tp_fx_bearger_line", {}, bearger_line_fn),
	-- MakeFx("tp_fx_dragonfly", dragonflys, dragonfly_fn),
	-- MakeFx("tp_fx_deerclops", deerclopses, deerclops_fn),
	-- MakeFx("tp_fx_moose", mooses, moose_fn),
	-- MakeFx("tp_fx_ham_ground_pound", {}, ham_ground_pound_fn),
	-- MakeFx("tp_fx_wilson_lunge", wilson_lunges, wilson_lunge_fn),
	-- MakeFx("tp_fx_snow_line", {}, snow_line_fn),
	-- MakeFx("tp_fx_fire_line", {}, fire_line_fn),
	-- MakeFx("tp_fx_blood", bloods, blood_fn),
	-- MakeFx("tp_fx_sign", signs, sign_fn),
	-- MakeFx("tp_fx_sign_line", {}, sign_line_fn),
	-- MakeFx("tp_fx_sign_circle_point", {}, sign_circle_point_fn),
	-- MakeFx("tp_fx_sign_circle", {}, sign_circle_fn),
	-- MakeFx("tp_fx_sign_wan", {}, sign_wan_fn),
	-- MakeFx("tp_fx_sign_2", signs, sign_2_fn),
	-- MakeFx("tp_fx_sign_surround", signs, sign_surround_fn),
	-- MakeFx("tp_fx_sign_three", {}, sign_three_fn),
	-- MakeFx("tp_fx_tree_seed_shadow_1", acorns, tree_seed_shadow_fn),
	-- MakeFx("tp_fx_tree_seed_shadow_2", pinecones, tree_seed_shadow_fn),
	-- MakeFx("tp_fx_tree_seed_shadow_3", jungletreeseeds, tree_seed_shadow_fn),
	-- MakeFx("tp_fx_tree_seed_shadow_4", teatree_nuts, tree_seed_shadow_fn),
	-- MakeFx("tp_fx_tree_seed_shadow_5", coconuts, tree_seed_shadow_fn),
	-- MakeFx("tp_fx_tree_seed_1", acorns, tree_seed_fn),
	-- MakeFx("tp_fx_tree_seed_2", pinecones, tree_seed_fn),
	-- MakeFx("tp_fx_tree_seed_3", jungletreeseeds, tree_seed_fn),
	-- MakeFx("tp_fx_tree_seed_4", teatree_nuts, tree_seed_fn),
	-- MakeFx("tp_fx_tree_seed_5", coconuts, tree_seed_fn),
	-- MakeFx("tp_fx_many_tree_seed", {}, many_tree_seed_fn),
	-- MakeFx("tp_fx_teatree_nut_surround", teatree_nuts, teatree_nut_surround_fn),
	-- MakeFx("tp_fx_shadow_arc", {}, shadow_arc_fn),
	-- MakeFx("tp_fx_shadow_arc_creater", {}, shadow_arc_creater),
	-- MakeFx("tp_fx_shadow_line", {}, shadow_line_fn),
	-- MakeFx("tp_fx_shadow_line_2", {}, shadow_line_2_fn),
	-- MakeFx("tp_fx_shadow_spawn", {}, shadow_spawn_fn),
	-- MakeFx("tp_fx_shadow_bat", {}, shadow_bat_fn),
	-- MakeFx("tp_fx_sign_wall", signs, sign_wall_fn),
	-- MakeFx("tp_fx_sign_circle_wall", {}, sign_circle_wall_fn),
	-- MakeFx("tp_fx_sign_line_wall", {}, sign_line_wall_fn),
	-- MakeFx("tp_fx_sign_killer", {}, sign_killer_fn),
	-- MakeFx("tp_fx_shadow_spiral", {}, shadow_spiral_fn),
	-- MakeFx("tp_fx_shadow_spiral_point", {}, shadow_spiral_point_fn),
	-- MakeFx("tp_fx_poison_bubble", poison_holes, poison_bubble_fn),
	-- MakeFx("tp_fx_spore", spores, spore_fn),
	-- MakeFx("tp_fx_spore_blue", spore_blues, spore_fn),
	-- MakeFx("tp_fx_spore_three", {}, spore_three_fn),
	-- MakeFx("tp_fx_boss_spirit", stafflights, boss_spirit_fn),
	-- MakeFx("tp_fx_boss_spirit_shadow", stafflights, boss_spirit_shadow_fn),
	-- MakeFx("tp_fx_snow_ball", snow_balls, snow_ball_fn),
	-- MakeFx("tp_fx_snow_ball_shoot", {}, snow_ball_shoot_fn),
	-- MakeFx("tp_fx_scroll_pig_damage", hambats, scroll_pig_effect_fn),
	-- MakeFx("tp_fx_scroll_pig_armorex", armorwoods, scroll_pig_effect_fn),
	-- MakeFx("tp_fx_scroll_pig_speed", coffeebeanses, scroll_pig_effect_fn),
	-- MakeFx("tp_fx_scroll_pig_heal", bandages, scroll_pig_effect_fn),
	-- MakeFx("tp_fx_scroll_pig_armor", footballs, scroll_pig_effect_fn),
	-- MakeFx("tp_fx_scroll_pig_leader", meats, scroll_pig_effect_fn),
	-- MakeFx("tp_fx_scroll_pig_health", dragonfruits, scroll_pig_effect_fn),
	-- MakeFx("tp_fx_scroll_pig_buff", {}, scroll_pig_buff_fn),
	-- MakeFx("tp_fx_catcoon_pick", catcoons, catcoon_pick_fn),
	-- MakeFx("tp_fx_wilson_run", wilson_lunges, wilson_run_fn),
	-- MakeFx("tp_fx_ice_spike", {}, ice_spike_fn),
	-- MakeFx("tp_fx_pigking", pigkings, pigking_fn),
	-- MakeFx("tp_fx_has_item", has_items, has_item_fn),
	-- MakeFx("tp_fx_armor_broken", {}, armor_broken_fn),
	-- MakeFx("tp_fx_ground_pound", {}, ground_pound_fn),
	-- MakeFx("tp_fx_splash_ground_pound", {}, splash_ground_pound_fn),
	-- MakeFx("tp_fx_charge_surround", bishop_charges, charge_surround_fn),
	-- MakeFx("tp_fx_light", {}, light_fn),
	-- MakeFx("tp_fx_speech", {}, speech_fn),
	-- MakeFx("tp_fx_dragon_cage_fly", dragonflys, dragon_cage_fly_fn),
	-- MakeFx("tp_fx_dragon_cage_front", birdcages, dragon_cage_front_fn),
	-- MakeFx("tp_fx_warm", {}, warm_fn),
	-- MakeFx("tp_fx_cool", {}, cool_fn),
	-- MakeFx("tp_fx_warg_head", wargs, warg_head_fn),
	-- MakeFx("tp_fx_warg_body", wargs, warg_body_fn),
	-- MakeFx("tp_fx_woodie_rider", woodies, woodie_rider_fn),
	-- MakeFx("tp_fx_warg", wargs, warg_fn)
	-- MakeFx("tp_fx_has_alloy", has_alloys, has_alloy_fn),
	-- MakeFx("tp_fx_has", hases, has_fn),
	-- MakeFx("tp_fx_has_2", has_2s, has_fn),