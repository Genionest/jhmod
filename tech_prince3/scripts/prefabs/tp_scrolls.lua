local PrefabUtil = require "extension.lib.prefab_util"
local Util = require "extension.lib.wg_util"
local Kit = require "extension.lib.wargon"
local AssetUtil = require "extension.lib.asset_util"
local Sounds = require "extension.datas.sounds"
local AssetMaster = Sample.AssetMaster
local BuffManager = Sample.BuffManager
local FxManager = Sample.FxManager
local ScrollManager = Sample.ScrollManager

ScrollManager:MakeTempTable()

local prefs = {}

local books = {loadfile("prefabs/books")()}

local scrolls = {
	"tp_scroll_sleep",
	"tp_scroll_grow",
	"tp_scroll_lightning",
    "tp_scroll_bird",
	"tp_scroll_tentacle",
	"tp_scroll_volcano",
}

for k, v in pairs(scrolls) do
    local name = v
    local scroll = deepcopy(books[k])
    PrefabUtil:SetPrefabName(scroll, name)
    PrefabUtil:HookPrefabFn(scroll, function(inst)
        local bank, build, animation, water = AssetMaster:GetAnimation(name, true)
        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(animation)
        if water then
            MakeInventoryFloatable(inst, water, animation)
        end
        local atlas, image = AssetMaster:GetImage(name, true)
        if string.find(image, ".tex") then
            assert(nil, "image should not have \".tex\"")
        end
        inst.components.inventoryitem.atlasname = atlas
        inst.components.inventoryitem:ChangeImageName(image)

        
        inst:AddTag("tp_scroll")
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = 40
        local read_fn = inst.components.book.onread
        inst.components.book.onread = function(inst, reader)
            reader:PushEvent("use_scroll", {scroll=inst})
            read_fn(inst, reader)
            if inst.components.stackable then
                inst.components.stackable:Get():Remove()
            end
            return true
        end
        inst.components.book:SetAction(ACTIONS.READMAP)
        inst:RemoveComponent("finiteuses")
    end)
    table.insert(prefs, scroll)
end

Util:AddString("tp_scroll_volcano", "火山卷轴", "召唤陨石")
Util:AddString("tp_scroll_bird", "百鸟卷轴", "召唤一群鸟")
Util:AddString("tp_scroll_sleep", "睡眠卷轴", "催眠周围的生物")
Util:AddString("tp_scroll_grow", "生长卷轴", "催熟周围的作物")
Util:AddString("tp_scroll_lightning", "闪电卷轴", "召唤闪电")
Util:AddString("tp_scroll_tentacle", "触手卷轴", "召唤触手")

ScrollManager:Add("tp_scroll_sleep", "shadow")
ScrollManager:Add("tp_scroll_grow", "wind")
ScrollManager:Add("tp_scroll_lightning", "electric")
ScrollManager:Add("tp_scroll_bird", "nature")
ScrollManager:Add("tp_scroll_tentacle", "nature")
ScrollManager:Add("tp_scroll_volcano", "fire")

--[[
创建卷轴  
(Prefab) 返回这个Prefab  
name (string)名字  
read_fn (func)阅读函数func(inst,reader)  
read_test (func)阅读检测func(inst,reader)  
fn (func)定制函数  
]]
local function MakeScroll(name, read_fn, read_test, fn)
    return Prefab("common/inventory/"..name, function()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        MakeInventoryPhysics(inst)
        local bank, build, animation, water = AssetMaster:GetAnimation(name, true)
        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(animation)
        if water then
            MakeInventoryFloatable(inst, water, animation)
        end
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        local atlas, image = AssetMaster:GetImage(name, true)
        if string.find(image, ".tex") then
            assert(nil, "image should not have \".tex\"")
        end
        inst.components.inventoryitem.atlasname = atlas
        inst.components.inventoryitem:ChangeImageName(image)

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = 40

        if read_fn and read_test then
            inst:AddComponent("book")
            inst.components.book.onread = read_fn
            inst.components.book.onreadtest = read_test
            inst.components.book:SetAction(ACTIONS.READMAP)
        end
        
        if fn then
            fn(inst)
        end

        return inst
    end, AssetMaster:GetDSAssets(name))
end

local ScrollTemplarConst = {50}
local scroll_templar = MakeScroll("tp_scroll_templar", 
function(inst, reader)
    reader.components.sanity:DoDelta(-ScrollTemplarConst[1])
    if inst.components.stackable then
        inst = inst.components.stackable:Get()
    end
    inst:Remove()
    BuffManager:AddBuff(reader, "tp_scroll_templar")
    return true
end, 
function(inst, reader)
    if reader.components.sanity 
    and reader.components.sanity.current>ScrollTemplarConst[1] then
        return true
    end
end)
table.insert(prefs, scroll_templar)
local buff = BuffManager:GetDataById("tp_scroll_templar")
Util:AddString(scroll_templar.name, "《圣堂武士威尔逊》", 
string.format("阅读消耗%d点理智，获得buff(%s)", ScrollTemplarConst[1], buff:desc()))

local ScrollRiderConst = {50}
local scroll_rider = MakeScroll("tp_scroll_rider", 
function(inst, reader)
    reader.components.sanity:DoDelta(-ScrollRiderConst[1])
    if inst.components.stackable then
        inst = inst.components.stackable:Get()
    end
    local pos = Kit:find_walk_pos(inst, math.random(3, 5))
    if pos then
        local beef = SpawnPrefab("beefalo") 
        beef.components.domesticatable:DeltaDomestication(1) 
        beef.components.domesticatable:DeltaObedience(1) 
        beef.components.domesticatable:DeltaTendency("ORNERY", 1) 
        beef:SetTendency() 
        beef.components.domesticatable:BecomeDomesticated() 
        beef.components.hunger:SetPercent(1) 
        beef.components.rideable:SetSaddle(nil, SpawnPrefab("saddle_war")) 
        beef.Transform:SetPosition(pos:Get())
        beef.components.tp_creature_equip.level = 30
        beef.components.tp_creature_equip:SetEquipByIds({
            "warmog_armor", math.random()<.5 and "frozen_heart" or "sun_fire_cape",
        })
        inst:Remove()
        return true
    end
end, 
function(inst, reader)
    if reader.components.sanity 
    and reader.components.sanity.current>ScrollRiderConst[1] then
        return true
    end
end)
table.insert(prefs, scroll_rider)
Util:AddString(scroll_rider.name, "《骑行的女武神》", 
string.format("阅读消耗%d点理智，召唤一头驯服的战牛", ScrollRiderConst[1]))

local ScrollHarvestConst = {30}
local scroll_harvest = MakeScroll("tp_scroll_harvest", 
function(inst, reader)
    local x, y, z = inst:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 15)
	for k, v in pairs(ents) do
		if v.components.pickable and v.prefab ~= "flower" then
			v.components.pickable:Pick(reader, v:GetPosition())
		end
		if v.components.crop then
			v.components.crop:Harvest(reader, v:GetPosition())
		end
	end    
    reader.components.sanity:DoDelta(-ScrollHarvestConst[1])
    if inst.components.stackable then
        inst = inst.components.stackable:Get()
    end
    inst:Remove()
    return true
end, 
function(inst, reader)
    if reader.components.sanity 
    and reader.components.sanity.current>ScrollHarvestConst[1] then
        return true
    end
end)
table.insert(prefs, scroll_harvest)
Util:AddString(scroll_harvest.name, "《收获者薇克巴顿》", 
string.format("阅读消耗%d点理智，收获周围的作物", ScrollHarvestConst[1]))

local scroll_back = MakeScroll("tp_scroll_back", 
function(inst, reader)
    local ent = GetClosestInstWithTag("tp_campfire_burning", inst, 9999)
    if ent == nil then
        return
    end
    reader.HUD:Hide()
    TheFrontEnd:Fade(false,.5)
    reader:DoTaskInTime(.5, function()
        reader.Transform:SetPosition(ent:GetPosition():Get())
        reader.HUD:Show()
        TheFrontEnd:Fade(true,.5) 
    end)

    if inst.components.stackable then
        inst = inst.components.stackable:Get()
    end
    inst:Remove()
    return true
end, 
nil,
function(inst)
    inst.components.book.test_data = {
        attr = {
            faith = 5,
            intelligence = 5,
        },
        san = 20,
        mana = 20,
    }
end)
table.insert(prefs, scroll_back)
Util:AddString(scroll_back.name, "《返回》", "传送到最近的一个点燃的无尽营火处")
ScrollManager:Add(scroll_back.name, "holly")

local scroll_fire_atk = MakeScroll("tp_scroll_fire_atk", 
function(inst, reader)
    local potion = SpawnPrefab("tp_potion_fire_atk")
    local weapon = inst.components.combat:GetWeapon()
    if weapon and potion.components.tp_smear_item:Test(weapon, reader) then
        weapon.components.tp_smearable:SmearItem(potion)
    end
    if inst.components.stackable then
        inst = inst.components.stackable:Get()
    end
    inst:Remove()
    return true
end, 
nil,
function(inst)
    inst.components.book.test_data = {
        attr = {
            faith = 5,
            intelligence = 5,
        },
        san = 20,
        mana = 20,
    }
end)
table.insert(prefs, scroll_fire_atk)
Util:AddString(scroll_fire_atk.name, "《火焰武器》", "武器攻击附带火属性伤害")
ScrollManager:Add(scroll_fire_atk.name, "fire")

local scroll_ice_atk = MakeScroll("tp_scroll_ice_atk", 
function(inst, reader)
    local potion = SpawnPrefab("tp_potion_ice_atk")
    local weapon = inst.components.combat:GetWeapon()
    if weapon and potion.components.tp_smear_item:Test(weapon, reader) then
        weapon.components.tp_smearable:SmearItem(potion)
    end
    if inst.components.stackable then
        inst = inst.components.stackable:Get()
    end
    inst:Remove()
    return true
end, 
nil,
function(inst)
    inst.components.book.test_data = {
        attr = {
            intelligence = 8,
        },
        san = 20,
        mana = 20,
    }
end)
table.insert(prefs, scroll_ice_atk)
Util:AddString(scroll_ice_atk.name, "《寒冰武器》", "武器攻击附带冰属性伤害")
ScrollManager:Add(scroll_ice_atk.name, "ice")

local scroll_electric_atk = MakeScroll("tp_scroll_electric_atk", 
function(inst, reader)
    local potion = SpawnPrefab("tp_potion_electric_atk")
    local weapon = inst.components.combat:GetWeapon()
    if weapon and potion.components.tp_smear_item:Test(weapon, reader) then
        weapon.components.tp_smearable:SmearItem(potion)
    end
    if inst.components.stackable then
        inst = inst.components.stackable:Get()
    end
    inst:Remove()
    return true
end, 
nil,
function(inst)
    inst.components.book.test_data = {
        attr = {
            faith = 10,
        },
        san = 30,
        mana = 30,
    }
end)
table.insert(prefs, scroll_electric_atk)
Util:AddString(scroll_electric_atk.name, "《雷电武器》", "武器攻击附带雷属性伤害")
ScrollManager:Add(scroll_electric_atk.name, "electric")

local scroll_shadow_atk = MakeScroll("tp_scroll_shadow_atk", 
function(inst, reader)
    local potion = SpawnPrefab("tp_potion_shadow_atk")
    local weapon = inst.components.combat:GetWeapon()
    if weapon and potion.components.tp_smear_item:Test(weapon, reader) then
        weapon.components.tp_smearable:SmearItem(potion)
    end
    if inst.components.stackable then
        inst = inst.components.stackable:Get()
    end
    inst:Remove()
    return true
end, 
nil,
function(inst)
    inst.components.book.test_data = {
        attr = {
            intelligence = 10,
        },
        san = 30,
        mana = 30,
    }
end)
table.insert(prefs, scroll_shadow_atk)
Util:AddString(scroll_shadow_atk.name, "《黑暗武器》", "武器攻击附带暗属性伤害")
ScrollManager:Add(scroll_shadow_atk.name, "shadow")

for k, v in pairs({
    fire = {40, 60, 90},
    ice = {30, 45, 70},
    shadow = {20, 35, 55},
    wind = {30, 45, 60},
    blood = {40, 50, 60},
    poison = {30, 40, 50},
    electric = {30, 50, 70},
    holly = {10, 20, 30},
}) do

local elem = k

for i = 1, 3 do
    local item_name, scroll_name
    if i == 1 then
        item_name = "tp_"..elem.."_bean"
        scroll_name = string.format("《吞噬武器I(%s)》", STRINGS.TP_DMG_TYPE[elem])
    elseif i == 2 then
        item_name = "tp_"..elem.."_arrow"
        scroll_name = string.format("《吞噬武器II(%s)》", STRINGS.TP_DMG_TYPE[elem])
    elseif i == 3 then
        item_name = "tp_"..elem.."_ball"
        scroll_name = string.format("《吞噬武器III(%s)》", STRINGS.TP_DMG_TYPE[elem])
    end
    local scroll = MakeScroll("tp_scroll_eatweapon"..tostring(i).."_"..elem, 
    function(inst, reader)
        local weapon = reader.components.combat:GetWeapon()
        if weapon and weapon.components.finiteuses then
            local damage = weapon.components.weapon:GetDamage()
            local uses = weapon.components.finiteuses:GetUses()
            local sum = damage*uses
            local amt = v[i]
            local stack = math.floor(sum/amt+.5) 
            weapon:Remove()
            reader.SoundEmitter:PlaySound("dontstarve/wilson/use_armour_break")
            FxManager:MakeFx("beefalo_transform_fx", reader)
            local item = SpawnPrefab(item_name)
            item.components.stackable:SetStackSize(stack)
            reader.components.inventory:GiveItem(item, nil, Vector3(TheSim:GetScreenPos(reader.Transform:GetWorldPosition())))
        end
    end,
    function(inst, reader)
        local weapon = reader.components.combat:GetWeapon()
        if weapon and weapon.components.finiteuses then
            return true
        end
    end,
    function(inst, reader)
        inst.components.book.test_data = {
            san = 10*i,
            mana = 10*i,
        }
    end)
    table.insert(prefs, scroll)
    Util:AddString(scroll.name, scroll_name, 
        string.format("如果你装备了武器(且拥有耐久),将其摧毁,根据其攻击力和剩余耐久获得数张%s", 
            Util:GetScreenName(item_name)) 
    )
    ScrollManager:Add(scroll.name, elem)
end

end

-- local scroll_wake_skill = MakeScroll("tp_scroll_wake_skill", 
-- function(inst, reader)
--     local equips = {}
--     local equip = reader.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
--     table.insert(equips, equip)
--     local equip = reader.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
--     table.insert(equips, equip)
--     local equip = reader.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
--     table.insert(equips, equip)
--     for k, v in pairs(equips) do
--         if v.components.tp_smearable then
--             if v.components.tp_smearable:CanSmearId("skill_wake") then
--                 v.components.tp_smearable:Smear("skill_wake")
--             end
--         end
--     end
-- end, 
-- nil,
-- function(inst)
--     inst.components.book.test_data = {
--         san = 10,
--         mana = 10,
--     }
-- end)
-- table.insert(prefs, scroll_wake_skill)
-- Util:AddString(scroll_wake_skill.name, "《激活技能》", "激活穿戴装备的技能")
-- ScrollManager:Add(scroll_wake_skill.name, "wind")

local scroll_fire_lunge = MakeScroll("tp_scroll_fire_lunge", 
function(inst, reader)
    local weapon = reader.components.combat:GetWeapon()
    if weapon and weapon.components.tp_smearable then
        if weapon.components.tp_smearable:CanSmearId("fire_lunge") then
            weapon.components.tp_smearable:Smear("fire_lunge")
        end
    end
end,
function(inst, reader)
    local weapon = reader.components.combat:GetWeapon()
    if weapon and weapon.components.tp_smearable then
        return true
    end
end,
function(inst)
    inst.components.book.test_data = {
        san = 10,
        mana = 10,
    }
end)
table.insert(prefs, scroll_fire_lunge)
Util:AddString(scroll_fire_lunge.name, "《火焰突刺》", "令你的武器获得火焰突刺")
ScrollManager:Add(scroll_fire_lunge.name, "fire")

local scroll_ice_lunge = MakeScroll("tp_scroll_ice_lunge", 
function(inst, reader)
    local weapon = reader.components.combat:GetWeapon()
    if weapon and weapon.components.tp_smearable then
        if weapon.components.tp_smearable:CanSmearId("ice_lunge") then
            weapon.components.tp_smearable:Smear("ice_lunge")
        end
    end
end,
function(inst, reader)
    local weapon = reader.components.combat:GetWeapon()
    if weapon and weapon.components.tp_smearable then
        return true
    end
end,
function(inst)
    inst.components.book.test_data = {
        san = 10,
        mana = 10,
    }
end)
table.insert(prefs, scroll_ice_lunge)
Util:AddString(scroll_ice_lunge.name, "《冰霜突刺》", "令你的武器获得冰霜突刺")
ScrollManager:Add(scroll_ice_lunge.name, "ice")

local scroll_shadow_lunge = MakeScroll("tp_scroll_shadow_lunge", 
function(inst, reader)
    local weapon = reader.components.combat:GetWeapon()
    if weapon and weapon.components.tp_smearable then
        if weapon.components.tp_smearable:CanSmearId("shadow_lunge") then
            weapon.components.tp_smearable:Smear("shadow_lunge")
        end
    end
end,
function(inst, reader)
    local weapon = reader.components.combat:GetWeapon()
    if weapon and weapon.components.tp_smearable then
        return true
    end
end,
function(inst)
    inst.components.book.test_data = {
        san = 20,
        mana = 20,
    }
end)
table.insert(prefs, scroll_shadow_lunge)
Util:AddString(scroll_shadow_lunge.name, "《幻影突刺》", "令你的武器获得幻影突刺")
ScrollManager:Add(scroll_shadow_lunge.name, "shadow")

local scroll_double_cyclone = MakeScroll("tp_scroll_double_cyclone", 
function(inst, reader)
    local weapon = reader.components.combat:GetWeapon()
    if weapon and weapon.components.tp_smearable then
        if weapon.components.tp_smearable:CanSmearId("double_cyclone") then
            weapon.components.tp_smearable:Smear("double_cyclone")
        end
    end
end,
function(inst, reader)
    local weapon = reader.components.combat:GetWeapon()
    if weapon and weapon.components.tp_smearable then
        return true
    end
end,
function(inst)
    inst.components.book.test_data = {
        san = 20,
        mana = 20,
    }
end)
table.insert(prefs, scroll_double_cyclone)
Util:AddString(scroll_double_cyclone.name, "《双重回旋》", "令你的武器获得双重回旋")
ScrollManager:Add(scroll_double_cyclone.name, "wind")

ScrollManager:Submit()

return unpack(prefs)