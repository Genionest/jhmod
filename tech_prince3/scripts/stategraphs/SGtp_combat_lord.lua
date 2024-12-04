require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events =
{
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnStep(),
    -- CommonHandlers.OnLocomote(true,false),
    CommonHandlers.OnAttack(),
    -- CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
}

local states=
{
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)            
            inst.AnimState:Hide("swap_arm_carry")
            inst.AnimState:PlayAnimation("death")
        end,
    },
	
	State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("idle_loop", true)
        end,
    },

    State{
        name = "wait",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("idle_loop", true)
            inst.sg:SetTimeout(1.5)
        end,
        ontimeout = function(inst)
            inst.sg:GoToState("throw")
        end,
    },

    State{
        name = "wait2",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("idle_loop", true)
            inst.sg:SetTimeout(1.5)
        end,
        ontimeout = function(inst)
            inst.sg:GoToState("tp_ci_start")
        end,
    },
    
    State{
        name = "tp_ci_start",
        tags = {"busy"},
        onenter = function(inst)
            inst.AnimState:AddOverrideBuild("player_lunge_wargon")
            inst.AnimState:PlayAnimation("lunge_pre")
            if inst.components.combat.target then
                local target = inst.components.combat.target
                inst:ForceFacePoint(target:GetPosition())
            end
        end,
        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                inst.sg:GoToState('tp_ci')
            end),
        },
    },

    State{
        name = "tp_ci",
        tags = {"doing", "busy", "canrotate", "attack"},
        onenter = function(inst)
            RemovePhysicsColliders(inst)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
            -- inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.brain:Stop()
            inst.Physics:SetMotorVelOverride(30, 0, 0)
            -- if inst.components.combat.target then
            --     local target = inst.components.combat.target
            --     inst:ForceFacePoint(target:GetPosition())
            -- end
            -- inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("lunge_pst")
            -- inst:PerformBufferedAction()
        end,
        timeline =
        {
            TimeEvent(2*FRAMES, function(inst) 
                inst.components.combat:DoAttack() 
            end),
            TimeEvent(5*FRAMES, function(inst) 
                inst.components.combat:DoAttack() 
            end),
            TimeEvent(7* FRAMES, function(inst)
                inst.Physics:ClearMotorVelOverride()
                ChangeToCharacterPhysics(inst)
                -- inst.components.locomotor:EnableGroundSpeedMultiplier(true)
                inst.sg:RemoveStateTag("attack")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.AnimState:ClearOverrideBuild("player_lunge_wargon")
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("wait")
                    -- inst.sg:GoToState("throw")
                    -- inst:RemoveTag("tp_combat_lord_lunge")
                end
            end),
        },

        onexit = function(inst)
            inst.brain:Start()
            inst.Physics:ClearMotorVelOverride()
            -- inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end,
    },    

    State{
        name = "tp_tou_start",
        tags = { "aoe", "doing", "busy", "nointerrupt", "nomorph"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("superjump_pre")
            -- inst.AnimState:PushAnimation("superjump_lag", false)
            RemovePhysicsColliders(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("tp_tou")
            end),
        },

        onexit = function(inst)
        end,
    },

    State{
        name = "tp_tou",
        tags = { "aoe", "doing", "busy", "nointerrupt", "nopredict", "nomorph"},

        onenter = function(inst, data)
            inst.components.health:SetInvincible(true)
            inst.AnimState:PlayAnimation("superjump")
            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("tp_tou_pst")
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetInvincible(true)
                inst.DynamicShadow:Enable(false)
            end),
        },
    },

    State{
        name = "tp_tou_pst",
        tags = { "aoe", "doing", "busy", "noattack", "nopredict", "nomorph"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("superjump_land")
            if inst.components.combat.target then
                local target = inst.components.combat.target
                inst.Transform:SetPosition(target:GetPosition():Get())
            end
            inst.sg:SetTimeout(22 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("noattack")
                inst.components.health:SetInvincible(false)
                -- inst:PerformBufferedAction()
                -- inst.components.groundpounder:GroundPound()
                inst.components.combat:DoAttack()
                ChangeToCharacterPhysics(inst)
            end),
            TimeEvent(19 * FRAMES, PlayFootstep),
        },

        ontimeout = function(inst)
            -- inst.sg:GoToState("tp_ci_start", true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("wait2")
                    -- inst.sg:GoToState("tp_ci_start")
                    -- inst:AddTag("tp_combat_lord_lunge")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            inst.DynamicShadow:Enable(true)
            inst.components.health:SetInvincible(false)
        end,
    },

    State{
        name = "throw",
        tags = {"busy", "attack"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            -- inst.components.combat:StartAttack()
            local target = inst.components.combat.target
            if target then
                inst:ForceFacePoint(target:GetPosition():Get())
            end
            inst.AnimState:PlayAnimation("atk", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end,
        timeline = {
            TimeEvent(8*FRAMES, function(inst)
                local target = inst.components.combat.target
                if target then
                    local proj = SpawnPrefab("tp_combat_lord_proj")
                    proj.Transform:SetPosition(inst:GetPosition():Get())
                    proj.components.wg_projectile:Throw(inst, target)
                    inst.AnimState:Hide("ARM_carry")
                    inst.AnimState:Show("ARM_normal")
                    inst.AnimState:ClearOverrideSymbol("swap_object")
                    -- 变回近战，近战不扔长矛
                    inst:AddTag("spear_thrown")
                    -- throw_over(inst)
                    -- inst.components.combat:SetRange(3, 3)
                    -- inst:RemoveTag("want_throw")
                end
            end)
        },
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
                -- inst.sg:GoToState("tp_ci_start")
            end)
        },
        onexit = function(inst)
            -- inst.sg:GoToState("tp_tou")
        end,
    },

    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            
            inst.components.combat:StartAttack()
            -- if inst:HasTag("tp_combat_lord_lunge") then
            --     inst.sg:GoToState("tp_ci_start")
            -- else
            local n = math.random()
            if n < .33 then
                inst.sg:GoToState("tp_tou_start")
            elseif n < .67 then
                inst.sg:GoToState("tp_ci_start")
            else
                inst.sg:GoToState("throw")
            end
            -- end
            -- inst.Physics:Stop()
            -- inst.AnimState:PlayAnimation("atk")
            -- inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end,
        
        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) 
            	inst.components.combat:DoAttack() 
            end),
            TimeEvent(12*FRAMES, function(inst) 
				inst.sg:RemoveStateTag("busy")
				inst.sg:RemoveStateTag("attack")
			end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
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
	    
		timeline = 
		{
		    TimeEvent(4*FRAMES, PlayFootstep ),
		    TimeEvent(5*FRAMES, PlayFootstep ),
		},

		events=
		{   
			EventHandler("animover", function(inst) 
                inst.sg:GoToState("run") 
            end ),        
		},
	},
    
	State{
		name = "run",
		tags = {"moving", "running", "canrotate"},
	    
		onenter = function(inst) 
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("run_loop")
		end,
		
		events=
		{   
			EventHandler("animover", function(inst) 
                inst.sg:GoToState("run") 
            end ),        
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
			EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle") 
            end ),        
		},
	},
	
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit") 
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle") 
            end ),
        },        
    },    
}
    
CommonStates.AddFrozenStates(states)

return StateGraph("tp_combat_lord", states, events, "idle", actionhandlers)

