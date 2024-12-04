local BuffManager = Sample.BuffManager
local EntUtil = require "extension.lib.ent_util"

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
        sleep = true,
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
        inst.enemies = {}
        for i = 1, 3 do
            inst:DoTaskInTime(i * 0.1, function()
                EntUtil:make_area_dmg(doer, 3.3, doer, 0, inst, 
                    EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type),
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
            end)
        end
    end
end
AddPrefabPostInit("spear", fn)

local function fn(inst)
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription("将火腿吃掉")
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({})
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    -- inst.components.wg_action_tool.get_action_fn = function(inst, data)
    --     -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
    -- end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        local food = SpawnPrefab("meatballs")
        local ba = BufferedAction(doer, nil, ACTIONS.EAT, food)
        doer:PushBufferedAction(ba)
        inst:Remove()
    end
    -- inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
    --     -- 动作触发时会到达的效果
    -- end
end
AddPrefabPostInit("hambat", fn)

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