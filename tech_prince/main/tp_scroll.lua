local function on_use(inst)
    local item = inst.components.stackable:Get()
    item:Remove()
end

local function tentaclesfn(inst, reader)
    local pt = Vector3(reader.Transform:GetWorldPosition())

    local numtentacles = 3

    reader.components.sanity:DoDelta(-TUNING.SANITY_HUGE)

    reader:StartThread(function()
        for k = 1, numtentacles do
        
            local theta = math.random() * 2 * PI
            local radius = math.random(3, 8)

            -- we have to special case this one because birds can't land on creep
            local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
                local x,y,z = (pt + offset):Get()

                local invalidTypes = {-1, 1, 0, 52, 55, 56, 57, 58, 59, 60, 61, 62, 63}
                local tile = GetVisualTileType(x, y, z)
                
                for k,v in pairs(invalidTypes) do
                    if v == tile then
                        return false
                    end
                end
                
                local ents = TheSim:FindEntities(x,y,z , 1)
                return not next(ents) 
            end)

            if result_offset then
                local tentacle = SpawnPrefab("tentacle")
                
                tentacle.Transform:SetPosition((pt + result_offset):Get())
                GetPlayer().components.playercontroller:ShakeCamera(reader, "FULL", 0.2, 0.02, .25, 40)
                
                --need a better effect
                local fx = SpawnPrefab("splash_ocean")
                local pos = pt + result_offset
                fx.Transform:SetPosition(pos.x, pos.y, pos.z)
                --PlayFX((pt + result_offset), "splash", "splash_ocean", "idle")
                tentacle.sg:GoToState("attack_pre")
            end

            Sleep(.33)
        end
    end)
    on_use(inst)
    return true    

end


local function birdsfn(inst, reader)
    if not GetWorld().components.birdspawner then
        return false
    end

    reader.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
    local num = 20 + math.random(10)
    
    --we can actually run out of command buffer memory if we allow for infinite birds
    local x, y, z = reader.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 10, nil, nil, {'magicalbird'})
    if #ents > 30 then
        num = 0
        reader.components.talker:Say(GetString(reader.prefab, "ANNOUNCE_WAYTOOMANYBIRDS"))
    elseif #ents > 20 then
        reader.components.talker:Say(GetString(reader.prefab, "ANNOUNCE_TOOMANYBIRDS"))
        num = 10 + math.random(10)
    end
    
    if num > 0 then
        reader:StartThread(function()
            for k = 1, num do

                if reader.components.driver and reader.components.driver:GetIsDriving() then 
                    local pt = GetWorld().components.birdspawner:GetAquaticSpawnPoint(Vector3(reader.Transform:GetWorldPosition() ))
                    if pt then
                        local bird = GetWorld().components.birdspawner:SpawnAquaticBird(pt, true)
                        bird:AddTag("magicalbird")
                    end
                else 
                    local pt = GetWorld().components.birdspawner:GetSpawnPoint(Vector3(reader.Transform:GetWorldPosition() ))
                    
                    if pt then
                        local bird = GetWorld().components.birdspawner:SpawnBird(pt, true)
                        if bird then
                           bird:AddTag("magicalbird")
                        end
                    end
                end 
                Sleep(math.random(.2, .25))
            end
        end)
    end
    on_use(inst)
    return true
end

local function firefn(inst, reader)

    local num_lightnings =  16
    reader.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
    reader:StartThread(function()
        for k = 0, num_lightnings do

            local rad = math.random(3, 15)
            local angle = k*((4*PI)/num_lightnings)
            local pos = Vector3(reader.Transform:GetWorldPosition()) + Vector3(rad*math.cos(angle), 0, rad*math.sin(angle))
            GetSeasonManager():DoLightningStrike(pos)
            Sleep(math.random( .3, .5))
        end
    end)
    on_use(inst)
    return true
end

local function sleepfn(inst, reader)
    reader.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
    local range = 30
    local pos = Vector3(reader.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, range)
    for k,v in pairs(ents) do
        if v.components.sleeper and v ~= reader then
            v.components.sleeper:AddSleepiness(10, 20)
        end
    end
    on_use(inst)
    return true
end

local function growfn(inst, reader)
    reader.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
    local range = 30
    local pos = Vector3(reader.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, range)
    for k,v in pairs(ents) do
        if v.components.pickable then
            v.components.pickable:FinishGrowing()
        end

        if v.components.hackable then
            v.components.hackable:FinishGrowing()
        end

        if v.components.crop then
            v.components.crop:DoGrow(TUNING.TOTAL_DAY_TIME*3)
        end
        
        if v:HasTag("tree") and v.components.growable and not v:HasTag("stump") then
            v.components.growable:DoGrowth()
        end
    end
    on_use(inst)
    return true
end


local function volcanofn(inst, reader)
    local delay = 0.0
    for i = 1, TUNING.VOLCANOBOOK_FIRERAIN_COUNT, 1 do
        local pos = Vector3(reader.Transform:GetWorldPosition())
        local x, y, z = TUNING.VOLCANOBOOK_FIRERAIN_RADIUS * UnitRand() + pos.x, pos.y, TUNING.VOLCANOBOOK_FIRERAIN_RADIUS * UnitRand() + pos.z
        reader:DoTaskInTime(delay, function(inst)
            local firerain = SpawnPrefab("firerain")
            firerain.Transform:SetPosition(x, y, z)
            firerain:StartStep()
        end)
        delay = delay + TUNING.VOLCANOBOOK_FIRERAIN_DELAY
    end
    on_use(inst)
    return true 
end

GLOBAL.WARGON_SCROLL_FN = {
    tentacle    = tentaclesfn,
    bird        = birdsfn,
    lightning   = firefn,
    sleep       = sleepfn,
    grow        = growfn,
    volcano     = volcanofn,
}