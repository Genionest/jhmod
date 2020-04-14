local assets = {
	Asset("ANIM", "anim/monkey_beardhair.zip"),
	Asset("ATLAS", "images/inventoryimages/monkey_beardhair.xml"),
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	anim:SetBank("monkey_beardhair")
    anim:SetBuild("monkey_beardhair")
    anim:PlayAnimation("idle")
	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "idle_water", "idle")
	MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/monkey_beardhair.xml"
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = 10

	return inst
end

return Prefab("common/inventory/monkey_beardhair", fn, assets)