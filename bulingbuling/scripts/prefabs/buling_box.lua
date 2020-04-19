local assets ={
	Asset("ANIM", "anim/buling_manual.zip"),
	Asset("ANIM", "anim/buling_box.zip"),
	Asset("ATLAS", "images/inventoryimages/buling_manual.xml"),
	Asset("ANIM", "anim/buling_ronglu.zip"),
	Asset("ANIM", "anim/cook_pot_warly.zip"),
	Asset("ANIM", "anim/ui_antchest_honeycomb.zip"),
	Asset("ANIM", "anim/wakuangji.zip"),
}
local hechengbiao = {
--塞德锭
["buling_zhongziding"]={"seeds,nil,seeds,nil,goldnugget,nil,seeds,nil,seeds,"}, 
--植物改良桌
["buling_planttable_item"]={"nil,nil,nil,boards,buling_zhongziding,boards,buling_zhongziding,nil,buling_zhongziding,"},
--不灵萃取机
["buling_ronglu_item"]={"cutstone,cutstone,cutstone,cutstone,transistor,cutstone,buling_zhongziding,buling_zhongziding,buling_zhongziding,"},
--电力中继器
["buling_zhongjiqi_item"]={"buling_zhongziding,transistor,buling_zhongziding,buling_zhongziding,transistor,buling_zhongziding,buling_zhongziding,buling_zhongziding,buling_zhongziding,"},
--生存发电机
["buling_shengcun_item"]={"nil,buling_ronglu_item,nil,buling_zhongziding,buling_zhongjiqi_item,buling_zhongziding,buling_zhongziding,buling_zhongziding,buling_zhongziding,"},
--不灵炮塔
["buling_paotai_item"]={"nil,gears,nil,nil,log,nil,buling_zhongziding,log,buling_zhongziding,"},
--不灵雷达
["buling_radar_item"]={"buling_zhongziding,compass,buling_zhongziding,buling_zhongziding,buling_zhongjiqi_item,buling_zhongziding,buling_zhongziding,buling_zhongziding,buling_zhongziding,"},
--不灵采集者
["buling_cropbox_item"]={"seeds,seeds,seeds,goldenshovel,gears,goldenshovel,buling_zhongziding,buling_zhongjiqi_item,buling_zhongziding,"},
--不灵电灯
["buling_diandeng_item"]={"nil,buling_glass,nil,nil,torch,nil,nil,buling_zhongziding,nil,"},
--人力发电机
["buling_huosai_item"]={"nil,nil,nil,cutstone,gears,cutstone,cutstone,cutstone,cutstone,"},
--种子培育机
["buling_seedbox_item"]={"buling_glass,buling_zhongziding,buling_glass,seeds,fertilizer,seeds,buling_zhongziding,buling_zhongziding,buling_zhongziding,"},
--太阳能发电机
["buling_solarenergy_item"]={"buling_glass,buling_glass,buling_glass,buling_zhongziding,buling_zhongjiqi_item,buling_zhongziding,buling_zhongziding,buling_zhongziding,buling_zhongziding,"},
--电动剪刀
["buling_jiandao"]={"buling_zhongziding,nil,buling_zhongziding,nil,buling_zhongjiqi_item,nil,twigs,nil,twigs,"},
--电动镐
["buling_diandonggao"]={"buling_zhongziding,buling_zhongjiqi_item,buling_zhongziding,nil,twigs,nil,nil,twigs,nil,"},
--电动斧
["buling_dianlifu"]={"nil,buling_zhongjiqi_item,buling_zhongziding,nil,twigs,buling_zhongziding,nil,twigs,nil,"},
--充电器
["buling_chongdianqi_item"]={"buling_zhongziding,buling_zhongjiqi_item,buling_zhongziding,nil,buling_zhongziding,nil,buling_zhongziding,buling_zhongziding,buling_zhongziding,"},
--齿轮
["gears"]={"nil,buling_zhongziding,nil,buling_zhongziding,nil,buling_zhongziding,nil,buling_zhongziding,nil,"},
--扳手
["buling_banshou"]={"nil,buling_zhongziding,nil,nil,twigs,buling_zhongziding,twigs,nil,nil,"},
--合金箱
["buling_chest_item"]={"buling_zhongziding,buling_zhongziding,buling_zhongziding,buling_zhongziding,nil,buling_zhongziding,buling_zhongziding,buling_zhongziding,buling_zhongziding,"},
--料理台
["buling_cooktable_item"]={"buling_zhongziding,buling_zhongziding,buling_zhongziding,buling_zhongziding,nil,buling_zhongziding,nil,nil,nil,"},
}
local shaozhibiao = {
	["buling_seed_wheat"] = "buling_flour",
	["buling_zhongziding"] = "buling_glass",
	["flint"] = "rocks",
	["rocks"] = "sand",
	["sand"] = "alloy",
	["carrot_seeds"] = "seeds",
	["corn_seeds"] = "seeds",
	["pumpkin_seeds"] = "seeds",
	["eggplant_seeds"] = "seeds",
	["durian_seeds"] = "seeds",
	["sweet_potato_seeds"] = "seeds",
	["pomegranate_seeds"] = "seeds",
	["dragonfruit_seeds"] = "seeds",
	["watermelon_seeds"] = "seeds",
	["aloe_seeds"] = "seeds",
	["asparagus_seeds"] = "seeds",
	["radish_seeds"] = "seeds",
}
local weaponhechengbiao ={

}
local seedhechengbiao ={
--燧石种子
["buling_seed_flint"]={"flint,flint,flint,flint,seeds,flint,flint,flint,flint,"},
--小麦种子
["buling_seed_wheat"]={"seeds,seeds,seeds,nil,seeds,nil,nil,nil,nil,"},
--硝石种子
["buling_seed_nitre"]={"nitre,nitre,nitre,nitre,seeds,nitre,nitre,nitre,nitre,"},
--岩石种子
["buling_seed_rock"]={"rocks,rocks,rocks,rocks,seeds,rocks,rocks,rocks,rocks,"},
--黄金种子
["buling_seed_gold"]={"goldnugget,goldnugget,goldnugget,goldnugget,seeds,goldnugget,goldnugget,goldnugget,goldnugget,"},
--十胜石种子
["buling_seed_obsidian"]={"gunpowder,redgem,gunpowder,ash,seeds,ash,gunpowder,ash,gunpowder,"},
--大理石种子
["buling_seed_marble"]={"sand,rocks,sand,rocks,seeds,rocks,sand,rocks,sand,"},
--塞德锭
["buling_zhongziding"]={"nil,seeds,nil,nil,goldnugget,nil,nil,seeds,nil,"}, 
--肥料
["buling_manure_8"]={"nil,ash,nil,ash,nitre,ash,nil,ash,nil,"}, 
}

--
local function get_name(inst)
	local name = STRINGS.NAMES[string.upper(inst.prefab)]
	local num = 0
	local beer = 0
		if inst.components.beerpower and inst.components.beerpower.PowerMax ~= 0 then
			num = inst.components.beerpower.power
			beer = inst.components.beerpower.beer
			name = name.."\n "..STRINGS.POWER.."<"..string.format("%.0f", num).."/"..inst.components.beerpower.PowerMax.."> "
		end	
	return name
end
local slotpos = {}
for y = 2, 0, -1 do
	for x = 0, 2 do
		table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
	end
end
--
local function buling_manual(inst)
	
	local widgetbuttoninfo = {
    text = "Do",
    position = Vector3(0, -140, 0),
    fn = function(inst)
		local peifang = ""
		local slots = inst.components.container.slots
		for k=1,9 do
			local item = inst.components.container:GetItemInSlot(k)
			if item == nil then
				item = "nil"
				else
				item = item.prefab
			end
			peifang = peifang..item..","
		end
		for k,v in pairs(hechengbiao) do
			if v[1] == peifang then
				inst.components.container:DestroyContents()
				inst.components.container:GiveItem(SpawnPrefab(k), 5)
				--GetPlayer().components.inventory:GiveItem(k)
			end
		end
	end, }
	local function OnOpen(inst)
		GetPlayer():PushEvent("OpenBuling_manual")
	end
	local function OnClose(inst)
		GetPlayer():PushEvent("CloseBuling_manual")
	end
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeObstaclePhysics(inst, .5)
    inst:AddComponent("inspectable")
	inst.AnimState:SetBank("buling_manual")
    inst.AnimState:SetBuild("buling_manual")
    inst.AnimState:PlayAnimation("idle")
	inst:AddComponent("container")
	inst.components.container:SetNumSlots(#slotpos)
	inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 100
	inst.components.container.widgetbuttoninfo = widgetbuttoninfo
	inst.components.container.acceptsstacks = false
	inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
	inst.beeritem = "buling_manual_item"
	return inst
end
local function ronglufn()
	local function itemtest(inst, item, slot)
		if slot == 1 and shaozhibiao[item.prefab] ~= nil  then
			return true
		end
		if slot == 2 then
			return true
		end
		
	end
	local function duidie(inst,itemname)
		local item2 = inst.components.container:GetItemInSlot(2)
		if item2 and item2.prefab == itemname and (item2.components.stackable and not item2.components.stackable:IsFull()) then
			item2.components.stackable:SetStackSize(item2.components.stackable.stacksize+1)
		else
			inst.components.container:GiveItem(SpawnPrefab(itemname), 2)
		end
	end
	local widgetbuttoninfo = {
	text = "BBQ",
	position = Vector3(0, -140, 0),
	fn = function(inst)
		local item = inst.components.container:GetItemInSlot(1)
		if  item then
			if shaozhibiao[item.prefab] ~= nil then
				if inst.components.beerpower.power >= 10 then
					local replacement = shaozhibiao[item.prefab]
					if replacement then
						inst.components.container:ConsumeByName(item.prefab,1)
						duidie(inst,replacement)
						inst.components.beerpower:UpBeer(10)
					end
				else
					GetPlayer().components.talker:Say(STRINGS.BULING_BWNG)
				end
			end
		end
	end}
	local function OnOpen(inst)
		--VisitURL("https://www.bilibili.com")
		GetPlayer():PushEvent("OpenBuling_cuiqu")
	end
	local function OnClose(inst)
		GetPlayer():PushEvent("CloseBuling_cuiqu")
	end
	local slotpos = {Vector3(-80,0,0),Vector3(80,0,0)}
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize(2,0.75)
	trans:SetFourFaced()
	inst.AnimState:SetBuild("buling_ronglu")
	inst.AnimState:SetBank("buling_ronglu")
	inst.AnimState:PlayAnimation("idle")
	inst:AddComponent("inspectable")
	inst:AddComponent("beerpower")
	inst.components.beerpower:SetNumber(200)
	inst.displaynamefn = get_name
	inst:AddComponent("container")
	inst.components.container:SetNumSlots(#slotpos)
	inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 100
	inst.components.container.widgetbuttoninfo = widgetbuttoninfo
	inst.components.container.itemtestfn = itemtest
	inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
	inst.beeritem = "buling_ronglu_item"
	return inst
end
local function buling_solarenergy(inst)
	local function task(inst)
		local pos = Vector3(inst.Transform:GetWorldPosition())
		local ents = TheSim:FindEntities(pos.x,pos.y,pos.z,15)
		local nengliang = -10
		if GetClock():IsNight() and GetClock():GetMoonPhase() == "full" then
			nengliang = -8
		end
		if GetClock():IsNight() then
			nengliang = 0
		end
		if GetClock():IsDusk() then
			nengliang = -5
		end
		if GetClock():IsDay() then
			nengliang = -10
		end
		for k,v in pairs(ents) do
			if v and v.components.beerpower and 
				v.components.beerpower.PowerMax > 0 and  
				v.components.beerpower.power < v.components.beerpower.PowerMax and
				v:HasTag("zhongjiqi") then
				v.components.beerpower:UpBeer(nengliang)
				break
			end
		end
	end
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeObstaclePhysics(inst, .5)
	inst.task = inst:DoPeriodicTask(5,function()task(inst)end)
    inst:AddComponent("inspectable")
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
    inst.AnimState:PlayAnimation("buling_solarenergy")
	inst.beeritem = "buling_solarenergy_item"
	return inst
end 
--种子管家
local function buling_seedbox(inst)
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeObstaclePhysics(inst, .5)
    inst:AddComponent("inspectable")
	inst:AddComponent("beerpower")
	inst.components.beerpower:SetNumber(200)
	inst.displaynamefn = get_name
	inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
    inst.AnimState:PlayAnimation("seedbox")
	inst.Transform:SetScale(2, 2, 2)
	inst.nengliang = 0
	local function turnon(inst)
		inst.components.machine.ison = true
		if inst.components.beerpower.power < 5 then
			inst:DoTaskInTime(0,function()
				inst.components.machine:TurnOff()
			end)
		end
	end
	local function turnoff(inst)
		inst.components.machine.ison = false
	end	
	inst:DoPeriodicTask(5,function()
		if inst.components.machine.ison == true then
			inst.components.beerpower:UpBeer(5)
			local NOTAGS = {"FX", "DECOR", "INLIMBO", "flingomatic_freeze_immune"}
			local x,y,z = inst:GetPosition():Get()
			local ents = TheSim:FindEntities(x,y,z, 15, {}, NOTAGS)
			for k,v in pairs(ents) do
				if v then
					if v.makewitherabletask then
						v.makewitherabletask:Cancel()
						v.makewitherabletask = nil
						v:AddTag("protected")
						if v.components.crop then
							v.components.crop.protected = true
						elseif v.components.pickable then
							v.components.pickable.protected = true
						end
						elseif v.components.crop and v.components.crop.witherable then
						v.components.crop.protected = true
						v:AddTag("protected")
						elseif v.components.pickable and v.components.pickable.witherable then
						v.components.pickable.protected = true
						if v.components.pickable.withered or v.components.pickable.shouldwither then
							if v.components.pickable.cycles_left and v.components.pickable.cycles_left <= 0 then
								v.components.pickable:MakeBarren()
							else
								v.components.pickable:MakeEmpty()
							end
							v.components.pickable.withered = false
							v.components.pickable.shouldwither = false
							v:RemoveTag("withered")
						end
						v:AddTag("protected")
					end
					if  (GetSeasonManager():IsWinter() and GetSeasonManager():GetCurrentTemperature() <= 0) then
						if v.components.crop then
							v.components.crop.growthpercent = v.components.crop.growthpercent + 4*v.components.crop.rate
						end
						if v.components.grower then
							v.components.grower.cycles_left = v.components.grower.cycles_left + 0.0125
						end
						if v.components.pickable then
							if v.components.pickable.protected_cycles ~= nil then
								v.components.pickable.protected_cycles = v.components.pickable.protected_cycles + 0.0125
							else
								v.components.pickable.protected_cycles = 0.0125
							end
						end
					end
				end
			end
		end
	end)
	local function onsave(inst,data)
		data.nengliang = inst.nengliang 
	end
	local function onload(inst,data)
		if data then
			inst.nengliang = data.nengliang
		end
	end
	inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
	inst.OnSave = onsave
    inst.OnLoad = onload
	inst.beeritem = "buling_seedbox_item"
	return inst
end 
--武装整备台
local function buling_weaponchest(inst)
	local widgetbuttoninfo = {
	text = "Do",
	position = Vector3(0, -140, 0),
	fn = function(inst)
		if inst.components.beerpower.power >= 50 then 
			
			local peifang = ""
			local slots = inst.components.container.slots
			for k=1,9 do
				local item = inst.components.container:GetItemInSlot(k)
				if item == nil then
					item = "nil"
					else
					item = item.prefab
				end
				peifang = peifang..item..","
			end
			for k,v in pairs(weaponhechengbiao) do
				if v[1] == peifang then
					inst.components.container:DestroyContents()
					inst.components.container:GiveItem(SpawnPrefab(k), 5)
					inst.components.beerpower:UpBeer(50)
				end
			end
		end
	end}
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inspectable")
	inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
	inst.AnimState:PlayAnimation("weaponchest")
	inst:AddComponent("beerpower")
	inst.components.beerpower:SetNumber(100)
	inst.displaynamefn = get_name
	inst:AddComponent("container")
	inst.components.container:SetNumSlots(#slotpos)
	inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 100
	inst.components.container.widgetbuttoninfo = widgetbuttoninfo
	inst.components.container.acceptsstacks = false
	inst.beeritem = "buling_weaponchest_item"
	return inst
end
--电动收割机
local function shouhuo(inst)
	local function shouhuotime(inst)
		local pos = Vector3(inst.Transform:GetWorldPosition())
		local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 15)
		for k,v in pairs(ents) do
			if v.components.pickable and v.prefab ~= "flower" then
				v.components.pickable:Pick(GetPlayer())
			end
			if v.components.crop then
				v.components.crop:Harvest(GetPlayer())
			end
		end
	end
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inspectable")
	inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
	inst.AnimState:PlayAnimation("shouhuo")
	local function turnon(inst)
		inst.components.machine.ison = true
		shouhuotime(inst)
		inst:DoTaskInTime(0,function()
			inst.components.machine:TurnOff()
			inst.components.beerpower:UpBeer(60)
		end)
	end
	local function turnoff(inst)
		inst.components.machine.ison = false
		inst.components.machine.caninteractfn = function() return  inst.components.beerpower and inst.components.beerpower.power >= 60 end
	end
	inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
	inst:AddComponent("beerpower")
	inst.components.beerpower:SetNumber(100)
	inst.components.machine.cooldowntime = 0
	inst.displaynamefn = get_name
	inst.beeritem = "buling_cropbox_item"
	return inst
end
--雷达
local function radar(inst)
	local function leida(inst)
		GetPlayer().components.inventory:ConsumeByName("buling_dianchi", 9)
		local map = TheSim:FindFirstEntityWithTag("minimap")
		local x,y,z = GetPlayer().Transform:GetWorldPosition()
		map.MiniMap:ShowArea(x, y, z, 10000)
	end
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inspectable")
	inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
	inst.AnimState:PlayAnimation("leida")
	local function turnon(inst)
		inst.components.machine.ison = true
		GetPlayer().components.talker:Say(STRINGS.BULING_LEIDA)
		leida(inst)
		inst:DoTaskInTime(0,function()
			inst.components.machine:TurnOff()
			inst.components.beerpower:UpBeer(800)
		end)
	end
	local function turnoff(inst)
		inst.components.machine.ison = false
		inst.components.machine.caninteractfn = function() return  inst.components.beerpower and inst.components.beerpower.power >= 800 end
	end
	inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
	inst.Transform:SetScale(2,2,2)
	inst:AddComponent("beerpower")
	inst.components.beerpower:SetNumber(1000)
	inst.components.machine.cooldowntime = 0
	inst.displaynamefn = get_name
	inst.beeritem = "buling_radar_item"
	return inst
end
--电力
local function commonfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeObstaclePhysics(inst, .5)
    inst:AddComponent("inspectable")
	inst.AnimState:SetBank("buling_zaxiang")
    inst.AnimState:SetBuild("buling_zaxiang")
	inst:AddComponent("beerpower")
	inst.displaynamefn = get_name
    return inst
end
--炮台
local function paotai(inst)
	local function WeaponDropped(inst)
		inst:Remove()
	end
	local function EquipWeapon(inst)
		local function canattack(inst, target)
			if inst.components.beerpower.power >= 5 then
				return true
			end
		end
		local function onattack(inst, owner, target)
			owner.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/shotexplo")
			owner.components.beerpower:UpBeer(5)
		end
		if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
			local weapon = CreateEntity()
			weapon.entity:AddTransform()
			weapon:AddComponent("weapon")
			weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
			weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange+4)
			weapon.components.weapon:SetProjectile("bishop_charge")
			weapon:AddComponent("inventoryitem")
			weapon.persists = false
			weapon.components.inventoryitem:SetOnDroppedFn(WeaponDropped)
			weapon:AddComponent("equippable")
			weapon.components.weapon:SetOnAttack(onattack)
			weapon.components.weapon:SetCanAttack(canattack)
			inst.components.inventory:Equip(weapon)
		end
	end
	local inst=commonfn(inst)
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("jianyipaotai")
	local function shouldKeepTarget(inst, target)
		if target and target:IsValid() and
			(target.components.health and not target.components.health:IsDead()) then
			local distsq = target:GetDistanceSqToInst(inst)
			return distsq < 20*20
		else
			return false
		end
	end
	local function retargetfn(inst)
		local notags = {"FX", "NOCLICK","INLIMBO"}
		local newtarget = FindEntity(inst, 20, function(guy)
				return  guy.components.combat and 
						inst.components.combat:CanTarget(guy) and
						(guy.components.combat.target == GetPlayer() or GetPlayer().components.combat.target == guy)
		end, nil, notags)
		return newtarget
	end
	inst.components.beerpower:SetNumber(50)
	inst:AddComponent("inventory")
	
	inst:AddComponent("combat")
	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(50)
    inst.components.combat:SetRange(15)
    inst.components.combat:SetDefaultDamage(15)
    inst.components.combat:SetAttackPeriod(TUNING.EYETURRET_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(15, retargetfn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
	inst:DoTaskInTime(1, EquipWeapon)  
	inst:DoPeriodicTask(1,function()
		local pos = Vector3(inst.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 15)
        for k,v in pairs(ents) do
            local pt1 = v:GetPosition()
            if v.components.combat and v.components.health and not v.components.health:IsDead() and( v.components.combat.target == inst or v:HasTag("monster") or v.components.combat.target == GetPlayer() or GetPlayer().components.combat.target == v) and inst.components.beerpower.power >= 5 then
				inst.components.combat:SetTarget(v)
				inst.components.combat:DoAttack()
			end
		end
	
	end)
	inst.beeritem = "buling_paotai_item"
	return inst
end
--电力中继器
local function zhongjiqi(inst)
	local function task(inst)
		local task = inst:DoPeriodicTask(5,function()
			--print("e")
		if inst.components.beerpower.power >= 5 and inst.components.machine.ison == true then
			local pos = Vector3(inst.Transform:GetWorldPosition())
			local ents = TheSim:FindEntities(pos.x,pos.y,pos.z,15)
				for k,v in pairs(ents) do
					if v and v.components.beerpower and 
						v.components.beerpower.PowerMax > 0 and  
						v.components.beerpower.power < v.components.beerpower.PowerMax and 
						not v:HasTag("zhongjiqi")
						then
						v.components.beerpower:UpBeer(-5)
						inst.components.beerpower:UpBeer(5)
					end
				end
				else
				inst.components.machine:TurnOff()
				if inst.task then
					inst.task:Cancel()
					inst.task = nil
				end
			end
		end)
		return task
	end
	local function turnon(inst)
		inst.components.machine.ison = true
		inst.AnimState:PlayAnimation("zhongjiqi_on")
		inst.task = task(inst)
		if inst.components.beerpower.power < 5 then
			inst:DoTaskInTime(0,function()
				inst.components.machine:TurnOff()
				if inst.task then
					--print("bbb1")
					inst.task:Cancel()
					inst.task = nil
				end
			end)
		end
	end
	local function turnoff(inst)
		inst.components.machine.ison = false
		inst.AnimState:PlayAnimation("zhongjiqi_off")
		if inst.task then
			--print("bbb")
			inst.task:Cancel()
			inst.task = nil
		end
	end	
	local inst=commonfn(inst)
	MakeObstaclePhysics(inst, 1)
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("zhongjiqi_off")
	inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
	inst.components.beerpower:SetNumber(1000)
	inst.components.machine.caninteractfn = function() return inst.components.beerpower and inst.components.beerpower.power > 5 end
	inst:AddTag("zhongjiqi")
	inst.beeritem = "buling_zhongjiqi_item"
	return inst
end
--生存发电机
local function shengcun(inst)
	local function get_name(inst)
		local name = STRINGS.NAMES[string.upper(inst.prefab)]
		name = name.."\n"..STRINGS.FUEL..":"..inst.components.fueled.currentfuel.."/1000"
	return name
	end
	local function task(inst)
		if inst.components.fueled.currentfuel > 0 then
			inst.components.fueled:DoDelta(-5)
			local pos = Vector3(inst.Transform:GetWorldPosition())
			local ents = TheSim:FindEntities(pos.x,pos.y,pos.z,15)
				for k,v in pairs(ents) do
					if v and v.components.beerpower and 
						v.components.beerpower.PowerMax > 0 and  
						v.components.beerpower.power < v.components.beerpower.PowerMax and
						v:HasTag("zhongjiqi") then
						v.components.beerpower:UpBeer(-5)
						break
					end
				end
				else
				inst.task:Cancel()
				inst.task = nil
			end
	end
	local function ontakefuel(inst)
		inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
		if inst.task == nil then
			inst.task = inst:DoPeriodicTask(5,function()task(inst)end)
		end
	end
	local inst=commonfn(inst)
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("shengcunfadianji")
	inst.task = inst:DoPeriodicTask(5,function()task(inst)end)
	inst:AddComponent("fueled")
	--inst.components.fueled.fueltype = "HUAXUERANLIAO"
	inst.components.fueled.maxfuel = 1000
	inst.components.fueled.ontakefuelfn = ontakefuel
    inst.components.fueled.accepting = true
	inst.components.fueled:SetDepletedFn(function(inst) 
		if inst.task then
			inst.task:Cancel()
			inst.task = nil
		end
	end)
	inst.displaynamefn = get_name
	inst.beeritem = "buling_shengcun_item"
	return inst
end
--电灯
local function diandeng(inst)
	local function turnon(inst)
		inst.components.machine.ison = true
		inst.Light:Enable(true)
		inst.AnimState:PlayAnimation("diandeng_on")
		inst.components.beerpower:StartPerishing()
		if inst.components.beerpower.power < 2 then
			inst:DoTaskInTime(0,function()
				inst.components.machine:TurnOff()
			end)
		end
	end
	local function turnoff(inst)
		inst.components.machine.ison = false
		inst.Light:Enable(false)
		inst.AnimState:PlayAnimation("diandeng_off")
		inst.components.beerpower:StopPerishing()
		inst.components.machine.caninteractfn = function() return  inst.components.beerpower and inst.components.beerpower.power > 2 end
	end
	local inst=commonfn(inst)
	inst.entity:AddLight()
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("diandeng_off")
    inst.Light:SetColour(180/255, 195/255, 150/255)
	inst.Light:Enable(false)
	inst.Light:SetIntensity(.75)
    inst.Light:SetFalloff( 0.9 )
    inst.Light:SetRadius( 8 )
	inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
	inst.components.beerpower:SetNumber(50,2)
	inst.components.machine.cooldowntime = 0
	inst.beeritem = "buling_diandeng_item"
	-- wargon fix
	inst:DoPeriodicTask(1, function()
		if inst.components.beerpower.power <= 0 then
			inst.components.machine:TurnOff()
		end
	end)
	-- wargon fix
	return inst
end
local function chongdian(inst)
	local function itemtest(inst, item, slot)
		return item:HasTag("beerpowertool")
	end
	local slotpos = {Vector3(0,0,0)}
	local widgetbuttoninfo = {
    text = "Charge",
    position = Vector3(0, -140, 0),
    fn = function(inst)
		local item = inst.components.container:GetItemInSlot(1)
		if item and item:HasTag("beerpowertool") and item.components.finiteuses then
			local beer = item.components.finiteuses.total - item.components.finiteuses.current
			if beer > 0 then
				if inst.components.beerpower.power >= beer then
					inst.components.beerpower:UpBeer(beer)
					item.components.finiteuses:Use(-beer)
					inst:AddComponent("equippable")
				else 
					local bp = inst.components.beerpower.power
					inst.components.beerpower:UpBeer(bp)
					item.components.finiteuses:Use(-bp)
					inst:AddComponent("equippable")
				end
			end
		end
	end, }
	local inst= commonfn(inst)
	inst.displaynamefn = get_name
	inst.AnimState:PlayAnimation("ai_aff")
	inst.components.beerpower:SetNumber(200)
	inst:AddComponent("container")
    inst.components.container:SetNumSlots(1.1)
	inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 100
	inst.components.container.widgetbuttoninfo = widgetbuttoninfo
	inst.components.container.itemtestfn = itemtest
	inst.components.container.canbeopened = true
	inst.beeritem = "buling_chongdianqi_item"
	return inst
end

local function buling_pot(inst)
	local slotpos = {Vector3(0,80,0),Vector3(0,0,0),Vector3(0,-80,0)}
	local widgetbuttoninfo = {
    text = "Do",
    position = Vector3(0, -140, 0),
    fn = function(inst)
		local item = inst.components.container:GetItemInSlot(1)
		local item2 = inst.components.container:GetItemInSlot(2)
		local item3 = inst.components.container:GetItemInSlot(3)
		if item and item2 then
			local nug = SpawnPrefab("buling_liaoli")
			nug.components.finiteuses:SetUses(2)
			nug.liaoli = item.prefab
			nug.liaoli2 = item2.prefab
			nug.hp = item.components.edible.healthvalue + item2.components.edible.healthvalue
			nug.hun = item.components.edible.hungervalue + item2.components.edible.hungervalue
			nug.san = item.components.edible.sanityvalue + item2.components.edible.sanityvalue
			if item3 then
				nug.liaoli3 = item3.prefab
			end
			local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,4.5,0)  
			nug.Transform:SetPosition(pt:Get())
			local down = TheCamera:GetDownVec()
			local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
			local sp = math.random()*4+2
			nug.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
			
		end
	end, }
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeObstaclePhysics(inst, .5)
    inst:AddComponent("inspectable")
	inst.AnimState:SetBank("cook_pot_warly")
    inst.AnimState:SetBuild("cook_pot_warly")
    inst.AnimState:PlayAnimation("idle_empty")
	inst:AddComponent("container")
	inst.components.container:SetNumSlots(#slotpos)
	inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 100
	inst.components.container.widgetbuttoninfo = widgetbuttoninfo
	inst.components.container.acceptsstacks = false
	return inst
end
local function bulingbox(inst)
	local slotpos = {}
	for y = 4, 0, -1 do
		for x = 0, 4 do
			table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
		end
	end
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeObstaclePhysics(inst, .5)
    inst:AddComponent("inspectable")
	inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
    inst.AnimState:PlayAnimation("chest")
	inst:AddComponent("container")
	inst.components.container:SetNumSlots(#slotpos)
	inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetpos = Vector3(-50,100,0)
    inst.components.container.side_align_tip = 100
	inst.beeritem = "buling_chest_item"
	return inst
end
local function bulingbeebox(inst)
	local function beework(inst)
		local item = inst.components.container:GetItemInSlot(4)
		if item and item.beeworkfn then
			item.beeworkfn(item,inst)
		end
	end
	local slotpos = {
		Vector3(-40,80,0),
		Vector3(40,80,0),
		Vector3(-80,0,0),
		Vector3(0,0,0),
		Vector3(80,0,0),
		Vector3(-40,-80,0),
		Vector3(40,-80,0),
	}
	local function itemtest(inst, item, slot)
		if slot == 4 and item:HasTag("bulingbug") then
			return true
		end
		if slot ~= 4 then
			return true
		end
	end
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeObstaclePhysics(inst, .5)
    inst:AddComponent("inspectable")
	inst.AnimState:SetBank("bee_box")
    inst.AnimState:SetBuild("bee_box")
    inst.AnimState:PlayAnimation("idle")
	inst:AddComponent("container")
	inst.components.container:SetNumSlots(#slotpos)
	inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetpos = Vector3(0,100,0)
    inst.components.container.side_align_tip = 100
	inst.components.container.acceptsstacks = false
	inst.components.container.widgetanimbank = "ui_antchest_honeycomb"
    inst.components.container.widgetanimbuild = "ui_antchest_honeycomb"
	inst.components.container.itemtestfn = itemtest
	inst.beeritem = "buling_chest_item"
	inst:ListenForEvent("itemget",function(inst, data)
		if data.slot == 4 and data.item:HasTag("bulingbug") then
			inst.beetask = inst:DoPeriodicTask(5,function()
				beework(inst)
			end)
		end
	end)
	inst:ListenForEvent("itemlose",function(inst, data)
		if data.slot == 4 and inst.beetask then
			inst.beetask:Cancel()
			inst.beetask = nil
		end
	end)
	return inst
end
local function planttable(inst)
	local widgetbuttoninfo = {
	text = "Do",
	position = Vector3(0, -140, 0),
	fn = function(inst)
		local peifang = ""
		local slots = inst.components.container.slots
		for k=1,9 do
			local item = inst.components.container:GetItemInSlot(k)
			if item == nil then
				item = "nil"
				else
				item = item.prefab
			end
			peifang = peifang..item..","
		end
		for k,v in pairs(seedhechengbiao) do
			if v[1] == peifang then
				inst.components.container:DestroyContents()
				inst.components.container:GiveItem(SpawnPrefab(k), 5)
			end
		end
	end}
	local function OnOpen(inst)
		GetPlayer():PushEvent("OpenBuling_planttable")
	end
	local function OnClose(inst)
		GetPlayer():PushEvent("CloseBuling_planttable")
	end
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inspectable")
	inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
	inst.AnimState:PlayAnimation("planttable")
	inst.displaynamefn = get_name
	inst:AddComponent("container")
	inst.components.container:SetNumSlots(#slotpos)
	inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 100
	inst.components.container.widgetbuttoninfo = widgetbuttoninfo
	inst.components.container.acceptsstacks = false
	inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
	inst.beeritem = "buling_planttable_item"
	return inst
end
--人力发电
local function huosaifadian(inst)
	local function turnon(inst)
		inst.components.machine.ison = true
		inst.AnimState:PlayAnimation("huosaifadian2")
		inst.AnimState:PushAnimation("huosaifadian")
		inst.components.beerpower:StartPerishing()
		local pos = Vector3(inst.Transform:GetWorldPosition())
		local ents = TheSim:FindEntities(pos.x,pos.y,pos.z,15)
			for k,v in pairs(ents) do
				if v and v.components.beerpower and 
					v.components.beerpower.PowerMax > 0 and  
					v.components.beerpower.power < v.components.beerpower.PowerMax and
					v:HasTag("zhongjiqi") then
					v.components.beerpower:UpBeer(-2)
					break
				end
			end
		inst:DoTaskInTime(1,function()
			inst.components.machine:TurnOff()
		end)
	end
	local function turnoff(inst)
		inst.components.machine.ison = false
		inst.AnimState:PlayAnimation("huosaifadian2")
	end
	local inst=commonfn(inst)
	MakeObstaclePhysics(inst, .5)
	--inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
	inst.AnimState:PlayAnimation("huosaifadian")
	inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
	inst.components.machine.cooldowntime = 1
	inst.beeritem = "buling_huosai_item"
	return inst
end
local function wakuang(inst)
	local function chukuang(inst,kuangwu)
		--for k = 1, math.random(1,5) do
			local nug = SpawnPrefab(kuangwu)
			local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,4.5,0)
                
			nug.Transform:SetPosition(pt:Get())
			local down = TheCamera:GetDownVec()
			local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
			local sp = math.random()*4+2
			nug.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
		--end
	end
	local function task(inst)
		inst.components.beerpower:UpBeer(75)
		local kuangwuzhi = math.random(1,150)
		local kuangwu = "rocks"
		if kuangwuzhi < 5 then
			kuangwu = "nitre"
		elseif kuangwuzhi > 5 and kuangwuzhi < 10 then
			kuangwu = "flint"
		elseif kuangwuzhi > 10 and kuangwuzhi < 30 then
			kuangwu = "gears"
		elseif kuangwuzhi > 30 and kuangwuzhi < 50 then
			kuangwu = "flint"
		elseif kuangwuzhi > 50 and kuangwuzhi < 60 then
			kuangwu = "nitre"
		elseif kuangwuzhi > 60 and kuangwuzhi < 70 then
			kuangwu = "obsidian"
		elseif kuangwuzhi > 70 and kuangwuzhi < 80 then
			kuangwu = "marble"
		elseif kuangwuzhi > 80 and kuangwuzhi < 90 then
			kuangwu = "goldnugget"
		elseif kuangwuzhi > 90 and kuangwuzhi < 100 then
			kuangwu = "seeds"
		elseif kuangwuzhi > 100 and kuangwuzhi < 110 then
			kuangwu = "tar"
		end
		chukuang(inst,kuangwu)
	end
	local inst=commonfn(inst)
	inst.AnimState:SetBank("wakuangji")
    inst.AnimState:SetBuild("wakuangji")
	inst.AnimState:PlayAnimation("idle",true)
	local function turnon(inst)
		inst.components.machine.ison = true
		inst.AnimState:PlayAnimation("workpre")
		inst.AnimState:PushAnimation("worded",true)
		inst:DoTaskInTime(10,function()
			task(inst)
			inst.components.machine:TurnOff()
		end)
	end
	local function turnoff(inst)
		inst.components.machine.ison = false
		inst.AnimState:PlayAnimation("workpst")
		inst.AnimState:PushAnimation("idle",true)
	end	
	inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
	inst.components.machine.cooldowntime = 10
	inst.Transform:SetScale(2, 2, 2)
	inst.beeritem = "buling_wakuang_item"
	return inst
end
return Prefab("buling_manual", buling_manual, assets),--合成台
Prefab("buling_diandeng", diandeng, assets),--电灯
Prefab("buling_wakuang", wakuang, assets),--挖矿机
Prefab("buling_huosai", huosaifadian, assets),--人力发电
Prefab("buling_chongdianqi", chongdian, assets),--充电器
Prefab("buling_shengcun", shengcun, assets),--生存发电机
Prefab("buling_zhongjiqi", zhongjiqi, assets),--电力中继器
Prefab("buling_solarenergy", buling_solarenergy, assets),--太阳能发电机
Prefab("buling_ronglu", ronglufn, assets),--萃取机
Prefab("buling_seedbox", buling_seedbox, assets),--种子增值机
Prefab("buling_weaponchest", buling_weaponchest, assets),--机械加工炉
Prefab("buling_cropbox", shouhuo, assets),--采集者
Prefab("buling_radar", radar, assets),--雷达
Prefab("buling_paotai", paotai, assets),--简易炮台
Prefab("buling_chest", bulingbox, assets),--合金储存箱
Prefab("buling_planttable", planttable, assets),--植物改良桌
Prefab("buling_bee_box", bulingbeebox, assets),--不灵蜂箱
MakePlacer("buling_manual_placer", "buling_manual", "buling_manual", "idle"),
MakePlacer("buling_planttable_placer", "buling_box", "buling_box", "planttable"),
MakePlacer("buling_wakuang_placer", "wakuangji", "wakuangji", "idle"),
MakePlacer("buling_chest_placer", "buling_box", "buling_box", "chest"),
MakePlacer("buling_ronglu_placer", "buling_ronglu", "buling_ronglu", "idle")