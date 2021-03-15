local papyruss = {"papyrus", "papyrus", "idle"}
local Anims = {
	papyrus = {"papyrus", "papyrus", "idle", },
}

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
		inst:AddTag("tp_scroll")

	    return inst
	end
	return Prefab("common/inventory/"..name, fn, {})
end

local function search_pigs(reader, num)
	local pigs = WARGON.finds(reader, 40, {'pig'}, {'werepig', 'guard'})
	if pigs then
		num = num or 8
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
	return common_fn(inst, reader, "scroll_pig_armorex")
end

local function speed_fn(inst, reader)
	return common_fn(inst, reader, "scroll_pig_speed")
end

local function damage_fn(inst, reader)
	return common_fn(inst, reader, "scroll_pig_damage")
end

local function heal_fn(inst, reader)
	return common_fn(inst, reader, "scroll_pig_heal")
end

local function teleport_fn(inst, reader)
	local pigking = c_find("tp_grass_pigking")
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
	return common_fn(inst, reader, "scroll_pig_health")
end

local function wind_fn(inst, reader)
	if reader.components.tpbuff then
		reader.components.tpbuff:AddBuff("scroll_wind")
		reader.components.sanity:DoDelta(-50)
	end
	on_use(inst)
	return true
end

local function pigman_fn(inst, reader)
	reader.components.sanity:DoDelta(-10)
	-- reader.components.health:DoDelta(-10)
	local pos = WARGON.around_land(reader, math.random(3, 6))
	if pos then
		local pig = WARGON.make_spawn(pos, "pigman")
		if WARGON.on_water(pig) then
			WARGON.make_fx(pos, "splash_water_sink")
			pig:Remove()
		else
			WARGON.make_fx(pos, "tp_fx_shadow_bat")
			WARGON.make_fx(pos, "statue_transition")
			-- WARGON.make_fx(pos, "statue_transition_2")
			WARGON.make_fx(pos, "vortex_cloak_fx")
			reader.components.leader:AddFollower(pig)
			pig.components.follower:AddLoyaltyTime(1200)
		end
		on_use(inst)
		return true
	end
end

local function bunnyman_fn(inst, reader)
	reader.components.sanity:DoDelta(-10)
	-- reader.components.health:DoDelta(-10)
	local pos = WARGON.around_land(reader, math.random(3, 6))
	if pos then
		local pig = WARGON.make_spawn(pos, "bunnyman")
		if WARGON.on_water(pig) then
			WARGON.make_fx(pos, "splash_water_sink")
			pig:Remove()
		else
			WARGON.make_fx(pos, "tp_fx_shadow_bat")
			WARGON.make_fx(pos, "statue_transition")
			-- WARGON.make_fx(pos, "statue_transition_2")
			WARGON.make_fx(pos, "vortex_cloak_fx")
			reader.components.leader:AddFollower(pig)
			pig.components.follower:AddLoyaltyTime(1200)
		end
		on_use(inst)
		return true
	end
end

local function shadow_fn(inst, reader)
	if reader.components.sanity:GetMaxSanity() >= TUNING.SHADOWWAXWELL_SANITY_PENALTY then
		local pos = reader:around_land(math.random(3,6))
		if pos then
			WARGON.make_fx(pos, "tp_fx_shadow_spawn")
			WARGON.do_task(reader, .5, function()
				local shadow = WARGON.make_spawn(pos, "tp_unreal_wilson")
				if WARGON.on_water(shadow) then
					shadow:SpawnShadowBoat(pos)
				end
				shadow.components.follower:SetLeader(reader)
				reader.components.health:DoDelta(-TUNING.SHADOWWAXWELL_HEALTH_COST)
			    reader.components.sanity:RecalculatePenalty()
			    reader.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_appear")
			end)
			on_use(inst)
			return true
		end
	end
end

local function harvest_fn(inst, reader)
	reader.components.sanity:DoDelta(-10)
	local ents = reader:wg_finds(15)
	for k, v in pairs(ents) do
		if v.components.pickable and v.prefab ~= "flower" then
			v.components.pickable:Pick(GetPlayer())
		end
		if v.components.crop then
			v.components.crop:Harvest(GetPlayer())
		end
	end
	on_use(inst)
	return true
end

return
MakeScroll("scroll_pig_armor", Anims.papyrus, armor_fn),
MakeScroll("scroll_pig_armorex", Anims.papyrus, armorex_fn),
MakeScroll("scroll_pig_speed", Anims.papyrus, speed_fn),
MakeScroll("scroll_pig_damage", Anims.papyrus, damage_fn),
MakeScroll("scroll_pig_heal", Anims.papyrus, heal_fn),
MakeScroll("scroll_pig_teleport", Anims.papyrus, teleport_fn),
MakeScroll("scroll_pig_leader", Anims.papyrus, leader_fn),
MakeScroll("scroll_pig_health", Anims.papyrus, health_fn),
MakeScroll("scroll_wind", Anims.papyrus, wind_fn),
MakeScroll("scroll_pigman", Anims.papyrus, pigman_fn),
MakeScroll("scroll_bunnyman", Anims.papyrus, bunnyman_fn),
MakeScroll("scroll_shadow", Anims.papyrus, shadow_fn),
MakeScroll("scroll_harvest", Anims.papyrus, harvest_fn)
-- return
-- 	MakeScroll("scroll_pig_armor", papyruss, armor_fn),
-- 	MakeScroll("scroll_pig_armorex", papyruss, armorex_fn),
-- 	MakeScroll("scroll_pig_speed", papyruss, speed_fn),
-- 	MakeScroll("scroll_pig_damage", papyruss, damage_fn),
-- 	MakeScroll("scroll_pig_heal", papyruss, heal_fn),
-- 	MakeScroll("scroll_pig_teleport", papyruss, teleport_fn),
-- 	MakeScroll("scroll_pig_leader", papyruss, leader_fn),
-- 	MakeScroll("scroll_pig_health", papyruss, health_fn),
-- 	MakeScroll("scroll_wind", papyruss, wind_fn),
-- 	MakeScroll("scroll_pigman", papyruss, pigman_fn),
-- 	MakeScroll("scroll_bunnyman", papyruss, bunnyman_fn),
-- 	MakeScroll("scroll_shadow", papyruss, shadow_fn),
-- 	MakeScroll("scroll_harvest", papyruss, harvest_fn)