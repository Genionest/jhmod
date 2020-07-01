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

_G.WARGON.CHECK.check_need()
_G.WARGON.add_asset(Assets, "recharge_meter_wargon", "anim")
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
	tp_ash = {'威吊的粉末', '可以合成一些东西', nil},
	bigfoot_sp = {'脚来', nil, nil},
	morph_sp = {'变身', nil, nil},
	callbeast_sp = {'九牛二猪', nil, nil},
	tp_perd = {'威吊的火鸡', '快去干活', nil},
	tp_pig_fire = {'火焰猪人', '火焰果实的持有者', nil},
	tp_pig_ice = {'冰霜猪人', '冰霜果实的持有者', nil},
	tp_pig_poison = {'珺之猪人', '剧毒果实的持有者', nil},
	tp_spear_lance = {'威吊的战矛', '尝尝科学的威力', '把石头磨尖'},
	tp_spear_ice = {'冰矛', '这把矛带着魔力'},
	tp_spear_fire = {'火矛', '这把矛带着魔力'},
	tp_spear_thunder = {'雷矛', '这把矛带着魔力'},
	tp_spear_gungnir = {'威吊的战矛', '尝尝科学的威力', '把石头磨尖'},
	tp_spear_poison = {'毒矛', '这把矛带着魔力'},
	tp_spear_shadow = {'影矛', '这把矛带着魔力'},
	tp_spear_blood = {'血矛', '这把矛带着魔力'},
	tp_spear_wind = {'森林之息', '风起于青萍之末', '风之精灵为你助阵'},
	tp_strawhat = {'精灵草帽', '决定就是你了'},
	tp_strawhat2 = {'精灵草帽', '驯师的草帽'},
	tp_ballhat = {'橄榄球头盔', '给你看看他的真正用法', '就像橄榄球一样'},
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
	tp_gingko = {'银杏', '银杏'},
	tp_gingko_tree = {'银杏树', '银杏树'},
	tp_war_tree_seed = {'战争树种', '战争树种'},
	tp_war_tree = {'战争树', '战争树'},
	tp_defense_tree_seed = {'哨兵树种', '哨兵树种'},
	tp_defense_tree = {'哨兵树', '哨兵树'},
	tp_chop_pig = {'伐木猪', '伐木猪'},
	tp_hack_pig = {'砍工猪', '砍工猪'},
	tp_farm_pig = {'农场猪', '农场猪'},
	tp_chop_pig_home = {'伐木猪屋', '伐木猪屋'},
	tp_hack_pig_home = {'砍工猪屋', '砍工猪屋'},
	tp_farm_pig_home = {'农场猪屋', '农场猪屋'},
	tp_bird_egg = {'威吊的蛋', '放心吧，我不会吃你的'},
	tp_bird_egg_cracked = {'威吊的蛋', '小鸡快出来'},
	tp_small_bird = {'威吊的小高鸟', '跟着我'},
	tp_beefalo = {'威吊的牛', '骑骑'},
	tp_baby_beefalo = {'威吊的小牛', '它现在还不能骑'},
	tp_werepig_king = {'野猪王', '谁把他放出来了'},
	tp_pigking_hat = {'猪王帽子', '必须要有一位猪人王'},
	tp_sign_rider = {'路牌骑士', '小心她的路牌'},
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

local scroll_rec = {
	tentacle 	= {"tentaclespots", "s_3"},
	bird 		= {"bird_egg", "s_1"},
	lightning 	= {"redgem", "m_3"},
	sleep 		= {"nightmarefuel", "m_2"},
	grow 		= {"seeds", "s_1"},
	volcano 	= {"obsidian", "s_3"},
}
for i, v in pairs(scroll_rec) do
	local ingd = {papyrus=1, tp_ash=5}
	ingd[v[1]] = 1
	local rcp = _G.WARGON.add_recipe('scroll_'..i, ingd, 'mag', v[2])
	rcp.image = "papyrus.tex"
	rcp.wargon_test = tech_prince_test
end
local book_rec = {
	birds = "bird",
	gardening = "grow",
	sleep = "sleep",
	brimstone = "lightning",
	meteor = "volcano",
	tentacles = "tentacle",
}
for i, v in pairs(book_rec) do
	local ingd = {}
	local num = 5
	if v == "bird" then
		num = 3
	end
	ingd["scroll_"..v] = num
	local rcp = _G.WARGON.add_recipe('book_'..i, ingd, "ref", "none")
	rcp.wargon_test = mad_prince_test
end

local function set_img(rcp, atlas)
	rcp.atlas = "images/inventoryimages/"..atlas..".xml"
	rcp.image = atlas..".tex"
end

-- local ash = _G.WARGON.add_recipe('tp_ash', {ash=1, beardhair=1}, 'ref', 'none')
-- ash.image = "ash.tex"

local spear_lance = _G.WARGON.add_recipe('tp_spear_lance', {spear=1, rope=5}, 'war', 's_1')
set_img(spear_lance, "spear_forge_lance")

local spear_gungnir = _G.WARGON.add_recipe('tp_spear_gungnir', {spear=1, rope=5}, 'war', 's_1')
set_img(spear_gungnir, "spear_forge_gungnir")

local spear_wind = _G.WARGON.add_recipe('tp_spear_wind', {spear=1, rope=5}, 'war', 's_2')
set_img(spear_wind, "spear_rose")

local strawhat = _G.WARGON.add_recipe('tp_strawhat', {strawhat=1, rope=5}, 'dre', 'none')
set_img(strawhat, "strawhat_cowboy")

local ballhat = _G.WARGON.add_recipe('tp_ballhat', {footballhat=1, rope=5}, 'war', 's_2')
set_img(ballhat, "footballhat_combathelm")

local wood = _G.WARGON.add_recipe('tp_woodarmor', {armorwood=1, rope=10}, 'war', 's_2')
set_img(wood, "armor_wood_fangedcollar")

local ham = _G.WARGON.add_recipe('tp_hambat', {hambat=1, rope=5}, 'war', 's_2')
set_img(ham, "ham_bat_spiralcut")

local rocket = _G.WARGON.add_recipe('tp_rocket', {trinket_5=1, rope=5}, 'sci', 's_2')
rocket.image = 'trinket_5.tex'

local cane = _G.WARGON.add_recipe('tp_cane', {cane=1, rope=5}, 'dre', 's_2')
set_img(cane, "cane_ancient")

local ruinbat = _G.WARGON.add_recipe('tp_ruinbat', {ruins_bat=1, rope=5}, 'anc', 'a_4')
set_img(ruinbat, "ruins_bat_heavy")

local cutlass = _G.WARGON.add_recipe('tp_cutlass', {cutlass=1, rope=5}, 'war', 's_2')
set_img(cutlass, "nightsword_sharp")

local mp_sp = _G.WARGON.add_recipe('morph_sp', {san=5}, "mag", "none")
mp_sp.atlas = "minimap/minimap_data.xml"
mp_sp.image = "wilson.png"

local bf_sp = _G.WARGON.add_recipe('bigfoot_sp', {san=50}, "mag", "none")
bf_sp.image = "bell.tex"
bf_sp.wargon_test = mad_prince_test

local call_sp = _G.WARGON.add_recipe('callbeast_sp', {san=50}, 'mag', 'none')
call_sp.image = "panflute.tex"
call_sp.wargon_test = mad_prince_test

local tent = _G.WARGON.add_recipe('tp_tent', {silk=10, twigs=6, rope=4}, 'sur', 's_2', 
	nil, nil, nil, "tp_tent_placer")
tent.atlas = "images/inventoryimages/tent_circus.xml"
tent.image = "tent_circus.tex"
tent.wargon_test = tech_prince_test

local chest = _G.WARGON.add_recipe('tp_chest', {boards=3}, 'mag', 'm_3',
	nil, nil, nil, "tp_chest_placer")
chest.atlas = "images/inventoryimages/treasure_chest_sacred.xml"
chest.image = "treasure_chest_sacred.tex"
chest.wargon_test = tech_prince_test

local chop_home = _G.WARGON.add_recipe('tp_chop_pig_home', {boards=4}, 'far', 's_2',
	nil, nil, nil, "tp_chop_pig_home_placer")
chop_home.image = "pighouse.tex"

local hack_home = _G.WARGON.add_recipe('tp_hack_pig_home', {boards=4}, 'far', 's_2',
	nil, nil, nil, "tp_hack_pig_home_placer")
hack_home.image = "pighouse.tex"

local farm_home = _G.WARGON.add_recipe('tp_farm_pig_home', {boards=4}, 'far', 's_2',
	nil, nil, nil, "tp_farm_pig_home_placer")
farm_home.image = "pighouse.tex"
--OBSIDIAN_BENCH
