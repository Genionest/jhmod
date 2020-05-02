require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.EAT, "eat"),
}


local events=
{
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(true),
    -- CommonHandlers.OnSleep(),
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
			if not inst.AnimState:IsCurrentAnimation("idle") then
				inst.AnimState:PlayAnimation("idle", true)
			end
		end,
	},

    State{
        name = "run_start",
        tags = {"moving", "running", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("walk_pre")
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
            inst.AnimState:PlayAnimation("walk_loop")
        end,

        timeline = 
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/footstep") end ),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/footstep") end ),
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
            inst.AnimState:PlayAnimation("walk_pst")
        end,

        events = 
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    
    -- State{
    --     name = "death",
    --     tags = {"busy"},
        
    --     onenter = function(inst)
    --         -- inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
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
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,
        
        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/attack") end),
            TimeEvent(12*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            TimeEvent(14*FRAMES, function(inst) 
                inst.sg:RemoveStateTag("attack")
                inst.sg:RemoveStateTag("busy")
            end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
    State{
        name = "eat",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("steal")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/scratch_ground")
        end,
        
        timeline=
        {
            TimeEvent(11*FRAMES, function(inst) inst:PerformBufferedAction() end),
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
            inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/hurt")
            inst.AnimState:PlayAnimation("hit")
            inst:ClearBufferedAction()
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
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

        timeline = {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/wakeup") end ),
        },

    },
}

-- CommonStates.AddSleepStates(states,
-- {
--     starttimeline = 
--     {
--         TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/sleep") end ),
--     },
--     waketimeline = 
--     {
--         TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/wakeup") end ),
--     },
-- })
CommonStates.AddFrozenStates(states)
    
return StateGraph("morph_tallbird", states, events, "wakeup", actionhandlers)

