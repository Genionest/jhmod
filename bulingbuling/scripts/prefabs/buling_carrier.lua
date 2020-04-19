require "stategraphs/SGbuling_glomling"
require "stategraphs/SGbuling_car"
local assets=
{
	Asset("ANIM", "anim/buling_glomling.zip"),
	Asset("ANIM", "anim/buling_car.zip"),
}
local function upcar(doer,inst)
	doer:DoTaskInTime(0.1,function()
		doer.sg:GoToState("idle")
		--doer:SetStateGraph("SGwilsonboating")
		doer.components.driver.vehicle = inst
		doer.components.driver.driving = true
		local follower = doer.entity:AddFollower()
		follower:FollowSymbol(inst.GUID,"body", 0, 0, 0 )
		ChangeToObstaclePhysics(doer)
		doer.HUD.controls.status:Hide()
		doer.HUD.controls.crafttabs:Hide()
		doer:Hide()
		inst.locomotor = doer.components.locomotor
		inst.combat = doer.components.combat
		doer.components.locomotor = inst.components.locomotor
		doer.components.combat = inst.components.combat
	end)
end
local function drop(inst,viewer)
	viewer:Show()
	local pos = Vector3(inst.Transform:GetWorldPosition())
	viewer.components.locomotor = inst.locomotor
	viewer.components.combat = inst.combat
	viewer.entity:AddFollower():FollowSymbol(viewer.GUID,"body", 0, 0, 0)
	viewer.Transform:SetPosition(pos.x+1,0,pos.z)
	inst.work = nil
	ChangeToCharacterPhysics(viewer)
	viewer.Physics:SetMass(75)
	viewer.HUD.controls.crafttabs:Show()
	--viewer.HUD.controls.inv:Show()
	viewer.HUD.controls.status:Show()
	viewer.components.driver.driving = false
	viewer.components.driver.vehicle = nil
	local x,y,z = GetPlayer().Transform:GetWorldPosition()
	GetPlayer().Transform:SetPosition(x,2,z)
end
local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local sound = inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddPhysics()
    inst.entity:AddAnimState():SetBloomEffectHandle( "shaders/anim.ksh" )
    inst.Transform:SetSixFaced(inst)
    --MakeGhostPhysics(inst, 1, .5)
	MakeAmphibiousGhostPhysics(inst, 10, .5)
    inst.DynamicShadow:SetSize( .8, .5 )
    inst.entity:AddAnimState():SetBank("buling_glomling")
    inst.entity:AddAnimState():SetBuild("buling_glomling")
    inst.entity:AddAnimState():PlayAnimation("idle_loop", true)
    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 0.6 )
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed =  4
    inst:AddComponent("inspectable")
    inst.Transform:SetScale(3, 3, 3)
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(100)
    inst:AddComponent("knownlocations")
    inst:AddComponent("combat")
	inst:SetStateGraph("SGbuling_glomling")
	inst.bulingdrop = drop
	inst:AddTag("buling_carrier")
    ------------------    
    inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl_LP", "howl")
	inst:AddComponent("inspectable")
	inst:ListenForEvent("death", function() 
		inst.bulingdrop (inst,GetPlayer())
	end)
	inst:AddComponent("drivable")
	inst.components.drivable.sanitydrain = TUNING.ROWBOAT_SANITY_DRAIN
	inst.components.drivable.runspeed = 10
	inst.components.drivable.OnMounted = function(self,doer)
		upcar(doer,inst)
	end
    return inst
end
local function carfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local sound = inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddPhysics()
    inst.entity:AddAnimState():SetBloomEffectHandle( "shaders/anim.ksh" )
    inst.Transform:SetFourFaced(inst)
    MakeCharacterPhysics(inst, 1, .5)
    inst.DynamicShadow:SetSize( .8, .5 )
    inst.entity:AddAnimState():SetBank("buling_car")
    inst.entity:AddAnimState():SetBuild("buling_car")
    inst.entity:AddAnimState():PlayAnimation("idle", true)
    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 0.6 )
    inst.components.locomotor.walkspeed = 8
    inst.components.locomotor.runspeed =  8
    inst:AddComponent("inspectable")
	--inst.Transform:SetScale(3, 3, 3)
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(100)
    inst:AddComponent("knownlocations")
    inst:AddComponent("combat")
	inst:SetStateGraph("SGbuling_car")
	inst.bulingdrop = drop
	inst:AddTag("buling_carrier")
    ------------------    
    inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl_LP", "howl")
	inst:AddComponent("inspectable")
	inst:ListenForEvent("death", function() 
		inst.bulingdrop (inst,GetPlayer())
	end)
	inst:AddComponent("drivable")
	inst.components.drivable.sanitydrain = TUNING.ROWBOAT_SANITY_DRAIN
	inst.components.drivable.runspeed = 10
	inst.components.drivable.OnMounted = function(self,doer)
		upcar(doer,inst)
	end
    return inst
end
local function gdfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.Transform:SetFourFaced(inst)
	MakeCharacterPhysics(inst, 1, .5)
	anim:SetBank("rocky")
	inst.DynamicShadow:SetSize(3, 3 )
	anim:SetBuild("buling_rocky")
	anim:PlayAnimation("idle_loop", true)
	inst:AddComponent("lootdropper")
	inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 0.6 )
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor.runspeed =  3
    inst:AddComponent("combat")
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat:SetRange(4)
    inst.components.combat:SetDefaultDamage(100)
	inst.Transform:SetScale(3, 3, 3)
	inst.bulingdrop = drop
	inst:AddTag("buling_carrier")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1000)
	inst:AddComponent("inventory")
    inst.components.inventory.dropondeath = false
	inst:SetStateGraph("SGbuling_rocky")
	inst:ListenForEvent("death", function() 
		inst.bulingdrop (inst,GetPlayer())
	end)
	inst:AddComponent("inspectable")
	inst:AddComponent("drivable")
	inst.components.drivable.sanitydrain = TUNING.ROWBOAT_SANITY_DRAIN
	inst.components.drivable.runspeed = 10
	inst.components.drivable.OnMounted = function(self,doer)
		upcar(doer,inst)
	end
	return inst
end
return Prefab("buling_glomling",fn , assets),
Prefab("buling_rocky",gdfn,assets),
Prefab("buling_car",carfn , assets)