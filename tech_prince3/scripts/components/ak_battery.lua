local WgValue = require "components/wg_value"

local AkBattery = Class(WgValue, function(self, inst)
    WgValue._ctor(self, inst)
    self.current = 0
    inst:AddTag("ak_battery")
    self.anims = {
        "off", "working_pre", "working_loop", "working_pst"
    }
    inst:ListenForEvent("wg_value_delta", function(inst, data)
        if self.anims and data.old_p <= 0 and data.new_p > 0 then

            inst.AnimState:PlayAnimation(self.anims[2])
            inst.AnimState:PushAnimation(self.anims[3], true)
        end
        if self.anims and data.old_p > 0 and data.new_p <= 0 then

            inst.AnimState:PlayAnimation(self.anims[4])
            inst.AnimState:PushAnimation(self.anims[1])
        end
    end)
    inst:DoTaskInTime(0, function()

        self:DoDelta(0)
    end)
    inst:AddComponent("ak_electrical")
    inst.components.ak_electrical.type = "battery"
end)

function AkBattery:SetMax(amount)
    self.max = amount
end

function AkBattery:GetWargonString()
    local s = string.format("储存电量:%d/%d", self.current, self.max)
    return s
end

return AkBattery