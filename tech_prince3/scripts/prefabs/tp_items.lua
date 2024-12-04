local Util = require "extension.lib.wg_util"
local AssetUtil = require "extension/lib/asset_util"
local PrefabUtil = require "extension/lib/prefab_util"
local EntUtil = require "extension/lib/ent_util"
local Kit = require "extension.lib.wargon"
local AssetMaster = Sample.AssetMaster
local BuffManager = Sample.BuffManager
local EnchantmentManager = Sample.EnchantmentManager
local FxManager = Sample.FxManager
local Info = Sample.Info

local prefs = {}

local spear_test = Prefab("tp_spear_test", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_spear_lance", true)
    local atlas, image = AssetMaster:GetImage("tp_spear_lance", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(786)
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable.symbol = "tp_spear_lance"
    return inst
end)
table.insert(prefs, spear_test)

local armor_test = Prefab("tp_armor_test", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_armor_health", true)
    local atlas, image = AssetMaster:GetImage("tp_armor_health", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:WgAddEquipMaxHealthModifier("test", 2853)
    inst.components.equippable.symbol = "tp_armor_health"
    return inst
end)
table.insert(prefs, armor_test)

local MultToolConst = {300, .1, 50}
local mult_tool = Prefab("tp_mult_tool", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_mult_tool", true)
    local atlas, image = AssetMaster:GetImage("tp_mult_tool", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddTag("nopunch")
    inst.states = {
        "axe", "pickaxe", "shovel", "machete", "hammer", "bugnet",
        "cane", "batbat",
    }
    inst.state = 1
    inst.state_equip_fn = function(inst, owner, old_state)
        local state = inst.states[inst.state]
        if state == old_state then
            return
        end
        if state == "batbat" then
            EntUtil:add_tag(owner, "wg_fast_harvester")
        elseif state == "cane" then
            EntUtil:add_speed_mod(owner, "equipslot_hands", MultToolConst[2])
        end
        if old_state == "batbat" then
            EntUtil:remove_tag(owner, "wg_fast_harvester")
        elseif old_state == "cane" then
            EntUtil:rm_speed_mod(owner, "equipslot_hands")
        end
        local symbol = inst.components.equippable.symbol
        local sym, build, sym2 = AssetMaster:GetSymbol(symbol)
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
        owner.AnimState:OverrideSymbol(sym, build, sym2)
    end
    inst.state_fn = function(inst, old_state)
        local state = inst.states[inst.state]
        if state == old_state then
            return
        end
        local bank, build, animation, water = AssetMaster:GetAnimation(state, true)
        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(animation)
        if water then
            MakeInventoryFloatable(inst, water, animation)
        end
        local atlas, image = AssetMaster:GetImage(state, true)
        inst.components.inventoryitem.atlasname = atlas
        inst.components.inventoryitem:ChangeImageName(image)
        inst.components.equippable.symbol = state
        if state == "axe" then
            inst.components.tool:SetAction(ACTIONS.CHOP, 1)
        elseif state == "pickaxe" then
            inst.components.tool:SetAction(ACTIONS.MINE, 1)
        elseif state == "shovel" then
            inst.components.tool:SetAction(ACTIONS.DIG, 1)
        elseif state == "machete" then
            inst.components.tool:SetAction(ACTIONS.HACK, 1)
        elseif state == "hammer" then
            inst.components.tool:SetAction(ACTIONS.HAMMER, 1)
        elseif state == "bugnet" then
            inst.components.tool:SetAction(ACTIONS.NET, 1)
        elseif state == "cane" then
            inst.components.equippable.walkspeedmult = MultToolConst[2]
        end
        if old_state == "axe" then
            -- 不能设置为0，不然还是会触发动作
            inst.components.tool.action[ACTIONS.CHOP] = nil
        elseif old_state == "pickaxe" then
            inst.components.tool.action[ACTIONS.MINE] = nil
        elseif old_state == "shovel" then
            inst.components.tool.action[ACTIONS.DIG] = nil
        elseif old_state == "machete" then
            inst.components.tool.action[ACTIONS.HACK] = nil
        elseif old_state == "hammer" then
            inst.components.tool.action[ACTIONS.HAMMER] = nil
        elseif old_state == "bugnet" then
            inst.components.tool.action[ACTIONS.NET] = nil
        elseif old_state == "cane" then
            inst.components.equippable.walkspeedmult = nil
        end
    end
    inst:AddComponent("equippable")
    inst.components.equippable.symbol = "axe"
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:RegisterSkillInfo({})
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        local old_state = inst.states[inst.state]
        if inst.state >= #inst.states then
            inst.state = 1
        else
            inst.state = inst.state + 1
        end
        inst:state_fn(old_state)
        inst:state_equip_fn(doer, old_state)
    end
    inst.components.equippable:SetOnEquip(function(inst, owner)
        inst:state_equip_fn(owner)
    end)
    inst.components.equippable:SetOnUnequip(function(inst, owner)
        EntUtil:remove_tag(owner, "wg_fast_harvester")
        EntUtil:rm_speed_mod(owner, "equipslot_hands")
    end)
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, 1)
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(MultToolConst[1])
    inst.components.finiteuses:SetUses(MultToolConst[1])
    inst.components.finiteuses:SetOnFinished(function(inst) 
        inst:Remove() 
    end)
    inst.components.finiteuses:SetConsumption(ACTIONS.CHOP,1)
    inst.components.finiteuses:SetConsumption(ACTIONS.MINE,1)
    inst.components.finiteuses:SetConsumption(ACTIONS.DIG,1)
    inst.components.finiteuses:SetConsumption(ACTIONS.HACK,1)
    inst.components.finiteuses:SetConsumption(ACTIONS.HAMMER,1)
    inst.components.finiteuses:SetConsumption(ACTIONS.NET,1)
    inst:AddComponent("wg_interable")
    inst.components.wg_interable.test = function(inst, item, doer) 
        return item.prefab == "flint"
    end
    inst.components.wg_interable:SetFn(function(inst, item, doer) 
        if item.components.stackable then
            item = item.components.stackable:Get()
        end
        inst.components.finiteuses:Repair(MultToolConst[3])
        item:Remove()
    end)
    inst.OnSave = function(inst, data)
        data.state = inst.state
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.state = data.state
            inst:state_fn("axe")
        end
    end
    return inst
end)
table.insert(prefs, mult_tool)
Util:AddString(mult_tool.name, "多功能工具", 
"可以在斧头、稿子、铲子、砍刀、锤子、镰刀、手杖之间切换，可以用燧石修复")

local alloy = deepcopy(require "prefabs/alloy")
PrefabUtil:SetPrefabName(alloy, "tp_alloy")
PrefabUtil:HookPrefabFn(alloy, function(inst)
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_alloy", true)
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(animation)
    MakeInventoryFloatable(inst, water, animation)
    local atlas, image = AssetMaster:GetImage("tp_alloy", true)
    inst.components.inventoryitem.atlasname = atlas
    inst.components.inventoryitem:ChangeImageName(image)
end)
PrefabUtil:SetPrefabAssets(alloy, AssetMaster:GetDSAssets("tp_alloy"))
table.insert(prefs, alloy)
Util:AddString(alloy.name, "蓝色合金", "锻造材料")

local alloy_red = deepcopy(require "prefabs/alloy")
PrefabUtil:SetPrefabName(alloy_red, "tp_alloy_red")
PrefabUtil:HookPrefabFn(alloy_red, function(inst)
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_alloy_red", true)
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(animation)
    MakeInventoryFloatable(inst, water, animation)
    local atlas, image = AssetMaster:GetImage("tp_alloy_red", true)
    inst.components.inventoryitem.atlasname = atlas
    inst.components.inventoryitem:ChangeImageName(image)
end)
PrefabUtil:SetPrefabAssets(alloy_red, AssetMaster:GetDSAssets("tp_alloy_red"))
table.insert(prefs, alloy_red)
Util:AddString(alloy_red.name, "红色合金", "锻造材料")

local alloy_great = deepcopy(require "prefabs/alloy")
PrefabUtil:SetPrefabName(alloy_great, "tp_alloy_great")
PrefabUtil:HookPrefabFn(alloy_great, function(inst)
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_alloy_great", true)
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(animation)
    MakeInventoryFloatable(inst, water, animation)
    local atlas, image = AssetMaster:GetImage("tp_alloy_great", true)
    inst.components.inventoryitem.atlasname = atlas
    inst.components.inventoryitem:ChangeImageName(image)
end)
PrefabUtil:SetPrefabAssets(alloy_great, AssetMaster:GetDSAssets("tp_alloy_great"))
table.insert(prefs, alloy_great)
Util:AddString(alloy_great.name, "紫色合金", "锻造材料")

local alloy_enchant = deepcopy(require "prefabs/alloy")
PrefabUtil:SetPrefabName(alloy_enchant, "tp_alloy_enchant")
PrefabUtil:HookPrefabFn(alloy_enchant, function(inst)
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_alloy_enchant", true)
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(animation)
    MakeInventoryFloatable(inst, water, animation)
    local atlas, image = AssetMaster:GetImage("tp_alloy_enchant", true)
    inst.components.inventoryitem.atlasname = atlas
    inst.components.inventoryitem:ChangeImageName(image)

    inst:RemoveComponent("stackable")
    inst:AddTag("enchantment_medium")
    inst.quality = nil
    inst.ids = nil
    inst:AddComponent("wg_info")
    inst.random_enchant = function(inst)
        if inst.quality == nil and inst.ids == nil then
            local day = GetClock():GetNumCycles()+1
            local q = math.ceil(day/Info.MonsterStrengthen.MaxDay*4)
            if math.random() < .1 then
                q = q+1
            end
            q = math.min(5, q)
            inst.quality = q
            local ids = EnchantmentManager:GetRandomIds(1)
            inst.ids = ids
        end
    end
    inst.components.wg_info.info = function(inst)
        if inst.quality and inst.ids then
            local s = string.format("品质:%d", inst.quality)
            for _, id in pairs(inst.ids) do
                local data = EnchantmentManager:GetDataById(id)
                s = s..string.format("\n%s", data:desc(nil, 
                    {datas={[id]={0,0,0,0,0,0}}}, id))
            end
            s = s.."\n(具体数值附魔后确定)"
            s = Util:SplitSentence(s, nil, true)
            return s
        end
    end
    local colours = {
        {1, 1, 1, 1},
        {135/255, 206/255, 235/255, 1},
        {138/255, 43/255, 226/255, 1},
        {255/255, 128/255, 0, 1},
        {255/255, 215/255, 0, 1},
    }
    inst.components.wg_info.colour = function(inst)
        if inst.quality then
            return colours[inst.quality]
        end
    end
    inst.OnSave = function(inst, data)
        data.ids = inst.ids
        data.quality = inst.quality
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.ids = data.ids
            inst.quality = data.quality
        end
    end
end)
PrefabUtil:SetPrefabAssets(alloy_enchant, AssetMaster:GetDSAssets("tp_alloy_enchant"))
table.insert(prefs, alloy_enchant)
Util:AddString(alloy_enchant.name, "魔法合金", "用于附魔")

local alloy_enchant2 = deepcopy(alloy_enchant)
PrefabUtil:SetPrefabName(alloy_enchant2, "tp_alloy_enchant2")
PrefabUtil:HookPrefabFn(alloy_enchant2, function(inst)
    inst:DoTaskInTime(0, function()
        inst:random_enchant()
    end)
    inst:SetPrefabName("tp_alloy_enchant")
end)
-- local alloy_enchant2 = Prefab("tp_alloy_enchant2", function()
--     local inst = CreateEntity()
--     local trans = inst.entity:AddTransform()
--     inst:AddComponent("lootdropper")
--     inst:DoTaskInTime(0, function()
--         local alloy=SpawnPrefab("tp_alloy_enchant")
--         alloy:random_enchant()
--         -- GetPlayer().components.inventory:GiveItem(alloy)
--         inst.components.lootdropper:DropLootPrefab(alloy)
--         inst:Remove()
--     end)
    
--     return inst
-- end, {})
table.insert(prefs, alloy_enchant2)
Util:AddString(alloy_enchant2.name, "魔法合金(已附魔)", "")

local FixPowderConst = {25, 75, .1}
local fix_powder = Prefab("ak_fix_powder", function() 
    local bank, build, animation, water = AssetMaster:GetAnimation("ak_fix_powder", true)
    local atlas, image = AssetMaster:GetImage("ak_fix_powder", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 40
    inst:AddComponent("wg_interable_item")
    inst.components.wg_interable_item.test = function(inst, target, doer) 
        return target:HasTag("tp_can_fix")
    end
    inst.components.wg_interable_item:SetFn(function(inst, target, doer) 
        if inst.components.stackable then
            inst = inst.components.stackable:Get()
        end
        inst:Remove()
        if target.components.finiteuses then
            local total = target.components.finiteuses.total
            local dt = FixPowderConst[1]+math.floor(total*FixPowderConst[3])
            target.components.finiteuses:Repair(dt)
        end
        if target.components.armor then
            local max = target.components.armor.maxcondition
            local dt = FixPowderConst[2]+math.floor(max*FixPowderConst[3])
            local cur = target.components.armor.condition
            target.components.armor:SetCondition(math.min(max, dt+cur))
        end
        target:PushEvent("tp_equip_fix")
    end)

    return inst
end, AssetMaster:GetDSAssets("ak_fix_powder"))
table.insert(prefs, fix_powder)
Util:AddString(fix_powder.name, "修理粉末", 
string.format("修复你的装备，修复效果为(%d+%d%%最大耐久)或(%d+%d%%最大护甲)", 
FixPowderConst[1], FixPowderConst[3]*100, FixPowderConst[2], FixPowderConst[3]*100))

local ssd = Prefab("ak_ssd", function() 
    local bank, build, animation, water = AssetMaster:GetAnimation("ak_ssd", true)
    local atlas, image = AssetMaster:GetImage("ak_ssd", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 40

    return inst
end, AssetMaster:GetDSAssets("ak_ssd"))
table.insert(prefs, ssd)
Util:AddString(ssd.name, "数据磁盘", "制作蓝图的材料")

local essence = Prefab("tp_epic", function() 
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_epic", true)
    local atlas, image = AssetMaster:GetImage("tp_epic", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 40

    return inst
end, AssetMaster:GetDSAssets("tp_epic"))
table.insert(prefs, essence)
Util:AddString(essence.name, "精华", "稀有材料")

local level_map = Prefab("tp_level_map", function() 
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_level_map", true)
    local atlas, image = AssetMaster:GetImage("tp_level_map", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 40
    inst:AddComponent("wg_useable")
    inst.components.wg_useable.test = function(inst, doer) 
        if doer.components.tp_level then
            local need = doer.components.tp_level.need
            return doer.components.tp_level:CanLevelUp(need)
        end
    end
    inst.components.wg_useable.use = function(inst, doer) 
        inst.components.stackable:Get():Remove()
        local need = doer.components.tp_level.need
        doer.components.tp_level:ExpDelta(need)
    end

    return inst
end, AssetMaster:GetDSAssets("tp_level_map"))
table.insert(prefs, level_map)
Util:AddString(level_map.name, "升级图", "升级")

local advance_map = Prefab("tp_advance_map", function() 
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_advance_map", true)
    local atlas, image = AssetMaster:GetImage("tp_advance_map", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 40
    inst:AddComponent("wg_useable")
    inst.components.wg_useable.test = function(inst, doer) 
        if doer.components.tp_level then
            local phase = doer.components.tp_level.phase
            return doer.components.tp_level:CanBeAdvanced(phase+1)
        end
    end
    inst.components.wg_useable.use = function(inst, doer) 
        inst.components.stackable:Get():Remove()
        local phase = doer.components.tp_level.phase
        doer.components.tp_level:BeAdvanced(phase+1)
    end

    return inst
end, AssetMaster:GetDSAssets("tp_advance_map"))
table.insert(prefs, advance_map)
Util:AddString(advance_map.name, "进阶图", "进阶")

local advance_chip = Prefab("tp_advance_chip", function() 
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_advance_chip", true)
    local atlas, image = AssetMaster:GetImage("tp_advance_chip", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("wg_useable")
    inst.components.wg_useable.test = function(inst, doer) 
        -- if doer.components.tp_level then
        --     return doer.components.tp_level:CanBeAdvanced(2)
        -- end
    end
    inst.components.wg_useable.use = function(inst, doer) 
        -- doer.components.tp_level:BeAdvanced(2)
        inst:Remove()
    end

    return inst
end, AssetMaster:GetDSAssets("tp_advance_chip"))
table.insert(prefs, advance_chip)
Util:AddString(advance_chip.name, "进阶芯片", "等级达到10级时，进阶你的人物到2阶段")

local advance_chip2 = Prefab("tp_advance_chip2", function() 
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_advance_chip2", true)
    local atlas, image = AssetMaster:GetImage("tp_advance_chip2", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("wg_useable")
    inst.components.wg_useable.test = function(inst, doer) 
        -- if doer.components.tp_level then
        --     return doer.components.tp_level:CanBeAdvanced(3)
        -- end
    end
    inst.components.wg_useable.use = function(inst, doer) 
        -- doer.components.tp_level:BeAdvanced(3)
        inst:Remove()
    end

    return inst
end, AssetMaster:GetDSAssets("tp_advance_chip2"))
table.insert(prefs, advance_chip2)
Util:AddString(advance_chip2.name, "高级进阶芯片", "等级达到20级时，进阶你的人物到3阶段")

local HatWinterConst = {6}
local hat_winter = Prefab("tp_hat_winter", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_hat_winter", true)
    local atlas, image = AssetMaster:GetImage("tp_hat_winter", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddTag("hat_open")
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
    inst.components.equippable.symbol = "tp_hat_winter"
    inst:AddComponent("wg_recharge")
    inst.components.wg_recharge:SetCommon("tp_hat_winter")
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:RegisterSkillInfo()
    inst.components.wg_action_tool.purify = true
    inst.components.wg_action_tool.test = function(inst, doer)
        if inst.components.wg_recharge:IsRecharged()
        and doer.components.freezable:IsFrozen() then
            return true
        end
    end
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        doer.components.freezable:Unfreeze()
        inst.components.wg_recharge:SetRechargeTime(HatWinterConst[1], "tp_hat_winter")
    end

    return inst
end, AssetMaster:GetDSAssets("tp_hat_winter"))
table.insert(prefs, hat_winter)
Util:AddString(hat_winter.name, "冬青花环", 
string.format("解冻，有%ds的冷却时间", HatWinterConst[1]))

local HatDodgeConst = {2.5, 100}
local hat_dodge = Prefab("tp_hat_dodge", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_hat_dodge", true)
    local atlas, image = AssetMaster:GetImage("tp_hat_dodge", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddTag("hat_open")
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable.symbol = "tp_hat_dodge"
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(HatDodgeConst[2])
    inst.components.finiteuses:SetUses(HatDodgeConst[2])
    inst.components.finiteuses:SetOnFinished(function(inst)
        inst:Remove()
    end)
    inst:AddComponent("wg_recharge")
    inst.components.wg_recharge:SetCommon("tp_hat_dodge")
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool.move = true
    inst.components.wg_action_tool:RegisterSkillInfo()  -- 注册后才能按键触发
    inst.components.wg_action_tool.test = function(inst, doer)
        if inst.components.wg_recharge:IsRecharged() then
            return true
        end
    end
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        local pos = TheInput:GetWorldPosition()
        local target = TheInput:GetWorldEntityUnderMouse()
        local doer = inst.components.equippable.owner
        if pos or target then
            doer:ClearBufferedAction()
            local ba = BufferedAction(doer, target, ACTIONS.WG_DODGE, inst, pos)
            doer:PushBufferedAction(ba)
        end
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        inst.components.wg_recharge:SetRechargeTime(HatDodgeConst[1], "tp_hat_dodge")
        inst.components.finiteuses:Use()
    end

    return inst
end, AssetMaster:GetDSAssets("tp_hat_dodge"))
table.insert(prefs, hat_dodge)
Util:AddString(hat_dodge.name, "羽翼花环", 
string.format("消耗耐久进行滑铲(滑铲全过程无敌)，有%.2fs的冷却时间", HatDodgeConst[1]))

local HatPigkingConst = {20, 30}
local hat_pigking_skill = string.format("召唤一个存活%ds的猪人随从，冷却时间%ds", 
HatPigkingConst[2], HatPigkingConst[1])
local hat_pigking = Prefab("tp_hat_pigking", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_hat_pigking", true)
    local atlas, image = AssetMaster:GetImage("tp_hat_pigking", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable.symbol = "tp_hat_pigking"
    inst.components.equippable:SetOnEquip(function(inst, owner)
        EntUtil:add_tag(owner, "pigroyalty")
        inst.event_fn = EntUtil:listen_for_event(inst, "attacked", function(inst, data)
            if data and data.attacker then
                inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
                    return dude:HasTag("pig") and not dude:HasTag("guard")
                        and not dude:HasTag("werepig") 
                end, 5)
            end
        end)
    end)
    inst.components.equippable:SetOnUnequip(function(inst, owner)
        EntUtil:remove_tag(owner, "pigroyalty")
        inst:RemoveEventCallback("attacked", inst.event_fn)
        inst.event_fn = nil
    end)
    inst:AddComponent("wg_recharge")
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool:RegisterSkillInfo({})
    inst.components.wg_action_tool.test = function(inst, doer)
        if inst.components.wg_recharge:IsRecharged() then
            return true
        end
    end
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        inst.components.wg_recharge:SetRechargeTime(HatPigkingConst[1])
        local pos = Kit:find_walk_pos(doer, math.random(3, 6))
        if pos then
            FxManager:MakeFx("statue_transition_2", pos)
            FxManager:MakeFx("statue_transition", pos)
            local pig = SpawnPrefab("pigman")
            pig.Transform:SetPosition(pos:Get())
            pig.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
            doer.components.leader:AddFollower(pig)
            pig.components.follower:AddLoyaltyTime(9999)
            BuffManager:AddBuff(pig, "summon", HatPigkingConst[2])
        end
    end

    return inst
end, AssetMaster:GetDSAssets("tp_hat_pigking"))
table.insert(prefs, hat_pigking)
Util:AddString(hat_pigking.name, "猪王帽子", 
string.format("戴上后会成为猪人的皇室成员(类似薇尔芭)，拥有技能%s", hat_pigking_skill))

local SignStaffConst = {3}
local sign_staff = Prefab("tp_sign_staff", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_sign_staff", true)
    local atlas, image = AssetMaster:GetImage("tp_sign_staff", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(42)
    inst.components.weapon:SetRange(8,10)
    inst.components.weapon:SetOnAttack(function(inst, owner, target)
        owner.components.sanity:DoDelta(-SignStaffConst[1])
    end)
    inst.components.weapon:SetProjectile("tp_sign_proj")
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable.symbol = "tp_sign_staff"
    inst.components.equippable:SetOnEquip(function(inst, owner)
    end)
    inst.components.equippable:SetOnUnequip(function(inst, owner)
    end)
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(100)
    inst.components.finiteuses:SetUses(100)
    inst.components.finiteuses:SetOnFinished(function(inst)
        inst:Remove()
    end)

    return inst
end, AssetMaster:GetDSAssets("tp_sign_staff"))
table.insert(prefs, sign_staff)
Util:AddString(sign_staff.name, "路牌法杖", 
string.format("消耗%d点理智,召唤路牌远程攻击", SignStaffConst[1]))

-- local ScrollTemplarConst = {50}
-- local scroll_templar = Prefab("tp_scroll_templar", function()
--     local bank, build, animation, water = AssetMaster:GetAnimation("tp_scroll_templar", true)
--     local atlas, image = AssetMaster:GetImage("tp_scroll_templar", true)
--     local inst = PrefabUtil:MakeItem(
--         bank, build, animation, water,
--         atlas, image
--     )
--     inst:AddComponent("stackable")
--     inst.components.stackable.maxsize = 40
--     inst:AddComponent("book")
--     inst.components.book.onread = function(inst, reader)
--         reader.components.sanity:DoDelta(-ScrollTemplarConst[1])
--         if inst.components.stackable then
--             inst = inst.components.stackable:Get()
--         end
--         inst:Remove()
--         BuffManager:AddBuff(reader, "tp_scroll_templar")
--         return true
--     end
--     inst.components.book.onreadtest = function(inst, reader)
--         if reader.components.sanity 
--         and reader.components.sanity.current>ScrollTemplarConst[1] then
--             return true
--         end
--     end
--     inst.components.book:SetAction(ACTIONS.READMAP)

--     return inst
-- end, AssetMaster:GetDSAssets("tp_scroll_templar"))
-- table.insert(prefs, scroll_templar)
-- local buff = BuffManager:GetDataById("tp_scroll_templar")
-- Util:AddString(scroll_templar.name, "《圣堂武士威尔逊》", 
-- string.format("阅读消耗%d点理智，获得buff(%s)", ScrollTemplarConst[1], buff:desc()))

local treasure_map = Prefab("tp_treasure_map", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_treasure_map", true)
    local atlas, image = AssetMaster:GetImage("tp_treasure_map", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 40
    inst:AddComponent("book")
    inst.components.book.onread = function(inst, reader)
        local inst = inst.components.stackable:Get()
        for tries = 1, 100 do
            local pt = reader:GetPosition()
            local pos = nil
            pos = FindGroundOffset(pt, math.random() * 2 * math.pi, math.random(100, 700), 18)
            if pos then
                local pb = SpawnPrefab("buriedtreasure")
                local spawn_pos = pt + pos
                pb.Transform:SetPosition(spawn_pos:Get())
                pb:SetRandomTreasure()
                pb:Reveal(pb)
                pb:RevealFog(pb)
                pb:FocusMinimap(pb)
                inst:Remove()
                return true
            end
        end
    end
    inst.components.book.onreadtest = function(inst, reader)
        return true
    end
    inst.components.book:SetAction(ACTIONS.READMAP)

    return inst
end, AssetMaster:GetDSAssets("tp_treasure_map"))
table.insert(prefs, treasure_map)
Util:AddString(treasure_map.name, "藏宝图", "发现宝藏")

local dimensional = Prefab("ak_dimensional", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("ak_dimensional", true)
    local atlas, image = AssetMaster:GetImage("ak_dimensional", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 40

    return inst
end, AssetMaster:GetDSAssets("ak_dimensional"))
table.insert(prefs, dimensional)
Util:AddString(dimensional.name, "次元装置", "异空间打开装置")

local engine = Prefab("tp_engine", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_engine", true)
    local atlas, image = AssetMaster:GetImage("tp_engine", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )

    return inst
end, AssetMaster:GetDSAssets("tp_engine"))
table.insert(prefs, engine)
Util:AddString(engine.name, "引擎", "机械动力源")

local gift = Prefab("tp_gift", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_gift", true)
    local atlas, image = AssetMaster:GetImage("tp_gift", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("lootdropper")

    inst:AddComponent("wg_useable")
    -- inst.components.wg_useable.test = function(inst, doer) end
    inst.components.wg_useable.use = function(inst, doer) 
        local day = GetClock():GetNumCycles()+1
        local n = 1
        local rate = day/180
        if math.random()<rate then
            n = 2
            if math.random()<rate then
                n = 3
            end
        end
        local loots = inst.loots or Info.GiftList["normal"]
        local loot = loots[math.random(#loots)]
        inst.components.lootdropper:SpawnLootPrefab(loot)
        inst:Remove()
    end
    inst.OnSave = function(inst, data)
        data.loots = inst.loots
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.loots = data.loots
        end
    end

    return inst
end, AssetMaster:GetDSAssets("tp_gift"))
table.insert(prefs, gift)
Util:AddString(gift.name, "礼包", "随机掉落奖品")

local level_gift = deepcopy(gift)
PrefabUtil:SetPrefabName(level_gift, "tp_level_gift")
PrefabUtil:HookPrefabFn(level_gift, function(inst)
    inst.loots = {}
    inst.add_loot = function(inst, loot, num)
        if inst.loots[loot] == nil then
            inst.loots[loot] = 0
        end
        inst.loots[loot] = inst.loots[loot]+num
    end
    inst.components.wg_useable.use = function(inst, doer) 
        for k, v in pairs(inst.loots) do
            for i = 1, v do
                local loot = SpawnPrefab(k)
                if loot.components.stackable then
                    loot.components.stackable:SetStackSize(v)
                    inst.components.lootdropper:DropLootPrefab(loot)
                    break
                else
                    inst.components.lootdropper:DropLootPrefab(loot)
                end
            end
            -- inst.components.lootdropper:SpawnLootPrefab(k)
        end
        inst:Remove()
    end
    inst:AddComponent('wg_info')
    inst.components.wg_info.info = function(inst)
        local s = "礼品:"
        for k, v in pairs(inst.loots) do
            s = s..string.format("%s%d个,", Util:GetScreenName(k), v)
        end
        s = Util:SplitSentence(s, nil, true)
        return s
    end
    inst.OnSave = function(inst, data)
        data.loots = inst.loots
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.loots = data.loots or {}
        end
    end
end)
table.insert(prefs, level_gift)
Util:AddString(level_gift.name, "礼包", "杀怪或升级获得的礼包；升级时，如果身上有礼包，那么奖励都会一并放入携带的礼包中")

local grass_pigking = Prefab("tp_grass_pigking", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_grass_pigking", true)
    local atlas, image = AssetMaster:GetImage("tp_grass_pigking", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )

    inst.AnimState:Hide("snow")
    inst.Transform:SetScale(.3, .3, .3)
    inst:AddTag("irreplaceable")
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(function(inst, item, giver)
        return item.components.tradable.goldvalue > 0
    end)
    inst.components.trader.onaccept = function(inst, giver, item)
        if item.components.tradable.goldvalue > 0 then
            inst:DoTaskInTime(20/30, function() 
                -- inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingThrowGold")
                for k = 1, item.components.tradable.goldvalue do
                    local nug = SpawnPrefab("goldnugget")
                    local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,4.5,0)
                    nug.Transform:SetPosition(pt:Get())
                    local down = TheCamera:GetDownVec()
                    local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
                    --local angle = (-TUNING.CAM_ROT-90 + math.random()*60-30)/180*PI
                    local sp = math.random()*4+2
                    nug.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
                end
            end)
            -- inst:DoTaskInTime(1.5, function() 
            --     inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingHappy")
            -- end)
        end
    end
    inst.components.trader.onrefuse = function(inst, giver, item)end

    return inst
end, AssetMaster:GetDSAssets("tp_grass_pigking"))
table.insert(prefs, grass_pigking)
Util:AddString(grass_pigking.name, "猪王草人", "可以像猪王一样交易")

local candy_bag = Prefab("ak_candy_bag", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("ak_candy_bag", true)
    local atlas, image = AssetMaster:GetImage("ak_candy_bag", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddTag("fridge")
    EntUtil:set_container(inst, "pack")
    inst.components.container.type = "ak_candy_bag"
    inst.components.container.widgetpos = Vector3(-130,-70,0)

    return inst
end, AssetMaster:GetDSAssets("ak_candy_bag"))
table.insert(prefs, candy_bag)
Util:AddString(candy_bag.name, "冰鲜包", "拥有冷藏效果的包")

local CaneDodgeConst = {1.5}
local cane_dodge = Prefab("tp_cane_dodge", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_cane_dodge", true)
    local atlas, image = AssetMaster:GetImage("tp_cane_dodge", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddTag("nopunch")
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable.walkspeedmult = .25
    inst.components.equippable.symbol = "tp_cane_dodge"

    inst:AddComponent("wg_recharge")
    inst.components.wg_recharge:SetCommon("tp_cane_dodge")
    inst:AddComponent("wg_action_tool")
    inst.components.wg_action_tool.move = true
    inst.components.wg_action_tool:RegisterSkillInfo()  -- 注册后才能按键触发
    inst.components.wg_action_tool.test = function(inst, doer)
        if inst.components.wg_recharge:IsRecharged() then
            return true
        end
    end
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        local pos = TheInput:GetWorldPosition()
        local target = TheInput:GetWorldEntityUnderMouse()
        local doer = inst.components.equippable.owner
        if pos or target then
            doer:ClearBufferedAction()
            local ba = BufferedAction(doer, target, ACTIONS.WG_DODGE, inst, pos)
            doer:PushBufferedAction(ba)
        end
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        inst.components.wg_recharge:SetRechargeTime(CaneDodgeConst[1], "tp_cane_dodge")
    end

    return inst
end, AssetMaster:GetDSAssets("tp_cane_dodge"))
table.insert(prefs, cane_dodge)
Util:AddString(cane_dodge.name, "滑行手杖", 
string.format("可以滑铲(滑铲全过程无敌)，有%.2fs的冷却时间", CaneDodgeConst[1]))

local coin = deepcopy(require "prefabs/oinc")
PrefabUtil:SetPrefabName(coin, "tp_coin")
PrefabUtil:HookPrefabFn(coin, function(inst)
    inst.components.inventoryitem:ChangeImageName("oinc")
    inst.components.stackable.maxsize = 999
    inst.oincvalue = nil
    inst:RemoveTag("oinc")
    inst:RemoveComponent("currency")
end)
table.insert(prefs, coin)
Util:AddString(coin.name, "呼噜假币", "希望不是假币")

local amulet_tbl = { loadfile("prefabs/amulet")() }
local green_amulet = deepcopy(amulet_tbl[5])
PrefabUtil:SetPrefabName(green_amulet, "tp_green_amulet")
PrefabUtil:HookPrefabFn(green_amulet, function(inst)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED 
    inst.components.inventoryitem:ChangeImageName("greenamulet")
    inst.components.equippable.walkspeedmult = .3
    Kit:make_light(inst, "lighter")
    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(function(inst, owner)
        owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "greenamulet")
        owner.components.builder.ingredientmod = TUNING.GREENAMULET_INGREDIENTMOD
        inst:check_light()
        EntUtil:add_hunger_mod(owner, "ak_green_amulet", -.5)
        EntUtil:add_damage_mod(owner, "ak_green_amulet", .5)
        owner:AddTag("wg_fast_harvester")
        inst.event_fn = EntUtil:listen_for_event(inst,
            "working", function(owner, data)
            if data and data.target then
                local cmp = data.target.components.workable
                -- 砍掉后workable就没了
                if cmp and cmp.workleft > 0 then
                    cmp:Destroy(owner)
                end
            end
        end, owner)
    end)
    inst.components.equippable:SetOnUnequip(function(inst, owner)
        owner.AnimState:ClearOverrideSymbol("swap_body")
        owner.components.builder.ingredientmod = 1
        inst.Light:Enable(false)
        EntUtil:rm_hunger_mod(owner, "ak_green_amulet")
        EntUtil:rm_damage_mod(owner, "ak_green_amulet")
        owner:RemoveTag("wg_fast_harvester")
        if inst.event_fn then
            inst:RemoveEventCallback("working", inst.event_fn, owner)
            inst.event_fn = nil
        end
    end)
    inst.check_light = function(inst)
        if GetWorld():IsCave() or GetClock():IsNight() 
        and inst.components.equippable:IsEquipped() then
            inst.Light:Enable(true)
        else
            inst.Light:Enable(false)
        end
    end
    inst:ListenForEvent("daytime", function(world, data)
        inst:check_light()
    end, GetWorld())
    inst:ListenForEvent("nighttime", function(world, data)
        inst:check_light()
    end, GetWorld())
end)
table.insert(prefs, green_amulet)
Util:AddString(green_amulet.name, "护符", "好好好！")

local gps = Prefab("ak_gps", function()
    -- local bank, build, animation, water = AssetMaster:GetAnimation("ak_gps", true)
    -- local atlas, image = AssetMaster:GetImage("ak_gps", true)
    local bank, build, animation, water = "tracker", "tracker", "idle", "idle_water"
    local atlas, image = "images/inventoryimages.xml", "compass"
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("wg_useable")
    -- inst.components.wg_useable.test = function(inst, doer) end
    inst.components.wg_useable.use = function(inst, doer) 
        inst:Remove()
        local targets = {
            "pigking",
            "reeds",
            "beefalo",
            "cave_entrance",
            "walrus_camp",
            "tallbirdnest",
        }
        local player = GetPlayer()
        local minimap = GetWorld().minimap.MiniMap
        local map = GetWorld().Map
        for k, v in pairs(targets) do
            local t = c_find(v)
            if t then
                local x, y, z = t.Transform:GetLocalPosition()
                local cx, cy, cz = map:GetTileCenterPoint(x, 0, z)
                minimap:ShowArea(cx, cy, cz, 30)
                map:VisitTile(map:GetTileCoordsAtPoint(cx, cy, cz))
            end
        end
    end

    return inst
end, nil)
table.insert(prefs, gps)
Util:AddString(gps.name, "GPS", "好好好！")

for k, v in pairs({
    "orange", "black", "grey", "white", "blue", 
    "red", "green", "yellow", "purple", "cyan", "pink",
}) do

local name = "tp_infused_nugget_"..v
local nugget = Prefab(name, function()
    local bank, build, animation, water = AssetMaster:GetAnimation(name, true)
    local atlas, image = AssetMaster:GetImage(name, true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddTag("forge_material")
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ELEMENTAL"
    inst.components.edible.hungervalue = 3

    inst:AddComponent("tradable")
    inst:AddComponent("stackable")

    inst:AddComponent("bait")
    inst:AddTag("molebait")

    return inst
end, nil)
table.insert(prefs, nugget)

end
Util:AddString("tp_infused_nugget_black", "注能矿", "锻造材料")
Util:AddString("tp_infused_nugget_white", "纯净注能矿", "锻造材料")
Util:AddString("tp_infused_nugget_orange", "火注能矿", "质变材料")
Util:AddString("tp_infused_nugget_grey", "风注能矿", "质变材料")
Util:AddString("tp_infused_nugget_blue", "雷注能矿", "质变材料")
Util:AddString("tp_infused_nugget_red", "血注能矿", "质变材料")
Util:AddString("tp_infused_nugget_green", "毒注能矿", "质变材料")
Util:AddString("tp_infused_nugget_yellow", "圣注能矿", "质变材料")
Util:AddString("tp_infused_nugget_purple", "影注能矿", "质变材料")
Util:AddString("tp_infused_nugget_cyan", "冰注能矿", "质变材料")
Util:AddString("tp_infused_nugget_pink", "魔注能矿", "质变材料")

local recover_bottle = Prefab("tp_recover_bottle", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_recover_bottle", true)
    local atlas, image = AssetMaster:GetImage("tp_recover_bottle", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst.update_bottle = function(inst)
        if inst.components.finiteuses:GetUses() > .66 then
            inst.AnimState:PlayAnimation("f14")
            inst.components.inventoryitem:ChangeImageName("items_14")
        elseif inst.components.finiteuses:GetUses() > .33 then
            inst.AnimState:PlayAnimation("f15")
            inst.components.inventoryitem:ChangeImageName("items_15")
        else
            inst.AnimState:PlayAnimation("f16")
            inst.components.inventoryitem:ChangeImageName("items_16")
        end
    end
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(3)
    inst.components.finiteuses:SetUses(3)
    inst.components.finiteuses.OnLoad = function(self, data)
        self:SetUses(data.uses or self.total)
    end
    -- inst.components.finiteuses:SetOnFinished(function(inst)
    -- end)
    inst.test = function(inst, doer)
        if inst.components.finiteuses:GetUses() >= 1 then
            return true
        end
    end
    inst.use = function(inst, doer)
        inst.components.finiteuses:Use(1)
        doer.components.health:DoDelta(inst.rcv)
    end
    inst.max = 3
    inst.rcv = 100
    inst.level_up = function(inst, part)
        if part == 1 then
            inst.max = inst.max + 1
            inst.components.finiteuses:SetMaxUses(inst.max)
        elseif part == 2 then
            inst.rcv = inst.rcv + 25
        end
    end
    inst:ListenForEvent("percentusedchange", function(inst, data)
        inst:update_bottle()
    end)
    inst.OnSave = function(inst, data)
        data.max = inst.max
        data.rcv = inst.rcv
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.max = data.max
            inst.rcv = data.rcv
        end
    end

    return inst
end)
table.insert(prefs, recover_bottle)
Util:AddString(recover_bottle.name, "恢复瓶", "恢复生命")

local beast_essence = Prefab("tp_beast_essence", function()
    local bank, build, animation, water = AssetMaster:GetAnimation("tp_beast_essence", true)
    local atlas, image = AssetMaster:GetImage("tp_beast_essence", true)
    local inst = PrefabUtil:MakeItem(
        bank, build, animation, water,
        atlas, image
    )
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 10

    return inst
end)
table.insert(prefs, beast_essence)
Util:AddString(beast_essence.name, "兽王之魂", "强大生物的精华")

return unpack(prefs)