local Kit = require "extension.lib.wargon"
local EntUtil = require "extension.lib.ent_util"

local function vehicle_push_event(inst, event)
	local vehicle = inst.components.wg_vehicle_owner and inst.components.wg_vehicle_owner.vehicle
	if vehicle then
		vehicle:PushEvent(event)
	end
end

local events = {
	"locomote",
	-- "",
}
local listen_fns = {
}

local WgVehicle = Class(function(self, inst)
	self.inst = inst
	self.owner = nil
	self.on_mount = nil  -- 上车触发的函数
	self.on_mounted = nil  -- 上车后触发的函数
	self.on_dismount = nil  -- 下车触发的函数
	self.on_death = nil  -- 死亡时触发的函数
	self.need_jump_mount = nil  -- 需要跳进跳出
	self.inst.components.combat.canbeattackedfn = function(inst, attacker)
		return self.owner ~= attacker
	end
	self.inst:ListenForEvent("death", function(inst, data)
		if self.owner then
			self:Dismount()
			if self.on_death then
				self.on_death(self.inst, self.owner)
			end
		end
	end)
	self.inst:AddTag("wg_not_projected")
end)

function WgVehicle:Mount(doer, is_load)
	local inst = self.inst
	if self.redirect_mount then
		self.redirect_mount(self.inst, doer)
	else
		if EntUtil:is_alive(doer) then
			if self.on_mount then
				self.on_mount(self.inst, doer)
			end
			doer.components.wg_vehicle_owner:SetVehicle(self.inst)
			self.owner = doer
			-- doer:AddTag("wg_not_combat")
			doer:AddTag("wg_driving_vehicle")
			-- if not self.inst:HasTag("wg_vehicle_no_locomotor") then
			-- 	self.locomotor = doer.components.locomotor
			-- 	doer.components.locomotor = inst.components.locomotor
			-- end
			-- if not self.inst:HasTag("wg_vehicle_no_combat") then
			-- 	self.combat = doer.components.combat
			-- 	doer.components.combat = inst.components.combat
			-- end
			if is_load then
				doer:DoTaskInTime(0, function()
					doer.HUD.controls.crafttabs:Hide()
					doer:Hide()
					-- doer.AnimState:SetMultColour(0, 0, 0, 0)
					-- 不能用这个，玩家会无法操作下车
					-- doer:RemoveFromScene()
					doer.DynamicShadow:Enable(false)
				end)
			else
				doer.HUD.controls.crafttabs:Hide()
				-- doer.HUD.controls.inv:Hide()
				-- doer.HUD.controls.status:Hide()
				doer:Hide()
				-- doer.AnimState:SetMultColour(0, 0, 0, 0)
				-- doer:RemoveFromScene()
				doer.DynamicShadow:Enable(false)
				-- doer.sg:Stop()
			end
			doer.entity:SetParent(self.inst.entity)
			doer.Transform:SetPosition(0, 0, 0)
			doer.Physics:SetActive(false)
			-- doer.components.playercontroller:Enable(false)
			self.inst.components.wg_vehicle_controller:Enable(true)
			-- self.inst.entity:SetParent(doer.entity)
			-- self:TransmitEvent("locomote", doer)
			-- 能量开始消耗
			if self.inst.components.wg_energy then
				self.inst.components.wg_energy:Start()
			end
			doer:PushEvent("wg_mount", {vehicle = self.inst})
			if self.on_mounted then
				self.on_mounted(self.inst, doer)
			end
		end
	end
end

function WgVehicle:Dismount(target_pos)
	-- print("down car")
	local doer = self.owner
	local inst = self.inst
	if self.redirect_dismount then
		self.redirect_dismount(self.inst, doer)
	else
		-- if EntUtil:is_alive(doer) then
			doer.components.wg_vehicle_owner:SetVehicle(nil)
			self.owner = nil
			-- if not self.inst:HasTag("wg_vehicle_no_locomotor") then
			-- 	doer.components.locomotor = self.locomotor
			-- 	self.locomotor = nil
			-- end11
			-- if not self.inst:HasTag("wg_vehicle_no_combat") then
			-- 	doer.components.combat = self.combat
			-- 	self.combat = nil
			-- end
			doer:Show()
			-- doer.AnimState:SetMultColour(1, 1, 1, 1)
			-- doer:ReturnToScene()
			doer.DynamicShadow:Enable(true)
			-- doer:RemoveTag("wg_not_combat")
			doer:RemoveTag("wg_driving_vehicle")
			doer.HUD.controls.crafttabs:Show()
			-- doer.HUD.controls.inv:Show()
			-- doer.HUD.controls.status:Show()
			doer.entity:SetParent(nil)
			doer.Physics:SetActive(true)
			-- doer.sg:Start()
			-- doer.components.playercontroller:Enable(true)
			self.inst.components.wg_vehicle_controller:Enable(false)
			-- self.inst.entity:SetParent(nil)
			-- self:ObstructEvent("locomote", doer)
			-- 能量停止消耗
			if self.inst.components.wg_energy then
				self.inst.components.wg_energy:Stop()
			end
			-- 停止移动
			if self.inst.components.locomotor then
				self.inst.components.locomotor:Stop()
			end
			doer:PushEvent("wg_dismount", {vehicle = self.inst})
			if self.on_dismount then
				self.on_dismount(self.inst, doer)
			end
			if self.need_jump_mount and target_pos then
				local pos = self.inst:GetPosition()
				doer.Transform:SetPosition(pos:Get())
				doer.sg:GoToState("wg_jump_dismount", target_pos)
			else
				local pos = Kit:find_walk_pos(self.inst, 1)
				if pos then
					doer.Transform:SetPosition(pos:Get())
				end
			end
		-- end
	end
end

function WgVehicle:DoDefaultMount(doer)
	doer.components.playercontroller.actionbuttonoverride = function(inst)
		return BufferedAction(inst, inst.components.wg_vehicle_owner.vehicle, ACTIONS.WG_DISMOUNT)
	end
	doer.components.playeractionpicker.leftclickoverride = function(inst, target, pos)
		if target and target.components.wg_vehicle
		and target.components.wg_vehicle:CanDismount() then
			return inst.components.playeractionpicker:SortActionList({ACTIONS.WG_DISMOUNT}, target, nil)
		end
	end
	doer.components.playeractionpicker.rightclickoverride = function(inst, target, pos) 
		return {} 
	end
end

function WgVehicle:DoDefaultDismount(doer)
	doer.components.playercontroller.actionbuttonoverride = nil
	doer.components.playeractionpicker.leftclickoverride = nil
	doer.components.playeractionpicker.rightclickoverride = nil
end

function WgVehicle:TransmitEvent(event, target)
	self.inst:ListenForEvent(event, listen_fns[event], target)
end

function WgVehicle:ObstructEvent(event, target)
	self.inst:RemoveEventCallback(event, listen_fns[event], target)
end

function WgVehicle:CanMount(doer)
	if not (doer.components.rider and doer.components.rider:IsRiding())
	and not (doer.components.driver and doer.components.driver:GetIsDriving())
	and	doer.components.wg_vehicle_owner 
	and not doer.components.wg_vehicle_owner:IsDriving()
	and self.owner == nil then
		return true
	end
end

function WgVehicle:CanDismount()
	if self.owner and self.owner.components.wg_vehicle_owner
	and self.owner.components.wg_vehicle_owner.vehicle == self.inst 
	and not self.need_jump_mount then
		return true
	end
end

function WgVehicle:CollectSceneActions(doer, actions, right)
	if right then
		if self:CanMount(doer) then
			if self.need_jump_mount then
				table.insert(actions, ACTIONS.WG_JUMP_MOUNT)
			else
				table.insert(actions, ACTIONS.WG_MOUNT)
			end
		elseif self:CanDismount() then
			table.insert(actions, ACTIONS.WG_DISMOUNT)
		end
	end
end

function WgVehicle:OnSave()
	local data = {}
	local refs = {}
	if self.owner then
		table.insert(refs, self.owner.GUID)
		data.owner = self.owner.GUID
	end
	return data, refs
end

function WgVehicle:LoadPostPass(ents, data)
	if data.owner and ents[data.owner] then
		local owner = ents[data.owner].entity
		self:Mount(owner, true)
	end
end

function WgVehicle:OnLoad(data)
end

return WgVehicle