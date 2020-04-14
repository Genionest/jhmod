local onequip = function(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_staffs", "yellowstaff")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local onunequip = function(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function fn()
	local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    anim:SetBank("staffs")
    anim:SetBuild("staffs")
    anim:PlayAnimation("yellowstaff")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "yellowstaff"
	inst.components.inventoryitem.atlasname = "images/inventoryimages_2.xml"
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(1)
    inst.components.weapon:SetRange(8, 10)
    -- inst.components.weapon:SetOnAttack(onattack_sign)
    inst.components.weapon:SetProjectile("sign_staff_projectile")

    return inst
end

local function OnHit(inst, owner, target)
	SpawnPrefab("sign_fx").Transform:SetPosition(inst:GetPosition():Get())
    inst:Remove()
end

local function CreateSign(inst)
	SpawnPrefab("sign_fx").Transform:SetPosition(inst:GetPosition():Get())
end

local function projectile_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    anim:SetBank("sign_home")
    anim:SetBuild("sign_home")
    -- anim:PlayAnimation("place")
    anim:PlayAnimation("")

    inst:AddTag("projectile")
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(20)
    inst.components.projectile:SetLaunchOffset(Vector3(2, .5, 0))
    inst.components.projectile:SetOnMissFn(OnHit)
    inst.components.projectile:SetOnHitFn(OnHit)

    inst:DoPeriodicTask(.1, function()
    	CreateSign(inst)
    end, 0)

    return inst
end

local function DoDamage(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	inst.components.combat.ignorehitrange = true
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, 3, nil, {"DECOR", "INLIMBO", "player"})) do
		if v:IsValid() and not v:IsInLimbo() 
		and not (v.components.health ~= nil 
		and v.components.health:IsDead()) then
			local vradius = 0
            if v.Physics then
                vradius = v.Physics:GetRadius()
            end
            local range = 2 + vradius
            if v:GetDistanceSqToPoint(Vector3(x, y, z)) < range * range then
				if v.components.health then
					inst.components.combat:DoAttack(v)                
                    if v:IsValid() and (v.components.health 
                    and not v.components.health:IsDead()) then
                        if v.components.freezable and v.components.freezable:IsFrozen() then
                            v.components.freezable:Unfreeze()
                        end
       --                  if v.event_listeners["attacked"]
       --                  and v.event_listeners["attacked"][inst] then
       --                  	local event_fn = v.event_listeners["attacked"][inst][1]
							-- if event_fn then                        	
       --                  		event_fn(v, {attacker=GetPlayer()})
       --                  	end
       --                  end
                        if v.components.combat then
                        	v.components.combat:SetTarget(GetPlayer())
                        end
                    end
				end
			end
		end
	end
end

local function fxfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	anim:SetBank("sign_home")
    anim:SetBuild("sign_home")
    anim:PlayAnimation("place")

    inst.persists = false
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(20)
    inst.components.combat:SetKeepTargetFunction(function()
    	return false
    end)
    inst:DoTaskInTime(0, function()
    	DoDamage(inst)
    end)
    inst:ListenForEvent("animover", function()
    	inst:Remove()
    end)

    return inst
end

return Prefab("common/inventory/sign_staff", fn, {}),
	Prefab("common/sign_staff_projectile", projectile_fn, {}),
	Prefab("common/sign_fx", fxfn, {})