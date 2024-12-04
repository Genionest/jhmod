local TpPuppetMgr = Class(function(self, inst)
    self.inst = inst
    self.puppet_guid = nil
    self.inst:DoTaskInTime(0, function()
        self:CheckAndClear()
    end)
end)

function TpPuppetMgr:CheckAndClear()
    -- 删除多余的tp_puppet
    local x, y, z = self.inst:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 9999, {"tp_puppet"})
    for k, v in pairs(ents) do
        -- if v.GUID ~= self.puppet_guid then
            v:Remove()
        -- end
    end
end

function TpPuppetMgr:SpawnPuppet(pos)
    self:CheckAndClear()
    local puppet = SpawnPrefab("tp_puppet")
    puppet.Transform:SetPosition(pos:Get())
    puppet:onbuilt()
    self:SetPuppetGuid(puppet)
end

function TpPuppetMgr:SetPuppetGuid(puppet)
     self.puppet_guid = puppet.GUID
end

-- function TpPuppetMgr:ClearLastPuppetInfo()
--    -- 不好找
--     local SGIdx = SaveGameIndex
--     local name
--     SGIdx.data.slots[SGIdx.current_slot].resurrectors[name]
-- end

-- function TpPuppetMgr:OnSave()
--     return {
--         puppet_guid = self.puppet_guid
--     }
-- end

-- function TpPuppetMgr:OnLoad(data)
--     if data then
--         self.puppet_guid = data.puppet_guid
--     end
-- end

return TpPuppetMgr