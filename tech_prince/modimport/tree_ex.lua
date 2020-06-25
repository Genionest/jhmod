-- args: name, builds, bank, fix_fn, on_chop_fn, on_chop_down_fn, chop_fx, minimap, inspect_fn, stump_loot, growth_stages
local function create_trees(tree_name, tree_builds, tree_bank, tree_fix_fn, tree_on_chop_fn, tree_on_chop_down_fn, tree_chop_fx, tree_minimap, tree_inspect_fn, tree_stump_loot, tree_growth_stages)

local builds = tree_builds or 
{
	normal = {
		file="evergreen_new",  -- build
		prefab_name="evergreen",
		normal_loot = {"log", "log", "pinecone"},
		short_loot = {"log"},
		tall_loot = {"log", "log", "log", "pinecone", "pinecone"},
    },
}

local function makeanims(stage)
    return {
        idle="idle_"..stage,  -- 摇动
        sway1="sway1_loop_"..stage,
        sway2="sway2_loop_"..stage,
        chop="chop_"..stage,
        fallleft="fallleft_"..stage,
        fallright="fallright_"..stage,
        stump="stump_"..stage, 
        burning="burning_loop_"..stage,  -- 然后中
        burnt="burnt_"..stage,  -- 燃烧后
        chop_burnt="chop_burnt_"..stage,
        idle_chop_burnt="idle_chop_burnt_"..stage,
        blown1="blown_loop_"..stage.."1",  -- 风吹动
        blown2="blown_loop_"..stage.."2",
        blown_pre="blown_pre_"..stage,
        blown_pst="blown_pst_"..stage
    }
end

local short_anims = makeanims("short")
local tall_anims = makeanims("tall")
local normal_anims = makeanims("normal")
local old_anims =
{
	idle="idle_old",
    sway1="idle_old",
    sway2="idle_old",
    chop="chop_old",
    fallleft="chop_old",
    fallright="chop_old",
    stump="stump_old",
    burning="idle_olds",
    burnt="burnt_tall",
    chop_burnt="chop_burnt_tall",
    idle_chop_burnt="idle_chop_burnt_tall",
    blown = "blown_loop",
    blown_pre="blown_pre_old",
    blown_pst="blown_pst_old"
}

local function dig_up_stump(inst, chopper)
	inst:Remove()
	inst.components.lootdropper:SpawnLootPrefab(tree_stump_loot or "log")
    -- args: stump_loot
end

local function chop_down_burnt_tree(inst, chopper)
    inst:RemoveComponent("workable")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")          
    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")          
	inst.AnimState:PlayAnimation(inst.anims.chop_burnt)
    RemovePhysicsColliders(inst)
	inst:ListenForEvent("animover", function() inst:Remove() end)
    inst.components.lootdropper:SpawnLootPrefab("charcoal")
    inst.components.lootdropper:DropLoot()
    if inst.pineconetask then
        inst.pineconetask:Cancel()
        inst.pineconetask = nil
    end
end

local function GetBuild(inst)
	local build = builds[inst.build]
	if build == nil then
		return builds["normal"]
	end
	return build
end

local burnt_highlight_override = {.5,.5,.5}
local function OnBurnt(inst, imm)
	
	local function changes()
	    if inst.components.burnable then
		    inst.components.burnable:Extinguish()
		end
		inst:RemoveComponent("burnable")
		inst:RemoveComponent("propagator")
		inst:RemoveComponent("growable")
        inst:RemoveComponent("blowinwindgust")
        inst:RemoveTag("shelter")
        inst:RemoveTag("dragonflybait_lowprio")
        inst:RemoveTag("fire")
        inst:RemoveTag("gustable")

		inst.components.lootdropper:SetLoot({})
		
		if inst.components.workable then
			inst.components.workable:SetWorkLeft(1)
			inst.components.workable:SetOnWorkCallback(nil)
			inst.components.workable:SetOnFinishCallback(chop_down_burnt_tree)
		end
	end
		
	if imm then
		changes()
	else
		inst:DoTaskInTime( 0.5, changes)
	end    
	inst.AnimState:PlayAnimation(inst.anims.burnt, true)
    inst:AddTag("burnt")

    inst.highlight_override = burnt_highlight_override
end

local function PushSway(inst)
    if math.random() > .5 then
        inst.AnimState:PushAnimation(inst.anims.sway1, true)
    else
        inst.AnimState:PushAnimation(inst.anims.sway2, true)
    end
end

local function Sway(inst)
    if math.random() > .5 then
        inst.AnimState:PlayAnimation(inst.anims.sway1, true)
    else
        inst.AnimState:PlayAnimation(inst.anims.sway2, true)
    end
end

local function SetShort(inst)
    inst.anims = short_anims
    
    if inst.components.workable then
	    inst.components.workable:SetWorkLeft(TUNING.EVERGREEN_CHOPS_SMALL)
	end
		    
    inst.components.lootdropper:SetLoot(GetBuild(inst).short_loot)
    Sway(inst)
end

local function GrowShort(inst)
    inst.AnimState:PlayAnimation("grow_old_to_short")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrowFromWilt")          
    PushSway(inst)
end

local function SetNormal(inst)
    inst.anims = normal_anims
    
    if inst.components.workable then
	    inst.components.workable:SetWorkLeft(TUNING.EVERGREEN_CHOPS_NORMAL)
	end
	
    inst.components.lootdropper:SetLoot(GetBuild(inst).normal_loot)
    Sway(inst)
end

local function GrowNormal(inst)
    inst.AnimState:PlayAnimation("grow_short_to_normal")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")          
    PushSway(inst)
end

local function SetTall(inst)
    inst.anims = tall_anims
	if inst.components.workable then
		inst.components.workable:SetWorkLeft(TUNING.EVERGREEN_CHOPS_TALL)
	end
	
    inst.components.lootdropper:SetLoot(GetBuild(inst).tall_loot)
    Sway(inst)
end

local function GrowTall(inst)
    inst.AnimState:PlayAnimation("grow_normal_to_tall")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")          
    PushSway(inst)
end

local inspect_tree = nil
if tree_inspect_fn == "nil" then
    inspect_tree = function(inst)
        if inst:HasTag("burnt") then
            return "BURNT"
        elseif inst:HasTag("stump") then
            return "CHOPPED"
        end
    end
else
    inspect_tree = tree_inspect_fn
end
-- args: inspect_fn

local growth_stages = tree_growth_stages or
{
    {name="short", time = function(inst) return GetRandomWithVariance(TUNING.EVERGREEN_GROW_TIME[1].base, TUNING.EVERGREEN_GROW_TIME[1].random) end, fn = function(inst) SetShort(inst) end,  growfn = function(inst) GrowShort(inst) end , leifscale=.7 },
    {name="normal", time = function(inst) return GetRandomWithVariance(TUNING.EVERGREEN_GROW_TIME[2].base, TUNING.EVERGREEN_GROW_TIME[2].random) end, fn = function(inst) SetNormal(inst) end, growfn = function(inst) GrowNormal(inst) end, leifscale=1 },
    {name="tall", time = function(inst) return GetRandomWithVariance(TUNING.EVERGREEN_GROW_TIME[3].base, TUNING.EVERGREEN_GROW_TIME[3].random) end, fn = function(inst) SetTall(inst) end, growfn = function(inst) GrowTall(inst) end, leifscale=1.25 },
}
-- args: growth_stages

local function chop_tree(inst, chopper, chops)
    
    if chopper and chopper.components.beaverness and chopper.components.beaverness:IsBeaver() then
		inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/beaver_chop_tree")          
	else
		inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")          
	end

    local fx = SpawnPrefab(tree_chop_fx or "pine_needles_chop")  -- args: chop_fx
    local x, y, z= inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x,y + math.random()*2,z)

    inst.AnimState:PlayAnimation(inst.anims.chop)
    inst.AnimState:PushAnimation(inst.anims.sway1, true)
    
    if tree_on_chop_fn then
        tree_on_chop_fn(inst)
    end
    -- args: on_chop_fn
end

local function chop_down_tree(inst, chopper)
    inst:RemoveComponent("burnable")
    MakeSmallBurnable(inst)
    inst:RemoveComponent("propagator")
    MakeSmallPropagator(inst)
    inst:RemoveComponent("workable")
    inst:RemoveTag("shelter")
    inst:RemoveComponent("blowinwindgust")
    inst:RemoveTag("gustable")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local hispos = Vector3(chopper.Transform:GetWorldPosition())

    local he_right = (hispos - pt):Dot(TheCamera:GetRightVec()) > 0
    
    if he_right then
        inst.AnimState:PlayAnimation(inst.anims.fallleft)
        inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
    else
        inst.AnimState:PlayAnimation(inst.anims.fallright)
        inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
    end

    inst:DoTaskInTime(.4, function() 
		local sz = (inst.components.growable and inst.components.growable.stage > 2) and .5 or .25
		GetPlayer().components.playercontroller:ShakeCamera(inst, "FULL", 0.25, 0.03, sz, 6)
    end)
    
    RemovePhysicsColliders(inst)
    inst.AnimState:PushAnimation(inst.anims.stump)
	
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up_stump)
    inst.components.workable:SetWorkLeft(1)
    
    inst:AddTag("stump")
    if inst.components.growable then
        inst.components.growable:StopGrowing()
    end

    inst:AddTag("NOCLICK")
    inst:DoTaskInTime(2, function() inst:RemoveTag("NOCLICK") end)
    
    if tree_on_chop_down_fn then
        tree_on_chop_down_fn(inst)
    end
    -- args: on_chop_down_fn
end

local function tree_burnt(inst)
	OnBurnt(inst)
	inst.pineconetask = inst:DoTaskInTime(10,
		function()
			local pt = Vector3(inst.Transform:GetWorldPosition())
			if math.random(0, 1) == 1 then
				pt = pt + TheCamera:GetRightVec()
			else
				pt = pt - TheCamera:GetRightVec()
			end
			inst.components.lootdropper:DropLoot(pt)
			inst.pineconetask = nil
		end)
end



local function handler_growfromseed (inst)
	inst.components.growable:SetStage(1)
	inst.AnimState:PlayAnimation("grow_seed_to_short")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")          
	PushSway(inst)
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
    
    if inst:HasTag("stump") then
        data.stump = true
    end

	if inst.build ~= "normal" then
		data.build = inst.build
	end
end
        
local function onload(inst, data)
    if data then
		if not data.build or builds[data.build] == nil then
			inst.build = "normal"
		else
			inst.build = data.build
		end

        if data.burnt then
            inst:AddTag("fire") -- Add the fire tag here: OnEntityWake will handle it actually doing burnt logic
        elseif data.stump then
            inst:RemoveComponent("burnable")
            MakeSmallBurnable(inst)
            inst:RemoveComponent("workable")
            inst:RemoveComponent("propagator")
            MakeSmallPropagator(inst)
            inst:RemoveComponent("growable")
            inst:RemoveComponent("blowinwindgust")
            RemovePhysicsColliders(inst)
            inst.AnimState:PlayAnimation(inst.anims.stump)
            inst:AddTag("stump")
            inst:RemoveTag("shelter")
            inst:RemoveTag("gustable")
    		inst:AddComponent("workable")
    	    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    	    inst.components.workable:SetOnFinishCallback(dig_up_stump)
    	    inst.components.workable:SetWorkLeft(1)
        end
    end
end        

local function OnEntitySleep(inst)
    local fire = false
    if inst:HasTag("fire") then
        fire = true
    end
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("inspectable")
    if fire then
        inst:AddTag("fire")
    end
end

local function OnEntityWake(inst)

    if not inst:HasTag("burnt") and not inst:HasTag("fire") then
        if not inst.components.burnable then
            if inst:HasTag("stump") then
                MakeSmallBurnable(inst) 
            else
                MakeLargeBurnable(inst)
                inst.components.burnable:SetFXLevel(5)
                inst.components.burnable:SetOnBurntFn(tree_burnt)
            end
        end

        if not inst.components.propagator then
            if inst:HasTag("stump") then
                MakeSmallPropagator(inst)
            else
                MakeLargePropagator(inst)
            end
        end
    elseif not inst:HasTag("burnt") and inst:HasTag("fire") then
        OnBurnt(inst, true)
    end

    if not inst.components.inspectable then
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree
    end

end

local function OnGustAnimDone(inst)
    if inst:HasTag("stump") or inst:HasTag("burnt") then
        inst:RemoveEventCallback("animover", OnGustAnimDone)
        return
    end
    if inst.components.blowinwindgust and inst.components.blowinwindgust:IsGusting() then
        local anim = math.random(1,2)
        inst.AnimState:PlayAnimation(inst.anims["blown"..tostring(anim)], false)
    else
        inst:DoTaskInTime(math.random()/2, function(inst)
            inst:RemoveEventCallback("animover", OnGustAnimDone)
            inst.AnimState:PlayAnimation(inst.anims.blown_pst, false)
            PushSway(inst)
        end)
    end
end

local function OnGustStart(inst, windspeed)
    if inst:HasTag("stump") or inst:HasTag("burnt") then
        return
    end
    inst:DoTaskInTime(math.random()/2, function(inst)
        if inst.spotemitter == nil then
            AddToNearSpotEmitter(inst, "treeherd", "tree_creak_emitter", TUNING.TREE_CREAK_RANGE)
        end
        inst.AnimState:PlayAnimation(inst.anims.blown_pre, false)
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/wind_tree_creak")
        inst:ListenForEvent("animover", OnGustAnimDone)
    end)
end

local function OnGustFall(inst)
    if inst:HasTag("burnt") then
        chop_down_burnt_tree(inst, GetPlayer())
    else
        chop_down_tree(inst, GetPlayer())
    end
end

local function makefn(build, stage, data)
	
    local function fn(Sim)
		local l_stage = stage
		if l_stage == 0 then
			l_stage = math.random(1,3)
		end
        
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        
        local sound = inst.entity:AddSoundEmitter()

        MakeObstaclePhysics(inst, .25)   

		local minimap = inst.entity:AddMiniMapEntity()

        if tree_minimap then
            minimap:SetIcon(tree_minimap)
            minimap:SetPriority(-1)
        end
        -- args: minimap
       
        inst:AddTag("plant")
        inst:AddTag("tree")
        inst:AddTag("workable")
        inst:AddTag("shelter")
        
        inst.build = build
        anim:SetBuild(GetBuild(inst).file)
        -- args: bank
        anim:SetBank(tree_bank or "evergreen_short")
        local color = 0.5 + math.random() * 0.5
        anim:SetMultColour(color, color, color, 1)
        
        -------------------        
        MakeLargeBurnable(inst)
        inst.components.burnable:SetFXLevel(5)
        inst.components.burnable:SetOnBurntFn(tree_burnt)
        inst.components.burnable:MakeDragonflyBait(1)
        
        MakeLargePropagator(inst)
        
        -------------------        
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree

        
        -------------------
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.CHOP)
        inst.components.workable:SetOnWorkCallback(chop_tree)
        inst.components.workable:SetOnFinishCallback(chop_down_tree)
        
        -------------------
        inst:AddComponent("lootdropper") 
        ---------------------        
        inst:AddComponent("growable")
        inst.components.growable.stages = growth_stages
        inst.components.growable:SetStage(l_stage)
        inst.components.growable.loopstages = true
        inst.components.growable.springgrowth = true
        inst.components.growable:StartGrowing()
        
        inst.growfromseed = handler_growfromseed

        inst:AddComponent("blowinwindgust")
        inst.components.blowinwindgust:SetWindSpeedThreshold(TUNING.EVERGREEN_WINDBLOWN_SPEED)
        inst.components.blowinwindgust:SetDestroyChance(TUNING.EVERGREEN_WINDBLOWN_FALL_CHANCE)
        inst.components.blowinwindgust:SetGustStartFn(OnGustStart)
        inst.components.blowinwindgust:SetDestroyFn(OnGustFall)
        inst.components.blowinwindgust:Start()

        ---------------------        
        --PushSway(inst)
        inst.AnimState:SetTime(math.random()*2)

        ---------------------        
     
        inst.OnSave = onsave 
        inst.OnLoad = onload
        
		MakeSnowCovered(inst, .01)
        ---------------------        

		inst:SetPrefabName( GetBuild(inst).prefab_name )

        if data =="burnt"  then
            OnBurnt(inst)
        end
        
        if data =="stump"  then
            inst:RemoveComponent("burnable")
            MakeSmallBurnable(inst)            
            inst:RemoveComponent("workable")
            inst:RemoveComponent("propagator")
            MakeSmallPropagator(inst)
            inst:RemoveComponent("growable")
            inst:RemoveComponent("blowinwindgust")
            inst:RemoveTag("gustable")
            RemovePhysicsColliders(inst)
            inst.AnimState:PlayAnimation(inst.anims.stump)
            inst:AddTag("stump")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.DIG)
            inst.components.workable:SetOnFinishCallback(dig_up_stump)
            inst.components.workable:SetWorkLeft(1)
        end


        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake

        if tree_fix_fn then
            tree_fix_fn(inst)
        end

        return inst
    end
    return fn
end    

local function tree(name, build, stage, data)
    return Prefab("forest/objects/trees/"..name, makefn(build, stage, data), {})
end

return {
        tree(tree_name, "normal", 0),
        tree(tree_name.."_normal", "normal", 2),
        tree(tree_name.."_tall", "normal", 3),
        tree(tree_name.."_short", "normal", 1),
        tree(tree_name.."_burnt", "normal", 0, "burnt"),
        tree(tree_name.."_stump", "normal", 0, "stump"),
}
end

----------------------- treeseeds ------------------------------
local no_tags = {'NOBLOCK', "player", 'FX'}
local function treeseed_test(inst, pt)
    local ok = WARGON.on_land(inst, pt)
    local tiletype = WARGON.get_tile(pt)
    ok = ok and tiletype ~= GROUND.ROCKY and tiletype ~= GROUND.ROAD 
    and tiletype ~= GROUND.IMPASSABLE and tiletype ~= GROUND.INTERIOR 
    and tiletype ~= GROUND.UNDERROCK and tiletype ~= GROUND.WOODFLOOR 
    and tiletype ~= GROUND.CARPET and tiletype ~= GROUND.CHECKER 
    and tiletype < GROUND.UNDERGROUND
    if ok then
        local can = WARGON.can_deploy(inst, pt, 4, no_tags, 2)
        return can
    end
    return false
end

local function treeseed_grow(inst, tree_name)
    print ("GROWTREE")
    inst.growtask = nil
    inst.growtime = nil
    local tree = WARGON.make_spawn(inst, tree_name)
    tree:growfromseed()
    inst:Remove()
end

local function treeseed_plant(inst, growtime, tree_name)
    inst:RemoveComponent("inventoryitem")
    inst:RemoveComponent("locomotor")
    RemovePhysicsColliders(inst)
    RemoveBlowInHurricane(inst)
    inst.AnimState:PlayAnimation("idle_planted")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    inst.growtime = GetTime() + growtime
    print ("PLANT", growtime)
    inst.growtask = WARGON.do_task(inst, growtime, function()
        treeseed_grow(inst, tree_name)
    end)
end

local function treeseed_deploy(inst, pt, tree_name)
    inst = inst.components.stackable:Get()
    inst.Transform:SetPosition(pt:Get())
    local timeToGrow = GetRandomWithVariance(TUNING.ACORN_GROWTIME.base, TUNING.ACORN_GROWTIME.random)
    treeseed_plant(inst, timeToGrow, tree_name)  
end

local function treeseed_stop(inst)
    if inst.growtask then
        inst.growtask:Cancel()
        inst.growtask = nil
    end
    inst.growtime = nil
end

local function treeseed_start(inst)
    if inst and not inst.growtask then
        local growtime = GetRandomWithVariance(TUNING.ACORN_GROWTIME.base, TUNING.ACORN_GROWTIME.random)
        inst.growtime = GetTime() + growtime
        inst.growtask = WARGON.do_task(inst, growtime, function()
            treeseed_grow(inst, inst.tree)
        end)
    end
end

local function treeseed_save(inst, data)
    WARGON.seed_save(inst, data)
end

local function treeseed_load(inst, data)
    WARGON.seed_load(inst, data)
end

GLOBAL.WARGON_TREE_EX = {
-- name, builds, bank, fix_fn, on_chop_fn, on_chop_down_fn, chop_fx, minimap, inspect_fn, stump_loot, growth_stages
    create_trees    = create_trees,
    treeseed_test   = treeseed_test,
    treeseed_grow   = treeseed_grow,
    treeseed_plant  = treeseed_plant,
    treeseed_deploy = treeseed_deploy,
    treeseed_stop   = treeseed_stop,
    treeseed_start  = treeseed_start,
    treeseed_save   = treeseed_save,
    treeseed_load   = treeseed_load,
}

GLOBAL.WARGON.TREE = GLOBAL.WARGON_TREE_EX