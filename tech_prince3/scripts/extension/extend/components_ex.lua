local Info = Sample.Info

-- 隔热可以同时拥有两种隔热效果
AddComponentPostInit("insulator", function(self)
	if self.wg_fix then return end self.wg_fix = true
	
	self.winter_insulation = 0
	self.summer_insulation = 0
end)

AddComponentPostInit("temperature", function(self)
	if self.wg_fix then return end self.wg_fix = true
	
	local GetInsulation = self.GetInsulation
	function self:GetInsulation(...)
		local winter, summer = GetInsulation(self, ...)
		if self.inst.components.inventory then
			for k,v in pairs (self.inst.components.inventory.equipslots) do
				if v.components.insulator then
					winter = winter + v.components.insulator.winter_insulation
					summer = summer + v.components.insulator.summer_insulation
				end
			end
		end
		return winter, summer
	end
end)

-- 合并与分开时推送事件，以触发相应的效果
AddComponentPostInit("stackable", function(self)
    local Get = self.Get
    function self:Get(num)
        local instance = Get(self, num)
        instance:PushEvent("tp_stackable_get", {source=self.inst})
        return instance
    end
    local Put = self.Put
    function self:Put(item, source_pos)
        self.inst:PushEvent("tp_stackable_put", {item=item})
		return Put(self, item, source_pos)
	end
end)

local function fn(self)
	local DropLoot = self.DropLoot
	function self:DropLoot(...)
		if self.inst:HasTag("not_drop_loot") then
		else
			DropLoot(self, ...)
		end
	end
	-- 掉落单个战利品
	function self:DropSingleLoot(pt, loots)
		local prefabs = loots
		if prefabs == nil then
			prefabs = self:GenerateLoot()
		end
		if prefabs and #prefabs>0 then

			local loot = prefabs[math.random(#prefabs)]
			-- if loot ~= "tp_boss_loot" then
				self:SpawnLootPrefab(loot, pt)
			-- end
		end
	end
	-- 增加掉落率
	local GenerateLoot = self.GenerateLoot
	local chance_fix = GetPlayer().components.tp_player_attr and GetPlayer().components.tp_player_attr:GetLootChance() or 0
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
				table.insert(loots, "charcoal")
			end
		end
		
		return loots
	end
end
AddComponentPostInit("lootdropper", fn)

AddComponentPostInit("combat", function(self)
	-- 战吼
	local battle_cry = self.BattleCry
	function self:BattleCry()
		if not self.not_battle_cry then
			battle_cry(self)
		end
	end
end)

-- 说多句话
AddComponentPostInit("talker", function(self)
	function self:SayLines(strs)
		if type(strs) == "string" then
			self:Say(strs)
		else
			local lines = {}
			for k, v in pairs(strs) do
				lines[k] = {
					message = v,
					duration = 2.5,
					noanim = nil,
				}
			end
			self:Say(lines)
		end
	end
end)

local function fn(self)
	-- 添加属性消耗的一些参数, 方便写代码
	local CanRead = self.CanRead
	function self:CanRead(reader)
		if self.test_data then
			local data = self.test_data
			if data.san then
				-- if reader.components.sanity == nil
				if reader.components.sanity.current < data.san then
					return false
				end
			end
			if data.mana then
				if reader.components.tp_val_mana:GetCurrent() < data.mana then
					return false
				end
			end
			-- if data.vigor then
			-- 	if reader.components.tp_val_vigor:GetCurrent():IsEmpty() then
			-- 		return
			-- 	end
			-- end
			if data.attr then
				-- if reader.components.tp_player_attr == nil then
				--     return 
				-- end
				for k, v in pairs(data.attr) do
					if reader.components.tp_player_attr:GetAttr(k) < v then
						return false
					end
				end
			end
		end
		return CanRead(self, reader)
	end
	local OnRead = self.OnRead
	function self:OnRead(reader)
		if self.test_data then
			local data = self.test_data
			if data.san then
				-- if reader.components.sanity == nil
				reader.components.sanity:DoDelta(-data.san)
			end
			if data.mana then
				reader.components.tp_val_mana:DoDelta(-data.mana)
			end
			-- if data.vigor then
			-- 	reader.components.tp_val_vigor:DoDelta(-data.vigor)
			-- end
		end
		return OnRead(self, reader)
	end
	
	function self:GetWargonString()
		if self.test_data then
			local data = self.test_data
			local s = "需求:"
			if data.san then
				s = s..string.format("%d理智,", data.san)
			end
			if data.mana then
				s = s..string.format("%d魔力,", data.mana)
			end
			-- if data.vigor then
			-- 	s = s..string.format("精力非空,")
			-- end
			if data.attr then
				for k, v in pairs(data.attr) do
					local attr_name = Info.Attr.PlayerAttrStr[k]
					s = s..string.format("%s:%d,", attr_name, v)
				end
			end
	
			return s
		end
	end
end
AddComponentPostInit("book", fn)
-- 要添加这个,不然CanRead不执行
ACTIONS.READMAP.testfn = function(act)
	local targ = act.target or act.invobject
	if targ and targ.components.book and act.doer and act.doer.components.reader then
		return targ.components.book:CanRead(act.doer)
	end
end

AddComponentPostInit("inventory", function(self)
	local GetWaterproofness = self.GetWaterproofness
	function self:GetWaterproofness(slot)
		local rate = GetWaterproofness(self, slot)
		if self.inst:HasTag("hollow_evade") then
			rate = rate + .8
		end
		return rate
	end
end)

AddComponentPostInit("finiteuses", function(self)
	local OnSave = self.OnSave
	function self:OnSave()
		local data = OnSave(self)
		data.max_modifier = self.max_modifier
		return data
	end
	local OnLoad = self.OnLoad
	function self:OnLoad(data)
		if data.max_modifier then
			self.max_modifier = data.max_modifier
			self.total = self.total + data.max_modifier
		end
		OnLoad(self, data)
	end
	function self:AddMaxModifier(v)
		if self.max_modifier == nil then
			self.max_modifier = 0
		end
		self.max_modifier = self.max_modifier + v
		self.total = self.total + v
	end
end)