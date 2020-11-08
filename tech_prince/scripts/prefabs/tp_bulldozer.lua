local function fn(Sim)
    local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize(6, 3.5)
    
    inst.Transform:SetSixFaced()

	MakeCharacterPhysics(inst, 1000, 1.5)

    inst.Physics:SetCollisionCallback(OnCollide)

    anim:SetBank("metal_hulk")
    anim:SetBuild("metal_hulk_build")
    anim:PlayAnimation("idle", true)
    
    anim:AddOverrideBuild("laser_explode_sm")
    anim:AddOverrideBuild("smoke_aoe")    
    anim:AddOverrideBuild("laser_explosion")   
    anim:AddOverrideBuild("ground_chunks_breaking")   
     
    ------------------------------------------

	-- inst:AddTag("epic")
 --    inst:AddTag("monster")
 --    inst:AddTag("hostile")
 --    inst:AddTag("scarytoprey")
 --    inst:AddTag("largecreature")
 --    inst:AddTag("ancient_hulk") 
 --    inst:AddTag("laser_immune")   
 --    inst:AddTag("mech")

    ------------------------------------------

    -- inst:AddComponent("sanityaura")
    -- inst.components.sanityaura.aurafn = CalcSanityAura

    ------------------
    
    -- inst:AddComponent("health")
    -- inst.components.health:SetMaxHealth(TUNING.BEARGER_HEALTH)
    -- inst.components.health.destroytime = 5
    -- inst.components.health.fire_damage_scale = 0
    
    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.ANCIENT_HULK_DAMAGE)
    -- inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetRange(TUNING.ANCIENT_HULK_ATTACK_RANGE, TUNING.ANCIENT_HULK_MELEE_RANGE)
    inst.components.combat:SetAreaDamage(5.5, 0.8)
    inst.components.combat.hiteffectsymbol = "segment01"
    inst.components.combat:SetAttackPeriod(TUNING.BEARGER_ATTACK_PERIOD)
    -- inst.components.combat:SetRetargetFunction(3, RetargetFn)
    -- inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    --inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/bearger/hurt")
    -- inst:ListenForEvent("killed", function(inst, data)
    --     if inst.components.combat and data and data.victim == inst.components.combat.target then
    --         inst.components.combat.target = nil
    --     end 
    -- end)


    inst.orbs = 2
    ------------------------------------------

    inst:AddComponent("lootdropper")
    -- inst.components.lootdropper:SetChanceLootTable("ancient_hulk")
    
    ------------------------------------------

    inst:AddComponent("inspectable")

    ------------------------------------------

    -- inst:AddComponent("groundpounder")
    -- inst.components.groundpounder.destroyer = true
    -- inst.components.groundpounder.damageRings = 2
    -- inst.components.groundpounder.destructionRings = 3
    -- inst.components.groundpounder.numRings = 3
    -- inst.components.groundpounder.groundpoundfx = "groundpound_fx_hulk"

    ------------------------------------------

    -- inst:ListenForEvent("attacked", OnAttacked)

    ------------------------------------------
    inst:AddComponent("fader")
    inst.glow = inst.entity:AddLight()    
    inst.glow:SetIntensity(.6)
    inst.glow:SetRadius(5)
    inst.glow:SetFalloff(3)
    inst.glow:SetColour(1, 0.3, 0.3)
    inst.glow:Enable(false)

    -- inst.OnSave = OnSave
    -- inst.OnLoad = OnLoad
    -- inst.LaunchProjectile = LaunchProjectile
    -- inst.ShootProjectile = ShootProjectile
    -- inst.DoDamage = DoDamage
    -- inst.spawnbarrier = spawnbarrier
    -- inst.dropparts = dropparts
    -- inst.SetLightValue = SetLightValue

    inst:DoPeriodicTask(1,function() checkforAttacks(inst) end)

    inst:ListenForEvent( "onremove", function() inst.SoundEmitter:KillSound("gears") print("KILLLL GEARS!!!!!!!!!")  end, inst )
    
    ------------------------------------------

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.BEARGER_RUN_SPEED
    inst.components.locomotor:SetShouldRun(true)

    inst:SetStateGraph("SGancient_hulk")
    local brain = require("brains/ancient_hulkbrain")
    inst:SetBrain(brain)

    if not inst.shotspawn then
        inst.shotspawn = SpawnPrefab( "ancient_hulk_marker" )        
        inst.shotspawn:Hide()
        inst.shotspawn.persists = false
        local follower = inst.shotspawn.entity:AddFollower()
        follower:FollowSymbol( inst.GUID, "hand01", 0,0,0 )
    end


    return inst
end

return Prefab("common/tp_bulldozer", fn, {})