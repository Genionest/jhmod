local BossSpawner = Class(function(self, inst)
    self.inst = inst
    self.spawned = {}
end)

function BossSpawner:CanSpawnBoss(boss)
    return not self.spawned[boss]
end

function BossSpawner:SpawnBoss(boss)
    if self.spawned[boss] == nil then
        self.spawned[boss] = true
    end
end

function BossSpawner:SpawnBossWithFn(boss, fn)
    if self:CanSpawnBoss(boss) then
        fn(self.inst)
    end
end

function BossSpawner:OnSave()
    return {
        spawned = self.spawned,
    }
end

function BossSpawner:OnLoad(data)
    if data then
        self.spawned = data.spawned or {}
    end
end

return BossSpawner