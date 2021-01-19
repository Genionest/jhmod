local Image = require "widgets/image"
local Text = require "widgets/text"

local DragImage = Class(Image, function(self, atlas, img)
	Image._ctor(self, atlas, img)
    self.word = self:AddChild(Text(TITLEFONT, 30))
    self.word:SetString(string.format("%s, %s", 0, 0))
    self.word:Hide()
end)

function DragImage:OnControl(control, down)
	if control == CONTROL_ACCEPT then
        if down then
            self:StartDrag()
        else
            self:StopDrag()
        end
    end
    if not self:IsEnabled() or not self.focus then return end
    if control == CONTROL_ACCEPT then
        if down then
            -- self:ScaleTo(1,0.9,1/15)
            self.down = true
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        elseif self.down then
            -- self:ScaleTo(0.9,1,1/15)
            self.down = false
        end
        return true
    end
end

function DragImage:StartDrag()
	if not self.is_drag then
        self.is_drag = true
        self:StartUpdating()
    end
end

function DragImage:StopDrag()
    self:StopUpdating()
    self.is_drag = false
end

function DragImage:OnLoseFocus()
    DragImage._base.OnLoseFocus(self)
    -- self:StopDrag()
end

function DragImage:SetMaster(master, offset)
    self.master = master
    self.offset = offset
end

function DragImage:OnUpdate(dt)
	dt = dt or 0
	if self.is_drag then
		local pos = TheInput:GetScreenPosition()
        if self.master and self.offset then
            pos.x = pos.x + self.offset.x
            pos.y = pos.y + self.offset.y
            self.master:SetPosition(pos)
        else
            self:SetPosition(pos)
        end
        self.word:SetString(string.format("%s, %s", pos.x, pos.y))
        if self.drag_fn then
            self.drag_fn(self)
        end
    end
end

return DragImage