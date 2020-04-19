local assets ={
	Asset("ANIM", "anim/buling_zhongziding.zip"),
	Asset("ANIM", "anim/buling_zaxiang.zip"),
	Asset("ANIM", "anim/swap_beeraxe.zip"),
	Asset("ANIM", "anim/swap_beerpickaxe.zip"),
	Asset("ANIM", "anim/buling_tool.zip"),
	Asset("ANIM", "anim/swap_buling_shears.zip"),
	Asset("ANIM", "anim/swap_buling_banshou.zip"),
	Asset("ANIM", "anim/buling_banshou.zip"),
	Asset("ANIM", "anim/buling_glass.zip"),
	Asset("ATLAS", "images/inventoryimages/buling_zhongziding.xml"),
	Asset("ANIM", "anim/maichongbug.zip"),
	Asset("ANIM", "anim/buling_liaoli.zip"),
	Asset("ATLAS", "images/inventoryimages/buling_ronglu.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_diandonggao.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_diandongjian.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_dianlifu.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_paotai.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_shengcun.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_zhongjiqi.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_diandeng.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_zhuangzhi.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_kuangjia.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_leida.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_glass.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_shouge.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_seedchest.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_seedbox.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_taiyangneng.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_chongdian.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_banshou.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_weaponbox.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_planttable.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_chest.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_manure.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_wakuang.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_huosai.xml"),
}
---通用
local function commonfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inspectable")
    return inst
end

local function repair(inst)
end
-----
local function buling_manure(inst)
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
    inst.AnimState:PlayAnimation("buling_manure")
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_manure"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_manure.xml"
	inst:AddComponent("tradable")
	inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES
    inst.components.fertilizer.planthealing = true
	return inst
end
--
local function buling_manure_8(inst)
	local inst=commonfn(inst)
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_manure"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_manure.xml"
	inst.components.inventoryitem:SetOnPickupFn(function()
		inst:DoTaskInTime(0.1,function()
			inst:Remove()
			for k=1,4 do
				GetPlayer().components.inventory:GiveItem(SpawnPrefab("buling_manure"))
			end
		end)
	end)
	return inst
end
local function buling_glass(inst)
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_glass")
    inst.AnimState:SetBuild("buling_glass")
    inst.AnimState:PlayAnimation("f3")
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_glass"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_glass.xml"
	inst:AddComponent("tradable")
	return inst
end
local function gongzuotaiitemfn(Sim)
	local function ondeploy(inst, pt, deployer)
		SpawnPrefab("buling_manual").Transform:SetPosition(pt.x, pt.y, pt.z)      
	end
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("buling_manual")
    inst.AnimState:SetBuild("buling_manual")
    inst.AnimState:PlayAnimation("idle")
	inst.Transform:SetScale(.5, .5, .5)
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "buling_manual"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_manual.xml"
	inst:AddTag("eyeturret")
    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable.placer = "buling_manual_placer"
    return inst
end
--测试
local function huojian()
	local function GetVerb(inst)
		return "Travel Through"
	end
	local BigPopupDialogScreen = require "screens/popupdialog"
	require "prefabutil"
	local function OnActivate_GoTo(inst)
		SetPause(true,"portal")
	
		local function dofight()
			TheFrontEnd:PopScreen()
			SetPause(false)
			GetPlayer().sg:GoToState("teleportato_teleport")
			GetPlayer():DoTaskInTime(5, function() SaveGameIndex:GoToDimension("stormplanet") end)
		end
		local function dofight2()
			TheFrontEnd:PopScreen()
			SetPause(false)
			GetPlayer().sg:GoToState("teleportato_teleport")
			GetPlayer():DoTaskInTime(5, function() SaveGameIndex:GoToDimension("desertplanet") end)
		end
		local function dofight3()
			TheFrontEnd:PopScreen()
			SetPause(false)
			GetPlayer().sg:GoToState("teleportato_teleport")
			GetPlayer():DoTaskInTime(5, function() SaveGameIndex:GoToDimension("edenplanet") end)
		end
		local function rejectfight()
			TheFrontEnd:PopScreen()
			SetPause(false) 
			inst.components.activatable.inactive = true
		end

		TheFrontEnd:PushScreen(BigPopupDialogScreen("航空火箭","确定要进行太空旅行吗？\n请确保携带了可以返回的物资",
				{{text="风暴", cb = dofight},
				{text="沙漠", cb = dofight2},
				{text="伊甸", cb = dofight3},
				{text="放弃", cb = rejectfight}} ))
	end
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.Transform:SetScale(3, 3, 2.5)
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("trinkets")
    inst.AnimState:SetBuild("trinkets")
	inst.AnimState:PlayAnimation("5")
    inst:AddComponent("inspectable")
	inst:AddComponent("activatable")
    inst.components.activatable.inactive = true
    inst.components.activatable.getverb = GetVerb
	inst.components.activatable.quickaction = true
	inst.components.activatable.OnActivate = OnActivate_GoTo
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
	
    inst.AnimState:SetBank("buling_tool")
    inst.AnimState:SetBuild("buling_tool")
	inst.AnimState:PlayAnimation("fuzi")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_dianlifu"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_dianlifu.xml"
	inst:AddTag("beerpowertool")
    
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
	repair(inst)
	return inst
end
local function banshou()--扳手
	local function canbanshou(staff, caster, target, pos)
		return target and target.beeritem~= nil
	end
	local function spawnbanshou(staff, target, pos)
		local item = target.beeritem
		local tornado = SpawnPrefab(item)
		tornado.Transform:SetPosition(target.Transform:GetWorldPosition())
		SpawnPrefab("statue_transition").Transform:SetPosition(target:GetPosition():Get())
        SpawnPrefab("statue_transition_2").Transform:SetPosition(target:GetPosition():Get())
		if target.components.container then target.components.container:DropEverything() end
		target:DoTaskInTime(0.1,function() target:Remove() end)
	end
    local function onequip(inst, owner)
		owner.AnimState:OverrideSymbol("swap_object", "swap_buling_banshou", "swap_buling_banshou")
		owner.AnimState:Show("ARM_carry")
		owner.AnimState:Hide("ARM_normal")
	end
	local function onunequip(inst, owner)
		owner.AnimState:Hide("ARM_carry")
		owner.AnimState:Show("ARM_normal")
	end
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("buling_banshou")
    inst.AnimState:SetBuild("buling_banshou")
	inst.AnimState:PlayAnimation("idle")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_banshou"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_banshou.xml"
    inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
    inst:AddComponent("inspectable")
	inst:AddComponent("spellcaster")
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canusefrominventory = false
    inst.components.spellcaster:SetSpellTestFn(canbanshou)
    inst.components.spellcaster:SetSpellFn(spawnbanshou)
    inst.components.spellcaster.castingstate = "castspell_tornado"
    inst.components.spellcaster.actiontype = "SCIENCE"
	return inst
end
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
	
    inst.AnimState:SetBank("buling_tool")
    inst.AnimState:SetBuild("buling_tool")
	inst.AnimState:PlayAnimation("gaozi")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_diandonggao"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_diandonggao.xml"
	inst:AddTag("beerpowertool")
    --inst:AddTag("sees_hiddendanger")
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
	repair(inst)
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
    
    anim:SetBank("buling_tool")
    anim:SetBuild("buling_tool")
    anim:PlayAnimation("jiandao")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SHEARS_DAMAGE)
    inst:AddTag("shears")
	inst:AddTag("beerpowertool")
    ---------------------------------------------------------------
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.SHEAR,2)
    ---------------------------------------------------------------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(120)
    inst.components.finiteuses:SetUses(1)
    
    inst.components.finiteuses:SetOnFinished( onfinished )
    inst.components.finiteuses:SetConsumption(ACTIONS.SHEAR, 1)
    ---------------------------------------------------------------

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("equippable")
	

    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip ) 

    inst.components.inventoryitem.imagename = "buling_diandongjian"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_diandongjian.xml"
	repair(inst)
    return inst
end
local function boxitem(Sim)
	local function ondeploy(inst, pt, deployer)
		SpawnPrefab(inst.boxname).Transform:SetPosition(pt.x, pt.y, pt.z)      
	end
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
    inst.AnimState:PlayAnimation("zhuangzhi")
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "buling_zhuangzhi"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_zhuangzhi.xml"
	inst:AddTag("eyeturret")
    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable.placer = "firesuppressor_placer"
	inst.Transform:SetScale(.5, .5, .5)
    return inst
end
local function rongluitemfn(inst)
    local inst = boxitem(inst)
	inst.boxname = "buling_ronglu"
	inst.components.deployable.placer = "buling_ronglu_placer"
	inst.components.inventoryitem.imagename = "buling_ronglu"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_ronglu.xml"
    return inst
end
local function buling_diandengitemfn(inst)
    local inst = boxitem(inst)
	inst.boxname = "buling_diandeng"
	inst.components.inventoryitem.imagename = "buling_diandeng"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_diandeng.xml"
    return inst
end
local function buling_shengcun_itemfn(inst)
    local inst = boxitem(inst)
	inst.boxname = "buling_shengcun"
	inst.components.inventoryitem.imagename = "buling_shengcun"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_shengcun.xml"
    return inst
end
local function buling_zhongjiqi_itemfn(inst)
    local inst = boxitem(inst)
	inst.boxname = "buling_zhongjiqi"
	inst.components.inventoryitem.imagename = "buling_zhongjiqi"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_zhongjiqi.xml"
    return inst
end
local function buling_seedbox_itemfn(inst)
    local inst = boxitem(inst)
	inst.boxname = "buling_seedbox"
	inst.components.inventoryitem.imagename = "buling_seedbox"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_seedbox.xml"
    return inst
end
local function buling_weaponchest_itemfn(inst)
    local inst = boxitem(inst)
	inst.components.inventoryitem.imagename = "buling_seedchest"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_seedchest.xml"
	inst.boxname = "buling_weaponchest"
    return inst
end
local function buling_solarenergy_itemfn(inst)
    local inst = boxitem(inst)
	inst.boxname = "buling_solarenergy"
	inst.components.inventoryitem.imagename = "buling_taiyangneng"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_taiyangneng.xml"
    return inst
end
local function buling_paotai_itemfn(inst)
    local inst = boxitem(inst)
	inst.boxname = "buling_paotai"
	inst.components.inventoryitem.imagename = "buling_paotai"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_paotai.xml"
    return inst
end
local function buling_radar_itemfn(inst)
    local inst = boxitem(inst)
	inst.boxname = "buling_radar"
	inst.components.inventoryitem.imagename = "buling_leida"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_leida.xml"
    return inst
end
local function buling_cropbox_itemfn(inst)
    local inst = boxitem(inst)
	inst.boxname = "buling_cropbox"
	inst.components.inventoryitem.imagename = "buling_shouge"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_shouge.xml"
    return inst
end
local function buling_chongdianqi_itemfn(inst)
    local inst = boxitem(inst)
	inst.boxname = "buling_chongdianqi"
	inst.components.inventoryitem.imagename = "buling_chongdian"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_chongdian.xml"
    return inst
end
local function buling_weaponbox_itemfn(inst)
    local inst = boxitem(inst)
	inst.boxname = "buling_weaponbox"
	inst.components.inventoryitem.imagename = "buling_weaponbox"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_weaponbox.xml"
    return inst
end
local function buling_chest_itemfn(inst)
    local inst = boxitem(inst)
	inst.components.deployable.placer = "buling_chest_placer"
	inst.components.inventoryitem.imagename = "buling_chest"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_chest.xml"
	inst.boxname = "buling_chest"
    return inst
end
local function buling_planttablet_itemfn(inst)
    local inst = boxitem(inst)
	inst.components.deployable.placer = "buling_planttable_placer"
	inst.components.inventoryitem.imagename = "buling_planttable"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_planttable.xml"
	inst.boxname = "buling_planttable"
    return inst
end
local function buling_cooktable_itemfn(inst)
    local inst = boxitem(inst)
	inst.components.deployable.placer = "buling_cooktable_placer"
	inst.components.inventoryitem.imagename = "buling_cooktable"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_cooktable.xml"
	inst.boxname = "buling_cooktable"
    return inst
end
local function buling_huosai_itemfn(inst)
    local inst = boxitem(inst)
	inst.components.inventoryitem.imagename = "buling_huosai"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_huosai.xml"
	inst.boxname = "buling_huosai"
    return inst
end
local function buling_wakuang_itemfn(inst)
    local inst = boxitem(inst)
	inst.components.deployable.placer = "buling_wakuang_placer"
	inst.components.inventoryitem.imagename = "buling_wakuang"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_wakuang.xml"
	inst.boxname = "buling_wakuang"
    return inst
end
--
local function buling_kao(inst)
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
    inst.AnimState:PlayAnimation("zhuangzhi")
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_cook_kao"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_cook_kao.xml"
	inst:AddComponent("tradable")
	inst:AddTag("buling_cook_tool")
	return inst
end
local function buling_cook_guo(inst)
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
    inst.AnimState:PlayAnimation("zhuangzhi")
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_cook_guo"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_cook_guo.xml"
	inst:AddComponent("tradable")
	inst:AddTag("buling_cook_tool")
	return inst
end
local function buling_cook_zheng(inst)
	local inst=commonfn(inst)
	inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
    inst.AnimState:PlayAnimation("zhuangzhi")
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "buling_cook_zheng"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_cook_zheng.xml"
	inst:AddComponent("tradable")
	inst:AddTag("buling_cook_tool")
	return inst
end
--零件

return Prefab("buling_huojian", huojian, assets),--测试用火箭
Prefab("buling_cook_kao", buling_kao, assets),--烤
Prefab("buling_cook_guo", buling_cook_guo, assets),--锅
Prefab("buling_cook_zheng", buling_cook_zheng, assets),--蒸
Prefab("buling_glass", buling_glass, assets),--不灵玻璃
Prefab("buling_manure", buling_manure, assets),--不灵肥料
Prefab("buling_wakuang_item", buling_wakuang_itemfn, assets),--挖矿机
Prefab("buling_manure_8", buling_manure_8, assets),--不灵肥料x8
Prefab("buling_manual_item", gongzuotaiitemfn, assets),--不灵工作台-物品
Prefab("buling_jiandao", jiandao, assets),--电动剪刀
Prefab("buling_diandonggao", diandonggao, assets),--电动镐
Prefab("buling_dianlifu", dianlifu, assets),--电动斧
Prefab("buling_banshou", banshou, assets),--扳手
Prefab("buling_diandeng_item", buling_diandengitemfn, assets),--不灵电灯-物品  
Prefab("buling_huosai_item", buling_huosai_itemfn, assets),--人力发电-物品  
Prefab("buling_shengcun_item", buling_shengcun_itemfn, assets),--生存发电机-物品  
Prefab("buling_solarenergy_item", buling_solarenergy_itemfn, assets),--太阳能发电机-物品  
Prefab("buling_zhongjiqi_item", buling_zhongjiqi_itemfn, assets),--电力中继器-物品
Prefab("buling_seedbox_item", buling_seedbox_itemfn, assets),--种子增值机-物品
Prefab("buling_paotai_item", buling_paotai_itemfn, assets),--不灵炮台-物品
Prefab("buling_chongdianqi_item", buling_chongdianqi_itemfn, assets),--充电器-物品
Prefab("buling_cooktable_item", buling_cooktable_itemfn, assets),--料理台-物品
Prefab("buling_radar_item", buling_radar_itemfn, assets),--不灵雷达-物品
Prefab("buling_chest_item", buling_chest_itemfn, assets),--不灵箱子-物品
Prefab("buling_planttable_item", buling_planttablet_itemfn, assets),--不灵箱子-物品
Prefab("buling_cropbox_item", buling_cropbox_itemfn, assets),--不灵采集者-物品
Prefab("buling_weaponchest_item", buling_weaponchest_itemfn, assets),--武装整备台-物品
Prefab("buling_ronglu_item", rongluitemfn, assets)--不灵萃取器-物品