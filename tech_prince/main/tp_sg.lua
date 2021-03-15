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
        if not inst:HasTag("tp_no_morph") then
    		inst:PerformBufferedAction()
            inst.sg:GoToState("science_morphed")
        else
            inst.sg:GoToState("idle")
        end
    end,
})

add_player_sg(State{
    name = "science_morph2",
    tags = {"busy"},
    onenter = function(inst)
        inst.sg:GoToState("science_morphed")
    end,
})

add_player_sg(State{
    name = "science_morphed",
    tags = {"busy"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.Physics:Stop()
        if not inst:HasTag("tp_no_morph") then
            inst.AnimState:PlayAnimation("idle_inaction_sanity")
        end
        -- WARGON.make_fx(inst, "boat_death")
        WARGON.make_fx(inst, "sanity_raise")
        WARGON.make_fx(inst, "tp_fx_shadow_spiral_point")
    end,
    timeline=
    {
        TimeEvent(12*FRAMES, function(inst)
            WARGON.make_fx(inst, "beefalo_transform_fx")
            if inst:HasTag("tp_no_morph") then
                inst.sg:GoToState("idle")
            end
        end),
    },
    events = {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
})

-- add_player_sg(State{
--     name = "science_morphing"
--     tags = {"busy"},
--     onenter = function(inst)
--         inst.components.locomotor:Stop()
--         inst.Physics:Stop()
--         inst.AnimState:PlayAnimation("teleport")
--     end,    
--     events = {
--         EventHandler("animover", function(inst)
--             inst.sg:GoToState("science_morphed")
--         end),
--     },
-- })

-- add_player_sg(State{
--     name = "science_morphed",
--     tags = {"busy"},
--     onenter = function(inst)

--     end,
-- })

add_player_sg(State{
	name = "tp_call_beasts",
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
    name = "tp_spawn_beefalo",
    tags = {"busy"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("horn")
        inst.AnimState:OverrideSymbol("horn01", "horn", "horn01")
        inst.AnimState:Show("ARM_normal")
    end,
    
    onexit = function(inst)
        if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
            inst.AnimState:Show("ARM_carry") 
            inst.AnimState:Hide("ARM_normal")
        end
    end,
    
    timeline=
    {
        TimeEvent(21*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/horn_beefalo")
            -- inst:PerformBufferedAction()
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

-- add_player_sg(State{
--     name = "tp_tou",
--     tags = {"busy"},
--     onenter = function(inst)
--         inst.AnimState:PlayAnimation("atk")
--     end,
--     timeline={
--         TimeEvent(8*FRAMES, function(inst)
--             inst:PerformBufferedAction()
--         end),
--         TimeEvent(12*FRAMES, function(inst) 
--             inst.sg:RemoveStateTag("busy")
--         end),   
--     },
-- })

add_sg("wilson", State{
    name = "tp_tou_start",
    tags = { "aoe", "doing", "busy", "nointerrupt", "nomorph" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("superjump_pre")
        -- inst.AnimState:PushAnimation("superjump_lag", false)

        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local ba = inst:GetBufferedAction()
        if ba and ba.target then
            ba.pos = ba.target:GetPosition()
        end
        if ba.pos then
            inst.sg.statemem.targetpos = ba.pos
        end
        RemovePhysicsColliders(inst)
        -- if weapon ~= nil and weapon.components.aoetargeting ~= nil and weapon.components.aoetargeting.targetprefab ~= nil then
        --     local buffaction = inst:GetBufferedAction()
        --     if buffaction ~= nil and buffaction.pos ~= nil then
        --         inst.sg.statemem.targetfx = SpawnPrefab(weapon.components.aoetargeting.targetprefab)
        --         if inst.sg.statemem.targetfx ~= nil then
        --             inst.sg.statemem.targetfx.Transform:SetPosition(buffaction:GetActionPoint():Get())
        --             inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
        --         end
        --     end
        -- end
    end,

    events =
    {
        -- EventHandler("combat_superjump", function(inst, data)
        --     inst.sg.statemem.superjump = true
        --     inst.sg:GoToState("combat_superjump", {
        --         targetfx = inst.sg.statemem.targetfx,
        --         data = data,
        --     })
        -- end),
        -- EventHandler("animover", function(inst)
            -- if inst.AnimState:AnimDone() then
            --     if inst.AnimState:IsCurrentAnimation("superjump_pre") then
            --         inst.AnimState:PlayAnimation("superjump_lag")
                    -- inst:PerformBufferedAction()
                -- else
                    -- inst.sg:GoToState("idle")
                -- end
            -- end
        -- end),
        -- EventHandler("animqueueover", function(inst)
        EventHandler("animover", function(inst)
            inst.sg:GoToState("tp_tou", {
                pos = inst.sg.statemem.targetpos
            })
        end),
    },

    onexit = function(inst)
        -- if not inst.sg.statemem.superjump and inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
        --     OnRemoveCleanupTargetFX(inst)
        -- end
    end,
})

add_sg("wilson", State{
    name = "tp_tou",
    tags = { "aoe", "doing", "busy", "nointerrupt", "nopredict", "nomorph" },

    onenter = function(inst, data)
        -- if data ~= nil then
        --     inst.sg.statemem.targetfx = data.targetfx
        --     inst.sg.statemem.data = data
        --     data = data.data
        --     if data ~= nil and
        --         data.targetpos ~= nil and
        --         data.weapon ~= nil and
        --         data.weapon.components.aoeweapon_leap ~= nil and
        --         inst.AnimState:IsCurrentAnimation("superjump_lag") then
                -- ToggleOffPhysics(inst)
                inst.AnimState:PlayAnimation("superjump")
                inst.AnimState:SetMultColour(.8, .8, .8, 1)
                -- inst.components.colouradder:PushColour("superjump", .1, .1, .1, 0)
                -- inst.sg.statemem.data.startingpos = inst:GetPosition()
                -- inst.sg.statemem.weapon = data.weapon
                -- if inst.sg.statemem.data.startingpos.x ~= data.targetpos.x or inst.sg.statemem.data.startingpos.z ~= data.targetpos.z then
                --     inst:ForceFacePoint(data.targetpos:Get())
                -- end
                if data and data.pos then
                    inst:ForceFacePoint(data.pos:Get())
                    inst.sg.statemem.pos = data.pos
                end
                -- inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt", nil, .4)
                -- inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
                inst.sg:SetTimeout(1)
            --     return
            -- end
        -- end
        --Failed
        -- inst.sg:GoToState("idle", true)
    end,

    ontimeout = function(inst)
        inst.sg:GoToState("tp_tou_pst", {
            pos = inst.sg.statemem.pos
        })
    end,

    onupdate = function(inst)
        if inst.sg.statemem.dalpha ~= nil and inst.sg.statemem.alpha > 0 then
            inst.sg.statemem.dalpha = math.max(.1, inst.sg.statemem.dalpha - .1)
            inst.sg.statemem.alpha = math.max(0, inst.sg.statemem.alpha - inst.sg.statemem.dalpha)
            inst.AnimState:SetMultColour(0, 0, 0, inst.sg.statemem.alpha)
        end
    end,

    timeline =
    {
        TimeEvent(FRAMES, function(inst)
            inst.DynamicShadow:Enable(false)
            inst.sg:AddStateTag("noattack")
            inst.components.health:SetInvincible(true, "tp_tou")
            inst.AnimState:SetMultColour(.5, .5, .5, 1)
            -- inst.components.colouradder:PushColour("superjump", .3, .3, .2, 0)
            -- inst:PushEvent("dropallaggro")
            -- if inst.sg.statemem.weapon ~= nil and inst.sg.statemem.weapon:IsValid() then
            --     inst.sg.statemem.weapon:PushEvent("superjumpstarted", inst)
            -- end
        end),
        TimeEvent(2 * FRAMES, function(inst)
            inst.AnimState:SetMultColour(0, 0, 0, 1)
            -- inst.components.colouradder:PushColour("superjump", .6, .6, .4, 0)
        end),
        TimeEvent(3 * FRAMES, function(inst)
            inst.sg.statemem.alpha = 1
            inst.sg.statemem.dalpha = .5
        end),
        -- TimeEvent(1 - 7 * FRAMES, function(inst)
            -- if inst.sg.statemem.targetfx ~= nil then
            --     if inst.sg.statemem.targetfx:IsValid() then
            --         OnRemoveCleanupTargetFX(inst)
            --     end
            --     inst.sg.statemem.targetfx = nil
            -- end
        -- end),
    },
})

add_sg("wilson", State{
    name = "tp_tou_pst",
    tags = { "aoe", "doing", "busy", "noattack", "nopredict", "nomorph" },

    onenter = function(inst, data)
        -- if data ~= nil and data.data ~= nil then
        --     inst.sg.statemem.startingpos = data.startingpos
        --     inst.sg.statemem.isphysicstoggle = data.isphysicstoggle
        --     data = data.data
        --     inst.sg.statemem.weapon = data.weapon
        --     if inst.sg.statemem.startingpos ~= nil and
        --         data.targetpos ~= nil and
        --         data.weapon ~= nil and
        --         data.weapon.components.aoeweapon_leap ~= nil and
                -- inst.AnimState:IsCurrentAnimation("superjump") then
                inst.AnimState:PlayAnimation("superjump_land")
                inst.AnimState:SetMultColour(.4, .4, .4, .4)
                -- inst.sg.statemem.targetpos = data.targetpos
                -- inst.sg.statemem.flash = 0
                -- if not inst.sg.statemem.isphysicstoggle then
                --     ToggleOffPhysics(inst)
                -- end
                -- inst.Physics:Teleport(data.targetpos.x, 0, data.targetpos.z)
                if data and data.pos then
                    inst.Transform:SetPosition(data.pos:Get())
                end
                inst.components.health:SetInvincible(true, "tp_tou")
                inst.sg:SetTimeout(22 * FRAMES)
                -- return
        --     end
        -- end
        --Failed
        -- inst.sg:GoToState("idle", true)
    end,

    -- onupdate = function(inst)
        -- if inst.sg.statemem.flash > 0 then
        --     inst.sg.statemem.flash = math.max(0, inst.sg.statemem.flash - .1)
        --     local c = math.min(1, inst.sg.statemem.flash)
        --     inst.components.colouradder:PushColour("superjump", c, c, 0, 0)
        -- end
    -- end,

    timeline =
    {
        TimeEvent(FRAMES, function(inst)
            -- inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            inst.AnimState:SetMultColour(.7, .7, .7, .7)
            -- inst.components.colouradder:PushColour("superjump", .1, .1, 0, 0)
        end),
        TimeEvent(2 * FRAMES, function(inst)
            inst.AnimState:SetMultColour(.9, .9, .9, .9)
            -- inst.components.colouradder:PushColour("superjump", .2, .2, 0, 0)
        end),
        TimeEvent(3 * FRAMES, function(inst)
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            -- inst.components.colouradder:PushColour("superjump", .4, .4, 0, 0)
            inst.DynamicShadow:Enable(true)
        end),
        TimeEvent(4 * FRAMES, function(inst)
            -- inst.components.colouradder:PushColour("superjump", 1, 1, 0, 0)
            -- inst.components.bloomer:PushBloom("superjump", "shaders/anim.ksh", -2)
            -- ToggleOnPhysics(inst)
            -- ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
            -- inst.sg.statemem.flash = 1.3
            inst.sg:RemoveStateTag("noattack")
            inst.components.health:SetInvincible(false, "tp_tou")
            inst:PerformBufferedAction()
            ChangeToCharacterPhysics(inst)
            -- if inst.sg.statemem.weapon:IsValid() then
            --     inst.sg.statemem.weapon.components.aoeweapon_leap:DoLeap(inst, inst.sg.statemem.startingpos, inst.sg.statemem.targetpos)
            --     inst.sg.statemem.weapon = nil
            -- end
        end),
        -- TimeEvent(8 * FRAMES, function(inst)
            -- inst.components.bloomer:PopBloom("superjump")
        -- end),
        TimeEvent(19 * FRAMES, PlayFootstep),
    },

    ontimeout = function(inst)
        inst.sg:GoToState("idle", true)
    end,

    events =
    {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        -- if inst.sg.statemem.isphysicstoggle then
        --     ToggleOnPhysics(inst)
        -- end
        inst.AnimState:SetMultColour(1, 1, 1, 1)
        inst.DynamicShadow:Enable(true)
        inst.components.health:SetInvincible(false, "tp_tou")
        -- inst.components.bloomer:PopBloom("superjump")
        -- inst.components.colouradder:PopColour("superjump")
        -- if inst.sg.statemem.weapon ~= nil and inst.sg.statemem.weapon:IsValid() then
        --     inst.sg.statemem.weapon:PushEvent("superjumpcancelled", inst)
        -- end
    end,
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
        inst.components.health:SetInvincible(true, "tp_hua")
    end,
    events = {
        EventHandler("animover", function(inst)
            inst.components.health:SetInvincible(false, "tp_hua")
            inst.sg:GoToState("tp_hua_pst")
        end),
    },
    onexit = function(inst)
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        inst.Physics:ClearMotorVelOverride()
        inst.components.locomotor:Stop()
        
        inst.components.locomotor:SetBufferedAction(nil)
        inst.components.health:SetInvincible(false, "tp_hua")
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
        inst.AnimState:AddOverrideBuild("player_attack_leap_wargon")
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("atk_leap_pre")
        -- inst.AnimState:PlayAnimation("jumpboat")
        -- inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_whoosh")
        -- local ba = inst:GetBufferedAction()
        -- inst.sg.statemem.startpos = inst:GetPosition()
        -- inst.sg.statemem.targetpos = inst:GetPosition()
        -- if ba and ba.pos then
        --     inst.sg.statemem.targetpos = ba.pos
        -- elseif ba and ba.target then
        --     inst.sg.statemem.targetpos = ba.target:GetPosition()
        -- end
        -- RemovePhysicsColliders(inst)
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        inst.components.health:SetInvincible(true, "tp_za")
        inst.components.playercontroller:Enable(false)
        inst.sg:SetTimeout(8*FRAMES)
    end,

    onexit = function(inst)
        -- ChangeToCharacterPhysics(inst)
        -- inst.components.locomotor:Stop()
        -- inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        inst.components.health:SetInvincible(false, "tp_za")
        -- inst.components.playercontroller:Enable(true)
    end,

    timeline =
    {
        TimeEvent(0*FRAMES, function(inst)
            -- inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
            -- local dist = inst:GetPosition():Dist(inst.sg.statemem.targetpos)
            -- local speed = dist / (8/30)
            -- inst.Physics:SetMotorVelOverride(1 * speed, 0, 0)
        end),
    },

    events =
    {
        EventHandler("animover", function(inst)
            -- inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
            -- inst.Physics:Stop()
            -- inst:PerformBufferedAction()
            inst.components.health:SetInvincible(false, "tp_za")
            inst.sg:GoToState("tp_za_pst")
        end),
    },
    ontimeout = function(inst)
        -- inst:PerformBufferedAction()
        -- inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
        -- inst.Physics:Stop()
        inst.components.health:SetInvincible(false, "tp_za")
        inst.sg:GoToState("tp_za_pst")
    end,
})

add_sg("wilson", State{
    name = "tp_za_pst",
    tags = {"doing", "busy", "canrotate"},

    onenter = function(inst)
        local ba = inst:GetBufferedAction()
        inst.sg.statemem.startpos = inst:GetPosition()
        inst.sg.statemem.targetpos = inst:GetPosition()
        if ba and ba.pos then
            inst.sg.statemem.targetpos = ba.pos
        elseif ba and ba.target then
            inst.sg.statemem.targetpos = ba.target:GetPosition()
        end
        RemovePhysicsColliders(inst)
        inst.components.health:SetInvincible(true, "tp_za")
        inst.components.playercontroller:Enable(false)

        -- inst.AnimState:PushAnimation("land", false)
        inst.AnimState:PlayAnimation("atk_leap")
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_to_land")
        PlayFootstep(inst)
        inst.sg:SetTimeout(30*FRAMES)
    end,

    timeline =
    {
        TimeEvent(0*FRAMES, function(inst)
            inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
            local dist = inst:GetPosition():Dist(inst.sg.statemem.targetpos)
            local speed = dist / (13/30)
            inst.Physics:SetMotorVelOverride(1 * speed, 0, 0)
        end),
        TimeEvent(13 * FRAMES, function(inst)
            inst:PerformBufferedAction()
            ChangeToCharacterPhysics(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end),
    },

    ontimeout = function(inst)
        -- inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
        inst.Physics:Stop()
        inst.components.health:SetInvincible(false, "tp_za")
        inst.sg:GoToState("idle")
    end,

    onexit = function(inst)
        -- inst.components.health:SetInvincible(true)
        inst.Physics:Stop()
        inst.components.health:SetInvincible(false, "tp_za")
        inst.components.playercontroller:Enable(true)
        inst.AnimState:ClearOverrideBuild("player_attack_leap_wargon")
    end,

    events =
    {
        -- EventHandler("animover", function(inst)
        --     inst.sg:GoToState("idle")
        -- end),
    },
})

add_sg("wilson", State{
    name = "tp_ci_start",
    tags = {"busy"},
    onenter = function(inst)
        -- inst.sg:SetTimeout(.2)
        -- inst.AnimState:PlayAnimation("atk")
        local ba = inst:GetBufferedAction()
        if ba and ba.pos then
            inst:ForceFacePoint(ba.pos:Get())
        end
        inst.AnimState:AddOverrideBuild("player_lunge_wargon")
        inst.AnimState:PlayAnimation("lunge_pre")
        -- if inst.tp_lunge_fx == nil then
        --     inst.tp_lunge_fx = WARGON.make_fx(inst, "")
        -- end
    end,
    -- ontimeout = function(inst)
    --     inst.sg:GoToState("tp_ci")
    -- end,
    timeline =
    {
        TimeEvent(12 * FRAMES, function(inst)
            inst.sg:GoToState('tp_ci')
        end),
    },

    events =
    {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
})

add_sg("wilson", State{
    name = "tp_ci",
    tags = {"doing", "busy", "canrotate"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        inst.Physics:SetMotorVelOverride(20, 0, 0)
        -- inst.AnimState:PlayAnimation("sail_loop")
        inst.AnimState:PlayAnimation("lunge_pst")
        inst:PerformBufferedAction()
        -- inst.sg:SetTimeout(.3)
    end,
    -- ontimeout = function(inst)
    --     inst.components.locomotor:EnableGroundSpeedMultiplier(true)
    --     inst.Physics:ClearMotorVelOverride()
    --     inst.sg:GoToState("idle")
    -- end,
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
    end,
})

add_sg("wilson", State{
    name = 'tp_zhuan',
    tags = {"busy"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("chop_pre")
        local ba = inst:GetBufferedAction()
        if ba.target then
            ba.pos = ba.target:GetPosition()
        end
        if ba.pos then
            inst:ForceFacePoint(ba.pos)
        end
    end,
    events = {
        EventHandler("animover", 
            function(inst) inst.sg:GoToState("tp_zhuan_pst") 
        end),
    },  
})

add_sg("wilson", State{
    name = "tp_zhuan_pst",
    tags = {"busy"},
    onenter = function(inst)
        inst.AnimState:PlayAnimation("chop_loop")
    end,
    timeline = {
        TimeEvent(0*FRAMES, function(inst)
            inst:PerformBufferedAction()
        end),
        TimeEvent(4*FRAMES, function(inst)
        end),
    },
    events = {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end)
    },
})

add_sg("wilson", State{
    name = "tp_cui_feng",
    tags = {"busy"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("chop_pre")
        local ba = inst:GetBufferedAction()
        if ba.target then
            ba.pos = ba.target:GetPosition()
        end
        if ba.pos then
            inst:ForceFacePoint(ba.pos)
        end
    end,
    events = {
        EventHandler("animover", 
            function(inst) inst.sg:GoToState("tp_cui_feng_pst") 
        end),
    },
})

add_sg("wilson", State{
    name = "tp_cui_feng_pst",
    tags = {"busy"},
    onenter = function(inst)
        inst.AnimState:PlayAnimation("chop_loop")
    end,
    timeline = {
        TimeEvent(4*FRAMES, function(inst)
            local moose = WARGON.make_fx(inst, "tp_fx_moose")
            moose.Transform:SetRotation(inst.Transform:GetRotation())
        end),
        TimeEvent(8*FRAMES, function(inst)
            local ba = inst:GetBufferedAction()
            if ba.target then
                ba.pos = ba.target:GetPosition()
            end
            if ba.pos then
                -- inst:ForceFacePoint(ba.pos)
                local function getspawnlocation(inst, target)
                    local tarPos = target:GetPosition()
                    local pos = inst:GetPosition()
                    local vec = tarPos - pos
                    vec = vec:Normalize()
                    local dist = pos:Dist(tarPos)
                    return pos + (vec * (dist * .15))
                end
                local null = WARGON.make_fx(ba.pos, "tp_fx_null")
                local target = ba.target or null
                local tornado = SpawnPrefab("tornado")
                tornado:AddTag("tp_wind_attack_target")
                tornado.WINDSTAFF_CASTER = inst
                local spawnPos = inst:GetPosition() + TheCamera:GetDownVec()
                local totalRadius = target.Physics and target.Physics:GetRadius() or 0.5 + tornado.Physics:GetRadius() + 0.5
                local targetPos = target:GetPosition() + (TheCamera:GetDownVec() * totalRadius)
                tornado.Transform:SetPosition(getspawnlocation(inst, target):Get())
                tornado.components.knownlocations:RememberLocation("target", targetPos)
            end
            inst:PerformBufferedAction()
        end)
    },
    events = {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end)
    },
})

add_sg("wilson", State{
    name = "tp_wind_attack",
    tags = {"doing", "busy", "canrotate"},
    onenter = function(inst)
        inst.AnimState:AddOverrideBuild("player_attack_leap")
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("atk_leap_pre")
        inst.components.health:SetInvincible(true, "tp_wind_attack")
        inst.components.playercontroller:Enable(false)
        inst.sg:SetTimeout(8*FRAMES)
    end,

    onexit = function(inst)
        inst.components.health:SetInvincible(false, "tp_wind_attack")
    end,
    events =
    {
        EventHandler("animover", function(inst)
            inst.components.health:SetInvincible(false, "tp_wind_attack")
            inst.sg:GoToState("tp_wind_attack_pst")
        end),
    },
    ontimeout = function(inst)
        inst.components.health:SetInvincible(false, "tp_wind_attack")
        inst.sg:GoToState("tp_wind_attack_pst")
    end,
})

add_sg("wilson", State{
    name = "tp_wind_attack_pst",
    tags = {"doing", "busy", "canrotate"},

    onenter = function(inst)
        local ba = inst:GetBufferedAction()
        inst.sg.statemem.startpos = inst:GetPosition()
        inst.sg.statemem.targetpos = inst:GetPosition()
        if ba and ba.pos then
            inst.sg.statemem.targetpos = ba.pos
        elseif ba and ba.target then
            inst.sg.statemem.targetpos = ba.target:GetPosition()
            ba.target:RemoveTag("tp_wind_attack_target")
        end
        inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
        inst:ForceFacePoint(inst.sg.statemem.startpos)
        RemovePhysicsColliders(inst)
        inst.components.health:SetInvincible(true, "tp_wind_attack")
        inst.components.playercontroller:Enable(false)

        inst.AnimState:PlayAnimation("atk_leap")
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_to_land")
        PlayFootstep(inst)
        inst.sg:SetTimeout(30*FRAMES)
    end,

    timeline =
    {
        TimeEvent(13 * FRAMES, function(inst)
            inst:PerformBufferedAction()
            ChangeToCharacterPhysics(inst)
            inst.components.locomotor:Stop()
        end),
    },

    ontimeout = function(inst)
        inst.Physics:Stop()
        inst.components.health:SetInvincible(false, "tp_wind_attack")
        inst.sg:GoToState("idle")
    end,

    onexit = function(inst)
        inst.Physics:Stop()
        inst.components.health:SetInvincible(false, "tp_wind_attack")
        inst.components.playercontroller:Enable(true)
        inst.AnimState:ClearOverrideBuild("player_attack_leap")
    end,
})

add_sg("wilson", State{
    name = "tp_rotate",
    tags = {"doing", "busy"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        -- inst.AnimState:PlayAnimation("chop_loop")
        inst.AnimState:SetPercent("chop_loop", 1-.9)
        inst:PerformBufferedAction()
        inst.sg:SetTimeout(12*FRAMES)
    end,
    timeline = {
        TimeEvent(0*FRAMES, function(inst)
            inst.Transform:SetRotation(0)
        end),
        TimeEvent(3*FRAMES, function(inst)
            inst.Transform:SetRotation(90)
        end),
        TimeEvent(6*FRAMES, function(inst)
            inst.Transform:SetRotation(180)
        end),
        TimeEvent(9*FRAMES, function(inst)
            inst.Transform:SetRotation(270)
        end),
    },
    events =
    {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
    ontimeout = function(inst)
        inst.sg:GoToState("idle")
    end,
})

add_sg("wilson", State{
    name = "tp_bangalore",
    tags = {"doing", "busy"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("atk")
    end,
    timeline = {
        TimeEvent(10*FRAMES, function(inst)
            local ba = inst:GetBufferedAction()
            if ba.target then
                ba.pos = ba.target:GetPosition()
            end
            if ba.pos then
                if c_countprefabs("tp_bangalore") < 3 then
                    local bang = WARGON.make_fx(ba.pos, "tp_bangalore")
                    bang:PushEvent("onbuilt")
                else
                    WARGON.make_fx(ba.pos, "laser_ring")
                    local ents = WARGON.finds(ba.pos, 3, {"tp_bangalore"})
                    for k, v in pairs(ents) do
                        -- v.components.explosive:OnBurnt()
                        if v.boom then
                            v:boom(v)
                        end
                    end
                end
            end
            inst:PerformBufferedAction()
        end),
    },
    events =
    {
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
})

add_sg("wilson", State{
    name = "tp_diving",
    tags = {"doing", "canrotate", "busy"},
    
    onenter = function(inst)
        inst.sg.statemem.action = inst:GetBufferedAction()
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("jump")
        RemovePhysicsColliders(inst)
        local ba = inst:GetBufferedAction()
        if ba and ba.target then
            inst:ForceFacePoint(ba.target:GetPosition())
            inst.sg.statemem.target = ba.target
        end
        -- inst:DoTaskInTime(4.7, function(inst) inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt", "bodyfall") end )
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        inst.components.health:SetInvincible(true, "tp_diving")
        inst.components.playercontroller:Enable(false)
    end,
    
    timeline =
    {
        TimeEvent(5*FRAMES, function(inst)
            local dist = inst:GetPosition():Dist(inst.sg.statemem.target:GetPosition())
            local speed = dist / (8/30)
            inst.Physics:SetMotorVelOverride(1 * speed, 0, 0)
        end),
        TimeEvent(13*FRAMES, function(inst)
            inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end),
        -- this is just hacked in here to make the sound play BEFORE the player hits the wormhole
        TimeEvent(19*FRAMES, function(inst)
            -- if inst.sg.statemem.action and inst.sg.statemem.action.target and inst.sg.statemem.action.target.prefab == "bermudatriangle" then
            --     inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bermudatriangle_travel", "wormhole_travel")
            -- else
                inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/travel", "wormhole_travel")
            -- end
        end),
        TimeEvent(20*FRAMES, function(inst)
            WARGON.make_fx(inst, "splash_water_sink")
        end)
    },

    events=
    {
        EventHandler("animover", function(inst)
            inst.components.health:SetInvincible(false, "tp_diving")
            inst.components.playercontroller:Enable(true)
            inst:PerformBufferedAction()
            ChangeToCharacterPhysics(inst)
            inst.sg:GoToState("wakeup") 
        end ),
    },
})

add_sg("wilson", State{
    name = "tp_scythe",
    tags = {"doing", "busy"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("atk")
        inst.sg:SetTimeout(8*FRAMES)
    end,
    timeline=
    {
        TimeEvent(4*FRAMES, function( inst )
            inst.sg:RemoveStateTag("busy")
        end),
        TimeEvent(10*FRAMES, function( inst )
        inst.sg:RemoveStateTag("doing")
        inst.sg:AddStateTag("idle")
        end),
    },
    ontimeout = function(inst)
        inst:PerformBufferedAction()
    end,
    events=
    {
        EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end end ),
    },
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

-- add_player_sg_post(function(sg)
--     local old_timeline = sg.states["attack"].timeline
--     local time_scale = GetPlayer().components.tpbody and GetPlayer().components.tpbody:GetAttackPeriod()
--     local new_timeline = {
--         TimeEvent(8*time_scale*FRAMES, function(inst) 
--             inst.components.combat:DoAttack(inst.sg.statemem.target) 
--             inst.sg:RemoveStateTag("abouttoattack") 

--             local weapon = inst.components.combat:GetWeapon()
--             if weapon and weapon:HasTag("corkbat") then
--                 inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/items/weapon/corkbat_hit")
--             end

--         end),
--         TimeEvent(12*time_scale*FRAMES, function(inst) 
--             inst.sg:RemoveStateTag("busy")
--         end),
--         TimeEvent(13*time_scale*FRAMES, function(inst)
--             if not inst.sg.statemem.slow and not inst.sg.statemem.slowweapon then
--                 inst.sg:RemoveStateTag("attack")
--             end
--         end),
--         TimeEvent(23*time_scale*FRAMES, function(inst)
--             if inst.sg.statemem.slowweapon then
--                 inst.sg:RemoveStateTag("attack")
--             end
--         end),
--         TimeEvent(24*time_scale*FRAMES, function(inst)
--             if inst.sg.statemem.slow then
--                 inst.sg:RemoveStateTag("attack")
--             end
--         end),
--     }
--     sg.states["attack"].timeline = new_timeline
-- end)

WARGON.SG.add_sg_post("dragonfly", function(sg)
    local old_timeline = sg.states["taunt"].timeline
    table.insert(old_timeline, TimeEvent(0*FRAMES, function(inst)
        local delay = 0.0
        for i = 1, 10 do
            inst:DoTaskInTime(delay, function(inst)
                local target = inst.components.combat.target or inst
                local pos = Vector3(target.Transform:GetWorldPosition())
                local x, y, z = TUNING.VOLCANOBOOK_FIRERAIN_RADIUS * UnitRand() + pos.x, pos.y, TUNING.VOLCANOBOOK_FIRERAIN_RADIUS * UnitRand() + pos.z
                local firerain = SpawnPrefab("firerain")
                firerain.Transform:SetPosition(x, y, z)
                firerain:StartStep()
            end)
            delay = delay + TUNING.VOLCANOBOOK_FIRERAIN_DELAY
        end
    end) )
end)

WARGON.SG.add_sg_post("moose", function(sg)
    local old_timeline = sg.states["disarm"].timeline
    table.insert(old_timeline, TimeEvent(15*FRAMES, function(inst)
        local function getspawnlocation(inst, target)
            local tarPos = target:GetPosition()
            local pos = inst:GetPosition()
            local vec = tarPos - pos
            vec = vec:Normalize()
            local dist = pos:Dist(tarPos)
            return pos + (vec * (dist * .15))
        end
        local target = inst.components.combat.target
        if target then
            if target.components.inventory then
                target.components.inventory:DropEverything()
            end
            local tornado = SpawnPrefab("tornado")
            tornado.WINDSTAFF_CASTER = inst
            local totalRadius = target.Physics and target.Physics:GetRadius() or 0.5 + tornado.Physics:GetRadius() + 0.5
            local targetPos = target:GetPosition() + (TheCamera:GetDownVec() * totalRadius)
            tornado.Transform:SetPosition(getspawnlocation(inst, target):Get())
            tornado.components.knownlocations:RememberLocation("target", targetPos)
        end
    end) )
end)

WARGON.SG.add_sg_post("bearger", function(sg)
    local old_timeline = sg.states["pound"].timeline
    table.insert(old_timeline, TimeEvent(25*FRAMES, function(inst)
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 12, nil, {
                "FX", "NOCLICK", "DECOR", "INLIMBO", "groundpoundimmune", "bearger",
            })
        if ents then
            for k2,v2 in pairs(ents) do
                if v2 and v2.components.health and not v2.components.health:IsDead() and 
                inst.components.combat:CanTarget(v2) then
                    -- inst.components.combat:DoAttack(v2, nil, nil, nil, 1)
                    local dmg = inst.components.combat.defaultdamage
                    v2.components.combat:GetAttacked(inst, dmg, nil, nil)
                end
            end
        end
        local fx = WARGON.make_fx(inst, "tp_fx_bearger_line")
        fx.master = inst
        local target = inst.components.combat.target
        if target then
            WARGON.face_target(fx, target)
        end
        -- for i = 1, 2 do
        --     WARGON.do_task(inst, .3 * i, function()
        --         local rot = inst.Transform:GetRotation()
        --         local angle = rot * PI/180
        --         local radius = 8 * i
        --         local pos = inst:GetPosition()
        --         pos.x = pos.x + math.cos(angle)*radius
        --         pos.z = pos.z + math.sin(angle)*radius
        --         local fx = WARGON.make_fx(pos, "tp_fx_bearger")
        --         fx:AddTag("tp_boss_shadow")
        --         fx.Transform:SetRotation(rot)
        --     end)
        -- end
    end) )
end)

WARGON.SG.add_sg_post("warg", function(sg)
    local old_timeline = sg.states["howl"].timeline
    table.insert(old_timeline, TimeEvent(10*FRAMES, function(inst)
        if inst.has_friend then
            local pos = WARGON.around_land(inst, 6)
            if pos then
                inst.has_friend = false
                local friend_name = nil
                if inst:HasTag("tp_blue_warg") then
                    friend_name = "tp_red_warg"
                elseif inst:HasTag("tp_red_warg") then
                    friend_name = "tp_blue_warg"
                end
                local friend = WARGON.make_spawn(pos, friend_name)
                local target = inst.components.combat and inst.components.combat.target
                if target then
                    friend.components.combat:SuggestTarget(target)
                end
                friend.has_friend = false
                WARGON.make_spawn(pos, "statue_transition")
                WARGON.make_spawn(pos, "statue_transition_2")
            end
        end
        local buffs = {
            "scroll_pig_armorex",
            "scroll_pig_damage",
            "scroll_pig_speed",
            "scroll_pig_heal",
        }
        if inst.tp_howl_fn then
            inst:tp_howl_fn(inst)
        end
    end) )
end)

WARGON.SG.add_sg_post("wilson", function(sg)
    local old_hide_enter = sg.states.hide.onenter
    sg.states.hide.onenter = function(inst, ...)
        old_hide_enter(inst, ...)
        inst:AddTagNum("notarget", 1)
        -- WARGON.add_tag_num(inst, "notarget", 1)
    end
    local old_hide_exit = sg.states.hide.onexit
    sg.states.hide.onexit = function(inst, ...)
        old_hide_exit(inst, ...)
        inst:AddTagNum("notarget", -1)
        -- WARGON.add_tag_num(inst, "notarget", -1)
    end
    local old_hide_idle_enter = sg.states.hide_idle.onenter
    sg.states.hide_idle.onenter = function(inst, ...)
        old_hide_idle_enter(inst, ...)
        inst:AddTagNum("notarget", 1)
        -- WARGON.add_tag_num(inst, "notarget", 1)
    end
    local old_hide_idle_exit = sg.states.hide_idle.onexit
    sg.states.hide_idle.onexit = function(inst, ...)
        old_hide_idle_exit(inst, ...)
        inst:AddTagNum("notarget", -1)
        -- WARGON.add_tag_num(inst, "notarget", -1)
    end
end)

-- Fast work buff
WARGON.SG.add_sg_handler("wilson", 
    ActionHandler(ACTIONS.HARVEST, function(inst, action)
        if inst:HasTag("tp_fast_work") then
            return "doshortaction"
        -- elseif inst:HasTag("tp_bat_scythe") then
        --     return "tp_scythe"
        else
            return "dolongaction"
        end
    end)
)
WARGON.SG.add_sg_handler("wilson", 
    ActionHandler(ACTIONS.PICK, function(inst, action)
        if inst:HasTag("tp_fast_work") then
            return "doshortaction"
        elseif inst:HasTag("tp_bat_scythe") 
        and action.target.components.pickable 
        and (action.target.prefab == "grass"
        or action.target.prefab == "sapling"
        or action.target.prefab == "reeds"
        or action.target.prefab == "marsh_bush"
        or action.target.prefab == "berrybush"
        or action.target.prefab == "slow_farmplot"
        or action.target.prefab == "fast_farmplot"
        or action.target.prefab == "red_mushroom"
        or action.target.prefab == "green_mushroom"
        or action.target.prefab == "blue_mushroom"
        or action.target.prefab == "flower_cave"
        or action.target.prefab == "flower_cave_double"
        or action.target.prefab == "flower_cave_triple") then
            return "tp_scythe"
        else
            if action.target.components.pickable then
                if action.target.components.pickable.quickpick then
                    return "doshortaction"
                else
                    return "dolongaction"
                end
            end
        end
    end)
)