local Sounds = require "extension/datas/sounds"
local EntUtil = require "extension.lib.ent_util"

local function PlayerAnimation(inst, fname, ...)
    inst.AnimState[fname](inst.AnimState, ...)
    if inst.tp_fx then
        inst.tp_fx.Transform:SetRotation(inst.Transform:GetRotation())
        inst.tp_fx.AnimState[fname](inst.tp_fx.AnimState, ...)
    end
end

local function add_player_sg(state)
    AddStategraphState("wilson", state)
    AddStategraphState("wilsonboating", state)
end


--[[ 投掷 ]]
STRINGS.WG_PROJECT = "投掷"
local project = Action({},2, false, true, 20, true)
project.id = "WG_PROJECT"
project.str = STRINGS.WG_PROJECT
project.fn = function(act)
	if act.target.components.combat and act.doer.components.inventory then
		local item = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if item and item.components.weapon and item.components.wg_projectile then
			local projectile = act.doer.components.inventory:DropItem(item, false, nil, nil, true) 
			if projectile then
				projectile.components.wg_projectile:Throw(act.doer, act.target, act.doer)
				if projectile.components.finiteuses then
					projectile.components.finiteuses:Use()
				end
			end
			return true
		end
	end
end
AddAction(project)
AddStategraphActionHandler("wilson", ActionHandler(project, "wg_project"))
AddStategraphActionHandler("wilsonboating", ActionHandler(project, "wg_project"))

add_player_sg(State{
    name = "wg_project",
    tags = {"busy"},
    onenter = function(inst)
        -- 面向目标
        local ba = inst:GetBufferedAction()
        if ba and ba.target then
            inst:ForceFacePoint(ba.target:GetPosition():Get())
        end
        PlayerAnimation(inst, "PlayAnimation", "atk")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
    end,
    events={
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
    timeline={
        TimeEvent(8*FRAMES, function(inst)
            inst:PerformBufferedAction()
        end),
        TimeEvent(12*FRAMES, function(inst) 
            inst.sg:RemoveStateTag("busy")
        end),   
    },
})

--[[ 突刺，未设置动作 ]]

AddStategraphState("wilson", State{
    name = "wg_lunge_pre",
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
            inst.sg:GoToState('wg_lunge')
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
    name = "wg_lunge",
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
        local weapon = inst.components.combat:GetWeapon()
        if weapon then
            weapon:PushEvent("weapon_stop_lunge", {owner=inst})
        end
        inst:PushEvent("stop_lunge", {weapon=weapon})
    end,
})

--[[ 横扫，未设置动作 ]]
add_player_sg(State{
    name = "wg_attack_prop_pre",
    tags = { "propattack", "doing", "busy", "notalking" },

    onenter = function(inst)
        local ba = inst:GetBufferedAction()
        if ba and ba.pos then
            inst:ForceFacePoint(ba.pos:Get())
        end
        inst.components.locomotor:Stop()
        PlayerAnimation(inst, "PlayAnimation", "atk_prop_pre")
        inst.SoundEmitter:PlaySound(Sounds.attack)
    end,

    events =
    {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("wg_attack_prop")
            end
        end),
    },
})

add_player_sg(State{
    name = "wg_attack_prop",
    tags = { "propattack", "doing", "busy", "notalking", "pausepredict" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        PlayerAnimation(inst, "PlayAnimation", "atk_prop")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        if inst:HasTag("attack_prop_protect") then
            inst.components.health:SetInvincible(true, "wg_attack_prop")
        end
    end,
    timeline =
    {
        TimeEvent(FRAMES, function(inst)
            inst:PerformBufferedAction()
        end),
        TimeEvent(13 * FRAMES, function(inst)
            inst.sg:GoToState("idle", true)
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
        if inst:HasTag("attack_prop_protect") then
            inst.components.health:SetInvincible(nil, "wg_attack_prop")
        end
    end,
})

AddStategraphState("wilson", State{
    name = "wg_dodge_pre",
    tags = {"busy", "evade","no_stun","canrotate", "doing"},
    onenter = function(inst)
        local ba = inst:GetBufferedAction()
        if ba and ba.pos then
            inst:ForceFacePoint(ba.pos)
        end
        inst.components.locomotor:Stop()
        inst:PerformBufferedAction()
        PlayerAnimation(inst, "PlayAnimation", "slide_pre")
        -- EntUtil:add_tag(inst, "tp_not_freezable")
        inst.components.health:SetInvincible(true, "wg_dodge")
    end,
    events = {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("wg_dodge")
        end),
    },
    onexit = function(inst)
        -- EntUtil:remove_tag(inst, "tp_not_freezable")
        inst.components.health:SetInvincible(nil, "wg_dodge")
    end,
})

AddStategraphState("wilson", State{
    name = "wg_dodge",
    tags = {"busy", "evade","no_stun", "doing"},
    onenter =   function(inst)
        -- EntUtil:add_tag(inst, "tp_not_freezable")
        inst.components.health:SetInvincible(true, "wg_dodge")
        PlayerAnimation(inst, "PushAnimation", "slide_loop")
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        inst.Physics:SetMotorVelOverride(20,0,0)
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    end,
    events = {
        EventHandler("animover", function(inst)
            inst.components.health:SetInvincible(nil, "wg_dodge")
            inst.sg:GoToState("wg_dodge_pst")
        end),
    },
    onexit = function(inst)
        -- EntUtil:remove_tag(inst, "tp_not_freezable")
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        inst.Physics:ClearMotorVelOverride()
        inst.components.locomotor:Stop()
        inst.components.locomotor:SetBufferedAction(nil)
        inst.components.health:SetInvincible(nil, "wg_dodge")
    end,
})

AddStategraphState("wilson", State{
    name = "wg_dodge_pst",
    tags = {"evade","no_stun", "doing"},
    onenter = function(inst)
        -- EntUtil:add_tag(inst, "tp_not_freezable")
        PlayerAnimation(inst, "PlayAnimation", "slide_pst")
        inst.components.health:SetInvincible(true, "wg_dodge")
    end,
    onexit = function(inst)
        -- EntUtil:remove_tag(inst, "tp_not_freezable")
        inst.components.health:SetInvincible(nil, "wg_dodge")
    end,
    events =
    {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end ),
    },
})

local dodge = Action({}, 0, false, true, 20, nil, true)
dodge.id = 'WG_DODGE'
dodge.str = '滑铲'
dodge.fn = function(act)
    local item = act.invobject
    if act.target and not act.pos then
        act.pos = act.target:GetPosition()
    end
    if item.components.wg_reticule then
        item.components.wg_reticule:HideReticule()
    end
    if item.components.wg_action_tool then
        item.components.wg_action_tool:DoSkillEffect(act)
    end
    return true
end
AddAction(dodge)
AddStategraphActionHandler("wilson", ActionHandler(dodge, "wg_dodge_pre"))