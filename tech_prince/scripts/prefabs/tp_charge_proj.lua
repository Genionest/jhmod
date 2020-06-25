local function can_target(target, inst)
    if target.components.combat and target.components.health
    and inst.master.components.combat:CanTarget(target) then
        for k, v in pairs(inst.no_targets) do
            if v == target then
                return false
            end
        end
        return true
    end
end

local function OnMiss(inst, owner, target)
    inst:Remove()
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")
end

local function OnHit(inst, owner, target)
    table.insert(inst.no_targets, target)
    if #inst.no_targets <= 10 then
        local new_target = WARGON.find(inst, 5, can_target, nil, 
            {"player", "wall", "FX", "NOCLICK", "INLIMBO"})
        if new_target then
            inst.components.tpproj:Throw(owner, new_target, owner)
        else
            inst:Remove()
        end
    else
        inst:Remove()
    end
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")
end

local function fn()
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
    inst.no_targets = {}

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(10)
    -- inst.components.weapon:SetRange(1, 1)
    inst:AddComponent("tpproj")
    inst.components.tpproj:SetSpeed(20)
    -- inst.components.tpproj:SetHoming(false)
    -- inst.components.tpproj:SetHitDist(2)
    inst.components.tpproj:SetOnHitFn(OnHit)
    inst.components.tpproj:SetOnMissFn(OnMiss)
    inst.components.tpproj:SetLaunchOffset(Vector3(0, -1, 0))
    
    return inst
end

return Prefab( "common/inventory/tp_charge_proj", fn, {}) 
