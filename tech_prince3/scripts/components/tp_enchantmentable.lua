local Util = require "extension.lib.wg_util"
local EnchantmentManager = Sample.EnchantmentManager

local TpEnchantmentable = Class(function(self, inst)
    self.inst = inst
    self.ids = nil
    self.datas = nil
    self.init = nil
    self.quality = nil
end)

function TpEnchantmentable:Test()
    return self.init == nil
end

function TpEnchantmentable:TestData(data)
    local Data = data
    local id = data:GetId()
    if Data.test and not Data.test(Data, self.inst, self, id) then
        return
    end
    return true
end

function TpEnchantmentable:SetId(id)
    local Data = EnchantmentManager:GetDataById(id)
    if Data then
        if self:TestData(Data) then
            table.insert(self.ids, id)
            if self.init == nil then
                if Data.init then
                    Data.init(Data, self.inst, self, id)
                end
            end
            Data:Init(self.inst, self, id)
            if Data.fn then
                Data.fn(Data, self.inst, self, id)
            end
            if self.quality == nil then
                self.quality = 0
            end
            self.quality = self.quality + Data.quality
        end
    end
end

function TpEnchantmentable:Enchantment(item)
    -- self:SetQuality(item.quality)
    self:SetIds(item.ids)
end

function TpEnchantmentable:SetQuality(quality)
    -- self.quality = quality
end

function TpEnchantmentable:SetIds(ids)
    -- 由DataManager来保证id不重复
    self.ids = {}
    self.datas = {}
    for k, v in pairs(ids) do
        self:SetId(v)
    end
    self.init = true
end

function TpEnchantmentable:OnSave()
    return {
        ids = self.ids,
        -- quality = self.quality,
        datas = self.datas,
        init = self.init,
    }
end

function TpEnchantmentable:OnLoad(data)
    if data then
        -- self.quality = data.quality
        self.datas = data.datas
        self.init = data.init
        if data.ids then
            self.ids = {}
            for k, v in pairs(data.ids) do
                self:SetId(v)
            end
        end
    end
end

function TpEnchantmentable:GetWargonString()
    if self.quality and self.ids then
        local s = string.format("品质:%d", self.quality)
        for _, id in pairs(self.ids) do
            local data = EnchantmentManager:GetDataById(id)
            s = s..string.format("\n%s", data:GetDescription(self.inst, self, id))
        end
        s = Util:SplitSentence(s, 17, true)
        return s
    else
        -- return "可附魔"
    end
end

-- white, blue, purple, orange, gold
local colours = {
    {1, 1, 1, 1},
    {135/255, 206/255, 235/255, 1},
    {138/255, 43/255, 226/255, 1},
    {255/255, 128/255, 0, 1},
    {255/255, 215/255, 0, 1},
}
function TpEnchantmentable:GetWargonStringColour()
    if self.quality then
        for k, v in pairs({18, 12, 6, 3, 1}) do
            if self.quality >= v then
                return colours[5-k+1]
            end
        end
    end
end

return TpEnchantmentable