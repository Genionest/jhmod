local AkElectrical = Class(function(self, inst)
    self.inst = inst
    self.type = nil
    self.system = nil
    inst:AddTag("ak_electrical")
    inst:DoTaskInTime(.5, function()
        local mgr = GetPlayer().components.ak_electric_manager
        if mgr then
            mgr:CheckAndJoinSystem(self.inst)
        end

    end)
end)

function AkElectrical:OnRemoveEntity()
    local mgr = GetPlayer().components.ak_electric_manager
    if mgr then
        mgr:CheckAndDisjoinSystem(self.inst)
    end
end

return AkElectrical