require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events =
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,false),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
}

local states=
{


	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("fall_off")
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount") 
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("death_pst")
            end ),
        } 
    },

    State{
        name = "death_pst",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:SetBuild("wilson")
            inst.AnimState:Hide("swap_arm_carry")
            inst.AnimState:PlayAnimation("death")
            local beefalo = WARGON.make_spawn(inst, 'beefalo')
            beefalo.components.health:Kill()
        end,
    },

    State{
		name = "bellow",
		tags = {"busy"},
		
		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("bellow")
			inst.SoundEmitter:PlaySound("dontstarve/beefalo/grunt")
			local target = nil
			if inst.components.combat and inst.components.combat.target then
				target = inst.components.combat.target
			end
			if not target then
				target = inst
			end
            if c_find("tp_fx_sign_killer") == nil then
                WARGON.make_fx(target, "tp_fx_sign_killer")
            end
			inst.atk_num = 0
		end,
		
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
	},
	
	State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("idle_loop", true)
        end,
    },
    
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("player_atk_pre")
            inst.AnimState:PushAnimation("player_atk", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            inst.atk_num = inst.atk_num + 1
        end,
        
        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) 
            	inst.components.combat:DoAttack() 
            end),
            TimeEvent(12*FRAMES, function(inst) 
				inst.sg:RemoveStateTag("busy")
				inst.sg:RemoveStateTag("attack")
			end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst)
                if inst.atk_num >= 3 then
                	inst.sg:GoToState('bellow')
                else
                    inst.sg:GoToState("idle")
                end
            end ),
        },
    },
    
	State{
		name = "run_start",
		tags = {"moving", "running", "canrotate"},
	    
		onenter = function(inst) 
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("run_pre")
		end,
	    
		timeline = 
		{
		    TimeEvent(4*FRAMES, PlayFootstep ),
		    TimeEvent(5*FRAMES, PlayFootstep ),
		},

		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
		},
	},
    
	State{
		name = "run",
		tags = {"moving", "running", "canrotate"},
	    
		onenter = function(inst) 
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("run_loop")
		end,
		
		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
		},
	},
        
	State{
		name = "run_stop",
		tags = {"canrotate"},
	    
		onenter = function(inst) 
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("run_pst")
		end,
	    
		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
		},
	},
	
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit") 
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },    
}
    
return StateGraph("tp_sign_rider", states, events, "idle", actionhandlers)

