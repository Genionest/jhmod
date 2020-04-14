local function pigking_game()
	local pigking = c_find("pigking")
	if pigking then
		local inst = pigking
		inst.AnimState:PlayAnimation("cointoss")
	    inst.AnimState:PushAnimation("happy")
	    inst.AnimState:PushAnimation("idle", true)
	    inst:DoTaskInTime(20/30, function() 
	        inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingThrowGold")
	        
	        for k = 1, 10 do
	    		local nug = SpawnPrefab("goldnugget")
	           	local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,4.5,0)
	            
	            nug.Transform:SetPosition(pt:Get())
	            local down = TheCamera:GetDownVec()
	            local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
	            --local angle = (-TUNING.CAM_ROT-90 + math.random()*60-30)/180*PI
	            local sp = math.random()*4+2
	            nug.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
	        end
	    end)
	    inst:DoTaskInTime(.5, function() 
	        inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingHappy")
	        local pt = inst:GetPosition()
	        local ds = .5+math.random(2, 3)
	        if math.random() < .5 then
	        	ds = -ds
	        end
	        SpawnPrefab("collapse_small").Transform:SetPosition(pt.x+ds, 0, pt.z+ds)
	        local pig1 = SpawnPrefab("pigking_gamer_1")
	        pig1.Transform:SetPosition(pt.x+ds, 0, pt.z+ds)
	        SpawnPrefab("collapse_small").Transform:SetPosition(pt.x-ds, 0, pt.z+ds)
	        local pig2 = SpawnPrefab("pigking_gamer_2")
	        pig2.Transform:SetPosition(pt.x-ds, 0, pt.z+ds)
	        SpawnPrefab("collapse_small").Transform:SetPosition(pt.x-ds, 0, pt.z-ds)
	        local pig3 = SpawnPrefab("pigking_gamer_3")
	        pig3.Transform:SetPosition(pt.x-ds, 0, pt.z-ds)
	    end)
	    inst.happy = true
	    if inst.endhappytask then
	        inst.endhappytask:Cancel()
	    end
	    inst.endhappytask = inst:DoTaskInTime(5, function()
	        inst.happy = false
	        inst.endhappytask = nil
	    end)
	end
end

return pigking_game