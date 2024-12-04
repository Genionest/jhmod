local ImageButton = require "widgets/imagebutton"

--[[
    让容器能够拥有更多的按钮,
    container组件添加了函数WgAddContainerButtonInfo来添加其他按钮
]]
AddClassPostConstruct("widgets/containerwidget", function(self)
    if self.more_cont_btn_fix then return end self.more_cont_btn_fix = true
    local Open = self.Open
    function self:Open(container, doer, boatwidget, ...)
        Open(self, container, doer, boatwidget, ...)
        self.wg_btns_info = container.components.container:WgGetOtherContainerButtonInfo()
        if self.wg_btns_info and not TheInput:ControllerAttached() then
            self.wg_buttons = {}
            for i, info in pairs(self.wg_btns_info) do
                local button = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex"))
                button:SetPosition(info.position)
                button:SetText(info.text)
                button:SetOnClick( function() info.fn(container, doer) end )
                button:SetFont(BUTTONFONT)
                button:SetTextSize(35)
                button.text:SetVAlign(ANCHOR_MIDDLE)
                button.text:SetColour(0,0,0,1)
                
                if info.validfn then
                    if info.validfn(container, doer) then
                        button:Enable()
                    else
                        button:Disable()
                    end
                end
                self.wg_buttons[i] = button
            end
        end
    end

    local Close = self.Close
    function self:Close(dont_close_container, ...)
        if self.isopen then
            if self.wg_buttons then
                for i, button in pairs(self.wg_buttons) do
                    button:Kill()
                end
            end
        end
        Close(self, dont_close_container, ...)
    end

    local OnItemGet = self.OnItemGet
    function self:OnItemGet(data, ...)
        OnItemGet(self, data, ...)
        if self.wg_btns_info and self.wg_buttons then
            for i, button in pairs(self.wg_buttons) do
                local info = self.wg_btns_info[i]
                if button and self.container and info and info.validfn then
                    if info.validfn(self.container) then
                        button:Enable()
                    else
                        button:Disable()
                    end
                end 
            end
        end
    end
    
    local OnItemLose = self.OnItemLose
    function self:OnItemLose(data, ...)
        OnItemLose(self, data, ...)
        if self.wg_btns_info and self.wg_buttons then
            for i, button in pairs(self.wg_buttons) do
                local info = self.wg_btns_info[i]
                if self.container and button and info and info.validfn then
                    if info.validfn(self.container) then
                        button:Enable()
                    else
                        button:Disable()
                    end
                end
            end
        end
    end
    
end)

AddComponentPostInit("container", function(self)
    --[[
        添加更多的容器按钮
    ]]
    function self:WgAddContainerButtonInfo(info)
        if self.wg_btns_info == nil then
            self.wg_btns_info = {}
        end
        table.insert(self.wg_btns_info, info)
    end
    --[[
        获取更多按钮的信息
    ]]
    function self:WgGetOtherContainerButtonInfo()
        return self.wg_btns_info
    end
end)