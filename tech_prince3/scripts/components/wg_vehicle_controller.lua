local WgVehicleController = Class(function(self, inst)
	self.inst = inst
	self.enabled = false

    self.handler = TheInput:AddGeneralControlHandler(function(control, value) self:OnControl(control, value) end)
    -- self.handler_dismount = TheInput:AddKeyDownHandler(KEY_R, function() 
    -- 	self:Dismount() 
    -- end)
    self.inst:StartUpdatingComponent(self)
    self.draggingonground = false
    self.startdragtestpos = nil
    self.startdragtime = nil

    self.reticule = nil

    self.terraformer = nil

    self.LMBaction = nil
    self.RMBaction = nil

    self.mousetimeout = 10
    self.time_direct_walking = 0

    -- 可以攻击
    self.can_attack = false
    -- 应该行走
    self.should_walk = false
end)

function WgVehicleController:IsEnabled()
	return self.enabled
end

function WgVehicleController:OnControl(control, down)

	if not self:IsEnabled() then return end
	if not IsPaused() then
		-- 鼠标右键或者CTRL和ALT键
		if self.inst and (control == CONTROL_SECONDARY or control == CONTROL_CONTROLLER_ALTACTION) then
			if not down then
				self.inst:PushEvent("rightbuttonup")
			else
				self.inst:PushEvent("rightbuttondown")
			end
		end
		-- 鼠标左键
		-- if control == CONTROL_PRIMARY then
		-- 	self:OnLeftClick(down)
		-- 	return 
		-- elseif control == CONTROL_SECONDARY then
		-- 	self:OnRightClick(down)
		-- 	return 
		-- end
	
		if down then
				--print ("CONTROL IS ", control)
			if control == nil then
			-- elseif control == CONTROL_INSPECT then
			-- 	self:DoInspectButton()
			-- elseif control == CONTROL_ACTION then
			-- 	self:DoActionButton()
			elseif control == CONTROL_ATTACK then
				self:DoAttackButton()
			-- elseif control == CONTROL_CONTROLLER_ALTACTION then
			-- 	self:DoControllerAltAction()
			-- elseif control == CONTROL_CONTROLLER_ACTION then
			-- 	self:DoControllerAction()
			-- elseif control == CONTROL_CONTROLLER_ATTACK then
			-- 	self:DoControllerAttack()
			-- elseif control == CONTROL_ROTATE_LEFT then
			elseif control == CONTROL_ROTATE_LEFT then
				-- self:DoFlipFacing("left")
				-- self:RotLeft()
			elseif control == CONTROL_ROTATE_RIGHT then					
				-- self:DoFlipFacing("right")
				-- self:RotRight()
			end
				
		end
	end
end

function WgVehicleController:DoAttackButton()
	if not self.can_attack then
		return
	end
	local attack_target = self:GetAttackTarget(TheInput:IsControlPressed(CONTROL_FORCE_ATTACK)) 			
	-- 因为会一直追击之前的目标，所以和之前一样就不打断原来的追击动作
	if attack_target and self.inst.components.combat.target ~= attack_target then
	-- if attack_target then
		local action = BufferedAction(self.inst, attack_target, ACTIONS.ATTACK)
		-- local action = BufferedAction(self.inst, attack_target, ACTIONS.FORCEATTACK)
		local can_run = self.run_attack
		self.inst.components.locomotor:PushAction(action, can_run)
	else
		return -- already doing it!
	end	
end

function WgVehicleController:GetAttackTarget(force_attack)

	local x,y,z = self.inst.Transform:GetWorldPosition()
	
	local rad = self.inst.components.combat:GetAttackRange()
	
	
	if not self.directwalking then rad = rad + 6 end --for autowalking
	
	--To deal with entity collision boxes we need to pad the radius.
	local nearby_ents = TheSim:FindEntities(x,y,z, rad + 5, nil, {"falling", "FX", "NOCLICK", "DECOR", "INLIMBO", "player"})
	-- local tool = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	-- local has_weapon = tool and tool.components.weapon 
	local has_weapon = false
	
	local playerRad = self.inst.Physics:GetRadius()
	local lastresort = nil
	for k,guy in ipairs(nearby_ents) do

	   	local guyradius = 0 
	   	if guy.Physics then
	   	 	guyradius = guy.Physics:GetRadius() 
	   	end

		if guy ~= self.inst and
		guy:IsValid() and not guy:IsInLimbo() 
		and not (guy.sg and guy.sg:HasStateTag("invisible")) 
		and guy.components.health 
		and not guy.components.health:IsDead() 
		and guy.components.combat 
		and guy.components.combat:CanBeAttacked(self.inst) 
		and not (guy.components.follower 
		and guy.components.follower.leader == self.inst) 
		--Now we ensure the target is in range.
		and distsq(guy:GetPosition(), self.inst:GetPosition()) <= math.pow(rad + playerRad + guyradius + 0.1 , 2) then
			if (guy:HasTag("monster") and has_weapon) 
			or guy:HasTag("hostile") 
			or self.inst.components.combat:IsRecentTarget(guy) 
			or guy.components.combat.target == self.inst 
			or force_attack then

				-- webber wont auto attack non hostile spiders.
				local ok = true
				if guy:HasTag("spider") and self.inst:HasTag("spiderwhisperer") then
					ok = false
					if guy.components.combat 
					and guy.components.combat.target 
					and (guy.components.combat.target == self.inst 
					or (guy.components.combat.target.components.follower 
					and guy.components.combat.target.components.follower.leader == self.inst)) then							
						ok = true
				    end
				end

				if ok or force_attack then
					if guy:HasTag("lastresort") then
						lastresort = guy
					else
						return guy
					end
				end
			end
		end
	end
	if lastresort then
		return lastresort
	end
end

function WgVehicleController:DoControllerAction()
	self.time_direct_walking = 0
	if self.deployplacer then
		if self.deployplacer.components.placer.can_build then
			local act = self.deployplacer.components.placer:GetDeployAction()
			if act.distance < 1 then 
				act.distance = 1
			end 
			self:DoAction(act)
		end
	elseif self.controller_target then
		self:DoAction( self:GetSceneItemControllerAction(self.controller_target) )
	end
end

function WgVehicleController:GetSceneItemControllerAction(item)
    local lmb, rmb = nil, nil
    
	-- local acts = self.inst.components.playeractionpicker:GetClickActions(item)
	local acts = self.inst.components.wg_vehicle_action_picker:GetClickActions(item)
	if acts and #acts > 0 then
		local action = acts[1]
		if action.action ~= ACTIONS.LOOKAT and action.action ~= ACTIONS.ATTACK and action.action ~= ACTIONS.WALKTO then
			lmb = acts[1]
		end
	end

	-- acts = self.inst.components.playeractionpicker:GetRightClickActions(item)
	acts = self.inst.components.wg_vehicle_action_picker:GetRightClickActions(item)
	if acts and #acts > 0 then
		local action = acts[1]
		if action.action ~= ACTIONS.LOOKAT and action.action ~= ACTIONS.ATTACK and action.action ~= ACTIONS.WALKTO then
			rmb = action
		end
	end
	
	if rmb and lmb and rmb.action == lmb.action then
		rmb = nil
	end
	
	return lmb, rmb
end

function WgVehicleController:DoActionButton()
	local ba = self:GetActionButtonAction()
	if ba then
		self.inst.components.locomotor:PushAction(ba, true)
	end
end

function WgVehicleController:GetActionButtonAction()
	if self.actionbuttonoverride then
		return self.actionbuttonoverride(self.inst)
	end
	if self:IsEnabled() and not (self.inst.sg:HasStateTag("working")
	or self.inst.sg:HasStateTag("doing")) then

	end
end

function WgVehicleController:Dismount()
	if self.inst.components.wg_vehicle 
	and self.inst.components.wg_vehicle.owner then
		self.inst.components.wg_vehicle:Dismount()
	end
end

function WgVehicleController:RotLeft()
	local rotamount = 45 ---90-- GetWorld():IsCave() and 22.5 or 45
	if TheCamera:CanControl() then  
		
		if IsPaused() then
			if GetWorld().minimap.MiniMap:IsVisible() then
				TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() - rotamount) 
				TheCamera:Snap()
			end
		else
			TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() - rotamount) 
			--UpdateCameraHeadings() 
		end
	end
end

function WgVehicleController:RotRight()
	local rotamount = 45 --90--GetWorld():IsCave() and 22.5 or 45
	if TheCamera:CanControl() then  
		
		if IsPaused() then
			if GetWorld().minimap.MiniMap:IsVisible() then
				TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() + rotamount) 
				TheCamera:Snap()
			end
		else
			TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() + rotamount) 
			--UpdateCameraHeadings() 
		end
	end
end

function WgVehicleController:OnRemoveEntity()
	self.handler:Remove()
	-- self.handler_dismount:Remove()
end

function WgVehicleController:Enable(val)
	self.enabled = val
end

function WgVehicleController:UpdateControllerInteractionTarget(dt)
	if self.controller_target and (not self.controller_target:IsValid() or self.controller_target:IsInLimbo() or self.controller_target:HasTag("NOCLICK")) then
		self.controller_target = nil
	end

	if self.placer or ( self.deployplacer and self.deploy_mode ) then
		self.controller_target = nil
		self.controllertargetage = 0
		return
	end

	if self.controllertargetage then
		self.controllertargetage = self.controllertargetage + dt
	end

	if self.controllertargetage and self.controllertargetage < .2 then return end

	local heading_angle = -(self.inst.Transform:GetRotation())
	local dir = Vector3(math.cos(heading_angle*DEGREES),0, math.sin(heading_angle*DEGREES))

	local me_pos = Vector3(self.inst.Transform:GetWorldPosition())

	local inspect_rad = .75
	local min_rad = 1.5
	local max_rad = 6
	local rad = max_rad
	if self.controller_target and self.controller_target:IsValid() then
		local dsq = self.inst:GetDistanceSqToInst(self.controller_target)
		rad = math.max(min_rad, math.min(rad, math.sqrt(dsq)))
	end

	local x,y,z = me_pos:Get()

	local nearby_ents = TheSim:FindEntities(x,y,z, rad, nil, {"FX", "NOCLICK", "DECOR", "INLIMBO"})

	if self.controller_target and not self.controller_target:IsInLimbo() then
		table.insert(nearby_ents, self.controller_target) --may double add.. should be harmless?
	end


	local target = nil
	local target_score = nil
	local target_action = nil
	local target_dist = nil

	local lastresort = nil

	for k,v in pairs(nearby_ents) do
		if v ~= self.inst then
		
			local px,py,pz = v.Transform:GetWorldPosition()
			local ox,oy,oz = px - me_pos.x, py-me_pos.y, pz-me_pos.z
			local dsq = ox*ox + oy*oy +oz*oz

			local already_target = self.controller_target == v or self.controller_attack_target == v
									
			local should_consider = dsq < min_rad*min_rad or
									(ox*dir.x + oy*dir.y +oz*dir.z) > 0 or
									already_target
									
			

			if dsq > max_rad*max_rad then
				should_consider = false
			end

			if should_consider then

				local dist = dsq > 0 and math.sqrt(dsq) or 0

				local dot = 0
				if dist > 0 then
					local nx, ny, nz = ox/dist, oy/dist, oz/dist
					dot = nx*dir.x + ny*dir.y + nz*dir.z
				end
				
				--keep the angle component between [0..1]
				local angle_component = (dot + 1)/2
				
				--distance doesn't matter when you're really close, and then attenuates down from 1 as you get farther away
				local dist_component = dsq < min_rad*min_rad and 1 or (1 / (dsq/(min_rad*min_rad)))
				local add = 0
				
				--for stuff that's *really* close - ie, just dropped
				if dsq < .25*.25 then
					add = 1
				end
				local mult = 1
				
				if v == self.controller_target and not v:HasTag("wall") then
					mult = 1.5--just a little hysteresis
				end
				
				local score = angle_component*dist_component*mult + add
				
				--print (v, angle_component, dist_component, mult, add, score)
				
				if not target_score or score > target_score or not target_action then
					
					--this is kind of expensive, so ideally we don't get here for many objects
					local l,r = self:GetSceneItemControllerAction(v)
					local action = l or r

					-- if not action then
					-- 	local inv_obj = self:GetCursorInventoryObject()
					-- 	if inv_obj then
					-- 		action = self:GetItemUseAction(inv_obj, v)
					-- 	end
					-- end
					if v:HasTag("lastresort") then
						lastresort = v
					elseif ((action or (v.components.inspectable and not v.components.inspectable.inspectdisabled) ) and (not target_score or score > target_score)) --better real action
					   --or ((action or v.components.inspectable) and ((not target or (target and not target_action)) )) --it's inspectable, so it's better than nothing
					   --or (target and not target_action and action and not( dist > inspect_rad and target_dist < inspect_rad))  --replacing an inspectable with an actual action
						then
							target = v
							target_dist = dist
							target_score = score
							target_action = action
					end
				end
			end
		end
	end

	if not target and lastresort then
		target = lastresort
	end
	if target ~= self.controller_target then
		self.controller_target = target
		self.controllertargetage = 0
	end
	
end

function WgVehicleController:OnUpdate(dt)
	if self:IsEnabled() then

		if not self.inst.sg:HasStateTag("busy") then
			
			if self.draggingonground then
				local pt = TheInput:GetWorldPosition()
				local dst = distsq(pt, Vector3(self.inst.Transform:GetWorldPosition()))

				if dst > 1 then
					local angle = self.inst:GetAngleToPoint(pt)
					self.inst:ClearBufferedAction()
					if self.should_walk then
						-- print("should walk")
						self.inst.components.locomotor:WalkInDirection(angle, false)
					else
						-- print("should run")
						self.inst.components.locomotor:RunInDirection(angle)
					end
				end
				self.directwalking = false
			else
				-- print("direct walk")
				-- 按键控制移动
		        self:DoDirectWalking(dt)
			end
	    end

	    -- self:UpdateControllerInteractionTarget(dt)
	    if not self.inst.sg:HasStateTag("busy") 
	    and not self.directwalking then
	    	if TheInput:IsControlPressed(CONTROL_ATTACK) then
				self:OnControl(CONTROL_ATTACK, true)
			-- elseif TheInput:IsControlPressed(CONTROL_CONTROLLER_ATTACK) then
			-- 	self:OnControl(CONTROL_CONTROLLER_ATTACK, true)
			end
		end
	end
end

function WgVehicleController:GetWorldControllerVector()
	local xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
	local ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
	local deadzone = .3

	if math.abs(xdir) < deadzone and math.abs(ydir) < deadzone then xdir = 0 ydir = 0 end
	if xdir ~= 0 or ydir ~= 0 then
	    local CameraRight = TheCamera:GetRightVec()
		local CameraDown = TheCamera:GetDownVec()
		local dir = CameraRight * xdir - CameraDown * ydir
		dir = dir:GetNormalized()
		return dir
	end
end

function WgVehicleController:DoDirectWalking(dt)
	if self.inst.components.locomotor.bufferedaction ~= nil then
		if self.inst.components.locomotor.bufferedaction.action.overrides_direct_walk then
			return
		end
	end

	if self.inst.bufferedaction ~= nil then
		if self.inst.bufferedaction.action.overrides_direct_walk then
			return
		end
	end

	local dir = self:GetWorldControllerVector()
	if dir then
		local ang = -math.atan2(dir.z, dir.x)/DEGREES

		self.inst:ClearBufferedAction()
		self.inst.components.locomotor:SetBufferedAction(nil)
		if self.should_walk then
			self.inst.components.locomotor:WalkInDirection(ang)
		else
			self.inst.components.locomotor:RunInDirection(ang)
		end
		if not self.directwalking then
			self.time_direct_walking = 0
		end

		self.directwalking = true

		self.time_direct_walking = self.time_direct_walking + dt

		if self.time_direct_walking > .2 then
			if not self.inst.sg:HasStateTag("attack") then
				self.inst.components.combat:SetTarget(nil)
			end
		end
	else
		if self.directwalking then
			self.inst.components.locomotor:Stop() --bargle
			self.directwalking = false
		end
	end
end

-- function WgVehicleController:WalkButtonDown()
-- 	return  TheInput:IsControlPressed(CONTROL_MOVE_UP) or TheInput:IsControlPressed(CONTROL_MOVE_DOWN) or TheInput:IsControlPressed(CONTROL_MOVE_LEFT) or TheInput:IsControlPressed(CONTROL_MOVE_RIGHT)
-- end

-- function WgVehicleController:OnLeftUp()
    
--     if not self:IsEnabled() then return end    

-- 	if self.draggingonground then
		
-- 		if not self:WalkButtonDown() then
-- 			self.inst.components.locomotor:Stop() --bargle
-- 		end
-- 		self.draggingonground = false
-- 		TheFrontEnd:LockFocus(false)
-- 	end
-- 	self.startdragtime = nil
	
-- end

-- function WgVehicleController:OnLeftClick(down)
    
--     if not self:UsingMouse() then return end
    
-- 	if not down then return self:OnLeftUp() end

--     self.startdragtime = nil

--     if not self:IsEnabled() then return end
    
--     if TheInput:GetHUDEntityUnderMouse() then
-- 		return 
--     end
    
--     self.inst.components.combat.target = nil
    
--     if self.inst.inbed then
--         self.inst.inbed.components.bed:StopSleeping()
--         return
--     end
    
--     local action = self:GetLeftMouseAction()
--     if action then
-- 	    self:DoAction( action )
-- 	else
-- 		local endPos = TheInput:GetWorldPosition() 
-- 		if not self.inst.components.driver:GetIsDriving() and self.inst:GetIsOnWater(endPos.x, endPos.y, endPos.z) then 
-- 			local stoppos = nil--position 
--             local myPos = self.inst:GetPosition()
--             local dir = (endPos - myPos):GetNormalized()
--             local dist = (endPos - myPos):Length()
--             local step = 0.25
--             local numSteps = dist/step

--             for i = 0, numSteps, 1 do 
--                 local testPos = myPos + dir * step * i 
--                 local testTile = GetWorld().Map:GetTileAtPoint(testPos.x , testPos.y, testPos.z) 
--                 if GetWorld().Map:IsWater(testTile) then
--                     if i > 0 then  
--                         stoppos =  myPos + dir * (step * (i - 1))
--                     else  
--                         stoppos =  myPos + dir * (step * i)
--                     end 
--                     endPos = stoppos
--                     break
--                 end 
--             end 
-- 		end 

-- 		self:DoAction( BufferedAction(self.inst, nil, ACTIONS.WALKTO, nil, endPos) ) 		
-- 	    local clicked = TheInput:GetWorldEntityUnderMouse()
-- 	    if not clicked then
-- 	        self.startdragtime = GetTime()
-- 	    end
--     end
    
-- end

return WgVehicleController