AddComponentPostInit("interiorspawner", function(self)
    local UnloadInterior = self.UnloadInterior
    function self:UnloadInterior()
        if self.current_interior then
            if self.current_interior.dungeon_name == "boss_room" then
                -- 退出boss房,说明打败了boss,清理掉boss房周围的障碍物
                -- 要延迟一下, 现在还没有完全退出
                GetPlayer():DoTaskInTime(.1, function()
                    local x, y, z = GetPlayer():GetPosition():Get()
                    local ents = TheSim:FindEntities(x, y, z, 20, {"tp_boss_obstacle"})
                    for k, v in pairs(ents) do
                        v:Remove() 
                    end
                end)
            end
        end
        UnloadInterior(self)
    end
end)