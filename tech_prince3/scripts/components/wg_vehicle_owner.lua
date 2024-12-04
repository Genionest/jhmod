local WgVehicleOwner = Class(function(self, inst)
	self.inst = inst
	self.vehicle = nil
	self.inst:ListenForEvent("death", function(inst, data)
		if self.vehicle and self.vehicle.components.wg_vehicle then
			self.vehicle.components.wg_vehicle:Dismount()
		end
	end)
end)

function WgVehicleOwner:SetVehicle(vehicle)
	self.vehicle = vehicle
	self.inst:PushEvent("wg_change_vehicle", {vehicle = vehicle})
end

function WgVehicleOwner:IsDriving()
	return self.vehicle ~= nil
end

function WgVehicleOwner:OnSave()
	-- local data = {}
	-- if self.vehicle then
	-- 	data.vehicle = self.vehicle:GetSaveRecord()
	-- end
	-- return data
end

function WgVehicleOwner:OnLoad(data)
	-- if data and data.vehicle then
	-- 	local vehicle = SpawnSaveRecord(data.vehicle)
	-- 	self.inst:DoTaskInTime(0, function()
	-- 		vehicle.components.tpvehicle:UpCar(self.inst)
	-- 	end)
	-- end
end

return WgVehicleOwner