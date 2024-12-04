local AkTransporterScreen = require "screens/ak_transporter_screen"
local WgShelf = require "extension.lib.wg_shelf"

local TpTransporter = Class(function(self, inst)
    self.inst = inst
    inst:AddTag("tp_transporter")
end)

-- function TpTransporter:SetCenter(center)
--     self.center = center
-- end

-- function TpTransporter:GetCenterElectric()
--     if self.center and self.center:IsValid()

--     and self.center.components.ak_electric then
--         return self.center.components.ak_electric.current
--     end
-- end

function TpTransporter:DoTransport()
    local x, y, z = self.inst:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 9999, {"tp_campfire_burning"})
    local shelfs = WgShelf("", 6)
    for k, v in pairs(ents) do
        if v ~= self.inst then
            local title = v.components.ak_editor:GetText()
            local shelf = WgShelf(title, 1)
            shelf.machine = v
            shelfs:AddItem(shelf)
        end 
    end
    TheFrontEnd:PushScreen(AkTransporterScreen(shelfs))
end

function TpTransporter:GoMyPoint()
    local player = GetPlayer()
    player.HUD:Hide()
    TheFrontEnd:Fade(false,.5)
    self.inst:DoTaskInTime(.5, function()
        player.Transform:SetPosition(self.inst:GetPosition():Get())
        player.HUD:Show()
        TheFrontEnd:Fade(true,.5) 
    end)
    -- self:CostCenterElectric(self.inst.cost)
end

-- function TpTransporter:CostCenterElectric(amount)
--     if self.center and self.center:IsValid()

--     and self.center.components.ak_electric then
--         self.center.components.ak_electric:DoDelta(-amount)
--     end
-- end

-- function TpTransporter:GetWargonString()
--     local cur = self:GetCenterElectric()
--     if cur then
--         return string.format("电站电力:%d", cur)
--     else
--         return string.format("无电站供给电力")
--     end
-- end

return TpTransporter