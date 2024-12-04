local EntUtil = require "extension.lib.ent_util"
local Kit = require "extension.lib.wargon"
local cooked_food_dict = require("preparedfoods")
local FxManager = Sample.FxManager
local BuffManager = Sample.BuffManager

local cooked_food_list = {}
for k, v in pairs(cooked_food_dict) do
    table.insert(cooked_food_list, k)
end

local DataManager = require "extension.lib.data_manager"
local FoodEffectManager = DataManager("FoodEffectManager")

local EffectData = Class(function(self)
end)

--[[
创建食物效果类  
(EffectData) 返回此类  
id (string)名称  
init (func)初始函数，function(self, id, food)  
eat (func)食用触发函数，function(self, inst, cmp, id, food)inst是食用者，cmp是eater组件  
desc (func)描述函数，function(self, id, food)  
data (table)相关数据  
quality (number)词条的等级，没有则为1  
cost (number)消耗，默认为1  
]]
local function Effect(id, init, eat, desc, data, quality, cost)
    local self = EffectData()
    self.id = id
    self.init = init
    self.eat = eat
    self.data = data
    self.desc = desc
    self.quality = quality or 1
    self.cost = cost or 1
    return self
end

function EffectData:GetId()
    return self.id
end

--[[
Effect("", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
end, 
function(self, id, food)
end, {}, 1, 1),
]]

local small = {
Effect("meat_hp", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 2, 1),
Effect("meat_sp", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 2, 1),
Effect("meat_hg", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 2, 1),
-- Effect("return_food",
-- function(self, id, food)
-- end, 
-- function(self, inst, cmp, id, food)
--     -- 房间内不能传送
--     local interior_spawner = GetWorld().components.interiorspawner
--     if interior_spawner then
--         local cur = interior_spawner.current_interior
--         if cur and cur.dungeon_name then
--             return
--         end
--     end
--     -- 记录坐标，世界不同不能传送，但是进入新的世界等于退出，
--     -- 坐标不会保存，所以没事
--     if cmp[id.."_pos"] == nil then
--         cmp[id.."_pos"] = inst:GetPosition()
--     else
--         if cmp[id.."_pos"] then
--             TheFrontEnd:Fade(true,1)
--             inst.Transform:SetPosition(cmp[id.."_pos"]:Get())
--             cmp[id.."_pos"] = nil
--         end
--     end
-- end,
-- function(self, id, food)
--     local s = string.format("食用时记录当前坐标,如已记录坐标,回到并清除当前坐标(在房间内不会生效)")
--     return s
-- end, nil, 2, 0), 
Effect("food_sleep", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil),
Effect("differ_food_hg", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 2, 2),
Effect("differ_food_sp", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 2, 2),
Effect("differ_food_hp", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 2, 2),
Effect("fst_veggie_hp",
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    cmp:AddOnEatFn(id, function(inst, food)
        if food.components.edible.foodtype == "veggie" then
            if EntUtil:is_alive(inst) then
                inst.components.health:DoDelta(self.data[1])
            end
            cmp:RmOnEatFn(id)
        end
    end)
end,
function(self, id, food)
    local s = string.format("食用的下一个蔬菜额外回复%d点生命", self.data[1])
    return s
end, {5}, 1, 0),
Effect("fst_veggie_sp",
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    cmp:AddOnEatFn(id, function(inst, food)
        if food.components.edible.foodtype == "veggie" then
            if inst.components.sanity then
                inst.components.sanity:DoDelta(self.data[1])
            end
            cmp:RmOnEatFn(id)
        end
    end)
end,
function(self, id, food)
    local s = string.format("食用的下一个蔬菜额外回复%d点理智", self.data[1])
    return s
end, {5}, 1, 0),
Effect("fst_veggie_hg",
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    cmp:AddOnEatFn(id, function(inst, food)
        if food.components.edible.foodtype == "veggie" then
            if inst.components.hunger then
                inst.components.hunger:DoDelta(self.data[1])
            end
            cmp:RmOnEatFn(id)
        end
    end)
end,
function(self, id, food)
    local s = string.format("食用的下一个蔬菜额外回复%d点饥饿", self.data[1])
    return s
end, {5}, 1, 0),
-- Effect("food_dmg_stk", 
-- function(self, id, food)
-- end,
-- function(self, inst, cmp, id, food)
--     BuffManager:AddBuff(inst, id)
-- end, 
-- function(self, id, food)
--     local buff = BuffManager:GetDataById(id)
--     local s = string.format("获得buff(%s)", buff:desc(nil, {stacks={}, id=id}))
--     return s
-- end, nil),
Effect("food_spd_stk", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc(nil, {stacks={}, id=id}))
    return s
end, nil),
-- Effect("food_def_stk", 
-- function(self, id, food)
-- end,
-- function(self, inst, cmp, id, food)
--     BuffManager:AddBuff(inst, id)
-- end, 
-- function(self, id, food)
--     local buff = BuffManager:GetDataById(id)
--     local s = string.format("获得buff(%s)", buff:desc(nil, {stacks={}, id=id}))
--     return s
-- end, nil),
Effect("low_health", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    if EntUtil:is_alive(inst)
    and inst.components.health:GetPercent()<self.data[1] then
        inst.components.health:DoDelta(self.data[2])
    end
end,
function(self, id, food)
    return string.format("如果食用食物后你的生命值低于%d%%,再回复%d生命",
        self.data[1]*100, self.data[2])
end, {.6, 10}),
Effect("low_sanity", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    if inst.components.sanity
    and inst.components.sanity:GetPercent()<self.data[1] then
        inst.components.sanity:DoDelta(self.data[2])
    end
end,
function(self, id, food)
    return string.format("如果食用食物后你的理智值低于%d%%,再回复%d理智",
        self.data[1]*100, self.data[2])
end, {.6, 10}),
Effect("low_hunger", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    if inst.components.hunger
    and inst.components.hunger:GetPercent()<self.data[1] then
        inst.components.hunger:DoDelta(self.data[2])
    end
end,
function(self, id, food)
    return string.format("如果食用食物后你的饥饿值低于%d%%,再回复%d饥饿",
        self.data[1]*100, self.data[2])
end, {.6, 10}),
-- Effect("food_spear", 
-- function(self, id, food)
-- end,
-- function(self, inst, cmp, id, food)
--     BuffManager:AddBuff(inst, id)
-- end, 
-- function(self, id, food)
--     local buff = BuffManager:GetDataById(id)
--     local s = string.format("获得buff(%s)", buff:desc())
--     return s
-- end, nil),
-- Effect("food_spear2", 
-- function(self, id, food)
-- end,
-- function(self, inst, cmp, id, food)
--     BuffManager:AddBuff(inst, id)
-- end, 
-- function(self, id, food)
--     local buff = BuffManager:GetDataById(id)
--     local s = string.format("获得buff(%s)", buff:desc())
--     return s
-- end, nil),
-- Effect("food_spear3", 
-- function(self, id, food)
-- end,
-- function(self, inst, cmp, id, food)
--     BuffManager:AddBuff(inst, id)
-- end, 
-- function(self, id, food)
--     local buff = BuffManager:GetDataById(id)
--     local s = string.format("获得buff(%s)", buff:desc())
--     return s
-- end, nil),
-- Effect("food_spear4", 
-- function(self, id, food)
-- end,
-- function(self, inst, cmp, id, food)
--     local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
--     if item and item.prefab == "spear" then
--         item.components.finiteuses:Repair(self.data[1])
--     end
-- end, 
-- function(self, id, food)
--     local s = string.format("令你持有的长矛回复%d点耐久", self.data[1])
--     return s
-- end, {10}),
-- Effect("food_armor_wood", 
-- function(self, id, food)
-- end,
-- function(self, inst, cmp, id, food)
--     BuffManager:AddBuff(inst, id)
-- end, 
-- function(self, id, food)
--     local buff = BuffManager:GetDataById(id)
--     local s = string.format("获得buff(%s)", buff:desc())
--     return s
-- end, nil),
-- Effect("food_armor_wood2", 
-- function(self, id, food)
-- end,
-- function(self, inst, cmp, id, food)
--     BuffManager:AddBuff(inst, id)
-- end, 
-- function(self, id, food)
--     local buff = BuffManager:GetDataById(id)
--     local s = string.format("获得buff(%s)", buff:desc())
--     return s
-- end, nil),
-- Effect("food_armor_wood4", 
-- function(self, id, food)
-- end,
-- function(self, inst, cmp, id, food)
--     local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
--     if item and item.prefab == "armorwood" then
--         local max = item.components.armor.maxcondition
--         local dt = self.data[1]
--         local cur = item.components.armor.condition
--         item.components.armor:SetCondition(math.min(max, dt+cur))
--     end
-- end, 
-- function(self, id, food)
--     local s = string.format("令你穿戴的木甲回复%d点护甲值", self.data[1])
--     return s
-- end, {30}),
Effect("taste0",
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    inst.components.tp_taste:DoDelta(self.data[1])
end, 
function(self, id, food)
    return string.format("回复%d点品尝值", self.data[1])
end, {1}, 1, 0),
Effect("hg0", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    inst.components.hunger:DoDelta(self.data[1])
end, 
function(self, id, food)
    return string.format("额外回复%d点饥饿", self.data[1])
end, {5}, 1, 0),
Effect("other_max_hg+2", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    cmp:AddOnEatFn(id, function(inst, food)
        BuffManager:AddBuff(inst, id)
        cmp:RmOnEatFn(id)
    end)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("你食用下一个食物获得buff(%s)", buff:desc())
    return s
end, {}, 1, 1),
Effect("skill_sp1", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, {}, 1, 1),
Effect("hp2", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    inst.components.health:DoDelta(self.data[1])
end, 
function(self, id, food)
    return string.format("额外回复%d点生命", self.data[1])
end, {10}, 1, 1),
-- Effect("fresh", 
-- function(self, id, food)
--     if food.components.perishable then
--         local time = food.components.perishable.perishtime
--         food.components.perishable:SetPerishTime(time*self.data[1])
--     end
-- end, 
-- function(self, inst, cmp, id, food)
-- end, 
-- function(self, id, food)
--     return string.format("腐烂时间变为%d倍", self.data[1])
-- end, {2}, 1, 1),
Effect("food_fast2", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    EntUtil:add_speed_mod(inst, id, self.data[1], self.data[2])
end, 
function(self, id, food)
    return string.format("增加%d%%移速%ds", self.data[1]*100, self.data[2])
end, {.1, 20}, 1, 1),
Effect("next_dmg_up1", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, {}, 1, 1),
Effect("food_next_def1", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, {}, 1, 1),
Effect("give_food1", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    local food2 = SpawnPrefab("carrot")
    food2.components.tp_food_effect:Random()
    inst.components.inventory:GiveItem(food2)
end, 
function(self, id, food)
    local s = string.format("获得1个随机词条的胡萝卜")
    return s
end, {}, 1, 2),
Effect("weapon_dmg_up1", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, {}, 1, 2),
Effect("change_equip_finite", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local item2 = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if item.components.finiteuses and item2.components.armor then
        local p1 = item.components.finiteuses:GetPercent()
        local p2 = item2.components.armor:GetPercent()
        item.components.finiteuses:SetPercent(p2)
        item2.components.armor:SetPercent(p1)
    end
end, 
function(self, id, food)
    local s = string.format("若你的穿戴武器和护甲，交换你武器和护甲的耐久百分比")
    return s
end, {}, 2, 2),
Effect("replace_cooked", 
function(self, id, food)
    food:ListenForEvent("perished", function()
        if food.components.tp_food_effect.id == id then
            local food_name = cooked_food_list[math.random(#cooked_food_list)]
            local food2 = SpawnPrefab(food_name)
            local owner = food.components.inventoryitem:GetGrandOwner()
            if owner then
                local holder = owner.components.inventory or owner.components.container
                holder:GiveItem(food2)
            else
                food2.Transform:SetPosition(food:GetPosition():Get())
            end
        end
    end)
end, 
function(self, inst, cmp, id, food)
end, 
function(self, id, food)
    local s = string.format("腐烂后随机变为一种菜肴")
    return s
end, {}, 2, 2),
Effect("give_cooked_great1", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    local food_name = cooked_food_list[math.random(#cooked_food_list)]
    local food2 = SpawnPrefab(food_name)
    food2.components.tp_food_effect:Random({"med"})
    inst.components.inventory:GiveItem(food2)
end, 
function(self, id, food)
    local s = string.format("获得1个随机词条的菜肴(消耗大于4)")
    return s
end, {}, 4, 3),
Effect("food_fast3", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    EntUtil:add_speed_mod(inst, id, self.data[1], self.data[2])
end, 
function(self, id, food)
    return string.format("增加%d%%移速%ds", self.data[1]*100, self.data[2])
end, {.15, 20}, 1, 3),
Effect("meat_hp_sp", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 3, 3),
Effect("pet_dmg_up1", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    for k, v in pairs(inst.components.leader.followers) do
        BuffManager:AddBuff(k, id)
    end
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("令你的随从获得buff(%s)", buff:desc())
    return s
end, nil, 1, 3),
Effect("kill_dmg_up1", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 1, 3),
Effect("murake", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 4, 3),
}

local med = {
Effect("spawn_pig", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    local pos = Kit:find_walk_pos(inst, math.random(3, 5))
    if pos then
        FxManager:MakeFx("statue_transition_2", pos)
        local pet = SpawnPrefab("pigman")
        pet.Transform:SetPosition(pos:Get())
        inst.components.leader:AddFollower(pet)
        pet.components.follower:AddLoyaltyTime(9999)
    end
end, 
function(self, id, food)
    local s = string.format("召唤一个跟随你的猪人")
    return s
end, nil, 1, 4),
Effect("giant_hunter", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 3, 4),
Effect("food_next_def2", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, {}, 1, 4),
Effect("skill_many_pog",
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, {}, 2, 4),
Effect("pet2_dmg_hp_up1", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    local cnt = 2
    for k, v in pairs(inst.components.leader.followers) do
        BuffManager:AddBuff(k, id)
        cnt = cnt-1
        if cnt==0 then
            break
        end
    end
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("令你的两个随从获得buff(%s)", buff:desc())
    return s
end, nil, 2, 4),
Effect("atk_pet_dmg_hp_up1", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 4, 5),
Effect("wound_dmg_up",
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 2, 5),
Effect("copy_pet", 
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    local pet_name
    for k, v in pairs(inst.components.leader.followers) do
        pet_name = k.prefab
        break
    end
    if pet_name then
        local pos = Kit:find_walk_pos(inst, math.random(3, 5))
        if pos then
            FxManager:MakeFx("statue_transition_2", pos)
            local pet = SpawnPrefab(pet_name)
            pet.Transform:SetPosition(pos:Get())
            inst.components.leader:AddFollower(pet)
            pet.components.follower:AddLoyaltyTime(9999)
            if BuffManager:HasBuff(pet, "summon") then
                BuffManager:AddBuff(pet, "summon", 30)
            end
        end
    end
end, 
function(self, id, food)
    local s = string.format("从你的随从中召唤一个复制")
    return s
end, nil, 3, 5),
Effect("food_fast4", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    EntUtil:add_speed_mod(inst, id, self.data[1], self.data[2])
end, 
function(self, id, food)
    return string.format("增加%d%%移速%ds", self.data[1]*100, self.data[2])
end, {.2, 30}, 1, 5),
Effect("give_q3_weapon", 
function(self, id, food)
end, 
function(self, inst, cmp, id, food)
    local spear = SpawnPrefab("tp_spear_enchant")
    spear.components.tp_enchantmentable:SetQuality(3)
    for i = 1, 100 do
        local ids, kinds = EnchantmentManager:GetRandomIds(1, {"all", "weapon"})
        local data = EnchantmentManager:GetDataById(ids[1], kinds[1])
        if spear.components.tp_enchantmentable:TestData(data) then
            spear.components.tp_enchantmentable:Enchantment({
                quality = 3,
                ids = ids,
            })
            break
        end
    end
end, 
function(self, id, food)
    return string.format("获得一把品质为3的附魔武器")
end, {}, 4, 5),
Effect("taste_give_food",
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 2, 6),
Effect("max_attr_food",
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 1, 6),
}
local large = {
Effect("atk_spd_food",
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, id)
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById(id)
    local s = string.format("获得buff(%s)", buff:desc())
    return s
end, nil, 1, 7),
Effect("perish_q5_weapon", 
function(self, id, food)
    food:ListenForEvent("perished", function()
        if food.components.tp_food_effect.id == id then
            local food2 = SpawnPrefab("tp_spear_enchant2")
            local owner = food.components.inventoryitem:GetGrandOwner()
            if owner then
                local holder = owner.components.inventory or owner.components.container
                holder:GiveItem(food2)
            else
                food2.Transform:SetPosition(food:GetPosition():Get())
            end
        end
    end)
end, 
function(self, inst, cmp, id, food)
    BuffManager:AddBuff(inst, "food_next_def2")
end, 
function(self, id, food)
    local buff = BuffManager:GetDataById("food_next_def2")
    local s = string.format("腐烂后获得一把品质为5的附魔武器,")
    s = s..string.format("食用后获得buff(%s)", buff:desc())
    return s
end, {}, 4, 8),
Effect("red_dragon",
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    inst.components.health:DoDelta(self.data[1])
end, 
function(self, id, food)
    local s = string.format("额外回复%d生命", self.data[1])
    return s
end, {80}, 4, 8),
Effect("blue_dragon",
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    local max = inst.components.inventory.maxslots
    local num = inst.components.inventory:NumItems()
    for i = 1, max-num do
        local food_name = cooked_food_list[math.random(#cooked_food_list)]
        local food2 = SpawnPrefab(food_name)
        inst.components.inventory:GiveItem(food2)
    end
end, 
function(self, id, food)
    local s = string.format("你每有一个空余的格子，给予你一个菜肴")
    return s
end, nil, 4, 9),
Effect("black_dragon",
function(self, id, food)
end,
function(self, inst, cmp, id, food)
    local x, y, z = inst:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 15, nil, EntUtil.not_enemy_tags)
    local n = inst.components.leader.numfollowers
    local cnt = 0
    for k, v in pairs(ents) do
        if not v:HasTag("epic")
        and EntUtil:is_alive(v)
        and v.components.combat 
        and v.components.combat.target == inst then
            if cnt >= n then
                break
            end
            cnt = cnt+1
            v.components.health:Kill()
            FxManager:MakeFx("wathgrithr_spirit", v)
        end
    end
    for k, v in pairs(inst.components.leader.followers) do
        if cnt == 0 then
            break
        end
        if EntUtil:is_alive(k) then
            k.components.health:Kill()
            FxManager:MakeFx("wathgrithr_spirit", k)
            cnt = cnt - 1
        end
    end
end, 
function(self, id, food)
    local s = string.format("令周围以你为攻击目标的单位死亡(史诗单位除外),需要祭献你的1个随从才能杀死1个")
    return s
end, nil, 4, 10),
}

-- local bad = {
-- Effect("bfood_hp", 
-- function(self, id, food)
--     local cur = food.components.edible.healthvalue
--     food.components.edible.healthvalue=cur*self.data[1]
-- end,
-- function(self, inst, cmp, id, food)
-- end, 
-- function(self, id, food)
--     local s = string.format("该食物的生命回复降低至%d%%", self.data[1]*100)
--     return s
-- end, {.8}, 6),
-- Effect("bfood_sp", 
-- function(self, id, food)
--     local cur = food.components.edible.sanityvalue
--     food.components.edible.sanityvalue=cur*self.data[1]
-- end,
-- function(self, inst, cmp, id, food)
-- end, 
-- function(self, id, food)
--     local s = string.format("该食物的理智回复降低至%d%%", self.data[1]*100)
--     return s
-- end, {.8}, 6),
-- Effect("bfood_hg", 
-- function(self, id, food)
--     local cur = food.components.edible.hungervalue
--     food.components.edible.hungervalue=cur*self.data[1]
-- end,
-- function(self, inst, cmp, id, food)
-- end, 
-- function(self, id, food)
--     local s = string.format("该食物的饥饿回复降低至%d%%", self.data[1]*100)
--     return s
-- end, {.8}, 6),
-- }

FoodEffectManager:AddDatas(small, "small")
FoodEffectManager:AddDatas(med, "med")
FoodEffectManager:AddDatas(large, "large")
-- FoodEffectManager:AddDatas(bad, "bad")

Sample.FoodEffectManager = FoodEffectManager