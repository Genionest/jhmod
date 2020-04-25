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
    	inst:Remove()
    end)

    return inst
end

return Prefab("common/mk_morph_fx", fn, {})