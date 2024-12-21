local EntUtil = require "extension.lib.ent_util"
local Sounds = require "extension.datas.sounds"
local Kit = require "extension.lib.wargon"
local BuffManager = Sample.BuffManager
local FxManager = Sample.FxManager


local function fn(inst)
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:SetSkillId("torch")
end
AddPrefabPostInit("torch", fn)

local function fn(inst)
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:SetSkillId("lunge_gungnir")
    -- inst.components.wg_action_tool:SetSkillId("lunge")
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 5,
        mana = 15,
        vigor = 3,
        -- sleep = (inst.speartype == "wathgrithr") and false or true,
    })
end
AddPrefabPostInit("spear", fn)
AddPrefabPostInit("spear_wathgrithr", fn)

local function fn(inst)
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:SetSkillId("drop_smallmeat")
    inst.components.wg_action_tool.test = function(inst, doer)
        --检测
        return false
    end
end
AddPrefabPostInit("hambat", fn)

local function fn(inst)
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:SetSkillId("shadow_tentacle")
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 15,
        mana = 15,
        vigor = 2,
    })
end
AddPrefabPostInit("tentaclespike", fn)

local function fn(inst)
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:SetSkillId("thunder_ball")
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 6,
        mana = 20,
        vigor = 3,
        -- sleep = true,
    })
end
AddPrefabPostInit("nightstick", fn)

local function fn(inst)
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:SetSkillId("cyclone_slash_blood")
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 8,
        mana = 15,
        vigor = 3,
        -- sleep = true,
    })
end
AddPrefabPostInit("batbat", fn)

local function fn(inst)
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:SetSkillId("lunging_shadow")
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 8,
        mana = 15,
        vigor = 3,
        -- sleep = (inst.speartype == "wathgrithr") and false or true,
    })
end
AddPrefabPostInit("nightsword", fn)

local function fn(inst)
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:SetSkillId("broken_heavy_attack")
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 8,
        mana = 20,
        vigor = 4,
        -- sleep = (inst.speartype == "wathgrithr") and false or true,
    })
end
AddPrefabPostInit("ruins_bat", fn)

local function fn(inst)
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:SetSkillId("dodge")
    inst.components.wg_action_tool:RegisterSkillInfo({
        cd = 1,
        mana = 5,
        vigor = 2,
        -- sleep = true,
    })
end
AddPrefabPostInit("earmuffshat", fn)

local function fn(inst)
end