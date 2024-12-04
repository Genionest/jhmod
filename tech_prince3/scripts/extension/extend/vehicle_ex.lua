--[[ 相关的动作 ]]
STRINGS.WG_MOUNT = "上车"
local mount = Action({}, 10)
mount.id = "WG_MOUNT"
mount.str = STRINGS.WG_MOUNT
mount.fn = function(act)
	if act.target and act.doer then
		if act.doer.components.wg_vehicle_owner 
		and act.target.components.wg_vehicle then
			act.target.components.wg_vehicle:Mount(act.doer)
			return true
		end
	end
end

STRINGS.WG_JUMP_MOUNT = "上车"
local jump_mount = Action({}, 10, nil, nil, 6)
jump_mount.id = "WG_JUMP_MOUNT"
jump_mount.str = STRINGS.WG_MOUNT
jump_mount.fn = function(act)
	if act.target and act.doer then
		if act.doer.components.wg_vehicle_owner
		and act.target.components.wg_vehicle then
			act.target.components.wg_vehicle:Mount(act.doer)
			return true
		end
	end
end

STRINGS.WG_JUMP_DISMOUNT = "下车"
local jump_dismount = Action({}, 10, nil, nil, 6)
jump_dismount.id = "WG_JUMP_DISMOUNT"
jump_dismount.str = STRINGS.WG_DISMOUNT
jump_dismount.fn = function(act)
	if act.doer and act.pos then
		if act.doer.components.wg_vehicle_owner 
		and act.doer.components.wg_vehicle_owner.vehicle then
			local vehicle = act.doer.components.wg_vehicle_owner.vehicle
			vehicle.components.wg_vehicle:Dismount(act.pos)
			return true
		end
	end
end

STRINGS.WG_DISMOUNT = "下车"
local dismount = Action({}, 10)
dismount.id = "WG_DISMOUNT"
dismount.str = STRINGS.WG_DISMOUNT
dismount.fn = function(act)
	if act.target and act.doer then
		if act.doer.components.wg_vehicle_owner 
		and act.target.components.wg_vehicle then
			act.target.components.wg_vehicle:Dismount(act.doer)
			return true
		end
	end
end

local function add_player_sg_action_handler(action, state)
    AddAction(action)
    AddStategraphActionHandler("wilson", ActionHandler(action, state))
    -- AddStategraphActionHandler("wilsonboating", ActionHandler(action, state))
end

add_player_sg_action_handler(mount, "give")
add_player_sg_action_handler(dismount, "give")
add_player_sg_action_handler(jump_mount, "jumponboatstart")
add_player_sg_action_handler(jump_dismount, "boatdismount")

--[[ sg ]]
local function add_player_sg(state)
    AddStategraphState("wilson", state)
    AddStategraphState("wilsonboating", state)
end

add_player_sg(State{
    name = "wg_jump_dismount",
    tags = {"doing", "busy", "canrotate"},

    onenter = function(inst, target_pos)
        inst.components.locomotor:Stop()
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        inst.AnimState:PlayAnimation("jumpboat")
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_whoosh")
        -- local vehicle = inst.components.tpvehicleowner.vehicle
        inst.sg.statemem.startpos = inst:GetPosition()
        inst.sg.statemem.targetpos = target_pos

        RemovePhysicsColliders(inst)
        inst.components.health:SetInvincible(true, "jump_dismount")
        inst.components.playercontroller:Enable(false)
    end,

    onexit = function(inst)
    --This shouldn't actually be reached
        ChangeToCharacterPhysics(inst)
        inst.components.locomotor:Stop()
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        inst.components.health:SetInvincible(false, "jump_dismount")
        inst.components.playercontroller:Enable(true)
        -- inst:RemoveTag("wg_boat_driver")
    end,

    timeline =
    {
        TimeEvent(7*FRAMES, function(inst)
            inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
            -- local dist = inst.sg.statemem.startpos:Dist(inst.sg.statemem.targetpos)
            local dist = inst:GetPosition():Dist(inst.sg.statemem.targetpos)
            local speed = dist / (18/30)
            inst.Physics:SetMotorVelOverride(1 * speed, 0, 0)
        end),
    },

    events =
    {
        EventHandler("animover", function(inst)
            inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
            inst.Physics:Stop()
            inst.components.health:SetInvincible(false)
            inst.sg:GoToState("jumpoffboatland")
        end),
    },
})

-- 当前版本
local cur_ver = 1

--[[ 防止在海上乘坐载具保存重进后淹死 ]]
AddComponentPostInit("keeponland", function(self)
    if self.vehicle_fix and cur_ver<=self.vehicle_fix then 
        return 
    end 
    self.vehicle_fix = cur_ver

	local OnUpdate = self.OnUpdate
	function self:OnUpdate(dt)
		-- 载具
		if self.inst:HasTag("wg_driving_vehicle") then
			return
		end
		OnUpdate(self, dt)
	end
end)

AddComponentPostInit("combat", function(self)
    -- if self.vehicle_fix and cur_ver<=self.vehicle_fix then 
    --     return 
    -- end 
    -- self.vehicle_fix = cur_ver
end)

AddPlayerPostInit(function(inst)
    -- 骑车时不能攻击
    local CanAttack = inst.components.combat.CanAttack
    function inst.components.combat:CanAttack(target)
        if not self.inst:HasTag("wg_driving_vehicle") then
            return CanAttack(self, target)
        end
    end
    inst:AddComponent("wg_vehicle_owner")
end)