local TpPointCollector = Class(function(self, inst)
    self.inst = inst
    self.points = {}
    self.auto_spawner = {}
end)

function TpPointCollector:Collect()
    local x, y, z = self.inst:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 9999, {"tp_point_postman"})
    for k, v in pairs(ents) do
        local pos = v:GetPosition()
        local kind = v.components.tp_postman.kind
        self:CollectPoint(pos, kind)
        v:Remove()
    end
    for k, v in pairs(self.auto_spawner) do
        local pos = v:GetPoint(v)
        if self.inst.components.tp_boss_spawner:CanSpawnBoss(v) then
            local obj = SpawnPrefab(v)
            obj.Transform:SetPosition(pos:Get())
            self.inst.components.tp_boss_spawner:SpawnBoss(v)
        end
    end
end

function TpPointCollector:CollectPoint(pos, kind)
    kind = kind or "boss"
    if self.points[kind] == nil then
        self.points[kind] = {}
    end
    table.insert(self.points[kind], pos)
end

function TpPointCollector:GetPoint(kind)
    kind = kind or "boss"
    if self.points[kind] then
        local n = #self.points[kind]
        if n > 0 then
            local m = math.random(n)
            local pos = self.points[kind][m]
            table.remove(self.points[kind], m)
            return Vector3(pos.x, pos.y, pos.z)
        end
    end
end

function TpPointCollector:Print()
    print("TpPointCollector:")
    for k, v in pairs(self.points) do
        print(k)
        for k2, v2 in pairs(v) do
            print(v2)
        end
    end
end

function TpPointCollector:OnSave()
    return {
        points = self.points
    }
end

function TpPointCollector:OnLoad(data)
    if data then
        self.points = data.points or {}
    end
end

return TpPointCollector