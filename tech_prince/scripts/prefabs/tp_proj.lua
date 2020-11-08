-- it's not a projectile, must be remove on hit.
local bishop_charges = {"bishop_attack", "bishop_attack", "idle"}

local function proj_remove(inst)
    inst:Remove()
end

local function charge_proj_can_target(target, inst)
    if target.components.combat and target.components.health
    and inst.master.components.combat:CanTarget(target)
    and target.components.follower
    and target.components.follower.leader ~= GetPlayer() then
        for k, v in pairs(inst.no_targets) do
            if v == target then
                return false
            end
        end
        return true
    end
end

local function charge_proj_miss(inst, owner, target)
    inst:Remove()
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")
end

-- it need attack many target, not be removed at the moment.
local function charge_proj_hit(inst, owner, target)
    table.insert(inst.no_targets, target)
    if #inst.no_targets <= 10 then
        local new_target = WARGON.find(inst, 5, charge_proj_can_target, nil, 
            {"player", "wall", "companion", "FX", "NOCLICK", "INLIMBO"})
        if new_target then
            inst.components.tpproj:Throw(owner, new_target, owner)
        else
            inst:Remove()
        end
    else
        inst:Remove()
    end
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")
    -- inst:Remove()
end

local charge_proj_data = {
    damage = 10, speed = 20, hit = charge_proj_hit,
    miss = charge_proj_miss, offset = Vector3(0, -1, 0),
}

local function soul_charge_hit(inst, owner, target)
    -- local ents = WARGON.finds(target, 20, {"ghost"})
    -- local count = 0
    -- for k, v in pairs(ents) do
    --     count = count + 1
    -- end
    -- if count < 8 then
        WARGON.make_spawn(target, "ghost")
    -- end
    inst:Remove()
end

local function charge_proj_fn(inst)
    inst.no_targets = {}
end

local soul_charge_data = {
    damage = 150, speed = 20, hit = soul_charge_hit,
    miss = proj_remove, offset = Vector3(0, -1, 0),
}

local function soul_charge_fn(inst)
    inst.AnimState:PlayAnimation("idle", true)
end

local function MakeProj(name, anims, data, proj_fn)
    local function fn()
    	local inst = CreateEntity()
    	local trans = inst.entity:AddTransform()
    	inst.Transform:SetFourFaced()
    	local anim = inst.entity:AddAnimState()
    	local sound = inst.entity:AddSoundEmitter()
    	
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
        
        anim:SetBank(anims[1])
        anim:SetBuild(anims[2])
        anim:PlayAnimation(anims[3])
        
        inst:AddTag("projectile")
        inst.persists = false
        inst:AddComponent("weapon")
        inst:AddComponent("tpproj")

        -- inst.no_targets = {}
        inst.components.weapon:SetDamage(data.damage)
        -- inst.components.weapon:SetRange(1, 1)
        inst.components.tpproj:SetSpeed(data.speed)
        -- inst.components.tpproj:SetHoming(false)
        -- inst.components.tpproj:SetHitDist(2)
        inst.components.tpproj:SetOnHitFn(data.hit)
        inst.components.tpproj:SetOnMissFn(data.miss)
        inst.components.tpproj:SetLaunchOffset(data.offset)
        if proj_fn then
            proj_fn(inst)
        end
        
        return inst
    end

    return Prefab( "common/inventory/"..name, fn, {}) 
end

return 
    MakeProj("tp_charge_proj", bishop_charges, charge_proj_data, charge_proj_fn),
    MakeProj("tp_soul_charge", bishop_charges, soul_charge_data, soul_charge_fn)