local function kill_fx(inst)
    inst.AnimState:PlayAnimation("close")
    inst:DoTaskInTime(0.6, function() inst:Remove() end)    
end

local function MakeField(name, nature)
	local function fn()
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
	    local anim = inst.entity:AddAnimState()
	    local sound = inst.entity:AddSoundEmitter()

	    anim:SetBank(name)
	    anim:SetBuild(name)
	    anim:PlayAnimation("open")
	    anim:PushAnimation("idle_loop", true)

	    inst.persists = false
	    -- inst:AddComponent("natureforbid")
	    inst.kill_fx = kill_fx
	    -- inst:DoTaskInTime(30, function()
	    -- 	if inst.owner then
		   --  	inst.owner:RemoveTag("monkey_king_"..nature.."f")
		   --  end
	    -- 	inst:Remove()
	    -- end)

	    return inst
	end

	return Prefab( "common/"..name, fn, {}) 
end

return MakeField("coolfield", "fire"),
	MakeField("warmfield", "cold")