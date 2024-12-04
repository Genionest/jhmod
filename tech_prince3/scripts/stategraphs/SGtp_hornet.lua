local EntUtil = require "extension.lib.ent_util"

require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events =
{
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,false),
    -- CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("doattack", function(inst)
        if inst.components.health and not inst.components.health:IsDead()
        and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
            if inst:HasTag("want_throw") then
                inst.sg:GoToState("throw")
            else
                if math.random() < .33 then
                    -- if math.random() < .5 then
                        inst.sg:GoToState("stand_aoe")
                    -- else
                        -- inst.sg:GoToState("throw")
                    -- end
                else
                    inst.sg:GoToState("attack")
                end
            end
        end
    end)
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
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
            -- inst.AnimState:PlayAnimation("player_atk_pre")
            -- inst.AnimState:PushAnimation("player_atk", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
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
                if math.random() < .5 then
                    -- 下次长矛，变成远程
                    inst:AddTag("want_throw")
                    inst.components.combat:SetRange(10, 12)
                end
            end ),
        },
    },

    State{
        name = "stand_aoe",
        tags = {"attack", "busy"},
        onenter = function(inst)
            -- inst.components.playercontroller:Enable(false)
            inst.AnimState:PlayAnimation("staff") 
            -- local colourizefx = function(staff)
            --     return staff.fxcolour or {1,1,1}
            -- end
            inst.components.locomotor:Stop()
            --Spawn an effect on the player's location
            inst.stafffx = SpawnPrefab("staffcastfx")            

            local pos = inst:GetPosition()
            -- local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.stafffx.Transform:SetPosition(pos.x, pos.y, pos.z)
            -- local colour = colourizefx(staff)
            local colour = {1,1,1}
            inst.stafffx.Transform:SetRotation(inst.Transform:GetRotation())
            inst.stafffx.AnimState:SetMultColour(colour[1], colour[2], colour[3], 1)
        end,
        onexit = function(inst)
            -- inst.components.playercontroller:Enable(true)
            if inst.stafffx then
                inst.stafffx:Remove()
            end
        end,
        timeline = 
        {
            TimeEvent(0*FRAMES, function(inst)
                inst.stafflight = SpawnPrefab("staff_castinglight")
                -- local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                local pos = inst:GetPosition()
                -- local colour = staff.fxcolour or {1,1,1}
                local colour = {1,1,1}
                inst.stafflight.Transform:SetPosition(pos.x, pos.y, pos.z)
                inst.stafflight.setupfn(inst.stafflight, colour, 1.9, .33)                

            end),
            TimeEvent(20*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_gemstaff") 
                EntUtil:make_area_dmg2(inst, 4, inst, 30, nil, 
                    EntUtil:add_stimuli(nil, "spike"))
                -- local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                -- if staff and staff.castfast then
                --     inst:PerformBufferedAction()
                -- end
            end),
            TimeEvent(40*FRAMES, function(inst) 
                EntUtil:make_area_dmg2(inst, 4, inst, 30, nil, 
                    EntUtil:add_stimuli(nil, "spike"))
                    -- local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    -- if not staff or not staff.castfast then
                    --     inst:PerformBufferedAction() 
                    -- end
                end),

            TimeEvent(60*FRAMES, function(inst) 
                EntUtil:make_area_dmg2(inst, 4, inst, 30, nil, 
                    EntUtil:add_stimuli(nil, "spike"))
                    -- local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    -- if staff and staff.endcast then
                    --     staff.endcast(staff)
                    -- end
                end),            
        },
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle") 
            end ),
        },
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
            inst.AnimState:PlayAnimation("atk")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end,
        timeline = {
            TimeEvent(8*FRAMES, function(inst)
                local target = inst.components.combat.target
                if target then
                    local proj = SpawnPrefab("tp_hornet_proj")
                    proj.Transform:SetPosition(inst:GetPosition():Get())
                    proj.components.wg_projectile:Throw(inst, target, inst)
                    inst.AnimState:Hide("ARM_carry")
                    inst.AnimState:Show("ARM_normal")
                    inst.AnimState:ClearOverrideSymbol("swap_object")
                    -- 变回近战，近战不扔长矛
                    inst.components.combat:SetRange(3, 3)
                    inst:RemoveTag("want_throw")
                    inst:AddTag("spear_thrown")
                end
            end)
        },
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end)
        },
    },
    
    State{
        name = "tp_hua_start",
        tags = {"busy", "evade","no_stun","canrotate"},
        onenter = function(inst)
            -- local ba = inst:GetBufferedAction()
            -- if ba and ba.pos then
            --     inst:ForceFacePoint(ba.pos)
            -- end
            -- inst:PerformBufferedAction()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("slide_pre")
            inst:start_slide()
        end,
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("tp_hua")
            end),
        },
    },

    State{
        name = "tp_hua",
        tags = {"busy", "evade","no_stun", "runing", "moving"},
        onenter =   function(inst)
            inst.AnimState:PushAnimation("slide_loop")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
            -- inst.Physics:SetMotorVelOverride(20,0,0)
            inst.components.locomotor.runspeed = inst:HasTag("tp_hornet_fast") and 30 or 20
            inst.components.locomotor:RunForward()
            -- inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.components.health:SetInvincible(true)
        end,
        events = {
            EventHandler("animover", function(inst)
                inst.components.health:SetInvincible(false)
                inst.sg:GoToState("tp_hua_pst")
            end),
        },
        onexit = function(inst)
            -- inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            -- inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:Stop()
            
            inst.components.locomotor:SetBufferedAction(nil)
            inst.components.health:SetInvincible(false)
            inst.components.locomotor.runspeed = 6
        end,
    },

    State{
        name = "tp_hua_pst",
        tags = {"evade","no_stun"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("slide_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst:stop_slide()
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
            -- inst.AnimState:PlayAnimation("slide_pre")
        end,
        
        timeline = 
        {
            TimeEvent(4*FRAMES, PlayFootstep ),
            TimeEvent(5*FRAMES, PlayFootstep ),
        },

        events=
        {   
            EventHandler("animover", function(inst) 
                if inst.components.combat.target 
                and inst.components.combat:InCooldown() then
                    inst.sg:GoToState("tp_hua_start")
                else
                    inst.sg:GoToState("run") 
                end
            end ),        
		},
	},
    
	State{
		name = "run",
		tags = {"moving", "running", "canrotate"},
	    
		onenter = function(inst) 
			inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_loop")
			-- inst.AnimState:PlayAnimation("slide_loop")
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
			-- inst.AnimState:PlayAnimation("slide_pst")
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

return StateGraph("tp_hornet", states, events, "idle", actionhandlers)

