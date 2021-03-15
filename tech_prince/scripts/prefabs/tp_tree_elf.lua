local INTENSITY = .5

local function fadein(inst)
    inst.components.fader:StopAll()
    inst.AnimState:PlayAnimation("swarm_pre")
    inst.AnimState:PushAnimation("swarm_loop", true)
    inst.Light:Enable(true)
	if inst:IsAsleep() then
		inst.Light:SetIntensity(.5)
	else
		inst.Light:SetIntensity(0)
		inst.components.fader:Fade(0, .5, 3+math.random()*2, 
        function(v) 
            inst.Light:SetIntensity(v) 
        end, function() 
            -- inst:RemoveTag("NOCLICK") 
        end)
	end
end

local function fadeout(inst)
    inst.components.fader:StopAll()
    inst.AnimState:PlayAnimation("swarm_pst")
	if inst:IsAsleep() then
		inst.Light:SetIntensity(0)
	else
		inst.components.fader:Fade(.5, 0, .75+math.random()*1, 
            function(v) 
                inst.Light:SetIntensity(v) 
            end, 
            function() 
                -- inst:AddTag("NOCLICK") 
                inst.Light:Enable(false) 
            end)
	end
end

local function updatelight(inst)
    if GetClock():IsNight()
    then
        if not inst.lighton then
            fadein(inst)
        else
            inst.Light:Enable(true)
            inst.Light:SetIntensity(.5)
        end
        inst.lighton = true
        -- inst:RemoveTag("NOCLICK")
    else
        if inst.lighton then
            fadeout(inst)
        else
            inst.Light:Enable(false)
            inst.Light:SetIntensity(0)
        end
        inst.lighton = false
        -- inst:AddTag("NOCLICK")
    end
end

local function fn(Sim)

	local inst = CreateEntity()

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    WARGON.no_save(inst)
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.entity:AddPhysics()
 
    local light = inst.entity:AddLight()
    light:SetFalloff(1)
    light:SetIntensity(.5)
    light:SetRadius(1)
    light:SetColour(180/255, 195/255, 220/255)
    light:Enable(false)
    
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    
    inst.AnimState:SetBank("fireflies")
    inst.AnimState:SetBuild("fireflies")
    inst.AnimState:SetMultColour(.1, 1, .1, 1)

    inst.AnimState:SetRayTestOnBB(true);
    
    inst:AddComponent("fader")

    inst:ListenForEvent( "daytime", function()
        inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
    end, GetWorld())
    inst:ListenForEvent( "nighttime", function()
        inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
    end, GetWorld())
    
    return inst
end

return Prefab( "tp_tree_elf", fn, {}) 