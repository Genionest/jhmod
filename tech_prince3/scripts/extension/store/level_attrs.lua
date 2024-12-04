local AssetUtil = require "extension/lib/asset_util"
local EntUtil = require "extension/lib/ent_util"
local Util = require "extension.lib.wg_util"
local WgShelf = require "extension/lib/wg_shelf"
local AssetMaster = Sample.AssetMaster
local Info = Sample.Info

local LevelAttrData = Class(function(self)
end)

--[[
生成饰品数据类  
(LevelAttrData) 返回这个类  
id (string) 标识  
Uimg (Img) 图片资源,   
done (function) 点击触发函数  
owner (EntityScript) 拥有者  
]]
local function LevelAttr(id, Uimg)
    local self = LevelAttrData()
    self.id = id
    self.name = Info.Attr.PlayerAttrStr[self.id]
    -- self.desc = desc
    self.Uimg = Uimg
    return self
end

function LevelAttrData:GetId()
    return self.id
end

function LevelAttrData:GetName()
    local num = self.master.buffer[self.id]
    local owner = self:GetOwner()
    num = num + owner.components.tp_player_attr.attr[self.id]
    local name = string.format("%d", num)
    return Util:SplitSentence(name, 5, true)
end

function LevelAttrData:GetDescription()
    -- local str = self.desc(self.owner, self)
    local num = self.master.buffer[self.id]
    local owner = self:GetOwner()
    num = num + owner.components.tp_player_attr.attr[self.id]
    -- num = num + owner.components.tp_player_attr:GetAttr(self.id)  -- 属性值可能受外界
    local str = owner.components.tp_player_attr:Review(self.id, num)
    return Util:SplitSentence(str, 10, true)
end

function LevelAttrData:GetImage()
    return AssetUtil:GetImage(self.Uimg)
end

function LevelAttrData:GetAnims()
end

function LevelAttrData:GetOwner()
    return self.master.owner
end

function LevelAttrData:Done()
    local owner = self:GetOwner()
    local master = self.master
    local n = owner.components.tp_player_attr.attr[self.id]
    if TheInput:IsKeyDown(KEY_CTRL) then
        if master.cost > 0 and master.buffer[self.id] > 0 then
            master.cost = master.cost - 1
            master.essence = master.essence + 1
            master.buffer[self.id] = master.buffer[self.id] - 1
        end
    else
        if master.essence > 0 and master.buffer[self.id] + n < 99 then
            master.essence = master.essence - 1
            master.cost = master.cost + 1
            master.buffer[self.id] = master.buffer[self.id] + 1
        end
    end
end

local level_attrs = {
    LevelAttr("health", 
        AssetUtil:MakeImg("half_health")
    ),
    LevelAttr("endurance",
        AssetUtil:MakeImg("bedroll_straw")
    ),
    LevelAttr("stamina",
        AssetUtil:MakeImg("backpack")
    ),
    LevelAttr("attention",
        AssetUtil:MakeImg("tophat")
    ),
    LevelAttr("strengthen",
        AssetUtil:MakeImg("hambat")
    ),
    LevelAttr("agility",
        AssetUtil:MakeImg("cutlass")
    ),
    LevelAttr("faith",
        AssetUtil:MakeImg("relic_4")
    ),
    LevelAttr("intelligence",
        AssetUtil:MakeImg("walrushat")
    ),
    LevelAttr("lucky",
        AssetUtil:MakeImg("piratehat")
    )
}

local shelfs = WgShelf("升级", 20)
for k, v in pairs({level_attrs}) do
    shelfs:AddBar()
    local shelf = WgShelf("", 20)
    for k2, v2 in pairs(v) do
        shelf:AddItem(v2)
        v2.master = shelfs
    end
    shelfs:AddItem(shelf)
end
shelfs.Init = function(self, owner, machine)
    self.owner = owner
    self.machine = machine
    self.essence = self.owner.components.tp_player_attr:GetEssence()
    self.cost = 0
    self.buffer = {}
    for k, v in pairs(self.owner.components.tp_player_attr.attr) do
        self.buffer[k] = 0
    end
end
shelfs.GetBalance = function(self)
    return self.essence
end
shelfs.Sure = function(self)
    -- fx
    SpawnPrefab("sparklefx").Transform:SetPosition(self.owner:GetPosition():Get())
    
    for k, v in pairs(self.buffer) do 
        self.owner.components.tp_player_attr:AddAttr(k, v)
    end
    self.owner.components.tp_player_attr:UpdateAttr()
    self.owner.components.inventory:ConsumeByName("tp_epic", self.cost)

    local load = self.machine.components.ak_electric.load
    self.machine.components.ak_electric:DoDelta(-load)
end

Sample.LevelAttrSystem = shelfs