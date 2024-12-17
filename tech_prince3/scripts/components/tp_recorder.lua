local EntUtil = require "extension.lib.ent_util"

local TpRecorder = Class(function(self, inst)
    self.inst = inst
    self.data = {
        dmg_sum = {},
        absorb_sum = {},
        equip = {},
        use_scroll = {},
        weapon_use = {},
    }
    self.inst:ListenForEvent("onhitother", function(inst, data)
        if data.damage and data.stimuli then
            local dmg_type = EntUtil:get_dmg_stimuli(data.stimuli)
            self.dmg_num[dmg_type] = (self.dmg_num[dmg_type] or 0) + data.damage
        end
    end)
    self.inst:ListenForEvent("attacked", function(inst, data)
        if data.amount and data.stimuli then
            local dmg_type = EntUtil:get_dmg_stimuli(data.stimuli)
            self.absorb_sum[dmg_type] = (self.absorb_sum[dmg_type] or 0) + data.amount
        end
    end)
    self.inst:ListenForEvent("armor_absorb", function(inst, data)
        if data.damage and data.stimuli then
            local dmg_type = EntUtil:get_dmg_stimuli(data.stimuli)
            self.absorb_sum[dmg_type] = (self.absorb_sum[dmg_type] or 0) + data.damage
        end
    end)
    self.inst:ListenForEvent("equip", function(inst, data)
        local slot = data.eslot
        if self.equip[slot] == nil then
            self.equip[slot] = {}
        end
        if self.equip[slot][data.item.prefab] == nil then 
            self.equip[slot][data.item.prefab] = {}
        end
        local id = tostring(data.item.GUID)
        if self.equip[slot][data.item.prefab][id] == nil then
            self.equip[slot][data.item.prefab][id] = true
        end
    end)
    self.inst:ListenForEvent("use_scroll", function(inst, data)
        if data.scroll then
            if self.use_scroll[data.scroll.prefab] == nil then
                self.use_scroll[data.scroll.prefab] = 1
            end
            self.use_scroll[data.scroll.prefab] = self.use_scroll[data.scroll.prefab] + 1
        end
    end)
    self.inst:ListenForEvent("tp_do_attack", function(inst, data)
        if data.weapon then
            if self.weapon_use[data.weapon.prefab] == nil then
                self.weapon_use[data.weapon.prefab] = 1
            end
            self.weapon_use[data.weapon.prefab] = self.weapon_use[data.weapon.prefab] + 1
        end
    end)
end)

function TpRecorder:OnSave()
    return self.data
end

function TpRecorder:OnLoad(data)
    if data then
        self.data = data
    end
end

return TpRecorder