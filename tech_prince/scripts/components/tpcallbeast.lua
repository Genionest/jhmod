local CallBeast = Class(function(self, inst)
	self.inst = inst
end)

function CallBeast:MagicBeast(target)
	target.AnimState:SetMultColour(.1, .1, .5, .5)
	WARGON_FX_EX.shadow_fx(target)
	WARGON.no_save(target)
	target.components.health:SetAbsorptionAmount(.99)
	target:RemoveComponent("burnable")
	target:RemoveComponent("propagator")
	target:RemoveComponent("poisonable")
	target:RemoveComponent("freezable")
	target:AddTag("tp_call_beast")
	target:AddTag("tp_call_beast")
	local monster = WARGON.find(target, 20, nil, {"monster"})
	if monster then
		target.components.combat:SetTarget(monster)
	end
	WARGON.do_task(target, 30, function()
		WARGON_FX_EX.shadow_fx(target)
		target:Remove()
	end)
end

function CallBeast:CallBeast()
	self.inst:StartThread(function()
		for k = 1, 9 do
			local name = "pigman"
			if k > 2 then
				name = "beefalo"
			end
			local beast = SpawnPrefab(name)
			local pos = WARGON.around_land(self.inst, math.random(3, 9))
			beast.Transform:SetPosition(pos:Get())
			self:MagicBeast(beast)

			Sleep(.5)
		end
	end)
end

return CallBeast