local Util = require "extension.lib.wg_util"
local AssetUtil = require "extension/lib/asset_util"
local PrefabUtil = require "extension/lib/prefab_util"
local EntUtil = require "extension/lib/ent_util"
local PrefabUtil = require "extension.lib.prefab_util"
local BuffManager = require "extension.store.buffs"
local AssetMaster = Sample.AssetMaster
local FxManager = Sample.FxManager


local prefs = {}

--[[
创建抛射物  
(Prefab) projectile返回这个预制物  
name (string)名字  
bank (string)动画资源1  
build (string)动画资源2  
animation (string)动画资源3  
fn (func)定制函数  
assets (talbe{Asset})资源列表  
]]
local function MakeProjectile(name, bank, build, animation, fn, assets)
    return Prefab(name, function()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        MakeInventoryPhysics(inst)
		inst.AnimState:SetBank(bank)
		inst.AnimState:SetBuild(build)
		inst.AnimState:PlayAnimation(animation)

        inst:AddTag("projectile")
        inst.persists = false

        if fn then
            fn(inst)
        end

        return inst
    end, assets)
end

local function snow_ball_hit(inst)
	local dist = 4
	local x,y,z = inst:GetPosition():Get()
	local ents = TheSim:FindEntities(x,y,z, dist, nil, 
		{"FX", "DECOR", "INLIMBO"})
	for k,v in pairs(ents) do
		if v then
			print("testing",v.prefab)
			if v.components.burnable then
				print("testing 2",v.prefab)
				if v.components.burnable:IsBurning() then
					print("testing 3",v.prefab)
					v.components.burnable:Extinguish(true, TUNING.FIRESUPPRESSOR_EXTINGUISH_HEAT_PERCENT)
				elseif v.components.burnable:IsSmoldering() then
					print("testing 4",v.prefab)
					v.components.burnable:Extinguish(true)
				end
			end
			if v ~= inst.owner then
				if v.components.freezable then
					print("testing 5",v.prefab)
					v.components.freezable:AddColdness(2) 
				elseif v.components.health 
				and not v.components.health:IsDead() then
					v.components.health:DoDelta(-20)
				end
				if v.components.temperature then
					print("testing 6",v.prefab)
					local temp = v.components.temperature:GetCurrent()
	        		v.components.temperature:SetTemperature(temp - TUNING.FIRE_SUPPRESSOR_TEMP_REDUCTION)
				end
			else
				if v.components.health and not v.components.health:IsDead() then
					v.components.health:DoDelta(10)
				end
			end
		end
	end
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_impact")
	FxManager:MakeFx("splash_snow_fx", inst)
	-- SpawnPrefab("splash_snow_fx").Transform:SetPosition(inst:GetPosition():Get())
	inst:Remove()
end

local snow_ball = MakeProjectile("tp_snow_ball", 
"firefighter_projectile", "firefighter_projectile", "spin_loop",
function(inst)
    inst.entity:AddSoundEmitter()
    RemovePhysicsColliders(inst)
    inst.Physics:SetMass(1)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetFriction(10)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(GetWorldCollision())
    inst.Physics:CollidesWith(COLLISION.INTWALL)
    
    inst:AddComponent("locomotor")
    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnHit(snow_ball_hit)
    inst.components.complexprojectile.yOffset = 2.5
end)
table.insert(prefs, snow_ball)

local tornado = MakeProjectile("tp_tornado_proj", 
"tornado", "tornado", "tornado_pre", function(inst)
	inst.entity:AddSoundEmitter()
	inst.AnimState:PushAnimation("tornado_loop")
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tornado", "spinLoop")

	inst:AddComponent("weapon")
	inst.components.weapon.dmg_type = "wind"
	inst:AddComponent("wg_projectile")
	inst.components.wg_projectile:SetSpeed(TUNING.TORNADO_WALK_SPEED)
	inst.components.wg_projectile:SetOnThrownFn(function(inst, owner, target) end)
	inst.components.wg_projectile:SetOnMissFn(function(inst, owner, target) 
		inst:Remove()
	end)
	inst.components.wg_projectile:SetOnHitFn(function(inst, owner, target)
		inst.components.wg_projectile.onmiss(inst, owner, target)
		BuffManager:AddBuff(owner, "wind")
	end)
	inst.components.wg_projectile:SetHoming(true)
	inst.components.wg_projectile:SetLaunchOffset(Vector3(0, 0.2, 0))
	-- inst.components.wg_projectile.test = function(inst, target, doer)
	-- 	return true
	-- end
	-- inst.components.wg_projectile:SetOnCaughtFn(function(inst, catcher)
	-- end)

end)
table.insert(prefs, tornado)

local coconut_shot = deepcopy(require "prefabs/cannonshot")
PrefabUtil:SetPrefabName(coconut_shot, "tp_coconut_shot")
PrefabUtil:HookPrefabFn(coconut_shot, function(inst)
	local OnBurnt = inst.components.explosive.OnBurnt
	inst.components.explosive.buildingdamage = 0
	inst.components.explosive.OnBurnt = function(self)
		local pos = Vector3(self.inst.Transform:GetWorldPosition())
    
		GetClock():DoLightningLighting()
		
		GetPlayer().components.playercontroller:ShakeCamera(self.inst, "FULL", 0.7, 0.02, .5, 40)

		if self.onexplodefn then
			self.onexplodefn(self.inst)
		end

		local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, self.explosiverange, nil, {"falling", "FX", "NOCLICK", "DECOR", "INLIMBO", "player"})
		
		self.stacksize = 1

		if self.inst.components.stackable then
			self.stacksize =  self.inst.components.stackable.stacksize
		end

		for k,v in pairs(ents) do
			local inpocket = v.components.inventoryitem and v.components.inventoryitem:IsHeld()

			if not inpocket and not (self.noremove and v == self.inst) then

				if v.components.combat and v ~= self.inst then
					v.components.combat:GetAttacked(self.inst, self.explosivedamage * self.stacksize or 1, nil)
				elseif v.components.workable and v.components.workable.workleft > 0 and v.components.workable.workable and not v:HasTag("busy") then --Haaaaaaack!            
					v.components.workable:WorkedBy(self.inst, self.buildingdamage)
				end

				if v:IsValid() and v.components.burnable and not v.components.fueled and self.lightonexplode then
					v.components.burnable:Ignite()
				end

				v:PushEvent("explosion", {explosive = self.inst})
			end
		end

		local world = GetWorld()    --bleh, better way to do this?    
		for i=1,self.stacksize,1 do
			if world then
				world:PushEvent("explosion", {damage = self.explosivedamage})
			end
		end

		--self.inst:PushEvent("explosion")

		if not self.noremove then
			if self.inst.components.health then self.inst:PushEvent("death") end

			self.inst:Remove()
		end
	end
end)
table.insert(prefs, coconut_shot)
Util:AddString(coconut_shot.name, "炸弹", "多看一眼就会爆炸")

local electric_proj = Prefab("tp_electric_proj", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("bishop_attack")
    inst.AnimState:SetBuild("bishop_attack")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("projectile")
    inst.persists = false
    RemovePhysicsColliders(inst)
	inst.entity:AddSoundEmitter()
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(20)
	inst:AddComponent("wg_projectile")
	inst.enemies = {}
	inst.max_enemy = 0
	inst.find_target = function(inst, owner)
		if #inst.enemies >= inst.max_enemy then
			return
		end
		local owner = inst.owner
		local new_target = FindEntity(inst, 5, function(guy, inst)
			if owner and EntUtil:check_combat_target(owner, guy) then
				for k, v in pairs(inst.enemies) do
					if v == guy then
						return false
					end
				end
				return true
			end
		end, {"electric"}, EntUtil.not_enemy_tags)
		return new_target
	end
	inst.components.wg_projectile:SetSpeed(20)
	inst.components.wg_projectile:SetOnMissFn(function(inst, owner, target) 
		inst:Remove()
	end)
	inst.components.wg_projectile:SetOnHitFn(function(inst, owner, target)
		inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")
		BuffManager:AddBuff(target, "electric")
		table.insert(inst.enemies, target)
		local new_target = inst:find_target()
		if new_target then
			inst.components.wg_projectile:Throw(owner, new_target, owner)
		else
			inst.components.wg_projectile.onmiss(inst, owner, target)
		end
	end)
	inst.components.wg_projectile:SetLaunchOffset(Vector3(0, 0.2, 0))

    return inst
end, {})
table.insert(prefs, electric_proj)

local galeforce_proj = Prefab("tp_galeforce_proj", function()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.Transform:SetFourFaced()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    anim:SetBank("the_fx22")
    anim:SetBuild("the_fx22")
    anim:PlayAnimation("idle", true)
    
    inst:AddTag("projectile")
    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(2)
    inst.components.projectile:SetOnHitFn(function(inst, owner, target)
		inst:Remove()
		inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")
	end)
    inst.components.projectile:SetOnMissFn(function(inst, owner, target)
		inst:Remove()
		inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")
	end)
	
	return inst
end, {})
table.insert(prefs, galeforce_proj)

return unpack(prefs)