local pack_crabs = {"backpack1", "backpack_crab", "anim", "idle_water"}
local pack_dragonflys = {"backpack1", "backpack_dragonfly", "anim", "idle_water"}
local pack_rabbits = {'backpack1', 'backpack_rabbit', 'anim', 'idle_water'}
local pack_beefalos = {'backpack1', 'backpack_beefalo', 'anim', 'idle_water'}
local pack_catcoons = {'backpack1', 'backpack_catcoon', 'anim', 'idle_water'}
local pack_hounds = {'backpack1', 'backpack_hound', 'anim', 'idle_water'}
local pack_deerclopses = {'backpack1', 'backpack_deerclops', 'anim', 'idle_water'}
local pack_beargers = {'backcub', 'backcub', 'anim', 'idle_water'}
local pack_giants = {'backpack1', 'giantsfoot', 'anim', 'idle_water'}

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
        inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
        
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

local function beefalo_equip(inst, owner)
    common_equip(owner, "backpack_beefalo")
    owner:AddTagNum("beefalo", 1)
    -- owner:AddTag('beefalo')
    -- if owner.components.tptagnum then
    --     owner.components.tptagnum:DeltaTag("beefalo", 1)
    -- end
end

local function beefalo_unequip(inst, owner)
    -- local hat =  owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    -- if not (hat and hat.prefab == "beefalohat") then
    --     owner:RemoveTag('beefalo')
    -- end
    -- if owner.components.tptagnum then
    --     owner.components.tptagnum:DeltaTag("beefalo", -1)
    -- end
    owner:AddTagNum("beefalo", -1)
end

local function beefalo_fn(inst)
end

local function catcoon_equip(inst, owner)
    common_equip(owner, "backpack_catcoon")
    if inst.task == nil then
        inst.task = WARGON.per_task(inst, 1, function()
            local spear = WARGON.find(owner, 10, nil, 
                {"tp_catcoon_spear"}, {"projectile"})
            if spear and WARGON.on_land(spear) then
                WARGON.make_fx(spear, "small_puff")
                WARGON.make_fx(spear, "tp_fx_catcoon_pick")
                if spear.components.tpproj then
                    spear.components.tpproj:Throw(owner, owner)
                end
            end
        end)
    end
end

local function catcoon_unequip(inst, owner)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function catcoon_fn(inst)
end

local function hound_equip(inst, owner)
    common_equip(owner, "backpack_hound")
    if inst.task == nil then
        inst.task = WARGON.per_task(inst, 1, function()
            local traps = WARGON.finds(owner, 15, {"tp_trap_teeth"})
            if traps then
                for k, v in pairs(traps) do
                    if v.components.mine
                    and v.components.mine.issprung then
                        v.components.mine:Reset()
                    end
                end
            end
        end)
    end
    -- if inst.task2 == nil then
    --     inst.task2 = inst:per_task(inst, 1, function()
    --         local trap = inst.components.container:FindItem(function(item)
    --             return item.prefab == "trap_teeth"
    --         end)
    --         if trap then
    --             local ents = inst:wg_finds()
    --         end
    --     end)
    -- end
end

local function hound_unequip(inst, owner)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function hound_fn(inst)
end

local function deerclops_equip(inst, owner)
    common_equip(owner, "backpack_deerclops")
    if inst.task == nil then
        inst.task = WARGON.per_task(inst, 1, function()
            for i, v in pairs(inst.components.container.slots) do
                if v and v.components.perishable 
                and not v:HasTag("tp_must_spoilsh") then
                    local perishable = v.components.perishable
                    local old_val = perishable.perishremainingtime
                    perishable.perishremainingtime = perishable.perishremainingtime + 2
                end
            end
        end)
    end
end

local function deerclops_unequip(inst, owner)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function deerclops_fn(inst)
end

local function giant_equip(inst, owner)
    common_equip(owner, "giantsfoot")
    owner:AddTag("groundpoundimmune")
end

local function giant_unequip(inst, owner)
    owner:RemoveTag("groundpoundimmune")
end

local function giant_fn(inst)
end

local function bearger_eat(inst)
    if inst.components.container then
        local food = inst.components.container:FindItem(function(item)
            return item.components.edible 
                and item.components.edible.hungervalue > 0
                and (item.components.edible.foodtype == "MEAT"
                or item.components.edible.foodtype == "VEGGIE"
                or item.components.edible.foodtype == "INSECT"
                or item.components.edible.foodtype == "SEEDS"
                or item.components.edible.foodtype == "GENERIC")
        end)
        if food then
            if inst.components.tpvalue then
                local dt = food.components.edible.hungervalue
                inst.components.tpvalue:DoDelta(dt)
                if food.components.stackable then
                    food = food.components.stackable:Get()
                end
                food:Remove()
            end
        else
            local my_owner = inst.components.equippable.owner
            if my_owner then
                my_owner.components.inventory:DropItem(inst)
            end
        end 
    end
end

local function bearger_equip(inst, owner)
    common_equip(owner, "backcub")
end

local function bearger_unequip(inst, owner)
end

local function bearger_fn(inst)
    local slotpos = {}

    for y = 0, 6 do
        table.insert(slotpos, Vector3(-162, -y*75 + 240 ,0))
        table.insert(slotpos, Vector3(-162 +75, -y*75 + 240 ,0))
    end
    inst.components.container:SetNumSlots(#slotpos)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_krampusbag_2x8"
    inst.components.container.widgetanimbuild = "ui_krampusbag_2x8"
    inst.components.container.widgetpos = Vector3(-5,-120,0)
    inst.components.container.side_widget = true    
    inst.components.container.type = "pack"

    inst:AddComponent("tpvalue")
    inst.components.tpvalue:SetMax(150)
    inst.components.tpvalue:SetRate(TUNING.WILSON_HUNGER_RATE)
    inst.components.tpvalue.empty = bearger_eat
end

return 
    MakePack("tp_pack_crab", pack_crabs, crab_equip, nil, crab_fn, "backpack_crab"),
    MakePack("tp_pack_dragonfly", pack_dragonflys, dragonfly_equip, nil, dragonfly_fn, "backpack_dragonfly"),
    MakePack("tp_pack_rabbit", pack_rabbits, rabbit_equip, nil, rabbit_fn, "backpack_rabbit"),
    MakePack("tp_pack_beefalo", pack_beefalos, beefalo_equip, beefalo_unequip, beefalo_fn, "backpack_beefalo"),
    MakePack("tp_pack_catcoon", pack_catcoons, catcoon_equip, catcoon_unequip, catcoon_fn, "backpack_catcoon"),
    MakePack("tp_pack_hound", pack_hounds, hound_equip, hound_unequip, hound_fn, "backpack_hound"),
    MakePack("tp_pack_deerclops", pack_deerclopses, deerclops_equip, deerclops_unequip, deerclops_fn, "backpack_deerclops"),
    MakePack("tp_pack_giant", pack_giants, giant_equip, giant_unequip, giant_fn, "giantsfoot"),
    MakePack("tp_pack_bearger", pack_beargers, bearger_equip, bearger_unequip, bearger_fn, "backcub")