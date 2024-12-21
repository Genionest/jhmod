local AssetUtil = require "extension/lib/asset_util"
local EntUtil = require "extension/lib/ent_util"
local Util = require "extension/lib/wg_util"
local AssetMaster = Sample.AssetMaster
local Info = Sample.Info
local ScrollLibrary = Sample.ScrollLibrary

local SkillData = Class(function(self, data)
end)

--[[
创建技能类
(SkillData) 返回
id (String) 标识
name (String) 名字
desc (String/func) 描述
Uimg (Img) 图片资源,
anim (table{String}) 动画资源列表, bank, build, animation
fn (func) 拥有此技能后触发的函数  
fn2 (func) 拥有此技能后触发的函数2  
data (table) 技能数据  
]]
local function Skill(id, name, desc, Uimg, anims, fn, fn2, data)
    local self = SkillData()
    self.id = id
    self.name = name
    self.desc = desc
    -- 图片资源
    -- if AssetMaster:HasAssetData(img) then
    --     self.Uimg = AssetMaster:GetUimg(img)
    -- else
    --     self.Uimg = AssetUtil:MakeImg(img)
    -- end
    self.Uimg = Uimg
    self.anims = anims
    self.fn = fn
    self.fn2 = fn2
    self.data = data
    self.unlock = nil
    return self
end

function SkillData:GetId()
    return self.id
end

function SkillData:IsLock()
    return not self.unlock
end

function SkillData:Unlock(owner)
    -- self:Trigger(owner)
    self.unlock = true
end

function SkillData:Trigger(owner)
    self.fn(owner, self)
end

function SkillData:ForeverEffect(owner)
    if self.fn2 then
        self.fn2(owner, self)
    end
end

function SkillData:TestUnlock()

    if self.unlock then
        return false
    end
    return true
end

function SkillData:TryUnlock(owner)
    if self:TestUnlock() then
        self:Unlock(owner)
    end
end

function SkillData:GetAnims()
    return self.anims
end

function SkillData:GetImage()
    return AssetUtil:GetImage(self.Uimg)
end

function SkillData:GetName()
    if self.unlock then
        return self.name
    else
        return ""
    end
end

function SkillData:GetDescription()
    -- if self:IsLock() then
    --     local a1 = string.find(self.id, "P")
    --     local a2 = string.find(self.id, "L")
    --     if a1 and a2 then
    --         local phase = string.sub(self.id, a1+1, a2-1)
    --         local level = string.sub(self.id, a2+1, -1)
    --         return "阶段"..phase.."等级"..level.."解锁"
    --     end
    -- else
    
    -- end
    local desc
    if type(self.desc) == "function" then
        desc = self.desc(self)
    elseif type(self.desc) == "string" then
        desc = self.desc
    else
        assert(nil, string.format("SkillData's desc must be function or string, not %s", type(self.desc)))
    end
    return Util:SplitSentence(desc, nil, true)
end

local function skill_grow(name, phase)
    if phase == 3 then
        return Skill("P3L21", "成长II",
            string.format("理智降低速度增加%d%%, 增加%d理智上限",
                Info.Character[name].Phase3SanityRate*100,
                Info.Character[name].Phase3SanityMod),
            AssetUtil:MakeImg("gummy_cake"), 
            nil,
            function(inst)
                inst.components.sanity:WgAddMaxSanityModifier("skill", Info.Character[name].Phase3SanityMod)
                EntUtil:add_sanity_mod(inst, "skill", Info.Character[name].Phase3SanityRate)
            end,
            function(inst)
                inst.components.sanity:WgAddMaxSanityModifier("skill", Info.Character[name].Phase3SanityMod, true)
            end
        )
    elseif phase == 2 then
        return Skill("P2L11", "成长",
            string.format("饥饿速度增加%d%%, 增加%d饥饿上限", 
                Info.Character[name].Phase2HungerRate*100,
                Info.Character[name].Phase2HungerMod),
            AssetUtil:MakeImg("pumpkincookie"), 
            nil, 
            function(inst)
                inst.components.hunger:WgAddMaxHungerModifier("skill", Info.Character[name].Phase2HungerMod)
                EntUtil:add_hunger_mod(inst, "skill", Info.Character[name].Phase2HungerRate)
            end,
            function(inst)
                inst.components.hunger:WgAddMaxHungerModifier("skill", Info.Character[name].Phase2HungerMod, true)
            end
        )
    end
end

local player_tree = {
    Skill("wilson", "威尔逊",
    function(self)
        return string.format("耐力+%d,体力%+d,专注%+d;你使用%d张卷轴后,升级你的技能", 
            self.data[1], self.data[2], self.data[3], self.data[4])
    end,
    AssetUtil:MakeImg("minimap/minimap_data.xml", "wilson.png", true),
    nil,
    function(inst, cmp, id, self)
        inst.components.tp_player_attr:AddAttrMod("endurance", self.data[1])
        inst.components.tp_player_attr:AddAttrMod("stamina", self.data[1])
        inst.components.tp_player_attr:AddAttrMod("attention", self.data[3])
        inst:ListenForEvent("use_scroll", function(inst, data)
            local btn_id = inst.components.tp_player_button.id
            if btn_id == "wilson" then
                local n = cmp[id.."_val"] or 0
                n = n + 1
                if n >= self.data[4] then
                    inst.components.tp_player_button:SetSkillButton("wilson2")
                end
                cmp[id.."_val"] = n
            end
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {10, 5, 15, 30}),
    
    Skill("willow", "薇洛",
    function(self)
        return string.format("专注%+d,信仰%+d;你使用%d张火卷轴后,获得1本火魔法书;低理智时不再会放火",
            self.data[1], self.data[2], self.data[3])
    end,
    AssetUtil:MakeImg("minimap/minimap_data.xml", "willow.png", true),
    nil,
    function(inst, cmp, id, self)
        inst.components.tp_player_attr:AddAttrMod("attention", 10)
        inst:ListenForEvent("use_scroll", function(inst, data)
            local scroll_name = data.scroll.prefab
            if ScrollLibrary:GetDataKindById(scroll_name) == "fire" then
                local n = cmp[id.."_val"] or 0
                local scroll_num = self.data[3]
                if n < scroll_num then
                    n = n + 1
                    if n >= scroll_num then

                    end
                end
                cmp[id.."_val"] = n
            end
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {15, 10, 20}),
    
    Skill("wathgrithr", "薇格弗德",
    function(self)
        return string.format("健康%+d;耐力%+d;强壮%+d;强壮效果提升至%d%%;原本的杀死单位效果不再触发",
            self.data[1], self.data[2], self.data[3], self.data[4]*100)
    end,
    AssetUtil:MakeImg("minimap/minimap_data.xml", "wathgrithr.png", true),
    nil,
    function(inst, cmp, id, self)
        inst.components.tp_player_attr:SetAttrRate("strengthen", self.data[4])
        inst.components.tp_player_attr:AddAttrMod("health", self.data[1])
        inst.components.tp_player_attr:AddAttrMod("endurance", self.data[2])
        inst.components.tp_player_attr:AddAttrMod("strengthen", self.data[3])
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {10, 10, 10, 1.3}),
    
    Skill("wickerbottom", "薇克巴顿",
    function(self)
        return string.format("智力%+d,专注%+d;专注效果提升至%d%%;",
            self.data[1], self.data[2], self.data[3]*100)
    end,
    AssetUtil:MakeImg("minimap/minimap_data.xml", "wickerbottom.png", true),
    nil,
    function(inst, cmp, id, self)
        inst.components.tp_player_attr:SetAttrRate("attention", self.data[3])
        inst.components.tp_player_attr:AddAttrMod("intelligence", self.data[1])
        inst.components.tp_player_attr:AddAttrMod("attention", self.data[2])
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {15, 15, 1.25}),
    
    Skill("waxwell", "麦斯威尔", 
    function(self)
        return string.format("专注%+d,信仰%+d;智力效果提升至%d%%;你使用20个暗卷轴后,升级你的技能",
            self.data[1], self.data[2], self.data[3]*100, self.data[4])
    end,
    AssetUtil:MakeImg("minimap/minimap_data.xml", "waxwell.png", true),
    nil,
    function(inst, cmp, id, self)
        inst.components.tp_player_attr:SetAttrRate("intelligence", self.data[3])
        inst.components.tp_player_attr:AddAttrMod("attention", self.data[1])
        inst.components.tp_player_attr:AddAttrMod("faith", self.data[2])
        inst:ListenForEvent("use_scroll", function(inst, data)
            local btn_id = inst.components.tp_player_button.id
            if btn_id == "waxwell" then
                local n = cmp[id.."_val"] or 0
                n = n + 1
                if n >= self.data[4] then
                    inst.components.tp_player_button:SetSkillButton("waxwell2")
                end
                cmp[id.."_val"] = n
            end
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {20, 10, 1.3, 20}),

    Skill("wolfgang", "沃尔夫冈",
    function(self)
        return string.format("健康%+d,耐力%+d,体力%+d;健康效果提升至%d%%",
            self.data[1], self.data[2], self.data[3], self.data[4]*100)
    end,
    AssetUtil:MakeImg("minimap/minimap_data.xml", "wolfgang.png", true),
    nil,
    function(inst, cmp, id, self)
        inst.components.tp_player_attr:SetAttrRate("health", self.data[4])
        inst.components.tp_player_attr:AddAttrMod("health", self.data[1])
        inst.components.tp_player_attr:AddAttrMod("endurance", self.data[2])
        inst.components.tp_player_attr:AddAttrMod("stamina", self.data[3])
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {10, 10, 10, 1.4}),
}

local other_tree = {
    Skill("SKbeard_defense", "胡子",
    function(self)
        return string.format("防御%+d;长出的胡子会提高防御值", self.data[1])
    end,
    AssetUtil:MakeImg("beardhair"),
    nil,
    function(inst, cmp, id, self)
        inst.components.combat:AddDefenseMod(id, self.data[1])
        if inst.components.beard then
            inst:ListenForEvent("daycomplete", function(world, data)
                local cmp = inst.components.beard
                if not cmp.pause then
                    local n = cmp.daysgrowth
                    if cmp.callbacks[n] then
                        inst.components.combat:AddDefenseMod(id, n*2)
                    end
                end
            end, GetWorld())
        end
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {10}),
    Skill("SKfire_scroll_liker", "火魔法爱好",
    function(self)
        return string.format("法力%+d;你使用火卷轴后,恢复%d点理智", 
            self.data[1], self.data[2])
    end,
    AssetUtil:MakeImg("tp_scrolls2", "tp_scroll_fire_ball"),
    nil,
    function(inst, cmp, id, self)
        inst.components.tp_val_mana:AddMaxMod(id, self.data[1])
        inst:ListenForEvent("use_scroll", function(inst, data)
            local scroll_name = data.scroll.prefab
            if ScrollLibrary:GetDataKindById(scroll_name) == "fire" then
                inst.components.sanity:DoDelta(self.data[2])
            end
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {30, 10}),
    Skill("SKfire_scroll_master", "火魔法精通",
    function(self)
        return string.format("法力%+d;你的火卷轴造成的获得%d%%智力收益的伤害加成",
            self.data[1], self.data[2]*100)
    end,
    AssetUtil:MakeImg("tp_scrolls2", "tp_scroll_fire1"),
    nil,
    function(inst, cmp, id, self)
        inst.components.tp_val_mana:AddMaxMod(id, self.data[1])
        inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
            if EntUtil:in_stimuli(stimuli, "fire", "magic") then
                local amt = owner.components.tp_player_attr:GetAttrFactor("intelligence")
                damage = damage + amt*self.data[2]
            end
            return damage
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {50, 1}),
    Skill("SKcombat_blood", "战斗之血",
    function(self)
        return string.format("体力%+d;装备武器后,获得%d防御,和%d%%吸血",
            self.data[1], self.data[2], self.data[3]*100)
    end,
    AssetUtil:MakeImg("wathgrithrhat"),
    nil,
    function(inst, cmp, id, self)
        inst:ListenForEvent("equip", function(inst, data)
            if data.elsot == EQUIPSLOTS.HANDS then
                if data.item.components.weapon then
                    inst.components.combat:AddDefenseMod(id, self.data[2])
                    inst.components.combat:AddLifeStealRateMod(id, self.data[3])
                end
            end
        end)
    end, -- always
    function(inst, cmp, id, self)
        inst:ListenForEvent("unequip", function(inst, data)
            if data.elsot == EQUIPSLOTS.HANDS then
                if data.item.components.weapon then
                    inst.components.combat:RmDefenseMod(id)
                    inst.components.combat:RmLifeStealRateMod(id)
                end
            end
        end)
    end, -- once
    {5, 50, .25}),
    Skill("brute", "野蛮",
    function(self)
        return string.format("强壮%+d;普通攻击造成的伤害%+d", 
            self.data[1], self.data[2])
    end,
    AssetUtil:MakeImg("spear_wathgrithr"),
    nil,
    function(inst, cmp, id, self)
        inst.components.tp_player_attr:AddAttrMod("strengthen", self.data[1])
        inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
            if EntUtil:can_dmg_effect(stimuli) then
                damage = damage + self.data[2]
            end
            return damage
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {5, 20}),
    Skill("SKdesire_fight", "战斗渴望",
    function(self)
        return string.format("理智%+d;你因吸血恢复生命时,同时恢复理智,但效果只有%d%%",
            self.data[1], self.data[2]*100)
    end,
    AssetUtil:MakeImg("tp_icons2", "talent1"),
    nil,
    function(inst, cmp, id, self)
        inst.components.sanity:WgAddMaxSanityModifier(id, self.data[1])
        inst:ListenForEvent("life_steal", function(inst, data)
            if data.amount then
                inst.components.sanity:DoDelta(data.amount*self.data[2])
            end
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {50, .5}),
    Skill("library_wind", "书院来风",
    function(self)
        return string.format("法力恢复%+.2f;你使用1张风卷轴后,随机获得1张卷轴",
            self.data[1])
    end,
    AssetUtil:MakeImg("tp_scrolls2", "tp_scroll_wind2"),
    nil,
    function(inst, cmp, id, self)
        inst.components.tp_val_mana:AddRateMod(id, self.data[1])
        inst:ListenForEvent("use_scroll", function(inst, data)
            local scroll_name = data.scroll.prefab
            if ScrollLibrary:GetDataKindById(scroll_name) == "wind" then
                local scroll_name2 = ScrollLibrary:GetRandomIds(1)
                EntUtil:give_player_item(SpawnPrefab(scroll_name2), inst)
            end
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {.3}),
    Skill("wind_comfortable", "风系亲和",
    function(self)
        return string.format("体力%+d;你使用风卷轴后提升%d%%移速,持续%ds",
            self.data[1], self.data[2]*100, self.data[3])
    end,
    AssetUtil:MakeImg("tp_scrolls2", "tp_scroll_wind1"),
    nil,
    function(inst, cmp, id, self)
        inst.components.tp_player_attr:AddAttrMod("stamina", self.data[1])
        inst:ListenForEvent("use_scroll", function(inst, data)
            local scroll_name = data.scroll.prefab
            if ScrollLibrary:GetDataKindById(scroll_name) == "wind" then
                EntUtil:add_speed_mod(inst, self.data[2], self.data[3])
            end
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {3, .2, 60}),
    Skill("wind_caster", "风之魔导士",
    function(self)
        return string.format("智力+%d;你的风卷轴造成的伤害提升%d%%",
            self.data[1], self.data[2]*100)
    end,
    AssetUtil:MakeImg("tp_scrolls2", "tp_scroll_wind_ball"),
    nil,
    function(inst, cmp, id, self)
        inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
            if EntUtil:in_stimuli(stimuli, "wind", "magic") then
                damage = damage * (1 + self.data[2])
            end
            return damage
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {5, .3}),
    Skill("shadow_manipulator", "暗影操纵者",
    function(self)
        return string.format("暗抗%+d%%;你造成的暗影伤害增加%d%%",
            self.data[1]*100, self.data[2]*100)
    end,
    AssetUtil:MakeImg("researchlab3"),
    nil,
    function(inst, cmp, id, self)
        inst.components.combat:AddDmgTypeAbsorb("shadow", -self.data[1])
        inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
            if EntUtil:in_stimuli(stimuli, "shadow") then
                damage = damage * (1 + self.data[2])
            end
            return damage
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {.05, .2}),
    Skill("SKshadow_inflatrate", "暗影渗透",
    function(self)
        return string.format("法力%+d;你每使用1张暗影卷轴,技能cd-%ds", 
            self.data[1], self.data[2] )
    end,
    AssetUtil:MakeImg("ash"),
    nil,
    function(inst, cmp, id, self)
        inst.components.tp_val_mana:AddMaxMod(id, self.data[1])
        inst:ListenForEvent("use_scroll", function(inst, data)
            local scroll_name = data.scroll.prefab 
            local kind = ScrollLibrary:GetDataKindById(scroll_name)
            if kind == "shadow" then
                cmp:DoDelta(self.data[2])
            end
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {30, 10}),
    Skill("MrMuscle", "威猛先生",
    function(self)
        return string.format("生命%+d;普通攻击提升生命上限%d%%的伤害",
            self.data[1], self.data[2]*100 )
    end,
    AssetUtil:MakeImg("tp_icons2", "attr_health"),
    nil,
    function(inst, cmp, id, self)
        inst.components.health:WgAddMaxHealthModifier(id, self.data[1])
        inst.components.combat:WgAddCalcDamageFn(function(damage, owner, target, weapon, stimuli)
            if EntUtil:can_dmg_effect(stimuli) then
                local max = owner.components.health:GetMaxHealth()
                local amt = max * self.data[2]
                damage = damage * amt
            end
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {50, .03}),
    Skill("physical_training", "体能训练",
    function(self)
        return string.format("强壮%+d;你每拥有1点强壮系数,便%+d生命", 
            self.data[1], self.data[2] )
    end,
    AssetUtil:MakeImg("tp_icons2", "talent2"),
    nil,
    function(inst, cmp, id, self)
        inst:ListenForEvent("player_attr_update", function(inst, data)
            local strengthen = inst.components.tp_player_attr:GetAttrFactor("strengthen")
            local amt = self.data[2] * strengthen
            inst.components.health:WgAddMaxHealthModifier(id, amt)
        end)
        inst.components.tp_player_attr:AddAttrMod("strengthen", self.data[1])
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {5, 5}),
    -- 
    Skill("hollow", "六目",
        "你获得六目能量",
    AssetUtil:MakeImg("tp_icons2", "badge_31"),
    nil,
    function(inst, cmp, id, self)
        inst:AddComponent("tp_val_hollow")
        inst:DoTaskInTime(0, function()
            inst.components.tp_val_hollow:InitBadge()
        end)
    end, -- always
    function(inst, cmp, id, self)
    end, -- once
    {}),
    
}


local DataManager = require "extension/lib/data_manager"
local SkillTreeManager = DataManager("SkillTreeManager")
SkillTreeManager:AddDatas(player_tree, "player")
SkillTreeManager:AddDatas(other_tree, "other")

function SkillTreeManager:UnlockSkill(id, inst, skill_data)
    skill_data = skill_data or self:GetDataById(id)
    assert(skill_data~=nil, string.format("%s's skill tree don't have skill %s", inst.prefab, id))
    skill_data:Unlock(inst)
end

function SkillTreeManager:TriggerSkill(id, inst, skill_data)
    skill_data = skill_data or self:GetDataById(id)
    assert(skill_data~=nil, string.format("%s's skill tree don't have skill %s", inst.prefab, id))
    skill_data:Trigger(inst)
end

function SkillTreeManager:ForeverEffectSkill(id, inst, skill_data)
    skill_data = skill_data or self:GetDataById(id)
    assert(skill_data~=nil, string.format("%s's skill tree don't have skill %s", inst.prefab, id))
    skill_data:ForeverEffect(inst)
end

function SkillTreeManager:LoadSkill(id, inst, skill_data)
    -- 游戏开始时, inst.prefab尚未添加
    skill_data = skill_data or self:GetDataById(id)
    assert(skill_data~=nil, string.format("%s's skill tree don't have skill %s", inst.prefab, id))
    skill_data:Unlock(inst)
    skill_data:Trigger(inst)
end

function SkillTreeManager:PlayerSkillTree2LevelFn(name)
    local level_fn = function(inst, level, old_level)
        local datas = SkillTreeManager:GetDatasByKind(name)
        for k, v in pairs(datas) do
            local id = v:GetId()
            local a1 = string.find(id, "P")
            local a2 = string.find(id, "L")
            if a1 and a2 then
                local phase = tonumber(string.sub(id, a1+1, a2-1))
                local data_level = tonumber(string.sub(id, a2+1, -1))
                if level>=data_level and old_level<data_level then
                    v:Trigger(inst)
                end
            end
        end
    end
    local level_up_fn = function(inst, level)
        local datas = SkillTreeManager:GetDatasByKind(name)
        for k, v in pairs(datas) do
            local id = v:GetId()
            local a1 = string.find(id, "P")
            local a2 = string.find(id, "L")
            if a1 and a2 then
                local phase = tonumber(string.sub(id, a1+1, a2-1))
                local data_level = tonumber(string.sub(id, a2+1, -1))
                if level==data_level then
                    v:ForeverEffect(inst)
                    v:Unlock()
                    inst.components.tp_skill_tree:AddId(id)
                end
            end
        end
    end
    return level_fn, level_up_fn
end

Sample.SkillTreeManager = SkillTreeManager