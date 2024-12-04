local WgBadge = require "extension/uis/wg_badge"
local AssetUtil = require "extension/lib/asset_util"
local AssetMaster = Sample.AssetMaster

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
]]
local function SkillButton(id, name, desc, Uimg, mana, time, fn)
    local self = SkillButtonData()
    -- 不能在这里解析
    self.id = id
    self.Uimg = Uimg
    self.name = name
    self.desc = desc
    self.mana = mana
    self.time = time
    self.fn = fn
    return self
end

local Button = Class(WgBadge, function(self, owner)
    WgBadge._ctor(self, owner)
    -- owner.skill_button = self.anim
    self.anim:GetAnimState():SetMultColour(210/255, 105/255, 30/255, 1)
end)

function SkillButtonData:GetButton(owner)
    local widget = Button(owner)
    local atlas, image = AssetUtil:GetImage(self.Uimg)
    widget:SetImageButton(atlas, image, function(player)
        if player.components.tp_val_mana:GetCurrent()>=self.mana then
            player.components.tp_player_button:Trigger()
            self.fn(player)
            player.components.tp_val_mana:DoDelta(-self.mana)
        end
    end)
    widget:SetString(self.name)
    widget:SetDescription(self.desc)
    widget.id = self.id
    return widget
end

function SkillButtonData:GetId()
    return self.id
end

local buttons = {
SkillButton("wilson", "露营", 
    -- "消耗20法力,生成一个威尔逊的工作台,可以制造威尔逊的小发明", 
    "消耗20法力,生成一个临时帐篷", 
    AssetMaster:GetUimg("tp_desk"), 
    20,
    90,
    function(inst)
        -- local desk = SpawnPrefab("tp_table_wilson")
        -- local desk = SpawnPrefab("tent")
        -- desk.Transform:SetPosition(inst:GetPosition():Get())
        local tent = SpawnPrefab("tent")
        tent.persists = false
        tent:DoTaskInTime(60, tent.Remove)
        SpawnPrefab("collapse_big").Transform:SetPosition(inst:GetPosition():Get())
    end
),
SkillButton("wathgrithr", "战前准备",
    "消耗20法力,获得一个女武神的战矛,女武神的头盔",
    AssetUtil:MakeImg("wathgrithrhat"),
    20,
    60,
    function(inst)
        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        local spear = SpawnPrefab("tp_spear_wathgrithr")
        local helm = SpawnPrefab("tp_hat_wathgrithr")
        if weapon then
            inst.components.inventory:GiveItem(spear)
        else
            inst.components.inventory:Equip(spear)
        end
        if hat then
            inst.components.inventory:GiveItem(helm)
        else
            inst.components.inventory:Equip(helm)
        end
    end
),
SkillButton("wickerbottom", "小帮手",
    "消耗20法力,随机获得一个工具",
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
SkillButton("wolfgang", "营养餐", 
    "消耗20法力,获得三个食材,食用后能增加一项三围上限(各个食物的增加的上限不同,如果吃了一个提升高的和一个提升低的,按提升高的算)",
    AssetUtil:MakeImg("jammypreserves"),
    20,
    200,
    function(inst)
        local veggie = {
            "sweet_potato", "corn", "coffeebeans", "cave_banana", "pomegranate", "watermelon", 
            "cactus_meat", "dragonfruit", "carrot", "berries", "durian", "aloe", "pumpkin", 
            "eggplant", "asparagus", "radish", 
        }
        for i = 1, 3 do
            local n = math.random(#veggie)
            local food = SpawnPrefab("tp_wolfgang_"..veggie[n])
            table.remove(veggie, n)
            inst.components.inventory:GiveItem(food)
        end
    end
),
}

local DataManager = require "extension/lib/data_manager"
local SkillButtonManager = DataManager("SkillButtonManager")
SkillButtonManager:AddDatas(buttons)

Sample.SkillButtonManager = SkillButtonManager