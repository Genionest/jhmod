local MadMaker = Class(function(self, inst)
	self.inst = inst
	self.range = 4
	self.tags = {"tp_mad_value"}
	self.no_tags = nil
	self.fn = nil
	self.task = WARGON.per_task(self.inst, 1, function()
		self:AuraMad()
	end)
end)

function MadMaker:AuraMad()
	local ents = WARGON.finds(self.inst, self.range, self.tags, self.no_tags)
	for k, ent in pairs(ents) do
		if ent.components.tpmadvalue and ent.components.health
		and not ent.components.health:IsDead() then
			local dt = 2
			if self.fn then
				dt = self.fn(self.inst, ent)
			end
			ent.components.tpmadvalue:DoDelta(dt, true)
		end
	end
end

function MadMaker:SetFn(fn)
	self.fn = fn
end

return MadMaker