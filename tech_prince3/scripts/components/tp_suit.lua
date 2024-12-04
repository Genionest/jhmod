local Suit = Class(function(self, inst)
    self.inst = inst
    self.suit = nil
    inst:ListenForEvent("equip", function(inst, data)
        if data and (data.eslot == EQUIPSLOTS.HEAD
        or data.eslot == EQUIPSLOTS.HANDS 
        or data.eslot == EQUIPSLOTS.BODY) then
            self:CheckSuit()
        end
    end)
    inst:ListenForEvent("unequip", function(inst, data)
        if data and (data.eslot == EQUIPSLOTS.HEAD
        or data.eslot == EQUIPSLOTS.HANDS 
        or data.eslot == EQUIPSLOTS.BODY) then
            self:CheckSuit()
        end   
    end)
end)

function Suit:CheckSuit()
    local helm = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    local weapon = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local armor = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    local s1 = helm and helm.components.equippable.suit
    local s2 = weapon and weapon.components.equippable.suit
    local s3 = armor and armor.components.equippable.suit
    if s1 and s1 == s2 and s2 == s3 then
        self.suit = s1
    else
        self.suit = nil
    end
end

function Suit:GetWargonString()
    return string.format("套装:%s", tostring(self.suit))
end

return Suit