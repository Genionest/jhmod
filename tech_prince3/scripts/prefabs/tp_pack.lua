local Util = require "extension.lib.wg_util"
local AssetUtil = require "extension/lib/asset_util"
local PrefabUtil = require "extension/lib/prefab_util"
local EntUtil = require "extension/lib/ent_util"
local Kit = require "extension.lib.wargon"
local AssetMaster = Sample.AssetMaster
local BuffManager = Sample.BuffManager
local Info = Sample.Info
local FxManager = Sample.FxManager
local EnchantmentManager = Sample.EnchantmentManager

local prefs = {}

local function onopen(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_open", "open")
end

local function onclose(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close", "open")
end

local slotpos = {}

for y = 0, 3 do
    table.insert(slotpos, Vector3(-162, -y*75 + 114 ,0))
    table.insert(slotpos, Vector3(-162 +75, -y*75 + 114 ,0))
end
--[[
创建武器预制物  
(Prefab) 返回预制物  
name (string)名字  
equip (func)装备时触发函数  
unequip (func)卸下时触发函数  
fn (func)自定以函数，可以为nil  
]]
local function MakePack(name, equip, unequip, fn)
    return Prefab("objects/"..name, function()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        MakeInventoryPhysics(inst)
        local bank, build, animation, water = AssetMaster:GetAnimation(name, true)
        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(animation)
        if water then
            MakeInventoryFloatable(inst, water, animation)
        end
        -- local map = AssetMaster:GetMap(name)
        -- if map then
            local minimap = inst.entity:AddMiniMapEntity()
            -- minimap:SetIcon(map)
            minimap:SetIcon("backpack.png")
        -- end
        inst:AddTag("backpack")
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        local atlas, image = AssetMaster:GetImage(name, true)
        if string.find(image, ".tex") then
            assert(nil, "image should not have \".tex\"")
        end
        inst.components.inventoryitem.atlasname = atlas
        inst.components.inventoryitem:ChangeImageName(image)

        inst.components.inventoryitem.cangoincontainer = false
        inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/backpack"

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
        inst.components.equippable:SetOnEquip(function(inst, owner)
            owner.AnimState:OverrideSymbol("swap_body", "swap_backpack", "backpack")
            local symbol, build, symbol2 = AssetMaster:GetSymbol(name)
            owner.AnimState:OverrideSymbol(symbol, build, symbol2)
            -- owner.AnimState:OverrideSymbol("swap_body", build, "swap_body")
            owner.components.inventory:SetOverflow(inst)
            inst.components.container:Open(owner) 
            if equip then
                equip(inst, owner)
            end
        end)
        inst.components.equippable:SetOnUnequip(function(inst, owner)
            owner.AnimState:ClearOverrideSymbol("swap_body")
            owner.AnimState:ClearOverrideSymbol("backpack")
            owner.components.inventory:SetOverflow(nil)
            inst.components.container:Close(owner)
            if unequip then
                unequip(inst, owner)
            end
        end)
        -- inst.components.equippable.symbol = name

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

        if fn then
            fn(inst)
        end

        return inst
    end, AssetMaster:GetDSAssets(name))
end

local PackCrabConst = {.15}
local pack_crab = MakePack("tp_pack_crab", 
function(inst, owner)
    local rate = PackCrabConst[1]
    local cmp = owner.components.eater
    cmp:AddHealthAbsorptionMod(inst.prefab, rate)
    cmp:AddSanityAbsorptionMod(inst.prefab, rate)
    cmp:AddHungerAbsorptionMod(inst.prefab, rate)
end, 
function(inst, owner)
    local cmp = owner.components.eater
    cmp:RmHealthAbsorptionMod(inst.prefab)
    cmp:RmSanityAbsorptionMod(inst.prefab)
    cmp:RmHungerAbsorptionMod(inst.prefab)
end, 
function(inst)
end)
table.insert(prefs, pack_crab)
Util:AddString(pack_crab.name, "螃蟹背包", 
string.format("食用食物的三围回复提升%d%%", PackCrabConst[1]*100))

local PackRabbitConst = {.25}
local pack_rabbit = MakePack("tp_pack_rabbit", 
nil, nil,
function(inst)
    inst.components.equippable.walkspeedmult = PackRabbitConst[1]
end)
table.insert(prefs, pack_rabbit)
Util:AddString(pack_rabbit.name, "兔子背包", 
string.format("增加%d%%移速", PackRabbitConst[1]*100))

local PackBeefaloConst = {.15, .35}
local pack_beefalo = MakePack("tp_pack_beefalo", 
function(inst, owner)
    EntUtil:add_tag(owner, "beefalo")
    inst.event_fn = EntUtil:listen_for_event(inst,
        "mounted", function(owner, data)
            if data and data.target then
                EntUtil:add_damage_mod(data.target, inst.prefab, PackBeefaloConst[2])
            end
        end, owner)
    inst.event_fn2 = EntUtil:listen_for_event(inst,
        "dismounted", function(owner, data)
            if data and data.target then
                EntUtil:rm_damage_mod(data.target, inst.prefab)
            end
        end, owner)
    if owner.components.rider 
    and owner.components.rider.mount then
        local target = owner.components.rider.mount
        EntUtil:add_damage_mod(target, inst.prefab, PackBeefaloConst[2])        
    end
end, 
function(inst, owner)
    EntUtil:remove_tag(owner, "beefalo")
    if inst.event_fn then
        inst:RemoveEventCallback("mounted", inst.event_fn, owner)
    end
    if inst.event_fn2 then
        inst:RemoveEventCallback("dismounted", inst.event_fn2, owner)
    end
    if owner.components.rider 
    and owner.components.rider.mount then
        local target = owner.components.rider.mount
        EntUtil:rm_damage_mod(target, inst.prefab)        
    end
end,
function(inst)
    inst.components.equippable.walkspeedmult = PackBeefaloConst[1]
end)
table.insert(prefs, pack_beefalo)
Util:AddString(pack_beefalo.name, "牦牛背包", 
string.format("增加%d%%移速，不会被发情的牛攻击，骑的牛获得%d%%的攻击加成", 
PackBeefaloConst[1]*100, PackBeefaloConst[2]*100))

local PackSmallbirdConst = {40}
local pack_smallbird = MakePack("tp_pack_smallbird", 
function(inst, owner)
    owner.components.combat:AddEvadeRateMod(inst.prefab, PackSmallbirdConst[1])
end, 
function(inst, owner)
    owner.components.combat:RmEvadeRateMod(inst.prefab, PackSmallbirdConst[1])
end,
function(inst)
end)
table.insert(prefs, pack_smallbird)
Util:AddString(pack_smallbird.name, "小鸟背包", 
string.format("增加%d闪避", PackSmallbirdConst[1]))

local PackMandrakeConst = {.3}
local pack_mandrake = MakePack("tp_pack_mandrake", 
function(inst, owner)
    owner.components.health:AddRecoverRateMod(inst.prefab, PackMandrakeConst[1])
end, 
function(inst, owner)
    owner.components.health:RmRecoverRateMod(inst.prefab, PackMandrakeConst[1])
end,
function(inst)
end)
table.insert(prefs, pack_mandrake)
Util:AddString(pack_mandrake.name, "曼德拉背包", 
string.format("增加%d%%生命回复收益", PackMandrakeConst[1]*100))

return unpack(prefs)