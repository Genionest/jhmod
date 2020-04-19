local assets ={
	Asset("ANIM", "anim/wx78_bulingbuling.zip"),
	Asset("ANIM", "anim/buling_fly.zip"),
	Asset("ANIM", "anim/hatbag.zip"),
	Asset("ANIM", "anim/redlycoris.zip"),
	Asset("ANIM", "anim/swap_lightsword_buling.zip"),
}
local function redlycoris()
    local function onequip(inst, owner)
		if not inst:HasTag("baojia") then
			owner.AnimState:OverrideSymbol("swap_hat", "redlycoris", "swap_hat")
			owner.AnimState:Show("HAT")
			owner.AnimState:Show("HAT_HAIR")
			owner.AnimState:Hide("HEAD")
			owner.AnimState:Hide("HAIRFRONT")
			local headfur = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if headfur == nil or (headfur and (headfur.prefab ~= "buling_redlycoris_weapon" or headfur.prefab ~= "buling_redlycoris_sword")) then
				owner.components.inventory:Equip(SpawnPrefab("buling_redlycoris_weapon"))
			end
			owner.components.inventory:Equip(SpawnPrefab("buling_redlycoris_armor"))
		end
	end
	local function onunequip(inst, owner)
		owner.AnimState:Show("HEAD")
		owner.AnimState:Show("HAIRFRONT")
		owner.AnimState:Hide("HEAD_HAIR")
		owner.AnimState:Hide("HAT")
		local handfur = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if handfur and (handfur.prefab == "buling_redlycoris_weapon" or handfur.prefab == "buling_redlycoris_sword") then
			handfur.components.equippable.un_unequipable = nil
			handfur:Remove()
		end
		local headfur = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if headfur and headfur.prefab == "buling_redlycoris_armor" then
			headfur.components.equippable.un_unequipable = nil
			headfur:Remove()
		end
	end
	
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("buling_tool")
    inst.AnimState:SetBuild("buling_tool")
	inst.AnimState:PlayAnimation("gaozi")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_diandonggao"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_diandonggao.xml"
    --inst:AddTag("sees_hiddendanger")
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(120)
	inst.components.finiteuses:SetUses(0)
	inst:DoPeriodicTask(1,function()
		local owner = inst.components.inventoryitem.owner
		if owner and owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) == inst and inst.components.finiteuses.current < 120 then
			inst.components.finiteuses:Use(-1)
		end
	end)
    inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
	inst.components.equippable.un_unequipable = true
    inst:AddComponent("inspectable")
	local function onusebush(inst)
		inst:AddTag("fire")
		GetPlayer().components.talker:Say(STRINGS.YUNSHI)
		inst.components.finiteuses:Use(60)
	end
	local function canusebush(inst)
		if inst.components.finiteuses.current >= 60 and not inst:HasTag("fire") and not inst:HasTag("baojia") then
			return true
		end
		return false
	end
	inst:AddComponent("useableitem")
	inst.components.useableitem:SetCanInteractFn(canusebush)
	inst.components.useableitem:SetOnUseFn(onusebush)
	local function onsave(inst, data)
		if inst:HasTag("baojia") then
			data.baojia = true
		end
	end
	local function onload(inst, data)
		if data and data.startkill then
			inst:AddTag("baojia")
		end
	end
	inst.OnSave = onsave
    inst.OnLoad = onload
	return inst
end
local function redlycoris_armor()
	local function onequip(inst, owner)
		owner.AnimState:SetBuild("wx78_bulingbuling")
		owner.AnimState:OverrideSymbol("hand", "buling_fly", "hand")
		owner.AnimState:OverrideSymbol("arm_upper", "buling_fly", "arm_upper")
		owner.AnimState:OverrideSymbol("headbase", "bulingbuling", "headbase")
		owner.AnimState:OverrideSymbol("headbase_hat", "bulingbuling", "headbase_hat")
		owner.AnimState:OverrideSymbol("torso", "buling_fly", "torso")
		owner.AnimState:OverrideSymbol("face", "bulingbuling", "face")
		owner.AnimState:OverrideSymbol("arm_upper_skin", "buling_fly", "arm_upper_skin")
		owner.AnimState:OverrideSymbol("hair", "bulingbuling", "hair")
	end
	local function onunequip(inst, owner)
		owner.AnimState:SetBuild("bulingbuling")
		owner.AnimState:OverrideSymbol("hand", "bulingbuling", "hand")
		owner.AnimState:OverrideSymbol("torso", "bulingbuling", "torso")
		owner.AnimState:OverrideSymbol("arm_upper", "bulingbuling", "arm_upper")
		owner.AnimState:OverrideSymbol("arm_upper_skin", "bulingbuling", "arm_upper_skin")
	end
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
	local function onfinished(inst)
		inst:Remove()
	end
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_diandonggao"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_diandonggao.xml"
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(120)
	inst.components.finiteuses:SetUses(120)
	inst.components.finiteuses:SetOnFinished( onfinished)
	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.un_unequipable = true
    inst:AddComponent("inspectable")
	local function onusebush(inst)
		local owner = inst.components.inventoryitem.owner
		local headfur = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		headfur:AddTag("baojia")
		owner.AnimState:OverrideSymbol("swap_hat", "hatbag", "swap_hat")
		owner.AnimState:OverrideSymbol("arm_upper", "wx78_bulingbuling", "arm_upper")
		owner.AnimState:OverrideSymbol("arm_upper_skin", "wx78_bulingbuling", "arm_upper_skin")
		owner.AnimState:OverrideSymbol("hand", "wx78_bulingbuling", "hand")
		local handfur = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if handfur and handfur.prefab == "buling_redlycoris_weapon" then
			handfur.components.equippable.un_unequipable = nil
			handfur:Remove()
			owner.components.inventory:Equip(SpawnPrefab("buling_redlycoris_sword"))
		end
	end
	inst:AddComponent("useableitem")
	inst.components.useableitem:SetOnUseFn(onusebush)
	inst:DoPeriodicTask(1,function()
		local owner = inst.components.inventoryitem.owner
		if owner and owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) == inst and inst.components.finiteuses.current > 0 and inst:HasTag("baojia") then
			inst.components.finiteuses:Use(1)
		end
	end)
	return inst
end
local function redlycoris_weapon()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
	local function onfinished(inst)
		if inst:HasTag("gatling") then
			inst:RemoveTag("gatling")
		end
	end
	local function canattack(inst, target)
		if inst:HasTag("gatling") and inst.components.finiteuses.current > 10 then
			inst.components.weapon:LaunchProjectile2(inst, target)
		end
		if inst.components.finiteuses.current > 0 then
			return true
		else
			return false
		end
		return false
	end
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_diandonggao"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_diandonggao.xml"
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(120)
	inst.components.finiteuses:SetUses(0)
	inst.components.finiteuses:SetOnFinished( onfinished)
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(20, 25)
	inst.components.weapon:SetCanAttack(canattack)
	inst.components.weapon:SetProjectile("buling_fire_projectile2")
	--inst.persists = false 
	inst:AddComponent("equippable")
	inst.components.equippable.un_unequipable = true
    inst:AddComponent("inspectable")
	inst:AddTag("blunderbuss")
	inst.components.weapon.LaunchProjectile2 = function (self,attacker, target)
		if self.projectile then
			local proj = SpawnPrefab("buling_fire_projectile")
			if proj then
				if self.onprojectilelaunch then
					self.onprojectilelaunch(self.inst, attacker, target, proj)
				end
				if proj.components.projectile then
					local owner = nil 
					if self.inst.components.inventoryitem then 
						owner = self.inst.components.inventoryitem.owner --Could be the player or a weapon that is equipped by another weapon (i.e. boat cannon)
						if owner and owner.components.inventoryitem and owner.components.inventoryitem.owner then 
								owner = owner.components.inventoryitem.owner
						end  
						if owner and owner.components.drivable and owner.components.drivable.driver then 
								owner = owner.components.drivable.driver
						end 
					end

					if self.projectilelaunchsymbol and owner and owner.AnimState then 
						proj.Transform:SetPosition(owner.AnimState:GetSymbolPosition(self.projectilelaunchsymbol, 0, 0, 0))
					else
						local x, y, z = attacker.Transform:GetWorldPosition()
						proj.Transform:SetPosition(x, y+(self.heightoffset or 0), z)
					end 
					proj.components.projectile:Throw(self.inst, target, attacker)
				end
				if proj.components.complexprojectile then 
					proj.Transform:SetPosition(attacker.Transform:GetWorldPosition())
					proj.components.complexprojectile:Launch(target:GetPosition(), attacker, self.inst)                
				end
			end
		end
	end
	local function createlight(inst, caster, target, pos)
		local firerain = SpawnPrefab("buling_firerain")
        firerain.Transform:SetPosition(TheInput:GetWorldPosition():Get())
        firerain:StartStep()
		local headfur = GetPlayer().components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		headfur.components.useableitem.inuse = false
		headfur:RemoveTag("fire")
	end
	local function cancreatelight(staff, caster, target, pos)
		local ground = GetWorld()
		local headfur = caster.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		if ground and pos and headfur and headfur:HasTag("fire") then
			local tile = ground.Map:GetTileAtPoint(pos.x, pos.y, pos.z)
			return  true
		end
		return false
	end
	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(createlight)
	inst.components.spellcaster:SetSpellTestFn(cancreatelight)
	inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.canusefrominventory = false
	inst.components.spellcaster.actiontype = "SCIENCE"
	inst.components.spellcaster.castingstate = "castspell_tornado"
	local function onusebush(inst)
		if inst:HasTag("gatling") then
			inst:RemoveTag("gatling")
		else
			inst:AddTag("gatling")
		end
		inst.components.equippable.walkspeedmult = 0.5
		inst:DoTaskInTime(1,function() inst.components.useableitem.inuse = false end)
	end
	inst:AddComponent("useableitem")
	inst.components.useableitem:SetOnUseFn(onusebush)
	inst:DoPeriodicTask(1,function()
		local owner = inst.components.inventoryitem.owner
		if owner and owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == inst and inst.components.finiteuses.current < 120 then
			inst.components.finiteuses:Use(-1)
		end
	end)
	return inst
end
local function fire()
	local function OnHit(inst, owner, target)
		inst:Remove()
	end
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.persists = false 
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    anim:SetBank("projectile")
    anim:SetBuild("staff_projectile")
    inst:AddTag("projectile")
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(50)
    inst.components.projectile:SetLaunchOffset(Vector3(2, .5, 0))
    inst.components.projectile:SetOnMissFn(OnHit)
    inst.AnimState:PlayAnimation("fire_spin_loop", true)
	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    inst.components.projectile:SetOnHitFn(function(inst, owner, v)
		owner.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/shotexplo")
		SpawnPrefab("collapse_small").Transform:SetPosition(v.Transform:GetWorldPosition())
		SpawnPrefab("explode_small").Transform:SetPosition(v.Transform:GetWorldPosition())
		owner.components.playercontroller:ShakeCamera(owner, "FULL", 0.2, 0.02, .5, 40)
		if v.components.combat and not v.components.health:IsDead()and v.components.health and not v:HasTag("player") and not v:HasTag("wall") then
			v.components.combat:GetAttacked(inst,10)
		end
		inst:Remove()
     end)
    return inst
end
local function ice()
	local function OnHit(inst, owner, target)
		inst:Remove()
	end
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.persists = false 
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    anim:SetBank("laser_explode_sm")
    anim:SetBuild("laser_explode_sm")
    inst:AddTag("projectile")
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(50)
    inst.components.projectile:SetLaunchOffset(Vector3(2, .5, 0))
    inst.components.projectile:SetOnMissFn(OnHit)
    inst.AnimState:PlayAnimation("anim", true)
	inst:DoTaskInTime(1,function() inst:Remove() end)
	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    inst.components.projectile:SetOnHitFn(function(inst, owner, v)
		owner.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/shotexplo")
		SpawnPrefab("collapse_small").Transform:SetPosition(v.Transform:GetWorldPosition())
		SpawnPrefab("laser_ring").Transform:SetPosition(v.Transform:GetWorldPosition())
		owner.components.playercontroller:ShakeCamera(owner, "FULL", 0.2, 0.02, .5, 40)
		if v.components.combat and not v.components.health:IsDead()and v.components.health and not v:HasTag("player") and not v:HasTag("wall") then
			v.components.combat:GetAttacked(inst,30)	
		end
		inst:Remove()
     end)
    return inst
end
local function redlycoris_sword()
	local function createlight(inst, target, pos)
		if target then target.components.combat:GetAttacked(inst,10) end
			if target then
				pos = Vector3(target.Transform:GetWorldPosition())
			end
			GetPlayer():ForceFacePoint(pos.x,pos.y,pos.z)
			local zidan = SpawnPrefab("buling_ying_fx")
			zidan.Transform:SetPosition(GetPlayer().Transform:GetWorldPosition())
			zidan:AddTag("noremove")
			zidan:ForceFacePoint(pos.x,pos.y,pos.z)
			zidan.Physics:SetMotorVelOverride(10,0,0)
			zidan:DoTaskInTime(0.5,function() zidan.Physics:ClearMotorVelOverride()
				GetPlayer().Transform:SetPosition(zidan.Transform:GetWorldPosition())
				zidan:Remove()
			end)
		--end
	end
	local function cancreatelight(staff, caster, target, pos)
		local ground = GetWorld()
		if target and target.components.combat and target.components.health and not target.components.health:IsDead() and not target:HasTag("player") and not target:HasTag("wall") then
			return true
		else
			if ground and pos then
				local tile = ground.Map:GetTileAtPoint(pos.x, pos.y, pos.z)
				return  tile ~= GROUND.IMPASSIBLE and tile < GROUND.UNDERGROUND
			end
		end
		return false
	end
	local function attack(inst, attacker, target)
		target.components.combat:GetAttacked(inst,50)
		local zidan = SpawnPrefab("buling_ying_fx")
		zidan.Transform:SetPosition(GetPlayer().Transform:GetWorldPosition())
		zidan.Physics:SetMotorVelOverride(30,0,3)
		zidan.Transform:SetPosition(GetPlayer().Transform:GetWorldPosition())
		zidan:AddTag("noremove")
		zidan:ForceFacePoint(target.Transform:GetWorldPosition())
		zidan:DoTaskInTime(0.2,function() 
			GetPlayer().Transform:SetPosition(zidan.Transform:GetWorldPosition())
			zidan:Remove()
		end)
	end
    local function onequip(inst, owner)
		owner.AnimState:OverrideSymbol("swap_object", "swap_lightsword_buling", "swap_lightsword_z")
		owner.AnimState:Show("ARM_carry")
		owner.AnimState:Hide("ARM_normal")
	end
	local function onunequip(inst, owner)
		owner.AnimState:Hide("ARM_carry")
		owner.AnimState:Show("ARM_normal")
	end
	local inst = CreateEntity()
	--inst.persists = false 
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_dianlifu"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_dianlifu.xml"
    
    inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
	inst.components.equippable.un_unequipable = true
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(0)
	inst.components.weapon:SetOnAttack(attack)
	inst.components.weapon:SetRange(6, 6)
	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(createlight)
	inst.components.spellcaster:SetSpellTestFn(cancreatelight)
	inst.components.spellcaster.canuseonpoint = true
	inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canusefrominventory = false
	inst.components.spellcaster.actiontype = "SCIENCE"
	inst.components.spellcaster.castingstate = "castspell_tornado"
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(100)
	inst.components.finiteuses:SetUses(100)
	inst:DoPeriodicTask(1,function()
		local owner = inst.components.inventoryitem.owner
		if owner and owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == inst and inst.components.finiteuses.current <100 then
			inst.components.finiteuses:Use(-1)
		end
	end)
	return inst
end
local function tornado_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
	inst.persists = false 
	anim:SetBank("deerclops_icespike")
	anim:SetBuild("deerclops_icespike")
	anim:PlayAnimation("spike1")
	MakeInventoryPhysics(inst)
	inst.Transform:SetScale(2, 2, 2)
	inst.Physics:CollidesWith(COLLISION.WORLD_01)
   -- RemovePhysicsColliders(inst)
	inst.AnimState:SetMultColour(0/255,0/255,0/255,.5)
	inst:DoPeriodicTask(.1, function()
		local target = FindEntity(inst, 1.5, function(v) return v.components.combat and v.components.health and not v.components.health:IsDead() and not v:HasTag("player") and not v:HasTag("wall")  end)
		if target and not inst:HasTag("noremove") then
			target.components.combat:GetAttacked(inst,10)
			target:AddTag("showd")
			inst:Remove()
			GetPlayer().Transform:SetPosition(inst.Transform:GetWorldPosition())
		end
		if not inst:HasTag("bing") then
			local ice = SpawnPrefab("buling_ying_fx")
			ice:AddTag("noremove")
			ice:AddTag("bing")
			ice.Transform:SetScale(1, 1, 1)
			ice.Transform:SetPosition(inst.Transform:GetWorldPosition())
			ice:DoTaskInTime(0.5,function() ice:Remove() end)
		end
	end)
	return inst
end

return Prefab( "buling_redlycoris", redlycoris, assets),
Prefab( "buling_ying_fx", tornado_fn, assets),
Prefab( "buling_fire_projectile", fire, assets),
Prefab( "buling_fire_projectile2", ice, assets),
Prefab( "buling_redlycoris_armor", redlycoris_armor, assets),
Prefab( "buling_redlycoris_sword", redlycoris_sword, assets),
Prefab( "buling_redlycoris_weapon", redlycoris_weapon, assets)