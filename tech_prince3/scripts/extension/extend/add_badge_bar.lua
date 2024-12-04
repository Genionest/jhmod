local Widget = require "widgets/widget"

AddClassPostConstruct("widgets/statusdisplays", function(self)
    
    self.badges = {}
    function self:AddBadge(widget)
        if self.badge_bar == nil then
            self.badge_bar = self:AddChild(Widget("BadgeBar"))
            self.badge_bar:SetPosition(-150, 0, 0)
        end
        self.badge_bar:AddChild(widget)
        table.insert(self.badges, widget)
        self:RefreshBadges()
        return widget
    end
    function self:RemoveBadge(widget)
        if widget.bid then
            table.remove(self.badges, widget.bid)
            self.badge_bar:RemoveChild(widget)
        end
        widget:Kill()
        self:RefreshBadges()
    end
    function self:RefreshBadges()
        table.sort(self.badges, function(a, b) 
            local ap = a.priority or 0
            local bp = b.priority or 0
            return ap < bp
        end)
        for k, v in pairs(self.badges) do
            local idx = k-1
            local row = math.floor(idx/4)
            local col = idx % 4
            v.bid = k
            v:SetPosition( col * -70, row*-100, 0)
        end
    end
end)