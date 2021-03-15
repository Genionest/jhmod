local assets =
{
    -- Asset("ANIM", "anim/lantern_tesla_fx.zip"),
	--Asset("DYNAMIC_ANIM", "anim/dynamic/lantern_tesla.zip"),
    --Asset("PKGREF", "anim/dynamic/lantern_tesla.dyn"),
}

local BLANK_FRAMES = { 0, 14, 15, 29, 30, 31, 42 }

local function MakeFX(suffix)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst:AddTag("FX")
		inst:AddTag("INTERIOR_LIMBO_IMMUNE")

        inst.AnimState:SetBank("lantern_tesla_fx")
        inst.AnimState:SetBuild("lantern_tesla_fx")
        inst.AnimState:PlayAnimation("idle_"..suffix, true)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetFinalOffset(1)

        inst.persists = false
        return inst
    end

    return Prefab("tp_thunder_fx_"..suffix, fn, assets)
end

return MakeFX("held"),
    MakeFX("ground")