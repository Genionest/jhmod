local function Equip(name, data)
    return {
        name = name,
        GetId = function(self)
            return self.name
        end,
        data = data
    }
end

local large_equips_atk = {
Equip("divine_sunderer", {
    dmg = 40,
    hp = 400,
    speed = 0.2,
    init = function(self, inst, cmp, id)
        inst:AddTag("tp_not_freezable")
        inst:AddTag("tp_not_fire_damage")
        inst:AddTag("tp_not_poisonable")
        inst:AddTag("tp_not_poison_damage")
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            if not inst:HasTag(id.."_tag")
            and data.target
            and not data.target:HasTag("epic") then
                inst:AddTag(id.."_tag")
                local max_hp = data.target.components.health:GetMaxHealth()
                local ex_dmg = max_hp*self.db[1]
                dmg = dmg+ex_dmg
                if EntUtil:is_alive(inst) then
                    inst.components.health:DoDelta(dmg*self.db[2])
                end
                -- BuffManager:AddBuff(data.target, id.."_debuff")
                inst:DoTaskInTime(self.db[3], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
            return dmg
        end)
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        inst.components.combat:AddPenetrateMod(id.."_buff2", num*self.db[4])
        inst.components.combat:AddHitRateMod(id.."_buff2", num*self.db[5])
    end,
    db = {.05, .5, 8, .05, .05},
}, function(self, inst, cmp, id)
    local s = "【※※神分】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d%%穿透和%d%%命中;", self.db[4]*100, self.db[5]*100)
    s = s..string.format("免疫冰火毒;攻击额外造成目标最大生命值%d%%的伤害(对史诗生物无效),你回复这次攻击伤害的%d%%,有%ds的冷却",
    self.db[1]*100, self.db[2]*100, self.db[3])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("duskblade_draktharr", {
    dmg=60,
    penetrate=.2,
    speed=.2,
    init = function(self, inst, cmp, id)
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            if not inst:HasTag(id.."_tag") then
                inst:AddTag(id.."_tag")
                local base_dmg = inst.components.combat.defaultdamage
                local ex_dmg = base_dmg*self.db[1]+self.db[2]
                dmg = dmg+ex_dmg
                BuffManager:AddBuff(data.target, id.."_debuff")
                inst:DoTaskInTime(self.db[3], function()
                    inst:RemoveTag(id.."_tag")
                end)
                -- 召唤触手
                local target = data.target
                local attacker = inst
                local pt = target:GetPosition()
                local st_pt =  FindWalkableOffset(pt or attacker:GetPosition(), math.random()*2*PI, 2, 3)
                if st_pt then
                    if attacker.SoundEmitter then
                        attacker.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
                        attacker.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")            
                    end
                    st_pt = st_pt + pt
                    local st = SpawnPrefab("shadowtentacle")
                    --print(st_pt.x, st_pt.y, st_pt.z)
                    st.Transform:SetPosition(st_pt.x, st_pt.y, st_pt.z)
                    st.components.combat:SetTarget(target)
                    st.components.combat:SetRange(self.db[4])
                end
            end
            return dmg
        end)
        -- inst:ListenForEvent("killed", function(inst, data)
        --     BuffManager:AddBuff(inst, id.."_buff")
        -- end)
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        inst.components.combat:AddPenetrateMod(id.."_buff2", num*self.db[5])
    end,
    db = {.25, 33, 10, 3, 0.05},
}, function(self, inst, cmp, id)
    local s = "【※※幕刃】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d%%穿透;", self.db[5]*100)
    local buff = BuffManager:GetDataById(id.."_debuff")
    -- local buff2 = BuffManager:GetDataById(id.."_buff")
    -- s = s..string.format("你的攻击会额外造成攻击力%d%%+%d伤害,并令目标获得debuff(%s),有%ds冷却;你杀死单位后,获得buff(%s)", 
    -- self.db[1]*100, self.db[2], buff:desc(), self.db[3], buff2:desc())
    s = s..string.format("你的攻击会额外造成基础攻击力%d%%+%d伤害,并召唤1个攻击距离为%d的暗影触手,并令目标获得debuff(%s),有%ds冷却", 
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
        if inst:HasTag("epic")
        and not inst:HasTag("galeforce_equip") then
            if cmp[id.."_task"] == nil then
                cmp[id.."_task"] = inst:DoPeriodicTask(self.db[4]/10, function()
                    local target = inst.components.combat.target
                    if target and inst:IsNear(target, 20)
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
        if (not inst:HasTag("epic") 
        or inst:HasTag("galeforce_equip"))
        and inst.components.combat:GetWeapon() == nil then
            local fx = FxManager:MakeFx("ballightning", Vector3(0,0,0))
            inst:AddChild(fx)
            local weapon = CreateEntity()
            weapon.entity:AddTransform()
            weapon:AddComponent("weapon")
            weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
            weapon.components.weapon:SetRange(self.db[5], self.db[5]+2)
            weapon.components.weapon:SetProjectile("bishop_charge")
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
        end
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            if not inst:HasTag(id.."_tag") then
                inst:AddTag(id.."_tag")
                local min, max = self.db[1], self.db[2]
                local base = min+(max-min)/90*cmp.level
                local base_dmg = inst.components.combat.defaultdamage
                dmg = dmg+base+base_dmg*self.db[3]
                inst:DoTaskInTime(self.db[4], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
            return dmg
        end)
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        EntUtil:add_attack_speed_mod(inst, id.."_buff2", num*self.db[6])
    end,
    db = {60, 105, .15, 30, 6, -.03},
}, function(self, inst, cmp, id)
    local s = "【※※狂风之力】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d%%攻速;", -self.db[6]*100)
    local min, max = self.db[1], self.db[2]
    local base = min+(max-min)/90*cmp.level
    s = s..string.format("若不为史诗生物,装备一个攻击距离为%d的武器;攻击额外造成基础攻击力%d%%+%d(基于等级提升)的伤害,有%ds的冷却;",
    self.db[5], self.db[3]*100, base, self.db[4])
    s = s..string.format("若为史诗生物,召唤一阵旋风攻击敌人,造成攻击力%d%%+%d(基于等级提升)的伤害,有%ds的冷却",
    self.db[3]*100, base, self.db[4])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("goredrinker", {
    dmg=45,
    hp=400,
    recover=1,
    speed=.2,
    init = function(self, inst, cmp, id)
        -- if cmp[id.."_task"] then
        --     cmp[id.."_task"] = inst:DoPeriodicTask(self.db[1], function()
        --         local target = inst.components.combat.target
        --         if target and inst:IsNear(target, 4) then
        --             local base_dmg = inst.components.combat.defaultdamage
        --             local dmg = base_dmg*self.db[2]
        --             EntUtil:get_attacked(target, inst, dmg, nil, nil, nil)
        --             local max_hp = inst.components.health:GetMaxHealth()
        --             local cur = inst.components.health.currenthealth
        --             local dt = (max_hp-cur)*self.db[3]+base_dmg*mult*self.db[4]
        --             inst.components.health:DoDelta(dt)
        --             FxManager:MakeFx("statue_transition_2", target)
        --         end
        --     end)
        -- end
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            if not inst:HasTag(id.."_tag") then
                inst:AddTag(id.."_tag")
                local base_dmg = inst.components.combat.defaultdamage
                dmg = dmg+base_dmg*self.db[2]
                local max_hp = inst.components.health:GetMaxHealth()
                local cur = inst.components.health.currenthealth
                local dt = (max_hp-cur)*self.db[3]+base_dmg*self.db[4]
                if EntUtil:is_alive(inst) then
                    inst.components.health:DoDelta(dt)
                end
                inst:DoTaskInTime(self.db[1], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
            return dmg
        end)
        inst:ListenForEvent("healthdelta", function(inst, data)
            local p = inst.components.health:GetPercent()
            EntUtil:add_damage_mod(inst, id.."_buff", 1-p)
        end)
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        EntUtil:add_speed_mod(inst, id.."_buff2", num*self.db[5])
    end,
    db = {10, 1, .3, .25, .05},
}, function(self, inst, cmp, id)
    local s = "【※※渴血】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d%%移速;", self.db[5]*100)
    -- s = s..string.format("每隔%ds,对敌人造成攻击力%d%%的伤害,并回复攻击力%d%%+已损失生命%d%%的生命;每失去1%%生命值,获得1%%攻击力",
    -- self.db[1], self.db[2]*100, self.db[4]*100, self.db[3]*100)
    s = s..string.format("每失去1%%生命值,获得1%%攻击力;攻击额外造成基础攻击力%d%%的伤害,并回复基础攻击力%d%%+已损失生命%d%%的生命,有%ds的冷却",
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
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            local n = cmp[id.."_stack"]
            if n == 3 then
                cmp[id.."_stack"] = 0
                BuffManager:AddBuff(inst, id.."_buff")
                local base_dmg = inst.components.combat.defaultdamage
                local ex_dmg = self.db[1]+base_dmg*self.db[2]
                dmg = dmg+ex_dmg
            end
            return dmg
        end)
    end,
    attack = function(self, inst, cmp, id, data)
        local n = cmp[id.."_stack"]
        if n == nil then
            n = 0
        end
        cmp[id.."_stack"] = n+1
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        EntUtil:add_attack_speed_mod(inst, id.."_buff2", num*self.db[3])
    end,
    db = {30, .45, -.05},
}, function(self, inst, cmp, id)
    local s = "【※※海妖】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d%%攻速;", -self.db[3]*100)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("你每第3次攻击,额外造成基础攻击力%d%%+%d的伤害,并获得buff(%s)",
        self.db[2]*100, self.db[1], buff:desc())
    return s
end),
Equip("prowler_claw", {
    dmg=60,
    penetrate=.2,
    speed=.2,
    init = function(self, inst, cmp, id)
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            if inst.components.locomotor then
                local spd_mult = inst.components.locomotor:GetSpeedMultiplier()
                if spd_mult>=self.db[1] then
                    if not inst:HasTag(id.."_tag") then
                        local base_dmg = inst.components.combat.defaultdamage
                        local ex_dmg = self.db[2]+base_dmg*self.db[3]
                        dmg = dmg+ex_dmg
                        inst:AddTag(id.."_tag")
                        inst:DoTaskInTime(self.db[4], function()
                            inst:RemoveTag(id.."_tag")
                        end)
                        BuffManager:AddBuff(data.target, id.."_debuff")
                    end
                end
            end
            return dmg
        end)
        if cmp[id.."_task"] == nil then
            cmp[id.."_task"] = inst:DoPeriodicTask(self.db[5], function()
                EntUtil:add_speed_mod(inst, id.."_buff", self.db[6], self.db[7])
            end)
        end
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        inst.components.combat:AddPenetrateMod(id.."_buff2", num*self.db[8])
    end,
    db = {.7, 43, .45, 10, 8, .5, 1, .05},
}, function(self, inst, cmp, id)
    local s = "【※※暗爪】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d%%穿透;", self.db[8]*100)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("每隔%ds,你获得%d%%移速加成%ds;若你的移速加成不低于%d%%,你的攻击额外造成基础攻击力%d%%+%d的伤害,并令目标获得debuff(%s),有%ds的冷却;",
    self.db[5], self.db[6]*100, self.db[7], self.db[1]*100, self.db[3]*100, self.db[2], buff:desc(), self.db[4])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("stride_breaker", {
    dmg=50,
    attack_speed=-.2,
    hp=300,
    speed=.2,
    init = function(self, inst, cmp, id)
        if cmp[id.."_task"] == nil then
            cmp[id.."_task"] = inst:DoPeriodicTask(self.db[1]/10, function()
                local target = inst.components.combat.target
                if target and inst:IsNear(target, 8)
                and not inst:HasTag(id.."_tag")
                and EntUtil:is_alive(inst) then
                    local base_dmg = inst.components.combat.defaultdamage
                    local dmg = base_dmg*self.db[2]
                    EntUtil:get_attacked(target, inst, dmg, nil, nil, nil)
                    FxManager:MakeFx("statue_transition_2", target)
                    BuffManager:AddBuff(target, id.."_debuff")
                    inst:AddTag(id.."_tag")
                    inst:DoTaskInTime(self.db[1], function()
                        inst:RemoveTag(id.."_tag")
                    end)
                end
            end)
        end
    end,
    attack = function(self, inst, cmp, id, data)
        BuffManager:AddBuff(inst, id.."_buff")
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        EntUtil:add_speed_mod(inst, id.."_buff2", num*self.db[3])
    end,
    db = {10, 1.75, .05},
}, function(self, inst, cmp, id)
    local s = "【※※挺进】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d%%移速;", self.db[3]*100)
    local buff = BuffManager:GetDataById(id.."_debuff")
    local buff2 = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("对敌人造成基础攻击力%d%%的伤害,并令目标获得debuff(%s),有%ds的冷却;你进行攻击后,获得buff(%s)",
    self.db[2]*100, buff:desc(), self.db[1],  buff2:desc())
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("trinity_force", {
    dmg=25,
    attack_speed=-.35,
    hp=200,
    speed=.2,
    init = function(self, inst, cmp, id)
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            if not inst:HasTag(id.."_tag")
            and data.target then
                inst:AddTag(id.."_tag")
                local base_dmg = inst.components.combat.defaultdamage
                local ex_dmg = base_dmg*self.db[1]
                dmg = dmg+ex_dmg
                inst:DoTaskInTime(self.db[2], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
            return dmg
        end)
    end,
    attack = function(self, inst, cmp, id, data)
        BuffManager:AddBuff(inst, id.."_buff")
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        EntUtil:add_attack_speed_mod(inst, id.."_buff2", num*self.db[3])
    end,
    db = {1, 5, -.05},
}, function(self, inst, cmp, id)
    local s = "【※※三相】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d%%攻速;", -self.db[3]*100)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("攻击额外造成基础攻击力%d%%的伤害,有%ds的冷却;攻击会获得buff(%s)",
    self.db[1]*100, self.db[2], buff:desc(inst, inst.components.wg_simple_buff, id.."_debuff"))
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
}

local large_equips_def = {
Equip("eclipse", {
    dmg=55,
    penetrate=.2,
    life_steal=.1,
    init = function(self, inst, cmp, id)
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            local n = cmp[id.."_stack"] or 0
            if n >= 2 then
                if not inst:HasTag(id.."_tag") then
                    inst:AddTag(id.."_tag")
                    cmp[id.."_stack"] = 0
                    local max_hp = inst.components.health.wg_max_health
                    local ex_dmg = max_hp*self.db[1]
                    -- local base_dmg = inst.components.combat.defaultdamage
                    -- local dt = self.db[2]+base_dmg*self.db[3]
                    -- inst.components.health:DoDelta(dt)
                    BuffManager:AddBuff(inst, id.."_buff")
                    dmg = dmg+ex_dmg
                    -- 强化防御
                    BuffManager:AddBuff(inst, "defense")
                    inst:DoTaskInTime(self.db[4], function()
                        inst:RemoveTag(id.."_tag")
                    end)
                end
            end
            return dmg
        end)
    end,
    attack = function(self, inst, cmp, id, data)
        local n = cmp[id.."_stack"]
        if n == nil then
            n = 0
        end
        cmp[id.."_stack"] = n+1
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        inst.components.combat:AddPenetrateMod(id.."_buff2", num*self.db[4])
    end,
    db = {.1, 180, .4, 5, .05},
}, function(self, inst, cmp, id)
    local s = "【※※星蚀】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d%%移速;", self.db[4]*100)
    local buff = BuffManager:GetDataById(id.."_buff")
    local buff2 = BuffManager:GetDataById("defense")
    -- s = s..string.format("你每两次攻击,会额外造成最大生命%d%%的伤害,并让你回复攻击力%d%%+%d的生命,并获得buff(%s)",
    -- self.db[1]*100, self.db[3]*100, self.db[2], buff:desc())
    s = s..string.format("你每两次攻击,会额外造成基础最大生命%d%%的伤害,并获得buff(%s)(%s),有%ds的冷却",
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
    hit = function(self, inst, cmp, id, data)
        if EntUtil:is_alive(inst) 
        and not inst:HasTag(id.."_tag") then
            if inst.components.health:GetPercent() <= self.db[1] then
                local min, max = self.db[2], self.db[3]
                local dt = min+(max-min)/90*cmp.level
                inst.components.health:DoDelta(dt)
                inst:AddTag(id.."_tag")
                BuffManager:AddBuff(inst, id.."_buff")
                inst:DoTaskInTime(self.db[4], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
        end
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        inst.components.health:WgAddMaxHealthModifier(id.."_buff2", num*self.db[5], true)
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            dmg = dmg+num*self.db[6]
            return dmg
        end)
    end,
    db = {.3, 250, 700, 40, 50, 5},
}, function(self, inst, cmp, id)
    local s = "【※※盾弓】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d生命和%d攻击力;", self.db[5], self.db[6])
    local min, max = self.db[2], self.db[3]
    local dt = min+(max-min)/90*cmp.level
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("受到攻击后,若你的生命值低于%d%%,回复%d的生命值(基于等级提升),并获得buff(%s),有%ds冷却",
    self.db[1]*100, dt, buff:desc(), self.db[4])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("frostfire_gauntlet", {
    hp=350,
    absorb=.25,
    evade=.25,
    speed=.2,
    init = function(self, inst, cmp, id, data)
        inst:AddTag("tp_not_freezable")
    end,
    attack = function(self, inst, cmp, id, data)
        data.attacker = inst
        local attacker = data.target
        if EntUtil:can_thorns(data) then
            local max_hp = inst.components.health:GetMaxHealth()
            local ex_dmg = math.min(self.db[6], max_hp*self.db[3])
            local min, max = self.db[1], self.db[2]
            local base = min+(max-min)/90*cmp.level
            local dmg = ex_dmg+base
            attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
        end
        if not inst:HasTag(id.."_tag") then
            BuffManager:AddBuff(attacker, id.."_debuff", nil, {target=inst})
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
            attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
        end
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        inst.components.health:WgAddMaxHealthModifier(id.."_buff2", num*self.db[5], true)
    end,
    db = {5, 10, .001, 6, 100, 10},
}, function(self, inst, cmp, id)
    local s = "【※※霜火护手】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d生命;", self.db[5])
    local min, max = self.db[1], self.db[2]
    local base = min+(max-min)/90*cmp.level
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("不会被冰冻;攻击敌人和受到攻击时,对方会受到你最大生命%.2f%%(最高%d点)+%d(基于等级提升)的火焰伤害;攻击会对目标施加1层冰冻效果;你的攻击会令目标获得debuff(%s),有%ds冷却",
    self.db[3]*100, self.db[6], base, buff:desc(), self.db[4])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("turbo_chemtank", {
    hp=350,
    absorb=.25,
    evade=.25,
    speed=.2,
    init = function(self, inst, cmp, id)
        inst:AddTag("tp_not_poison_damage")
        inst:ListenForEvent("newcombattarget", function(inst, data)
            if not inst:HasTag(id.."_tag")
            and data.target 
            and data.target ~= data.oldtarget then
                inst:AddTag(id.."_tag")
                EntUtil:add_speed_mod(inst, id, self.db[4], self.db[5])
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
        if EntUtil:can_thorns(data) then
            -- local max_hp = inst.components.health.wg_max_health
            -- local ex_dmg = max_hp*self.db[3]
            -- local min, max = self.db[1], self.db[2]
            -- local base = min+(max-min)/90*cmp.level
            -- local dmg = ex_dmg+base
            -- attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
            BuffManager:AddBuff(attacker, "poison")
        end
    end,
    hit = function(self, inst, cmp, id, data)
        local attacker = data.attacker
        if EntUtil:can_thorns(data) then
            -- local max_hp = inst.components.health.wg_max_health
            -- local ex_dmg = math.max(self.db[8], max_hp*self.db[3])
            -- local min, max = self.db[1], self.db[2]
            -- local base = min+(max-min)/90*cmp.level
            -- local dmg = ex_dmg+base
            -- attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
            BuffManager:AddBuff(attacker, "poison")
        end
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        inst.components.health:WgAddMaxHealthModifier(id.."_buff2", num*self.db[7], true)
    end,
    db = {5, 10, 0.01, .5, 5, 15, 100, 10},
}, function(self, inst, cmp, id)
    local s = "【※※炼金罐】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d生命;", self.db[7])
    local min, max = self.db[1], self.db[2]
    local base = min+(max-min)/90*cmp.level
    local buff = BuffManager:GetDataById(id.."_debuff")
    local buff2 = BuffManager:GetDataById("poison")
    s = s..string.format("免疫毒伤;攻击敌人和受到攻击时,令对方获得debuff(%s);发现攻击目标后,提升移速%d%%,持续%ds,并令目标获得debuff(%s),有%ds冷却",
    buff2:desc(), self.db[4]*100, self.db[5], buff:desc(), self.db[6])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("locket_IronSolari", {
    hp=200,
    absorb=.3,
    evade=.3,
    speed=.2,
    hit = function(self, inst, cmp, id, data)
        if not inst:HasTag(id.."_tag") then
            inst:AddTag(id.."_tag")
            local x, y, z = inst:GetPosition():Get()
            local ents = TheSim:FindEntities(x, y, z, 6, nil, EntUtil.not_enemy_tags)
            for k, v in pairs(ents) do
                if EntUtil:check_congeneric(inst, v) then
                    BuffManager:AddBuff(v, id.."_buff")
                end
            end
            inst:DoTaskInTime(self.db[3], function()
                inst:RemoveTag(id.."_tag")
            end)
        end
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        inst.components.combat:AddDefenseMod(id.."_buff2", self.db[1]*num)
        inst.components.combat:AddEvadeRateMod(id.."_buff2", self.db[2]*num)
    end,
    db = {.02, .02, 10},
}, function(self, inst, cmp, id)
    local s = "【※※钢铁烈阳之匣】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d防御和%d闪避;", self.db[1]*100, self.db[2]*100)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("受到攻击令周围的同类获得buff(%s),有%ds冷却",
    buff:desc(), self.db[3])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("SunFire_aegis", {
    hp=350,
    absorb=.3,
    evade=.3,
    speed=.15,
    init = function(self, inst, cmp, id, data)
        inst:AddTag("tp_not_fire_damage")
    end,
    attack = function(self, inst, cmp, id, data)
        data.attacker = inst
        local attacker = data.target
        if EntUtil:can_thorns(data) then
            local max_hp = inst.components.health:GetMaxHealth()
            local ex_dmg = math.min(self.db[4], max_hp*self.db[3])
            local dmg = ex_dmg+self.db[2]
            attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
            BuffManager:AddBuff(attacker, id.."_debuff")
        end
    end,
    hit = function(self, inst, cmp, id, data)
        local attacker = data.attacker
        if EntUtil:can_thorns(data) then
            local max_hp = inst.components.health:GetMaxHealth()
            local ex_dmg = math.min(self.db[4], max_hp*self.db[3])
            local dmg = ex_dmg+self.db[2]
            attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
            BuffManager:AddBuff(attacker, id.."_debuff")
        end
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        inst.components.health:WgAddMaxHealthModifier(id.."_buff2", num*self.db[1], true)
    end,
    db = {100, 6, .001, 10},
}, function(self, inst, cmp, id)
    local s = "【※※日炎圣盾】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d生命;", self.db[1])
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("免疫火伤;攻击敌人和受到攻击时,对方会受到你基础最大生命%d%%(最高10点)+%d的火焰伤害,并令其获得debuff(%s)", 
    self.db[3]*100, self.db[4], self.db[2], buff:desc())
    return s
end),
Equip("heart_steel", {
    recover=1,
    hp=800,
    speed=.2,
    init = function(self, inst, cmp, id)
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            if not inst:HasTag(id.."_tag") then
                local max_hp = inst.components.health:GetMaxHealth()
                local ex_dmg = max_hp*self.db[2]
                dmg = dmg+ex_dmg
                inst:AddTag(id.."_tag")
                BuffManager:AddBuff(inst, id.."_buff")
                inst:DoTaskInTime(self.db[3], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
            return dmg
        end)
    end,
    post = function(self, inst, cmp, id)
        local num = #cmp.equips
        inst.components.health:WgAddMaxHealthMultiplier(id.."_buff2", num*self.db[1], true)
    end,
    db = {.05, .002, 15},
}, function(self, inst, cmp, id)
    local s = "【※※心之钢】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("你每有1件装备,获得%d%%最大生命;", self.db[1]*100)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("攻击目标会额外造成最大生命%.2f%%的伤害,并令你获得buff(%s),有%ds冷却",
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
        inst:ListenForEvent("healthdelta", function(inst, data)
            if data and data.cause == "life_steal" then
                if inst.components.health:GetPercent() >= 1 then
                    inst.components.health:WgAddMaxHealthMultiplier(id, self.db[1])
                end
            end
        end)
    end,
    db = {.2},
}, function(self, inst, cmp, id)
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
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击会令目标获得debuff(%s)", 
        buff:desc(inst, inst.components.wg_simple_buff, id.."_debuff"))
    return s
end),
Equip("ruined_king_blade",
{
    dmg=20,
    attack_speed=-0.20,
    life_steal = .5,
    init = function(self, inst, cmp, id)
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            local target = data.target
            if not target:HasTag("epic") then
                local max_hp = target.components.health:GetMaxHealth()
                local ex_dmg = max_hp*self.db[1]
                dmg = math.min(self.db[2], dmg+ex_dmg)
            end
            return dmg
        end)
    end,
    db = {.03, 100},
}, function(self, inst, cmp, id)
    local s = "【※破败】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击额外造成目标最大生命值%d%%的伤害(最多%d,对史诗生物无效)",
        self.db[1]*100, self.db[2])
    return s
end),
Equip("phantom_dancer",
{
    dmg=20,
    attack_speed=-0.25,
    speed=0.10,
    crit=0.20,
    attack = function(self, inst, cmp, id, data)
        BuffManager:AddBuff(inst, id.."_buff")
    end,
}, function(self, inst, cmp, id)
    local s = "【※幻影之舞】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("攻击目标后会获得buff(%s)", buff:desc())
    return s
end),
Equip("mortal_reminder",
{
    dmg=10,
    attack_speed=-0.25,
    speed=0.10,
    crit=0.20,
    penetrate = .3,
    attack = function(self, inst, cmp, id, data)
        local target = data.target
        if not target:HasTag("epic") then
            BuffManager:AddBuff(target, "recover_debuff")
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【※凡性提醒】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById("recover_debuff")
    s = s..string.format("攻击目标后，令其获得debuff(%s)(对史诗生物无效)", buff:desc())
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
    local buff = BuffManager:GetDataById("poison")
    s = s..string.format("攻击目标会令目标中毒,若目标已中毒,令其获得debuff(%s)", buff:desc())
    return s
end),
Equip("rapid_direcannon",
{
    attack_speed=-0.35,
    speed=0.10,
    crit=0.20,
    init = function(self, inst, cmp, id)
        inst.components.combat.tp_range_buff = self.db[1]
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
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            if not inst:HasTag(id.."_tag") then
                local base_dmg = inst.components.combat.defaultdamage
                local ex_dmg = base_dmg*self.db[1]
                dmg = dmg+ex_dmg
                inst:AddTag(id.."_tag")
                BuffManager:AddBuff(data.target, id.."_debuff")
                inst:DoTaskInTime(self.db[2], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
            return dmg
        end)
    end,
    db = {1, 15}
}, function(self, inst, cmp, id)
    local s = "【※岚切】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击目标会额外造成基础攻击力%d%%的伤害,并令目标获得debuff(%s),有%ds冷却",
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
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            local ex_dmg = self.db[1]
            local rate = inst.components.combat.tp_crit or 0
            ex_dmg = ex_dmg + ex_dmg*rate*self.db[2]
            dmg = dmg+ex_dmg
            return dmg
        end)
    end,
    db = {10, 2}
}, function(self, inst, cmp, id)
    local s = "【※鬼索】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击额外造成%d的伤害,你每有1%%的暴击率,额外伤害便提高%d%%", 
        self.db[1], self.db[2])
    return s
end),
Equip("lord_dominik_regard",
{
    dmg=15,
    crit=0.20,
    penetrate=.5,
    attack = function(self, inst, cmp, id, data)
        if data.target then
            BuffManager:AddBuff(data.target, "armor_broken")
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【※多米尼克】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById("armor_broken")
    s = s..string.format("攻击会令目标获得debuff(%s)", buff:desc())
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
    s = s..string.format("如果攻击目标拥有理智,攻击会降低目标最大理智%d%%+%d点理智,并回复自身等量的生命",
        self.db[2], self.db[1])
    return s
end),
Equip("sanguine_blade",
{
    dmg=25,
    penetrate = .1,
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
    penetrate = .2,
    init = function(self, inst, cmp, id)
        inst:ListenForEvent("newcombattarget", function(inst, data)
            if not inst:HasTag(id.."_tag") 
            and data.target
            and data.target ~= data.oldtarget then
                inst:AddTag(id.."_tag")
                EntUtil:add_speed_mod(inst, id.."_buff", self.db[1], self.db[2])
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
    penetrate = .2,
    attack = function(self, inst, cmp, id, data)
        if data and data.target and not data.target:HasTag("epic")
        and not data.target:HasTag("player") then
            local p = data.target.components.health:GetPercent()
            if p<=self.db[1] then
                data.target.components.health:Kill()
            end
        end
    end,
    db = {.05},
}, function(self, inst, cmp, id)
    local s = "【※收集者】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("若目标生命值比例低于%d%%,则直接杀死目标(对史诗生物和玩家无效)",
        self.db[1]*100)
    return s
end),
Equip("wit_end",
{
    dmg=30,
    attack_speed=-0.40,
    evade=0.25,
    attack = function(self, inst, cmp, id, data)
        BuffManager:AddBuff(inst, id.."_buff")
    end,
}, function(self, inst, cmp, id)
    local s = "【※智慧末刃】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("攻击会获得buff(%s)", 
        buff:desc(inst, inst.components.wg_simple_buff, id.."_buff"))
    return s
end),
Equip("death_dance",
{
    absorb=0.20,
    dmg=25,
    speed=0.15,
    init = function(self, inst, cmp, id)
        inst:ListenForEvent("killed", function(inst, data)
            BuffManager:AddBuff(inst, id.."_buff")
        end)
    end,
}, function(self, inst, cmp, id)
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
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            local max_hp = inst.components.health:GetMaxHealth()
            dmg = dmg+max_hp*self.db[1]
            return dmg
        end)
    end,
    db = {.003},
}, function(self, inst, cmp, id)
    local s = "【※巨九】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击会额外造成自身最大生命值%.2f%%的伤害",
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
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("造成暴击后获得buff(%s)", buff:desc())
    return s
end),
Equip("serylda_grudge",
{
    dmg=25,
    penetrate = .5,
    attack = function(self, inst, cmp, id, data)
        if data.target then
            BuffManager:AddBuff(data.target, "armor_broken")
            BuffManager:AddBuff(data.target, id.."_debuff")
        end
    end,
}, function(self, inst, cmp, id)
    local s = "【※塞瑞尔达】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById("armor_broken")
    local buff2 = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击会令目标获得debuff(%s)(%s)", 
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
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击会令目标获得debuff(%s)(对史诗生物无效)", 
        buff:desc())
    return s
end),
}

local equips_def = {
Equip("malmortius_maw",
{
    dmg=25,
    speed=0.15,
    evade=0.25,
    init = function(self, inst, cmp, id)
        if EntUtil:is_alive(inst) 
        and not inst:HasTag(id.."_tag") then
            if inst.components.health:GetPercent() <= self.db[1] then
                -- local max_hp = inst.components.health:GetMaxHealth()
                local base_dmg = inst.components.combat.defaultdamage
                local mult = inst.components.combat:GetDamageModifier()
                local dt = self.db[2]+base_dmg*mult*self.db[3]
                inst.components.health:DoDelta(dt)
                inst:AddTag(id.."_tag")
                BuffManager:AddBuff(inst, id.."_buff")
                inst:DoTaskInTime(self.db[4], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
        end
    end,
    db = {.3, 200, 2.25, 30}
}, function(self, inst, cmp, id)
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
    absorb = .4,
    speed=0.10,
    hit = function(self, inst, cmp, id, data)
        if data and data.attacker then
            BuffManager:AddBuff(data.attacker, id.."_debuff")
        end
    end,
}, function(self, inst, cmp, id)
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
        if cmp[id.."_task"] == nil then
            cmp[id.."_task"] = inst:DoPeriodicTask(self.db[1], function()
                local max_hp = inst.components.health:GetMaxHealth()
                if EntUtil:is_alive(inst) then
                    inst.components.health:DoDelta(max_hp*self.db[2])
                end
            end)
        end
    end,
    db = {4, .03}
}, function(self, inst, cmp, id)
    local s = "【※狂徒】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("每%ds回复%d%%生命上限的生命值", self.db[1], self.db[2])
    return s
end),
Equip("ask_flag",
{
    absorb=0.30,
    speed=0.10,
    evade=0.15,
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
    local s = "【※号令之旗】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("受到攻击时令周围的同类获得buff(%s)", buff:desc())
    return s
end),
Equip("thornmail",
{
    hp=175,
    absorb=0.30,
    hit = function(self, inst, cmp, id, data)
        if EntUtil:can_thorns(data) then
            -- local dmg = data.damage*self.db[1]
            local defense = inst.components.combat:GetDefense()
            local dmg = self.db[1]+defense*self.db[2]
            data.attacker.components.health:DoDelta(-dmg)
            -- EntUtil:get_attacked(data.attacker, inst, dmg, nil, "thorns", nil)
            BuffManager:AddBuff(data.attacker, "not_reflection")
            if not data.attacker:HasTag("epic") then
                BuffManager:AddBuff(data.attacker, "recover_debuff")
            end
            FxManager:MakeFx("thorns", inst)
        end
    end,
    db = {10, 12},
}, function(self, inst, cmp, id)
    local s = "【※反甲】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById("recover_debuff")
    s = s..string.format("受到攻击令攻击者失去%dx防御系数+%d的生命,令其获得debuff(%s)(不对史诗生物生物)", 
    self.db[2], self.db[1], buff:desc())
    return s
end),
Equip("redemption",
{
    hp=100,
    speed=0.15,
    recover=.5,
    hit = function(self, inst, cmp, id, data)
        if not inst:HasTag(id.."_tag") then
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
                    end
                end
            end
        end
    end,
    db = {.5, 5, .1, 15},
}, function(self, inst, cmp, id)
    local s = "【※救赎】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("受到攻击时会令周围的同类回复%d%%最大生命+%d点的生命值(有%ds的冷却)",
    self.db[3]*100, self.db[4], self.db[2])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("zhonya_hourglass",
{
    absorb=0.20,
    speed=0.10,
    hit = function(self, inst, cmp, id, data)
        if inst.components.health:GetPercent() <= self.db[1] then
            if not inst:HasTag(id.."_tag") then
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[2], function()
                    inst:RemoveTag(id.."_tag")
                end)
                BuffManager:AddBuff(inst, "invincible")
            end
        end
    end,
    db = {.5, 15},
}, function(self, inst, cmp, id)
    local s = "【※中娅】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById("invincible")
    s = s..string.format("生命值小于%d%%时,受到攻击会获得buff(%s),有%ds冷却",
    self.db[1]*100, buff:desc(), self.db[2])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("sun_fire_cape",
{
    hp=210,
    absorb=0.3,
    attack = function(self, inst, cmp, id, data)
        data.attacker = inst
        local attacker = data.target
        if EntUtil:can_thorns(data) then
            local max_hp = inst.components.health.wg_max_health
            local ex_dmg = math.min(self.db[3], max_hp*self.db[2])
            local dmg = ex_dmg+self.db[1]
            attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
        end
    end,
    hit = function(self, inst, cmp, id, data)
        local attacker = data.attacker
        if EntUtil:can_thorns(data) then
            local max_hp = inst.components.health.wg_max_health
            local ex_dmg = math.min(self.db[3], max_hp*self.db[2])
            local dmg = ex_dmg+self.db[1]
            attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
        end
    end,
    db = {6, .01, 10}
}, function(self, inst, cmp, id)
    local s = "【※日炎】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击敌人和受到攻击时,对方会受到你基础最大生命%d%%(最高10点)+%d的火焰伤害", 
    self.db[2]*100, self.db[3], self.db[1])
    return s
end),
Equip("dead_plate",
{
    hp=200,
    absorb=0.20,
    speed=0.10,
    init = function(self, inst, cmp, id)
        EntUtil:add_speed_mod(inst, id.."_buff", self.db[1])
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            if not inst:HasTag(id.."_tag") then
                local base_dmg = inst.components.combat.defaultdamage
                local ex_dmg = base_dmg*self.db[2]+self.db[3]
                dmg = dmg+ex_dmg
                inst:AddTag(id.."_tag")
                EntUtil:rm_speed_mod(inst, id.."_buff")
                BuffManager:AddBuff(data.target, id.."_debuff")
                inst:DoTaskInTime(self.db[4], function()
                    inst:RemoveTag(id.."_tag")
                    EntUtil:add_speed_mod(inst, id.."_buff", self.db[1])
                end)
            end
            return dmg
        end)
    end,
    db = {.3, .1, 10, 5}
}, function(self, inst, cmp, id)
    local s = "【※板甲】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("获得增益:提升%d%%移速,下次攻击额外造成基础攻击力%d%%+%d的伤害,并令目标获得debuff(%s),有%ds的冷却",
    self.db[1]*100, self.db[2]*100, self.db[3], buff:desc(), self.db[4])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("iceborn_gauntlet",
{
    hp=175,
    absorb=0.15,
    speed=0.20,
    evade=0.15,
    init = function(self, inst, cmp, id)
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            if not inst:HasTag(id.."_tag") then
                inst:AddTag(id.."_tag")
                local base_dmg = inst.components.combat.defaultdamage
                local ex_dmg = base_dmg*self.db[1]
                dmg = dmg+ex_dmg
                BuffManager:AddBuff(data.target, id.."_debuff", nil, {target=inst})
                inst:DoTaskInTime(self.db[2], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
            return dmg
        end)
    end,
    db = {.5, 6},
}, function(self, inst, cmp, id)
    local s = "【※冰拳】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击额外造成基础攻击力%d%%的伤害,令目标获得debuff(%s),有%ds冷却",
    self.db[1]*100,  buff:desc(), self.db[2])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("iron_solari",
{
    hp=100,
    absorb=0.15,
    speed=0.20,
    evade=0.15,
    hit = function(self, inst, cmp, id, data)
        if not inst:HasTag(id.."_tag") then
            inst:AddTag(id.."_tag")
            local x, y, z = inst:GetPosition():Get()
            local ents = TheSim:FindEntities(x, y, z, 6, nil, EntUtil.not_enemy_tags)
            for k, v in pairs(ents) do
                if EntUtil:check_congeneric(inst, v) then
                    BuffManager:AddBuff(v, id.."_buff")
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
    evade=0.20,
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
    evade=0.30,
    hit = function(self, inst, cmp, id, data)
        BuffManager:AddBuff(inst, id.."_buff")
    end,
}, function(self, inst, cmp, id)
    local s = "【※自然之力】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("受到攻击后,获得buff(%s)", 
        buff:desc(inst, inst.components.wg_simple_buff, id.."_buff"))
    return s
end),
Equip("guardian_angel",
{
    absorb=0.20,
    dmg=20,
    init = function(self, inst, cmp, id)
        inst:AddTag(id.."_tag")
        if inst.components.health then
            inst.components.health:SetMinHealth(1)
            inst:ListenForEvent("minhealth", function(inst, data)
                if inst:HasTag(id.."_tag") and data 
                and data.cause ~= "file_load" then
                    FxManager:MakeFx("wathgrithr_spirit", inst)
                    inst.components.health:SetPercent(self.db[1])
                    inst.components.health:SetMinHealth(0)
                    inst:RemoveTag(id.."_tag")
                    BuffManager:AddBuff(inst, "invincible")
                    inst:DoTaskInTime(self.db[2], function()
                        inst.components.health:SetMinHealth(1)
                        inst:AddTag(id.."_tag")
                    end)
                end
            end)
        end
    end,
    db = {.3, 60},
}, function(self, inst, cmp, id)
    local s = "【※守护天使】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById("invincible")
    s = s..string.format("受到致命伤后,恢复%d%%的生命,并获得buff(%s),有%ds的冷却",
    self.db[1]*100, buff:desc(), self.db[2])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("frozen_heart",
{
    absorb=0.40,
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
    db = {5},
}, function(self, inst, cmp, id)
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
    absorb=0.15,
    recover=1,
    init = function(self, inst, cmp, id)
        inst:ListenForEvent("newcombattarget", function(inst, data)
            if not inst:HasTag(id.."_tag")
            and data.target 
            and data.target ~= data.oldtarget then
                inst:AddTag(id.."_tag")
                EntUtil:add_speed_mod(inst, id, self.db[1], self.db[2])
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
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("发现攻击目标后,提升移速%d%%,持续%ds,并令目标获得debuff(%s),有%ds冷却",
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
        if EntUtil:is_alive(inst) 
        and not inst:HasTag(id.."_tag") then
            if inst.components.health:GetPercent() <= self.db[1] then
                local max_hp = inst.components.health:GetMaxHealth()
                -- local base_dmg = inst.components.combat.defaultdamage
                -- local dt = self.db[2]+max_hp*self.db[3]+base_dmg*self.db[4]
                local dt = self.db[2]+max_hp*self.db[3]
                inst.components.health:DoDelta(dt)
                inst:AddTag(id.."_tag")
                -- BuffManager:AddBuff(inst, id.."_buff")
                inst:DoTaskInTime(self.db[4], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
        end
    end,
    db = {.3, 100, .32, 35}
}, function(self, inst, cmp, id)
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
    evade=0.30,
    init = function(self, inst, cmp, id)
        inst.components.health:WgAddMaxHealthMultiplier(id.."_buff", 1, true)
    end,
}, function(self, inst, cmp, id)
    local s = "【※石像鬼】:"
    s = s..get_attr_desc(self, inst)
    s = s.."增加100%最大生命值"
    return s
end),
}

local small_equips_atk = {
Equip("kircheis_shard",
{
    attack_speed=-0.15,
    init = function(self, inst, cmp, id)
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            if not inst:HasTag(id.."_tag") then
                local ex_dmg = self.db[1]
                dmg = dmg+ex_dmg
                inst:AddTag(id.."_tag")
                inst:DoTaskInTime(self.db[2], function()
                    inst:RemoveTag(id.."_tag")
                end)
            end
            return dmg
        end)
    end,
    db = {10, 10},
}, function(self, inst, cmp, id)
    local s = "【基舍碎片】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击会额外造成%d点伤害,有%ds冷却",
    self.db[1], self.db[2])
    local cd = inst:HasTag(id.."_tag") and "(冷却中)" or "(已准备)"
    s = s..cd
    return s
end),
Equip("rageknife",
{
    attack_speed=-0.25,
    init = function(self, inst, cmp, id)
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            local ex_dmg = self.db[1]
            dmg = dmg+ex_dmg
            return dmg
        end)
    end,
    attack = function(self, inst, cmp, id, data)
        BuffManager:AddBuff(inst, id.."_buff")
    end,
    db = {6},
}, function(self, inst, cmp, id)
    local s = "【狂怒小刀】:"
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("攻击额外造成%d点伤害，并获得buff(%s)",
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
    local buff = BuffManager:GetDataById(id.."_debuff")
    s = s..string.format("攻击会令目标获得debuff(%s)",
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
    attack_speed=-0.25,
    init = function(self, inst, cmp, id)
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            local ex_dmg = self.db[1]
            dmg = dmg+ex_dmg
            return dmg
        end)
    end,
    db = {5},
}, function(self, inst, cmp, id)
    local s = "【反曲弓】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击造成额外%d点伤害", self.db[1])
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
    s = s..get_attr_desc(self, inst)
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("攻击获得buff(%s)", buff:desc())
    return s
end),
Equip("serrated_dirk",
{
    dmg=15,
    penetrate = .1,
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
    init = function(self, inst, cmp, id)
        if EntUtil:is_alive(inst) 
        and not inst:HasTag(id.."_tag") then
            if inst.components.health:GetPercent() <= self.db[1] then
                local min = self.db[2]
                local max = self.db[3]
                local dt = min+(max-min)/90*cmp.level
                inst.components.health:DoDelta(dt)
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
        inst.components.combat:WgAddCalcDamageFn(function(data)
            local dmg = data.damage
            if data.target and not data.target:HasTag("epic")
            and not data.target:HasTag("largecreature") then
                local ex_dmg = self.db[1]
                dmg = dmg+ex_dmg
            end
            return dmg
        end)
    end,
    db = {15},
}, function(self, inst, cmp, id)
    local s = "【箭袋】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("对boss,大型生物以外的目标额外造成%d点伤害",
    self.db[1])
    return s
end),
Equip("last_whisper",
{
    dmg=20,
    penetrate = .2,
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
    absorb=0.20,
    hit = function(self, inst, cmp, id, data)
        if data and data.attacker then
            BuffManager:AddBuff(data.attacker, id.."_debuff")
        end
    end,
}, function(self, inst, cmp, id)
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
        if EntUtil:can_thorns(data) then
            local max_hp = inst.components.health.wg_max_health
            local ex_dmg = math.min(self.db[3], max_hp*self.db[2])
            local dmg = ex_dmg+self.db[1]
            attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
        end
    end,
    hit = function(self, inst, cmp, id, data)
        local attacker = data.attacker
        if EntUtil:can_thorns(data) then
            local max_hp = inst.components.health.wg_max_health
            local ex_dmg = math.min(self.db[3], max_hp*self.db[2])
            local dmg = ex_dmg+self.db[1]
            attacker.components.health:DoFireDamage(dmg, nil, true)
            BuffManager:AddBuff(attacker, "not_reflection")
        end
    end,
    db = {2, .01, 6}
}, function(self, inst, cmp, id)
    local s = "【熔渣】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("攻击敌人和受到攻击时,对方会受到你基础最大生命%d%%+%d的火焰伤害", 
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
    absorb=0.15,
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
    local buff = BuffManager:GetDataById(id.."_buff")
    s = s..string.format("受到攻击时令周围的同类获得buff(%s)", buff:desc())
    return s
end),
Equip("glacial_buckler",
{
    hp=75,
    absorb=0.10,
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
    absorb=0.20,
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
    absorb=0.20,
    hit = function(self, inst, cmp, id, data)
        if EntUtil:can_thorns(data) then
            local dmg = self.db[1]
            data.attacker.components.health:DoDelta(-dmg)
            -- EntUtil:get_attacked(data.attacker, inst, dmg, nil, "thorns", nil)
            BuffManager:AddBuff(data.attacker, "not_reflection")
            FxManager:MakeFx("thorns", inst)
        end
    end,
    db = {5},
}, function(self, inst, cmp, id)
    local s = "【小反甲】:"
    s = s..get_attr_desc(self, inst)
    s = s..string.format("受到攻击令攻击者失去%d点生命",
        self.db[1])
    return s
end),
}

local Info = require "scripts.extension.datas.info"
local DataManager = require "scripts/extension/lib/data_manager2"
-- CreatureEquipManager:SetName("CreatureEquipManager")
local CreatureEquipManager = DataManager
CreatureEquipManager:SetUniqueIdMode()
CreatureEquipManager:AddDatas(large_equips_atk, "large_equips_atk")
CreatureEquipManager:AddDatas(large_equips_def, "large_equips_def")
CreatureEquipManager:AddDatas(equips_atk, "equips_atk")
CreatureEquipManager:AddDatas(equips_def, "equips_def")
CreatureEquipManager:AddDatas(small_equips_atk, "small_equips_atk")
CreatureEquipManager:AddDatas(small_equips_def, "small_equips_def")

local function get_equip_ids(inst, day)
    local s, m, L = Info.MonsterStrengthenFns.GetEquipNum(inst, day)
    -- 平均分配攻击装和防御装
    local s1, s2, m1, m2, L1, L2 = 0, 0, 0, 0, 0, 0
    local flag = math.random()<.5 and 1 or -1
    for i = 1, s do
        if flag == 1 then
            s1 = s1+1
        else
            s2 = s2+1
        end
        flag = -flag
    end
    for i = 1, m do
        if flag == 1 then
            m1 = m1+1
        else
            m2 = m2+1
        end
        flag = -flag
    end
    for i = 1, L do
        if flag == 1 then
            L1 = L1+1
        else
            L2 = L2+1
        end
        flag = -flag
    end
    local equip_ids = {}
    local ids = CreatureEquipManager:GetRandomIds(s1, {"small_equips_atk"})
    for k, v in pairs(ids) do
        table.insert(equip_ids, v)
    end
    local ids = CreatureEquipManager:GetRandomIds(s2, {"small_equips_def"})
    for k, v in pairs(ids) do
        table.insert(equip_ids, v)
    end
    local ids = CreatureEquipManager:GetRandomIds(m1, {"equips_atk"})
    for k, v in pairs(ids) do
        table.insert(equip_ids, v)
    end
    local ids = CreatureEquipManager:GetRandomIds(m2, {"equips_def"})
    for k, v in pairs(ids) do
        table.insert(equip_ids, v)
    end
    local ids = CreatureEquipManager:GetRandomIds(L1, {"large_equips_atk"})
    for k, v in pairs(ids) do
        table.insert(equip_ids, v)
    end
    local ids = CreatureEquipManager:GetRandomIds(L2, {"large_equips_def"})
    for k, v in pairs(ids) do
        table.insert(equip_ids, v)
    end
    return equip_ids
end

local day = 1
local is_boss = false
local function make_monster()
    local inst = {HasTag = function() return is_boss end}
    inst.dmg = is_boss and 75 or 20
    inst.dmg_mod = 0
    inst.hp = is_boss and 3000 or 100
    inst.rcr = 0
    inst.spd = 0
    inst.atk_spd = 0
    inst.def = 0
    inst.crit = 0
    inst.evade = 0
    inst.blood = 0
    inst.pen = 0
    inst.hr = 0
    local ids = get_equip_ids(inst, day)
    for k, v in pairs(ids) do   
        local equip = CreatureEquipManager:GetDataById(v)
        local equip_data = equip.data
        -- print(v)
        -- for k2, v2 in pairs(equip_data) do
        --     print(k2, v2)
        -- end
        if equip_data.hp then
            if is_boss then
                inst.hp = inst.hp + equip_data.hp*Info.MonsterStrengthen.EpicEquipHpRate
            else
                inst.hp = inst.hp + equip_data.hp
            end
        end
        if equip_data.recover then
            inst.rcr = inst.rcr+equip_data.recover
        end
        if equip_data.speed then
            inst.spd = inst.spd+equip_data.speed
        end
        if equip_data.dmg then
            if is_boss then
                inst.dmg_mod = inst.dmg_mod+equip_data.dmg*0.01
            else
                inst.dmg = inst.dmg+equip_data.dmg
            end
        end
        if equip_data.dmg_mod then
            inst.dmg_mod = inst.dmg_mod*equip_data.dmg
        end
        if equip_data.attack_speed then
            inst.atk_spd = inst.atk_spd+equip_data.attack_speed
        end
        if equip_data.absorb then
            inst.def = inst.def+equip_data.absorb
        end
        if equip_data.crit then
            inst.crit = inst.crit+equip_data.crit
        end
        if equip_data.evade then
            inst.evade = inst.evade+equip_data.evade
        end
        if equip_data.life_steal then
            inst.blood = inst.blood+equip_data.life_steal
        end
        if equip_data.penetrate then
            inst.pen = inst.pen+equip_data.penetrate
        end
        if equip_data.hit_rate then
            inst.hr = inst.hr+equip_data.hit_rate
        end
    end

    local attr_data
    if attr_data == nil then
        attr_data = {
            hp_mod = Info.MonsterStrengthenFns.HpFunc(inst, day),
            absorb = Info.MonsterStrengthenFns.AbsorbFunc(inst, day),
            ex_dmg = Info.MonsterStrengthenFns.DamageFunc(inst, day),
            dmg_mod = Info.MonsterStrengthenFns.DmgModFunc(inst, day),
            penetrate = Info.MonsterStrengthenFns.PenetrateFunc(inst, day),
        }
    end
    inst.hp = inst.hp+inst.hp*attr_data.hp_mod
    inst.def = inst.def+attr_data.absorb
    inst.dmg_mod = inst.dmg_mod+attr_data.dmg_mod
    inst.pen = inst.pen+attr_data.penetrate
    inst.dmg = inst.dmg+attr_data.ex_dmg
    -- for k, v in pairs(inst) do
    --     print(k, v)
    -- end

    return inst
end

local function calc_atk(inst)
    local p = inst.dmg+(inst.dmg*inst.dmg_mod)
    p = p*(1-inst.atk_spd)
    p = p*(1+inst.crit)
    return p
end

local function calc_def(inst)
    local p = inst.hp*(1+inst.def)
    p = p*(1+inst.evade)
    return p
end

local function calc_total()
    local inst = make_monster()
    return calc_atk(inst), calc_def(inst)
end

local ss = [[{
    day = %d, 
    monster = {atk=%d, def=%d},
    boss = {atk=%d, def=%d},
    player = {atk=%d, def=%d},
},]]
local t = 100000
for j = 1, 11 do
    local ma, md, ba, bd
    for k = 1, 2 do
        local sa, sd = 0, 0
        for i = 1, t do
            local a, d = calc_total()
            sa = sa+a
            sd = sd+d
        end
        sa = sa/t
        sd = sd/t

        if is_boss then
            ba, bd = sa, sd
        else
            ma, md = sa, sd
        end
        is_boss = not is_boss
    end
    local pa = md/3
    local pd = ma*7.5
    print(string.format(ss, day-1, ma, md, ba, bd, pa, pd))

    day = day+10
end