local TpAngry = Class(function(self, inst)
	self.inst = inst
	self.trigger = true
	self.days = 0
	self.diff = false
	self.inst:ListenForEvent("onhitother", function(inst, data)
		self:Trigger(data)
	end)
	self.inst:ListenForEvent("daycomplete", function()
		self:Reset()
	end, GetWorld())
end)

local fxs = {
	-- "tp_fx_deerclops",
	-- "tp_fx_moose",
	-- "tp_fx_dragonfly",
	-- "tp_fx_bearger",
	"deerclops",
	"bearger",
	"dragonfly",
	"moose",
}

function TpAngry:Trigger(data)
	-- local time_over = WARGON.CONFIG.diff == 1 and 70 or 70
	-- local rand = WARGON.CONFIG.diff == 1 and .33 or .33
	local time_over = self.diff and 70 or 70
	local rand = self.diff and .33 or .33
	-- print("TpAngry", time_over, rand)
	if self.days<=0 and self.diff
	-- if self.days<=0 and WARGON.CONFIG.diff == 1
	and math.random() < rand and WARGON.get_days() > time_over
	and data.target and not data.target:HasTag("tp_sign_rider") then
		if self.fx == nil then
			local boss = fxs[math.random(#fxs)]
			local fx_name = "tp_fx_"..boss
			-- local weapon = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			-- if weapon then
			-- end
			self.fx = WARGON.make_fx(self.inst, fx_name)
			self.fx:AddTag("tp_boss_angry")
		end
		WARGON.do_task(self.inst, 1, function()
			self.fx = nil
		end)
	end
end

function TpAngry:ReTime()
	self.days = self.diff and 70 or 70
	-- self.days = WARGON.CONFIG.diff == 1 and 70 or 70
end

function TpAngry:Reset()
	self.days = math.max(0, self.days-1)
	if self.days == 0 and c_findtag("tp_boss_ice_statue") then
		self.days = 5
	end
	print(self.days)
end

function TpAngry:OnSave()
	return {days = self.days}
end

function TpAngry:OnLoad(data)
	if data then
		self.days = data.days or 0
	end
end

return TpAngry