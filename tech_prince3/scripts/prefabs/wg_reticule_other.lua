local function MakeReticule(name, bank, build, animation)
    local assets =
    {
    }

    local function fn()
        local inst = CreateEntity()

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(animation)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
        -- inst.AnimState:SetScale(SCALE, SCALE)

        inst.UpdatePosition = function(inst)
            inst.Transform:SetPosition(TheInput:GetWorldPosition():Get())
        end

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeReticule("wg_reticule_range", "firefighter_placement", "firefighter_placement", "idle")