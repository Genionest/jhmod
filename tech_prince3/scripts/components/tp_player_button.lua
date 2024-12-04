local WgValue = require "components/wg_value"
local SkillButtonManager = Sample.SkillButtonManager

local TpPlayerButton = Class(WgValue, function(self, inst)
    WgValue._ctor(self, inst)
    self:SetRate(-1)
    self.event = "tp_player_btn_delta"
    self.badge = nil
    self.fn = nil
    self.id = nil
    self:Start()
    self.inst:DoTaskInTime(0, function()
        -- 一开始playerHUD还没加载出来
        local id = self.id
        if not self:HasId() then
            id = self.inst.prefab
        end
        self:SetSkillButton(id, true)
    end)
end)

function TpPlayerButton:HasId()
    return self.id ~= nil
end

function TpPlayerButton:SetSkillButton(id, force)
    if self.id == id and not force then
        return
    end
    self.id = id
    local data = SkillButtonManager:GetDataById(self.id)
    self:SetMax(data.time)
    local widget = data:GetButton(self.inst)
    local inst = self.inst
    if inst.HUD then
		if self.badge then
            inst.HUD.controls.status:RemoveBadge(self.badge)
            self.badge = nil
        end
        self.badge = inst.HUD.controls.status:AddBadge(widget)
        -- self.badge = inst.HUD.controls.status:AddChild(widget)
        -- widget:SetPosition(-150, 0, 0)
        widget.max = self:GetMax()
        widget:SetPercent(self:GetPercent())
        widget.inst:ListenForEvent(self.event, function(inst, data)
            local p = self:GetPercent()
            widget:SetPercent(p, self:GetMax())
            if p < 1 and data.old_p >= 1 then
                widget.wg_btn:Disable()
            elseif p>=1 and data.old_p < 1 then
                widget.wg_btn:Enable()
            end
        end, self.inst)
    end
end

function TpPlayerButton:SetFn(fn)
    self.fn = fn
end

function TpPlayerButton:Trigger()
    -- self.fn(self.inst)
    self:SetPercent(0)
end

function TpPlayerButton:OnSave()
    local data = TpPlayerButton._base.OnSave(self)
    data.id = self.id
    return data
end

function TpPlayerButton:OnLoad(data)
    TpPlayerButton._base.OnLoad(self, data)
    if data then
        self.id = data.id
    end
end

-- function TpPlayerButton:GetWargonString()
--     local s = string.format("技能冷却:%d", self.max-self.current)
--     return s
-- end

-- function TpPlayerButton:GetWargonStringColour()
--     return {100/255, 149/255, 237/255, 1}
-- end

return TpPlayerButton