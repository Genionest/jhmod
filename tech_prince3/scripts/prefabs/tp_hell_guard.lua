-- require "stategraphs/SGbigfoot"

local assets = 
{
	-- Asset("ANIM", "anim/foot_build.zip"),
	-- Asset("ANIM", "anim/foot_basic.zip"),
	-- Asset("ANIM", "anim/foot_print.zip"),
	-- Asset("ANIM", "anim/foot_shadow.zip"),
}

local prefabs = 
{
    -- "groundpound_fx",
    -- "groundpoundring_fx",
}

local ShadowWarnTime = 2

local function DoStep(inst)
	local player = GetPlayer()
	local distToPlayer = inst:GetPosition():Dist(player:GetPosition())
	local power = Lerp(3, 1, distToPlayer/180)
	player.components.playercontroller:ShakeCamera(player, "VERTICAL", 0.5, 0.03, power, 40) 
	inst.components.groundpounder:GroundPound()
	inst:SpawnPrint()
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/foot_ground")
	-- GetWorld():PushEvent("bigfootstep")
end

local function roundToNearest(numToRound, multiple)
	local half = multiple/2
	return numToRound+half - (numToRound+half) % multiple
end

local function GetRotation(inst)
	local rotationTranslation = 
	{
		["0"] = 180, -- "right"
		["1"] = 135, -- "up"
		["2"] = 0, -- "left"
		["3"] = -135, --"down"
	}
	local cameraVec = TheCamera:GetDownVec()
	local cameraAngle =  math.atan2(cameraVec.z, cameraVec.x)
	cameraAngle = cameraAngle * (180/math.pi)
	cameraAngle = roundToNearest(cameraAngle, 45)
	local rot = inst.AnimState:GetCurrentFacing()
	return rotationTranslation[tostring(rot)] - cameraAngle
end

local function SpawnPrint(inst)
	local footprint = SpawnPrefab("bigfootprint")
	footprint.Transform:SetPosition(inst:GetPosition():Get())
	footprint.Transform:SetRotation(GetRotation(inst))
end

local function SimulateStep(inst)
	inst:DoTaskInTime(ShadowWarnTime, function(inst) 
		inst:DoStep()
		inst:Remove()
	end)
end

local function StartStep(inst)
	local shadow = SpawnPrefab("bigfootshadow")
	shadow.Transform:SetPosition(inst:GetPosition():Get())
	shadow.Transform:SetRotation(GetRotation(inst))
	inst:Hide()
	inst:DoTaskInTime(ShadowWarnTime - (5*FRAMES), function(inst) inst.sg:GoToState("stomp") end)
end

local function foot_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	trans:SetFourFaced()

	anim:SetBank("tp_hell_guard")
	anim:SetBuild("tp_hell_guard")

	inst:SetStateGraph("SGbigfoot")

	inst:AddComponent("groundpounder")
	inst.components.groundpounder.destroyer = true
	local cmp = inst.components.groundpounder
	function cmp:DestroyPoints(points, breakobjects, dodamage)
		local getEnts = breakobjects or dodamage
		for k,v in pairs(points) do
			local ents = nil
			if getEnts then
				ents = TheSim:FindEntities(v.x, v.y, v.z, 3, {"shadowcreature"}, self.noTags)
			end
			if ents and breakobjects then
				-- first check to see if there's crops here, we want to work their farm
				for k2,v2 in pairs(ents) do
					if v2 and self.burner and v2.components.burnable and not v2:HasTag("fire") and not v2:HasTag("burnt") then
						v2.components.burnable:Ignite()
					end
					-- Don't net any insects when we do work
					if v2 and self.destroyer and v2.components.workable and v2.components.workable.workleft > 0 and v2.components.workable.action ~= ACTIONS.NET then
						v2.components.workable:Destroy(self.inst)
				end
					if v2 and self.destroyer and v2.components.crop then
						print("Has Crop:",v2)
						v2.components.crop:ForceHarvest()
					end
				end
			end
			if ents and dodamage then
				for k2,v2 in pairs(ents) do
					if not self.ignoreEnts then 
						self.ignoreEnts = {}
					end 
					if not self.ignoreEnts[v2.GUID] then --If this entity hasn't already been hurt by this groundpound
						-- if v2 and v2.components.health and not v2.components.health:IsDead() and 
						-- inst.owner.components.combat:CanTarget(v2) then
						--     EntUtil:get_attacked(v2, inst.owner, 0, nil, nil, true)
						--     -- self.inst.components.combat:DoAttack(v2, nil, nil, nil, self.groundpounddamagemult)
						-- end
						if v2 and v2.components.health then
							v2.components.health:Kill()
						end
						self.ignoreEnts[v2.GUID] = true --Keep track of which entities have been hit 
					end 
				end
			end
			local map = GetMap()
			if map then
				local ground = map:GetTileAtPoint(v.x, 0, v.z)
				if ground == GROUND.IMPASSABLE or map:IsWater(ground) then
					--Maybe do some water fx here?
				else
					if self.groundpoundfx then 
						SpawnPrefab(self.groundpoundfx).Transform:SetPosition(v.x, 0, v.z)
					end 
				end
			end
		end
	end

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(1000)
	inst:AddComponent("inspectable")

	inst.SpawnPrint = SpawnPrint
	inst.DoStep = DoStep
	inst.SimulateStep = SimulateStep -- For really far away steps.

	inst.StartStep = StartStep

	return inst
end

local function footprint_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	anim:SetBank("foot_print")
	anim:SetBuild("foot_print")
	anim:PlayAnimation("idle")
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
	trans:SetRotation( 0 )

	inst:AddTag("scarytoprey")

	inst:AddComponent("colourtweener")
	inst.components.colourtweener:StartTween({0,0,0,0}, 15, function(inst) inst:Remove() end)

	inst.persists = false

	return inst
end
local easing = require("easing")
local function LerpOut(inst)
	local timeToLeave = 1.33
	if not inst.sizeTask then
		inst.LeaveTime = inst:GetTimeAlive() + timeToLeave
		inst.sizeTask = inst:DoPeriodicTask(FRAMES, LerpOut)
		inst.components.colourtweener:StartTween({0,0,0,0}, timeToLeave, function() inst:Remove() end)
	end
	local t = timeToLeave - (inst.LeaveTime - inst:GetTimeAlive())
	local s = easing.outCirc(t, 1, inst.StartingScale - 1, timeToLeave)
	inst.Transform:SetScale(s,s,s)
end

local function LerpIn(inst)
	local s = easing.inExpo(inst:GetTimeAlive(), inst.StartingScale, 1 - inst.StartingScale, inst.TimeToImpact)
	inst.Transform:SetScale(s,s,s)
	if s <= 1 then
		inst.sizeTask:Cancel()
		inst.sizeTask = nil
	end
end

local function shadow_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetBank("foot_shadow")
	anim:SetBuild("foot_shadow")
	anim:PlayAnimation("idle")
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

	inst.persists = false
	
	local s = 2
	inst.StartingScale = s
	inst.Transform:SetScale(s,s,s)
	inst.TimeToImpact = ShadowWarnTime

	inst:AddComponent("colourtweener")
	inst.AnimState:SetMultColour(0,0,0,0)
	inst.components.colourtweener:StartTween({0,0,0,1}, inst.TimeToImpact, function() inst:DoTaskInTime(45*FRAMES, LerpOut) end)

	inst.sizeTask = inst:DoPeriodicTask(FRAMES, LerpIn)

	return inst
end

local Util = require "extension.lib.wg_util"
Util:AddString("tp_hell_guard", "冥界守卫", "冥界的守卫")

return Prefab("common/tp_hell_guard", foot_fn, assets, prefabs)
-- Prefab("common/bigfootprint", footprint_fn, assets, prefabs),
-- Prefab("common/bigfootshadow", shadow_fn, assets, prefabs)