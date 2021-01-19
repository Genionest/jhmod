local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"

local FollowImageButton = Class(Widget, function(self, atlas, img)
    Widget._ctor(self, "followImageButton")

    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(1.25)
    self.buttons = {}
    self.offset = Vector3(0,0,0)
    self.screen_offset = Vector3(0,0,0)

    self:StartUpdating()
    self:SetContent()
    -- self.imagebutton = self:AddChild(ImageButton(atlas, img))
end)

local uipos = {}
for i = 0, 0 do
    for j = 0, 1 do
        local x = -(1*70)/2 + 70*j
        local y = (1*70)/2 - 70*i
        local pos = Vector3(x, y, 0)
        table.insert(uipos, pos)
    end
end

function FollowImageButton:SetContent()
    for k, v in pairs(uipos) do
        self.buttons[k] = self:AddChild(ImageButton(
            "images/inventoryimages.xml", "ash.tex"
        ))
    end
end

function FollowImageButton:SetButtons(btns, skill, cmp)
    for k, v in pairs(btns) do
        self.buttons[k]:SetTextures(
            v.atlas or "images/inventoryimages.xml", v.img
        )
        self.buttons[k]:SetOnClick(function()
            v.fn(skill, cmp)
        end)
        self.buttons[k]:SetPosition(uipos[k])
    end
end

-- function FollowImageButton:SetOnClick(fn)
--     self.imagebutton:SetOnClick(fn)
-- end

function FollowImageButton:SetTarget(target)
    self.target = target
    self:OnUpdate()
end

function FollowImageButton:SetOffset(offset)
    self.offset = offset
    self:OnUpdate()
end

function FollowImageButton:SetScreenOffset(x,y)
    self.screen_offset.x = x
    self.screen_offset.y = y
    self:OnUpdate()
end

function FollowImageButton:GetScreenOffset()
    return self.screen_offset.x, self.screen_offset.y
end

function FollowImageButton:OnUpdate(dt)
    if self.target and self.target:IsValid() then
        local scale = TheFrontEnd:GetHUDScale()
        for k, v in pairs(self.buttons) do
            v:SetScale(scale)
        end
        -- self.imagebutton:SetScale(scale)

        local world_pos = nil

        if self.target.AnimState then
            world_pos = Vector3(self.target.AnimState:GetSymbolPosition(self.symbol or "", self.offset.x, self.offset.y, self.offset.z))
        else
            world_pos = self.target:GetPosition()
        end

        if world_pos then
            local screen_pos = Vector3(TheSim:GetScreenPos(world_pos:Get())) 

            screen_pos.x = screen_pos.x + self.screen_offset.x
            screen_pos.y = screen_pos.y + self.screen_offset.y
            self:SetPosition(screen_pos)
        end
    end
end

return FollowImageButton