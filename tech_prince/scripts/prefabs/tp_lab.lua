require "prefabutil"

--local cooking = require("smelting")

local assets=
{
	-- Asset("ANIM", "anim/smelter.zip"),
	--Asset("ANIM", "anim/cook_pot_food.zip"),
}

local prefabs = {}
--[[
for k,v in pairs(cooking.recipes.cookpot) do
	table.insert(prefabs, v.name)
end
]]


local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	if not inst:HasTag("burnt") and inst.components.tpstewer and inst.components.tpstewer.product and inst.components.tpstewer.done then
		inst.components.lootdropper:AddChanceLoot(inst.components.tpstewer.product, 1)
	end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit_empty")
		
		if inst.components.tpstewer.cooking then
			inst.AnimState:PushAnimation("cooking_loop1")
		elseif inst.components.tpstewer.done then
			-- inst.AnimState:PushAnimation("cooking_finish")
			inst.AnimState:PushAnimation("idle")
		else
			inst.AnimState:PushAnimation("idle")
		end
	end
end

local slotpos = {	Vector3(0,64+32+8+4,0), 
					Vector3(0,32+4,0),
					Vector3(0,-(32+4),0), 
					Vector3(0,-(64+32+8+4),0)}

local widgetbuttoninfo = {
	text = STRINGS.TP_STR.tp_craft,
	position = Vector3(0, -165, 0),
	fn = function(inst)
		inst.components.tpstewer:StartCooking()	
	end,
	
	validfn = function(inst)
		return inst.components.tpstewer:CanCook()
	end,
}

local function itemtest(inst, item, slot)
	if not inst:HasTag("burnt") then
		-- if item.prefab == "bluegem" then
			return true
		-- end
	end
end

--anim and sound callbacks
local function ShowProduct(inst)
	if not inst:HasTag("burnt") then
		local product = inst.components.tpstewer.product
		if inst.fx == nil then
			inst.fx = SpawnPrefab("tp_fx_has_item")
			inst:AddChild(inst.fx)
			if product then
				-- local img = get_image(product)
				-- local atlas, image = inst.components.tpstewer:ResolvePath(img)
				local product_img_manager = WARGON.DATA.tp_data_composed.product_img_manager
				local atlas, image = product_img_manager:get_img(product)
				inst.fx.components.tpfollowimage:SetImage(atlas, image)
				-- local atlas = product == "ash" and "images/inventoryimages.xml" or "images/inventoryimages/"..img..".xml"
				-- inst.fx.components.tpfollowimage:SetImage(atlas, img..".tex")
			end
		end
	end
end

local function startcookfn(inst)
	if not inst:HasTag("burnt") then
		-- inst.AnimState:PlayAnimation("smelting_pre")
		inst.AnimState:PlayAnimation("cooking_loop3_pre")
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/smelter/move_1")
		-- inst.AnimState:PushAnimation("smelting_loop", true)
		inst.AnimState:PushAnimation("cooking_loop1")
		inst.SoundEmitter:KillSound("snd")
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/smelt_LP", "snd")
		inst.Light:Enable(true)
	end
end


local function onopen(inst)
	if not inst:HasTag("burnt") then
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/move_3", "open")
	end
	if inst.components.tpwidget then

	end
end

local function onclose(inst)
	if not inst:HasTag("burnt") then
		if not inst.components.tpstewer.cooking then
			-- inst.AnimState:PlayAnimation("idle_empty")
			inst.AnimState:PlayAnimation("idle")
			inst.SoundEmitter:KillSound("snd")
		end
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/move_3", "close")
	end
end

local function spoilfn(inst)
	if not inst:HasTag("burnt") then
		inst.components.tpstewer.product = inst.components.tpstewer.spoiledproduct
		ShowProduct(inst)
	end
end

local function donecookfn(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("cooking_finish")
		inst.AnimState:PushAnimation("idle")
		-- inst.AnimState:PlayAnimation("smelting_pst")
		-- inst.AnimState:PushAnimation("idle_full")
		ShowProduct(inst)
		inst.SoundEmitter:KillSound("snd")
		inst.Light:Enable(false)
		-- inst:DoTaskInTime(1/30, function()
  --               -- if inst.AnimState:IsCurrentAnimation("smelting_pst") then
  --               if inst.AnimState:IsCurrentAnimation("cooking_finish") then
  --                  inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/move_1")
  --              end
  --          end )
		-- inst:DoTaskInTime(8/30, function()
  --               -- if inst.AnimState:IsCurrentAnimation("smelting_pst") then
  --               if inst.AnimState:IsCurrentAnimation("cooking_finish") then
  --                  inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/move_2")
  --              end
  --          end )
		-- inst:DoTaskInTime(14/30, function()
  --               -- if inst.AnimState:IsCurrentAnimation("smelting_pst") then
  --               if inst.AnimState:IsCurrentAnimation("cooking_finish") then
  --                  inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/pour")
  --              end
  --          end )
		-- inst:DoTaskInTime(31/30, function()
  --               -- if inst.AnimState:IsCurrentAnimation("smelting_pst") then
  --               if inst.AnimState:IsCurrentAnimation("cooking_finish") then
  --                  inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/steam")
  --              end
  --          end )
  --       inst:DoTaskInTime(36/30, function()
  --               -- if inst.AnimState:IsCurrentAnimation("smelting_pst") then
  --               if inst.AnimState:IsCurrentAnimation("cooking_finish") then
  --                  inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/brick")
  --              end
  --          end )   
  --       inst:DoTaskInTime(49/30, function()
  --               -- if inst.AnimState:IsCurrentAnimation("smelting_pst") then
  --               if inst.AnimState:IsCurrentAnimation("cooking_finish") then
  --                  inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/move_2")
  --              end
  --          end )
	end
end

local function continuedonefn(inst)
	if not inst:HasTag("burnt") then
		-- inst.AnimState:PlayAnimation("idle_full")
		inst.AnimState:PlayAnimation("idle")
		ShowProduct(inst)
	end
end

local function continuecookfn(inst)
	if not inst:HasTag("burnt") then
		-- inst.AnimState:PlayAnimation("smelting_loop", true)
		inst.AnimState:PlayAnimation("cooking_loop1", true)
		inst.Light:Enable(true)

		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/smelt_LP", "snd")
	end
end

local function harvestfn(inst)
	if not inst:HasTag("burnt") then
		-- inst.AnimState:PlayAnimation("idle_empty")
		inst.AnimState:PlayAnimation("idle")
		if inst.fx then
			inst.fx:Remove()
			inst.fx = nil
		end
	end
end

local function getstatus(inst)
	if inst:HasTag("burnt") then
		return "BURNT"
	elseif inst.components.tpstewer.cooking and inst.components.tpstewer:GetTimeToCook() > 15 then
		return "COOKING_LONG"
	elseif inst.components.tpstewer.cooking then
		return "COOKING_SHORT"
	elseif inst.components.tpstewer.done then
		return "DONE"
	else
		return "EMPTY"
	end
end

local function onfar(inst)
	if inst.components.container then
		inst.components.container:Close()
	end
end

local function onbuilt(inst)
	-- inst.AnimState:PlayAnimation("place")
	-- inst.AnimState:PushAnimation("idle_empty")
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
	inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/build")
	-- inst:DoTaskInTime(1/30, function()
 --                -- if inst.AnimState:IsCurrentAnimation("place") then
 --                if inst.AnimState:IsCurrentAnimation("hi_pre") then
 --                   inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/brick")
 --               end
 --           end )
	-- inst:DoTaskInTime(4/30, function()
 --                -- if inst.AnimState:IsCurrentAnimation("place") then
 --                if inst.AnimState:IsCurrentAnimation("hi_pre") then
 --                   inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/brick")
 --               end
 --           end )
	-- inst:DoTaskInTime(8/30, function()
 --                -- if inst.AnimState:IsCurrentAnimation("place") then
 --                if inst.AnimState:IsCurrentAnimation("hi_pre") then
 --                   inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/brick")
 --               end
 --           end )
	-- inst:DoTaskInTime(12/30, function()
 --                -- if inst.AnimState:IsCurrentAnimation("place") then
 --                if inst.AnimState:IsCurrentAnimation("hi_pre") then
 --                   inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/brick")
 --               end
 --           end )
	-- inst:DoTaskInTime(14/30, function()
 --                -- if inst.AnimState:IsCurrentAnimation("place") then
 --                if inst.AnimState:IsCurrentAnimation("hi_pre") then
 --                   inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/brick")
 --               end
 --           end )
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
	if data and data.burnt then
        inst.components.burnable.onburnt(inst)
        inst.Light:Enable(false)
    end
end

local function onFloodedStart(inst)
	if inst.components.container then 
		inst.components.container.canbeopened = false 
	end 
	if inst.components.tpstewer then 
		if inst.components.tpstewer.cooking then 
			inst.components.tpstewer.product = "wetgoop"
		end 
	end 
end 

local function onFloodedEnd(inst)
	if inst.components.container then 
		inst.components.container.canbeopened = true 
	end 
end 

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "tp_lab.tex" )
	
    local light = inst.entity:AddLight()
    inst.Light:Enable(false)
	inst.Light:SetRadius(.6)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235/255,62/255,12/255)
    
    inst:AddTag("structure")
    MakeObstaclePhysics(inst, .5)
    
    -- inst.AnimState:SetBank("smelter")
    -- inst.AnimState:SetBuild("smelter")
    -- inst.AnimState:PlayAnimation("idle_empty")
    inst.AnimState:SetBank("tp_lab")
    inst.AnimState:SetBuild("tp_lab")
    inst.AnimState:PlayAnimation("idle")
    -- inst.AnimState:SetMultColour(.1, 1, .1, 1)

    inst:AddComponent("tpstewer")
    inst.components.tpstewer.onstartcooking = startcookfn
    inst.components.tpstewer.oncontinuecooking = continuecookfn
    inst.components.tpstewer.oncontinuedone = continuedonefn
    inst.components.tpstewer.ondonecooking = donecookfn
    inst.components.tpstewer.onharvest = harvestfn
    inst.components.tpstewer.onspoil = spoilfn
    inst.components.tpstewer.product_tbl = WARGON.DATA.tp_data_composed.lab_items
    
    inst:AddComponent("container")
    inst.components.container.itemtestfn = itemtest
    inst.components.container:SetNumSlots(4)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_cookpot_1x4"
    inst.components.container.widgetanimbuild = "ui_cookpot_1x4"
    inst.components.container.widgetpos = Vector3(200,0,0)
    inst.components.container.side_align_tip = 100
    inst.components.container.widgetbuttoninfo = widgetbuttoninfo
    -- inst.components.container.acceptsstacks = false
    inst.components.container.type = "cooker"

    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    inst:AddComponent("inspectable")
	-- inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerFar(onfar)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	-- inst:AddComponent("floodable")
	-- inst.components.floodable.onStartFlooded = onFloodedStart
	-- inst.components.floodable.onStopFlooded = onFloodedEnd
	-- inst.components.floodable.floodEffect = "shock_machines_fx"
	-- inst.components.floodable.floodSound = "dontstarve_DLC002/creatures/jellyfish/electric_land"

	MakeSnowCovered(inst, .01)    
	inst:ListenForEvent( "onbuilt", onbuilt)

	-- MakeMediumBurnable(inst, nil, nil, true)
	-- MakeSmallPropagator(inst)

	inst.OnSave = onsave 
   	inst.OnLoad = onload

    return inst
end

return Prefab( "common/tp_lab", fn, assets, prefabs),
		MakePlacer( "common/tp_lab_placer", "tp_lab", "tp_lab", "idle" ) 
