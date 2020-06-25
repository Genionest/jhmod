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

GLOBAL.WARGON_FX_EX = {
	impact_fx = impact_fx,
	sparks_fx = sparks_fx,
	shadow_fx = shadow_fx,
}

GLOBAL.WARGON.FX = GLOBAL.WARGON_FX_EX