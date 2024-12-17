require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events =
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,false),
    -- CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("doattack", function(inst)
        if inst.components.health and not inst.components.health:IsDead()
        and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then 
            inst.sg:GoToState("attack")
        end
    end),
    EventHandler("castspell", function(inst)
        if inst.components.health and not inst.components.health:IsDead() then
            inst.sg:GoToState("castspell")
        end
    end),
    EventHandler("armorbroke", function(inst, data)
        inst.sg:GoToState("armorbroke", data.armor)
    end),  
    EventHandler("ontalk", function(inst, data)
        if inst.components.wg_chatable and inst.sg:HasStateTag("idle") then
            inst.sg:GoToState("talk", data.noanim)
        end
    end),
    EventHandler("start_lunge", function(inst)
        if inst.components.health and not inst.components.health:IsDead() then
            inst.sg:GoToState("wg_lunge_pre")
        end
    end),
}

local function get_sound_path(inst)
    local sound_name = inst.soundsname or inst.prefab
    local path = inst.talker_path_override or "dontstarve/characters/"
    return path..sound_name
end

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
        name = "talk",
        tags = {"idle", "talking"},
        
        onenter = function(inst, noanim)
            -- inst.components.locomotor:Stop()
            if not noanim then
                inst.AnimState:PlayAnimation("dial_loop", true)
            end
            
            inst.SoundEmitter:PlaySound(get_sound_path(inst).."/talk_LP", "talk")
            
            inst.sg:SetTimeout(1.5 + math.random()*.5)
        end,
        
        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("talk")
            inst.sg:GoToState("idle") 
        end,
        
        onexit = function(inst)
            inst.SoundEmitter:KillSound("talk")
        end,
        
        events=
        {
            EventHandler("donetalking", function(inst) inst.sg:GoToState("idle") end),
        },
    }, 

    State{
        name = "castspell",
        tags = {"doing", "busy", "canrotate", "spell"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("staff") 
            local colourizefx = function(staff)
                return {1,1,1}
            end
            inst.components.locomotor:Stop()
            --Spawn an effect on the player's location
            inst.stafffx = SpawnPrefab("staffcastfx")            

            local pos = inst:GetPosition()
            inst.stafffx.Transform:SetPosition(pos.x, pos.y, pos.z)
            local colour = colourizefx()

            inst.stafffx.Transform:SetRotation(inst.Transform:GetRotation())
            inst.stafffx.AnimState:SetMultColour(colour[1], colour[2], colour[3], 1)
            inst.components.health:SetInvincible(true, "castspell")
        end,

        onexit = function(inst)
            inst.components.health:SetInvincible(nil, "castspell")
            if inst.stafffx then
                inst.stafffx:Remove()
            end
        end,

        timeline = 
        {
            TimeEvent(13*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_gemstaff") 
                if inst.castspell then
                    inst:castspell()
                end
            end),
            TimeEvent(0*FRAMES, function(inst)
                inst.stafflight = SpawnPrefab("staff_castinglight")
                local pos = inst:GetPosition()
                local colour = {1,1,1}
                inst.stafflight.Transform:SetPosition(pos.x, pos.y, pos.z)
                inst.stafflight.setupfn(inst.stafflight, colour, 1.9, .33)                
            end),
            TimeEvent(53*FRAMES, function(inst)  
            end),
            TimeEvent(60*FRAMES, function(inst) 
            end),            
        },
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle") 
            end ),
        },
    },

    State{
        name = "jump_pre",
        tags = {"doing", "busy"},
        onenter = function(inst, pos)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("jumpboat")
            inst.sg.statemem.startpos = inst:GetPosition()
            inst.sg.statemem.targetpos = inst:GetPosition()
            local target = inst.components.combat.target
            inst.sg.statemem.targetpos = pos
        end,
        onexit = function(inst)
            inst.components.locomotor:Stop()
        end,
        timeline = {
             TimeEvent(7*FRAMES, function(inst)
                if inst.sg.statemem.targetpos then
                    inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
                    local dist = inst:GetPosition():Dist(inst.sg.statemem.targetpos)
                    local speed = dist / (18/30)
                    inst.Physics:SetMotorVelOverride(1 * speed, 0, 0)
                end
            end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.targetpos then
                    inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
                end
                inst.Physics:Stop()
                inst.components.locomotor:Stop()
                inst.sg:GoToState("jump_pst")
            end),
        },
    },

    State{
        name = "jump_pst",
        tags = {"doing", "busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("land", false)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_to_land")
            PlayFootstep(inst)
        end,
        events = {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end)
        },
    },

    State{
        name = "armorbroke",
        tags = {"busy"},
        onenter = function(inst, armor)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_armour_break")
        end,
        onexit = function(inst)
        end,
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
            -- 这个是只有wilson，没有其他的
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
            -- inst.SoundEmitter:PlaySound(get_sound_path(inst).."/hurt")
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

    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit") 
            -- inst.SoundEmitter:PlaySound(get_sound_path(inst).."/hurt")
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

    State{
        name = "wg_lunge_pre",
        tags = {"busy", "not_hit_stunned"},
        onenter = function(inst)
            inst.Physics:Stop()
            local ba = inst:GetBufferedAction()
            if ba and ba.pos then
                inst:ForceFacePoint(ba.pos:Get())
            end
            inst.AnimState:AddOverrideBuild("player_lunge_wargon")
            PlayerAnimation(inst, "PlayAnimation", "lunge_pre")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw", "wg_lunge_pre")
        end,
        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                inst.sg:GoToState('wg_lunge')
            end),
        },
        events =
        {
            EventHandler("unequip", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    
    State{
        name = "wg_lunge",
        tags = {"doing", "busy", "canrotate", "not_hit_stunned"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            local speed = 28
            if inst:HasTag("far_lunge") then
                speed = speed + 10
            end
            inst.Physics:SetMotorVelOverride(speed, 0, 0)
            PlayerAnimation(inst, "PlayAnimation", "lunge_pst")
            inst:PerformBufferedAction()
            inst.SoundEmitter:KillSound("wg_lunge_pre")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
            if inst:HasTag("lunge_protect") then
                inst.components.health:SetInvincible(true, "wg_lunge")
            end
            ChangeToGhostPhysics(inst)
        end,
        timeline =
        {
            TimeEvent(7* FRAMES, function(inst)
                inst.Physics:ClearMotorVelOverride()
                inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                inst.AnimState:ClearOverrideBuild("player_lunge_wargon")
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            if inst:HasTag("lunge_protect") then
                inst.components.health:SetInvincible(nil, "wg_lunge")
            end
            ChangeToCharacterPhysics(inst)
            local weapon = inst.components.combat:GetWeapon()
            if weapon then
                weapon:PushEvent("weapon_stop_lunge", {owner=inst})
            end
            inst:PushEvent("stop_lunge", {weapon=weapon})
        end,
    },
}

CommonStates.AddFrozenStates(states)
CommonStates.AddSleepStates(states, nil, {
    onsleep = function(inst)
        inst.sg:GoToState("sleeping")
    end,
}, {
    sleep_pre = "sleep", 
    sleep_loop = "sleep", 
    sleep_pst = "wakeup"
})

return StateGraph("tp_npc", states, events, "idle", actionhandlers)

