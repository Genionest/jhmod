require("stategraphs/commonstates")
local _SG = WARGON.SG
local actionhandlers = {}
_SG.add_acthd(actionhandlers, {
	{ACTIONS.EAT, 'eat'},
})
local events = {}
_SG.add_handlers(events, {'step', 'walk', 'hit', 'atk', 'death'})
-- add_ehd(events, {})
local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)
            inst.sg:SetTimeout(4 + 4*math.random())
        end,

        ontimeout = function(inst)
            if math.random() <= inst.user_fn.get_peep_chance(inst) then
                inst.sg:GoToState("idle_peep")
            else
                inst.sg:GoToState("idle_blink")
            end
        end,

        events=
        {
            EventHandler("startstarving", 
                function(inst, data)
                    inst.sg:GoToState("idle_peep")
                end
            ),
        },
    },

    State{
        name = "idle_blink",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_blink")
        end,
       
        timeline = 
        {
            TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/blink") end),
        },

        events=
        {
            EventHandler("animover", 
                function(inst,data) 
                    if math.random() < 0.1 then
                        inst.sg:GoToState("idle_blink")
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            ),
        },
    },

    State{
        name = "idle_peep",
        tags = {"idle"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("meep")
        end,
       
        timeline = 
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/chirp") end),
        },

        events=
        {
            EventHandler("animover", 
                function(inst,data) 
                    if math.random() <= inst.user_fn.get_peep_chance(inst) then
                        inst.sg:GoToState("idle_peep")
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            ),
        },
    },

    State{
        name = "hatch",
        tags = {"busy"},
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/egg_hatch_crack")
            inst.AnimState:PlayAnimation("hatch")
        end,
        timeline = 
        {
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/egg_hatch") end),
        },
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
                -- inst.userfunctions.FollowLeader(inst)
                inst.user_fn.follow_leader(inst)
            end),
        },
    },

    State{
        name = "growup",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("grow")
        end,
        timeline = 
        {
            TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/leg_sproing") end),
            TimeEvent(30*FRAMES, function(inst) inst.Transform:SetScale(1.1, 1.1, 1.1) end),
            TimeEvent(100*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teenbird/leg_sproing") end),
            TimeEvent(102*FRAMES, function(inst) inst.Transform:SetScale(1.2, 1.2, 1.2) end),
        },
        events=
        {
            EventHandler("animover", function(inst)
                -- inst.userfunctions.SpawnTeen(inst)
                inst.user_fn.spawn_teen(inst)
            end),
        },
    },

    State{
        name = "taunt",
        tags = {"busy", "canrotate"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("call")
            if inst.components.combat and inst.components.combat.target then
                inst:FacePoint(Vector3(inst.components.combat.target.Transform:GetWorldPosition()))
            end
        end,
        
        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/chirp_short") end),
            TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/chirp_short") end),
            TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/chirp_short") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },    
}

_SG.add_states(states, {
	-- {'idle', {}},
	{'combat', {
		tl = {
			atk = {
				{10, function(inst)
					inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/attack")
				end},
				{12, function(inst)
					inst.components.combat:DoAttack()
					-- inst.sg:RemoveStateTag('attack')
					-- inst.sg:RemoveStateTag('busy')
				end}
			},
			hit = {0, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/hurt")
			end},
			death = {0, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/death")
			end},
		},
	}},
	{'walk', {
		tl = {
			walk = {1, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/wings") 
			end},
		},
		soft = true,
	}},
	{'frozen', {}},
	{'sleep', {
		tl = {
			sleep_pre = {0, function(inst)
				nst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/sleep")
			end},
			-- sleep = {},
			wake = {0, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/wakeup")
			end},
		},
	}},
	{'act', {
		name = 'eat',
		anim = 'eat',
		time = 7,
		tags = {"busy", "canrotate"},
	}},
})

return StateGraph("tp_small_bird", states, events, 'idle', actionhandlers)