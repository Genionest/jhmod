local darkmonster = Class(function(self, inst)
	local function OnAttack(inst,data)
		if data.target and data.target.components.health then
			local target = data.target
			local darkdef = 0
			if target.components.darklevel then
				darkdef = target.components.darklevel.def
			end
			local darkdamage = self.atk
			if darkdef ~= 0 then
				darkdamage = darkdamage - darkdef
				if darkdamage <= 0 then
					darkdamage = 0
				end
			end
			target.components.health:DoDelta(-darkdamage)
			target:PushEvent("attacked", { attacker = inst, damage = 0 })
		end
	end
	inst.persists = false
	self.inst = inst
	self.atk = 10
	inst:AddTag("shadowcreature")
	inst.AnimState:SetMultColour(0,0,0,.5)
	if inst.components.combat then
		local combat = inst.components.combat
		local oldGetAttacked = combat.GetAttacked
		combat.GetAttacked = function(self,attacker, damage, weapon, stimuli)
			if not stimuli  or stimuli ~= "dark" then
				return  false
			end
			return oldGetAttacked(self,attacker, damage, weapon, stimuli)
		end
		self.atk = inst.components.combat.defaultdamage
		inst:DoTaskInTime(0.1,function() inst.components.combat.defaultdamage = 0 end) 
		inst:ListenForEvent("onattackother", OnAttack)
	end
	if not inst.components.lootdropper then
		inst:AddComponent("lootdropper")
	end
	inst.components.lootdropper.randomloot = nil
	inst.components.lootdropper:SetChanceLootTable('nightmare_creature')
end)
return darkmonster