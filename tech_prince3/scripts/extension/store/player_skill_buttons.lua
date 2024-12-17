local WgBadge = require "extension/uis/wg_badge"
local AssetUtil = require "extension/lib/asset_util"
local EntUtil = require "extension/lib/ent_util"
local AssetMaster = Sample.AssetMaster
local BuffManager = Sample.BuffManager
local ScrollManager = Sample.ScrollManager

local SkillButtonData = Class(function(self)
end)

--[[
创建技能按钮类  
(WgBadge) 返回这个类  
id (String) 标识  
name (String) 技能名  
desc (String) 技能描述  
Uimg (Img) 图片资源  
mana (number) 法力需求  
time (number) 技能冷却时间
fn (func) 技能效果函数  
init (func) 技能初始化函数  
]]
local function SkillButton(id, name, desc, Uimg, mana, time, fn, init)
    local self = SkillButtonData()
    -- 不能在这里解析
    self.id = id
    self.Uimg = Uimg
    self.name = name
    self.desc = desc
    self.mana = mana
    self.time = time
    self.fn = fn
    self.init = init
    return self
end

local Button = Class(WgBadge, function(self, owner)
    WgBadge._ctor(self, owner)
    -- owner.skill_button = self.anim
    self.anim:GetAnimState():SetMultColour(210/255, 105/255, 30/255, 1)
    self.priority = -3
end)

function SkillButtonData:GetButton(owner)
    local widget = Button(owner)
    local atlas, image = AssetUtil:GetImage(self.Uimg)
    widget:SetImageButton(atlas, image, function(player)
        -- local mana = self.mana
        -- if player.components.tp_val_hollow
        -- and player.components.tp_val_hollow:CanReduceManaCost() then
        --     mana = mana * .2
        -- end
        -- if player.components.tp_val_mana:GetCurrent()>=self.mana then
        --     player.components.tp_player_button:Trigger()
        --     self.fn(player)
        --     player.components.tp_val_mana:DoDelta(-mana)
        --     if player.components.tp_val_hollow
        --     and player.components.tp_val_hollow:CanReduceManaCost() then
        --         player.components.tp_val_hollow:EffectReduceManaCost()
        --     end
        -- end
        player.components.tp_player_button:Click()
    end)
    widget:SetString(self.name)
    local desc = self.desc
    if self.mana then
        desc = string.format("消耗%d法力,%s", self.mana, self.desc)
    end
    widget:SetDescription(desc)
    widget.id = self.id
    return widget
end

function SkillButtonData:GetId()
    return self.id
end

local buttons = {
SkillButton("wilson", "发明创造", 
    -- "消耗20法力,生成一个威尔逊的工作台,可以制造威尔逊的小发明", 
    "生成一个临时工作台", 
    AssetMaster:GetUimg("tp_wilson_table"), 
    20,
    90,
    function(inst)
        local obj = SpawnPrefab("tp_wilson_table")
        -- local obj = SpawnPrefab("tent")
        obj.Transform:SetPosition(inst:GetPosition():Get())
        -- local obj = SpawnPrefab("tent")
        obj.persists = false
        obj:DoTaskInTime(60, obj.Remove)
        SpawnPrefab("collapse_big").Transform:SetPosition(inst:GetPosition():Get())
    end
),
SkillButton("wilson2", "才思涌现",
    "被动:你每造成200点魔法伤害,随机获得1个卷轴",
    AssetMaster:GetUimg("tp_desk"),
    0,
    200,
    function(inst)
    end,
    function(inst, cmp, id)
        cmp:Stop()
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = inst.components.combat:WgAddOnHitFn(function(damage, inst, target, weapon, stimuli)
                if EntUtil:in_stimuli(stimuli, "magic") then
                    local n = cmp[id.."_val"] or 0
                    n = n + damage
                    if n >= 200 then
                        n = 0
                        local scroll_name = ScrollManager:GetRandomIds(1)
                        EntUtil:give_player_item(SpawnPrefab(scroll_name), inst)
                    end
                    cmp[id.."_val"] = n
                    cmp:SetPercent(n/200)
                end
            end)
        -- else
            -- inst.components.combat:WgRemoveOnHitFn(cmp[id.."_fn"])
            -- cmp[id.."_fn"] = nil
            -- cmp[id.."_val"] = nil
        end
    end
),
SkillButton("wathgrithr", "战前准备",
    "获得一个女武神的战矛,女武神的头盔",
    AssetUtil:MakeImg("wathgrithrhat"),
    20,
    60,
    function(inst)
        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        local spear = SpawnPrefab("spear_wathgrithr")
        spear.components.tp_exist_time:SetTime(80)
        local helm = SpawnPrefab("wathgrithrhat")
        helm.components.tp_exist_time:SetTime(80)
        inst.components.inventory:GiveItem(spear, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
        inst.components.inventory:GiveItem(helm, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
        if weapon then
        else
            inst.components.inventory:Equip(spear)
        end
        if hat then
        else
            inst.components.inventory:Equip(helm)
        end
    end
),
SkillButton("willow", "火焰上跳舞",
    "进入灼烧状态,增加你的火魔法伤害",
    AssetUtil:MakeImg("tp_scrolls2", "tp_scroll_fire1"),
    20,
    100,
    function(inst)
        BuffManager:AddBuff(inst, "fire")
        BuffManager:AddBuff(inst, "willow_skill")
    end
),
SkillButton("waxwell", "习得暗影",
    "获得一个暗影波",
    AssetUtil:MakeImg("tp_scrolls2", "tp_scroll_shadow_ball"),
    20,
    100,
    function(inst)
        EntUtil:give_player_item(SpawnPrefab("tp_scroll_shadow_ball"), inst)
    end
),
SkillButton("waxwell2", "暗术共鸣",
    "获得一个暗影波;被动:你使用一个暗卷轴时,此技能冷却-40s",
    AssetUtil:MakeImg("tp_scrolls2", "tp_scroll_shadow_ball"),
    10,
    100,
    function(inst)
        EntUtil:give_player_item(SpawnPrefab("tp_scroll_shadow_ball"), inst)
    end,
    function(inst, cmp, id)
        if cmp[id.."_fn"] == nil then
            cmp[id.."_fn"] = EntUtil:listen_for_event(inst, "use_scroll", function(inst, data)
                local scroll_name = data.scroll.prefab 
                local kind = ScrollManager:GetDataKindById(scroll_name)
                if kind == "shadow" then
                    cmp:DoDelta(40)
                end
            end)
        end
    end
),
SkillButton("wickerbottom", "小帮手",
    "随机获得一个工具",
    AssetUtil:MakeImg("axe"),
    20,
    180,
    function(inst)
        local tools = {"axe", "pickaxe", "machete", "cane"}
        local name = tools[math.random(#tools)]
        local tool = SpawnPrefab("tp_"..name.."_wickerbottom")
        inst.components.inventory:GiveItem(tool)
    end
),
SkillButton("wolfgang", "罐头订单", 
    "获取一个食品罐头",
    AssetUtil:MakeImg("tunacan"),
    20,
    200,
    function(inst)
        EntUtil:give_player_item(SpawnPrefab("tp_wolfgang_can"), inst)
    end
),
--
SkillButton("hollow_evade", "无量空洞",
    "开启/关闭无量空洞状态(必须要有六目才能使用)",
    AssetUtil:MakeImg("tp_icons2", "hollow_evade"),
    4,
    4,
    function(inst)
        if inst.components.tp_val_hollow then
            if BuffManager:HasBuff(inst, "hollow_evade") then
                BuffManager:ClearBuff(inst, "hollow_evade")
            else
                BuffManager:AddBuff(inst, "hollow_evade")
            end 
        end
    end
),
SkillButton("tp_cookpot_demon", "伏魔御厨房",
    "召唤一个伏魔御厨锅,伏魔烹饪锅会不断斩击周围的敌人",
    AssetUtil:MakeImg("tp_icons2", "tp_cookpot_demon"),
    10,
    100,
    function(inst)
        local cookpot = SpawnPrefab("tp_cookpot_demon")
        cookpot.Transform:SetPosition(inst:GetPosition():Get())
        cookpot.owner = inst
        cookpot:onbuilt()
    end
),
}

local DataManager = require "extension/lib/data_manager"
local SkillButtonManager = DataManager("SkillButtonManager")
SkillButtonManager:AddDatas(buttons)

Sample.SkillButtonManager = SkillButtonManager