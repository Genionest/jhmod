local Sounds = require "extension.datas.sounds"

local function add_player_sg_post(fn, no_boat)
    AddStategraphPostInit("wilson", fn)
    if not no_boat then
        AddStategraphPostInit("wilsonboating", fn)
    end
end

local function add_player_sg(state, no_boat)
    AddStategraphState("wilson", state)
    if not no_boat then
        AddStategraphState("wilsonboating", state)
    end
end

add_player_sg_post(function(sg)
    local do_attack = sg.events["doattack"].fn
    sg.events["doattack"].fn = function(inst)
        if not inst.components.health:IsDead() 
        and not inst.sg:HasStateTag("attack") 
        and not inst.sg:HasStateTag("sneeze") then
            local weapon = inst.components.combat and inst.components.combat:GetWeapon()
            local state = nil
            local riding = inst.components.rider:IsRiding()
            local driving = inst.components.driver:GetIsDriving()
            if weapon then
                if weapon:HasTag("tp_forest_dragon") then
                    if not inst.sg:HasStateTag("ak_forest_dragon_shoot_pre") then
                        state = "ak_forest_dragon_shoot"
                    else
                        state = "ak_forest_dragon_shoot_pre"
                    end
                elseif not riding and not driving
                and weapon:HasTag("ak_multithrust") then
                    state = "ak_multithrust_pre"
                elseif weapon:HasTag("tp_mine_attack") then
                    state = "tp_mine_attack"
                elseif weapon:HasTag("tp_chop_attack") then
                    state = "tp_chop_attack"
                end
            end
            if state then
                inst.sg:GoToState(state)
            else
                do_attack(inst)
            end
        end
    end
end)

add_player_sg(State{
    name = "ak_forest_dragon_shoot_pre", 
    tags = {"attack", "notalking", "abouttoattack", "ak_forest_dragon_shoot_pre"},
    onenter = function(inst)
        local target = inst.components.combat.target
        inst.sg.statemem.target = target
        inst.sg.statemem.target_position = target and Vector3(inst.components.combat.target.Transform:GetWorldPosition())
        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("speargun")
        if inst.components.combat.target then
            if inst.components.combat.target and inst.components.combat.target:IsValid() then
                inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
            end
        end
    end,   
    timeline=
    {
        TimeEvent(4*FRAMES, function(inst)
            inst.sg:GoToState("ak_forest_dragon_shoot")
        end),
    },
})

add_player_sg(State{
    name = "ak_forest_dragon_shoot",
    tags = {"attack", "abouttoattack", "notalking", "ak_forest_dragon_shoot"},
    onenter = function(inst)
        if inst.components.combat.target then
            if inst.components.combat.target and inst.components.combat.target:IsValid() then
                inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
            end
        end
        inst.AnimState:SetPercent("speargun", .3)
        inst.sg:SetTimeout(5*FRAMES)
    end,
    timeline = {
        TimeEvent(2*FRAMES, function(inst)
            inst.sg:RemoveStateTag("abouttoattack")
            inst.components.combat:DoAttack(inst.sg.statemem.target)
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/items/weapon/blunderbuss_shoot")
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
            inst.sg:RemoveStateTag("attack")
        end),
        TimeEvent(1*FRAMES, function(inst)
        end),
        TimeEvent(3*FRAMES, function(inst)
            inst.AnimState:SetPercent("speargun", .5)
        end),
    },
    ontimeout = function(inst)
        inst.sg:GoToState("idle")
    end,
})

AddStategraphState("wilson", State{
    name = "ak_multithrust_pre",
    tags = { "attack", "notalking", "abouttoattack", "doing", "busy", },
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("multithrust_yell")
        if inst.components.combat.target then
            inst.components.combat:BattleCry()
            if inst.components.combat.target and inst.components.combat.target:IsValid() then
                inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
            end
        end
        inst.components.combat:StartAttack()
        inst.sg.statemem.target = inst.components.combat.target

    end,
    events =
    {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("ak_multithrust", inst.sg.statemem.target)
            end
        end),
    },
    onexit = function(inst)

    end,
})


AddStategraphState("wilson", State{
    name = "ak_multithrust",
    tags = { "attack", "notalking", "abouttoattack", "doing", "busy", },
    onenter = function(inst, target)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("multithrust")

        if target ~= nil and target:IsValid() then
            inst.sg.statemem.target = target
            inst:ForceFacePoint(target.Transform:GetWorldPosition())
        end
        inst.sg:SetTimeout(30 * FRAMES)
        inst:AddTag("ak_multithrust")
        inst.components.health:SetInvincible(true, "ak_multithrust")
    end,
    timeline =
    {
        TimeEvent(7 * FRAMES, function(inst)

        end),
        TimeEvent(9 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),
        TimeEvent(11 * FRAMES, function(inst)
            -- inst.components.combat:DoAttack(inst.sg.statemem.target) 
        end),
        TimeEvent(13 * FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),
        TimeEvent(15 * FRAMES, function(inst) 
            inst.components.combat:DoAttack(inst.sg.statemem.target) 
        end),
        TimeEvent(17 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),
        TimeEvent(19 * FRAMES, function(inst)
            -- inst.components.combat:DoAttack(inst.sg.statemem.target) 
        end),
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
        inst:RemoveTag("ak_multithrust")
        inst.components.health:SetInvincible(nil, "ak_multithrust")

    end,
})

add_player_sg(State{
    name = "tp_mine_attack",
    tags = {"attack", "notalking", "abouttoattack", "busy", "doing"},       
    onenter = function(inst)
        inst.AnimState:PlayAnimation("pickaxe_pre")

        inst.components.combat:StartAttack()
        if inst.components.combat.target then
            if inst.components.combat.target and inst.components.combat.target:IsValid() then
                inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
            end
        end

        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        -- TimeEvent(8*FRAMES, function(inst) 
        --     inst:PerformBufferedAction()
        -- end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("tp_mine_attack_pst") end ),
    },
})

add_player_sg(State{
    name = "tp_mine_attack_pst",
    tags = {"attack", "notalking", "abouttoattack", "busy", "doing"},       
    onenter = function(inst)
        inst.AnimState:PlayAnimation("pickaxe_loop")
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        TimeEvent(12*FRAMES, function(inst) 
            inst.components.combat:DoAttack()
        end),
        TimeEvent(9*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },
})

-- add_player_sg(State{
--     name = "tp_chop_attack",
--     tags = {"attack", "notalking", "abouttoattack", "busy", "doing"},       
--     onenter = function(inst)
--         inst.AnimState:PlayAnimation("chop_pre")

--         inst.components.combat:StartAttack()
--         if inst.components.combat.target then
--             if inst.components.combat.target and inst.components.combat.target:IsValid() then
--                 inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
--             end
--         end
--         inst.components.locomotor:StopMoving()         
--     end,
--     timeline = {
--         -- TimeEvent(8*FRAMES, function(inst) 
--         --     inst:PerformBufferedAction()
--         -- end),
--     },
--     events={
--         EventHandler("animover", function(inst) inst.sg:GoToState("tp_chop_attack_pst") end ),
--     },
-- })

add_player_sg(State{
    name = "tp_chop_attack",
    tags = {"attack", "notalking", "abouttoattack", "busy", "doing"},       
    onenter = function(inst)
        inst.AnimState:PlayAnimation("chop_loop")
        inst.components.combat:StartAttack()
        if inst.components.combat.target then
            if inst.components.combat.target and inst.components.combat.target:IsValid() then
                inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
            end
        end
        inst.components.locomotor:StopMoving()         
    end,
    timeline = {
        TimeEvent(5*FRAMES, function(inst) 
            inst.components.combat:DoAttack()
        end),
        TimeEvent(9*FRAMES, function(inst) 
            inst.sg:RemoveStateTag("busy")
        end),
        TimeEvent(9*FRAMES, function(inst) 
            inst.sg:RemoveStateTag("attack")
        end),
        TimeEvent(4*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound(Sounds.attack)
        end),
    },
    events={
        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },
})

