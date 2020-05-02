local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	anim:SetBank("wilson")
	anim:SetBuild("monkey_king")
    anim:PlayAnimation("staff")
    anim:OverrideSymbol("swap_object", "mk_jgb", "swap_mk_jgb")
    inst.persists = false
    inst:AddTag('FX')
    inst:AddTag('NOCLICK')
    
    inst:DoTaskInTime(0, function()
        inst.stafffx = SpawnPrefab("staffcastfx")
        local pos = inst:GetPosition()
        inst.stafffx.Transform:SetPosition(pos.x, pos.y, pos.z)
        inst.stafffx.Transform:SetRotation(inst.Transform:GetRotation())
        inst.stafffx.AnimState:SetMultColour(.5, 0, 0, 1)
        inst.stafflight = SpawnPrefab("staff_castinglight")
        local pos = inst:GetPosition()
        local colour = {.5,0,0}
        inst.stafflight.Transform:SetPosition(pos.x, pos.y, pos.z)
        inst.stafflight.setupfn(inst.stafflight, colour, 1.9, .33)
    end)
    
    inst:DoTaskInTime(1, function()
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_gemstaff")
    end)

    inst:ListenForEvent("animover", function()
        local pos = inst:GetPosition()
        SpawnPrefab("collapse_small").Transform:SetPosition(pos:Get())
        inst.stafffx:Remove()
        if inst.morph_body and inst.monkeyking then
            if inst.morph_body == "monkey" then
                -- GetPlayer().components.morph:UnMorph()
                inst.monkeyking.components.morph:UnMorph()
            else
                -- GetPlayer().components.morph:Morph(inst.morph_body)
                inst.monkeyking.components.morph:Morph(inst.morph_body)
            end
            -- GetPlayer().components.mkskillmanager:Turn(true)
            inst.monkeyking.components.mkskillmanager:Turn(true)
        end
        if inst.cloud then
            for k in pairs(inst.cloud.clouds) do
                if k:IsValid() then
                    k.entity:SetParent(nil)
                    k:Remove()
                end
            end
        end
        inst:Remove()
    end)

    return inst
end

local function create_clouds(inst)
    local offsets = { Vector3(0, 0, 0),}
    for i = 1,6 do
        table.insert(offsets,Vector3(math.cos(i*6.283/6),0,math.sin(i*6.283/6)))
    end
    for k,v in pairs(offsets)do
        local fx = SpawnPrefab('mk_cloud_child')
        local s = math.mod(k,2) == 0 and 1 or .8
        fx.AnimState:SetTime(2*math.random())
        fx.AnimState:SetFinalOffset(-3)
        fx.AnimState:SetDeltaTimeMultiplier(GetRandomMinMax(.9,1.1))
        fx.Transform:SetPosition((v*0.7):Get())
        fx.Transform:SetScale(s,s,s)
        fx.entity:SetParent(inst.entity)
        fx:ScaleFn(nil,nil,1.1)

        fx.cloud = inst
        inst.clouds[fx] = true
    end
end

local function fn2()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("mk_cloudfx")
    inst.AnimState:SetBuild("mk_cloudfx")
    inst.AnimState:PlayAnimation('anim_loop', true)

    inst.AnimState:SetMultColour(0,0,0,0)
    inst.AnimState:SetFinalOffset(1)

    inst.Transform:SetScale(.5,.5,.5)

    inst.persists = false
    inst:AddTag('FX')
    inst:AddTag('NOCLICK')
    inst.clouds = {}
    create_clouds(inst)

    return inst
end

return Prefab("common/mk_morph_fx", fn, {}),
    Prefab("common/mk_morph_fx2", fn2, {})