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

return unpack(prefs)