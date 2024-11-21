AddComponentPostInit("sleepingbag", function(self)
	local old_scene = self.CollectSceneActions
	function self:CollectSceneActions(doer, actions)
		if doer and doer:HasTag("player") and not doer:HasTag("insomniac") then
			if self.inst:HasTag("tp_sea_sleep") 
			and WARGON.on_water(self.inst) then
				table.insert(actions, ACTIONS.TP_SEA_SLEEP)
			else
				old_scene(self, doer, actions)
			end
	    end
	end
end)

AddComponentPostInit("dryable", function(self)
	local old_use = self.CollectUseActions
	function self:CollectUseActions(doer, target, actions)
		if not target:HasTag("burnt") then
	        if target.components.dryer and target.components.dryer:CanDry(self.inst) then
	            if target:HasTag("tp_sea_dryer") 
	            and WARGON.on_water(target) then
		            table.insert(actions, ACTIONS.TP_SEA_DRY)
		        else
		        	old_use(self, doer, target, actions)
		        end
	        end
	    end
	end
end)

AddComponentPostInit("propagator", function(self)
	local old_update = self.OnUpdate
	function self:OnUpdate(dt)
		if not self.inst:HasTag("INTERIOR_LIMBO") then   
	        if self.currentheat > 0 then
	            self.currentheat = self.currentheat - dt*self.decayrate
	        end
	        if self.spreading then 
	            local pos = Vector3(self.inst.Transform:GetWorldPosition())
	            local prop_range = self.propagaterange
	            if (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then prop_range = prop_range * TUNING.SPRING_FIRE_RANGE_MOD end
	            local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, prop_range, nil, {"FX", "NOCLICK", "DECOR", "INLIMBO"})
	            
	            for k,v in pairs(ents) do
	                if not v:IsInLimbo() then
	    			    if v ~= self.inst and v.components.propagator and v.components.propagator.acceptsheat then
	                        v.components.propagator:AddHeat(self.heatoutput*dt)
	    			    end
	                    if v ~= self.inst and v.components.freezable then
	                        v.components.freezable:AddColdness((-self.heatoutput/4)*dt)
	                        if v.components.freezable:IsFrozen() and v.components.freezable.coldness <= 0 then
	                            if v.sg then
	                            	v.sg:GoToState("thaw")
	                        	end
	                            v.components.freezable:Unfreeze()
	                        end
	                    end
	                    if v ~= self.inst and v:HasTag("frozen") and not (self.inst.components.heater and self.inst.components.heater.iscooler) then
	                        v:PushEvent("firemelt")
	                        if not v:HasTag("firemelt") then v:AddTag("firemelt") end
	                    end
	    			    if self.damages and v.components.health and v.components.health.vulnerabletoheatdamage then
	    				    local dsq = distsq(pos, Vector3(v.Transform:GetWorldPosition()))
	                        local dmg_range = self.damagerange*self.damagerange
	                        if (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then dmg_range = dmg_range * TUNING.SPRING_FIRE_RANGE_MOD end
	    				    if dsq < dmg_range then
	    					    --local percent_damage = math.min(.5, 1- (math.min(1, dsq / self.damagerange*self.damagerange)))
	    					    v.components.health:DoFireDamage(self.heatoutput*dt)
	    				    end
	    			    end
	    			end
	            end
	        end 
	        if not self.spreading and not (self.inst.components.heater and self.inst.components.heater.iscooler) then
	            local pos = Vector3(self.inst.Transform:GetWorldPosition())
	            local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, self.propagaterange, {"frozen", "firemelt"})
	            if #ents > 0 then
	                for k,v in pairs(ents) do
	                    v:PushEvent("stopfiremelt")
	                    v:RemoveTag("firemelt")
	                end
	            end
	            if self.currentheat <= 0 then
	                self:StopUpdating()
	            end
	        end
	    end
	end
end)

AddComponentPostInit("hunter", function(self)
	table.insert(self.alternate_beast_prefab, "tp_blue_warg")
	table.insert(self.alternate_beast_prefab, "tp_red_warg")
end)

AddComponentPostInit("health", function(self)
	local old_delta = self.DoDelta
	function self:DoDelta(amount, ...)
		if amount > 0 and self.inst:HasTag("tp_wound") then
			amount = amount - amount * .5
		end
		if amount < 0 and self.inst.components.tpbody then
		-- 	if self.inst:HasTag("tp_armor_broken") then
		-- 		amount = amount - amount*self.inst.components.tpbody.absorb*.5
		-- 	else
				local absorb = self.inst.components.tpbody:GetAbsorbModifier()
				amount = math.min(0, amount - absorb * amount)
			-- end
		end
		-- if amount < 0 and self.inst:HasTag("tp_armor_broken")
		-- and self.absorb < 1 then
		-- 	amount = amount + (amount*self.absorb*.5)
		-- end
		old_delta(self, amount, ...)
	end
	local old_kill = self.Kill
	function self:Kill(cause)
		if self.inst:HasTag("ironlord") == false then
			old_kill(self, cause)
		end
	end
	local old_fire = self.DoFireDamage
	function self:DoFireDamage(amount, doer, instant)
		if self.inst.components.tpbody then
			amount = amount * self.inst.components.tpbody.fire
			old_fire(self, amount, doer, instant)
		end
	end
	local old_set_max = self.SetMaxHealth
	function self:SetMaxHealth(amount)
		if not self.inst:HasTag("player") then
			local add_years = WARGON.get_years() - 1
			local extra = 0
			if add_years > 2 then
				extra = 1 + (add_years-2)*.1
			else
				extra = add_years * .5
			end
			amount = amount + amount*extra
		end
		old_set_max(self, amount)
	end
	local old_penalty = self.RecalculatePenalty
	function self:RecalculatePenalty(...)
		old_penalty(self, ...)
		local extra = self.inst.components.tpbody and self.inst.components.tpbody.health_penalty or 0
		self.penalty = self.penalty + extra
		self:DoDelta(0, nil, "resurrection_penalty")
	end
	self.invincible_cause = {}
	local old_invincible = self.SetInvincible
	function self:SetInvincible(val, cause)
		cause = cause or "health"
		self.invincible_cause[cause] = val
		local is_invincible = false
		if val then
			is_invincible = true
		else
			for k, v in pairs(self.invincible_cause) do
				if v then 
					is_invincible = true 
				end
			end
		end
		old_invincible(self, is_invincible)
	end
end)

AddComponentPostInit("armor", function(self)
	local old_take = self.TakeDamage
	function self:TakeDamage(damage_amount, attacker, weapon)
		local invitem = self.inst.components.inventoryitem
		local owner = invitem and invitem.owner
		if owner and owner:HasTag("tp_armor_broken") then
			if self:CanResist(attacker, weapon) then
		        local leftover = damage_amount
		        
		        local max_absorbed = damage_amount * self.absorb_percent/2;
		        local absorbed = math.floor(math.min(max_absorbed, self.condition))
		        -- we said we were going to absorb something so we will
		        if absorbed < 1 then
		            absorbed = 1
		        end
		        leftover = damage_amount - absorbed
		        ProfileStatsAdd("armor_absorb", absorbed)
		        
		        if METRICS_ENABLED then
					FightStat_Absorb(absorbed)
				end

		        if self.bonussanitydamage then
		            local sanitydamage = absorbed * self.bonussanitydamage
		            if self.inst.components.equippable and self.inst.components.equippable:IsEquipped() and self.inst.components.equippable.equipper then
		                self.inst.components.equippable.equipper.components.sanity:DoDelta(-sanitydamage)
		            end                
		        end

		        self:SetCondition(self.condition - absorbed)
				if self.ontakedamage then
					self.ontakedamage(self.inst, damage_amount, absorbed, leftover)
				end


		        self.inst:PushEvent("armorhit")

		        if self.absorb_percent >= 1 then
		            return 0
		        end

		        return leftover
		    else
		        return damage_amount
		    end
		else
			return old_take(self, damage_amount, attacker, weapon)
		end
	end
end)

AddComponentPostInit("projectile", function(self)
	local old_throw = self.Throw
	function self:Throw(owner, target, attacker)
		if self.speed_z then
			self.owner = owner
		    self.target = target
		    self.start = Vector3(owner.Transform:GetWorldPosition() )
		    self.dest = Vector3(target.Transform:GetWorldPosition() )

		    local offset = self.launchoffset
		    print('throwing '..tostring(attacker)..", "..tostring(offset))
		    if attacker and offset then
		        local pos = self.inst:GetPosition()
		        local facing_angle = attacker.Transform:GetRotation()*DEGREES
		        local offset_vec = Vector3(offset.x * math.cos( facing_angle ), offset.y, -offset.x * math.sin( facing_angle ))
		        print("facing", facing_angle)
		        print("offset", offset)
		        print("vec", offset_vec)
		        pos = pos + offset_vec
		        self.inst.Transform:SetPosition( pos:Get() )
		    elseif target and offset then
		        local pos = self.inst:GetPosition()
		        local facing_angle = target.Transform:GetRotation()*DEGREES
		        local offset_vec = Vector3(offset.x * math.cos( facing_angle ), offset.y, -offset.x * math.sin( facing_angle ))
		        print("facing", facing_angle)
		        print("offset", offset)
		        print("vec", offset_vec)
		        pos = pos + offset_vec
		        self.inst.Transform:SetPosition( pos:Get() )
		    end
		    if self.vertical then 
		         self.inst.Physics:SetVel(0, self.speed, self.speed_z)
		    else 
		        self:RotateToTarget(self.dest)
		        self.inst.Physics:SetMotorVel(self.speed,0,self.speed_z)
		    end 
		    self.inst:StartUpdatingComponent(self)
		    self.inst:PushEvent("onthrown", {thrower = owner, target = target})
		    target:PushEvent("hostileprojectile",{thrower = owner, attacker = attacker, target = target})
		    if self.onthrown then
		        self.onthrown(self.inst, owner, target)
		    end
		    if self.cancatch and target.components.catcher then
		        target.components.catcher:StartWatching(self.inst)
		    end
		else
			old_throw(self, owner, target, attacker)
		end
	end
end)

AddComponentPostInit("lootdropper", function(self)
	local old_loot = self.GenerateLoot
	local chance_fix = GetPlayer().components.tpbody and GetPlayer().components.tpbody:GetLucky() or 0
	function self:GenerateLoot()
		local loots = {}
		
		if self.numrandomloot and math.random() <= (self.chancerandomloot or 1) then
			for k = 1, self.numrandomloot do
				local loot = self:PickRandomLoot()
				if loot then
					table.insert(loots, loot)
				end
			end
		end
		
		if self.chanceloot then
			for k,v in pairs(self.chanceloot) do
				if math.random() < v.chance + chance_fix then
					table.insert(loots, v.prefab)
					self.droppingchanceloot = true
				end
			end
		end

		if self.chanceloottable then
			local loot_table = LootTables[self.chanceloottable]
			if loot_table then
				for i, entry in ipairs(loot_table) do
					local prefab = entry[1]
					local chance = entry[2]
					if math.random() <= chance + chance_fix then
						table.insert(loots, prefab)
						self.droppingchanceloot = true
					end
				end
			end
		end

		if not self.droppingchanceloot and self.ifnotchanceloot then
			self.inst:PushEvent("ifnotchanceloot")
			for k,v in pairs(self.ifnotchanceloot) do
				table.insert(loots, v.prefab)
			end
		end

		if self.loot then
			for k,v in ipairs(self.loot) do
				table.insert(loots, v)
			end
		end
		
		local recipename = self.inst.prefab
		if self.inst.recipeproxy then
			recipename = self.inst.recipeproxy
		end

		local recipe = GetRecipe(recipename)

		if recipe then
			local percent = 1

			if self.lootpercentoverride then
				percent = self.lootpercentoverride(self.inst)
			elseif self.inst.components.finiteuses then
				percent = self.inst.components.finiteuses:GetPercent()
			end

			for k,v in ipairs(recipe.ingredients) do
				local amt = math.ceil( (v.amount * TUNING.HAMMER_LOOT_PERCENT) * percent)
				if self.inst:HasTag("burnt") then
					amt = math.ceil( (v.amount * TUNING.BURNT_HAMMER_LOOT_PERCENT) * percent)
				end
				for n = 1, amt do
					table.insert(loots, v.type)
				end
			end

			if self.inst:HasTag("burnt") and math.random() < .4 then
				table.insert(loots, "charcoal") -- Add charcoal to loot for burnt structures
			end
		end
		
		return loots
	end
end)

-- the King of Autumn
-- AddComponentPostInit("seasonmanager_rog", function(self)
-- 	self.autumnsegs = {day=8/2,  dusk=6/2,  night=2/2}
-- 	self.wintersegs = {day=5/2,  dusk=5/2,  night=6/2}
-- 	self.springsegs = {day=5/2,  dusk=8/2,  night=3/2}
-- 	self.summersegs = {day=11/2, dusk=1/2,  night=4/2}
-- end)

----------------------------------------------------------
-- if _G.WARGON.CONFIG.diff == 1 then
-- 	AddComponentPostInit("combat", function(self)
-- 		local old_can = self.CanBeAttacked
-- 		function self:CanBeAttacked(attacker)
-- 			if not (attacker:HasTag("player") 
-- 			or attacker:HasTag("pig")) 
-- 			and self.inst:HasTag("tp_only_player_attack") then
-- 				return false
-- 			end
-- 			return old_can(self, attacker)
-- 		end
-- 	end)
-- end

-- AddComponentPostInit("locomotor", function(self)
-- 	local old_push = self.PushAction
-- 	function self:PushAction(bufferedaction, run, try_instant)
-- 		if bufferedaction and bufferedaction.action == ACTIONS.BUILD then
-- 			if self.inst:HasTag("tech_prince") then
-- 				self.inst:PushBufferedAction(bufferedaction)
-- 			end
-- 		end
-- 		old_push(self, bufferedaction, run, try_instant)
-- 	end
-- end)

