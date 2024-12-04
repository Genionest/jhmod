local AkTransporterScreen = require "screens/ak_transporter_screen"
local WgShelf = require "extension.lib.wg_shelf"

local AkTransporter = Class(function(self, inst)
    self.inst = inst
    inst:AddTag("ak_transporter")
end)

function AkTransporter:SetCenter(center)
    self.center = center
end

function AkTransporter:GetCenterElectric()
    if self.center and self.center:IsValid()

    and self.center.components.ak_electric then
        return self.center.components.ak_electric.current
    end
end

function AkTransporter:DoTransport()
    local x, y, z = self.inst:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 9999, {"ak_transporter"})
    local shelfs = WgShelf("", 6)
    for k, v in pairs(ents) do
        if v ~= self.inst then
            local title = v.components.ak_editor:GetText()
            local shelf = WgShelf(title, 1)
            shelf.machine =v
            shelfs:AddItem(shelf)
        end 
    end
    TheFrontEnd:PushScreen(AkTransporterScreen(shelfs))
end

function AkTransporter:GoMyPoint()
    local player = GetPlayer()
    player.Transform:SetPosition(self.inst:GetPosition():Get())
    self:CostCenterElectric(self.inst.cost)
end

function AkTransporter:CostCenterElectric(amount)
    if self.center and self.center:IsValid()

    and self.center.components.ak_electric then
        self.center.components.ak_electric:DoDelta(-amount)
    end
end

function AkTransporter:GetWargonString()
    local cur = self:GetCenterElectric()
    if cur then
        return string.format("电站电力:%d", cur)
    else
        return string.format("无电站供给电力")
    end
end

return AkTransporter