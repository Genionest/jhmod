local TpDivable = Class(function(self, inst)
	self.inst = inst
end)

function TpDivable:CollectSceneActions(doer, actions, right)
	if right and doer:HasTag("tp_diver") then
		table.insert(actions, ACTIONS.TP_DIVING)
	end
end

function TpDivable:Diving(doer)
	local pool = nil
	local clock = GetClock()
	if clock:IsNight() and clock:GetMoonPhase() == "full" then
		-- local target = c_find("tp_moon_lake")
		local target = WARGON.find(self.inst, 1000, nil, {"tp_moon_lake"})
		if target then
			TheFrontEnd:Fade(true, 1)
			GetPlayer().Transform:SetPosition(target:GetPosition():Get())
			-- doer.Transform:SetPosition(500, 0, 500)
			-- local queen = SpawnPrefab("spiderqueen")
			-- queen.Transform:SetPosition(target:GetPosition():Get())
			-- queen.Transform:SetPosition(503, 0, 503)
			return
		end
	end
	-- local start = GetPlayer().tp_pool_node
	-- local start = GetWorld().tp_pool_start
	-- pool = self.inst.tp_pool_last or start
	local pool = GetWorld().tp_pool_start
	for k, v in pairs(GetWorld().tp_pools) do
		if v.tp_pool_id and v.tp_pool_id == self.inst.tp_pool_id+1 then
			pool = v
		end
	end
	if pool == nil then
		pool = WARGON.find(self.inst, 9999, nil, {"tp_diving_target"})
	end
	if pool then
		local pos = WARGON.around_land(pool, 2)
		if pos then
			TheFrontEnd:Fade(true, 1)
			doer.Transform:SetPosition(pos:Get())
			if doer.components.moisture then
				doer.components.moisture:DoDelta(100)
			end
		end
	end
end

return TpDivable