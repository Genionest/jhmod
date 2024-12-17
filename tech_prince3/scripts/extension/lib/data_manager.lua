
--[[
数据管理器,批量管理数据  
name (string)名字
]]
local DataManager = Class(function(self, name)
    self.name = name
    self.db = {}  -- ids
    self.dict = {}
    self.len_t = {}
    self.all_kinds = {}
end)
-- local DataManager = {
--     name = nil,
--     db = {},
--     dict = {},
--     len_t = {},
--     all_kinds = {},
-- }

--[[
设置名字  
name (string)名字  
]]
function DataManager:SetName(name)
    self.name = name
end


--[[
添加数据列表(添加的数据需要有GetId接口)  
datas (table)数据列表  
kind (string)数据种类，默认为default  
]]
function DataManager:AddDatas(datas, kind)
    kind = kind or "default"
    local dict_kind = kind
    if self.unique_id_mode then
        dict_kind = "default"
    end
    if self.dict[dict_kind] == nil then
        self.dict[dict_kind] = {}
    end
    if self.db[kind] == nil then
        -- self.db[kind] = datas
        self.db[kind] = {}
        table.insert(self.all_kinds, kind)
        for k, v in pairs(datas) do
            -- 重复检测
            if self.dict[dict_kind][v:GetId()] ~= nil then
                assert(nil, string.format("DataManager(%s) add repetitived \"kind\"(%s)-\"id\"(%s)", self.name, dict_kind, v:GetId()))
            end
            self.dict[dict_kind][v:GetId()] = v
            table.insert(self.db[kind], v:GetId())
        end
        self.len_t[kind] = #self.db[kind]
    else
        for k, v in pairs(datas) do
            -- local len = self.len_t[kind]
            table.insert(self.db[kind], v:GetId())
            -- self.dict[v:GetId()] = len+k
            self.dict[dict_kind][v:GetId()] = v
        end
        self.len_t[kind] = #self.db[kind]
    end
end

--[[
根据索引获取数据  
(any)返回这个数据
idx (number)数据在数据库中的索引
kind (string)数据的种类  
]]
function DataManager:GetData(idx, kind)
    kind = kind or "default"
    -- if self.db[kind] then
    --     return self.db[kind][idx]
    -- end
    local id = self.db[kind][idx]
    return self:GetDataById(id, kind)
end

--[[
将数据管理器设置为id唯一模式，确认所有录取的id都是唯一的，
该模式下会提升GetDataById的速度
]]
function DataManager:SetUniqueIdMode()
    self.unique_id_mode = true
end

--[[
根据id获取数据  
id (string)数据的id  
kind (string)数据类型，为nil则会从所有类型中寻找，
如果是id唯一模式，则不需要kind  
]]
function DataManager:GetDataById(id, kind)
    -- local idx = self.dict[id]
    -- if idx then
    --     self:GetData(idx, kind)
    -- end
    local t_kind
    local data
    if self.unique_id_mode then
        t_kind = "default"
    elseif kind then
        t_kind = kind
    else
        for _kind, tbl in pairs(self.dict) do
            if tbl[id] then
                t_kind = _kind
            end
        end
    end
    if t_kind == nil or id == nil then
        assert(nil, string.format("DataManager(%s) can't find data that kind=\"%s\" and id=\"%s\".", self.name, tostring(t_kind), tostring(id) ))
    end
    data = self.dict[t_kind][id]
    assert(data~=nil, string.format("DataManager(%s) can't find data that kind=\"%s\" and id=\"%s\".", self.name, t_kind, id))

    return data
end

--[[
获取数据的类型  
(string) kind数据类型  
data (any)目标数据  
]]
function DataManager:GetDataKindById(id)
    local t_kind
    local data
    if self.unique_id_mode then
        t_kind = "default"
    else
        for _kind, tbl in pairs(self.dict) do
            if tbl[id] then
                t_kind = _kind
            end
        end
    end
    return t_kind
end

--[[
从指定类型中随机获取一个数据  
(any) 返回这个数据  
kinds (table)类型列表,随机数据会从里面的种类之中选取,为nil则为所有类型
]]
function DataManager:GetRandomData(kinds)
    if kinds then
        assert(type(kinds)=="table", string.format("DataManager(%s): kinds(%s) must be table", self.name, tostring(kinds)))
    end
    -- 默认从所有data里随机
    kinds = kinds or self.all_kinds
    local kind = kinds[math.random(#kinds)]
    local len = self.len_t[kind]
    local id = self.db[kind][math.random(len)]
    return self:GetDataById(id, kind)
    -- local idx = math.random(len)
    -- return self:GetData(idx, kind)
end

--[[
检查一个元素是否在列表中  
(bool) 返回bool  
tbl (table)需要检查的列表  
elem (any)需要检查的元素  
]]
local function in_table(tbl, elem)
    for k, v in pairs(tbl) do
        if v == elem then
            return true
        end
    end
end

--[[
从指定类型中随机获取多个数据的id及其类型,并分别放入列表  
ids(table), kinds(table) 返回的id列表和类型列表  
n (number)获取数据的数量  
kinds (table)类型列表,随机数据会从里面的种类之中选取,为nil则为所有类型
]]
function DataManager:GetRandomIds(n, kinds)
    kinds = kinds or self.all_kinds
    local ids = {}
    local kind_rand_t = {}
    for i = 1, n do
        local kind = kinds[math.random(#kinds)]
        local m = kind_rand_t[kind] or 0
        -- kind_rand_t = { kind1=2（说明在kind1池子取两个idx） }
        kind_rand_t[kind] = m+1
        -- 返回的是idx_t = { kind1 = {1,2}（说明在kind1池子取idx为1和2的data）, kind2 = {3, 4} }
    end
    local ret_kinds = {}
    for k, v in pairs(kind_rand_t) do
        local kind = k
        local len = self.len_t[kind]
        local i = 1
        local cnt = 0
        while i<=v do  
            -- for循环里面的i改变不会影响循环条件里的i
            local id = self.db[kind][math.random(len)]
            -- 防止出现同样的id
            if in_table(ids, id) then
                i = i - 1
                cnt = cnt+1
                -- 防止无限循环
                if cnt > 100 then
                    break
                end
            else
                table.insert(ids, id)
                table.insert(ret_kinds, kind)
            end
            i = i+1
        end
    end
    return ids, ret_kinds
end

--[[
从指定类型中随机获取多个数据,并放入一个列表  
(table) 返回这个列表  
n (number)获取数据的数量  
kinds (table)类型列表,随机数据会从里面的种类之中选取,为nil则为所有类型
]]
function DataManager:GetRandomDatas(n, kinds)
    local ids, ret_kinds = self:GetRandomIds(n, kinds)
    local datas = {}
    for i = 1, #ids do
        local id = ids[i]
        local kind = ret_kinds[i]
        local data = self:GetDataById(id, kind)
        table.insert(datas, data)
    end
    return datas
end

--[[
获取所有的id,并放入一个列表  
(table) 返回这个列表
]]
function DataManager:GetAllIds()
    local all_ids = {}
    for _, kind in pairs(self.all_kinds) do
        local ids = self.db[kind]
        for _, id in pairs(ids) do
            table.insert(all_ids, id)
        end
    end
    return all_ids
end

--[[
转为字符函数
]]
function DataManager:__tostring()
    return string.format("DataManager(%s)", self.name)
end

return DataManager