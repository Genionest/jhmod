local original_tbl = {
	carrot_planted = GROUND.GRASS,  -- 胡萝卜
	-- lichen = GROUND.FUNGUS,  -- 苔藓
	sweet_potato_planted = GROUND.MEADOW,  -- 马铃薯
	asparagus_planted = GROUND.PLAINS,  -- 芦笋
}
local life_tree_plants = {}
for k, v in pairs(original_tbl) do
	life_tree_plants[tostring(v)] = k
end

local TpPlantSpawner = Class(function(self, inst)
	self.inst = inst
	self.plants = life_tree_plants
	self.tags = {"life_tree_plant"}
	self.notags = nil
	self.num = 4
	self.fx = "green_leaves"
	self.time = 30 * 16
	self.canspawn = function(inst)
		return inst.components.growable.stage >= 3
	end
end)

function TpPlantSpawner:SpawnPlant(pos)
	local tile = WARGON.get_tile(pos)
	local plant = self.plants[tostring(tile)]
	if plant then
		WARGON.make_spawn(pos, plant)
		WARGON.make_fx(pos, self.fx)
	end
end

function TpPlantSpawner:Start()
	local inst = self.inst
	if self.task == nil then
		self.task  = WARGON.per_task(inst, self.time, function()
			if self.canspawn and self.canspawn(inst) then
				local ents = WARGON.finds(inst, 6, self.tags, self.notags)
				if #ents < self.num then
					for i = 1, 100 do
						local pos = WARGON.around_land(inst, math.random(1, 4))
						if pos and WARGON.on_land(inst, pos) then
							local ents = WARGON.finds(pos, 1, self.tags, self.notags)
							if not (ents and #ents>0) then
								self:SpawnPlant(pos)
								break
							end
						end
					end
				end
			end
		end)
	end
end

function TpPlantSpawner:Stop()
	if self.task then
		self.task:Cancel()
		self.task = nil
	end
end

return TpPlantSpawner