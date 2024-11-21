require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.CHOP, "work"),
    ActionHandler(ACTIONS.HACK, "work"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
}


local events=
{
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(true),
    -- CommonHandlers.OnDeath(),
    EventHandler("locomote", function(inst, data)
    	-- local is_attacking = inst.sg:HasStateTag("attack")
    	local is_busy = inst.sg:HasStateTag("busy")
    	if is_busy then return end
    	-- if is_attacking or is_busy then return end
    	local is_moving = inst.sg:HasStateTag("moving")
    	-- local is_running = inst.sg:HasStateTag("running")
    	local should_move = inst.components.locomotor:WantsToMoveForward()
    	-- local should_run = inst.components.locomotor:WantsToRun()

    	if is_moving and not should_move then
			inst.sg:GoToState("run_stop")
		elseif not is_moving and should_move then
			inst.sg:GoToState("run_start")
    	end
    end),
    EventHandler("doaction", function(inst, data) 
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
            if data.action == ACTIONS.CHOP then
                inst.sg:GoToState("chop", data.target)
            end
        end
    end),
    EventHandler("wakeup", function(inst) inst.sg:GoToState("wakeup") end),
}

local states=
{	
	State{
		name = "idle",
		tags = {"idle", "canrotate"},
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.components.locomotor:Clear()
			if not inst.AnimState:IsCurrentAnimation("idle_loop") then
				inst.AnimState:PlayAnimation("idle_loop", true)
			end
		end,
	},

	State{
		name = "run_start",
		tags = {"moving", "running", "canrotate"},

		onenter = function(inst)
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("run_pre")
		end,

		events = 
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("run")
			end)
		},

		onupdate = function(inst)
			inst.components.locomotor:RunForward()
		end,
	},

	State{
		name = "run",
		tags = {"moving", "running", "canrotate"},

		onenter = function(inst)
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("run_loop")
		end,

		timeline = 
		{
			TimeEvent(0*FRAMES, PlayFootstep),
			TimeEvent(12*FRAMES, PlayFootstep),
		},

		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("run")
			end),
		},
	},

	State{
		name = "run_stop",
		tags = {"canrotate", "idle"},

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("run_pst")
		end,

		events = 
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	},
    
  --   State {
		-- name = "frozen",
		-- tags = {"busy"},
		
  --       onenter = function(inst)
  --           inst.AnimState:PlayAnimation("frozen")
  --           inst.Physics:Stop()
  --       end,
  --   },
    
    -- State{
    --     name = "death",
    --     tags = {"busy"},
        
    --     onenter = function(inst)
    --         -- inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
    --         -- inst.components.morph:UnMorph()
    --         inst.AnimState:PlayAnimation("death")
    --         inst.Physics:Stop()
    --         RemovePhysicsColliders(inst)            
    --         -- inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
    --     end,
        
    -- },
    
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
            TimeEvent(13*FRAMES, function(inst) inst.components.combat:DoAttack() inst.sg:RemoveStateTag("attack") inst.sg:RemoveStateTag("busy") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "work",
        tags = {"working"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
            inst.sg.statemem.action = inst:GetBufferedAction()
        end,
        
        timeline=
        {
            TimeEvent(13*FRAMES, function(inst) inst:PerformBufferedAction() end ),
            TimeEvent(15*FRAMES, function(inst)
                if (TheInput:IsMouseDown(MOUSEBUTTON_LEFT)
                or TheInput:IsKeyDown(KEY_SPACE))
                and inst.sg.statemem.action
                and inst.sg.statemem.action:IsValid()
                and inst.sg.statemem.action.target
                and inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action)
                and (inst.sg.statemem.action.target.components.workable
                or inst.sg.statemem.action.target.components.hackable) then
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    -- State{
    --     name = "hack",
    --     tags = {"hacking"},
        
    --     onenter = function(inst)
    --         inst.Physics:Stop()
    --         inst.AnimState:PlayAnimation("atk")
    --     end,
        
    --     timeline=
    --     {
    --         TimeEvent(13*FRAMES, function(inst) inst:PerformBufferedAction() end ),
    --     },
        
    --     events=
    --     {
    --         EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
    --     },
    -- },
    
    State{
        name = "eat",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("eat")
        end,
        
        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/pig/oink")
            inst.AnimState:PlayAnimation("hit")
            inst:ClearBufferedAction()
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },

        timeline =
        {
            TimeEvent(3*FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },   
    },

    State{
        name = "electrocute",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.fx = SpawnPrefab("shock_fx")
            inst.fx.Transform:SetRotation(inst.Transform:GetRotation())
            local pos = inst:GetPosition()
            inst.fx.Transform:SetPosition(pos.x, pos.y, pos.z)
        end,

        onexit = function(inst)
            inst.fx:Remove()
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")            
            end),
        },
    },

    State{
        name = "wakeup",

        onenter = function(inst)
            inst.components.playercontroller:Enable(false)
            inst.AnimState:PlayAnimation("sleep_pst")
            inst.components.health:SetInvincible(true)
        end,
        
        onexit = function(inst)
            inst.components.playercontroller:Enable(true)
            inst.components.health:SetInvincible(false)
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        -- timeline = {
        --     TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/pig/sleep") end ),
        -- },

    },
}

CommonStates.AddFrozenStates(states)
    
return StateGraph("morph_pig", states, events, "idle", actionhandlers)

