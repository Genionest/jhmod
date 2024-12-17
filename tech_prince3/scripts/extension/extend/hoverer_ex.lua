local mouse_info = GetModConfigData("mouse_info")
if not mouse_info then 
    AddClassPostConstruct("widgets/hoverer",function(self)
        local OnUpdate = self.OnUpdate
        function self:OnUpdate()
            OnUpdate(self)
            if self.owner then
                if self.owner.should_hide_hover 
                and self.owner.should_hide_hover == 1 then
                    self.text:Hide()
                    self.secondarytext:Hide()
                end
            end
        end
    end)
end