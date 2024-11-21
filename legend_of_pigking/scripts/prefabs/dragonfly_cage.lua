local function AcceptTestFn(inst, item)
    if inst.components.dragonflycage.fly == nil then
        return prefab.item == "dragon_scales"
    end
end

local function OnHammeredFn(inst, worker)
    inst:Remove()
end

local function OnHitFn(inst, worker)
    inst.AnimState:PlayAnimation("hit_idle")
    inst.AnimState:PushAnimation("idle")
end

local function fn()
	local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "birdcage.png" )

    anim:SetBank("bird_cage")
    anim:SetBuild("bird_cage")
    anim:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddComponent("inspectable")
    inst:AddComponent("dragonflycage")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(OnHammeredFn)
    inst.components.workable:SetOnWorkCallback(OnHitFn)  

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(AcceptTestFn)
    inst.components.trader.onaccept = OnAcceptFn
    inst.components.trader.onrefuse = OnRefuseFn
    -- inst.components.trader:Disable()  

    return inst
end

return Prefab("common/dragonfly_cage", fn, {})