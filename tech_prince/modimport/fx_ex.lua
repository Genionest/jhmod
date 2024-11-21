local function impact_fx(inst, target)
	local impactfx = SpawnPrefab("impact")
	if impactfx then
	    local follower = impactfx.entity:AddFollower()
	    follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
        impactfx:FacePoint(inst:GetPosition():Get())
    end
end

local function sparks_fx(inst, target)
	local fx = SpawnPrefab("sparks_fx")
	if fx then
	    local follower = fx.entity:AddFollower()
	    follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
        fx:FacePoint(inst:GetPosition():Get())
    end
end

local function shadow_fx(inst)
	SpawnPrefab("statue_transition").Transform:SetPosition(inst:GetPosition():Get())
	SpawnPrefab("statue_transition_2").Transform:SetPosition(inst:GetPosition():Get())
end

local function fly_do_trail(inst)
    -- local owner = inst.components.inventoryitem:GetGrandOwner() or inst
    local owner = inst
    if not owner.entity:IsVisible() then
        return
    end

    local x, y, z = owner.Transform:GetWorldPosition()
    if owner.sg ~= nil and owner.sg:HasStateTag("moving") then
        local theta = -owner.Transform:GetRotation() * DEGREES
        local speed = owner.components.locomotor:GetRunSpeed() * .1
        x = x + speed * math.cos(theta)
        z = z + speed * math.sin(theta)
    end
	local map = GetWorld().Map
    local offset = FindValidPositionByFan(
        math.random() * 2 * PI,
         .5 + math.random() * .5,
        4,
        function(offset)
            local pt = Vector3(x + offset.x, 0, z + offset.z)
            return map:GetTileAtPoint(pt:Get())	
                and #TheSim:FindEntities(pt.x, 0, pt.z, .7, { "shadowtrail" }) <= 0 
        end
    )
    if offset ~= nil then
		SpawnPrefab("tp_shadow_fx").Transform:SetPosition(x + offset.x, 0, z + offset.z)
    end
end

local function shadow_foot_fx(inst)
	if inst._shadow_foot_fx == nil then
		inst._shadow_foot_fx = inst:DoPeriodicTask(6 * FRAMES, fly_do_trail, 2 * FRAMES)
	end
end

GLOBAL.WARGON_FX_EX = {
	impact_fx 		= impact_fx,
	sparks_fx 		= sparks_fx,
	shadow_fx 		= shadow_fx,
	shadow_foot_fx 	= shadow_foot_fx,
}

GLOBAL.WARGON.FX = GLOBAL.WARGON_FX_EX