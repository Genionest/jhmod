PrefabFiles = {
	"tp_items",
	"tp_spear",
	"tp_charge_proj",
	"tp_ruinbat",
	"scrolls",
	"scrolls_pig",
	"tp_builder",
	-- "tp_perd",
	"tp_char",
	"tp_structure",
	"tp_tree",
	"tp_tree_seed",
	"tp_pet",
	-- "tp_beefalo",
	-- "tp_baby_beefalo",
	"tp_unreal_wilson",
	"tp_pig_spirit",
	"tp_pig_worker",
	"tp_pig_home",
	"tp_werepig_king",
	"tp_sign_rider",
	"tp_smelter",
	"tp_cook_pot",
	"tp_pack",
	"tp_fx",
	"tp_sparkle_fx",
	"tp_snow_fx",
	"tp_shadow_fx",
	"tp_blood_fx",
	"tp_bat_fx",
	"tp_spirit_fx",
}

Assets = {}

-- local function GlobalUsingMetatable()
-- 	GLOBAL.setmetatable(env, {__index = function(t, k)
-- 		return GLOBAL.rawget(GLOBAL, k)
-- 	end,})
-- end
-- GlobalUsingMetatable()

local _G = GLOBAL
modimport("modimport/wargon.lua")
-----------------------------------------------
_L = _G.WARGON.get_config("language")
STRINGS.TP_STR = {
	tp_reng = _L and 'throw' or '扔',
	tp_tou = _L and 'cast' or '投',
	tp_hua = _L and 'slide' or '滑',
	tp_za = _L and 'jump' or '跳砸',
	tp_ci = _L and 'lunge' or '突刺',
	tp_load_ammo = _L and 'load' or '装填',
	tp_change = _L and 'change' or '改变',
	tp_gift_pigking = _L and "Gift of the Pig King" or '猪王的礼物',
	tp_gift_alloy = _L and "Gift of Forge" or '熔炉的礼物',
	tp_gift_gingko = _L and "Gift of Ginkgo" or '银杏的礼物',
	tp_pig_fire = _L and 'Fire Punch' or '炎拳',
	tp_pig_ice = _L and 'for the Lich King' or '为了巫妖王',
	tp_pig_poison = _L and 'Juggernaut' or '主宰',
}
-----------------------------------------------
modimport("modimport/equip_ex.lua")
modimport("modimport/sleep_ex.lua")
modimport("modimport/builder_ex.lua")
modimport("modimport/cmp_ex.lua")
modimport("modimport/sg_ex.lua")
modimport("modimport/brain_ex.lua")
modimport("modimport/fx_ex.lua")
modimport("modimport/check_ex.lua")
modimport("modimport/tree_ex.lua")
-----------------------------------------------
modimport("main/scroll.lua")
modimport("main/tp_prefab.lua")
modimport("main/tp_sg.lua")
modimport("main/tp_action.lua")
modimport("main/tp_class.lua")
modimport("main/tp_tuning.lua")

_G.WARGON.CHECK.check_need()

local scroll_assets = {
	"bird",
	"lightning",
	"sleep",
	"tentacle",
	"volcano",
	"grow",
	"pig_armor",
	"pig_armorex",
	"pig_speed",
	"pig_damage",
	"pig_heal",
	"pig_teleport",
	"pig_leader",
	"pig_health",
}
for i, v in pairs(scroll_assets) do
	_G.WARGON.add_asset(Assets, "inventoryimages/scroll_"..v, "atlas")
end
local spear_assets = {
	"ice",
	"fire",
	"thunder",
	"blood",
	"poison",
	"shadow",
}
for i, v in pairs(spear_assets) do
	_G.WARGON.add_asset(Assets, "tp_spear_"..v, "anim")
	_G.WARGON.add_asset(Assets, "inventoryimages/tp_spear_"..v, "atlas")
end
local ruinbat_assets = {
	"bearger",
	"dragonfly",
	"deerclops",
	"moose",
}
for i, v in pairs(ruinbat_assets) do
	_G.WARGON.add_asset(Assets, "tp_ruinbat_"..v, "anim")
	_G.WARGON.add_asset(Assets, "inventoryimages/tp_ruinbat_"..v, "atlas")
end
local item_assets = {
	"tp_cutlass",
	"tp_sign_staff",
	"pig_book",
	"pig_lamp",
	"tp_gift",
	"tp_gingko_tree",
	"tp_gingko",
	"tp_gingko_leaf",
	"tp_gingko_spaling",
	"tp_alloy",
	"tp_flare",
	"tp_cook_pot",
	"tp_furnace",
	"tp_forest_gun",
	"tp_spear_wind",
}
for i, v in pairs(item_assets) do
	_G.WARGON.add_asset(Assets, v, "anim")
	_G.WARGON.add_asset(Assets, "inventoryimages/"..v, "atlas")
end
local a_t = _G.WARGON.CHECK.check_asset()
if not a_t.wortox then
	_G.WARGON.add_asset(Assets, "wortox_soul_heal_fx", "anim")
end
_G.WARGON.add_asset(Assets, "recharge_meter_wargon", "anim")
-- _G.WARGON.add_asset(Assets, "recharge_meter", "anim")
_G.WARGON.add_asset(Assets, "tp_spore", "anim")
_G.WARGON.add_asset(Assets, "tp_spore_blue", "anim")
_G.WARGON.add_asset(Assets, "tp_teen_bird", "anim")
_G.WARGON.add_asset(Assets, "tp_small_bird", "anim")
_G.WARGON.add_asset(Assets, "tp_has_alloy", "anim")
_G.WARGON.add_asset(Assets, "tp_strawhat_trap", "anim")
_G.WARGON.add_asset(Assets, "tp_strawhat", 'anim')
_G.WARGON.add_asset(Assets, "swap_forest_gun", 'anim')
_G.WARGON.add_asset(Assets, "swap_spear_wind", 'anim')
------------------------------------
_G.WARGON.add_asset(Assets, "inventoryimages/tp_war_tree_spaling", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_defense_tree_spaling", 'atlas')
_G.WARGON.add_asset(Assets, "hud/tp_recipe", 'atlas')
------------------------------------
_G.WARGON.add_map('inventoryimages/tp_gingko_tree')
_G.WARGON.add_map('inventoryimages/tent_circus')
_G.WARGON.add_map('inventoryimages/treasure_chest_sacred')
_G.WARGON.add_map('inventoryimages/pighouse_logcabin')
_G.WARGON.add_map('inventoryimages/tp_cook_pot')
_G.WARGON.add_map('inventoryimages/tp_furnace')
_G.WARGON.add_map('inventoryimages/backpack_crab')
_G.WARGON.add_map('inventoryimages/backpack_dragonfly')
_G.WARGON.add_map('inventoryimages/backpack_rabbit')
_G.WARGON.add_map('inventoryimages/backpack_beefalo')
_G.WARGON.add_map('inventoryimages/backpack_catcoon')
_G.WARGON.add_map('inventoryimages/strawhat_cowboy')

local scroll_generic = "失落的上古之章"
local scroll_str = {
	tentacle 	= "大地之触",
	bird 		= "百鸟朝凰",
	lightning 	= "诸神之怒",
	sleep 		= "梦游仙境",
	grow 		= "精灵之歌",
	volcano 	= "烈火雄心",
	pig_armor 	= "守护卷轴",
	pig_armorex = "庇佑卷轴",
	pig_speed 	= "神速卷轴",
	pig_damage 	= "狂野卷轴",
	pig_teleport= "传送卷轴",
	pig_heal	= "恢复卷轴",
	pig_leader	= "征召卷轴",
	pig_health 	= "祝福卷轴",
}
local e_scroll_str = {
	tentacle 	= "Page Tentacle",
	bird 		= "Page Bird",
	lightning 	= "Page Brimstone",
	sleep 		= "Page Sleep",
	grow 		= "Page Garden",
	volcano 	= "Page Meteor",
	pig_armor 	= "Page Armor",
	pig_armorex = "Page Defense",
	pig_speed 	= "Page Speed",
	pig_damage 	= "Page Damage",
	pig_teleport= "Page Teleport",
	pig_heal	= "Page Heal",
	pig_leader	= "Page Leader",
	pig_health 	= "Page Wish",
}
for i, v in pairs(_L and e_scroll_str or scroll_str) do
	_G.WARGON.add_str("scroll_"..i, v, scroll_generic)
end
local the_strs = {
	-- tp_ash = {'威尔逊的粉末', '可以合成一些东西', nil},
	-- beefalo_sp = {'牛来', nil, nil},
	-- tp_perd = {'威尔逊的火鸡', '快去干活', nil},
	-- tp_gingko = {'银杏果', '银杏树的果实'},
	-- tp_war_tree_seed = {'战争树种', '孕育战争的精灵'},
	-- tp_defense_tree_seed = {'哨兵树种', '精灵守护着这个种子'},
	-- tp_beefalo = {'骑骑', '它很温顺'},
	-- tp_baby_beefalo = {'威尔逊的小牛', '它现在还不能骑'},
	-- tp_gift_pigking = {'猪王的礼物', '打开看看'},
	-- tp_gift_gingko = {'银杏的礼物', '打开看看'},
	-- tp_gift_alloy = {'工坊的礼物', '打开看看'},
	bigfoot_sp = {'脚来', nil, nil},
	morph_sp = {'变身', nil, nil},
	callbeast_sp = {'九牛二猪', nil, nil},
	tp_pig_fire = {'赤蹄·瑞德', '火焰果实的持有者', nil},
	tp_pig_ice = {'青鬃·布鲁', '冰霜果实的持有者', nil},
	tp_pig_poison = {'绿鼻-格林', '剧毒果实的持有者', nil},
	tp_spear_lance = {'威尔逊的战矛', '尝尝科学的威力', '把石头磨尖'},
	tp_spear_ice = {'冰矛', '这把矛带着宝石的魔力'},
	tp_spear_fire = {'火矛', '这把矛带着宝石的魔力'},
	tp_spear_thunder = {'雷矛', '这把矛带着宝石的魔力'},
	tp_spear_gungnir = {'威尔逊的战矛', '尝尝科学的威力', '把石头磨尖'},
	tp_spear_poison = {'毒矛', '这把矛带着宝石的魔力'},
	tp_spear_shadow = {'影矛', '这把矛带着宝石的魔力'},
	tp_spear_blood = {'血矛', '这把矛带着宝石的魔力'},
	tp_spear_wind = {'落木之息', '风起于青萍之末...', '风之精灵为你助阵'},
	tp_strawhat = {'精灵草帽', '决定就是你了'},
	tp_strawhat2 = {'精灵草帽', '决定就是你了'},
	tp_strawhat_saddle = {'精灵草帽鞍', '决定就是你了'},
	tp_strawhat_trap = {'精灵草帽陷阱', '决定就是你了'},
	tp_ballhat = {'战斗头盔', '加入战斗', '拥抱战斗的荣耀'},
	tp_woodarmor = {'锯齿木甲', '应该这样用才对', '木质板砖'},
	tp_hambat = {'威尔逊的火腿', '好棒', '戳破天际'},
	tp_staff_trinity = {'三一魔杖', '三份的快乐'},
	tp_tent = {'大帐篷', '醒了记得修', '睡个好觉'},
	tp_rocket = {'人工降雨', '准备发射', '戳破天际'},
	tp_cane = {'滑行手杖', '我得换条好点的裤子', '我建议滑着走'},
	tp_ruinbat = {'守卫者的短剑', '重击敌人'},
	tp_ruinbat_bearger = {'熊獾短剑', '巨人的灵魂所铸'},
	tp_ruinbat_dragonfly = {'龙蝇短剑', '巨人的灵魂所铸'},
	tp_ruinbat_deerclops = {'巨鹿短剑', '巨人的灵魂所铸'},
	tp_ruinbat_moose = {'鹿鹅短剑', '巨人的灵魂所铸'},
	tp_cutlass = {'旗鱼水剑', '踏浪而行'},
	tp_sign_staff = {'路牌法杖', '大威天龙'},
	tp_forest_gun = {'森林之枪', '精灵的歌声中有它的名字'},
	tp_unreal_sword = {'幻影剑', '这是猪王py老麦来的'},
	tp_oak_armor = {'橡木甲', '有精灵居住在这里'},
	tp_pig_book = {'猪王日记', '希望这里记录有金矿的位置'},
	tp_brave_amulet = {'勇气护符', '化食物为力量'},
	tp_pig_lamp = {'猪拉丁神灯', '这玩意能许愿不'},
	tp_pig_spirit = {'神灯之灵', '你管这玩意叫灯神'},
	tp_chest = {'潘多拉魔盒', '受诅咒的宝箱'},
	tp_gingko_tree = {'银杏树', '这是银杏的变种'},
	tp_gingko_leaf = {'银杏树叶', '叶落归根'},
	tp_gingko_spaling = {'银杏树苗', '十年树木，百年树人'},
	tp_war_tree_spaling = {'战争树苗', '孕育战争的精灵'},
	tp_war_tree = {'战争古树', '古老的战争精灵'},
	tp_defense_tree_spaling = {'哨兵树苗', '精灵守护着这个种子'},
	tp_defense_tree = {'哨兵树', '古老的守卫者'},
	tp_chop_pig = {'伐木猪', '工具猪1号'},
	tp_hack_pig = {'砍工猪', '工具猪2号'},
	tp_farm_pig = {'农场猪', '工具猪3号'},
	tp_chop_pig_home = {'伐木猪屋', '把灯开一下'},
	tp_hack_pig_home = {'砍工猪屋', '把灯开一下'},
	tp_farm_pig_home = {'农场猪屋', '把灯开一下'},
	tp_bird_egg = {'威尔逊的蛋', '放心吧，我不会吃你的'},
	tp_bird_egg_cracked = {'威尔逊的鸟蛋', '小鸡快出来'},
	tp_small_bird = {'小锅鸟', '跟着我'},
	tp_teen_bird = {'大锅鸟', '它很方便'},
	tp_werepig_king = {'野猪王', '谁把他放出来了'},
	tp_pigking_hat = {'猪王帽子', '必须要有一位猪人王'},
	tp_sign_rider = {'路牌骑士', '小心她的路牌'},
	tp_smelter = {'战争熔炉', '锻造合金'},
	tp_alloy = {'蓝色合金', '千锤百炼'},
	tp_gift = {'萌新礼包', '开局就送'},
	tp_cook_pot = {'威尔逊的烹饪锅', '它很方便'},
	tp_pack_crab = {'冰蟹背包', '背着的保鲜袋'},
	tp_pack_dragonfly = {'火蜓背包', '吃的是草，挤得是灰'},
	tp_pack_rabbit = {'兔兔背包', '动若脱兔'},
	tp_pack_beefalo = {'牦牛背包', '与牛共舞'},
	tp_pack_catcoon = {'浣熊背包', '嗷呜~'},
}
local e_the_strs = {
	bigfoot_sp = {'Big Foot', nil, nil},
	morph_sp = {'Morph', nil, nil},
	callbeast_sp = {'Herd', nil, nil},
	tp_pig_fire = {'Fire Pig', 'It is a fire pig', nil},
	tp_pig_ice = {'Ice Pig', 'It is a ice pig', nil},
	tp_pig_poison = {'Poison Pig', 'It is a poison pig', nil},
	tp_spear_lance = {'spear of wilson', 'I love this'},
	tp_spear_ice = {'ice spear', 'the spear have gem power'},
	tp_spear_fire = {'fire spear', 'the spear have gem power'},
	tp_spear_thunder = {'thunder spear', 'the spear have gem power'},
	tp_spear_gungnir = {'spear of wilson', 'I love this'},
	tp_spear_poison = {'poison spear', 'the spear have gem power'},
	tp_spear_shadow = {'shadow spear', 'the spear have gem power'},
	tp_spear_blood = {'blood spear', 'the spear have gem power'},
	tp_spear_wind = {'Fallen Leaves', 'the wind elf'},
	tp_strawhat = {'straw hat', 'this is speical'},
	tp_strawhat2 = {'straw hat', 'this is speical'},
	tp_strawhat_saddle = {'straw saddle', 'this is speical'},
	tp_strawhat_trap = {'straw trap', 'this is speical'},
	tp_ballhat = {'Combat Helmet', 'join the fight'},
	tp_woodarmor = {'Sawtooth Armor', 'right way'},
	tp_hambat = {'ham of wilson', 'good ham'},
	tp_staff_trinity = {'Trinity Staff', 'one is full'},
	tp_tent = {'big tent', 'have a good sleep'},
	tp_rocket = {'mini rocket', 'shoot sky'},
	tp_cane = {'slide cane', 'I need a great pants'},
	tp_ruinbat = {"Gatekeepers' Dagger", 'Blow the enemy'},
	tp_ruinbat_bearger = {"Gatekeepers' Dagger", 'with soul of gaint'},
	tp_ruinbat_dragonfly = {"Gatekeepers' Dagger", 'with soul of gaint'},
	tp_ruinbat_deerclops = {"Gatekeepers' Dagger", 'with soul of gaint'},
	tp_ruinbat_moose = {"Gatekeepers' Dagger", 'with soul of gaint'},
	tp_cutlass = {'Water Cutlass', 'walking on water'},
	tp_sign_staff = {'Home Sign', 'sign of home'},
	tp_forest_gun = {'Forest Gun', "It has its name in the elf's song"},
	tp_unreal_sword = {'Unreal Sword', "It's Maxwell's?"},
	tp_oak_armor = {'Oak Armor', 'the abode of the elves'},
	tp_pig_book = {'Pigking Journal', '... how to be king'},
	tp_brave_amulet = {'Brave Amulet', 'mountain of courage'},
	tp_pig_lamp = {"Pigladdin's Magic Lamp", 'Hello, Pigladdin'},
	tp_pig_spirit = {'Lamp Spirit', 'what?'},
	tp_chest = {"Pandora's Box", 'Cursed treasure chest'},
	tp_gingko_tree = {'gingko tree', 'another kind of gingko tree'},
	tp_gingko_leaf = {'ginkgo biloba', 'Can I do it?'},
	tp_gingko_spaling = {'gingko spaling', 'Hurry and grow up'},
	tp_war_tree_spaling = {'war tree spaling', 'Hurry and grow up'},
	tp_war_tree = {'war tree', 'The old soldier'},
	tp_defense_tree_spaling = {'defense tree', 'Hurry and grow up'},
	tp_defense_tree = {'defense tree', 'The old guard'},
	tp_chop_pig = {'chopper', 'No.001'},
	tp_hack_pig = {'hacker', 'No.002'},
	tp_farm_pig = {'farmer', 'No.003'},
	tp_chop_pig_home = {'chopper house', 'turn off the lights'},
	tp_hack_pig_home = {'hacker house', 'turn off the lights'},
	tp_farm_pig_home = {'farmer house', 'turn off the lights'},
	tp_bird_egg = {'egg of wilson', "Don't worry"},
	tp_bird_egg_cracked = {'egg of wilson', "Don't worry"},
	tp_small_bird = {'small pot bird', 'follow me'},
	tp_teen_bird = {'big pot bird', 'looks good'},
	tp_werepig_king = {'Werepig King', 'Who let him out'},
	tp_pigking_hat = {'Pig King Hat', 'There must be a pig king'},
	tp_sign_rider = {'Knights of the Apocalypse', 'Be Careful'},
	tp_smelter = {'War Furnace', 'forged alloy'},
	tp_alloy = {'blue alloy', 'dental laboratories'},
	tp_gift = {"Maxwell's Gift", 'open and see'},
	tp_cook_pot = {'cooking pot of wilson', 'looks good'},
	tp_pack_crab = {'crab pack', 'It is like crab'},
	tp_pack_dragonfly = {'dragonfly pack', 'It is like dragonfly'},
	tp_pack_rabbit = {'rabbit pack', 'It is like rabbit'},
	tp_pack_beefalo = {'beefalo pack', 'It is like beefalo'},
	tp_pack_catcoon = {'catcoon pack', 'It is like catcoon'},
}
for i, v in pairs(_L and e_the_strs or the_strs) do
	_G.WARGON.add_str(i, v[1], v[2], v[3])
end

-- _G.WARGON.add_recipe(name, ingd, tab, tech, game, atlas, img, placer)
local function tech_prince_test(inst)
	return inst:HasTag("tech_prince")
end
local function mad_prince_test(inst)
	return inst:HasTag("mad_prince")
end

local function set_pig_test(rcp)
	-- rcp.wargon_test = function(inst)
	-- 	return inst:HasTag("pig_builder")
	-- end
	rcp.pigking = true
end
-- local book_rec = {
-- 	birds = "bird",
-- 	gardening = "grow",
-- 	sleep = "sleep",
-- 	brimstone = "lightning",
-- 	meteor = "volcano",
-- 	tentacles = "tentacle",
-- }
-- for i, v in pairs(book_rec) do
-- 	local ingd = {}
-- 	local num = 5
-- 	if v == "bird" then
-- 		num = 3
-- 	end
-- 	ingd["scroll_"..v] = num
-- 	local rcp = _G.WARGON.add_recipe('book_'..i, ingd, "ref", "none")
-- 	rcp.wargon_test = mad_prince_test
-- end

local function set_img(rcp, atlas)
	rcp.atlas = "images/inventoryimages/"..atlas..".xml"
	rcp.image = atlas..".tex"
end

local function get_img(img)
	local atlas = "images/inventoryimages/"..img..".xml"
	local tex = img..".tex"
	return atlas, tex
end

local function get_ori_img(img, two)
	local atlas = "images/inventoryimages.xml"
	if two then
		atlas = "images/inventoryimages_2.xml"
	end
	local tex = img..".tex"
	return atlas, tex
end

-- local ash = _G.WARGON.add_recipe('tp_ash', {ash=1, beardhair=1}, 'ref', 'none')
-- ash.image = "ash.tex"

AddPrefabPostInit("wilson", function(inst)
	local rtb = {str="invent", sort=999, icon="tp_recipe.tex",
		icon_atlas="images/hud/tp_recipe.xml"}
	inst.components.builder:AddRecipeTab(rtb)
-- original
local mp_sp = _G.WARGON.add_recipe('morph_sp', {san=5}, rtb, "none")
mp_sp.atlas = "minimap/minimap_data.xml"
mp_sp.image = "wilson.png"

local spear_lance = _G.WARGON.add_recipe('tp_spear_lance', 
	{twigs=2, rope=2, goldnugget=1}, rtb, 's_1')
set_img(spear_lance, "spear_forge_lance")

local spear_gungnir = _G.WARGON.add_recipe('tp_spear_gungnir', 
	{twigs=2, rope=2, goldnugget=1}, rtb, 's_1')
set_img(spear_gungnir, "spear_forge_gungnir")

local strawhat = _G.WARGON.add_recipe('tp_strawhat', 
	{cutgrass=12, rope=1}, rtb, 'none')
set_img(strawhat, "strawhat_cowboy")

local ham = _G.WARGON.add_recipe('tp_hambat', 
	{pigskin=1, twigs=2, meat=3}, rtb, 's_2')
set_img(ham, "ham_bat_spiralcut")

local wood = _G.WARGON.add_recipe('tp_woodarmor', 
	{log=8, rope=2, houndstooth=2}, rtb, 's_2')
set_img(wood, "armor_wood_fangedcollar")

local rocket = _G.WARGON.add_recipe('tp_rocket', 
	{cutgrass=5, twigs=1, gunpowder=1}, rtb, 's_2')
set_img(rocket, "tp_flare")

local cane = _G.WARGON.add_recipe('tp_cane', 
	{cane=1, thulecite_pieces=5, rope=1}, rtb, 's_2')
set_img(cane, "cane_ancient")
cane.wargon_test = tech_prince_test

local staff_trinity = _G.WARGON.add_recipe('tp_staff_trinity',
	{spear=1, redgem=1, bluegem=1}, rtb, 'm_2')
set_img(staff_trinity, "spear_bee")
staff_trinity.wargon_test = tech_prince_test

local pack_crab = _G.WARGON.add_recipe('tp_pack_crab',
	{cutreeds=12, rope=2, lobster=1}, rtb, 's_2')
set_img(pack_crab, "backpack_crab")
pack_crab.wargon_test = tech_prince_test

local pack_dragonfly = _G.WARGON.add_recipe('tp_pack_dragonfly',
	{cutreeds=12, rope=2, dragon_scales=1}, rtb, 's_2')
set_img(pack_dragonfly, "backpack_dragonfly")
pack_dragonfly.wargon_test = tech_prince_test

local pack_rabbit = _G.WARGON.add_recipe('tp_pack_rabbit',
	{cutreeds=12, rope=2, rabbit=4}, rtb, 's_2')
set_img(pack_rabbit, "backpack_rabbit")
pack_rabbit.wargon_test = tech_prince_test

local pack_beefalo = _G.WARGON.add_recipe('tp_pack_beefalo',
	{cutreeds=12, rope=2, beefalowool=6}, rtb, 's_2')
set_img(pack_beefalo, 'backpack_beefalo')
pack_beefalo.wargon_test = tech_prince_test

local pack_catcoon = _G.WARGON.add_recipe('tp_pack_catcoon',
	{cutreeds=12, rope=2, coontail=4}, rtb, 's_2')
set_img(pack_catcoon, 'backpack_catcoon')
pack_catcoon.wargon_test = tech_prince_test

local tent = _G.WARGON.add_recipe('tp_tent', {silk=10, twigs=6, rope=4}, 
	rtb, 's_2', nil, nil, nil, "tp_tent_placer")
-- tent.atlas = "images/inventoryimages/tent_circus.xml"
-- tent.image = "tent_circus.tex"
set_img(tent, 'tent_circus')
tent.wargon_test = tech_prince_test

local function create_scroll_rec(recs)
	for i, v in pairs(recs) do
		local ingd = {papyrus=1, honey=1}
		ingd[v[1]] = v[2]
		local rcp = _G.WARGON.add_recipe('scroll_'..i, ingd, rtb, v[3])
		set_img(rcp, 'scroll_'..i)
		if string.find(i, "pig") then
			set_pig_test(rcp)
		else
			rcp.wargon_test = tech_prince_test
		end
	end
end

local scroll_rec = {
	tentacle 	= {"tentaclespots", 1, "s_3"},
	bird 		= {"feather_robin", 1, "s_1"},
	lightning 	= {"redgem", 1, "m_3"},
	sleep 		= {"nightmarefuel", 1, "m_2"},
	grow 		= {"seeds", 1, "s_1"},
	volcano 	= {"obsidian", 1, "s_3"},
}
create_scroll_rec(scroll_rec)
local scroll_pig_rec = {
	pig_armor 	= {"footballhat", 1, "s_9"},
	pig_armorex = {"armorwood", 1, "s_9"},
	pig_speed  	= {"coffeebeans", 1, "s_9"},
	pig_damage  = {"hambat", 1, "s_9"},
	pig_heal	= {"bandage", 1, "s_9"},
	-- pig_leader 	= {'meat', 1, "s_9"},
	pig_teleport= {"butterflywings", 1, "s_9"},
	pig_health 	= {"dragonfruit", 1, 's_9'},
}
create_scroll_rec(scroll_pig_rec)

local egg = _G.WARGON.add_recipe('tp_bird_egg', 
	{tallbirdegg=5, bird_egg=1}, 'ref', 's_2')
egg.image = "tallbirdegg.tex"
egg.wargon_test = mad_prince_test

-- local beefalo_sp = _G.WARGON.add_recipe('beefalo_sp', 
-- 	{beefalowool=20, horn=2}, 'mag', 'none')
-- beefalo_sp.image = 'horn.tex'
-- beefalo_sp.wargon_test = mad_prince_test

local bf_sp = _G.WARGON.add_recipe('bigfoot_sp', {san=50}, "mag", "none")
bf_sp.image = "bell.tex"
bf_sp.wargon_test = mad_prince_test

local call_sp = _G.WARGON.add_recipe('callbeast_sp', {san=50}, 'mag', 'none')
call_sp.image = "panflute.tex"
call_sp.wargon_test = mad_prince_test

-- tree_line
local gingko_spaling = _G.WARGON.add_recipe('tp_gingko_spaling',
	{tp_gingko_leaf={1, get_img('tp_gingko_leaf')}, poop=1}, 
	'ref', 's_2', nil, nil, nil, "tp_gingko_spaling_placer")
set_img(gingko_spaling, 'tp_gingko_spaling')

local war_spaling = _G.WARGON.add_recipe('tp_war_tree_spaling',
	{tp_gingko_leaf={2, get_img('tp_gingko_leaf')}, poop=1}, 
	'ref', 's_2', nil, nil, nil, 'tp_war_tree_spaling_placer')
set_img(war_spaling, 'tp_war_tree_spaling')

local defense_spaling = _G.WARGON.add_recipe('tp_defense_tree_spaling',
	{tp_gingko_leaf={3, get_img('tp_gingko_leaf')}, poop=1}, 
	'ref', 's_2', nil, nil, nil, 'tp_defense_tree_spaling_placer')
set_img(defense_spaling, 'tp_defense_tree_spaling')

local spear_wind = _G.WARGON.add_recipe('tp_spear_wind', 
	{
		tp_spear_lance={2, get_img('spear_forge_lance')}, 
		tp_gingko_leaf={20, get_img('tp_gingko_leaf')}
	}, 
	'war', 's_2')
set_img(spear_wind, "tp_spear_wind")

local oak_armor = _G.WARGON.add_recipe('tp_oak_armor',
	{armorwood=2, tp_gingko_leaf={20, get_img('tp_gingko_leaf')} }, 'war', 's_2')
set_img(oak_armor, "armor_wood_haramaki")

local forest_gun = _G.WARGON.add_recipe('tp_forest_gun',
	{gears=5, gunpowder=5, tp_gingko_leaf={50, get_img('tp_gingko_leaf')} }, 'war', 's_2')
set_img(forest_gun, "tp_forest_gun")

-- local war_seed = _G.WARGON.add_recipe('tp_war_tree_seed',
-- 	{tp_gingko_leaf={2, get_img('tp_gingko_leaf')}, pinecone=2}, 'ref', 'm_3')
-- war_seed.image = "pinecone.tex"

-- local defense_seed = _G.WARGON.add_recipe('tp_defense_tree_seed',
-- 	{tp_gingko_leaf={2, get_img('tp_gingko_leaf')}, acorn=2}, 'ref', 'm_3')
-- defense_seed.image = "acorn.tex"

-- war_line
local ballhat = _G.WARGON.add_recipe('tp_ballhat', 
	{pigskin=1, rope=2, tp_alloy={1, get_img('tp_alloy')} }, 'war', 's_2')
set_img(ballhat, "footballhat_combathelm")
ballhat.wargon_test = tech_prince_test

local spear_ice = _G.WARGON.add_recipe('tp_spear_ice', 
	{
		tp_spear_lance={1, get_img('spear_forge_lance')}, 
		tp_alloy={1, get_img('tp_alloy')}, 
		bluegem=1
	}, 'war', 's_2')
set_img(spear_ice, 'tp_spear_ice')

local spear_fire = _G.WARGON.add_recipe('tp_spear_fire',
	{
		tp_spear_lance={1, get_img('spear_forge_lance')}, 
		tp_alloy={1, get_img('tp_alloy')}, 
		redgem=1
	}, 'war', 's_2')
set_img(spear_fire, 'tp_spear_fire')

local spear_thunder = _G.WARGON.add_recipe('tp_spear_thunder',
	{
		tp_spear_lance={1, get_img('spear_forge_lance')}, 
		tp_alloy={1, get_img('tp_alloy')}, 
		purplegem=1
	}, 'war', 's_2')
set_img(spear_thunder, 'tp_spear_thunder')

local spear_poison = _G.WARGON.add_recipe('tp_spear_poison',
	{
		tp_spear_gungnir={1, get_img('spear_forge_gungnir')}, 
		tp_alloy={3, get_img('tp_alloy')}, 
		greengem=1
	}, 'war', 's_2')
set_img(spear_poison, 'tp_spear_poison')

local spear_shadow = _G.WARGON.add_recipe('tp_spear_shadow',
	{
		tp_spear_gungnir={1, get_img('spear_forge_gungnir')}, 
		tp_alloy={3, get_img('tp_alloy')}, 
		yellowgem=1
	}, 'war', 's_2')
set_img(spear_shadow, 'tp_spear_shadow')

local spear_blood = _G.WARGON.add_recipe('tp_spear_blood',
	{
		tp_spear_gungnir={1, get_img('spear_forge_gungnir')}, 
		tp_alloy={3, get_img('tp_alloy')}, 
		orangegem=1
	}, 'war', 's_2')
set_img(spear_blood, 'tp_spear_blood')

local ruinbat = _G.WARGON.add_recipe('tp_ruinbat', 
	{	
		thulecite=4, livinglog=3, 
		tp_alloy={3, get_img('tp_alloy')} 
	}, 'anc', 'a_4', {'rog'})
set_img(ruinbat, "ruins_bat_heavy")

local cutlass = _G.WARGON.add_recipe('tp_cutlass', 
	{
		dead_swordfish=1, goldnugget=2,
		tp_alloy={3, get_img('tp_alloy')} 
	}, 'war', 's_2')
set_img(cutlass, "tp_cutlass")
--OBSIDIAN_BENCH
local smelter = _G.WARGON.add_recipe('tp_smelter', 
	{
		tp_alloy={1, get_img('tp_alloy')}, 
		redgem=2, goldnugget=10
	}, 
	'sci', 's_2', nil, nil, nil, "tp_smelter_placer")
set_img(smelter, "tp_furnace")

-- pig_line
local pig_book = _G.WARGON.add_recipe('tp_pig_book', 
	{papyrus=4, nightmarefuel=4, pigskin=4}, 'mag', 's_9')
set_img(pig_book, 'pig_book')
set_pig_test(pig_book)

local pig_lamp = _G.WARGON.add_recipe('tp_pig_lamp', 
	{tarlamp=1, purplegem=4, obsidian=4}, 'mag', 's_9')
set_img(pig_lamp, 'pig_lamp')
set_pig_test(pig_lamp)

local brave_amulet = _G.WARGON.add_recipe('tp_brave_amulet',
	{greenamulet=1, yellowamulet=1, orangeamulet=1}, 'mag', 's_9')
set_img(brave_amulet, "amulet_red_occulteye")
set_pig_test(brave_amulet)

local unreal_sword = _G.WARGON.add_recipe('tp_unreal_sword',
	{
		nightsword=1, purplegem=1,
		tp_pigking_hat={1, get_img('beefalohat_pigking')}, 
	}, 'mag', 's_9')
set_img(unreal_sword, 'nightsword_sharp')
set_pig_test(unreal_sword)

local chest = _G.WARGON.add_recipe('tp_chest', 
	{boards=3, nightmarefuel=9}, 'mag', 's_9',
	nil, nil, nil, "tp_chest_placer")
chest.atlas = "images/inventoryimages/treasure_chest_sacred.xml"
chest.image = "treasure_chest_sacred.tex"
set_pig_test(chest)

local chop_home = _G.WARGON.add_recipe('tp_chop_pig_home', 
	{boards=4, pigskin=4, axe=1}, 'far', 's_9',
	nil, nil, nil, "tp_chop_pig_home_placer")
set_img(chop_home, "pighouse_logcabin")
set_pig_test(chop_home)

local hack_home = _G.WARGON.add_recipe('tp_hack_pig_home', 
	{boards=4, pigskin=4, machete=1}, 'far', 's_9',
	nil, nil, nil, "tp_hack_pig_home_placer")
set_img(hack_home, "pighouse_logcabin")
set_pig_test(hack_home)

local farm_home = _G.WARGON.add_recipe('tp_farm_pig_home', 
	{boards=4, pigskin=4, fertilizer=1}, 'far', 's_9',
	nil, nil, nil, "tp_farm_pig_home_placer")
set_img(farm_home, "pighouse_logcabin")
set_pig_test(farm_home)

end)
