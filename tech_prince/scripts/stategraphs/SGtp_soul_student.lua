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
        name = "staff",
        tags = {"doing", "busy",  "canrotate", "spell"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("staff") 
            inst.components.locomotor:Stop()
            --Spawn an effect on the player's location
            inst.stafffx = SpawnPrefab("staffcastfx")            

            local pos = inst:GetPosition()
            inst.stafffx.Transform:SetPosition(pos.x, pos.y, pos.z)

            inst.stafffx.Transform:SetRotation(inst.Transform:GetRotation())
            inst.stafffx.AnimState:SetMultColour(1, 1, 1, 1)
        end,
        onexit = function(inst)
            if inst.stafffx then
                inst.stafffx:Remove()
            end
        end,
        timeline = 
        {
            TimeEvent(13*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_gemstaff") 
            end),
            TimeEvent(0*FRAMES, function(inst)
                inst.stafflight = SpawnPrefab("staff_castinglight")
                local pos = inst:GetPosition()
                local colour = {1,1,1}
                inst.stafflight.Transform:SetPosition(pos.x, pos.y, pos.z)
                inst.stafflight.setupfn(inst.stafflight, colour, 1.9, .33)                

            end),
            TimeEvent(53*FRAMES, function(inst) 
                local ents = WARGON.finds(inst, 20, {"ghost"})
                for k, v in pairs(ents) do
                    if v and v:IsValid() then
                        WARGON.make_fx(v, "tp_fx_ground_pound")
                        v:Remove()
                    end
                end
            end),
        },

        events = {
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
		end,
	    
		timeline = 
		{
		    TimeEvent(4*FRAMES, PlayFootstep ),
		    TimeEvent(5*FRAMES, PlayFootstep ),
		},

		events=
		{   
			EventHandler("animover", function(inst) 
                inst.sg:GoToState("run") 
            end ),        
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
    
return StateGraph("tp_soul_student", states, events, "idle", actionhandlers)

