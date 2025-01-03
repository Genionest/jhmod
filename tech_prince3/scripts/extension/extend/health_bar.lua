-- local FollowText = require "widgets/followtext"
-- local UIAnim = require "widgets/uianim"
-- local Text = require "widgets/text"
-- local Widget = require "widgets/widget"

-- local HealthBar = Class(FollowText, function(self)
--     FollowText._ctor(self, TALKINGFONT, 35)
--     self.hp_bg = self:AddChild(Widget("HealthBarBg"))
--     self.health = self.hp_bg:AddChild(UIAnim())
--     self.health:GetAnimState():SetBank("tp_health_bar")
--     self.health:GetAnimState():SetBuild("tp_health_bar")
--     self.health:GetAnimState():SetMultColour(1,1,1,.5)
--     -- self.health:GetAnimState():PlayAnimation("h1")
--     self.sheild = self.hp_bg:AddChild(UIAnim())
--     self.sheild:GetAnimState():SetBuild("tp_health_bar")
--     self.sheild:GetAnimState():SetBank("tp_health_bar")
--     self.sheild:GetAnimState():SetMultColour(1,1,1,.5)
--     self.sheild:Hide()
--     self.hp_txt = self.hp_bg:AddChild(Text(TALKINGFONT, 35))
-- end)

-- local function set_health_bar(cmp)
    
-- end

-- local function health_bar_delta(widget, p, txt)
--     widget.health:GetAnimState():SetPercent("h2", p)
--     widget.hp_txt:SetString(txt)
-- end

-- local function on_health_delta(inst, data)
--     local cmp = inst.components.health
--     local max = cmp:GetMaxHealth()
--     local dt = (data.newpercent - data.oldpercent) * max
--     if math.abs(dt) < 1 then
--         return
--     end
--     -- local p = math.min(.999, 1-data.newpercent)
--     local p = 1-data.newpercent
--     local txt = string.format("%d/%d", cmp.currenthealth, cmp:GetMaxHealth())
--     local widget = inst.components.wg_follow_widget:GetWidget()
--     inst.components.wg_follow_widget:Execute()
--     if widget == nil then
--         local scale = 1
--         if inst:HasTag("epic") then
--             inst.components.wg_follow_widget.offset = Vector3(0, -1000, 0)
--             scale = 1.2
--         elseif inst:HasTag("largecreature") then
--             inst.components.wg_follow_widget.offset = Vector3(0, -700, 0)
--             scale = 1
--         elseif inst:HasTag("smallcreature") then
--             inst.components.wg_follow_widget.offset = Vector3(0, -300, 0)
--             scale = .5
--         else
--             inst.components.wg_follow_widget.offset = Vector3(0, -500, 0)
--             scale = .8
--         end


--         inst.components.wg_follow_widget:SetWidget(HealthBar(), function(widget)
--             widget.hp_bg:SetScale(scale)
--             health_bar_delta(widget, p, txt)
--         end)
--     else
--         health_bar_delta(widget, p, txt)
--     end
--     if cmp.tp_bar_task then
--         cmp.tp_bar_task:Cancel()
--         cmp.tp_bar_task = nil
--     end
--     cmp.tp_bar_task = cmp:DoTaskInTime(10, function()
--         inst.components.wg_follow_widget:Hide()
--     end)
-- end

-- AddComponentPostInit("health", function(self)
--     self.inst:AddComponent("wg_follow_widget")
--     self.tp_sleep = nil
--     self.inst:ListenForEvent("death", function(inst, data)
--         -- 死亡血条消失
--         inst.components.wg_follow_widget:Kill()
--     end)
--     local OnEntityWake = self.OnEntityWake
--     function self:OnEntityWake()
--         if OnEntityWake then
--             OnEntityWake(self)
--         end
--         self.tp_sleep = true
--         self.inst:ListenForEvent("healthdelta", on_health_delta)
--     end
--     local OnEntitySleep = self.OnEntitySleep
--     function self:OnEntitySleep()
--         if OnEntitySleep then
--             OnEntitySleep(self)
--         end
--         if self.tp_sleep then
--             self.tp_sleep = nil
--             self.inst:RemoveEventCallback("healthdelta", on_health_delta)
--         end
--     end
-- end)