local PrefabUtil = require "extension.lib.prefab_util"
local Util = require "extension.lib.wg_util"
local Kit = require "extension.lib.wargon"
local AssetMaster = Sample.AssetMaster
local BuffManager = Sample.BuffManager
local FxManager = Sample.FxManager

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

        if read_fn == nil and read_test == nil then
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
            faith = 10,
            intelligence = 10,
        },
        san = 40,
        mana = 40,
    }
end)
table.insert(prefs, scroll_back)
Util:AddString(scroll_back.name, "《返回》", "传送到最近的一个点燃的无尽营火处")

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
            faith = 10,
            intelligence = 10,
        },
        san = 40,
        mana = 40,
    }
end)
table.insert(prefs, scroll_fire_atk)
Util:AddString(scroll_fire_atk.name, "《火焰武器》", "武器攻击附带火属性伤害")

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
            intelligence = 16,
        },
        san = 40,
        mana = 40,
    }
end)
table.insert(prefs, scroll_ice_atk)
Util:AddString(scroll_ice_atk.name, "《寒冰武器》", "武器攻击附带冰属性伤害")

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
            faith = 20,
        },
        san = 80,
        mana = 80,
    }
end)
table.insert(prefs, scroll_electric_atk)
Util:AddString(scroll_electric_atk.name, "《雷电武器》", "武器攻击附带雷属性伤害")

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
            intelligence = 20,
        },
        san = 80,
        mana = 80,
    }
end)
table.insert(prefs, scroll_shadow_atk)
Util:AddString(scroll_shadow_atk.name, "《黑暗武器》", "武器攻击附带暗属性伤害")

local scroll_hollow = MakeScroll("tp_scroll_hollow", nil, nil, function(inst)
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    -- inst.components.equippable:SetOnEquip(function(inst, owner)
    -- end)
    -- inst.components.equippable:SetOnUnequip(function(inst, owner)
    -- end)
    inst.components.equippable.equipstack = true
    inst:AddComponent("wg_reticule")
    inst:AddComponent("wg_action_tool")
    inst:AddTag("wg_equip_skill")
    inst.components.wg_action_tool:SetDescription()
    inst.components.wg_action_tool:SetSkillType()
    inst.components.wg_action_tool:RegisterSkillInfo({
        mana = 100,
        vigor = 2,
    })
    -- inst.components.wg_action_tool.test = function(inst, doer)
    --     --检测
    -- end
    inst.components.wg_action_tool.get_action_fn = function(inst, data)
        -- 装备后可以收集到的动作 data={doer=doer, pos=pos, target=target}
        if data.pos or data.target then
            return ACTIONS.TP_ATK
        end
    end
    inst.components.wg_action_tool.click_no_action = true
    inst.components.wg_action_tool.click_fn = function(inst, doer)
        -- 技能栏里释放技能会触发的效果，默认会出发get_action_fn的动作
        inst.components.wg_reticule:Toggle()
    end
    inst.components.wg_action_tool.effect_fn = function(inst, doer, target, pos)
        -- 动作触发时会到达的效果
        if target then
            pos = target:GetPosition()
        end
        local fx = FxManager:MakeFx("hollow_bean", doer, {pos = pos, owner=doer})
        -- if math.random() < .5 then
        -- else
        --     local fx = FxManager:MakeFx("hollow_bean2", doer, {pos = pos, owner=doer})
        -- end
    end
end)
table.insert(prefs, scroll_hollow)
Util:AddString(scroll_hollow.name, "《顺时针法术·苍》", "发射一个能量球,飞行一段距离后会停止,能量球会造成伤害,停止后造成的伤害更高")

return unpack(prefs)