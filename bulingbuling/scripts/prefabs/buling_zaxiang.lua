local assets ={
	Asset("ANIM", "anim/buling_rocky.zip"),
	Asset("ANIM", "anim/hat_tiexue.zip"),
	Asset("ANIM", "anim/buling_plane.zip"),
}
local function commonfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inspectable")
    return inst
end
local function moonmonster()
	local function OnWentHome(inst)
		if inst.components.follower.leader ~= nil then
			if inst.components.follower.leader.components.inventory then
				inst.components.inventory:TransferInventory(inst.components.follower.leader)               
			end
		end
	end
	local function retargetfn(inst)
		if not inst.components.health:IsDead() then
			return FindEntity(inst, TUNING.FROG_TARGET_DIST, function(guy) 
				if guy.components.combat and guy.components.health and not guy.components.health:IsDead() and guy:HasTag("monster") and not guy:HasTag("wall") then
					return guy.components.health ~= nil
				end
			end)
		end
	end
	local function OnAttacked(inst, data)
		inst.components.combat:SetTarget(data.attacker)
		inst.components.combat:ShareTarget(data.attacker, 10, function(dude) return dude:HasTag("buling_player")--[[dude.prefabs == inst.prefabs]] and not dude.components.health:IsDead() end, 30)
	end
	local items ={
		AXE = "swap_axe",
		PICK = "swap_pickaxe",
		SWORD = "swap_nightmaresword",
		HAMMER = "swap_hammer",
		HACK = "swap_machete",
		SHOVEL = "swap_shovel"
	}
	local function EquipItem(inst, item)
		if item then
			inst.AnimState:OverrideSymbol("swap_object", item, item)
			inst.AnimState:Show("ARM_carry") 
			inst.AnimState:Hide("ARM_normal")
		end
	end
    local inst = CreateEntity()
	inst.items = items
	inst.entity:AddDynamicShadow()
	inst.equipfn = EquipItem
    EquipItem(inst)
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.5, .5 )
	local sound = inst.entity:AddSoundEmitter()
	MakeCharacterPhysics(inst, 10, .5)
	inst.DynamicShadow:SetSize(3, 1)
    inst:AddComponent("inspectable")
	inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wendy")
	inst:AddTag("buling_player")
	inst.AnimState:PlayAnimation("idle")
	inst.Transform:SetFourFaced(inst)
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(100)
	inst:AddComponent("locomotor")
	inst:AddComponent("eater")
    inst.components.locomotor.walkspeed = 6
	inst.force_onwenthome_message = true
	inst:AddComponent("inventory")
    inst.components.inventory.ignorescangoincontainer = true
    local brain = require "brains/buling_playerbrain"
	inst:SetBrain(brain)
	inst:AddComponent("combat")
    inst.components.combat.defaultdamage = 50
	inst:SetStateGraph("SGbuling_player")
	inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Show("ARM_normal")
	inst:ListenForEvent("attacked", OnAttacked)
	inst.components.combat:SetRetargetFunction(3, retargetfn)
	inst:AddComponent("knownlocations")
	inst:AddComponent("follower")
	inst:ListenForEvent("onwenthome", OnWentHome)
    return inst
end
local function jidi(inst)
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inspectable")
	inst.AnimState:SetBank("buling_zaxiang")
    inst.AnimState:SetBuild("buling_zaxiang")
	inst:AddTag("buling_yingdi")
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("jidi")
	inst:AddComponent("leader")
	inst:AddComponent("inventory")
	--[[inst.components.inspectable.getstatus = function(inst,viewer)
		inst.components.inventory:DropEverything(false, false)
	end]]
	inst.components.inventory.maxslots = 25
	return inst
end
local function planefn(Sim)
		local function OnThrown(inst, owner, target)
		if target ~= owner then
			owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
		end
		inst.AnimState:PlayAnimation("idle", true)
	end
	local function OnHit(inst, owner, target)
		if target then
			inst.bulingtarget = target
		end
		local impactfx = SpawnPrefab("explode_small")
		if impactfx then
			local follower = impactfx.entity:AddFollower()
			follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
			impactfx:FacePoint(inst.Transform:GetWorldPosition())
		end
		inst.Physics:SetMotorVel(8,0,0)
	end
	local function testforplant(inst)
		local x,y,z = inst.Transform:GetWorldPosition()
		local ent = TheSim:FindFirstEntityWithTag("player")
		if ent and ent:GetDistanceSqToInst(inst) < 1 and inst:HasTag("nofire") then
			inst:Remove()
		end
		local target = FindEntity(inst, 1, function(item) 
			return inst.bulingtarget and item == inst.bulingtarget 
		end)
		if target and not inst:HasTag("bulingcd") and target.components.combat and target.components.health and not target.components.health:IsDead() then
			inst.bulingtarget.components.combat:GetAttacked(inst,45)
			inst:AddTag("bulingcd")
			local impactfx = SpawnPrefab("explode_small")
			if impactfx then
				local follower = impactfx.entity:AddFollower()
				follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
				impactfx:FacePoint(inst.Transform:GetWorldPosition())
			end 
			inst.task = inst:DoTaskInTime(.5,function() 
				inst:RemoveTag("bulingcd")
			end)
		end
	end
	local inst = CreateEntity()
	local trans = inst .entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    inst.Transform:SetFourFaced()
    anim:SetBank("buling_plane")
    anim:SetBuild("buling_plane")
    anim:PlayAnimation("idle")
    anim:SetRayTestOnBB(true);
    inst:AddTag("projectile")
    inst:AddTag("thrown")
	inst.Physics:SetMotorVel(8,0,0)
    inst:AddComponent("inspectable")
	inst:AddComponent("locomotor")
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(10)
    --inst.components.projectile:SetCanCatch(true)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)
    --inst.components.projectile:SetOnCaughtFn(OnCaught)
    inst.components.projectile:SetLaunchOffset(Vector3(0, 0.2, 0))
	
	inst:DoPeriodicTask(2,function() 
		inst.Physics:SetMotorVel(8,0,0)
		if inst.bulingtarget and inst.bulingtarget ~= GetPlayer() and inst.bulingtarget:IsValid() then
			local pos = inst.bulingtarget:GetPosition()
			inst:ForceFacePoint(pos.x+math.random(-8,8),pos.y,pos.z+math.random(-8,8))
		else
			inst:AddTag("nofire")
			inst.bulingtarget = GetPlayer()
		end
	end)
	inst:DoPeriodicTask(1,function() 
		inst.Physics:SetMotorVel(8,0,0)
		if inst.bulingtarget and inst.bulingtarget:IsValid()  then 
			local pos = inst.bulingtarget:GetPosition()
			inst:ForceFacePoint(pos.x,pos.y,pos.z)
		end
	end)
	inst:DoTaskInTime(5,function()
		inst:AddTag("nofire")
		inst.bulingtarget = GetPlayer()
	end)
	inst:DoPeriodicTask(0.1,function() testforplant(inst) end)
    return inst
end
return Prefab("buling_jidi", jidi, assets),
Prefab( "buling_plane", planefn, assets),
Prefab("buling_player",moonmonster,assets)