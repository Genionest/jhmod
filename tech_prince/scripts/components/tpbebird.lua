local TpBeBird = Class(function(self, inst)
	self.inst = inst
	self.bird = nil
end)

function TpBeBird:CanChange()
	local inst = self.inst
    return not (inst.components.stewer.done 
        or inst.components.stewer.cooking) and (self.bird ~= nil)
end

function TpBeBird:BeBird()
	if not self:CanChange() then
		return
	end
	self.inst:RemoveChild(self.bird)
    self.bird:ReturnToScene()
    self.bird.components.tpbepot.cookpot = nil
	if self.bird.Physics ~= nil then
        self.bird.Physics:Teleport(self.inst.Transform:GetWorldPosition())
    else
        self.bird.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
    end
	if self.bird.components.brain ~= nil then
        BrainManager:Wake(self.bird)
    end
    if not self.bird.components.health:IsDead() then
        self.bird.sg:GoToState("wake")
    end
    self.inst.components.container:DropEverything()
	-- WARGON.make_fx(self.inst, "collapse_small")
	self.inst:Remove()
end

function TpBeBird:OnSave()
	local data = {}
    if self.bird ~= nil then
        data.bird = self.bird:GetSaveRecord()
    end
    return data
end

function TpBeBird:OnLoad(data)
	 if data and data.bird ~= nil then
        self.bird = SpawnSaveRecord(data.bird)
        self.bird.components.tpbepot:Hide()
        self.inst:AddChild(self.bird)
        self.bird.components.cookpot = self.inst
    end
end

function TpBeBird:CollectSceneActions(doer, actions, right)
	if right and self:CanChange() then
		table.insert(actions, ACTIONS.TP_CHANGE)
	end
end

return TpBeBird