local TpBePot = Class(function(self, inst)
	self.inst = inst
	self.pot = "tp_cook_pot"
	self.cookpot = nil
end)

function TpBePot:CanChange()
	return true
end

function TpBePot:Hide()
	self.inst:RemoveFromScene()
	self.inst.Transform:SetPosition(0,0,0)
	if self.inst.components.brain ~= nil then
        BrainManager:Hibernate(self.inst)
    end
    if self.inst.SoundEmitter ~= nil then
        self.inst.SoundEmitter:KillAllSounds()
    end
end

function TpBePot:BePot()
	if not self:CanChange() then
		return 
	end
	local inst = self.inst
	if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
	else
		inst.sg:GoToState('sleep')
		WARGON.do_task(inst, .75, function()
			-- WARGON.make_fx(inst, "collapse_small")
			local pos = inst:GetPosition()
			self:Hide()
			local pot = WARGON.make_spawn(pos, self.pot)
			pot.components.tpbebird.bird = inst
			pot:AddChild(self.inst)
			self.cookpot = pot
		end)
    end
end

function TpBePot:OnSave()
	return {hide=self.hide}
end

function TpBePot:OnLoad(data)
	if data.hide then
		self.hide = data.hide
	end
end

function TpBePot:CollectSceneActions(doer, actions, right)
	if right and self:CanChange() then
		table.insert(actions, ACTIONS.TP_CHANGE)
	end
end

return TpBePot