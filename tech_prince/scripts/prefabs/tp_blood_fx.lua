local TINT = { r = 154 / 255, g = 23 / 255, b = 19 / 255 }

local function OnUpdateTargetTint(inst)--, dt)
    if inst._tinttarget:IsValid() then
        local curframe = (inst.AnimState:GetCurrentAnimationLength()*inst.AnimState:GetPercent()) / FRAMES
        if curframe < 10 then
            local k = curframe / 10 * .5
            if inst._tinttarget.components.colouradder ~= nil then
                inst._tinttarget.components.colouradder:PushColour(inst, TINT.r * k, TINT.g * k, TINT.b * k, 0)
            end
        elseif curframe < 40 then
            local k = (curframe - 10) / 30
            k = (1 - k * k) * .5
            if inst._tinttarget.components.colouradder ~= nil then
                inst._tinttarget.components.colouradder:PushColour(inst, TINT.r * k, TINT.g * k, TINT.b * k, 0)
            end
        else
            inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateTargetTint)
            if inst._tinttarget.components.colouradder ~= nil then
                inst._tinttarget.components.colouradder:PopColour(inst)
            end
        end
    else
        inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateTargetTint)
    end
end

local function Setup(inst, target)
    if inst.components.updatelooper == nil then
        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateTargetTint)
        inst._tinttarget = target
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("wortox_soul_heal_fx")
    inst.AnimState:SetBuild("wortox_soul_heal_fx")
    inst.AnimState:PlayAnimation("heal")
    inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:SetScale((-1)^math.random(2)*1.5, 1.5)
    inst.AnimState:SetDeltaTimeMultiplier(2)

    inst:AddTag("FX")

    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false
    inst.Setup = Setup

    return inst
end

return Prefab("tp_blood_fx", fn, {})
