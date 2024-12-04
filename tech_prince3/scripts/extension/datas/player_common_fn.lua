local function player_common_fn(inst)
    inst:AddComponent("tp_skill_tree")
    inst:AddComponent("wg_start")
    inst.components.wg_start:AddFn(function(inst)
        -- fire shrine
        -- local x,y,z = inst.Transform:GetWorldPosition()

        -- local ground = GetWorld()

        -- for i=-1,1 do
        --     for t=-1,1 do
        --         local xp = x - 2  + (i*4)
        --         local zp = z - 2  + (t*4)
        --         local xt, yt = ground.Map:GetTileCoordsAtPoint(xp, y, zp)
        --         ground.Map:SetTile(xt,yt, GROUND.PIGRUINS_NOCANOPY)
        --         ground.Map:RebuildLayer( GROUND.PIGRUINS_NOCANOPY, xt, yt )
        --     end
        -- end

        -- x = math.floor(x) +.5
        -- z = math.floor(z) +.5
        -- local wall1 = SpawnPrefab("wall_pig_ruins_repaired")
        -- wall1.Transform:SetPosition(x-5,0,z-5)
        -- local wall2 = SpawnPrefab("wall_pig_ruins_repaired")
        -- wall2.Transform:SetPosition(x+5,0,z+5)	
        -- local wall3 = SpawnPrefab("wall_pig_ruins_repaired")
        -- wall3.Transform:SetPosition(x+5,0,z-5)	
        -- local wall4 = SpawnPrefab("wall_pig_ruins_repaired")
        -- wall4.Transform:SetPosition(x-5,0,z+5)	


        -- local campfire = SpawnPrefab("tp_campfire")
        -- campfire.Transform:SetPosition(x+3,0,z)
        -- campfire.components.ak_editor.text = "FireShrine"
        -- SpawnPrefab("tp_start_point").Transform:SetPosition(x,y,z)
        -- skill
        inst.components.tp_skill_tree:UnlockSkill(inst.prefab)
    end)
end

return player_common_fn