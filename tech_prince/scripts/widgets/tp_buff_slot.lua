local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Button = require "widgets/button"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local UIAnim = require "widgets/uianim"

local TpBuffSlot = Class(Widget, function(self, name, img, time, red)
    Widget._ctor(self, "TpBuffSlot")
    -- spoliage, timer, kill self
    self.name = name
    self.max_time = time
    self.time = time
    self.spoilage = self:AddChild(UIAnim())
    self.spoilage:GetAnimState():SetBank("spoiled_meter")
    self.spoilage:GetAnimState():SetBuild("spoiled_meter")
    self.spoilage:GetAnimState():SetPercent("anim", 0)
    if red then
        self.spoilage:GetAnimState():SetMultColour(1, .1, .1, 1)
    else
        self.spoilage:GetAnimState():SetMultColour(1, 1, .1, 1)
    end
    self.spoilage:SetClickable(false)
    self.image = self:AddChild(Image(
        -- WARGON.resolve_img_path(img)
        img[1], img[2]
    ))
    self:SetScale(.5)
    self.next = nil
end)

function TpBuffSlot:Start()
    self.task = GetPlayer():per_task(1, function()
        self.time = math.max( self.time-1, 0 )
        local p = self.time/self.max_time
        self:SetPercent(p)
        if self.time <= 0 then
            if self.task then
                self.task:Cancel()
                self.task = nil
            end
        end
    end)
end

function TpBuffSlot:SetPercent(p)
    -- fix spoiled_meter is disappear in advance
    self.spoilage:GetAnimState():SetPercent("anim", math.min(1-p, .99))   
end

function TpBuffSlot:SetTime(time)
    self.time = time
    local p = self.time/self.max_time
    self:SetPercent(p)
end

return TpBuffSlot