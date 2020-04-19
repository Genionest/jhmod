local buling_system = Class(function(self, inst)
    self.inst = inst
end)


function buling_system:OnRead(reader)
    if self.onread then
        return self.onread(self.inst, reader)
    end

    return true
end

function buling_system:CollectSceneActions(doer, actions)
    if doer.components.reader then
        table.insert(actions, ACTIONS.READ)
    end
end

function buling_system:CollectInventoryActions(doer, actions)
    if doer.components.reader then
        table.insert(actions, ACTIONS.BULING_STSTEM)
    end
end

return buling_system