local function add_sg(name, state)
    GLOBAL.WARGON_SG_EX.add_sg_state(name, state)
end

local function add_player_sg(state)
	GLOBAL.WARGON_SG_EX.add_sg_state("wilson", state)
	GLOBAL.WARGON_SG_EX.add_sg_state("wilsonboating", state)
end

local function add_player_sg_post(sg)
	GLOBAL.WARGON_SG_EX.add_sg_post("wilson", sg)
	GLOBAL.WARGON_SG_EX.add_sg_post("wilsonboating", sg)
end

add_player_sg(State{
	name = "science_morph",
	tags = {"busy"},
	onenter = function(inst)
		inst:PerformBufferedAction()

		inst.components.locomotor:Stop()
        inst.Physics:Stop()
        inst.AnimState:PlayAnimation("idle_inaction_sanity")
        WARGON.make_fx(inst, "boat_death")
    end,
    timeline=
    {
        TimeEvent(13*FRAMES, function(inst)
            WARGON.make_fx(inst, "beefalo_transform_fx")
        end),
    },
	events = {
		EventHandler("animover", function(inst)
			inst.sg:GoToState("idle")
		end),
	},
})

add_player_sg(State{
    name = "science_morph2",
    tags = {"busy"},
    onenter = function(inst)

        inst.components.locomotor:Stop()
        inst.Physics:Stop()
        inst.AnimState:PlayAnimation("idle_inaction_sanity")

        WARGON.make_fx(inst, "boat_death")
    end,
    timeline=
    {
        TimeEvent(12*FRAMES, function(inst)
            WARGON.make_fx(inst, "beefalo_transform_fx")
        end),
    },
    events = {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
})

add_player_sg(State{
	name = "tp_call_beast",
	tags = {"busy"},
	onenter = function(inst)
		inst:PerformBufferedAction()

        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("flute")
        inst.AnimState:OverrideSymbol("pan_flute01", "pan_flute",  "pan_flute01")
        inst.AnimState:Hide("ARM_carry") 
        inst.AnimState:Show("ARM_normal")
    end,
    onexit = function(inst)
        inst.SoundEmitter:KillSound("flute")
        if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
            inst.AnimState:Show("ARM_carry")
            inst.AnimState:Hide("ARM_normal")
        end
    end,
    timeline=
    {
        TimeEvent(30*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/flute_LP", "flute")
        end),
        TimeEvent(85*FRAMES, function(inst)
            inst.SoundEmitter:KillSound("flute")
        end),
    },
    events=
    {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
})

add_player_sg(State{
	name = "tp_spawn",
	tags = {"busy"},
	onenter = function(inst)
		inst:PerformBufferedAction()

		inst.AnimState:PlayAnimation("dial_loop")
	end,
	events={
		EventHandler("animover", function(inst)
			inst.sg:GoToState("idle")
		end),
	},
})

add_player_sg(State{
    name = "tp_reng",
    tags = {"busy"},
    onenter = function(inst)
        inst.AnimState:PlayAnimation("atk")
    end,
    events={
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
    timeline={
        TimeEvent(8*FRAMES, function(inst)
            inst:PerformBufferedAction()
        end),
        TimeEvent(12*FRAMES, function(inst) 
            inst.sg:RemoveStateTag("busy")
        end),   
    },
})

add_player_sg(State{
    name = "tp_tou",
    tags = {"busy"},
    onenter = function(inst)
        inst.AnimState:PlayAnimation("atk")
    end,
    timeline={
        TimeEvent(8*FRAMES, function(inst)
            inst:PerformBufferedAction()
        end),
        TimeEvent(12*FRAMES, function(inst) 
            inst.sg:RemoveStateTag("busy")
        end),   
    },
})

add_sg("wilson", State{
    name = "tp_hua_start",
    tags = {"busy", "evade","no_stun","canrotate"},
    onenter = function(inst)
        local ba = inst:GetBufferedAction()
        if ba and ba.pos then
            inst:ForceFacePoint(ba.pos)
        end
        inst:PerformBufferedAction()
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("slide_pre")
    end,
    events = {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("tp_hua")
        end),
    },
})

add_sg("wilson", State{
    name = "tp_hua",
    tags = {"busy", "evade","no_stun"},
    onenter =   function(inst)
        inst.AnimState:PushAnimation("slide_loop")
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        inst.Physics:SetMotorVelOverride(20,0,0)
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    end,
    events = {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("tp_hua_pst")
        end),
    },
    onexit = function(inst)
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        inst.Physics:ClearMotorVelOverride()
        inst.components.locomotor:Stop()
        
        inst.components.locomotor:SetBufferedAction(nil)
    end,
})

add_sg("wilson", State{
    name = "tp_hua_pst",
    tags = {"evade","no_stun"},
    onenter = function(inst)
        inst.AnimState:PlayAnimation("slide_pst")
    end,

    events =
    {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end ),
    },
})

add_sg("wilson", State{
    name = "tp_za",
    tags = {"doing", "busy", "canrotate"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        inst.AnimState:PlayAnimation("jumpboat")
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_whoosh")
        local ba = inst:GetBufferedAction()
        inst.sg.statemem.startpos = inst:GetPosition()
        inst.sg.statemem.targetpos = inst:GetPosition()
        if ba and ba.pos then
            inst.sg.statemem.targetpos = ba.pos
        elseif ba and ba.target then
            inst.sg.statemem.targetpos = ba.target:GetPosition()
        end

        RemovePhysicsColliders(inst)
        inst.components.health:SetInvincible(true)
        inst.components.playercontroller:Enable(false)
    end,

    onexit = function(inst)
        ChangeToCharacterPhysics(inst)
        inst.components.locomotor:Stop()
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        inst.components.health:SetInvincible(false)
        inst.components.playercontroller:Enable(true)
    end,

    timeline =
    {
        TimeEvent(7*FRAMES, function(inst)
            inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
            local dist = inst:GetPosition():Dist(inst.sg.statemem.targetpos)
            local speed = dist / (18/30)
            inst.Physics:SetMotorVelOverride(1 * speed, 0, 0)
        end),
    },

    events =
    {
        EventHandler("animover", function(inst)
            inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
            inst.Physics:Stop()
            inst:PerformBufferedAction()
            inst.components.health:SetInvincible(false)
            inst.sg:GoToState("tp_za_pst")
        end),
    },
})

add_sg("wilson", State{
    name = "tp_za_pst",
    tags = {"doing", "busy", "canrotate"},

    onenter = function(inst)
        inst.components.health:SetInvincible(true)
        inst.Physics:Stop()
        inst.AnimState:PushAnimation("land", false)
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_to_land")
        PlayFootstep(inst)
    end,

    onexit = function(inst)
        inst.components.health:SetInvincible(false)
    end,

    events =
    {
        EventHandler("animqueueover", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
})

add_sg("wilson", State{
    name = "tp_ci_start",
    tags = {"busy"},
    onenter = function(inst)
        inst.sg:SetTimeout(.2)
        inst.AnimState:PlayAnimation("atk")
        local ba = inst:GetBufferedAction()
        if ba and ba.pos then
            inst:ForceFacePoint(ba.pos:Get())
        end
    end,
    ontimeout = function(inst)
        inst.sg:GoToState("tp_ci")
    end,
})

add_sg("wilson", State{
    name = "tp_ci",
    tags = {"doing", "busy", "canrotate"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        inst.Physics:SetMotorVelOverride(20, 0, 0)
        inst.AnimState:PlayAnimation("sail_loop")
        inst:PerformBufferedAction()
        inst.sg:SetTimeout(.3)
    end,
    ontimeout = function(inst)
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        inst.Physics:ClearMotorVelOverride()
        inst.sg:GoToState("idle")
    end,
})

WARGON_SG_EX.sp_wilson_build_sg()

add_player_sg_post(function(sg)
    local old_timeline = sg.states["speargun"].timeline
    table.insert(old_timeline, TimeEvent(10*FRAMES, function(inst)
        if inst.components.combat:GetWeapon() 
        and inst.components.combat:GetWeapon():HasTag("tp_forest_gun") then
             inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/items/weapon/blunderbuss_shoot")
            local cloud0 = SpawnPrefab("cloudpuff")
            local cloud1 = SpawnPrefab("feathers_packim_fire")
            -- local cloud2 = SpawnPrefab("red_leaves_chop")
            -- local cloud3 = SpawnPrefab("red_leaves")
            local pt = Vector3(inst.Transform:GetWorldPosition())

            local angle
            if inst.components.combat.target and inst.components.combat.target:IsValid() then
                angle = (inst:GetAngleToPoint(inst.components.combat.target.Transform:GetWorldPosition()) -90)*DEGREES
            elseif inst.sg.statemem.target_position then
                angle = (inst:GetAngleToPoint(inst.sg.statemem.target_position.x, inst.sg.statemem.target_position.y, inst.sg.statemem.target_position.z) -90)*DEGREES
            end                     
            inst.sg.statemem.target_position = nil
            
            local DIST = 1.5
            local offset
            if angle then
                offset = Vector3(DIST * math.cos( angle+(PI/2) ), 0, -DIST * math.sin( angle+(PI/2) ))
            else
                offset = Vector3(0, 0, 0)
            end
            cloud0.Transform:SetPosition(pt.x+offset.x, 2,pt.z+offset.z)
            cloud1.Transform:SetPosition(pt.x+offset.x, 0,pt.z+offset.z)
            -- cloud2.Transform:SetPosition(pt.x+offset.x,-1,pt.z+offset.z)
            -- cloud3.Transform:SetPosition(pt.x+offset.x, 2,pt.z+offset.z)
        end
    end) )
end)