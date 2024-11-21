local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 2.5, 1.5 )

	trans:SetFourFaced()
	local s = 1
	trans:SetScale(s,s,s)
	MakeCharacterPhysics(inst, 100, .5)

	anim:SetBank("warg")
	anim:SetBuild("warg_build")
	anim:PlayAnimation("idle_loop", true)
	-- anim:Hide("WARG_FACEBASE")
	-- anim:Hide("WARG_EYE")
	-- anim:Hide("WARG_MOUTH")
	-- anim:Hide("WARG_BODY")
	-- anim:Hide("WARG_HOOF")
	-- anim:Hide("WARG_TAIL")

	inst:AddComponent("inspectable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1000)
    inst:AddComponent("wargrideable")

	return inst
end

local function fxfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	-- local sound = inst.entity:AddSoundEmitter()
	trans:SetFourFaced()
	local s = 1
	trans:SetScale(s,s,s)
	anim:SetBank("warg")
	anim:SetBuild("warg_build")
	-- anim:SetBuild("")
	-- anim:SetBank("koalefant")
	-- anim:SetBuild("koalefant_summer_build")
	anim:PlayAnimation("idle_loop", true)
	anim:Hide("beefalo_head")
	anim:Hide("beefalo_antler")
	anim:Hide("beefalo_body")
	-- anim:SetLayer( 2.5 )
	inst:AddComponent("wargrideable")
	return inst
end

local function fxfn2()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	-- local sound = inst.entity:AddSoundEmitter()
	trans:SetFourFaced()
	local s = 1
	trans:SetScale(s,s,s)
	anim:SetBank("warg")
	anim:SetBuild("warg_build")
	-- anim:SetBuild("")
	-- anim:SetBank("koalefant")
	-- anim:SetBuild("koalefant_summer_build")
	anim:PlayAnimation("idle_loop", true)
	anim:Hide("beefalo_hoof")
	anim:Hide("beefalo_tail")
	anim:Hide("beefalo_facebase")
	anim:Hide("beefalo_mouth")
	anim:Hide("beefalo_eye")
	-- anim:SetLayer( 2.5 )
	-- anim:SetSortOrder(  )
	-- inst:AddComponent("wargrideable")
	return inst
end

return Prefab("common/ride_warg", fn, {}),
	Prefab("common/ride_warg_head_fx", fxfn2, {}),
	Prefab("common/ride_warg_body_fx", fxfn, {})