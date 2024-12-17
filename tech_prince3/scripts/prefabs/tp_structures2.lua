local Util = require "extension.lib.wg_util"
local PrefabUtil = require "extension/lib/prefab_util"
local AssetMaster = Sample.AssetMaster
local WorkbenchRecipes = Sample.WorkbenchRecipes
local FxManager = Sample.FxManager
local WgComposBook = require "extension/uis/wg_cook_book"
local Kit = require "extension.lib.wargon"
local EntUtil = require "extension.lib.ent_util"

local prefs = {}

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
            self.fxdata = { x = 0, y = 0, z = 0, level=self:GetDefaultFXLevel() }
        end
        if self.fxdata then
            for k,v in pairs(self.fxdata) do
                local fx = SpawnPrefab(v.prefab)
                if fx then

                    if v.follow then
                        local follower = fx.entity:AddFollower()
                        follower:FollowSymbol( self.inst.GUID, v.follow, v.x,v.y,v.z)
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

local chest = Prefab("tp_chest", function()
    local bank, build, animation = AssetMaster:GetAnimation("tp_chest")
    -- local map = AssetMaster:GetMap("tp_chest")
    local inst = PrefabUtil:MakeStructure(
        bank, build, animation, nil
    )
    RemovePhysicsColliders(inst)
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
    -- inst.components.container.itemtestfn = function(inst, item, slot) end
    inst.components.container.type = "chest"
    inst:AddComponent("wg_start")
    inst.components.wg_start:AddFn(function(inst)
        
    end)
    
    return inst
end, AssetMaster:GetDSAssets("tp_chest"))
table.insert(prefs, chest)
Util:AddString(chest.name, "宝箱", "里面有什么好东西呢?")

local cookpot_demon = Prefab("tp_cookpot_demon", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    
    local light = inst.entity:AddLight()
    inst.Light:Enable(true)
	inst.Light:SetRadius(.6)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235/255,62/255,12/255)
    
    inst.Transform:SetScale(1.5,1.5,1.5)
    
    local bank, build, animation = AssetMaster:GetAnimation("tp_cookpot_demon")
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("cooking_loop")
    inst:DoTaskInTime(1, function()    
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
    end)
    inst.onbuilt = function(inst)
        -- inst.SoundEmitter:KillSound("snd")
        inst.AnimState:PlayAnimation("place")
        inst.AnimState:PushAnimation("cooking_loop")
        inst.SoundEmitter:PlaySound("dontstarve/common/craftable/cook_pot")
        -- inst:DoTaskInTime(1, function()
        --     inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
        -- end)
    end

    inst:AddComponent("inspectable")

    inst.enemies = {}
    inst.task = inst:DoPeriodicTask(.3, function()
        if inst.owner and inst.owner.components.tp_val_mana then
            inst.owner.components.tp_val_mana:DoDelta(-5)
            if inst.owner.components.tp_val_mana:IsEmpty() then
                FxManager:MakeFx("collapse_big", inst)
                inst:Remove()
            end
        end
        local ent = FindEntity(inst, 20, function(target, inst)
            if EntUtil:check_combat_target(inst.owner, target) then
                return not inst.enemies[target]
            end
        end, nil, EntUtil.not_enemy_tags)
        if ent then
            inst.enemies[ent] = true
            local proj = SpawnPrefab("tp_cookpot_demon_proj")
            proj.Transform:SetPosition(inst:GetPosition():Get())
            proj.components.wg_projectile:Throw(inst.owner, ent, inst.owner)
            proj.owner = inst.owner
            local dist = inst:GetPosition():Dist(ent:GetPosition())
            proj.components.wg_projectile:SetSpeed(dist/.3)
        else
            inst.enemies = {}
        end
    end)

    inst.OnSave = function(inst, data)
        if inst.owner then
            data.onwer = inst.owner.GUID
        end
    end
    inst.OnLoadPostPass = function(inst, newents, savedata)
        if savedata and savedata.owner then
            local owner = newents[savedata.owner]
            if owner then
                inst.owner = owner
            end
        end
    end
    
    return inst
end, AssetMaster:GetDSAssets("tp_cookpot_demon"))
table.insert(prefs, cookpot_demon)
Util:AddString(cookpot_demon.name, "伏魔御厨锅", "不断斩击周围的敌人并为你回复生命值和饥饿值")

local cookpot_demon_proj = Prefab("tp_cookpot_demon_proj", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst.Transform:SetFourFaced()
    inst.entity:AddSoundEmitter()
    local anim = inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("tp_invisible_man")
    -- inst.AnimState:SetBuild("wilson")
    inst.AnimState:OverrideSymbol("swap_object", "swap_machete", "swap_machete")
    inst.AnimState:PlayAnimation("chop_pre")
    inst.AnimState:PushAnimation("chop_loop", true)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(100)
    inst.components.weapon.dmg_type = "slash"

    inst:AddComponent("wg_projectile")
    inst.components.wg_projectile:SetSpeed(25)
    inst.components.wg_projectile:SetOnThrownFn(function(inst, owner, target) 
    end)
    inst.components.wg_projectile:SetOnMissFn(function(inst, owner, target) 
        inst:Remove()
    end)
    inst.components.wg_projectile:SetOnHitFn(function(inst, owner, target)
        owner.components.health:DoDelta(inst.components.weapon.damage*.33)
        if owner.components.hunger then
            owner.components.hunger:DoDelta(inst.components.weapon.damage*.33)
        end
        inst.components.wg_projectile.onmiss(inst, owner, target)
    end)
    inst.components.wg_projectile:SetHoming(true)
    inst.components.wg_projectile:SetLaunchOffset(Vector3(0, 0.2, 0))
    inst.components.wg_projectile.test = function(inst, target, doer)
        return true
    end
    inst.components.wg_projectile:SetOnCaughtFn(function(inst, catcher)
    end)

    return inst
end)
table.insert(prefs, cookpot_demon_proj)

local powder_keg = Prefab("tp_powder_keg", function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    -- trans:SetFourFaced()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    -- phy
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(100)
    inst.components.health:SetMinHealth(1)
    inst:AddComponent("combat")
    inst:AddComponent("inspectable")
    inst.components.combat:AddAttackedCalcFn(function(damage, attacker, owner, weapon, stimuli)
        if attacker and EntUtil:in_stimuli(stimuli, "fire") then
            inst:DoTaskInTime(.1, function()
                if EntUtil:is_alive(attacker) then
                    FxManager:MakeFx("explodering_fx", inst)
                    EntUtil:make_area_dmg(inst, 4, attacker, 50, nil, 
                        EntUtil:add_stimuli(nil, "fire", "pure")
                    )
                    inst:Remove()
                end
            end)
        end
    end)
    inst:ListenForEvent("minhealth", function(inst, data)
        inst:DoTaskInTime(.2, function()
            FxManager:MakeFx("collapse_small", inst)
            inst:Remove()
        end)
    end)
    
    return inst
end)
table.insert(prefs, powder_keg)
Util:AddString(powder_keg.name, "火药桶", "受到火焰伤害会爆炸")

return unpack(prefs)