local EntUtil = require "extension.lib.ent_util"
local Sounds = require "extension.datas.sounds"
local Kit = require "extension.lib.wargon"
local BuffManager = Sample.BuffManager
local FxManager = Sample.FxManager


local function fn(inst)
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription(
        string.format("点亮你的脚下")
    )
    -- inst.components.wg_action_tool:SetDefaultClickFn()
    -- inst.components.wg_action_tool:SetClickFn()
    inst.components.wg_action_tool.test = function(inst, doer)
        --检测
        return true
    end
    -- inst.components.wg_action_tool.get_action_fn = function(inst, data)
    --     -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
    -- end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        BuffManager:AddBuff(doer, inst.prefab)
        inst:Remove()
    end
    -- inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
    --     -- 动作触发时会到达的效果
    -- end
end
AddPrefabPostInit("torch", fn)

local function fn(inst)
    inst:AddComponent("wg_reticule")
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription("向前突刺")
    inst.components.wg_action_tool:SetSkillType("move")

    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 5,
        mana = 15,
        vigor = 3,
        -- sleep = (inst.speartype == "wathgrithr") and false or true,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_LUNGE
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        EntUtil:do_lunge(inst, doer, 3.3, 0, 
            EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "lunge"),
            {
                calc=true,
                fn = function(v, attacker, weapon)
                    inst.enemies[v] = true
                end,
                test = function(v, attacker, weapon)
                    return not inst.enemies[v]
                end
            }
        )
    end
end
AddPrefabPostInit("spear", fn)
AddPrefabPostInit("spear_wathgrithr", fn)

local function fn(inst)
    inst:ListenForEvent("wg_owner_killed", function(inst, data)
        -- if inst:HasTag("skill_wake") then
        --     return
        -- end
        if data.victim and data.victim.components.health then
            local max = data.victim.components.health:GetMaxHealth()
            local n = math.max(0, max-100)
            local rate = (1-500/(500+n))
            if math.random() < rate then
                local meat = SpawnPrefab("smallmeat")
                Kit:throw_item(meat, data.owner)
            end
        end
    end)
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription("击杀敌人有几率掉落小肉")
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        -- sleep = true
    })
    inst.components.wg_action_tool.test = function(inst, doer)
        --检测
        return false
    end
end
AddPrefabPostInit("hambat", fn)

local function fn(inst)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst.components.wg_reticule.reticule_prefab = "wg_reticuleaoesummon"
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription("选择一个敌人,召唤暗影触手对其进行攻击")
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 15,
        mana = 15,
        vigor = 2,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.target and EntUtil:check_combat_target(data.doer, data.target) then
            return ACTIONS.TP_BATTLE_CRY
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        local st = SpawnPrefab("shadowtentacle")
        st.Transform:SetPosition(target:GetPosition():Get())
        st.components.combat:SetTarget(target)
    end
end
AddPrefabPostInit("tentaclespike", fn)

local function fn(inst)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_reticule")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription("发射一个电磁炮")
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 6,
        mana = 20,
        vigor = 3,
        -- sleep = true,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_ATK
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        local fx = FxManager:MakeFx("bishop_attack", doer, {
            angle= doer.Transform:GetRotation(),
            owner = doer,
            weapon = inst,
        })
    end
end
AddPrefabPostInit("nightstick", fn)

local function fn(inst)
    inst.components.equippable:WgAddEquipFn(function(inst, owner)
        owner.components.combat:AddLifeStealRateMod("batbat", .1)
    end)
    inst.components.equippable:WgAddUnequipFn(function(inst, owner)
        owner.components.combat:RmLifeStealRateMod("batbat")
    end)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription("发动1次回旋斩击,命中敌人会回复生命")
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 8,
        mana = 15,
        vigor = 3,
        -- sleep = true,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        return ACTIONS.TP_CHOP_START
    end
    -- inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.no_catch_action = true
    inst.components.wg_action_tool:SetDefaultClickFn()
    -- inst.components.wg_action_tool.click_fn = function(inst, doer)
    --     -- -- 技能栏里释放技能会触发的效果,默认会出发get_action_fn的动作
    -- end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        inst:cyclone_slash(doer)
    end
    inst.cyclone_slash = function(inst, doer, ignore)
        FxManager:MakeFx("slash_fx3", doer, {angle=doer.Transform:GetRotation()})
        doer:DoTaskInTime(0.2, function() 
            FxManager:MakeFx("slash_fx3", doer, {angle=doer.Transform:GetRotation()-180})
        end)
        local amt = 0
        EntUtil:do_cyclone_slash(inst, doer, 5, 0,
            EntUtil:add_stimuli(nil, "blood", "skill", "cyclone_slash"),
            { 
                calc = true, 
                fn = function(v, attacker, weapon)
                    if v:HasTag("epic") then
                        amt = amt + 10
                    elseif v:HasTag("largecreature") then
                        amt = amt + 6
                    elseif v:HasTag("monster") then
                        amt = amt + 3
                    else
                        amt = amt + 1
                    end
                end,
            },
            ignore
        )
        doer.components.health:DoDelta(amt)
    end
end
AddPrefabPostInit("batbat", fn)

local function fn(inst)
    inst:AddComponent("wg_reticule")
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription("召唤影子向前突刺")
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 8,
        mana = 15,
        vigor = 3,
        -- sleep = (inst.speartype == "wathgrithr") and false or true,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_ATK
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        if target then
            pos = target:GetPosition()
        end
        local fx = FxManager:MakeFx("nightsword_fx", doer, {owner=doer,pos=pos,weapon=inst})
    end
end
AddPrefabPostInit("nightsword", fn)

local function fn(inst)
    inst:AddComponent("wg_recharge")
    inst:AddTag("wg_equip_skill")
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:SetDescription("滑铲")
    inst.components.wg_action_tool:SetSkillType("move")
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 1,
        mana = 5,
        vigor = 2,
        -- sleep = true,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.WG_DODGE
        end
    end
    -- inst.components.wg_action_tool.click_no_action = true
    -- inst.components.wg_action_tool.click_fn = function(inst, doer)
    --     -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
    -- end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
    end
end
AddPrefabPostInit("earmuffshat", fn)