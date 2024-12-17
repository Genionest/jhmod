local WgValue = require "components/wg_value"
local WgBadge = require "extension/uis/wg_badge"
local AssetUtil = require "extension/lib/asset_util"

local REDUCE_MANA_COST_NEED_VAL = 5

local TpValHollow = Class(WgValue, function(self, inst)
    WgValue._ctor(self, inst)
    self:SetRate(-1)
    self.event = "val_hollow_delta"
    self.badge = nil
    self:Start()
end)

local ValBadge = Class(WgBadge, function(self, owner)
    WgBadge._ctor(self, owner)
    owner.skill_button = self.anim
    self.anim:GetAnimState():SetMultColour(97/255, 74/255, 132/255, 1)
end)

function TpValHollow:MakeBadge()
    local widget = ValBadge(self.inst)
    local Uimg = AssetUtil:MakeImg("tp_icons2", "badge_31")
    local atlas, image = AssetUtil:GetImage(Uimg)
    widget:SetImage(atlas, image)
    widget:SetString("六目")
    widget:SetDescription("玩家释放技能时,消耗的法力减少80%,但会消耗部分无量值")
    widget.id = self.id
    return widget
end

function TpValHollow:InitBadge()
    local inst = self.inst
    if inst.HUD then
		if not self.badge then
            local widget = self:MakeBadge()
            self.badge = inst.HUD.controls.status:AddBadge(widget)
            -- self.badge = inst.HUD.controls.status:AddChild(widget)
            -- widget:SetPosition(-150-70, 0, 0)
            widget.max = self:GetMax()
            widget:SetPercent(self:GetPercent())
            widget.inst:ListenForEvent(self.event, function(inst, data)
                local p = self:GetPercent()
                widget:SetPercent(p, self:GetMax())
            end, self.inst)
        end
    end
end

function TpValHollow:CanReduceManaCost()
    return self:GetCurrent() > REDUCE_MANA_COST_NEED_VAL
end

function TpValHollow:EffectReduceManaCost()
    self:DoDelta(-REDUCE_MANA_COST_NEED_VAL)
end


-- function TpValHollow:GetWargonString()
--     return string.format("法力值")
-- end

return TpValHollow