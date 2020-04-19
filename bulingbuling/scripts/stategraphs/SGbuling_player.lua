require("stategraphs/commonstates")

local actionhandlers =
{  

	ActionHandler(ACTIONS.PICKUP, "steal"),
	ActionHandler(ACTIONS.PICK, "steal"),
	ActionHandler(ACTIONS.HARVEST, "steal"),
	ActionHandler(ACTIONS.GIVE, "give"),
	ActionHandler(ACTIONS.HAMMER, "hammer"),
    ActionHandler(ACTIONS.CHOP, 
        function(inst)
            if not inst.sg:HasStateTag("prechop") then 
                if inst.sg:HasStateTag("chopping") then
                    return "chop"
                else
                    return "chop_start"
                end
            end 
        end),
	ActionHandler(ACTIONS.DIG, 
        function(inst)
            if not inst.sg:HasStateTag("predig") then 
                if inst.sg:HasStateTag("digging") then
                    return "dig"
                else
                    return "dig_start"
                end
            end 
        end),
    ActionHandler(ACTIONS.MINE, 
        function(inst) 
            if not inst.sg:HasStateTag("premine") then 
                if inst.sg:HasStateTag("mining") then
                    return "mine"
                else
                    return "mine_start"
                end
            end 
        end),
	ActionHandler(ACTIONS.HACK, 
        function(inst) 
            if not inst.sg:HasStateTag("prehack") then
                if inst.sg:HasStateTag("hacking") then
                    return "hack"
                else
                    return "hack_start"
                end
            end
        end),
	ActionHandler(ACTIONS.EAT, 
        function(inst, action)
            if inst.sg:HasStateTag("busy") then
                return nil
            end
            local obj = action.target or action.invobject
            if not (obj and obj.components.edible) then
                return nil
            end
            
            if obj.components.edible.foodtype == "MEAT" then
                return "eat"
            else
                return "eat"
            end
        end),
	 ActionHandler(ACTIONS.GOHOME, "action"),
	 
}

local events = 
{
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttack(),
}

local states =
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, pushanim)    
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop", true)
        end,
    },

    State{
        name = "run_start",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst)
			inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_pre")
            inst.sg.mem.foosteps = 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
        
        timeline=
        {        
            TimeEvent(4*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
            end),
        },        
        
    },

    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst) 
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_loop")
            
        end,
        
        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline=
        {
            TimeEvent(7*FRAMES, function(inst)
				inst.sg.mem.foosteps = inst.sg.mem.foosteps + 1
                inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
            end),
            TimeEvent(15*FRAMES, function(inst)
				inst.sg.mem.foosteps = inst.sg.mem.foosteps + 1
                inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
            end),
        },
        
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
    },
    
    State{
    
        name = "run_stop",
        tags = {"canrotate", "idle"},
        
        onenter = function(inst) 
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("run_pst")
        end,
        
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },
        
    },
	State{
        name = "steal",
        tags = {"busy"},

        onenter = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/krampus/growllong")

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pickup")
            --inst.AnimState:PushAnimation("steal", false)
        end,
        
		timeline=
        {
			
			TimeEvent(5*FRAMES, function(inst) inst:PerformBufferedAction() end),
			TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/krampus/growllong") end),
        },
        
        
		events=
        {
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },        
    },
    State{
        name = "attack",
        tags = {"attack", "notalking", "abouttoattack", "busy"},
        
        onenter = function(inst)
            inst.equipfn(inst, inst.items["SWORD"])        

            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
            
            if inst.components.combat.target then
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
                end
            end
            
        end,
        
        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) inst.sg:RemoveStateTag("abouttoattack") end),
            TimeEvent(12*FRAMES, function(inst) 
                inst.sg:RemoveStateTag("busy")
            end),               
            TimeEvent(13*FRAMES, function(inst)
                if not inst.sg.statemem.slow then
                    inst.sg:RemoveStateTag("attack")
                end
            end),
            TimeEvent(24*FRAMES, function(inst)
                if inst.sg.statemem.slow then
                    inst.sg:RemoveStateTag("attack")
                end
            end),           
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },
    },  
	State{
        name = "hammer",
        tags = {"busy"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
			inst.equipfn(inst, inst.items["HAMMER"])   
            inst.AnimState:PlayAnimation("pickaxe_pre")
			inst.AnimState:PushAnimation("pickaxe_loop",false)
        end,

        timeline=
        {

            TimeEvent(0*FRAMES, function(inst)  inst.SoundEmitter:PlaySound("dontstarve/creatures/krampus/attack") end),
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/krampus/kick_whoosh") end),
            TimeEvent(18*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/krampus/kick_impact") end),
            
        },

        events=
        {
            EventHandler("animqueueover", function(inst)inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:Hide("swap_arm_carry")
            inst.AnimState:PlayAnimation("death")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst:DoTaskInTime(1, function() 
                    SpawnPrefab("statue_transition").Transform:SetPosition(inst:GetPosition():Get())
                    SpawnPrefab("statue_transition_2").Transform:SetPosition(inst:GetPosition():Get())
                    inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_despawn")
                    inst:Remove()
                end)
            end ),
        },
    },  
   
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("hit")
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
        name = "stunned",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst:ClearBufferedAction()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_sanity_pre")
            inst.AnimState:PushAnimation("idle_sanity_loop", true)
            inst.sg:SetTimeout(5)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

        State{ name = "chop_start",
        tags = {"prechop", "chopping", "working"},
        onenter = function(inst)
            inst.equipfn(inst, inst.items["AXE"])
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("chop_pre")

        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("chop") end),
        },
    },
    
    State{
        name = "chop",
        tags = {"prechop", "chopping", "working"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("chop_loop")        
        end,

        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) 
                    inst:PerformBufferedAction() 
            end),

            TimeEvent(9*FRAMES, function(inst)
                    inst.sg:RemoveStateTag("prechop")
            end),

            TimeEvent(16*FRAMES, function(inst) 
                inst.sg:RemoveStateTag("chopping")
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end ),            
        },        
    },
	State{
        name = "eat",
        tags ={"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            local is_gear = inst:GetBufferedAction() and inst:GetBufferedAction().invobject and inst:GetBufferedAction().invobject.components.edible and inst:GetBufferedAction().invobject.components.edible.foodtype == "GEARS"

            if not is_gear then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")    
            end
            
            inst.AnimState:PlayAnimation("eat")
        end,

        timeline=
        {
            
            TimeEvent(28*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
            end),
            
            TimeEvent(30*FRAMES, function(inst) 
                inst.sg:RemoveStateTag("busy")
            end),
            
            TimeEvent(70*FRAMES, function(inst) 
	            inst.SoundEmitter:KillSound("eating")    
	        end),
            
        },        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
        
        onexit= function(inst)
            inst.SoundEmitter:KillSound("eating")    
        end,
    },    

    State{ 
        name = "mine_start",
        tags = {"premine", "working"},
        onenter = function(inst)
            inst.equipfn(inst, inst.items["PICK"])
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("mine") end),
        },
    },
	State {
        name = "give",
        tags = { "doing", "busy", "working" },
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
        end,
        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
	 State{
        
        name = "action",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("give", true)
            inst:PerformBufferedAction()
        end,
        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    },
    
    State{
        name = "mine",
        tags = {"premine", "mining", "working"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("pickaxe_loop")
        end,

        timeline=
        {
            TimeEvent(9*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
                inst.sg:RemoveStateTag("premine") 
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_pick_rock")
            end),          
        },
        
        events=
        {
            EventHandler("animover", function(inst) 
                inst.AnimState:PlayAnimation("pickaxe_pst") 
                inst.sg:GoToState("idle", true)
            end ),            
        },        
    },
	State{ name = "dig_start",
        tags = {"predig", "working", "digging"},
        onenter = function(inst)
			inst.equipfn(inst, inst.items["SHOVEL"])
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("shovel_pre")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("dig") end),
        },
    },
    State{
        name = "dig",
        tags = {"predig", "digging", "working"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("shovel_loop")
        end,

        timeline=
        {
            TimeEvent(9*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
                inst.sg:RemoveStateTag("predig") 
                inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
            end),          
        },
        
        events=
        {
            EventHandler("animover", function(inst) 
                inst.AnimState:PlayAnimation("shovel_pst")
                inst.sg:GoToState("idle", true)
            end ),            
        },        
    },
	State{ name = "hack_start",
        tags = {"prehack", "hacking", "working"},
        onenter = function(inst)
			inst.equipfn(inst, inst.items["HACK"])
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("chop_pre")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("hack") end),
        },
    },
    State{
        name = "hack",
        tags = {"prehack", "hacking", "working"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("chop_loop")
        end,

        timeline=
        {
            TimeEvent(9*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
                inst.sg:RemoveStateTag("prehack") 
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_pick_rock")
            end),          
        },
        
        events=
        {
            EventHandler("animover", function(inst) 
                inst.AnimState:PlayAnimation("pickaxe_pst") 
                inst.sg:GoToState("idle", true)
            end ),            
        },        
    },
}

return StateGraph("shadowmaxwell", states, events, "idle", actionhandlers)