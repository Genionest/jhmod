local WgReticule = Class(function(self, inst)
	self.inst = inst
	-- self.spellfn = nil
	-- self.canspell = true

	self.reticule_prefab = 'wg_reticuleline'
	-- self.trigger_action = ACTIONS.DO_ANIM_ATK

	self.inst:ListenForEvent('unequipped',function()self:KillReticule();end)
end)

-- function WgReticule:CanCast(doer)
-- 	if doer.components.driver and doer.components.driver:GetIsDriving() then
-- 		return false
-- 	end
-- 	return self.canspell
-- end

-- function WgReticule:SetCanSpell(enabled)
--     self.canspell = enabled
--     if not enabled then
--     	self:HideReticule()
--     end
-- end

-- function WgReticule:SetSpellFn(fn)
--     self.spellfn = fn
-- end

-- function WgReticule:CastSpell(doer, pos)
--     if self.spellfn ~= nil then
--         self.spellfn(self.inst,doer, pos)
-- 	end
-- 	self:HideReticule()
-- end

function WgReticule:Toggle()
    if self:IsShown() then
        self:HideReticule()
    else
        self:ShowReticule()
    end
end

function WgReticule:IsShown()
    return self.shown
end

function WgReticule:ShowReticule()
	-- 将其他装备的指示器隐藏
	local owner = self.inst.components.equippable.owner
	for k, v in pairs(owner.components.inventory.equipslots) do
		if v.components.wg_reticule 
		and v.components.wg_reticule:IsShown() then
			v.components.wg_reticule:HideReticule()
		end
	end

	self.shown = true
	if self.reticule and self.reticule:IsValid() then
		self.reticule:Show()
	else
		self.reticule = SpawnPrefab(self.reticule_prefab) --SetDebugEntity(self.reticule)
		self.reticule:DoPeriodicTask(0,function(inst)
			inst:UpdatePosition(self.inst:GetPosition(), self.inst:GetAngleToPoint(TheInput:GetWorldPosition()))
		end)
	end
end

function WgReticule:HideReticule()
	self.shown = false
	if self.reticule and self.reticule:IsValid() then
		self.reticule:Hide()
	else
		self.reticule = nil
	end
end

-- function WgReticule:OnRightClick(canshow)
-- 	if self.shown then
-- 		self:HideReticule()
-- 	elseif canshow and self:CanCast(self.inst) then
-- 		self:ShowReticule()
-- 	end
-- end

function WgReticule:KillReticule()
	self.shown = false
	if self.reticule then
		self.reticule:Remove()
		self.reticule = nil
	end
end

function WgReticule:OnRemoveEntity()
	self:KillReticule()
end

-- function WgReticule:CollectPointActions(doer, pos, actions, right)
-- 	if not right and self:CanCast(doer) and self.shown then
-- 		table.insert(actions, self.trigger_action)
-- 	end
-- end

-- function WgReticule:CollectEquippedActions(doer, target, actions, right)
-- 	local pos = target:GetPosition()
-- 	if pos then
-- 		return self:CollectPointActions(doer, pos, actions, right)
-- 	end
-- end

return WgReticule


