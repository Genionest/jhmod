local Util = require "extension.lib.wg_util"

local Cmp = Class(function(self, inst)
    self.inst = inst
end)

function Cmp:GetWargonString()
    local cmp = self.inst.components.tp_creature_equip
    if cmp.attr_data == nil then return end
    -- local str = string.format("等级:%d,生命+%d%%,攻击+%d&+%d%%,防御+%d,穿透+%d",
    --     cmp.level, cmp.attr_data.hp_mod*100, cmp.attr_data.ex_dmg, 
    --     cmp.attr_data.dmg_mod*100, cmp.attr_data.absorb, 
    --     cmp.attr_data.penetrate)
    local str = string.format("等级:%d", cmp.level)
    str = Util:SplitSentence(str, 17, true)
    return str
end

function Cmp:GetWargonStringColour()
    return {227/255, 207/255, 87/255, 1}
end

-- function Cmp:GetWargonStringFont()
--     return 20
-- end

return Cmp