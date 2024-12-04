local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"

local WgScrollBar = Class(Widget, function(self, max)
    Widget._ctor(self, "WgScrollBar")
    self.data = {
        {"TwoButton", 50, 5},
        {"BarWidth", 10, 5},
        {"BarHeight", 190, 5},
    }
    self.max = max
    self.cur = 1
    self.control_up = CONTROL_SCROLLBACK
	self.control_down = CONTROL_SCROLLFWD
    self.bg = self:AddChild(Image("images/ui.xml", "blank.tex"))
    -- self.bg:ScaleToSize(scissor_width, scissor_height)
    self.list_root = self:AddChild(Widget("list_root"))

    self.scroll_bar_container = self:AddChild(Widget("scroll-bar-container"))
    -- self.scroll_bar_container:SetPosition(unpack(self.scrollbar_offset))
    self.up_button = self.scroll_bar_container:AddChild(ImageButton("images/global_redux.xml", "scrollbar_arrow_up.tex"))
    self.up_button:SetPosition(0, self.data[1][2])
    self.up_button:SetScale(0.3)
    -- self.up_button:SetWhileDown( function()
    --     if not self.last_up_button_time or GetStaticTime() - self.last_up_button_time > button_repeat_time then
    --         self.last_up_button_time = GetStaticTime()
    --         self:Scroll(-self.scroll_per_click)
    --     end
    -- end)
    self.up_button:SetOnClick( function()
        -- self.last_up_button_time = nil
        self:Scroll(-1)
    end)

    self.down_button = self.scroll_bar_container:AddChild(ImageButton("images/global_redux.xml", "scrollbar_arrow_down.tex"))
    self.down_button:SetPosition(0, -self.data[1][2])
    self.down_button:SetScale(0.3)
    -- self.down_button:SetWhileDown( function()
    --     if not self.last_down_button_time or GetStaticTime() - self.last_down_button_time > button_repeat_time then
    --         self.last_down_button_time = GetStaticTime()
    --         self:Scroll(self.scroll_per_click)
    --     end
    -- end)
    self.down_button:SetOnClick( function()
        -- self.last_down_button_time = nil
        self:Scroll(1)
    end)

    self.scroll_bar_bg = self.scroll_bar_container:AddChild(Image("images/ui.xml", "textbox_long.tex"))
    self.scroll_bar_bg:SetPosition(0, 0)
    self.scroll_bar_bg:ScaleToSize(self.data[2][2]*2+50, self.data[3][2]*2)
    self.scroll_bar_bg:SetTint(1,1,1,0)

    self.scroll_bar_line = self.scroll_bar_container:AddChild(Image("images/global_redux.xml", "scrollbar_bar.tex"))
    self.scroll_bar_line:ScaleToSize(self.data[2][2], self.data[3][2])
    self.scroll_bar_line:SetPosition(0, 0)
    self.scroll_bar_bg.focus_forward = self.scroll_bar_line

    self.position_marker = self.scroll_bar_container:AddChild(ImageButton("images/global_redux.xml", "scrollbar_handle.tex"))
    self.position_marker:SetScale(0.3, 0.3, 1)
    self.position_marker:SetPosition(0, self.data[1][2])
    self.o_pos = nil
    self.position_marker.OnControl = function() end
    -- self.position_marker.OnGainFocus = function()end
    -- self.position_marker.OnLoseFocus = function()end
end)

function WgScrollBar:OnScroll()
    if self.on_scroll then
        self.on_scroll(self)
    end
    local p
    if self.max==1 or self.cur==1 then
        p = 0
    else
        p = (self.cur-1)/(self.max-1)
    end
    local height = self.data[1][2]*2
    self.position_marker:SetPosition(0, self.data[1][2]-height*p)
end

function WgScrollBar:Scroll(dt)
    local old_cur = self.cur
    self.cur = math.max(math.min(self.cur + dt, self.max), 1)
    if self.cur ~= old_cur then
        self:OnScroll()
    end
end

function WgScrollBar:ScrollTo(page)
    page = math.max(1, math.min(self.max, page))
    self:Scroll(page-self.cur)
end

function WgScrollBar:OnControl(control, down)
    if WgScrollBar._base.OnControl(self, control, down) then return true end
    
    if down and (self.focus) and self:IsVisible() then
        if control == self.control_up then
            local scroll_amt = -1
            -- if TheInput:ControllerAttached() then
            --     scroll_amt = scroll_amt / 2
            -- end
            -- if self:Scroll(scroll_amt) then
            --     TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
            -- end
            self:Scroll(scroll_amt)
            return true
        elseif control == self.control_down then
            local scroll_amt = 1
            -- if TheInput:ControllerAttached() then
            --     scroll_amt = scroll_amt / 2
            -- end
            self:Scroll(scroll_amt)
            return true
        end
    end
end

return WgScrollBar