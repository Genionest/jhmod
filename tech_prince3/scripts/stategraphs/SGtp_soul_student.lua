local EntUtil = require "extension.lib.ent_util"
local FxManager = Sample.FxManager

require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events =
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,false),
    -- CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("doattack", function(inst)
        if inst.components.health and not inst.components.health:IsDead()
        and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
            if math.random() < .33 then
                inst.sg:GoToState("jump_attack_pre")
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
                local target = inst.components.combat.target
                if target then
                    local soul = FindEntity(inst, 100, nil, {"ghost"})
                    if soul and EntUtil:is_alive(soul) then
                        local proj = SpawnPrefab(inst.proj)
                        proj.Transform:SetPosition(soul:GetPosition():Get())
                        proj.components.wg_projectile:Throw(inst, target, inst)
                        soul.components.health:Kill()
                    end
                end
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
                -- inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
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
            -- if math.random() < .5 then
                inst.components.combat:StartAttack()
            -- else
            --     inst:AddTag("fake_knight_will_aoe")
            -- end
            local target = inst.components.combat.target
            if target then
                FxManager:MakeFx("statue_transition", inst)
                FxManager:MakeFx("statue_transition_2", inst)
                inst.Transform:SetPosition(target:GetPosition():Get())
            end
        end,
        timeline = {
            TimeEvent(4*FRAMES, function(inst)
                local dmg = inst.components.combat.defaultdamage*.4
                EntUtil:make_area_dmg2(inst, 3, inst, dmg, nil, 
                    EntUtil:add_stimuli(nil, "electric"))
            end)
        },
        onexit = function(inst)
            -- inst:RemoveTag("fake_knight_will_aoe")
        end,    
        events = {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end)
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
                local x, y, z = inst:GetPosition():Get()
                local ents = TheSim:FindEntities(x, y, z, 20, {"ghost"})
                local pos = nil
                for k, v in pairs(ents) do
                    if v and v:IsValid() then
                        pos = v:GetPosition()
                        v:Remove()
                    end
                end
                SpawnPrefab("groundpoundring_fx").Transform:SetPosition(pos:Get())
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

CommonStates.AddFrozenStates(states)

return StateGraph("tp_soul_student", states, events, "idle", actionhandlers)

