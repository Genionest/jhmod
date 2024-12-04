require "brains/rookbrain"
require "stategraphs/SGrook"

local assets=
{
}

local prefabs =
{
}

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 40
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local function ShouldSleep(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if not (homePos and distsq(homePos, myPos) <= SLEEP_DIST_FROMHOME*SLEEP_DIST_FROMHOME)
       or (inst.components.combat and inst.components.combat.target)
       or (inst.components.burnable and inst.components.burnable:IsBurning() )
       or (inst.components.freezable and inst.components.freezable:IsFrozen() ) then
        return false
    end
    local nearestEnt = GetClosestInstWithTag("character", inst, SLEEP_DIST_FROMTHREAT)
    return nearestEnt == nil
end

local function ShouldWake(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > SLEEP_DIST_FROMHOME*SLEEP_DIST_FROMHOME)
       or (inst.components.combat and inst.components.combat.target)
       or (inst.components.burnable and inst.components.burnable:IsBurning() )
       or (inst.components.freezable and inst.components.freezable:IsFrozen() ) then
        return true
    end
    local nearestEnt = GetClosestInstWithTag("character", inst, SLEEP_DIST_FROMTHREAT)
    return nearestEnt
end

local function Retarget(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > 40*40)  and not
    (inst.components.follower and inst.components.follower.leader)then
        return
    end
    
    local newtarget = FindEntity(inst, TUNING.ROOK_TARGET_DIST, function(guy)
            return (guy:HasTag("character") or guy:HasTag("monster"))
                   and not (inst.components.follower and inst.components.follower.leader == guy)
                   and not (guy:HasTag("chess") and (guy.components.follower and not guy.components.follower.leader))
                   and not ((inst.components.follower and inst.components.follower.leader == GetPlayer()) and (guy.components.follower and guy.components.follower.leader == GetPlayer()))
                   and inst.components.combat:CanTarget(guy)
    end)
    return newtarget
end

local function KeepTarget(inst, target)

    if (inst.components.follower and inst.components.follower.leader) then
        return true
    end

    if inst.sg and inst.sg:HasStateTag("running") then
        return true
    end

    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    return (homePos and distsq(homePos, myPos) < 40*40)
end

local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    if attacker and attacker:HasTag("chess") then return end
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("chess") end, MAX_TARGET_SHARES)
end

local function HitShake()


        TheCamera:Shake("SIDE", 0.5, 0.05, 0.1)
end

local function DoChargeDamage(inst, target)
    if not inst.recentlycharged then
        inst.recentlycharged = {}
    end

    for k,v in pairs(inst.recentlycharged) do
        if v == target then

            return
        end
    end
    inst.recentlycharged[target] = target
    inst:DoTaskInTime(3, function() inst.recentlycharged[target] = nil end)
    inst.components.combat:DoAttack(target, inst.weapon)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/rook/explo") 
end

local function oncollide(inst, other)
    local v1 = Vector3(inst.Physics:GetVelocity())
    if other == GetPlayer() then
        return
    end
    if v1:LengthSq() < 42 then return end

    HitShake()

    inst:DoTaskInTime(2*FRAMES, function()   
            -- if  (other and other:HasTag("smashable")) then

            --     other.components.health:Kill()
            -- elseif other and other.components.workable and other.components.workable.workleft > 0 then
            --     SpawnPrefab("collapse_small").Transform:SetPosition(other:GetPosition():Get())
            --     other.components.workable:Destroy(inst)
            -- elseif other and other.components.health and other.components.health:GetPercent() >= 0 then
            --     DoChargeDamage(inst, other)
            -- end
        if other and other.components.workable and other.components.workable.workleft > 0 then
            SpawnPrefab("collapse_small").Transform:SetPosition(other:GetPosition():Get())
            other.components.workable:Destroy(inst)
        end
    end)

end

local function CreateWeapon(inst)
    local weapon = CreateEntity()
    weapon.entity:AddTransform()
    weapon:AddComponent("weapon")
    weapon.components.weapon:SetDamage(200)
    weapon.components.weapon:SetRange(0)
    weapon:AddComponent("inventoryitem")
    weapon.persists = false
    weapon.components.inventoryitem:SetOnDroppedFn(function() weapon:Remove() end)
    weapon:AddComponent("equippable")
    inst.components.inventory:GiveItem(weapon)
    inst.weapon = weapon
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

local function MakeRook(nightmare)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 3, 1.25 )
    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(0.66, 0.66, 0.66)
    MakeCharacterPhysics(inst, 50, 1.5)
    inst.Physics:SetCollisionCallback(oncollide)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "tp_rook.tex" )
    anim:SetBank("rook")

    inst:AddComponent("lootdropper")

        inst.kind = ""
        inst.soundpath   = "dontstarve/creatures/rook/"
        inst.effortsound = "dontstarve/creatures/rook/steam"
        anim:SetBuild("rook_build")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.ROOK_WALK_SPEED
    inst.components.locomotor.runspeed =  TUNING.ROOK_RUN_SPEED
    
    inst:SetStateGraph("SGrook")

    inst:AddTag("scarytoprey")
    inst:AddTag("companion")
    inst:AddTag("character")
    -- inst:AddTag("tp_rook")

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "spring"
    inst.components.combat:SetAttackPeriod(2)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ROOK_HEALTH*5)
    inst.components.health:StartRegen(TUNING.BEEFALO_HEALTH_REGEN, TUNING.BEEFALO_HEALTH_REGEN_PERIOD)
    -- inst.components.health.show_badge = true
    inst.components.combat:SetDefaultDamage(TUNING.ROOK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.ROOK_ATTACK_PERIOD)

    inst:AddComponent("inventory")
    inst:AddComponent("inspectable")

    CreateWeapon(inst)

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
        if inst.sg:HasStateTag("moving") then
            inst.sg:GoToState("run_stop")
        end
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
    end
    inst.components.wg_vehicle.on_dismount = function(inst, doer)
        doer.components.playercontroller.actionbuttonoverride = nil
        doer.components.playeractionpicker.leftclickoverride = nil
        doer.components.playeractionpicker.rightclickoverride = nil
        inst.components.fueled:StopConsuming()
    end

    return inst
end

local Util = require "extension.lib.wg_util"
Util:AddString("tp_rook", "战车", "驾驶它进行冲撞")

return Prefab("common/tp_rook", function() return MakeRook(false) end , assets, prefabs),
MakePlacer("common/tp_rook_placer", "rook", "rook_build", "idle", nil, nil, nil, .66)

