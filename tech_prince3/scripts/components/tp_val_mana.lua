local WgValue = require "components/wg_value"
local WgBadge = require "extension/uis/wg_badge"
local AssetUtil = require "extension/lib/asset_util"

local TpValMana = Class(WgValue, function(self, inst)
    WgValue._ctor(self, inst)
    self:SetRate(-1)
    self.event = "val_mana_delta"
    self.badge = nil
    self:Start()
end)

local ValBadge = Class(WgBadge, function(self, owner)
    WgBadge._ctor(self, owner)
    owner.skill_button = self.anim
    self.anim:GetAnimState():SetMultColour(.35, .3, 1, 1)
end)

function TpValMana:MakeBadge()
    local widget = ValBadge(self.inst)
    local Uimg = AssetUtil:MakeImg("tophat")
    local atlas, image = AssetUtil:GetImage(Uimg)
    widget:SetImage(atlas, image)
    widget:SetString("法力值")
    widget:SetDescription("玩家释放一些技能需要消耗法力值")
    widget.id = self.id
    return widget
end

function TpValMana:InitBadge()
    local inst = self.inst
    if inst.HUD then
		if not self.badge then
            local widget = self:MakeBadge()
            self.badge = inst.HUD.controls.status:AddChild(widget)
            widget:SetPosition(-150-70, 0, 0)
            widget.max = self:GetMax()
            widget:SetPercent(self:GetPercent())
            widget.inst:ListenForEvent(self.event, function(inst, data)
                local p = self:GetPercent()
                widget:SetPercent(p, self:GetMax())
            end, self.inst)
        end
    end
end

-- function TpValMana:GetWargonString()
--     return string.format("法力值")
-- end

return TpValMana