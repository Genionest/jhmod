local Util = require "extension.lib.wg_util"
local SmearManager = Sample.SmearManager

local TpEnchantmentable2 = Class(function(self, inst)
    self.inst = inst
end)

function TpEnchantmentable2:GetWargonString()
    local cmp = self.inst.components.tp_smearable
    return cmp:GetInfoString()
end

-- white, blue, purple, orange, gold
local colours = {
    {1, 1, 1, 1},
    {135/255, 206/255, 235/255, 1},
    {138/255, 43/255, 226/255, 1},
    {255/255, 128/255, 0, 1},
    {255/255, 215/255, 0, 1},
}
function TpEnchantmentable2:GetWargonStringColour()
    return colours[self.quality or 1]
end

return TpEnchantmentable2