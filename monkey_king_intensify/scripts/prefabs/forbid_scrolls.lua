local function make_perish(nature)
	local function onperish(inst)
		local owner = inst.components.inventoryitem.owner
		if owner then
			print("-monkey_king_"..nature.."_forbid")
			owner:RemoveTag("monkey_king_"..nature.."_forbid")
		end
		inst:Remove()
	end
	return onperish
end

local function make_get(nature)
	local function get_forbid(inst, owner)
		-- local owner = inst.components.inventoryitem.owner
		if owner then
			print("monkey_king_"..nature.."_forbid")
			owner:AddTag("monkey_king_"..nature.."_forbid")
		end
	end
	return get_forbid
end

local function make_lose(nature)
	local function lose_forbid(inst, dropper)
		local tag = "monkey_king_"..nature.."_forbid"
		if dropper then
			print(tag)
			dropper:RemoveTag(tag)
		else
			print("dropper none")
			local player = GetPlayer()
			if player:HasTag(tag) 
			and not player.components.inventory:Has(inst.prefab, 1) then
				player:RemoveTag(tag)
				print("-"..tag)
			end
		end
	end
	return lose_forbid
end

local function MakeScroll(name, nature)
	local assets = {
		Asset("ATLAS", "images/inventoryimages/"..name..".xml"),
	}

	local function fn()
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		anim:SetBank("papyrus")
	    anim:SetBuild("papyrus")
	    anim:PlayAnimation("idle")
		MakeInventoryPhysics(inst)
		MakeInventoryFloatable(inst, "idle_water", "idle")
    	MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
    	inst:AddComponent("inspectable")
	    inst:AddComponent("appeasement")
    	inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL
		inst:AddComponent("tradable")
		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.atlasname = "images/inventoryimages/"..name..".xml"
        inst.components.inventoryitem:SetOnPutInInventoryFn(make_get(nature))
		inst.components.inventoryitem:SetOnDroppedFn(make_lose(nature))
		inst:AddComponent("fueled")
        inst.components.fueled:InitializeFuelLevel(100)
        inst.components.fueled:SetDepletedFn(make_perish(nature))
        inst.components.fueled:StartConsuming() 

		return inst
	end

	return Prefab("common/inventory/"..name, fn, assets)
end

return MakeScroll("fire_forbid_scroll", "fire"),
	MakeScroll("cold_forbid_scroll", "cold")