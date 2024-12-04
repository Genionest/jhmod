-- require "brains/spidermonkeybrain"
-- require "stategraphs/SGspidermonkey"

local assets = 
{
	--Asset("ANIM", "anim/kiki_basic.zip"),
	--Asset("ANIM", "anim/spidermonkey_build.zip"),
 --    Asset("ANIM", "anim/spiderape_basics.zip"),
 --    Asset("ANIM", "anim/spiderape_build.zip"),

	-- Asset("SOUND", "sound/monkey.fsb"),
}

local prefabs = 
{
	-- "poop",
	-- "monkeyprojectile",
	-- "monstermeat",
	-- "spidergland",
}


local function OnSave(inst, data)

end

local function OnLoad(inst, data)

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

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()	
    inst.soundtype = ""
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize(2, 1.25)
	
	inst.Transform:SetFourFaced()

	--inst.Transform:SetScale(2.2, 2.2, 2.2)
	MakeCharacterPhysics(inst, 40, 1.5)
    -- MakeMediumBurnableCharacter(inst)
    -- MakeMediumFreezableCharacter(inst)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "tp_coal_beast.tex" )
    anim:SetBank("rook")

    anim:SetBank("spiderape")
	anim:SetBuild("SpiderApe_build")
	
	anim:PlayAnimation("idle_loop", true)

	-- inst:AddTag("spider_monkey")
	-- inst:AddTag("animal")

	-- inst:AddComponent("inventory")

	inst:AddComponent("inspectable")

	-- inst:AddComponent("thief")

    inst:AddComponent("locomotor")
    -- inst.components.locomotor:SetSlowMultiplier(1)
    -- inst.components.locomotor:SetTriggersCreep(false)
    -- inst.components.locomotor.pathcaps = { ignorecreep = false }
    inst.components.locomotor.walkspeed = TUNING.SPIDER_MONKEY_SPEED_AGITATED
    inst.components.locomotor.runspeed = TUNING.SPIDER_MONKEY_SPEED_AGITATED

    inst:AddComponent("combat")
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_MONKEY_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.SPIDER_MONKEY_MELEE_RANGE)
    -- inst.components.combat:SetRetargetFunction(1, retargetfn)
    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_MONKEY_DAMAGE)
    -- inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetAreaDamage(TUNING.DEERCLOPS_AOE_RANGE, TUNING.DEERCLOPS_AOE_SCALE)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SPIDER_MONKEY_HEALTH*5)
    inst.components.health:StartRegen(50, 1)
    
    -- inst:AddComponent("periodicspawner")
    -- inst.components.periodicspawner:SetPrefab("poop")
    -- inst.components.periodicspawner:SetRandomTimes(200, 400)
    -- inst.components.periodicspawner:SetDensityInRange(20, 2)
    -- inst.components.periodicspawner:SetMinimumSpacing(15)
    -- inst.components.periodicspawner:Start()

    inst:AddComponent("lootdropper")
    -- inst.components.lootdropper:SetChanceLootTable("spidermonkey")
    -- inst.components.lootdropper.droppingchanceloot = false

	-- inst:AddComponent("eater")
	-- inst.components.eater:SetVegetarian()
	-- inst.components.eater:SetOnEatFn(oneat)

	-- inst:AddComponent("sleeper")
	-- inst.components.sleeper:SetNocturnal()

    inst:AddComponent("knownlocations")
    -- inst:AddComponent("herdmember")
    -- inst.components.herdmember:SetHerdPrefab("spider_monkey_herd")

	-- inst:AddComponent("playerprox")
 --    inst.components.playerprox:SetDist(20, 23)
 --    inst.components.playerprox:SetOnPlayerNear(onnear)
 --    inst.components.playerprox:SetOnPlayerFar(onfar)
    
	-- inst:AddComponent("sanityaura")
 --    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

	-- local brain = require "brains/spidermonkeybrain"
	-- inst:SetBrain(brain)
    -- 不然不会走过去攻击
    inst:SetBrain(require "brains/wilsonbrain")
	-- inst:SetStateGraph("SGtp_coal_beast")
    inst:SetStateGraph("SGspidermonkey")
    inst.components.combat.not_battle_cry = true

    -- inst.listenfn = function(listento, data) OnMonkeyDeath(inst, data) end

    -- inst:ListenForEvent("onpickup", onpickup)
 --    inst:ListenForEvent("attacked", OnAttacked)

    -- inst.AnimState:Hide("spiderleg")

    inst:AddTag("scarytoprey")
    inst:AddTag("companion")
    inst:AddTag("tp_coal_beast")

    inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(TUNING.MED_FUEL*10)
    -- inst.components.fueled.fueltype = "BURNABLE"
    -- inst.components.fueled.secondaryfueltype = "CHEMICAL"
    inst.components.fueled.accepting = true
    inst.components.fueled.period = 1
    inst.components.fueled.ontakefuelfn = function()
        inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
        if inst.components.fueled:GetPercent()>0 then
            inst.components.combat:SetAreaDamage(TUNING.DEERCLOPS_AOE_RANGE, TUNING.DEERCLOPS_AOE_SCALE)
            -- inst.components.health:StartRegen(50, 1)
        end
    end
    inst.components.fueled:SetDepletedFn(function(inst)
        inst.components.combat:SetAreaDamage(nil, nil)
        -- inst.components.health:StopRegen()
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
    inst.components.wg_vehicle_controller.can_attack = true

    -- inst:ListenForEvent("onhitother", function(inst, data)
    --     if data and data.cause ~= "tp_coal_beast_warth"
    --     and inst.components.tpenergy.burn_modifier["warth"] then
    --         local fx = WARGON.make_fx(inst, "groundpoundring_fx")
    --         WARGON.area_dmg(inst, 4, inst, 30, "tp_coal_beast_warth", nil)
    --     end
    -- end)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

	return inst
end

local Util = require "extension.lib.wg_util"
Util:AddString("tp_coal_beast", "战斗猩猩", "可以战斗,拥有燃料是造成范围伤害")

return Prefab("common/object/tp_coal_beast", fn, assets, prefabs),
MakePlacer("common/tp_coal_beast_placer", "spiderape", "SpiderApe_build", "idle_loop")
