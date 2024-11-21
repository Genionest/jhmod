require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.EAT, "eat"),
}


local events=
{
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnSleep(),
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
    -- EventHandler("locomote", 
    --     function(inst) 
    --         if not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving") then return end
            
    --         if not inst.components.locomotor:WantsToMoveForward() then
    --             if not inst.sg:HasStateTag("idle") then
    --                 if not inst.sg:HasStateTag("running") then
    --                     inst.sg:GoToState("idle")
    --                 end
    --                     inst.sg:GoToState("idle")
    --             end
    --         elseif inst.components.locomotor:WantsToRun() then
    --             if not inst.sg:HasStateTag("running") then
    --                 inst.sg:GoToState("run")
    --             end
    --         else
    --             -- if not inst.sg:HasStateTag("hopping") then
    --             --     inst.sg:GoToState("hop")
    --             -- end
    --         end
    --     end),
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
            inst.AnimState:PlayAnimation("run")
        end,

        -- timeline = 
        -- {
        --     TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/growl") end),
        --     TimeEvent(0*FRAMES, PlayFootstep),
        --     TimeEvent(4*FRAMES, PlayFootstep),
        -- },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("run")
            end),
        },
    },

    -- State{
    --     name = "run",
    --     tags = {"moving", "running", "canrotate"},
        
    --     onenter = function(inst) 
    --         -- local play_scream = true
    --         -- if inst.components.inventoryitem then
    --         --     play_scream = inst.components.inventoryitem.owner == nil
    --         -- end
    --         -- if play_scream then
    --         --     inst.SoundEmitter:PlaySound(inst.sounds.scream)
    --         -- end
    --         inst.AnimState:PlayAnimation("run_pre")
    --         inst.AnimState:PushAnimation("run", true)
    --         inst.components.locomotor:RunForward()
    --     end,
        
    --     --[[onupdate= function(inst)
    --         if not inst.components.locomotor:WantsToMoveForward() then
    --             inst.sg:GoToState("idle")
    --         end
    --     end, --]]       
        
    -- },    

    State{
        name = "run_stop",
        tags = {"canrotate", "idle"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle")
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
            inst:ClearBufferedAction()
            inst.sg:RemoveStateTag("attack")
            inst.sg:RemoveStateTag("busy") 
            inst.sg:GoToState("idle")
            -- inst.components.combat:StartAttack()
            -- inst.Physics:Stop()
            -- inst.AnimState:PlayAnimation("atk_pre")
            -- inst.AnimState:PushAnimation("atk", false)
        end,
        
        -- timeline=
        -- {
        --     TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/attack") end),
        --     TimeEvent(16*FRAMES, function(inst) inst.components.combat:DoAttack() inst.sg:RemoveStateTag("attack") inst.sg:RemoveStateTag("busy") end),
        -- },
        
        -- events=
        -- {
        --     EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        -- },
    },
    
    State{
        name = "eat",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("rabbit_eat_pre", false)
            inst.AnimState:PushAnimation("rabbit_eat_loop", false)
            inst.AnimState:PushAnimation("rabbit_eat_pst", false)
            -- inst.sg:SetTimeout(2+math.random()*4)
        end,
        
        timeline=
        {
            TimeEvent(14*FRAMES, function(inst) inst:PerformBufferedAction() end),
            -- TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/bite") end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },        
        -- ontimeout= function(inst)
        --     inst:PerformBufferedAction()
        --     inst.sg:GoToState("idle", )
        -- end,
    },

    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/rabbit/scream_short")
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

        -- timeline = {
        --     TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/wakeup") end ),
        -- },

    },
}

-- CommonStates.AddSleepStates(states)
CommonStates.AddFrozenStates(states)
    
return StateGraph("morph_rabbit", states, events, "idle", actionhandlers)

