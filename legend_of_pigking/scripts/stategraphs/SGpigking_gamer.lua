require("stategraphs/commonstates")

local actionhandlers = {
	ActionHandler(ACTIONS.PICKUP, "pickup"),
}

local events = {
	CommonHandlers.OnLocomote(true, true),
	CommonHandlers.OnAttack(),
	CommonHandlers.OnAttacked(true),
}

local states = {
	State{
		name = "taunt",
		tags = {"idle"},
		onenter = function(inst)
			inst.Physics:Stop()
            inst.AnimState:PlayAnimation(inst.start_idle)
            inst.components.talker:Say(inst.start_talk)
		end,
		events=
        {
            EventHandler("animover", function(inst) 
            	inst.sg:GoToState("idle") 
            end),
        },
	},

    State{
        name = "exit",
        tags = {},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation(inst.start_idle)
        end,
        events = {
        },
    },

	State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/pig/attack")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,
        
        timeline=
        {
            TimeEvent(13*FRAMES, function(inst) 
            	inst.components.combat:DoAttack() 
            	inst.sg:RemoveStateTag("attack") 
            	inst.sg:RemoveStateTag("busy") 
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) 
            	inst.sg:GoToState("idle") 
            end),
        },
    },

    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/pig/oink")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) 
            	inst.sg:GoToState("idle") 
            end ),
        },        
    },    
}

CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(12*FRAMES, PlayFootstep ),
	},
})
CommonStates.AddRunStates(states,
{
	runtimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(10*FRAMES, PlayFootstep ),
	},
})

CommonStates.AddIdle(states)
CommonStates.AddSimpleActionState(states,"pickup", "pig_pickup", 10*FRAMES, {"busy"})

return StateGraph("pigking_gamer", states, events, "taunt", actionhandlers)