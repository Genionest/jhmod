local pack_crabs = {"backpack1", "backpack_crab", "anim", "idle_water"}
local pack_dragonflys = {"backpack1", "backpack_dragonfly", "anim", "idle_water"}
local pack_rabbits = {'backpack1', 'backpack_rabbit', 'anim', 'idle_water'}

local function onopen(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_open", "open")
end

local function onclose(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close", "open")
end

local function common_equip(owner, build)
    owner.AnimState:OverrideSymbol("swap_body", build, "swap_body")
end

local function MakePack(name, anims, pack_equip_fn, pack_unequip_fn, pack_fn, pack_img)

    local function onequip(inst, owner) 
        owner.AnimState:OverrideSymbol("swap_body", "swap_backpack", "backpack")
        if pack_equip_fn then
            pack_equip_fn(inst, owner)
        else
            owner.AnimState:OverrideSymbol("swap_body", "swap_backpack", "swap_body")
        end
        owner.components.inventory:SetOverflow(inst)
        inst.components.container:Open(owner) 
    end

    local function onunequip(inst, owner) 
        if pack_unequip_fn then
            pack_unequip_fn(inst, owner)
        end
        owner.AnimState:ClearOverrideSymbol("swap_body")
        owner.AnimState:ClearOverrideSymbol("backpack")
        owner.components.inventory:SetOverflow(nil)
        inst.components.container:Close(owner)
    end

    local slotpos = {}

    for y = 0, 3 do
        table.insert(slotpos, Vector3(-162, -y*75 + 114 ,0))
        table.insert(slotpos, Vector3(-162 +75, -y*75 + 114 ,0))
    end

    local function fn()
    	local inst = CreateEntity()    
    	inst.entity:AddTransform()
    	inst.entity:AddAnimState()
    	inst.entity:AddSoundEmitter()
        if pack_img then
            local minimap = inst.entity:AddMiniMapEntity()  
            minimap:SetIcon(pack_img..".tex")
        end

        MakeInventoryPhysics(inst)
        
        inst.AnimState:SetBank(anims[1])
        inst.AnimState:SetBuild(anims[2])
        inst.AnimState:PlayAnimation(anims[3])
        if anims[4] then
            MakeInventoryFloatable(inst, anims[4], anims[3])
        end

        inst:AddTag("backpack")

        inst:AddComponent("inspectable")
        
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/inventoryimages/"..pack_img..".xml"
        inst.components.inventoryitem.imagename = pack_img
        inst.components.inventoryitem.cangoincontainer = false
        inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/backpack"

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        
        inst.components.equippable:SetOnEquip( onequip )
        inst.components.equippable:SetOnUnequip( onunequip )
        
        inst:AddComponent("container")
        inst.components.container:SetNumSlots(#slotpos)
        inst.components.container.widgetslotpos = slotpos
        inst.components.container.widgetanimbank = "ui_backpack_2x4"
        inst.components.container.widgetanimbuild = "ui_backpack_2x4"
        inst.components.container.widgetpos = Vector3(-5,-70,0)
        inst.components.container.side_widget = true
        inst.components.container.type = "pack"
       
        inst.components.container.onopenfn = onopen
        inst.components.container.onclosefn = onclose

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        inst.components.burnable:SetOnBurntFn(function()
            if inst.inventoryitemdata then inst.inventoryitemdata = nil end

            if inst.components.container then
                inst.components.container:DropEverything()
                inst.components.container:Close()
                inst:RemoveComponent("container")
            end
            
            local ash = SpawnPrefab("ash")
            ash.Transform:SetPosition(inst.Transform:GetWorldPosition())

            inst:Remove()
        end)
        if pack_fn then
            pack_fn(inst)
        end

    	return inst
    end

    return Prefab("objects/"..name, fn, {})
end

local function crab_equip(inst, owner)
    common_equip(owner, "backpack_crab")
    -- owner.AnimState:OverrideSymbol("swap_body", "backpack_crab", "swap_body")
end

local function crab_fn(inst)
    inst:AddTag("fridge")
    inst:AddTag("nocool")
end

local function dragonfly_equip(inst, owner)
    common_equip(owner, "backpack_dragonfly")
    -- owner.AnimState:OverrideSymbol("swap_body", "backpack_dragonfly", "swap_body")
end

local function dragonfly_close(inst)
    onclose(inst)
    local container = inst.components.container
    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item then 
            local replacement = nil 
            if item.components.cookable then 
                replacement = item.components.cookable:GetProduct()
            elseif item.components.burnable then 
                replacement = "ash"
            end  
            if replacement then 
                local stacksize = 1 
                if item.components.stackable then 
                    stacksize = item.components.stackable:StackSize()
                end 
                local newprefab = SpawnPrefab(replacement)
                if newprefab.components.stackable then 
                    newprefab.components.stackable:SetStackSize(stacksize)
                end 
                container:RemoveItemBySlot(i)
                item:Remove()
                container:GiveItem(newprefab, i)
            end 
         end 
    end 
end

local function dragonfly_fn(inst)
    inst.components.container.onclosefn = dragonfly_close
end

local function rabbit_equip(inst, owner)
    -- owner.AnimState:OverrideSymbol("swap_body", "backpack_rabbit", "swap_body")
    common_equip(owner, "backpack_rabbit")
end

local function rabbit_fn(inst)
    inst.components.equippable.walkspeedmult = .25
end

return 
    MakePack("tp_pack_crab", pack_crabs, crab_equip, nil, crab_fn, "backpack_crab"),
    MakePack("tp_pack_dragonfly", pack_dragonflys, dragonfly_equip, nil, dragonfly_fn, "backpack_dragonfly"),
    MakePack("tp_pack_rabbit", pack_rabbits, rabbit_equip, nil, rabbit_fn, "backpack_rabbit")