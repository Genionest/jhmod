local assets =
{
    -- Asset("ANIM", "anim/lantern_winter_fx.zip"),
}

local function KillFX(inst)
    if inst:GetTimeAlive() > 0 then
        inst.killed = true
    else
        inst:Remove()
    end
end

local function IsMovingStep(step)
    return step ~= 0 and step ~= 3
end

local function OnSnowflakeAnimOver(inst)
    if inst.snowflakeemitter:IsValid() then
        if IsMovingStep(inst.step) then
            if inst.snowflakeemitter.ismoving then
                inst:Show()
            else
                inst:Hide()
            end
        end
        inst.Transform:SetPosition(inst.snowflakeemitter.Transform:GetWorldPosition())
        inst.AnimState:PlayAnimation(inst.anim)
    else
        inst:Remove()
    end
end

local function CreateSnowflake(snowflakeemitter, variation, step)
    local inst = CreateEntity()
    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("lantern_winter_fx")
    inst.AnimState:SetBuild("lantern_winter_fx")
    inst.AnimState:OverrideSymbol("snowflake", "lantern_winter_fx", "snowflake")
    inst.AnimState:SetFinalOffset(1)

    inst.snowflakeemitter = snowflakeemitter
    inst.anim = "snowfall"..tostring(variation)
    inst.step = step
    inst:ListenForEvent("animover", OnSnowflakeAnimOver)
    OnSnowflakeAnimOver(inst)

    return inst
end

local function CheckMoving(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        local newpos = parent:GetPosition()
        inst.ismoving = inst.prevpos ~= nil and inst.prevpos ~= newpos
        inst.prevpos = newpos
    else
        inst.ismoving = false
    end
end

local function snowfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --inst.entity:AddNetwork()

    inst:AddTag("FX")

    --Dedicated server does not need to spawn the local fx
    --if not TheNet:IsDedicated() then
        for i = 0, 5 do
            local delay = i * 86 / 6 * FRAMES
            inst:DoTaskInTime(delay + 1 * FRAMES, CreateSnowflake, 1, i)
            inst:DoTaskInTime(delay + 7 * FRAMES, CreateSnowflake, 2, i)
            inst:DoTaskInTime(delay + 13 * FRAMES, CreateSnowflake, 3, i)
            inst:DoTaskInTime(delay + 30 * FRAMES, CreateSnowflake, 4, i)
            inst:DoTaskInTime(delay + 41 * FRAMES, CreateSnowflake, 5, i)
            inst:DoTaskInTime(delay + 58 * FRAMES, CreateSnowflake, 6, i)
            inst:DoTaskInTime(delay + 67 * FRAMES, CreateSnowflake, 7, i)
        end
        inst.ismoving = false
        inst:DoPeriodicTask(0, CheckMoving)
    --end
    inst.persists = false

    return inst
end

local function OnGroundAnimOver(inst)
    if not inst.killed then
        if not inst.AnimState:IsCurrentAnimation("snow_pre") then
            inst.AnimState:Show("hidepre")
        end
        inst.AnimState:PlayAnimation("snow_loop")
    elseif inst.AnimState:IsCurrentAnimation("snow_pst") then
        inst:Remove()
    else
        inst.AnimState:PlayAnimation("snow_pst")
    end
end

local function groundfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("lantern_winter_fx")
    inst.AnimState:SetBuild("lantern_winter_fx")
    inst.AnimState:Hide("hidepre")
    inst.AnimState:PlayAnimation("snow_pre")
    inst.AnimState:SetFinalOffset(1)

    --inst.entity:SetPristine()

    --if not TheWorld.ismastersim then
    --    return inst
    --end
	inst.AnimState:OverrideSymbol("snowflake", "lantern_winter_fx", "snowflake")
    inst.persists = false

    --if POPULATING then
        --inst.AnimState:PushAnimation("snow_loop")
        --inst.AnimState:SetTime(math.random() * (inst.AnimState:GetCurrentAnimationLength() - FRAMES))
		--inst.AnimState:SetTime(math.random() * (2.867 - FRAMES))
    --end

    inst:ListenForEvent("animover", OnGroundAnimOver)
    inst.KillFX = KillFX

    return inst
end

return Prefab("tp_snow_fx", snowfn, assets),
    Prefab("tp_snow_fx_ground", groundfn, assets)
