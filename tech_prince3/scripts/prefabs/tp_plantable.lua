local PrefabUtil = require "extension.lib.prefab_util"
local Util = require "extension.lib.wg_util"
local AssetMaster = Sample.AssetMaster

local no_tags = {'NOBLOCK', "player", 'FX'}
local function deploy_test(inst, pt, dist, aquatic)
    local dist = dist or 2
    local ok = nil
    if aquatic then
        ok = inst:GetIsOnWater(pt:Get()) -- args:x,y,z
    else
        ok = inst:GetIsOnLand(pt:Get()) -- args:x,y,z
    end
    local tiletype = GetGroundTypeAtPosition(pt)
    ok = ok and tiletype ~= GROUND.ROCKY and tiletype ~= GROUND.ROAD 
    and tiletype ~= GROUND.IMPASSABLE and tiletype ~= GROUND.INTERIOR 
    and tiletype ~= GROUND.UNDERROCK and tiletype ~= GROUND.WOODFLOOR 
    and tiletype ~= GROUND.CARPET and tiletype ~= GROUND.CHECKER 
    and tiletype < GROUND.UNDERGROUND
    if ok then
        local can = true
        local x, y, z = pt:Get()
        local ents = TheSim:FindEntities(x, y, z, dist, nil, no_tags)
        local min = dist or inst.components.deployable and inst.components.deployable.min_spacing
        for k, v in pairs(ents) do
            if v ~= inst and v:IsValid() and v.entity:IsVisible()
            and not v.components.placer and v.parent == nil then
                if distsq(Vector3(v:GetPosition():Get()), pt) < min*min then
                    can = false
                    break
                end
            end
        end
        return can
    end
    return false
end

--[[
创建植物种子  
(Prefab) 返回这个Prefab  
name (string)名字  
tree (string)植物名字  
placer (string)放置蓝图名  
dist (number)距离，默认为2  
aquatic (bool)是否水中  
fn (func)定制函数  
]]
local function MakePlantable(name, tree, placer, dist, aquatic, fn)
    dist = dist or 2
    return Prefab("common/inventory/"..name, function()
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
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        local atlas, image = AssetMaster:GetImage(name, true)
        if string.find(image, ".tex") then
            assert(nil, "image should not have \".tex\"")
        end
        inst.components.inventoryitem.atlasname = atlas
        inst.components.inventoryitem:ChangeImageName(image)

        inst.tree = tree
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = 40
        inst:AddComponent("deployable")
        inst.components.deployable.test = function(inst, pt)
            return deploy_test(inst, pt, dist, aquatic)
        end
        inst.components.deployable.ondeploy = function(inst, pt)
            local tree = SpawnPrefab(inst.tree)
            inst.components.stackable:Get():Remove()
            tree.Transform:SetPosition(pt:Get())
        end
        inst.components.deployable.placer = placer

        if fn then
            fn(inst)
        end

        return inst
    end, AssetMaster:GetDSAssets(name))
end

local prefs = {
MakePlantable("tp_plantable_reeds", "reeds", "reeds_placer"),
MakePlantable("tp_plantable_flower_cave", "flower_cave", "flower_cave_placer"),
MakePlantable("tp_plantable_reeds_water", "reeds_water", "reeds_water_placer", 4, true),
MakePlantable("tp_plantable_grass_water", "grass_water", "grass_water_placer", 4, true),
MakePlantable("tp_plantable_mangrove", "mangrove_normal", "mangrove_placer", 4, true),
PrefabUtil:MakePlacer("reeds", nil, "grass", "reeds", "idle"),
PrefabUtil:MakePlacer("flower_cave", nil, "bulb_plant_single", "bulb_plant_single", "idle"),
PrefabUtil:MakePlacer("reeds_water", nil, "grass_inwater", "reeds_water_build", "idle"),
PrefabUtil:MakePlacer("mangrove", nil, "tree_mangrove", "tree_mangrove_build", "idle_short"),
PrefabUtil:MakePlacer("grass_water", nil, "grass_inwater", "grass_inwater", "idle"),
}

Util:AddString("tp_plantable_mangrove", "红树之茎", "种植出红树")
Util:AddString("tp_plantable_grass_water", "水草之茎", "种植出水草")
Util:AddString("tp_plantable_reeds", "芦苇之茎", "种植出芦苇")
Util:AddString("tp_plantable_reeds_water", "水芦苇之茎", "种植出水芦苇")
Util:AddString("tp_plantable_flower_cave", "荧光之茎", "种植出荧光果")

return unpack(prefs)
