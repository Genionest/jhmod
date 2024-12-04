local WgValue = require "components/wg_value"
local WgBadge = require "extension/uis/wg_badge"
local AssetUtil = require "extension/lib/asset_util"

local TpValSheild = Class(WgValue, function(self, inst)
    WgValue._ctor(self, inst)
    self.current = 0
    -- self:SetRate(-1)
    self.event = "val_sheild_delta"
    self.badge = nil
    -- self:Start()
    self.cur_mods = nil
    self.cur_buff = nil
end)

function TpValSheild:AddCurMod(key, val)
    if not self.cur_mods then
        self.cur_mods = {}
    end
    self.cur_mods[key] = val
    self.cur_buff = self:GetCurMod()
    self:DoDelta(0)  -- 0无法触发
    if self.inst.components.tp_health_bar then
        self.inst.components.tp_health_bar:SetHealthBar()
    end
end

function TpValSheild:RmCurMod(key)
    if self.cur_mods then
        self.cur_mods[key] = nil
    end
    self.cur_buff = self:GetCurMod()
    self:DoDelta(0)
    if self.inst.components.tp_health_bar then
        self.inst.components.tp_health_bar:SetHealthBar()
    end
end

function TpValSheild:GetCurMod()
    local val = 0
    if self.cur_mods then
        for k, v in pairs(self.cur_mods) do
            val = val + v
        end
    end
    return val
end

function TpValSheild:GetCurrent()
    local cur = self.current
    if self.cur_buff then
        cur = cur + self.cur_buff
    end 
    if cur <= 0 then
        -- 完全抵消
        self.cur_buff = nil
        self.cur_mods = nil
        self.current = 0
        cur = 0
    end
    return cur
end

function TpValSheild:GetMax()
    if self.inst.components.health then
        return self.inst.components.health:GetMaxHealth()
    end
    return TpValSheild._base.GetMax(self)
end

function TpValSheild:GetPercent()
    return math.min(1,self:GetCurrent()/self:GetMax())
end

function TpValSheild:DoDelta(delta)
    local old = self:GetCurrent()
    -- 可以为负数, 用以抵消cur_buff的值, 可以超过上限
    -- 不可用self:GetCurrent(), 因为会受到cur_buff的影响
    self.current = self.current + delta 
	-- print("WgValue current", self:GetCurrent())
	if self.delta_fns then
		for k, v in pairs(self.delta_fns) do
			v(self, delta, old)
		end
	end
	self.inst:PushEvent(self.event, {
		old_p = old/self:GetMax(),
		new_p = self:GetCurrent()/self:GetMax(),
		delta = delta,
	})
end

function TpValSheild:OnSave()
    local data = TpValSheild._base.OnSave(self)
    data.cur_mods = deepcopy(self.cur_mods)
    return data
end

function TpValSheild:OnLoad(data)
    if data then
        self.cur_mods = data.cur_mods
        self.cur_buff = self:GetCurMod()
        TpValSheild._base.OnLoad(self, data)
    end
end

-- local ValBadge = Class(WgBadge, function(self, owner)
--     WgBadge._ctor(self, owner)
--     owner.skill_button = self.anim
--     self.anim:GetAnimState():SetMultColour(.35, .3, 1, 1)
-- end)

-- function TpValSheild:MakeBadge()
--     local widget = ValBadge(self.inst)
--     local Uimg = AssetUtil:MakeImg("tophat")
--     local atlas, image = AssetUtil:GetImage(Uimg)
--     widget:SetImage(atlas, image)
--     widget:SetString("法力值")
--     widget:SetDescription("玩家释放一些技能需要消耗法力值")
--     widget.id = self.id
--     return widget
-- end

-- function TpValSheild:InitBadge()
--     local inst = self.inst
--     if inst.HUD then
-- 		if not self.badge then
--             local widget = self:MakeBadge()
--             self.badge = inst.HUD.controls.status:AddChild(widget)
--             widget:SetPosition(-150-70, 0, 0)
--             widget.max = self:GetMax()
--             widget:SetPercent(self:GetPercent())
--             widget.inst:ListenForEvent(self.event, function(inst, data)
--                 local p = self:GetPercent()
--                 widget:SetPercent(p, self:GetMax())
--             end, self.inst)
--         end
--     end
-- end

-- function TpValSheild:GetWargonString()
--     return string.format("法力值")
-- end

return TpValSheild