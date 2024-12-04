local Util = require "extension.lib.wg_util"
-- 将功能分为多个包，减轻导入时的压力
local Kit = {}

--[[
创建实体的光源  
inst 进行操作的实体  
light_type 光的类型 miner_hat,lantern,lighter,campfire,city_lamp,fire_flies  
]]
function Kit:make_light(inst, light_type)
    local light = nil
    if inst.entity.Light then
        light = inst.Light
    else
        light = inst.entity:AddLight()
    end
    local lights = {
		-- falloff, intensity, radius, colour
        miner_hat = {.4, .7, 2.5, {180/255, 195/255, 150/255} },
        lantern = {.9, .6, 5, {180/255, 195/255, 150/255} },
		lighter = { .5, .75, 1, {200/255,150/255,50/255} },
		campfire = {.33, .8, 5, {255/255,255/255,192/255} },
		city_lamp = { 0.9, 0.6, 5, {197/255, 197/255, 10/255}},
		fire_flies = { 1, .5, 1, {180/255, 195/255, 150/255}},
	}
    local data = lights[light_type]
	assert(data~=nil, "argument \"light_type\" isn't valid, not find corresponding data.")
    
    light:SetFalloff(data[1])
    light:SetIntensity(data[2])
    light:SetRadius(data[3])
    light:SetColour(unpack(data[4]))
    light:Enable(false)
end

--[[
获取目标位置  
(Vector3)/(number)x,(number)y,(number)z 返回对应的位置  
pt, (EntityScript/Vector3)需要获取位置的目标  
is_v, 为true则返回类型为Vector3，否则返回x,y,z  
]]
function Kit:get_pos(pt, is_v)
    return Util:GetPos(pt, is_v)
end

--[[
召唤Prefab  
(Prefab) 返回这个Prefab  
name, 预制物名  
pos, (EntityScript/Vector3)目标位置或实体  
is_follow，如果pos为实体，is_follow为true，则pos:AddChild(Prefab)  
]]
function Kit:spawn_prefab(name, pos, is_follow)
    assert(type(name)=="string", "arguments \"name\" must be string.")
    
    local ent = SpawnPrefab(name)
    if ent then
        pos = self:get_pos(pos)
        if is_follow then
            assert(pos.entity, "argument \"pos\" isn't entity, can't be followed.")
            
            pos:AddChild(ent)
            ent.Transform:SetPosition(0,0,0)
        end
    end
    return ent
end

--[[
判断在第几个dlc  
(bool)返回bool  
n, dlc的序号，1-ROG, 2-SW, 3-HAM  
]]
function Kit:is_dlc(n)
    if SaveGameIndex then
		local tbl = {
			SaveGameIndex:IsModeSurvival(),
			SaveGameIndex:IsModeShipwrecked(),
			SaveGameIndex:IsModePorkland(),
		}
		return tbl[n]
	end
end

--[[
判断启用了第几个dlc
(bool) 返回bool    
n, dlc的序号，1-ROG, 2-SW, 3-HAM  
]]
function Kit:have_dlc(n)
    if GLOBAL.IsDLCEnabled then
		return GLOBAL.IsDLCEnabled(n)
	else
		return IsDLCEnabled(n)
	end
end

--[[
寻找范围内符合条件的第一个实体  
(EntityScript) 返回找到的这个实体，没找到则为nil  
inst, 以该实体为中心进行搜索  
range, 搜索的范围  
fn, 搜索函数function(item, inst)end  
tags, 搜索物体需要包含的所有tag  
no_tags, 搜索物体不该包含的所有tag  
]]
-- function Kit:find_ent(inst, range, fn, tags, no_tags)
--     return FindEntity(inst, range, fn, tags, no_tags)
-- end

--[[
寻找范围内符合条件的所有实体，装进一个列表，里面包含所有找到的实体，没找到则为空列表  
(table) 返回这个列表
pos, (EntityScript/Vector3)以该坐标或实体为中心进行搜索  
range, 搜索的范围  
tags, 搜索物体需要包含的所有tag  
no_tags, 搜索物体不该包含的所有tag  
]]
-- function Kit:find_ents(pos, range, tags, no_tags)
--     local x, y, z = self:get_pos(pos)
--     return TheSim:FindEntities(x, y, z, range, tags, no_tags)
-- end

--[[
寻找周围可以行走的位置，可以是水面上的位置  
(Vector3) 返回这个位置  
pt (EntityScript/Vector3)以该坐标或实体为中心进行搜索  
dist 搜索的范围  
]]
function Kit:find_walk_pos(pt, dist)
    local theta = math.random() * 2 * PI
    local pt = self:get_pos(pt, true)
    local radius = dist
    local offset = FindWalkableOffset(pt, theta, radius, 12, true)
    if offset then
        local pos = pt + offset
        return pos
    end
end

--[[
寻找周围的地面坐标  
(Vector3) 返回这个坐标  
pt (EntityScript/Vector3)以该坐标或实体为中心进行搜索  
dist 搜索的范围  
]]
function Kit:find_ground_pos(pt, dist)
    local pt = self:get_pos(pt, true)
    local pos = FindGroundOffset(pt, math.random() * 2 * math.pi, dist, 18)
	if pos then
		local offset = pt + pos
		return offset
	end
end

--[[
像猪王一样丢东西（给定位置，给定物品）  
item (EntityScript)需要被抛起的实体  
pos (EntityScript/Vector3)目标位置或实体，可以为nil  
]]
function Kit:pigking_throw(item, pos)
    assert(item.entity, "argument \"item\" must be EntityScript.")
    
    local nug = item
    pos = pos or nug
    local pt = self:get_pos(pos, true) + Vector3(0,4.5,0)
    
    nug.Transform:SetPosition(pt:Get())
    local down = TheCamera:GetDownVec()
    local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
    --local angle = (-TUNING.CAM_ROT-90 + math.random()*60-30)/180*PI
    local sp = math.random()*4+2
    nug.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
    if nug.components.inventoryitem then
	    nug.components.inventoryitem:OnStartFalling()
    end
end

--[[
像lootdropper一样丢东西，（给定实体，给定位置）  
item (EntityScript)需要被抛起的实体  
pos (EntityScript/Vector3)目标位置或实体，可以为nil  
]]
function Kit:throw_item(item, pos)
    assert(item.entity, "argument \"item\" must be EntityScript.")
    
    local down = TheCamera:GetDownVec()
	local spawnangle = math.atan2(down.z, down.x)
	local angle = math.atan2(down.z, down.x) + (math.random()*90-45)*DEGREES
	local sp = math.random()*3+2
	pos = pos or item
	if item.components.inventoryitem then
		local pt = self:get_pos(pos, true) + Vector3(2*math.cos(spawnangle), 3, 2*math.sin(spawnangle))
		item.Transform:SetPosition(pt:Get())
		item.Physics:SetVel(sp*math.cos(angle), math.random()*2+9, sp*math.sin(angle))
        item.components.inventoryitem:OnStartFalling()
    elseif item.Physics then
        local x,y,z = item.Transform:GetWorldPosition()
        if x and y and z then 
            local vely = 0 
            if item.Physics then 
                local vx, vy, vz = item.Physics:GetVelocity()
                vely = vy or 0
            end
            if y + vely * .1 * 1.5 < 0.01 and vely <= 0 then
                print("vely", vely)
            end
        end 
    else
        print(string.format("Kit:Warnning! function \"throw_item\"'s argument item(%s) not have Physics.", item))
    end
end

function Kit:test_anim(bank, build, animation)
    if self.anim_fx == nil then
        local pos = TheInput:GetWorldPosition()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.persists = false
        inst.Transform:SetPosition(pos:Get())
        self.anim_fx = inst
    end
    local inst = self.anim_fx
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(animation)
end

function Kit:test_teleport(name)
    local ent = c_find(name)
    if ent then
        GetPlayer().Transform:SetPosition(ent:GetPosition():Get())
    end
end

return Kit