local items = {
    spear = {
        "tp_spear_trap",
        "tp_staff_trinity",
        "tp_spear_lance",
        "tp_spear_gungnir",
    },
}

AddComponentPostInit('builder', function(self)
    local old_can_pt = self.CanBuildAtPoint
    function self:CanBuildAtPoint(pt, recipe)
        if recipe.aquatic == false and recipe.tp_pot_structure then
            local ground = GetWorld()
            local tile = GROUND.GRASS
            if ground and ground.Map then
                tile = ground.Map:GetTileAtPoint(pt:Get())
            end

            local onWater = ground.Map:IsWater(tile)
            local boating = self.inst.components.driver and self.inst.components.driver.driving
            if boating then
                local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 6, nil, {'player', 'fx', 'NOBLOCK', "tp_structure_pot"}) -- or we could include a flag to the search?
                for k, v in pairs(ents) do
                    if v ~= self.inst and (not v.components.placer) and v.entity:IsVisible() and not (v.components.inventoryitem and v.components.inventoryitem.owner) then
                        local min_rad = recipe.min_spacing or 2+1.2
                        local dsq = distsq(Vector3(v.Transform:GetWorldPosition()), pt)
                        if dsq <= min_rad*min_rad then
                            return false
                        end
                    end
                end
                local rafts = WARGON.finds(pt, .5, {"tp_structure_pot"})
                if rafts and #rafts > 0 then
                    return true
                end
                -- for k, v in pairs(ents) do
                --     local dsq = distsq(Vector3(v.Transform:GetWorldPosition()), pt)
                --     if dsq <= 1 then
                --         return true
                --     end
                -- end
            end
        end
        return old_can_pt(self, pt, recipe)
    end
end)


local function SetRecipe()
    local recipe = GetAllRecipes()
    -- tp_raft
    local pot_structures = {
        "cookpot",
        "icebox",
        "tent",
        "meatrack",
        "icemaker",
        "birdcage",
    }
    for k, v in pairs(pot_structures) do
        if recipe[v] then
            recipe[v].tp_pot_structure = true
        end
    end
    -- resurrectionstatue
    for k, v in pairs(recipe["resurrectionstatue"].ingredients) do
        v.amount = math.floor(v.amount/2)
    end
    -- primeape
    -- recipe["primeapebarrel"].game_type = RECIPE_GAME_TYPE.COMMON
end

SetRecipe()