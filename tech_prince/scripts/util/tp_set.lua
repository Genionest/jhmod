local TpSet = Class(function(self)
    self.list = {}
end)

function TpSet:Add(value)
    for k, v in pairs(self.list) do
        if v == value then
            break
        end
    end
    table.insert(self.list, value)
end

function TpSet:List(list)
    for k, v in pairs(list) do
        self:Add(v)
    end
end

function TpSet:Index(i)
    return self.list[i]
end

function TpSet:Delete(value)
    for i = #self.list, 1, -1 do
        if self.list[i] == value then
            table.remove(self.list, i)
        end
    end
end

function TpSet:Pop(idx)
    idx = idx or #self.list
    idx = math.min(#self.list, math.max(1, idx))
    table.remove(self.list, idx)
end

return TpSet