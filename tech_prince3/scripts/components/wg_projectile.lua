local EntUtil = require "extension/lib/ent_util"
local Projectile = require "components/projectile"

local WgProjectile = Class(Projectile, function(self, inst)
    Projectile._ctor(self, inst)
    self.inst:DoTaskInTime(10, function()
        self:Miss(self.target)
    end)
end)

function WgProjectile:CollectSceneActions(doer, actions)
    -- local catcher = doer.components.catcher
    -- if self.cancatch and self:IsThrown() and catcher and catcher:CanCatch() then
    --     table.insert(actions, ACTIONS.CATCH)
    -- end
end

function WgProjectile:Test(target, doer)
    -- 标记检测到直接无
    if target:HasTag("wg_not_projected") then
        return
    end
    -- 冷却未到直接无
    if self.inst.components.wg_recharge 
    and not self.inst.components.wg_recharge:IsRecharged() then
        return
    end
    if not (target.components.combat 
    and doer.components.combat:CanTarget(target)) then
        return
    end
    if self.test then
        return self.test(self.inst, target, doer)
    end
    return true
end

function WgProjectile:CollectEquippedActions(doer, target, actions, right)
    if right and self:Test(target, doer)
     then
        table.insert(actions, ACTIONS.WG_PROJECT)
    end
end

function WgProjectile:Hit(target)
    local attacker = self.owner
    local weapon = self.inst
    self:Stop()
    self.inst.Physics:Stop()
    if not attacker.components.combat and attacker.components.weapon and attacker.components.inventoryitem then
        weapon = attacker
        attacker = weapon.components.inventoryitem.owner
    end
    local damage = 0
    local true_weapon = nil
    if weapon.components.weapon then
        true_weapon = weapon
        damage = weapon.components.weapon:GetDamage()
    end
    print("a001", damage, attacker, target)
    if damage>0 and attacker and attacker.components.combat 
    and attacker ~= target then
        print("a002")
        -- attacker.components.combat:DoAttackattacker.components.combat:Get(target, weapon, self.inst)
        -- target.components.combat:GetAttacked(attacker, damage, weapon, 'wg_projectile')
        local rate = attacker.components.combat:GetDamageModifier()
        local stimuli = EntUtil:add_stimuli(nil, "wg_projectile")
        if weapon.components.weapon and weapon.components.weapon.dmg_type then
            print("a003")
            EntUtil:add_stimuli(stimuli, weapon.components.weapon.dmg_type)
        end
        EntUtil:get_attacked(target, attacker, damage*rate, true_weapon, stimuli)
    end
    
    if target == attacker then
        if self.oncaught then
            self.oncaught(self.inst, attacker)
        end
        if self.inst.components.finiteuses then
            self.inst.components.finiteuses:Use()
        end
    else
        if self.onhit then
            self.onhit(self.inst, attacker, target, weapon)
        end
    end
end

return WgProjectile
