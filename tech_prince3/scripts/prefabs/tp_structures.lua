local Util = require "extension.lib.wg_util"
local PrefabUtil = require "extension/lib/prefab_util"
local AssetMaster = Sample.AssetMaster
local WorkbenchRecipes = Sample.WorkbenchRecipes
local FxManager = Sample.FxManager
local WgComposBook = require "extension/uis/wg_cook_book"
local Kit = require "extension.lib.wargon"
local EntUtil = require "extension.lib.ent_util"

local prefs = {}

STRINGS.WG_SURE = "确认"

local function MakeBurnable(inst)
    MakeMediumBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetOnBurntFn(function(inst)
        inst:AddTag("burnt")
        if inst.components.workable then
            inst.components.workable:Destroy(inst)
        end
    end)
    inst.components.burnable.SpawnFX = function(self, immediate)
        if self.nofx then
            return
        end
        self:KillFX()
        if not self.fxdata then
            self.fxdata = { x = 0, y = 0, z = 0, level = self:GetDefaultFXLevel() }
        end
        if self.fxdata then
            for k, v in pairs(self.fxdata) do
                local fx = SpawnPrefab(v.prefab)
                if fx then
                    if v.follow then
                        local follower = fx.entity:AddFollower()
                        follower:FollowSymbol(self.inst.GUID, v.follow, v.x, v.y, v.z)
                    else
                        self.inst:AddChild(fx)
                        fx.Transform:SetPosition(v.x, v.y, v.z)
                    end
                    table.insert(self.fxchildren, fx)
                    if fx.components.firefx then
                        fx.components.firefx:SetLevel(self.fxlevel, immediate)
                    end
                end
            end
        end
    end
end

local function MakeFloodable(inst, start_flooded, stop_flooded)
    inst:AddComponent("floodable")
    inst.components.floodable.onStartFlooded = start_flooded
    inst.components.floodable.onStopFlooded = stop_flooded
    inst.components.floodable.floodEffect = "shock_machines_fx"
    inst.components.floodable.floodSound = "dontstarve_DLC002/creatures/jellyfish/electric_land"
end

STRINGS.TP_FORGE = "鍛造"
local furnace = Prefab("tp_furnace", function()
    local bank, build, animation = AssetMaster:GetAnimation("tp_furnace")
    local map = AssetMaster:GetMap("tp_furnace")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    inst:AddComponent("container")
    inst.components.container:SetNumSlots(2)
    inst.components.container.widgetanimbank = "ui_cookpot_1x4"
    inst.components.container.widgetanimbuild = "ui_cookpot_1x4"
    inst.components.container.widgetslotpos = {
        Vector3(0, 40, 0),
        Vector3(0, -40, 0)
    }
    inst.components.container.widgetpos = Vector3(200, 0, 0)
    inst.components.container.side_align_tip = 100
    inst.components.container.widgetbuttoninfo = {
        text = STRINGS.TP_FORGE,
        position = Vector3(0, -140, 0),
        fn = function(inst)
            -- if inst.components.container:Has("goldnugget", 1) then
            --     inst.components.container:ConsumeByName("goldnugget", 1)
            --     local food = inst.components.container:FindItem(function(nug) return nug.components.tppowerfruit end)
            --     if food then food.components.tppowerfruit:Random() end
            -- end
            local equip = inst.components.container:FindItem(function(item)
                return item.components.tp_forge_weapon
            end)
            local material = inst.components.container:FindItem(function(item)
                return item:HasTag("forge_material")
            end)
            equip.components.tp_forge_weapon:Forge(material)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh",nil,.5)
        end,
        validfn = function(inst)
            local equip = inst.components.container:FindItem(function(item)
                return item.components.tp_forge_weapon
            end)
            if equip then
                local material = inst.components.container:FindItem(function(item)
                    return equip.components.tp_forge_weapon:CanForge(item)
                end)
                if material then
                    return true
                end
            end
        end,
    }
    inst.components.container.onopenfn = function(inst, doer)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
    inst.components.container.onclosefn = function(inst, doer)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
    -- local inst = PrefabUtil:MakeWorkbench(
    --     bank, build, animation, map
    -- )
    -- inst.recipe_book = WorkbenchRecipes:GetRecipeShelf("tp_furnace")
    -- inst.components.workable:SetOnWorkCallback(function(inst, worker)
    --     inst.AnimState:PlayAnimation("hi_hit")
    --     if inst.components.wg_workbench.running then
    --         inst.AnimState:PushAnimation("hi", true)
    --     else
    --         inst.AnimState:PushAnimation("idle")
    --     end
    -- end)
    -- inst.components.wg_workbench.consume_test = function(inst)
    --     return true
    -- end
    -- inst.components.wg_workbench.consume_fn = function(inst)
    -- end
    -- inst.components.wg_workbench.run_start = function(inst)
    --     inst.AnimState:PlayAnimation("hi", true)
    -- end
    -- inst.components.wg_workbench.run_stop = function(inst)
    --     inst.AnimState:PlayAnimation("idle")
    -- end
    -- inst.components.wg_workbench.test = function(inst)
    --     return true
    -- end
    return inst
end, AssetMaster:GetDSAssets("tp_furnace"))
table.insert(prefs, furnace)
table.insert(prefs, PrefabUtil:MakePlacer(furnace.name, nil,
    AssetMaster:GetAnimation(furnace.name)))
Util:AddString(furnace.name, "熔炉", "鍛造物品")

local desk = Prefab("tp_desk", function()
    local bank, build, animation = AssetMaster:GetAnimation("tp_desk")
    local map = AssetMaster:GetMap("tp_desk")
    local inst = PrefabUtil:MakeWorkbench(
        bank, build, animation, map
    )
    inst.recipe_book = WorkbenchRecipes:GetRecipeShelf("tp_desk")
    inst.components.workable:SetOnWorkCallback(function(inst, worker)
        inst.AnimState:PlayAnimation("hit")
        if inst.components.wg_workbench.running then
            inst.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PushAnimation("idle")
        end
    end)
    inst.components.wg_workbench.consume_test = function(inst)
        return true
    end
    inst.components.wg_workbench.consume_fn = function(inst)
    end
    inst.components.wg_workbench.run_start = function(inst)
        inst.AnimState:PlayAnimation("proximity_loop", true)
    end
    inst.components.wg_workbench.run_stop = function(inst)
        inst.AnimState:PlayAnimation("idle")
    end
    inst.components.wg_workbench.test = function(inst)
        return true
    end
    return inst
end, AssetMaster:GetDSAssets("tp_desk"))
table.insert(prefs, desk)
table.insert(prefs, PrefabUtil:MakePlacer(desk.name, nil,
    AssetMaster:GetAnimation(desk.name)))
Util:AddString(desk.name, "绘图台", "绘制物品")

local lab = Prefab("tp_lab", function()
    local bank, build, animation = AssetMaster:GetAnimation("tp_lab")
    local map = AssetMaster:GetMap("tp_lab")
    local inst = PrefabUtil:MakeWorkbench(
        bank, build, animation, map
    )
    inst.recipe_book = WorkbenchRecipes:GetRecipeShelf("tp_lab")
    inst.components.workable:SetOnWorkCallback(function(inst, worker)
        inst.AnimState:PlayAnimation("hit_empty")
        if inst.components.wg_workbench.running then
            inst.AnimState:PushAnimation("cooking_loop1", true)
        else
            inst.AnimState:PushAnimation("idle")
        end
    end)
    inst.components.wg_workbench.consume_test = function(inst)
        return true
    end
    inst.components.wg_workbench.consume_fn = function(inst)
    end
    inst.components.wg_workbench.run_start = function(inst)
        inst.AnimState:PlayAnimation("cooking_loop3_pre")
        inst.AnimState:PushAnimation("cooking_loop1", true)
    end
    inst.components.wg_workbench.run_stop = function(inst)
        inst.AnimState:PlayAnimation("idle")
    end
    inst.components.wg_workbench.test = function(inst)
        return true
    end
    return inst
end, AssetMaster:GetDSAssets("tp_lab"))
table.insert(prefs, lab)
table.insert(prefs, PrefabUtil:MakePlacer(lab.name, nil,
    AssetMaster:GetAnimation(lab.name)))
Util:AddString(lab.name, "制药台", "炼制物品")

local research_center = Prefab("ak_research_center", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_research_center")
    local map = AssetMaster:GetMap("ak_research_center")
    local inst = PrefabUtil:MakeWorkbench(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst.components.container.widgetbuttoninfo.fn = function(inst, doer)
        inst.components.container:Close()
        if inst.recipe_book == nil then
            local title = inst.prefab
            -- local title = inst.prefab.."_"..doer.prefab
            inst.recipe_book = WorkbenchRecipes:GetRecipeShelf(title)
        end
        TheFrontEnd:PushScreen(WgComposBook(inst.recipe_book, inst, doer))
    end
    inst.components.workable:SetOnWorkCallback(function(inst, worker)
    end)
    inst.components.wg_workbench.consume_test = function(inst)
        return not inst:HasTag("flooded")
    end
    inst.components.wg_workbench.consume_fn = function(inst)
    end
    inst.components.wg_workbench.run_start = function(inst)
    end
    inst.components.wg_workbench.run_stop = function(inst)
    end
    inst.components.wg_workbench.test = function(inst)
        return not inst:HasTag("flooded")
    end
    return inst
end, AssetMaster:GetDSAssets("ak_research_center"))
table.insert(prefs, research_center)
table.insert(prefs, PrefabUtil:MakePlacer(research_center.name,
    { scale = 2 },
    AssetMaster:GetAnimation(research_center.name)))
Util:AddString(research_center.name, "研究中心", "发明物品")

local work_bench = Prefab("ak_work_bench", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_work_bench")
    local map = AssetMaster:GetMap("ak_work_bench")
    local inst = PrefabUtil:MakeWorkbench(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst.recipe_book = WorkbenchRecipes:GetRecipeShelf("ak_work_bench")
    inst.components.workable:SetOnWorkCallback(function(inst, worker)
    end)

    inst:AddComponent("ak_electric")
    local load = 60
    inst.components.ak_electric:SetMax(load * 4)
    inst.components.ak_electric:SetRate(load)
    inst.components.ak_electric.load = load
    inst.components.wg_workbench.consume_test = function(inst)
        return (not inst:HasTag("flooded"))
            and inst.components.ak_electric.current >= load
    end
    inst.components.wg_workbench.consume_fn = function(inst)
        inst.components.ak_electric:DoDelta(-load)
    end
    inst.components.wg_workbench.test = function(inst)
        return (not inst:HasTag("flooded"))
            and inst.components.ak_electric.current >= load
    end

    return inst
end, AssetMaster:GetDSAssets("ak_work_bench"))
table.insert(prefs, work_bench)
table.insert(prefs, PrefabUtil:MakePlacer(work_bench.name,
    { scale = 2 },
    AssetMaster:GetAnimation(work_bench.name)))
Util:AddString(work_bench.name, "工作台", "制作物品")

local smithing_table = Prefab("ak_smithing_table", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_smithing_table")
    local map = AssetMaster:GetMap("ak_smithing_table")
    local inst = PrefabUtil:MakeWorkbench(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst.recipe_book = WorkbenchRecipes:GetRecipeShelf("ak_smithing_table")
    inst.components.workable:SetOnWorkCallback(function(inst, worker)
    end)

    inst:AddComponent("ak_electric")
    local load = 480
    inst.components.ak_electric:SetMax(load * 4)
    inst.components.ak_electric:SetRate(load)
    inst.components.ak_electric.load = load
    inst.components.wg_workbench.consume_test = function(inst)
        return (not inst:HasTag("flooded"))
            and inst.components.ak_electric.current >= load
    end
    inst.components.wg_workbench.consume_fn = function(inst)
        inst.components.ak_electric:DoDelta(-load)
    end
    inst.components.wg_workbench.test = function(inst)
        return (not inst:HasTag("flooded"))
            and inst.components.ak_electric.current >= load
    end

    return inst
end, AssetMaster:GetDSAssets("ak_smithing_table"))
table.insert(prefs, smithing_table)
table.insert(prefs, PrefabUtil:MakePlacer(smithing_table.name,
    { scale = 2 },
    AssetMaster:GetAnimation(smithing_table.name)))
Util:AddString(smithing_table.name, "锻造台", "制作高级物品")

local manual_generator = Prefab("ak_manual_generator", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_manual_generator")
    local map = AssetMaster:GetMap("ak_manual_generator")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")

    inst:AddComponent("ak_generator")
    inst.components.ak_generator.power = 60
    inst:AddComponent("wg_machine")
    inst.components.wg_machine.long_act = true
    inst.components.wg_machine.fn = function(inst, doer)
        inst.components.ak_generator:DoDelta(2)
    end
    inst.components.wg_machine.test = function(inst, doer)
        return not inst:HasTag("flooded")
    end

    return inst
end, AssetMaster:GetDSAssets("ak_manual_generator"))
table.insert(prefs, manual_generator)
table.insert(prefs, PrefabUtil:MakePlacer(manual_generator.name,
    { scale = 2 },
    AssetMaster:GetAnimation(manual_generator.name)))
Util:AddString(manual_generator.name, "人力发电机", "进行操作后发电")

local wood_generator = Prefab("ak_wood_generator", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_wood_generator")
    local map = AssetMaster:GetMap("ak_wood_generator")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")
    inst:AddComponent("ak_generator")
    inst.components.ak_generator:SetMax(300)
    inst.components.ak_generator.power = 300
    inst.components.ak_generator.consume_fn = function(inst)
    end
    inst:AddComponent('wg_interable')
    inst.components.wg_interable.test = function(inst, item, doer)
        return item.prefab == "log"
    end
    inst.components.wg_interable:SetFn(function(inst, item, doer)
        local n = 1
        if item.components.stackable then
            local need = math.ceil(inst.components.ak_generator:GetCost() / 5)
            local stack = item.components.stackable:StackSize()
            n = math.max(1, math.min(need, stack))
        end
        inst.components.ak_generator:DoDelta(n * 5)
        item:Remove()
    end)

    return inst
end, AssetMaster:GetDSAssets("ak_wood_generator"))
table.insert(prefs, wood_generator)
table.insert(prefs, PrefabUtil:MakePlacer(wood_generator.name,
    { scale = 2 },
    AssetMaster:GetAnimation(wood_generator.name)))
Util:AddString(wood_generator.name, "木料发电机", "添加木头发电")

local sun_generator = Prefab("ak_sun_generator", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_sun_generator")
    local map = AssetMaster:GetMap("ak_sun_generator")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    inst.Transform:SetScale(2, 2, 2)
    inst:AddComponent("lootdropper")
    inst:AddTag("metal_structure")
    inst:AddComponent("ak_generator")
    inst.components.ak_generator.power = 400
    inst.components.ak_generator:SetMax(3)
    inst.start = function(inst)
        if not GetWorld():IsCave() then
            if inst.task == nil then
                inst.task = inst:DoPeriodicTask(2, function()
                    inst.components.ak_generator:DoDelta(3)
                end)
            end
        end
    end
    inst.stop = function(inst)
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end
    inst:DoTaskInTime(0, function()
        if not GetClock():IsNight() then
            inst:start()
        end
    end)
    inst:ListenForEvent("daytime", function(world, data)
        inst:start()
    end, GetWorld())
    -- inst:ListenForEvent("dusktime", function(world, data)

    -- end)
    inst:ListenForEvent("nighttime", function(world, data)
        inst:stop()
    end, GetWorld())
    return inst
end, AssetMaster:GetDSAssets("ak_sun_generator"))
table.insert(prefs, sun_generator)
table.insert(prefs, PrefabUtil:MakePlacer(sun_generator.name,
    { scale = 2 },
    AssetMaster:GetAnimation(sun_generator.name)))
Util:AddString(sun_generator.name, "太阳能板", "白天发电，夜晚和洞穴内不发电")

local battery = Prefab("ak_battery", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_battery")
    local map = AssetMaster:GetMap("ak_battery")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")
    inst:AddComponent("ak_battery")
    inst.components.ak_battery:SetMax(10000)
    inst.components.ak_battery.anims = {
        "off", "on_pre", "on", "on_pst"
    }
    return inst
end, AssetMaster:GetDSAssets("ak_battery"))
table.insert(prefs, battery)
table.insert(prefs, PrefabUtil:MakePlacer(battery.name,
    { scale = 2 },
    AssetMaster:GetAnimation(battery.name)))
Util:AddString(battery.name, "电池", "储存电力")

local smart_battery = Prefab("ak_smart_battery", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_smart_battery")
    local map = AssetMaster:GetMap("ak_smart_battery")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")
    inst.components.workable:SetOnFinishCallback(function(inst, worker)
        if inst.components.lootdropper then
            inst.components.lootdropper:DropLoot()
        end
        SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
        inst:work()
        inst:Remove()
    end)
    inst:AddComponent("ak_battery")
    inst.components.ak_battery:SetMax(20000)
    inst.components.ak_battery.anims = nil
    inst:DoTaskInTime(1, function()
        local on = inst.components.ak_battery:GetPercent() < .7
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 15, { "ak_generator" })
        for k, v in pairs(ents) do
            v.components.ak_generator.on = on
            if on then
                v:PushEvent("ak_generator_on")
            else
                v:PushEvent("ak_generator_off")
            end
        end
    end)
    inst:ListenForEvent("wg_value_delta", function(inst, data)
        if data.old_p < .8 and data.new_p >= .8 then
            local x, y, z = inst:GetPosition():Get()
            local ents = TheSim:FindEntities(x, y, z, 15, { "ak_generator" })
            for k, v in pairs(ents) do
                v.components.ak_generator.on = nil
                v:PushEvent("ak_generator_off")
            end
        end
        if data.old_p >= .8 and data.new_p < .8 then
            inst:work()
        end
    end)
    inst.work = function(inst)
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 15, { "ak_generator" })
        for k, v in pairs(ents) do
            v.components.ak_generator.on = true
            v:PushEvent("ak_generator_on")
        end
    end

    return inst
end, AssetMaster:GetDSAssets("ak_smart_battery"))
table.insert(prefs, smart_battery)
table.insert(prefs, PrefabUtil:MakePlacer(smart_battery.name,
    { scale = 2 },
    AssetMaster:GetAnimation(smart_battery.name)))
Util:AddString(smart_battery.name, "智能电池", "存储电力超过80%后输出信号暂停周围的发电机")

local electric_wire = Prefab("ak_electric_wire", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_electric_wire")
    local map = AssetMaster:GetMap("ak_electric_wire")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")
    inst:AddComponent("ak_electric_wire")
    inst.components.ak_electric_wire.max_load = 2000

    return inst
end, AssetMaster:GetDSAssets("ak_electric_wire"))
table.insert(prefs, electric_wire)
table.insert(prefs, PrefabUtil:MakePlacer(electric_wire.name,
    { scale = 2 },
    AssetMaster:GetAnimation(electric_wire.name)))
Util:AddString(electric_wire.name, "电能传输器",
    "电力传输的桥梁，发电设施生产的电必须通过它传输到用电设施上，电力可以跨越多个电能传输设施；最大负载2000")

local large_power_transformer = Prefab("ak_large_power_transformer", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_large_power_transformer")
    local map = AssetMaster:GetMap("ak_large_power_transformer")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(4, 4, 4)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")
    inst:AddComponent("ak_electric_wire")
    inst.components.ak_electric_wire.max_load = 40000
    return inst
end, AssetMaster:GetDSAssets("ak_large_power_transformer"))
table.insert(prefs, large_power_transformer)
table.insert(prefs, PrefabUtil:MakePlacer(large_power_transformer.name,
    { scale = 4 },
    AssetMaster:GetAnimation(large_power_transformer.name)))
Util:AddString(large_power_transformer.name, "大电能传输器",
    "电力传输的桥梁，发电设施生产的电必须通过它传输到用电设施上，电力可以跨越多个电能传输设施；最大负载40000")

local power_shutoff = Prefab("ak_power_shutoff", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_power_shutoff")
    local map = AssetMaster:GetMap("ak_power_shutoff")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst, function(inst)
        if inst.components.machine.ison then
            inst.components.machine:TurnOff()
        end
    end)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")
    inst:AddComponent("ak_electric")
    inst.components.ak_electric:SetMax(240)
    inst.components.ak_electric.load = 120
    inst:AddComponent("machine")
    inst:ListenForEvent("turnedon", function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_on")
    end)
    inst:ListenForEvent("turnedoff", function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_off")
    end)
    inst.components.machine.turnonfn = function(inst)
        inst:turn_on()
    end
    inst.components.machine.turnofffn = function(inst)
        inst:turn_off()
    end
    -- inst.components.machine.cooldowntime = 3
    inst.components.machine.caninteractfn = function(inst)
        return inst.components.ak_electric.current >= 40
            and not inst:HasTag("flooded")
    end
    inst.turn_on = function(inst)
        if inst.task == nil then
            inst.task = inst:DoPeriodicTask(1, function()
                local x, y, z = inst:GetPosition():Get()
                local ents = TheSim:FindEntities(x, y, z, 4, 15)
                if ents then
                    for k, v in pairs(ents) do
                        if v.prefab == "trap_teeth"
                            and v.components.mine
                            and v.components.mine.issprung then
                            inst.components.ak_electric:DoDelta(-40)
                            v.components.mine:Reset()
                        end
                    end
                end
            end)
        end
        inst.AnimState:PlayAnimation("on_pre")
        inst.AnimState:PushAnimation("on", false)
    end
    inst.turn_off = function()
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
        inst.AnimState:PlayAnimation("on_pst")
        inst.AnimState:PushAnimation("off")
    end

    return inst
end, AssetMaster:GetDSAssets("ak_power_shutoff"))
table.insert(prefs, power_shutoff)
table.insert(prefs, PrefabUtil:MakePlacer(power_shutoff.name,
    { scale = 2 },
    AssetMaster:GetAnimation(power_shutoff.name)))
Util:AddString(power_shutoff.name, "陷阱重置器", "电器，重置周围的犬牙陷阱")

local lamp = Prefab("ak_lamp", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_lamp")
    local map = AssetMaster:GetMap("ak_lamp")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst, function(inst)
        if inst.components.machine.ison then
            inst.components.machine:TurnOff()
        end
    end)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")
    inst:AddComponent("ak_electric")
    inst.components.ak_electric:SetMax(100)
    inst.components.ak_electric:SetRate(10)
    inst.components.ak_electric.load = 10
    inst.components.ak_electric.empty = function(inst)
        inst:turn_off()
    end
    Kit:make_light(inst, "city_lamp")
    inst.Light:SetRadius(10)
    inst.Light:SetFalloff(.8)
    inst:AddComponent("machine")
    inst.components.machine.turnonfn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_on")
        inst:turn_on()
    end
    inst.components.machine.turnofffn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_off")
        inst:turn_off()
    end
    -- inst.components.machine.cooldowntime = 3
    inst.components.machine.caninteractfn = function(inst)
        return inst.components.ak_electric.current >= 10
            and not inst:HasTag("flooded")
    end
    inst.turn_on = function(inst)
        if (GetWorld():IsCave() or GetClock():IsNight()) then
            inst.AnimState:PlayAnimation("on")
            inst.Light:Enable(true)
            inst.components.ak_electric:Start()
        end
    end
    inst.turn_off = function(inst)
        inst.AnimState:PlayAnimation("off")
        inst.Light:Enable(false)
        inst.components.ak_electric:Stop()
    end
    inst:ListenForEvent("daytime", function(world, data)
        if not (GetWorld():IsCave() or GetClock():IsNight()) then
            inst:DoTaskInTime(1, function()
                inst:turn_off()
            end)
        end
    end, GetWorld())
    inst:ListenForEvent("nighttime", function(world, data)
        if inst.components.machine.ison then
            inst:turn_on()
        end
    end, GetWorld())

    return inst
end, AssetMaster:GetDSAssets("ak_lamp"))
table.insert(prefs, lamp)
table.insert(prefs, PrefabUtil:MakePlacer(lamp.name,
    { scale = 2 },
    AssetMaster:GetAnimation(lamp.name)))
Util:AddString(lamp.name, "电灯", "电器，照亮大范围地区，夜晚或洞穴内才会开灯")

local food_compressor = Prefab("ak_food_compressor", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_food_compressor")
    local map = AssetMaster:GetMap("ak_food_compressor")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")

    inst:AddComponent("ak_electric")
    inst.components.ak_electric:SetMax(240)
    inst.components.ak_electric.load = 60
    inst:AddComponent("container")
    inst.components.container.itemtestfn = function(inst, item, slot)
        return item.components.tp_food_effect
            and item.components.tp_food_effect:Test()
    end
    inst.components.container:SetNumSlots(1.1)
    inst.components.container.widgetslotpos = { Vector3(0, 0, 0) }
    inst.components.container.widgetanimbank = "ui_bundle_2x2"
    inst.components.container.widgetanimbuild = "ui_bundle_2x2"
    inst.components.container.widgetpos = Vector3(200, 0, 0)
    inst.components.container.side_align_tip = 100
    inst.components.container.widgetbuttoninfo = {
        text = STRINGS.ACTIONS.COOK.GENERIC,
        position = Vector3(0, -165, 0),
        fn = function(inst)
            inst.components.ak_electric:DoDelta(-60)
            inst.AnimState:PlayAnimation("working_pre")
            inst.AnimState:PushAnimation("working_loop", false)
            inst.AnimState:PushAnimation("working_pst", false)
            inst.AnimState:PushAnimation("off", false)

            inst.components.container:Close()
            inst.components.container.canbeopened = false
        end,
        validfn = function(inst)
            return inst.components.ak_electric.current >= 60
                and not inst:HasTag("flooded")
        end,
    }
    inst.components.container.onopenfn = function(inst, doer)
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open", "open")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot", "snd")
    end
    inst.components.container.onclosefn = function(inst, doer)
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close", "close")
    end
    inst.compress_food = function(inst)
        local food = inst.components.container:FindItem(function(nug)
            return nug.components.tp_food_effect
        end)
        if food then
            -- food.components.tp_food_effect:Random()
            food.components.tp_food_effect.wake = true
        end
    end
    inst:ListenForEvent("animover", function(inst, data)
        if inst.AnimState:IsCurrentAnimation("working_pst") then
            inst:compress_food()
            inst.components.container.canbeopened = true
        end
    end)

    return inst
end, AssetMaster:GetDSAssets("ak_food_compressor"))
table.insert(prefs, food_compressor)
table.insert(prefs, PrefabUtil:MakePlacer(food_compressor.name,
    { scale = 2 },
    AssetMaster:GetAnimation(food_compressor.name)))
Util:AddString(food_compressor.name, "食物压制机",
    "电器,放入食物能够给食物添加调料,食用后会有特殊效果(叠加无调料的食物会失去调料效果)")

local compost = Prefab("ak_compost", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_compost")
    local map = AssetMaster:GetMap("ak_compost")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("wood_structure")
    inst:AddComponent("lootdropper")

    local compost_items = {
        ["spoiled_food"] = true,
        ["spoiled_fish"] = true,
        ["rottenegg"] = true,
    }
    inst.components.container.itemtestfn = function(inst, item)
        return compost_items[item.prefab]
            or (item.components.perishable
                and compost_items[item.components.perishable.onperishreplacement])
    end
    inst.task = inst:DoPeriodicTask(60, function()
        local name = nil
        for k, v in pairs(compost_items) do
            if inst.components.container:Has(k, 1) then
                name = k
                break
            end
        end
        if name then
            inst.components.container:ConsumeByName(name, 1)
            local poop = SpawnPrefab("poop").Transform:SetPosition(inst:GetPosition():Get())
        end
        -- 加速腐烂
        for k, v in pairs(inst.components.container.slots) do
            if v.components.perishable then
                local p = v.components.perishable:GetPercent()
                v.components.perishable:SetPercent(p - .05)
            end
        end
    end)
    inst.change = function(inst)
        local n = inst.components.container:NumItems()
        if n == 1 then
            inst.AnimState:PlayAnimation("idle_half")
        elseif n > 1 then
            inst.AnimState:PlayAnimation("working_pst")
        end
    end
    inst:ListenForEvent("itemget", function(inst)
        inst:change()
    end)
    inst:ListenForEvent("itemlose", function(inst)
        inst:change()
    end)

    return inst
end, AssetMaster:GetDSAssets("ak_compost"))
table.insert(prefs, compost)
table.insert(prefs, PrefabUtil:MakePlacer(compost.name,
    { scale = 2 },
    AssetMaster:GetAnimation(compost.name)))
Util:AddString(compost.name, "堆肥堆",
    "可以放入腐烂食物、腐烂鱼、腐烂蛋或者腐烂后会变成前三种东西的物品，加速腐烂速度，腐烂物经过一定时间后转化成便便")

local triage_table = Prefab("ak_triage_table", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_triage_table")
    local map = AssetMaster:GetMap("ak_triage_table")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")

    inst:AddComponent("ak_electric")
    inst.components.ak_electric.load = 60
    inst:AddComponent("sleepingbag")
    inst.components.sleepingbag.onsleep = function(inst, sleeper)
        local can_sleep = true
        if inst:HasTag("flooded") then
            sleeper.components.talker:Say("建筑被淹没")
        end
        if not sleeper.components.poisonable:IsPoisoned() then
            sleeper.components.talker:Say("我并没有中毒")
            return
        end
        if inst.components.ak_electric.current < 60 then
            sleeper.components.talker:Say("电量不足")
            return
        end

        local hounded = GetWorld().components.hounded
        local notags = { "FX", "NOCLICK", "INLIMBO" }
        local danger = FindEntity(inst, 10, function(target)
            return (target:HasTag("monster") and not target:HasTag("player") and not sleeper:HasTag("spiderwhisperer"))
                or
                (target:HasTag("monster") and not target:HasTag("player") and sleeper:HasTag("spiderwhisperer") and not target:HasTag("spider"))
                or (target:HasTag("pig") and not target:HasTag("player") and sleeper:HasTag("spiderwhisperer"))
                or (target.components.combat and target.components.combat.target == sleeper)
        end, nil, notags)
        if hounded and (hounded.warning or hounded.timetoattack <= 0) then
            danger = true
        end
        if danger then
            if sleeper.components.talker then
                sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NODANGERSLEEP"))
            end
            return
        end

        GetPlayer().HUD:Hide()
        TheFrontEnd:Fade(false, 1)
        inst.components.ak_electric:DoDelta(-60)
        inst:DoTaskInTime(1.2, function()
            GetPlayer().HUD:Show()
            TheFrontEnd:Fade(true, 1)

            sleeper.sg:GoToState("wakeup")
            if sleeper.components.hunger then
                sleeper.components.hunger:DoDelta(-TUNING.CALORIES_HUGE, false, true)
            end
            if sleeper.components.poisonable then
                sleeper.components.poisonable:Cure()
            end

            GetClock():MakeNextDay()
        end)
    end

    return inst
end, AssetMaster:GetDSAssets("ak_triage_table"))
table.insert(prefs, triage_table)
table.insert(prefs, PrefabUtil:MakePlacer(triage_table.name,
    { scale = 2 },
    AssetMaster:GetAnimation(triage_table.name)))
Util:AddString(triage_table.name, "分诊床", "睡一觉解毒")

local farmer_station = Prefab("ak_farmer_station", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_farmer_station")
    local map = AssetMaster:GetMap("ak_farmer_station")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst, function(inst)
        if inst.components.machine.ison then
            inst.components.machine:TurnOff()
        end
    end)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")

    inst:AddComponent("ak_electric")
    inst.components.ak_electric.load = 120
    inst.components.ak_electric:SetMax(240)
    inst.components.ak_electric:SetRate(120)
    inst:AddComponent("machine")
    inst:ListenForEvent("turnedon", function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_on")
    end)
    inst:ListenForEvent("turnedoff", function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_off")
    end)
    inst.components.machine.turnonfn = function(inst)
        if inst.components.ak_electric.current >= 120 then
            inst:turn_on()
        end
    end
    inst.components.machine.turnofffn = function(inst)
        inst:turn_off()
    end
    -- inst.components.machine.cooldowntime = 3
    inst.components.machine.caninteractfn = function(inst)
        return inst.components.ak_electric.current >= 120
            and not inst:HasTag("flooded")
    end
    inst.components.ak_electric.empty = function(inst)
    end
    inst.num = 0
    inst:AddComponent("wg_info")
    inst.components.wg_info.info = function(inst)
        return string.format("肥料值:%d\n施肥计时器:%ds", inst.num, inst.timer)
    end
    inst:AddComponent('wg_interable')
    inst.components.wg_interable.test = function(inst, item, doer)
        return (item.prefab == "poop" or item.prefab == "guano")
            and inst.num < 100
    end
    inst.components.wg_interable:SetFn(function(inst, item, doer)
        local stack = item.components.stackable:StackSize()
        local n = math.min(100 - inst.num, stack * 10)
        n = math.ceil(n / 10)
        inst.num = math.min(100, inst.num + n * 10)
        item = item.components.stackable:Get(n)
        item:Remove()
    end)
    inst.protect_plant = function(inst)
        if inst.num <= 0 then
            return
        end
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 15)
        for k, v in pairs(ents) do
            if v.components.pickable
                and not v.components.pickable.reverseseasons
                and v.components.pickable:CanBeFertilized() then
                local target = SpawnPrefab("spoiled_food")
                if target then
                    v.components.pickable:Fertilize(target)
                    SpawnPrefab("small_puff").Transform:SetPosition(v:GetPosition():Get())
                    -- once
                    inst:cost()
                    break
                end
            end

            if v.components.pickable
                and v.components.pickable.reverseseasons
                and v.components.pickable:CanBeFertilized() then
                local target = SpawnPrefab("ash")
                if target then
                    v.components.pickable:Fertilize(target)
                    SpawnPrefab("small_puff").Transform:SetPosition(v:GetPosition():Get())
                    -- once
                    inst:cost()
                    break
                end
            end

            if v.components.hackable
                and not v.components.hackable.reverseseasons
                and v.components.hackable:CanBeFertilized() then
                local target = SpawnPrefab("spoiled_food")
                if target then
                    v.components.hackable:Fertilize(target)
                    SpawnPrefab("small_puff").Transform:SetPosition(v:GetPosition():Get())
                    -- once
                    inst:cost()
                    break
                end
            end
            -- 农田里的植物
            if v and v.components.crop
                and not v.components.crop:IsReadyForHarvest()
                and not v.components.crop:IsWithered() then
                local target = SpawnPrefab("spoiled_food")
                if target then
                    v.components.crop:ForceFertilize(target)
                    SpawnPrefab("small_puff").Transform:SetPosition(v:GetPosition():Get())
                    -- once
                    inst:cost()
                    break
                end
            end
        end
    end
    inst.cost = function(inst)
        inst.components.ak_electric:DoDelta(-120)
        inst.num = inst.num - 1
        inst.timer = 0
    end
    inst.timer = 0
    inst.turn_on = function(inst)
        inst.AnimState:PlayAnimation("working_pre")
        inst.AnimState:PushAnimation("working_loop", true)

        if inst.task == nil then
            inst.task = inst:DoPeriodicTask(1, function()
                if inst.timer < 60 then
                    inst.timer = inst.timer + 1
                    inst.components.ak_electric:DoDelta(-60)
                else
                    inst:protect_plant()
                end
            end)
        end
    end
    inst.turn_off = function(inst)
        inst.AnimState:PlayAnimation("working_pst")
        inst.AnimState:PushAnimation("off", false)

        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end
    inst.OnSave = function(inst, data)
        if data then
            data.num = inst.num
            data.timer = inst.timer
        end
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.num = data.num or 0
            inst.timer = data.timer or 0
        end
    end

    return inst
end, AssetMaster:GetDSAssets("ak_farmer_station"))
table.insert(prefs, farmer_station)
table.insert(prefs, PrefabUtil:MakePlacer(farmer_station.name,
    { scale = 2 },
    AssetMaster:GetAnimation(farmer_station.name)))
Util:AddString(farmer_station.name, "农业站", "电器，需要添加粪肥，周期性为周围的作物施肥")

local auto_harvester_robot = Prefab("ak_auto_harvester_robot", function()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddComponent("inventory")
    return inst
end)
table.insert(prefs, auto_harvester_robot)

local auto_harvester = Prefab("ak_auto_harvester", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_auto_harvester")
    local map = AssetMaster:GetMap("ak_auto_harvester")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")

    inst:AddComponent("ak_electric")
    inst.components.ak_electric:SetMax(240)
    inst.components.ak_electric.load = 120
    inst.work = function(inst, doer)
        if doer == nil then
            if inst.robot == nil then
                inst.robot = SpawnPrefab("ak_auto_harvester_robot")
                inst.robot.Transform:SetPosition(inst:GetPosition():Get())
            end
            doer = inst.robot
        end
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 4, 20)
        for k, v in pairs(ents) do
            if not (v.components.burnable
                    and v.components.burnable:IsBurning()) then
                if v.components.pickable
                    and v.components.pickable:CanBePicked()
                    and v.components.pickable.caninteractwith then
                    v.components.pickable:Pick(doer)
                end

                if v.components.pickupable
                    and v.components.pickupable:CanPickUp() then
                    doer:PushEvent("onpickup", { item = v })
                    v.components.pickupable:OnPickup(doer)
                end

                if v.components.harvestable
                    and v.components.harvestable:CanBeHarvested() then
                    v.components.harvestable:Harvest(doer)
                end

                if v.components.breeder
                    and v.components.breeder.volume > 0 then
                    v.components.breeder:Harvest(doer)
                end

                if v.components.crop
                    and (v.components.crop:IsReadyForHarvest()
                        or v.components.crop:IsWithered()) then
                    v.components.crop:Harvest(doer)
                end

                if v.components.dryer
                    and v.components.dryer:IsDone() then
                    v.components.dryer:Harvest(doer)
                end
                -- mod的一些东西
                if v:HasTag("ak_can_harvest") then
                    if not v.ak_harvest_test or v.ak_harvest_test(v, doer) then
                        if v.ak_harvest_fn then
                            v.ak_harvest_fn(v, doer)
                        end
                    end
                end
            end
        end
        inst.components.ak_electric:DoDelta(-120)
        doer.components.inventory:DropEverything()
    end
    inst:AddComponent("machine")
    inst:ListenForEvent("turnedon", function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_on")
    end)
    inst:ListenForEvent("turnedoff", function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_off")
    end)
    inst.components.machine.turnonfn = function(inst)
        inst:work()
        if inst.event_fn == nil then
            inst.event_fn = EntUtil:listen_for_event(inst, "daytime", function(world, data)
                inst:work()
            end, GetWorld())
        end
    end
    inst.components.machine.turnofffn = function(inst)
        if inst.event_fn then
            inst:RemoveEventCallback("daytime", inst.event_fn, GetWorld())
        end
        inst.event_fn = nil
    end
    -- inst.components.machine.cooldowntime = 3
    inst.components.machine.caninteractfn = function(inst)
        return inst.components.ak_electric.current >= 120
            and not inst:HasTag("flooded")
    end

    return inst
end, AssetMaster:GetDSAssets("ak_auto_harvester"))
table.insert(prefs, auto_harvester)
table.insert(prefs, PrefabUtil:MakePlacer(auto_harvester.name,
    { scale = 2 },
    AssetMaster:GetAnimation(auto_harvester.name)))
Util:AddString(auto_harvester.name, "自动收获机",
    "电器，使用时收获周围的作物，（包括农场，渔场和晒肉架的作物）；之后会定期执行此操作")

local loader = Prefab("ak_loader", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_loader")
    local map = AssetMaster:GetMap("ak_loader")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")

    inst:AddComponent("ak_electric")
    inst.components.ak_electric:SetMax(240)
    inst.components.ak_electric.load = 120
    inst:AddTag("fridge")
    inst:AddComponent("container")
    local root_slotpos = {}
    for y = 2.5, -0.5, -1 do
        for x = 0, 2 do
            table.insert(root_slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
        end
    end
    inst.components.container:SetNumSlots(#root_slotpos, true)
    inst.components.container.widgetslotpos = root_slotpos
    inst.components.container.widgetpos = Vector3(75, 200, 0)
    inst.components.container.widgetanimbank = "ui_chester_shadow_3x4"
    inst.components.container.widgetanimbuild = "ui_chester_shadow_3x4"
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
    inst.work = function(inst, doer)
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 20)
        for k, v in pairs(ents) do
            if v.components.grower
                and v.components.grower:IsEmpty()
                and v.components.grower:IsFertile() then
                local target = inst.components.container:FindItem(function(item)
                    return string.find(item.prefab, "seed")
                end)

                target = inst.components.container:RemoveItem(target)
                if target and target.components.plantable
                    and v.components.grower.level >= target.components.plantable.minlevel then
                    if target.components.stackable then
                        target = target.components.stackable:Get()
                    end
                    v.components.grower:PlantItem(target)

                    SpawnPrefab("small_puff").Transform:SetPosition(v:GetPosition():Get())
                end
            end

            if v.components.dryer then
                local target = inst.components.container:FindItem(function(item)
                    return item.components.dryable
                end)

                if target
                    and v.components.dryer:CanDry(target) then
                    target = inst.components.container:RemoveItem(target)
                    if target.components.stackable then
                        target = target.components.stackable:Get()
                    end
                    v.components.dryer:StartDrying(target)

                    SpawnPrefab("small_puff").Transform:SetPosition(v:GetPosition():Get())
                end
            end

            if v.components.ak_tree_table
                and v.components.ak_tree_table:Test() then
                local target = inst.components.container:FindItem(function(item)
                    return item.components.deployable
                        and item:HasTag("ak_tree_seed")
                end)

                target = inst.components.container:RemoveItem(target)
                if target then
                    v.components.ak_tree_table:Plant(target, doer or inst)

                    SpawnPrefab("small_puff").Transform:SetPosition(v:GetPosition():Get())
                end
            end

            if v.components.pickable
                and not v.components.pickable.reverseseasons
                and v.components.pickable:CanBeFertilized() then
                local target = inst.components.container:FindItem(function(item)
                    return item.components.fertilizer
                        and not item.components.fertilizer.volcanic
                end)

                target = inst.components.container:RemoveItem(target)
                if target then
                    v.components.pickable:Fertilize(target)

                    SpawnPrefab("small_puff").Transform:SetPosition(v:GetPosition():Get())
                end
            end

            if v.components.pickable
                and v.components.pickable.reverseseasons
                and v.components.pickable:CanBeFertilized() then
                local target = inst.components.container:FindItem(function(item)
                    return item.components.fertilizer
                        and item.components.fertilizer.volcanic
                end)

                target = inst.components.container:RemoveItem(target)
                if target then
                    v.components.pickable:Fertilize(target)

                    SpawnPrefab("small_puff").Transform:SetPosition(v:GetPosition():Get())
                end
            end

            if v.components.grower
                and not v.components.grower:IsFertile()
                and v.components.grower:IsEmpty() then
                local target = inst.components.container:FindItem(function(item)
                    return item.components.fertilizer
                        and not item.components.fertilizer.volcanic
                end)

                target = inst.components.container:RemoveItem(target)
                if target then
                    v.components.grower:Fertilize(target)

                    SpawnPrefab("small_puff").Transform:SetPosition(v:GetPosition():Get())
                end
            end

            if v.components.hackable
                and not v.components.hackable.reverseseasons
                and v.components.hackable:CanBeFertilized() then
                local target = inst.components.container:FindItem(function(item)
                    return item.components.fertilizer
                        and not item.components.fertilizer.volcanic
                end)

                target = inst.components.container:RemoveItem(target)
                if target then
                    v.components.hackable:Fertilize(target)

                    SpawnPrefab("small_puff").Transform:SetPosition(v:GetPosition():Get())
                end
            end

            -- if v.components.ak_injectable
            -- and v.components.ak_injectable:Test()
            -- and (not v.components.growable or not v.components.growable.stages
            -- or v.components.growable.stage >= 3) then
            --     local target = inst.components.container:FindItem(function(item)
            --         return item.injector
            --     end)

            --     target = inst.components.container:RemoveItem(target)
            --     if target then
            --         v.components.wg_interable:Interact(target, v)

            --         SpawnPrefab("small_puff").Transform:SetPosition(v:GetPosition():Get())
            --     end
            -- end
        end
    end
    inst:AddComponent("machine")
    inst:ListenForEvent("turnedon", function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_on")
    end)
    inst:ListenForEvent("turnedoff", function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_off")
    end)
    inst.components.machine.turnonfn = function(inst)
        inst:work()
        if inst.event_fn == nil then
            inst.event_fn = EntUtil:listen_for_event(inst, "daytime", function(world, data)
                inst:work()
            end, GetWorld())
        end
    end
    inst.components.machine.turnofffn = function(inst)
        if inst.event_fn then
            inst:RemoveEventCallback("daytime", inst.event_fn, GetWorld())
        end
        inst.event_fn = nil
    end
    -- inst.components.machine.cooldowntime = 3
    inst.components.machine.caninteractfn = function(inst)
        return inst.components.ak_electric.current >= 120
            and not inst:HasTag("flooded")
    end

    return inst
end, AssetMaster:GetDSAssets("ak_loader"))
table.insert(prefs, loader)
table.insert(prefs, PrefabUtil:MakePlacer(loader.name,
    { scale = 2 },
    AssetMaster:GetAnimation(loader.name)))
Util:AddString(loader.name, "装载器",
    "电器，使用时将该容器内的物品进行种植（可以种树，需要植树标识），晾晒，施肥，使用注射剂。有保鲜效果；之后会定期执行此操作")

local park_sign = Prefab("ak_park_sign", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_park_sign")
    local map = AssetMaster:GetMap("ak_park_sign")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("wood_structure")
    inst:AddComponent("lootdropper")

    inst:AddComponent("ak_tree_table")

    return inst
end, AssetMaster:GetDSAssets("ak_park_sign"))
table.insert(prefs, park_sign)
table.insert(prefs, PrefabUtil:MakePlacer(park_sign.name,
    { scale = 2 },
    AssetMaster:GetAnimation(park_sign.name)))
Util:AddString(park_sign.name, "植树标识", "用于给装载器标记种树地点")

local farm_brick = Prefab("ak_farm_brick", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_farm_brick")
    local map = AssetMaster:GetMap("ak_farm_brick")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    inst.Transform:SetScale(1.5, 1.5, 1.5)
    inst:AddTag("wood_structure")
    inst:AddComponent("lootdropper")

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddComponent("grower")
    inst.components.grower.level = 3
    inst.components.grower.onplantfn = function()
        inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_seeds")
    end
    inst.components.grower.croppoints = { Vector3(0, 0, 0) }
    inst.components.grower.growrate = TUNING.FARM3_GROW_BONUS
    inst.components.grower.max_cycles_left = 90000
    inst.components.grower.cycles_left = inst.components.grower.max_cycles_left

    return inst
end, AssetMaster:GetDSAssets("ak_farm_brick"))
table.insert(prefs, farm_brick)
table.insert(prefs, PrefabUtil:MakePlacer(farm_brick.name,
    { scale = 2 },
    AssetMaster:GetAnimation(farm_brick.name)))
Util:AddString(farm_brick.name, "土培砖", "材料更简单的农场")

local fridge_slotpos = {}
for y = 4, -1, -1 do
    for x = -1, 3 do
        local pos = Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 40, 0)
        table.insert(fridge_slotpos, pos)
    end
end

local clear_station = Prefab("ak_clear_station", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_clear_station")
    local map = AssetMaster:GetMap("ak_clear_station")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")

    inst:AddComponent("ak_electric")
    inst.components.ak_electric:SetMax(480)
    inst.components.ak_electric.load = 240
    inst:AddTag("fridge")
    inst.components.ak_electric.empty = function(inst)
        inst:RemoveTag("fridge")
    end
    inst.components.ak_electric.spring = function(inst)
        inst:AddTag("fridge")
    end
    inst:AddComponent("container")
    inst.components.container:SetNumSlots(#fridge_slotpos)
    inst.components.container.widgetslotpos = fridge_slotpos
    inst.components.container.widgetbgatlas = "images/fepanels.xml"
    inst.components.container.widgetbgimage = "panel_saveslots.tex"
    inst.components.container.widgetpos = Vector3(-250, 100, 0)
    inst.components.container.hscale = 1
    inst.components.container.vscale = 1
    inst.components.container.side_align_tip = 160
    inst:AddComponent("machine")
    inst:ListenForEvent("turnedon", function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_on")
    end)
    inst:ListenForEvent("turnedoff", function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_off")
    end)
    inst.components.machine.turnonfn = function(inst)
        if inst.task == nil then
            inst.task = inst:DoPeriodicTask(2, function()
                if not inst.components.container:IsFull() then
                    local cost = nil
                    local x, y, z = inst:GetPosition():Get()
                    local ents = TheSim:FindEntities(x, y, z, 20, nil, EntUtil.constants.not_entity_tags)
                    for k, v in pairs(ents) do
                        if v and v.components.inventoryitem
                            and v.components.inventoryitem.cangoincontainer
                            and inst.components.container:Count(v.prefab) > 0 then
                            SpawnPrefab("small_puff").Transform:SetPosition(v:GetPosition():Get())
                            inst.components.container:GiveItem(v)
                            cost = true
                        end
                    end
                    if cost then
                        inst.components.ak_electric:DoDelta(-120)
                    end
                end
            end)
        end
    end
    inst.components.machine.turnofffn = function(inst)
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end
    -- inst.components.machine.cooldowntime = 3
    inst.components.machine.caninteractfn = function(inst)
        return (not inst.components.ak_electric:IsEmpty())
            and not inst:HasTag("flooded")
    end

    return inst
end, AssetMaster:GetDSAssets("ak_clear_station"))
table.insert(prefs, clear_station)
table.insert(prefs, PrefabUtil:MakePlacer(clear_station.name,
    { scale = 2 },
    AssetMaster:GetAnimation(clear_station.name)))
Util:AddString(clear_station.name, "扫扫基站",
    "电器，收集周围的地面物品，只会收集自己容器内已装有的物品；有电时有冰箱效果")

local robot_worker = Prefab("ak_robot_worker", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_robot_worker")
    local map = AssetMaster:GetMap("ak_robot_worker")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst, function(inst)
        if inst.components.machine.ison then
            inst.components.machine:TurnOff()
        end
    end)
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")

    inst:AddComponent("ak_electric")
    inst.components.ak_electric:SetMax(240)
    inst.components.ak_electric.load = 120
    inst.acts = {
        chop = true,
        mine = true,
        hack = true,
    }

    inst:AddComponent("machine")
    inst:ListenForEvent("turnedon", function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_on")
    end)
    inst:ListenForEvent("turnedoff", function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_off")
    end)
    inst.components.machine.turnonfn = function(inst)
        inst.AnimState:PlayAnimation("on")
        if inst.task == nil then
            inst.task = inst:DoPeriodicTask(3, function()
                if inst.components.ak_electric.current >= 120 then
                    local ent = FindEntity(inst, 15, function(target)
                        if inst.acts.hack and target.components.hackable
                            and target.components.hackable:CanBeHacked() then
                            return true
                        end
                        if target.components.workable == nil then
                            return
                        end
                        if inst.acts.chop
                            and target.components.workable.action == ACTIONS.CHOP then
                            if target.components.growable
                                and target.components.growable.stages
                                and target.components.growable.stage < 3 then
                                return
                            end
                            return true
                        end
                        if inst.acts.mine
                            and target.components.workable.action == ACTIONS.MINE then
                            return true
                        end
                        -- if target.components.workable.action==ACTIONS.HACK then
                        --     return true
                        -- end
                        if inst.acts.chop
                            and (target.components.workable.action == ACTIONS.DIG
                                and target:HasTag("stump")) and target:HasTag("tree") then
                            return true
                        end
                    end)
                    if ent then
                        SpawnPrefab("collapse_small").Transform:SetPosition(ent:GetPosition():Get())
                        if ent.components.hackable then
                            ent.components.hackable:Hack(inst, 15)
                        elseif ent.components.workable then
                            ent.components.workable:Destroy(inst)
                        end
                        inst.components.ak_electric:DoDelta(-120)
                    end
                end
            end)
        end
    end
    inst.components.machine.turnofffn = function(inst)
        inst.AnimState:PlayAnimation("off")
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end
    -- inst.components.machine.cooldowntime = 3
    inst.components.machine.caninteractfn = function(inst)
        return (not inst.components.ak_electric:IsEmpty())
            and not inst:HasTag("flooded")
    end
    inst.OnSave = function(inst, data)
        data.acts = inst.acts
    end
    inst.OnLoad = function(inst, data)
        if data and data.acts then
            inst.acts = data.acts
        end
    end

    return inst
end, AssetMaster:GetDSAssets("ak_robot_worker"))
table.insert(prefs, robot_worker)
table.insert(prefs, PrefabUtil:MakePlacer(robot_worker.name,
    { scale = 2 },
    AssetMaster:GetAnimation(robot_worker.name)))
Util:AddString(robot_worker.name, "机器工人", "电器，自动进行斧子，稿子，砍刀的工作")

local AkEditorScreen = require "screens.ak_editor_screen"
local transporter = Prefab("ak_transporter", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_transporter")
    local map = AssetMaster:GetMap("ak_transporter")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")

    inst:AddComponent("ak_transporter")
    inst:AddComponent("ak_editor")
    inst.components.ak_editor:SetText("text")
    inst:AddComponent("wg_useable")
    inst.components.wg_useable.right = false
    inst.components.wg_useable.use = function(inst, doer)
        TheFrontEnd:PushScreen(AkEditorScreen(inst))
    end
    inst.cost = 200
    inst:AddComponent("wg_machine")
    inst.components.wg_machine.fn = function(inst, doer)
        inst.components.ak_transporter:DoTransport()
    end
    inst.components.wg_machine.test = function(inst, doer)
        local cur = inst.components.ak_transporter:GetCenterElectric()
        if cur then
            return cur >= inst.cost
        end
    end
    inst:ListenForEvent("onbuilt", function(inst, data)
        local ent = FindEntity(inst, 9999, nil, { "ak_transport_center" })
        if ent then
            inst.components.ak_transporter:SetCenter(ent)
        end
    end)

    return inst
end, AssetMaster:GetDSAssets("ak_transporter"))
table.insert(prefs, transporter)
table.insert(prefs, PrefabUtil:MakePlacer(transporter.name,
    { scale = 2 },
    AssetMaster:GetAnimation(transporter.name)))
Util:AddString(transporter.name, "传送装置",
    "消耗电控站的电力，将玩家传送到其他传送装置处，左键修改传送装置的标识，右键进行传送")

local transport2 = Prefab("ak_transporter2", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_transporter")

    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.Transform:SetScale(2, 2, 2)
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(animation)

    inst:AddComponent("inspectable")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetMaxWork(4)
    inst.components.workable:SetOnWorkCallback(function(inst, worker)
    end)
    inst.components.workable:SetOnFinishCallback(function(inst, worker)
        SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
        inst:Remove()
    end)
    inst:AddComponent("repairable")
    inst.components.repairable.repairmaterial = "gears"
    inst.components.repairable.onrepaired = function(inst)
        SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
        local pos = inst:GetPosition()
        inst:Remove()
        local st = SpawnPrefab("ak_transporter")
        st.Transform:SetPosition(pos:Get())
        st:PushEvent("onbuilt")
    end
    inst:DoPeriodicTask(5, function()
        local fx = FxManager:MakeFx("shock_machines_fx", inst)
        -- inst:AddChild(fx)
    end)

    return inst
end)
table.insert(prefs, transport2)
Util:AddString(transport2.name, "损坏的传送装置",
    "给予齿轮进行修复")

local transport_center = Prefab("ak_transport_center", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_transport_center")
    local map = AssetMaster:GetMap("ak_transport_center")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")

    inst:AddTag("ak_transport_center")
    inst:AddComponent("ak_electric")
    inst.components.ak_electric:SetMax(2000)
    inst.components.ak_electric.load = 480
    inst.init = function(inst)
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 9999, { "ak_transporter" })
        for k, v in pairs(ents) do
            v.components.ak_transporter:SetCenter(inst)
        end
    end
    inst:DoTaskInTime(0, function()
        inst:init()
    end)

    return inst
end, AssetMaster:GetDSAssets("ak_transport_center"))
table.insert(prefs, transport_center)
table.insert(prefs, PrefabUtil:MakePlacer(transport_center.name,
    { scale = 2 },
    AssetMaster:GetAnimation(transport_center.name)))
Util:AddString(transport_center.name, "电控站", "为传送装置供给电力，建造多个无意义")

-- local level_eraser = Prefab("ak_level_eraser", function()
--     local bank, build, animation = AssetMaster:GetAnimation("ak_level_eraser")
--     local map = AssetMaster:GetMap("ak_level_eraser")
--     local inst = PrefabUtil:MakeStructure(
--         bank, build, animation, map
--     )
--     inst.Transform:SetScale(2, 2, 2)
--     inst:AddTag("metal_structure")
--     inst:AddComponent("lootdropper")

--     inst:AddComponent("ak_electric")
--     inst.components.ak_electric:SetMax(1000)
--     local load = 120
--     inst.components.ak_electric.load = load

--     local slotpos = {}
--     for y = 2, 0, -1 do
--         for x = 0, 2 do
--             table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80, 0))
--         end
--     end
--     inst:AddComponent("container")
--     inst.components.container:SetNumSlots(#slotpos)
--     inst.components.container.widgetslotpos = slotpos
--     inst.components.container.widgetanimbank = "ui_chest_3x3"
--     inst.components.container.widgetanimbuild = "ui_chest_3x3"
--     inst.components.container.widgetpos = Vector3(0, 200, 0)
--     inst.components.container.side_align_tip = 160
--     inst:ListenForEvent("onopen", function(inst, data)
--         if inst.SoundEmitter then
--             inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
--         end
--     end)
--     inst:ListenForEvent("onclose", function(inst, data)
--         if inst.SoundEmitter then
--             inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
--         end
--     end)
--     inst.components.container.widgetpos = Vector3(200,0,0)
--     inst.components.container.side_align_tip = 100
--     inst.components.container.widgetbuttoninfo = {
--         text = STRINGS.WG_SURE,
--         position = Vector3(0, -165, 0),
--         fn = function(inst)
--             inst.AnimState:PlayAnimation("working_pre")
--             inst.AnimState:PushAnimation("working_loop", false)
--             inst.AnimState:PushAnimation("working_pst", false)
--             inst.AnimState:PushAnimation("off", false)
--             inst.components.container:Close()
--             inst.components.container.canbeopened = false
--             inst:work()
--         end,
--         validfn = function(inst)
--             local equip = inst.components.container:FindItem(function(item)
--                 return item.components.tp_enchantmentable
--                     -- and item.components.tp_enchantmentable:Test()
--             end)
--             -- local medium = inst.components.container:FindItem(function(item)
--             --     return item:HasTag("enchantment_medium")
--             --         -- and item.quality and item.ids
--             -- end)
--             local medium_num = inst.components.container:Count("tp_alloy_enchant")
--             if (equip and medium_num==1) or medium_num>=2 then
--                 return inst.components.ak_electric.current>=load
--                     and not inst:HasTag("flooded")
--             end
--         end,
--     }
--     inst.work = function(inst)
--         inst.components.ak_electric:DoDelta(-load)
--         local equip = inst.components.container:FindItem(function(item)
--             return item.components.tp_enchantmentable
--                 -- and item.components.tp_enchantmentable:Test()
--         end)
--         if equip then
--             -- 装备存在
--             local medium = inst.components.container:FindItem(function(item)
--                 return item:HasTag("enchantment_medium")
--                     -- and item.quality and item.ids
--             end)
--             local cmp = equip.components.tp_enchantmentable
--             -- 装备和石头有的转给没有的一方，原来有的那个消失
--             if cmp.ids and medium.ids == nil then
--                 medium.ids = cmp.ids
--                 medium.quality = cmp.quality
--                 cmp.inst:Remove()
--             end
--             if cmp.ids == nil and medium.ids then
--                 cmp:Enchantment(medium)
--                 medium:Remove()
--             end
--         else
--             -- 装备不存在，有多个石头，将所有石头合成一个石头
--             -- 词条添加在一起（最多5个），品质取最高
--             local items = inst.components.container:FindItems(function(item)
--                 return item:HasTag("enchantment_medium")
--             end)
--             local medium = SpawnPrefab("tp_alloy_enchant")
--             medium.ids = {}
--             medium.quality = 1
--             for k, v in pairs(items) do
--                 if v.ids then
--                     for k2, v2 in pairs(v.ids) do
--                         table.insert(medium.ids, v2)
--                     end
--                 end
--                 if v.quality and v.quality>medium.quality then
--                     medium.quality = v.quality
--                 end
--                 v:Remove()
--             end
--             while #medium.ids>5 do
--                 table.remove(medium.ids, #medium.ids)
--             end
--             inst.components.container:GiveItem(medium)
--         end
--     end
--     inst:ListenForEvent("animover", function(inst, data)
--         if inst.AnimState:IsCurrentAnimation("working_pst") then
--             inst.components.container.canbeopened = true
--         end
--     end)

--     return inst
-- end, AssetMaster:GetDSAssets("ak_level_eraser"))
-- table.insert(prefs, level_eraser)
-- table.insert(prefs, PrefabUtil:MakePlacer(level_eraser.name,
-- {scale=2},
-- AssetMaster:GetAnimation(level_eraser.name)))
-- local level_eraser_str = ""
-- for k, v in pairs({
--     "放入一个可附魔的装备和一个魔法合金,",
--     "如果装备没有附魔,魔法合金拥有附魔词条,装备会获得魔法合金的附魔词条,魔法合金会消失;",
--     "如果装备有附魔词条,魔法合金没有,魔法合金会获得装备的附魔词条,装备会消失",
--     "也可以不放入装备,而是放入多个魔法合金,他们会融合成一个魔法合金,",
--     "拥有所有融合的魔法合金的附魔词条(最多5个),并获得它们之中最高的品质",
-- }) do
--     level_eraser_str = level_eraser_str..v
-- end
-- Util:AddString(level_eraser.name, "附魔台", level_eraser_str)

local TpLevelScreen = require "screens/tp_level_screen"
local level_eraser = Prefab("ak_level_eraser", function()
    local bank, build, animation = AssetMaster:GetAnimation("ak_level_eraser")
    local map = AssetMaster:GetMap("ak_level_eraser")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, map
    )
    inst.Transform:SetScale(2, 2, 2)
    inst:AddTag("metal_structure")
    inst:AddComponent("lootdropper")

    inst:AddComponent("ak_electric")
    inst.components.ak_electric:SetMax(1000)
    local load = 240
    inst.components.ak_electric.load = load

    inst:AddComponent("wg_useable")
    inst.components.wg_useable.test = function(inst, doer)
        return (not inst:HasTag("flooded"))
            and inst.components.ak_electric.current >= load
    end
    inst.components.wg_useable.use = function(inst, doer)
        local data = Sample.LevelAttrSystem
        data:Init(doer, inst)
        TheFrontEnd:PushScreen(TpLevelScreen(data, doer))
    end

    return inst
end, AssetMaster:GetDSAssets("ak_level_eraser"))
table.insert(prefs, level_eraser)
table.insert(prefs, PrefabUtil:MakePlacer(level_eraser.name,
    { scale = 2 },
    AssetMaster:GetAnimation(level_eraser.name)))
Util:AddString(level_eraser.name, "升级中心", "可以为人物进行升级")

local wilson_table = Prefab("tp_wilson_table", function()
    local bank, build, animation = AssetMaster:GetAnimation("tp_wilson_table")
    local map = AssetMaster:GetMap("tp_wilson_table")
    local inst = PrefabUtil:MakeWorkbench(
        bank, build, animation, map
    )
    MakeBurnable(inst)
    MakeFloodable(inst)
    inst.Transform:SetScale(2, 2, 2)
    inst.recipe_book = WorkbenchRecipes:GetRecipeShelf("ak_work_bench")
    inst.components.workable:SetOnWorkCallback(function(inst, worker)
    end)

    inst.components.wg_workbench.consume_test = function(inst)
        return (not inst:HasTag("flooded"))
    end
    inst.components.wg_workbench.consume_fn = function(inst)
    end
    inst.components.wg_workbench.test = function(inst)
        return (not inst:HasTag("flooded"))
    end

    return inst
end, AssetMaster:GetDSAssets("tp_wilson_table"))
table.insert(prefs, wilson_table)
table.insert(prefs, PrefabUtil:MakePlacer(wilson_table.name,
    { scale = 2 },
    AssetMaster:GetAnimation(wilson_table.name)))
Util:AddString(wilson_table.name, "工作台", "制作物品")

return unpack(prefs)
