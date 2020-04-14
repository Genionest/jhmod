local function fn()
	local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "sign.png" )

    anim:SetBank("sign_home")
    anim:SetBuild("sign_home")
    anim:PlayAnimation("idle")

    inst:AddComponent("inspectable")

    return inst
end

return Prefab("common/pigking_sign", fn, {})