local Projectile = require "components/projectile"

local TpProjectile = Class(Projectile, function(self, inst)
    Projectile._ctor(self, inst)
end)

function TpProjectile:CollectSceneActions(doer, actions)
    -- local catcher = doer.components.catcher
    -- if self.cancatch and self:IsThrown() and catcher and catcher:CanCatch() then
    --     table.insert(actions, ACTIONS.CATCH)
    -- end
end

function TpProjectile:CanAction()
    if self.inst.components.tprecharge then
        return self.inst.components.tprecharge:IsRecharged()
    end
    return true
end

function TpProjectile:CollectEquippedActions(doer, target, actions, right)
    if right and target.components.combat and self:CanAction()
    and doer.components.combat:CanTarget(target) then
        table.insert(actions, ACTIONS.TP_RENG)
    end
end

function TpProjectile:Hit(target)
    local attacker = self.owner
    local weapon = self.inst
    self:Stop()
    self.inst.Physics:Stop()
    if not attacker.components.combat and attacker.components.weapon and attacker.components.inventoryitem then
        weapon = attacker
        attacker = weapon.components.inventoryitem.owner
    end
    local damage = 0
    if weapon.components.weapon then
        damage = weapon.components.weapon.damage
    end
    if attacker and attacker.components.combat 
    and attacker ~= target then
        -- attacker.components.combat:DoAttackattacker.components.combat:Get(target, weapon, self.inst)
        target.components.combat:GetAttacked(attacker, damage, weapon, 'tp_projectile')
    end
    
    if target == attacker then
        if self.oncatch then
            self.oncatch(self.inst, attacker)
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

return TpProjectile
