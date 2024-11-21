local TpThrow = Class(function(self, inst)
	self.inst = inst
	self.speed = 20
	self.yOffset = 1
	self.onthrown = nil
end)

function TpThrow:CanThrowAtPoint(pos)
	return true
end

function TpThrow:CanAction()
	if self.inst.components.tprecharge then
        return self.inst.components.tprecharge:IsRecharged()
    end
    return true
end

function TpThrow:CollectPointActions(doer, pos, actions, right)
    if right then
		if self:CanThrowAtPoint(pos) and self:CanAction() then
			table.insert(actions, ACTIONS.TP_TOU)
		end
	end
end

function TpThrow:CollectEquippedActions(doer, target, actions, right)
	if right and self:CanThrowAtPoint(target:GetPosition()) and self:CanAction() then
		table.insert(actions, ACTIONS.TP_TOU)
	end
end

function TpThrow:Throw(pt, thrower)
	if not self:CanThrowAtPoint(pt) then
		return false
	end

	local tothrow = self.inst

	if thrower and self.inst.components.inventoryitem and self.inst.components.inventoryitem:IsHeldBy(thrower) then
		tothrow = thrower.components.inventory:DropItem(self.inst, false, nil, nil, false)
	end

	local yOffset = self.yOffset
	local pos = self.inst:GetPosition()
	local offset = Vector3(0, yOffset, 0)

	tothrow.Transform:SetPosition((pos + offset):Get()) 
    tothrow.Physics:SetVel(0, self.speed, 0)

	if self.onthrown then
		self.onthrown(tothrow, thrower, pt)
	end

	return true
end

return TpThrow