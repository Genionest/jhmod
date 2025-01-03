require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events =
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("giveuptarget", function(inst, data) if data.target then inst.sg:GoToState("howl") end end),
    EventHandler("newcombattarget", function(inst, data)
        if data.target and not inst.sg:HasStateTag("busy") then
            if math.random() < 0.3 then
                inst.sg:GoToState("howl")
            else
                inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/idle")
            end
        end
    end),
}

local states=
{


	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/grunt")
            inst.AnimState:PlayAnimation("defeat")
            inst.AnimState:PushAnimation("defeat_idle_pre", false)
            inst.AnimState:PushAnimation("defeat_idle_loop")
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },
    
    State{
		name = "howl",
		tags = {"busy"},
		
		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("taunt")
			inst:spawn_werepig()
			inst.atk_num = 0
		end,
		
		timeline = 
		{
			TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/howl") end),
		},
		
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
	},
	
	State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)
        end,
    },
    
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.Physics:SetMotorVelOverride(10, 0, 0)
            inst.AnimState:PlayAnimation("atk3")
            inst.AnimState:PushAnimation("atk3_pst", false)
            inst.atk_num = inst.atk_num + 1
        end,
        
        timeline=
        {
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/attack") end),
            TimeEvent(12*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            TimeEvent(14*FRAMES, function(inst)
                inst.Physics:ClearMotorVelOverride()
            end),
        },
        -- onexit = function(inst)
		-- 	inst.Physics:ClearMotorVelOverride()
		-- end,
        events=
        {
            EventHandler("animqueueover", function(inst)
                if not inst.components.combat.target and math.random() < 0.3 then
                    inst.sg:GoToState("howl")
                elseif inst.atk_num >= 3 then
                	inst.sg:GoToState('howl')
                else
                    inst.sg:GoToState("idle")
                end
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
        timeline={
            TimeEvent(0*FRAMES, PlayFootstep),
        },
		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
		},
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
		    TimeEvent(9*FRAMES, PlayFootstep ),
		    TimeEvent(22*FRAMES, PlayFootstep ),
		},
		
		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
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
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
		},
	},

	State{
		name = "walk_start",
		tags = {"moving", "canrotate"},
	    
		onenter = function(inst) 
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("run_pre")
		end,
        timeline={
            TimeEvent(0*FRAMES, PlayFootstep),
        },
		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
		},
	},
    
	State{
		name = "walk",
		tags = {"moving", "canrotate"},
	    
		onenter = function(inst) 
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("run_loop")
		end,
	    
		timeline = 
		{
		    TimeEvent(9*FRAMES, PlayFootstep ),
		    TimeEvent(22*FRAMES, PlayFootstep ),
		},
		
		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
		},
	},
        
	State{
		name = "walk_stop",
		tags = {"canrotate"},
	    
		onenter = function(inst) 
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("run_pst")
		end,
		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
		},
	},

	-- State{
	-- 	name = "walk_start",
	-- 	tags = {"moving", "canrotate"},
	    
	-- 	onenter = function(inst) 
    --         inst:CreateHead()
	-- 		inst.components.locomotor:WalkForward()
	-- 		inst.AnimState:PlayAnimation("walk_pre")
	-- 	end,
    --     timeline={
    --         TimeEvent(0*FRAMES, PlayFootstep),
    --     },
	-- 	events=
	-- 	{   
	-- 		EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
	-- 	},
	-- },
        
	-- State{
	-- 	name = "walk",
	-- 	tags = {"moving", "canrotate"},
	    
	-- 	onenter = function(inst) 
	-- 		inst.components.locomotor:WalkForward()
	-- 		inst.AnimState:PlayAnimation("walk_loop")
	-- 	end,
		
	-- 	timeline = 
	-- 	{
	-- 	    TimeEvent(19*FRAMES, PlayFootstep),
	-- 	    TimeEvent(43*FRAMES, PlayFootstep),
	-- 	},
		
	-- 	events=
	-- 	{   
	-- 		EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
	-- 	},
	-- },

	-- State{
	-- 	name = "walk_stop",
	-- 	tags = {"canrotate"},
	    
	-- 	onenter = function(inst) 
	-- 		inst.Physics:Stop()
	-- 		inst.AnimState:PlayAnimation("walk_pst")
	-- 	end,
	-- 	onexit = function(inst)
    --         inst:RemoveHead()
    --     end,
	-- 	events=
	-- 	{   
	-- 		EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
	-- 	},
	-- },

    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/hurt")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },    
}
    
return StateGraph("tp_werepig_king", states, events, "idle", actionhandlers)

