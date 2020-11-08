local assets =
{
}

local function on_hit(inst, owner, target)
    inst:Remove()
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")
end

local function bishop_charge_fn()
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
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(2)
    inst.components.projectile:SetOnHitFn(on_hit)
    inst.components.projectile:SetOnMissFn(on_hit)
    inst.components.projectile:SetLaunchOffset(Vector3(0, -1, 0))
    
    return inst
end

local function spear_shoot_ball_dmg(inst,ent, targets, rad, hit)
    local x, y, z = inst.Transform:GetWorldPosition()
    if hit then 
        targets = {}
    end    
    if not rad then 
        rad = 0
    end
    local v = ent
    if not targets[v] and v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) and not v:HasTag("laser_immune") then            
        local vradius = 0
        if v.Physics then
            vradius = v.Physics:GetRadius()
        end

        local range = rad + vradius
        if hit or v:GetDistanceSqToPoint(Vector3(x, y, z)) < range * range then
            if v.components.health then            
                inst.components.combat:DoAttack(v)     
                WARGON.FX.impact_fx(inst, v)                                               
            end
        end
    end 
    return targets   
end

local function spear_shoot_ball_collide(inst,other)
    spear_shoot_ball_dmg(inst,other,nil,nil,true)
    inst:Remove()
end

local function spear_shoot_ball_fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    MakeCharacterPhysics(inst, 1, 0.5)

    -- Don't collide with the land edge
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.WAVES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
    
    inst.Physics:SetCollisionCallback(spear_shoot_ball_collide)

    anim:SetBank("bulb")
    anim:SetBuild("bulb")
    anim:PlayAnimation("idle", true)    

    inst.Transform:SetScale(0.5,0.5,0.5)

    inst.persists = false

    inst:AddComponent("locomotor")
    inst:AddTag("projectile")

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.ANCIENT_HULK_MINE_DAMAGE/3)

    inst.Physics:SetMotorVelOverride(60,0,0)

    inst:DoTaskInTime(2,function() inst:Remove() end)

    inst:AddComponent("fader")
    inst.glow = inst.entity:AddLight()    
    inst.glow:SetIntensity(.6)
    inst.glow:SetRadius(3)
    inst.glow:SetFalloff(1)
    -- inst.glow:SetColour(1, 0.3, 0.3)
    inst.glow:SetColour(0.3, 0.6, 0.5)
    inst.glow:Enable(true)

    return inst
end

return 
Prefab("common/inventory/tp_spear_shoot_ball", spear_shoot_ball_fn, {}),

Prefab( "common/inventory/tp_bishop_charge", bishop_charge_fn, assets)
