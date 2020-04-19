local assets =
{
	Asset("ANIM", "anim/rowboat_basic.zip"),
	Asset("ANIM", "anim/boat_buling_build.zip"),
	Asset("ANIM", "anim/bulingboat_tiexue_build.zip"),
}

local prefabs = {}

local function setupcontainer(inst, slots, bank, build, inspectslots, inspectbank, inspectbuild, inspectboatbadgepos, inspectboatequiproot)
	inst:AddComponent("container")
	inst.components.container:SetNumSlots(#slots)
	inst.components.container.type = "boat"
	inst.components.container.side_align_tip = -500
	inst.components.container.canbeopened = false

	inst.components.container.widgetslotpos = slots
	inst.components.container.widgetanimbank = bank
	inst.components.container.widgetanimbuild = build
	inst.components.container.widgetboatbadgepos = Vector3(0, 40, 0)
	inst.components.container.widgetequipslotroot = Vector3(-80, 40, 0)


	local boatwidgetinfo = {}
	boatwidgetinfo.widgetslotpos = inspectslots
	boatwidgetinfo.widgetanimbank = inspectbank
	boatwidgetinfo.widgetanimbuild = inspectbuild
	boatwidgetinfo.widgetboatbadgepos = inspectboatbadgepos
	boatwidgetinfo.widgetpos = Vector3(200, 0, 0)
	boatwidgetinfo.widgetequipslotroot = inspectboatequiproot
	inst.components.container.boatwidgetinfo = boatwidgetinfo
end 

local function boat_perish(inst)
	if inst.components.drivable.driver then
		local driver = inst.components.drivable.driver
		driver.components.driver:OnDismount(true)
		driver.components.health:Kill("drowning")
		inst.SoundEmitter:PlaySound(inst.sinksound)
		inst:Remove()
	end
end

local function candrive(inst, driver)
	return driver and driver.prefab and driver.prefab == "buling_wx78"
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
	trans:SetFourFaced()

	inst:AddTag("shadowboat")

	anim:SetBank("rowboat")
	anim:SetBuild("boat_buling_build")
	anim:PlayAnimation("run_loop", true)

	--setupcontainer(inst, {}, "boat_hud_raft", "boat_hud_raft", {}, "boat_inspect_raft", "boat_inspect_raft", {x=0,y=5}, {})

	inst:AddComponent("drivable")
	inst.components.drivable.sanitydrain = TUNING.ROWBOAT_SANITY_DRAIN
	inst.components.drivable.runspeed = TUNING.ROWBOAT_SPEED
	inst.components.drivable.runanimation = "sail_loop"
	inst.components.drivable.prerunanimation = "sail_pre"
	inst.components.drivable.postrunanimation = "sail_pst"
	inst.components.drivable.overridebuild = "boat_buling_build"
	inst.components.drivable.flotsambuild = "flotsam_rowboat_build"
	inst.components.drivable.hitfx = "boat_hit_fx_rowboat"
	inst.components.drivable.maprevealbonus = TUNING.MAPREVEAL_ROWBOAT_BONUS
	inst.components.drivable.candrivefn = candrive

	--inst.AnimState:SetMultColour(0,0,0,.4)

	-- inst:AddComponent("boathealth")
	-- inst.components.boathealth:SetDepletedFn(boat_perish)
	-- inst.perishtime = TUNING.ROWBOAT_PERISHTIME
	-- inst.components.boathealth:SetHealth(inst.perishtime)

	inst.no_wet_prefix = true

 	return inst
end
local function bulingfn()
	local function onmounted(inst,data)
		local owner = GetPlayer()
		owner.components.inventory:Equip(SpawnPrefab("buling_plane_gun"))
		owner.components.inventory:Equip(SpawnPrefab("buling_boat_hat"))
	end
	local function dismounted(inst,data)
		print("不灵小姐下船了")
		local owner = GetPlayer()
		local handfur = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		local hatur = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		if handfur and handfur.prefab == "buling_plane_gun"  then
			handfur.components.equippable.un_unequipable = nil
			handfur:Remove()
		end
		if hatur and hatur.prefab == "buling_boat_hat"  then
			hatur.components.equippable.un_unequipable = nil
			hatur:Remove()
		end
	end
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
	trans:SetFourFaced()

	inst:AddTag("shadowboat")

	anim:SetBank("raft")
	anim:SetBuild("bulingboat_tiexue_build")
	anim:PlayAnimation("run_loop", true)

	setupcontainer(inst, {}, "boat_hud_raft", "boat_hud_raft", {}, "boat_inspect_raft", "boat_inspect_raft", {x=0,y=5}, {x=40, y=-45})

	inst:AddComponent("drivable")
	inst.components.drivable.sanitydrain = TUNING.ROWBOAT_SANITY_DRAIN
	inst.components.drivable.runspeed = 10
	inst.components.drivable.runanimation = "sail_loop"
	inst.components.drivable.prerunanimation = "sail_pre"
	inst.components.drivable.postrunanimation = "sail_pst"
	inst.components.drivable.overridebuild = "bulingboat_tiexue_build"
	inst.components.drivable.flotsambuild = "flotsam_rowboat_build"
	inst.components.drivable.hitfx = "boat_hit_fx_rowboat"
	
	inst:AddComponent("boathealth")
	inst.components.boathealth:SetDepletedFn(boat_perish)
	inst.perishtime = 1000
	inst.components.boathealth:SetHealth(inst.perishtime)
	inst:ListenForEvent("mounted", onmounted)
	inst:ListenForEvent("dismounted", dismounted)
	inst.no_wet_prefix = true

 	return inst
end

return Prefab("buling_boat", fn, assets, prefabs),
Prefab("buling_boat_tiexue", bulingfn, assets, prefabs)