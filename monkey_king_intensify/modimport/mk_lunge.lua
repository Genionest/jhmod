-- 突刺修改
local function changeMkLunge(sg)
	if not sg.states["mk_lunge"] then  -- nil警告
		return
	end
	local old_fn = sg.states["mk_lunge"].onenter
	sg.states["mk_lunge"].onenter = function(inst)
		if MK_INTENSIFY_CONSTANT.other_skill then
			local buffaction = inst:GetBufferedAction()
		    local weapon = inst.components.combat:GetWeapon()
		    if not (buffaction and weapon and weapon.DoLunge) then
		        inst.sg:GoToState('idle')
		    else
		        if inst.components.monkeymana and inst.prefab == 'monkey_king' then
		            if inst:HasTag('skill_boost_mk') then
		                local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		                if hat and hat.prefab == 'golden_hat_mk' then
		                    -- hat.components.fueled:DoDelta(-24)
		              --       if inst.components.monkeymana:GetCurrent() >= 20 then
				            --     inst.components.monkeymana:DoDelta(-20, true)
				            -- else
				            -- 	inst.components.hunger:DoDelta(-20)
				            -- end
				            if not inst.components.monkeymana:EnoughMana(20) then
				            	inst.components.hunger:DoDelta(-20)
				            end
		                end
		            else
		            	-- if inst.components.monkeymana:GetCurrent() >= 40 then
			            --     inst.components.monkeymana:DoDelta(-40)
			            -- else
			            -- 	inst.components.hunger:DoDelta(-40)
			            -- end
			            if not inst.components.monkeymana:EnoughMana(40) then
			            	inst.components.hunger:DoDelta(-40)
			            end
		            end
		        end
		        weapon.components.myth_rechargeable:StartRecharging()
		        inst.AnimState:PlayAnimation("lunge_pst")
		        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
		        --inst.SoundEmitter:PlaySound("monkey_sound/monkey_sound/fireball") --这个
		        inst.Physics:SetMotorVelOverride(30,0,0)
		        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
		        inst.components.bloomer:PushBloom("lunge", "shaders/anim.ksh", -2)
		        inst.components.colouradder:PushColour("lunge", 1, 1, 0, 0)
		        inst.sg.statemem.flash = 1

		        local targetpos = buffaction.pos

		        local pos = inst:GetPosition()
		        if pos.x ~= targetpos.x or pos.z ~= targetpos.z then
		            inst:ForceFacePoint(targetpos:Get())
		        end
				local angle = (inst.Transform:GetRotation() + 90) * DEGREES  
				local step = .75
				local offset = 0.25
				local dist = (10 + .5) * step + offset				
		        weapon:DoLunge(inst, pos, targetpos)

		        inst:PerformBufferedAction()
		    end
		else
			old_fn(inst)
		end
	end
end

AddStategraphPostInit("wilson", changeMkLunge)