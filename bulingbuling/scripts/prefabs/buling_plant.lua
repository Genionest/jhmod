local assets =
{
	Asset("ANIM", "anim/plant_normal.zip"),
	Asset("ANIM", "anim/hat_volcano_on.zip"),
	Asset("ANIM", "anim/jungletreeguard_build.zip"),
	Asset("ANIM", "anim/jungletreeguard_idles.zip"),
	Asset("ANIM", "anim/buling_wheat.zip"),
	Asset("ANIM", "anim/buling_seeds.zip"),
	Asset("ATLAS", "images/inventoryimages/buling_seed_zhongziding.xml"),
	
	Asset("ATLAS", "images/inventoryimages/buling_seed_flint.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_seed_gold.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_seed_marble.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_seed_nitre.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_seed_obsidian.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_seed_rock.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_seed_marble.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_seed_wheat.xml"),
}
local function onmatured(inst, grower)
	inst.SoundEmitter:PlaySound("dontstarve/common/farm_harvestable")
		inst.AnimState:OverrideSymbol("swap_grown", inst.bank,inst.build)
end
local function OnLoadPostPass(inst)
    if inst.components.crop and not inst.components.crop.grower then
        inst.components.crop:Resume()
    end
end
local function workcallback(inst, worker, workleft)
	if workleft <= 0 then
		inst.components.lootdropper:SpawnLootPrefab("seeds")
		inst:Remove()
	end
end
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
    anim:SetBank("plant_normal")
    anim:SetBuild("plant_normal")
    anim:PlayAnimation("grow")
	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.DIG)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnWorkCallback(workcallback)
    inst:AddComponent("crop")
    inst.components.crop:SetOnMatureFn(onmatured)
    inst.makewitherabletask = inst:DoTaskInTime(TUNING.WITHER_BUFFER_TIME, function(inst) inst.components.crop:MakeWitherable() end)
    inst:AddComponent("inspectable")
    MakeSmallPropagator(inst)
    anim:SetFinalOffset(-1)
	inst.time = 1440
    inst.OnLoadPostPass = OnLoadPostPass   
    inst:DoTaskInTime(0,function() 
        if inst.components.crop and not inst.components.crop.product_prefab then
            if inst.components.crop.task then
                inst.components.crop.task:Cancel()
                inst.components.crop.task = nil
            end
            inst.components.crop:StartGrowing(inst.grower, inst.time, inst)
        end
    end)
	--hook
	inst.components.crop.Harvest = function(self,harvester)
		if self.matured or self.withered then
        local product = nil
        if self.grower and self.grower:HasTag("fire") or self.inst:HasTag("fire") then
            local temp = SpawnPrefab(self.product_prefab)
            if temp.components.cookable and temp.components.cookable.product then
                product = SpawnPrefab(temp.components.cookable.product)
            else
                product = SpawnPrefab("seeds_cooked")
            end
            temp:Remove()
        else
            product = SpawnPrefab(self.product_prefab)
        end

        if product then
            self.inst:ApplyInheritedMoisture(product)
        end
        harvester.components.inventory:GiveItem(product, nil, Vector3(TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition())))
        ProfileStatsAdd("grown_"..product.prefab) 
        
        self.matured = false
        self.withered = false
        self.inst:RemoveTag("withered")
        self.growthpercent = 0
        self.product_prefab = nil

        if self.grower and self.grower.components.grower then
            self.grower.components.grower:RemoveCrop(self.inst)
            self.grower = nil
        else
            self.inst.components.crop:StartGrowing(inst.grower, inst.time, inst,.5)
        end
        
        return true
		end
	end
	
    return inst
end
---------plants
local function zhongzidingfn(inst)
	local inst = fn(inst)
	inst.grower = "buling_zhongziding"
	inst.bank = "buling_zhongziding"
	inst.build = "buling_zhongziding_01"
	return inst
end
local function rockfn(inst)
	local inst = fn(inst)
	inst.grower = "rocks"
	inst.bank = "rocks"
	inst.build = "rocks01"
	return inst
end
local function marblefn(inst)
	local inst = fn(inst)
	inst.grower = "marble"
	inst.bank = "marble"
	inst.build = "marble01"
	return inst
end
local function goldfn(inst)
	local inst = fn(inst)
	inst.grower = "goldnugget"
	inst.bank = "gold_nugget"
	inst.build = "nugget"
	return inst
end
local function tarpoolfn(inst)
	local inst = fn(inst)
	inst.grower = "tar_pool"
	inst.bank = "gold_nugget"
	inst.build = "nugget"
	return inst
end
local function sandfn(inst)
	local inst = fn(inst)
	inst.grower = "sand"
	inst.bank = "sandhill"
	inst.build = "sand_image"
	return inst
end
local function nitrefn(inst)
	local inst = fn(inst)
	inst.grower = "nitre"
	inst.bank = "nitre"
	inst.build = "nitre01"
	return inst
end
local function obsidianfn(inst)
	local inst = fn(inst)
	inst.grower = "obsidian"
	inst.bank = "obsidian"
	inst.build = "obsidian_image"
	return inst
end
local function flintfn(inst)
	local inst = fn(inst)
	inst.grower = "flint"
	inst.bank = "flint"
	inst.build = "flint01"
	return inst
end
local function wheatfn(inst)
	local inst = fn(inst)
	inst.grower = "buling_seed_wheat"
	inst.bank = "buling_wheat"
	inst.build = "buling_wheat"
	return inst
end
local function ceshi_foodfn(inst)
	local inst = fn(inst)
	inst.grower = "rocks"
	inst.bank = "buling_wheat"
	inst.build = "buling_wheat"
	return inst
end
-------------seeds
local function seedsfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("buling_seeds")
    inst.AnimState:SetBuild("buling_seeds")
	inst:AddComponent("stackable")
    inst:AddComponent("inspectable")
    inst:AddComponent("deployable")
    inst:AddComponent("inventoryitem")
	inst:AddComponent("tradable")
    inst:AddTag("seed")
	inst.components.deployable.placer = "seeds_placer"
    return inst
end
local function zhongzidingseedfn(inst)
	local function OnDeploy (inst, pt)
		SpawnPrefab("buling_plant_zhongziding").Transform:SetPosition(pt.x, pt.y, pt.z)
		inst.components.stackable:Get():Remove()
	end
	local inst = seedsfn(inst)
	inst.AnimState:SetBank("buling_zhongziding")
    inst.AnimState:SetBuild("buling_zhongziding")
    inst.AnimState:PlayAnimation("anim")
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.inventoryitem.imagename = "buling_zhongziding"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_zhongziding.xml"
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	inst:AddComponent("tradable")
	return inst
end
local function rockseedfn(inst)
	local function OnDeploy (inst, pt)
		SpawnPrefab("buling_plant_rock").Transform:SetPosition(pt.x, pt.y, pt.z)
		inst.components.stackable:Get():Remove()
	end
	local inst = seedsfn(inst)
    inst.AnimState:PlayAnimation("seeds_1",true)
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.inventoryitem.imagename = "buling_seed_rock"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_seed_rock.xml"
	return inst
end
local function flintseedfn(inst)
	local function OnDeploy (inst, pt)
		SpawnPrefab("buling_plant_flint").Transform:SetPosition(pt.x, pt.y, pt.z)
		inst.components.stackable:Get():Remove()
	end
	local inst = seedsfn(inst)
    inst.AnimState:PlayAnimation("seeds_4",true)
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.inventoryitem.imagename = "buling_seed_flint"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_seed_flint.xml"
	return inst
end
local function nitreseedfn(inst)
	local function OnDeploy (inst, pt)
		SpawnPrefab("buling_plant_nitre").Transform:SetPosition(pt.x, pt.y, pt.z)
		inst.components.stackable:Get():Remove()
	end
	local inst = seedsfn(inst)
    inst.AnimState:PlayAnimation("seeds_6",true)
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.inventoryitem.imagename = "buling_seed_nitre"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_seed_nitre.xml"
	return inst
end
local function goldseedfn(inst)
	local function OnDeploy (inst, pt)
		SpawnPrefab("buling_plant_gold").Transform:SetPosition(pt.x, pt.y, pt.z)
		inst.components.stackable:Get():Remove()
	end
	local inst = seedsfn(inst)
    inst.AnimState:PlayAnimation("seeds_2",true)
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.inventoryitem.imagename = "buling_seed_gold"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_seed_gold.xml"
	return inst
end
local function obsidianseedfn(inst)
	local function OnDeploy (inst, pt)
		SpawnPrefab("buling_plant_obsidian").Transform:SetPosition(pt.x, pt.y, pt.z)
		inst.components.stackable:Get():Remove()
	end
	local inst = seedsfn(inst)
    inst.AnimState:PlayAnimation("seeds_7",true)
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.inventoryitem.imagename = "buling_seed_obsidian"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_seed_obsidian.xml"
	return inst
end
local function marbleseedfn(inst)
	local function OnDeploy (inst, pt)
		SpawnPrefab("buling_plant_marble").Transform:SetPosition(pt.x, pt.y, pt.z)
		inst.components.stackable:Get():Remove()
	end
	local inst = seedsfn(inst)
    inst.AnimState:PlayAnimation("seeds_5",true)
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.inventoryitem.imagename = "buling_seed_marble"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_seed_marble.xml"
	return inst
end
local function ceshiseedfn(inst)--测试
	local function OnDeploy (inst, pt)
		SpawnPrefab("buling_plant_rock").Transform:SetPosition(pt.x, pt.y, pt.z)
		inst.components.stackable:Get():Remove()
	end
	local inst = seedsfn(inst)
    inst.AnimState:PlayAnimation("seed",true)
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.inventoryitem.imagename = "buling_seed_wheat"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_seed_wheat.xml"
	return inst
end
local function wheatseedfn(inst)--小麦
	local function OnDeploy (inst, pt)
		SpawnPrefab("buling_plant_wheat").Transform:SetPosition(pt.x, pt.y, pt.z)
		inst.components.stackable:Get():Remove()
	end
	local inst = seedsfn(inst)
	inst.AnimState:SetBank("buling_wheat")
    inst.AnimState:SetBuild("buling_wheat")
    inst.AnimState:PlayAnimation("idle")
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.inventoryitem.imagename = "buling_seed_wheat"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_seed_wheat.xml"
	inst:AddComponent("edible")
	inst.components.edible.foodtype = "VEGGIE"
	inst.components.edible.healthvalue = 1
	inst.components.edible.hungervalue = 0
	inst.components.edible.sanityvalue = -1
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	return inst
end
return Prefab( "buling_plant_zhongziding", zhongzidingfn, assets),
Prefab( "buling_plant_rock", rockfn, assets),
Prefab( "buling_plant_marble", marblefn, assets),
Prefab( "buling_plant_nitre", nitrefn, assets),
Prefab( "buling_plant_gold", goldfn, assets),
Prefab( "buling_plant_sand", sandfn, assets),
Prefab( "buling_plant_obsidian", obsidianfn, assets),
Prefab( "buling_plant_flint", flintfn, assets),
Prefab( "buling_plant_wheat", wheatfn, assets),
Prefab( "buling_plant_ceshi", ceshi_foodfn, assets),
--seed
Prefab( "buling_seed_flint", flintseedfn, assets),
Prefab( "buling_seed_wheat", wheatseedfn, assets),
Prefab( "buling_seed_nitre", nitreseedfn, assets),
Prefab( "buling_seed_rock", rockseedfn, assets),
Prefab( "buling_seed_gold", goldseedfn, assets),
Prefab( "buling_seed_obsidian", obsidianseedfn, assets),
Prefab( "buling_seed_marble", marbleseedfn, assets),
Prefab( "buling_zhongziding", zhongzidingseedfn, assets)
