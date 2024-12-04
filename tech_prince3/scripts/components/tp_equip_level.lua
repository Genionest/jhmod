local LevelConst = {.03, 5}
local EquipLevel = Class(function(self, inst)
    self.inst = inst
    self.exp = 0
    self.level = 0
    self.max = 10
    inst:ListenForEvent("wg_owner_killed", function(inst, data)
        if data and data.victim and (data.victim:HasTag("monster")
        or data.victim:HasTag("epic") or data.victim:HasTag("largecreature"))
        and data.victim.components.health then
        else
            return
        end
        local max_hp = data.victim.components.health:GetMaxHealth()
        self:ExpDelta(max_hp*LevelConst[1])
        self:UpGrade()
    end)
    inst:ListenForEvent("tp_equip_fix", function(inst, data)
        self:ExpDelta(1)
    end)
end)

function EquipLevel:SetMax(max)
    self.max = max
end

function EquipLevel:UpGrade(is_load)
    if self.upgrade then
        self.upgrade(self.inst, self.level, is_load)
    end
end

function EquipLevel:ExpDelta(dt)
    if self.level < self.max or self.unlimited then
        self.exp = self.exp+dt
        for i = self.level, self.max do
            if self.level < self.max and self.exp > self.level*LevelConst[2] then
                self.exp = self.exp - self.level*LevelConst[2]
                self.level = self.level+1
            else
                break
            end
        end
        if self.level == self.max then
            self.exp = 0
        end
    end
end

function EquipLevel:OnSave()
    return {
        exp = self.exp,
        level = self.level,
    }
end

function EquipLevel:OnLoad(data)
    if data then
        self.level = data.level
        self.exp = data.exp
        self:UpGrade(true)
    end
end

function EquipLevel:GetWargonString()
    local max
    if self.unlimited then
        max = "∞"
    else
        max = tostring(self.max)
    end
    local s = string.format("等级:%d,上限:%s,经验:%d/%d", 
        self.level, max, self.exp, self.level*LevelConst[2])
    return s
end

function EquipLevel:GetWargonStringColour()
    return {135/255, 224/255, 230/255, 1}
end

return EquipLevel