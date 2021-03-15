local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Button = require "widgets/button"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local UIAnim = require "widgets/uianim"
local TpBuffSlot = require "widgets/tp_buff_slot"

local TpBuffBar = Class(Widget, function(self, owner)
    Widget._ctor(self, "TpBuffBar")
    self.slots = {}
    self.owner = owner

    -- self.inst:ListenForEvent("tp_add_buff", function(inst, data)
    --     if data.img then
    --         self:Add(data.buff, data.img, data.time)
    --     end
    -- end, self.owner)
    -- self.inst:ListenForEvent("tp_done_buff", function(inst, data)
    --     self:Delete(buff)
    -- end, self.owner)
end)

local uipos = {}
for i = 0, 5 do
    table.insert(uipos, Vector3(i*40, 0, 0))
end
local MAX_SLOT = #uipos

function TpBuffBar:Add(buff, img, time, debuff)
    local slot = self:Search(buff)
    if not slot then
        slot = self:AddChild(TpBuffSlot(buff, img, time, debuff))
        slot:Start()
        table.insert(self.slots, slot)
    else
        slot:SetTime(time)
    end
    self:ReSort()
    return slot
end

function TpBuffBar:Delete(buff)
    local slot, idx = self:Search(buff)
    if slot then
        self:RemoveChild(slot)
        slot:Kill()
        table.remove(self.slots, idx)
        slot = nil
        self:ReSort()
    end
    return slot
end

function TpBuffBar:Search(buff)
    for k, v in pairs(self.slots) do
        print(v.name, buff)
        if v.name == buff then
            return v, k
        end
    end
end

function TpBuffBar:ReSort()
    for k, v in pairs(self.slots) do
        if k > MAX_SLOT then
            v:Hide()
        else
            if not v.shown then
                v:Show()
            end
            v:SetPosition(uipos[k])
        end
    end
end

-- function TpBuffBar:SetPosition(pos, y, z)
--     local scr_w, scr_h = TheSim:GetScreenSize()
--     local scale = scr_w/1920
--     if type(pos) == "number" then
--         TpBuffBar._base.SetPosition(pos*scale, y*scale, z)
--     else
--         pos.x = pos.x*scale
--         pos.y = pos.y*scale
--         TpBuffBar._base.SetPosition(pos)
--     end
-- end

return TpBuffBar