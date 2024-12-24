local EntUtil = require "extension.lib.ent_util"
local Kit = require "extension.lib.wargon"
local FxManager = Sample.FxManager
local BuffManager = Sample.BuffManager
local Info = Sample.Info

local EnchantmentData = Class(function(self)
end)

--[[
创建附魔类  
(EnchantmentData) 返回  
id (string) 名字  
init (func) 初始函数  
fn (func) 执行函数  
test (func) 条件函数  
desc (func) 描述函数  
quality (int) 附魔等级
]]
local function Enchantment(id, init, fn, test, desc, data, quality)
    local self = EnchantmentData()
    self.id = id
    self.init = init
    self.fn = fn
    self.test = test
    self.desc = desc
    self.data = data
    self.quality = quality or 1
    return self
end

function EnchantmentData:GetId()
    return self.id
end

function EnchantmentData:Init(inst, cmp, id)
    if self.data then
        if self.data.hp then
            inst.components.equippable:WgAddEquipMaxHealthModifier(id, self.data.hp)
        end
        if self.data.san then
            inst.components.equippable:WgAddEquipMaxSanityModifier(id, self.data.san)
        end
        if self.data.hg then
            inst.components.equippable:WgAddEquipMaxHungerModifier(id, self.data.hg)
        end
        if self.data.wp_dmg then
            if inst.components.weapon then
                inst.components.weapon:AddWeaponDmgMod(id, self.data.wp_dmg)
            end
        end
        if self.data.finite then
            if inst.components.finiteuses then 
                inst.components.finiteuses:AddMaxModifier(self.data.finite)
            end
        end
        if self.data.armor then
            if inst.components.armor then
                inst.components.armor:AddMaxModifier(self.data.armor)
            end
        end
        if self.data.dapper then
            local n = inst.components.equippable.dapperness
            inst.components.equippable.dapperness = n + self.data.dapper
        end
        if self.data.winter then
            if inst.components.insulator == nil then
                inst:AddComponent("insulator")
            end
            local n = inst.components.insulator.winter_insulation
            inst.components.insulator.winter_insulation = n + self.data.winter
        end
        if self.data.summer then
            if inst.components.insulator == nil then
                inst:AddComponent("insulator")
            end
            local n = inst.components.insulator.summer_insulation
            inst.components.insulator.summer_insulation = n + self.data.summer
        end
        if self.data.rain then
            if inst.components.waterproofer == nil then
                inst:AddComponent("waterproofer")
            end
            local n = inst.components.waterproofer.effectiveness
            inst.components.waterproofer.effectiveness = n + self.data.rain
        end
        inst.components.equippable:WgAddEquipFn(function(inst, owner)
            if self.data.spd then
                EntUtil:add_speed_amt(owner, id, self.data.spd)
            end
            if self.data.def then
                owner.components.combat:AddDefenseMod(id, self.data.def)
            end
            if self.data.evade then
                owner.components.combat:AddEvadeRateMod(id, self.data.evade)
            end
            if self.data.pentrt then
                owner.components.combat:AddPenetrateMod(id, self.data.pentrt)
            end
            if self.data.hit_rate then
                owner.components.combat:AddHitRateMod(id, self.data.hit_rate)
            end
            if self.data.atk_spd then
                EntUtil:add_attack_speed_mod(owner, id, self.data.atk_spd)
            end
            if self.data.crit then
                owner.components.combat:AddCritRateMod(id, self.data.crit)
            end
            if self.data.life_steal then
                owner.components.combat:AddLifeStealRateMod(id, self.data.life_steal)
            end
            if self.data.recover then
                owner.components.health:AddRecoverRateMod(id, self.data.recover)
            end
            if self.data.san_rate then
                EntUtil:add_sanity_mod(owner, id, self.data.san_rate)
            end
            if self.data.san_resist then
                owner.components.sanity:WgAddNegativeModifier(id, self.data.san_resist)
            end
            if self.data.hg_rate then
                EntUtil:add_hunger_mod(owner, id, self.data.hg_rate)
            end
            if self.data.attrs then
                if owner.components.tp_player_attr then
                    for attr, val in pairs(self.data.attrs) do
                        owner.components.tp_player_attr:AddAttrMod(attr, id, val)
                    end
                end
            end
            if self.dmg_resist then
                for dmg_type, val in pairs(self.data.dmg_resist) do
                    owner.components.combat:AddDmgTypeAbsorb(dmg_type, val)
                end
            end
        end)
        inst.components.equippable:WgRemoveEquipFn(function(inst, owner)
            if self.data.spd then
                EntUtil:rm_speed_amt(owner, id)
            end
            if self.data.def then
                owner.components.combat:RmDefenseMod(id)
            end
            if self.data.evade then
                owner.components.combat:RmEvadeRateMod(id)
            end
            if self.data.pentrt then
                owner.components.combat:RmPenetrateMod(id)
            end
            if self.data.hit_rate then
                owner.components.combat:RmHitRateMod(id)
            end
            if self.data.atk_spd then
                EntUtil:rm_attack_speed_mod(owner, id)
            end
            if self.data.crit then
                owner.components.combat:RmCritRateMod(id)
            end
            if self.data.life_steal then
                owner.components.combat:RmLifeStealRateMod(id)
            end
            if self.data.recover then
                owner.components.health:RmRecoverRateMod(id)
            end
            if self.data.san_rate then
                EntUtil:rm_sanity_mod(owner, id)
            end
            if self.data.san_resist then
                owner.components.sanity:WgRemoveNegativeModifier(id)
            end
            if self.data.hg_rate then
                EntUtil:rm_hunger_mod(owner, id)
            end 
            if self.data.attrs then
                if owner.components.tp_player_attr then
                    for attr, val in pairs(self.data.attrs) do
                        owner.components.tp_player_attr:RmAttrMod(attr, id)
                    end
                end
            end
            if self.dmg_resist then
                for dmg_type, val in pairs(self.data.dmg_resist) do
                    owner.components.combat:AddDmgTypeAbsorb(dmg_type, -val)
                end
            end
        end)
    end
end

function EnchantmentData:GetDescription(inst, cmp, id)
    local s = ""
    if self.data then
        if self.data.hp then
            s = s..string.format("生命%+d,", self.data.hp)
        end
        if self.data.san then
            s = s..string.format("理智%+d,", self.data.san)
        end
        if self.data.hg then
            s = s..string.format("饥饿%+d,", self.data.hg)
        end
        if self.data.wp_dmg then
            s = s..string.format("攻击%+d,", self.data.wp_dmg)
        end
        if self.data.spd then
            s = s..string.format("速度%+d,", self.data.spd)
        end
        if self.data.def then
            s = s..string.format("防御%+d,", self.data.def)
        end
        if self.data.evade then
            s = s..string.format("闪避%+d,", self.data.evade)
        end
        if self.data.pentrt then
            s = s..string.format("穿透%+d,", self.data.pentrt)
        end
        if self.data.hit_rate then
            s = s..string.format("命中%+d,", self.data.hit_rate)
        end
        if self.data.atk_spd then
            s = s..string.format("攻速%+d%%,", self.data.atk_spd*100)
        end
        if self.data.crit then
            s = s..string.format("暴击%+d%%,", self.data.crit*100)
        end
        if self.data.life_steal then
            s = s..string.format("吸血%+d%%,", self.data.life_steal*100)
        end
        if self.data.recover then
            s = s..string.format("生命恢复%+d%%,", self.data.recover*100)
        end
        if self.data.san_rate then
            s = s..string.format("理智缓降%+d%%,", self.data.san_rate*100)
        end
        if self.data.san_resist then
            s = s..string.format("理智抗性%+d%%,", self.data.san_resist*100)
        end
        if self.data.hg_rate then
            s = s..string.format("饥饿抗性%+d%%,", self.data.hg_rate*100)
        end
        if self.data.finite then
            s = s..string.format("耐久%+d,", self.data.finite)
        end
        if self.data.armor then
            s = s..string.format("护甲%+d,", self.data.armor)
        end
        if self.data.dapper then
            s = s..string.format("理智恢复%+.3f,", self.data.dapper)
        end
        if self.data.winter then
            s = s..string.format("耐寒%+d,", self.data.winter)
        end
        if self.data.summer then
            s = s..string.format("耐暑%+d,", self.data.summer)
        end
        if self.data.rain then
            s = s..string.format("防雨%+d%%,", self.data.rain*100)
        end
        if self.data.attrs then
            for attr, val in pairs(self.data.attrs) do
                s = s..string.format("%s%+d,", Info.Attr.PlayerAttrStr[attr], val)
            end
        end
        if self.dmg_resist then
            for dmg_type, val in pairs(self.data.dmg_resist) do
                s = s..string.format("%s抗%+d%%,", STRINGS.TP_DMG_TYPE[dmg_type], -val*100)
            end
        end
    end
    s = s..self:desc(inst, cmp, id)
    return s
end

function EnchantmentData:__tostring()
    return string.format("EnchantmentData(%s)", self.id)
end

local enchant_weapon = {
Enchantment("ice_weapon",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if math.random() < self.data.rate then
            BuffManager:AddBuff(target, "ice")
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击有%d%%几率令敌人进入寒冷状态",
        self.data.rate * 100)
end,
{hp=25,san=10,hg=25,rate=.2}, 1),
Enchantment("fire_weapon",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if math.random() < self.data.rate then
            BuffManager:AddBuff(target, "fire")
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击有%d%%几率令敌人进入灼烧状态",
        self.data.rate * 100)
end,
{hp=35,san=25,hg=35,rate=.2}, 1),
Enchantment("thunder_weapon",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if math.random() < self.data.rate then
            BuffManager:AddBuff(target, "electric")
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击有%d%%几率令敌人进入感电状态",
        self.data.rate * 100)
end, 
{hp=15,san=15,hg=15,rate=.3}, 1),
Enchantment("poison_weapon",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if math.random() < self.data.rate then
            BuffManager:AddBuff(target, "poison")
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击有%d%%几率令敌人进入毒害状态",
        self.data.rate * 100)
end, 
{hp=50,san=50,hg=50,rate=.2},2),
Enchantment("life_steal_weapon",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    return true
end,
function(self, inst, cmp, id)
    return ""
end, 
{hp=55,life_steal=.2}, 2),
Enchantment("with_wind_weapon",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        local n = cmp.datas[id] or 0
        n = n + 1
        if n >= 3 then
            n = 0
            EntUtil:get_attacked(target, owner, self.data.dmg, inst, 
                EntUtil:add_stimuli(nil, "wind")
            )
            FxManager:MakeFx("leaf", target)
        end
        cmp.datas[id] = n
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("第3次攻击会额外造成%d风属性伤害(第%d次)",
        self.data.dmg, cmp.datas[id] or 0)
end, 
{dmg=20, atk_spd=.1}, 1),
Enchantment("with_electric_weapon",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if math.random() < self.data.rate then
            EntUtil:get_attacked(target, owner, self.data.dmg, inst, 
                EntUtil:add_stimuli(nil, "electric")
            )
            FxManager:MakeFx("lightning", target)
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击时有%d%%几率额外造成%d电属性伤害",
        self.data.rate*100, self.data.dmg)
end, 
{hp=10,san=25,san_rate=.15,dmg=30,rate=.3}, 1),
Enchantment("add_speed_weapon",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        BuffManager:AddBuff(owner, "speed_up", nil, self.data.add_spd)
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击后增加%d移速", 
        self.data.add_spd)
end,
{wp_dmg=10,hp=10,hg=25,add_spd=3}, 1),
Enchantment("combat_hot",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        local n = cmp.datas[id] or 0
        n = math.min(n + 1, 10)
        if cmp[id.."_task"] then
            cmp[id.."_task"]:Cancel()
            cmp[id.."_task"] = nil
        end
        cmp[id.."_task"] = inst:DoTaskInTime(4, function(inst)
            cmp.datas[id] = nil
            if cmp[id.."_task"] then
                cmp[id.."_task"]:Cancel()
                cmp[id.."_task"] = nil
            end
        end)
    end)
    inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
        local n = cmp.datas[id] or 0
        return damage + n * self.data.dmg
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击会叠加层数,每层增加%d攻击力(%d层)",
        self.data.dmg, cmp.datas[id] or 0)
end, 
{hp=20,hg=30,dmg=3}, 1),
Enchantment("beefalo_killer",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if target:HasTag("beefalo") then
            EntUtil:get_attacked(target, owner, self.data.dmg, nil,
                EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type)
            )
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击对牦牛额外造成%d点伤害",
        self.data.dmg)
end, 
{hp=10,hg=30,san=30,dmg=30}, 1),
Enchantment("dmg_recover",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddEquipFn(function(inst, owner)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = EntUtil:listen_for_event(owner, "onhitother", function(inst, data)
                if data.target and data.damage then
                    data.target:DoTaskInTime(3, function(target)
                        if EntUtil:is_alive(target) then
                            target.components.health:DoDelta(data.damage)
                        end
                    end)
                end
            end)
        end
    end)
    inst.components.weapon:WgAddUnequipFn(function(inst, owner)
        if cmp[id.."_fn"] then
            owner:RemoveEventCallback("onhitother", cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击的敌人3s后会回复本次受到伤害的生命值")
end, 
{wp_dmg=50,hg=80,hp=60,san=70}, 1),
Enchantment("rose_bloom",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if not inst:HasTag(id) then
            FxManager:MakeFx("thorns_green", target)
            EntUtil:make_area_dmg(target, 4, owner, self.data.dmg, inst,
                EntUtil:add_stimuli(nil, "spike"),
                {
                    test = function(v, attacker, weapon)
                        return v ~= target
                    end
                }
            )
            inst:AddTag(id)
            inst:DoTaskInTime(10, function()
                inst:RemoveTag(id)
            end)
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("每隔一段时间,下次攻击会造成%d范围伤害",
        self.data.dmg)
end, 
{dmg=30,hp=20,hg=40}, 1),
Enchantment("rose_ice_bloom",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if not inst:HasTag(id) then
            BuffManager:AddBuff(target, "ice")
            FxManager:MakeFx("thorns_blue", target)
            EntUtil:make_area_dmg(target, 4, owner, self.data.dmg, inst,
                EntUtil:add_stimuli(nil, "ice"),
                {
                    test = function(v, attacker, weapon)
                        return v ~= target
                    end,
                    fn = function(v, attacker, weapon)
                        BuffManager:AddBuff(v, "ice")
                    end
                }
            )
            inst:AddTag(id)
            inst:DoTaskInTime(10, function()
                inst:RemoveTag(id)
            end)
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("每隔一段时间,下次攻击会造成%d范围伤害,并令伤害对象进入寒冷状态",
        self.data.dmg)
end, 
{hp=20,hg=20,dapper=.01,dmg=10}, 2),
Enchantment("rose_ice_bloom",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if not inst:HasTag(id) then
            BuffManager:AddBuff(target, "fce")
            FxManager:MakeFx("thorns_red", target)
            EntUtil:make_area_dmg(target, 4, owner, self.data.dmg, inst,
                EntUtil:add_stimuli(nil, "spike"),
                {
                    test = function(v, attacker, weapon)
                        return v ~= target
                    end,
                    fn = function(v, attacker, weapon)
                        BuffManager:AddBuff(v, "fire")
                    end
                }
            )
            inst:AddTag(id)
            inst:DoTaskInTime(15, function()
                inst:RemoveTag(id)
            end)
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("每隔一段时间,下次攻击会造成%d范围伤害,并令伤害对象进入灼烧状态",
        self.data.dmg)
end, 
{hp=20,san=30,finite=50,dmg=10}, 2),
Enchantment("steal_small_dmg",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if target:HasTag("smallcreature") then
            BuffManager:AddBuff(owner, "damage_up", nil, self.data.dmg_steal)
            BuffManager:AddBuff(target, "damage_down", nil, self.data.dmg_steal)
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击小型生物时,会偷取其%d攻击力",
        self.data.dmg_steal)
end, 
{dmg_steal=20,hp=60}, 2),
Enchantment("keyboard_dmg",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.equippable:WgAddEquipFn(function(inst, owner)
        if cmp[id.."_handler"] == nil then
            cmp[id.."_handler"] = TheInput:AddKeyDownHandler(KEY_F, function()
                if cmp[id.."_key"] == nil then
                    cmp[id.."_key"] = true
                    if cmp[id.."_task"] then
                        cmp[id.."_task"]:Cancel()
                        cmp[id.."_task"] = nil
                    end
                    cmp[id.."_task"] = inst:DoTaskInTime(.5, function()
                        cmp[id.."_stack"] = nil
                    end)
                    local n = cmp[id.."_stack"] or 0
                    n = math.min(n + 1, 10)
                    cmp[id.."_stack"] = n
                end
            end)
        end
        if cmp[id.."_handler2"] == nil then
            cmp[id.."_handler2"] = TheInput:AddKeyUpHandler(KEY_F, function()
                cmp[id.."_key"] = nil
            end)
        end
    end)
    inst.components.equippable:WgAddUnequipFn(function(inst, owner)
        if cmp[id.."_handler"] then
            cmp[id.."_handler"]:Remove()
            cmp[id.."_handler"] = nil
        end
        if cmp[id.."_handler2"] then
            cmp[id.."_handler2"]:Remove()
            cmp[id.."_handler2"] = nil
        end
    end)
    inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
        local n = cmp[id.."_stack"] or 0
        return damage + n*self.data.dmg
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("每次按下F键,会增加%d攻击力",
        self.data.dmg)
end, 
{dmg=5,hp=40,san=40}, 1),
Enchantment("assassin_part",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return ""
end, 
{dmg=10,pentrt=10}, 1),
Enchantment("drop_smallmeat",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst:ListenForEvent("wg_owner_killed", function(inst, data)
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
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("杀死单位有几率掉落小肉,生命越高的单位掉率越高")
end, 
{hp=25,san=10,hg=25}, 1),
Enchantment("low_finite_dmg_up",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
        if inst.components.finiteuses then
            local p = inst.components.finiteuses:GetPercent()
            if p <= self.data.rate then
                damage = damage + self.data.dmg
            end
        end
        return damage
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("耐久低于%d%%时,攻击力增加%d",
        self.data.rate * 100, self.data.dmg)
end, 
{rate=.3,dmg=35,atk_spd=.05,hp=10}, 1),
-- quality 2
Enchantment("conqueror",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        local n = cmp.datas[id] or 0
        n = math.min(n + 1, 12)
        if n == 12 then
            BuffManager:AddBuff(owner, "life_setal_up", nil, self.data.life_steal2)
        end
        if cmp[id.."_task"] then
            cmp[id.."_task"]:Cancel()
            cmp[id.."_task"] = nil
        end
        cmp[id.."_task"] = inst:DoTaskInTime(5, function(inst)
            cmp.datas[id] = nil
            if cmp[id.."_task"] then
                cmp[id.."_task"]:Cancel()
                cmp[id.."_task"] = nil
            end
        end)
    end)
    inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
        local n = cmp.datas[id] or 0
        return damage + n * 2
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击会叠加层数,提升攻击力,叠至最大层时,吸血%+d%%(%d层)",
        self.data.life_steal2 * 100, cmp.datas[id] or 0)
end, 
{hp=20,san=30,hg=30,life_steal2=.2}, 2),
Enchantment("thunder_weapon2",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if math.random() < self.data.rate then
            BuffManager:AddBuff(target, "electric")
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击有%d%%几率令敌人进入感电状态",
        self.data.rate * 100)
end, 
{wp_dmg=10,dapper=.01,rate=.33}, 2),
Enchantment("conductive_ice_weapon",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if target:HasTag("electric") then
            BuffManager:AddBuff(target, "conductive_ice")
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击感电状态的敌人会令其进入感电易寒冷状态")
end,
{hp=20,san=30,crit=.1}, 2),
Enchantment("conductive_ice_weapon",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if target:HasTag("electric") then
            BuffManager:AddBuff(target, "conductive_fire")
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击感电状态的敌人会令其进入感电易灼烧状态")
end, 
{hp=20,hg=30,hit_rate=10}, 2),
Enchantment("small_aoe",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        FxManager:MakeFx("groundpound_fx", target)
        EntUtil:make_area_dmg(target, 3.5, owner, self.data.dmg, inst,
            EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type),
            {
                test = function(v, attacker, weapon)
                    return v ~= target
                end
            }
        )
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击对周围单位造成%d伤害",
        self.data.dmg)
end, 
{dmg=20,wp_dmg=5,hp=30}, 2),
Enchantment("fire_ex_dmg",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if BuffManager:HasBuff(target, "fire") then
            EntUtil:get_attacked(target, owner, self.data.dmg, nil, 
                EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type)
            )
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("对灼烧状态的单位造成额外伤害")
end, 
{dmg=40,finite=10}, 2),
Enchantment("atk_poison_rcv_down",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if BuffManager:HasBuff(target, "poison") then
            BuffManager:AddBuff(target, "recover_down", self.data.rate)
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击毒害状态的目标降低其%d%%生命恢复",
        self.data.rate * 100)
end, 
{rate=.2,atk_spd=.1,wp_dmg=10}, 2),
Enchantment("atk_ice_def_down",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if BuffManager:HasBuff(target, "ice") then
            BuffManager:AddBuff(target, "defense_down", self.data.def2)
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击寒冷状态的敌人,降低其%d防御",
        self.data.def2)
end, 
{def2=30,crit=.1,san_rate=.15}, 2),
Enchantment("drop_gold",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst:ListenForEvent("wg_owner_killed", function(inst, data)
        if data.victim and data.victim.components.tp_creature_equip then
            local max = data.victim.components.health:GetMaxHealth()
            local level = data.victim.components.tp_creature_equip.level or 1
            local n = math.max(1,math.floor(level/10))
            if data.victim:HasTag("world_boss") then
                n = n*10
            elseif data.victim:HasTag("epic") then
                n = n*5
            elseif data.victim:HasTag("largecreature") then
                n = n*2
            end
            while n > 0 do
                local dt = math.min(40, n)
                local reward = SpawnPrefab("oinc")
                reward.components.stackable:SetStackSize(dt)
                Kit:throw_item(reward, data.owner)
                n = n - dt
            end
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("杀死生物装备的单位后,会获得赏金,怪物等级越高,体型越大,赏金越多")
end, 
{atk_spd=.15,crit=.1}, 2),
Enchantment("anubis_believer",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst:ListenForEvent("wg_owner_killed", function(inst, data)
        if data.victim 
        and data.victim.components.tp_creature_equip then
            local n = 1
            if data.victim:HasTag("epic") then
                n = 4
            elseif data.victim:HasTag("largecreature") then
                n = 2
            end
            if data.owner.components.tp_recorder then
                local stk = data.owner.components.tp_recorder.anubis_stack
                data.owner.components.tp_recorder.anubis_stack = stk+n
            end
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("杀死生物装备的单位后,会增加阿努比斯的祭献值")
end, 
{wp_dmg=10,san_resist=.1,hp=20}, 2),
Enchantment("attacking_absorb",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.equippable:WgAddEquipAttackedFn(function(damage, attacker, weapon, owner, item)
        if owner.sg and owner.sg:HasStateTag("attack")
        and owner.sg:HasStateTag("busy") then
            if owner.sg:HasStateTag("abouttoattack") then
                damage = damage * self.data.rate
            else
                damage = damage * self.data.rate/3
            end
        end
        return damage
    end)
end,
function(self, inst, cmp, id)
    return inst.components.equippable ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击时降低受到的伤害,前摇时降低的伤害较少")
end, 
{rate=.6,life_steal=.1,finite=30}, 2),
-- quality 3
Enchantment("fire_immune",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        BuffManager:AddBuff(owner, "fire_immune")
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击获得buff,免疫燃烧")
end, 
{hp=30,pentrt=10,def=10}, 3),
Enchantment("poison_immune",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        BuffManager:AddBuff(owner, "poison_immune")
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击获得buff,免疫中毒")
end, 
{hp=30,san=30,spd=1}, 3),
Enchantment("frozen_immune",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        BuffManager:AddBuff(owner, "frozen_immune")
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击获得buff,免疫冰冻")
end, 
{hp=30,hg=30,hit_rate=10}, 3),
Enchantment("lose_finite_up_dmg",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
        if inst.components.finiteuses then
            local use = inst.components.finiteuses:GetUses()
            local total = inst.components.finiteuses.total
            damage = damage + math.floor((total - use)/self.data.rate)
        end
        return damage
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("每损失%d点耐久,攻击力越高",
        self.data.rate)
end, 
{rate=5,hp=50,hit_rate=10}, 3),
Enchantment("recover_debuff_weapon",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        BuffManager:AddBuff(target, "recover_down", self.data.rate)
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击令目标生命恢复降低%d%%",
        self.data.rate*100)
end, 
{rate=.3,finite=100,hp=50}, 3),
-- quality 4
Enchantment("drop_one_loot",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if target.components.lootdropper
        and math.random() < self.rate then
            target.components.lootdropper:DropSingleLoot()
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击有几率掉落一个属于目标的战利品")
end, 
{spd=2,atk_spd=.15,rate=.1}, 4),
Enchantment("weapon_from_strengthen",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
        local owner = inst.components.equippable and inst.components.equippable.owner
        if owner then
            local power = owner.components.tp_player_attr.power
            return damage + power
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("强壮属性带来的攻击力加成翻倍")
end, 
{hp=125,hg=80}, 4),
-- Enchantment("elem_debuff_immune",
-- function(self, inst, cmp, id)
-- end,
-- function(self, inst, cmp, id)
--     inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
--         BuffManager:AddBuff(owner, "fire_immune")
--         BuffManager:AddBuff(owner, "poison_immune")
--         BuffManager:AddBuff(owner, "frozen_immune")
--     end)
-- end,
-- function(self, inst, cmp, id)
--     return inst.components.weapon ~= nil
-- end,
-- function(self, inst, cmp, id)
--     return string.format("攻击获得buff,免疫燃烧,免疫中毒,免疫冰冻")
-- end, 
-- {hp=55,san=65,hg=55}, 4),
Enchantment("shadow_killer",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if target:HasTag("shadowcreature") then
            EntUtil:get_attacked(target, owner, self.data.dmg, nil,
                EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type)
            )
        end
    end)
    -- inst.components.equippable:WgAddEquipFn(function(inst, owner)
    --     EntUtil:add_speed_amt(owner, id, self.data.spd)
    --     owner.components.sanity:WgAddNegativeModifier(id, self.data.san_resist)
    -- end)
    -- inst.components.equippable:WgAddUnequipFn(function(inst, owner)
    --     EntUtil:rm_speed_amt(owner, id)
    --     owner.components.sanity:WgRemoveNegativeModifier(id)
    -- end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击对暗影生物额外造成%d伤害",
        self.data.dmg)
end, 
{dmg=200,spd=1,san_resist=.2}, 4),
Enchantment("atk_defense",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        BuffManager:AddBuff(target, "defense_up", nil, self.data.def2)
    end)
    -- inst.components.weapon:AddWeaponDmgMod(id, self.data.dmg)
    -- inst.components.equippable:WgAddEquipMaxHealthModifier(id, self.data.hp)
    -- inst.components.equippable:WgAddEquipMaxSanityModifier(id, self.data.san)
    -- inst.components.equippable:WgAddEquipMaxHungerModifier(id, self.data.hg)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击提升%d防御", 
        self.data.def2)
end, 
{def2=50,wp_dmg=20,hp=70,san=55,hg=55}, 4),
Enchantment("low_hp_killer",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        if target.components.health:GetPercent() < self.data.rate then
            EntUtil:get_attacked(target, owner, self.data.dmg, nil,
                EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type)
            )
        end
    end)
end,
function(self, inst, cmp, id)
    return true
end,
function(self, inst, cmp, id)
    return string.format("对生命值低于%d%%的单位额外造成%d点伤害",
        self.data.rate*100, self.data.dmg)
end, 
{rate=.3,dmg=300,san_resist=.3,pentrt=30}, 4),
-- quality 6
Enchantment("kind_aoe",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        FxManager:MakeFx("groundpoundring_fx", owner)
        EntUtil:make_area_dmg(owner, 12, owner, 0, inst,
            EntUtil:add_stimuli(nil, inst.components.weapon.dmg_type),
            {
                calc = true,
                mult = self.data.dmg_mult,
                test = function(v, attacker, weapon)
                    return v ~= target
                        and EntUtil:check_congeneric(v, target)
                end,
            }
        )
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击会对周围的与目标同类的单位造成伤害")
end, 
{dmg_mult=.35,hp=130,hg=125,san=125}, 6),
Enchantment("hades_weapon",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        local pos = target:GetPosition()    
        local foot = SpawnPrefab("tp_hell_guard")	
        foot.Transform:SetRotation(self:SetFootRotation())
        foot.Transform:SetPosition(pos:Get())
        foot:DoTaskInTime(10*FRAMES, function() foot:StartStep() end)
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("攻击暗影生物会召唤冥界守卫,对暗影生物造成毁灭性打击")
end,
{life_steal=.33,dapper=.1,hp=100,san=145}, 6),
Enchantment("up_dmg_by_san_p",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.weapon:WgAddWeaponDamageFn(function(inst, damage)
        local owner = inst.components.equippable and inst.components.equippable.owner
        if owner.components.sanity then
            local p = owner.components.sanity:GetPercent()
            damage = damage + p*100
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.weapon ~= nil
end,
function(self, inst, cmp, id)
    return string.format("你每拥有1%%的理智,你的攻击力增加1点")
end, 
{dapper=-.1,spd=1,pentrt=20,hp=120,san=100,hg=130}, 6),
}
-- weapon over

local enchant_armor = {
-- quality 1
Enchantment("life_wood",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.armor:WgAddTakeDamageFn(function(ab_dmg, attacker, weapon, owner, item, stimuli)
        if cmp.datas[id] == nil then
            cmp.datas[id] = 0
        end
        cmp.datas[id] = cmp.datas[id] + ab_dmg
        if cmp.datas[id] > self.data.amt then
            cmp.datas[id] = nil
            owner.components.health:DoDelta(self.data.rcv_hp)
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("每吸收%d伤害,恢复%d生命值",
        self.data.amt, self.data.rcv_hp)
end, 
{hp=20,amt=200,rcv_hp=30}, 1),
Enchantment("recover_armor",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    return true
end,
function(self, inst, cmp, id)
    return string.format("")
end, 
{recvoer=.15,hp=50}, 1),
Enchantment("ice_armor",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.armor:WgAddTakeDamageFn(function(ab_dmg, attacker, weapon, owner, item, stimuli)
        if EntUtil:can_dmg_effect(stimuli) then
            if math.random() < self.data.rate then
                BuffManager:AddBuff(attacker, "ice")
            end
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("受到普通攻击有%d%%几率令敌人进入寒冷状态", 
        self.data.rate*100)
end, 
{rate=.3,hp=20,san=15,hg=15}, 1),
Enchantment("fire_armor",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.armor:WgAddTakeDamageFn(function(ab_dmg, attacker, weapon, owner, item, stimuli)
        if EntUtil:can_dmg_effect(stimuli) then
            if math.random() < self.data.rate then
                BuffManager:AddBuff(attacker, "fire")
            end
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("受到普通攻击有%d%%几率令敌人进入灼烧状态", 
        self.data.rate*100)
end, 
{rate=.3,hp=20,san=15,hg=15}, 1),
Enchantment("electric_wake",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.armor:WgAddTakeDamageFn(function(ab_dmg, attacker, weapon, owner, item, stimuli)
        if EntUtil:in_stimuli(stimuli, "electric") then
            BuffManager:AddBuff(owner, "speed_up", nil, self.data.spd2)
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("受到雷属性伤害会增加%d速度", self.data.spd2)
end, 
{spd2=3,hp=15,hg=20,san=20}, 1),
Enchantment("evade_armor",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    return true
end,
function(self, inst, cmp, id)
    return string.format("")
end, 
{evade=20,hp=20}, 1),
Enchantment("def_armor",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    return true
end,
function(self, inst, cmp, id)
    return string.format("")
end, 
{def=20,hp=15}, 1),
-- quality 2
Enchantment("rock_break",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.armor:WgAddTakeDamageFn(function(ab_dmg, attacker, weapon, owner, item, stimuli)
        local n = cmp.datas[id] or 0
        n = math.min(n + ab_dmg, self.data.max)
        cmp.datas[id] = n
        if cmp[id.."_task"] then
            cmp[id.."_task"]:Cancel()
            cmp[id.."_task"] = nil
        end
        cmp[id.."_task"] = inst:DoTaskInTime(10, function()
            cmp.datas[id] = nil
        end)
    end)
    inst.components.equippable:WgAddEquipAttackedFn(function(damage, attacker, weapon, owner, item, stimuli)
        local n = cmp.datas[id] or 0
        if n > self.data.max then
            damage = damage - self.data.amt
        end
        return damage
    end)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("吸收超过%d点伤害后,受到的伤害减少%d点(已吸收%d)",
        self.data.max, self.data.amt, cmp.datas[id] or 0)
end, 
{max=50,amt=10,def=10,evade=10,hp=20}, 2),
Enchantment("big_rock",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("")
end, 
{spd=-2,def=50,hp=100,san=50,hg=50}, 2),
Enchantment("fire_resist_armor",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("")
end, 
{dmg_resist={fire=-.15},evade=10,hp=20,hg=20}, 2),
Enchantment("spike_resist_armor",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("")
end, 
{dmg_resist={spike=-.1},evade=10,hp=15,hg=15}, 2),
Enchantment("shadow_resist_armor",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("")
end, 
{dmg_resist={shadow=-.25},hp=-75,san=-30}, 2),
Enchantment("rain_charge_armor",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    return true
end,
function(self, inst, cmp, id)
    return string.format("")
end, 
{rain=.2,spd=1,def=20,san_rate=.15}, 2),
-- quality 3
Enchantment("san_hg_evade_armor",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.amror:WgAddTakeDamageFn(function(ab_dmg, attacker, weapon, owner, item, stimuli)
        if owner.components.sanity then
            owner.components.sanity:DoDelta(-ab_dmg*self.data.rate)
        end
        if owner.components.hunger then
            owner.components.hunger:DoDelta(-ab_dmg*self.data.rate)
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("吸收伤害时会减少%d%%此伤害的理智和饥饿", 
        self.data.rate*100)
end, 
{rate=.3,evade=80}, 3),
Enchantment("firm_armor",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.equippable:WgAddEquipFn(function(inst, owner)
        owner:AddTag("not_hit_stunned")
    end)
    inst.components.equippable:WgAddUnequipFn(function(inst, owner)
        owner:RemoveTag("not_hit_stunned")
    end)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("受到攻击不会硬直")
end, 
{hp=55,san=60,hg=50}, 3),
Enchantment("against_armor",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.equippable:WgAddEquipAttackedFn(function(damage, attacker, weapon, owner, item, stimuli)
        inst.components.armor:WgAddTakeDamageFn(function(ab_dmg, attacker, weapon, owner, item, stimuli)
            local n = cmp.datas[id] or 0
            n = math.min(n + ab_dmg, self.data.max)
            cmp.datas[id] = n
        end)
    end)

    inst.components.equippable:WgAddEquipFn(function(inst, owner)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = owner.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
                local n = cmp.datas[id] or 0
                if n >= self.data.max then
                    cmp.datas[id] = nil
                    damage = damage - self.data.dmg
                end
            end)
        end
    end)
    inst.components.equippable:WgAddUnequipFn(function(inst, owner)
        if cmp[id.."_fn"] then
            owner.components.combat:WgRemoveCalcDamageFn(cmp[id.."_fn"])
            cmp[id.."_fn"] = nil
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("吸收%d伤害后,下次攻击%+d,(已吸收%d)",
        self.data.max, self.data.dmg, cmp.datas[id] or 0)
end, 
{max=150,dmg=50,armor=200}, 3),
-- quality 4
Enchantment("periodic_block",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst:DoTaskInTime(self.data.time, function()
        inst:AddTag(id)
    end)
    inst.components.equippable:WgAddEquipAttackedFn(function(damage, attacker, weapon, owner, item, stimuli)
        if inst:HasTag(id) then
            inst:RemoveTag(id)
            inst:DoTaskInTime(self.data.time, function()
                inst:AddTag(id)
            end)
            return 0
        end
    end)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("每过%d秒,免疫一次攻击(%s)", 
        self.data.time, inst:HasTag(id) and "已准备" or "冷却中")
end, 
{time=60,attrs={strengthen=2,health=2,faith=2}}, 4),
-- quality 6
Enchantment("giant_blocker",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.equippable:WgAddEquipAttackedFn(function(damage, attacker, weapon, owner, item, stimuli)
        local max = attacker.components.health:GetMaxHealth()
        local max2 = owner.components.health:GetMaxHealth()
        if max - max2 >= self.data.dt then
            damage = damage * (1-self.data.rate)
        end
        return damage
    end)
end,
function(self, inst, cmp, id)
    return inst.components.armor ~= nil
end,
function(self, inst, cmp, id)
    return string.format("如果攻击你的单位生命上限比你高%d,那么此伤害降低%d%%",
        self.data.dt, self.data.rate*100)
end, 
{4000, .3}, 6),
}
-- armor over

local enchant_all = {
Enchantment("warm_equip",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    return true
end,
function(self, inst, cmp, id)
    return string.format("")
end, 
{winter=120,attrs={endurance=2}}, 1),
Enchantment("cool_equip",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    return true
end,
function(self, inst, cmp, id)
    return string.format("")
end, 
{summer=120,attrs={health=2}}, 1),
Enchantment("rain_equip",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    return true
end,
function(self, inst, cmp, id)
    return string.format("")
end, 
{rain=.3,attrs={stamina=2}}, 1),
-- quality 2
Enchantment("poisonblocker_equip",
function(self, inst, cmp, id)
end,
function(self, inst, cmp, id)
    inst.components.equippable.poisonblocker = true
end,
function(self, inst, cmp, id)
    return true
end,
function(self, inst, cmp, id)
    return string.format("防毒")
end, 
{attrs={health=2}}, 2),
}

local enchant_cloth = {}

local enchant_tool = {}

local DataManager = require "extension.lib.data_manager"
local EnchantmentManager = DataManager("EnchantmentManager")
EnchantmentManager:AddDatas(enchant_weapon, "weapon")
EnchantmentManager:AddDatas(enchant_all, "all")
EnchantmentManager:AddDatas(enchant_cloth, "cloth")
EnchantmentManager:AddDatas(enchant_armor, "armor")
EnchantmentManager:AddDatas(enchant_tool, "tool")

Sample.EnchantmentManager = EnchantmentManager
