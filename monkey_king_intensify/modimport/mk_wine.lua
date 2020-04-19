local function eatWine(inst)
	-- 素酒
	local old_fn = inst.components.eater.oneatfn
	inst.components.eater:SetOnEatFn(function(inst, food)
		old_fn(inst, food)
		if food.prefab == "peach_wine" then
			inst.components.monkeymana:DoDelta(100)
		end
	end)
	-- 酒葫芦
	if ACTIONS.DRINK then
		local old_fn2 = ACTIONS.MK_DRINK.fn 
		ACTIONS.MK_DRINK.fn= function(act)
			if act.doer.components.monkeymana then
				act.doer.components.monkeymana:DoDelta(100)
			end
			old_fn2(act)
			return true
		end 
	end
end

local function proWine(self)
	self.max = 10
	self.current = 10
end

AddPrefabPostInit("monkey_king", eatWine)
AddComponentPostInit("wined", proWine)