local AssetUtil = require "extension/lib/asset_util"
local WgComposBook = require "extension/uis/wg_cook_book"

local PrefabUtil = {}

--[[
设置Prefab名字  
pref (Prefab)预制物类  
name (string)设置的名字  
]]
function PrefabUtil:SetPrefabName(pref, name)
    pref.name = string.sub(name, string.find(name, "[^/]*$"))
end

--[[
钩取Prefab的函数  
pref (Prefab)预制物类  
fn (func)注入的函数  
]]
function PrefabUtil:HookPrefabFn(pref, fn)
    local old = pref.fn
    pref.fn = function()
        local inst = old()
        fn(inst)
        return inst
    end
end

--[[
设置Prefab的资源表  
pref (Prefab)预制物类  
assets (table{Asset})资源列表  
]]
function PrefabUtil:SetPrefabAssets(pref, assets)
    if assets then
        pref.assets = assets
    end
end

--[[
创建item的EntityScript  
(EntityScript) 返回inst  
bank (string)动画资源1
build (string)动画资源2
animation (string)动画资源3  
water (string)动画资源4  
atlas (string)图片资源1  
image (string)图片资源2  
]]
function PrefabUtil:MakeItem(bank, build, animation, water, atlas, image)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    -- trans:SetFourFaced()
    local anim = inst.entity:AddAnimState()
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(animation)
    if water then
        MakeInventoryFloatable(inst, water, animation)
    end
    -- inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = atlas
    if string.find(image, ".tex") then
        assert(nil, "image should not have \".tex\"")
    end
    inst.components.inventoryitem:ChangeImageName(image)

    return inst
end

--[[
创建建筑EntityScript  
(EntityScript) 返回inst  
bank (string)动画资源1
build (string)动画资源2
animation (string)动画资源3  
map (string)地图图标  
]]
function PrefabUtil:MakeStructure(bank, build, animation, map)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    -- trans:SetFourFaced()
    local anim = inst.entity:AddAnimState()
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(animation)
    inst.entity:AddSoundEmitter()
    MakeObstaclePhysics(inst, .5)
    if map then
        local minimap = inst.entity:AddMiniMapEntity()
        minimap:SetIcon(map)
    end
    inst:AddTag("structure")
    inst:AddComponent("inspectable")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnWorkCallback(function(inst, worker)end)
    inst.components.workable:SetOnFinishCallback(function(inst, worker)
        if inst.components.lootdropper then
            inst.components.lootdropper:DropLoot()
        end
        SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
        if inst:HasTag("wood_structure") then
            inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
        elseif inst:HasTag("metal_structure") then
            inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
        end
        inst:Remove()
    end)

    return inst
end

--[[
创建工作台EntityScript  
(EntityScript) 返回inst  
bank (string)动画资源1
build (string)动画资源2
animation (string)动画资源3  
map (string)地图图标  
]]
function PrefabUtil:MakeWorkbench(bank, build, animation, map)
    local inst = self:MakeStructure(bank, build, animation, map)
    local slotpos = {}
    for y = 2, 0, -1 do
        for x = 0, 2 do
            table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80, 0))
        end
    end
    inst:AddComponent("container")
    inst.components.container:SetNumSlots(#slotpos)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0, 200, 0)
    inst.components.container.side_align_tip = 160
    inst:ListenForEvent("onopen", function(inst, data)
        if inst.SoundEmitter then
            inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
        end
    end)
    inst:ListenForEvent("onclose", function(inst, data)
        if inst.SoundEmitter then
            inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
        end
    end)
    inst.components.container.widgetbuttoninfo = {
        text = STRINGS.WG_BOOK,
        position = Vector3(0, -150, 0),
        fn = function(inst, doer)
            inst.components.container:Close()
            if inst.recipe_book then
                TheFrontEnd:PushScreen(WgComposBook(inst.recipe_book, inst, doer))
            end
        end,
        validfn = function(inst)
            return true
        end,
    }
    inst:AddComponent("wg_workbench")
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerFar(function(inst)
        if inst.close_compos then
            inst:close_compos()
        end
    end)
    return inst
end

--[[
创建Placer  
(Prefab) 返回这个Placer  
name 名字  
data 其他数据{onground, snap, metersnap, scale, snap_to_flood, fixedcameraoffset, facing, hide_on_invalid, hide_on_ground, placeTestFn, modifyfn, preSetPrefabfn}  
bank (string)动画资源1
build (string)动画资源2
animation (string)动画资源3  
]]
function PrefabUtil:MakePlacer(name, data, bank, build, animation)
    local args = {"onground", "snap", "metersnap", "scale", "snap_to_flood", "fixedcameraoffset", "facing", "hide_on_invalid", "hide_on_ground", "placeTestFn", "modifyfn", "preSetPrefabfn"}
	data = data or {}
    for k, v in pairs(args) do
        data[k] = data[k] or data[v]
    end
    return MakePlacer("common/"..name.."_placer", bank, build, animation, data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12])
end

return PrefabUtil