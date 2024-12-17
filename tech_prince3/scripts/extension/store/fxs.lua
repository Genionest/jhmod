local easing = require "easing"
local FxManager = require "extension.lib.fx_manager"
local Kit = require "extension.lib.wargon"
local AssetUtil = require "extension.lib.asset_util"
local Sounds = require "extension.datas.sounds"
local EntUtil = require "extension.lib.ent_util"
local AssetMaster = Sample.AssetMaster

local fxs = {}

--[[
淡入  
inst (EntityScript)实体  
time (number)淡入时间  
]]
local function fade_in(inst, time)
    local alpha = 0
    local task
    task = inst:DoPeriodicTask(1/30, function() 
        alpha = alpha + 1/30/time
        inst.AnimState:SetMultColour(1,1,1,alpha)
        if alpha >= 1 and task then
            task:Cancel()
            task = nil
        end
    end)
end

--[[
发射粒子  
inst (EntityScript)实体  
data (table)粒子数据{owner, angle/pos, weapon}  
speed (number)速度  
range (number)弹道半径  
damage (number/func)伤害或伤害函数func(v,attacker,weapon,reason)  
stimuli (table)伤害原因  
calc (bool)是否计算伤害  
living_time (number)存活时间  
test_fn (function)测试函数func(v,attacker,weapon)  
hit_fn (function)命中函数func(v,attacker,weapon)  
over_fn (function)结束函数func(inst)  
]]
local function shoot_emitter(inst, data, speed, range, damage, stimuli, calc, living_time, test_fn, hit_fn, over_fn)
    if data.angle then
        inst.Transform:SetRotation(data.angle)
    elseif data.pos then
        inst:ForceFacePoint(data.pos)
    end
    inst.Physics:SetMotorVel(speed, 0, 0)
    local task
    task = inst:DoPeriodicTask(.1, function()
        local ent = FindEntity(inst, range, function(target, inst)
            if EntUtil:check_combat_target(data.owner, target) then
                return true
            end
        end, nil, EntUtil.not_enemy_tags)
        if ent and (test_fn == nil or test_fn(ent, data.owner, data.weapon)) then
            EntUtil:get_attacked(ent, data.owner, damage, data.weapon, stimuli, calc)
            if hit_fn then
                hit_fn(ent, data.owner, data.weapon)
            end
            if task then
                task:Cancel()
                task = nil
            end
            inst.Physics:Stop()
            if over_fn then
                over_fn(inst)
            end
            inst:WgRecycle()
        end
    end)
    inst:DoTaskInTime(living_time, function(inst)
        if task then
            task:Cancel()
            task = nil
        end
        inst.Physics:Stop()
        inst:WgRecycle()
    end)
end

--[[
造成直线伤害  
inst (EntityScript)实体  
data (table)粒子数据{owner, angle/pos, weapon}  
speed (number)速度  
damage (number/func)伤害或伤害函数func(v,attacker,weapon,reason)  
range (number)弹道半径  
stimuli (table)伤害原因  
calc (bool)是否计算伤害  
living_time (number)存活时间  
test_fn (function)测试函数func(v,attacker,weapon)  
hit_fn (function)命中函数func(v,attacker,weapon)  
stop_fn (function)结束函数
]]
local function do_line_damage(inst, data, speed, range, damage, stimuli, calc, living_time, test_fn, hit_fn, stop_fn)
    if data.angle then
        inst.Transform:SetRotation(data.angle)
    elseif data.pos then
        inst:ForceFacePoint(data.pos)
    end
    inst.Physics:SetMotorVel(speed, 0, 0)
    local task
    inst.enemies = {}
    if damage then
        task = inst:DoPeriodicTask(.1, function()
            EntUtil:make_area_dmg(inst, range, data.owner, damage, data.weapon, stimuli, {
                test = test_fn or function(v, attacker, weapon)
                    return not inst.enemies[v]
                end,
                fn = hit_fn or function(v, attacker, weapon)
                    inst.enemies[v] = true
                end,
                calc = calc
            })
        end)
    end
    inst:DoTaskInTime(living_time, function(inst)
        inst.enemies = nil
        if task then
            task:Cancel()
            task = nil
        end
        inst.Physics:Stop()
        if stop_fn then
            stop_fn(inst) 
        end
        inst:WgRecycle()
    end)
end

--[[
创建粒子物理,注意粒子一旦StopPhysics,将会立马往地下掉落  
inst (EntityScript)实体  
]]
local function make_emitter_physics(inst)
    inst.entity:AddPhysics()
    inst.Physics:SetSphere(.5)
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(.1)
    inst.Physics:SetDamping(0)
    inst.Physics:SetRestitution(.5)
    inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
    inst.Physics:ClearCollisionMask()
end

-- 导入原游戏的fx
local original_fx = require "fx"
for k, t in pairs(original_fx) do
	fxs[t.name] = {
        init=function(inst)
			if not t.twofaced then
				inst.Transform:SetFourFaced()
			else
				inst.Transform:SetTwoFaced()
			end
			inst.anim = t.anim
			if t.sound or t.sound2 then
				inst.entity:AddSoundEmitter()
			end
			if t.transform then
				inst.AnimState:SetScale(t.transform:Get())
			end
			inst.AnimState:SetBank(t.bank)
			inst.AnimState:SetBuild(t.build)
		end,
        wake = function(inst)
            if t.fnc and t.fntime then
                inst:DoTaskInTime(t.fntime, t.fnc)
            end
            if t.sound then
                inst:DoTaskInTime(t.sounddelay or 0, function() inst.SoundEmitter:PlaySound(t.sound) end)
            end
            if t.sound2 then
                inst:DoTaskInTime(t.sounddelay2 or 0, function() inst.SoundEmitter:PlaySound(t.sound2) end)
            end
            local anim = inst.anim
            if type(inst.anim) ~= "string" then
                anim = inst.anim[math.random(#inst.anim)]
            end
            inst.AnimState:PlayAnimation(inst.anim, false)
            if t.tint or t.tintalpha then
                inst.AnimState:SetMultColour((t.tint and t.tint.x) or (t.tintalpha or 1),(t.tint and t.tint.y)  or (t.tintalpha or 1),(t.tint and t.tint.z)  or (t.tintalpha or 1), t.tintalpha or 1)
            end
            if t.bloom and inst.bloom == nil then
                inst.bloom = true
                inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
            end
            inst.on_recycle = function(inst)
                -- if inst.bloom then inst.AnimState:ClearBloomEffectHandle() end
                inst:WgRecycle() 
            end
            inst:ListenForEvent("animover", inst.on_recycle)
	    end,
        recycle = function(inst)
            if inst.parent then
                inst.parent:RemoveChild(inst)
            end
            inst:RemoveEventCallback("animover", inst.on_recycle)
        end,
    }
end

fxs.log = {
    init = function(inst)
        inst.AnimState:SetBank("log")
        inst.AnimState:SetBuild("log")
        inst.AnimState:PlayAnimation("idle")
    end,
    wake = function(inst, data)
    end,
    recycle = function(inst, data)
    end,
}

fxs.explodering_fx = {
    init = function(inst)
        local anim = inst.AnimState
        anim:SetBank("explode_ring_fx")
        anim:SetBuild("explode_ring_fx")
        anim:SetFinalOffset(-1)
        
        anim:SetOrientation( ANIM_ORIENTATION.OnGround )
        anim:SetLayer( LAYER_BACKGROUND )
        anim:SetSortOrder( 3 )
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("idle")
        inst:ListenForEvent("animover", inst.WgRecycle)
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
        inst:RemoveEventCallback("animover", inst.WgRecycle)
    end,
}

fxs.collapse_small = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.AnimState:SetBank("collapse")
        inst.AnimState:SetBuild("structure_collapse_fx")
        inst.AnimState:PlayAnimation("collapse_small")
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("collapse_small")
        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke",nil,.25)
        inst:DoTaskInTime(1, function()
            inst:WgRecycle()
        end)
    end,
}

fxs.collapse_big = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.AnimState:SetBank("collapse")
        inst.AnimState:SetBuild("structure_collapse_fx")
        inst.AnimState:PlayAnimation("collapse_large")
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("collapse_large")
        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke")
        inst:DoTaskInTime(1, function()
            inst:WgRecycle()
        end)
    end,
}

fxs.impact = {
    init = function(inst)
        inst.AnimState:SetBank("impact")
        inst.AnimState:SetBuild("impact")
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetFinalOffset(-1)
    end,
    wake = function(inst, data)
        if data and data.owner then
            inst:ForceFacePoint(data.owner:GetPosition():Get())
        end
        inst.event_fn = EntUtil:listen_for_event(inst, "animover", function(inst, data)
            inst:WgRecycle()
        end)
    end,
    recycle = function(inst)
        if inst.event_fn then
            inst:RemoveEventCallback("animover", inst.event_fn)
            inst.event_fn = nil
        end
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.force_field = {
    init = function(inst)
        inst.AnimState:SetBank("forcefield")
        inst.AnimState:SetBuild("forcefield")
    end,
    wake = function(inst, data)
        inst.AnimState:PushAnimation("idle_loop", true)
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.force_field2 = {
    init = function(inst)
        inst.AnimState:SetBank("forcefield")
        inst.AnimState:SetBuild("forcefield")
        inst.AnimState:SetMultColour(1, 1, 1, .6)
    end,
    wake = function(inst, data)
        inst.AnimState:PushAnimation("idle_loop", true)
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

-- 射出雪球
local function launch_snow_ball(inst, targetpos, owner)
	local x, y, z = inst.Transform:GetWorldPosition()
	local projectile = SpawnPrefab("tp_snow_ball")
	-- projectile.Transform:SetPosition(x, y+4, z)  -- 抛得更远
	projectile.Transform:SetPosition(x, y, z)
	local dx = targetpos.x - x
	local dz = targetpos.z - z
	local rangesq = dx * dx + dz * dz
	local maxrange = TUNING.FIRE_DETECTOR_RANGE
	local speed = easing.linear(rangesq, 15, 3, maxrange * maxrange)
	projectile.components.complexprojectile:SetHorizontalSpeed(speed)
	projectile.components.complexprojectile:SetGravity(-25)
	projectile.components.complexprojectile:Launch(targetpos, inst, inst)
	projectile.owner = owner
end

fxs.snow_ball_dropper = {
    wake = function(inst, data)
        inst:DoTaskInTime(0, function()
            local pt = inst:GetPosition()
            inst.Transform:SetPosition(pt.x, 4, pt.z)
            for i = 1, math.random(4, 8) do
                local pos = Kit:find_walk_pos(inst, 
                math.random(TUNING.FIRE_DETECTOR_RANGE/3)+math.random())
                if pos then
                    launch_snow_ball(inst, pos, data.owner)
                end
            end
        end)
    end,
}

fxs.snow_ball_shooter = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.AnimState:SetBank("firefighter")
        inst.AnimState:SetBuild("firefighter")
        inst.AnimState:PlayAnimation("idle_on_loop")
		inst.shoot = function(inst)
			inst.AnimState:PlayAnimation("launch_pre")
			inst.AnimState:PushAnimation("launch", false)
			inst.AnimState:PushAnimation("launch_pst", false)
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_spin")
		end
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("idle_on_loop")
        inst:DoTaskInTime(0, function()
            FxManager:MakeFx("collapse_small", inst)
        end)
        inst:DoTaskInTime(.1, function()
            inst:shoot()
            if inst.task == nil then
                inst.task = inst:DoPeriodicTask(.2, function()
                    local pos = Kit:find_walk_pos(inst, 
                        math.random(TUNING.FIRE_DETECTOR_RANGE/2)+math.random())
                    if pos then
                        launch_snow_ball(inst, pos, data.owner)
                    end
                end)
            end
        end)
        inst:ListenForEvent("animqueueover", inst.shoot)
        inst:DoTaskInTime(2, function()
            FxManager:MakeFx("collapse_small", inst)
            inst:WgRecycle()
        end)
    end,
    recycle = function(inst)
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
        inst:RemoveEventCallback("animqueueover", inst.shoot)
    end,
}

fxs.over_load = {
    init = function(inst)
        inst:AddComponent("talker")
        inst.components.talker.colour = Vector3(1, .1, .1)
    end,
    wake = function(inst, data)
        inst.components.talker:Say("超载")
    end,
    recycle = function(inst)
        inst.components.talker:ShutUp()
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.no_electric = {
    init = function(inst)
        inst:AddComponent("talker")
        -- inst.components.talker.colour = Vector3(1, .1, .1)
    end,
    wake = function(inst, data)
        inst.components.talker:Say("没电")
    end,
    recycle = function(inst)
        inst.components.talker:ShutUp()
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.slience = {
    init = function(inst)
        inst:AddComponent("talker")
        inst.components.talker.colour = Vector3(.3, .3, 1)
    end,
    wake = function(inst, data)
        inst.components.talker:Say("沉默")
    end,
    recycle = function(inst)
        inst.components.talker:ShutUp()
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.talker = {
    init = function(inst)
        inst:AddComponent("talker")
    end,
    wake = function(inst, data)
        if inst.task == nil then
            inst.task = inst:DoPeriodicTask(.05, function()
                local pt = inst:GetPosition()
                pt.y = pt.y + .1
                inst.Transform:SetPosition(pt:Get())
            end)
        end
        if data.colour then
            inst.components.talker.colour = data.colour
        end
        if data.str then
            inst:DoTaskInTime(0, function()
                inst.components.talker:Say(data.str)
            end)
        end
        inst:DoTaskInTime(1, inst.WgRecycle)
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
        inst.components.talker:ShutUp()
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.crit = {
    init = function(inst)
        fxs.talker.init(inst)
        inst.components.talker.colour=Vector3(255/255, 130/255, 71/255)
    end,
    wake = function(inst, data)
        fxs.talker.wake(inst, {str="Critical"})
    end,
    recycle = fxs.talker.recycle,
}

fxs.evade = {
    init = function(inst)
        fxs.talker.init(inst)
        inst.components.talker.colour=Vector3(0x66/255, 0xcc/255, 0xff/255)
    end,
    wake = function(inst, data)
        fxs.talker.wake(inst, {str="Missing"})
    end,
    recycle = fxs.talker.recycle,
}

local function drop(inst)
    -- 抛出
    -- local down = TheCamera:GetDownVec()
    -- local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
    --local angle = (-TUNING.CAM_ROT-90 + math.random()*60-30)/180*PI
    local angle = math.random()*2*PI
    local sp = math.random()*4+2
    inst.Physics:SetVel(sp*math.cos(angle), math.random()*2+8+4, sp*math.sin(angle))
    -- 下落监听
    local dt = .01
    inst.task = inst:DoPeriodicTask(dt, function()
        local x,y,z = inst.Transform:GetWorldPosition()
        if x and y and z then 
            local vely = 0 
            if inst.Physics then 
                local vx, vy, vz = inst.Physics:GetVelocity()
                vely = vy or 0

                if (not vx) or (not vy) or (not vz) then
                    inst:WgRecycle()
                elseif (vx == 0) and (vy == 0) and (vz == 0) then
                    inst:WgRecycle()
                end
            end

            if y + vely * dt * 1.5 < 0.01 and vely <= 0 then
                -- print("vely", vely)
                inst:WgRecycle()
            end        
        else     
            inst:WgRecycle()
        end 
    end)

end

fxs.health_number = {
    init = function(inst)
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
        inst:AddComponent("talker")
        inst.components.talker.font = UIFONT
    end,
    wake = function(inst, data)
        drop(inst)
        if data.number then
            if data.number < 0 then
                inst.components.talker.colour = Vector3(1,.4,.2)
            else
                inst.components.talker.colour = Vector3(.2,1,.2)
            end
            inst:DoTaskInTime(0, function()
                inst.components.talker:Say(string.format("%+.1f", data.number))
            end)
        end
    end,
    recycle = function(inst)
        inst.components.talker:ShutUp()
        inst.Physics:Stop()
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.attack_number = {
    init = function(inst)
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
        inst:AddComponent("talker")
        inst.components.talker.font = UIFONT
    end,
    wake = function(inst, data)
        drop(inst)

        if data.number and data.stimuli then
            local dmg_type
            if EntUtil:in_stimuli(data.stimuli, "spike") then
                dmg_type = STRINGS.TP_DMG_TYPE["spike"]
                inst.components.talker.colour = Vector3(.8,.8,.8)
            elseif EntUtil:in_stimuli(data.stimuli, "strike") then
                dmg_type = STRINGS.TP_DMG_TYPE["strike"]
                inst.components.talker.colour = Vector3(.8,.8,.8)
            elseif EntUtil:in_stimuli(data.stimuli, "slash") then
                dmg_type = STRINGS.TP_DMG_TYPE["slash"]
                inst.components.talker.colour = Vector3(.8,.8,.8)
            elseif EntUtil:in_stimuli(data.stimuli, "thump") then
                dmg_type = STRINGS.TP_DMG_TYPE["thump"]
                inst.components.talker.colour = Vector3(.8,.8,.8)
            elseif EntUtil:in_stimuli(data.stimuli, "fire") then
                dmg_type = STRINGS.TP_DMG_TYPE["fire"]
                inst.components.talker.colour = Vector3(1,.8,.3)
            elseif EntUtil:in_stimuli(data.stimuli, "ice") then
                dmg_type = STRINGS.TP_DMG_TYPE["ice"]
                inst.components.talker.colour = Vector3(.3,1,1)
            elseif EntUtil:in_stimuli(data.stimuli, "electric") then
                dmg_type = STRINGS.TP_DMG_TYPE["electric"]
                inst.components.talker.colour = Vector3(.3,.3,1)
            elseif EntUtil:in_stimuli(data.stimuli, "poison") then
                dmg_type = STRINGS.TP_DMG_TYPE["poison"]
                inst.components.talker.colour = Vector3(.3,1,.3)
            elseif EntUtil:in_stimuli(data.stimuli, "shadow") then
                dmg_type = STRINGS.TP_DMG_TYPE["shadow"]
                inst.components.talker.colour = Vector3(1,.3,1)
            elseif EntUtil:in_stimuli(data.stimuli, "blood") then
                dmg_type = STRINGS.TP_DMG_TYPE["blood"]
                inst.components.talker.colour = Vector3(1,.3,.3)
            elseif EntUtil:in_stimuli(data.stimuli, "wind") then
                dmg_type = STRINGS.TP_DMG_TYPE["wind"]
                inst.components.talker.colour = Vector3(.6,1,.6)
            elseif EntUtil:in_stimuli(data.stimuli, "holly") then
                dmg_type = STRINGS.TP_DMG_TYPE["holly"]
                inst.components.talker.colour = Vector3(1,1,.3)
            elseif EntUtil:in_stimuli(data.stimuli, "true") then
                dmg_type = "真"
                inst.components.talker.colour = Vector3(1,1,1)
            else
                dmg_type = "无"
                inst.components.talker.colour = Vector3(1,1,1)
            end
            inst:DoTaskInTime(0, function()
                inst.components.talker:Say(string.format("%s %.1f", dmg_type, data.number))
            end)
        end
    end,
    recycle = function(inst)
        inst.components.talker:ShutUp()
        inst.Physics:Stop()
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.img_fx=  {
    init = function(inst)
        inst:AddComponent("wg_follow_image")
    end,
    wake = function(inst, data)
        if data.Uimg then
            local Uimg = data.Uimg
            local atlas, image = AssetUtil:GetImage(Uimg)
            inst.components.wg_follow_image:SetImage(atlas, image)
        end
        inst.components.wg_follow_image:Show()
        inst.n = 0
        inst.task = inst:DoPeriodicTask(1/30, function()
            inst.n = inst.n + 100/30
            local alpha = math.max(0, 1-inst.n/100)
            local scale = 1 + inst.n/100
            inst.components.wg_follow_image:Execute(function(widget)
                widget.wg_image:SetTint(1,1,1,alpha)
                widget.wg_image:SetScale(scale)
            end)
            -- inst.Transform:SetScale(scale, scale, scale)
        end)
        inst:DoTaskInTime(1, inst.WgRecycle)
    end,
    recycle = function(inst)
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
        -- inst.Transform:SetScale(1, 1, 1)
        inst.components.wg_follow_image:Hide()
    end,
}

fxs.anim_fx = {
    wake = function(inst, data)
        if data and data.anim then
            inst.AnimState:SetBank(data.anim[1])
            inst.AnimState:SetBuild(data.anim[2])
            inst.AnimState:PlayAnimation(data.anim[3], data.anim[4])
        end
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

for k, v in pairs({
    fire = "img_9",
    ice = "img_16",
    electric = "img_15",
    poison = "img_11",
    blood = "img_8",
    wind = "img_6",
    shadow = "img_5",
    holly = "img_4",
}) do

fxs[k .. "_magic"] = {
    init = fxs.img_fx.init,
    wake = function(inst, data)
        fxs.img_fx.wake(inst, {Uimg=AssetUtil:MakeImg("tp_icons3", v)})
    end,
    recycle = fxs.img_fx.recycle,
}  
  
end

fxs.mult_area_dmg_fx = {
    init = function(inst)
    end,
    wake = function(inst, data)
        inst.enemies = {}
    end,
    recycle = function(inst, data)
        inst.enemies = nil
    end,
}

fxs.magic_center = {
    init = function(inst)
        inst.fx_anim = nil
        inst.num = 16  -- child_fx数量
		inst.step = 5  -- 多少次转完一圈
		inst.width = 3  -- 距离半径
		inst.height = 3.5  -- 一边的高度为0, 另一边的高度为这个值, 这样子倾斜
        -- inst.const_height = 0  -- 固定高度
		inst.get_point = function(inst, angle)
			local radius = inst.width
			local arc = angle * DEGREES
			local x = math.cos(arc) * radius
			local z = math.sin(arc) * radius
			local y = 0
			if inst.height ~= 0 then
				y = inst.height- math.abs(angle-180)/(180/inst.height)
			end
			if inst.const_height then
				y = inst.const_height
			end
			local pos = Vector3(x, y, z)
			return pos
		end
		inst.get_points = function(inst)
			local pos_t = {}
			for i = 0, inst.num-1 do
				local angle = inst.angle or 0
				angle = (angle + i*360/inst.num)%360
				local pos = inst.get_point(inst, angle)
				table.insert(pos_t, pos)
			end
			inst.angle = (inst.angle + inst.step)%360
			return pos_t
		end
		inst.get_fxs = function(inst)
			if inst.fxs == nil then
				inst.fxs = {}
				for i = 1, inst.num do
                    local fx = FxManager:MakeFx(inst.child_fx, inst, inst.child_data)
                    inst:AddChild(fx)
					fx.Transform:SetPosition(0, 0, 0)
					table.insert(inst.fxs, fx)
				end
			end
			return inst.fxs
		end
		inst.set_fxs_pos = function(inst)
			local fxs = inst.get_fxs(inst)
			local pos_t = inst.get_points(inst)
			for k, v in pairs(fxs) do
				v.Transform:SetPosition(pos_t[k]:Get())
                if inst.child_fn then
                    inst.child_fn(v)
                end
			end
		end
    end,
    wake = function(inst, data)
        inst.angle = 0
        inst.task = inst:DoPeriodicTask(.05, function()
            inst:set_fxs_pos()
        end)
        inst.task2 = inst:DoPeriodicTask(FRAMES, function()
            if inst.owner and (inst.components.health == nil
            or EntUtil:is_alive(inst.owner)) then
                local pt = inst.owner:GetPosition()
                inst.Transform:SetPosition(pt:Get())
            end
        end)
    end,
    recycle = function(inst)
        if inst.fxs then
            for k, v in pairs(inst.fxs) do
                v:WgRecycle()
            end
            inst.fxs = nil
        end
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
        if inst.task2 then
            inst.task2:Cancel()
            inst.task2 = nil
        end
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.templar_magic = {
    init = function(inst)
        fxs.magic_center.init(inst)
        inst.child_fx = "anim_fx"
        inst.child_data = {anim={"tp_spear_lance", "tp_spear_lance", "throw"}}
        inst.num = 4
        inst.step = 14
        inst.width = 2
        inst.height = 0
        -- inst.const_height = 0
    end,
    wake = function(inst, data)
        -- 不要AddChild这个fx, 传入data.owner, 会自行设置位置跟随
        fxs.magic_center.wake(inst, data)
        if data then
            inst.owner = data.owner
            inst.target = data.target
        end
        -- inst.task2 = inst:DoPeriodicTask(FRAMES, function()
        --     if inst.owner and EntUtil:is_alive(inst.owner) then
        --         local pt = inst.owner:GetPosition()
        --         inst.Transform:SetPosition(pt:Get())
        --     end
        -- end)
        for i = 1, 4 do
            inst:DoTaskInTime(3+.5*i, function()
                local fx = inst.fxs[1]
                if fx then
                    if inst.owner and EntUtil:is_alive(inst.owner)
                    and inst.owner.components.combat then
                        local target = inst.owner.components.combat.target or inst.target
                        if target and EntUtil:is_alive(target) then
                            local proj = SpawnPrefab("tp_templar_proj")
                            if inst.owner:HasTag("player") then
                                proj.components.weapon:SetDamage(5)
                            end
                            proj.Transform:SetPosition(fx:GetPosition():Get())
                            proj.components.wg_projectile:Throw(inst.owner, target, inst.owner)
                        end
                    end
                    fx:WgRecycle()
                    table.remove(inst.fxs, 1)
                end
            end)
        end
        inst:DoTaskInTime(3+.5*5, inst.WgRecycle)
    end,
    recycle = function(inst)
        fxs.magic_center.recycle(inst)
        -- if inst.task2 then
        --     inst.task2:Cancel()
        --     inst.task2 = nil
        -- end
        inst.owner = nil
        inst.target = nil
    end,
}

fxs.templar_magic2 = {
    init = function(inst)
        fxs.magic_center.init(inst)
        inst.child_fx = "anim_fx"
        inst.child_data = {anim={"tp_spear_lance", "tp_spear_lance", "throw"}}
        inst.num = 4
        inst.step = 14
        inst.width = 2
        inst.height = 0
        -- inst.const_height = 0
    end,
    wake = function(inst, data)
        -- 不要AddChild这个fx, 传入data.owner, 会自行设置位置跟随
        fxs.magic_center.wake(inst, data)
        if data and data.owner then
            inst.owner = data.owner
        end
    end,
    recycle = function(inst)
        fxs.magic_center.recycle(inst)
        inst.owner = nil
    end,
}

fxs.thorns = {
    init = function(inst)
        inst.AnimState:SetBank("bramblefx")
        inst.AnimState:SetBuild("bramblefx")
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("idle")
        inst:ListenForEvent("animover", inst.WgRecycle)
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
        inst:RemoveEventCallback("animover", inst.WgRecycle)
    end,
}

fxs.thorns_red = {
    init = function(inst)
        fxs.thorns.init(inst)
        inst.AnimState:SetMultColour(1, .3, .3, 1)
    end,
    wake = fxs.thorns.wake,
    recycle = fxs.thorns.recycle,
}

fxs.thorns_blue = {
    init = function(inst)
        fxs.thorns.init(inst)
        inst.AnimState:SetMultColour(.3, .3, 1, 1)
    end,
    wake = fxs.thorns.wake,
    recycle = fxs.thorns.recycle,
}

fxs.thorns_green = {
    init = function(inst)
        fxs.thorns.init(inst)
        inst.AnimState:SetMultColour(.3, 1, .3, 1)
    end,
    wake = fxs.thorns.wake,
    recycle = fxs.thorns.recycle,
}

fxs.ballightning = {
    init = function(inst)
        inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
        inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
        inst.AnimState:PlayAnimation("crackle_loop", true)
    end,
    wake = function(inst)
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.lightning = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
        inst.AnimState:SetLightOverride(1)
        inst.AnimState:SetScale(2,2,2)
        inst.AnimState:SetBank("lightning")
        inst.AnimState:SetBuild("lightning")
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("anim")
        inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_close")
        inst:ListenForEvent("animover", inst.WgRecycle)
    end,
    recycle = function(inst)
        inst:RemoveEventCallback("animover", inst.WgRecycle)
    end,
}

fxs.bearger_line = {
    init = function(inst)
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
    end,
    wake = function(inst, data)
        inst.Physics:SetMotorVel(20, 0, 0)
        inst:DoTaskInTime(0, function()
            if data and data.owner then
                inst.owner = data.owner
                local rot = inst.owner.Transform:GetRotation()
                inst.Transform:SetRotation(rot)
            end
        end)
        for i = 1, 2 do
            inst:DoTaskInTime(i*.5, function(inst)
                local fx = FxManager:MakeFx("bearger", inst, {owner=inst.owner})
            end)
        end
        inst:DoTaskInTime(1.2, inst.WgRecycle)
    end,
    recycle = function(inst)
        inst.Physics:Stop()
    end,
}

fxs.bearger = {
    init = function(inst)
        inst.Transform:SetFourFaced()
        inst.entity:AddSoundEmitter()
        inst.AnimState:SetBank("bearger")
        inst.AnimState:SetBuild("bearger_build")
        inst.AnimState:SetMultColour(1, 1, 1, .5)
        inst:AddComponent("groundpounder")
        inst.components.groundpounder.destroyer = true
        inst.components.groundpounder.damageRings = 3
        inst.components.groundpounder.destructionRings = 4
        inst.components.groundpounder.numRings = 5
        local cmp = inst.components.groundpounder
        function cmp:DestroyPoints(points, breakobjects, dodamage)
            local getEnts = breakobjects or dodamage
            for k,v in pairs(points) do
                local ents = nil
                if getEnts then
                    ents = TheSim:FindEntities(v.x, v.y, v.z, 3, nil, self.noTags)
                end
                if ents and breakobjects then
                    -- first check to see if there's crops here, we want to work their farm
                    for k2,v2 in pairs(ents) do
                        if v2 and self.burner and v2.components.burnable and not v2:HasTag("fire") and not v2:HasTag("burnt") then
                            v2.components.burnable:Ignite()
                        end
                        -- Don't net any insects when we do work
                        if v2 and self.destroyer and v2.components.workable and v2.components.workable.workleft > 0 and v2.components.workable.action ~= ACTIONS.NET then
                            v2.components.workable:Destroy(self.inst)
                    end
                        if v2 and self.destroyer and v2.components.crop then
                            print("Has Crop:",v2)
                            v2.components.crop:ForceHarvest()
                        end
                    end
                end
                if ents and dodamage then
                    for k2,v2 in pairs(ents) do
                        if not self.ignoreEnts then 
                            self.ignoreEnts = {}
                        end 
                        if not self.ignoreEnts[v2.GUID] then --If this entity hasn't already been hurt by this groundpound
                            if v2 and v2.components.health and not v2.components.health:IsDead() and 
                            inst.owner.components.combat:CanTarget(v2) then
                                EntUtil:get_attacked(v2, inst.owner, 0, nil, nil, true)
                                -- self.inst.components.combat:DoAttack(v2, nil, nil, nil, self.groundpounddamagemult)
                            end
                            self.ignoreEnts[v2.GUID] = true --Keep track of which entities have been hit 
                        end 
                    end
                end
                local map = GetMap()
                if map then
                    local ground = map:GetTileAtPoint(v.x, 0, v.z)
                    if ground == GROUND.IMPASSABLE or map:IsWater(ground) then
                        --Maybe do some water fx here?
                    else
                        if self.groundpoundfx then 
                            SpawnPrefab(self.groundpoundfx).Transform:SetPosition(v.x, 0, v.z)
                        end 
                    end
                end
            end
        end
    end,
    wake = function(inst, data)
        if data and data.owner then
            inst.owner = data.owner
        end
        inst.AnimState:PlayAnimation("ground_pound")
        inst:DoTaskInTime(0, function()
            if inst.owner then
                local rot = inst.owner.Transform:GetRotation()
                inst.Transform:SetRotation(rot)
            end
        end)
        inst:DoTaskInTime(20*FRAMES, function()
            inst.components.groundpounder:GroundPound()
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
        end)
        inst:ListenForEvent("animover", inst.WgRecycle)
    end,
    recycle = function(inst)
        inst:RemoveEventCallback("animover", inst.WgRecycle)
    end,
}

fxs.sign = {
    init = function(inst)
        inst.AnimState:SetBank("sign_home")
        inst.AnimState:SetBuild("sign_home")
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("place")
        inst:ListenForEvent("animover", inst.WgRecycle)
        for i = 1, 6 do
            inst:DoTaskInTime(i*.1, function()
                inst.AnimState:SetMultColour(1, 1, 1, 1-i*.1)
            end)
        end
    end,
    recycle = function(inst)
        inst.AnimState:SetMultColour(1, 1, 1, 1)
        inst:RemoveEventCallback("animover", inst.WgRecycle)
    end,
}

fxs.sign2 = {
    init = function(inst)
        inst.AnimState:SetBank("sign_home")
        inst.AnimState:SetBuild("sign_home")
        inst.AnimState:PlayAnimation("idle")
    end,
    wake = function(inst, data)
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.sign_wall = {
    init = function(inst)
        inst.AnimState:SetBank("sign_home")
        inst.AnimState:SetBuild("sign_home")
        MakeObstaclePhysics(inst, .5)
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("place")
        inst.AnimState:PushAnimation("idle")
        inst.Physics:SetActive(true)
    end,
    recycle = function(inst)
        inst.Physics:SetActive(false)
    end,
}

fxs.sign_line = {
    init = function(inst)
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
    end,
    wake = function(inst, data)
        inst.Physics:SetMotorVel(20, 0, 0)
        inst.task = inst:DoPeriodicTask(.1, function()
            FxManager:MakeFx("sign", inst)
        end)
        inst:DoTaskInTime(0, function()
            local rot = data and data.angle or 0
            inst.Transform:SetRotation(rot)
        end)
    end,
    recycle = function(inst)
        inst.Physics:Stop()
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.sign_six_line = {
    init = function(inst)
    end,
    wake = function(inst, data)
        inst:DoTaskInTime(0, function()
            for i = 1, 6 do
                local angle = 360/6*i
                local fx = FxManager:MakeFx("sign_line", inst, {angle=angle})
                fx:DoTaskInTime(.3, inst.WgRecycle)
            end
        end)
        inst:DoTaskInTime(.5, inst.WgRecycle)
    end,
    recycle = function(inst)
    end,
}

fxs.sign_magic_circle = {
    init = function(inst)
        inst.set_sign_wall = function(inst, angle, radius)
			local pos = inst:GetPosition()
			pos.x = pos.x + math.cos(angle)*radius
			pos.z = pos.z + math.sin(angle)*radius
			local fx = FxManager:MakeFx("sign_wall", pos)
			table.insert(inst.fxs, fx)
		end
    end,
    wake = function(inst, data)
        inst.fxs = {}
        inst:DoTaskInTime(0, function()
            -- 圆形
            local start = math.random(18)
            for i = 1, 18 do
                inst:DoTaskInTime(.1*i, function()
                    local angle = (start+i) * 10 * PI/180
                    local angle2 = PI + angle
                    inst:set_sign_wall(angle, 8)
                    inst:set_sign_wall(angle2, 8)
                end)
            end
            -- 十字
            for i = 1, 4 do
                local angle = PI/180*360/4*i
                for j = 1, 4 do
                    inst:DoTaskInTime(j*.1+1, function()
                        inst:set_sign_wall(angle, j)
                    end)
                end
            end
        end)
        inst:DoTaskInTime(4.6, function()
            SpawnPrefab("groundpoundring_fx").Transform:SetPosition(inst:GetPosition():Get())
            if inst.fxs then
                for k, v in pairs(inst.fxs) do
                    v:WgRecycle()
                end
                inst.fxs = nil
            end
        end)
        inst:DoTaskInTime(5, function()
            local no_tags = {"epic", "beefalo", "ironlord", "tp_defense_sign"}
            local x, y, z = inst:GetPosition():Get()
            local ents = TheSim:FindEntities(x, y, z, 8, nil, no_tags)
            for i2, v2 in pairs(ents) do
                if v2.components.health then
                    if v2:HasTag("player") then
                        Sample.BuffManager:AddBuff(v2, "curse", nil, 10)
                        -- v2.components.tp_madness:DoDelta(75)
                        -- v2.components.health:DoDelta(-50)
                    else
                        v2.components.health:Kill()
                        FxManager:MakeFx("wathgrithr_spirit", v2)
                    end
                end
            end
            local x, y, z = inst:GetPosition():Get()
            local ents = TheSim:FindEntities(x, y, z, 8, {"beefalo"}, {"player"})
            for i2, v2 in pairs(ents) do
                if v2.components.health then
                    v2.components.health:DoDelta(100)
                end
            end
            inst:WgRecycle()
        end)
    end,
    recycle = function(inst)
        if inst.fxs then
            for k, v in pairs(inst.fxs) do
                v:WgRecycle()
            end
            inst.fxs = nil
        end
    end,
}

fxs.minotaur_shadow = {
    init = function(inst)
        inst.AnimState:SetBank("rook")
        inst.AnimState:SetBuild("rook_rhino")
        inst.AnimState:SetMultColour(1, 1, 1, .5)
		inst.Transform:SetFourFaced()
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("atk", true)
        if data and data.owner then
            inst.owner = data.owner
        end
        inst:DoPeriodicTask(0, function()
            if inst.owner then
                local rot = inst.owner.Transform:GetRotation()
                inst.Transform:SetRotation(rot)
            end
        end)
        inst.turn_on = function(inst)
            inst:Show()
            
        end
        inst.turn_off = function(inst)
            inst:Hide()
            if inst.task then
                inst.task:Cancel()
                inst.task = nil 
            end
        end
    end,
    recycle = function(inst)
        inst.owner = nil
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.minotaur_charge = {
    init = function(inst)
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
    end,
    wake = function(inst, data)
        inst:DoTaskInTime(0, function()
            local rot = data.owner.Transform:GetRotation()
            inst.Transform:SetRotation(rot)
        end)
        inst.Physics:SetMotorVel(17, 0, 0)
        inst.tp_fxs = {}
        inst.Transform:SetRotation(0)
        local vals = {
            {6, -70}, {5, -35}, {5, 0}, {5, 35}, {6, 70}
        }
        for i = 1, 5 do
            local radius = vals[i][1]
            local angle = 0
            local rot = angle + vals[i][2]*PI/180
            local x = 0 + math.cos(rot)*radius
            local z = 0 + math.sin(rot)*radius
            local pt = Vector3(x, 0, z)
            local fx = FxManager:MakeFx("minotaur_shadow", pt, {owner=inst})
            inst:AddChild(fx)
            table.insert(inst.tp_fxs, fx)
        end
        if inst.tp_task == nil then
            inst.tp_enemies = {}
            inst.tp_task2 = inst:DoPeriodicTask(.5, function()
                inst.tp_enemies = {}
            end)
            inst.tp_task = inst:DoPeriodicTask(.1, function()
                for _, fx in pairs(inst.tp_fxs) do
                    local dmg = 50
                    local mult = data.owner.components.combat:GetDamageModifier()
                    EntUtil:make_area_dmg2(fx, 4, data.owner, dmg*mult, nil, 
                        EntUtil:add_stimuli(nil, data.owner.components.combat.dmg_type), {
                            -- calc=true,
                            test = function(v, attacker, weapon)
                                return inst.tp_enemies[v] == nil
                            end,
                            fn = function(v, attacker, weapon)
                                inst.tp_enemies[v] = true
                            end,
                        }
                    )
                end
            end)
        end
        inst:DoTaskInTime(1, inst.WgRecycle)
    end,
    recycle = function(inst)
        inst.Physics:Stop()
        for _, fx in pairs(inst.tp_fxs) do
            fx:WgRecycle()
        end
        inst.tp_fxs = nil
        if inst.tp_task then
            inst.tp_task:Cancel()
            inst.tp_task = nil
        end
        if inst.tp_task2 then
            inst.tp_task2:Cancel()
            inst.tp_task2 = nil
        end
        inst.tp_enemies = nil
    end,
}

fxs.ice_spike = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.AnimState:SetBank("deerclops_icespike")
		inst.AnimState:SetBuild("deerclops_icespike")
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("spike"..math.random(4))
        inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/ice_small")
        inst:ListenForEvent("animover", inst.WgRecycle)
    end,
    recycle = function(inst)
        if inst.parent then
            inst:RemoveChild(inst.parent)
        end
        inst:RemoveEventCallback("animover", inst.WgRecycle)
    end,
}

-- fxs.line_fx = {
--     init = function(inst)
--         MakeInventoryPhysics(inst)
-- 		RemovePhysicsColliders(inst)
--     end,
--     wake = function(inst, data)
--         if data and data.angle then
--             inst:DoTaskInTime(0, function()
--                 inst.Transform:SetRotation(data.angle)
--             end)
--         end
--         inst.Physics:SetMotorVel(10, 0, 0)
--     end,
--     recycle = function(inst)
--         inst.Physics:Stop()
--     end,
-- }

fxs.line_fx = {
    init = function(inst)
        MakeInventoryPhysics(inst)
		RemovePhysicsColliders(inst)
    end,
    wake = function(inst, data)
        -- {angle/pos, speed}
        if data.angle then
            inst.Transform:SetRotation(data.angle)
        elseif data.pos then
            inst:ForceFacePoint(data.pos)
        end
        inst.Physics:SetMotorVel(data.speed or 10, 0, 0)
    end,
    recycle = function(inst)
        inst.Physics:Stop()
    end,
}

local blood_bubble_kill = function(inst)
    inst.AnimState:PlayAnimation(string.format("level%d_pst", inst.level))
    inst:DoTaskInTime(.3, inst.WgRecycle)
end

fxs.blood_bubble = {
    init = function(inst)
        inst.AnimState:SetBank("poison")
        inst.AnimState:SetBuild("poison")
        inst.AnimState:SetMultColour(1, .3, .3, 1)
        inst.kill = blood_bubble_kill
    end,
    wake = function(inst, data)
        local level = data.level or 1
        inst.level = level
        inst.AnimState:PlayAnimation(string.format("level%d_pre", level))
        inst.AnimState:PushAnimation(string.format("level%d_loop", level), true)
    end,
    recycle = function(inst)
        inst.level = nil
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.frozen_route = {
    init = function(inst)
        inst.work = function(master, child, owner, damage, dmg_mod)
            FxManager:MakeFx("ice_spike", child)
            EntUtil:make_area_dmg(child, 2, owner, damage, 
                nil, EntUtil:add_stimuli(nil, "ice"), {
                    fn = function(v, attacker, weapon)
                        EntUtil:frozen(v)
                        master.enemies[v] = true
                    end,
                    test = function(v, attackder, weapon)
                        return master.enemies[v] == nil
                    end,
                    calc = true,
                    mult = dmg_mod,
                })
        end
        inst.get_rot = function(n)
            if n > 1 then
                local angle = 60
                local gap = 60/(n-1)
                return gap
            end
        end
        inst.range = 7
    end,
    wake = function(inst, data)    
        inst.enemies = {}
        inst:DoTaskInTime(0, function()
            if data and data.pos then
                inst:ForceFacePoint(data.pos)
            end
            local rot = inst.Transform:GetRotation()
            for i = 1, inst.range do
                local gap = inst.get_rot(i)
                for j = 1, i do
                    local rot2 = 0
                    if i == 1 then
                        rot2 = rot
                    else
                        rot2 = rot+30-inst.get_rot(i)*(j-1)
                    end
                    local fx = FxManager:MakeFx("line_fx", inst, {angle=rot2})
                    local work_time = .15*i  -- 控制出现的位置
                    fx:DoTaskInTime(work_time, function()
                        inst:work(fx, data.owner, data.damage)
                        fx:WgRecycle()
                    end)
                end
            end
        end)
        inst:DoTaskInTime(2.1, inst.WgRecycle)
    end,
    recycle = function(inst)
        inst.enemies = nil
    end,
}

fxs.sleep_flame = {
    init = function(inst)
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
        inst.AnimState:SetBank("campfire_fire")
        inst.AnimState:SetBuild("campfire_fire")
        inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
        inst.AnimState:SetRayTestOnBB(true)
        inst.AnimState:PlayAnimation("level3", true)
    end,
    wake = function(inst, data)
        if data and data.angle then
            inst:DoTaskInTime(0, function()
                inst.Transform:SetRotation(data.angle)
            end)
        end
        inst.Physics:SetMotorVel(10, 0, 0)
        inst.task = inst:DoPeriodicTask(.1, function()
            local ent = FindEntity(inst, 2, function(target, inst)
                if EntUtil:check_combat_target(data.owner, target) then
                    return true
                end
            end, {}, {})
            if ent then
                EntUtil:get_attacked(ent, data.owner, data.damage, nil, 
                    EntUtil:add_stimuli(nil, "fire"))
                EntUtil:sleep(ent, 1, 10)
                inst:WgRecycle()
            end
        end)
        inst:DoTaskInTime(1, inst.WgRecycle)
    end,
    recycle = function(inst)
        inst.Physics:Stop()
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.sleep_fire = {
    init = function(inst)
    end,
    wake = function(inst, data)
        inst:DoTaskInTime(0, function()
            if data and data.pos then
                inst:ForceFacePoint(data.pos)
            end
            local rot = inst.Transform:GetRotation()
            for i = -2, 2 do
                local angle = 20*i+rot
                local fx = FxManager:MakeFx("sleep_flame", inst, {
                    angle=angle, owner=data.owner, damage=data.damage,
                })
            end
        end)
    end,
    recycle = function(inst)
    end,
}

fxs.laser = {
    init = function(inst)
        inst.AnimState:SetBank("laser_hits_sparks")
        inst.AnimState:SetBuild("laser_hit_sparks_fx")
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("hit_"..math.random(5))
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength()+2*FRAMES, inst.WgRecycle)
    end,
    recycle = function(inst)
    end,
}

fxs.laserscorch = {
    init = function(inst)
        inst.AnimState:SetBank("laser_burntground")
        inst.AnimState:SetBuild("burntground")
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
		inst.AnimState:SetSortOrder(3)
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("idle")
        inst.Transform:SetRotation(math.random() * 360)
        inst.alpha = 0
        inst.task = inst:DoPeriodicTask(0, function()
            inst.alpha = math.max(0, inst.alpha - (1/90) )
            inst.AnimState:SetMultColour(1, 1, 1,  inst.alpha)
            if inst.alpha == 0 then
                inst:WgRecycle()
            end
        end)
    end,
    recycle = function(inst)
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.lasertrail = {
    init = function(inst)
        inst.AnimState:SetBank("laser_smoke_fx")
        inst.AnimState:SetBuild("laser_smoke_fx")
        inst.AnimState:SetAddColour(1, 0, 0, 1)
		inst.AnimState:SetMultColour(1, 0, 0, 1)
		inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("idle")
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength()+2*FRAMES, inst.WgRecycle)
    end,
    recycle = function(inst)
    end,
}

fxs.laser_line = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        MakeInventoryPhysics(inst)
		RemovePhysicsColliders(inst)
    end,
    wake = function(inst, data)
        if data and data.pos then
            inst:DoTaskInTime(0, function()
                inst:ForceFacePoint(data.pos)
            end)
        end
        inst.Physics:SetMotorVel(20, 0, 0)
        inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/creatures/boss/hulk_metal_robot/laser")
        inst.task = inst:DoPeriodicTask(.05, function()
            FxManager:MakeFx("laser", inst)
            FxManager:MakeFx("laserscorch", inst)
            FxManager:MakeFx("lasertrail", inst)
        end, 0.1)
        inst:DoTaskInTime(.5, function()
            inst:WgRecycle()
        end)
    end,
    recycle = function(inst)
        inst.Physics:Stop()
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.blowdart = {
    init = function(inst)
        -- inst.Transform:SetFourFaced()
        inst.AnimState:SetBank("blow_dart")
        inst.AnimState:SetBuild("blow_dart")
        inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("dart_purple")
        if data and data.angle then
            inst:DoTaskInTime(0, function()
                inst.Transform:SetRotation(data.angle)
            end)
        end
        inst.Physics:SetMotorVel(30, 0, 0)
        inst.task = inst:DoPeriodicTask(.1, function()
            local ent = FindEntity(inst, 1.5, function(target, inst)
                if EntUtil:check_combat_target(data.owner, target) then
                    return true
                end
            end, {}, {})
            if ent then
                EntUtil:get_attacked(ent, data.owner, 0, data.weapon, 
                    EntUtil:add_stimuli(nil, "spike"), true, 
                    data.dmg_mod)
                local impactfx = SpawnPrefab("impact")
                if impactfx and data.owner then
                    local follower = impactfx.entity:AddFollower()
                    follower:FollowSymbol(ent.GUID, ent.components.combat.hiteffectsymbol, 0, 0, 0 )
                    impactfx:FacePoint(data.owner.Transform:GetWorldPosition())
                end
                inst:WgRecycle()
            end
        end)
        inst:DoTaskInTime(1, inst.WgRecycle)
    end,
    recycle = function(inst)
        inst.Physics:Stop()
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.mult_blowdart = {
    init = function(inst)
    end,
    wake = function(inst, data)
        if data and data.pos then
            inst:DoTaskInTime(0, function()
                inst:ForceFacePoint(data.pos)
                local rot = inst.Transform:GetRotation()
                for i = -1, 1 do
                    inst:DoTaskInTime(.1*i, function()
                        local angle = rot+10*i
                        FxManager:MakeFx("blowdart", inst, {
                            angle=angle, owner=data.owner, 
                            weapon=data.weapon, dmg_mod=data.dmg_mod,
                        })
                    end)
                end
            end)
        end
        inst:DoTaskInTime(.5, inst.WgRecycle)
    end,
    recycle = function(inst)
    end,
}

fxs.throw_spear = {
    init = function(inst, data)
        inst.AnimState:SetBank("speargun")
        inst.AnimState:SetBuild("speargun_empty")
        inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround)
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("spear_spear")
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.bishop_attack = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.AnimState:SetBuild("bishop_attack")
        inst.AnimState:SetBank("bishop_attack")
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
    end,
    wake = function(inst, data)
        inst.SoundEmitter:PlaySound(Sounds.bishop_charge)
        inst.AnimState:PlayAnimation("idle")
        if data.angle then
            inst.Transform:SetRotation(data.angle)
        elseif data.pos then
            inst:ForceFacePoint(data.pos)
        end
        inst.Physics:SetMotorVel(30, 0, 0)
        inst.task = inst:DoPeriodicTask(.1, function()
            local ent = FindEntity(inst, 2, function(target, inst)
                if EntUtil:check_combat_target(data.owner, target) then
                    return true
                end
            end, nil, EntUtil.not_enemy_tags)
            if ent then
                EntUtil:get_attacked(ent, data.owner, 0, data.weapon, 
                    EntUtil:add_stimuli(nil, "electric"), true)
                inst:WgRecycle()
            end
        end)
        inst:DoTaskInTime(1, inst.WgRecycle)
    end,
    recycle = function(inst)
        inst.Physics:Stop()
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.spear_magic_circle = {
    init = function(inst)
        fxs.magic_center.init(inst)
        inst.child_fx = "throw_spear"
        -- inst.child_data = {}
        inst.num = 4
        inst.step = 14
        inst.width = 2
        -- inst.height = 1
        inst.const_height = 1
    end,
    wake = function(inst, data)
        -- 不要AddChild这个fx, 传入data.owner, 会自行设置位置跟随
        fxs.magic_center.wake(inst, data)
        -- inst.child_data = {owner=data.owner}
        inst.child_fn = function(fx)
            fx:ForceFacePoint(data.owner:GetPosition())
            local rot = fx.Transform:GetRotation()
            fx.Transform:SetRotation(rot+180)
        end
        if data then
            inst.owner = data.owner
            inst.target = data.target
        end
        -- inst.task2 = inst:DoPeriodicTask(FRAMES, function()
        --     if inst.owner and EntUtil:is_alive(inst.owner) then
        --         local pt = inst.owner:GetPosition()
        --         inst.Transform:SetPosition(pt:Get())
        --     end
        -- end)
        inst.task3 = inst:DoPeriodicTask(1, function()
            EntUtil:make_area_dmg(data.owner, 4, data.owner, 
                data.damage, nil, EntUtil:add_stimuli(nil, "spike"))
        end)
        inst:DoTaskInTime(10, inst.WgRecycle)
    end,
    recycle = function(inst)
        fxs.magic_center.recycle(inst)
        -- if inst.task2 then
        --     inst.task2:Cancel()
        --     inst.task2 = nil
        -- end
        if inst.task3 then
            inst.task3:Cancel()
            inst.task3 = nil
        end
        inst.owner = nil
        inst.target = nil
    end,
}

fxs.deerclops_power = {
    init = function(inst)
        inst.AnimState:SetBank("deerclops")
        inst.AnimState:SetBuild("deerclops_build")
        inst.AnimState:SetMultColour(1,1,1,.3)
        inst.Transform:SetFourFaced()
    end,
    wake = function(inst, data)
        inst:DoTaskInTime(0, function()
            local rot = data.owner.Transform:GetRotation()
            inst.Transform:SetRotation(rot)
        end)
        inst.AnimState:PlayAnimation("taunt")
        inst.event_fn = EntUtil:listen_for_event(inst, "animover",
            function(inst, _data)
                local pos = inst:GetPosition()
                for i = 1, 1 do
                    FxManager:MakeFx("snow_ball_dropper", pos, {owner=data.owner})
                end
                inst:WgRecycle()
            end
        )
    end,
    recycle = function(inst, data)
        inst:RemoveEventCallback("animover", inst.event_fn)
        inst.event_fn = nil
    end,
}

fxs.dragonfly_power = {
    init = function(inst)
        inst.AnimState:SetBank("dragonfly")
        inst.AnimState:SetBuild("dragonfly_build")
        inst.AnimState:SetMultColour(1,1,1,.3)
        inst.Transform:SetFourFaced()
    end,
    wake = function(inst, data)
        inst:DoTaskInTime(0, function()
            local rot = data.owner.Transform:GetRotation()
            inst.Transform:SetRotation(rot)
        end)
        inst.AnimState:PlayAnimation("taunt")
        inst:ListenForEvent("animover", inst.WgRecycle)
        local delay = 0.0
        for i = 1, 6 do
            data.owner:DoTaskInTime(1+delay, function(inst)
                local target = inst.components.combat.target or inst
                local pos = Vector3(target.Transform:GetWorldPosition())
                local x, y, z = TUNING.VOLCANOBOOK_FIRERAIN_RADIUS * UnitRand() + pos.x, pos.y, TUNING.VOLCANOBOOK_FIRERAIN_RADIUS * UnitRand() + pos.z
                local firerain = SpawnPrefab("firerain")
                firerain.Transform:SetPosition(x, y, z)
                firerain:StartStep()
                firerain.tp_owner = inst
            end)
            delay = delay + TUNING.VOLCANOBOOK_FIRERAIN_DELAY
        end
    end,
    recycle = function(inst, data)
        inst:RemoveEventCallback("animover", inst.WgRecycle)
    end,
}

fxs.bearger_power = {
    init = function(inst)
        inst.AnimState:SetBank("bearger")
        inst.AnimState:SetBuild("bearger_build")
        inst.AnimState:SetMultColour(1,1,1,.3)
        inst.Transform:SetFourFaced()
    end,
    wake = function(inst, data)
        inst:DoTaskInTime(0, function()
            local rot = data.owner.Transform:GetRotation()
            inst.Transform:SetRotation(rot)
        end)
        inst.AnimState:PlayAnimation("taunt")
        inst.event_fn = EntUtil:listen_for_event(inst, "animover",
            function(inst, _data)
                local pos = inst:GetPosition()
                FxManager:MakeFx("bearger_line", pos, {owner=data.owner})
                inst:WgRecycle()
            end
        )
    end,
    recycle = function(inst)
        inst:RemoveEventCallback("animover", inst.event_fn)
        inst.event_fn = nil
    end,
}

fxs.moose_power = {
    init = function(inst)
        inst.AnimState:SetBank("goosemoose")
        inst.AnimState:SetBuild("goosemoose_build")
        inst.AnimState:SetMultColour(1,1,1,.3)
        inst.Transform:SetFourFaced()
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("taunt")
        inst:DoTaskInTime(0, function()
            local rot = data.owner.Transform:GetRotation()
            inst.Transform:SetRotation(rot)
        end)
        inst.event_fn = EntUtil:listen_for_event(inst, "animover",
            function(inst, _data)
                local pos = inst:GetPosition()
                local function getspawnlocation(inst, target)
                    local tarPos = target:GetPosition()
                    local pos = inst:GetPosition()
                    local vec = tarPos - pos
                    vec = vec:Normalize()
                    local dist = pos:Dist(tarPos)
                    return pos + (vec * (dist * .15))
                end
                local target = data.owner.components.combat.target
                if target and not target:HasTag("tp_wind_power")
                and EntUtil:is_alive(data.owner) then
                    if target.components.inventory then
                        target.components.inventory:DropEverything()
                    end
                    local tornado = SpawnPrefab("tornado")
                    tornado.WINDSTAFF_CASTER = data.owner
                    tornado:ListenForEvent("death", data.owner.Remove, data.owner)
                    local totalRadius = target.Physics and target.Physics:GetRadius() or 0.5 + tornado.Physics:GetRadius() + 0.5
                    local targetPos = target:GetPosition() + (TheCamera:GetDownVec() * totalRadius)
                    tornado.Transform:SetPosition(getspawnlocation(data.owner, target):Get())
                    tornado.components.knownlocations:RememberLocation("target", targetPos)
                end
                inst:WgRecycle()
            end
        )
    end,
    recycle = function(inst)
        inst:RemoveEventCallback("animover", inst.event_fn)
        inst.event_fn = nil
    end,
}

fxs.minotaur_power = {
    init = function(inst)
        inst.AnimState:SetBank("rook")
        inst.AnimState:SetBuild("rook_rhino")
        inst.AnimState:SetMultColour(1, 1, 1, .3)
		inst.Transform:SetFourFaced()
    end,
    wake = function(inst, data)
        inst:DoTaskInTime(0, function()
            local rot = data.owner.Transform:GetRotation()
            inst.Transform:SetRotation(rot)
        end)
        inst.AnimState:PlayAnimation("taunt")
        inst.event_fn = EntUtil:listen_for_event(inst, "animover",
            function(inst, _data)
                local pos = inst:GetPosition()
                FxManager:MakeFx("minotaur_charge", pos, {owner=data.owner})
                inst:WgRecycle()
            end
        )
    end,
    recycle = function(inst)
        inst:RemoveEventCallback("animover", inst.event_fn)
        inst.event_fn = nil
    end,
}

fxs.forest_dragon_acorn = {
    init = function(inst)
        inst.AnimState:SetBank("acorn")
        inst.AnimState:SetBuild("acorn")
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("idle")
        for i = 0, 3 do
            inst:DoTaskInTime(.05*i, function()
                inst.AnimState:SetMultColour(1,1,1,3/4-i*1/4)
            end)
        end
        inst:DoTaskInTime(.4, inst.WgRecycle)
    end,
    recycle = function(inst)
    end,
}

fxs.city_lamp = {
    init = function(inst)
        Kit:make_light(inst, "city_lamp")
        inst.Light:Enable(false)
    end,
    wake = function(inst, data)
        inst.Light:Enable(true)
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
        inst.Light:Enable(false)
    end,
}

fxs.combat_fx = {
    init = function(inst)
        inst:AddComponent("combat")
    end,
}

fxs.blood = {
    init = function(inst)
        inst.AnimState:SetBank("poison")
        inst.AnimState:SetBuild("poison")
        inst.AnimState:SetMultColour(1, .3, .3, 1)
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("level2_pre")
        -- inst.AnimState:PushAnimation("level2_loop", false)
        inst.AnimState:PushAnimation("level2_pst", false)
        inst:ListenForEvent("animqueueover", inst.WgRecycle)
    end,    
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
        inst:RemoveEventCallback("animqueueover", inst.WgRecycle)
    end,
}

fxs.poison_hole_bubble = {
    init = function(inst)
        -- inst.entity:AddSoundEmitter()
        inst.AnimState:SetBank("poison_hole")
        inst.AnimState:SetBuild("poison_hole")
        inst.AnimState:PlayAnimation("pop")
		inst.AnimState:Hide('Layer 165')
    end,
    wake = function(inst, data)
        -- inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/poisonswamp_attack")
        inst.AnimState:PlayAnimation("pop")
        inst:ListenForEvent("animover", inst.WgRecycle)
    end,
    recycle = function(inst)
        inst:RemoveEventCallback("animover", inst.WgRecycle)
    end,
}

fxs.rapid_direcannon = {
    init = function(inst)
        -- inst.AnimState:SetBank("butterfly")
        -- inst.AnimState:SetBuild("butterfly_basic")   
        -- inst.AnimState:SetMultColour(1, 1, 1, .6)
    end,
    wake = function(inst, data)
        -- inst.AnimState:PlayAnimation("idle_flight_loop", true)
    end,
    recycle = function(inst, data)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.stride_breaker_fx = {
    init = function(inst)
        inst.AnimState:SetBank("the_fx05")
        inst.AnimState:SetBuild("the_fx05")
        inst.AnimState:SetScale(4, 4, 4)
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("idle")
        inst:ListenForEvent("animover", inst.WgRecycle)
    end,
    recycle = function(inst, data)
        inst:RemoveEventCallback("animover", inst.WgRecycle)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.galeforce_fx = {
    init = function(inst)
        inst.AnimState:SetBank("the_fx22")
        inst.AnimState:SetBuild("the_fx22")
        inst.AnimState:PlayAnimation("idle", true)
        inst.AnimState:SetMultColour(1, 1, 1, .6)
    end,
    wake = function(inst, data)
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.recover_equip_fx = {
    init = function(inst)
        -- inst.AnimState:SetBank("amulets")
        -- inst.AnimState:SetBuild("amulets")   
        -- inst.AnimState:SetMultColour(1, 1, 1, .6)
        -- inst.AnimState:PlayAnimation("redamulet")
        -- -- inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
        -- inst.AnimState:SetLayer(LAYER_BACKGROUND)
		-- inst.AnimState:SetSortOrder(3)
    end,
    wake = function(inst, data)
    end,
    recycle = function(inst, data)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.groundpoundring_fx = {
    init = function(inst)
        local anim = inst.AnimState
        anim:SetBank("bearger_ring_fx")
        anim:SetBuild("bearger_ring_fx")
        anim:SetFinalOffset(-1)
        anim:SetOrientation( ANIM_ORIENTATION.OnGround )
        anim:SetLayer( LAYER_BACKGROUND )
        anim:SetSortOrder( 3 )
    end,
    wake = function(inst)
        inst.AnimState:PlayAnimation("idle")
        inst:ListenForEvent("animover", inst.WgRecycle)
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
        inst:RemoveEventCallback("animover", inst.WgRecycle)
    end,
}

-- fxs.tp_armor_jax_fx = {
--     init = function(inst)
--         fxs.magic_center.init(inst)
--         inst.child_fx = "anim_fx"
--         inst.child_data = {anim={"boomerang", "boomerang", "spin_loop", true}}
--         -- inst.child_data = {}
--         inst.num = 4
--         inst.step = 14
--         inst.width = 2
--         -- inst.height = 1
--         inst.const_height = 1
--     end,
--     wake = function(inst, data)
--         fxs.magic_center.wake(inst, data)
--         if data then
--             inst.owner = data.owner
--         end
--         inst.task2 = inst:DoPeriodicTask(FRAMES, function()
--             if inst.owner and EntUtil:is_alive(inst.owner) then
--                 local pt = inst.owner:GetPosition()
--                 inst.Transform:SetPosition(pt:Get())
--             end
--         end)
--         inst:DoTaskInTime(10, inst.WgRecycle)
--     end,
--     recycle = function(inst)
--         fxs.magic_center.recycle(inst)
--         if inst.task2 then
--             inst.task2:Cancel()
--             inst.task2 = nil
--         end
--         inst.owner = nil
--     end,
-- }

fxs.poison_debuff_fx = {  
    init = function(inst)
        inst.AnimState:SetBank("the_fxr46")
        inst.AnimState:SetBuild("the_fxr46")   
        inst.AnimState:SetPercent("idle", 0)
    end,
    wake = function(inst, data)
        inst.y = 0
        inst.s = .5
        inst.task = inst:DoPeriodicTask(.1, function()
            inst.y = inst.y + .2
            local pos = inst:GetPosition()
            inst.Transform:SetPosition(pos.x, inst.y, pos.z)
            inst.s = inst.s + .05
            inst.AnimState:SetScale(inst.s, inst.s, inst.s)
        end)
        inst:DoTaskInTime(1.3, inst.WgRecycle)
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end
}

fxs.leaf = {
    init = function(inst)
        inst.anims = {
            {"tree_leaf_fx", "tree_leaf_fx_green", "fall", },
            {"tree_leaf_fx", "tree_leaf_fx_green", "chop", },
            {"chop_mangrove", "chop_mangrove", "chop", },
            {"chop_mangrove", "chop_mangrove", "fall", },
        }
    end,
    wake = function(inst, data)
        local n = math.random(1, #inst.anims)
        local t = inst.anims[n]
        inst.AnimState:SetBank(t[1])
        inst.AnimState:SetBuild(t[2])
        inst.AnimState:PlayAnimation(t[3])
        inst:ListenForEvent("animover", inst.WgRecycle)
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
        inst:RemoveEventCallback("animover", inst.WgRecycle)
    end,
}

fxs.large_fire = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.AnimState:SetBank("fire")
        inst.AnimState:SetBuild("fire")   
        inst.AnimState:PlayAnimation("level4", true)
        inst.AnimState:SetRayTestOnBB(true)
        inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    end,
    wake = function(inst, data)
        inst.SoundEmitter:PlaySound("dontstarve/common/forestfire", "fire")
        inst.SoundEmitter:SetParameter("fire", "intensity", 1)
        inst:DoTaskInTime(1, inst.WgRecycle)
    end,
    recycle = function(inst)
        inst.SoundEmitter:KillSound("fire")
    end
}

fxs.lunge_fire = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.AnimState:SetBank("fire")
        inst.AnimState:SetBuild("fire")   
        inst.AnimState:PlayAnimation("level2", true)
        inst.AnimState:SetRayTestOnBB(true)
        inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    end,
    wake = function(inst, data)
        inst.SoundEmitter:PlaySound("dontstarve/common/forestfire", "fire")
        inst.SoundEmitter:SetParameter("fire", "intensity", 1)
        EntUtil:make_area_dmg(inst, 3.3, data.owner, 20, data.weapon, 
            EntUtil:add_stimuli(nil, "fire", "lunge")
        )
        inst:DoTaskInTime(1, inst.WgRecycle)
    end,
    recycle = function(inst)
        inst.SoundEmitter:KillSound("fire")
    end
}

fxs.lunge_ice = {
    init = function(inst)
    end,
    wake = function(inst, data)
        local pos = inst:GetPosition()
        local angle = data.owner.Transform:GetRotation()
        for i = -1, 1 do
            if i ~= 0 then
                local x = math.cos(angle+90*i)*1.5
                local z = math.sin(angle+90*i)*1.5
                FxManager:MakeFx("ice_spike", pos+Vector3(x,0,z))
            end
        end
        EntUtil:make_area_dmg(inst, 3.3, data.owner, 20, data.weapon, 
            EntUtil:add_stimuli(nil, "ice", "lunge")
        )
        inst:DoTaskInTime(.5, inst.WgRecycle)
    end,
    recycle = function(inst)
    end
}

fxs.lunge_dragonfly = {
    init = function(inst)
        inst.AnimState:SetBank("dragonfly")
        inst.AnimState:SetBuild("dragonfly_fire_build")
        inst.AnimState:SetMultColour(1,1,1,.3)
        inst.Transform:SetFourFaced()
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
    end,
    wake = function(inst, data)
        local rot = data.owner.Transform:GetRotation()
        inst.Transform:SetRotation(rot)
        inst.AnimState:PlayAnimation("atk")
        local attackfx = FxManager:MakeFx("attackfire_fx", Vector3(0,0,0))
        -- attackfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        -- attackfx.Transform:SetRotation(inst.Transform:GetRotation())
        inst.fx = inst:AddChild(attackfx)
        fade_in(inst, .3)
        inst:DoTaskInTime(.3, function()
            inst.Physics:SetMotorVel(30, 0, 0)
            inst.enemies = {}
            inst.task = inst:DoPeriodicTask(.1, function()
                EntUtil:make_area_dmg(inst, 4, data.owner, 200, nil, 
                    EntUtil:add_stimuli(nil, "fire", "lunge"), 
                    {
                        calc = true,
                        test = function(v, attacker, weapon)
                            return not inst.enemies[v]
                        end,
                        fn = function(v, attacker, weapon)
                            inst.enemies[v] = true
                        end,
                    }
                )
                FxManager:MakeFx("large_fire", inst)
            end)
        end)
        inst:DoTaskInTime(1, inst.WgRecycle)
        -- inst:ListenForEvent("animover", inst.WgRecycle)
    end,
    recycle = function(inst)
        inst.enemies = nil
        inst.Physics:Stop()
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
        if inst.fx then
            inst.fx:WgRecycle()
            inst.fx = nil
        end
        -- inst:RemoveEventCallback("animover", inst.WgRecycle)
    end
}

fxs.firering_fx = {
    init = function(inst)
        inst.AnimState:SetBank("dragonfly_ring_fx")
        inst.AnimState:SetBuild("dragonfly_ring_fx")
        inst.AnimState:SetFinalOffset(-1)

        inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
        inst.AnimState:SetLayer( LAYER_BACKGROUND )
        inst.AnimState:SetSortOrder( 3 )

        inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    end,
    wake = function(inst)
        inst.AnimState:PlayAnimation("idle")
        inst:ListenForEvent("animover", inst.WgRecycle)
    end,
    recycle = function(inst)
        inst:RemoveEventCallback("animover", inst.WgRecycle)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.solar_pieces = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.work = function(master, child, owner, damage)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp_voice")
            FxManager:MakeFx("firering_fx", child)
            FxManager:MakeFx("firesplash_fx", child)
            EntUtil:make_area_dmg(child, 8, owner, damage, 
                nil, EntUtil:add_stimuli(nil, "fire", "magic"), {
                    fn = function(v, attacker, weapon)
                        -- EntUtil:frozen(v)
                        master.enemies[v] = true
                    end,
                    test = function(v, attackder, weapon)
                        return master.enemies[v] == nil
                    end,
                    calc = true,
                })
        end
        inst.get_rot = function(n)
            if n > 1 then
                local angle = 60
                local gap = 60/(n-1)
                return gap
            end
        end
        inst.range = 3
    end,
    wake = function(inst, data)    
        -- data = {pos, owner, damage}
        inst.enemies = {}
        if data.pos then
            inst:ForceFacePoint(data.pos)
        end
        local rot = inst.Transform:GetRotation()
        -- start number
        for i = 2, inst.range do
            local gap = inst.get_rot(i)
            for j = 1, i do
                local rot2 = 0
                if i == 1 then
                    rot2 = rot
                else
                    rot2 = rot+40-inst.get_rot(i)*(j-1)
                end
                local fx = FxManager:MakeFx("line_fx", inst, {angle=rot2, speed=30})
                local work_time = .15*i  -- 控制出现的位置
                fx:DoTaskInTime(work_time, function()
                    inst:work(fx, data.owner, data.damage)
                    fx:WgRecycle()
                end)
            end
        end
        inst:DoTaskInTime(2.1, inst.WgRecycle)
    end,
    recycle = function(inst)
        inst.enemies = nil
    end,
}

for k, v in pairs({
    fire = {255/255, 140/255, .2, 1},
    ice = {.2, 1, 1, 1},
    shadow = {1, .2, 1, 1},
    wind = {.2, 254/255, 154/255, 1},
    holly = {1, 1, .2, 1},
    blood = {1, .2, .2, 1},
    electric = {2., .2, 1, 1},
    poison = {.2, 1, .2, 1},
}) do
    fxs[k.."_bean"] = {
        init = function(inst)
            -- {owner, pos/angle, [weapon], damage, [calc]}
            inst.AnimState:SetBank("the_fxc66")
            inst.AnimState:SetBuild("the_fxc66")
            inst.AnimState:PlayAnimation("idle")
            inst.AnimState:SetMultColour(unpack(v))
            inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround)
            -- MakeInventoryPhysics(inst)
            -- RemovePhysicsColliders(inst)
            make_emitter_physics(inst)
        end,
        wake = function(inst, data)
            shoot_emitter(inst, data, 22, 2, data.damage, 
                EntUtil:add_stimuli(nil, k, "magic"),
                nil, 1
            )
        end,
        recycle = function(inst)
        end,
    }
    fxs[k.."_arrow"] = {
        init = function(inst)
            -- {owner, pos/angle, [weapon], damage, [calc]}
            inst.AnimState:SetBank("the_fxc65")
            inst.AnimState:SetBuild("the_fxc65")
            inst.AnimState:PlayAnimation("idle")
            inst.AnimState:SetMultColour(unpack(v))
            inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround)
            -- MakeInventoryPhysics(inst)
            -- RemovePhysicsColliders(inst)
            make_emitter_physics(inst)
        end,
        wake = function(inst, data)
            shoot_emitter(inst, data, 25, 2, data.damage, 
                EntUtil:add_stimuli(nil, k, "magic"),
                nil, 1
            )
        end,
        recycle = function(inst)
        end,
    }
    fxs[k.."_ball"] = {
        init = function(inst)
            -- {owner, pos/angle, [weapon], damage, [calc]}
            inst.AnimState:SetBank("the_fxc64")
            inst.AnimState:SetBuild("the_fxc64")
            inst.AnimState:PlayAnimation("idle", true)
            inst.AnimState:SetMultColour(unpack(v))
            inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround)
            -- MakeInventoryPhysics(inst)
            -- RemovePhysicsColliders(inst)
            make_emitter_physics(inst)
        end,
        wake = function(inst, data)
            shoot_emitter(inst, data, 30, 2, data.damage, 
                EntUtil:add_stimuli(nil, k, "magic"),
                nil, 1
            )
        end,
        recycle = function(inst)
        end,
    }
end

fxs.ice_super_ball = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.AnimState:SetBank("the_fxc64")
        inst.AnimState:SetBuild("the_fxc64")
        inst.AnimState:PlayAnimation("idle", true)
        inst.AnimState:SetMultColour(.2, 1, 1, 1)
        inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetScale(1.5, 1, 1.5)
        -- MakeInventoryPhysics(inst)
        -- RemovePhysicsColliders(inst)
        make_emitter_physics(inst)
    end,
    wake = function(inst, data)
        -- {owner, pos/angle, [weapon], damage, [calc]}
        inst:DoTaskInTime(.7, function()
            inst.arrow = true
        end)
        inst.task = inst:DoPeriodicTask(.33, function()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/ice_small")
            if inst.arrow then
                local rot = inst.Transform:GetRotation()
                for i = 1, 5 do
                    local angle = rot+60*i
                    -- 不要deepcopy(data), 里面有data.owner,会浪费很多内存和计算
                    local fx = FxManager:MakeFx("ice_arrow", inst, {
                        owner = data.owner, angle=angle, damage=data.damage*.5
                    })
                end
            else
                local rot = inst.Transform:GetRotation()
                for i = 1, 5 do
                    local angle = rot+60*i
                    local fx = FxManager:MakeFx("ice_bean", inst, {
                        owner = data.owner, angle=angle, damage=data.damage*.3
                    })
                end
            end
        end)
        do_line_damage(inst, data, 30, 2, data.damage, 
            EntUtil:add_stimuli(nil, "ice", "magic"),
            data.calc, 1, nil, nil
        )
    end,
    recycle = function(inst)
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
        inst.arrow = nil
    end,
}

fxs.ice_flower = {
    init = function(inst)
    end,
    wake = function(inst, data)
        -- {owner, [weapon], damage, [calc]}
        local friends = {}
        for i = 1, 6 do
            local angle = i*60
            local fx = FxManager:MakeFx("line_fx", inst, {angle=angle})
            table.insert(friends, fx)
            fx.friends = friends
            fx.task = fx:DoPeriodicTask(.15, function()
                local pos = fx:GetPosition()
                FxManager:MakeFx("ice_spike", pos)
                for i = -1, 1 do
                    if i ~= 0 then
                        local x = math.cos(angle+90*i)*1.5
                        local z = math.sin(angle+90*i)*1.5
                        FxManager:MakeFx("ice_spike", pos+Vector3(x,0,z))
                    end
                end
            end)
            do_line_damage(fx, 
                {owner=data.owner, angle=angle, weapon=data.weapon},
                10, 3, data.damage, EntUtil:add_stimuli(nil, "ice", "magic"),
                data.calc, 1.06, 
                function(v, attacker, weapon)
                    if inst.friends then
                        for _, f in pairs(inst.friends) do
                            if f.enemies and f.enemies[v] then
                                return false
                            end
                        end
                    end
                    return not fx.enemies[v]
                end, function(v, attacker, weapon)
                    fx.enemies[v] = true
                    EntUtil:frozen(v)
                end, function(inst)
                    if fx.task then
                        fx.task:Cancel()
                        fx.task = nil
                    end
                end
            )
        end
    end,
    recycle = function(inst)
    end
}

fxs.ice_meteor = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.Transform:SetTwoFaced()
        inst.AnimState:SetBank("tp_meteor")
        inst.AnimState:SetBuild("tp_meteor")
        inst.AnimState:SetMultColour(.2, 1, 1, 1)
    end,
    wake = function(inst, data)
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bomb_fall")
        inst.AnimState:PlayAnimation("crash")
        -- inst:ListenForEvent("animover", inst.WgRecycle)
        inst:DoTaskInTime(.5, function()
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano/volcano_rock_smash")
            inst:WgRecycle()
        end)
    end,
    recycle = function(inst)
        -- inst:RemoveEventCallback("animover", inst.WgRecycle)
    end,
}

fxs.ice_storm = {
    init = function(inst)
        -- inst.AnimState:SetBank("log")
        -- inst.AnimState:SetBuild("log")
        -- inst.AnimState:PlayAnimation("idle")
    end,
    wake = function(inst, data)
        -- {owner, [weapon], damage}
        for i = 1, 6 do
            local angle = i*60
            inst:DoTaskInTime(.1*i, function()
                local x = math.cos(angle) * math.random(4,5)+math.random()
                local z = math.sin(angle) * math.random(4,5)+math.random()
                local pos = inst:GetPosition()
                FxManager:MakeFx("ice_meteor", pos+Vector3(x, 0, z))
            end)
        end
        for i = 1, 2 do
            inst:DoTaskInTime(.3*i, function()
                EntUtil:make_area_dmg(inst, 8, data.owner, data.damage, nil, 
                    EntUtil:add_stimuli(nil, "ice", "magic"), {
                        fn = function(v, attacker, weapon)
                            EntUtil:frozen(v)
                        end
                    }
                )
            end)
        end
        inst:DoTaskInTime(1, inst.WgRecycle)
    end,
    recycle = function(inst)
    end,
}

fxs.fire_pulse = {
    init = function(inst)
        -- MakeInventoryPhysics(inst)
        -- RemovePhysicsColliders(inst)
        make_emitter_physics(inst)
    end,
    wake = function(inst, data)
        inst.task = inst:DoPeriodicTask(.15, function()
            FxManager:MakeFx("large_fire", inst)
        end)
        do_line_damage(inst, data, 20, 4, nil, 
            nil,
            nil, 1
        )
        inst.task = inst:DoPeriodicTask(.1, function()
            EntUtil:make_area_dmg(inst, 4, data.owner, data.damage, data.weapon, 
                EntUtil:add_stimuli(nil, "fire", "magic"), {
                test = function(v, attacker, weapon)
                    if inst.friends then
                        for _, f in pairs(inst.friends) do
                            if f.enemies and f.enemies[v] then
                                return false
                            end
                        end
                    end
                    return not inst.enemies[v]
                end,
                fn = function(v, attacker, weapon)
                    inst.enemies[v] = true
                end,
                calc = nil
            })
        end)
        if math.random() < .1 then
            EntUtil:ignite(inst)
        end
    end,
    recycle = function(inst)
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.shadow_burst = {
    init = function(inst)
        inst.AnimState:SetBank("the_fxc64")
        inst.AnimState:SetBuild("the_fxc64")
        inst.AnimState:PlayAnimation("idle", true)
        inst.AnimState:SetMultColour(1,.2,1,1)
        inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround)
        make_emitter_physics(inst)
    end,
    wake = function(inst, data)
        -- {owner, angle, pos, [weapon], damage, [calc]}
        inst.Transform:SetRotation(data.angle)
        inst.Physics:SetMotorVel(20,0,0)
        inst:DoTaskInTime(.3, function()
            inst.direct = true
        end)
        inst.task = inst:DoPeriodicTask(.1, function()
            if inst.direct == nil then
                local rot = inst.Transform:GetRotation()%360
                local angle = inst:GetAngleToPoint(data.pos:Get())%360
                -- 在-180, 180度内转弯才不会一下子转到后面去
                local dt = (angle-rot+180)%360-180
                if math.floor(dt) > 0 then
                    -- 角度差越大,转动角度越大,但不大于60,不小于10
                    local dt = math.min(60, math.max(10, math.abs(dt)/2))
                    -- 防止转过头了
                    rot = math.min(angle, rot+dt)
                elseif math.floor(dt) < 0 then
                    local dt = math.min(60, math.max(10, math.abs(dt)/2))
                    rot = math.max(angle, rot-dt)
                else
                    rot = angle
                    -- 方向正确后,不再转动
                    inst.direct = true
                end
                inst.Transform:SetRotation(rot)
            end
            local ent = FindEntity(inst, 2, function(target, inst)
                if EntUtil:check_combat_target(data.owner, target) then
                    return true
                end
            end, nil, EntUtil.not_enemy_tags)
            if ent then
                EntUtil:get_attacked(ent, data.owner, data.damage, data.weapon, 
                    EntUtil:add_stimuli(nil, "shadow", "magic"),
                    data.calc
                )
                inst:WgRecycle()
            end
        end)
        inst:DoTaskInTime(1, inst.WgRecycle)
    end,
    recycle = function(inst)
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
        inst.direct = nil
        inst.Physics:Stop()
    end,
}

fxs.shadow_sword = {
    init = function(inst)
        inst.Transform:SetFourFaced()
        inst.AnimState:SetScale(1.7,1.7,1.7)
        inst.AnimState:SetMultColour(1,1,1,.7)
        inst.AnimState:SetBank("wilson")
        inst.AnimState:SetBuild("tp_invisible_man")
        inst.AnimState:OverrideSymbol("swap_object", "tp_scroll_shadow_sword", "swap_object")
    end,
    wake = function(inst, data)
        local angle = data.owner.Transform:GetRotation()
        inst.Transform:SetRotation(angle)
        local angle = angle%360
        inst.AnimState:PlayAnimation("atk_prop_pre")
        inst.AnimState:PushAnimation("atk_prop", false)
        inst:DoTaskInTime(.2, function()
            inst.enemies = {}
            EntUtil:make_area_dmg(data.owner, 12, data.owner, data.damage, nil,
                EntUtil:add_stimuli(nil, "shadow", "magic"),
                {
                    test = function(v, attacker, weapon)
                        if not inst.enemies[v] then
                            -- 目标面向我的角度 和 我的角度超过90度, 即在我的面前
                            local pos = data.owner:GetPosition()
                            local angle2 = v:GetAngleToPoint(pos:Get())%360
                            if math.abs(angle-angle2)>90 then
                                return true
                            end
                        end
                    end,
                    fn = function(v, attacker, weapon)
                        inst.enemies[v] = true
                    end,
                    calc = data.calc,
                }
            )
        end)
        inst:ListenForEvent("animqueueover", inst.WgRecycle)
    end,
    recycle = function(inst)
        inst.enemies = nil
        inst:RemoveEventCallback("animqueueover", inst.WgRecycle)
    end
}

fxs.scroll_wind1 = {
    init = function(inst)
        local sound = inst.entity:AddSoundEmitter()
        local anim = inst.AnimState
        anim:SetBank("tornado")
        anim:SetBuild("tornado")
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
    end,
    wake = function(inst, data)
        -- {owner, pos, angle, damage}
        inst.Transform:SetRotation(data.angle)
        inst.Physics:SetMotorVel(20, 0, 5)
        local anim = inst.AnimState
        anim:PlayAnimation("tornado_pre")
        anim:PushAnimation("tornado_loop")
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tornado", "spinLoop")
        inst.enemies = {}
        inst.speed_x = 20
        inst.speed_z = 5
        inst.task = inst:DoPeriodicTask(.2, function()
            EntUtil:make_area_dmg(inst, 2, data.owner, 
                function(v,attacker,weaopn,reason)
                    if inst.enemies[v] then
                        return data.damage/5
                    end
                    return data.damage
                end, nil, 
                EntUtil:add_stimuli(nil, "wind", "magic"),
                {
                    fn = function(v,attacker,weapon)
                        inst.enemies[v] = true
                    end,
                }
            )
            local pos = inst:GetPosition()
            if distsq(pos, data.pos) > 10*10  then
                inst.speed_x = - inst.speed_x
                inst.Physics:SetMotorVel(inst.speed_x, 0, inst.speed_z)
            end
        end)
        inst.task2 = inst:DoPeriodicTask(.5, function()
            inst.speed_z = - inst.speed_z
            inst.Physics:SetMotorVel(inst.speed_x, 0, inst.speed_z)
        end)
        inst:DoTaskInTime(2, inst.WgRecycle)
    end,
    recycle = function(inst)
        inst.SoundEmitter:KillSound("spinLoop")
        inst.Physics:Stop()
        inst.enemies = nil
        inst.speed_x = nil
        inst.speed_z = nil
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
        if inst.task2 then
            inst.task2:Cancel()
            inst.task2 = nil
        end
    end,
}

fxs.scroll_wind2 = {
    init = function(inst)
    end,
    wake = function(inst, data)
        -- {owner, damage}
        inst.enemies = {}
        local pos = inst:GetPosition()
        inst.radius = 2
        local cnt = 0
        for i = 0, 2 do
            for j = 1, 8+4*i do
                inst:DoTaskInTime(.05*cnt, function()
                    local angle = j*360/(8+4*i)
                    -- print(j, i, angle, 360/(8+4*i))
                    inst.radius = inst.radius + .15
                    local x = math.cos(angle)*inst.radius
                    local z = math.sin(angle)*inst.radius
                    FxManager:MakeFx("leaf", pos+Vector3(x, 0, z))
                    -- FxManager:MakeFx("log", pos+Vector3(x, 0, z))
                    EntUtil:make_area_dmg(pos+Vector3(x, 0, z), 2, data.owner, data.damage, nil,
                        EntUtil:add_stimuli(nil, "wind", "magic"),
                        {
                            test = function(v, attacker, weapon)
                                return not inst.enemies[v]
                            end,
                            fn = function(v, attacker, weapon)
                                inst.enemies[v] = true
                            end,
                        }
                    )
                end)
                cnt = cnt + 1
            end
        end
    end,
    recycle = function(inst, data)
        inst.radius = nil
    end,
}

fxs.scroll_wind3 = {
    init = function(inst)
        local sound = inst.entity:AddSoundEmitter()
        local anim = inst.AnimState
        anim:SetBank("the_fx147")
        anim:SetBuild("the_fx147")
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
    end,
    wake = function(inst, data)
        -- {owner, pos/angle, damage}
        if data.angle then
            inst.Transform:SetRotation(data.angle)
        elseif data.pos then
            inst:ForceFacePoint(data.pos:Get())
        end
        inst.AnimState:PlayAnimation("idle")
        inst.speed = 0
        inst.enemies = {}
        inst.range = 2
        inst.task = inst:DoPeriodicTask(.1, function()
            inst.speed = inst.speed + 1
            inst.range = inst.range + .2
            inst.Physics:SetMotorVel(inst.speed, 0, 0)
            local dmg = data.damage * inst.range * .5
            if inst.speed % 2 == 0 then
                EntUtil:make_area_dmg(inst, inst.range, data.owner, 
                    function(v,attacker,weaopn,reason)
                        if inst.enemies[v] then
                            return dmg/5
                        end
                        return dmg
                    end, nil,
                    EntUtil:add_stimuli(nil, "wind", "magic"),
                    {
                        fn = function(v, attacker, weapon)
                            inst.enemies[v] = true
                        end,
                    }
                )
            end
        end)
        inst:DoTaskInTime(1.5, inst.WgRecycle)
    end,
    recycle = function(inst, data)
        inst.Physics:Stop()
        inst.speed = nil
        inst.range = nil
        inst.enemies = nil
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.scroll_blood1 = {
    init = function(inst)
        inst.AnimState:SetBank("the_fxc18")
        inst.AnimState:SetBuild("the_fxc18")
        inst.AnimState:SetPercent("idle", 0)
        inst.AnimState:SetScale(.7,.7,.7)
        inst.AnimState:SetMultColour(1,.2,.2,.7)
        -- inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround)
    end,
    wake = function(inst, data)
    end,
    recycle = function(inst, data)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.scroll_blood2 = {
    init = function(inst)
        local anim = inst.AnimState
        anim:SetBank("the_fx30")
        anim:SetBuild("the_fx30")
        inst.AnimState:PlayAnimation("idle", true)
        make_emitter_physics(inst)
    end,
    wake = function(inst, data)
        -- {owner, pos/angle, damage}
        if data.pos then
            inst:ForceFacePoint(data.pos:Get())
        elseif data.angle then
            inst.Transform:SetRotation(data.angle)
        end
        inst.Physics:SetMotorVel(20, 0, 0)
        inst.enemies = {}
        inst:DoTaskInTime(1, function()
            inst.back = true
            inst.enemies = {}
            inst:ForceFacePoint(data.owner:GetPosition())
        end)
        inst.task = inst:DoPeriodicTask(.1, function()
            EntUtil:make_area_dmg(inst, 4, data.owner, 
                function(v,attacker,weapon,reason) 
                    if inst.back then
                        return data.damage/2
                    end
                    return data.damage
                end, nil, 
                EntUtil:add_stimuli(nil, "blood", "magic"),
                {
                    test = function(v, attacker, weapon)
                        return not inst.enemies[v]
                    end,
                    fn = function(v, attacker, weapon)
                        inst.enemies[v] = true
                    end
                }
            )
        end)
        inst:DoTaskInTime(2, inst.WgRecycle)
    end,
    recycle = function(inst, data)
        inst.enemies = nil
        inst.back = nil
        inst.Physics:Stop()
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.scroll_blood3 = {
    init = function(inst)
    end,
    wake = function(inst, data)
        inst:DoTaskInTime(.05, function()
            local attacker = data.owner
            local weapon = data.weapon
            local reason = EntUtil:add_stimuli(nil, "blood", "magic", "scroll_blood3")
            local x, y, z = inst:GetPosition():Get()
            local ents = TheSim:FindEntities(x, y, z, 14, nil, EntUtil.not_enemy_tags)
            local targets = {}
            for k, v in pairs(ents) do
                if EntUtil:check_combat_target(attacker, v) then
                    table.insert(targets, v)
                end
            end
            if #targets > 0 then
                local damage = math.min(data.damage/#targets, data.damage/4)
                for k, v in pairs(targets) do
                    FxManager:MakeFx("blood_tooth", v)
                    EntUtil:get_attacked(v, attacker, damage, weapon, reason, nil, nil)
                end
            end
        end)
        inst:DoTaskInTime(.2, function(inst)
            inst:WgRecycle()
        end)
    end,
    recycle = function(inst, data)
    end,
}

fxs.scroll_poison1 = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.work = function(master, child, owner, damage)
            FxManager:MakeFx("poison_hole_bubble", child)
            EntUtil:make_area_dmg(child, 3, owner, damage, 
                nil, EntUtil:add_stimuli(nil, "poison", "magic"), {
                    fn = function(v, attacker, weapon)
                        Sample.BuffManager:AddBuff(v, "poison")
                        master.enemies[v] = true
                    end,
                    test = function(v, attackder, weapon)
                        return master.enemies[v] == nil
                    end,
                    calc = true,
                })
        end
        inst.get_rot = function(n)
            if n > 1 then
                local angle = 60
                local gap = 60/(n-1)
                return gap
            end
        end
        inst.range = 4
    end,
    wake = function(inst, data)    
        -- data = {pos, owner, damage}
        inst.enemies = {}
        if data.pos then
            inst:ForceFacePoint(data.pos)
        end
        local rot = inst.Transform:GetRotation()
        -- start number
        for i = 3, inst.range do
            local gap = inst.get_rot(i)
            for j = 1, i do
                local rot2 = 0
                if i == 1 then
                    rot2 = rot
                else
                    rot2 = rot+40-inst.get_rot(i)*(j-1)
                end
                local fx = FxManager:MakeFx("line_fx", inst, {angle=rot2, speed=20})
                local work_time = .15*(i-2)  -- 控制出现的位置
                fx:DoTaskInTime(work_time, function()
                    inst:work(fx, data.owner, data.damage)
                    fx:WgRecycle()
                end)
            end
        end
        inst:DoTaskInTime(2.1, inst.WgRecycle)
    end,
    recycle = function(inst)
        inst.enemies = nil
    end,
}

fxs.scroll_poison2 = {
    init = function(inst)
        -- {owner, pos/angle, [weapon], damage, [calc]}
        inst.AnimState:SetBank("the_fxc65")
        inst.AnimState:SetBuild("the_fxc65")
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetMultColour(.2, 1, .2, 1)
        inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetScale(1.5, 1, 1.5)
        -- MakeInventoryPhysics(inst)
        -- RemovePhysicsColliders(inst)
        make_emitter_physics(inst)
    end,
    wake = function(inst, data)
        shoot_emitter(inst, data, 25, 2, 
            function(v, attacker, weapon, reason)
                if v.components.combat.poisonous
                or (v.components.poisonable
                and v.components.poisonable:IsPoisoned())
                or Sample.BuffManager:HasBuff(v, "poison") then
                    return data.damage*1.75
                end
                return data.damage
            end, 
            EntUtil:add_stimuli(nil, "poison", "magic"),
            nil, 1
        )
    end,
    recycle = function(inst)
    end,
}

fxs.scroll_poison3 = {
    init = function(inst)
    end,
    wake = function(inst, data)
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 12, nil, EntUtil.not_enemy_tags)
        for k, v in pairs(ents) do
            if EntUtil:check_combat_target(data.owner, v) then
                local can = nil
                if v.components.poisonable 
                and v.components.poisonable:IsPoisoned() then
                    can = true
                    v.components.poisonable:Cure()
                end
                if Sample.BuffManager:HasBuff(v, "poison") then
                    can = true
                    Sample.BuffManager:ClearBuff(v, "poison")
                end
                if can then
                    EntUtil:get_attacked(v, data.owner, data.damage, nil,
                        EntUtil:add_stimuli(nil, "poison", "magic"),
                        nil, nil
                    )
                    FxManager:MakeFx("green_emitter2", v)
                end 
            end
        end
    end,
    recycle = function(inst)
    end,
}

fxs.scroll_electric1 = {
    init = function(inst)
        inst.AnimState:SetBank("the_fxh48")
        inst.AnimState:SetBuild("the_fxh48")
        inst.AnimState:PlayAnimation("idle", true)
        inst.AnimState:SetScale(2, 2, 2)
    end,
    wake = function(inst, data)
        inst.enemies = {}
        inst.task = inst:DoPeriodicTask(0.5, function()
            EntUtil:make_area_dmg(inst, 3, data.owner, 
                function(v, attacker, weapon, reason)
                    if inst.enemies[v] then
                        return data.damage/5
                    end
                    return data.damage
                end, nil,
                EntUtil:add_stimuli(nil, "electric", "magic"),
                {
                    fn = function(v, attacker, weapon)
                        inst.enemies[v] = true
                    end,
                }
            )
        end)
        inst:DoTaskInTime(5, inst.WgRecycle)
    end,
    recycle = function(inst, data)
        inst.enemies = nil
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.scroll_electric2 = {
    init = function(inst)
        fxs.magic_center.init(inst)
        inst.child_fx = "ball3"
        inst.num = 3
        inst.step = 16
        inst.width = 4
        inst.height = 0
        -- inst.const_height = 0
    end,
    wake = function(inst, data)
        -- 不要AddChild这个fx, 传入data.owner, 会自行设置位置跟随
        -- {owner, damage}
        fxs.magic_center.wake(inst, data)
        inst.owner = data.owner
        inst.enemies = {}
        inst.task3 = inst:DoPeriodicTask(0.2, function()
            for k, v in pairs(inst.fxs) do
                EntUtil:make_area_dmg(v, 1.5, data.owner, 
                    function(v,attacker,weapon,reason)
                        if inst.enemies[v] then
                            return data.damage/5
                        end
                        return data.damage
                    end, nil,
                    EntUtil:add_stimuli(nil, "electric", "magic"), {
                        fn = function(v, attacker, weapon)
                            inst.enemies[v] = true
                        end
                    }
                )
            end
        end)
        -- inst:DoTaskInTime(10, inst.WgRecycle)
    end,
    recycle = function(inst)
        fxs.magic_center.recycle(inst)
        inst.owner = nil
        if inst.task3 then
            inst.task3:Cancel()
            inst.task3 = nil
        end
    end,
}

fxs.scroll_electric3 = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        make_emitter_physics(inst)
    end,
    wake = function(inst, data)
        -- {owner, pos/angle, [weapon], damage}
        shoot_emitter(inst, data, 25, 3, data.damage, 
            EntUtil:add_stimuli(nil, "electric", "magic"), 
            nil, 1.5, nil, function(v, attacker, weapon)
                FxManager:MakeFx("hit_fx5", v)
            end
        )
        inst.task2 = inst:DoPeriodicTask(0.2, function()
            inst.SoundEmitter:PlaySound(Sounds.thunder)
            FxManager:MakeFx("hit_fx5", inst)
        end, 0)
    end,
    recycle = function(inst, data)
        if inst.task2 then
            inst.task2:Cancel()
            inst.task2 = nil
        end
    end,
}

fxs.scroll_holly2 = {
    init = function(inst)
        fxs.magic_center.init(inst)
        inst.child_fx = "anim_fx"
        inst.child_data = {anim={
            "tp_scroll_holly_sword", "tp_scroll_holly_sword", "idle"
        }}
        inst.num = 3
        inst.step = 8
        inst.width = 2
        inst.height = 0
        -- inst.const_height = 0
    end,
    wake = function(inst, data)
        -- 不要AddChild这个fx, 传入data.owner, 会自行设置位置跟随
        -- {owner}
        fxs.magic_center.wake(inst, data)
        inst.owner = data.owner
        -- inst:DoTaskInTime(10, inst.WgRecycle)
    end,
    recycle = function(inst)
        fxs.magic_center.recycle(inst)
        inst.owner = nil
    end,
}

fxs.holly_bean2 = {
    init = function(inst)
        fxs.holly_bean.init(inst)
    end,
    wake = function(inst, data)
        inst.enemies = {}  -- 不要deepcopy
        if data.enemies then
            for k, v in pairs(data.enemies) do
                inst.enemies[k] = true
            end
        end
        shoot_emitter(inst, data, 10, 2, data.damage, 
            EntUtil:add_stimuli(nil, "holly", "magic"),
            nil, .5, function(v, attacker, weapon, reason)
                return not inst.enemies[v]
            end
        )
    end,
    recycle = function(inst)
        inst.enemies = nil
    end,
}
fxs.holly_bean3 = {
    init = function(inst)
        fxs.holly_bean.init(inst)
        inst.AnimState:SetScale(1.5,1.5,1.5)
    end,
    wake = function(inst, data)
        inst.enemies = {}  -- 不要deepcopy
        if data.enemies then
            for k, v in pairs(data.enemies) do
                inst.enemies[k] = true
            end
        end
        inst.owner = data.owner
        inst.damage = data.damage
        inst.angle = data.angle
        shoot_emitter(inst, data, 10, 2, data.damage, 
            EntUtil:add_stimuli(nil, "holly", "magic"),
            nil, .5, function(v, attacker, weapon, reason)
                return not inst.enemies[v]
            end, function(v, attacker, weapon, reason)
                inst.enemies[v] = true
            end
        )
    end,
    recycle = function(inst)
        for i = -2, 2 do
            local fx = FxManager:MakeFx("holly_bean2", inst, {
                angle=inst.angle+i*15,
                owner=inst.owner,
                damage=inst.damage/2,
                enemies=inst.enemies,
            })
        end
        inst.owner = nil
        inst.damage = nil
        inst.enemies = nil
        inst.angle = nil
    end,
}

fxs.holly_meteor = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.Transform:SetTwoFaced()
        inst.AnimState:SetBank("tp_meteor")
        inst.AnimState:SetBuild("tp_meteor")
        inst.AnimState:SetMultColour(1, 1, .2, 1)
    end,
    wake = function(inst, data)
        -- {owner, damage}
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bomb_fall")
        inst.AnimState:PlayAnimation("crash")
        -- inst:ListenForEvent("animover", inst.WgRecycle)
        inst.enemies = {}
        inst:DoTaskInTime(.4, function(inst)
            EntUtil:make_area_dmg(inst, 4, data.owner, data.damage, nil, 
                EntUtil:add_stimuli(nil, "holly", "magic"),
                {
                    fn = function(v, attacker, weapon)
                        inst.enemies[v] = true
                    end,
                }
            )
            for i = 1, 8 do
                local fx = FxManager:MakeFx("holly_bean3", inst, {
                    angle=i*360/8,
                    owner=data.owner,
                    damage=data.damage/2,
                    enemies=inst.enemies,
                })
            end
        end)
        inst:DoTaskInTime(.5, function()
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano/volcano_rock_smash")
            inst:WgRecycle()
        end)
    end,
    recycle = function(inst)
        inst.enemies = nil
        -- inst:RemoveEventCallback("animover", inst.WgRecycle)
    end,
}

fxs.conductive = {
    init = function(inst)
        inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
        inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
        inst.AnimState:PlayAnimation("crackle_loop", true)
        inst.AnimState:SetScale(.7, .7, .7)
        inst.AnimState:SetMultColour(.3, 1, .3, 1)
    end,
    wake = function(inst)
    end,
    recycle = function(inst)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.nightsword_fx = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.AnimState:SetBank("wilson")
        inst.AnimState:SetMultColour(0,0,0,1)
        inst.AnimState:AddOverrideBuild("player_lunge_wargon")
        make_emitter_physics(inst)
    end,
    wake = function(inst, data)
        inst.AnimState:SetBuild(data.owner.prefab)
        inst.AnimState:PlayAnimation("lunge_pst")
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/slide")
        do_line_damage(inst, data, 28, 0, 3.3,
            EntUtil:add_stimuli(nil, "shadow"), true, 1 )
    end,
    recycle = function(inst)
    end,
}

fxs.time_bomb = {
    init = function(inst)
        inst.AnimState:SetBank("the_fx17")
        inst.AnimState:SetBuild("the_fx17")
    end,
    wake = function(inst, data)
        inst.AnimState:SetPercent("idle", 0)
        inst:DoTaskInTime(data.time, function()
            inst.AnimState:PlayAnimation("idle", true)
        end)
        inst:ListenForEvent("animover", inst.WgRecycle)
    end,
    recycle = function(inst, data)
        inst:RemoveEventCallback("animover", inst.WgRecycle)
    end,
}

fxs.hollow_bean = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.AnimState:SetBank("the_fx29")
        inst.AnimState:SetBuild("the_fx29")
        inst.AnimState:PlayAnimation("idle", true)
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
        inst:AddTag("hollow_bean")
        inst:AddTag("cyclone_bean")
    end,
    wake = function(inst, data)
        if data.pos then
            inst:ForceFacePoint(data.pos:Get())
        end
        inst.Physics:SetMotorVel(20, 0, 0)
        inst.dmg = 30
        inst.stop_dmg = 40 + data.damage
        inst:DoTaskInTime(1, function()
            inst.dmg = inst.stop_dmg
            inst.Physics:Stop()
        end)
        inst:DoTaskInTime(5, inst.WgRecycle)
        inst.enemies = {}
        inst.cnt = 0
        inst.task = inst:DoPeriodicTask(.1, function()
            if data.owner and EntUtil:is_alive(data.owner) then
                inst.cnt = inst.cnt + 1
                if inst.cnt % 10 == 0 then
                    inst.cnt = 0
                    inst.enemies = {}
                end
                if inst.cnt == 20 then
                    inst.cnt = 0
                    inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")
                end
                EntUtil:make_area_dmg(inst, 2, data.owner, inst.dmg, nil, 
                    EntUtil:add_stimuli(nil, "electric"),
                    {
                        fn = function(v, attacker, weapon)
                            inst.enemies[v] = true
                        end,
                        test = function(v, attacker, weapon)
                            return not inst.enemies[v]
                        end,
                    }
                )
            end
        end)
    end,
    recycle = function(inst, data)
        inst.enemies = {}
        inst.Physics:Stop()
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end,
}

fxs.hollow_bean2 = {
    init = function (inst)
        fxs.hollow_bean.init(inst)
        inst.AnimState:SetMultColour(1,.1,.1,1)
        inst:RemoveTag("cyclone_bean")
        inst:AddTag("recyclone_bean")
    end,
    wake = function(inst, data)
        fxs.hollow_bean.wake(inst, data)
        inst.dmg = 60 + data.damage
        inst.stop_dmg = 30
        inst.task2 = inst:DoPeriodicTask(.1, function()
            local ent = FindEntity(inst, 2, function(target, inst)
                return target:HasTag("cyclone_bean")
            end)
            if ent then
                local pos = inst:GetPosition()
                if data.owner and EntUtil:is_alive(data.owner) then
                    FxManager:MakeFx("hollow_blast", pos)
                    FxManager:MakeFx("groundpoundring_fx", pos)
                    EntUtil:make_area_dmg(pos, 10, data.owner, 1000+inst.dmg*2, nil, 
                        EntUtil:add_stimuli(nil, "not_evade", "holly")
                    )
                end
                inst:WgRecycle()
                ent:WgRecycle()
            end
        end)
    end,
    recycle = function(inst)
        if inst.task2 then
            inst.task2:Cancel()
            inst.task2 = nil
        end
        fxs.hollow_bean.recycle(inst)
    end,
}

fxs.hollow_blast = {
    init = function(inst)
        inst.entity:AddSoundEmitter()
        inst.AnimState:SetBank("the_fx19")
        inst.AnimState:SetBuild("the_fx19")
        inst.AnimState:SetScale(2,2,2)
        inst:AddComponent("groundpounder")
        inst.components.groundpounder.destroyer = true
        inst.components.groundpounder.damageRings = 3
        inst.components.groundpounder.destructionRings = 4
        inst.components.groundpounder.numRings = 5
        local cmp = inst.components.groundpounder
        function cmp:DestroyPoints(points, breakobjects, dodamage)
            local getEnts = breakobjects or dodamage
            for k,v in pairs(points) do
                local ents = nil
                if getEnts then
                    ents = TheSim:FindEntities(v.x, v.y, v.z, 3, nil, self.noTags)
                end
                if ents and breakobjects then
                    -- first check to see if there's crops here, we want to work their farm
                    for k2,v2 in pairs(ents) do
                        if v2 and self.burner and v2.components.burnable and not v2:HasTag("fire") and not v2:HasTag("burnt") then
                            v2.components.burnable:Ignite()
                        end
                        -- Don't net any insects when we do work
                        if v2 and self.destroyer and v2.components.workable and v2.components.workable.workleft > 0 and v2.components.workable.action ~= ACTIONS.NET then
                            v2.components.workable:Destroy(self.inst)
                    end
                        if v2 and self.destroyer and v2.components.crop then
                            print("Has Crop:",v2)
                            v2.components.crop:ForceHarvest()
                        end
                    end
                end
                if ents and dodamage then
                    for k2,v2 in pairs(ents) do
                        if not self.ignoreEnts then 
                            self.ignoreEnts = {}
                        end 
                        if not self.ignoreEnts[v2.GUID] then --If this entity hasn't already been hurt by this groundpound
                            -- if v2 and v2.components.health and not v2.components.health:IsDead() and 
                            -- inst.owner.components.combat:CanTarget(v2) then
                            --     EntUtil:get_attacked(v2, inst.owner, 0, nil, nil, true)
                            --     -- self.inst.components.combat:DoAttack(v2, nil, nil, nil, self.groundpounddamagemult)
                            -- end
                            self.ignoreEnts[v2.GUID] = true --Keep track of which entities have been hit 
                        end 
                    end
                end
                local map = GetMap()
                if map then
                    local ground = map:GetTileAtPoint(v.x, 0, v.z)
                    if ground == GROUND.IMPASSABLE or map:IsWater(ground) then
                        --Maybe do some water fx here?
                    else
                        if self.groundpoundfx then 
                            SpawnPrefab(self.groundpoundfx).Transform:SetPosition(v.x, 0, v.z)
                        end 
                    end
                end
            end
        end
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("idle")
        inst:ListenForEvent("animover", inst.WgRecycle)
        
        EntUtil:shake_camera(inst, 40)
        inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
        inst.components.groundpounder:GroundPound()
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 10, {"hollow_bean"})
        for _, v in pairs(ents) do
            v:WgRecycle()
        end
    end,
    recycle = function(inst, data)
        inst:RemoveEventCallback("animover", inst.WgRecycle)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

fxs.hollow_evade = {
    init = function(inst)
        inst.AnimState:SetBank("the_fx04")
        inst.AnimState:SetBuild("the_fx04")
        inst.AnimState:SetScale(1, 2, 1)
    end,
    wake = function(inst, data)
        inst.AnimState:PlayAnimation("idle", true)
    end,
    recycle = function(inst, data)
        inst.AnimState:Pause()
        -- inst.AnimState:SetPercent("idle", 1)
        if inst.parent then
            inst.parent:RemoveChild(inst)
        end
    end,
}

local two_faced_fxs = {
    slash_fx = "the_fx02",
    slash_fx2 = "the_fx26",
    slash_fx3 = "the_fx146",
    cyclone_slash = "the_fx27",
    cyclone_slash2 = "the_fx18",
    cyclone_slash3 = "the_fxc26",
    cyclone_slash4 = "the_fxc27",
}
for k, v in pairs(two_faced_fxs) do
    fxs[k] = {
        init = function(inst)
            inst.Transform:SetTwoFaced()
            inst.AnimState:SetBank(v)
            inst.AnimState:SetBuild(v)
        end,
        wake = function(inst, data)
            inst.AnimState:PlayAnimation("idle")
            if data.pos then
                inst:ForceFacePoint(data.pos:GetPosition():Get())
            elseif data.angle then
                inst.Transform:SetRotation(data.angle)
            end
            inst:ListenForEvent("animover", inst.WgRecycle)
        end,
        recycle = function(inst, data)
            inst:RemoveEventCallback("animover", inst.WgRecycle)
        end
    }
end

local continuous_fxs = {
    strong_fx = {"the_fx03"},
    strong_fx2 = {"the_fx04"},
    strong_fx3 = {"the_fx51"},
    thunder = {"the_fx23"},
    ball = {"the_fx28"},
    ball2 = {"the_fx29"},
    ball3 = {"the_fx22"},  -- galeforce ball
    weak_fx = {"the_fx48"},
    defense_fx = {"the_fxc20", 2},
    defense_fx2 = {"the_fxc22", 2},
    defense_fx3 = {"the_fxc24", 2},
    elem_defense_fx = {"the_fxc21", 2},
    elem_defense_fx2 = {"the_fxc23", 2},
    elem_defense_fx3 = {"the_fxc25", 2},
    fire_debuff_fx = {"the_fx54", 2},
    thunder_pillar = {"the_fxh48"},
    green_emitter = {"the_fxr46"}
}
for k, v in pairs(continuous_fxs) do
    fxs[k] = {
        init = function(inst)
            inst.AnimState:SetBank(v[1])
            inst.AnimState:SetBuild(v[1])
            inst.AnimState:PlayAnimation("idle", true)
            if v[2] then
                inst.AnimState:SetScale(v[2], v[2], v[2])
            end
        end,
        wake = function(inst, data)
        end,
        recycle = function(inst, data)
            -- inst.AnimState:SetPercent("idle", 1)
            if inst.parent then
                inst.parent:RemoveChild(inst)
            end
        end,
    }
end

local some_fxs = {
    recover_fx = "the_fxa11",
    heal_fx = "the_fx31",
    ice_fist = "the_fx37",
    hit_fx = "the_fx01",
    hit_fx2 = "the_fx45",
    hit_fx3 = "the_fx10",
    hit_fx4 = "the_fx47",
    hit_fx5 = {"the_fx50", 2},
    hit_fx6 = {"the_fx60", 2},
    hit_fx7 = "the_fx13",
    hit_fx8 = "the_fxc05",
    hit_fx9 = "the_fxc06",
    thump_fx = "the_fx05",
    thump_fx2 = "the_fx12",
    thump_fx3 = "the_fx15",
    crow_fx = "the_fx14",
    weapon_might = "the_fx16",
    blast = "the_fx19",
    blast2 = "the_fx21",
    blast3 = "the_fx33",
    blast4 = "the_fx39",
    blast5 = "the_fx40",
    armor_broken = "the_fx42",
    armor_broken2 = "the_fx43",
    blood_tooth = "the_fxc18",
    green_emitter2 = {"the_fxr46", 2},
}
for k, v in pairs(some_fxs) do
    fxs[k] = {
        init = function(inst)
            if type(v) == "table" then
                inst.AnimState:SetBank(v[1])
                inst.AnimState:SetBuild(v[1])
                inst.AnimState:SetScale(v[2], v[2], v[2])
            else
                inst.AnimState:SetBank(v)
                inst.AnimState:SetBuild(v)
            end
        end,
        wake = function(inst, data)
            inst.AnimState:PlayAnimation("idle")
            inst:ListenForEvent("animover", inst.WgRecycle)
        end,
        recycle = function(inst, data)
            inst:RemoveEventCallback("animover", inst.WgRecycle)
            if inst.parent then
                inst.parent:RemoveChild(inst)
            end
        end,
    }
end



-- 添加函数
for k, v in pairs(fxs) do
    FxManager:AddFxHandler(k, v)
end

Sample.FxManager = FxManager