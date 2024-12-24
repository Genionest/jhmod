local Sounds = require "extension/datas/sounds"
local EntUtil = require "extension.lib.ent_util"
local BuffManager = Sample.BuffManager
local FxManager = Sample.FxManager

local function PlayerAnimation(inst, fname, ...)
    inst.AnimState[fname](inst.AnimState, ...)
    if inst.tp_fx then
        inst.tp_fx.Transform:SetRotation(inst.Transform:GetRotation())
        inst.tp_fx.AnimState[fname](inst.tp_fx.AnimState, ...)
    end
end

local function add_player_sg(state, no_boating)
    AddStategraphState("wilson", state)
    if not no_boating then
        AddStategraphState("wilsonboating", state)
    end
end

local function action_tool_fn(act)
    local item = act.invobject
    if act.target and not act.pos then
		act.pos = act.target:GetPosition()
	end
    if item.components.wg_reticule then
        item.components.wg_reticule:HideReticule()
    end
    if item.components.wg_action_tool then
        if act.pos then
            act.doer:ForceFacePoint(act.pos:Get())
        end
        item.components.wg_action_tool:DoSkillEffect(act)
    end
    return true
end

local battle_cry = Action({})
battle_cry.id = "TP_BATTLE_CRY"
battle_cry.str = ""
battle_cry.fn = function(act)
    return action_tool_fn(act)
end
AddAction(battle_cry)
AddStategraphActionHandler("wilson", ActionHandler(battle_cry, "tp_battle_cry"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(battle_cry, state))

add_player_sg(State{
    name = "tp_battle_cry",
    tags = {"busy", "doing"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "multithrust_yell")
        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        TimeEvent(6*FRAMES, function(inst) 
            inst:PerformBufferedAction()
            inst.SoundEmitter:PlaySound(Sounds.attack)
        end),
        TimeEvent(0*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
        end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },
}, true)

local multi_thrust = Action({})
multi_thrust.id = "TP_MULT_THRUST"
multi_thrust.str = ""
multi_thrust.fn = action_tool_fn
AddAction(multi_thrust)
AddStategraphActionHandler("wilson", ActionHandler(multi_thrust, "tp_mult_thrust"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(multi_thrust, state))

add_player_sg(State{
    name = "tp_mult_thrust",
    tags = {"busy", "doing"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "multithrust")
        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end
        inst.components.locomotor:StopMoving()  
        inst.sg:SetTimeout(30 * FRAMES)          
    end,
    timeline =
    {
        -- TimeEvent(7 * FRAMES, function(inst)

        -- end),
        TimeEvent(9 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),
        TimeEvent(11 * FRAMES, function(inst)
            -- inst.components.combat:DoAttack(inst.sg.statemem.target) 
            inst:PerformBufferedAction()
        end),
        TimeEvent(13 * FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),
        -- TimeEvent(15 * FRAMES, function(inst) 
        --     inst.components.combat:DoAttack(inst.sg.statemem.target) 
        -- end),
        TimeEvent(17 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),
        -- TimeEvent(19 * FRAMES, function(inst)
        --     inst.components.combat:DoAttack(inst.sg.statemem.target) 
        -- end),
    },
    ontimeout = function(inst)
        inst.sg:GoToState("idle", true)
    end,
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },
})

local sail = Action({}, 3, nil, nil, 20)
sail.id = "TP_SAIL"
sail.str = "释放技能"
sail.fn = action_tool_fn
AddAction(sail)
AddStategraphActionHandler("wilson", ActionHandler(sail, "tp_sail"))
AddStategraphActionHandler("wilsonboating", ActionHandler(sail, "tp_sail"))

add_player_sg(State{
    name = "tp_sail",
    tags = {"busy", "doing"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "sail_loop")
        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        TimeEvent(0*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
        end),
        TimeEvent(4*FRAMES, function(inst) 
            inst:PerformBufferedAction()
        end),
        TimeEvent(8*FRAMES, function(inst) 
            inst.sg:RemoveStateTag("busy")
        end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },
})

local chop = Action({}, 3, nil, nil, 20)
chop.id = "TP_CHOP"
chop.str = "释放技能"
chop.fn = action_tool_fn
AddAction(chop)
AddStategraphActionHandler("wilson", ActionHandler(chop, "tp_chop_pre"))
AddStategraphActionHandler("wilsonboating", ActionHandler(chop, "tp_chop_pre"))

add_player_sg(State{
    name = "tp_chop_pre",
    tags = {"busy", "doing"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "chop_pre")

        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        -- TimeEvent(8*FRAMES, function(inst) 
        --     inst:PerformBufferedAction()
        -- end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("tp_chop") end ),
    },
})

add_player_sg(State{
    name = "tp_chop",
    tags = {"busy", "doing"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "chop_loop")
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        TimeEvent(5*FRAMES, function(inst) 
            inst:PerformBufferedAction()
        end),
        TimeEvent(16*FRAMES, function(inst) 
            inst.sg:RemoveStateTag("busy")
        end),
        TimeEvent(4*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound(Sounds.attack)
        end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },
})

local tp_chop_start = Action({}, 3, nil, nil, 20)
tp_chop_start.id = string.upper("tp_chop_start")
tp_chop_start.str = "释放技能"
tp_chop_start.fn = action_tool_fn
AddAction(tp_chop_start)
AddStategraphActionHandler("wilson", ActionHandler(tp_chop_start, "tp_chop_start"))
AddStategraphActionHandler("wilsonboating", ActionHandler(tp_chop_start, "tp_chop_start"))

add_player_sg(State{
    name = "tp_chop_start",
    tags = {"busy", "doing"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "chop_pre")

        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        TimeEvent(4*FRAMES, function(inst) 
            inst:PerformBufferedAction()
        end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },
})

local shovel = Action({}, 3, nil, nil, 20)
shovel.id = "TP_SHOVEL"
shovel.str = "释放技能"
shovel.fn = action_tool_fn
AddAction(shovel)
AddStategraphActionHandler("wilson", ActionHandler(shovel, "tp_shovel"))
AddStategraphActionHandler("wilsonboating", ActionHandler(shovel, "tp_shovel"))

add_player_sg(State{
    name = "tp_shovel",
    tags = {"busy", "doing"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "shovel_pre")
        PlayerAnimation(inst, "PushAnimation", "shovel_loop")
        PlayerAnimation(inst, "PushAnimation", "shovel_pst", false)
        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end
        inst.components.locomotor:StopMoving()         
    end,
    timeline=
    {
        TimeEvent(25*FRAMES, function(inst) 
            inst:PerformBufferedAction() 
            inst.sg:RemoveStateTag("busy") 
            inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
        end),
    },
    events=
    {
        EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
    },
})

local blowdart = Action({}, 3, nil, nil, 20)
blowdart.id = "TP_BLOWDART"
blowdart.str = "释放技能"
blowdart.fn = action_tool_fn
AddAction(blowdart)
AddStategraphActionHandler("wilson", ActionHandler(blowdart, "tp_blowdart"))
AddStategraphActionHandler("wilsonboating", ActionHandler(blowdart, "tp_blowdart"))

add_player_sg(State{
    name = "tp_blowdart",
    tags = {"busy", "doing"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "dart")
        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        TimeEvent(8*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot")
        end),
        TimeEvent(10*FRAMES, function(inst)
            inst:PerformBufferedAction()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot")
        end),
        TimeEvent(20*FRAMES, function(inst) inst.sg:RemoveStateTag("busy") end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },
})

local mine = Action({})
mine.id = "TP_MINE"
mine.str = ""
mine.fn = action_tool_fn
AddAction(mine)
AddStategraphActionHandler("wilson", ActionHandler(mine, "tp_mine_pre"))
AddStategraphActionHandler("wilsonboating", ActionHandler(mine, "tp_mine_pre"))

add_player_sg(State{
    name = "tp_mine_pre",
    tags = {"busy", "doing"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "pickaxe_pre")

        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        -- TimeEvent(8*FRAMES, function(inst) 
        --     inst:PerformBufferedAction()
        -- end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("tp_mine") end ),
    },
})

add_player_sg(State{
    name = "tp_mine",
    tags = {"busy", "doing"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "pickaxe_loop")
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        TimeEvent(12*FRAMES, function(inst) 
            inst:PerformBufferedAction()
        end),
        TimeEvent(9*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_pick_rock")
        end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },
})

local lunge = Action({}, 0, false, true, 20, nil, true)
lunge.id = "TP_LUNGE"
lunge.str = "释放技能"
lunge.fn = action_tool_fn
AddAction(lunge)
AddStategraphActionHandler("wilson", ActionHandler(lunge, "wg_lunge_pre"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(fire_lunge, "fire_lunge_pre"))

local attack_prop = Action({}, 3, nil, nil, 20)
attack_prop.id = "TP_ATTACK_PROP"
attack_prop.str = "释放技能"
attack_prop.fn = action_tool_fn
AddAction(attack_prop)
AddStategraphActionHandler("wilson", ActionHandler(attack_prop, "wg_attack_prop_pre"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(attack_prop, state))

local atk = Action({}, 3, nil, nil, 20)
atk.id = "TP_ATK"
atk.str = "释放技能"
atk.fn = action_tool_fn
AddAction(atk)
AddStategraphActionHandler("wilson", ActionHandler(atk, "tp_atk"))
AddStategraphActionHandler("wilsonboating", ActionHandler(atk, "tp_atk"))

add_player_sg(State{
    name = "tp_atk",
    tags = {"busy", "doing"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "atk")
        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        TimeEvent(8*FRAMES, function(inst) 
            inst:PerformBufferedAction()
        end),
        TimeEvent(0*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },
})

local high_jump = Action({})
high_jump.id = "TP_HIGH_JUMP"
high_jump.str = ""
high_jump.fn = action_tool_fn
AddAction(high_jump)
AddStategraphActionHandler("wilson", ActionHandler(high_jump, "high_jump"))
AddStategraphActionHandler("wilsonboating", ActionHandler(high_jump, "high_jump"))

add_player_sg(State{
    name = "high_jump",
    tags = {"doing", "busy", "not_hit_stunned"},
    onenter = function(inst, pos)
        inst.components.locomotor:Stop()
        PlayerAnimation(inst, "PlayAnimation", "jumpboat")
        inst.components.combat:AddEvadeRateMod("high_jump", 10000)
    end,
    onexit = function(inst)
        inst.components.combat:RmEvadeRateMod("high_jump")
        inst.components.locomotor:Stop()
    end,
    timeline = {
         TimeEvent(7*FRAMES, function(inst)
            inst:PerformBufferedAction()
        end),
    },
    events =
    {
        EventHandler("animover", function(inst)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            inst.sg:GoToState("high_jump_pst")
        end),
    },
})
add_player_sg(State{
    name = "high_jump_pst",
    tags = {"doing", "busy", "not_hit_stunned"},
    onenter = function(inst)
        inst.Physics:Stop()
        PlayerAnimation(inst, "PushAnimation", "land", false)
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_to_land")
        PlayFootstep(inst)
        inst.components.combat:AddEvadeRateMod("high_jump", 10000)
    end,
    onexit = function(inst)
        inst.components.combat:RmEvadeRateMod("high_jump")
    end,
    events = {
        EventHandler("animqueueover", function(inst)
            inst.sg:GoToState("idle")
        end)
    },
})

local spiral = Action({})
spiral.id = "TP_SPIRAL"
spiral.str = ""
spiral.fn = action_tool_fn
AddAction(spiral)
AddStategraphActionHandler("wilson", ActionHandler(spiral, "tp_spiral"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(spiral, state))

add_player_sg(State{
    name = "tp_spiral",
    tags = {"busy", "not_hit_stunned"},
    onenter = function(inst)
        inst.Physics:Stop()
        local ba = inst:GetBufferedAction()
        if ba and ba.pos then
            inst:ForceFacePoint(ba.pos:Get())
        end
        inst.AnimState:AddOverrideBuild("player_lunge_wargon")
        -- inst.AnimState:SetDeltaTimeMultiplier(.5)
        PlayerAnimation(inst, "PlayAnimation", "lunge_pre")
        PlayerAnimation(inst, "PushAnimation", "chop_loop", false)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw", "wg_lunge_pre")
        inst.components.combat:AddEvadeRateMod("tp_spiral", 10000)
        -- inst.sg.statemem.event_fn = EntUtil:listen_for_event(inst, 
        --     "tp_evade", function(inst, data)
        --         EntUtil:add_speed_mod(inst, "tp_spiral", .25, 5)
        --     end
        -- )
        -- inst.sg:SetTimeout(24*FRAMES)
    end,
    onexit = function(inst)
        inst.AnimState:ClearOverrideBuild("player_lunge_wargon")
        -- inst.AnimState:SetDeltaTimeMultiplier(1)
        -- inst:RemoveEventCallback("tp_evade", inst.sg.statemem.event_fn)
        inst.components.combat:RmEvadeRateMod("tp_spiral")
    end,
    timeline =
    {
        TimeEvent(17 * FRAMES, function(inst)
            inst:PerformBufferedAction()
        end),
    },
    -- ontimeout = function(inst)
    --     inst.sg:GoToState("idle")
    -- end,
    events = {
        EventHandler("animqueueover", function(inst)
            inst.sg:GoToState("idle")
        end)
    },
}, true)

local fast_lunge = Action({})
fast_lunge.id = "TP_FAST_LUNGE"
fast_lunge.str = ""
fast_lunge.fn = action_tool_fn
AddAction(fast_lunge)
AddStategraphActionHandler("wilson", ActionHandler(fast_lunge, "tp_fast_lunge"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(act, state))

AddStategraphState("wilson", State{
    name = "tp_fast_lunge",
    tags = {"doing", "busy", "canrotate", "not_hit_stunned"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        local speed = 28
        if inst:HasTag("far_lunge") then
            speed = speed + 10
        end
        inst.Physics:SetMotorVelOverride(speed, 0, 0)
        inst.AnimState:AddOverrideBuild("player_lunge_wargon")
        PlayerAnimation(inst, "PlayAnimation", "lunge_pst")
        inst:PerformBufferedAction()
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        if inst:HasTag("lunge_protect") then
            inst.components.health:SetInvincible(true, "wg_lunge")
        end
        ChangeToGhostPhysics(inst)
    end,
    timeline =
    {
        TimeEvent(7* FRAMES, function(inst)
            inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end),
    },
    events =
    {
        EventHandler("animover", function(inst)
            inst.AnimState:ClearOverrideBuild("player_lunge_wargon")
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
    onexit = function(inst)
        inst.Physics:ClearMotorVelOverride()
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        if inst:HasTag("lunge_protect") then
            inst.components.health:SetInvincible(nil, "wg_lunge")
        end
        ChangeToCharacterPhysics(inst)
    end,
})

AddStategraphState("wilson", State{
    name = "tp_lunge_gungnir_pre",
    tags = {"busy", "not_hit_stunned"},
    onenter = function(inst)
        inst.Physics:Stop()
        local ba = inst:GetBufferedAction()
        if ba and ba.pos then
            inst:ForceFacePoint(ba.pos:Get())
        end
        inst.AnimState:AddOverrideBuild("player_lunge_wargon")
        PlayerAnimation(inst, "PlayAnimation", "lunge_pre")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw", "wg_lunge_pre")
    end,
    timeline =
    {
        TimeEvent(12 * FRAMES, function(inst)
            inst.sg:GoToState('tp_lunge_gungnir')
        end),
    },
    events =
    {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
})
AddStategraphState("wilson", State{
    name = "tp_lunge_gungnir",
    tags = {"doing", "busy", "canrotate", "not_hit_stunned"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        local speed = 28
        if inst:HasTag("far_lunge") then
            speed = speed + 10
        end
        inst.Physics:SetMotorVelOverride(speed, 0, 0)
        PlayerAnimation(inst, "PlayAnimation", "lunge_pst")
        inst:PerformBufferedAction()
        inst.SoundEmitter:KillSound("wg_lunge_pre")
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        if inst:HasTag("lunge_protect") then
            inst.components.health:SetInvincible(true, "wg_lunge")
        end
        ChangeToGhostPhysics(inst)
    end,
    timeline =
    {
        TimeEvent(7* FRAMES, function(inst)
            inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end),
    },
    events =
    {
        EventHandler("animover", function(inst)
            -- inst.AnimState:ClearOverrideBuild("player_lunge_wargon")
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("tp_lunge_gungnir_next")
            end
        end),
    },
    onexit = function(inst)
        inst.Physics:ClearMotorVelOverride()
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        if inst:HasTag("lunge_protect") then
            inst.components.health:SetInvincible(nil, "wg_lunge")
        end
        ChangeToCharacterPhysics(inst)
        local weapon = inst.components.combat:GetWeapon()
        if weapon then
            weapon:PushEvent("weapon_stop_lunge", {owner=inst})
        end
        inst:PushEvent("stop_lunge", {weapon=weapon})
    end,
})
AddStategraphState("wilson", State{
    name = "tp_lunge_gungnir_next",
    tags = {"doing", "busy", "canrotate", "not_hit_stunned"},
    onenter = function(inst)
        local weapon = inst.components.combat:GetWeapon()
        if weapon then
            weapon:next_lunge()
        else
            inst.sg:GoToState("idle")
        end

        inst.components.locomotor:Stop()
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        local speed = 28
        if inst:HasTag("far_lunge") then
            speed = speed + 10
        end
        inst.Physics:SetMotorVelOverride(speed, 0, 0)
        PlayerAnimation(inst, "PlayAnimation", "lunge_pst")
        -- inst:PerformBufferedAction()

        inst.SoundEmitter:KillSound("wg_lunge_pre")
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        if inst:HasTag("lunge_protect") then
            inst.components.health:SetInvincible(true, "wg_lunge")
        end
        ChangeToGhostPhysics(inst)
    end,
    timeline =
    {
        TimeEvent(7* FRAMES, function(inst)
            inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end),
    },
    events =
    {
        EventHandler("animover", function(inst)
            local weapon = inst.components.combat:GetWeapon()
            if weapon and weapon:can_next_lunge() then
                inst.sg:GoToState('tp_lunge_gungnir_next')
            else
                inst.AnimState:ClearOverrideBuild("player_lunge_wargon")
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end
        end),
    },
    onexit = function(inst)
        inst.Physics:ClearMotorVelOverride()
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        if inst:HasTag("lunge_protect") then
            inst.components.health:SetInvincible(nil, "wg_lunge")
        end
        ChangeToCharacterPhysics(inst)
        local weapon = inst.components.combat:GetWeapon()
        if weapon then
            weapon:PushEvent("weapon_stop_lunge", {owner=inst})
        end
        inst:PushEvent("stop_lunge", {weapon=weapon})
    end,
})
local tp_lunge_gungnir = Action({}, 0, false, true, 20, nil, true)
tp_lunge_gungnir.id = string.upper("tp_lunge_gungnir")
tp_lunge_gungnir.str = "释放技能"
tp_lunge_gungnir.fn = action_tool_fn
AddAction(tp_lunge_gungnir)
AddStategraphActionHandler("wilson", ActionHandler(tp_lunge_gungnir, "tp_lunge_gungnir_pre"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(tp_lunge_gungnir, ""))


local helm_jarvaniv = Action({})
helm_jarvaniv.id = "TP_HELM_JARVANIV"
helm_jarvaniv.str = "释放技能"
helm_jarvaniv.fn = action_tool_fn
AddAction(helm_jarvaniv)
AddStategraphActionHandler("wilson", ActionHandler(helm_jarvaniv, "tp_helm_jarvaniv"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(act, state))

AddStategraphState("wilson", State{
    name = "tp_helm_jarvaniv",
    tags = {"doing", "busy", "canrotate", "not_hit_stunned"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        -- inst.AnimState:AddOverrideBuild("player_lunge_wargon")
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        -- PlayerAnimation(inst, "PlayAnimation", "lunge_pst")
        PlayerAnimation(inst, "PlayAnimation", "atk")
        inst.sg:SetTimeout(.4+8*FRAMES)
    end,
    timeline =
    {
        TimeEvent(8*FRAMES, function(inst)
            inst.AnimState:SetPercent("atk", .4)
            local ba = inst:GetBufferedAction()
            if ba then
                local pos = ba.target:GetPosition()
                inst:ForceFacePoint(pos:Get())
                local pos2 = inst:GetPosition()
                local dx, dz = pos.x-pos2.x, pos.z-pos2.z
                local dist_sq = (dx*dx)+(dz*dz)
                local dist = math.sqrt(dist_sq)
                -- local speed = dist / (7*FRAMES)
                local speed = dist / (.4)
                inst.Physics:SetMotorVelOverride(1 * speed, 0, 0)
            end
            inst:PerformBufferedAction()
            ChangeToGhostPhysics(inst)
        end),
        TimeEvent(.4+8*FRAMES, function(inst)
            inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end),
    },
    -- events =
    -- {
    --     EventHandler("animover", function(inst)
    --         -- inst.AnimState:ClearOverrideBuild("player_lunge_wargon")
    --         if inst.AnimState:AnimDone() then
    --             inst.sg:GoToState("idle")
    --         end
    --     end),
    -- },
    ontimeout = function(inst)
        inst.sg:GoToState("idle")
    end,
    onexit = function(inst)
        inst.Physics:ClearMotorVelOverride()
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        ChangeToCharacterPhysics(inst)
    end,
})

local spear_monk = Action({})
spear_monk.id = "TP_SPEAR_MONK"
spear_monk.str = ""
spear_monk.fn = action_tool_fn
AddAction(spear_monk)
AddStategraphActionHandler("wilson", ActionHandler(spear_monk, "tp_spear_monk"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(act, state))

AddStategraphState("wilson", State{
    name = "tp_spear_monk",
    tags = {"busy", "evade","no_stun", "doing", "not_hit_stunned"},
    onenter =   function(inst)
        -- EntUtil:add_tag(inst, "tp_not_freezable")
        -- inst.components.health:SetInvincible(true, "wg_dodge")
        inst.components.locomotor:Stop()
        PlayerAnimation(inst, "PlayAnimation", "slide_loop")
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.target:GetPosition()
            inst:ForceFacePoint(pos:Get())
            local dist = inst:GetPosition():Dist(pos)
            local time = dist/30
            inst.sg:SetTimeout(time)
            inst.Physics:SetMotorVelOverride(30, 0, 0)
        end
        ChangeToGhostPhysics(inst)
    end,
    ontimeout = function(inst)
        inst:PerformBufferedAction()
        inst.sg:GoToState("idle")
    end,
    onexit = function(inst)
        -- EntUtil:remove_tag(inst, "tp_not_freezable")
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        inst.Physics:ClearMotorVelOverride()
        inst.components.locomotor:Stop()
        inst.components.locomotor:SetBufferedAction(nil)
        -- inst.components.health:SetInvincible(nil, "wg_dodge")
        ChangeToCharacterPhysics(inst)
    end,
})

local armor_monk = Action({}, 3, nil, nil, 10)
armor_monk.id = "TP_ARMOR_MONK"
armor_monk.str = ""
armor_monk.fn = action_tool_fn
AddAction(armor_monk)
AddStategraphActionHandler("wilson", ActionHandler(armor_monk, "tp_armor_monk"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(act, state))

AddStategraphState("wilson", State{
    name = "tp_armor_monk",
    tags = {"busy", "doing", "canrotate", "not_hit_stunned"},
    onenter =   function(inst)
        -- EntUtil:add_tag(inst, "tp_not_freezable")
        -- inst.components.health:SetInvincible(true, "wg_dodge")
        inst.components.locomotor:Stop()
        inst.AnimState:SetPercent("atk_leap_pre", .9)
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        local ba = inst:GetBufferedAction()
        if ba and ba.target ~= inst then
            local pos = ba.target:GetPosition()
            inst:ForceFacePoint(pos:Get())
            local dist = inst:GetPosition():Dist(pos)
            local time = dist/30
            inst.sg:SetTimeout(time)
            inst.Physics:SetMotorVelOverride(30, 0, 0)
        else
            inst.sg:SetTimeout(5*FRAMES)
        end
        ChangeToGhostPhysics(inst)
    end,
    ontimeout = function(inst)
        inst:PerformBufferedAction()
        inst.sg:GoToState("idle")
    end,
    onexit = function(inst)
        -- EntUtil:remove_tag(inst, "tp_not_freezable")
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        inst.Physics:ClearMotorVelOverride()
        inst.components.locomotor:Stop()
        inst.components.locomotor:SetBufferedAction(nil)
        -- inst.components.health:SetInvincible(nil, "wg_dodge")
        ChangeToCharacterPhysics(inst)
    end,
})

local spear_zed = Action({}, 3, nil, nil, 20)
spear_zed.id = "TP_SPEAR_ZED"
spear_zed.str = "释放技能"
spear_zed.fn = action_tool_fn
AddAction(spear_zed)
AddStategraphActionHandler("wilson", ActionHandler(spear_zed, "tp_spear_zed"))
AddStategraphActionHandler("wilsonboating", ActionHandler(spear_zed, "tp_spear_zed"))

add_player_sg(State{
    name = "tp_spear_zed",
    tags = {"busy", "doing"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "atk")
        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
                local armor = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
                if armor and armor.fx then
                    armor.fx.AnimState:PlayAnimation("atk")
                    armor.fx.AnimState:PushAnimation("idle_loop")
                    armor.fx:ForceFacePoint(pos:Get())
                end
            end
        end
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        TimeEvent(8*FRAMES, function(inst) 
            inst:PerformBufferedAction()
        end),
        TimeEvent(0*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },
})

local spear_jax = Action({}, 3, nil, nil, 12)
spear_jax.id = "TP_SPEAR_JAX"
spear_jax.str = "释放技能"
spear_jax.fn = action_tool_fn
AddAction(spear_jax)
AddStategraphActionHandler("wilson", ActionHandler(spear_jax, "tp_spear_jax"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(spear_jax, "tp_spear_jax"))

AddStategraphState("wilson", State{
    name = "tp_spear_jax",
    tags = {"doing", "busy", "canrotate", "not_hit_stunned"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        PlayerAnimation(inst, "PlayAnimation", "atk_leap_pre")
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        inst.components.playercontroller:Enable(false)
        inst.sg:SetTimeout(4*FRAMES)
    end,

    onexit = function(inst)
    end,

    timeline =
    {
    },

    events =
    {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("tp_spear_jax_pst")
        end),
    },
    ontimeout = function(inst)
        inst.sg:GoToState("tp_spear_jax_pst")
    end,
})

AddStategraphState("wilson", State{
    name = "tp_spear_jax_pst",
    tags = {"doing", "busy", "canrotate", "not_hit_stunned"},

    onenter = function(inst)
        local ba = inst:GetBufferedAction()
        inst.sg.statemem.startpos = inst:GetPosition()
        inst.sg.statemem.targetpos = inst:GetPosition()
        if ba and ba.pos then
            inst.sg.statemem.targetpos = ba.pos
        elseif ba and ba.target then
            inst.sg.statemem.targetpos = ba.target:GetPosition()
        end
        RemovePhysicsColliders(inst)
        inst.components.playercontroller:Enable(false)

        -- PlayerAnimation(inst, "PushAnimation", "land", false)
        inst.AnimState:SetDeltaTimeMultiplier(1.5)
        PlayerAnimation(inst, "PlayAnimation", "atk_leap")
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_to_land")
        PlayFootstep(inst)
        inst.sg:SetTimeout(20*FRAMES)
    end,

    timeline =
    {
        TimeEvent(0*FRAMES, function(inst)
            inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
            local dist = inst:GetPosition():Dist(inst.sg.statemem.targetpos)
            local speed = dist / (9/30)
            inst.Physics:SetMotorVelOverride(1 * speed, 0, 0)
        end),
        TimeEvent(8 * FRAMES, function(inst)
            inst:PerformBufferedAction()
            ChangeToCharacterPhysics(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end),
    },

    ontimeout = function(inst)
        -- inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
        inst.Physics:Stop()
        inst.sg:GoToState("idle")
    end,

    onexit = function(inst)
        -- inst.components.health:SetInvincible(true)
        inst.Physics:Stop()
        inst.components.playercontroller:Enable(true)
        inst.AnimState:SetDeltaTimeMultiplier(1)
    end,

    events =
    {
        -- EventHandler("animover", function(inst)
        --     inst.sg:GoToState("idle")
        -- end),
    },
})

local spear_darius = Action({})
spear_darius.id = "TP_SPEAR_DARIUS"
spear_darius.str = "释放技能"
spear_darius.fn = action_tool_fn
AddAction(spear_darius)
AddStategraphActionHandler("wilson", ActionHandler(spear_darius, "tp_spear_darius"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(spear_darius, "tp_spear_darius"))

add_player_sg(State{
    name = "tp_spear_darius",
    tags = {"doing", "busy", "canrotate", "not_hit_stunned"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "multithrust_yell")
        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end
        inst.components.locomotor:StopMoving()      
    end,
    timeline = {
        TimeEvent(6*FRAMES, function(inst) 
            -- inst:PerformBufferedAction()
            inst.SoundEmitter:PlaySound(Sounds.attack)
        end),
        TimeEvent(0*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
        end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("tp_spear_darius2") end ),
    },
}, true)

add_player_sg(State{
    name = "tp_spear_darius2",
    tags = {"doing", "busy", "canrotate", "not_hit_stunned"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "chop_pre")
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        -- TimeEvent(8*FRAMES, function(inst) 
        --     inst:PerformBufferedAction()
        -- end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("tp_spear_darius_pst") end ),
    },
}, true)

AddStategraphState("wilson", State{
    name = "tp_spear_darius_pst",
    tags = {"doing", "busy", "not_hit_stunned"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        -- PlayerAnimation(inst, "PlayAnimation", "chop_loop")
        inst.AnimState:SetPercent("chop_loop", 1-.9)
        inst.sg:SetTimeout(12*FRAMES)
        local rot = inst.Transform:GetRotation()
        inst.sg.statemem.rot = rot
        local m = 12
        local rad = 4
        local pos = inst:GetPosition()
        for i = 0, m-1 do
            inst:DoTaskInTime(FRAMES*i, function()
                local angle = (-rot+360/m*i)*DEGREES
                local x = math.cos(angle)*rad
                local z = math.sin(angle)*rad
                local fx = FxManager:MakeFx("dragoon_charge_fx", pos+Vector3(x,0,z))
            end)
        end
    end,
    timeline = {
        TimeEvent(0*FRAMES, function(inst)
            inst.Transform:SetRotation(inst.sg.statemem.rot+0)
        end),
        TimeEvent(3*FRAMES, function(inst)
            inst.Transform:SetRotation(inst.sg.statemem.rot+90)
        end),
        TimeEvent(6*FRAMES, function(inst)
            inst.Transform:SetRotation(inst.sg.statemem.rot+180)
        end),
        TimeEvent(9*FRAMES, function(inst)
            inst.Transform:SetRotation(inst.sg.statemem.rot+270)
        end),
        TimeEvent(3*FRAMES, function(inst)
            inst:PerformBufferedAction()
        end),
    },
    events =
    {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
    ontimeout = function(inst)
        inst.sg:GoToState("idle")
    end,
})

local helm_garen = Action({})
helm_garen.id = "TP_HELM_GAREN"
helm_garen.str = "释放技能"
helm_garen.fn = action_tool_fn
AddAction(helm_garen)
AddStategraphActionHandler("wilson", ActionHandler(helm_garen, "tp_helm_garen"))
AddStategraphActionHandler("wilsonboating", ActionHandler(helm_garen, "tp_helm_garen"))

add_player_sg(State{
    name = "tp_helm_garen",
    tags = {"doing", "busy", "canrotate", "not_hit_stunned"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "chop_pre")
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        TimeEvent(1*FRAMES, function(inst) 
            inst:PerformBufferedAction()
        end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("tp_helm_garen_loop") end ),
    },
})

add_player_sg(State{
    name = "tp_helm_garen_loop",
    tags = {"doing", "busy", "canrotate", "not_hit_stunned"},
    onenter = function(inst)
        -- inst.components.locomotor:Stop()
        -- PlayerAnimation(inst, "PlayAnimation", "chop_loop")
        inst.AnimState:SetPercent("chop_loop", 1-.9)
        inst.sg:SetTimeout(12*FRAMES)
        local rot = inst.Transform:GetRotation()
        inst.sg.statemem.rot = rot
    end,
    timeline = {
        TimeEvent(0*FRAMES, function(inst)
            local spear = inst.components.combat:GetWeapon()
            EntUtil:make_area_dmg(inst, 3.5, inst, 20, spear, nil, {
                mult = .4,
            })
        end),
        TimeEvent(0*FRAMES, function(inst)
            inst.Transform:SetRotation(inst.sg.statemem.rot+0)
        end),
        TimeEvent(2*FRAMES, function(inst)
            inst.Transform:SetRotation(inst.sg.statemem.rot+90)
        end),
        TimeEvent(4*FRAMES, function(inst)
            inst.Transform:SetRotation(inst.sg.statemem.rot+180)
        end),
        TimeEvent(8*FRAMES, function(inst)
            inst.Transform:SetRotation(inst.sg.statemem.rot+270)
        end),
    },
    events =
    {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
    ontimeout = function(inst)
        local helm = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if helm and helm.prefab == "tp_helm_garen" 
        and not helm.components.tp_equip_value:IsEmpty() then
            inst.sg:GoToState("tp_helm_garen_loop")
        else
            inst.sg:GoToState("idle")
        end
    end,
})

local smear = Action({})
smear.id = "TP_SMEAR"
smear.str = "涂抹"
smear.fn = function(act)
    if act.target and act.invobject and act.doer then
        if act.target.components.tp_smearable then
            act.target.components.tp_smearable:SmearItem(act.invobject, act.doer)
            return true
        end
    end
end
AddAction(smear)
AddStategraphActionHandler("wilson", ActionHandler(smear, "give"))
AddStategraphActionHandler("wilsonboating", ActionHandler(smear, "give"))

AddPrefabPostInit("tp_recover_bottle", function(inst)
    inst.components["tp_recover_bottle"] = {
        inst = inst,
        CollectSceneActions = function(self, doer, actions, right) end,
        CollectUseActions = function(self, doer, useitem, actions, right) end,
        CollectPointActions = function(self, doer, pos, actions, right) end,
        CollectEquippedActions = function(self, doer, target, actions, right) end,
        CollectInventoryActions = function(self, doer, actions, right) 
            if self.inst.components.finiteuses:GetUses()>0 then
                table.insert(actions, ACTIONS.TP_RECOVER_BOTTLE)
            end
        end,
    }
end)

local tp_recover_bottle = Action({})
tp_recover_bottle.id = string.upper("tp_recover_bottle")
tp_recover_bottle.str = "饮用"
tp_recover_bottle.fn = function(act)
    if act.doer and act.invobject then
        act.invobject:use(act.doer)
        return true
    end
end
AddAction(tp_recover_bottle)
AddStategraphActionHandler("wilson", ActionHandler(tp_recover_bottle, "tp_recover_bottle"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(tp_recover_bottle, state))

add_player_sg(State{
    name = "tp_recover_bottle",
    tags = {"doing", "busy"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "eat")
        
        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end
        inst.components.locomotor:StopMoving()            
    end,
    timeline={
        TimeEvent(0*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating") 
        end),
        TimeEvent(28*FRAMES, function(inst) 
            inst:PerformBufferedAction() 
        end),
    },
    onexit= function(inst)
        inst.SoundEmitter:KillSound("eating")    
    end,
    events={
        EventHandler("animover", function(inst) 
            inst.sg:GoToState("idle") 
        end ),
    },
})

local tp_read_scroll = Action({})
tp_read_scroll.id = string.upper("tp_read_scroll")
tp_read_scroll.str = "阅读"
tp_read_scroll.fn = function(act)
end
AddAction(tp_read_scroll)
AddStategraphActionHandler("wilson", ActionHandler(tp_read_scroll, "tp_read_scroll"))
AddStategraphActionHandler("wilsonboating", ActionHandler(tp_read_scroll, "tp_read_scroll"))

local tp_scroll_weapon = Action({}, 3, nil, nil, 20)
tp_scroll_weapon.id = string.upper("tp_scroll_weapon")
tp_scroll_weapon.str = "释放技能"
tp_scroll_weapon.fn = action_tool_fn
AddAction(tp_scroll_weapon)
AddStategraphActionHandler("wilson", ActionHandler(tp_scroll_weapon, "tp_read_scroll"))
AddStategraphActionHandler("wilsonboating", ActionHandler(tp_scroll_weapon, "tp_read_scroll"))

local state = State{
    name = "tp_read_scroll",
    tags = {"doing", "busy"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        PlayerAnimation(inst, "PlayAnimation", "scroll", false)
        PlayerAnimation(inst,"OverrideSymbol", "scroll", "messagebottle", "scroll")
        PlayerAnimation(inst,"PushAnimation","scroll_pst", false)
        
        --PlayerAnimation(inst,"Hide","ARM_carry") 
        PlayerAnimation(inst,"Show","ARM_normal")
        if inst.components.inventory.activeitem and inst.components.inventory.activeitem.components.book then
            inst.components.inventory:ReturnActiveItem()
        end
        PlayerAnimation(inst, "SetDeltaTimeMultiplier", 2.5)

    end,
    onexit = function(inst)
        if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and not inst.were then
            PlayerAnimation(inst,"Show","ARM_carry") 
            PlayerAnimation(inst,"Hide","ARM_normal")
        end
        PlayerAnimation(inst, "SetDeltaTimeMultiplier", 1)
    end,
    timeline=
    {
        TimeEvent(24/2*FRAMES, function(inst) 
            PlayerAnimation(inst, "SetDeltaTimeMultiplier", 3.5)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/treasuremap_open") 
        end),
        TimeEvent(58/2*FRAMES, function(inst) 
            PlayerAnimation(inst, "SetDeltaTimeMultiplier", 2.5)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/treasuremap_close") 
        end),
    },
    events=
    {
        EventHandler("animover", function(inst)
            inst:PerformBufferedAction()
        end),
        EventHandler("animqueueover", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
}
AddStategraphState("wilson", state)
AddStategraphState("wilsonboating", state)

local state = State{
    name = "tp_lunge_pre",
    tags = {"busy", "doing", "not_hit_stunned"},
    onenter = function(inst)
        inst.Physics:Stop()
        local ba = inst:GetBufferedAction()
        if ba and ba.pos then
            inst:ForceFacePoint(ba.pos:Get())
        end
        inst.AnimState:AddOverrideBuild("player_lunge_wargon")
        PlayerAnimation(inst, "PlayAnimation", "lunge_pre")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw", "wg_lunge_pre")
    end,
    timeline={
        TimeEvent(5*FRAMES, function(inst)
            inst:PerformBufferedAction()
        end)
    },
    events={
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end ),
    },
}
AddStategraphState("wilson", state)
AddStategraphState("wilsonboating", state)

local tp_lunge_pre = Action({}, 3, nil, nil, 20)
tp_lunge_pre.id = string.upper("tp_lunge_pre")
tp_lunge_pre.str = "释放技能"
tp_lunge_pre.fn = action_tool_fn
AddAction(tp_lunge_pre)
AddStategraphActionHandler("wilson", ActionHandler(tp_lunge_pre, "tp_lunge_pre"))
AddStategraphActionHandler("wilsonboating", ActionHandler(tp_lunge_pre, "tp_lunge_pre"))

AddStategraphState("wilson", State{
    name = "tp_multithrust_pre",
    tags = {"busy", "doing"},       
    onenter = function(inst)
        PlayerAnimation(inst, "PlayAnimation", "multithrust_yell")

        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        -- TimeEvent(8*FRAMES, function(inst) 
        --     inst:PerformBufferedAction()
        -- end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("tp_multithrust") end ),
    },
})
AddStategraphState("wilson", State{
    name = "tp_multithrust",
    tags = { "doing", "busy", },
    onenter = function(inst, target)
        PlayerAnimation(inst, "PlayAnimation", "multithrust")
        inst.components.locomotor:Stop()

        inst.sg:SetTimeout(30 * FRAMES)
        inst:AddTag("tp_multithrust")
        inst.components.health:SetInvincible(true, "tp_multithrust")
    end,
    timeline =
    {
        TimeEvent(7 * FRAMES, function(inst)
        end),
        TimeEvent(9 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),
        TimeEvent(11 * FRAMES, function(inst)
            inst:PerformBufferedAction()
            -- inst.components.combat:DoAttack(inst.sg.statemem.target) 
        end),
        TimeEvent(13 * FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),
        TimeEvent(15 * FRAMES, function(inst) 
            -- inst.components.combat:DoAttack(inst.sg.statemem.target) 
        end),
        TimeEvent(17 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),
        TimeEvent(19 * FRAMES, function(inst)
            -- inst.components.combat:DoAttack(inst.sg.statemem.target) 
        end),
    },
    ontimeout = function(inst)
        inst.sg:GoToState("idle", true)
    end,
    events =
    {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
    onexit = function(inst)
        inst:RemoveTag("tp_multithrust")
        inst.components.health:SetInvincible(nil, "tp_multithrust")

    end,
})
local tp_mult_thrust = Action({})
tp_mult_thrust.id = string.upper("tp_mult_thrust")
tp_mult_thrust.str = "释放技能"
tp_mult_thrust.fn = action_tool_fn
AddAction(tp_mult_thrust)
AddStategraphActionHandler("wilson", ActionHandler(tp_mult_thrust, "tp_multithrust_pre"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(tp_mult_thrust, ""))


AddStategraphState("wilson", State{
    name = "tp_parry_pre",
    tags = { "preparrying", "busy", "doing", },
    onenter = function(inst)
        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end
        inst.components.locomotor:Stop()
        PlayerAnimation(inst, "PlayAnimation", "parry_pre")
    end,
    onexit = function(inst)
        inst.components.health:SetInvincible(nil, "tp_parry")
    end,
    timeline = {
        TimeEvent(1*FRAMES, function(inst)
            if inst:HasTag("tp_parry_protect") then
                inst.components.health:SetInvincible(true, "tp_parry")
            end
        end),
    },
    events =
    {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("tp_parry")
            end
        end),
    },
})
AddStategraphState("wilson", State{
    name = "tp_parry",
    tags = { "parrying", "busy", "doing" },
    onenter = function(inst)
        inst.components.locomotor:Stop()
        -- inst.AnimState:PlayAnimation("parry_loop", true)
        PlayerAnimation(inst, "PlayAnimation", "parry_loop")
        inst.sg:SetTimeout(.55)
        inst:PerformBufferedAction()
        if inst:HasTag("tp_parry_protect") then
            inst.components.health:SetInvincible(true, "tp_parry")
        end
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/items/weapon/halberd")
    end,
    ontimeout = function(inst)
        inst.sg:GoToState("tp_parry_pst")
    end,
    events =
    {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
    onexit = function(inst)
        inst.components.health:SetInvincible(nil, "tp_parry")
    end,
})
AddStategraphState("wilson", State{
    name = "tp_parry_pst",
    tags = { "parryingpst", "busy", "doing" },
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("parry_pst")
        if inst:HasTag("tp_parry_protect") then
            inst.components.health:SetInvincible(true, "tp_parry")
        end
    end,
    timeline = {
        TimeEvent(8*FRAMES, function(inst)
            inst.components.health:SetInvincible(nil, "tp_parry")
        end),
    },
    events =
    {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
    onexit = function(inst)
        inst.components.health:SetInvincible(nil, "tp_parry")
    end,
})
local tp_parry = Action({})
tp_parry.id = string.upper("tp_parry")
tp_parry.str = "释放技能"
tp_parry.fn = action_tool_fn
AddAction(tp_parry)
AddStategraphActionHandler("wilson", ActionHandler(tp_parry, "tp_parray_pre"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(tp_parry, "tp_parry_pre"))


AddStategraphState("wilson", State{
    name = "tp_attack_leap_pre",
    tags = {"doing", "busy", "canrotate"},
    onenter = function(inst)
        local ba = inst:GetBufferedAction()
        if ba then
            local pos = ba.pos or (ba.target and ba.target:GetPosition())
            if pos then
                inst:ForceFacePoint(pos:Get())
            end
        end

        inst.components.locomotor:Stop()
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        inst.components.playercontroller:Enable(false)
        
        inst.AnimState:AddOverrideBuild("player_attack_leap_wargon")
        -- inst.AnimState:PlayAnimation("atk_leap_pre")
        PlayerAnimation(inst, "PlayAnimation", "atk_leap_pre")
        
        inst.sg:SetTimeout(8*FRAMES)
        inst.components.health:SetInvincible(true, "tp_attack_leap")
    end,
    onexit = function(inst)
        inst.components.health:SetInvincible(false, "tp_attack_leap")
    end,
    timeline =
    {
        TimeEvent(0*FRAMES, function(inst)
        end),
    },
    events =
    {
        EventHandler("animover", function(inst)
            inst.components.health:SetInvincible(false, "tp_attack_leap")
            inst.sg:GoToState("tp_attack_leap_pst")
        end),
    },
    ontimeout = function(inst)
        inst.components.health:SetInvincible(false, "tp_attack_leap")
        inst.sg:GoToState("tp_attack_leap")
    end,
})
AddStategraphState("wilson", State{
    name = "tp_attack_leap",
    tags = {"doing", "busy", "canrotate"},
    onenter = function(inst)
        local ba = inst:GetBufferedAction()
        inst.sg.statemem.startpos = inst:GetPosition()
        inst.sg.statemem.targetpos = inst:GetPosition()
        if ba and ba.pos then
            inst.sg.statemem.targetpos = ba.pos
        elseif ba and ba.target then
            inst.sg.statemem.targetpos = ba.target:GetPosition()
        end
        RemovePhysicsColliders(inst)
        inst.components.playercontroller:Enable(false)
        
        -- inst.AnimState:PlayAnimation("atk_leap")
        PlayerAnimation(inst, "PlayAnimation", "atk_leap")
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_to_land")
        PlayFootstep(inst)
        
        inst.sg:SetTimeout(30*FRAMES)
        inst.components.health:SetInvincible(true, "tp_attack_leap")
    end,
    timeline =
    {
        TimeEvent(0*FRAMES, function(inst)
            inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
            local dist = inst:GetPosition():Dist(inst.sg.statemem.targetpos)
            local speed = dist / (13/30)
            inst.Physics:SetMotorVelOverride(1 * speed, 0, 0)
        end),
        TimeEvent(13 * FRAMES, function(inst)
            inst:PerformBufferedAction()
            ChangeToCharacterPhysics(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end),
    },
    ontimeout = function(inst)
        inst.Physics:Stop()
        inst.components.health:SetInvincible(false, "tp_attack_leap")
        inst.sg:GoToState("idle")
    end,
    onexit = function(inst)
        inst.Physics:Stop()
        inst.components.health:SetInvincible(false, "tp_attack_leap")
        inst.components.playercontroller:Enable(true)
        inst.AnimState:ClearOverrideBuild("player_attack_leap_wargon")
    end,
    events =
    {
    },
})
local tp_attack_leap = Action({}, 3, nil, nil, 20)
tp_attack_leap.id = string.upper("tp_attack_leap")
tp_attack_leap.str = "释放技能"
tp_attack_leap.fn = action_tool_fn
AddAction(tp_attack_leap)
AddStategraphActionHandler("wilson", ActionHandler(tp_attack_leap, "tp_attack_leap_pre"))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(tp_attack_leap, "tp_attack_leap_pre"))

add_player_sg(State{
    name = "tp_cast_spell",
    tags = {"doing", "busy", "canrotate", "spell"},

    onenter = function(inst)
        inst.AnimState:PlayAnimation("staff") 
        local colourizefx = function(staff)
            return {1,1,1}
        end
        inst.components.locomotor:Stop()
        --Spawn an effect on the player's location
        inst.stafffx = SpawnPrefab("staffcastfx")            

        local pos = inst:GetPosition()
        inst.stafffx.Transform:SetPosition(pos.x, pos.y, pos.z)
        local colour = colourizefx()

        inst.stafffx.Transform:SetRotation(inst.Transform:GetRotation())
        inst.stafffx.AnimState:SetMultColour(colour[1], colour[2], colour[3], 1)
        -- inst.components.health:SetInvincible(true, "castspell")
    end,

    onexit = function(inst)
        -- inst.components.health:SetInvincible(nil, "castspell")
        if inst.stafffx then
            inst.stafffx:Remove()
        end
    end,

    timeline = 
    {
        TimeEvent(13*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_gemstaff") 
            inst:PerformBufferedAction()
        end),
        TimeEvent(0*FRAMES, function(inst)
            inst.stafflight = SpawnPrefab("staff_castinglight")
            local pos = inst:GetPosition()
            local colour = {1,1,1}
            inst.stafflight.Transform:SetPosition(pos.x, pos.y, pos.z)
            inst.stafflight.setupfn(inst.stafflight, colour, 1.9, .33)                
        end),
        TimeEvent(53*FRAMES, function(inst)  
        end),
        TimeEvent(60*FRAMES, function(inst) 
        end),            
    },
    events = {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle") 
        end ),
    },
})
local tp_cast_spell = Action({}, 3, nil, nil, 20)
tp_cast_spell.id = string.upper("tp_cast_spell")
tp_cast_spell.str = "释放技能"
tp_cast_spell.fn = action_tool_fn
AddAction(tp_cast_spell)
AddStategraphActionHandler("wilson", ActionHandler(tp_cast_spell, "tp_cast_spell"))
AddStategraphActionHandler("wilsonboating", ActionHandler(tp_cast_spell, "tp_cast_spell"))