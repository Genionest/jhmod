local Info = Sample.Info

local function fn(inst)
    inst:AddComponent("tp_creature_equip")
    inst:DoTaskInTime(0, function()
        if inst.prefab == "antman_warrior" then
            if inst.queen and inst.components.tp_creature_equip:Test() then
                local equips = inst.queen.components.tp_creature_equip.equips
                for k2, v2 in pairs(equips) do
                    inst.components.tp_creature_equip:SetEquipById(v2)
                end
            end
        else
            inst.components.tp_creature_equip:Random()
        end
    end)
end
for k, v in pairs(Info.CreatureEquipMonster) do
    AddPrefabPostInit(v, fn)
end


local spider_kind = {
    "spider", "spider_warrior", "spider_hider", "spider_spitter", "spider_dropper"
}
for k, v in pairs(spider_kind) do
    AddPrefabPostInit("spider", function(inst)
        inst.components.tp_creature_equip.include_ids = { poison_gland=true }
    end)
end

local animals_include_equip = {
    hound = { sharp_tooth=true },
    firehound = { fire_stone=true },
    icehound = { ice_stone=true },
    bat = { sharp_tooth=true },
    bunnyman = { sharp_tooth=true },
    beefalo = { sharp_horn=true },
    pigman = { fighter=true },
    pigguard = { fighter=true },
    merm = { fighter=true },
    leif = { firm=true },
    leif_sparse = { firm=true },
    knight = { gear_core=true },
    knight_nightmare = { gear_core=true },
    bishop = { gear_core=true },
    bishop_nightmare = { gear_core=true },
    rook = { gear_core=true },
    rook_nightmare = { gear_core=true },
}

for k, v in pairs(animals_include_equip) do
    AddPrefabPostInit(k, function(inst)
        inst.components.tp_creature_equip.include_ids = v
    end)
end

for k, v in pairs(Info.Boss) do
    AddPrefabPostInit(v, function(inst)
        inst.components.tp_creature_equip.include_ids = { world_boss = true }
    end)
end

-- for k, v in pairs(Info.ProfessionMonster) do
--     AddPrefabPostInit(v, function(inst)
--         inst:AddComponent("tp_profession")
--         inst:DoTaskInTime(0, function()
--             inst.components.tp_profession:Random()
--         end)
--     end)
-- end
