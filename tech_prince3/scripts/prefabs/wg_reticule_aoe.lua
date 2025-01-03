local assets =
{
    Asset("ANIM", "anim/reticuleaoe.zip"),
    --Asset("ANIM", "anim/reticuleaoebase.zip"),
}

local PAD_DURATION = .1
local SCALE = 1.5
local FLASH_TIME = .3

local function UpdatePing(inst, s0, s1, t0, duration, multcolour, addcolour)
    if next(multcolour) == nil then
        multcolour[1], multcolour[2], multcolour[3], multcolour[4] = inst.AnimState:GetMultColour()
    end
    if next(addcolour) == nil then
        addcolour[1], addcolour[2], addcolour[3], addcolour[4] = inst.AnimState:GetAddColour()
    end
    local t = GetTime() - t0
    local k = 1 - math.max(0, t - PAD_DURATION) / duration
    k = 1 - k * k
    local s = Lerp(s0, s1, k)
    local c = Lerp(1, 0, k)
    inst.Transform:SetScale(s, s, s)
    inst.AnimState:SetMultColour(multcolour[1], multcolour[2], multcolour[3], c * multcolour[4])

    k = math.min(FLASH_TIME, t) / FLASH_TIME
    c = math.max(0, 1 - k * k)
    inst.AnimState:SetAddColour(c * addcolour[1], c * addcolour[2], c * addcolour[3], c * addcolour[4])
end

local function MakePing(name, anim, scaleup)
    local function fn()
        local inst = CreateEntity()

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst.AnimState:SetBank("reticuleaoe")
        inst.AnimState:SetBuild("reticuleaoe")
        inst.AnimState:PlayAnimation(anim)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGroundFixed)
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
        inst.AnimState:SetScale(SCALE, SCALE)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

        local duration = .5
        inst:DoPeriodicTask(0, UpdatePing, nil, 1, scaleup, GetTime(), duration, {}, {})
        inst:DoTaskInTime(duration, inst.Remove)

        return inst
    end

    return Prefab(name, fn, assets)
end

--------------------------------------------------------------------------

--[[local function CreateBase()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")]]
    --[[Non-networked entity]]
    --[[inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("reticuleaoebase")
    inst.AnimState:SetBuild("reticuleaoebase")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGroundFixed)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(SCALE, SCALE)
    inst.AnimState:SetMultColour(1, 1, 0, 1)

    inst.Transform:SetRotation(90)

    return inst
end

local function OnHideReticule(inst)
    if inst.base ~= nil and inst.base:IsValid() then
        inst.base:Hide()
    end
    inst._Hide(inst)
end

local function OnShowReticule(inst)
    if inst.base ~= nil and inst.base:IsValid() then
        inst.base:Show()
    end
    inst._Show(inst)
end

local function OnRemoveReticule(inst)
    if inst.base ~= nil and inst.base:IsValid() then
        inst.base:Remove()
    end
end]]

local function MakeReticule(name, anim)
    local function fn()
        local inst = CreateEntity()

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst.AnimState:SetBank("reticuleaoe")
        inst.AnimState:SetBuild("reticuleaoe")
        inst.AnimState:PlayAnimation(anim)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
        inst.AnimState:SetScale(SCALE, SCALE)

        --[[if ThePlayer ~= nil and not TheInput:ControllerAttached() then
            inst.base = CreateBase()
            inst.base.entity:SetParent(ThePlayer.entity)

            inst._Hide = inst.Hide
            inst._Show = inst.Show
            inst.Hide = OnHideReticule
            inst.Show = OnShowReticule
            inst.OnRemoveEntity = OnRemoveReticule
        end]]
        inst.UpdatePosition = function(inst)
            inst.Transform:SetPosition(TheInput:GetWorldPosition():Get())
        end

        return inst
    end

    return Prefab("wg_"..name, fn, assets)
end

local reticule_target = Prefab("wg_reticule_target", function(inst)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("reticuleaoe")
    inst.AnimState:SetBuild("reticuleaoe")
    inst.AnimState:PlayAnimation("idle_small")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(SCALE, SCALE)

    --[[if ThePlayer ~= nil and not TheInput:ControllerAttached() then
        inst.base = CreateBase()
        inst.base.entity:SetParent(ThePlayer.entity)

        inst._Hide = inst.Hide
        inst._Show = inst.Show
        inst.Hide = OnHideReticule
        inst.Show = OnShowReticule
        inst.OnRemoveEntity = OnRemoveReticule
    end]]
    inst:DoTaskInTime(0, function()
        local fx = SpawnPrefab("wg_reticuleaoesmall")
        fx.Transform:SetPosition(0,0,0)
        fx.Transform:SetScale(0.3,0.3,0.3)
        inst:AddChild(fx)
    end)

    inst.UpdatePosition = function(inst)
        inst.Transform:SetPosition(TheInput:GetWorldPosition():Get())
    end

    return inst
end)

return reticule_target,
    MakeReticule("reticuleaoe", "idle"),
    MakeReticule("reticuleaoesmall", "idle_small"),
    MakeReticule("reticuleaoesummon", "idle_summon")
    -- MakePing("reticuleaoeping", "idle", 1.05),
    -- MakePing("reticuleaoesmallping", "idle_small", 1.1),
    -- MakePing("reticuleaoesummonping", "idle_summon", 1.025),
    -- MakeTarget("reticuleaoehostiletarget", "idle_target", { 1, .25, 0, 1 }),
    -- MakeTarget("reticuleaoefriendlytarget", "idle_target", { 0, 1, .25, 1 }),
    -- MakeTarget("reticuleaoecctarget", "idle_target", { .3, .5, .2, 1 }),
    -- MakeTarget("reticuleaoesmallhostiletarget", "idle_small_target", { 1, .25, 0, 1 }),
    -- MakeTarget("reticuleaoesummontarget", "idle_summon_target", { .3, .5, .2, 1 })
