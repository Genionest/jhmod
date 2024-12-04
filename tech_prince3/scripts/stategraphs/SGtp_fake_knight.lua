local EntUtil = require "extension.lib.ent_util"

require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events =
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,false),
    -- CommonHandlers.OnAttack(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("doattack", function(inst)
        if inst.components.health and not inst.components.health:IsDead()
        and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
            if math.random() < .33 then
                if math.random() < .5 then
                    inst.sg:GoToState("fall_stone_pre")
                else
                    inst.sg:GoToState("jump_attack_pre")
                end
            else
                inst.sg:GoToState("attack")
            end
        end
    end)
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
        name = "jump_attack_pre",
        tags = {"attack", "busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("jumpboat")
            inst.sg.statemem.startpos = inst:GetPosition()
            inst.sg.statemem.targetpos = inst:GetPosition()
            local target = inst.components.combat.target
            if target then
                inst.sg.statemem.targetpos = target:GetPosition()
            end
        end,
        onexit = function(inst)
            inst.components.locomotor:Stop()
        end,
        timeline = {
             TimeEvent(7*FRAMES, function(inst)
                inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
                local dist = inst:GetPosition():Dist(inst.sg.statemem.targetpos)
                local speed = dist / (18/30)
                inst.Physics:SetMotorVelOverride(1 * speed, 0, 0)
            end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
                inst.Physics:Stop()
                inst.components.locomotor:Stop()
                inst.sg:GoToState("jump_attack_pst")
            end),
        },
    },

    State{
        name = "jump_attack_pst",
        tags = {"attack", "busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("land", false)
            if math.random() < .5 then
                inst.components.combat:StartAttack()
            else
                inst:AddTag("fake_knight_will_aoe")
            end
        end,
        timeline = {
            TimeEvent(4*FRAMES, function(inst)
                if inst:HasTag("fake_knight_will_aoe") then
                    EntUtil:make_area_dmg2(inst, 6, inst, 30, nil, 
                        EntUtil:add_stimuli(nil, "thump"))
                    SpawnPrefab("groundpoundring_fx").Transform:SetPosition(inst:GetPosition():Get())
                else
                    inst.components.combat:DoAttack()
                end
            end)
        },
        onexit = function(inst)
            inst:RemoveTag("fake_knight_will_aoe")
        end,    
        events = {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end)
        },
    },

    State{
        name = "fall_stone_pre",
        tags = {"attack", "busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
        end,
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("fall_stone_pst")
            end)
        },
    },

    State{
        name = "fall_stone_pst",
        tags = {"attack", "busy"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("pickaxe_loop")
            inst.components.combat:StartAttack()
        end,
        timeline = {
            TimeEvent(4*FRAMES, function(inst)
                inst.components.combat:DoAttack()
                inst:spawn_fall_stone()
            end),
        },
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end)
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

CommonStates.AddFrozenStates(states)
    
return StateGraph("tp_fake_knight", states, events, "idle", actionhandlers)

