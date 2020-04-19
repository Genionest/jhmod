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
            inst.AnimState:PlayAnimation("idle_loop", true)
        end,
    },
    State{
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst)
            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop",true)
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
            inst.AnimState:PlayAnimation("idle_loop",true)
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
            inst.AnimState:PlayAnimation("idle_loop")
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
            inst.AnimState:PlayAnimation("idle_loop",true)
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
}
CommonStates.AddSimpleWalkStates(states, "idle_loop")
CommonStates.AddSimpleRunStates(states, "idle_loop")

--return StateGraph("fireelemental", states, events, "idle")

return StateGraph("buling_glomling", states, events, "idle",actionhandlers)
