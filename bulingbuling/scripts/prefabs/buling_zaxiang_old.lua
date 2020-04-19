local assets =
{
	Asset("ANIM", "anim/buling_zaxiang.zip"),
	Asset("ANIM", "anim/hat_tiexue.zip"),
	Asset("ANIM", "anim/millbuilder.zip"),
	Asset("ANIM", "anim/swap_beeraxe.zip"),
	Asset("ANIM", "anim/swap_beerpickaxe.zip"),
	Asset("ANIM", "anim/swap_buling_shears.zip"),
	Asset("ANIM", "anim/buling_manual.zip"),
	Asset("ANIM", "anim/buling_tuzhi.zip"),
	Asset("ANIM", "anim/wakuangji.zip"),
	Asset("ATLAS", "images/inventoryimages/buling_ai.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_diandonggao.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_dianlifu.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_diandeng.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_huaxueranliao.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_huoli.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_jidi.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_jinshu.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_kuangjia.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_lingjian.xml"),
	
	Asset("ATLAS", "images/inventoryimages/buling_ranliaozhizuo.xml"),
	
	Asset("ATLAS", "images/inventoryimages/buling_shengwu.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_yanmo.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_yaokongqi.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_yuxiang.xml"),
	
	Asset("ATLAS", "images/inventoryimages/millbuilder.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_wakuang.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_manual.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_naozhi.xml"),
	
	
}

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
local function commonfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inspectable")
	inst.AnimState:SetBank("buling_zaxiang")
    inst.AnimState:SetBuild("buling_zaxiang")
	inst:AddComponent("beerpower")
	inst.displaynamefn = get_name
    return inst
end
--生物发电机
local function shengwu(inst)
	local inst=commonfn(inst)
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("shengwufadian")
	return inst
end

--零件制作台
local function lingjian(inst)
	local function get_name(inst)
		local name = STRINGS.NAMES[string.upper(inst.prefab)]
		local item = nil
		local time = 0
			if inst.task then
				item = STRINGS.NAMES[string.upper(inst.itemtarget)]
				time = GetTaskRemaining(inst.task)
				name = name..(item ~= nil and ("\n"..STRINGS.BULINGITEM.."<"..item..">")or "")..(time > 0 and ("\n "..STRINGS.BULINGTIME.."<"..string.format("%.0f", time).."s>") or "")
			end	
		return name
	end
	local function makeitem(inst)
		for k = 1,inst.num do
			local nug = SpawnPrefab(inst.itemtarget)
			local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,4.5,0)
			nug.Transform:SetPosition(pt:Get())
			local down = TheCamera:GetDownVec()
			local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
			local sp = math.random()*4+2
			nug.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
		end
		inst.itemtarget = nil
		inst.num = nil
		inst.maketime = nil
		inst.AnimState:PlayAnimation("lingjian_on")
		inst.components.activatable.inactive = true
		inst.task = nil
	end
	local function WorkStart(inst,data)
		if data then
			inst.itemtarget = data.itemtarget
			inst.num = data.num
			inst.maketime = data.maketime
		end
		inst.AnimState:PlayAnimation("lingjian_off")
		inst.components.activatable.inactive = false
		inst.task = inst:DoTaskInTime(inst.maketime,function()
			makeitem(inst)
		end)
	end
	local function OnActivate_GoTo(inst)
		inst:DoTaskInTime(0.5,function()
			--GetPlayer():PushEvent("openlingjian")
			GetPlayer().jiqi = inst
            local bulinglingjian = require "widgets/bulinglingjian"
            TheFrontEnd:PushScreen(bulinglingjian())
			inst.components.activatable.inactive = true
		end)
	end
	local inst=commonfn(inst)
	inst.displaynamefn = get_name
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("lingjian_on")
	inst:AddComponent("activatable")
    inst.components.activatable.inactive = true
	inst.components.activatable.quickaction = true
	inst.components.activatable.OnActivate = OnActivate_GoTo
	inst:ListenForEvent("WorkStart",WorkStart)
	
	local function onsave(inst, data)
		if inst.itemtarget and inst.num and inst.maketime then
			data.itemtarget = inst.itemtarget
			data.num = inst.num
			data.maketime = GetTaskRemaining(inst.task)
		end
	end
	local function onload(inst, data)
		if data.maketime and data.num and data.itemtarget then
			inst.itemtarget = data.itemtarget
			inst.num = data.num
			inst.maketime = data.maketime
			inst.AnimState:PlayAnimation("lingjian_off")
			inst.components.activatable.inactive = false
			WorkStart(inst)
			
		end
	end
	inst.OnSave = onsave
    inst.OnLoad = onload
	return inst
end
--机械框架
local function kuangjia(inst)
	local inst=commonfn(inst)
	--inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("jiqikuangjia")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_kuangjia"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_kuangjia.xml"
	inst:AddComponent("stackable")
	inst.displaynamefn = nil
	return inst
end
--金属原料
local function jinshu(inst)
	local inst=commonfn(inst)
	inst.Transform:SetScale(0.5, 0.5, 0.5)
	inst.AnimState:PlayAnimation("jinshuyuanliao")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_jinshu"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_jinshu.xml"
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM 
	inst.displaynamefn = nil
	return inst
end
--基地
local function jidi(inst)
	local slotpos = {}

	for y = 5, 0, -1 do
		for x = 0, 5 do
			table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
		end
	end
	local SCIENCEMACHINE2 =
	{
		    	SCIENCE = 3,
		    	MAGIC = 1,
		    	ANCIENT = 0,
		    	OBSIDIAN = 0,
		    	WATER = 0,
				LOST = 0,
	}
	local inst=commonfn(inst)
	inst:AddTag("prototyper")
	inst:AddTag("level3")
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("jidi")
	inst:AddComponent("prototyper")
	inst.components.prototyper.trees = SCIENCEMACHINE2
	--[[inst:AddComponent("container")

    inst.components.container:SetNumSlots(#slotpos)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetpos = Vector3(-50,100,0)
    inst.components.container.side_align_tip = 160]]
	inst:AddComponent("door")
	return inst
end

--火力发电机
local function huoli(inst)
	local function task(inst)
		
		--报燃料
			inst.components.talker:Say(STRINGS.FUEL..":"..inst.components.fueled.currentfuel.."/360", 5, false)
		--
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
				inst.task = nil
			end
		
	end
	local function ontakefuel(inst)
		inst.components.talker:Say(STRINGS.FUEL..":"..inst.components.fueled.currentfuel.."/360", 5, false)
		inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
		if inst.task == nil then
			inst.task = inst:DoPeriodicTask(5,function() task(inst)end)
		end
		if not inst.fire then
            inst.fire = SpawnPrefab( "torchfire" )
			inst.fire.Transform:SetScale(2,2,2)
            inst.fire:AddTag("INTERIOR_LIMBO_IMMUNE")	-- TODO: Fix follower handling in interiorspawner
            inst.fire.entity:SetParent(inst.entity)
			inst.fire.Transform:SetPosition(0,1,0)
        end
	end
	local inst=commonfn(inst)
	
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("huolifadian")
	inst.task = inst:DoPeriodicTask(5,function() task(inst)end)
	inst:AddComponent("talker")
	inst.components.talker.offset = Vector3(0,-200,0)
	inst:AddComponent("fueled")
	inst.components.fueled.maxfuel = TUNING.FIREPIT_FUEL_MAX
	inst.components.fueled.ontakefuelfn = ontakefuel
    inst.components.fueled.accepting = true
	inst.components.fueled:SetDepletedFn(function(inst) 
		if inst.task then
			inst.task = nil
		end
		if inst.fire then
			inst:RemoveChild(inst.fire)
			inst.fire:Remove()
			inst.fire = nil
		end
	end)
	inst:DoTaskInTime(0,function()
		inst.components.talker:Say(STRINGS.FUEL..":"..inst.components.fueled.currentfuel.."/360", 5, false)
		if not inst.fire and inst.components.fueled.currentfuel > 0 then
			inst.fire = SpawnPrefab( "torchfire" )
			inst.fire.Transform:SetScale(2,2,2)
			inst.fire:AddTag("INTERIOR_LIMBO_IMMUNE")	-- TODO: Fix follower handling in interiorspawner
			inst.fire.entity:SetParent(inst.entity)
			inst.fire.Transform:SetPosition(-0.3,1,0)
		end
	end) 
	
	return inst
end
--燃料制造机
local function ranliaozhizuo(inst)
	local function kaishizhizuo(inst)
		if  inst.components.beerpower.work~= true and inst.components.beerpower.power > 5 then
			--inst.components.beerpower:StopPerishing()
			for i = 1, inst.components.container:GetNumSlots() do
				local item = inst.components.container:GetItemInSlot(i)
				if item and (item.prefab == "log" or item.components.edible)  then
					if item.components.edible then
						inst.ranliao = math.floor(item.components.edible.hungervalue%10) 						
					end
					if item.prefab == "log" then
						inst.ranliao = 2
					end
					inst.components.container:ConsumeByName(item.prefab, 1)
					inst.components.beerpower:StartPerishing()
					break
				end
			end
			--inst.components.beerpower:StopPerishing()
			return
		end
	end 
	local function ranliaozhizao(inst)
		print(inst.ranliao)
		for k = 1,inst.ranliao do
			local nug = SpawnPrefab("buling_huaxueranliao")
			local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,4.5,0)
			nug.Transform:SetPosition(pt:Get())
			local down = TheCamera:GetDownVec()
			local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
			local sp = math.random()*4+2
			nug.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
		end
		inst.ranliao = 1
		inst.components.beerpower:StopPerishing()
		kaishizhizuo(inst)
	end
	local function turnon(inst)
		inst.components.machine.ison = true
		inst.components.beerpower:StartPerishing()
	end
	local function turnoff(inst)
		inst.components.machine.ison = false
		inst.components.beerpower:StopPerishing()
	end
	--------------------
	local slotpos_3x3 = {}

	for y = 2, 0, -1 do
		for x = 0, 2 do
			table.insert(slotpos_3x3, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
		end
	end
	local function itemtest(inst, item, slot)
		return (item.components.edible and item.components.edible.hungervalue > 10) or 
		item.prefab == "log" 
	end
	--------------------
	local inst=commonfn(inst)
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("huaxueranliaozhizuo")
	inst.components.beerpower:SetNumber(100,10,10)
	inst.components.beerpower:Setworkfn(ranliaozhizao)
	inst.ranliao = 1
    --[[inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff]]
	
	
	inst:AddComponent("container")
	inst.components.container.itemtestfn = itemtest
    inst.components.container:SetNumSlots(#slotpos_3x3)
    inst.components.container.widgetslotpos = slotpos_3x3
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 160
	inst:ListenForEvent("itemget",kaishizhizuo)
	local function onsave(inst, data)
		data.ranliao = inst.ranliao
		data.work = inst.components.beerpower.work
	end
	local function onload(inst, data)
		if data then
			inst.ranliao = data.ranliao
			inst.components.beerpower.work = data.work
		end
		if inst.components.beerpower.work == true then
			inst.components.beerpower:StartPerishing()
		end
	end
	inst.OnSave = onsave
    inst.OnLoad = onload
	return inst
end
--化学燃料
local function huaxueranliao(inst)
	local inst=commonfn(inst)
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("huaxueranliao")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_huaxueranliao"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_huaxueranliao.xml"
	inst:AddComponent("stackable")
	inst.displaynamefn = nil
	inst:AddComponent("fuel")
    inst.components.fuel.fueltype = "HUAXUERANLIAO"
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	return inst
end

--ai打印机
local function ai(inst)
	--ui
	local function OnActivate_GoTo(inst)
		inst:DoTaskInTime(0.5,function()
			GetPlayer():PushEvent("openai")
			GetPlayer().jiqi = inst
		end)
	end
	--
	local function task(inst)
		inst:DoPeriodicTask(5,function()
			if inst.components.beerpower.beer >= 100 and inst.beeritem then
				inst.components.beerpower.beer = 0
				local nug = SpawnPrefab(inst.beeritem)
				local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,4.5,0)
				nug.Transform:SetPosition(pt:Get())
				local down = TheCamera:GetDownVec()
				local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
				local sp = math.random()*4+2
				nug.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
				inst.beeritem = nil
			end
			if inst.beeritem and inst.components.beerpower.power >= 5 then
				inst.components.beerpower.power = inst.components.beerpower.power - 5
				inst.components.beerpower.beer = inst.components.beerpower.beer + 1
			end
		end)
	end
	local inst=commonfn(inst)
	
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("ai_aff")
	inst.components.beerpower:SetNumber(100)
	inst.task = task(inst)
	inst:AddComponent("activatable")
    inst.components.activatable.inactive = true
	inst.components.activatable.quickaction = true
	inst.components.activatable.OnActivate = OnActivate_GoTo
	return inst
end
--鱼箱
local function yuxiang(inst)
	local inst=commonfn(inst)
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
	
	
	
	
	inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("yuxiang_off")
	return inst
end
--遥控器
local function yaokongqi(inst)
	local function createlight(inst)
		local firerain = SpawnPrefab("firerain")
        firerain.Transform:SetPosition(TheInput:GetWorldPosition():Get())
        firerain:StartStep()
		inst:AddTag("cd")
		local jidi = SpawnPrefab("buling_jidi")
		jidi.Transform:SetPosition(TheInput:GetWorldPosition():Get())
		jidi:Hide()
		jidi:DoTaskInTime(1.9,function()
			jidi:Show()
			inst:Remove()
			local pos = Vector3(jidi.Transform:GetWorldPosition())
			local ents = TheSim:FindEntities(pos.x,pos.y,pos.z,15)
				for k,v in pairs(ents) do
					if v and v.prefab == "lavapool"  then
						v:Remove()
					end
				end
		end)
	end
	local function cancreatelight(staff, caster, target, pos)
		local ground = GetWorld()
		if ground and pos then
			local tile = ground.Map:GetTileAtPoint(pos.x, pos.y, pos.z)
			return  not staff:HasTag("cd") 
		end
		--return true
	end
	local inst=commonfn(inst)
	--inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("yaokongqi")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_yaokongqi"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_yaokongqi.xml"
	inst.displaynamefn = nil
	--[[inst.components.inspectable.getstatus = function(inst,viewer)
		viewer.AnimState:OverrideSymbol("swap_hat", "hat_tiexue", "swap_hat")
        viewer.AnimState:Show("HAT")
        viewer.AnimState:Show("HAT_HAIR")
	end]]
	inst:AddComponent("equippable")
	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(createlight)
	inst.components.spellcaster.actiontype = "hujiao"
	inst.components.spellcaster:SetSpellTestFn(cancreatelight)
	inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.canusefrominventory = false
	return inst
end
--研磨机
local function yanmo(inst)
	local itemyanmo = {
		rocks = "flint",
		flint = "rocks",
		nitre = "marble",
		marble = "nitre",
		cutstone = "nitre",
	}
	local inst=commonfn(inst)
	inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:PlayAnimation("yanmo")
	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(
		function(inst, item)
			return inst.components.beerpower.power > 10 and itemyanmo[item.prefab] ~= nil
		end)
	inst.components.trader.onaccept = OnGetItemFromPlayer
	inst.components.beerpower:SetNumber(100)
	return inst
end

--简易研磨机
local function millbuilder(inst)
	local itemyanmo = {
		rocks = "sand",
		flint = "buling_jinshu",
		goldnugget = "buling_jinshu",
		iron = "buling_jinshu",
		cutstone = "rocks",
	}
	local numyanmo = {
		flint = 2
	}
	local numyanmoitem = {
		cutstone = 3
	}
	local function OnGetItemFromPlayer(inst, giver, item)
		inst.AnimState:PlayAnimation("idle",false)
		if numyanmo[item.prefab] and numyanmo[item.prefab] > 1 then
			local a = numyanmo[item.prefab] - 1
			GetPlayer().components.inventory:ConsumeByName(item.prefab, a)
		end
		if item.prefab == "sand" then 
			local itemnames = {"ash","nil","rocks","nil","flint","nil","iron","nil","nil","nil","buling_jinshu","nil","nil"}
			local itemname = itemnames[math.random(#itemnames)]
			if itemname ~= "nil" then
				giver.components.inventory:GiveItem( SpawnPrefab(itemname))
			end
			else
			for k=1,numyanmoitem[item.prefab]or 1 do
				giver.components.inventory:GiveItem( SpawnPrefab(itemyanmo[item.prefab])) 
			end
		end
		
	end
	local inst=commonfn(inst)
	inst.Transform:SetScale(0.8, 0.8, 0.8)
	inst.AnimState:SetBank("millbuilder")
    inst.AnimState:SetBuild("millbuilder")
	inst.AnimState:PlayAnimation("idle",false)
	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(
		function(inst, item)
			print(numyanmo[item.prefab] or 1)
			return (itemyanmo[item.prefab] ~= nil and GetPlayer().components.inventory:Has(item.prefab, numyanmo[item.prefab] or 1)) or item.prefab == "sand"
		end)
	inst.components.trader.onaccept = OnGetItemFromPlayer
	return inst
end

--电力挖矿机
local function wakuang(inst)
	local function chukuang(inst,kuangwu)
		for k = 1, math.random(1,5) do
			local nug = SpawnPrefab(kuangwu)
			local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,4.5,0)
                
			nug.Transform:SetPosition(pt:Get())
			local down = TheCamera:GetDownVec()
			local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
			local sp = math.random()*4+2
			nug.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
		end
	end
	local function task(inst)
		if inst.components.beerpower.power > 75 then
			inst:DoTaskInTime(0,function()
				inst.components.machine:TurnOff()
				if inst.task then
					inst.task:Cancel()
					inst.task = nil
				end	
			end)
		end 
			inst.components.beerpower:UpBeer(75)
			local kuangwuzhi = math.random(1,150)
			local kuangwu = "rocks"
			if kuangwuzhi < 5 then
				kuangwu = "thulecite"
			elseif kuangwuzhi > 5 and kuangwuzhi < 10 then
				kuangwu = "orangegem"
			elseif kuangwuzhi > 10 and kuangwuzhi < 30 then
				kuangwu = "gears"
			elseif kuangwuzhi > 30 and kuangwuzhi < 50 then
				kuangwu = "flint"
			elseif kuangwuzhi > 50 and kuangwuzhi < 60 then
				kuangwu = "nitre"
			elseif kuangwuzhi > 60 and kuangwuzhi < 70 then
				kuangwu = "buling_jinshu"
			elseif kuangwuzhi > 70 and kuangwuzhi < 80 then
				kuangwu = "marble"
			elseif kuangwuzhi > 80 and kuangwuzhi < 90 then
				kuangwu = "goldnugget"
			elseif kuangwuzhi > 90 and kuangwuzhi < 120 then
				kuangwu = "buling_jinshu"
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
		inst.AnimState:PushAnimation("worded")
		inst.task = inst:DoPeriodicTask(40,function() task(inst) end)
		if inst.components.beerpower.power < 75 then
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
		inst.AnimState:PlayAnimation("workpst")
		inst.AnimState:PushAnimation("idle",true)
		if inst.task then
			inst.task:Cancel()
			inst.task = nil
		end
	end	
	inst.components.beerpower:SetNumber(150)
	inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
	inst.Transform:SetScale(2, 2, 2)
	return inst
end
--电动镐
local function diandonggao()

    local function onequip(inst, owner)
		if inst.components.finiteuses.current<= 0 then
			local hands = GetPlayer().components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			inst:DoTaskInTime(0.1,function()
				owner.components.inventory:DropItem(hands)
			end)
		end
		owner.AnimState:OverrideSymbol("swap_object", "swap_beerpickaxe", "swap_beerpickaxe")
		owner.AnimState:Show("ARM_carry")
		owner.AnimState:Hide("ARM_normal")
		
	end
	local function onunequip(inst, owner)
		owner.AnimState:Hide("ARM_carry")
		owner.AnimState:Show("ARM_normal")
	end
	local function onfinished(inst)
		if inst.components.equippable then
            local target = GetPlayer()
            local item = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if inst == item then
                target.components.inventory:GiveItem(item)
            end
            inst:RemoveComponent("equippable")
        end
	end 
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("needle")
    inst.AnimState:SetBuild("needle")
	inst.AnimState:PlayAnimation("idle")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_diandonggao"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_diandonggao.xml"
	inst:AddTag("beertool")
    
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(120)
	inst.components.finiteuses:SetUses(1)
	inst.components.finiteuses:SetOnFinished(onfinished)
    inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(15)
    inst:AddComponent("inspectable")
	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.MINE,1)
	inst.components.finiteuses:SetConsumption(ACTIONS.MINE, 1)
	return inst
end
local function dianlifu()--电动斧

    local function onequip(inst, owner)
		owner.AnimState:OverrideSymbol("swap_object", "swap_beeraxe", "swap_beeraxe")
		owner.AnimState:Show("ARM_carry")
		owner.AnimState:Hide("ARM_normal")
		if inst.components.finiteuses.current<= 0 then
			print("xxxx")
			local hands = GetPlayer().components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			inst:DoTaskInTime(0.1,function()
				owner.components.inventory:DropItem(hands)
			end)
		end
	end
	local function onunequip(inst, owner)
		owner.AnimState:Hide("ARM_carry")
		owner.AnimState:Show("ARM_normal")
	end
	local function onfinished(inst)
		if inst.components.equippable then
            local target = GetPlayer()
            local item = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if inst == item then
                target.components.inventory:GiveItem(item)
            end
            inst:RemoveComponent("equippable")
        end
	end 
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("needle")
    inst.AnimState:SetBuild("needle")
	inst.AnimState:PlayAnimation("idle")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_dianlifu"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_dianlifu.xml"
	inst:AddTag("beertool")
    
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(120)
	inst.components.finiteuses:SetUses(1)
	inst.components.finiteuses:SetOnFinished(onfinished)
    inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(15)
    inst:AddComponent("inspectable")
	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.CHOP,3)
	inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)
	return inst
end
local function jiandao(Sim)
	local function onfinished(inst)
		if inst.components.equippable then
            local target = GetPlayer()
            local item = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if inst == item then
                target.components.inventory:GiveItem(item)
            end
            inst:RemoveComponent("equippable")
        end
	end

	local function onequip(inst, owner) 
		owner.AnimState:OverrideSymbol("swap_object", "swap_buling_shears", "swap_shears")
		owner.AnimState:Show("ARM_carry")
		owner.AnimState:Hide("ARM_normal")
	end

	local function onunequip(inst, owner)
		owner.AnimState:Hide("ARM_carry")
		owner.AnimState:Show("ARM_normal")
	end
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)
    
    anim:SetBank("shears")
    anim:SetBuild("shears")
    anim:PlayAnimation("idle")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SHEARS_DAMAGE)
    inst:AddTag("shears")

    ---------------------------------------------------------------
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.SHEAR,2)
    ---------------------------------------------------------------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(120)
    inst.components.finiteuses:SetUses(0)
    
    inst.components.finiteuses:SetOnFinished( onfinished )
    inst.components.finiteuses:SetConsumption(ACTIONS.SHEAR, 1)
    ---------------------------------------------------------------

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    --inst.components.inventoryitem:ChangeImageName("machete")

    return inst
end
--研究桌
local function buling_manual(inst)
	local function OnActivate_GoTo(inst,doer)
		if doer.components.sanity and doer.components.sanity.current >= 10 and doer.components.hunger and doer.components.hunger.current >= 10  then
			doer.components.sanity:DoDelta(-10)
			doer.components.hunger:DoDelta(-10)
			doer.components.inventory:GiveItem(SpawnPrefab("buling_naozhi"))
			else
			doer.components.talker:Say(STRINGS.BULINGYANJIUSHIBAI,4,false)
		end 
		
		inst.components.beeryanjiu.inactive = true
	end
	local inst=commonfn(inst)
	
	inst.AnimState:SetBank("buling_manual")
    inst.AnimState:SetBuild("buling_manual")
    inst.AnimState:PlayAnimation("idle")
	inst.displaynamefn = nil
	
	inst:AddComponent("beeryanjiu")
	inst.components.beeryanjiu.OnYanjiu = OnActivate_GoTo
	return inst
end
--脑汁
local function naozhi(inst)
	local inst=commonfn(inst)
	--inst.Transform:SetScale(2, 2, 2)
	inst.AnimState:SetBank("buling_tuzhi")
    inst.AnimState:SetBuild("buling_tuzhi")
    inst.AnimState:PlayAnimation("naozhi")
	inst:AddComponent("stackable")
	inst.displaynamefn = nil
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_naozhi"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_naozhi.xml"
	inst:AddComponent("tradable")
	return inst
end
return Prefab("buling_ai", ai, assets),--ai打印机
Prefab("buling_diandeng", diandeng, assets),--电灯
Prefab("buling_huaxueranliao", huaxueranliao, assets),--化学燃料
Prefab("buling_ranliaozhizuo", ranliaozhizuo, assets),--燃料制造机
Prefab("buling_huoli", huoli, assets),--火力发电机

Prefab("buling_jidi", jidi, assets),--基地
Prefab("buling_jinshu", jinshu, assets),--金属原料
Prefab("buling_kuangjia", kuangjia, assets),--机械框架
Prefab("buling_lingjian", lingjian, assets),--零件制作台

Prefab("buling_wakuang", wakuang, assets),--挖矿机
Prefab("buling_yaokongqi", yaokongqi, assets),--摇控器
Prefab("buling_diandonggao", diandonggao, assets),--电动镐
Prefab("buling_dianlifu", dianlifu, assets),--电动斧
Prefab("buling_yanmo", yanmo, assets),--研磨机
Prefab("buling_jiandao", jiandao, assets),--电动剪刀
Prefab("millbuilder", millbuilder, assets),--简易研磨机
Prefab("buling_manual", buling_manual, assets),--不灵研究桌
Prefab("buling_naozhi", naozhi, assets),--脑汁

MakePlacer( "buling_manual_placer", "buling_manual", "buling_manual", "idle" ),
MakePlacer( "buling_lingjian_placer", "buling_zaxiang", "buling_zaxiang", "lingjian_on" )
