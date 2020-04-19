local assets ={
	Asset("ANIM", "anim/buling_bee_cai.zip"),
	Asset("ANIM", "anim/buling_bee_fish.zip"),
	Asset("ANIM", "anim/buling_bee_police.zip"),
	Asset("ANIM", "anim/buling_bee_smith.zip"),
	Asset("ANIM", "anim/buling_bee_mine.zip"),
	Asset("ANIM", "anim/buling_bee_gardener.zip"),
	Asset("ANIM", "anim/buling_bee_pirate.zip"),
	Asset("ANIM", "anim/buling_bee_queen.zip"),
	Asset("ANIM", "anim/buling_bee_governor.zip"),
	Asset("ANIM", "anim/buling_bee_stonecutters.zip"),
	Asset("ATLAS", "images/inventoryimages/buling_bee_pirate.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_bee_gardener.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_bee_smith.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_bee_queen.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_bee_mine.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_bee_police.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_bee_cai.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_bee_fish.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_bee_stonecutters.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_bee_governor.xml"),
}
local function commonfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inspectable")
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	inst:AddComponent("inventoryitem")
	inst:AddComponent("tradable")
	inst:AddTag("bulingbug")
	inst.tasknum = 0
	local function onsave(inst, data)
		data.tasknum = inst.tasknum
    end
	local function onload(inst, data)
		inst.tasknum = data.tasknum
	end
	inst.OnSave = onsave
    inst.OnLoad = onload
    return inst
end
local function buling_cai(inst)
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_bee")
    inst.AnimState:SetBuild("buling_bee_cai")
    inst.AnimState:PlayAnimation("land_idle",true)
	inst.components.inventoryitem.imagename = "buling_bee_cai"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_bee_cai.xml"
	return inst
end
local function buling_pirate(inst)
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_bee")
    inst.AnimState:SetBuild("buling_bee_pirate")
    inst.AnimState:PlayAnimation("land_idle",true)
	inst.components.inventoryitem.imagename = "buling_bee_pirate"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_bee_pirate.xml"
	return inst
end
local function buling_gardener(inst)
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_bee")
    inst.AnimState:SetBuild("buling_bee_gardener")
    inst.AnimState:PlayAnimation("land_idle",true)
	inst.components.inventoryitem.imagename = "buling_bee_gardener"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_bee_gardener.xml"
	return inst
end
local function buling_fish(inst)
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_bee")
    inst.AnimState:SetBuild("buling_bee_fish")
    inst.AnimState:PlayAnimation("land_idle",true)
	inst.components.inventoryitem.imagename = "buling_bee_fish"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_bee_fish.xml"
	return inst
end
local function buling_police(inst)
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_bee")
    inst.AnimState:SetBuild("buling_bee_police")
    inst.AnimState:PlayAnimation("land_idle",true)
	inst.components.inventoryitem.imagename = "buling_bee_police"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_bee_police.xml"
	inst.bugitem = "honey"
	return inst
end
local function buling_smith(inst)
	local minelist = {
		rocks = 4,
		flint = 4,
		honey = 10,
		buling_seed_rock = 1,
		buling_seed_flint = 1,
	}
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_bee")
    inst.AnimState:SetBuild("buling_bee_smith")
    inst.AnimState:PlayAnimation("land_idle",true)
	inst.components.inventoryitem.imagename = "buling_bee_smith"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_bee_smith.xml"
	inst.beeworkfn = function(inst)
		local owner = inst.components.inventoryitem.owner
		if inst.tasknum >= 48 and owner and owner.prefab == "buling_bee_box" then
			if not owner.components.container:IsFull() then
				inst.tasknum = 0
				local prize = weighted_random_choice(minelist)
				owner.components.container:GiveItem(SpawnPrefab(prize))
			end
		end
		inst.tasknum = inst.tasknum + 1
	end
	return inst
end
local function buling_mine(inst)
	local minelist = {
		rocks = 4,
		flint = 4,
		honey = 10,
		buling_seed_rock = 1,
		buling_seed_flint = 1,
	}
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_bee")
    inst.AnimState:SetBuild("buling_bee_mine")
    inst.AnimState:PlayAnimation("land_idle",true)
	inst.components.inventoryitem.imagename = "buling_bee_mine"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_bee_mine.xml"
	inst.beeworkfn = function(inst)
	local owner = inst.components.inventoryitem.owner
		if inst.tasknum >= 48 and owner and owner.prefab == "buling_bee_box" then
		print(inst.tasknum)
			if not owner.components.container:IsFull() then
				inst.tasknum = 0
				local prize = weighted_random_choice(minelist)
				owner.components.container:GiveItem(SpawnPrefab(prize))
			end
		end
		inst.tasknum = inst.tasknum + 1
	end
	return inst
end
local function buling_queen(inst)
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_bee")
    inst.AnimState:SetBuild("buling_bee_queen")
    inst.AnimState:PlayAnimation("land_idle",true)
	inst.components.inventoryitem.imagename = "buling_bee_queen"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_bee_queen.xml"
	inst.beeworkfn = function(inst)
	local owner = inst.components.inventoryitem.owner
		if  owner and owner.prefab == "buling_bee_box" and not owner.components.container:IsFull() then
			for k,v in pairs(owner.components.container.slots) do
				if v:HasTag("bulingbug") and v~= inst then
					if  inst.tasknum >= 4 then
						inst.tasknum = 0
						owner.components.container:GiveItem(SpawnPrefab(v.prefab))
					else
						inst.tasknum = inst.tasknum + 1
					end
					return
				end
			end
		end
	end
	return inst
end
local function buling_stonecutters(inst)
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_bee")
    inst.AnimState:SetBuild("buling_bee_stonecutters")
    inst.AnimState:PlayAnimation("land_idle",true)
	inst.components.inventoryitem.imagename = "buling_bee_stonecutters"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_bee_stonecutters.xml"
	inst.bugitem = "honey"
	return inst
end
local function buling_governor(inst)
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_bee")
    inst.AnimState:SetBuild("buling_bee_governor")
    inst.AnimState:PlayAnimation("land_idle",true)
	inst.components.inventoryitem.imagename = "buling_bee_governor"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_bee_governor.xml"
	inst.bugitem = "honey"
	return inst
end
return Prefab("buling_bee_mine", buling_mine, assets),--地质蜂
Prefab("buling_bee_police", buling_police, assets),--警察蜂
Prefab("buling_bee_pirate", buling_pirate, assets),--海盗蜂
Prefab("buling_bee_queen", buling_queen, assets),--女王蜂
Prefab("buling_bee_governor", buling_governor, assets),--提督蜂
Prefab("buling_bee_stonecutters", buling_stonecutters, assets),--石匠蜂
Prefab("buling_bee_gardener", buling_gardener, assets),--园丁蜂
Prefab("buling_bee_cai", buling_cai, assets),--菜嗡嗡
Prefab("buling_bee_fish", buling_fish, assets),--渔夫蜂
Prefab("buling_bee_smith", buling_smith, assets)--铁匠蜂