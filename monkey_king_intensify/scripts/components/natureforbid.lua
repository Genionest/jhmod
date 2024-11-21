local nature_tbl = {
	-- coldf = "warmfield",
	firef = "coolfield",
}

local NatureForbid = Class(function(self, inst)
	self.inst = inst
	self.max = {
		-- coldf = 60,
		-- firef = 60,
	}
	self.current = {}
	inst:DoPeriodicTask(1, function()
		self:DoDelta(1)
	end)
end)

function NatureForbid:DoDelta(amount)
	for k, v in pairs(self.current) do
		self.current[k] = self.current[k] + amount
		self.current[k] = math.min(self.max[k], math.max(0, self.current[k]))
		if self.current[k] >= self.max[k] then
			self:StopForbid(k)
		end
	end
end

function NatureForbid:AddNature(k, amount)
	self.max[k] = amount
	self.current[k] = self.max[k]
end

function NatureForbid:IsForbid(nature)
	return self.inst:HasTag("monkey_king_"..nature)
end

function NatureForbid:SetFx(nature)
	local fx = SpawnPrefab(nature_tbl[nature])
	if fx then
		fx.entity:SetParent(self.inst.entity)
		fx.Transform:SetPosition(0, 0.2, 0)
		self.inst[nature.."_filed"] = fx
	end
end

function NatureForbid:StartForbid(nature)
	self.current[nature] = 0
	self:SetFx(nature)
	self.inst:AddTag("monkey_king_"..nature)
	print("monkey_king_"..nature)
end

function NatureForbid:StopForbid(nature)
	if self.inst[nature.."_filed"] then
		self.inst[nature.."_filed"].kill_fx(self.inst[nature.."_filed"])
	end
	if self.inst:HasTag("monkey_king_"..nature) then
		self.inst:RemoveTag("monkey_king_"..nature)
	end
end

function NatureForbid:OnSave()
	return {current = self.current}
end

function NatureForbid:OnLoad(data)
	if data.current then
		self.current = data.current or {}
		-- self.current[k] = data.current[k] or self.max[k]
		for k, v in pairs(self.current) do
			if self.current[k] < self.max[k] then
				self:StartForbid(k)
			end
		end
	end
end

return NatureForbid