require("stategraphs/commonstates")

local actionhandlers = 
{
    -- ActionHandler(ACTIONS.EAT, "eat"),
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
            inst.AnimState:PlayAnimation("walk")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jump")
        end,

        -- timeline = 
        -- {
        --     TimeEvent(5*FRAMES, PlayFootstep),
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
    
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
            -- inst.AnimState:PushAnimation("atk", false)
        end,
        
        timeline=
        {
            TimeEvent(9*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/headbutt")
            end),
            TimeEvent(12*FRAMES, function(inst)
                inst.components.combat:DoAttack()
            end),
            TimeEvent(15*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") inst.sg:RemoveStateTag("busy") end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
    -- State{
    --     name = "eat",
    --     tags = {"busy"},
        
    --     onenter = function(inst)
    --         inst.Physics:Stop()
    --         -- inst.AnimState:PlayAnimation("graze_loop", true)
    --     end,
        
    --     timeline=
    --     {
    --         TimeEvent(15*FRAMES, function(inst) inst:PerformBufferedAction() end),
    --     },
        
    --     -- ontimeout= function(inst)
    --     --     inst.sg:GoToState("idle")
    --     -- end,
    --     events=
    --     {
    --         EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    --     },        
    -- },

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
            inst.AnimState:PlayAnimation("shock")
            inst.AnimState:PushAnimation("shock_pst", false)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/shocked_electric")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/shocked_bleet")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jacobshorn")
            inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
            inst:AddTag("monkey_king_charged")
            inst.AnimState:SetBuild("lightning_goat_shocked_build")
            inst.morph_charged_fx = SpawnPrefab("mk_charged_light")
            inst.morph_charged_fx.entity:SetParent(inst.entity)
            inst.morph_charged_fx.master = inst
            inst.morph_charged_fx.Transform:SetPosition(0,0,0)
            inst:ListenForEvent("attacked", inst.morph_charged_fx.onattacked)
            -- inst:ListenForEvent("daytime", function(inst)
            --     if inst:HasTag("monkey_king_charged") then
            --         inst.sg:GoToState("discharge")
            --     end
            -- end)
            -- inst.fx = SpawnPrefab("shock_fx")
            -- inst.fx.Transform:SetRotation(inst.Transform:GetRotation())
            -- local pos = inst:GetPosition()
            -- inst.fx.Transform:SetPosition(pos.x, pos.y, pos.z)
        end,

        onexit = function(inst)
            inst.AnimState:Show("fx")
            -- inst.fx:Remove()
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")            
            end),
        },
    }, 

    State{
        name = "discharge",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("trans")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/shocked_electric")
        end,
        
        timeline=
        {
            TimeEvent(18*FRAMES, function(inst) 
                inst.AnimState:Hide("fx") 
                inst.AnimState:SetBuild("lightning_goat_build")
                inst:RemoveTag("monkey_king_charged")
                inst.AnimState:ClearBloomEffectHandle()
            end)
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
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
    
return StateGraph("morph_goat", states, events, "idle", actionhandlers)

