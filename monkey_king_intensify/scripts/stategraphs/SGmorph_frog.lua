require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.EAT, "eat"),
}

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(true),
    EventHandler("locomote", function(inst, data)
        local is_busy = inst.sg:HasStateTag("busy")
        if is_busy then return end
        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

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
            -- if MK_INTENSIFY_UTIL.IsInWater(inst) then
            --     inst.AnimState:PlayAnimation("swim", true)
            -- else
            --     inst.AnimState:PlayAnimation("idle", true)
            -- end
        end,
    },

    State{
        name = "emerge",
        tags = {"canrotate", "busy"},
        
        onenter = function(inst)
            inst.AnimState:SetBank("frog_water")
            inst.AnimState:PlayAnimation("jumpout_pre")
            inst.components.locomotor:RunForward()
        end,
       
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("emerge_finish")
            end),
        },
    },

    State{
        name = "emerge_finish",
        tags = {"canrotate", "busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("jumpout")
            inst.components.locomotor:RunForward()
        end,

        events=
        {
            EventHandler("animover", function(inst) 
                --inst.AnimState:PlayAnimation("idle")
                inst.AnimState:SetBank("frog")
                inst.sg:GoToState("idle")
            end),
        },
    },  

    State{
        name = "submerge",
        tags = {"canrotate", "busy"},
        
        onenter = function(inst)
            inst.AnimState:SetBank("frog_water")
            inst.AnimState:PlayAnimation("jumpin_pre")
            inst.components.locomotor:RunForward()
        end,
       
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("submerge_finish")
            end),
        },
    },

    State{
        name = "submerge_finish",
        tags = {"canrotate", "busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("jumpin")
            inst.components.locomotor:RunForward()
        end,
       
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end),
        },
    }, 

    State{
        name = "run_start",
        tags = {"moving", "running", "canrotate"},

        onenter = function(inst)
            -- inst.components.locomotor:Stop()
            -- inst.AnimState:PlayAnimation("idle")
            inst.components.locomotor:RunForward()
            if MK_INTENSIFY_UTIL.IsInWater(inst) then
                inst.AnimState:PlayAnimation("swim_pre")
            else
                inst.AnimState:PlayAnimation("jump_pre")
            end
        end,

        events = 
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("run")
            end)
        },

        -- onupdate = function(inst)
        --     inst.components.locomotor:RunForward()
        -- end,
    },

    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            -- inst.AnimState:PlayAnimation("jump_pre")
            -- inst.AnimState:PushAnimation("jump")
            -- inst.AnimState:PushAnimation("jump_pst", false)
            if MK_INTENSIFY_UTIL.IsInWater(inst) then
                inst.AnimState:PlayAnimation("swim", true)
            else
                inst.AnimState:PlayAnimation("jump")
            end
        end,

        -- timeline = 
        -- {
        --     TimeEvent(5*FRAMES, PlayFootstep),
        -- },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if MK_INTENSIFY_UTIL.IsInWater(inst) then
                    inst.sg:GoToState("run")
                else
                    inst.sg:GoToState("run_stop")
                end
            end),
        },
    },

    State{
        name = "run_stop",
        tags = {"canrotate", "idle"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if MK_INTENSIFY_UTIL.IsInWater(inst) then
                inst.AnimState:PushAnimation("swim_pst")
            else
                inst.AnimState:PushAnimation("jump_pst")
            end
            -- if not inst.AnimState:IsCurrentAnimation("jump_pst") then
            --     inst.AnimState:PushAnimation("jump_pst")
            -- else
            --     inst.AnimState:PushAnimation("idle")
            -- end
        end,

        events = 
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    
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
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/frog/attack_spit") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/frog/attack_voice") end),
            TimeEvent(25*FRAMES, function(inst) inst.components.combat:DoAttack() inst.sg:RemoveStateTag("attack") inst.sg:RemoveStateTag("busy") end),
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
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,
        
        timeline=
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/frog/attack_spit") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/frog/attack_voice") end),
            TimeEvent(17*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },
        
        -- ontimeout= function(inst)
        --     inst.sg:GoToState("idle")
        -- end,
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },

    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk_pre")
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
            inst.AnimState:PlayAnimation("atk_pre")
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
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/frog/wake") end ),
        },

    },
}

CommonStates.AddFrozenStates(states)
    
return StateGraph("morph_frog", states, events, "idle", actionhandlers)

