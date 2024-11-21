local homes = {"pig_house", "pighouse_logcabin", "idle"}
local home_phy = {"obs", 1, nil}

local function home_hammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
        inst.components.burnable:Extinguish()
    end
	if inst.components.spawner then inst.components.spawner:ReleaseChild() end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function home_hit(inst, worker)
    if not inst:HasTag("burnt") then
    	inst.AnimState:PlayAnimation("hit")
    	inst.AnimState:PushAnimation("idle")
    end
end

local function home_light_on(inst)
	if not inst:HasTag("burnt") then
        inst.Light:Enable(true)
        inst.AnimState:PlayAnimation("lit", true)
        inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lighton")
        inst.lightson = true
    end
end

local function home_light_off(inst)
	if not inst:HasTag("burnt") then
        inst.Light:Enable(false)
        inst.AnimState:PlayAnimation("idle", true)
        inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lightoff")
        inst.lightson = false
    end
end

local function home_occupied(inst, child)
	inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/city_pig/pig_in_house_LP", "pigsound")
	inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
	home_light_on(inst)
    if not inst:HasTag("burnt") and child then
    	if child.components.inventory then
    		if not inst.components.container:IsFull() then
                for k, v in pairs(child.components.inventory.itemslots) do
                    if inst.components.container:IsFull() then
                    	break
                    end
                    local item = child.components.inventory:RemoveItemBySlot(k)
                    if item then
                        inst.components.container:GiveItem(item)
                    end
                end
            end
    	end
    	WARGON.do_task(inst, 10, function()
    		if not GetClock():IsNight()
    		and inst.components.spawner:IsOccupied() then
				inst.components.spawner:ReleaseChild()
    		end
    	end)
    end
end

local function home_vacate(inst, child)
	inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
    inst.SoundEmitter:KillSound("pigsound")
    home_light_off(inst)
    if not inst:HasTag("burnt") and child then
    	if child.components.health then
	        child.components.health:SetPercent(1)
    	end
    end
end

local function home_day_time(inst)
	 if not inst:HasTag("burnt") then
        if inst.components.spawner:IsOccupied() then
        	home_light_off(inst)
            if inst.doortask then
                inst.doortask:Cancel()
                inst.doortask = nil
            end
            inst.doortask = WARGON.do_task(inst, 1 + math.random()*2, function()
            	inst.components.spawner:ReleaseChild()
            end)
        end
    end
end

local function home_burnt_up(inst, data)
	if inst.doortask then
		inst.doortask:Cancel()
		inst.doortask = nil
	end
end

local function home_onignite(inst, data)
	if inst.components.spawner then
		inst.components.spawner:ReleaseChild()
	end
end

local function home_on_built(inst, data)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
end

local function home_open(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function home_close(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function home_cont_test(inst)
	return true
end

local function MakeHome(name, pig_name)
	local function fn()
		local inst = WARGON.make_prefab(homes, nil, home_phy)
		WARGON.CMP.add_cmps(inst, {
			inspect = {},
			loot = {},
			work = {act=ACTIONS.HAMMER, num=4, ham=home_hammered, hit=home_hit},
			spawn = {child=pig_name, time=30*16, occupied=home_occupied, vacate=home_vacate},
			cont = {widgets={}, num=9, open=home_open, close=home_close, test=home_cont_test},
		})
		WARGON.make_map(inst, "pighouse_logcabin.tex")
		-- falloff, intensity, radius, colour, enable
		WARGON.make_light(inst, 1, .5, 1, {180/255, 195/255, 50/255}, false)
		WARGON.add_listen(inst, {
			burntup = home_burnt_up,
			onignite = home_onignite,
			onbuilt = home_on_built,
		})
		WARGON.add_tags(inst, {
			"structure",
			})
		WARGON.make_burn(inst, 'med', nil, nil, true)
		WARGON.make_prop(inst, 'large')
		inst:ListenForEvent('daytime', function()
			home_day_time(inst)
		end, GetWorld())
		WARGON.do_task(inst, math.random(), function()
			if GetClock():IsDay() then
				home_day_time(inst)
			end
		end)
		inst.OnSave = WARGON.burn_save
		inst.OnLoad = WARGON.burn_load

		return inst
	end
	return Prefab("common/object/"..name, fn, {})
end

return 
	MakeHome("tp_chop_pig_home", "tp_chop_pig"),
	MakeHome("tp_hack_pig_home", "tp_hack_pig"),
	MakeHome("tp_farm_pig_home", "tp_farm_pig"),
	MakePlacer("common/tp_chop_pig_home_placer", homes[1], homes[2], homes[3]),
	MakePlacer("common/tp_hack_pig_home_placer", homes[1], homes[2], homes[3]),
	MakePlacer("common/tp_farm_pig_home_placer", homes[1], homes[2], homes[3])