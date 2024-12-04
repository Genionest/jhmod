local AssetUtil = require "extension/lib/asset_util"
local EntUtil = require "extension/lib/ent_util"
local Util = require "extension.lib.wg_util"
local AssetMaster = Sample.AssetMaster

local OrnamentData = Class(function(self)
end)

--[[
生成饰品数据类  
(OrnamentData) 返回这个类  
id (string) 标识  
name (string) 名字  
desc (string) 描述  
take (function) 获得时函数  
lose (function) 失去时函数  
data (table/number) 数据  
no_click (bool) 是否不可点击卸下  
]]
local function Ornament(id, name, desc, take, lose, data, no_click)
    local self = OrnamentData()
    self.id = id
    self.name = name
    self.desc = desc
    self.take = take
    self.lose = lose
    self.data = data
    self.no_click = no_click
    return self
end

function OrnamentData:GetId()
    return self.id
end

function OrnamentData:GetName()
    return Util:SplitSentence(self.name, 5, true)
end

function OrnamentData:GetDescription()
    local str = self.desc(self.data)
    return Util:SplitSentence(str, nil, true)
end

function OrnamentData:GetImage()
    if self:IsNone() then
        local Uimg = AssetUtil:MakeImg("amulet")
        return AssetUtil:GetImage(Uimg)
    else
        return AssetMaster:GetImage(self.id)
    end
end

function OrnamentData:IsNone()
    return self.id == "none"
end

function OrnamentData:IsDisable()
    return self.no_click
end

function OrnamentData:Take(owner)
    self.take(owner, self.id, self.data)
end

function OrnamentData:Lose(owner)
    self.lose(owner, self.id, self.data)
    owner.components.tp_ornament:LoseOrnament(self.id)
    local item = SpawnPrefab(self.id)
    owner.components.inventory:GiveItem(item)
end

local ornaments = {
Ornament("none",
    "",
    function()
        return ""
    end,
    function()
    end,
    function()
    end,
    nil,
    true
),
Ornament("ak_ornament_plain1", 
    "生命饰品",
    function(data)
        return string.format("增加%d生命上限", data)
    end,
    function(inst, id, data)
        inst.components.health:WgAddMaxHealthModifier(id, data, true)
    end,
    function(inst, id, data)
        inst.components.health:WgRemoveMaxHealthModifier(id, true)
    end,
    75
),
Ornament("ak_ornament_plain2", 
    "理智饰品",
    function(data)
        return string.format("增加%d理智上限", data)
    end,
    function(inst, id, data)
        inst.components.sanity:WgAddMaxSanityModifier(id, data, true)
    end,
    function(inst, id, data)
        inst.components.sanity:WgRemoveMaxSanityModifier(id, true)
    end,
    75
),
Ornament("ak_ornament_plain3", 
    "饱食饰品",
    function(data)
        return string.format("增加%d饥饿上限", data)
    end,
    function(inst, id, data)
        inst.components.hunger:WgAddMaxHungerModifier(id, data, true)
    end,
    function(inst, id, data)
        inst.components.hunger:WgRemoveMaxHungerModifier(id, true)
    end,
    75
),
Ornament("ak_ornament_plain4",
    "力量饰品",
    function(data)
        return string.format("增加%d%%攻击", data*100)
    end,
    function(inst, id, data)
        EntUtil:add_damage_mod(inst, id, data)
    end,
    function(inst, id, data)
        EntUtil:rm_damage_mod(inst, id)
    end,
    .1
),
Ornament("ak_ornament_plain5",
    "敏捷饰品",
    function(data)
        return string.format("增加%d%%移速", data*100)
    end,
    function(inst, id, data)
        EntUtil:add_speed_mod(inst, id, data)
    end,
    function(inst, id, data)
        EntUtil:rm_speed_mod(inst, id)
    end,
    .1
),
Ornament("ak_ornament_plain6",
    "智慧饰品",
    function(data)
        return string.format("降低%d%%理智衰减速度", data*100)
    end,
    function(inst, id, data)
        local mult = inst.components.sanity.dapperness_mult
        inst.components.sanity.dapperness_mult = mult-data
    end,
    function(inst, id, data)
        local mult = inst.components.sanity.dapperness_mult
        inst.components.sanity.dapperness_mult = mult+data
    end,
    .35
),
Ornament("ak_ornament_plain7",
    "锋利饰品",
    function(data)
        return string.format("增加%d穿甲", data)
    end,
    function(inst, id, data)
        inst.components.combat:AddPenetrateMod(id, data)
    end,
    function(inst, id, data)
        inst.components.combat:RmPenetrateMod(id)
    end,
    10
),
Ornament("ak_ornament_plain8",
    "贪婪饰品",
    function(data)
        return string.format("如果你同时装备了贪婪饰品和欲望饰品,你有%d%%的几率双倍掉落,你获得的经验增加%d%%", 
            data*100, data*100)
    end,
    function(inst, id, data)
        inst:AddTag("plain8")
        if inst:HasTag("plain8") and inst:HasTag("plain9") then
            local lucky = Sample.LUCKY
            lucky = lucky+data
            Sample.LUCKY = lucky
        end
    end,
    function(inst, id, data)
        inst:RemoveTag("plain8")
        local lucky = Sample.LUCKY
        lucky = lucky-data
        Sample.LUCKY = lucky
    end,
    .1
),
Ornament("ak_ornament_plain9",
    "欲望饰品",
    function(data)
        return string.format("如果你同时装备了贪婪饰品和欲望饰品,你有%d%%的几率双倍掉落,你获得的经验增加%d%%", 
            data*100, data*100)
    end,
    function(inst, id, data)
        inst:AddTag("plain9")
        if inst:HasTag("plain8") and inst:HasTag("plain9") then
            local lucky = Sample.LUCKY
            lucky = lucky+data
            Sample.LUCKY = lucky
        end
    end,
    function(inst, id, data)
        inst:RemoveTag("plain9")
        local lucky = Sample.LUCKY
        lucky = lucky-data
        Sample.LUCKY = lucky
    end,
    .1
),


Ornament("ak_ornament_fancy1", 
    "生命之赐",
    function(data)
        return string.format("增加%d生命上限", data)
    end,
    function(inst, id, data)
        inst.components.health:WgAddMaxHealthModifier(id, data, true)
    end,
    function(inst, id, data)
        inst.components.health:WgRemoveMaxHealthModifier(id, true)
    end,
    150
),
Ornament("ak_ornament_fancy2", 
    "理智之赐",
    function(data)
        return string.format("增加%d理智上限", data)
    end,
    function(inst, id, data)
        inst.components.sanity:WgAddMaxSanityModifier(id, data, true)
    end,
    function(inst, id, data)
        inst.components.sanity:WgRemoveMaxSanityModifier(id, true)
    end,
    150
),
Ornament("ak_ornament_fancy3", 
    "饱食之赐",
    function(data)
        return string.format("增加%d饥饿上限", data)
    end,
    function(inst, id, data)
        inst.components.hunger:WgAddMaxHungerModifier(id, data, true)
    end,
    function(inst, id, data)
        inst.components.hunger:WgRemoveMaxHungerModifier(id, true)
    end,
    150
),
Ornament("ak_ornament_fancy4", 
    "切斯特之赐",
    function(data)
        return string.format("无法卸下;增加%d饰品上限", data)
    end,
    function(inst, id, data)
        local max = inst.components.tp_ornament.max
        inst.components.tp_ornament.max = max+data
    end,
    function(inst, id, data)
        local max = inst.components.tp_ornament.max
        inst.components.tp_ornament.max = max-data
    end,
    4,
    true
),

Ornament("ak_ornament_festivalevents2", 
    "火焰之地的加护",
    function(data)
        return string.format("燃烧中的生物不会影响其掉落的战利品")
    end,
    function(inst, id, data)
        Sample.NO_BURNING_LOOT = true
    end,
    function(inst, id, data)
        Sample.NO_BURNING_LOOT = nil
    end,
    {}
),
Ornament("ak_ornament_festivalevents3", 
    "战神的加护",
    function(data)
        return string.format("无法卸下;获得%d防御;在你到达%d级后,失去此饰品", data[1], data[2])
    end,
    function(inst, id, data)
        inst.components.combat:AddDefenseMod(id, data[1])
    end,
    function(inst, id, data)
        inst.components.combat:RmDefenseMod(id)
    end,
    {30, 11},
    true
),
Ornament("ak_ornament_festivalevents4", 
    "护身符",
    function(data)
        return string.format("增加%d生命上限", data)
    end,
    function(inst, id, data)
        inst.components.health:WgAddMaxHealthModifier(id, data, true)
    end,
    function(inst, id, data)
        inst.components.health:WgRemoveMaxHealthModifier(id, true)
    end,
    50
),
Ornament("ak_ornament_boss_wagstaff", 
    "阿瑞斯的加护",
    function(data)
        return string.format("无法卸下;获得%d防御;在你到达%d级后,失去此饰品", data[1], data[2])
    end,
    function(inst, id, data)
        inst.components.combat:AddDefenseMod(id, data[1])
    end,
    function(inst, id, data)
        inst.components.combat:RmDefenseMod(id)
    end,
    {30, 11},
    true
),
}

local DataManager = require "extension/lib/data_manager"
local OrnamentManager = DataManager("OrnamentManager")
OrnamentManager:AddDatas(ornaments)

return OrnamentManager