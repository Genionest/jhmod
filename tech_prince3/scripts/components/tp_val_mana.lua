local WgValue = require "components/wg_value"
local WgBadge = require "extension/uis/wg_badge"
local AssetUtil = require "extension/lib/asset_util"
local WgValModifier = require "extension.lib.wg_val_modifier"

local TpValMana = Class(WgValue, function(self, inst)
    WgValue._ctor(self, inst)
    self:SetRate(-1)
    self.event = "val_mana_delta"
    self.badge = nil
    -- self.rate_mods = {}
    -- self.rate_buff = 0
    -- self.rate_mult = 1
    self.wg_val_modifier = WgValModifier(self)
    self.wg_val_modifier:RegisterMember("rate")
    self:Start()
end)

local ValBadge = Class(WgBadge, function(self, owner)
    WgBadge._ctor(self, owner)
    owner.skill_button = self.anim
    self.anim:GetAnimState():SetMultColour(234/255, 25/255, 254/255, 1)
    self.priority = -2
end)

function TpValMana:MakeBadge()
    local widget = ValBadge(self.inst)
    local Uimg = AssetUtil:MakeImg("tp_icons2", "tp_val_mana")
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

-- function TpValMana:AddRateMod(key, val)
--     self.rate_mods[key] = val
--     self.rate_buff = self:GetRateMod()
-- end

-- function TpValMana:RmRateMod(key)
--     self.rate_mods[key] = nil
--     self.rate_buff = self:GetRateMod()
-- end

-- function TpValMana:GetRateMod()
--     local val = 0
--     for k, v in pairs(self.rate_mods) do
--         val = val + v
--     end
--     return val
-- end

function TpValMana:GetRate()
    return self.rate * self:GetRateMult() + self:GetRateMod()
end

-- function TpValMana:SetRateMult(val)
--     self.rate_mult = val
-- end

function TpValMana:Start()
	if self.task == nil then
		self.task = self.inst:DoPeriodicTask(self.period, function()
            self:DoDelta(-self:GetRate())
			-- -- 满足消耗条件
			-- if self.test == nil or self.test(self.inst) then
			-- 	self:DoDelta(-self.rate)
			-- 	-- 推送消耗事件
			-- 	if self.consume_event then
			-- 		self.inst:PushEvent(self.consume_event)
			-- 	end
			-- 	-- 执行消耗函数
			-- 	if self.consume then
			-- 		self.consume(self.inst)
			-- 	end
			-- 	-- 执行消耗运行函数
			-- 	if self.run_start then
			-- 		if self.running == nil then
			-- 			self.running = true
			-- 			self.run_start(self.inst)
			-- 			-- self.inst:PushEvent(self.running_event.."_start")
			-- 		end
			-- 	end
			-- else
			-- 	-- 停止消耗运行函数
			-- 	if self.run_stop then
			-- 		if self.running then
			-- 			self.running = nil
			-- 			self.run_stop(self.inst)
			-- 			-- self.inst:PushEvent(self.running_event.."_stop")
			-- 		end
			-- 	end
			-- end
		end)
		-- print("WgValue Start")
	end
end

-- function TpValMana:GetWargonString()
--     return string.format("法力值")
-- end

return TpValMana