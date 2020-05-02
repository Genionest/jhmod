local function onattacked(inst, data)
    if inst:HasTag("monkey_king_charged") then
        if data.attacker.components.health then
            if (data.weapon == nil or (not data.weapon:HasTag("projectile") and data.weapon.projectile == nil)) 
            and (data.attacker ~= GetPlayer() or (data.attacker == GetPlayer() and not GetPlayer().components.inventory:IsInsulated())) then
                data.attacker.components.health:DoDelta(-10)
                -- if data.attacker == GetPlayer() then
                --     data.attacker.sg:GoToState("electrocute")
                -- end
            end
        end
    end

end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("")
    inst.AnimState:SetBuild("")
    inst.AnimState:PlayAnimation('')

    local light = inst.entity:AddLight()
    inst.Light:Enable(true)
    inst.Light:SetRadius(.85)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(255/255,255/255,236/255)

    inst.persists = false
    inst:AddTag('FX')
    inst:AddTag('NOCLICK')

    inst:DoTaskInTime(30*8, function()
        inst:killfx(inst)
    end)
    inst.killfx = function(inst)
        if inst.master then
            if inst.master.components.morph:GetCurrent() == "goat" then
                inst.master.sg:GoToState("discharge")
            else
                inst.master:RemoveTag("monkey_king_charged")
                inst.master.AnimState:ClearBloomEffectHandle()
            end
        end
        inst.master:RemoveEventCallback("attacked", onattacked)
        inst:Remove()
    end
    inst.onattacked = onattacked
    -- inst.master:ListenForEvent("attacked", onattacked)

    return inst
end

return Prefab("common/mk_charged_light", fn, {})