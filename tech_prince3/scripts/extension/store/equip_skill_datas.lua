local EntUtil = require "extension.lib.ent_util"
local FxManager = Sample.FxManager
local BuffManager = Sample.BuffManager

local EquipSkillData = Class(function(self)
end)

--[[
装备技能  
@string id 技能ID  
@table select_type 技能选择类型{target=bool,pos=bool}
@string action 技能动作
@func init 技能初始化  
@func fn 技能函数  
@string/func desc 技能描述  
@return 装备技能  
]]
local function EquipSkill(id, select_type, action, init, fn, desc)
    local self = EquipSkill()
    self.id = id
    self.select_type = select_type
    self.action = action
    self.init = init
    self.fn = fn
    self.desc = desc
    return self
end

function EquipSkillData:GetId()
    return self.id
end

function EquipSkillData:SetGetActionFn(inst)
    inst.components.get_action_fn = function(inst, data)
        local need_target = self.select_type.target
        local need_pos = self.select_type.pos
        if (need_target and data.target) or (need_pos and data.pos) then
            return ACTIONS[self.action]
        end
    end
end


local lunge_skills = {
EquipSkill("lunge", 
{target=true,pos=true},
"TP_LUNGE",
function(self, inst, cmp, id)
    inst:AddComponent("wg_reticule")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetSkillType("move")
    inst.components.wg_action_tool:RegisterSkillInfo({
        desc = self.desc,
    })
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
end,
function(self, inst, cmp, id, doer, target, pos)
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
end,
"向前突刺"
),
EquipSkill("lunge_overload", 
{target=true,pos=true},
"TP_LUNGE",
function(self, inst, cmp, id)
    inst:AddComponent("wg_reticule")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetSkillType("move")
    inst.components.wg_action_tool:RegisterSkillInfo({
        desc = self.desc,
    })
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
end,
function(self, inst, cmp, id, doer, target, pos)
    BuffManager:AddBuff(doer, "tp_spear_overload")
    EntUtil:do_lunge(inst, doer, 3.3, 50, 
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
end,
"向前突刺,并获得攻击和攻速加成"
),
EquipSkill("lunge_cyclone_slash", 
{target=true,pos=true},
"TP_LUNGE",
function(self, inst, cmp, id)
    inst:AddComponent("wg_reticule")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetSkillType("move")
    inst.components.wg_action_tool:RegisterSkillInfo({
        desc = self.desc,
    })
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst:ListenForEvent("weapon_stop_lunge", function(inst, data)
        local eskill_id = "cyclone_slash2"
        local eskill = Sample.EquipSkillManager:GetDataById(eskill_id)
        eskill:fn(inst, inst.components.wg_action_tool, eskill_id, data.owner, nil, nil, true)
    end)
end,
function(self, inst, cmp, id, doer, target, pos)
    EntUtil:do_lunge(inst, doer, 3.3, 10, 
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
end,
"向前突刺,突刺结束后释放回旋斩击"
),
}

local cyclone_slash_skills = {
EquipSkill("cyclone_slash",
{},
"TP_CHOP_START",
function(self, inst, cmp, id)
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        desc = self.desc
    })
    -- inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.no_catch_action = true
    inst.components.wg_action_tool:SetDefaultClickFn()
    -- inst.components.wg_action_tool.click_fn = function(inst, doer)
    --     -- -- 技能栏里释放技能会触发的效果,默认会出发get_action_fn的动作
    -- end
end,
function(self, inst, cmp, id, doer, target, pos, data)
    FxManager:MakeFx("cyclone_slash", doer, {angle=doer.Transform:GetRotation()})
    EntUtil:do_cyclone_slash(inst, doer, 5, 10, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "cyclone_slash"),
        { calc = true },
        data
    )
end,
"回旋斩击"
),
EquipSkill("cyclone_slash2",
{},
"TP_CHOP_START",
function(self, inst, cmp, id)
    inst:AddTag("cyclone_slash_weapon")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        desc = self.desc
    })
    -- inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.no_catch_action = true
    inst.components.wg_action_tool:SetDefaultClickFn()
    -- inst.components.wg_action_tool.click_fn = function(inst, doer)
    --     -- -- 技能栏里释放技能会触发的效果,默认会出发get_action_fn的动作
    -- end
end,
function(self, inst, cmp, id, doer, target, pos, data)
    FxManager:MakeFx("cyclone_slash2", doer, {angle=doer.Transform:GetRotation()})
    EntUtil:do_cyclone_slash(inst, doer, 5, 20, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "slkill", "cyclone_slash"),
        { calc = true },
        data
    )
end,
"回旋斩击(锋)"
),
EquipSkill("cyclone_slash3",
{},
"TP_CHOP_START",
function(self, inst, cmp, id)
    inst:AddTag("cyclone_slash_weapon")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        desc = self.desc
    })
    -- inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.no_catch_action = true
    inst.components.wg_action_tool:SetDefaultClickFn()
    -- inst.components.wg_action_tool.click_fn = function(inst, doer)
    --     -- -- 技能栏里释放技能会触发的效果,默认会出发get_action_fn的动作
    -- end
end,
function(self, inst, cmp, id, doer, target, pos, data)
    FxManager:MakeFx("cyclone_slash3", doer, {angle=doer.Transform:GetRotation()})
    EntUtil:do_cyclone_slash(inst, doer, 5, 20, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "cyclone_slash"),
        { calc = true },
        data
    )
end,
"回旋斩击(芒)"
),
EquipSkill("cyclone_slash_blood",
{},
"TP_CHOP_START",
function(self, inst, cmp, id)
    inst:AddTag("cyclone_slash_weapon")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        desc = self.desc
    })
    -- inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.no_catch_action = true
    inst.components.wg_action_tool:SetDefaultClickFn()
    -- inst.components.wg_action_tool.click_fn = function(inst, doer)
    --     -- -- 技能栏里释放技能会触发的效果,默认会出发get_action_fn的动作
    -- end
end,
function(self, inst, cmp, id, doer, target, pos, data)
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
        data
    )
    doer.components.health:DoDelta(amt)
end,
"回旋斩击,命中敌人会治疗自己"
),
}

-- for k, v in pairs(lunge_skills) do
--     if v.id == "lunge_cyclone_slash" then
--         table.insert(cyclone_slash_skills, v)
--         break
--     end
-- end


local DataManager = require "extension.lib.data_manager"
local EquipSkillManager = DataManager("EquipSkillManager")
EquipSkillManager:AddDatas(lunge_skills, "lunge")
EquipSkillManager:AddDatas(cyclone_slash_skills, "cyclone_slash")

Sample.EquipSkillManager = EquipSkillManager




