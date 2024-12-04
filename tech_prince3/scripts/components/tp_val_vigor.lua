local WgValue = require "components/wg_value"
local WgBadge = require "extension/uis/wg_badge"
local AssetUtil = require "extension/lib/asset_util"

local TpValVigor = Class(WgValue, function(self, inst)
    self.inst = inst
    WgValue._ctor(self, inst)
    self.rate = -.5
    self.period = .1
    self:SetMax(10)
    self.event = "val_vigor_delta"
    self.badge = nil
    self:Start()
    -- 增加时
    self.delta_fns = {
        function(cmp, delta, old)
            -- 消耗精力时
            if delta < 0 then
                self:Stop()
                if self.hold_task then
                    self.hold_task:Cancel()
                    self.hold_task = nil
                end
                self.hold_task = self.inst:DoTaskInTime(1.5, function()
                    self:Start()
                end)
            end
        end,
    }
    -- self.dt = 5
    -- self.atk = 1
    self.inst:ListenForEvent("tp_do_attack", function(inst, data)
        -- self:StopConsume()
        -- self:DoDelta(self.atk)
        -- self.atk = self.atk + 1
        local amt = -2
        local cost_vigor = self:GetWeaponVigor() or 0
        amt = amt - cost_vigor
        self:DoDelta(amt)
    end)
    -- self.inst:ListenForEvent("val_vigor_delta", function(inst, data)
    --     local p = self:GetPercent()
    --     if p >= 1 then
    --         self.inst.components.combat:AddDamageModifier("vigor", -.8)
    --     elseif p >= .8 then
    --         self.inst.components.combat:AddDamageModifier("vigor", -.2)
    --     elseif p >= .5 then
    --         self.inst.components.combat:AddDamageModifier("vigor", -.1)
    --     elseif p >= .3 then
    --         self.inst.components.combat:AddDamageModifier("vigor", -.05)
    --     end
    -- end)
end)

local ValBadge = Class(WgBadge, function(self, owner)
    WgBadge._ctor(self, owner)
    owner.skill_button = self.anim
    self.anim:GetAnimState():SetMultColour(33/255, 122/255, 52/255, 1)
    self.priority = -1
end)

function TpValVigor:MakeBadge()
    local widget = ValBadge(self.inst)
    local Uimg = AssetUtil:MakeImg("tp_icons2", "badge_30")
    local atlas, image = AssetUtil:GetImage(Uimg)
    widget:SetImage(atlas, image)
    widget:SetString("精力值")
    widget:SetDescription("精力值空了无法攻击")
    widget.id = self.id
    return widget
end

function TpValVigor:InitBadge()
    local inst = self.inst
    if inst.HUD then
		if not self.badge then
            local widget = self:MakeBadge()
            self.badge = inst.HUD.controls.status:AddBadge(widget)
            -- self.badge = inst.HUD.controls.status:AddChild(widget)
            -- widget:SetPosition(-150-70*2, 0, 0)
            widget.max = self:GetMax()
            widget:SetPercent(self:GetPercent())
            widget.inst:ListenForEvent(self.event, function(inst, data)
                local p = self:GetPercent()
                widget:SetPercent(p, self:GetMax())
            end, self.inst)
        end
    end
end

function TpValVigor:GetWeaponVigor()
    local weapon = self.inst.components.combat:GetWeapon()
    if weapon and weapon.components.weapon.cost_vigor then
        return weapon.components.weapon.cost_vigor
    end
end

-- function TpValVigor:StartConsume()
--     if self.consume_task == nil then
--         -- self.atk = 1
--         self.consume_task = self.inst:DoPeriodicTask(1, function()
--             self:DoDelta(-self.dt)
--             -- self.dt = self.dt + 1
--             -- self.dt = self.dt + math.floor(self:GetMax()/10)*.1
--         end, 0)
--     end
-- end

-- function TpValVigor:StopConsume()
--     if self.consume_task then
--         self.consume_task:Cancel()
--         self.consume_task = nil
--         -- self.dt = 1
--     end
-- end

-- function TpValVigor:OnSave()
--     local data = TpValVigor._base.OnSave(self)
--     -- data.dt = self.dt
--     -- data.atk = self.atk
--     return data
-- end

-- function TpValVigor:OnLoad(data)
--     TpValVigor._base.OnLoad(self, data)
--     if data then
--         -- self.dt = data.dt
--         -- self.atk = data.atk
--         if self:GetCurrent() > 0 then
--             self:StartConsume()
--         end
--     end
-- end

return TpValVigor