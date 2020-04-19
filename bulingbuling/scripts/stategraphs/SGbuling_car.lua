require("stategraphs/commonstates")
--感谢班花的sg支援
local events =
{
    --CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttack(),
	CommonHandlers.OnAttacked(),
	EventHandler("locomote", function(inst) 
        if not inst.sg:HasStateTag("busy") then
            
            local is_moving = inst.sg:HasStateTag("moving")
            local wants_to_move = inst.components.locomotor:WantsToMoveForward()
            if not inst.sg:HasStateTag("attack") and is_moving ~= wants_to_move then
                if wants_to_move then
                    inst.sg:GoToState("walk_start")
                else
                    inst.sg:GoToState("idle")
                end
            end
        end
    end),
	EventHandler("dismount",
        function(inst)
            if not inst.sg:HasStateTag("dismounting") then
                inst.sg:GoToState("dismount")
            end
        end),
}
local actionhandlers =
{  
ActionHandler(ACTIONS.GOHOME, "idle"),
ActionHandler(ACTIONS.DISMOUNT, "dismount"),
}
local states =
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle")
        end,
    },
    State{
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst)
            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle")
            if inst.components.combat.target ~= nil and inst.components.combat.target:IsValid() then
                inst:FacePoint(inst.components.combat.target.Transform:GetWorldPosition())
            end
        end,
        timeline =
        {
			TimeEvent(8*FRAMES, function(inst)
            end),
            TimeEvent(10*FRAMES, function(inst)
                inst.sg:RemoveStateTag("abouttoattack")
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
            TimeEvent(20*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    State{
        name = "hit",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle")
            inst.Physics:Stop()            
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },
	State{
        name = "dismount",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle")
            inst.Physics:Stop() 
			GetPlayer().components.driver:OnDismount(false, Vector3(TheInput:GetWorldPosition():Get()))
        end,
        events=
        {	
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") 
			end ),
        },
    },
    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle")
            RemovePhysicsColliders(inst)   
			if inst.components.lootdropper then
				inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))  
			end
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst:Remove()
                end
            end),
        },
    },
	   --[[ State{
        name = "walk_start",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pre")
			
        end,
		 timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                inst.components.locomotor:WalkForward()
            end),
        },


        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("walk")
                end
            end),
        },
    },
	    State{
        name = "walk",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_loop", false)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("walk")
        end,
    },
    State{  name = "walk_stop",
            tags = {"canrotate", "idle"},
            
            onenter = function(inst) 
                inst.SoundEmitter:KillSound("walk_pst")
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("idle", false)
            end,

            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
            },
        },    ]]
}
CommonStates.AddSimpleWalkStates(states, "idle")
CommonStates.AddSimpleRunStates(states, "idle")

--return StateGraph("fireelemental", states, events, "idle")

return StateGraph("buling_glomling", states, events, "idle",actionhandlers)
