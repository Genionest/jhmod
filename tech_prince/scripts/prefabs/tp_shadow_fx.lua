local assets =
{
    -- Asset("ANIM", "anim/cane_shadow_fx.zip"),
}

local NUM_VARIATIONS = 3
local MIN_SCALE = 1
local MAX_SCALE = 1.8

local function PlayShadowAnim(proxy, anim, scale, flip)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

	inst.Transform:SetPosition(proxy.Transform:GetWorldPosition())

    inst.AnimState:SetBank("cane_shadow_fx")
    inst.AnimState:SetBuild("cane_shadow_fx")
    inst.AnimState:SetScale(flip and -scale or scale, scale)
    inst.AnimState:SetMultColour(1, 1, 1, .5)
    inst.AnimState:PlayAnimation(anim)

    inst:ListenForEvent("animover", inst.Remove)
end

local function OnRandDirty(inst)
    if inst._complete or inst._rand <= 0 then
        return
    end

    local flip = inst._rand > 31
    local scale = MIN_SCALE + (MAX_SCALE - MIN_SCALE) * (flip and inst._rand - 32 or inst._rand - 1) / 30
    inst:DoTaskInTime(0, PlayShadowAnim, "shad"..inst.variation, scale, flip)
end

local function MakeShadowFX(name, num, prefabs)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()

        inst:AddTag("FX")
        inst:AddTag("shadowtrail")

        inst.variation = tostring(num or math.random(NUM_VARIATIONS))

		inst._rand = math.random(62)
        inst._complete = false
		OnRandDirty(inst)

        inst.persists = false
        inst:DoTaskInTime(1.5, inst.Remove)
        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local ret = {}
local prefs = {}
for i = 1, NUM_VARIATIONS do
    local name = "tp_shadow_fx"..tostring(i)
    table.insert(prefs, name)
    table.insert(ret, MakeShadowFX(name, i))
end
table.insert(ret, MakeShadowFX("tp_shadow_fx", nil, prefs))
prefs = nil

return unpack(ret)
