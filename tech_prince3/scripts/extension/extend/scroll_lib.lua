local DataManager = require "extension.lib.data_manager"

local ScrollData = Class(function(self, id)
    self.id = id
end)

function ScrollData:GetId()
    return self.id
end


local ScrollManager = DataManager("ScrollManager")
ScrollManager.scroll_type_dict = {
    ["nature"] = "自然",
    ["fire"] = "火",
    ["ice"] = "冰",
    ["shadow"] = "暗",
    ["holly"] = "圣",
    ["electric"] = "雷",
    ["poison"] = "毒",
    ["wind"] = "风",
    ["blood"] = "血",
}

local GetDataKindById = ScrollManager.GetDataKindById
function ScrollManager:GetDataKindById(id)
    if self.id_kind_dict == nil then
        self.id_kind_dict = {}
    end
    if self.id_kind_dict[id] == nil then
        local kind = GetDataKindById(self, id)
        self.id_kind_dict[id] = kind
    end
    return self.id_kind_dict[id]
end

function ScrollManager:MakeTempTable()
    self.temp = {}
end

function ScrollManager:Add(scroll_name, kind)
    if self.scroll_type_dict[kind] == nil then
        assert(nil, string.format("%s not in ScrollManager type dict", kind))
    end
    if self.temp[kind] == nil then
        self.temp[kind] = {}
    end
    table.insert(self.temp[kind], ScrollData(scroll_name))
end

-- 提交
function ScrollManager:Submit()
    for kind, scrolls in pairs(self.temp) do
        self:AddDatas(scrolls, kind)
    end
    self.temp = nil
end

Sample.ScrollManager = ScrollManager