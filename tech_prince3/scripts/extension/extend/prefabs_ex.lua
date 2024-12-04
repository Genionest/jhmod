local Kit = require "extension.lib.wargon"
local Info = Sample.Info

AddPlayerPostInit(function(inst)
    local AddSpeedModifier_Mult = inst.components.locomotor.AddSpeedModifier_Mult
    function inst.components.locomotor:AddSpeedModifier_Mult(key, mod, timer)
        if mod<0 and self.inst:HasTag("speed_slow_resist") then
            mod = mod/2
        end
        AddSpeedModifier_Mult(self, key, mod, timer)
    end
end)

local no_buff_creatures = {
    ["beehive"] = true,
    ["spiderden"] = true,
    ["shurtlehole"] = true,
    ["houndmound"] = true,
    ["gnat"] = true,
}

AddPrefabPostInitAny(function(inst)
    if inst.components.combat and inst.components.health and not inst:HasTag("wall")
    and not inst:HasTag("player") and not no_buff_creatures[inst.prefab] then
        inst:AddComponent("wg_simple_buff")
    end
    if inst.components.combat and inst.components.health then
        inst:AddComponent("tp_health_bar")
        inst:AddComponent("tp_val_sheild")
    end
end)

local interalbe_items = {
    "log", "charcoal", "tar", "bird_egg", "spoiled_food",
    "spoiled_fish", "rottenegg", "doydoyegg", "tallbirdegg",
    "petals", "dragonfruit", "sand", "foliage", "redgem", 
    "bluegem", "purplegem", "yellowgem", "greengem", "orangegem",
    "bonestew", "thulecite", "dug_grass", "dug_sapling",
    "flint", "goldnugget", 
    "acorn", "pinecone", "jungletreeseed", "teatree_nut", "coconut",
}
for k, v in pairs(interalbe_items) do
    AddPrefabPostInit(v, function(inst)
        inst:AddComponent("wg_interable_item")
    end)
end

AddPrefabPostInitAny(function(inst)
    -- 附魔
    if inst.components.equippable 
    and inst.components.inventoryitem
    and inst.components.inventoryitem.cangoincontainer
    and not inst.components.stackable then
        if inst.components.tp_enchantmentable == nil then
            inst:AddComponent("tp_enchantmentable")
        end
        -- 涂抹
        if inst.components.tp_smearable == nil then
            inst:AddComponent("tp_smearable")
        end
    end
    -- food effect
    local food_type = {
        "MEAT", "VEGGIE", "INSECT", "SEEDS", "GENERIC"
    }
    if inst.components.edible 
	and (inst.components.edible.healthvalue > Info.FoodEffect.HealthValueLimit
	or inst.components.edible.sanityvalue > Info.FoodEffect.SanityValueLimit
	or inst.components.edible.hungervalue > Info.FoodEffect.HungerValueLimit) 
    then
        for k, v in pairs(food_type) do
            if inst.components.edible.foodtype==v then
                inst:AddComponent("tp_food_effect")
                -- inst.components.tp_food_effect:Random()
            end
        end
	end
end)

-- AddPrefabPostInit("armorwood", function(inst)
--     inst.components.equippable:WgAddEquipAttackedFn(function(damage, attacker, weapon, owner, inst)
--         if owner:HasTag("food_armor_wood") then
--             damage = damage - Info.FoodArmorWoodConst[1]
--         end
--         if owner:HasTag("food_armor_wood2")
--         and math.random()<Info.FoodArmorWood2Const[1] then
--             if owner.components.sanity then
--                 owner.components.sanity:DoDelta(Info.FoodArmorWood2Const[2])
--             end
--             return 0
--         end
--         if owner:HasTag("food_armor_wood3")
--         and owner.components.health
--         and owner.components.health:GetPercent()<Info.FoodArmorWood3Const[1] then
--             damage = damage - Info.FoodArmorWood3Const[2]
--         end
--         return damage
--     end)
-- end)

AddPrefabPostInit("cave_entrance", function(inst)
    inst.components.workable:SetWorkLeft(20)
    inst:ListenForEvent("worked", function(inst, data)
        if inst.worked == nil then
            inst.worked = true
            SpawnPrefab("statue_transition").Transform:SetPosition(inst:GetPosition():Get())
            for i = 2, 4 do
                inst:DoTaskInTime(i*.3, function()
                    local shadow = SpawnPrefab("tp_cave_shadow"..tostring(i))
                    shadow.Transform:SetPosition(inst:GetPosition():Get())
                    local pos = Kit:find_walk_pos(inst, math.random(3, 5))
                    shadow.sg:GoToState("jump_pre", pos)
                end)
            end
        end
    end)
    local OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        OnSave(inst, data)
        data.worked = inst.worked
    end
    local OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        OnLoad(inst, data)
        if data then
            inst.worked = data.worked
        end
    end
end)

AddPrefabPostInit("firerain", function(inst)
    table.insert(inst.components.groundpounder.noTags, "tp_fire_power")
    local CanHitTarget = inst.components.combat.CanHitTarget
    inst.components.combat.CanHitTarget = function(self, target, ...)
        if target == inst.tp_owner then
            return false
        end
        return CanHitTarget(self, target, ...)
    end
end)

-- AddPrefabPostInit("adventure_portal", function(inst)
--     inst:AddComponent("wg_start")
--     inst.components.wg_start.on_start = function(inst)
--         local pos = inst:GetPosition()
--         pos.x = pos.x + 6
--         SpawnPrefab("ak_transporter2").Transform:SetPosition(pos:Get())
--     end
-- end)

-- AddPrefabPostInit("teleportato_base", function(inst)
--     inst:AddComponent("wg_start")
--     inst.components.wg_start.on_start = function(inst)
--         local pos = inst:GetPosition()
--         pos.x = pos.x + 6
--         SpawnPrefab("ak_transporter2").Transform:SetPosition(pos:Get())
--     end
-- end)

-- AddPrefabPostInit("sunken_boat", function(inst)
--     inst:AddComponent("wg_start")
--     inst.components.wg_start.on_start = function(inst)
--         local pos = Kit:find_walk_pos(inst, 8)
--         if pos then
--             SpawnPrefab("ak_transporter2").Transform:SetPosition(pos:Get())
--         end
--     end
-- end)

AddPrefabPostInit("tornado", function(inst)
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.TORNADO_DAMAGE)
end)