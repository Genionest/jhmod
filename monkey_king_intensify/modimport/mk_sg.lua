local function addMagicFx(inst)
	inst.mk_do_magic = function(inst)
	-- 	inst.components.playercontroller:Enable(false)
	-- 	inst.AnimState:PlayAnimation("staff")
	-- 	stafffx = SpawnPrefab("staffcastfx")
 --    	local pos = inst:GetPosition()
 --    	-- local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	-- 	stafffx.Transform:SetPosition(pos.x, pos.y, pos.z)
 --    	-- local colour = colourizefx(staff)
 --    	stafffx.Transform:SetRotation(inst.Transform:GetRotation())
 --    	stafffx.AnimState:SetMultColour(.5, 0, 0, 1)
 --    	inst:DoTaskInTime(1.5, function()
 --    		inst.components.playercontroller:Enable(true)
 --    	end)
		inst.sg:GoToState("mk_do_magic")
	end
end

local magic_state = State{
	name = "mk_do_magic",
        tags = {"doing", "busy", "canrotate", "spell"},

        onenter = function(inst)
            inst.components.playercontroller:Enable(false)
            inst.AnimState:PlayAnimation("staff") 
            inst.components.locomotor:Stop()
            inst.components.mkskillfx:StaffFx()
            -- inst.stafffx2 = SpawnPrefab("staffcastfx")           
            -- local pos = inst:GetPosition()
            -- inst.stafffx2.Transform:SetPosition(pos.x, pos.y, pos.z)
            -- inst.stafffx2.Transform:SetRotation(inst.Transform:GetRotation())
            -- inst.stafffx2.AnimState:SetMultColour(.5, 0, 0, 1)
        end,

        onexit = function(inst)
            inst.components.playercontroller:Enable(true)
            if inst.stafffx2 then
                inst.stafffx2:Remove()
            end
            inst.components.mkskillmanager:Turn(true)
        end,

        timeline = 
        {
            TimeEvent(13*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_gemstaff") 
            end),
            TimeEvent(0*FRAMES, function(inst)
                inst.components.mkskillfx:StaffLight()
                -- inst.stafflight2 = SpawnPrefab("staff_castinglight")
                -- local pos = inst:GetPosition()
                -- local colour = {.5,0,0}
                -- inst.stafflight2.Transform:SetPosition(pos.x, pos.y, pos.z)
                -- inst.stafflight2.setupfn(inst.stafflight2, colour, 1.9, .33)                
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
}

local function fix_idle(sg)
    local old_fn = sg.states["idle"].onenter
    sg.states["idle"].onenter = function(inst, ...)
        if inst.prefab == "monkey_king"
        and inst.components.mkskillmanager then
            inst.components.mkskillmanager:Turn(true)
        end
        old_fn(inst, ...)
    end
end
-- AddPrefabPostInit("monkey_king", addMagicFx)
AddStategraphState("wilson", magic_state)
AddStategraphState("wilsonboating", magic_state)
AddStategraphPostInit("wilson", fix_idle)