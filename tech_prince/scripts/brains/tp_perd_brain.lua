local function is_bush(item)
	return item.components.pickable
       and item.components.pickable:CanBePicked()
       and item.components.pickable.product == "berries"
end

local function home_bush(item)
	return item.components.pickable
       and item.components.pickable:CanBePicked()
       and item:HasTag("bush")
end

return WARGON_BRAIN_EX.animal_brain(is_bush, home_bush, 'scarytopery')