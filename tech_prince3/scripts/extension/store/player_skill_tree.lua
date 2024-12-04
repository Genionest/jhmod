local AssetUtil = require "extension/lib/asset_util"
local EntUtil = require "extension/lib/ent_util"
local Util = require "extension/lib/wg_util"
local AssetMaster = Sample.AssetMaster
local Info = Sample.Info

local SkillData = Class(function(self, data)
end)

--[[
创建技能类
(SkillData) 返回
id (String) 标识
name (String) 名字
desc (String) 描述
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

function SkillData:ForverEffect(owner)
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
    if self:IsLock() then
        local a1 = string.find(self.id, "P")
        local a2 = string.find(self.id, "L")
        if a1 and a2 then
            local phase = string.sub(self.id, a1+1, a2-1)
            local level = string.sub(self.id, a2+1, -1)
            return "阶段"..phase.."等级"..level.."解锁"
        end
    else
        return Util:SplitSentence(self.desc, nil, true)
    end
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
    Skill("wilson", "科学家",
        "获得15点智力,15点专注\n威尔逊长出的胡子会提高防御值",
    AssetUtil:MakeImg("minimap/minimap_data.xml", "wilson.png", true),
    nil,
    function(inst, self)
    end, -- always
    function(inst, self)
        inst.components.tp_player_attr:AddAttrMod("attention", 15)
        inst.components.tp_player_attr:AddAttrMod("intelligence", 15)
        inst.components.tp_player_attr:UpdateAttr()
    end, -- once
    nil),
    Skill("hollow", "六目",
        "你获得六目值",
    AssetUtil:MakeImg("tp_icons2", "badge_31"),
    nil,
    function(inst, self)
        inst:AddComponent("tp_val_hollow")
        inst:DoTaskInTime(0, function()
            inst.components.tp_val_hollow:InitBadge()
        end)
    end, -- always
    function(inst, self)
    end, -- once
    {}),
}

-- local wilson_tree = {
-- Skill("skill_btn", "天才发明家", 
--     "获得技能\"发明创造\"", 
--     AssetMaster:GetUimg("tp_desk"), 
--     nil, 
--     function(inst)
--     end
-- ),
-- Skill("P1L3", "成熟的科学家",
--     "威尔逊可以长胡子了",
--     AssetUtil:MakeImg("beardhair"), 
--     nil, 
--     function(inst)
--         if inst.components.beard == nil then
--             inst.beard_fn(inst)
--         end
--     end
-- ),
-- Skill("P1L6", "助学金",
--     string.format("获得%d呼噜币", Info.Character.wilson.Phase1RewardOinc100*100),
--     AssetUtil:MakeImg("oinc"), 
--     nil, 
--     function(inst)
--     end,
--     function(inst)
--         local coin = SpawnPrefab("oinc100")
--         coin.components.stackable:SetStackSize(Info.Character.wilson.Phase1RewardOinc100)
--         inst.components.inventory:GiveItem(coin)
--         inst.components.tp_skill_tree:ShowSkillDesc()
--     end
-- ),
-- skill_grow("wilson", 2),
-- Skill("P2L12", "风行者", 
--     string.format("每提升100%%的移速，提升%d%%攻击", 
--         Info.Character.wilson.SpeedDmgMod*100),
--     AssetUtil:MakeImg("coffee"), 
--     nil, 
--     function(inst)
--         local CalcDamage = inst.components.combat.CalcDamage
--         function inst.components.combat:CalcDamage(target, weapon, multiplier)
--             multiplier = multiplier or 1
--             local base = inst.components.locomotor.runspeed
--             local total = inst.components.locomotor:GetRunSpeed()
--             local p = total/base
--             if p>1 then
--                 multiplier = multiplier+(p-1)*Info.Character.wilson.SpeedDmgMod
--             end
--             return CalcDamage(self, target, weapon, multiplier)
--         end
--     end
-- ),
-- skill_grow("wilson", 3),
-- Skill("P3L22", "见习研究员",
--     string.format("自带一本科技"),
--     AssetUtil:MakeImg("researchlab"), 
--     nil,
--     function(inst)
--         inst.components.builder.science_bonus = 1
--     end
-- ),
-- Skill("P3L23", "见习术士",
--     string.format("自带魔法一本科技"),
--     AssetUtil:MakeImg("researchlab4"), 
--     nil,
--     function(inst)
--         inst.components.builder.magic_bonus = 1
--     end
-- ),
-- }

-- local wathgrithr_tree = {
-- Skill("skill_btn", "天生的格斗家",
--     "获得技能\"战前准备\"",
--     AssetUtil:MakeImg("wathgrithrhat"), 
--     nil, 
--     function(inst)
--     end
-- ),
-- Skill("P1L3", "装备精良",
--     "解锁专属制造",
--     AssetUtil:MakeImg("spear_wathgrithr"), 
--     nil, 
--     function(inst)
--         if not inst:HasTag("wathgrithr") then
--             inst:AddTag("wathgrithr")
--         end
--     end
-- ),
-- Skill("P1L5", "战斗技艺",
--     string.format("获得%d%%的吸血和%d%%的防御、穿透、命中加成", 
--         Info.Character.wathgrithr.LifeStealRate*100, Info.Character.wathgrithr.Phase1CombatAttrMod*100),
--     AssetUtil:MakeImg("hambat"), 
--     nil, 
--     function(inst)
--         inst.components.combat:AddPenetrateMod("skill", Info.Character.wathgrithr.Phase1CombatAttrMod)
--         inst.components.combat:AddHitRateMod("skill", Info.Character.wathgrithr.Phase1CombatAttrMod)
--         inst.components.combat:AddDefenseMod("skill", Info.Character.wathgrithr.Phase1CombatAttrMod)
--         inst.components.combat:AddLifeStealRateMod("skill", Info.Character.wathgrithr.LifeStealRate)
--     end
-- ),
-- Skill("P1L8", "战神之子",
--     string.format("装带饰品阿瑞斯的加护"),
--     AssetMaster:GetUimg("ak_ornament_festivalevents3"),
--     nil, 
--     function(inst)
--     end,
--     function(inst)
--         inst.components.tp_ornament:TakeOrnament("ak_ornament_festivalevents3")
--         inst.components.tp_ornament:EffectOrnament("ak_ornament_festivalevents3")
--     end
-- ),
-- Skill("P2L11", "成长",
--     string.format("饥饿速度增加%d%%, 增加%d饥饿上限", 
--         Info.Character.wathgrithr.Phase2HungerRate*100,
--         Info.Character.wathgrithr.Phase2HungerMod),
--     AssetUtil:MakeImg("pumpkincookie"), 
--     nil, 
--     function(inst)
--         inst.components.hunger:WgAddMaxHungerModifier("skill", Info.Character.wathgrithr.Phase2HungerMod)
--         EntUtil:add_hunger_mod(inst, "skill", Info.Character.wathgrithr.Phase2HungerRate)
--     end,
--     function(inst)
--         inst.components.hunger:WgAddMaxHungerModifier("skill", Info.Character.wathgrithr.Phase2HungerMod, true)
--         inst.components.tp_ornament:LoseOrnament("ak_ornament_festivalevents3")
--         inst.components.tp_ornament:UneffectOrnament("ak_ornament_festivalevents3")
--     end
-- ),
-- Skill("P2L12", "肉食者",
--     string.format("只能吃肉,增加%d生命上限", 
--         Info.Character.wathgrithr.Phase2HealthMod),
--     AssetUtil:MakeImg("meat"), 
--     nil, 
--     function(inst)
--         inst.components.eater:SetCarnivore(true)
--         inst.components.health:WgAddMaxHealthModifier("skill", Info.Character.wathgrithr.Phase2HealthMod)
--     end,
--     function(inst)
--         inst.components.health:WgAddMaxHealthModifier("skill", Info.Character.wathgrithr.Phase2HealthMod, true) 
--     end
-- ),
-- Skill("P2L13", "战斗渴望",
--     string.format("杀死怪物回复理智和生命"),
--     AssetUtil:MakeImg("guacamole"), 
--     nil, 
--     function(inst)
--         inst:ListenForEvent("entity_death", function(wrld, data) inst.onkill(inst, data) end, GetWorld())
--     end
-- ),
-- skill_grow("wathgrithr", 3),
-- Skill("P3L22", "精致技艺",
--     string.format("防御、穿透、命中加成提升至%d%%", 
--         Info.Character.wathgrithr.Phase3CombatAttrMod*100),
--     AssetUtil:MakeImg("ruins_bat"), 
--     nil, 
--     function(inst)
--         inst.components.combat:AddPenetrateMod("skill", Info.Character.wathgrithr.Phase3CombatAttrMod)
--         inst.components.combat:AddHitRateMod("skill", Info.Character.wathgrithr.Phase3CombatAttrMod)
--         inst.components.combat:AddDefenseMod("skill", Info.Character.wathgrithr.Phase3CombatAttrMod)
--     end
-- ),
-- }

-- local wickerbottom_tree = {
-- Skill("skill_btn", "勤劳的管理员",
--     "获得技能\"小帮手\"",
--     AssetUtil:MakeImg("axe"),
--     nil,
--     function(inst)end
-- ),
-- Skill("P1L3", "博览群书",
--     "自带一本科技",
--     AssetUtil:MakeImg("researchlab"),
--     nil,
--     function(inst)
--         inst.components.builder.science_bonus = 1
--     end
-- ),
-- --[[
-- local c = GetPlayer().components.builder.custom_tabs
-- for k, v in pairs(c) do
--     for k2, v2 in pairs(v) do
--         print(k2, v2)
--     end
-- end
-- ]]
-- -- Skill("P1L3", "造纸术",
-- --     "可以使用竹子制造纸",
-- --     AssetUtil:MakeImg("papyrus"),
-- --     nil,
-- --     function(inst, self)
-- --         if not inst:HasTag(self.id) then
-- --             inst:AddTag(self.id)
-- --             local recipe = Recipe("papyrus", {Ingredient("bamboo", 1)}, RECIPETABS.REFINE, TECH.NONE, RECIPE_GAME_TYPE.COMMON, nil, nil, nil, 4)
-- --             recipe.sortkey = 1
-- --         end
-- --     end
-- -- ),
-- Skill("P1L5", "赠书清单",
--     "获得5本书",
--     AssetUtil:MakeImg("book_brimstone"),
--     nil,
--     function(inst)
--     end,
--     function(inst)
--         inst.give_gift(inst, "book_birds", 1)
--         inst.give_gift(inst, "book_gardening", 1)
--         inst.give_gift(inst, "book_sleep", 1)
--         inst.give_gift(inst, "book_brimstone", 1)
--         if SaveGameIndex:IsModeShipwrecked() then
--             inst.give_gift(inst, "book_meteor", 1)
--         else
--             inst.give_gift(inst, "book_tentacles", 1)
--         end
--     end
-- ),
-- Skill("P1L8", "赠书清单2",
--     "获得10本书",
--     AssetUtil:MakeImg("book_sleep"),
--     nil,
--     function(inst)
--     end,
--     function(inst)
--         inst.give_gift(inst, "book_birds", 2)
--         inst.give_gift(inst, "book_gardening", 2)
--         inst.give_gift(inst, "book_sleep", 2)
--         inst.give_gift(inst, "book_brimstone", 2)
--         if SaveGameIndex:IsModeShipwrecked() then
--             inst.give_gift(inst, "book_meteor", 2)
--         else
--             inst.give_gift(inst, "book_tentacles", 2)
--         end
--     end
-- ),
-- skill_grow("wickerbottom", 2),
-- Skill("P2L12", "藏书库",
--     "解锁专属制造",
--     AssetUtil:MakeImg("book_birds"),
--     nil,
--     function(inst, self)
--         if not inst:HasTag("wickerbottom") then
--             inst:AddTag("wickerbottom")
--         end
--     end
-- ),
-- Skill("P2L13", "失眠多梦",
--     string.format("失眠,理智上限提升%d", 
--         Info.Character.wickerbottom.Phase2SanityMod),
--     AssetUtil:MakeImg("bedroll_straw"),
--     nil,
--     function(inst)
--         inst.components.sanity:WgAddMaxSanityModifier("skill", Info.Character.wickerbottom.Phase2SanityMod)
--         if not inst:HasTag("insomniac") then
--             inst:AddTag("insomniac") 
--         end
--     end,
--     function(inst)
--         inst.components.sanity:WgAddMaxSanityModifier("skill", Info.Character.wickerbottom.Phase2SanityMod, true)
--     end
-- ),
-- skill_grow("wickerbottom", 3),
-- Skill("P3L22", "老胃病",
--     string.format("不适应不新鲜的食物,饥饿上限提升%d", 
--         Info.Character.wickerbottom.Phase3HungerMod),
--     AssetUtil:MakeImg("wetgoop"),
--     nil,
--     function(inst)
--         inst.components.sanity:WgAddMaxSanityModifier("skill", Info.Character.wickerbottom.Phase3SanityMod)
--         EntUtil:add_sanity_mod(inst, "skill", Info.Character.wickerbottom.Phase3SanityRate)
--     end,
--     function (inst)
--         inst.components.sanity:WgAddMaxSanityModifier("skill", Info.Character.wickerbottom.Phase3SanityMod, true)
--     end
-- ),
-- }

-- local wolfgang_tree = {
-- Skill("skill_btn", "健美选手",
--     "获得技能\"营养餐\"",
--     AssetUtil:MakeImg("carrot"),
--     nil,
--     function(inst)end
-- ),
-- Skill("P1L3", "强健体魄",
--     string.format("获得%d%%额外生命收益", Info.Character.wolfgang.NormalRecoverRate*100),
--     AssetUtil:MakeImg("bandage"),
--     nil,
--     function(inst)
--         inst.components.health:AddRecoverRateMod("skill", Info.Character.wolfgang.NormalRecoverRate)
--     end
-- ),
-- Skill("P1L5", "大力士",
--     string.format("饥饿会影响多项属性(包括生命回复收益，最低%d%%, 最高%d%%)", 
--         Info.Character.wolfgang.WimpyRecoverRate*100, Info.Character.wolfgang.MightyRecoverRate*100),
--     AssetUtil:MakeImg("marble"),
--     nil,
--     function(inst, self)
--         inst.applymightiness(inst)
--         EntUtil:listen_for_event(inst, "hungerdelta", inst.onhungerchange)
--     end
-- ),
-- skill_grow("wolfgang", 2),
-- Skill("P2L12", "胆小",
--     string.format("变得胆小, 增加%d理智上限",
--         Info.Character.wolfgang.Phase2SanityMod),
--     AssetUtil:MakeImg("cactus_meat"),
--     nil,
--     function(inst)
--         inst.components.sanity:WgAddMaxSanityModifier("skill", Info.Character.wolfgang.Phase3SanityMod)
--         inst.components.sanity.night_drain_mult = 1.1
--         inst.components.sanity.neg_aura_mult = 1.1
--     end,
--     function(inst)
--         inst.components.sanity:WgAddMaxSanityModifier("skill", Info.Character.wolfgang.Phase3SanityMod, true)
--     end
-- ),
-- Skill("P2L13", "强健心脏",
--     string.format("获得%d%%额外生命回复, 生命值越低, 提升越高, 最多达到%d%%", 
--         Info.Character.wolfgang.Phase2RecoverRateMin*100,
--         Info.Character.wolfgang.Phase2RecoverRateMax*100
--     ),
--     AssetUtil:MakeImg("butterflymuffin"),
--     nil,
--     function(inst)
--         local fn = EntUtil:listen_for_event(inst, "healthdelta", function(inst, data)
--             local min = Info.Character.wolfgang.Phase2RecoverRateMin
--             local max = Info.Character.wolfgang.Phase2RecoverRateMax
--             local p = inst.components.health:GetPercent()
--             local rate = min+(max-min)*(1-p)
--             inst.components.health:AddRecoverRateMod("P2L13", rate)
--         end)
--     end
-- ),
-- skill_grow("wolfgang", 3),
-- Skill("P3L22", "马力全开",
--     string.format("饥饿速度增加%d%%，获得的额外生命回复提升至%d%%", 
--         Info.Character.wolfgang.Phase3HungerRate*100, 
--         Info.Character.wolfgang.Phase3RecoverRate*100),
--     AssetUtil:MakeImg("cork_bat"),
--     nil,
--     function(inst)
--         EntUtil:add_hunger_mod(inst, "tp_level0", Info.Character.wolfgang.Phase3HungerRate)
--         inst.components.health:AddRecoverRateMod("tp_level2", Info.Character.wolfgang.Phase3RecoverRate)
--     end
-- ),
-- }

local DataManager = require "extension/lib/data_manager"
local SkillTreeManager = DataManager("SkillTreeManager")
SkillTreeManager:AddDatas(player_tree, "player")
-- SkillTreeManager:AddDatas(wilson_tree, "wilson")
-- SkillTreeManager:AddDatas(wathgrithr_tree, "wathgrithr")
-- SkillTreeManager:AddDatas(wickerbottom_tree, "wickerbottom")
-- SkillTreeManager:AddDatas(wolfgang_tree, "wolfgang")

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

function SkillTreeManager:ForverEffectSkill(id, inst, skill_data)
    skill_data = skill_data or self:GetDataById(id)
    assert(skill_data~=nil, string.format("%s's skill tree don't have skill %s", inst.prefab, id))
    skill_data:ForverEffect(inst)
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
                    v:ForverEffect(inst)
                    v:Unlock()
                    inst.components.tp_skill_tree:AddId(id)
                end
            end
        end
    end
    return level_fn, level_up_fn
end

Sample.SkillTreeManager = SkillTreeManager