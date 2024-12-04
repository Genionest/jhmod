local Kit = require "extension.lib.wargon"
local EntUtil = require "extension.lib.ent_util"
local FxManager = Sample.FxManager
local Info = Sample.Info
local AssetMaster = Sample.AssetMaster

local function wake_wall(pos)
    local x, y, z = pos:Get()
    local ents = TheSim:FindEntities(x, y, z, 25, {"tp_wall_wood"}, {})
    for k, v in pairs(ents) do
        v:wake()
    end
end

AddPlayerPostInit(function(inst)
    -- 隐形人
    -- local mt = getmetatable(inst.AnimState)
    -- local OverrideSymbol = rawget(mt.__index, "OverrideSymbol")
    -- getmetatable(inst.AnimState).__index.OverrideSymbol = function(animstate, ...)
    --     OverrideSymbol(animstate, ...)
    --     if animstate.tp_fx then
    --         animstate.tp_fx:PushEvent("override", {...})
    --         print("override symbol", ...)
    --         -- inst.tp_fx.AnimState:OverrideSymbol(...)
    --         -- OverrideSymbol(inst.tp_fx.AnimState, ...)
    --         -- inst.tp_fx.AnimState:OverrideSymbol(...)
    --     end
    -- end
    inst:DoTaskInTime(0, function()
        local man = SpawnPrefab("tp_invisible_man")
        man.Transform:SetPosition(0,0,0)
        inst.tp_fx = man
        inst.tp_fx:Hide()
        inst:AddChild(inst.tp_fx)
        -- 加载武器在inventory.OnLoad里,更早
        local weapon = inst.components.combat:GetWeapon()
        if weapon
        and weapon.components.tp_forge_level
        and weapon.components.tp_forge_level.element == nil then
            if weapon.components.equippable.symbol then
                inst.tp_fx:Show("ARM_carry")
                inst.tp_fx:Hide("ARM_normal")
                local symbol, build, symbol2 = AssetMaster:GetSymbol(weapon.components.equippable.symbol)
                inst.tp_fx.AnimState:OverrideSymbol(symbol, build, symbol2)
            else
                local onequipfn = weapon.components.equippable.onequipfn
                onequipfn(weapon, inst.tp_fx)
            end
            if weapon:HasTag("element_weapon") then
                inst.tp_fx:Show()
            else
                inst.tp_fx:Hide()
            end
        end
        -- inst.tp_fx.AnimState:SetMultColour(0,1,0,.7)
        -- man:ListenForEvent("override", function(inst, data)
        --     man.AnimState:OverrideSymbol(unpack(data))
        -- end)
        -- mt.__index.tp_fx = man
        -- inst.AnimState.tp_fx = man
        -- man.AnimState = inst.AnimState
    end)
    inst:ListenForEvent("equip", function(inst, data)
        if inst.tp_fx 
        and data.eslot == EQUIPSLOTS.HANDS 
        and data.item
        and data.item.components.tp_forge_level
        and data.item.components.tp_forge_level.element == nil then
            if data.item.components.equippable.symbol then
                inst.tp_fx:Show("ARM_carry")
                inst.tp_fx:Hide("ARM_normal")
                local symbol, build, symbol2 = AssetMaster:GetSymbol(data.item.components.equippable.symbol)
                inst.tp_fx.AnimState:OverrideSymbol(symbol, build, symbol2)
            else
                local onequipfn = data.item.components.equippable.onequipfn
                onequipfn(data.item, inst.tp_fx)
            end
            if data.item:HasTag("element_weapon") then
                inst.tp_fx:Show()
            else
                inst.tp_fx:Hide()
            end
        end
    end)
    inst:ListenForEvent("unequip", function(inst, data)
        inst.tp_fx.AnimState:Hide("ARM_carry")
        inst.tp_fx.AnimState:Show("ARM_normal")
    end)
    inst:AddComponent("wg_buff")
    inst.components.wg_buff:Start()
    inst:AddComponent("wg_timer_manager")
    inst.components.wg_timer_manager:Start()

    inst:AddComponent("wg_recharge_manager")
    inst:AddComponent("ak_electric_manager")
    -- boss召唤
    inst:AddComponent("tp_boss_spawner")
    inst:AddComponent("tp_point_collector")
    -- inst.components.tp_point_collector.auto_spawner = {
    --     "tp_fake_knight_room", "tp_hornet_room",
    --     "tp_soul_student_room", "tp_combat_lord_room",
    --     "tp_templar", "tp_sign_rider",
    -- }
    inst:AddComponent("tp_body_size")
    inst:AddComponent("tp_val_mana")
    inst:DoTaskInTime(0, function()
        inst.components.tp_val_mana:InitBadge()
    end)
    inst:AddComponent("tp_val_vigor")
    inst:DoTaskInTime(0, function()
        inst.components.tp_val_vigor:InitBadge()
    end)
    -- 精力空了不能攻击
    local CanAttack =  inst.components.combat.CanAttack
    inst.components.combat.CanAttack = function(self, target)
        if self.inst.components.tp_val_vigor:IsEmpty() then
            return false
        end
        return CanAttack(self, target)
    end
    local ForceAttack =  inst.components.combat.ForceAttack
    inst.components.combat.ForceAttack = function(self)
        if self.inst.components.tp_val_vigor:IsEmpty() then
            return false
        end
        return ForceAttack(self)
    end
    -- 技能按钮
    inst:AddComponent("tp_player_button")
    -- local level_data = inst.level_data
    -- local attrs = level_data.attrs
    -- inst.components.health:SetMaxHealth(attrs.hp[1])
    -- inst.components.sanity:SetMax(attrs.sp[1])
    -- inst.components.hunger:SetMax(attrs.hg[1])
    -- inst.components.combat:AddDamageModifier("tp_level0", attrs.dm[1])
    inst:AddComponent("tp_level")
    -- inst.components.tp_level:SetGrowthAttr({
    --     health = {
    --         (attrs.hp[2]-attrs.hp[1])*0.1, 
    --         (attrs.hp[3]-attrs.hp[2])*0.1, 
    --         (attrs.hp[4]-attrs.hp[3])*0.1
    --     },
    --     sanity = {
    --         (attrs.sp[2]-attrs.sp[1])*0.1, 
    --         (attrs.sp[3]-attrs.sp[2])*0.1, 
    --         (attrs.sp[4]-attrs.sp[3])*0.1
    --     },
    --     hunger = {
    --         (attrs.hg[2]-attrs.hg[1])*0.1, 
    --         (attrs.hg[3]-attrs.hg[2])*0.1, 
    --         (attrs.hg[4]-attrs.hg[3])*0.1
    --     },
    --     dmg_mult = {
    --         (attrs.dm[2]-attrs.dm[1])*0.1, 
    --         (attrs.dm[3]-attrs.dm[2])*0.1, 
    --         (attrs.dm[4]-attrs.dm[3])*0.1
    --     },
    -- })
    -- inst.components.tp_level:SetLevelFn(level_data.level_fn)
    -- inst.components.tp_level:SetAdvancedFn(level_data.advance_fn)
    -- inst:ListenForEvent("tp_level_up", level_data.tp_level_up)
    -- inst:ListenForEvent("tp_be_advanced", level_data.tp_be_advanced)
    inst.components.tp_level:Upgrade()
    inst:AddComponent("tp_player_attr")
    inst.components.tp_player_attr:UpdateAttr()
    inst:AddComponent("tp_ornament")
    -- 不灭人偶
    inst:AddComponent("tp_puppet_mgr")
    -- 由postman自行提交地点，不用玩家来收集
    -- inst:DoTaskInTime(3, function()
    --     inst.components.tp_point_collector:Collect()
    -- end)
    -- 传递击杀事件给装备
    inst:ListenForEvent("killed", function(inst, data)
        data.owner = inst
        local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item then
            item:PushEvent("wg_owner_killed", data)
        end
        local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
        if item then
            item:PushEvent("wg_owner_killed", data)
        end
        local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if item then
            item:PushEvent("wg_owner_killed", data)
        end
    end)
    -- 特殊tag
    local sp_tags = {
        ["beefalo"]=true,
        ["not_hit_stunned"]=true,
        ["notarget"]=true,
    }
    local AddTag = inst.AddTag
    inst.AddTag = function(self, tag, raw)
        if (not raw) and sp_tags[tag] then
            EntUtil:add_tag(self, tag)
        else
            AddTag(self, tag)
        end
    end
    local RemoveTag = inst.RemoveTag
    inst.RemoveTag = function(self, tag, raw)
        if (not raw) and sp_tags[tag] then
            EntUtil:remove_tag(self, tag)
        else
            RemoveTag(self, tag)
        end
    end

    
    -- inst:DoTaskInTime(5, function()
    --     if not GetWorld():IsCave() then
    --         local boss_t = {
    --             "ak_transporter2",
    --         }
    --         for k, v in pairs(boss_t) do
    --             if inst.components.tp_boss_spawner:CanSpawnBoss(v) then
    --                 local pos = inst.components.tp_point_collector:GetPoint("boss")
    --                 if pos then
    --                     inst.components.tp_boss_spawner:SpawnBoss(v)
    --                     wake_wall(pos)
    --                     local boss = SpawnPrefab(v)
    --                     boss.Transform:SetPosition(pos:Get())
    --                 end
    --             end
    --         end
    --         local room_boss_t = {
    --             "tp_fake_knight_room",
    --             "tp_hornet_room",
    --             "tp_soul_student_room",
    --             "tp_combat_lord_room",
    --         }
    --         for k, v in pairs(room_boss_t) do
    --             if inst.components.tp_boss_spawner:CanSpawnBoss(v) then
    --                 local pos = inst.components.tp_point_collector:GetPoint("room_boss")
    --                 if pos then
    --                     inst.components.tp_boss_spawner:SpawnBoss(v)
    --                     local boss = SpawnPrefab(v)
    --                     boss.Transform:SetPosition(pos:Get())
    --                 end
    --             end
    --         end
    --     end
    -- end)
    -- inst:ListenForEvent("daytime", function(world, data)
    --     local day = data.day+1
    --     if inst.components.tp_boss_spawner:CanSpawnBoss("tp_templar") then
    --         if day>=Info.BossAppearDay.Templar then
    --             -- local pos = Kit:find_walk_pos(inst, math.random(4, 6))
    --             -- pos = pos or inst:GetPosition()
    --             local pos = inst.components.tp_point_collector:GetPoint()
    --             if pos then
    --                 inst.components.tp_boss_spawner:SpawnBoss("tp_templar")
    --                 wake_wall(pos)
    --                 FxManager:MakeFx("statue_transition", pos)
    --                 local boss = SpawnPrefab("tp_templar")
    --                 boss.Transform:SetPosition(pos:Get())
    --                 boss.sg:GoToState("jump_pre")
    --             end
    --         end
    --     end
    --     if inst.components.tp_boss_spawner:CanSpawnBoss("tp_sign_rider") then
    --         if day>=Info.BossAppearDay.SignRider then
    --             local beefalo = c_find("beefalo")
    --             if beefalo then
    --                 local pos = beefalo:GetPosition()
    --                 beefalo:Remove()
    --                 inst.components.tp_boss_spawner:SpawnBoss("tp_sign_rider")
    --                 local boss = SpawnPrefab("tp_sign_rider")
    --                 boss.Transform:SetPosition(pos:Get())
    --                 FxManager:MakeFx("beefalo_transform_fx", pos)
    --             end
    --         end
    --     end
    -- end, GetWorld())

    if WG_TEST then
        local chest_items = require("extension.datas.chest_items")
        inst:AddComponent("wg_start")
        inst.components.wg_start.on_start = function(inst)
            c_give("ak_green_amulet")
            c_give("ak_gps")
            -- local chest = SpawnPrefab("casket")
            -- local tbl = {
            --     {"log", 20*10},
            --     {"charcoal", 10},
            --     {"pinecone", 40},
            --     {"rocks", 40*5},
            --     {"goldnugget", 20*3},
            --     {"nitre", 20*2},
            --     {"flint", 40*2},
            --     {"iron", 40},
            --     {"cutreeds", 20},
            --     {"twigs", 40},
            --     {"cutgrass", 40},
            --     {"dug_sapling", 40},
            --     {"dug_grass", 40},
            --     {"dug_berrybush", 10},
            --     {"berries", 10},
            --     {"petals", 20},
            --     {"gears"},
            -- }
            -- for k, v in pairs(tbl) do
            --     local item = SpawnPrefab(v[1])
            --     local n = v[2] or 1
            --     if item.components.stackable then
            --         item.components.stackable:SetStackSize(n)
            --     else
            --         for i = 2, n do
            --             local item = SpawnPrefab(v[1])
            --             chest.components.container:GiveItem(item)
            --         end
            --     end
            --     chest.components.container:GiveItem(item)
            -- end
            -- local pt = inst:GetPosition()
            -- for k, v in pairs(chest_items) do
            --     -- local radius = PI/180*360/3*k
            --     -- local dist = 4
            --     -- local pos = pt + Vector3(math.cos(radius)*dist, 0, math.sin(radius)*dist)
            --     -- local chest = SpawnPrefab("treasurechest")
            --     -- chest.Transform:SetPosition(pos:Get())
            --     for k2, v2 in pairs(v) do
            --         local item = SpawnPrefab(v2.item)
            --         if v2.count and v2.count>1 then
            --             item.components.stackable:SetStackSize(v2.count)
            --         end
            --         chest.components.container:GiveItem(item)
            --     end
            -- end
            
        end        

        local EnchantmentManager = Sample.EnchantmentManager
        TheInput:AddKeyDownHandler(KEY_END, function()
            c_give("spear")
            c_give("tp_potion_fire_atk")
            -- local foods = {
            --     "carrot",
            --     "carrot_cooked",
            --     "berries",
            --     "berries_cooked",
            --     "bird_egg",
            --     "bird_egg_cooked",
            --     "meat",
            --     "meat_dried",
            --     "cookedmeat",
            -- }
            -- for k, v in pairs(foods) do
            --     local food = SpawnPrefab(v)
            --     food.components.tp_food_effect:Random()
            --     food.components.stackable:SetStackSize(5)
            --     inst.components.inventory:GiveItem(food)
            -- end

            -- inst.components.tp_level:ExpDelta(1000)
            -- if inst.components.tp_level:CanBeAdvanced(2) then
            --     c_give("tp_advance_chip")
            -- end
            -- if inst.components.tp_level:CanBeAdvanced(3) then
            --     c_give("tp_advance_chip2")
            -- end

            -- local spear = SpawnPrefab("spear")
            -- local id = "frozen_route"
            -- local data = EnchantmentManager:GetDataById(id)
            -- -- print("a001", data:GetId())
            -- -- if spear.components.tp_enchantmentable:TestData(data) then
            --     spear.components.tp_enchantmentable:Enchantment({
            --         quality = 3,
            --         ids = {id},
            --     })
            -- -- end
            -- inst.components.inventory:GiveItem(spear)
            
            -- local armor = SpawnPrefab("armorwood")
            -- local id = "high_jump"
            -- local data = EnchantmentManager:GetDataById(id)
            -- -- print("a001", data:GetId())
            -- -- if armor.components.tp_enchantmentable:TestData(data) then
            --     armor.components.tp_enchantmentable:Enchantment({
            --         quality = 3,
            --         ids = {id},
            --     })
            -- -- end
            -- inst.components.inventory:GiveItem(armor)
        end)
    
    end

end)