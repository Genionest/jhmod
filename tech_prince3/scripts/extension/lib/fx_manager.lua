local Util = require "extension.lib.wg_util"

--[[
fx群组，保存这一类的fx，并提供处理函数  
name 群组名字  
fx_handler (table{func})这类fx的处理函数列表{init,wake,recycle}  
]]
local FxGroup = Class(function(self, name, fx_handler)
    self.name = name
    self.fxs = {}
    self.fx_handler = fx_handler
    self.inactivate_fx_id = 1
end)

--[[
回收fx  
self (FxUtil.FxGroup)目标类  
fx (EntityScript)需要回收的fx  
]]
function FxGroup:WgRecycle(fx)
    -- 回收
    local recycle = self.fx_handler.recycle
    if recycle then
        recycle(fx)
    end
    fx:PushEvent("wg_recycle")
    fx:RemoveAllEventCallbacks()
    fx:CancelAllPendingTasks()
    fx:KillTasks()
    fx:RemoveFromScene()
    fx.wg_activate = false
    if fx.on_wg_recycle then
        fx:on_wg_recycle()
    end
    self.inactivate_fx_id = fx.wg_fx_id
end

--[[
创造一个新的fx，  
(Prefab) 返回这个fx  
]]
function FxGroup:CreateFx()
    local fx = SpawnPrefab("wg_recyclable_fx")

    fx.wg_fx_group = self
    fx.WgRecycle = function(fx)
        if fx.wg_fx_group then
            fx.wg_fx_group:WgRecycle(fx)
        end
    end
    fx:ListenForEvent("onremove", function()
        -- 被remove的特效从列表中删除
        if fx.wg_fx_id then
            table.remove(self.fxs, fx.wg_fx_id)
            if fx.wg_fx_id <= self.inactivate_fx_id then
                -- 如果他在预id的前面，保存的回收id也随之退一位
                self.inactivate_fx_id = math.max(1, self.inactivate_fx_id - 1)
                -- self.inactivate_fx_id = self.inactivate_fx_id-1
            end
        end
    end)
    fx:ListenForEvent("entitysleep", function()
        fx:WgRecycle()
    end)
    -- 初始化
    local init = self.fx_handler.init
    if init then
        init(fx)
    end
    return fx
end

--[[
获取下一个沉睡的fx的id，
如果没有，则创建一个新的fx，并获取其id  
(number) 返回这个id  
]]
function FxGroup:GetInactivateId()
    local len = #self.fxs
    if len > 0 then
        for i = self.inactivate_fx_id, len do
            if not self.fxs[i].wg_activate then
                self.inactivate_fx_id = math.min(len, i + 1)
                return i
            end
        end
        for i = 1, self.inactivate_fx_id do
            if not self.fxs[i].wg_activate then
                self.inactivate_fx_id = math.min(len, i + 1)
                return i
            end
        end
    end
    -- 用完了
    local fx = self:CreateFx()
    -- table.insert(self.fxs, fx)
    local id  = len + 1
    self.fxs[id] = fx
    fx.wg_fx_id = id
    return fx.wg_fx_id
end

--[[
提取fx，获取下一个沉睡的fx,  
(Prefab) 返回这个fx  
data (any)额外参数，用于在wake函数中进行处理  
]]
function FxGroup:MakeFx(data)
    local id = self:GetInactivateId()
    local fx = self.fxs[id]
    -- 需要清除wait_id
    fx.wg_fx_wait_id = nil  
    fx.wg_activate = true
    fx:ReturnToScene()
    -- 不在这里激活
    -- local wake = self.fx_handler.wake
    -- if wake then
    --     wake(fx, data)
    -- end
    return fx
end

local FxManager = {
    groups = {},
    fx_handlers = {},
}

--[[
添加名为fx_name的函数列表  
fx_name (string)特效名    
fx_handler (table{func})特效的相关函数{init,wake,recycle} 
]]
function FxManager:AddFxHandler(fx_name, fx_handler)
    self.fx_handlers[fx_name] = fx_handler
end

--[[
获取对应的fx函数  
(function) 返回这个函数  
name 需要获取的函数对应的名字  
]]
function FxManager:GetFxHandler(name)
    local fx_handler = self.fx_handlers[name]
    assert(fx_handler~=nil, string.format("FxManager can't find FxHandler named %s", name))
    return fx_handler
end

--[[
提取执行特定函数的fx,  
(Prefab) 返回这个fx  
name fx群组的名字  
pos (Vector3/EntityScript)用于标定生成fx的坐标或实体  
data 其他数据，和wake函数相关，可以为nil  
]]
function FxManager:MakeFx(name, pt, data)
    if self.groups[name] == nil then
        local fx_handler = self:GetFxHandler(name)
        self.groups[name] = FxGroup(name, fx_handler)
    end
    local fx_group = self.groups[name]
    local fx = fx_group:MakeFx(data)
    -- fn(fx, data)
    local pos = Util:GetPos(pt, true)
    fx.Transform:SetPosition(pos:Get())
    -- 激活
    local wake = fx_group.fx_handler.wake
    if wake then
        wake(fx, data)
    end

    return fx
end

--[[
统计fx的数量，统计每个群组的fx数，以及总数  
(number) 返回总数  
]]
function FxManager:CountFx()
    local count = 0
    for k, v in pairs(self.groups) do
        local sum = 0
        for k2, v2 in pairs(v.fxs or {}) do
            count = count + 1
            sum = sum + 1
        end
        print(string.format("FxManager:\"%s\" part have %d fx", k, sum))
    end
    print("FxManager:fx's total number:", count)
    return count
end

return FxManager