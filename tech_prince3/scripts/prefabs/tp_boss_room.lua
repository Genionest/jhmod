local Util = require "extension.lib.wg_util"


local function onsave(inst, data)
    if inst:HasTag("spawned_shop") then
        data.spawned_shop = true
    end
end

local function onload(inst, data)
    if data and data.spawned_shop then
        inst:AddTag("spawned_shop")
    end
end

local function createInterior(inst, name)
    if not inst:HasTag("spawned_shop") then
        -- CREATE THE INTERIOR
        local interior_spawner = GetWorld().components.interiorspawner

        local palaceID = interior_spawner:GetNewID()

        local depth = 18
        local width = 26        

        local exterior_door_def =
        {
            my_door_id = name..palaceID.."_door",
            target_door_id = name..palaceID.."_exit",
            target_interior = palaceID
        }

        interior_spawner:AddDoor(inst, exterior_door_def)

        local floortexture   = "levels/textures/interiors/floor_marble_royal.tex"
        local walltexture    = "levels/textures/interiors/wall_royal_high.tex"
        local minimaptexture = "levels/textures/map_interior/mini_floor_marble_royal.tex"

        -- local floortexture = "levels/textures/interiors/floor_cityhall.tex"
        -- local walltexture = "levels/textures/interiors/wall_mayorsoffice_whispy.tex"         

        local addprops = {}     
        addprops =
        {
            { name = "prop_door", x_offset = 9, z_offset = 0, animdata = {bank = "palace_door", build = "palace_door", anim = "south", background = false }, 
                my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, rotation = -90, addtags = {"guard_entrance"}, usesounds={"dontstarve_DLC003/common/objects/store/door_close"} },

            { name = "prop_door_shadow", x_offset = 9, z_offset = 0, animdata = {bank = "palace_door", build = "palace_door", anim = "south_floor"} },

            { name = "deco_roomglow_large", x_offset = 0, z_offset = 0 },
           
            { name = "deco_palace_beam_room_tall_corner_front", x_offset =  18/2, z_offset = -26/2, rotation = 90, flip = true },
            { name = "deco_palace_beam_room_tall_corner_front", x_offset =  18/2, z_offset =  26/2, rotation = 90 }, 

            { name = "deco_palace_banner_small_front", x_offset = -18/2, z_offset = -26/18-3, rotation = 90 },
            { name = "deco_palace_banner_small_front", x_offset = -18/2, z_offset =  26/18+3, rotation = 90 }, 

            { name = "deco_palace_banner_small_front", x_offset = -18/2, z_offset = -26/18 - 26/3, rotation = 90 },
            { name = "deco_palace_banner_small_front", x_offset = -18/2, z_offset =  26/18 - 26/3, rotation = 90 },        

            { name = "deco_palace_banner_small_sidewall", x_offset = -18/14, z_offset = -26/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset = -18/14, z_offset =  26/2, rotation = 90 },
            { name = "deco_palace_banner_small_sidewall", x_offset =  18/14, z_offset = -26/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset =  18/14, z_offset =  26/2, rotation = 90 },

            { name = "deco_palace_banner_small_sidewall", x_offset = -18/14 * 3, z_offset = -26/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset = -18/14 * 3, z_offset =  26/2, rotation = 90 },
            { name = "deco_palace_banner_small_sidewall", x_offset =  18/14 * 3, z_offset = -26/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset =  18/14 * 3, z_offset =  26/2, rotation = 90 },

            { name = "deco_palace_banner_small_sidewall", x_offset = -18/14 * 5, z_offset =  -26/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset = -18/14 * 5, z_offset =   26/2, rotation = 90 },
            { name = "deco_palace_banner_small_sidewall", x_offset =  18/14 * 5, z_offset =  -26/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset =  18/14 * 5, z_offset =   26/2, rotation = 90 },

            { name = inst.boss_name,       x_offset = -3, z_offset = 0 },

            -- floor corner pieces
            { name = "rug_palace_corners", x_offset = -18/2, z_offset =  26/2, rotation = 90  },
            { name = "rug_palace_corners", x_offset =  18/2, z_offset =  26/2, rotation = 180 },
            { name = "rug_palace_corners", x_offset =  18/2, z_offset = -26/2, rotation = 270 },
            { name = "rug_palace_corners", x_offset = -18/2, z_offset = -26/2, rotation = 0   },

            -- front wall floor lights
            { name = "swinglightobject", x_offset = 18/2, z_offset = -26/3, rotation = -90 }, 
            { name = "swinglightobject", x_offset = 18/2, z_offset =  26/3, rotation = -90 }, 

            -- back wall lights and floor lights
            { name = "window_round_light_backwall", x_offset = -18/2, z_offset = -26/3, rotation = -90 }, 
            { name = "window_palace",               x_offset = -18/2, z_offset = -26/3, rotation =  90 },
            { name = "window_round_light_backwall", x_offset = -18/2, z_offset =  26/3, rotation = -90 }, 
            { name = "window_palace",               x_offset = -18/2, z_offset =  26/3, rotation =  90 }, 
            { name = "window_round_light_backwall", x_offset = -18/2, z_offset =     0, rotation = -90 }, 
            { name = "window_palace_stainglass",    x_offset = -18/2, z_offset =     0, rotation =  90 }, 
        }

        interior_spawner:CreateRoom("generic_interior", width, 13, depth, name, palaceID, addprops, {}, walltexture, floortexture, minimaptexture, nil, "images/colour_cubes/pigshop_interior_cc.tex", nil, nil, "palace", "PALACE","STONE")

        inst.interiorID = palaceID
        inst:AddTag("spawned_shop")
    end
end

local function create_void_room(inst, name)
    if not inst:HasTag("spawned_shop") then
        -- CREATE THE INTERIOR
        local interior_spawner = GetWorld().components.interiorspawner

        local palaceID = interior_spawner:GetNewID()

        local depth = 18
        local width = 26        

        local exterior_door_def =
        {
            my_door_id = name..palaceID.."_door",
            target_door_id = name..palaceID.."_exit",
            target_interior = palaceID,
        }

        interior_spawner:AddDoor(inst, exterior_door_def)

        local    floortexture = "levels/textures/interiors/batcave_floor.tex"
        local    walltexture =  "levels/textures/interiors/batcave_wall_rock.tex"
        local    minimaptexture = "levels/textures/map_interior/mini_vamp_cave_noise.tex"

        -- local floortexture = "levels/textures/interiors/floor_cityhall.tex"
        -- local walltexture = "levels/textures/interiors/wall_mayorsoffice_whispy.tex"         

        local addprops = {}     
        addprops =
        {
            { name = "prop_door", x_offset = 9, z_offset = 0, animdata = {bank = "exitrope", build = "cave_exit_rope", anim = "idle_loop", background = false }, 
                my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, rotation = -90, addtags = {"guard_entrance"}, usesounds={"dontstarve_DLC003/common/objects/store/door_close"} },

            -- { name = "prop_door_shadow", x_offset = 9, z_offset = 0, animdata = {bank = "palace_door", build = "palace_door", anim = "south_floor"} },

            { name = "deco_roomglow_large", x_offset = 0, z_offset = 0 },
            -- { name = "tp_moon_lake", x_offset = 0, z_offset = 0 },
           
            -- { name = "deco_palace_beam_room_tall_corner_front", x_offset =  18/2, z_offset = -26/2, rotation = 90, flip = true },
            -- { name = "deco_palace_beam_room_tall_corner_front", x_offset =  18/2, z_offset =  26/2, rotation = 90 }, 

            -- { name = "deco_palace_banner_small_front", x_offset = -18/2, z_offset = -26/18-3, rotation = 90 },
            -- { name = "deco_palace_banner_small_front", x_offset = -18/2, z_offset =  26/18+3, rotation = 90 }, 

            -- { name = "deco_palace_banner_small_front", x_offset = -18/2, z_offset = -26/18 - 26/3, rotation = 90 },
            -- { name = "deco_palace_banner_small_front", x_offset = -18/2, z_offset =  26/18 - 26/3, rotation = 90 },        

            -- { name = "deco_palace_banner_small_sidewall", x_offset = -18/14, z_offset = -26/2, rotation = 90, flip = true },
            -- { name = "deco_palace_banner_small_sidewall", x_offset = -18/14, z_offset =  26/2, rotation = 90 },
            -- { name = "deco_palace_banner_small_sidewall", x_offset =  18/14, z_offset = -26/2, rotation = 90, flip = true },
            -- { name = "deco_palace_banner_small_sidewall", x_offset =  18/14, z_offset =  26/2, rotation = 90 },

            -- { name = "deco_palace_banner_small_sidewall", x_offset = -18/14 * 3, z_offset = -26/2, rotation = 90, flip = true },
            -- { name = "deco_palace_banner_small_sidewall", x_offset = -18/14 * 3, z_offset =  26/2, rotation = 90 },
            -- { name = "deco_palace_banner_small_sidewall", x_offset =  18/14 * 3, z_offset = -26/2, rotation = 90, flip = true },
            -- { name = "deco_palace_banner_small_sidewall", x_offset =  18/14 * 3, z_offset =  26/2, rotation = 90 },

            -- { name = "deco_palace_banner_small_sidewall", x_offset = -18/14 * 5, z_offset =  -26/2, rotation = 90, flip = true },
            -- { name = "deco_palace_banner_small_sidewall", x_offset = -18/14 * 5, z_offset =   26/2, rotation = 90 },
            -- { name = "deco_palace_banner_small_sidewall", x_offset =  18/14 * 5, z_offset =  -26/2, rotation = 90, flip = true },
            -- { name = "deco_palace_banner_small_sidewall", x_offset =  18/14 * 5, z_offset =   26/2, rotation = 90 },

            { name = inst.boss_name,       x_offset = -3, z_offset = 0 },

            -- floor corner pieces
            -- { name = "rug_palace_corners", x_offset = -18/2, z_offset =  26/2, rotation = 90  },
            -- { name = "rug_palace_corners", x_offset =  18/2, z_offset =  26/2, rotation = 180 },
            -- { name = "rug_palace_corners", x_offset =  18/2, z_offset = -26/2, rotation = 270 },
            -- { name = "rug_palace_corners", x_offset = -18/2, z_offset = -26/2, rotation = 0   },

            -- front wall floor lights
            { name = "swinglightobject", x_offset = 18/2, z_offset = -26/3, rotation = -90 }, 
            { name = "swinglightobject", x_offset = 18/2, z_offset =  26/3, rotation = -90 }, 

            -- back wall lights and floor lights
            -- { name = "window_round_light_backwall", x_offset = -18/2, z_offset = -26/3, rotation = -90 }, 
            -- { name = "window_palace",               x_offset = -18/2, z_offset = -26/3, rotation =  90 },
            -- { name = "window_round_light_backwall", x_offset = -18/2, z_offset =  26/3, rotation = -90 }, 
            -- { name = "window_palace",               x_offset = -18/2, z_offset =  26/3, rotation =  90 }, 
            -- { name = "window_round_light_backwall", x_offset = -18/2, z_offset =     0, rotation = -90 }, 
            -- { name = "window_palace_stainglass",    x_offset = -18/2, z_offset =     0, rotation =  90 }, 
        }

        interior_spawner:CreateRoom("generic_interior", width, 13, depth, name, palaceID, addprops, {}, walltexture, floortexture, minimaptexture, nil, "images/colour_cubes/pigshop_interior_cc.tex", nil, nil, "palace", "PALACE","STONE")

        inst.interiorID = palaceID
        inst:AddTag("spawned_shop")
    end
end

local function fool_spider_room_fn(inst)
    inst:AddTag("tp_moon_lake")
    inst:DoTaskInTime(0, function(inst)
        create_void_room(inst, "moon_lake")
    end)
    inst.AnimState:PlayAnimation("idle", true)
    inst:AddTag("NOCLICK")
    -- inst:AddTag("FX")
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )
    inst:ListenForEvent("nighttime", function()
        if GetClock():IsNight() and GetClock():GetMoonPhase()=="full" then
            inst:RemoveTag("NOCLICK")
        end
    end, GetWorld())
    inst:ListenForEvent("daytime", function()
        inst:AddTag("NOCLICK")
    end, GetWorld())
    inst:DoTaskInTime(0, function()
        if GetClock():IsNight() and GetClock():GetMoonPhase()=="full" then
            inst:RemoveTag("NOCLICK")
        end
    end)
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    inst:AddComponent("door")
    inst:AddComponent("inspectable")
    inst:AddTag("guard_entrance")
    -- inst:AddTag("teleportato_part")
    inst:AddComponent("wg_start")
    inst.components.wg_start.delay = 1
    inst.components.wg_start:AddFn(function(inst)
        SpawnPrefab("tp_boss_obstacle_spawner").Transform:SetPosition(inst:GetPosition():Get())
    end)

    inst.OnSave = onsave 
    inst.OnLoad = onload

    inst.boss_name = nil


    inst:DoTaskInTime(0, function() 
        if inst.cave then
            create_void_room(inst, "boss_room")
        else 
            createInterior(inst, "boss_room")
        end
    end)

    return inst
end

local function fn2()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    inst:AddComponent("door")
    inst:AddComponent("inspectable")
    inst:AddTag("guard_entrance")
    -- inst:AddTag("teleportato_part")
    inst:AddComponent("wg_start")

    inst.OnSave = onsave 
    inst.OnLoad = onload

    inst.boss_name = nil
    fool_spider_room_fn(inst)
    -- inst:DoTaskInTime(0, function() 
    --     create_void_room(inst, "boss_room")
    -- end)

    return inst
end

local function hut()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.AnimState:SetBank("hut")
    inst.AnimState:SetBuild("palmleaf_hut")
    inst.AnimState:PlayAnimation("idle", true)
    inst:AddTag("NOCLICK")
    inst.persists = false

    return inst
end

local function rug()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.AnimState:SetBank("rugs")
    inst.AnimState:SetBuild("rugs")
    inst.AnimState:PlayAnimation("rug_octagon", true)
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )
    inst:AddTag("NOCLICK")
    inst.persists = false
    
    return inst
end

local function genCircEdgePositions(num)
	assert(num>0)
	local positions = {}
	for i = 1, num do
	   	local a = (3.14159*2/num) * i
		table.insert(positions, {x=math.sin(a),y=math.cos(a)})
	end
	return positions
end	

local function obstacle_spawner()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst:DoTaskInTime(0, function(inst)
        local pos = inst:GetPosition()
        local t = genCircEdgePositions(55)
        local radius = 16
        for k, v in pairs(t) do
            local x = v.x * radius
            local z = v.y * radius
            if inst:GetIsOnLand(pos.x+x, 0, pos.z+z) then
                local wall = SpawnPrefab("tp_boss_obstacle")
                wall.Transform:SetPosition(pos.x+x, 0, pos.z+z)
                wall.center = {pos.x, pos.z}
            end
        end
        inst:Remove()
    end)
    return inst
end

local function obstacle()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.AnimState:SetBank("blocker_sanity")
    inst.AnimState:SetBuild("blocker_sanity")
    inst.AnimState:PlayAnimation("idle_active")

    MakeObstaclePhysics(inst, 1)
    
    inst:AddTag("tp_boss_obstacle")
    -- inst:AddComponent("inspectable")
    inst:AddTag("obstacle")
    inst:AddComponent("wg_useable")
    -- inst.components.wg_useable.test = function(inst, doer) end
    inst.components.wg_useable.sound = "dontstarve/common/deathpoof"
    inst.components.wg_useable.use = function(inst, doer) 
        GetPlayer().HUD:Hide()
        TheFrontEnd:Fade(false,.5)
        inst:DoTaskInTime(.5, function()
            doer.Transform:SetPosition(inst.center[1], 0, inst.center[2])
            GetPlayer().HUD:Show()
            TheFrontEnd:Fade(true,.5) 
        end)
    end

    inst.OnSave = function(inst, data)
        data.center = inst.center
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.center = data.center
        end
    end

    return inst
end

Util:AddString("tp_boss_obstacle", "方尖碑", "触碰它吧")

return Prefab("tp_boss_room", fn, {}),
    Prefab("tp_boss_room_hut", hut, {}),
    Prefab("tp_boss_room_rug", rug, {}),
    Prefab("tp_boss_obstacle", obstacle, {}),
    Prefab("tp_boss_obstacle_spawner", obstacle_spawner, {})