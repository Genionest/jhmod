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
            inst.components.locomotor:Stop()
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)            
            inst.AnimState:Hide("swap_arm_carry")
            inst.AnimState:PlayAnimation("death")
        end,
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
            inst.AnimState:PlayAnimation("atk")
            -- inst.AnimState:PlayAnimation("player_atk_pre")
            -- inst.AnimState:PushAnimation("player_atk", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
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
                inst.sg:GoToState("idle")
            end ),
        },
    },
    
    State{
        name = "tp_hua_start",
        tags = {"busy", "evade","no_stun","canrotate"},
        onenter = function(inst)
            -- local ba = inst:GetBufferedAction()
            -- if ba and ba.pos then
            --     inst:ForceFacePoint(ba.pos)
            -- end
            -- inst:PerformBufferedAction()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("slide_pre")
        end,
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("tp_hua")
            end),
        },
    },

    State{
        name = "tp_hua",
        tags = {"busy", "evade","no_stun", "runing", "moving"},
        onenter =   function(inst)
            inst.AnimState:PushAnimation("slide_loop")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
            -- inst.Physics:SetMotorVelOverride(20,0,0)
            inst.components.locomotor.runspeed = inst:HasTag("tp_hornet_fast") and 30 or 20
            inst.components.locomotor:RunForward()
            -- inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.components.health:SetInvincible(true)
        end,
        events = {
            EventHandler("animover", function(inst)
                inst.components.health:SetInvincible(false)
                inst.sg:GoToState("tp_hua_pst")
            end),
        },
        onexit = function(inst)
            -- inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            -- inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:Stop()
            
            inst.components.locomotor:SetBufferedAction(nil)
            inst.components.health:SetInvincible(false)
            inst.components.locomotor.runspeed = 6
        end,
    },

    State{
        name = "tp_hua_pst",
        tags = {"evade","no_stun"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("slide_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },
    },

	State{
		name = "run_start",
		tags = {"moving", "running", "canrotate"},
	    
		onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_pre")
            -- inst.AnimState:PlayAnimation("slide_pre")
        end,
        
        timeline = 
        {
            TimeEvent(4*FRAMES, PlayFootstep ),
            TimeEvent(5*FRAMES, PlayFootstep ),
        },

        events=
        {   
            EventHandler("animover", function(inst) 
                if inst.components.combat.target 
                and inst.components.combat:InCooldown() then
                    inst.sg:GoToState("tp_hua_start")
                else
                    inst.sg:GoToState("run") 
                end
            end ),        
		},
	},
    
	State{
		name = "run",
		tags = {"moving", "running", "canrotate"},
	    
		onenter = function(inst) 
			inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_loop")
			-- inst.AnimState:PlayAnimation("slide_loop")
		end,
		
		events=
		{   
			EventHandler("animover", function(inst) 
                inst.sg:GoToState("run") 
            end ),        
		},
	},
        
	State{
		name = "run_stop",
		tags = {"canrotate"},
	    
		onenter = function(inst) 
			inst.Physics:Stop()
            inst.AnimState:PlayAnimation("run_pst")
			-- inst.AnimState:PlayAnimation("slide_pst")
		end,
	    
		events=
		{   
			EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle") 
            end ),        
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
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle") 
            end ),
        },        
    },    
}
    
return StateGraph("tp_hornet", states, events, "idle", actionhandlers)

