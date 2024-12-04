local brain = require "brains/koalefantbrain"
require "stategraphs/SGkoalefant"

local assets=
{
	-- Asset("ANIM", "anim/koalefant_basic.zip"),
 --    Asset("ANIM", "anim/koalefant_actions.zip"),
 --    --Asset("ANIM", "anim/koalefant_build.zip"),
 --    Asset("ANIM", "anim/koalefant_summer_build.zip"),
 --    Asset("ANIM", "anim/koalefant_winter_build.zip"),
	-- Asset("SOUND", "sound/koalefant.fsb"),
}

local prefabs =
{
    -- "meat",
    -- "poop",
    -- "trunk_summer",
    -- "trunk_winter",
}

-- local loot_summer = {"meat","meat","meat","meat","meat","meat","meat","meat","trunk_summer"}
-- local loot_winter = {"meat","meat","meat","meat","meat","meat","meat","meat","trunk_winter"}


local WAKE_TO_RUN_DISTANCE = 10
local SLEEP_NEAR_ENEMY_DISTANCE = 14

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or inst:IsNear(GetPlayer(), WAKE_TO_RUN_DISTANCE)
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not inst:IsNear(GetPlayer(), SLEEP_NEAR_ENEMY_DISTANCE)
end

local function Retarget(inst)

end

local function KeepTarget(inst, target)
    return distsq(Vector3(target.Transform:GetWorldPosition() ), Vector3(inst.Transform:GetWorldPosition() ) ) < TUNING.KOALEFANT_CHASE_DIST * TUNING.KOALEFANT_CHASE_DIST
end

local function OnNewTarget(inst, data)

end

local function GetStatus(inst)

end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30,function(dude)
        return dude:HasTag("koalefant") and not dude:HasTag("player") and not dude.components.health:IsDead()
    end, 5)
end

local function action_button_picker(inst)
    return BufferedAction(inst, inst.components.wg_vehicle_owner.vehicle, ACTIONS.WG_DISMOUNT)
end

local function left_click_picker(inst, target, pos)
    if target and target.components.wg_vehicle
    and target.components.wg_vehicle:CanDismount() then
        return inst.components.playeractionpicker:SortActionList({ACTIONS.WG_DISMOUNT}, target, nil)
    end
end

local function right_click_picker(inst, target, pos)
    return {}
end

-- local function create_base(sim)
local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 4.5, 2 )
    inst.Transform:SetFourFaced()

    MakePoisonableCharacter(inst)
    MakeCharacterPhysics(inst, 100, .75)
    
    anim:SetBank("koalefant")
    anim:SetBuild("koalefant_summer_build")
    anim:PlayAnimation("idle_loop", true)
    
    -- inst:AddTag("animal")
    -- inst:AddTag("largecreature")

    
    -- inst:AddComponent("eater")
    -- inst.components.eater:SetVegetarian()
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "beefalo_body"
    inst.components.combat:SetDefaultDamage(TUNING.KOALEFANT_DAMAGE)
    -- inst.components.combat:SetRetargetFunction(1, Retarget)
    -- inst.components.combat:SetKeepTargetFunction(KeepTarget)
    -- inst:ListenForEvent("newcombattarget", OnNewTarget)
    -- inst:ListenForEvent("attacked", function(inst, data) OnAttacked(inst, data) end)
    
     
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.KOALEFANT_HEALTH)

    inst:AddComponent("lootdropper")
    
    inst:AddComponent("inspectable")
    -- inst.components.inspectable.getstatus = GetStatus
    
    -- inst:AddComponent("knownlocations")
    
    -- inst:AddComponent("periodicspawner")
    -- inst.components.periodicspawner:SetPrefab("poop")
    -- inst.components.periodicspawner:SetRandomTimes(40, 60)
    -- inst.components.periodicspawner:SetDensityInRange(20, 2)
    -- inst.components.periodicspawner:SetMinimumSpacing(8)
    -- inst.components.periodicspawner:Start()

    -- MakeLargeBurnableCharacter(inst, "beefalo_body")
    -- MakeLargeFreezableCharacter(inst, "beefalo_body")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 1.5
    inst.components.locomotor.runspeed = 7
    
    -- inst:AddComponent("sleeper")
    -- inst.components.sleeper:SetResistance(3)
    -- inst.components.sleeper:SetSleepTest(ShouldSleep)
    -- inst.components.sleeper:SetWakeTest(ShouldWakeUp)
    
    -- inst:SetBrain(brain)
    inst:SetStateGraph("SGkoalefant")

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "tp_fant.tex" )

    inst:AddTag("scarytoprey")
    inst:AddTag("companion")
    inst:AddTag("tp_fant")

    inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(TUNING.MED_FUEL*10)
    -- inst.components.fueled.fueltype = "BURNABLE"
    -- inst.components.fueled.secondaryfueltype = "CHEMICAL"
    inst.components.fueled.accepting = true
    inst.components.fueled.period = 1
    inst.components.fueled.ontakefuelfn = function()
        inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    end
    inst.components.fueled:SetDepletedFn(function(inst)
        inst.components.wg_vehicle_controller:Enable(false)
    end)

    inst:AddComponent("wg_vehicle")
    inst:AddComponent("wg_vehicle_controller")
    inst:AddComponent("wg_vehicle_action_picker")
    inst.components.wg_vehicle.on_mounted = function(inst, doer)
        doer.components.playercontroller.actionbuttonoverride = action_button_picker
        doer.components.playeractionpicker.leftclickoverride = left_click_picker
        doer.components.playeractionpicker.rightclickoverride = right_click_picker
        inst.components.fueled:StartConsuming()

        if inst.task == nil then
            inst.task = inst:DoPeriodicTask(.5, function()
                local player = inst.components.wg_vehicle.owner
                if not player then
                    return
                end
                if inst.components.fueled:IsEmpty() then
                    return 
                end
                local x, y, z = inst:GetPosition():Get()
                local ents = TheSim:FindEntities(x, y, z, 2, {"wg_can_fast_harvest"})
                for k, v in pairs(ents) do
                    if v.components.harvestable then
                        v.components.harvestable:Harvest(player)
                    elseif v.components.crop then
                        v.components.crop:Harvest(player)
                    elseif v.components.pickable then
                        v.components.pickable:Pick(player)
                    end
                end
            end)
        end
    end
    inst.components.wg_vehicle.on_dismount = function(inst, doer)
        doer.components.playercontroller.actionbuttonoverride = nil
        doer.components.playeractionpicker.leftclickoverride = nil
        doer.components.playeractionpicker.rightclickoverride = nil
        inst.components.fueled:StopConsuming()

        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end

    return inst
end

-- local function create_summer(sim)
-- 	local inst = create_base(sim)

--     inst.AnimState:SetBuild("koalefant_summer_build")
--     inst.components.lootdropper:SetLoot(loot_summer)

-- 	return inst
-- end

-- local function create_winter(sim)
-- 	local inst = create_base(sim)

--     inst.AnimState:SetBuild("koalefant_winter_build")
--     inst.components.lootdropper:SetLoot(loot_winter)

-- 	return inst
-- end

local Util = require "extension.lib.wg_util"
Util:AddString("tp_fant", "收获象", "会收获周围的作物(需要燃料)")

return Prefab( "common/object/tp_fant", fn, assets, prefabs),
MakePlacer("tp_fant_placer", "koalefant", "koalefant_summer_build", "idle_loop")
	   -- Prefab( "forest/animals/koalefant_winter", create_winter, assets, prefabs) 
