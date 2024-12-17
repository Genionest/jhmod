local Sounds = require "extension.datas.sounds"
local SmearManager = Sample.SmearManager

local TpSmearable = Class(function(self, inst)
    self.inst = inst
    self.ids = nil
    self.mgr = nil
    -- 这个组件负责GetWargonString
    self.inst:AddComponent("tp_enchantmentable2")
end)

function TpSmearable:CanSmearId(id)
    if self.ids then
        for _, v in pairs(self.ids) do
            if v == id then
                return false
            end
        end
    end
    local data = SmearManager:GetDataById(id)
    if data.test and not data.test(data, self.inst, self, id) then
        return false
    end
end

function TpSmearable:CanSmear(item, doer)
    local id = item.components.tp_smear_item.id
    if self:CanSmearId(id) then
        return true
    end
end

function TpSmearable:SmearItem(item, doer)
    local id = item.components.tp_smear_item.id
    if item.components.stackable then
        item = item.components.stackable:Get()
        item:Remove()
    elseif item.components.finiteuses then
        item.components.finiteuses:Use(1)
    end
    if doer.SoundEmitter then
        doer.SoundEmitter:PlaySound(Sounds["get_item"])
	end
    self:Smear(id)
end

function TpSmearable:GetManager()
    self.mgr = self.mgr or GetPlayer().components.wg_timer_manager
    return self.mgr
end

function TpSmearable:Smear(id, time)
    if self.ids == nil then
        self.ids = {}
    end
    local data = SmearManager:GetDataById(id)
    local owner = self.inst.components.equippable.owner
    time = time or data.time
    if owner and owner:HasTag("tp_smear_longer") then
        time = time * 1.2
    end
    self.ids[id] = true
    if data.add then
        data.add(data, self.inst, self, id)
    end
    self:SetSmearTime(id, time)
end

function TpSmearable:SetSmearTime(id, time)
    self:GetManager()
    self.mgr:SetSmearTime(self.inst, id, time)
end

function TpSmearable:GetSmearTime(id)
    self:GetManager()
    return self.mgr:GetSmearTime(self.inst, id)
end

function TpSmearable:Clear(id)
    if self.ids then
        self.ids[id] = nil
    end
    local data = SmearManager:GetDataById(id)
    if data.rm then
        data.rm(data, self.inst, self, id)
    end
end

function TpSmearable:ClearAll()
    if self.ids then
        for id, _ in pairs(self.ids) do
            self:Clear(id)
        end
    end
end

function TpSmearable:OnRemoveEntity()
    self:ClearAll()
	self:GetManager()
	self.mgr:RemoveSmearTimer(self.inst)
end

function TpSmearable:OnSave()
    if self.ids then
        local data = {}
        for id, _ in pairs(self.ids) do
            local time = self:GetSmearTime(id)
            data[id] = time
        end
        return data
    end
end

function TpSmearable:OnLoad(data)
    if data then
        for id, time in pairs(data) do
            self:Smear(id, time)
        end
    end
end

-- 由组件tp_enchantmentable2输出
function TpSmearable:GetInfoString()
    if self.ids then
        local s
        for id, _ in pairs(self.ids) do
            local data = SmearManager:GetDataById(id)
            local time = self:GetSmearTime(id)
            if s == nil then
                s = string.format("buffs:\n%s(%ds)", data.desc(data, self.inst, self, id), time or 0)
            else
                s = s..string.format("\n%s(%ds)", data.desc(data, self.inst, self, id), time or 0)
            end
        end
        return s
    end
end

-- function TpSmearable:GetWargonStringColour()
--     return 
-- end

return TpSmearable