local WgRechargeManager = Class(function(self, inst)
    self.inst = inst
    self.items = nil
    -- self.timer = {}
end)

function WgRechargeManager:AddItem(item, group)
    group = group or item.prefab
    if self.items == nil then
        self.items = {}
        self.inst:StartUpdatingComponent(self)
    end
    if self.items[group] == nil then
        self.items[group] = {}
    end
    self.items[group][item] = true
end

function WgRechargeManager:RemoveItem(item, group)
    group = group or item.prefab
    if self.items[group] and self.items[group][item] then
        self.items[group][item] = nil
        if next(self.items[group]) == nil then
            self.items[group] = nil
        end
        if next(self.items) == nil then
            self.items = nil
            self.inst:StopUpdatingComponent(self)
        end
    end
end

function WgRechargeManager:OnUpdate(dt)
    for k, v in pairs(self.items) do
        for k2, v2 in pairs(v) do
            if not k2.components.wg_recharge:IsRecharged() then
                k2.components.wg_recharge:DoDelta(dt)
            end
        end
    end
end

function WgRechargeManager:SetRechargeTime(group, time)
    for k, v in pairs(self.items[group]) do
        k.components.wg_recharge:SetRechargeTime(time)
    end
end

-- function WgRechargeManager:OnSave()
--     return {
--         timer = self.timer
--     }
-- end

-- function WgRechargeManager:OnLoad(data)
--     if data then
--         self.timer = data.timer or {}
--     end
-- end

return WgRechargeManager