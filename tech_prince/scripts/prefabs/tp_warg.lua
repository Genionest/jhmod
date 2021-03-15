require("brains/wargbrain")
require "stategraphs/SGwarg"

SetSharedLootTable('tp_blue_warg',
{
    {'bluegem',             1.00},
    {'bluegem',             1.00},
    {'bluegem',             1.00},
    {'bluegem',             1.00},
    {'bluegem',             0.50},
    {'bluegem',             0.50},
    
    {'houndstooth',             1.00},
    {'houndstooth',             0.66},
    {'houndstooth',             0.33},
})
SetSharedLootTable('tp_red_warg',
{
    {'redgem',             1.00},
    {'redgem',             1.00},
    {'redgem',             1.00},
    {'redgem',             1.00},
    {'redgem',             0.50},
    {'redgem',             0.50},
    
    {'houndstooth',             1.00},
    {'houndstooth',             0.66},
    {'houndstooth',             0.33},
})

local function RetargetFn(inst)
	if inst.sg:HasStateTag("hidden") then return end
    return FindEntity(inst, TUNING.WARG_TARGETRANGE, function(guy)
        return inst.components.combat:CanTarget(guy) 
        and not guy:HasTag("wall") 
        and not guy:HasTag("warg") 
        and not guy:HasTag("hound")
    end)
end

local function KeepTargetFn(inst, target)
	if inst.sg:HasStateTag("hidden") then return end
    if target then
        return distsq(inst:GetPosition(), target:GetPosition()) < 40*40
        and not target.components.health:IsDead()
        and inst.components.combat:CanTarget(target)
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
	inst.components.combat:ShareTarget(data.attacker, TUNING.WARG_MAXHELPERS, function(dude)
	        return dude:HasTag("warg") or dude:HasTag("hound") 
	        and not dude.components.health:IsDead()
		end, TUNING.WARG_TARGETRANGE)
	if data.damage and (data.damage<30 and math.random() < .2)
	or (data.damage>=30 and math.random() < .5) then
		if inst:HasTag("tp_blue_warg") then
			inst.components.lootdropper:SpawnLootPrefab("bluegem")
		elseif inst:HasTag("tp_red_warg") then
			inst.components.lootdropper:SpawnLootPrefab("redgem")
		end
	end
end

local function MakeWarg(name, bank, build, tag)
	local function fn()
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		local sound = inst.entity:AddSoundEmitter()
		local shadow = inst.entity:AddDynamicShadow()
		shadow:SetSize( 2.5, 1.5 )

		local s = 1
		trans:SetScale(s,s,s)

		trans:SetSixFaced()
		MakeCharacterPhysics(inst, 1000, 2)
		MakePoisonableCharacter(inst)

		anim:SetBank(bank)
		anim:SetBuild(build)
		anim:PlayAnimation("idle")

		inst:AddTag("monster")
		inst:AddTag("warg")
		inst:AddTag("scarytoprey")
		inst:AddTag("houndfriend")
		inst:AddTag("largecreature")
		inst:AddTag(tag)

		inst.has_friend = true

		inst:AddComponent("inspectable")

		inst:AddComponent("leader")

		inst:AddComponent("locomotor")
		inst.components.locomotor.runspeed = TUNING.WARG_RUNSPEED
	    inst.components.locomotor:SetShouldRun(true)

		inst:AddComponent("combat")
	    inst.components.combat:SetDefaultDamage(TUNING.WARG_DAMAGE)
	    inst.components.combat:SetRange(TUNING.WARG_ATTACKRANGE)
	    inst.components.combat:SetAttackPeriod(TUNING.WARG_ATTACKPERIOD)
	    inst.components.combat:SetRetargetFunction(1, RetargetFn)
	    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
	    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/vargr/hit")
	    inst:ListenForEvent("attacked", OnAttacked)

		inst:AddComponent("health")
	    inst.components.health:SetMaxHealth(TUNING.WARG_HEALTH)

		inst:AddComponent("lootdropper")
	    inst.components.lootdropper:SetChanceLootTable(name) 

	    -- inst:AddComponent("sleeper")

		MakeLargeFreezableCharacter(inst)
		MakeLargeBurnableCharacter(inst, "swap_fire")

		inst.OnSave = function(inst, data)
			if data then 
				data.has_friend = inst.has_friend 
			end
		end
		inst.OnLoad = function(inst, data)
			if data then
				inst.has_friend = data.has_friend
			end
		end

		inst:SetStateGraph("SGwarg")
		inst:SetBrain(require("brains/wargbrain"))
		WARGON.do_task(inst, 0, function()
			if c_countprefabs(name) > 3 then
				inst:Remove()
			end
		end)

		return inst
	end
	return Prefab("common/"..name, fn, {})
end

local function MakeSpawner(name, warg)
	local function fn()
		local inst = WARGON.make_prefab({})
		WARGON.do_task(inst, 0, function()
			-- local warg = math.random() < .5 and "tp_blue_warg" or "tp_red_warg"
			if c_find(warg) == nil then
				local boss = WARGON.make_spawn(inst, warg)
				boss.has_friend = false
			end
			inst:Remove()
		end)

		return inst
	end
	return Prefab("common/"..name, fn, {})
end

return 
	MakeWarg("tp_blue_warg", "tp_blue_warg", "tp_blue_warg", "tp_blue_warg"),
	MakeWarg("tp_red_warg", "tp_red_warg", "tp_red_warg", "tp_red_warg"),
	-- MakeSpawner("tp_warg_spawner"),
	MakeSpawner("tp_blue_warg_spawner", "tp_blue_warg"),
	MakeSpawner("tp_red_warg_spawner", "tp_red_warg")