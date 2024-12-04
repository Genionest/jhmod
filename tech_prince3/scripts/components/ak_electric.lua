local WgValue = require "components/wg_value"
local FxManager = Sample.FxManager

local AkElectric = Class(WgValue, function(self, inst)
    WgValue._ctor(self, inst)
    self.inst:AddTag("ak_electric")


    self.inst:ListenForEvent("wg_value_delta", function(inst, data)
        if self.current <= 0 then
            inst:AddTag("ak_no_electric")
            if self.inst.components.machine
            and self.inst.components.machine.ison then
                self.inst.components.machine:TurnOff()
            end

            if self.fx == nil then
                self.fx = FxManager:MakeFx("no_electric", inst)
                inst:AddChild(self.fx)
            end
        else
            inst:RemoveTag("ak_no_electric")

            if self.fx then
                self.fx:WgRecycle()
                self.fx = nil
            end
        end
    end)
    self.load = 0
    inst:AddComponent("ak_electrical")
    inst.components.ak_electrical.type = "appliance"
end)

function AkElectric:GetWargonString()
    local s = string.format("电量:%d/%d", self.current, self.max)
    s = s..string.format("\n负载:%d", self.load)
    return s
end

return AkElectric