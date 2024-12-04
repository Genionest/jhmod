local mouse_info = GetModConfigData("mouse_info")
if not mouse_info then 
    AddClassPostConstruct("widgets/hoverer",function(self)
        local OnUpdate = self.OnUpdate
        function self:OnUpdate()
            OnUpdate(self)
            self.text:Hide()
            self.secondarytext:Hide()
        end
    end)
end