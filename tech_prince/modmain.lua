PrefabFiles = {
	"tp_items",
	"tp_spear",
	"tp_charge_proj",
	"tp_ruinbat",
	"scrolls",
	"tp_builder",
	"tp_perd",
	"tp_char",
	"tp_structure",
	"tp_tree",
	"tp_tree_seed",
	"tp_pet",
	"tp_beefalo",
	"tp_baby_beefalo",
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
modimport("modimport/equip_ex.lua")
modimport("modimport/sleep_ex.lua")
modimport("modimport/builder_ex.lua")
modimport("modimport/cmp_ex.lua")
modimport("modimport/sg_ex.lua")
modimport("modimport/brain_ex.lua")
modimport("modimport/fx_ex.lua")
modimport("modimport/check_ex.lua")
modimport("modimport/tree_ex.lua")
modimport("main/scroll.lua")
modimport("main/tp_prefab.lua")
modimport("main/tp_sg.lua")
modimport("main/tp_action.lua")
modimport("main/tp_class.lua")
modimport("main/tp_tuning.lua")

_G.WARGON.CHECK.check_need()
_G.WARGON.add_asset(Assets, "recharge_meter_wargon", "anim")
-- _G.WARGON.add_asset(Assets, "recharge_meter", "anim")
_G.WARGON.add_asset(Assets, "tp_spore", "anim")
_G.WARGON.add_asset(Assets, "tp_spore_blue", "anim")
_G.WARGON.add_asset(Assets, "tp_teen_bird", "anim")
_G.WARGON.add_asset(Assets, "tp_small_bird", "anim")
_G.WARGON.add_asset(Assets, "tp_has_alloy", "anim")
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
	"tp_alloy",
	"tp_flare",
	"tp_cook_pot",
	"tp_furnace",
}
for i, v in pairs(item_assets) do
	_G.WARGON.add_asset(Assets, v, "anim")
	_G.WARGON.add_asset(Assets, "inventoryimages/"..v, "atlas")
end
local a_t = _G.WARGON.CHECK.check_asset()
if not a_t.wortox then
	_G.WARGON.add_asset(Assets, "wortox_soul_heal_fx", "anim")
end
_G.WARGON.add_asset(Assets, "tp_strawhat", 'anim')
_G.WARGON.add_map('inventoryimages/tp_gingko_tree')
_G.WARGON.add_map('inventoryimages/tent_circus')
_G.WARGON.add_map('inventoryimages/treasure_chest_sacred')
_G.WARGON.add_map('inventoryimages/pighouse_logcabin')
_G.WARGON.add_map('inventoryimages/tp_cook_pot')
_G.WARGON.add_map('inventoryimages/tp_furnace')
_G.WARGON.add_map('inventoryimages/backpack_crab')
_G.WARGON.add_map('inventoryimages/backpack_dragonfly')
_G.WARGON.add_map('inventoryimages/backpack_rabbit')

local scroll_generic = "失落的上古之章"
local scroll_str = {
	tentacle 	= "大地之触",
	bird 		= "百鸟朝凰",
	lightning 	= "诸神之怒",
	sleep 		= "梦游仙境",
	grow 		= "精灵之歌",
	volcano 	= "烈火雄心",
}
for i, v in pairs(scroll_str) do
	_G.WARGON.add_str("scroll_"..i, v, scroll_generic)
end
local the_strs = {
	-- tp_ash = {'威吊的粉末', '可以合成一些东西', nil},
	bigfoot_sp = {'脚来', nil, nil},
	morph_sp = {'变身', nil, nil},
	callbeast_sp = {'九牛二猪', nil, nil},
	beefalo_sp = {'牛来', nil, nil},
	tp_perd = {'威吊的火鸡', '快去干活', nil},
	tp_pig_fire = {'赤蹄·瑞德', '火焰果实的持有者', nil},
	tp_pig_ice = {'青鬃·布鲁', '冰霜果实的持有者', nil},
	tp_pig_poison = {'绿鼻-格林', '剧毒果实的持有者', nil},
	tp_spear_lance = {'威吊的战矛', '尝尝科学的威力', '把石头磨尖'},
	tp_spear_ice = {'冰矛', '这把矛带着魔力'},
	tp_spear_fire = {'火矛', '这把矛带着魔力'},
	tp_spear_thunder = {'雷矛', '这把矛带着魔力'},
	tp_spear_gungnir = {'威吊的战矛', '尝尝科学的威力', '把石头磨尖'},
	tp_spear_poison = {'毒矛', '这把矛带着魔力'},
	tp_spear_shadow = {'影矛', '这把矛带着魔力'},
	tp_spear_blood = {'血矛', '这把矛带着魔力'},
	tp_spear_wind = {'落木之息', '风起于青萍之末', '风之精灵为你助阵'},
	tp_strawhat = {'精灵草帽', '决定就是你了'},
	tp_strawhat2 = {'精灵草帽', '驯师的草帽'},
	tp_ballhat = {'战斗头盔', '加入战斗', '拥抱战斗的荣耀'},
	tp_woodarmor = {'锯齿木甲', '应该这样用才对', '木质板砖'},
	tp_hambat = {'火腿肉棒', '好棒', '戳破天际'},
	tp_staff_trinity = {'三一魔杖', '三份的快乐'},
	tp_tent = {'大帐篷', '醒了记得修', '睡个好觉'},
	tp_rocket = {'人造火箭', '准备发射', '戳破天际'},
	tp_cane = {'滑行手杖', '我得换条好点的裤子', '我建议滑着走'},
	tp_ruinbat = {'远古短棒', '司马缸砸光', '重击敌人'},
	tp_ruinbat_bearger = {'熊獾短棒', '巨人的灵魂所铸'},
	tp_ruinbat_dragonfly = {'龙蝇短棒', '巨人的灵魂所铸'},
	tp_ruinbat_deerclops = {'巨鹿短棒', '巨人的灵魂所铸'},
	tp_ruinbat_moose = {'鹿鹅短棒', '巨人的灵魂所铸'},
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
	tp_gingko = {'银杏果', '银杏树的果实'},
	tp_gingko_tree = {'银杏树', '这是银杏的变种'},
	tp_war_tree_seed = {'战争树种', '古老的战争精灵'},
	tp_war_tree = {'战争树', '战争树'},
	tp_defense_tree_seed = {'哨兵树种', '古老的守卫者'},
	tp_defense_tree = {'哨兵树', '哨兵树'},
	tp_chop_pig = {'伐木猪', '工具猪1号'},
	tp_hack_pig = {'砍工猪', '工具猪2号'},
	tp_farm_pig = {'农场猪', '工具猪3号'},
	tp_chop_pig_home = {'伐木猪屋', '把灯开一下'},
	tp_hack_pig_home = {'砍工猪屋', '把灯开一下'},
	tp_farm_pig_home = {'农场猪屋', '把灯开一下'},
	tp_bird_egg = {'威吊的蛋', '放心吧，我不会吃你的'},
	tp_bird_egg_cracked = {'威吊的鸟蛋', '小鸡快出来'},
	tp_small_bird = {'小火锅', '跟着我'},
	tp_teen_bird = {'大火锅', '它很方便'},
	tp_beefalo = {'骑骑', '它很温顺'},
	tp_baby_beefalo = {'威吊的小牛', '它现在还不能骑'},
	tp_werepig_king = {'野猪王', '谁把他放出来了'},
	tp_pigking_hat = {'猪王帽子', '必须要有一位猪人王'},
	tp_sign_rider = {'路牌骑士', '小心她的路牌'},
	tp_smelter = {'战争熔炉', '锻造合金'},
	tp_alloy = {'蓝色合金', '千锤百炼'},
	tp_gift_pigking = {'猪王的礼物', '打开看看'},
	tp_gift_gingko = {'银杏的礼物', '打开看看'},
	tp_gift_alloy = {'工坊的礼物', '打开看看'},
	tp_gift = {'萌新礼包', '开局就送'},
	tp_cook_pot = {'威吊的烹饪锅', '它很方便'},
	tp_pack_crab = {'冰蟹背包', '背着保鲜'},
	tp_pack_dragonfly = {'火蜓背包', '吃的是草，挤得是灰'},
	tp_pack_rabbit = {'兔兔背包', '动若脱兔'}
}
for i, v in pairs(the_strs) do
	_G.WARGON.add_str(i, v[1], v[2], v[3])
end

-- _G.WARGON.add_recipe(name, ingd, tab, tech, game, atlas, img, placer)
local function tech_prince_test(inst)
	return inst:HasTag("tech_prince")
end
local function mad_prince_test(inst)
	return inst:HasTag("mad_prince")
end

local function pig_build_test(inst)
	return inst:HasTag("pig_builder")
end

local scroll_rec = {
	tentacle 	= {"tentaclespots", "s_3"},
	bird 		= {"bird_egg", "s_1"},
	lightning 	= {"redgem", "m_3"},
	sleep 		= {"nightmarefuel", "m_2"},
	grow 		= {"seeds", "s_1"},
	volcano 	= {"obsidian", "s_3"},
}
for i, v in pairs(scroll_rec) do
	local ingd = {papyrus=1, honey=1}
	ingd[v[1]] = 1
	local rcp = _G.WARGON.add_recipe('scroll_'..i, ingd, 'ref', v[2])
	rcp.image = "papyrus.tex"
	rcp.wargon_test = tech_prince_test
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

-- original
local spear_lance = _G.WARGON.add_recipe('tp_spear_lance', 
	{twigs=2, rope=2, goldnugget=1}, 'war', 's_1')
set_img(spear_lance, "spear_forge_lance")
-- spear_lance.wargon_test = tech_prince_test

local spear_gungnir = _G.WARGON.add_recipe('tp_spear_gungnir', 
	{twigs=2, rope=2, goldnugget=1}, 'war', 's_1')
set_img(spear_gungnir, "spear_forge_gungnir")
-- spear_gungnir.wargon_test = tech_prince_test

local strawhat = _G.WARGON.add_recipe('tp_strawhat', 
	{cutgrass=12, rope=1}, 'dre', 'none')
set_img(strawhat, "strawhat_cowboy")
-- strawhat.wargon_test = tech_prince_test

local ham = _G.WARGON.add_recipe('tp_hambat', 
	{pigskin=1, twigs=2, meat=3}, 'war', 's_2')
set_img(ham, "ham_bat_spiralcut")
-- ham.wargon_test = tech_prince_test

local wood = _G.WARGON.add_recipe('tp_woodarmor', 
	{log=8, rope=2, houndstooth=2}, 'war', 's_2')
set_img(wood, "armor_wood_fangedcollar")
-- wood.wargon_test = tech_prince_test

local rocket = _G.WARGON.add_recipe('tp_rocket', 
	{cutgrass=5, twigs=1, gunpowder=1}, 'sci', 's_2')
set_img(rocket, "tp_flare")
-- rocket.image = 'trinket_5.tex'
-- rocket.wargon_test = tech_prince_test

local cane = _G.WARGON.add_recipe('tp_cane', 
	{cane=1, thulecite_pieces=5, rope=1}, 'dre', 's_2')
set_img(cane, "cane_ancient")
cane.wargon_test = tech_prince_test

local staff_trinity = _G.WARGON.add_recipe('tp_staff_trinity',
	{spear=1, redgem=1, bluegem=1}, 'mag', 'm_2')
set_img(staff_trinity, "spear_bee")
staff_trinity.wargon_test = tech_prince_test

local pack_crab = _G.WARGON.add_recipe('tp_pack_crab',
	{cutreeds=12, rope=2, lobster=1}, 'sur', 's_2')
set_img(pack_crab, "backpack_crab")
pack_crab.wargon_test = tech_prince_test

local pack_dragonfly = _G.WARGON.add_recipe('tp_pack_dragonfly',
	{cutreeds=12, rope=2, dragon_scales=1}, 'sur', 's_2')
set_img(pack_dragonfly, "backpack_dragonfly")
pack_dragonfly.wargon_test = tech_prince_test

local pack_rabbit = _G.WARGON.add_recipe('tp_pack_rabbit',
	{cutreeds=12, rope=2, rabbit=4}, 'sur', 's_2')
set_img(pack_rabbit, "backpack_rabbit")
pack_rabbit.wargon_test = tech_prince_test

local mp_sp = _G.WARGON.add_recipe('morph_sp', {san=5}, "mag", "none")
mp_sp.atlas = "minimap/minimap_data.xml"
mp_sp.image = "wilson.png"

local tent = _G.WARGON.add_recipe('tp_tent', {silk=10, twigs=6, rope=4}, 
	'sur', 's_2', nil, nil, nil, "tp_tent_placer")
-- tent.atlas = "images/inventoryimages/tent_circus.xml"
-- tent.image = "tent_circus.tex"
set_img(tent, 'tent_circus')
tent.wargon_test = tech_prince_test

local egg = _G.WARGON.add_recipe('tp_bird_egg', 
	{tallbirdegg=1, bird_egg=1}, 'ref', 's_2')
-- egg.atlas = "images/inventoryimages_2.xml"
egg.image = "tallbirdegg.tex"
egg.wargon_test = mad_prince_test

local beefalo_sp = _G.WARGON.add_recipe('beefalo_sp', 
	{beefalowool=20, horn=2}, 'mag', 'none')
beefalo_sp.image = 'horn.tex'
beefalo_sp.wargon_test = mad_prince_test

local bf_sp = _G.WARGON.add_recipe('bigfoot_sp', {san=50}, "mag", "none")
bf_sp.image = "bell.tex"
bf_sp.wargon_test = mad_prince_test

local call_sp = _G.WARGON.add_recipe('callbeast_sp', {san=50}, 'mag', 'none')
call_sp.image = "panflute.tex"
call_sp.wargon_test = mad_prince_test

-- tree_line
local spear_wind = _G.WARGON.add_recipe('tp_spear_wind', 
	{
		tp_spear_lance={2, get_img('spear_forge_lance')}, 
		tp_gingko={20, get_img('tp_gingko')}
	}, 
	'war', 's_2')
set_img(spear_wind, "spear_rose")

local oak_armor = _G.WARGON.add_recipe('tp_oak_armor',
	{armorwood=2, tp_gingko={20, get_img('tp_gingko')} }, 'war', 's_2')
set_img(oak_armor, "armor_wood_haramaki")

local forest_gun = _G.WARGON.add_recipe('tp_forest_gun',
	{gears=5, gunpowder=5, tp_gingko={50, get_img('tp_gingko')} }, 'war', 's_2')
forest_gun.image = "blunderbuss.tex"

local war_seed = _G.WARGON.add_recipe('tp_war_tree_seed',
	{tp_gingko={2, get_img('tp_gingko')}, pinecone=2}, 'ref', 'm_3')
war_seed.image = "pinecone.tex"

local defense_seed = _G.WARGON.add_recipe('tp_defense_tree_seed',
	{tp_gingko={2, get_img('tp_gingko')}, acorn=2}, 'ref', 'm_3')
defense_seed.image = "acorn.tex"

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
		tp_alloy={1, get_img('tp_alloy')}, 
		greengem=1
	}, 'war', 's_2')
set_img(spear_poison, 'tp_spear_poison')

local spear_shadow = _G.WARGON.add_recipe('tp_spear_shadow',
	{
		tp_spear_gungnir={1, get_img('spear_forge_gungnir')}, 
		tp_alloy={1, get_img('tp_alloy')}, 
		yellowgem=1
	}, 'war', 's_2')
set_img(spear_shadow, 'tp_spear_shadow')

local spear_blood = _G.WARGON.add_recipe('tp_spear_blood',
	{
		tp_spear_gungnir={1, get_img('spear_forge_gungnir')}, 
		tp_alloy={1, get_img('tp_alloy')}, 
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
	}, 'war', 's_2', 'sw')
set_img(cutlass, "tp_cutlass")
--OBSIDIAN_BENCH
local smelter = _G.WARGON.add_recipe('tp_smelter', 
	{
		tp_alloy={1, get_img('tp_alloy')}, 
		redgem=2, goldnugget=10
	}, 
	'sci', 's_2', nil, nil, nil, "tp_smelter_placer")
-- smelter.image = "smelter.tex"
set_img(smelter, "tp_furnace")

-- pig_line
local pig_book = _G.WARGON.add_recipe('tp_pig_book', 
	{papyrus=4, nightmarefuel=4, pigskin=4}, 'mag', 'm_3')
set_img(pig_book, 'pig_book')
pig_book.wargon_test = pig_build_test

local pig_lamp = _G.WARGON.add_recipe('tp_pig_lamp', 
	{tarlamp=1, purplegem=4, obsidian=4}, 'mag', 'm_3', 'sw')
set_img(pig_lamp, 'pig_lamp')
pig_lamp.wargon_test = pig_build_test

local brave_amulet = _G.WARGON.add_recipe('tp_brave_amulet',
	{greenamulet=1, yellowamulet=1, orangeamulet=1}, 'anc', 'a_4', {'rog'})
set_img(brave_amulet, "amulet_red_occulteye")
brave_amulet.wargon_test = pig_build_test

local unreal_sword = _G.WARGON.add_recipe('tp_unreal_sword',
	{
		nightsword=1, purplegem=1,
		tp_pigking_hat={1, get_img('beefalohat_pigking')}, 
	}, 'mag', 'm_3')
set_img(unreal_sword, 'nightsword_sharp')
unreal_sword.wargon_test = pig_build_test

local chest = _G.WARGON.add_recipe('tp_chest', 
	{boards=3, nightmarefuel=9}, 'mag', 'm_3',
	nil, nil, nil, "tp_chest_placer")
chest.atlas = "images/inventoryimages/treasure_chest_sacred.xml"
chest.image = "treasure_chest_sacred.tex"
chest.wargon_test = pig_build_test

local chop_home = _G.WARGON.add_recipe('tp_chop_pig_home', 
	{boards=4, pigskin=4, axe=1}, 'far', 's_2',
	nil, nil, nil, "tp_chop_pig_home_placer")
set_img(chop_home, "pighouse_logcabin")
-- chop_home.image = "pighouse.tex"
chop_home.wargon_test = pig_build_test

local hack_home = _G.WARGON.add_recipe('tp_hack_pig_home', 
	{boards=4, pigskin=4, machete=1}, 'far', 's_2',
	nil, nil, nil, "tp_hack_pig_home_placer")
set_img(hack_home, "pighouse_logcabin")
-- hack_home.image = "pighouse.tex"
hack_home.wargon_test = pig_build_test

local farm_home = _G.WARGON.add_recipe('tp_farm_pig_home', 
	{boards=4, pigskin=4, fertilizer=1}, 'far', 's_2',
	nil, nil, nil, "tp_farm_pig_home_placer")
set_img(farm_home, "pighouse_logcabin")
-- farm_home.image = "pighouse.tex"
farm_home.wargon_test = pig_build_test
