local TpWereKingSpawner = Class(function(self, inst)
	self.inst = inst
	self.days = 0
	self.num = 0
	self.spawned = false
	-- inst:ListenForEvent("trade", function(inst, data)
	-- 	if data and data.item then
	-- 		local item = data.item
	-- 		if not (item.components.tradable and item.components.tradable.goldvalue>0) then
	-- 			inst.AnimState:PlayAnimation("cointoss")
	-- 	        inst.AnimState:PushAnimation("happy")
	-- 	        inst.AnimState:PushAnimation("idle", true)
	-- 	        inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingHappy")
	-- 			self:Trigger()
	-- 		end
	-- 	end
	-- end)
	-- inst:ListenForEvent("daycomplete", function()
	-- 	self.days = math.max(self.days-1, 0)
	-- end)
	self.inst:ListenForEvent("nighttime", function()
		-- if WARGON.is_full_moon() and not self.spawned then
		if WARGON.is_full_moon() then
			self:Spawn()
		end
	end, GetWorld())
end)

function TpWereKingSpawner:Spawn()
	if c_findtag("tp_werepig_king") then
		return
	end
	local lords = {
		-- "tp_werepig_king",
		"tp_blood_lord",
		"tp_thunder_lord",
		"tp_fire_lord",
		"tp_ice_lord",
		"tp_poison_lord",
		"tp_shadow_lord",
	}
	local temp = {}
	for k, v in pairs(lords) do
		if GetPlayer().components.tpprefabspawner:CanSpawn(v) then
			table.insert(temp, v)
		end
	end
	local lord = nil
	if #temp <= 0 then
		if GetPlayer().components.tpprefabspawner:CanSpawn("tp_pig_book") then
			lord = "tp_pig_book"
		end
	else
		lord = temp[math.random(#temp)]
	end
	if GetPlayer().components.tpprefabspawner:CanSpawn("tp_werepig_king") then
		lord = "tp_werepig_king"
	end
	if lord then
		local pos = WARGON.around_land(self.inst, 2)
		if pos then
			WARGON.make_fx(pos, "lightning")
			WARGON.make_spawn(pos, lord)
			GetPlayer().components.tpprefabspawner:TriggerPrefab(lord)
			-- WARGON.make_spawn(pos, "tp_werepig_king")
			-- WARGON.make_spawn(pos, "tp_grass_pigking")
			-- self.spawned = true
		end
	end
end

function TpWereKingSpawner:Trigger()
	-- local judge = math.random()
	-- print("TpWereKingSpawner", judge)
	-- local must = GetPlayer().components.tpprefabspawner:CanSpawn("tp_werepig_king")
	-- if judge <= 1/50 or must then
	-- 	if must then
	-- 		GetPlayer().components.tpprefabspawner:TriggerPrefab("tp_werepig_king")
	-- 	end
	-- 	local boss = c_find('tp_werepig_king')
	-- 	if boss == nil then
	-- 		local inst = self.inst
	-- 		local clock = GetClock()
	-- 		for i = 1, 2 do
	-- 			if clock:IsNight() == false then
	-- 				clock:NextPhase()
	-- 			end
	-- 		end
	-- 		inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/howl")
	-- 		local radius = 25 + math.random(5)
	-- 		local pos = WARGON.around_land(inst, radius)
	-- 		if pos and WARGON.on_land(inst, pos) then
	-- 			local new = WARGON.make_spawn(pos, "tp_werepig_king")
	-- 			self.days = 20
	-- 		end
	-- 	end
	-- end
	if c_find("tp_werepig_king") ~= nil then
		return
	end
	self.num = self.num + 1
	if self.num >= 4 then
		self.num = 0
		-- local pos = self.inst:GetPosition()
		local pos = WARGON.around_land(self.inst, 25)
		if pos then
			-- self.inst:Remove()
			local clock = GetClock()
			if clock:IsNight() == false then
				clock:NextPhase()
			end
			WARGON.make_spawn(pos, "tp_werepig_king")
			WARGON.make_fx(pos, "lightning")
			WARGON.make_fx(pos, "statue_transition")
			for i = -1, 1, 2 do
				for j = -1, 1, 2 do
					local pt = pos
					pt.x = pt.x + i
					pt.z = pt.z + i
					WARGON.make_fx(pt, "statue_transition")
				end
			end
		end
	end
end

function TpWereKingSpawner:OnSave()
	return {
		days=self.days,
		spawned = self.spawned,
	}
end

function TpWereKingSpawner:OnLoad(data)
	if data then
		self.days = data.days or 0
		self.spawned = data.spawned
	end
end

return TpWereKingSpawner