local EntUtil = require "extension.lib.ent_util"
local Kit = require "extension.lib.wargon"
local Sounds = require "extension.datas.sounds"
local FxManager = Sample.FxManager
local BuffManager = Sample.BuffManager
local SmearManager = Sample.SmearManager
local Info = Sample.Info

local EquipSkillData = Class(function(self)
end)

--[[
装备技能  
@string id 技能ID  
@table select_type 技能选择类型{target,pos,combat_target,wounded_target,reticule}
@string action 技能动作
@func init 技能初始化  
@func fn 技能函数  
@string/func desc 技能描述  
@table datas 技能数据{skill_type,factors}  
@return 装备技能  
]]
local function EquipSkill(id, select_type, action, init, fn, desc, datas)
    local self = EquipSkillData()
    self.id = id
    self.select_type = select_type
    self.action = action
    self.init = init
    self.fn = fn
    self.desc = desc
    self.datas = datas
    return self
end

function EquipSkillData:GetId()
    return self.id
end

function EquipSkillData:InitEquipSkill(inst, cmp)
    inst:AddTag("wg_equip_skill")
    local str = self.desc
    if self.factors then
        local level = 1
        if inst.components.tp_forge_weapon then
            level = inst.components.tp_forge_weapon.level
        elseif inst.components.tp_forge_armor then
            level = inst.components.tp_forge_armor.level
        elseif inst.components.tp_forge_scroll then
            level = inst.components.tp_forge_scroll.level
        end
        str = str .. "\n属性收益:"
        for attr, factor in pairs(self.factors) do
            local rate = factor*level
            str = str .. string.format("%s(%d%%),", 
                Info.Attr.PlayerAttrStr[attr], rate*100)
        end
    end
    inst.components.wg_action_tool:RegisterSkillInfo({
        desc = str,
    })
    if self.select_type then
        inst:AddComponent("wg_reticule")
        if self.select_type.reticule then
            inst.components.wg_reticule.reticule_prefab = self.select_type.reticule
        end
        inst.components.wg_action_tool.click_no_action = true
        inst.components.wg_action_tool.click_fn = function(inst, doer)
            -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
            inst.components.wg_reticule:Toggle()
        end
    else
        inst.components.wg_action_tool.no_catch_action = true
        inst.components.wg_action_tool:SetDefaultClickFn()
    end
    if self.datas then
        if self.datas.skill_type then
            inst.components.wg_action_tool:SetSkillType(self.datas.skill_type)
        end
    end
    self:SetGetActionFn(inst)
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        self:fn(inst, cmp, self.id, doer, target, pos)
    end
    if self.init then
        self:init(inst, inst.components.wg_action_tool, self.id)
    end
end

local function get_action_fn(inst, data)
    local cmp = inst.components.wg_action_tool
    if cmp.select_type == nil then
        return ACTIONS[cmp.action]
    end
    local need_target = cmp.select_type.target
    local need_pos = cmp.select_type.pos
    if (need_target and data.target) or (need_pos and data.pos) then
        return ACTIONS[cmp.action]
    end
    if cmp.select_type.combat_target then
        if data.target and EntUtil:check_combat_target(data.doer, data.target) then
            return ACTIONS[cmp.action]
        end
    end
    if cmp.select_type.wounded_target then
        if data.target then
            if EntUtil:is_alive(data.target) then
                if data.target.components.health:GetPercent() < 1 then
                    return ACTIONS[cmp.action]
                end
            end
        end
    end
end

function EquipSkillData:SetGetActionFn(inst)
    if self.action == nil then
        return
    end
    inst.components.wg_action_tool.select_type = self.select_type
    inst.components.wg_action_tool.action = self.action
    inst.components.wg_action_tool.get_action_fn = get_action_fn
end

function EquipSkillData:GetAttrIncome(inst, doer)
    local cmp 
    if inst.components.tp_forge_weapon then
        cmp = inst.components.tp_forge_weapon
    elseif inst.components.tp_forge_armor then
        cmp = inst.components.tp_forge_armor
    elseif inst.components.tp_forge_scroll then
        cmp = inst.components.tp_forge_scroll
    end
    local income = 0
    if self.factors then
        local owner = doer
        if owner and owner.components.tp_player_attr then
            for attr, factor in pairs(self.factors) do
                local amt = owner.components.tp_player_attr:GetAttrFactor(attr)
                income = income + (amt * factor * cmp.level)
            end
        end
    end
    return income
end


local DataManager = require "extension.lib.data_manager"
local EquipSkillManager = DataManager("EquipSkillManager")

local lunge_skills = {
EquipSkill("lunge", 
{target=true,pos=true},
"TP_LUNGE",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    local amt = doer.components.tp_player_attr:GetAttrFactor("agility")
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
"突刺:挥动武器,然后向前突刺",
{skill_type="move"}
),
EquipSkill("lunge_overload", 
{target=true,pos=true},
"TP_LUNGE",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    BuffManager:AddBuff(doer, "tp_spear_overload")
    EntUtil:do_lunge(inst, doer, 3.3, 50, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "lunge"),
        {
            calc=true,
            mult=1.3,
            fn = function(v, attacker, weapon)
                inst.enemies[v] = true
            end,
            test = function(v, attacker, weapon)
                return not inst.enemies[v]
            end
        }
    )
end,
"超能突刺:挥动武器,然后向前突刺,并获得攻击和攻速加成",
{skill_type="move"}
),
EquipSkill("lunge_cyclone_slash", 
{target=true,pos=true},
"TP_LUNGE",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    EntUtil:do_lunge(inst, doer, 3.3, 10, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "lunge"),
        {
            calc=true,
            mult=1.25,
            fn = function(v, attacker, weapon)
                inst.enemies[v] = true
            end,
            test = function(v, attacker, weapon)
                return not inst.enemies[v]
            end
        }, function(weapon, owner)
            local eskill_id = "cyclone_slash2"
            local eskill = EquipSkillManager:GetDataById(eskill_id)
            eskill:fn(weapon, cmp, eskill_id, owner, nil, nil, nil)
        end
    )
end,
"突刺回旋斩:挥动武器,然后向前突刺,突刺结束后释放回旋斩击",
{skill_type="move"}
),
EquipSkill("fire_lunge", 
{target=true,pos=true},
"TP_LUNGE", 
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    local task = inst:DoPeriodicTask(1, function()
        FxManager:MakeFx("lunge_fire", doer, {owner=doer,weapon=inst})
    end)
    EntUtil:do_lunge(inst, doer, 3.3, 10, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "lunge"),
        {
            calc=true,
            mult=1.2,
            fn = function(v, attacker, weapon)
                inst.enemies[v] = true
            end,
            test = function(v, attacker, weapon)
                return not inst.enemies[v]
            end
        }, function(weapon, owner)
            task:Cancel()
            task = nil
        end
    )
end,
"烈焰突刺:挥动武器,然后向前突刺,突刺会携带火焰",
{skill_type="move"}
),
EquipSkill("ice_lunge", 
{target=true,pos=true},
"TP_LUNGE", 
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    local task = inst:DoPeriodicTask(1, function()
        FxManager:MakeFx("lunge_ice", doer, {owner=doer,weapon=inst})
    end)
    EntUtil:do_lunge(inst, doer, 3.3, 10, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "lunge"),
        {
            calc=true,
            mult=1.2,
            fn = function(v, attacker, weapon)
                inst.enemies[v] = true
            end,
            test = function(v, attacker, weapon)
                return not inst.enemies[v]
            end
        }, function(weapon, owner)
            task:Cancel()
            task = nil
        end
    )
end,
"冰锥突刺:挥动武器,然后向前突刺,突刺会生成冰锥",
{skill_type="move"}
),
EquipSkill("shadow_lunge", 
{target=true,pos=true},
"TP_LUNGE", 
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    FxManager:MakeFx("statue_transition", doer)
    local fighter = SpawnPrefab("tp_shadow_fighter")
    fighter.Transform:SetPosition(doer:GetPosition())
    fighter.Transform:SetRotation(doer.Transform:GetRotation())
    fighter:PushEvent("start_lunge")
    doer.components.leader:AddFollower(fighter)
    BuffManager:AddBuff(fighter, "summon", 20)
    EntUtil:do_lunge(inst, doer, 3.3, 10, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "lunge"),
        {
            calc=true,
            mult=1.2,
            fn = function(v, attacker, weapon)
                inst.enemies[v] = true
            end,
            test = function(v, attacker, weapon)
                return not inst.enemies[v]
            end
        }
    )
end,
"幻影突刺:挥动武器,然后向前突刺,并召唤1个暗影突刺者",
{skill_type="move"}
),
EquipSkill("laser_lunge", 
{target=true,pos=true},
"TP_LUNGE", 
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    local fx = FxManager:MakeFx("laser_line", doer, { pos = pos })
    EntUtil:do_lunge(inst, doer, 3.3, 30, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "lunge"),
        {
            calc=true,
            mult=1.3,
            fn = function(v, attacker, weapon)
                inst.enemies[v] = true
                BuffManager:AddBuff(v, "fire")
            end,
            test = function(v, attacker, weapon)
                return not inst.enemies[v]
            end
        }, function(weapon, owner)
            fx:WgRecycle()
        end
    )
end,
"激光突刺:挥动武器,然后向前突刺,对沿途敌人造成伤害并点燃,并使其进入燃烧状态",
{skill_type="move"}
),
EquipSkill("lunge_gungnir", 
{target=true,pos=true},
"TP_LUNGE_GUNGNIR",
function(self, inst, cmp, id)
    inst.next_lunge = function(inst)
        local ids = EquipSkillManager:GetRandomIds(1, {"lunge"})
        local id = ids[1]
        if id == "lunge_gungnir" then
            id = "lunge"
        end
        local skill_data = EquipSkillManager:GetDataById(id, "lunge")
        local doer = inst.components.equippable.owner
        local pos = TheInput:GetWorldPosition() or doer:GetPosition()
        skill_data:fn(inst, cmp, id, doer, nil, pos)
        doer:ForceFacePoint(pos)  -- 这里转向
        inst.lunge_cnt = inst.lunge_cnt + 1
    end
    inst.can_next_lunge = function(inst)
        return inst.lunge_cnt < 5
    end
end,
function(self, inst, cmp, id, doer, target, pos)
    inst.lunge_cnt = 0
    local ids = EquipSkillManager:GetRandomIds(1, {"lunge"})
    local id = ids[1]
    if id == "lunge_gungnir" then
        id = "lunge"
    end
    local skill_data = EquipSkillManager:GetDataById(id, "lunge")
    skill_data:fn(inst, cmp, id, doer, target, pos)
end,
"奥丁之刺:挥动武器,然后连续随机释放6次其他的突刺技能(突刺会朝鼠标移动)",
{skill_type="move"}
),
}

local cyclone_slash_skills = {
EquipSkill("cyclone_slash",
nil,
"TP_CHOP_START",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos, data)
    FxManager:MakeFx("cyclone_slash", doer, {angle=doer.Transform:GetRotation()})
    EntUtil:do_cyclone_slash(inst, doer, 5, 10, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "cyclone_slash"),
        { calc = true },
        data
    )
end,
"回旋斩击:快速的发动1次斩击,对周围的敌人造成伤害"
),
EquipSkill("cyclone_slash2",
nil,
"TP_CHOP_START",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos, data)
    FxManager:MakeFx("cyclone_slash2", doer, {angle=doer.Transform:GetRotation()})
    EntUtil:do_cyclone_slash(inst, doer, 5, 20, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "slkill", "cyclone_slash"),
        { calc = true, mult = 1.2 },
        data
    )
end,
"回旋斩击(锋):快速的发动1次斩击,对周围的敌人造成伤害"
),
EquipSkill("cyclone_slash3",
nil,
"TP_CHOP_START",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos, data)
    FxManager:MakeFx("cyclone_slash3", doer, {angle=doer.Transform:GetRotation()})
    EntUtil:do_cyclone_slash(inst, doer, 5, 20, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "cyclone_slash"),
        { calc = true, mult=1.3 },
        data
    )
end,
"回旋斩击(芒):快速的发动1次斩击,对周围的敌人造成伤害"
),
EquipSkill("cyclone_slash_blood",
nil,
"TP_CHOP_START",
function(self, inst, cmp, id)
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
            mult = 1.1,
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
"血之回旋:快速的发动1次斩击,对周围的敌人造成伤害,命中敌人会治疗自己"
),
}

local shooter_skills = {
EquipSkill("thunder_ball", 
{pos=true, target=true},
"TP_ATK",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    local fx = FxManager:MakeFx("bishop_attack", doer, {
        angle= doer.Transform:GetRotation(),
        owner = doer,
        weapon = inst,
    })
end,
"电磁炮:发射一个电磁炮"
),
EquipSkill("bulb_bullet", 
{pos=true, target=true},
"TP_CHOP",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    local fx = FxManager:MakeFx("bulb_bullet", doer, {
        angle= doer.Transform:GetRotation(),
        owner = doer,
        weapon = inst,
    })
end,
"发射荧光果:发射一个荧光果"
),
EquipSkill("lunging_shadow", 
{pos=true, target=true},
"TP_ATK",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    if target then
        pos = target:GetPosition()
    end
    local fx = FxManager:MakeFx("nightsword_fx", doer, {
        owner=doer,pos=pos,weapon=inst
    })
end,
"突刺影子:召唤影子向前突刺"
),
EquipSkill("mult_blowdart", 
{target=true, pos=true},
"TP_ATTACK_PROP",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    if target then
        pos = target:GetPosition()
    end
    FxManager:MakeFx("mult_blowdart", doer, {
        pos=pos, owner=doer, weapon=inst, dmg_mod=.35
    })
end,
"多重吹箭:挥动武器,并暗中射出多个吹箭"
),
EquipSkill("shoot_tornado", 
{pos=true, target=true},
"TP_ATK",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    local function getspawnlocation(inst, pos)
        local tarPos = pos
        local pos = inst:GetPosition()
        local vec = tarPos - pos
        vec = vec:Normalize()
        local dist = pos:Dist(tarPos)
        return pos + (vec * (dist * .15))
    end
    if target then
        pos = target:GetPosition()
    end
    if pos then
        local tornado = SpawnPrefab("tornado")
        tornado.WINDSTAFF_CASTER = doer
        tornado:ListenForEvent("death", tornado.Remove, doer)
        local totalRadius = tornado.Physics:GetRadius() + 0.5
        local targetPos = pos + (TheCamera:GetDownVec() * totalRadius)
        tornado.Transform:SetPosition(getspawnlocation(inst, pos):Get())
        tornado.components.knownlocations:RememberLocation("target", targetPos)
    end
end,
"唤风者:召唤一个旋风,对其周围的敌人造成伤害"
),
}

local summon_skills = {
EquipSkill("shadow_tentacle", 
{combat_target=true},
"TP_BATTLE_CRY",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    local st = SpawnPrefab("shadowtentacle")
    st.Transform:SetPosition(target:GetPosition():Get())
    st.components.combat:SetTarget(target)
end,
"暗影触手:选择一个敌人,召唤暗影触手对其进行攻击"
),
EquipSkill("summon_turret",
{target=true, pos=true},
"TP_CAST_SPELL",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    if target then
        pos = target:GetPosition()
    end
    local turret = SpawnPrefab("eyeturret")
    turret.Transform:SetPosition(pos:Get())
    BuffManager:AddBuff(turret, "summon", 60)
end,
"召唤眼球塔:召唤一个眼球塔"
),
}

local other_skills = {
EquipSkill("torch", 
nil, 
nil, 
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    BuffManager:AddBuff(doer, "torch")
    inst:Remove()
end,
"打上火花:点亮你的脚下"
),
EquipSkill("giant_chop", 
nil, 
"TP_CHOP", 
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    FxManager:MakeFx("slash_fx4", doer, {angle=doer.Transform:GetRotation()})
    EntUtil:make_area_dmg(doer, 5, doer, 
        function(victim,attacker,weapon,reason,dmg)
            if victim:HasTag("smallcreature") then
                return dmg*.3+10
            end
            return 10
        end,
        inst, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill", "lunge"), 
        {
            calc = true,
            mult = 1.1,
        }
    )
end,
"强力劈砍:用力劈砍,对周围的敌人造成伤害,对小型单位造成额外伤害"
),
EquipSkill("frozen_route", 
{pos=true, target=true},
"TP_ATTACK_PROP",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    if target then
        pos = target:GetPosition()
    end
    FxManager:MakeFx("frozen_route", doer, {
        pos = pos, owner = doer, damage = 20
    })
end,
"霜冻路径:释放一段扇形的前进的冰锥,对经过的敌人造成伤害并施加1层冰冻效果"
),
EquipSkill("sleep_fire", 
{pos=true, target=true},
"TP_ATTACK_PROP",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    if target then
        pos = target:GetPosition()
    end
    FxManager:MakeFx("sleep_fire", doer, {
        pos = pos, owner = doer, damage = 15
    })
end,
"梦魇之火:挥动武器,喷出多个火焰,催眠命中的敌人,并造成伤害"
),
EquipSkill("thunder_rain", 
nil,
"TP_SAIL",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    local n = 0
    EntUtil:make_area_dmg(doer, 8, doer, 25, inst,
        EntUtil:add_stimuli(nil, "electric", "skill"), 
        {
            calc = true,
            fn = function(v, attacker, weapon)
                FxManager:MakeFx("lightning", v)
                n = n + 1
            end,
            test = function(v, attacker, weapon)
                return n < 8
            end,
        }
    )
end,
"雷霆之雨:召唤闪电攻击周围的敌人(最多8名)"
),
EquipSkill("dodge", 
{target=true,pos=true},
"WG_DODGE",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
end,
"滑铲:向前滑铲以躲避攻击",
{skill_type = "move"}
),
EquipSkill("counterattack_spiral", 
nil,
"TP_SPIRAL",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    EntUtil:make_area_dmg(doer, 5, doer, 30, inst, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill"), 
        {
            calc = true,
        }
    )
end,
"反击螺旋:旋转武器,极大幅提升闪避,旋转结束后对周围的敌人造成伤害"
),
EquipSkill("determination", 
nil,
"TP_BATTLE_CRY",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    BuffManager:AddBuff(doer, "determination", nil, 1.35)
end,
"决心:提升下次攻击的攻击力"
),
EquipSkill("mult_thrust", 
nil,
"TP_MULT_THRUST",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    for i = 0, 2 do
        inst:DoTaskInTime(.1*i, function()
            EntUtil:make_area_dmg(doer, 4, doer, 10, inst, 
                EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "skill"), 
                {
                    calc = true,
                    angle = 180,
                }
            )
        end)
    end
end,
"连环击:用武器向前进行多段突刺,对前面的敌人造成多段伤害"
),
EquipSkill("broken_heavy_attack", 
{target=true,pos=true},
"TP_ATTACK_LEAP",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    FxManager:MakeFx("thump_fx2", doer)
    EntUtil:make_area_dmg(doer, 6, doer, 30, inst, 
        EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type, "parry", "skill"), 
        {
            calc = true,
            fn = function(v, attacker, weapon)
                BuffManager:AddBuff(v, "broken_heavy_attack_debuff")
            end,
        }
    )
end,
"破碎重击:跃向空中,举起武器朝目标方向砸去,对周围的敌人造成伤害,并降低其防御",
{skill_type = "move"}
),
EquipSkill("lantern",
nil,
nil,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    if BuffManager:HasBuff(doer, "lantern") then
        BuffManager:ClearBuff(doer, "lantern")
    else
        BuffManager:AddBuff(doer, "lantern")
    end
end,
"发光开关"
),
EquipSkill("spear_magic_circle",
nil,
"TP_BATTLE_CRY",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    local fx = FxManager:MakeFx("spear_magic_circle", doer, {
        owner = doer, damage = 35
    })
end,
"护身长矛:召唤一阵环绕你的长矛,对周围的敌人周期性造成伤害"
),
EquipSkill("guardian",
nil,
"TP_SAIL",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    FxManager:MakeFx("firework_fx", doer)
    BuffManager:AddBuff(doer, id, nil, 100)
end,
"守护者:提升防御以抵挡下一次攻击"
),
EquipSkill("high_jump",
nil,
"TP_HIGH_JUMP",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
end,
"高跳:原地起跳,并获得巨额闪避"
),
EquipSkill("random_smear",
nil,
"TP_BATTLE_CRY",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    local ids = SmearManager:GetRandomIds(10)
    for _, id in pairs(ids) do
        if inst.components.tp_smearable:CanSmearId(id) then
            inst.components.tp_smearable:Smear(id)
            break
        end
    end
end,
"随身刀油:令武器随机获得一个buff"
),
EquipSkill("drop_smallmeat", 
nil,
"TP_BATTLE_CRY",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    local id = "drop_smallmeat"
    if inst.components.tp_smearable:CanSmearId(id) then
        inst.components.tp_smearable:Smear(id)
    end
end,
"肉制武器:攻击有几率掉落小肉"
),
}

local passive_skills = {

EquipSkill("drop_smallmeat", 
nil,
nil,
function(self, inst, cmp, id)
    inst.components.equippable:WgAddEquipFn(function(inst, owner)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = EntUtil:listen_for_event(owner, "onhitother", function(owner, data)
                local stimuli, target = data.stimuli, data.target
                if target.components.lootdropper 
                and EntUtil:can_extra_dmg(stimuli) then
                    target.components.lootdropper:DropSingleLoot()
                end
            end)
        end
    end)
    inst.components.equippable:WgAddUnequipFn(function(inst, owner)
        if cmp[id.."_fn"] then
            owner:RemoveEventCallback("onhitother", cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end)
end,
function(self, inst, cmp, id, doer, target, pos)
    local loot = SpawnPrefab("goldnugget")
    Kit:throw_item(loot, doer)
end,
"赫尔墨斯之赐:攻击敌人有几率掉落1个属于其的战利品"
),
}

local scroll_skills = {
EquipSkill("tp_scroll_hollow",
{target=true,pos=true},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    FxManager:MakeFx("electric_magic", doer)
    doer.SoundEmitter:PlaySound(Sounds.staff)
    if target then
        pos = target:GetPosition()
    end
    local damage = self:GetAttrIncome(inst, doer)
    local fx = FxManager:MakeFx("hollow_bean", doer, {pos=pos,owner=doer,damage=damage})
end,
"《顺时针法术·苍蓝》:发射一个能量球,飞行一段距离后会停止,能量球会造成伤害,停止后造成的伤害更高;与赫碰撞会发生大爆炸",
{factors={intelligence=.2}}
),
EquipSkill("tp_scroll_hollow2",
{target=true,pos=true},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    FxManager:MakeFx("electric_magic", doer)
    doer.SoundEmitter:PlaySound(Sounds.staff)
    if target then
        pos = target:GetPosition()
    end
    local damage = self:GetAttrIncome(inst, doer)
    local fx = FxManager:MakeFx("hollow_bean2", doer, {pos=pos,owner=doer,damage=damage})
end,
"《逆时针法术·红赫》:发射一个能量球,飞行一段距离后会停止,能量球会造成伤害,飞行时造成的伤害更高;与苍碰撞会发生大爆炸",
{factors={intelligence=.4}}
),
EquipSkill("tp_scroll_hollow3",
nil,
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    FxManager:MakeFx("electric_magic", doer)
    doer.SoundEmitter:PlaySound(Sounds.staff)
    local amt = 50 + self:GetAttrIncome(inst, doer)
    doer.components.tp_val_hollow:DoDelta(amt)
end,
"《反转有下限法术》:回复六目能量",
{factors={intelligence=.5}}
),
EquipSkill("tp_scroll_fire1",
{target=true,pos=true},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    FxManager:MakeFx("fire_magic", doer)
    doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
    if target then
        pos = target:GetPosition()
    end
    local damage = 150 + self:GetAttrIncome(inst, doer)
    local fx = FxManager:MakeFx("fire_pulse", doer, {pos=pos,owner=doer,damage=damage})
end,
"《火焰脉冲》:发射火焰脉冲对路径上的敌人造成伤害",
{factors={faith=.5,strengthen=.1}}
),
EquipSkill("tp_scroll_fire2",
{target=true,pos=true},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    FxManager:MakeFx("fire_magic", doer)
    doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
    if target then
        pos = target:GetPosition()
    end
    local damage = 150 + self:GetAttrIncome(inst, doer)
    local angle = doer.Transform:GetRotation()
    local friends = {}
    for i = -1, 1 do
        local rot = angle + 30*i
        local fx = FxManager:MakeFx("fire_pulse", doer, {angle=rot,owner=doer,damage=damage})
        table.insert(friends, fx)
        fx.friends = friends
    end
end,
"《火焰三尖枪》:发射3道火焰脉冲对路径上的敌人造成伤害",
{factors={faith=.6,strengthen=.1}}
),
EquipSkill("tp_scroll_fire3",
{target=true,pos=true,reticule="wg_reticulearc"},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    FxManager:MakeFx("fire_magic", doer)
    doer.SoundEmitter:PlaySound(Sounds.staff)
    if target then
        pos = target:GetPosition()
    end
    local damage = 300 + self:GetAttrIncome(inst, doer)
    local fx = FxManager:MakeFx("solar_pieces", doer, {pos=pos,owner=doer,damage=damage})
end,
"《太阳碎片》:朝着目标方向引爆能量造成大范围伤害",
{factors={faith=1.5,strengthen=.2}}
),
EquipSkill("tp_scroll_ice1",
{target=true,pos=true},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    FxManager:MakeFx("ice_magic", doer)
    doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
    if target then
        pos = target:GetPosition()
    end
    local damage = 85 + self:GetAttrIncome(inst, doer)
    local fx = FxManager:MakeFx("ice_super_ball", doer, {pos=pos,owner=doer,damage=damage})
end,
"《寒冰散华》:发射一个超级寒冰波,超级寒冰波会不断发射寒冰拳或寒冰箭",
{factors={intelligence=.45}}
),
EquipSkill("tp_scroll_ice2",
nil,
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    FxManager:MakeFx("ice_magic", doer)
    doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
    if target then
        pos = target:GetPosition()
    end
    local damage = 120 + self:GetAttrIncome(inst, doer)
    local fx = FxManager:MakeFx("ice_flower", doer, {pos=pos,owner=doer,damage=damage})
end,
"《寒冰新星》:朝周围释放冰柱,造成伤害并冰冻周围敌人",
{factors={intelligence=.6}}
),
EquipSkill("tp_scroll_ice3",
{target=true,pos=true},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    FxManager:MakeFx("ice_magic", doer)
    doer.SoundEmitter:PlaySound(Sounds.staff)
    if target then
        pos = target:GetPosition()
    end
    local damage = 200 + self:GetAttrIncome(inst, doer)
    local fx = FxManager:MakeFx("ice_storm", pos, {pos=pos,owner=doer,damage=damage})
end,
"《冰冻彗星》:在指定区域召唤一阵冰冻彗星",
{factors={intelligence=1.3}}
),
EquipSkill("tp_scroll_shadow1",
{target=true,pos=true,reticule="wg_reticuleaoesmall"},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
    -- 动作触发时会到达的效果
    FxManager:MakeFx("shadow_magic", doer)
    doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
    if target then
        pos = target:GetPosition()
    end
    local damage = 30 + self:GetAttrIncome(inst, doer)
    local rot = doer:GetAngleToPoint(pos:Get())
    for k, v in pairs({-120, -90, 90, 120}) do
        local angle = rot + v
        print(angle)
        local fx = FxManager:MakeFx("shadow_burst", doer, {pos=pos,angle=angle,owner=doer,damage=damage})
    end
end,
 "《暗影迸发》:发射多个暗影波朝目标地点移动",
{factors={intelligence= .3,faith= .2,}}
),
EquipSkill("tp_scroll_shadow2",
{target=true,pos=true,reticule="wg_reticulearc"},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("shadow_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 30 + self:GetAttrIncome(inst, doer)
        local rot = doer.Transform:GetRotation()
        for i = 0, 11 do
            inst:DoTaskInTime(0.05 * i, function()
                local angle = rot + (i%3-1) * 15
                local fx = FxManager:MakeFx("shadow_bean", doer, {angle=angle,owner=doer,damage=damage})
            end)
        end
    end,
 "《暗影连射》:发射多发暗影拳",
{factors={intelligence= .3,faith= .2,}}
),
EquipSkill("tp_scroll_shadow3",
{target=true,pos=true,reticule="wg_reticulearc"},
"TP_ATTACK_PROP",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("shadow_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        if target then
            pos = target:GetPosition()
        end
        local damage = 280 + self:GetAttrIncome(inst, doer)
        local fx = FxManager:MakeFx("shadow_sword", doer, {owner=doer,damage=damage})
    end,
 "《冥王之剑》:用魔法形成挥动的巨剑攻击目标",
{factors={intelligence= 1.2,faith= .8,}}
),
EquipSkill("tp_scroll_wind1",
nil,
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("wind_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        local damage = 30 + self:GetAttrIncome(inst, doer)
        for i = 1, 3 do
            doer:DoTaskInTime(.1*i, function()
                    local angle = i*360/3
                    local fx = FxManager:MakeFx("scroll_wind1", doer,     
                    {pos=doer:GetPosition(),owner=doer,angle=angle,damage=damage}
                )
            end)
        end
    end,
 "《巡回之风》:召唤3个来回的旋风",
{factors={intelligence= .2,agility= .1,}}
),
EquipSkill("tp_scroll_wind2",
nil,
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("wind_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        local damage = 100 + self:GetAttrIncome(inst, doer)
        local fx = FxManager:MakeFx("scroll_wind2", doer,
            {pos=doer:GetPosition(),owner=doer,damage=damage}
        )
    end,
 "《林地之风》:召唤一阵强风围绕自身旋转并造对敌人造成伤害",
{factors={intelligence= .6,agility= .1,}}
),
EquipSkill("tp_scroll_wind3",
{target=true,pos=true},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        -- 动作触发时会到达的效果
        FxManager:MakeFx("wind_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        if target then
            pos = target:GetPosition()
        end
        local damage = 130 + self:GetAttrIncome(inst, doer)
        local fx = FxManager:MakeFx("scroll_wind3", doer, {pos=pos,owner=doer,damage=damage})
    end,
 "《8级大狂风》:召唤1个强力龙卷风,龙卷风会不断加速和变大攻击范围",        
{factors={intelligence= .7,agility= .2,}}
),
EquipSkill("tp_scroll_blood1",
{combat_target=true,reticule="wg_reticule_target"},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        FxManager:MakeFx("blood_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        local damage = 30 + self:GetAttrIncome(inst, doer)
        EntUtil:get_attacked(target, doer, damage, nil,
            EntUtil:add_stimuli(nil, "blood", "magic")
        )
        BuffManager:AddBuff(target, "tp_scroll_blood1")
    end,
 "《血肉之咒》:造成伤害并诅咒一名敌人,其受到血属性伤害时会失去生命以治疗攻击者",
{factors={faith= .4,lucky= .2,}}
),
EquipSkill("tp_scroll_blood2",
{target=true,pos=true},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        FxManager:MakeFx("blood_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 75 + self:GetAttrIncome(inst, doer)
        local fx = FxManager:MakeFx("scroll_blood2", doer,
            {pos=pos,owner=doer,damage=damage})
    end,
 "《血之飞轮》:发射1个会返回的飞轮,对敌人造成伤害",
{factors={faith= .4,lucky= .3,}}
),
EquipSkill("tp_scroll_blood3",
nil,
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        FxManager:MakeFx("blood_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        local damage = 1000 + self:GetAttrIncome(inst, doer)
        local fx = FxManager:MakeFx("scroll_blood3", doer,
            {owner=doer,damage=damage})
    end,
 "《鲜血征收》:对周围的敌人造成伤害,伤害由所有受伤敌人分摊,并附带吸血效果",
{factors={faith= 1,lucky= .4,}}
),
EquipSkill("tp_scroll_poison1",
{target=true,pos=true,reticule="wg_reticulearc"},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        FxManager:MakeFx("poison_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 50 + self:GetAttrIncome(inst, doer)
        local fx = FxManager:MakeFx("scroll_poison1", doer,
            {pos=pos,owner=doer,damage=damage})
    end,
 "《喷洒毒雾》:朝前方喷洒毒雾,毒雾会造成伤害并令敌人进入毒害状态",        
{factors={intelligence= .4,strengthen= .2,}}
),
EquipSkill("tp_scroll_poison2",
{target=true,pos=true},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        FxManager:MakeFx("poison_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 100 + self:GetAttrIncome(inst, doer)
        local fx = FxManager:MakeFx("scroll_poison2", doer,
            {pos=pos,owner=doer,damage=damage})
    end,
 "《剧毒箭》:发射剧毒箭,如果带毒或中毒的目标造成更高伤害",
{factors={intelligence= .5,strengthen= .2,}}
),
EquipSkill("tp_scroll_poison3",
nil,
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        FxManager:MakeFx("poison_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        local damage = 270 + self:GetAttrIncome(inst, doer)
        local fx = FxManager:MakeFx("scroll_poison3", doer,
            {owner=doer,damage=damage})
    end,
"《毒性发作》:对周围中毒的敌人造成伤害,并结束其中毒状态",
{factors={intelligence= .9,strengthen= .5,}}
),
EquipSkill("tp_scroll_electric1",
{target=true,pos=true,reticule="wg_reticuleaoesmall"},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        FxManager:MakeFx("electric_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        if target then
            pos = target:GetPosition()
        end
        local damage = 90 + self:GetAttrIncome(inst, doer)
        local fx = FxManager:MakeFx("scroll_electric1", pos,
            {owner=doer,damage=damage})
    end,
"《电能之柱》:召唤一个持续造成伤害的雷柱",
{factors={faith= .5,intelligence= .1,}}
),
EquipSkill("tp_scroll_electric2",
nil,
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        FxManager:MakeFx("electric_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        local damage = 20 + self:GetAttrIncome(inst, doer)
        -- local fx = FxManager:MakeFx("scroll_electric2", doer,
        --     {owner=doer,damage=damage})
        BuffManager:AddBuff(doer, "tp_scroll_electric2", nil, {
            owner=doer,damage=damage
        })
    end,
"《电能环绕》:装备后获得雷属性伤害",
{factors={faith= .3,intelligence= .1,}}
),
EquipSkill("tp_scroll_electric3",
{target=true,pos=true},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        FxManager:MakeFx("electric_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        if target then
            pos = target:GetPosition()
        end
        local damage = 400 + self:GetAttrIncome(inst, doer)
        local fx = FxManager:MakeFx("scroll_electric3", doer,
            {pos=pos,owner=doer,damage=damage})
    end,
"《雷霆震荡》:引下天雷,对敌人造成伤害",
{factors={faith= 1.5,intelligence= .4,}}
),
EquipSkill("tp_scroll_holly1",
{wounded_target=true,reticule="wg_reticule_target"},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        FxManager:MakeFx("holly_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        local damage = 50 + self:GetAttrIncome(inst, doer)
        if target then
            -- print("a001", target)
            if EntUtil:is_alive(target) then
                -- print("a002")
                if target.components.health:GetPercent() < 1 then
                    -- print("a003", target.components.health:GetPercent())
                    target.components.health:DoDelta(damage, nil, "holly_magic")
                    local fx = FxManager:MakeFx("recover_fx", target)     
                    return
                end
            end
        end
        doer.components.health:DoDelta(damage, nil, "holly_magic")        
        local fx = FxManager:MakeFx("recover_fx", doer)
    end,
"《圣光疗愈》:选中一个受伤的单位,为其治疗;如果没有有效的单位,为自己治疗", 
{factors={faith= .5,}}
),
EquipSkill("tp_scroll_holly2",
nil,
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        FxManager:MakeFx("holly_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
        -- local damage = 50 + self:GetAttrIncome(inst, doer)
        -- target.components.health:DoDelta(damage, nil, "holly_magic")   
        -- local fx = FxManager:MakeFx("recover_fx", target)
        doer.components.inventory:GiveItem(
            SpawnPrefab("tp_scroll_holly_sword"),
            nil,
            Vector3(TheSim:GetScreenPos(doer.Transform:GetWorldPosition()))
        )
    end,
"《光之守护剑》:获得一把光之守护剑",
{factors={faith= .5,}}
),
EquipSkill("tp_scroll_holly3",
{target=true,pos=true,reticule="wg_reticuleaoesmall"},
"TP_SCROLL_WEAPON",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id, doer, target, pos)
        FxManager:MakeFx("holly_magic", doer)
        doer.SoundEmitter:PlaySound(Sounds.staff)
        if target then
            pos = target:GetPosition()
        end
        local damage = 300 + self:GetAttrIncome(inst, doer)
        -- damage = 10
        local fx = FxManager:MakeFx("holly_meteor", pos,
            {owner=doer,damage=damage})
    end,
"《神圣流星》:召唤一个神圣流星,神圣流行爆炸后会分裂出能量束",
{factors={faith= 1.5,}}
),

}

for elem, data in pairs({
    fire = {
        name = "火焰",
        dmg = {40, 60, 90},
        factor = {
            {faith=.2, strengthen=.1},
            {faith=.3, strengthen=.1},
            {faith=.4, strengthen=.1},
        },
    },
    ice = {
        name = "寒冰",
        dmg = {30, 45, 70},
        factor = {
            {intelligence=.25},
            {intelligence=.35},
            {intelligence=.45},
        },
    },
    shadow = {
        name = "暗影",
        dmg = {20, 35, 55},
        factor = {
            {intelligence=.2, faith=.1},
            {intelligence=.3, faith=.1},
            {intelligence=.3, faith=.2},
        },
    },
    wind = {
        name = "风暴",
        dmg = {30, 45, 60},
        factor = {
            {intelligence=.2, agility=.1},
            {intelligence=.3, agility=.1},
            {intelligence=.4, agility=.1},
        },
    },
    blood = {
        name = "血液",
        dmg = {40, 50, 60},
        factor = {
            {faith=.1, lucky=.2},
            {faith=.2, lucky=.2},
            {faith=.3, lucky=.2},
        },
    },
    poison = {
        name = "毒素",
        dmg = {30, 40, 50},
        factor = {
            {intelligence=.1, strengthen=.2},
            {intelligence=.2, strengthen=.2},
            {intelligence=.3, strengthen=.2},
        },
    },
    electric = {
        name = "雷电",
        dmg = {30, 50, 70},
        factor = {
            {faith=.2, intelligence=.1},
            {faith=.3, intelligence=.1},
            {faith=.4, intelligence=.1},
        },
    },
    holly = {
        name = "神圣",
        dmg = {10, 20, 30},
        factor = {
            {faith=.3, },
            {faith=.4, },
            {faith=.5, },
        },
    }
}) do
    local elemName = data.name
    local magicCircle = elem.."_magic"
    local beanName = elem.."_bean"
    local arrowName = elem.."_arrow"
    local ballName = elem.."_ball"
    local beanDmg, arrowDmg, ballDmg = unpack(data.dmg)
    local beanFactor, arrowFactor, ballFactor = unpack(data.factor)
    for emitterName, emitterData in pairs({
        beanName = {beanDmg, beanFactor, elemName.."拳"},
        arrowName = {arrowDmg, arrowFactor, elemName.."箭"},
        ballName = {ballDmg, ballFactor, elemName.."波"},
    }) do
        table.insert(scrolls, EquipSkill("tp_scroll_"..emitterName,
            {target=true,pos=true},
            "TP_SCROLL_WEAPON",
            function(self, inst, cmp, id)
            end,
            function(self, inst, cmp, id, doer, target, pos)
                FxManager:MakeFx(magicCircle, doer)
                doer.SoundEmitter:PlaySound(Sounds.magic_scroll)
                if target then
                    pos = target:GetPosition()
                end
                local damage = emitterData[1] + self:GetAttrIncome(inst, doer)
                local fx = FxManager:MakeFx(emitterName, doer, {
                    pos=pos,owner=doer,damage=damage
                })
            end,
            string.format("%s:发射%s", emitterData[3], emitterData[3]),
            {factors=emitterData[2]}
        ))
    end
end

-- for k, v in pairs(lunge_skills) do
--     if v.id == "lunge_cyclone_slash" then
--         table.insert(cyclone_slash_skills, v)
--         break
--     end
-- end



EquipSkillManager:AddDatas(lunge_skills, "lunge")
EquipSkillManager:AddDatas(cyclone_slash_skills, "cyclone_slash")
EquipSkillManager:AddDatas(shooter_skills, "shooter")
EquipSkillManager:AddDatas(summon_skills, "summon")
EquipSkillManager:AddDatas(other_skills, "other")
EquipSkillManager:AddDatas(scroll_skills, "scroll")

Sample.EquipSkillManager = EquipSkillManager




