local WgValue = require "components/wg_value"
local Image = require "widgets/image"
local AssetUtil = require "extension.lib.asset_util"
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
    TheInput:AddKeyDownHandler(Sample.button_key, function()
        if not IsPaused() then
            self:Click()
        end
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
    if data.init then
        data.init(self.inst, self, id)
    end
    local widget = data:GetButton(self.inst)
    local inst = self.inst
    if inst.HUD then
		if self.badge then
            inst.HUD.controls.status:RemoveBadge(self.badge)
            self.badge = nil
        end
        self.badge = inst.HUD.controls.status:AddBadge(widget)
        -- 特效
        local atlas, image = AssetUtil:GetImage(data.Uimg)
        local im = Image(atlas, image)
        local source_pos = Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition()))
        -- local dest_pos = Vector3(TheSim:GetScreenPos(widget:GetPosition()))
        local dest_pos = self:GetScreenPos()
        -- print(source_pos, dest_pos)
        im:MoveTo(source_pos, dest_pos, .3, function() 
            widget:ScaleTo(2, 1, .25) 
            im:Kill() 
        end)

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

function TpPlayerButton:GetScreenPos()
    local w, h = TheSim:GetScreenSize()
    local dest_pos = Vector3(w, h, 0)
    local parent = self.badge.parent
    while parent ~= nil do
        dest_pos = dest_pos + parent:GetPosition()
        parent = parent.parent
    end
    return dest_pos
end

function TpPlayerButton:SetFn(fn)
    self.fn = fn
end

function TpPlayerButton:Click()
    local data = SkillButtonManager:GetDataById(self.id)
    local player = self.inst
    local mana = data.mana
    if player.components.tp_val_hollow
    and player.components.tp_val_hollow:CanReduceManaCost() then
        mana = mana * .2
    end
    if player.components.tp_val_mana:GetCurrent()>=mana then
        player.components.tp_player_button:Trigger()
        data.fn(player)
        player.components.tp_val_mana:DoDelta(-mana)
        if player.components.tp_val_hollow
        and player.components.tp_val_hollow:CanReduceManaCost() then
            player.components.tp_val_hollow:EffectReduceManaCost()
        end
    end
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