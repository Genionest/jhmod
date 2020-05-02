local MkInsulator = Class(function(self, inst)
	self.inst = inst

	self.summer_insulation = 0
	self.winter_insulation = 0
end)

function MkInsulator:SetSummerInsulation(amount)
	self.summer_insulation = amount
end

function MkInsulator:SetWinterInsulation(amount)
	self.winter_insulation = amount
end

function MkInsulator:GetSummerInsulation()
	return self.summer_insulation or 0
end

function MkInsulator:GetWinterInsulation()
	return self.winter_insulation or 0
end

return MkInsulator