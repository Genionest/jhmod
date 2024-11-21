local function OnTalk(inst, script)
    inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
end

local function SetTalk(inst, colour, start_talk, start_idle)
    inst.components.talker.offset = Vector3(15, -180, 0)
    inst.components.talker.fontsize = 50
    inst.components.talker.colour = colour
    inst.start_talk = start_talk
    inst.start_idle = start_idle
end

function FindGold(inst)
    if inst.components.inventory then
        return inst.components.inventory:FindItems(function(item) 
                return item.prefab == "goldnugget"
            end)
    end
end

local function OnAttacked(inst, data)
    local attacker = data.attacker
    inst:ClearBufferedAction()
    if not inst:HasTag("gangqu") and attacker:HasTag("player") then
        -- inst.components.inventory:DropEverything()
        local golds = FindGold(inst)
        while golds and #golds>0 do
            for i, gold in ipairs(golds) do     
                inst.components.thief:StealItem(inst, gold, nil, nil, 4)
            end
            golds = FindGold(inst)
        end
    end
end

local function RetargetFn(inst)
    if not inst:HasTag("gangqu") then
        local target = FindEntity(inst, 16, function(guy)
            if guy:HasTag("player") and guy.components.health 
            and not guy.components.health:IsDead() 
            and inst.components.combat:CanTarget(guy) then
                if inst:HasTag("mouhu") then
                    local inv = guy.components.inventory
                    return inv and inv:Count("goldnugget")>0
                elseif inst:HasTag("agong") then
                    return true
                end
            end
        end)
        return target
    end
end

local function KeepTargetFn(inst, target)
    if target:HasTag("player") 
    and inst.components.combat:CanTarget(target) then
        if inst:HasTag("mouhu") then
            local inv = target.components.inventory
            return inv and inv:Count("goldnugget")>0
        elseif inst:HasTag("agong") then
            return true
        end
    end
end


local function MakeGamer(name,colour,start_talk,tag,start_idle,ranges,speeds)
    local function fn()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        local sound =inst.entity:AddSoundEmitter()
        local shadow = inst.entity:AddDynamicShadow()
        shadow:SetSize(1.5, .75)
        inst.Transform:SetFourFaced()
        MakeCharacterPhysics(inst, 50, .5)

        anim:SetBank("pigman")
        anim:SetBuild("pig_guard_build")
        anim:PlayAnimation("idle")

        inst:AddTag(tag)
        inst:AddTag("characters")
        inst:AddTag("pig")
        inst:AddComponent("inspectable")

        inst:AddComponent("locomotor")
        inst.components.locomotor.walkspeed = 4
        inst.components.locomotor.runspeed = 5

        inst:AddComponent("combat")
        inst.components.combat.hiteffectsymbol = "pig_torso"
        inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
        inst.components.combat:SetRetargetFunction(1, RetargetFn)
        inst.components.combat.onhitotherfn = function(inst, other, damage)
            if other:HasTag("player") then
                local golds = FindGold(other)
                while golds and (#golds > 0) do
                    for i, gold in ipairs(golds) do     
                        inst.components.thief:StealItem(other, gold, nil, nil, 4)
                    end
                    golds = FindGold(other)
                end
            end
        end
        inst:AddComponent("thief")
        inst.components.thief:SetDropDistance(10.0)
        inst.components.combat:SetAttackPeriod(4)
        inst.components.combat:SetDefaultDamage(.1)

        inst:AddComponent("named")
        inst.components.named.possiblenames = STRINGS.PIGNAMES
        inst.components.named:PickNewName()

        inst:AddComponent("inventory")
        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(1000)
        inst.components.health:SetAbsorptionAmount(1)
        inst.components.health:SetInvincible(true)

        inst:AddComponent("talker")
        inst.components.talker.ontalk = OnTalk
        SetTalk(inst, colour, start_talk, start_idle)

        inst:SetBrain(require "brains/pigking_gamer_brain")
        inst:SetStateGraph("SGpigking_gamer")
        
        inst:ListenForEvent("attacked", OnAttacked)
        inst:DoTaskInTime(1.5, function()
            inst.components.health:SetInvincible(false)
            inst:AddTag("game_start")
            inst:DoTaskInTime(16.5, function()
                for i = 1, inst.components.inventory:NumItems() do
                    inst.components.inventory:RemoveItemBySlot(i)
                end
                inst:DoTaskInTime(2, function()
                    inst:RemoveTag("game_start")
                    inst.components.health:SetInvincible(true)
                    inst.sg:GoToState("exit")
                    inst.components.talker.fontsize = 35
                    inst.components.talker.offset = Vector3(0,-400,0)
                    inst.components.talker.colour = {x=1, y=1, z=1}
                    inst.components.talker:Say("打得不错")
                    inst:DoTaskInTime(1.5, function()
                        SpawnPrefab("small_puff").Transform:SetPosition(inst:GetPosition():Get())
                        inst:Remove()
                    end)
                end)
            end)
        end)

        if ranges then
            inst.components.combat:SetRange(ranges[1], ranges[2])
        end
        if speeds then
            inst.components.locomotor.walkspeed = speeds[1]
            inst.components.locomotor.runspeed = speeds[2]
        end
        return inst
    end

    return Prefab("common/characters/"..name, fn, {})
end

local red = {x=1, y=0, z=0}
local blue = {x=0, y=0, z=1}
local yellow = {x=1, y=1, z=0}

return MakeGamer("pigking_gamer_1", red, "阿\n攻", "agong", "idle_angry", {3,5}, {4,8}),
    MakeGamer("pigking_gamer_2", blue, "哞\n护", "mouhu", "idle_happy"),
    MakeGamer("pigking_gamer_3", yellow, "刚\n躯", "gangqu", "hungry")