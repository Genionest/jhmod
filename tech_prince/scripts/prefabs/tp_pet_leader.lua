local tallbird_eggs = {"egg", "tallbird_egg", "egg"}
local krampus_sacks = {"backpack1", "krampus_sack", "anim"}
local krampus_sack_cards = {"krampus_sack_card", "krampus_sack_card", "idle"}

local SPAWN_DIST = 30

-- local function RebuildTile(inst)
    -- if inst.components.inventoryitem:IsHeld() then
    --     local owner = inst.components.inventoryitem.owner
    --     inst.components.inventoryitem:RemoveFromOwner(true)
    --     if owner.components.container then
    --         owner.components.container:GiveItem(inst)
    --     elseif owner.components.inventory then
    --         owner.components.inventory:GiveItem(inst)
    --     end
    -- end
-- end

local function GetSpawnPoint(pt)
    local theta = math.random() * 2 * PI
    local radius = SPAWN_DIST

	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	if offset then
		return pt+offset
	end
end

local function SpawnChester(inst)
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local spawn_pt = GetSpawnPoint(pt)
    if spawn_pt then
        -- local chester = SpawnPrefab("chester")
        local chester = SpawnPrefab(inst.tp_pet)
        if chester then
            chester.Physics:Teleport(spawn_pt:Get())
            chester:FacePoint(pt.x, pt.y, pt.z)

            return chester
        end
    end
end

local function StopRespawn(inst)
    if inst.respawntask then
        inst.respawntask:Cancel()
        inst.respawntask = nil
        inst.respawntime = nil
    end
end

local function RebindChester(inst, chester)
    chester = chester or TheSim:FindFirstEntityWithTag(inst.tp_pet_tag)
    -- chester = chester or TheSim:FindFirstEntityWithTag("chester")
    if chester then
        -- inst.AnimState:PlayAnimation("idle_loop", true)
        -- inst.components.inventoryitem:ChangeImageName(inst.openEye)
        inst:ListenForEvent("death", function() inst:OnChesterDeath() end, chester)

        if chester.components.tpbebird
        and chester.components.tpbebird.bird then
            chester = chester.components.tpbebird.bird
        end
        if chester.components.follower
        and chester.components.follower.leader ~= inst then
            chester.components.follower:SetLeader(inst)
        end
        return true
    end
end

local function RespawnChester(inst)
    StopRespawn(inst)

    local chester = TheSim:FindFirstEntityWithTag(inst.tp_pet_tag)
    -- local chester = TheSim:FindFirstEntityWithTag("chester")
    if not chester then
        chester = SpawnChester(inst)
    end
    RebindChester(inst, chester)
end

local function StartRespawn(inst, time)
    StopRespawn(inst)
    local respawntime = time or 0
    if respawntime then
        inst.respawntask = inst:DoTaskInTime(respawntime, function() RespawnChester(inst) end)
        inst.respawntime = GetTime() + respawntime
        -- inst.AnimState:PlayAnimation("dead", true)
        -- inst.components.inventoryitem:ChangeImageName(inst.closedEye)
    end
end

local function OnChesterDeath(inst)
    StartRespawn(inst, TUNING.CHESTER_RESPAWN_TIME)
end

local function FixChester(inst)
	inst.fixtask = nil
	if not RebindChester(inst) then
        -- inst.AnimState:PlayAnimation("dead", true)
        -- inst.components.inventoryitem:ChangeImageName(inst.closedEye)
		
		if inst.components.inventoryitem.owner then
			local time_remaining = 0
			local time = GetTime()
			if inst.respawntime and inst.respawntime > time then
				time_remaining = inst.respawntime - time		
			end
			StartRespawn(inst, time_remaining)
		end
	end
end

local function OnPutInInventory(inst)
	if not inst.fixtask then
		inst.fixtask = inst:DoTaskInTime(1, function() FixChester(inst) end)	
	end
end

local function OnSave(inst, data)
    local time = GetTime()
    if inst.respawntime and inst.respawntime > time then
        data.respawntimeremaining = inst.respawntime - time
    end
end

local function OnLoad(inst, data)
    if data and data.respawntimeremaining then
		inst.respawntime = data.respawntimeremaining + GetTime()
	end
end

local function MakePetLeader(name, anims, pet, atlas, img, speical_fn)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        --so I can find the thing while testing
        --local minimap = inst.entity:AddMiniMapEntity()
        --minimap:SetIcon( "treasure.png" )

        inst:AddTag(name)
        inst:AddTag("irreplaceable")
        inst:AddTag("nonpotatable")
        inst:AddTag("follower_leash")
        inst.tp_pet_tag = pet
        inst.tp_pet = pet

        MakeInventoryPhysics(inst)
        
        inst.AnimState:SetBank(anims[1])
        inst.AnimState:SetBuild(anims[2])
        inst.AnimState:PlayAnimation(anims[3])

        inst:AddComponent("inventoryitem")
        local inv_atlas = atlas and "images/inventoryimages/"..atlas..".xml"
        inst.components.inventoryitem.atlasname = inv_atlas
        inst.components.inventoryitem.imagename = img or atlas
        inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
        
        -- inst.EyeboneState = "NORMAL"
        -- inst.openEye = "chester_eyebone"
        -- inst.closedEye = "chester_eyebone_closed"   

        -- inst.components.inventoryitem:ChangeImageName(inst.openEye)    
        inst:AddComponent("inspectable")
        -- inst.components.inspectable:RecordViews()

        inst:AddComponent("leader")

        inst.OnLoad = OnLoad
        inst.OnSave = OnSave
        inst.OnChesterDeath = OnChesterDeath

        inst.fixtask = inst:DoTaskInTime(1, function() FixChester(inst) end)
        if speical_fn then
            speical_fn(inst)
        end

        return inst
    end
    return Prefab( "common/inventory/"..name, fn, {}) 
end

local function pot_bird_egg_fn(inst)
    -- WARGON.make_map(inst, "tallbirdegg.png")
    inst:add_cmps({
        use = {
            test = function()
                return not inst.stop
            end,
            use = function()
                local pot = c_find("tp_cook_pot")
                if pot and pot.components.tpbebird then
                    pot.components.tpbebird:BeBird()
                else
                    local bird = c_find("tp_pot_bird")
                    if bird and bird.components.tpbepot then
                        bird.components.tpbepot:BePot()
                    end
                end
                inst.stop = true
                inst:do_task(3, function()
                    inst.stop = false
                end)
            end,
        }
    })
end

local function red_dragon_sack_fn(inst)
    -- WARGON.make_map(inst, "krampus_sack_card.tex")
end

return 
MakePetLeader("tp_red_dragon_sack", krampus_sack_cards, "tp_red_dragon",
    "krampus_sack_card", nil, red_dragon_sack_fn),
MakePetLeader("tp_pot_bird_egg", tallbird_eggs, "tp_pot_bird", 
    nil, "tallbirdegg", pot_bird_egg_fn)