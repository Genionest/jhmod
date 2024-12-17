local function player_common_fn(inst)
    inst:AddComponent("tp_skill_tree")
    inst:AddComponent("wg_start")
    inst.components.wg_start:AddFn(function(inst)
        -- skill
        inst.components.tp_skill_tree:UnlockSkill(inst.prefab)
    end)
end

return player_common_fn