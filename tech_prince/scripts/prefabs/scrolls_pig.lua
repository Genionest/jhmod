local papyrus = {"papyrus", "papyrus", "idle"}

local function onfinished(inst)
	inst:Remove()
end

local function on_use(inst)
	local item = inst.components.stackable:Get()
	item:Remove()
end

local function MakeScroll(name, anims, book_fn)
	local function fn()
		local inst = WARGON.make_prefab(anims, nil, "inv")
		WARGON_CMP_EX.add_cmps(inst, 
		{
			invitem = {atlas="images/inventoryimages/"..name..'.xml', 
				img=name},
			inspect = {},
			stack = {max=20},
			book = {fn = book_fn, act="map"},
			-- finite = {use=1, max=1, fn=onfinished},
		})

	    return inst
	end
	return Prefab("common/inventory/"..name, fn, {})
end

local function search_pigs(reader, num)
	local pigs = WARGON.finds(reader, 40, {'pig'}, {'werepig', 'guard'})
	if pigs then
		num = num or 4
		for k, v in pairs(pigs) do
			if (not (v.components.follower
			and v.components.follower.leader == reader))
			or k > num  then
				pigs[k] = nil
			end
		end
	end
	return pigs
end

local function common_fn(inst, reader, name)
	local pigs = search_pigs(reader)
	if pigs then
		for k, v in pairs(pigs) do
			if v.components.tpbuff then
				v.components.tpbuff:AddBuff(name)
				WARGON.make_fx(v, "tp_fx_"..name)
			end
		end
	end
	on_use(inst)
	return true
end

local function armor_fn(inst, reader)
	local pigs = search_pigs(reader, 8)
	if pigs then
		for k, v in pairs(pigs) do
			if reader.components.inventory:Has("pigskin", 1) then
				reader.components.inventory:ConsumeByName("pigskin", 1)
				if v.components.inventory then
					local current = v.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
					if current then
						v.components.inventory:DropItem(current)
					end
					local hat = SpawnPrefab("footballhat")
					v.components.inventory:Equip(hat)
					v.AnimState:Show("hat")
					WARGON.make_fx(v, "tp_fx_scroll_pig_armor")
					-- reader.components.sanity:DoDelta(-10)
				end
			else
				break
			end
		end
	end
	on_use(inst)
	return true
end

local function armorex_fn(inst, reader)
	-- local pigs = search_pigs(reader)
	-- if pigs then
	-- 	for k, v in pairs(pigs) do
	-- 		if v.components.tpbuff then
	-- 			v.components.tpbuff:AddBuff('scroll_pig_armorex')
	-- 			WARGON.make_fx(v, "tp_fx_scroll_pig_armorex")
	-- 		end
	-- 	end
	-- end
	-- on_use(inst)
	-- return true
	return common_fn(inst, reader, "scroll_pig_armorex")
end

local function speed_fn(inst, reader)
	-- local pigs = search_pigs(reader)
	-- if pigs then
	-- 	for k, v in pairs(pigs) do
	-- 		if v.components.tpbuff then
	-- 			v.components.tpbuff:AddBuff('scroll_pig_speed')
	-- 			WARGON.make_fx(v, "tp_fx_scroll_pig_speed")
	-- 		end
	-- 	end
	-- end
	-- on_use(inst)
	-- return true
	return common_fn(inst, reader, "scroll_pig_speed")
end

local function damage_fn(inst, reader)
	-- local pigs = search_pigs(reader)
	-- if pigs then
	-- 	for k, v in pairs(pigs) do
	-- 		if v.components.tpbuff then
	-- 			v.components.tpbuff:AddBuff("scroll_pig_damage")
	-- 			WARGON.make_fx(v, "tp_fx_scroll_pig_damage")
	-- 		end
	-- 	end
	-- end
	-- on_use(inst)
	-- return true
	return common_fn(inst, reader, "scroll_pig_damage")
end

local function heal_fn(inst, reader)
	-- local pigs = search_pigs(reader)
	-- if pigs then
	-- 	for k, v in pairs(pigs) do
	-- 		if v.components.tpbuff then
	-- 			v.components.tpbuff:AddBuff('scroll_pig_heal')
	-- 			WARGON.make_fx(v, "tp_fx_scroll_pig_heal")
	-- 		end
	-- 	end
	-- end
	-- on_use(inst)
	-- return true
	return common_fn(inst, reader, "scroll_pig_heal")
end

local function teleport_fn(inst, reader)
	local pigking = c_find("pigking")
	if pigking then
		local pos = WARGON.around_land(pigking, 2)
		if pos then
			reader.components.sanity:DoDelta(-30)
			reader.Transform:SetPosition(pos:Get())
			TheFrontEnd:Fade(true,1)
		end
	end
	on_use(inst)
	return true
end

local function leader_fn(inst, reader)
	local pigs = WARGON.finds(reader, 30, {'pig'}, {'werepig', 'guard'})
	for k, v in pairs(pigs) do
		if reader.components.inventory:Has("meat", 1) then
			if v.components.follower then
				if v.components.follower.leader == nil then
					reader.components.leader:AddFollower(v)
				end
				local time = 480
				v.components.follower:AddLoyaltyTime(time)
				WARGON.make_fx(v, "tp_fx_scroll_pig_leader")
				reader.components.inventory:ConsumeByName("meat", 1)
			end
		else
			break
		end
	end
	on_use(inst)
	return true
end

local function health_fn(inst, reader)
	-- local pigs = search_pigs(reader)
	-- if pigs then
	-- 	for k, v in pairs(pigs) do
	-- 		if v.components.tpbuff then
	-- 			v.components.tpbuff:AddBuff('scroll_pig_health')
	-- 			WARGON.make_fx(v, "tp_fx_scroll_pig_health")
	-- 		end
	-- 	end
	-- end
	-- on_use(inst)
	-- return true
	return common_fn(inst, reader, "scroll_pig_health")
end

return
	MakeScroll("scroll_pig_armor", papyrus, armor_fn),
	MakeScroll("scroll_pig_armorex", papyrus, armorex_fn),
	MakeScroll("scroll_pig_speed", papyrus, speed_fn),
	MakeScroll("scroll_pig_damage", papyrus, damage_fn),
	MakeScroll("scroll_pig_heal", papyrus, heal_fn),
	MakeScroll("scroll_pig_teleport", papyrus, teleport_fn),
	MakeScroll("scroll_pig_leader", papyrus, leader_fn),
	MakeScroll("scroll_pig_health", papyrus, health_fn)