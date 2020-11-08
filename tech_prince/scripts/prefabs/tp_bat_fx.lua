local easing = require("easing")

local assets_bats =
{
    -- Asset("ANIM", "anim/bat_tree_fx.zip"),
    --Asset("PKGREF", "anim/dynamic/batbat_scythe.dyn"),
}
local function DoFlutterSound(inst, intensity)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/flap", nil, easing.outQuad(intensity, 0, 1, 1))
    if intensity > .2 then
        inst:DoTaskInTime(math.random(9, 10) * FRAMES, DoFlutterSound, intensity - .2)
    end
end

local function PlayBatFX(proxy)
    if proxy.variation > 0 then
        local inst = CreateEntity()

        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()

        inst.Transform:SetPosition(proxy.Transform:GetWorldPosition())

        inst.AnimState:SetBank("batbat_scythe")
        inst.AnimState:SetBuild("bat_tree_fx")
        inst.AnimState:PlayAnimation("bat"..tostring(proxy.variation))

        DoFlutterSound(inst, 1)

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")

        inst:ListenForEvent("animover", inst.Remove)
    end
end

local function OnBatFXSpawned(inst, parent)
    if parent ~= nil then
        if parent._batfxvariations == nil then
            parent._batfxvariations = {}
            local choices = { 1, 2, 3, 4 }
            while #choices > 0 do
                table.insert(parent._batfxvariations, table.remove(choices, math.random(#choices)))
            end
        end
        inst.variation = (table.remove(parent._batfxvariations, math.max(1, math.random(0, 2))))
        table.insert(parent._batfxvariations, inst.variation)
    else
        inst.variation = math.random(4)
    end
end

local function batsfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("nointerpolate")

    inst.variation = math.random(7)
	--inst.variation =
    inst:DoTaskInTime(0, PlayBatFX)
    inst:DoTaskInTime(.5, inst.Remove)
    inst.persists = false
    inst.OnBatFXSpawned = OnBatFXSpawned
    return inst
end

return 
    Prefab("tp_bat_fx", batsfn, assets_bats)
