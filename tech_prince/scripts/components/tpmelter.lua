--local cooking = require("smelting")
local Melter = require "components/melter"

local TpMelter = Class(Melter, function(self, inst)
	Melter._ctor(self, inst)
	self.spoiledproduct = "tp_spear_mix"
    self.min_num_for_cook = 3
    self.max_num_for_cook = 3
    self.tp_ings = {}
end)

-- local TpMelter = Class(function(self, inst)
--     self.inst = inst
--     self.cooking = false
--     self.done = false
    
--     self.product = nil
--     self.product_spoilage = nil
--     self.recipes = nil
--     self.default_recipe = nil
--     self.spoiledproduct = "tp_alloy"
--     self.maketastyfood = nil
    
--     self.min_num_for_cook = 4
--     self.max_num_for_cook = 4

--     self.cookername = nil

--     -- stuff to make warly's special recipes possible
--     self.specialcookername = nil	-- a special cookername to check first before falling back to cookername default
--     self.productcooker = nil		-- hold on to the cookername that is cooking the current product

--     self.inst:AddTag("stewer")
-- end)

-- local function dospoil(inst)
-- 	if inst.components.tpmelter and inst.components.tpmelter.onspoil then
-- 		inst.components.tpmelter.onspoil(inst)
-- 	end

--     if inst.components.tpmelter.spoiltask then
--         inst.components.tpmelter.spoiltask:Cancel()
--         inst.components.tpmelter.spoiltask = nil
--         inst.components.tpmelter.spoiltargettime = nil
--     end
-- end

local function dostew(inst)
	local stewercmp = inst.components.tpmelter
	stewercmp.task = nil
	
	if stewercmp.ondonecooking then
		stewercmp.ondonecooking(inst)
	end
--[[
	if stewercmp.product ~= nil then 
		local cooker = stewercmp.productcooker or (stewercmp.cookername or stewercmp.inst.prefab)
		local prep_perishtime = (cooking.recipes and cooking.recipes[cooker] and cooking.recipes[cooker][stewercmp.product] and cooking.recipes[cooker][stewercmp.product].perishtime) and cooking.recipes[cooker][stewercmp.product].perishtime or TUNING.PERISH_SUPERFAST
		local prod_spoil = stewercmp.product_spoilage or 1
		stewercmp.spoiltime = prep_perishtime * prod_spoil
		stewercmp.spoiltargettime =  GetTime() + stewercmp.spoiltime
		stewercmp.spoiltask = stewercmp.inst:DoTaskInTime(stewercmp.spoiltime, function(inst)
			if inst.components.tpmelter and inst.components.tpmelter.onspoil then
				inst.components.tpmelter.onspoil(inst)
			end
		end)
	end
	]]
	stewercmp.done = true
	stewercmp.cooking = nil
end

-- function TpMelter:SetCookerName(_name)
-- 	self.cookername = _name
-- end

-- function TpMelter:GetTimeToCook()
-- 	if self.cooking then
-- 		return self.targettime - GetTime()
-- 	end
-- 	return 0
-- end


function TpMelter:CanCook()
	local num = 0
	for k,v in pairs (self.inst.components.container.slots) do
		num = num + 1 
	end
	return num >= self.min_num_for_cook and num <= self.max_num_for_cook
		and self.product == nil
end


function TpMelter:StartCooking()
	if not self.done and not self.cooking then
		if self.inst.components.container then
		
			self.done = nil
			self.cooking = true
			
			if self.onstartcooking then
				self.onstartcooking(self.inst)
			end
		
			

			local spoilage_total = 0
			local spoilage_n = 0
			-- local ings = {}	
			-- for k,v in pairs (self.inst.components.container.slots) do
			-- 	table.insert(ings, v.prefab)
			-- end		
			-- self.ings = ings
			--[[
			local foundthespecial = false
			local cooktime = 1
			if self.specialcookername then
				-- check special first
				if cooking.ValidRecipe(self.specialcookername, ings) then
					self.product, cooktime = cooking.CalculateRecipe(self.specialcookername, ings)
					self.productcooker = self.specialcookername
					foundthespecial = true
				end
			end

			if not foundthespecial then
				-- fallback to regular cooking
				local cooker = self.cookername or self.inst.prefab
				self.product, cooktime = cooking.CalculateRecipe(cooker, ings)
				self.productcooker = cooker
			end
 			]]
			self.product = "tp_spear_mix"
			local cooktime = 0.2
			self.productcooker = self.inst.prefab
			
			local grow_time = TUNING.BASE_COOK_TIME * cooktime
			self.targettime = GetTime() + grow_time
			self.task = self.inst:DoTaskInTime(grow_time, dostew, "stew")

			self.inst.components.container:Close()
			-- self.inst.components.container:DestroyContents()
			self.inst.components.container.canbeopened = false
		end
		
	end
end

-- function TpMelter:OnSave()
--     local time = GetTime()
--     if self.cooking then
-- 		local data = {}
-- 		data.cooking = true
-- 		data.product = self.product
-- 		data.productcooker = self.productcooker
-- 		data.product_spoilage = self.product_spoilage
-- 		if self.targettime and self.targettime > time then
-- 			data.time = self.targettime - time
-- 		end
-- 		return data
--     elseif self.done then
-- 		local data = {}
-- 		data.product = self.product
-- 		data.productcooker = self.productcooker
-- 		data.product_spoilage = self.product_spoilage
-- 		if self.spoiltargettime and self.spoiltargettime > time then
-- 			data.spoiltime = self.spoiltargettime - time
-- 		end
-- 		data.timesincefinish = -(GetTime() - (self.targettime or 0))
-- 		data.done = true
-- 		return data		
--     end
-- end

function TpMelter:OnLoad(data)
    --self.produce = data.produce
    if data.cooking then
		self.product = data.product
		self.productcooker = data.productcooker or (self.cookername or self.inst.prefab)
		if self.oncontinuecooking then
			local time = data.time or 1
			self.product_spoilage = data.product_spoilage or 1
			self.oncontinuecooking(self.inst)
			self.cooking = true
			self.targettime = GetTime() + time
			self.task = self.inst:DoTaskInTime(time, dostew, "stew")
			
			if self.inst.components.container then		
				self.inst.components.container.canbeopened = false
			end
			
		end
    elseif data.done then
		self.product_spoilage = data.product_spoilage or 1
		self.done = true
		self.targettime = data.timesincefinish
		self.product = data.product
		self.productcooker = data.productcooker or (self.cookername or self.inst.prefab)
		if self.oncontinuedone then
			self.oncontinuedone(self.inst)
		end
		self.spoiltargettime = data.spoiltime and GetTime() + data.spoiltime or nil
		if self.spoiltargettime then
			self.spoiltask = self.inst:DoTaskInTime(data.spoiltime, function(inst)
				if inst.components.tpmelter and inst.components.tpmelter.onspoil then
					inst.components.tpmelter.onspoil(inst)
				end
			end)
		end
		if self.inst.components.container then		
			self.inst.components.container.canbeopened = false
		end
		
    end
end

-- function TpMelter:GetDebugString()
--     local str = nil
    
-- 	if self.cooking then 
-- 		str = "COOKING" 
-- 	elseif self.done then
-- 		str = "FULL"
-- 	else
-- 		str = "EMPTY"
-- 	end
--     if self.targettime then
--         str = str.." ("..tostring(self.targettime - GetTime())..")"
--     end
    
--     if self.product then
-- 		str = str.. " ".. self.product
--     end
    
--     if self.product_spoilage then
-- 		str = str.."("..self.product_spoilage..")"
--     end
    
-- 	return str
-- end

-- function TpMelter:CollectSceneActions(doer, actions, right)
-- 	if not doer.components.rider or not doer.components.rider:IsRiding() then
-- 		if not self.inst:HasTag("burnt") then
-- 		    if self.done then
-- 		        table.insert(actions, ACTIONS.HARVEST)
-- 		    elseif right and self:CanCook() then
-- 				table.insert(actions, ACTIONS.COOK)
-- 		    end
-- 		end
-- 	end
-- end

-- function TpMelter:IsDone()
-- 	return self.done
-- end

-- function TpMelter:StopCooking(reason)
-- 	if self.task then
-- 		self.task:Cancel()
-- 		self.task = nil
-- 	end
-- 	if self.spoiltask then
-- 		self.spoiltask:Cancel()
-- 		self.spoiltask = nil
-- 	end
-- 	if self.product and reason and reason == "fire" then
-- 		local prod = SpawnPrefab(self.product)
-- 		if prod then
-- 			prod.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
-- 			prod:DoTaskInTime(0, function(prod) prod.Physics:Stop() end)
-- 		end
-- 	end
-- 	self.product = nil
-- 	self.targettime = nil
-- end


function TpMelter:Harvest( harvester )
	print("HERE?")
	if self.done then
		if self.onharvest then
			self.onharvest(self.inst)
		end
		self.done = nil
		if self.product then
			if harvester and harvester.components.inventory then
				local loot = nil
				loot = SpawnPrefab("tp_spear_mix")
				local ings = {}
				for k,v in pairs(self.inst.components.container.slots) do
					local insert = true
					for k1, v1 in pairs(ings) do
						if v1 == v.prefab then
							insert = false
							break
						end
					end
					if insert then
						table.insert(ings, v.prefab)
					end
				end	
				self.inst.components.container:DestroyContents()
				if loot.components.tpmixweapon then
					loot.components.tpmixweapon:SetWeapons(ings)
				end
				-- loot.components.stackable:SetStackSize(4)
				--[[
				if self.product ~= "spoiledfood" then
					loot = SpawnPrefab(self.product)
					if loot and loot.components.perishable then
						loot.components.perishable:SetPercent( self.product_spoilage)
						loot.components.perishable:LongUpdate(GetTime() - self.targettime)
						loot.components.perishable:StartPerishing()
					end
				else
					loot = SpawnPrefab("spoiled_food")
				end
				]]	
				if loot then  
					harvester.components.inventory:GiveItem(loot, nil, Vector3(TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition())))
				end
			end
			self.product = nil
			self.spoiltargettime = nil

			if self.spoiltask then 
				self.spoiltask:Cancel()
				self.spoiltask = nil
			end
		end
		
		if self.inst.components.container and not self.inst:HasTag("flooded") then		
			self.inst.components.container.canbeopened = true
		end
		
		return true
	end
end

function TpMelter:LongUpdate(dt)
    if not self.paused and self.targettime ~= nil then
		if self.task ~= nil then
			self.task:Cancel()
			self.task = nil
		end

        self.targettime = self.targettime - dt

        if self.cooking then
            local time_to_wait = self.targettime - GetTime()
            if time_to_wait < 0 then
                dostew(self.inst)
            else
                self.task = self.inst:DoTaskInTime(time_to_wait, dostew, "stew")
            end
        end
    end

	if self.spoiltask ~= nil then
		self.spoiltask:Cancel()
		self.spoiltask = nil
        self.spoiltargettime = self.spoiltargettime - dt
		local time_to_wait = self.spoiltargettime - GetTime()
		if time_to_wait <= 0 then
			dospoil(self.inst)
		else
			self.spoiltask = self.inst:DoTaskInTime(time_to_wait, dospoil)
		end
	end
end

return TpMelter
