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

STRINGS.WG_BOOK = "图鉴"
STRINGS.WG_USE = "使用"
STRINGS.WG_TOUCH = "触碰"
local use = Action({mount_enabled=true}, 3)
use.id = "WG_USE"
-- use.str = STRINGS.WG_USE
use.strfn = function(act)
	local obj = act.target
	if obj and obj:HasTag("obstacle") then
		return "TOUCH"
	end
	return "USE"
end
use.fn = function(act)
	if (act.target or act.invobject) and act.doer then
		local target = act.target or act.invobject
		if target.components.wg_useable then
			target.components.wg_useable:Use(act.doer)
			return true
		end
		
	end
end
AddAction(use)
AddStategraphActionHandler("wilson", ActionHandler(use, "give"))
AddStategraphActionHandler("wilsonboating", ActionHandler(use, "give"))
-- 要在AddAction之后添加
STRINGS.ACTIONS.WG_USE = {
	USE = STRINGS.WG_USE,
	TOUCH = STRINGS.WG_TOUCH,
}

STRINGS.WG_OPERATE = "操作"
local operate = Action({mount_enabled=true}, 3)
operate.id = "WG_OPERATE"
operate.str = STRINGS.WG_OPERATE
operate.fn = function(act)
	if act.target and act.doer then
		if act.target.components.wg_machine then
			act.target.components.wg_machine:Use(act.doer)
			return true
		end
	end
end
AddAction(operate)
local operate_action_handler = function(inst, action)
    if action.target and action.target.components.wg_machine
	and action.target.components.wg_machine.long_act then
		return "dolongaction"
	end
	return "doshortaction"
end
AddStategraphActionHandler("wilson", ActionHandler(operate, operate_action_handler))
AddStategraphActionHandler("wilsonboating", ActionHandler(operate, operate_action_handler))


STRINGS.WG_INTERACT = "交互"
local interact = Action({mount_enabled=true}, .5)
interact.id = "WG_INTERACT"
interact.str = STRINGS.WG_INTERACT
interact.fn = function(act)
	if act.target and act.invobject and act.doer then
		if act.target.components.wg_interable then
			act.target.components.wg_interable:Interact(act.invobject, act.doer)
			return true
		end
	end
end
AddAction(interact)
AddStategraphActionHandler("wilson", ActionHandler(interact, "give"))
AddStategraphActionHandler("wilsonboating", ActionHandler(interact, "give"))

STRINGS.WG_CHAT = "交谈"
local chat = Action({mount_enabled=true}, .5)
chat.id = "WG_CHAT"
chat.str = STRINGS.WG_CHAT
chat.fn = function(act)
	if act.target and act.doer then
		if act.target.components.wg_chatable then
			act.target.components.wg_chatable:Chat(act.doer)
			return true
		end
	end
end
AddAction(chat)
AddStategraphActionHandler("wilson", ActionHandler(chat, "wg_chat"))
AddStategraphActionHandler("wilsonboating", ActionHandler(chat, "wg_chat"))
add_player_sg(State{
	name = "wg_chat",
	tags = {"idle", "talking"},
	
	onenter = function(inst, noanim)
		inst.components.locomotor:Stop()
		if not noanim then
			PlayerAnimation(inst, "PlayAnimation", "dial_loop", true)
		end
		
		local sound_name = inst.soundsname or inst.prefab
		local path = inst.talker_path_override or "dontstarve/characters/"
		local equippedHat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

		if equippedHat and equippedHat:HasTag("muffler") then
			inst.SoundEmitter:PlaySound(path..sound_name.."/gasmask_talk", "talk")

		elseif inst.talksoundoverride then
			inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
		else
			inst.SoundEmitter:PlaySound(path..sound_name.."/talk_LP", "talk")
		end

		if inst:HasTag("hasvoiceintensity_health") then
			local percent = inst.components.health:GetPercent()
			inst.SoundEmitter:SetParameter( "talk", "intensity", percent )                
		end
		
		inst.sg:SetTimeout(1.5 + math.random()*.5)
	end,
	
	timeline = {
        TimeEvent(6*FRAMES, function(inst) 
            inst:PerformBufferedAction()
        end),
    },

	ontimeout = function(inst)
		inst.SoundEmitter:KillSound("talk")
		inst.sg:GoToState("idle")
		if inst.components.talker.endspeechsound then
			inst.SoundEmitter:PlaySound(inst.components.talker.endspeechsound)
		end               
	end,
	
	onexit = function(inst)
		inst.SoundEmitter:KillSound("talk")
		if inst.components.talker.endspeechsound then
			inst.SoundEmitter:PlaySound(inst.components.talker.endspeechsound)
		end               
	end,
	
	events=
	{
		EventHandler("donetalking", function(inst) inst.sg:GoToState("idle") end),
	},
})