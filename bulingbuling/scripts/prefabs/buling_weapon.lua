local assets ={
	Asset("ATLAS", "images/inventoryimages/buling_mine.xml"),
	Asset("ANIM", "anim/swap_buling_acher.zip"),
}
local function DoDamage(inst, rad)
    local pos = inst:GetPosition()
	local ents = TheSim:FindEntities(pos.x,2, pos.z, rad, nil, {"FX", "DECOR", "INLIMBO"})
	for k,v in pairs(ents) do
		if v.components.combat and v.components.health and not v.components.health:IsDead()and  not v:HasTag("player") and not v:HasTag("wall") and v~= inst then
			v.components.combat:GetAttacked(GetPlayer(), inst.components.combat.defaultdamage)
	    end
	end
end
local function SetLightValue(inst, val1, val2, time)
    inst.components.fader:StopAll()
    if val1 and val2 and time then
        inst.Light:Enable(true)
        inst.components.fader:Fade(val1, val2, time, function(v) inst.Light:SetIntensity(v) end)
    else    
        inst.Light:Enable(false)
    end
end
local function onnearmine(inst, ents)   
    local detonate = false
    for i,ent in ipairs(ents)do
        if not ent:HasTag("player") then
            detonate = true
            break
        end
    end
    if inst.primed and detonate then
        inst.SetLightValue(inst, 0,0.75,0.2 )
        inst.AnimState:PlayAnimation("red_loop", true)
        --start beep
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/hulk_metal_robot/active_LP","boom_loop")
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/hulk_metal_robot/electro")
        inst:DoTaskInTime(0.5,function() 
            --explode, end beep
        inst.SoundEmitter:KillSound("boom_loop")
            local player = GetClosestInstWithTag("player", inst, SHAKE_DIST)
            if player then
                player.components.playercontroller:ShakeCamera(inst, "VERTICAL", 0.5, 0.03, 2, SHAKE_DIST)
            end
            inst:Hide()
            local ring = SpawnPrefab("laser_ring")
            ring.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst:DoTaskInTime(0.3,function() DoDamage(inst, 3.5) inst:Remove() end)    
            
            local explosion = SpawnPrefab("laser_explosion")
            explosion.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/hulk_metal_robot/smash_3")                          
        end)
    end
end
local function OnHit(inst, dist)    
    inst.AnimState:PlayAnimation("land")
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/hulk_metal_robot/ribs/step_wires")
    inst.AnimState:PushAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/hulk_metal_robot/rust")    
    inst:ListenForEvent("animover", function() 
        if inst.AnimState:IsCurrentAnimation("open") then
            inst.primed  = true
            inst.AnimState:PlayAnimation("green_loop",true)
        end
    end)
end
local function minefn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst, 75, 0.5)

    --inst.Physics:SetCollisionCallback(OnMineCollide)

    anim:SetBank("metal_hulk_mine")
    anim:SetBuild("metal_hulk_bomb")
    anim:PlayAnimation("green_loop", true)

    inst:AddTag("ancient_hulk_mine")

    inst.primed = true
	inst.Transform:SetScale(.7,.7,.7)
    inst:AddComponent("locomotor")
    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnHit(OnHit)
    inst.components.complexprojectile.yOffset = 2.5

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(40)
    --inst.components.combat.playerdamagepercent = .5

    inst:AddComponent("fader")
    inst.glow = inst.entity:AddLight()    
    inst.glow:SetIntensity(.6)
    inst.glow:SetRadius(2)
    inst.glow:SetFalloff(1)
    inst.glow:SetColour(1, 0.3, 0.3)
    inst.glow:Enable(false)

    inst.SetLightValue = SetLightValue
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_mine"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_mine.xml"
    inst:AddComponent("creatureprox")   
    inst.components.creatureprox.period = 0.01
    inst.components.creatureprox:SetDist(2.5,4) 
    inst.components.creatureprox:SetOnPlayerNear(onnearmine)
    inst.components.creatureprox:OnEntityWake()
	
    return inst
end
local function gun_weapon()
	local function onequip(inst, owner)
		owner.AnimState:OverrideSymbol("swap_object", "swap_buling_acher", "swap_buling_acher")
		owner.AnimState:Show("ARM_carry")
		owner.AnimState:Hide("ARM_normal")
	end
	local function onunequip(inst, owner)
		owner.AnimState:Hide("ARM_carry")
		owner.AnimState:Show("ARM_normal")
	end
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_diandonggao"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_diandonggao.xml"
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(20, 25)
	inst.components.weapon:SetProjectile("buling_plane")
	inst.persists = false 
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
	inst.components.equippable.un_unequipable = true
    inst:AddComponent("inspectable")
	inst:AddTag("hand_gun")
	inst:AddTag("gun")
	return inst
end
local function boat_hat()
	local function onequip(inst, owner)
		owner.AnimState:OverrideSymbol("swap_hat", "hat_tiexue", "swap_hat")
        owner.AnimState:Show("HAT")
		owner.AnimState:Show("HAT_HAIR")
		owner.AnimState:Hide("HEAD")
		owner.AnimState:Hide("HAIRFRONT")
	end
	local function onunequip(inst, owner)
		owner.AnimState:Show("HEAD")
		owner.AnimState:Show("HAIRFRONT")
		owner.AnimState:Hide("HEAD_HAIR")
		owner.AnimState:Hide("HAT")
	end
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_diandonggao"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_diandonggao.xml"
	inst.persists = false 
	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
	inst.components.equippable.un_unequipable = true
    inst:AddComponent("inspectable")
	return inst
end
return Prefab( "buling_mine", minefn, assets),
Prefab( "buling_boat_hat", boat_hat, assets),
Prefab( "buling_plane_gun", gun_weapon, assets)