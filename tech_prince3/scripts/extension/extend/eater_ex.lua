local Info = Sample.Info


-- 食物食用收益, 食用时的额外效果
local function fn(self)
	-- 慢消化
	if self.inst:HasTag("player") then
		self.healthabsorption = 0  
		self.hungerabsorption = 0
		self.sanityabsorption = 0
		self.tp_healthabsorption = 1  
		self.tp_hungerabsorption = 1
		self.tp_sanityabsorption = 1
		self.tp_health_dt = nil
		self.tp_hunger_dt = nil
		self.tp_sanity_dt = nil
	end
	local SetAbsorptionModifiers = self.SetAbsorptionModifiers
	function self:SetAbsorptionModifiers(health, hunger, sanity)
		if self.inst:HasTag("player") then
			-- 慢消化	
			self:AddHealthAbsorptionMod("eater", health)
			self:AddHungerAbsorptionMod("eater", hunger)
			self:AddSanityAbsorptionMod("eater", sanity)
		else
			self.healthabsorption = health
			self.hungerabsorption = hunger
			self.sanityabsorption = sanity
		end
	end
	function self:AddHealthAbsorptionMod(key, val)
		if self.health_mods == nil then
			self.health_mods = {}
		end
		self.health_mods[key] = val
		-- 慢消化
		self.tp_healthabsorption = self:GetHealthAbsorptionMod()
	end
	function self:AddSanityAbsorptionMod(key, val)
		if self.sanity_mods == nil then
			self.sanity_mods = {}
		end
		self.sanity_mods[key] = val
		-- 慢消化
		self.tp_sanityabsorption = self:GetSanityAbsorptionMod()
	end
	function self:AddHungerAbsorptionMod(key, val)
		if self.hunger_mods == nil then
			self.hunger_mods = {}
		end
		self.hunger_mods[key] = val
		-- 慢消化
		self.tp_hungerabsorption = self:GetHungerAbsorptionMod()
	end
	function self:RmHealthAbsorptionMod(key)
		if self.health_mods then
			self.health_mods[key] = nil
		end
		-- 慢消化
		self.tp_healthabsorption = self:GetHealthAbsorptionMod()
	end
	function self:RmSanityAbsorptionMod(key)
		if self.sanity_mods then
			self.sanity_mods[key] = nil
		end
		-- 慢消化
		self.tp_sanityabsorption = self:GetSanityAbsorptionMod()
	end
	function self:RmHungerAbsorptionMod(key)
		if self.hunger_mods then
			self.hunger_mods[key] = nil
		end
		-- 慢消化
		self.tp_hungerabsorption = self:GetHungerAbsorptionMod()
	end
	function self:GetHealthAbsorptionMod()
		local mod = 1
		if self.health_mods then
			for k, v in pairs(self.health_mods) do
				mod = mod + v
			end
		end
		return mod
	end
	function self:GetSanityAbsorptionMod()
		local mod = 1
		if self.sanity_mods then
			for k, v in pairs(self.sanity_mods) do
				mod = mod + v
			end
		end
		return mod
	end
	function self:GetHungerAbsorptionMod()
		local mod = 1
		if self.hunger_mods then
			for k, v in pairs(self.hunger_mods) do
				mod = mod + v
			end
		end
		return mod
	end
	
	self.tp_eat_time = 0  -- 消化时间
	self.tp_eat_time_max = Info.Attr.EatTime
	local Eat = self.Eat
	function self:Eat(food)
		-- 慢消化
		if self.inst:HasTag("player") and self:CanEat(food) then
			local stack_mult = self.eatwholestack and food.components.stackable ~= nil and food.components.stackable:StackSize() or 1
	
			if not self:IsDigesting() then
				self.cause = nil
				local hp_dt = 0
				local hg_dt = 0
				local san_dt = 0
				if self.inst.components.health and not self.inst:HasTag("donthealfromfood") then
					if (food.components.edible.healthvalue < 0 and self:DoFoodEffects(food) or food.components.edible.healthvalue > 0) and self.inst.components.health then
						local delta = food.components.edible:GetHealth(self.inst) * self.tp_healthabsorption
						-- self.tp_health_dt = delta* stack_mult/self.tp_eat_time_max
						hp_dt = delta * stack_mult
						self.cause = food.prefab
					end
				end
				if self.inst.components.hunger then
					local delta = food.components.edible:GetHunger(self.inst) * self.tp_hungerabsorption
					if delta ~= 0 then
						-- self.tp_hunger_dt = delta* stack_mult/self.tp_eat_time_max
						hg_dt = delta * stack_mult
						self.cause = food.prefab
					end
				end
				
				if (food.components.edible.sanityvalue < 0 and self:DoFoodEffects(food) or food.components.edible.sanityvalue > 0) and self.inst.components.sanity then
					local delta = food.components.edible:GetSanity(self.inst) * self.tp_sanityabsorption
					if delta ~= 0 then
						-- self.tp_sanity_dt = delta* stack_mult/self.tp_eat_time_max
						san_dt = delta * stack_mult
						self.cause = food.prefab
					end
				end
				if self.cause then
					local eat_time = self.tp_eat_time_max
					local total = math.abs(hp_dt) + math.abs(hg_dt) + math.abs(san_dt)
					if total <= 8 then
						eat_time = eat_time/3
					elseif total <= 18 then
						eat_time = eat_time*2/3
					end
					eat_time = math.ceil(eat_time)
					if hp_dt ~= 0 then
						self.tp_health_dt = hp_dt/eat_time
					end
					if hg_dt ~= 0 then
						self.tp_hunger_dt = hg_dt/eat_time
					end
					if san_dt ~= 0 then
						self.tp_sanity_dt = san_dt/eat_time
					end
					self:Digestion(eat_time)
				end
			end
	
		end
		return Eat(self, food)
	end
	-- 慢消化
	function self:IsDigesting()
		return self.tp_eat_task ~= nil
	end
	-- 慢消化
	function self:Digestion(time)
		self.tp_eat_time = time
		self.tp_eat_task = self.inst:DoPeriodicTask(1, function()
			self.tp_eat_time = self.tp_eat_time - 1
			if self.tp_health_dt then
				self.inst.components.health:DoDelta(self.tp_health_dt, true, self.cause)
			end
			if self.tp_hunger_dt then
				self.inst.components.hunger:DoDelta(self.tp_hunger_dt, true)
			end
			if self.tp_sanity_dt then
				self.inst.components.sanity:DoDelta(self.tp_sanity_dt, true)
			end
			if self.tp_eat_time <= 0 then
				self.tp_eat_task:Cancel()
				self.tp_eat_task = nil
				self.tp_health_dt = nil
				self.tp_hunger_dt = nil
				self.tp_sanity_dt = nil
			end
		end)
	end
	function self:OnSave()
		-- 慢消化
		local data = {}
		data.tp_eat_time = self.tp_eat_time
		data.tp_health_dt = self.tp_health_dt
		data.tp_hunger_dt = self.tp_hunger_dt
		data.tp_sanity_dt = self.tp_sanity_dt
		data.cause = self.cause
		return data
	end
	function self:OnLoad(data)
		if data then
			-- 慢消化
			self.tp_eat_time = data.tp_eat_time or 0
			self.tp_health_dt = data.tp_health_dt
			self.tp_hunger_dt = data.tp_hunger_dt
			self.tp_sanity_dt = data.tp_sanity_dt
			self.cause = data.cause
			if self.tp_eat_time > 0 then
				self:Digestion(self.tp_eat_time)
			end
		end
	end
	
	self.wg_eat_fns = nil
	self.inst:ListenForEvent("oneat", function(inst, data)
		if self.wg_eat_fns then
			for k, v in pairs(self.wg_eat_fns) do
				v(inst, data.food)
			end
		end
	end)
	function self:AddOnEatFn(key, fn)
		if self.wg_eat_fns == nil then
			self.wg_eat_fns = {}
		end
		self.wg_eat_fns[key] = fn
		return fn
	end
	function self:RmOnEatFn(key)
		if self.wg_eat_fns then
			self.wg_eat_fns[key] = nil
		end
	end
	
	function self:GetWargonString()
		if self:IsDigesting() then
			return string.format("消化食物中(%ds)", self.tp_eat_time)
		end
	end
	function self:GetWargonStringColour()
		return {1, 1, 0, 1}
	end
end
AddComponentPostInit("eater", fn)