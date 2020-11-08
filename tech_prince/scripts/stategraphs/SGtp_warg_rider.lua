require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events =
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,false),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
}

local function anim_play(inst, data)
    if data[1] == "push" then
        inst.AnimState:PushAnimation(data[2], data[3])
    else
        inst.AnimState:PlayAnimation(data[2], data[3])
    end
end

local function warg_anim(inst, data1, data2)
    if data1 and inst.warg_rider then
        anim_play(inst.warg_rider, data1)
    end
    if data2 and inst.warg_head then
        anim_play(inst.warg_head, data2)
    end
end

local states=
{


	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            if inst.task then
                inst.task:Cancel()
                inst.task = nil
            end
            -- inst.AnimState:PlayAnimation("fall_off")
            if inst.warg_rider then
                inst.warg_rider:Remove()
                inst.warg_rider = nil
            end
            if inst.warg_head then
                inst.warg_head:Remove()
                inst.warg_head = nil
            end
            local anim = inst.AnimState
            anim:Show("beefalo_head")
            anim:Show("beefalo_antler")
            anim:Show("beefalo_body")
            anim:Hide("beefalo_hoof")
            anim:Hide("beefalo_tail")
            anim:Hide("beefalo_facebase")
            anim:Hide("beefalo_mouth")
            anim:Hide("beefalo_eye")
            inst.AnimState:PlayAnimation("death")
            -- warg_anim({"play", "fall_off"}, {"play", "death"})
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount") 
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        -- events =
        -- {
        --     EventHandler("animover", function(inst)
                -- inst.sg:GoToState("death_pst")
        --     end ),
        -- } 
    },

    -- State{
    --     name = "death_pst",
    --     tags = {"busy"},
        
    --     onenter = function(inst)
    --         inst.components.locomotor:Stop()
    --         inst.AnimState:SetBuild("wilson")
    --         inst.AnimState:Hide("swap_arm_carry")
    --         inst.AnimState:PlayAnimation("death")
    --         local beefalo = WARGON.make_spawn(inst, 'beefalo')
    --         beefalo.components.health:Kill()
    --     end,
    -- },

    State{
		name = "bellow",
		tags = {"busy"},
		
		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("howl")
            warg_anim(inst, {"play", "bellow"}, {"play", "howl"})
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/vargr/howl")
            -- inst.SoundEmitter:PlaySound("dontstarve/beefalo/grunt")
            local target = nil
            if inst.components.combat and inst.components.combat.target then
                target = inst.components.combat.target
            end
            if not target then
                target = inst
            end
			inst:StartThread(function()
                for i = 1, 3 do
                    local pos = Vector3(target.Transform:GetWorldPosition())
                    GetSeasonManager():DoLightningStrike(pos, false, target) 
                    Sleep(.33)
                end
            end)
   --          if c_find("tp_fx_sign_killer") == nil then
   --              WARGON.make_fx(target, "tp_fx_sign_killer")
   --          end
			inst.atk_num = 0
		end,
		
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
	},
	
	State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("idle_loop", true)
            warg_anim(inst, {"push", "idle_loop", true}, {"push", "idle_loop", true})
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/vargr/idle")
        end,
    },
    
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            -- inst.AnimState:PlayAnimation("atk")
            inst.AnimState:PlayAnimation("idle_loop")
            -- warg_anim(inst, {"play", "player_atk_pre"}, {"play", "atk"})
            warg_anim(inst, {"play", "player_atk_pre"}, {"play", "idle_loop"})
            warg_anim(inst, {"push", "player_atk", false}, nil)
            -- inst.AnimState:PlayAnimation("player_atk_pre")
            -- inst.AnimState:PushAnimation("player_atk", false)
            -- inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            inst.atk_num = inst.atk_num + 1
            inst.sg:SetTimeout(1)
        end,
        
        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/vargr/attack") 
            end),
            TimeEvent(8*FRAMES, function(inst) 
            	inst.components.combat:DoAttack() 
            end),
            -- TimeEvent(12*FRAMES, function(inst) 
            --     inst.components.combat:DoAttack() 
            -- end),
            TimeEvent(13*FRAMES, function(inst) 
				inst.sg:RemoveStateTag("busy")
				inst.sg:RemoveStateTag("attack")
			end),
        },

        ontimeout = function(inst)
            if inst.atk_num >= 5 then
                inst.sg:GoToState('bellow')
            else
                inst.sg:GoToState("idle")
            end
        end,
        
        events=
        {
            -- EventHandler("animqueueover", function(inst)
            EventHandler("animover", function(inst)
                if inst.atk_num >= 5 then
                	inst.sg:GoToState('bellow')
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
            warg_anim(inst, {"play", "run_pre"}, {"play", "run_pre"})
		end,
	    
		timeline = 
		{
		    TimeEvent(4*FRAMES, PlayFootstep ),
		    TimeEvent(5*FRAMES, PlayFootstep ),
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
            warg_anim(inst, {"play", "run_loop"}, {"play", "run_loop"})
		end,
		
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
            warg_anim(inst, {"play", "run_pst"}, {"play", "run_pst"})
		end,
	    
		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
		},
	},
	
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit") 
            inst.AnimState:PlayAnimation("hit")
            warg_anim(inst, {"play", "hit"}, {"play", "hit"})
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },    
}
    
return StateGraph("tp_warg_rider", states, events, "idle", actionhandlers)

