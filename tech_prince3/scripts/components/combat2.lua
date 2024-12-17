local Util = require "extension.lib.wg_util"
local Info = Sample.Info

local Combat2 = Class(function(self, inst)
    self.inst = inst
end)

function Combat2:GetWargonString()
    local s = ""
    local cmp = self.inst.components.combat
    local dmg_type = cmp.dmg_type
    local weapon = cmp:GetWeapon()
    if weapon and weapon.components.weapon 
    and weapon.components.weapon.dmg_type then
        dmg_type = weapon.components.weapon.dmg_type
    elseif cmp.get_dmg_type_fn then
        dmg_type = cmp.get_dmg_type_fn(self.inst)
    end
    if dmg_type then
        s = s..string.format("伤害类型:%s", STRINGS.TP_DMG_TYPE[dmg_type])
    end
    if cmp.tp_dmg_type_absorb then
        if #s > 0 then
            s = s.."\n"
        end
        s = s.."伤害吸收:"
        -- for k, v in pairs(cmp.tp_dmg_type_absorb) do
        for k, v in pairs(Info.DmgTypeList) do
            local val = cmp.tp_dmg_type_absorb[v[1]]
            if val and math.floor(val*100-100)~=0 then
                s = s..string.format("%s(%d%%),", v[2], val*100)
                -- s = s..string.format("%s(%d%%),", STRINGS.TP_DMG_TYPE[k], v*100)
            end
        end
        -- s = s.."其他(100%)"
        return Util:SplitSentence(s, 17, true)
    end
end

function Combat2:GetWargonStringColour()
    return {179/255, 179/255, 79/255, 1}
end

return Combat2