local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Button = require "widgets/button"

local function frozenPrefab(target)
    if not target:IsValid() or target:HasTag("player") then
        return
    end
    -- if target.sg ~= nil and not target.sg:HasStateTag("frozen") then
    --     target:PushEvent("attacked", { attacker = attacker, damage = 0 })
    -- end
    if target.components.freezable then
        target.components.freezable:AddColdness(4)
        target.components.freezable:SpawnShatterFX()
        -- 能冻住才有这些
        if target.components.burnable then
            if target.components.burnable:IsBurning() then
                target.components.burnable:Extinguish()
            elseif target.components.burnable:IsSmoldering() then
                target.components.burnable:SmotherSmolder()
            end
        end
        if target.components.sleeper and target.components.sleeper:IsAsleep() then
            target.components.sleeper:WakeUp()
        end
    end
end

local function spawnFrozen(inst)
    if inst.prefab == 'monkey_king'
    and inst.components.monkeymana:EnoughMana(100) then
        -- SpawnPrefab("mk_jgb_rec").Transform:SetPosition(inst:GetPosition():Get())
        inst.components.talker:Say("定————")
        local x, y, z = inst.Transform:GetWorldPosition()
        local targets = TheSim:FindEntities(x, y, z, 10)
        for i, v in pairs(targets) do
            frozenPrefab(v)
        end
    end
end

local Mk_Frozen_UI = Class(Widget, function(self, owner)
	Widget._ctor(self, "Mk_Frozen_UI")
	self.owner = owner
	self.badge = self:AddChild(UIAnim())
    self.badge:GetAnimState():SetBank("ice")
    self.badge:GetAnimState():SetBuild("ice")
    self.badge:GetAnimState():PlayAnimation("f1")
    self.badge:SetScale(.26)
    SetDebugEntity(self.badge.inst)
    self.name = self:AddChild(Text(BODYTEXTFONT,20,("定身法儿")))
    self.name:SetPosition(0,-30,0)
end)

function Mk_Frozen_UI:OnControl(control, down) 
    if not self:IsEnabled() or not self.focus then return end
    if control == CONTROL_ACCEPT then
        if down then
            self:ScaleTo(1,0.9,1/15)
            self.down = true
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        elseif self.down then
            self:ScaleTo(0.9,1,1/15)
            self.down = false
            spawnFrozen(self.owner)
        end
        return true
    end
end

return Mk_Frozen_UI