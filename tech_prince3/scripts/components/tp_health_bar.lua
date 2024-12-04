local WgFollowWidget = require "components.wg_follow_widget"
local FollowText = require "widgets/followtext"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local EntUtil = require "extension.lib.ent_util"
local FxManager = Sample.FxManager

local HealthBar = Class(FollowText, function(self)
    FollowText._ctor(self, TALKINGFONT, 35)
    self.hp_bg = self:AddChild(Widget("HealthBarBg"))
    self.health = self.hp_bg:AddChild(UIAnim())
    self.health:GetAnimState():SetBank("tp_health_bar")
    self.health:GetAnimState():SetBuild("tp_health_bar")
    self.health:GetAnimState():SetMultColour(1,1,1,.7)
    -- self.health:GetAnimState():PlayAnimation("h1")
    self.sheild = self.hp_bg:AddChild(UIAnim())
    self.sheild:GetAnimState():SetBuild("tp_health_bar")
    self.sheild:GetAnimState():SetBank("tp_health_bar")
    self.sheild:GetAnimState():SetMultColour(1,1,1,.7)
    -- self.sheild:Hide()
    self.hp_txt = self.hp_bg:AddChild(Text(TALKINGFONT, 35))
end)

local TpHealthBar = Class(function(self, inst)
    WgFollowWidget._ctor(self, inst)
    self.sleep = nil
    self.state = nil
    self.task = nil
    self.hp_cur = nil
    self.shd_cur = nil
    self.inst:ListenForEvent("death", function(inst, data)
        -- 死亡血条消失
        self:Hide()
        self:Kill()
    end)
    self.inst:ListenForEvent("newcombattarget", function(inst, data)
        if data.target and data.target.components.tp_health_bar then
            data.target.components.tp_health_bar:SetHealthBar()
            if self.inst:HasTag("player") then
                data.target.components.tp_health_bar.state = 0
            end
            if data.target:HasTag("player") then
                self.state = 0 
            end
        end
        self:SetHealthBar()
    end)
    -- 监听伤害
    self.inst:ListenForEvent("attacked", function(inst, data)
        if data and data.damage and data.damage > 1 then
            FxManager:MakeFx("attack_number", self.inst, {
                number = data.damage,
                stimuli = data.stimuli
            })
        end
    end)
end)

function TpHealthBar:InitHealthBar()
    local scale
    if self.inst:HasTag("epic") then
        self.offset = Vector3(0, -1000, 0)
        scale = 1.2
    elseif self.inst:HasTag("largecreature") then
        self.offset = Vector3(0, -700, 0)
        scale = 1
    elseif self.inst:HasTag("smallcreature") then
        self.offset = Vector3(0, -300, 0)
        scale = .5
    elseif self.inst:HasTag("player") then
        self.offset = Vector3(0, -500, 0)
        scale = .8
    else
        self.offset = Vector3(0, -500, 0)
        scale = .8
    end
    self:SetWidget(HealthBar(), function(widget)
        widget.hp_bg:SetScale(scale)
        -- health_bar_delta(widget, p, txt)
    end)
end

function TpHealthBar:SetHealthBar()
    if self.widget == nil then
        self:InitHealthBar()
    end
    self:Execute(function(widget)
        local hp_cmp = self.inst.components.health
        self.hp_cur = hp_cmp.currenthealth
        local p = 1 - hp_cmp:GetPercent()

        local shd_cmp = self.inst.components.tp_val_sheild
        self.shd_cur = shd_cmp:GetCurrent()
        local p2 = 1 - shd_cmp:GetPercent()
        
        local txt
        if self.shd_cur > 0 then
            txt = string.format("(%d)%d/%d", 
                self.shd_cur, self.hp_cur, hp_cmp:GetMaxHealth())
        else
            txt = string.format("%d/%d", 
                self.hp_cur, hp_cmp:GetMaxHealth())
        end
        if self.inst:HasTag("player") then
            self.state = 2
        elseif self.state == nil then
            self.state = 1
        end
        self.widget.health:GetAnimState():SetPercent("h"..tostring(self.state), p)
        self.widget.sheild:GetAnimState():SetPercent("h3", p2)
        self.widget.hp_txt:SetString(txt)
        self.widget:Show()
    end)
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
    self.task = self.inst:DoTaskInTime(8, function(inst)
        if self.widget then 
            self.widget:Hide()
            self.state = nil
        end
    end)
end

function TpHealthBar:OnEntityWake()
    self.sleep = true
    if self.event_fn == nil then
        self.event_fn = EntUtil:listen_for_event(self.inst, "healthdelta", function(inst, data)
            local cur = self.inst.components.health.currenthealth
            -- 和显示的差距为1时改变血条
            if self.hp_cur and math.floor(math.abs(self.hp_cur - cur)) < 1 then
                return
            end
            self:SetHealthBar()
            -- if dt < 1 then
            --     return 
            -- end
            -- FxManager:MakeFx("health_number", self.inst, {number=dt})
        end)
    end
    if self.event_fn2 == nil then
        self.event_fn2 = EntUtil:listen_for_event(self.inst, "val_sheild_delta", function(inst, data)
            local cur = self.inst.components.tp_val_sheild:GetCurrent()
            -- 和显示的差距为1时改变血条
            if self.shd_cur and math.floor(math.abs(self.shd_cur - cur)) < 1 then
                return
            end
            self:SetHealthBar()
        end)
    end
end

function TpHealthBar:OnEntitySleep()
    if self.sleep then
        self.sleep = nil
        self.inst:RemoveEventCallback("healthdelta", self.event_fn)
        self.event_fn = nil
        self.inst:RemoveEventCallback("val_sheild_delta", self.event_fn2)
        self.event_fn2 = nil
    end
end

-- function TpHealthBar:GetWargonString()
--     return string.format("%d,%d", self.hp_cur or -1, self.shd_cur or -1)
-- end

return TpHealthBar
