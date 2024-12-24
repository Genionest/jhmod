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

local function fn(inst)

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
    if inst.components.edible then
        for k, v in pairs(food_type) do
            if inst.components.edible.foodtype==v then
                inst:AddComponent("tp_food_effect")
                -- inst.components.tp_food_effect:Random()
            end
        end
    end
    -- 存在时间
    if inst.components.inventoryitem
    and inst.components.inventoryitem.cangoincontainer then
        if inst.components.tp_exist_time == nil then
            inst:AddComponent("tp_exist_time")
        end
    end
end
AddPrefabPostInitAny(fn)

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

-- 敲洞穴入口会招来影子
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

-- 火雨不会伤害其tp_owner
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

-- 给飓风添加攻击组件, 让其能够成为攻击来源
AddPrefabPostInit("tornado", function(inst)
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.TORNADO_DAMAGE)
end)

-- 防止根箱的本体被破坏
AddPrefabPostInit("roottrunk", function(inst)
    inst:RemoveComponent("workable")
end)

-- 战车不会直接撞死拥有生物装备的生物
local function fn(inst)
    inst.Physics:SetCollisionCallback(function(inst, other) 
        local v1 = Vector3(inst.Physics:GetVelocity())
        if other == GetPlayer() then
            return
        end
        if v1:LengthSq() < 42 then return end
    
        TheCamera:Shake("SIDE", 0.5, 0.05, 0.1)
        
        inst:DoTaskInTime(2*FRAMES, function()   
            if  (other and other:HasTag("smashable") 
            and other.components.tp_creature_equip==nil) then
                --other.Physics:SetCollides(false)
                other.components.health:Kill()
            elseif other and other.components.workable and other.components.workable.workleft > 0 then
                SpawnPrefab("collapse_small").Transform:SetPosition(other:GetPosition():Get())
                other.components.workable:Destroy(inst)
            elseif other and other.components.health and other.components.health:GetPercent() >= 0 then
                if not inst.recentlycharged then
                    inst.recentlycharged = {}
                end
            
                for k,v in pairs(inst.recentlycharged) do
                    if v == other then
                        --You've already done damage to this by charging it recently.
                        return
                    end
                end
                inst.recentlycharged[other] = other
                inst:DoTaskInTime(3, function() inst.recentlycharged[other] = nil end)
                inst.components.combat:DoAttack(other, inst.weapon)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/rook/explo") 
            end
        end)
    end)
end
AddPrefabPostInit("rook", fn)
AddPrefabPostInit("rook_nightmare", fn)