local EntUtil = require "extension.lib.ent_util"
local BuffManager = Sample.BuffManager
local FxManager = Sample.FxManager
local Info = Sample.Info

local function can_trigger_skill(inst)
    if (inst:HasTag("wg_slience")
    or inst:HasTag("wg_sneer")
    or (inst.components.freezable 
    and inst.components.freezable:IsFrozen())) then
        return
    end
    return true
end

local EquipData = Class(function(self)
end)

--[[
创建装备数据  
(EquipData) 返回
id (string)id名  
data (table)装备相关数据  
desc (func)描述函数  
long_desc (func)详细描述函数  
wake (func)唤醒函数  
sleep (func)睡眠函数  
]]
local function Equip(id, data, desc, long_desc, wake, sleep)
    local self = EquipData()
    self.id = id
    self.data = data
    self.desc = desc
    self.long_desc = long_desc or desc
    self.wake = wake
    self.sleep = sleep
    return self
end

function EquipData:GetId()
    return self.id
end

function EquipData:GetData()
    return self.data
end

function EquipData:GetDesc()
    return self.desc
end

local function get_attr_desc(data, inst)
    local s = ""
    if data.hp then
        if inst:HasTag("epic") then
            s = s..string.format("生命+%d,", data.hp*Info.MonsterStrengthen.EpicEquipHpRate)
        else
            s = s..string.format("生命+%d,", data.hp)
        end
    end
    if data.absorb then
        s = s..string.format("防御+%d,", data.absorb)
    end
    if data.dmg then
        if inst:HasTag("epic") then
            s = s..string.format("攻击+%d,", data.dmg*Info.MonsterStrengthen.EpicEquipDmgRate)
        else
            s = s..string.format("攻击+%d,", data.dmg)
        end
    end
    if data.attack_speed then
        s = s..string.format("攻速+%d%%,", -data.attack_speed*100)
    end
    if data.penetrate then
        s = s..string.format("穿透+%d,", data.penetrate)
    end
    if data.speed then
        s = s..string.format("移速+%d%%,", data.speed*100)
    end
    if data.crit then
        s = s..string.format("暴击+%d%%,", data.crit*100)
    end
    if data.evade then
        s = s..string.format("闪避+%d,", data.evade)
    end
    if data.life_steal then
        s = s..string.format("吸血+%d%%,", data.life_steal*100)
    end
    if data.recover then
        s = s..string.format("回血+%d%%,", data.recover*100)
    end
    return s
end

local large_equips_atk = {
Equip("divine_sunderer", {
    dmg = 40,
    hp = 400,
    speed = 0.2,
    init = function(self, inst, cmp, id)
        -- inst:AddTag("tp_not_freezable")
        -- inst:AddTag("tp_not_burnable")
        -- inst:AddTag("tp_not_fire_damage")
        -- inst:AddTag("tp_not_poisonable")
        -- inst:AddTag("tp_not_poison_damage")
        inst.components.combat:AddDmgTypeAbsorb("fire", self.db[6])
        inst.components.combat:AddDmgTypeAbsorb("ice", self.db[6])
        inst.components.combat:AddDmgTypeAbsorb("poison", self.db[6])
        inst.components.combat:AddDmgTypeAbsorb("electric", self.db[6])
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage

        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if not inst:HasTag(id.."_tag")
            and target
            and not target:HasTag("epic") then
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[3], function()
                    inst:RemoveTag(id.."_tag")
                end)

                local max_hp = target.components.health:GetMaxHealth()
                local ex_dmg = max_hp*self.db[1]
                EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, "holly", "pure"))
                
                if EntUtil:is_alive(inst) then
                    inst.components.health:DoDelta(ex_dmg*self.db[2])
                end
                FxManager:MakeFx("blast4", target)
                -- FxManager:MakeFx("boat_hit_fx_raft_bamboo", target)
                -- BuffManager:AddBuff(data.target, id.."_debuff")
                                
            end
        end)
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     inst.components.combat:AddPenetrateMod(id.."_buff2", num*self.db[4])
    --     inst.components.combat:AddHitRateMod(id.."_buff2", num*self.db[5])
    -- end,
    db = {.05, .5, 8, .05, .05, .3},
}, function(self, inst, cmp, id)
    local s = "【※※神分】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("提升元素抗性;攻击增加圣属性伤害(基于目标生命上限)(对史诗生物无效),你基于此伤害恢复生命(有cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※※神分】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d%%穿透和%d%%命中;", self.db[4]*100, self.db[5]*100)
    s = s..string.format("降低%d%%冰火毒雷属性伤害;攻击额外造成目标最大生命值%d%%的圣属性伤害(对史诗生物无效),你回复这次攻击伤害%d%%的生命,有%ds的冷却",
    self.db[1]*100, self.db[2]*100, self.db[3])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("duskblade_draktharr", {
    dmg=60,
    penetrate=20,
    speed=.2,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
            
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if not inst:HasTag(id.."_tag") then
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[3], function()
                    inst:RemoveTag(id.."_tag")
                end)

                local base_dmg = inst.components.combat.defaultdamage
                local ex_dmg = base_dmg*self.db[1]+self.db[2]
                EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, "shadow", "pure"))
                BuffManager:AddBuff(target, id.."_debuff")
                FxManager:MakeFx("hit_fx4", inst)
                -- 召唤触手
                local attacker = inst
                local pt = target:GetPosition()
                local st_pt =  FindWalkableOffset(pt or attacker:GetPosition(), math.random()*2*PI, 2, 3)
                if st_pt then
                    if attacker.SoundEmitter then
                        attacker.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
                        attacker.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")            
                    end
                    st_pt = st_pt + pt
                    FxManager:MakeFx("sanity_raise", st_pt)
                    local st = SpawnPrefab("shadowtentacle")
                    --print(st_pt.x, st_pt.y, st_pt.z)
                    st.Transform:SetPosition(st_pt.x, st_pt.y, st_pt.z)
                    st.components.combat:SetTarget(target)
                    st.components.combat:SetRange(self.db[4])
                end
            end
        end)
        -- inst:ListenForEvent("killed", function(inst, data)
        --     BuffManager:AddBuff(inst, id.."_buff")
        -- end)
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     inst.components.combat:AddPenetrateMod(id.."_buff2", num*self.db[5])
    -- end,
    db = {.25, 33, 10, 3, 0.05},
}, function(self, inst, cmp, id)
    local s = "【※※幕刃】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击增加基于基础攻击的暗属性伤害,召唤暗影触手,并令敌人减速(有cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※※幕刃】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d%%穿透;", self.db[5]*100)
    local buff = BuffManager:GetDataById(id.."_debuff")
    -- local buff2 = BuffManager:GetDataById(id.."_buff")
    -- s = s..string.format("你的攻击会额外造成攻击力%d%%+%d伤害,并施加debuff(%s),有%ds冷却;你杀死单位后,获得buff(%s)", 
    -- self.db[1]*100, self.db[2], buff:desc(), self.db[3], buff2:desc())
    s = s..string.format("攻击额外造成基础攻击力%d%%+%d的暗属性伤害,并召唤1个攻击距离为%d的暗影触手,并施加debuff(%s),有%ds冷却", 
    self.db[1]*100, self.db[2], self.db[4], buff:desc(), self.db[3])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("galeforce", {
    dmg=60,
    attack_speed=-.2,
    crit=.2,
    speed=.1,
    init = function(self, inst, cmp, id)
        cmp[id.."_wake"] = function(self, inst, cmp, id)
            if cmp[id.."_task"] == nil then
                cmp[id.."_task"] = inst:DoPeriodicTask(self.db[4]/10, function()
                    local target = inst.components.combat.target
                    if can_trigger_skill(inst)
                    and target and inst:IsNear(target, 20)
                    and not inst:HasTag(id.."_tag")
                    and EntUtil:is_alive(inst) then
                        local proj = SpawnPrefab("tp_tornado_proj")
                        proj.Transform:SetPosition(inst:GetPosition():Get())
                        local min, max = self.db[1], self.db[2]
                        local base = min+(max-min)/90*cmp.level
                        local base_dmg = inst.components.combat.defaultdamage
                        local dmg = base+base_dmg*self.db[3]
                        proj.components.weapon:SetDamage(dmg)
                        proj.components.wg_projectile:Throw(inst, target, inst)
                        inst:AddTag(id.."_tag")
                        inst:DoTaskInTime(self.db[4], function()
                            inst:RemoveTag(id.."_tag")
                        end)
                    end
                end)
            end
        end
        if inst:HasTag("epic")
        and not inst:HasTag("galeforce_equip") then
            cmp[id.."_wake"](self, inst, cmp, id)
        end
        if (not inst:HasTag("epic") 
        or inst:HasTag("galeforce_equip"))
        and inst.components.combat:GetWeapon() == nil then
            local fx = FxManager:MakeFx("galeforce_fx", Vector3(0,0,0))
            inst:AddChild(fx)
            local weapon = CreateEntity()
            weapon.entity:AddTransform()
            weapon:AddComponent("weapon")
            weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
            weapon.components.weapon:SetRange(self.db[5], self.db[5]+2)
            weapon.components.weapon:SetProjectile("tp_galeforce_proj")
            weapon.persists = false
            weapon:AddTag("cantdrop")
            weapon:AddComponent("inventoryitem")
            weapon.components.inventoryitem:SetOnDroppedFn(inst.Remove)
            weapon:AddComponent("equippable")
            if inst.components.inventory then
                inst.components.inventory:Equip(weapon)
            else
                weapon.components.inventoryitem.owner = inst
                inst:AddChild(weapon)
                weapon.Transform:SetPosition(0, 0, 0)
                weapon:RemoveFromScene()
                inst.components.combat.tp_weapon = weapon
            end
            -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
            --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
            --     local dmg = data.damage
                
            --     return dmg
            -- end)
            inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
                if not EntUtil:can_dmg_effect(stimuli) then
                    return 
                end
                if can_trigger_skill(inst)
                and not inst:HasTag(id.."_tag") then
                    inst:AddTag(id.."_tag")
                    inst:DoTaskInTime(self.db[4], function()
                        inst:RemoveTag(id.."_tag")
                    end)

                    local min, max = self.db[1], self.db[2]
                    local base = min+(max-min)/90*cmp.level
                    local base_dmg = inst.components.combat.defaultdamage
                    local dmg = base+base_dmg*self.db[3]
                    EntUtil:get_attacked(target, inst, dmg, nil, EntUtil:add_stimuli(nil, "wind", "pure"))
                end 
            end)
        end
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     EntUtil:add_attack_speed_mod(inst, id.."_buff2", num*self.db[6])
    -- end,
    db = {60, 105, .15, 30, 6, -.03},
}, function(self, inst, cmp, id)
    local s = "【※※狂风之力】:"
    s = s..get_attr_desc(self, inst)
    if not inst:HasTag("epic") then
        s = s..string.format("装备远程武器;攻击增加基于基础攻击和等级的风属性伤害,(有cd)")
    else
        s = s..string.format("召唤旋风攻击敌人,造成基于攻击力的风属性伤害(有cd)")
    end
    return s
end, function(self, inst, cmp, id)
    local s = "【※※狂风之力】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d%%攻速;", -self.db[6]*100)
    local min, max = self.db[1], self.db[2]
    local base = min+(max-min)/90*cmp.level
    if not inst:HasTag("epic") then
        s = s..string.format("非史诗生物,装备一个攻击距离为%d的武器;攻击额外造成基础攻击力%d%%+%d(基于等级提升)的风属性伤害,有%ds的冷却;",
        self.db[5], self.db[3]*100, base, self.db[4])
    else
        s = s..string.format("史诗生物,召唤旋风攻击敌人,造成攻击力%d%%+%d(基于等级提升)的风属性伤害,有%ds的冷却",
        self.db[3]*100, base, self.db[4])
    end
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end, function(self, inst, cmp, id)
    cmp[id.."_wake"](self, inst, cmp, id)    
end, function(self, inst, cmp, id)
    if cmp[id.."_task"] then
        cmp[id.."_task"]:Cancel()
        cmp[id.."_task"] = nil
    end
end
),
Equip("goredrinker", {
    dmg=45,
    hp=400,
    recover=1,
    speed=.2,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
            
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if can_trigger_skill(inst)
            and not inst:HasTag(id.."_tag") then
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[1], function()
                    inst:RemoveTag(id.."_tag")
                end)

                local base_dmg = inst.components.combat.defaultdamage
                local dmg = base_dmg*self.db[2]
                EntUtil:get_attacked(target, inst, dmg, nil, EntUtil:add_stimuli(nil, "blood", "pure"))

                local max_hp = inst.components.health:GetMaxHealth()
                local cur = inst.components.health.currenthealth
                local dt = (max_hp-cur)*self.db[3]+base_dmg*self.db[4]
                if EntUtil:is_alive(inst) then
                    inst.components.health:DoDelta(dt)
                end
                local fx = FxManager:MakeFx("blood", inst)
                inst:AddChild(fx)
                
            end
        end)
        inst:ListenForEvent("healthdelta", function(inst, data)
            local p = inst.components.health:GetPercent()
            EntUtil:add_damage_mod(inst, id.."_buff", 1-p)
        end)
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     EntUtil:add_speed_mod(inst, id.."_buff2", num*self.db[5])
    -- end,
    db = {10, 1, .3, .25, .05},
}, function(self, inst, cmp, id)
    local s = "【※※渴血】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("每失去1%%生命,获得1%%攻击;攻击增加基于基础攻击的血属性伤害,并根据失去生命恢复生命值(有cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※※渴血】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d%%移速;", self.db[5]*100)
    s = s..string.format("每失去1%%生命值,获得1%%攻击力;攻击额外造成基础攻击力%d%%的血属性伤害,并回复基础攻击力%d%%+已损失生命%d%%的生命,有%ds的冷却",
    self.db[2]*100, self.db[4]*100, self.db[3]*100, self.db[1])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("kraken_slayer", {
    dmg=65,
    attack_speed=-.25,
    crit=.2,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
           
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            local n = cmp[id.."_stack"]
            if n == 3 then
                cmp[id.."_stack"] = 0

                local base_dmg = inst.components.combat.defaultdamage
                local ex_dmg = self.db[1]+base_dmg*self.db[2]
                EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, "electric", "true", "pure"))
                
                -- BuffManager:AddBuff(inst, id.."_buff")
                FxManager:MakeFx("splash_water_drop", target)
            end
        end)
    end,
    attack = function(self, inst, cmp, id, data)
        local n = cmp[id.."_stack"]
        if n == nil then
            n = 0
        end
        cmp[id.."_stack"] = n+1
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     EntUtil:add_attack_speed_mod(inst, id.."_buff2", num*self.db[3])
    -- end,
    db = {30, .45, -.05},
}, function(self, inst, cmp, id)
    local s = "【※※海妖】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("每3次攻击,额外造成基于基础攻击的雷属性真伤")
    return s
end, function(self, inst, cmp, id)
    local s = "【※※海妖】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d%%攻速;", -self.db[3]*100)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("你每第3次攻击,额外造成基础攻击力%d%%+%d的雷属性真伤",
        self.db[2]*100, self.db[1], buff:desc())
    return s
end),
Equip("prowler_claw", {
    dmg=60,
    penetrate=20,
    speed=.2,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
            
        --     return dmg
        -- end)
        cmp[id.."_wake"] = function(self, inst, cmp, id)
            if cmp[id.."_task"] == nil then
                cmp[id.."_task"] = inst:DoPeriodicTask(self.db[5], function()
                    -- FxManager:MakeFx("sparklefx", inst)
                    EntUtil:add_speed_mod(inst, id.."_buff", self.db[6], self.db[7])
                end)
            end
        end
        cmp[id.."_wake"](self, inst, cmp, id)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if inst.components.locomotor then
                local spd_mult = inst.components.locomotor:GetSpeedMultiplier()
                if spd_mult>=self.db[1] then
                    if not inst:HasTag(id.."_tag") then
                        inst:AddTag(id.."_tag")
                        inst:DoTaskInTime(self.db[4], function()
                            inst:RemoveTag(id.."_tag")
                        end)

                        local base_dmg = inst.components.combat.defaultdamage
                        local ex_dmg = self.db[2]+base_dmg*self.db[3]
                        EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, "shadow", "pure"))
                        
                        BuffManager:AddBuff(target, id.."_debuff")
                        FxManager:MakeFx("hit_fx2", target)
                    end
                end
            end
        end)
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     inst.components.combat:AddPenetrateMod(id.."_buff2", num*self.db[8])
    -- end,
    db = {.7, 43, .45, 10, 8, .5, 1, .05},
}, function(self, inst, cmp, id)
    local s = "【※※暗爪】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("周期性获得爆发性移速;高移速状态下,攻击额外造成暗属性伤害,并减速敌人(有cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※※暗爪】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d%%穿透;", self.db[8]*100)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("每隔%ds,你获得%d%%移速加成%ds;若你的移速加成不低于%d%%,攻击额外造成基础攻击力%d%%+%d的暗属性伤害,并施加debuff(%s),有%ds的冷却;",
    self.db[5], self.db[6]*100, self.db[7], self.db[1]*100, self.db[3]*100, self.db[2], buff:desc(), self.db[4])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end, function(self, inst, cmp, id)
    cmp[id.."_wake"](self, inst, cmp, id)
end, function(self, inst, cmp, id)
    if cmp[id.."_task"] then
        cmp[id.."_task"]:Cancel()
        cmp[id.."_task"] = nil
    end
end),
Equip("stride_breaker", {
    dmg=50,
    attack_speed=-.2,
    hp=300,
    speed=.2,
    init = function(self, inst, cmp, id)
        cmp[id.."_wake"] = function(self, inst, cmp, id)
            if cmp[id.."_task"] == nil then
                cmp[id.."_task"] = inst:DoPeriodicTask(self.db[1]/10, function()
                    local target = inst.components.combat.target
                    if can_trigger_skill(inst)
                    and target and inst:IsNear(target, 6)
                    and not inst:HasTag(id.."_tag")
                    and EntUtil:is_alive(inst) then
                        inst:AddTag(id.."_tag")
                        inst:DoTaskInTime(self.db[1], function()
                            inst:RemoveTag(id.."_tag")
                        end)
    
                        local base_dmg = inst.components.combat.defaultdamage
                        local dmg = base_dmg*self.db[2]
                        EntUtil:get_attacked(target, inst, dmg, nil, EntUtil:add_stimuli(nil, "wind", "pure"))
                        
                        -- FxManager:MakeFx("statue_transition_2", target)
                        FxManager:MakeFx("stride_breaker_fx", inst)
                        BuffManager:AddBuff(target, id.."_debuff")
                    end
                end)
            end
        end
        cmp[id.."_wake"](self, inst, cmp, id)
    end,
    attack = function(self, inst, cmp, id, data)
        BuffManager:AddBuff(inst, id.."_buff")
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     EntUtil:add_speed_mod(inst, id.."_buff2", num*self.db[3])
    -- end,
    db = {10, 1.75, .05},
}, function(self, inst, cmp, id)
    local s = "【※※挺进】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("周期性对敌人造成基于基础攻击的风属性伤害,并减速敌人;攻击会提升移速")
    return s
end, function(self, inst, cmp, id)
    local s = "【※※挺进】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d%%移速;", self.db[3]*100)
    local buff = BuffManager:GetDataById(id.."_debuff")
    local buff2 = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("对敌人造成基础攻击力%d%%的风属性伤害,并施加debuff(%s),有%ds的冷却;你进行攻击后,获得buff(%s)",
    self.db[2]*100, buff:desc(), self.db[1],  buff2:desc())
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end, function(self, inst, cmp, id)
    cmp[id.."_wake"](self, inst, cmp, id)
end, function(self, inst, cmp, id)
    if cmp[id.."_task"] then
        cmp[id.."_task"]:Cancel()
        cmp[id.."_task"] = nil
    end
end),
Equip("trinity_force", {
    dmg=25,
    attack_speed=-.35,
    hp=200,
    speed=.2,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
           
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if not inst:HasTag(id.."_tag")
            and target then
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[2], function()
                    inst:RemoveTag(id.."_tag")
                end)
                
                local base_dmg = inst.components.combat.defaultdamage
                local ex_dmg = base_dmg*self.db[1]
                local elem = "electric"
                local rand = math.random()
                if rand < .33 then
                    elem = "fire"
                elseif rand < .66 then
                    elem = "ice"
                end
                EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, elem, "pure"))

                -- FxManager:MakeFx("snake_scales_fx", target)
                FxManager:MakeFx("hit_fx3", target)
            end
        end)
    end,
    attack = function(self, inst, cmp, id, data)
        BuffManager:AddBuff(inst, id.."_buff")
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     EntUtil:add_attack_speed_mod(inst, id.."_buff2", num*self.db[3])
    -- end,
    db = {1, 5, -.05},
}, function(self, inst, cmp, id)
    local s = "【※※三相】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击增加基于基础攻击的随机属性伤害(有cd);攻击会提升攻速和攻击(可叠加)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※※三相】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d%%攻速;", -self.db[3]*100)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("攻击额外造成基础攻击力%d%%的随机属性伤害(冰火雷),有%ds的冷却;攻击会获得buff(%s)",
    self.db[1]*100, self.db[2], buff:desc(inst, inst.components.wg_simple_buff, id.."_debuff"))
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
}

local large_equips_def = {
Equip("eclipse", {
    dmg=55,
    penetrate=20,
    life_steal=.1,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
            
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return
            end
            if not EntUtil:can_extra_dmg(stimuli) then
                return
            end
            local n = cmp[id.."_stack"] or 0
            if n >= 2 then
                if not inst:HasTag(id.."_tag") then
                    inst:AddTag(id.."_tag")
                    inst:DoTaskInTime(self.db[4], function()
                        inst:RemoveTag(id.."_tag")
                    end)

                    cmp[id.."_stack"] = 0
                    
                    local max_hp = inst.components.health.wg_max_health
                    local ex_dmg = max_hp*self.db[1]
                    EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, "ice", "pure"))
                    -- FxManager:MakeFx("hit_fx", target)

                    -- local base_dmg = inst.components.combat.defaultdamage
                    -- local dt = self.db[2]+base_dmg*self.db[3]
                    -- inst.components.health:DoDelta(dt)
                    inst.components.tp_val_sheild:AddCurMod(id, ex_dmg)
                    BuffManager:AddBuff(inst, id.."_buff")
                    -- 强化防御
                    -- BuffManager:AddBuff(inst, "defense")
                end
            end
        end)
    end,
    attack = function(self, inst, cmp, id, data)
        local n = cmp[id.."_stack"]
        if n == nil then
            n = 0
        end
        cmp[id.."_stack"] = n+1
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     inst.components.combat:AddPenetrateMod(id.."_buff2", num*self.db[4])
    -- end,
    db = {.1, 180, .4, 5, .05},
}, function(self, inst, cmp, id)
    local s = "【※※星蚀】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("第2次攻击会造成基于基础生命的冰属性伤害,并提升护盾和移速(有cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※※星蚀】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d%%移速;", self.db[4]*100)
    local buff = BuffManager:GetDataById(id.."_buff")
    local buff2 = BuffManager:GetDataById("defense")
    -- s = s..string.format("你每两次攻击,会额外造成最大生命%d%%的伤害,并让你回复攻击力%d%%+%d的生命,并获得buff(%s)",
    -- self.db[1]*100, self.db[3]*100, self.db[2], buff:desc())
    s = s..string.format("每两次攻击,会额外造成基础最大生命%d%%的冰属性伤害,并获得buff(%s)(%s),有%ds的冷却",
    self.db[1]*100, buff:desc(), buff2:desc(), self.db[4])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("immortal_shieldbow", {
    dmg=55,
    attack_speed=-.2,
    crit=.2,
    life_steal=.15,
    init = function(self, inst, cmp, id, data)
        -- if cmp[id.."_fx"] == nil then
        --     cmp[id.."_fx"] = FxManager:MakeFx("recover_equip_fx", Vector3(0,0,0))
        --     inst:AddChild(cmp[id.."_fx"])
        -- end
    end,
    hit = function(self, inst, cmp, id, data)
        if EntUtil:is_alive(inst) 
        and not inst:HasTag(id.."_tag") then
            if inst.components.health:GetPercent() <= self.db[1] then
                local min, max = self.db[2], self.db[3]
                local dt = min+(max-min)/90*cmp.level
                -- inst.components.health:DoDelta(dt)
                inst.components.tp_val_sheild:AddCurMod(id, dt)
                local rcv_fx = FxManager:MakeFx("recover_fx", Vector3(0,0,0))
                inst:AddChild(rcv_fx)
                BuffManager:AddBuff(inst, id.."_buff")
                -- if cmp[id.."_fx"] then
                --     cmp[id.."_fx"]:WgRecycle()
                --     cmp[id.."_fx"] = nil
                -- end
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[4], function()
                    inst:RemoveTag(id.."_tag")
                    -- if cmp[id.."_fx"] == nil then
                    --     cmp[id.."_fx"] = FxManager:MakeFx("recover_equip_fx", Vector3(0,0,0))
                    --     inst:AddChild(cmp[id.."_fx"])
                    -- end
                end)
            end
        end
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     inst.components.health:WgAddMaxHealthModifier(id.."_buff2", num*self.db[5], true)
    --     inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
    --         local data = {damage=damage, inst=inst, target=target, weapon=weapon}
    --         local dmg = data.damage
    --         dmg = dmg+num*self.db[6]
    --         return dmg
    --     end)
    -- end,
    db = {.3, 250, 700, 40, 50, 5},
}, function(self, inst, cmp, id)
    local s = "【※※盾弓】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("生命低于%d%%时,获得基于等级的护盾,并提升吸血和攻击(有cd)",
        self.db[1]*100)
    return s
end, function(self, inst, cmp, id)
    local s = "【※※盾弓】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d生命和%d攻击力;", self.db[5], self.db[6])
    local min, max = self.db[2], self.db[3]
    local dt = min+(max-min)/90*cmp.level
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("若你的生命值低于%d%%,回复%d的生命值(基于等级提升),并获得buff(%s),有%ds冷却",
    self.db[1]*100, dt, buff:desc(), self.db[4])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("frostfire_gauntlet", {
    hp=350,
    absorb=50,
    evade=50,
    speed=.2,
    init = function(self, inst, cmp, id, data)
        -- inst:AddTag("tp_not_freezable")
        -- inst:AddTag("tp_not_fire_damage")
        -- inst:AddTag("tp_not_burnable")
        inst.components.combat:AddDmgTypeAbsorb("fire", self.db[7])
        inst.components.combat:AddDmgTypeAbsorb("ice", self.db[7])
    end,
    attack = function(self, inst, cmp, id, data)
        data.attacker = inst
        local attacker = data.target
        if EntUtil:can_extra_dmg(data.stimuli)
        and EntUtil:can_thorns(data) then
            local max_hp = inst.components.health:GetMaxHealth()
            local ex_dmg = math.min(self.db[6], max_hp*self.db[3])
            local min, max = self.db[1], self.db[2]
            local base = min+(max-min)/90*cmp.level
            local dmg = ex_dmg+base
            EntUtil:get_attacked(attacker, inst, dmg, nil, EntUtil:add_stimuli(nil, "ice", "pure"))
            -- attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
            FxManager:MakeFx("thorns_blue", inst)
        end
        if not inst:HasTag(id.."_tag") then
            BuffManager:AddBuff(attacker, id.."_debuff", nil, {target=inst})
            FxManager:MakeFx("ice_fist", attacker)
            inst:AddTag(id.."_tag")
            inst:DoTaskInTime(self.db[4], function()
                inst:RemoveTag(id.."_tag")
            end)
        end
        EntUtil:frozen(data.target)
    end,
    hit = function(self, inst, cmp, id, data)
        local attacker = data.attacker
        if EntUtil:can_thorns(data) then
            local max_hp = inst.components.health:GetMaxHealth()
            local ex_dmg = math.min(self.db[6], max_hp*self.db[3])
            local min, max = self.db[1], self.db[2]
            local base = min+(max-min)/90*cmp.level
            local dmg = ex_dmg+base
            EntUtil:get_attacked(attacker, inst, dmg, nil, EntUtil:add_stimuli(nil, "ice", "pure"))
            -- attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
            FxManager:MakeFx("thorns_blue", inst)
        end
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     inst.components.health:WgAddMaxHealthModifier(id.."_buff2", num*self.db[5], true)
    -- end,
    db = {5, 10, .01, 6, 100, 15, .3},
}, function(self, inst, cmp, id)
    local s = "【※※霜火护手】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("提升冰火抗;攻击/被攻击反馈基于生命上限的冰属性伤害;攻击带冰冻;攻击会降低移速(有cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※※霜火护手】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d生命;", self.db[5])
    local min, max = self.db[1], self.db[2]
    local base = min+(max-min)/90*cmp.level
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("降低%d%%冰火属性伤害;攻击和被攻击时,给予对方你最大生命%.2f%%(最高%d点)+%d(基于等级提升)的冰属性伤害;攻击会冰冻敌人1层;攻击会施加debuff(%s),有%ds冷却",
    self.db[7]*100, self.db[3]*100, self.db[6], base, buff:desc(), self.db[4])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("turbo_chemtank", {
    hp=350,
    absorb=50,
    evade=50,
    speed=.2,
    init = function(self, inst, cmp, id)
        -- inst:AddTag("tp_not_poison_damage")
        -- inst:AddTag("tp_not_poisonable")
        inst.components.combat:AddDmgTypeAbsorb("poison", self.db[9])
        inst:ListenForEvent("newcombattarget", function(inst, data)
            if can_trigger_skill(inst)
            and not inst:HasTag(id.."_tag")
            and data.target 
            and data.target ~= data.oldtarget then
                inst:AddTag(id.."_tag")
                BuffManager:AddBuff(data.target, "chase_target")
                -- EntUtil:add_speed_mod(inst, id, self.db[4], self.db[5])
                BuffManager:AddBuff(data.target, id.."_debuff")
                inst:DoTaskInTime(self.db[6], function()
                    inst:RemoveTag(id.."_tag")
                end)
                FxManager:MakeFx("statue_transition", data.target)
            end
        end)
    end,
    attack = function(self, inst, cmp, id, data)
        data.attacker = inst
        local attacker = data.target
        if EntUtil:can_extra_dmg(data.stimuli)
        and EntUtil:can_thorns(data) then
            local max_hp = inst.components.health.wg_max_health
            local ex_dmg = math.max(self.db[8], max_hp*self.db[3])
            local min, max = self.db[1], self.db[2]
            local base = min+(max-min)/90*cmp.level
            local dmg = ex_dmg+base
            EntUtil:get_attacked(attacker, inst, dmg, nil, EntUtil:add_stimuli(nil, "poison", "pure"))
            -- attacker.components.health:DoFireDamage(dmg, nil, true)
            -- BuffManager:AddBuff(attacker, "poison")
            BuffManager:AddBuff(attacker, "not_reflection")
            FxManager:MakeFx("poison_hole_bubble", inst)
        end
    end,
    hit = function(self, inst, cmp, id, data)
        local attacker = data.attacker
        if EntUtil:can_thorns(data) then
            local max_hp = inst.components.health.wg_max_health
            local ex_dmg = math.max(self.db[8], max_hp*self.db[3])
            local min, max = self.db[1], self.db[2]
            local base = min+(max-min)/90*cmp.level
            local dmg = ex_dmg+base
            attacker.components.health:DoFireDamage(dmg, nil, true)
            EntUtil:get_attacked(attacker, inst, dmg, nil, EntUtil:add_stimuli(nil, "poison", "pure"))

            -- BuffManager:AddBuff(attacker, "poison")
            BuffManager:AddBuff(attacker, "not_reflection")
            FxManager:MakeFx("poison_hole_bubble", inst)
        end
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     inst.components.health:WgAddMaxHealthModifier(id.."_buff2", num*self.db[7], true)
    -- end,
    db = {5, 10, 0.01, .5, 5, 15, 100, 20, .3},
}, function(self, inst, cmp, id)
    local s = "【※※炼金罐】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("增加毒抗;攻击/被攻击反馈基于生命上限和等级的毒属性伤害;发现目标后提升移速并减速目标(有cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※※炼金罐】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d生命;", self.db[7])
    local min, max = self.db[1], self.db[2]
    local base = min+(max-min)/90*cmp.level
    local buff = BuffManager:GetDataById(id.."_debuff")
    local buff2 = BuffManager:GetDataById("poison")
    s = s..string.format("降低%d%%毒属性伤害;攻击和被攻击时,给予对方你最大生命%.2f%%(最高%d点)+%d(基于等级提升)的毒属性伤害;发现攻击目标后,提升移速%d%%,持续%ds,并施加debuff(%s),有%ds冷却",
    self.db[9]*100, self.db[3]*100, self.db[8],
    buff2:desc(), self.db[4]*100, self.db[5], buff:desc(), self.db[6])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("locket_IronSolari", {
    hp=200,
    absorb=60,
    evade=60,
    speed=.2,
    hit = function(self, inst, cmp, id, data)
        if can_trigger_skill(inst)
        and not inst:HasTag(id.."_tag") then
            inst:AddTag(id.."_tag")
            local x, y, z = inst:GetPosition():Get()
            local ents = TheSim:FindEntities(x, y, z, 6, nil, EntUtil.not_enemy_tags)
            for k, v in pairs(ents) do
                if EntUtil:check_congeneric(inst, v) then
                    BuffManager:AddBuff(v, id.."_buff")
                    FxManager:MakeFx("sparklefx", v)
                    v.components.tp_val_sheild:AddCurMod(self.db[4])
                end
            end
            inst:DoTaskInTime(self.db[3], function()
                inst:RemoveTag(id.."_tag")
            end)
        end
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     inst.components.combat:AddDefenseMod(id.."_buff2", self.db[1]*num)
    --     inst.components.combat:AddEvadeRateMod(id.."_buff2", self.db[2]*num)
    -- end,
    db = {.02, .02, 10, 200},
}, function(self, inst, cmp, id)
    local s = "【※※钢铁烈阳之匣】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("受伤时提升周围的同类的防御,闪避,护盾(短cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※※钢铁烈阳之匣】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d防御和%d闪避;", self.db[1]*100, self.db[2]*100)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("受到攻击令周围的同类获得buff(%s),有%ds冷却",
    buff:desc(), self.db[3])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("SunFire_aegis", {
    hp=350,
    absorb=60,
    evade=60,
    speed=.15,
    init = function(self, inst, cmp, id, data)
        -- inst:AddTag("tp_not_fire_damage")
        inst.components.combat:AddDmgTypeAbsorb("fire", self.db[5])
    end,
    attack = function(self, inst, cmp, id, data)
        data.attacker = inst
        local attacker = data.target
        if EntUtil:can_extra_dmg(data.stimuli)
        and EntUtil:can_thorns(data) then
            local max_hp = inst.components.health:GetMaxHealth()
            local ex_dmg = math.min(self.db[4], max_hp*self.db[3])
            local dmg = ex_dmg+self.db[2]
            EntUtil:get_attacked(attacker, inst, dmg, nil, EntUtil:add_stimuli(nil, "fire", "pure"))
            -- attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
            BuffManager:AddBuff(attacker, id.."_debuff")
            FxManager:MakeFx("firesplash_fx", inst)
        end
    end,
    hit = function(self, inst, cmp, id, data)
        local attacker = data.attacker
        if EntUtil:can_thorns(data) then
            local max_hp = inst.components.health:GetMaxHealth()
            local ex_dmg = math.min(self.db[4], max_hp*self.db[3])
            local dmg = ex_dmg+self.db[2]
            EntUtil:get_attacked(attacker, inst, dmg, nil, EntUtil:add_stimuli(nil, "fire", "pure"))
            -- attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
            BuffManager:AddBuff(attacker, id.."_debuff")
            FxManager:MakeFx("firesplash_fx", inst)
        end
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     inst.components.health:WgAddMaxHealthModifier(id.."_buff2", num*self.db[1], true)
    -- end,
    db = {100, 6, .01, 20, .3},
}, function(self, inst, cmp, id)
    local s = "【※※日炎圣盾】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("增加火抗;攻击/被攻击反馈基于基础生命的火属性伤害,并降低对方防御") 
    return s
end, function(self, inst, cmp, id)
    local s = "【※※日炎圣盾】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d生命;", self.db[1])
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("降低%d%%火属性伤害;攻击和被攻击时,给予对方你基础最大生命%d%%(最高10点)+%d的火属性伤害,并施加debuff(%s)", 
    self.db[5]*100, self.db[3]*100, self.db[4], self.db[2], buff:desc())
    return s
end),
Equip("heart_steel", {
    recover=1,
    hp=800,
    speed=.2,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
           
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if not EntUtil:can_extra_dmg(stimuli) then
                return 
            end
            if not inst:HasTag(id.."_tag") then
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[3], function()
                    inst:RemoveTag(id.."_tag")
                end)

                local max_hp = inst.components.health:GetMaxHealth()
                local ex_dmg = max_hp*self.db[2]
                EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, "blood", "pure"))

                BuffManager:AddBuff(inst, id.."_buff")
                FxManager:MakeFx("hit_fx9", inst)
            end
        end)
    end,
    -- post = function(self, inst, cmp, id)
    --     local num = #cmp.equips
    --     inst.components.health:WgAddMaxHealthMultiplier(id.."_buff2", num*self.db[1], true)
    -- end,
    db = {.05, .002, 15},
}, function(self, inst, cmp, id)
    local s = "【※※心之钢】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击造成额外伤害(基于生命上限)并永久提高生命上限(有cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※※心之钢】:"
    s = s..get_attr_desc(self, inst)
    -- s = s..string.format("你每有1件装备,获得%d%%最大生命;", self.db[1]*100)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("攻击额外造成最大生命%.2f%%的血属性伤害,并令你获得buff(%s),有%ds冷却",
    self.db[2]*100, buff:desc(inst, inst.components.wg_simple_buff, id.."_buff"), self.db[3])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end)
}

local equips_atk = {
Equip("infinity_edge",
{
    dmg=35,
    crit=0.20,
}, function(self, inst, cmp, id)
    local s = "【※无尽】:"
    s = s..get_attr_desc(self, inst)
    s = s.."增加50%的暴击伤害"
    return s
end),
Equip("bloodthirster",
{
    dmg=30,
    crit=0.20,
    life_steal = 1,
    init = function(self, inst, cmp, id)
        inst:ListenForEvent("life_steal", function(inst, data)
            if inst.components.health:GetPercent() >= 1 then
                local max_hp = inst.components.health:GetMaxHealth()
                -- inst.components.health:WgAddMaxHealthMultiplier(id, self.db[1])
                if inst.components.tp_val_sheild.cur_mods == nil then
                    inst.components.tp_val_sheild.cur_mods = {}
                end
                local n = inst.components.tp_val_sheild.cur_mods[id] or 0
                inst.components.tp_val_sheild.cur_mods[id] = math.min(max_hp*self.db[1], n + data.amount)
            end
        end)
    end,
    db = {.2},
}, function(self, inst, cmp, id)
    local s = "【※饮血】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("生命值满时,吸血效果会获得护盾")
    return s
end, function(self, inst, cmp, id)
    local s = "【※饮血】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("若你的生命值已满,吸血效果会令你提升%d%%最大生命值(不叠加)",
        self.db[1]*100)
    return s
end),
Equip("black_cleaver",
{
    hp=225,
    dmg=20,
    speed=0.25,
    attack = function(self, inst, cmp, id, data)
        if data and data.target then
            BuffManager:AddBuff(data.target, id.."_debuff")
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【※黑切】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击会降低敌人护甲(可叠加)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※黑切】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击会施加debuff(%s)", 
        buff:desc(inst, inst.components.wg_simple_buff, id.."_debuff"))
    return s
end),
Equip("ruined_king_blade",
{
    dmg=20,
    attack_speed=-0.20,
    life_steal = .5,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
        --     local target = data.target
            
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if not EntUtil:can_extra_dmg(stimuli) then
                return    
            end
            if not target:HasTag("epic") then
                local max_hp = target.components.health:GetMaxHealth()
                local ex_dmg = max_hp*self.db[1]
                local dmg = math.min(self.db[2], ex_dmg)
                EntUtil:get_attacked(target, inst, dmg, nil, EntUtil:add_stimuli(nil, "blood", "pure"))
            end
        end)
    end,
    db = {.03, 100},
}, function(self, inst, cmp, id)
    local s = "【※破败】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击额外造成敌人生命上限的血属性伤害(对史诗生物无效)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※破败】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击额外造成目标最大生命值%d%%的血属性伤害(最多%d,对史诗生物无效)",
        self.db[1]*100, self.db[2])
    return s
end),
Equip("phantom_dancer",
{
    dmg=20,
    attack_speed=-0.25,
    speed=0.10,
    crit=0.20,
    init = function(self, inst, cmp, id)
        inst.components.combat:AddDmgTypeAbsorb("wind", self.db[1])
    end,
    attack = function(self, inst, cmp, id, data)
        BuffManager:AddBuff(inst, id.."_buff")
    end,
    db = {.2}
}, function(self, inst, cmp, id)
    local s = "【※幻影之舞】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("增加风抗,攻击会提升移速和闪避")
    return s
end, function(self, inst, cmp, id)
    local s = "【※幻影之舞】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("降低%d%%风属性伤害,攻击目标后会获得buff(%s)", 
        self.data[1]*100, buff:desc())
    return s
end),
Equip("mortal_reminder",
{
    dmg=10,
    attack_speed=-0.25,
    speed=0.10,
    crit=0.20,
    penetrate = 30,
    attack = function(self, inst, cmp, id, data)
        local target = data.target
        if not target:HasTag("epic") then
            BuffManager:AddBuff(target, "recover_debuff")
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【※凡性提醒】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击会降低敌人生命恢复(对史诗生物无效)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※凡性提醒】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById("recover_debuff")
    s = s..string.format("攻击目标后,令其获得debuff(%s)(对史诗生物无效)", buff:desc())
    return s
end),
Equip("chempunk_chainsword",
{
    hp=75,
    dmg=25,
    speed=0.15,
    attack = function(self, inst, cmp, id, data)
        local target = data.target
        if EntUtil:is_poisoned(target) then
            BuffManager:AddBuff(target, "poison")
        else
            EntUtil:poison(target)
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【※炼金锯剑】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击附加中毒;若目标已中毒则其进入毒害状态")
    return s
end, function(self, inst, cmp, id)
    local s = "【※炼金锯剑】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById("poison")
    s = s..string.format("攻击附加中毒,若目标已中毒,则施加debuff(%s)", buff:desc())
    return s
end),
Equip("rapid_direcannon",
{
    attack_speed=-0.35,
    speed=0.10,
    crit=0.20,
    init = function(self, inst, cmp, id)
        inst.components.combat.tp_range_buff = self.db[1]
        -- if cmp[id.."_fx"] == nil then
        --     cmp[id.."_fx"] = FxManager:MakeFx("rapid_direcannon", Vector3(0,0,0))
        --     inst:AddChild(cmp[id.."_fx"])
        -- end
    end,
    db = {1},
}, function(self, inst, cmp, id)
    local s = "【※火炮】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击距离+%d", self.db[1])
    return s
end),
Equip("stormrazor",
{
    dmg=20,
    attack_speed=-0.15,
    crit=0.20,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
            
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if not EntUtil:can_extra_dmg(stimuli) then
                return
            end
            if not inst:HasTag(id.."_tag") then
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[2], function()
                    inst:RemoveTag(id.."_tag")
                end)

                local base_dmg = inst.components.combat.defaultdamage
                local ex_dmg = base_dmg*self.db[1]
                EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, "wind", "pure"))

                BuffManager:AddBuff(target, id.."_debuff")
                FxManager:MakeFx("slash_fx", inst, {target=target})
            end
        end)
    end,
    db = {1, 15}
}, function(self, inst, cmp, id)
    local s = "【※岚切】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击增加基于基础攻击风属性伤害,并减速敌人(有cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※岚切】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击会额外造成基础攻击力%d%%的风属性伤害,并施加debuff(%s),有%ds冷却",
    self.db[1]*100, buff:desc(), self.db[2])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("guinsoo_rageblade",
{
    attack_speed=-0.45,
    crit=0.20,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
            
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if not EntUtil:can_extra_dmg(stimuli) then
                return 
            end
            local ex_dmg = self.db[1]
            local rate = inst.components.combat.tp_crit or 0
            ex_dmg = ex_dmg + ex_dmg*rate*self.db[2]
            EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, "fire", "pure"))
        end)
    end,
    db = {10, 2}
}, function(self, inst, cmp, id)
    local s = "【※鬼索】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击增加基于暴击率火属性伤害")
    return s
end, function(self, inst, cmp, id)
    local s = "【※鬼索】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击额外造成%d的火属性伤害,你每有1%%的暴击率,此伤害便提高%d%%", 
        self.db[1], self.db[2])
    return s
end),
Equip("lord_dominik_regard",
{
    dmg=15,
    crit=0.20,
    penetrate=50,
    attack = function(self, inst, cmp, id, data)
        if data.target then
            BuffManager:AddBuff(data.target, "armor_broken")
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【※多米尼克】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击会令敌人破甲")
    return s
end, function(self, inst, cmp, id)
    local s = "【※多米尼克】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById("armor_broken")
    s = s..string.format("攻击会施加debuff(%s)", buff:desc())
    return s
end),
Equip("essence_reaver",
{
    dmg=30,
    speed=0.20,
    crit=0.20,
    attack = function(self, inst, cmp, id, data)
        if data.target 
        and data.target.components.sanity then
            local max = data.target.components.sanity:GetMaxSanity()
            local dt = max*self.db[2]+self.db[1]
            data.target.components.sanity:DoDelta(dt)
            if EntUtil:is_alive(inst) then
                inst.components.health:DoDelta(dt)
            end
        end
    end,
    db = {30, .05},
}, function(self, inst, cmp, id)
    local s = "【※夺萃】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击会吸取目标的理智")
    return s
end, function(self, inst, cmp, id)
    local s = "【※夺萃】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("如果攻击目标拥有理智,攻击会降低目标最大理智%d%%+%d点理智,并回复自身等量的生命",
        self.db[2], self.db[1])
    return s
end),
Equip("sanguine_blade",
{
    dmg=25,
    penetrate = 10,
    life_steal = .5,
    init = function(self, inst, cmp, id)
        inst:ListenForEvent("healthdelta", function(inst, data)
            local p = inst.components.health:GetPercent()
            EntUtil:add_damage_mod(inst, id.."_buff", (1-p)/2)
        end)
    end,
}, function(self, inst, cmp, id)
    local s = "【※血刃】:"
    s = s..get_attr_desc(self, inst)
    s = s.."每失去2%%生命值,增加1%%攻击力"
    return s
end),
Equip("youmuu_ghostblade",
{
    dmg=30,
    penetrate = 20,
    init = function(self, inst, cmp, id)
        inst:ListenForEvent("newcombattarget", function(inst, data)
            if can_trigger_skill(inst)
            and not inst:HasTag(id.."_tag") 
            and data.target
            and data.target ~= data.oldtarget then
                inst:AddTag(id.."_tag")
                BuffManager:AddBuff(inst, "chase_target")
                -- EntUtil:add_speed_mod(inst, id.."_buff", self.db[1], self.db[2])
                inst:DoTaskInTime(self.db[3], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
        end)
    end,
    db = {.35, 6, 10},
}, function(self, inst, cmp, id)
    local s = "【※幽梦】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("发现目标后会增加%d%%移速,持续%ds,有%ds冷却",
    self.db[1]*100, self.db[2], self.db[3])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("the_collector",
{
    dmg=25,
    crit=0.20,
    penetrate = 20,
    attack = function(self, inst, cmp, id, data)
        if data and data.target and not data.target:HasTag("epic")
        and not data.target:HasTag("player") then
            local p = data.target.components.health:GetPercent()
            if p<=self.db[1] then
                data.target.components.health:Kill()
                FxManager:MakeFx("wathgrithr_spirit", data.target)
            end
        end
    end,
    db = {.05},
}, function(self, inst, cmp, id)
    local s = "【※收集者】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("斩杀生命低于%d%%的单位(对史诗生物和玩家无效)",
        self.db[1]*100)
    return s
end, function(self, inst, cmp, id)
    local s = "【※收集者】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("若目标生命值比例低于%d%%,则直接杀死目标(对史诗生物和玩家无效)",
        self.db[1]*100)
    return s
end),
Equip("wit_end",
{
    dmg=30,
    evade=50,
    attack_speed=-0.40,
    attack = function(self, inst, cmp, id, data)
        BuffManager:AddBuff(inst, id.."_buff")
    end,
}, function(self, inst, cmp, id)
    local s = "【※智慧末刃】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击会提升闪避(可叠加)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※智慧末刃】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("攻击会获得buff(%s)", 
        buff:desc(inst, inst.components.wg_simple_buff, id.."_buff"))
    return s
end),
Equip("death_dance",
{
    absorb=40,
    dmg=25,
    speed=0.15,
    init = function(self, inst, cmp, id)
        inst:ListenForEvent("killed", function(inst, data)
            BuffManager:AddBuff(inst, id.."_buff")
            FxManager:MakeFx("heal_fx", inst)
        end)
    end,
}, function(self, inst, cmp, id)
    local s = "【※死亡之舞】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("杀死单位后,恢复百分比生命值并提升防御")
    return s
end, function(self, inst, cmp, id)
    local s = "【※死亡之舞】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("杀死单位后,获得buff(%s)", buff:desc())
    return s
end),
Equip("titantic_hydra",
{
    hp=250,
    dmg=15,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
            
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if not EntUtil:can_extra_dmg(stimuli) then
                return 
            end
            local max_hp = inst.components.health:GetMaxHealth()
            local dmg = max_hp*self.db[1]
            EntUtil:get_attacked(target, inst, dmg, nil, EntUtil:add_stimuli(nil, "thump", "pure"))
        end)
    end,
    db = {.003},
}, function(self, inst, cmp, id)
    local s = "【※巨九】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击额外造成自身最大生命值%.2f%%的捶属性伤害",
        self.db[1]*100)
    return s
end),
Equip("navori_quickblades",
{
    dmg=30,
    crit=0.20,
    init = function(self, inst, cmp, id)
        inst:ListenForEvent("tp_crit", function(inst, data)
            BuffManager:AddBuff(inst, id.."_buff")
        end)
    end,
}, function(self, inst, cmp, id)
    local s = "【※迅刃】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("造成暴击后提升闪避和移速")
    return s
end, function(self, inst, cmp, id)
    local s = "【※迅刃】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("造成暴击后获得buff(%s)", buff:desc())
    return s
end),
Equip("serylda_grudge",
{
    dmg=25,
    penetrate = 50,
    attack = function(self, inst, cmp, id, data)
        if data.target then
            BuffManager:AddBuff(data.target, "armor_broken")
            BuffManager:AddBuff(data.target, id.."_debuff")
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【※塞瑞尔达】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击会令敌人破甲和减速")
    return s
end, function(self, inst, cmp, id)
    local s = "【※塞瑞尔达】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById("armor_broken")
    local buff2 = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击会施加debuff(%s)(%s)", 
        buff:desc(), buff2:desc())
    return s
end),
Equip("serpent_fang",
{
    dmg=55,
    attack = function(self, inst, cmp, id, data)
        if data.target and not data.target:HasTag("epic") then
            BuffManager:AddBuff(data.target, id.."_debuff")
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【※巨蛇之牙】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击会降低目标百分比生命上限")
    return s
end, function(self, inst, cmp, id)
    local s = "【※巨蛇之牙】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击会施加debuff(%s)(对史诗生物无效)", 
        buff:desc())
    return s
end),
}

local equips_def = {
Equip("malmortius_maw",
{
    dmg=25,
    speed=0.15,
    evade=50,
    hit = function(self, inst, cmp, id)
        -- if cmp[id.."_fx"] == nil then
        --     cmp[id.."_fx"] = FxManager:MakeFx("recover_equip_fx", Vector3(0,0,0))
        --     inst:AddChild(cmp[id.."_fx"])
        -- end
        if EntUtil:is_alive(inst) 
        and not inst:HasTag(id.."_tag") then
            if inst.components.health:GetPercent() <= self.db[1] then
                -- local max_hp = inst.components.health:GetMaxHealth()
                local base_dmg = inst.components.combat.defaultdamage
                local mult = inst.components.combat:GetDamageModifier()
                local dt = self.db[2]+base_dmg*mult*self.db[3]
                -- inst.components.health:DoDelta(dt)
                inst.components.tp_val_sheild:AddCurMod(id, dt)
                local rcv_fx = FxManager:MakeFx("recover_fx", Vector3(0,0,0))
                inst:AddChild(rcv_fx)
                BuffManager:AddBuff(inst, id.."_buff")
                -- if cmp[id.."_fx"] then
                --     cmp[id.."_fx"]:WgRecycle()
                --     cmp[id.."_fx"] = nil
                -- end
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[4], function()
                    inst:RemoveTag(id.."_tag")
                    -- if cmp[id.."_fx"] == nil then
                    --     cmp[id.."_fx"] = FxManager:MakeFx("recover_equip_fx", Vector3(0,0,0))
                    --     inst:AddChild(cmp[id.."_fx"])
                    -- end
                end)
            end
        end
    end,
    db = {.3, 200, 2.25, 30}
}, function(self, inst, cmp, id)
    local s = "【※大饮魔刀】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("生命低于%d%%时,获得基于攻击力的护盾,提升吸血和元素抗性(有cd)",
    self.db[1]*100, self.db[3]*100, self.db[2])
    return s
end, function(self, inst, cmp, id)
    local s = "【※大饮魔刀】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("受伤后,若你的生命值低于%d%%,回复攻击力%d%%+%d的生命值,并获得buff(%s),有%ds冷却",
    self.db[1]*100, self.db[3]*100, self.db[2], buff:desc(), self.db[4])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("randuin_omen", 
{
    hp=125,
    absorb = 80,
    speed=0.10,
    hit = function(self, inst, cmp, id, data)
        if data and data.attacker then
            BuffManager:AddBuff(data.attacker, id.."_debuff")
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【※兰顿】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("降低攻击者的攻击,攻速,移速")
    return s
end, function(self, inst, cmp, id)
    local s = "【※兰顿】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击者获得debuff(%s)", buff:desc())
    return s
end),
Equip("warmog_armor",
{
    hp=400,
    speed=0.10,
    recover=1,
    init = function(self, inst, cmp, id)
        cmp[id.."_wake"] = function(self, inst, cmp, id)
            if cmp[id.."_task"] == nil then
                cmp[id.."_task"] = inst:DoPeriodicTask(self.db[1], function()
                    local max_hp = inst.components.health:GetMaxHealth()
                    if EntUtil:is_alive(inst) then
                        inst.components.health:DoDelta(max_hp*self.db[2])
                    end
                end)
            end
        end
        cmp[id.."_wake"](self, inst, cmp, id)
    end,
    db = {2, .015}
}, function(self, inst, cmp, id)
    local s = "【※狂徒】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("每%ds回复%d%%生命上限的生命值", self.db[1], self.db[2])
    return s
end, function(self, inst, cmp, id)
    cmp[id.."_wake"](self, inst, cmp, id)
end, function(self, inst, cmp, id)
    if cmp[id.."_task"] then
        cmp[id.."_task"]:Cancel()
        cmp[id.."_task"] = nil
    end
end),
Equip("ask_flag",
{
    absorb=60,
    evade=30,
    speed=0.10,
    hit = function(self, inst, cmp, id, data)
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 6, nil, EntUtil.not_enemy_tags)
        for k, v in pairs(ents) do
            if EntUtil:check_congeneric(inst, v) then
                BuffManager:AddBuff(v, id.."_buff")
                FxManager:MakeFx("sparklefx", v)
            end
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【※号令之旗】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("受伤时增加周围同类的攻击和移速")
    return s
end, function(self, inst, cmp, id)
    local s = "【※号令之旗】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("受到攻击时令周围的同类获得buff(%s)", buff:desc())
    return s
end),
Equip("thornmail",
{
    hp=175,
    absorb=60,
    hit = function(self, inst, cmp, id, data)
        if EntUtil:can_thorns(data) then
            -- local dmg = data.damage*self.db[1]
            local defense = inst.components.combat:GetDefense()
            local dmg = self.db[1]+defense*self.db[2]
            dmg = math.min(self.db[3], dmg)
            -- data.attacker.components.health:DoDelta(-dmg)
            EntUtil:get_attacked(data.attacker, inst, dmg, nil, EntUtil:add_stimuli(nil, "spike", "pure"))
            BuffManager:AddBuff(data.attacker, "not_reflection")
            if not data.attacker:HasTag("epic") then
                BuffManager:AddBuff(data.attacker, "recover_debuff")
            end
            FxManager:MakeFx("thorns", inst)
        end
    end,
    db = {10, .1, 30},
}, function(self, inst, cmp, id)
    local s = "【※反甲】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("受伤时反伤刺属性伤害(基于防御),降低其恢复(史诗生物除外)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※反甲】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById("recover_debuff")
    s = s..string.format("受到攻击令敌人受到%dx防御系数+%d的刺属性伤害,令其获得debuff(%s)(不对史诗生物生效)", 
    self.db[2], self.db[1], buff:desc())
    return s
end),
Equip("redemption",
{
    hp=100,
    speed=0.15,
    recover=.5,
    hit = function(self, inst, cmp, id, data)
        if can_trigger_skill(inst)
        and not inst:HasTag(id.."_tag") then
            inst:AddTag(id.."_tag")
            inst:DoTaskInTime(self.db[2], function()
                inst:RemoveTag(id.."_tag")
            end)
            local x, y, z = inst:GetPosition():Get()
            local ents = TheSim:FindEntities(x, y, z, 6, nil, EntUtil.not_enemy_tags)
            for k, v in pairs(ents) do
                if EntUtil:check_congeneric(inst, v) then
                    if EntUtil:is_alive(v) then
                        local max_hp = v.components.health:GetMaxHealth()
                        local dt = max_hp*self.db[3]+self.db[4]
                        v.components.health:DoDelta(dt)
                        FxManager:MakeFx("heal_fx", v)
                    end
                end
            end
        end
    end,
    db = {.5, 5, .1, 15},
}, function(self, inst, cmp, id)
    local s = "【※救赎】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("受伤时回复周围的同类的生命值(基于其生命上限)(有cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※救赎】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("受到攻击时会令周围的同类回复%d%%最大生命+%d点的生命值(有%ds的冷却)",
    self.db[3]*100, self.db[4], self.db[2])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
-- Equip("zhonya_hourglass",
-- {
--     absorb=0.20,
--     speed=0.10,
--     hit = function(self, inst, cmp, id, data)
--         if can_trigger_skill(inst)
--         and inst.components.health:GetPercent() <= self.db[1] then
--             if not inst:HasTag(id.."_tag") then
--                 inst:AddTag(id.."_tag")
--                 inst:DoTaskInTime(self.db[2], function()
--                     inst:RemoveTag(id.."_tag")
--                 end)
--                 BuffManager:AddBuff(inst, "invincible")
--             end
--         end
--     end,
--     db = {.5, 15},
-- }, function(self, inst, cmp, id)
--     local s = "【※中娅】:"
--     s = s..get_attr_desc(self, inst)
--     local buff = BuffManager:GetDataById("invincible")
--     s = s..string.format("生命值小于%d%%时,受到攻击会获得buff(%s),有%ds冷却",
--     self.db[1]*100, buff:desc(), self.db[2])
--     local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
--     s = s..cd
--     return s
-- end),
Equip("sun_fire_cape",
{
    hp=210,
    absorb=60,
    attack = function(self, inst, cmp, id, data)
        data.attacker = inst
        local attacker = data.target
        if EntUtil:can_extra_dmg(data.stimuli)
        and EntUtil:can_thorns(data) then
            local max_hp = inst.components.health.wg_max_health
            local ex_dmg = math.min(self.db[3], max_hp*self.db[2])
            local dmg = ex_dmg+self.db[1]
            -- attacker.components.health:DoFireDamage(dmg, nil, true)
            EntUtil:get_attacked(attacker, inst, dmg, nil, EntUtil:add_stimuli(nil, "fire", "pure"))
            BuffManager:AddBuff(attacker, "not_reflection")
            FxManager:MakeFx("thorns_red", inst)
        end
    end,
    hit = function(self, inst, cmp, id, data)
        local attacker = data.attacker
        if EntUtil:can_thorns(data) then
            local max_hp = inst.components.health.wg_max_health
            local ex_dmg = math.min(self.db[3], max_hp*self.db[2])
            local dmg = ex_dmg+self.db[1]
            -- attacker.components.health:DoFireDamage(dmg, nil, true)
            EntUtil:get_attacked(attacker, inst, dmg, nil, EntUtil:add_stimuli(nil, "fire", "pure"))
            BuffManager:AddBuff(attacker, "not_reflection")
            FxManager:MakeFx("thorns_red", inst)
        end
    end,
    db = {6, .01, 20}
}, function(self, inst, cmp, id)
    local s = "【※日炎】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击和被攻击时,反馈基于基础生命的火属性伤害")
    return s
end, function(self, inst, cmp, id)
    local s = "【※日炎】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击和被攻击时,给予对方你基础最大生命%d%%(最高%d点)+%d的火属性伤害", 
    self.db[2]*100, self.db[3], self.db[1])
    return s
end),
Equip("dead_plate",
{
    hp=200,
    absorb=40,
    speed=0.10,
    init = function(self, inst, cmp, id)
        EntUtil:add_speed_mod(inst, id.."_buff", self.db[1])
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
            
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if not EntUtil:can_extra_dmg(stimuli) then
                return
            end
            if not inst:HasTag(id.."_tag") then
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[4], function()
                    inst:RemoveTag(id.."_tag")
                    EntUtil:add_speed_mod(inst, id.."_buff", self.db[1])
                end)

                local base_dmg = inst.components.combat.defaultdamage
                local ex_dmg = base_dmg*self.db[2]+self.db[3]
                EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, "strike", "pure"))

                EntUtil:rm_speed_mod(inst, id.."_buff")
                BuffManager:AddBuff(target, id.."_debuff")
            end
        end)
    end,
    db = {.3, .1, 10, 5}
}, function(self, inst, cmp, id)
    local s = "【※板甲】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("增加移速,攻击造成额外伤害并消耗移速加成(有cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※板甲】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("获得增益:提升%d%%移速,攻击额外造成基础攻击力%d%%+%d的打属性伤害,并施加debuff(%s),有%ds的冷却",
    self.db[1]*100, self.db[2]*100, self.db[3], buff:desc(), self.db[4])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("iceborn_gauntlet",
{
    hp=175,
    absorb=30,
    evade=30,
    speed=0.20,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
            
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if not EntUtil:can_extra_dmg(stimuli) then
                return 
            end
            if not inst:HasTag(id.."_tag") then
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[2], function()
                    inst:RemoveTag(id.."_tag")
                end)

                local base_dmg = inst.components.combat.defaultdamage
                local ex_dmg = base_dmg*self.db[1]
                EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, "ice", "pure"))
                
                FxManager:MakeFx("ice_fist", target)

                BuffManager:AddBuff(target, id.."_debuff", nil, {target=inst})
            end
        end)
    end,
    db = {.5, 6},
}, function(self, inst, cmp, id)
    local s = "【※冰拳】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击增加基础攻击力%d%%的冰属性伤害,并降低敌人移速和攻击(有cd)",
    self.db[1]*100)
    return s
end, function(self, inst, cmp, id)
    local s = "【※冰拳】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击额外造成基础攻击力%d%%的冰属性伤害,令目标获得debuff(%s),有%ds冷却",
    self.db[1]*100,  buff:desc(), self.db[2])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("iron_solari",
{
    hp=100,
    absorb=30,
    evade=30,
    speed=0.20,
    hit = function(self, inst, cmp, id, data)
        if can_trigger_skill(inst)
        and not inst:HasTag(id.."_tag") then
            inst:AddTag(id.."_tag")
            local x, y, z = inst:GetPosition():Get()
            local ents = TheSim:FindEntities(x, y, z, 6, nil, EntUtil.not_enemy_tags)
            for k, v in pairs(ents) do
                if EntUtil:check_congeneric(inst, v) then
                    BuffManager:AddBuff(v, id.."_buff")
                    FxManager:MakeFx("sparklefx", v)
                end
            end
            inst:DoTaskInTime(self.db[1], function()
                inst:RemoveTag(id.."_tag")
            end)
        end
    end,
    db = {6},
}, function(self, inst, cmp, id)
    local s = "【※钢铁烈阳】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("被攻击令周围的同类增加移速和防御")
    return s
end, function(self, inst, cmp, id)
    local s = "【※钢铁烈阳】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("受到攻击令周围的同类获得buff(%s),有%ds冷却",
    buff:desc(), self.db[1])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("spirit_visage",
{
    hp=225,
    speed=0.10,
    evade=40,
    recover=1,
}, function(self, inst, cmp, id)
    local s = "【※振奋盔甲】:"
    s = s..get_attr_desc(self, inst)
    s = s..""
    return s
end),
Equip("nature_force",
{
    hp=175,
    speed=0.10,
    evade=60,
    hit = function(self, inst, cmp, id, data)
        BuffManager:AddBuff(inst, id.."_buff")
    end,
}, function(self, inst, cmp, id)
    local s = "【※自然之力】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("受到攻击后,增加防御(可叠加)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※自然之力】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("受到攻击后,获得buff(%s)", 
        buff:desc(inst, inst.components.wg_simple_buff, id.."_buff"))
    return s
end),
-- Equip("guardian_angel",
-- {
--     absorb=40,
--     dmg=20,
--     init = function(self, inst, cmp, id)
--         if cmp[id.."_fx"] == nil then
--             cmp[id.."_fx"] = FxManager:MakeFx("recover_equip_fx", Vector3(0,0,0))
--             inst:AddChild(cmp[id.."_fx"])
--         end
--         -- if cmp[id.."_fx"] then
--         --     cmp[id.."_fx"]:WgRecycle()
--         --     cmp[id.."_fx"] = nil
--         -- end
--         inst:AddTag(id.."_tag")
--         if inst.components.health then
--             inst.components.health:SetMinHealth(1)
--             inst:ListenForEvent("minhealth", function(inst, data)
--                 if inst:HasTag(id.."_tag") and data 
--                 and data.cause ~= "file_load" then
--                     FxManager:MakeFx("wathgrithr_spirit", inst)
--                     inst.components.health:SetPercent(self.db[1])
--                     inst.components.health:SetMinHealth(0)
--                     inst:RemoveTag(id.."_tag")
--                     BuffManager:AddBuff(inst, "invincible")
--                     if cmp[id.."_fx"] then
--                         cmp[id.."_fx"]:WgRecycle()
--                         cmp[id.."_fx"] = nil
--                     end
--                     inst:DoTaskInTime(self.db[2], function()
--                         inst.components.health:SetMinHealth(1)
--                         inst:AddTag(id.."_tag")
--                         if cmp[id.."_fx"] == nil then
--                             cmp[id.."_fx"] = FxManager:MakeFx("recover_equip_fx", Vector3(0,0,0))
--                             inst:AddChild(cmp[id.."_fx"])
--                         end
--                     end)
--                 end
--             end)
--         end
--     end,
--     db = {.3, 60},
-- }, function(self, inst, cmp, id)
--     local s = "【※守护天使】:"
--     s = s..get_attr_desc(self, inst)
--     local buff = BuffManager:GetDataById("invincible")
--     s = s..string.format("受到致命伤后,恢复%d%%的生命,并获得buff(%s),有%ds的冷却",
--     self.db[1]*100, buff:desc(), self.db[2])
--     local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
--     s = s..cd
--     return s
-- end),
Equip("frozen_heart",
{
    absorb=80,
    speed=0.20,
    const=0.10,
    hit = function(self, inst, cmp, id, data)
        if data and data.attacker then
            BuffManager:AddBuff(data.attacker, id.."_debuff")
            if not inst:HasTag(id.."_tag") then
                inst:AddTag(id.."_tag")
                EntUtil:frozen(data.attacker)
                inst:DoTaskInTime(self.db[1], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
        end
    end,
    db = {4},
}, function(self, inst, cmp, id)
    local s = "【※冰心】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("令攻击者降低攻击力和移速;并冰冻对方1层(有cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※冰心】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("令攻击者获得debuff(%s),并对敌人施加1层冰冻效果(冰冻有%ds冷却)",
    buff:desc(), self.db[1])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("righteous_glory",
{
    hp=200,
    absorb=30,
    recover=1,
    init = function(self, inst, cmp, id)
        inst:ListenForEvent("newcombattarget", function(inst, data)
            if can_trigger_skill(inst)
            and not inst:HasTag(id.."_tag")
            and data.target 
            and data.target ~= data.oldtarget then
                inst:AddTag(id.."_tag")
                -- EntUtil:add_speed_mod(inst, id, self.db[1], self.db[2])
                BuffManager:AddBuff(inst, "chase_target")
                BuffManager:AddBuff(data.target, id.."_debuff")
                inst:DoTaskInTime(self.db[3], function()
                    inst:RemoveTag(id.."_tag")
                end)
                FxManager:MakeFx("statue_transition", data.target)
            end
        end)
    end,
    db = {.5, 5, 15}
}, function(self, inst, cmp, id)
    local s = "【※正义荣耀】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("发现目标后提升移速并减速目标(有cd)")
    return s
end, function(self, inst, cmp, id)
    local s = "【※正义荣耀】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("发现攻击目标后,提升移速%d%%,持续%ds,并施加debuff(%s),有%ds冷却",
    self.db[1]*100, self.db[2], buff:desc(), self.db[3])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("sterakgage",
{
    hp=200,
    dmg=25,
    hit = function(self, inst, cmp, id, data)
        -- if cmp[id.."_fx"] == nil then
        --     cmp[id.."_fx"] = FxManager:MakeFx("recover_equip_fx", Vector3(0,0,0))
        --     inst:AddChild(cmp[id.."_fx"])
        -- end
        -- if cmp[id.."_fx"] then
        --     cmp[id.."_fx"]:WgRecycle()
        --     cmp[id.."_fx"] = nil
        -- end
        if EntUtil:is_alive(inst) 
        and not inst:HasTag(id.."_tag") then
            if inst.components.health:GetPercent() <= self.db[1] then
                local max_hp = inst.components.health:GetMaxHealth()
                -- local base_dmg = inst.components.combat.defaultdamage
                -- local dt = self.db[2]+max_hp*self.db[3]+base_dmg*self.db[4]
                local dt = self.db[2]+max_hp*self.db[3]
                -- inst.components.health:DoDelta(dt)
                inst.components.tp_val_sheild:AddCurMod(id, dt)
                local rcv_fx = FxManager:MakeFx("recover_fx", Vector3(0,0,0))
                inst:AddChild(rcv_fx)
                BuffManager:AddBuff(inst, id.."_buff")
                -- if cmp[id.."_fx"] then
                --     cmp[id.."_fx"]:WgRecycle()
                --     cmp[id.."_fx"] = nil
                -- end

                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[4], function()
                    inst:RemoveTag(id.."_tag")
                    -- if cmp[id.."_fx"] == nil then
                    --     cmp[id.."_fx"] = FxManager:MakeFx("recover_equip_fx", Vector3(0,0,0))
                    --     inst:AddChild(cmp[id.."_fx"])
                    -- end
                end)
            end
        end
    end,
    db = {.3, 100, .32, 35}
}, function(self, inst, cmp, id)
    local s = "【※血手】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("生命值低于%d%%时,获得护盾,提升生命上限,增加攻击力",
    self.db[1]*100)
    return s
end, function(self, inst, cmp, id)
    local s = "【※血手】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("受到攻击后,若你的生命值低于%d%%,回复%d%%最大生命+%d的生命值,有%ds冷却",
    self.db[1]*100, self.db[3]*100, self.db[2], self.db[4])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("gargoyle_stoneplate",
{
    speed=0.15,
    evade=60,
    init = function(self, inst, cmp, id)
        -- inst.components.health:WgAddMaxHealthMultiplier(id.."_buff", 1, true)
        local max_hp = inst.components.health:GetMaxHealth()
        inst.components.tp_val_sheild:AddCurMod(id, max_hp)
    end,
    hit = function(self, inst, cmp, id, data)
        if cmp[id.."_task"] then
            cmp[id.."_task"]:Cancel()
            cmp[id.."_task"] = nil
        end
        cmp[id.."_task"] = inst:DoTaskInTime(100, function(inst)
            local max_hp = inst.components.health:GetMaxHealth()
            inst.components.tp_val_sheild:AddCurMod(id, max_hp)
        end)
    end,
}, function(self, inst, cmp, id)
    local s = "【※石像鬼】:"
    s = s..get_attr_desc(self, inst)
    s = s.."获得100%最大生命值的护盾"
    return s
end),
}

local small_equips_atk = {
Equip("kircheis_shard",
{
	attack_speed=-0.15,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
            
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if not EntUtil:can_extra_dmg(stimuli) then
                return
            end
            if not inst:HasTag(id.."_tag") then
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[2], function()
                    inst:RemoveTag(id.."_tag")
                end)

                FxManager:MakeFx("hit_fx8", inst, {target=target})
                local ex_dmg = self.db[1]
                EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, "electric", "pure"))
            end
        end)
    end,
    db = {10, 10},
}, function(self, inst, cmp, id)
    local s = "【基舍碎片】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击增加%d点雷属性伤害(有cd)", self.db[1])
    return s
end, function(self, inst, cmp, id)
    local s = "【基舍碎片】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击会额外造成%d点雷属性伤害,有%ds冷却",
    self.db[1], self.db[2])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("rageknife",
{
	attack_speed=-0.25,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
            
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if not EntUtil:can_extra_dmg(stimuli) then
                return
            end
            local ex_dmg = self.db[1]
            EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, "slash", "pure"))
        end)
    end,
    attack = function(self, inst, cmp, id, data)
        BuffManager:AddBuff(inst, id.."_buff")
    end,
    db = {6},
}, function(self, inst, cmp, id)
    local s = "【狂怒小刀】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击增加%d点斩属性伤害,增加攻速(可叠加)", self.db[1])
    return s
end, function(self, inst, cmp, id)
    local s = "【狂怒小刀】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("攻击额外造成%d点斩属性伤害,并获得buff(%s)",
        self.db[1], buff:desc(inst, inst.components.wg_simple_buff, id.."_buff"))
    return s
end),
Equip("executioner_calling",
{
	dmg=10,
    attack = function(self, inst, cmp, id, data)
        if data and data.target then
            BuffManager:AddBuff(data.target, id.."_debuff")
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【死刑宣告】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击会降低敌人生命恢复")
    return s
end, function(self, inst, cmp, id)
    local s = "【死刑宣告】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击会施加debuff(%s)",
        buff:desc())
    return s
end),
Equip("vampirie_scepter",
{
	dmg=10,
    life_steal = .3,
}, function(self, inst, cmp, id)
    local s = "【吸血杖】:"
    s = s..get_attr_desc(self, inst)
    s = s..""
    return s
end),
Equip("recurve_bow",
{
    dmg=5,
	attack_speed=-0.25,
    db = {5},
}, function(self, inst, cmp, id)
    local s = "【反曲弓】:"
    s = s..get_attr_desc(self, inst)
    return s
end),
Equip("phage",
{
	hp=100,
	dmg=10,
    attack = function(self, inst, cmp, id, data)
        if data and data.target then
            if math.random() < self.db[1] then
                BuffManager:AddBuff(data.target, id.."_debuff")
            end
        end
    end,
    db = {.35},
}, function(self, inst, cmp, id)
    local s = "【净蚀】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击%d%%几率降低敌人移速",
        self.db[1])
    return s
end, function(self, inst, cmp, id)
    local s = "【净蚀】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击有%d%%几率令敌人获得debuff(%s)",
        self.db[1]*100, buff:desc())
    return s
end),
Equip("hearthbound_axe",
{
	dmg=10,
	attack_speed=-0.15,
    attack = function(self, inst, cmp, id, data)
        BuffManager:AddBuff(inst, id.."_buff")
    end,
}, function(self, inst, cmp, id)
    local s = "【缚炉之斧】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击提升移速")
    return s
end, 
function(self, inst, cmp, id)
    local s = "【缚炉之斧】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("攻击获得buff(%s)", buff:desc())
    return s
end),
Equip("serrated_dirk",
{
	dmg=15,
    penetrate = 10,
}, function(self, inst, cmp, id)
    local s = "【锯齿短匕】:"
    s = s..get_attr_desc(self, inst)
    s = s..""
    return s
end),
Equip("caulfield_warhammer",
{
	dmg=15,
	speed=0.10,
}, function(self, inst, cmp, id)
    local s = "【战锤】:"
    s = s..get_attr_desc(self, inst)
    s = s..""
    return s
end),
Equip("zeal",
{
	attack_speed=-0.20,
	speed=0.10,
	crit=0.15,
}, function(self, inst, cmp, id)
    local s = "【狂热】:"
    s = s..get_attr_desc(self, inst)
    s = s..""
    return s
end),
Equip("hexdrinker",
{
	dmg=10,
    hit = function(self, inst, cmp, id)
        if EntUtil:is_alive(inst) 
        and not inst:HasTag(id.."_tag") then
            if inst.components.health:GetPercent() <= self.db[1] then
                local min = self.db[2]
                local max = self.db[3]
                local dt = min+(max-min)/90*cmp.level
                -- inst.components.health:DoDelta(dt)
                inst.components.tp_val_sheild:AddCurMod(id, dt)
                local fx = FxManager:MakeFx("heal_fx", Vector3(0,0,0))
                inst:AddChild(fx)
                BuffManager:AddBuff(inst, id.."_buff")

                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[4], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
        end
    end,
    db = {.3, 110, 280, 35},
}, function(self, inst, cmp, id)
    local s = "【饮魔刀】:"
    local min = self.db[2]
    local max = self.db[3]
    local dt = min+(max-min)/90*cmp.level
    s = s..get_attr_desc(self, inst)
    s = s..string.format("生命值低于%d%%时,回复%d护盾(看等级)并提高元素抗性(有cd)",
    self.db[1]*100, dt, self.db[4])
    return s
end,
function(self, inst, cmp, id)
    local s = "【饮魔刀】:"
    local min = self.db[2]
    local max = self.db[3]
    local dt = min+(max-min)/90*cmp.level
    s = s..get_attr_desc(self, inst)
    s = s..string.format("受伤后,若你的生命值低于%d%%,回复%d生命(基于等级提升),有%ds冷却",
    self.db[1]*100, dt, self.db[4])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("noonquiver",
{
	dmg=15,
	attack_speed=-0.15,
    init = function(self, inst, cmp, id)
        -- inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
        --     local data = {damage=damage, inst=inst, target=target, weapon=weapon}
        --     local dmg = data.damage
            
        --     return dmg
        -- end)
        inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
            if not EntUtil:can_dmg_effect(stimuli) then
                return 
            end
            if not EntUtil:can_extra_dmg(stimuli) then
                return
            end
            if target and not target:HasTag("epic")
            and not target:HasTag("largecreature") then
                local ex_dmg = self.db[1]
                EntUtil:get_attacked(target, inst, ex_dmg, nil, EntUtil:add_stimuli(nil, "spike", "pure"))
            end
        end)
    end,
    db = {15},
}, function(self, inst, cmp, id)
    local s = "【箭袋】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击额外造成%d点刺属性伤害(处boss,大型生物外)",
    self.db[1])
    return s
end),
Equip("last_whisper",
{
	dmg=20,
    penetrate = 30,
}, function(self, inst, cmp, id)
    local s = "【轻语】:"
    s = s..get_attr_desc(self, inst)
    s = s..""
    return s
end),
}

local small_equips_def = {
Equip("warden_mail",
{
	absorb=40,
    hit = function(self, inst, cmp, id, data)
        if data and data.attacker then
            BuffManager:AddBuff(data.attacker, id.."_debuff")
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【守望铠甲】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("降低攻击者的攻击")
    return s
end,
function(self, inst, cmp, id)
    local s = "【守望铠甲】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击者获得debuff(%s)", buff:desc())
    return s
end),
Equip("bami_cinder",
{
	hp=150,
    attack = function(self, inst, cmp, id, data)
        data.attacker = inst
        local attacker = data.target
        if EntUtil:can_thorns(data)
        and EntUtil:can_extra_dmg(data.stimuli) then
            local max_hp = inst.components.health.wg_max_health
            local ex_dmg = math.min(self.db[3], max_hp*self.db[2])
            local dmg = ex_dmg+self.db[1]
            EntUtil:get_attacked(attacker, inst, dmg, nil, EntUtil:add_stimuli(nil, "fire", "pure"))
            -- attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
            FxManager:MakeFx("thorns_red", attacker)
        end
    end,
    hit = function(self, inst, cmp, id, data)
        local attacker = data.attacker
        if EntUtil:can_thorns(data) then
            local max_hp = inst.components.health.wg_max_health
            local ex_dmg = math.min(self.db[3], max_hp*self.db[2])
            local dmg = ex_dmg+self.db[1]
            EntUtil:get_attacked(attacker, inst, dmg, nil, EntUtil:add_stimuli(nil, "fire", "pure"))
            -- attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
            FxManager:MakeFx("thorns_red", attacker)
        end
    end,
    db = {2, .01, 8}
}, function(self, inst, cmp, id)
    local s = "【熔渣】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击/被攻击反伤火属性伤害(基于生命上限)")
    return s
end,
function(self, inst, cmp, id)
    local s = "【熔渣】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击和被攻击时,给予对方你基础最大生命%d%%+%d的火属性伤害", 
        self.db[2]*100, self.db[1])
    return s
end),
Equip("spectre_cowl",
{
    hp=125,
    recover=.5,
}, function(self, inst, cmp, id)
    local s = "【幽魂斗篷】:"
    s = s..get_attr_desc(self, inst)
    s = s..""
    return s
end),
Equip("aegis_legion",
{
	absorb=30,
	speed=0.10,
    hit = function(self, inst, cmp, id, data)
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 6, nil, EntUtil.not_enemy_tags)
        for k, v in pairs(ents) do
            if EntUtil:check_congeneric(inst, v) then
                BuffManager:AddBuff(v, id.."_buff")
            end
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【军团】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("被攻击时强化周围同类的攻击和防御")
    return s
end,
function(self, inst, cmp, id)
    local s = "【军团】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("被攻击时令周围同类获得buff(%s)", buff:desc())
    return s
end),
Equip("glacial_buckler",
{
    hp=75,
    absorb=20,
}, function(self, inst, cmp, id)
    local s = "【冰川圆盾】:"
    s = s..get_attr_desc(self, inst)
    s = s..""
    return s
end),
Equip("giant_belt",
{
    hp=175,
}, function(self, inst, cmp, id)
    local s = "【巨人腰带】:"
    s = s..get_attr_desc(self, inst)
    s = s..""
    return s
end),
Equip("crystalline_bracer",
{
    hp=100,
}, function(self, inst, cmp, id)
    local s = "【护腕】:"
    s = s..get_attr_desc(self, inst)
    s = s..""
    return s
end),
Equip("chain_vest",
{
	absorb=40,
}, function(self, inst, cmp, id)
    local s = "【锁子甲】:"
    s = s..get_attr_desc(self, inst)
    s = s..""
    return s
end),
Equip("winged_moonplate",
{
	hp=75,
	speed=0.05,
}, function(self, inst, cmp, id)
    local s = "【月板甲】:"
    s = s..get_attr_desc(self, inst)
    s = s..""
    return s
end),
Equip("kindlegem",
{
	hp=100,
	speed=0.10,
}, function(self, inst, cmp, id)
    local s = "【燃烧宝石】:"
    s = s..get_attr_desc(self, inst)
    s = s..""
    return s
end),
Equip("bramble_vest",
{
	absorb=40,
    hit = function(self, inst, cmp, id, data)
        if EntUtil:can_thorns(data) then
            local dmg = self.db[1]
            -- data.attacker.components.health:DoDelta(-dmg)
            EntUtil:get_attacked(data.attacker, inst, dmg, nil, EntUtil:add_stimuli(nil, "spike", "pure"))
            BuffManager:AddBuff(data.attacker, "not_reflection")
            FxManager:MakeFx("thorns", inst)
        end
    end,
    db = {5},
}, function(self, inst, cmp, id)
    local s = "【小反甲】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("被攻击时反伤%d点刺属性伤害",
        self.db[1])
    return s
end),
}

local animal_equips = {
    Equip("poison_gland", {
        hp = 20,
        attack = function(self, inst, cmp, id, data)
            if not EntUtil:can_extra_dmg(data.stimuli) then
                return
            end
            EntUtil:get_attacked(data.target, inst, 10, nil, EntUtil:add_stimuli(nil, "poison", "pure") )
        end,
    }, function(self, inst, cmp, id)
        local s = "【毒腺】:"
        s = s..get_attr_desc(self, inst)
        s = s.."攻击增加10点毒属性伤害"
        return s
    end),
    Equip("sharp_tooth", {
        dmg = 5,
        attack = function(self, inst, cmp, id, data)
            if not EntUtil:can_extra_dmg(data.stimuli) then
                return
            end
            EntUtil:get_attacked(data.target, inst, 10, nil, EntUtil:add_stimuli(nil, "blood", "pure") )
        end,
    }, function(self, inst, cmp, id)
        local s = "【利齿】:"
        s = s..get_attr_desc(self, inst)
        s = s.."攻击增加10点血属性伤害"
        return s
    end),
    Equip("fire_stone", {
        hp = 30,
        init = function(self, inst, cmp, id)
            EntUtil:add_damage_mod(inst, id, -0.2)
            inst.components.combat:AddDmgTypeAbsorb("fire", -0.3)
        end,
        attack = function(self, inst, cmp, id, data)
            local dmg = data.damage or 0
            EntUtil:get_attacked(data.target, inst, dmg*.3, nil, EntUtil:add_stimuli(nil, "fire", "pure") )
        end,
    }, function(self, inst, cmp, id)
        local s = "【火之石】:"
        s = s..get_attr_desc(self, inst)
        s = s.."降低攻击,增加火抗,攻击额外造成30%火属性伤害"
        return s
    end),
    Equip("ice_stone", {
        hp = 30,
        init = function(self, inst, cmp, id)
            EntUtil:add_damage_mod(inst, id, -0.2)
            inst.components.combat:AddDmgTypeAbsorb("ice", -0.3)
        end,
        attack = function(self, inst, cmp, id, data)
            local dmg = data.damage or 0
            EntUtil:get_attacked(data.target, inst, dmg*.3, nil, EntUtil:add_stimuli(nil, "ice", "pure") )
        end,
    }, function(self, inst, cmp, id)
        local s = "【冰之石】:"
        s = s..get_attr_desc(self, inst)
        s = s.."降低攻击,增加冰抗,攻击额外造成30%冰属性伤害"
        return s
    end),
    Equip("sharp_horn", {
        absorb = 20,
        attack = function(self, inst, cmp, id, data)
            BuffManager:AddBuff(data.target, "sharp_horn_debuff")
        end,
    }, function(self, inst, cmp, id)
        local s = "【利角】:"
        s = s..get_attr_desc(self, inst)
        s = s.."攻击会降低敌人防御"
        return s
    end),
    Equip("fighter", {
        hp = 20,
        attack = function(self, inst, cmp, id, data)
            if not inst:HasTag(id.."_tag") and math.random() < 0.3 then
                inst.components.combat:ResetCooldown() 
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(3, function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
        end,
    }, function(self, inst, cmp, id)
        local s = "【斗士】:"
        s = s..get_attr_desc(self, inst)
        s = s.."攻击有30%概率攻击无cd(不能连续触发)"
        return s
    end),
    -- Equip("firm", {
    --     hp = 50,
    --     hit = function(self, inst, cmp, id, data)
    --         cmp[id.."_stack"] = cmp[id.."_stack"] or 0
    --         if cmp[id.."_stack"] >= 5 then
    --             cmp[id.."_stack"] = 0
    --             if EntUtil:is_alive(inst) then
    --                 inst.components.health:DoDelta(30)
    --             end
    --         end
    --         cmp[id.."_stack"] = cmp[id.."_stack"] + 1
    --     end
    -- }, function(self, inst, cmp, id)
    --     local s = "【坚韧】:"
    --     s = s..get_attr_desc(self, inst)
    --     s = s.."每被攻击5次,回复30点生命值"
    --     return s
    -- end),
    Equip("firm", {
        hp = 50,
        init = function(self, inst, cmp, id)
            inst:ListenForEvent("val_sheild_delta", function(inst, data)
                local cur = inst.components.tp_val_sheild:GetCurrent()
                if cur > 0 then
                    inst.components.combat:AddDefenseMod(id, 50)
                else
                    inst.components.combat:RmDefenseMod(id)
                end
            end)
        end
    }, function(self, inst, cmp, id)
        local s = "【坚韧】:"
        s = s..get_attr_desc(self, inst)
        s = s.."你拥有护盾时,获得50点防御"
        return s
    end),
    Equip("gear_core", {
        hp = 40,
        init = function(self, inst, cmp, id)
            inst:ListenForEvent("attacked", function(inst, data)
                if not inst:HasTag("gear_core_wake")
                and EntUtil:in_stimuli(data.stimuli, "electric") then
                    BuffManager:AddBuff(inst, "gear_core_wake")
                end
            end)
        end
    }, function(self, inst, cmp, id)
        local s = "【齿轮核心】:"
        s = s..get_attr_desc(self, inst)
        s = s.."受到电属性伤害后,攻击速度提高30%,移动速度提高30%"
        return s
    end),
    Equip("world_boss", {
        post = function(self, inst, cmp, id)
            local num = #cmp.equips
            inst.components.combat:WgAddCalcDamageFn(function(damage, inst, target, weapon)
                local data = {damage=damage, inst=inst, target=target, weapon=weapon}
                local dmg = data.damage
                dmg = dmg+num*30
                return dmg
            end)
            inst.components.health:WgAddMaxHealthModifier(id, num*300, true)
        end,
    }, function(self, inst, cmp, id)
        local s = "【Boss】:"
        s = s..get_attr_desc(self, inst)
        s = s.."每有1件装备,攻击力增加30点,生命值增加300点"
        return s
    end),
}

local DataManager = require "extension/lib/data_manager"
-- CreatureEquipManager:SetName("CreatureEquipManager")
local CreatureEquipManager = DataManager("CreatureEquipManager")
CreatureEquipManager:SetUniqueIdMode()
CreatureEquipManager:AddDatas(large_equips_atk, "large_equips_atk")
CreatureEquipManager:AddDatas(large_equips_def, "large_equips_def")
CreatureEquipManager:AddDatas(equips_atk, "equips_atk")
CreatureEquipManager:AddDatas(equips_def, "equips_def")
CreatureEquipManager:AddDatas(small_equips_atk, "small_equips_atk")
CreatureEquipManager:AddDatas(small_equips_def, "small_equips_def")
CreatureEquipManager:AddDatas(animal_equips, "animal_equips")

Sample.CreatureEquipManager = CreatureEquipManager