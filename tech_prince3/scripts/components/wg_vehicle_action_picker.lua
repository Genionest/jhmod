local WgVehicleActionPicker = Class(function(self, inst)
	self.inst = inst
	self.pointspecialactionsfn = nil
end)

function WgVehicleActionPicker:SortActionList(actions, target, useitem)

    if #actions > 0 then
        table.sort(actions, function(l, r) return l.priority > r.priority end)
        local ret = {}

        for k,v in ipairs(actions) do
            if not target then
                table.insert(ret, BufferedAction(self.inst, nil, v, useitem))
            elseif target:is_a(EntityScript) then
                table.insert(ret, BufferedAction(self.inst, target, v, useitem))
            elseif target:is_a(Vector3) then
                local quantizedTarget = target 
                local distance = nil 

                --If we're deploying something it might snap to a grid, if so we want to use the quantized position as the target pos 
                if v == ACTIONS.DEPLOY and useitem.components.deployable then 
                    distance = useitem.components.deployable.deploydistance
                    quantizedTarget = useitem.components.deployable:GetQuantizedPosition(target)
                end

                local ba = BufferedAction(self.inst, nil, v, useitem, quantizedTarget)
                if distance then 
                    ba.action.distance = distance 
                end 
                table.insert(ret, ba)
            end
        end
        return ret
    end
end

function WgVehicleActionPicker:GetSceneActions(targetobject, right)
	local actions = {}
    local cansee = true

    if GetPlayer().components.vision 
    and not GetPlayer().components.vision.focused 
	and not GetPlayer().components.vision:testsight(targetobject) then
        cansee = false
    end
    
    for k,v in pairs(targetobject.components) do
        if v.CollectSceneActions and (cansee or v.nearsited_ok ) then
            v:CollectSceneActions(self.inst, actions, right)
        end
    end

	if targetobject.inherentsceneaction and not right then
		table.insert(actions, targetobject.inherentsceneaction)
	end

	if targetobject.inherentscenealtaction and right then
		table.insert(actions, targetobject.inherentscenealtaction)
	end

    if #actions == 0 and targetobject.components.inspectable then
        table.insert(actions, ACTIONS.WALKTO)
    end
    return self:SortActionList(actions, targetobject)
end

function WgVehicleActionPicker:GetClickActions( target_ent, position )

    local isTargetAquatic = false 
    local isCursorWet = false 
    local isBoating = false
    -- local isBoating = self.inst.components.driver:GetIsDriving()

    if position then
        isCursorWet = self.inst:GetIsOnWater(position.x, position.y, position.z)
    end 

    -- local isBoating = self.inst.components.driver:GetIsDriving()
    local interactingWithBoat = false
    
    if target_ent then 
        isTargetAquatic = target_ent:HasTag("aquatic")
    end 

    if self.leftclickoverride then
        return self.leftclickoverride(self.inst, target_ent, position)
    end

    local actions = nil
    -- local useitem = self.inst.components.inventory:GetActiveItem()
    -- local equipitem = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    -- local equipitemhead = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    -- local boatitem = self.inst.components.driver and self.inst.components.driver.vehicle and self.inst.components.driver.vehicle.components.container and self.inst.components.driver.vehicle.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)
    local useitem = nil
    local equipitem = nil
    local equipitemhead = nil
    local boatitem = nil

    local passable = true
    if not self.ground then
        self.ground = GetWorld()
    end

    if position and self.ground and self.ground.Map then
        local tile = self.ground.Map:GetTileAtPoint(position.x, position.y, position.z)
        passable = tile ~= GROUND.IMPASSABLE
    end

    --if we're specifically using an item, see if we can use it on the target entity
    if target_ent then

        local target = target_ent
        if target_ent.playerpickerproxy then
            target = target_ent.playerpickerproxy
        end

        --if we're clicking on a scene entity, see if we can use our equipped object on it, or just use it
        -- if self:ShouldForceInspect() and target.components.inspectable then
        --     actions = self:SortActionList({ACTIONS.LOOKAT}, target, nil)
        -- elseif self:ShouldForceAttack() and self.inst.components.combat:CanTarget(target) then
        --     actions = self:SortActionList({ACTIONS.ATTACK}, target, nil)
        -- end
        
        if actions == nil or #actions == 0 then
			actions = self:GetSceneActions(target)
        end
    end
    
    --Are we in a boat and hovering over land? 
    if position then
        
    end

    if not actions and position and not target_ent and passable then
		
    end

    return actions or {}
end

function WgVehicleActionPicker:GetRightClickActions( target_ent, position, leftaction )
    local isTargetAquatic = false 
    local isCursorWet = false 
    -- local isBoating = self.inst.components.driver:GetIsDriving()
    local isBoating = false

    if position then 
        isCursorWet = self.inst:GetIsOnWater(position.x, position.y, position.z)
    end

    -- local isBoating = self.inst.components.driver:GetIsDriving()
    local interactingWithBoat = false

    if self.rightclickoverride then
        return self.rightclickoverride(self.inst, target_ent, position)
    end

    local actions = nil
    -- local useitem = self.inst.components.inventory:GetActiveItem()
    -- local equipitem = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    -- local equipitemhead = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    -- local boatitem = self.inst.components.driver and self.inst.components.driver.vehicle and self.inst.components.driver.vehicle.components.container and self.inst.components.driver.vehicle.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)
    local useitem = nil
    local equipitem = nil
    local equipitemhead = nil
    local boatitem = nil

    local passable = true
    if not self.ground then
        self.ground = GetWorld()
    end

    if position and self.ground and self.ground.Map then
        local tile = self.ground.Map:GetTileAtPoint(position.x, position.y, position.z)
        passable = tile ~= GROUND.IMPASSABLE
    end

    --if we're specifically using an item, see if we can use it on the target entity
    if target_ent then
        --if we're clicking on a scene entity, see if we can use our equipped object on it, or just use it
        if not actions then
            actions = self:GetSceneActions(target_ent, true)
        end
    end

    --this is to make it so you don't auto-drop equipped items when you click the ground. kinda ugly.

    -- if(isBoating and not isCursorWet and not TheInput:ControllerAttached() and (target_ent == nil or not target_ent:HasTag("aquatic"))) then 
    --     if not actions or #actions == 0 or (#actions > 0 and not actions[1].action.instant and not actions[1].action.crosseswaterboundary) then
    --             actions = nil
    --     end
    -- end

    -- if isCursorWet and not isBoating and not TheInput:ControllerAttached()  and not interactingWithBoat and (target_ent == nil or target_ent:HasTag("aquatic")) then 
    --     if not actions or #actions == 0 or (#actions > 0 and not actions[1].action.instant and not actions[1].action.crosseswaterboundary) then
    --         actions = nil
    --     end
    -- end

    if (actions == nil or #actions <= 0) and target_ent == nil and passable then
        actions = self:GetPointSpecialActions(position, useitem, true)
    end

    return actions or {}
end

function WgVehicleActionPicker:GetPointSpecialActions(pos, useitem, right)
    return self.pointspecialactionsfn ~= nil and self:SortActionList(self.pointspecialactionsfn(self.inst, pos, useitem, right), pos) or {}
end

return WgVehicleActionPicker