local potionts = {"tp_potion", "tp_potion", "health_small", nil}
local potionts2 = {"tp_potion_2", "tp_potion_2", "shadow", nil}

local function common_fn(inst, anim, food_fn)
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		food = {health=0, hunger=0, san=0, fn=food_fn},
		stack = {max=40},
	})
	inst.AnimState:PlayAnimation(anim)
end

local function common_food_fn(inst, eater)
	if eater.components.tpbuff then
		eater.components.tpbuff:AddBuff(inst.prefab)
	end
	c_give("messagebottleempty")
end

local function health_small_fn(inst)
	common_fn(inst, "health_small", common_food_fn)
end

local function sanity_small_fn(inst)
	common_fn(inst, "sanity_small", common_food_fn)
end

local function brave_small_food_fn(inst, eater)
	if eater.components.tpmadvalue then
		eater.components.tpmadvalue:DoDelta(-100)
	end
	c_give("messagebottleempty")
end

local function brave_small_fn(inst)
	common_fn(inst, "brave_small", brave_small_food_fn)
end

local function warth_fn(inst)
	common_fn(inst, "warth", common_food_fn)
end

local function crazy_fn(inst)
	common_fn(inst, "crazy", common_food_fn)
end

local function shine_fn(inst)
	common_fn(inst, "shine", common_food_fn)
end

local function dry_fn(inst)
	common_fn(inst, "dry", common_food_fn)
end

local function smell_fn(inst)
	common_fn(inst, "smell", common_food_fn)
end

local function iron_fn(inst)
	common_fn(inst, "iron", common_food_fn)
end

local function shadow_fn(inst)
	common_fn(inst, "shadow", common_food_fn)
end

local function killer_fn(inst)
	common_fn(inst, "killer", common_food_fn)
end

local function metal_fn(inst)
	common_fn(inst, "metal", common_food_fn)
end

local function cool_fn(inst)
	common_fn(inst, "cool", common_food_fn)
end

local function warm_fn(inst)
	common_fn(inst, "warm", common_food_fn)
end

local function detoxify_fn(inst)
	common_fn(inst, "detoxify", function(inst, eater)
		if eater.components.poisonable
		and eater.components.poisonable:IsPoisoned() then
			eater.components.poisonable:Cure()
		end
		c_give("messagebottleempty")
	end)
end

local function horror_fn(inst)
	common_fn(inst, "horror", function(inst, eater)
		local hp_p = eater.components.health:GetPercent()
		local san_p = math.max(eater.components.sanity:GetPercent(), .01)
		eater.components.health:SetPercent(san_p, "tp_potion_horror")
		eater.components.sanity:SetPercent(hp_p)
		c_give("messagebottleempty")
	end)
end

local function MakeItem(name, anims, item_fn, atlas, img)
	local function fn()
		local the_atlas = atlas and "images/inventoryimages/"..atlas..".xml" 
		local the_img = img or atlas
	 	local inst = WARGON.make_prefab(anims, anims[4], "inv", nil, nil)
	 	WARGON_CMP_EX.add_cmps(inst, {
	 		invitem = {atlas=the_atlas, img=the_img},
	 	})
	 	inst:AddTag("tp_item")
	 	if item_fn then
	 		item_fn(inst)
	 	end

	    return inst
	end
	return Prefab("common/inventory/"..name, fn, {})
end

return
	MakeItem("tp_potion_health_small", potionts, health_small_fn, "tp_potion_health_small"),
	MakeItem("tp_potion_sanity_small", potionts, sanity_small_fn, "tp_potion_sanity_small"),
	MakeItem("tp_potion_brave_small", potionts, brave_small_fn, "tp_potion_brave_small"),
	MakeItem("tp_potion_warth", potionts, warth_fn, "tp_potion_warth"),
	MakeItem("tp_potion_shine", potionts, shine_fn, "tp_potion_shine"),
	MakeItem("tp_potion_crazy", potionts2, crazy_fn, "tp_potion_crazy"),
	MakeItem("tp_potion_dry", potionts2, dry_fn, "tp_potion_dry"),
	MakeItem("tp_potion_smell", potionts2, smell_fn, "tp_potion_smell"),
	MakeItem("tp_potion_iron", potionts2, iron_fn, "tp_potion_iron"),
	MakeItem("tp_potion_metal", potionts2, metal_fn, "tp_potion_metal"),
	MakeItem("tp_potion_killer", potionts2, killer_fn, "tp_potion_killer"),
	MakeItem("tp_potion_shadow", potionts2, shadow_fn, "tp_potion_shadow"),
	MakeItem("tp_potion_cool", potionts2, cool_fn, "tp_potion_cool"),
	MakeItem("tp_potion_warm", potionts2, warm_fn, "tp_potion_warm"),
	MakeItem("tp_potion_detoxify", potionts2, detoxify_fn, "tp_potion_detoxify"),
	MakeItem("tp_potion_horror", potionts2, horror_fn, "tp_potion_horror")