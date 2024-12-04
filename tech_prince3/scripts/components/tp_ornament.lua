local OrnamentManager = require "extension/datas/ornaments"
local WgShelf = require "extension/lib/wg_shelf"

local TpOrnament = Class(function(self, inst)
    self.inst = inst
    self.ids = {}
    self.max = 10
end)

function TpOrnament:Test(id)
    local n = 0
    for k, v in pairs(self.ids) do
        n = n+1
    end
    return self.ids[id] == nil and n<self.max
end

function TpOrnament:TakeOrnament(id)
    self.ids[id] = true
    self.inst:PushEvent("take_ornament")
    -- local data = OrnamentManager:GetDataById(id)
    -- data:Take(self.inst)
end

function TpOrnament:EffectOrnament(id)
    local data = OrnamentManager:GetDataById(id)
    data:Take(self.inst)
end

function TpOrnament:LoseOrnament(id)
    self.ids[id] = nil
    self.inst:PushEvent("lose_ornament")
    -- local data = OrnamentManager:GetDataById(id)
    -- data:Lose(self.inst)
end

function TpOrnament:UneffectOrnament(id)
    local data = OrnamentManager:GetDataById(id)
    data.lose(self.inst, data.id, data.data)
end

function TpOrnament:GetScreenData()
    local ids = {}
    for k, v in pairs(self.ids) do
        table.insert(ids, k)
    end
    table.sort(ids)
    local datas = {}
    for k, v in pairs(ids) do
        local data = OrnamentManager:GetDataById(v)
        table.insert(datas, data)
    end
    for i = #datas+1, self.max do
        local data = OrnamentManager:GetDataById("none")
        table.insert(datas, data)
    end
    local shelfs = WgShelf("饰品", 20)
    for k, v in pairs({datas}) do

        shelfs:AddBar()
        local shelf = WgShelf("", 20)
        for k2, v2 in pairs(v) do
            shelf:AddItem(v2)
        end
        shelfs:AddItem(shelf)
    end
    return shelfs
end

function TpOrnament:OnSave()
    return {
        ids = self.ids
    }
end

function TpOrnament:OnLoad(data)
    if data then
        for k, v in pairs(data.ids or {}) do
            self:TakeOrnament(k)
            self:EffectOrnament(k)
        end
    end
end

return TpOrnament