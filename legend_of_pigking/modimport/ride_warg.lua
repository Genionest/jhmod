AddPrefabPostInit("wilson", function(inst)
	inst:AddComponent("wargrider")
end)

-- AddComponentPostInit("rider", function(cmt)
-- 	local old_fn = cmt:Mount()
-- end)

AddStategraphPostInit("wilson", function(sg)
	old_fn = sg.states["idle"].onenter
	sg.states["idle"].onenter = function(inst, pushanim)
		old_fn(inst, pushanim)
		if not inst.wantstosneeze 
		and not inst.toolwantstobreak then
			if inst.components.wargrider 
			and inst.components.wargrider:IsRiding() then
				inst.sg:GoToState("wargride_idle", pushanim)
				local mount = inst.components.wargrider:GetMount()
				if mount then
					inst.components.wargrider:PlayAllMountAnim("idle_loop")
					inst.components.wargrider:SetAllMountRotation()
				end
				return
			end
		end
	end
	old_fn2 = sg.states["run_start"].onenter
	sg.states["run_start"].onenter = function(inst)
		old_fn2(inst)
		if inst.components.wargrider
		and inst.components.wargrider:IsRiding() then
			local mount = inst.components.wargrider:GetMount()
			if mount then
				inst.components.wargrider:PlayAllMountAnim("run_pre")
				inst.components.wargrider:SetAllMountRotation()
			end
		end
	end
	old_fn3 = sg.states["run"].onenter
	sg.states["run"].onenter = function(inst)
		old_fn3(inst)
		if inst.components.wargrider
		and inst.components.wargrider:IsRiding() then
			local mount = inst.components.wargrider:GetMount()
			if mount then
				-- mount.AnimState:PlayAnimation("run_loop")
				-- local rot = inst.Transform:GetRotation()
				-- mount.Transform:SetRotation(rot)
				inst.components.wargrider:PlayAllMountAnim("run_loop")
				inst.components.wargrider:SetAllMountRotation()
			end
		end
	end
	old_fn4 = sg.states["run_stop"].onenter
	sg.states["run_stop"].onenter = function(inst)
		old_fn4(inst)
		if inst.components.wargrider
		and inst.components.wargrider:IsRiding() then
			local mount = inst.components.wargrider:GetMount()
			if mount then
				-- mount.AnimState:PlayAnimation("run_pst")
				-- local rot = inst.Transform:GetRotation()
				-- mount.Transform:SetRotation(rot)
				inst.components.wargrider:PlayAllMountAnim("run_pst")
				inst.components.wargrider:SetAllMountRotation()
			end
		end
	end
	old_fn5 = sg.states["attack"].onenter
	sg.states["attack"].onenter = function(inst)
		old_fn5(inst)
		if inst.components.wargrider
		and inst.components.wargrider:IsRiding() then
        	local cooldown = 13
        	if weapon and (weapon.components.weapon.projectile or weapon:HasTag("rangedweapon")) then
        	    inst.AnimState:PlayAnimation("player_atk_pre")
        	    inst.AnimState:PushAnimation("player_atk", false)
        	    cooldown = math.max(cooldown, 13 * FRAMES)
        	else
        	    -- inst.AnimState:PlayAnimation("atk_pre")
        	    -- inst.AnimState:PushAnimation("atk", false)
        	    inst.AnimState:PlayAnimation("atk")
        	    -- inst.AnimState:PushAnimation("dismount", false)
        	    cooldown = math.max(cooldown, 16 * FRAMES)
        	    local mount = inst.components.wargrider:GetMount()
        	    if mount then
     --    	    	mount.AnimState:PlayAnimation("atk")
     --    	    	local rot = inst.Transform:GetRotation()
					-- mount.Transform:SetRotation(rot)
	        	    -- mount[3].AnimState:PlayAnimation("atk_pre")
	        	    -- mount[3].AnimState:PushAnimation("atk", false)
					-- mount[1].AnimState:PlayAnimation("atk")
					-- mount[2].AnimState:PlayAnimation("atk")
					inst.components.wargrider:PlayAllMountAnim("atk")
					inst.components.wargrider:SetAllMountRotation()
        	    end
        	end
        	inst.sg:SetTimeout(cooldown)
        end
	end
end)

AddStategraphState("wilson", State{
	name = "wargride_idle",
	tags = {"idle", "canrotate"},
	onenter = function(inst, pushanim)
		if pushanim then
            inst.AnimState:PushAnimation("idle_loop", true)
        else
            inst.AnimState:PlayAnimation("idle_loop", true)
        end
        inst.sg:SetTimeout(2 + math.random() * 8)
	end,
	ontimeout = function(inst)
		local mount = inst.components.wargrider:GetMount()
		if mount == nil then
			inst.sg:GoToState("idle")
			return 
		else
			-- mount.AnimState:PlayAnimation("idle_loop", true)
			inst.components.wargrider:PlayAllMountAnim("idle_loop", true)
			inst.components.wargrider:SetAllMountRotation()
		end
	end,
})

AddStategraphState("wilson", State{
	name = "ride_warg",
	tags = { "doing", "busy", "nomorph", "nopredict" },
	onenter = function(inst)
        inst.components.locomotor:StopMoving()
        inst.AnimState:PlayAnimation("mount")
        -- if inst.components.playercontroller then
        --     inst.components.playercontroller:Enable(false)
        -- end
    end,
    timeline =
    {
        TimeEvent(20 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
            inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
	    	inst:PerformBufferedAction()
        end),
    },
    events =
    {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("wargride_idle")
            -- inst.components.wargrider:HandlerPlayerAnim(false)
        end),
    },
    -- onexit = function(inst)
        -- if inst.components.playercontroller then
        --     inst.components.playercontroller:Enable(true)
        -- end
    -- end,
})

AddStategraphState("wilson", State{
	name = "disride_warg",
	tags = { "doing", "busy", "pausepredict", "nomorph", "dismounting" },
    onenter = function(inst)
        inst.components.locomotor:StopMoving()
        -- inst.components.wargrider:HandlerPlayerAnim(true)
        inst.AnimState:PlayAnimation("dismount")
        inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
    end,
    events =
    {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
    onexit = function(inst)
        inst.components.wargrider:DisMount()
    end,
})

AddStategraphPostInit("warg", function(sg)
	local function SpawnHound(inst)
		local x, y, z = inst.Transform:GetWorldPosition()
		local wargs = TheSim:FindEntities(x,y,z, 40, {"warg"})
		if #wargs < 3 then
			local theta = math.random() * 2 * PI
		    local pt = inst:GetPosition()
		    local radius = math.random(3, 6)
		    local offset = FindWalkableOffset(pt, theta, radius, 12, true)
		    if offset then
		        local pos = pt + offset
				local warg = SpawnPrefab("warg")
		        warg.Transform:SetPosition(pos:Get())
		        SpawnPrefab("statue_transition").Transform:SetPosition(pos:Get())
    			SpawnPrefab("statue_transition_2").Transform:SetPosition(pos:Get())
			end
		else
			local maxNum = Lerp(2, 4, GetClock():GetNumCycles()/ 100)
			maxNum = math.clamp(maxNum, 2, 4)
			local num = math.random(1,maxNum)
			if GetWorld().components.hounded then
				for i = 1, num do
					local hound =GetWorld().components.hounded:SummonHound()
					if hound then
						hound.components.follower:SetLeader(inst)
					end
				end
			end
		end
	end
	sg.states["howl"].timeline = {
		TimeEvent(10*FRAMES, SpawnHound),
	}
end)

local ride_warg = Action({}, 9)
ride_warg.id = "RIDE_WARG"
ride_warg.str = "RIDE_WARG"
ride_warg.fn = function(act)
	local obj = act.target
	local doer = act.doer
	if obj.components.wargrideable and doer.components.wargrider
	and not doer.components.wargrider:IsRiding()
	and obj.components.health 
	and not obj.components.health:IsDead() then
		doer.components.wargrider:Mount(obj)
		return true
	end
end
AddAction(ride_warg)

local disride_warg = Action({}, 10)
disride_warg.id = "DISRIDE_WARG"
disride_warg.str = "DISRIDE_WARG"
disride_warg.fn = function(act)
	local doer = act.doer
	if doer.components.wargrider
	and doer.components.wargrider:IsRiding() then
		act.doer.components.wargrider:DisMount()
		return true
	end
end
AddAction(disride_warg)

local state = "doshortaction"
-- AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.RIDE_WARG, state))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.RIDE_WARG, "ride_warg"))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.DISRIDE_WARG, "disride_warg"))
