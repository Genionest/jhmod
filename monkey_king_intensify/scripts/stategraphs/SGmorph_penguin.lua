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
            -- inst.AnimState:PlayAnimation("walk")
            inst.AnimState:PlayAnimation("slide_bounce")
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

        onexit = function(inst)
            if GetSeasonManager():IsWinter() then
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/slide","slide")
            else
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/slide_dirt","slide")
            end
        end,
    },

    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            -- inst.AnimState:PlayAnimation("walk", true)
            inst.AnimState:PlayAnimation("slide_loop")
        end,

        -- timeline = 
        -- {
        --     TimeEvent(5*FRAMES, function(inst)
        --         if GetSeasonManager():IsWinter() then
        --             inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep")
        --         else
        --             inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep_dirt")
        --         end
        --     end),
        --     TimeEvent(21*FRAMES, function(inst)
        --         if GetSeasonManager():IsWinter() then
        --             inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep")
        --         else
        --             inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep_dirt")
        --         end
        --     end),
        -- },

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
            inst.SoundEmitter:KillSound("slide")
            inst.components.locomotor:Stop()
            -- inst.AnimState:PlayAnimation("idle_loop", true)
            inst.AnimState:PlayAnimation("slide_post")
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
            inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/attack")
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,
        
        timeline=
        {
            TimeEvent(15*FRAMES, function(inst) inst.components.combat:DoAttack() inst.sg:RemoveStateTag("attack") inst.sg:RemoveStateTag("busy") end),
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
            inst.AnimState:PlayAnimation("eat", true)
            inst.sg:SetTimeout(0.8+math.random())
        end,
        
        timeline=
        {
            TimeEvent(4*FRAMES, function(inst) 
                inst:PerformBufferedAction()
            end),
        },
        
        ontimeout= function(inst)
            inst.sg:GoToState("idle")
        end,
        -- events=
        -- {
        --     EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        -- },        
    },

    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
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

        -- },

    },
}

CommonStates.AddFrozenStates(states)
    
return StateGraph("morph_penguin", states, events, "idle", actionhandlers)

