local function add_asset(assets, asset, asset_type)
	local type_tbl = {img="IMAGE", anim="ANIM", atlas="ATLAS"}
	local pro_tbl = {img="images/", anim="anim/", atlas="images/"}
	local ext_tbl = {img=".tex", anim=".zip", atlas=".xml"}
	local a = Asset(type_tbl[asset_type], pro_tbl[asset_type]..asset..ext_tbl[asset_type])
	table.insert(assets, a)
end

local function add_recipe(name, ingd, tab, tech, game, atlas, img, placer)
	local rec_tab = GLOBAL.RECIPETABS or RECIPETABS
	local tab_tbl = {
		lig = rec_tab.LIGHT,
		tow = rec_tab.TOWN,
		far = rec_tab.FARM,
		sur = rec_tab.SURVIVAL,
		too = rec_tab.TOOLS,
		sci = rec_tab.SCIENCE,
		mag = rec_tab.MAGIC,
		ref = rec_tab.REFINE,
		war = rec_tab.WAR,
		dre = rec_tab.DRESS,
		anc = rec_tab.ANCIENT,
		nau = rec_tab.NAUTICAL,	-- 航海
		arc = rec_tab.ARCHAEOLOGY,  -- 考古
		cit = rec_tab.CITY,
		obs = rec_tab.OBSIDIAN,  -- 黑曜石
	}
	local g_tech = GLOBAL.TECH or TECH
	local tech_tbl = {
		none = g_tech.NONE,
		s_1 = g_tech.SCIENCE_ONE,
		s_2 = g_tech.SCIENCE_TWO,
		s_3 = g_tech.SCIENCE_THREE,
		s_9 = {SCIENCE=9},
		m_2 = g_tech.MAGIC_TWO,
		m_3 = g_tech.MAGIC_THREE,
		a_2 = g_tech.ANCIENT_TWO,
		a_3 = g_tech.ANCIENT_THREE,
		a_4 = g_tech.ANCIENT_FOUR,
		o_2 = g_tech.OBSIDIAN_TWO,
		h_2 = g_tech.HOME_TWO,
		city = g_tech.CITY,
		lost = g_tech.LOST,
	}
	local rg_type = GLOBAL.RECIPE_GAME_TYPE or RECIPE_GAME_TYPE
	local game_tbl = {
		com = rg_type.COMMON,
		rog = rg_type.ROG,
		sw  = rg_type.SHIPWRECKED,
		ham = rg_type.PORKLAND,
	}
	local game_type = {}
	-- if game == "com" then
	if type(game) == 'string' then
		game_type = game_tbl[game]
	elseif game == nil then
		game_type = game_tbl.com
	else
		for _, v in pairs(game) do
			table.insert(game_type, game_tbl[v])
		end
	end
	local ingredients = {}
	for i, v in pairs(ingd) do
		if i == 'hp' then i = CHARACTER_INGREDIENT.HEALTH
		elseif i == "max_hp" then i = CHARACTER_INGREDIENT.MAX_HEALTH
		elseif i == 'san' then i = CHARACTER_INGREDIENT.SANITY
		elseif i == "max_san" then i = CHARACTER_INGREDIENT.MAX_SANITY end
		if type(v) == "table" then
			local ingd = GLOBAL.Ingredient(i, v[1], v[2])
			ingd.image = v[3]
			table.insert(ingredients, ingd)
		else
			table.insert(ingredients, GLOBAL.Ingredient(i, v))
		end
	end
	local rcp = GLOBAL.Recipe(name, ingredients, tab_tbl[tab] or tab, tech_tbl[tech], game_type, placer)
	if atlas then rcp.atlas = "images/"..atlas..".xml" end
	if img then rcp.image = img..'.tex' end

	return rcp
end

local function add_map(atlas)
	AddMinimapAtlas("images/"..atlas..".xml")  
end

local function add_print(str, x)
	print(str..'--'..x)
	return x + 1
end

local function add_str(name, str1, str2, str3)
	local names = GLOBAL.STRINGS.NAMES or STRINGS.NAMES
	local generic = GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE or STRINGS.CHARACTERS.GENERIC.DESCRIBE
	local desc = GLOBAL.STRINGS.RECIPE_DESC or STRINGS.RECIPE_DESC
	name = string.upper(name)
	if str1 then names[name] = str1 end
	if str2 then generic[name] = str2 end
	if str3 then desc[name] = str3 end
end

local function add_tags(inst, tags)
	for i, v in pairs(tags) do
		inst:AddTag(v)
	end
end

local function remove_tags(inst, tags)
	for i, v in pairs(tags) do
		inst:RemoveTag(v)
	end
end

local function add_listen(inst, listeners)
	for i, v in pairs(listeners) do
		inst:ListenForEvent(i, v)
	end
end

local function make_prefab(anims, float_anim, phy, shadows, faced, fn)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local snd = inst.entity:AddSoundEmitter()

	local bank = anims and anims[1] or ''
	local build = anims and anims[2] or ''
	local anim_name = anims and anims[3] or ''
	anim:SetBank(bank)
	anim:SetBuild(build)
	anim:PlayAnimation(anim_name)
	if float_anim then
		if MakeInventoryFloatable then
	        MakeInventoryFloatable(inst, float_anim, anim_name)
	    end
	end
	local make_phy_tbl = {
		char = MakeCharacterPhysics,
		inv = MakeInventoryPhysics,
		obs = MakeObstaclePhysics,
	}
	if phy then
		if type(phy) == "string" then
			make_phy_tbl[phy](inst)
		else
			make_phy_tbl[phy[1]](inst, phy[2], phy[3])
		end
	end
	if shadows then
		local shadow = inst.entity:AddDynamicShadow()
		shadow:SetSize( shadows[1], shadows[2] )
	end
	if faced == 2 then
		trans:SetTwoFaced()
	elseif faced == 4 then
		trans:SetFourFaced()
	elseif faced == 6 then
		trans:SetSixFaced()
	elseif faced == 8 then
		trans:SetEightFaced()
	end

	if fn then
		fn(inst)
	end
	return inst
end

-- local function make_fx(pos, anims, loop, fn)
-- 	local inst = CreateEntity()
-- 	local trans = inst.entity:AddTransform()
-- 	local anim = inst.entity:AddAnimState()
-- 	local snd = inst.entity:AddSoundEmitter()

-- 	local bank = anims and anims[1] or ''
-- 	local build = anims and anims[2] or ''
-- 	local anim_name = anims and anims[3] or ''
-- 	anim:SetBank(bank)
-- 	anim:SetBuild(build)
-- 	anim:PlayAnimation(anim_name, loop)

-- 	if pos then
-- 		trans:SetPosition(pos:Get())
-- 	end

-- 	inst:AddTag('FX')
-- 	inst:AddTag('NOCLICK')
-- 	inst.persists = false

-- 	if fn then
-- 		fn(inst)
-- 	end

-- 	return inst
-- end

local function make_fx(pos, fx_name, is_follow)
	local fx = SpawnPrefab(fx_name)
	local pt = nil
	if fx then
		if pos.GetPosition then
			fx.Transform:SetPosition(pos:GetPosition():Get())
		elseif pos.Get then
			fx.Transform:SetPosition(pos:Get())
		end
		if is_follow and pos.entity then
			pos:AddChild(fx)
			fx.Transform:SetPosition(0, 0, 0)
		end
	end
	return fx
end

local function make_light(inst, falloff, intensity, radius, colour, enable)
	local light = inst.entity:AddLight()
	light:SetFalloff(falloff)
	light:SetIntensity(intensity)
	light:SetRadius(radius)
	light:SetColour(colour[1], colour[2], colour[3])
	light:Enable(enable)
end

local function make_map(inst, img, typ)
	local minimap = inst.entity:AddMiniMapEntity()
	if typ then
		minimap:SetIcon( img.."."..typ )
	else
		minimap:SetIcon(img)
	end
end

local function make_burn(inst, size, ...)
	if size == 'small' then
		MakeSmallBurnable(inst, ...)
	elseif size == 'med' then
		MakeMediumBurnable(inst, ...)
	elseif size == 'large' then
		MakeLargeBurnable(inst, ...)
	elseif size == 'c_small' then
		MakeSmallBurnableCharacter(inst, ...)
	elseif size == 'c_med' then
		MakeMediumBurnableCharacter(inst, ...)
	elseif size == "c_large" then
		MakeLargeBurnableCharacter(inst, ...)
	end
end

local function burn_bait(inst, n)
	if inst.components.burnable then
		inst.components.burnable:MakeDragonflyBait(n)
	end
end

local function make_prop(inst, size)
	if size == 'small' then
		MakeSmallPropagator(inst)
	elseif size == 'med' then
		MakeMediumPropagator(inst)
	elseif size == 'large' then
		MakeLargePropagator(inst)
	end
end

local function make_free(inst, size, ...)
	if size == 'tiny' then
		MakeTinyFreezableCharacter(inst, ...)
	elseif size == 'small' then
		MakeSmallFreezableCharacter(inst, ...)
	elseif size == 'med' then
		MakeMediumFreezableCharacter(inst, ...)
	elseif size == 'large' then
		MakeLargeFreezableCharacter(inst, ...)
	elseif size == 'huge' then
		MakeHugeFreezableCharacter(inst, ...)
	end
end

local function make_blow(inst, ...)
	MakeBlowInHurricane(inst, ...)
end

local function make_poi(inst, ...)
	MakePoisonableCharacter(inst, ...)
end

local function on_water(inst, pt)
	if pt then
		return inst:GetIsOnWater(pt.x, pt.y, pt.z)
	end
	return inst:GetIsOnWater()
end

local function on_land(inst, pt)
	if pt then
		return inst:GetIsOnLand(pt.x, pt.y, pt.z)
	end
	return inst:GetIsOnLand()
end

local function is_dlc(n)
	if SaveGameIndex then
		local tbl = {
			SaveGameIndex:IsModeSurvival(),
			SaveGameIndex:IsModeShipwrecked(),
			SaveGameIndex:IsModePorkland(),
		}
		return tbl[n]
	end
end

local function can_dlc(n)
	if GLOBAL.IsDLCEnabled then
		return GLOBAL.IsDLCEnabled(n)
	else
		return IsDLCEnabled(n)
	end
end

local function find(inst, range, fn, tags, no_tags)  -- fn(item, inst)
	return FindEntity(inst, range, fn, tags, no_tags)
end

local function finds(inst, range, tags, no_tags)
	local x, y, z
	if inst.Get then
		x, y, z = inst:Get()
	elseif inst.GetPosition then
		x, y, z = inst:GetPosition():Get()
	elseif type(inst)=="table" then
		x, y, z = inst[1], inst[2], inst[3]
	end
	if x and y and z then
		return TheSim:FindEntities(x, y, z, range, tags, no_tags)
	end
end

local function find_close(inst, tag, range)
	return GetClosestInstWithTag(tag, inst, range)
end

local function do_task(inst, ...)
	return inst:DoTaskInTime(...)
end

local function per_task(inst, ...)
	return inst:DoPeriodicTask(...)
end

local function around_land(inst, dist)
	local theta = math.random() * 2 * PI
    local pt = inst:GetPosition()
    -- local radius = math.random(3, 6)
    local radius = dist
    local offset = FindWalkableOffset(pt, theta, radius, 12, true)
    if offset then
        local pos = pt + offset
        return pos
    end
end

local function no_save(inst)
	inst.persists = false
end

local function key_down(key, fn)
	TheInput:AddKeyDownHandler(key, fn)
end

local function key_up(key, fn)
	TheInput:AddKeyUpHandler(key, fn)
end

local function area_dmg(inst, range, attacker, dmg, reason)
	local ents = WARGON.finds(inst, range, nil, {"player", "wall", "FX", "NOCLICK", "INLIMBO"})
	local attacker = attacker or inst
	for i, v in pairs(ents) do
		if attacker then
			if not v.components.follower or v.components.follower.leader ~= attacker then
				if v.components.combat and v.components.health
				and attacker.components.combat:CanTarget(v) then
					v.components.combat:GetAttacked(attacker, dmg, inst, reason)
				end
			end
		end
	end
end

local function fire_prefab(target)
	if target.components.burnable and not target.components.burnable:IsBurning() then
        if target.components.freezable and target.components.freezable:IsFrozen() then           
            target.components.freezable:Unfreeze()            
        else            
            if target.components.fueled and target:HasTag("campfire") and target:HasTag("structure") then
                -- Rather than worrying about adding fuel cmp here, just spawn some fuel and immediately feed it to the fire
                local fuel = SpawnPrefab("cutgrass")
                if fuel then target.components.fueled:TakeFuelItem(fuel) end
            else
                target.components.burnable:Ignite(true)
            end
        end   
    end

    if target:HasTag("aquatic") and not target.components.burnable then 
        local pt = target:GetPosition()
        local smoke = SpawnPrefab("smoke_out")
        smoke.Transform:SetPosition(pt:Get())

         if target.SoundEmitter then 
            target.SoundEmitter:PlaySound("dontstarve_DLC002/common/fire_weapon_out") 
        end 
    end 

    if target.components.freezable then
        target.components.freezable:AddColdness(-1) --Does this break ice staff?
        if target.components.freezable:IsFrozen() then
            target.components.freezable:Unfreeze()            
        end
    end

    if target.components.sleeper and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end

    target:PushEvent("attacked", { attacker = attacker, damage = 0 })
end

local function frozen_prefab(target)
	if not target:IsValid() then
        return
    end
    
    if target.components.sleeper and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end
    if target.components.burnable then
        if target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        elseif target.components.burnable:IsSmoldering() then
            target.components.burnable:SmotherSmolder()
        end
    end

    if target.sg ~= nil and not target.sg:HasStateTag("frozen") then
        target:PushEvent("attacked", { attacker = attacker, damage = 0 })
    end

    if target.components.freezable then
        target.components.freezable:AddColdness(1)
        target.components.freezable:SpawnShatterFX()
    end
end

local function poison_prefab(target)
	if target.components.poisonable and target:HasTag("poisonable") then
        target.components.poisonable:Poison()
    end 
end

local function shake_camera(inst)
	GetPlayer().components.playercontroller:ShakeCamera(inst, "FULL", 0.7, 0.02, 2, 40)
end

local function pigking_throw(inst, item)
	local nut = item
    local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,4.5,0)
    
    nug.Transform:SetPosition(pt:Get())
    local down = TheCamera:GetDownVec()
    local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
    --local angle = (-TUNING.CAM_ROT-90 + math.random()*60-30)/180*PI
    local sp = math.random()*4+2
    nug.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
    if nug.components.inventoryitem then
	    nug.components.inventoryitem:OnStartFalling()
    end
end

local function set_scale(inst, ...)
	local args = {...}
	if #args == 1 then
		local s = args[1]
		inst.Transform:SetScale(s,s,s)
	else
		inst.Transform:SetScale(...)
	end
end

local function set_pos(inst, ...)
	local args = {...}
	if #args == 1 then
		local x = args[1]
		inst.Transform:SetPosition(x,x,x)
	else
		inst.Transform:SetPosition(...)
	end
end

local function add_speed_rate(inst, ...)
	if inst.components.locomotor then
		inst.components.locomotor:AddSpeedModifier_Mult(...)
	end
end

local function remove_speed_rate(inst, ...)
	if inst.components.locomotor then
		inst.components.locomotor:RemoveSpeedModifier_Mult(...)
	end
end

local function add_dmg_rate(inst, ...)
	if inst.components.combat then
		inst.components.combat:AddDamageModifier(...)
	end	
end

local function remove_dmg_rate(inst, ...)
	if inst.components.combat then
		inst.components.combat:RemoveDamageModifier(...)
	end
end

local function add_hunger_rate(inst, ...)
	if inst.components.hunger then
		inst.components.hunger:AddBurnRateModifier(...)
	end
end

local function remove_hunger_rate(inst, ...)
	if inst.components.hunger then
		inst.components.hunger:RemoveBurnRateModifier(...)
	end
end

local function burn_save(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
		data.burnt = true
	end
end

local function burn_load(inst, data)
	if data and data.burnt and inst.components.burnable then
		inst.components.burnable.onburnt(inst)
	end
end

local function get_tile(pt)
	return GetGroundTypeAtPosition(pt)
end

local function can_deploy(inst, pt, range, no_tags, dist)
	local ents = WARGON.finds(pt, range, nil, no_tags)
	local min = dist or inst.components.deployable and inst.components.deployable.min_spacing
	for k, v in pairs(ents) do
		if v ~= inst and v:IsValid() and v.entity:IsVisible()
		and not v.components.placer and v.parent == nil then
			if distsq(Vector3(v:GetPosition():Get()), pt) < min*min then
				return false
			end
		end
	end
	return true
end

local function seed_save(inst, data)
	if inst.growtime then
        data.growtime = inst.growtime - GetTime()
    end
end

local function seed_load(inst, data)
	if data and data.growtime then
		WARGON.TREE.treeseed_plant(inst, data.growtime, inst.tree)
    end
end

local function is_monster(inst)
	return inst:HasTag("monster") or inst:HasTag("hound") 
		or inst:HasTag("spider_monkey")
end

local function play_snd(inst, snd)
	if inst.SoundEmitter then
		inst.SoundEmitter:PlaySound(snd)
	end
end

local function get_divide_point(inst, n, r)
	local pos = nil
	if inst.GetPosition then
		pos = inst:GetPosition()
	elseif inst.Get then
		pos = inst
	end
	if pos then
		local pts = {}
		local radius = r or 1
		for i = 1, n do
			local angle = PI/180 * 360/n * i
			local pt = pos
			pt.x = pt.x + math.cos(angle)*radius
			pt.z = pt.z + math.sin(angle)*radius
			table.insert(pts, pt)
		end
		return pts
	end
end

local function get_config(key)
	return GetModConfigData(key)
end

GLOBAL.WARGON = {
	add_asset 			= add_asset,
	add_recipe 			= add_recipe,
	add_map				= add_map,
	add_print 			= add_print,
	add_str 			= add_str,
	add_tags 			= add_tags,
	add_listen 			= add_listen,
	add_speed_rate		= add_speed_rate,
	add_dmg_rate		= add_dmg_rate,
	add_hunger_rate		= add_hunger_rate,
	remove_tags 		= remove_tags,
	remove_speed_rate 	= remove_speed_rate,
	remove_dmg_rate 	= remove_speed_rate,
	remove_hunger_rate 	= remove_hunger_rate,
	make_prefab 		= make_prefab,
	make_fx 			= make_fx,
	make_spawn 			= make_fx,
	make_light			= make_light,
	make_map 			= make_map,
	make_burn 			= make_burn,
	make_prop 			= make_prop,
	make_free 			= make_free,
	make_blow 			= make_blow,
	make_poi 			= make_poi,
	set_scale 			= set_scale,
	set_pos 			= set_pos,
	on_water 			= on_water,
	on_land 			= on_land,
	is_dlc 				= is_dlc,
	can_dlc 			= can_dlc,
	find 				= find,
	finds 				= finds,
	find_close 			= find_close,
	do_task 			= do_task,
	per_task 			= per_task,
	around_land 		= around_land,
	no_save 			= no_save,
	key_up 				= key_up,
	key_down 			= key_down,
	area_dmg 			= area_dmg,
	shake_camera		= shake_camera,
	fire_prefab 		= fire_prefab,
	frozen_prefab 		= frozen_prefab,
	poison_prefab 		= poison_prefab,
	pigking_throw		= pigking_throw,
	burn_save 			= burn_save,
	burn_load 			= burn_load,
	seed_save 			= seed_save,
	seed_load 			= seed_load,
	burn_bait 			= burn_bait,
	get_tile 			= get_tile,
	can_deploy 			= can_deploy,
	is_monster 			= is_monster,
	play_snd 			= play_snd,
	get_divide_point 	= get_divide_point,
	get_config 			= get_config,
}