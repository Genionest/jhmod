PrefabFiles = {
	"tp_items",
	"tp_spear",
	"tp_proj",
	"tp_projectile",
	"tp_ruinbat",
	"scrolls",
	"scrolls_pig",
	"tp_builder",
	"tp_char",
	"tp_structure",
	"tp_tree",
	"tp_tree_seed",
	"tp_pet",
	"tp_unreal_wilson",
	"tp_pig_spirit",
	"tp_pig_worker",
	"tp_pig_home",
	"tp_werepig_king",
	"tp_sign_rider",
	"tp_smelter",
	"tp_cook_pot",
	"tp_pack",
	"tp_raft",
	"tp_reporter",
	"tp_warg",
	"tp_thumper",
	"tp_blueprint",
	"tp_tree_elf",
	"tp_desk",
	"tp_leif",
	"tp_bench",
	"tp_fake_knight",
	"tp_hornet",
	"tp_combat_lord",
	"tp_fool_spider",
	"tp_soul_student",
	"tp_lab",
	"tp_potion",
	"tp_armor",
	"tp_hat",
	"tp_warg_rider",
	"tp_pet_leader",
	-------------------------
	"tp_fx",
	"tp_sparkle_fx",
	"tp_snow_fx",
	"tp_shadow_fx",
	"tp_blood_fx",
	"tp_bat_fx",
	"tp_spirit_fx",
	"tp_thunder_fx",
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
_G.WARGON.version = "v1.103"
-----------------------------------------------
-- _L = _G.WARGON.get_config("language")
-- _G.WARGON.CONFIG = {
-- 	lan 	= WARGON.get_config("language"),
-- 	diff 	= WARGON.get_config("difficulty"),
-- }
-----------------------------------------------
modimport("modimport/entity_ex.lua")
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
-- language
-- if not _L then
-- 	STRINGS.CHARACTER_DESCRIPTIONS.wilson = "虚假的科学家,只会长胡子\n真正的科学家,还不如虚假的科学家"
-- 	STRINGS.CHARACTER_QUOTES.wilson = "\"那个男人,他回来了\""
-- 	STRINGS.CHARACTER_TITLES.wilson = "真正的科学家"
-- end
modimport("main/tp_config.lua")
_L = _G.WARGON.CONFIG.lan
modimport("main/tp_string.lua")
local other_strs = _L and _G.WARGON.STRING.en_other_strs or _G.WARGON.STRING.cn_other_strs
local game_strs = _L and _G.WARGON.STRING.en_strs or _G.WARGON.STRING.cn_strs
STRINGS.TP_STR = other_strs
for k, v in pairs(game_strs) do
	_G.WARGON.add_str(k, v[1], v[2], v[3])
end
-----------------------------------------------
modimport("main/tp_util.lua")
modimport("main/tp_data.lua")
modimport("main/tp_data_composed.lua")
modimport("main/tp_data_check.lua")
modimport("main/tp_data_sale.lua")
modimport("main/tp_data_buff.lua")
modimport("main/tp_data_update.lua")
modimport("main/tp_data_teach.lua")
modimport("main/tp_data_level.lua")
modimport("main/tp_builder.lua")
modimport("main/tp_scroll.lua")
modimport("main/tp_prefab.lua")
modimport("main/tp_sg.lua")
modimport("main/tp_action.lua")
modimport("main/tp_class.lua")
modimport("main/tp_component.lua")
modimport("main/tp_tuning.lua")
modimport("main/tp_mode_difficulty.lua")
modimport("main/tp_mode_fast.lua")
modimport("main/tp_check_asset.lua")
modimport("main/tp_check_skin.lua")

-- _G.WARGON.CHECK.check_need()
-- _G.TP_SKIN_HAD = _G.WARGON.CHECK.check_skin()

local scroll_assets = {
	"bird",
	"lightning",
	"sleep",
	"tentacle",
	"volcano",
	"grow",
	"wind",
	"pigman",
	"bunnyman",
	"shadow",
	"harvest",
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
	"lightning",
	"speed",
	"earth",
	"shine",
	"bag",
	"beefalo",
	"combat",
	"diamond",
	"gold",
	"tornado",
	"conqueror",
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
	"tp_octopus",
	"tp_thumper",
	"tp_epic",
	"tp_egg_tool",
	"tp_desk",
	"tp_lab",
	"tp_armor_cool",
	"tp_armor_warm",
	"tp_armor_health",
	"tp_armor_thunder",
	"tp_armor_firm",
	"tp_hat_warm",
	"tp_hat_cool",
	"tp_hat_health",
	"tp_hat_antitoxin",
	"tp_shadow_statue",
	"tp_fix_powder",
}
for i, v in pairs(item_assets) do
	_G.WARGON.add_asset(Assets, v, "anim")
	_G.WARGON.add_asset(Assets, "inventoryimages/"..v, "atlas")
end
-- local a_t = _G.WARGON.CHECK.check_asset()
-- if not a_t.wortox then
-- 	_G.WARGON.add_asset(Assets, "wortox_soul_heal_fx", "anim")
-- end
for k, v in pairs(_G.WARGON.NEED_ASSETS) do
	for k2, v2 in pairs(v) do
		_G.WARGON.add_asset(Assets, v2[1], v2[2])
	end
end
_G.WARGON.add_asset(Assets, "wathgrithr", "anim")
_G.WARGON.add_asset(Assets, "recharge_meter_wargon", "anim")
_G.WARGON.add_asset(Assets, "player_lunge_wargon", "anim")  -- lunge
_G.WARGON.add_asset(Assets, "player_attack_leap_wargon", "anim")  -- jump
-- _G.WARGON.add_asset(Assets, "player_attack_prop", "anim")  -- defense
_G.WARGON.add_asset(Assets, "player_multithrust", "anim")  -- sting
_G.WARGON.add_asset(Assets, "player_superjump", "anim")  -- super jump
_G.WARGON.add_asset(Assets, "tp_blue_warg", 'anim')
_G.WARGON.add_asset(Assets, "tp_red_warg", "anim")
_G.WARGON.add_asset(Assets, "tp_spore", "anim")
_G.WARGON.add_asset(Assets, "tp_spore_blue", "anim")
_G.WARGON.add_asset(Assets, "tp_teen_bird", "anim")
_G.WARGON.add_asset(Assets, "tp_small_bird", "anim")
_G.WARGON.add_asset(Assets, "tp_has_item", 'anim')
_G.WARGON.add_asset(Assets, "tp_strawhat_trap", "anim")
_G.WARGON.add_asset(Assets, "tp_strawhat", 'anim')
_G.WARGON.add_asset(Assets, "swap_forest_gun", 'anim')
_G.WARGON.add_asset(Assets, "swap_spear_wind", 'anim')
_G.WARGON.add_asset(Assets, "tp_spear_lance", 'anim')
_G.WARGON.add_asset(Assets, "waxwell", 'anim')
_G.WARGON.add_asset(Assets, "wickerbottom", 'anim')
_G.WARGON.add_asset(Assets, "oasis_tile", 'anim')
_G.WARGON.add_asset(Assets, "tp_potion", 'anim')
_G.WARGON.add_asset(Assets, "tp_potion_2", 'anim')
_G.WARGON.add_asset(Assets, "tp_plantable", 'anim')
------------------------------------
_G.WARGON.add_asset(Assets, "inventoryimages/tp_war_tree_spaling", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_defense_tree_spaling", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_grass_pigking", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_armor_broken", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_moon_lake", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_brave_small", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_health_small", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_sanity_small", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_warth", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_crazy", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_shine", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_dry", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_iron", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_shadow", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_killer", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_metal", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_smell", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_cool", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_warm", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_detoxify", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_potion_horror", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_deerclops_ice_statue", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_dragonfly_ice_statue", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_bearger_ice_statue", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_moose_ice_statue", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_plantable_reeds", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_plantable_mangrove", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_plantable_flower_cave", 'atlas')
_G.WARGON.add_asset(Assets, "inventoryimages/tp_plantable_grass_water", 'atlas')
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
_G.WARGON.add_map('inventoryimages/backpack_hound')
_G.WARGON.add_map('inventoryimages/backcub')
_G.WARGON.add_map('inventoryimages/backpack_deerclops')
_G.WARGON.add_map('inventoryimages/giantsfoot')
_G.WARGON.add_map('inventoryimages/strawhat_cowboy')
_G.WARGON.add_map('inventoryimages/tp_thumper')
_G.WARGON.add_map('inventoryimages/tp_desk')
_G.WARGON.add_map('inventoryimages/tp_epic')
_G.WARGON.add_map('inventoryimages/tp_moon_lake')
_G.WARGON.add_map('inventoryimages/tp_lab')
_G.WARGON.add_map('inventoryimages/birdcage_curly')
_G.WARGON.add_map('inventoryimages/tp_shadow_statue')
_G.WARGON.add_map('inventoryimages/tp_deerclops_ice_statue')
_G.WARGON.add_map('inventoryimages/tp_moose_ice_statue')
_G.WARGON.add_map('inventoryimages/tp_bearger_ice_statue')
_G.WARGON.add_map('inventoryimages/tp_dragonfly_ice_statue')

-- _G.WARGON.add_recipe(name, ingd, tab, tech, game, atlas, img, placer)
local function tech_prince_test(inst)
	return inst:HasTag("tech_prince")
end
local function mad_prince_test(inst)
	return inst:HasTag("mad_prince")
end

local function set_pig_test(rcp)
	-- rcp.tp_tech = "pigking"
	rcp.wargon_test = function(inst)
		return inst.components.inventory:Has("tp_grass_pigking", 1)
	end
end

local function set_pig_test2(rcp)
	rcp.wargon_test = function(inst)
		local pigking = c_find('pigking')
		if pigking then
			return inst:IsNear(pigking, 4)
		end
	end
end

local function set_octopus_test(rcp)
	-- rcp.tp_tech = "octopus"
	rcp.wargon_test = function(inst)
		return inst.components.inventory:Has("tp_octopus", 1)
	end
end

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
local mp_sp = _G.WARGON.add_recipe('morph_sp', {san=0}, rtb, "none")
mp_sp.atlas = "minimap/minimap_data.xml"
mp_sp.image = "wilson.png"

local strawhat = _G.WARGON.add_recipe('tp_strawhat', 
{cutgrass=9, rope=1}, rtb, 'none')
set_img(strawhat, "strawhat_cowboy")

local rocket = _G.WARGON.add_recipe('tp_rocket', 
{cutgrass=5, twigs=1, gunpowder=1}, rtb, 'none')
set_img(rocket, "tp_flare")

local transport_plane = _G.WARGON.add_recipe('tp_transport_plane',
{twigs=1}, rtb, 'none')
transport_plane.image = "trinket_5.tex"

local thumper = _G.WARGON.add_recipe('tp_thumper',
{boards=3, cutstone=1, transistor=1}, rtb, 'lost', 
nil, "tp_thumper_placer")
set_img(thumper, 'tp_thumper')

local egg_tool = _G.WARGON.add_recipe('tp_egg_tool',
{rocks=1, ash=2}, rtb, 'lost')
set_img(egg_tool, 'tp_egg_tool')

local farm_pile = _G.WARGON.add_recipe('tp_farm_pile',
{fertilizer=1}, rtb, 'lost', nil, "tp_farm_pile_placer")
farm_pile.image = "fertilizer.tex"

local tent = _G.WARGON.add_recipe('tp_tent', {silk=10, twigs=6, rope=4}, 
rtb, 's_2', nil, "tp_tent_placer")
set_img(tent, 'tent_circus')
tent.wargon_test = tech_prince_test
tent.tp_pot_structure = true

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

local bf_sp = _G.WARGON.add_recipe('bigfoot_sp', {san=50}, rtb, "none")
bf_sp.image = "bell.tex"
bf_sp.wargon_test = mad_prince_test

local call_sp = _G.WARGON.add_recipe('callbeast_sp', {san=50}, rtb, 'none')
call_sp.image = "panflute.tex"
call_sp.wargon_test = mad_prince_test

local raft = _G.WARGON.add_recipe("tp_raft", 
	{lotus=1},
-- {log=6, cutgrass=4},
rtb, "none", {"sw", "ham"}, "tp_raft_placer", true)
-- raft.image = "lograft.tex"
raft.atlas = "minimap/minimap_data.xml"
raft.image = "lily_pad.png"
set_octopus_test(raft)

-- war_line
--OBSIDIAN_BENCH
local smelter = _G.WARGON.add_recipe('tp_smelter', 
{
tp_alloy={1, get_img('tp_alloy')}, 
	redgem=2, goldnugget=10
}, 
rtb, 'none', nil, "tp_smelter_placer")
set_img(smelter, "tp_furnace")

local tp_desk = _G.WARGON.add_recipe('tp_desk', 
{boards=4}, rtb, 'lost', nil, 'tp_desk_placer')
set_img(tp_desk, 'tp_desk')
-- set_pig_test(tp_desk)

local bench = _G.WARGON.add_recipe('tp_bench',
{
	tp_alloy={1, get_img('tp_alloy')}, 
	-- redgem=2, goldnugget=10
	obsidian=2, 
}, rtb, 'lost', nil, 'tp_bench_placer')
bench.atlas = "minimap/minimap_data.xml"
bench.image = "workbench_obsidian.png" 

local tp_lab = _G.WARGON.add_recipe('tp_lab',
{
	tp_alloy={1, get_img('tp_alloy')},
	goldnugget=4, boards=2,
}, rtb, 'lost', nil, 'tp_lab_placer')
set_img(tp_lab, 'tp_lab')

local dragon_cage = _G.WARGON.add_recipe("tp_dragon_cage",
{
	tp_alloy = {2, get_img('tp_alloy')},
	goldnugget=2, dragon_scales=1,
}, rtb, 'lost', nil, 'tp_dragon_cage_placer')
set_img(dragon_cage, 'birdcage_curly')

local dragonfly_statue = _G.WARGON.add_recipe(
"tp_dragonfly_ice_statue",
{
	dragon_scales = 1,
	ice = 8,
	meat = 8,
}, rtb, 'lost', nil, 'tp_dragonfly_ice_statue_placer')
set_img(dragonfly_statue, "tp_dragonfly_ice_statue")

local moose_statue = _G.WARGON.add_recipe(
"tp_moose_ice_statue",
{
	goose_feather = 5,
	ice = 8,
	meat = 8,
}, rtb, 'lost', nil, 'tp_moose_ice_statue_placer')
set_img(moose_statue, "tp_moose_ice_statue")
	
local bearger_statue = _G.WARGON.add_recipe(
"tp_bearger_ice_statue",
{
	bearger_fur = 1,
	ice = 8,
	meat = 8,
}, rtb, 'lost', nil, 'tp_bearger_ice_statue_placer')
set_img(bearger_statue, "tp_bearger_ice_statue")
	
local deerclops_statue = _G.WARGON.add_recipe(
"tp_deerclops_ice_statue",
{
	deerclops_eyeball = 1,
	ice = 8,
	meat = 8,
}, rtb, 'lost', nil, 'tp_deerclops_ice_statue_placer')
set_img(deerclops_statue, "tp_deerclops_ice_statue")

local chop_home = _G.WARGON.add_recipe('tp_chop_pig_home', 
{boards=4, pigskin=4, axe=1}, rtb, 'lost',
nil, "tp_chop_pig_home_placer")
set_img(chop_home, "pighouse_logcabin")
-- set_pig_test(chop_home)

local hack_home = _G.WARGON.add_recipe('tp_hack_pig_home', 
{boards=4, pigskin=4, machete=1}, rtb, 'lost',
nil, "tp_hack_pig_home_placer")
set_img(hack_home, "pighouse_logcabin")
-- set_pig_test(hack_home)

local farm_home = _G.WARGON.add_recipe('tp_farm_pig_home', 
{boards=4, pigskin=4, fertilizer=1}, rtb, 'lost',
nil, "tp_farm_pig_home_placer")
set_img(farm_home, "pighouse_logcabin")
-- set_pig_test(farm_home)

-- local egg = _G.WARGON.add_recipe('tp_bird_egg', 
-- {tallbirdegg=5, bird_egg=1}, rtb, 's_2')
-- egg.image = "tallbirdegg.tex"
-- egg.wargon_test = mad_prince_test

-- local intro_book = _G.WARGON.add_recipe("tp_intro",
-- 	{papyrus=2}, rtb, "none")
-- intro_book.image = "book_meteor.tex"

-- local reeds = _G.WARGON.add_recipe("reeds", 
-- {cutreeds=10, dug_grass=1}, rtb, "none", nil,
-- "tp_reeds_placer")
-- reeds.atlas = "minimap/minimap_data.xml"
-- reeds.image = "reeds.png"

-- local flower_cave = _G.WARGON.add_recipe("flower_cave",
-- {lightbulb=15, butterfly=1, foliage=5}, rtb, "none", nil,
-- "tp_flower_cave_placer")
-- flower_cave.atlas = "minimap/minimap_data.xml"
-- flower_cave.image = "bulb_plant.png"

-- local grass = _G.WARGON.add_recipe("grass_water", {dug_grass=1, poop=1}, 
-- rtb, 'none', {"sw", "ham"}, 'tp_grass_water_placer', true)
-- grass.atlas = "minimap/minimap_data.xml"
-- grass.image = "grassGreen.png"
-- set_octopus_test(grass)

-- local mangrove = _G.WARGON.add_recipe('mangrovetree_normal', 
-- {twigs=2, poop=1}, rtb, 'none', {'sw', 'ham'},
-- 'tp_mangrovetree_normal_placer', true)
-- mangrove.atlas = "minimap/minimap_data.xml"
-- mangrove.image = "mangrove.png"
-- set_octopus_test(mangrove)

-- local update_book = _G.WARGON.add_recipe("tp_update", 
-- 	{papyrus=2}, rtb, "none")
-- update_book.image = "book_brimstone.tex"

-- local spear_lance = _G.WARGON.add_recipe('tp_spear_lance', 
-- 	{twigs=2, rope=1, goldnugget=1}, rtb, 's_1')
-- set_img(spear_lance, "spear_forge_lance")

-- local spear_gungnir = _G.WARGON.add_recipe('tp_spear_gungnir', 
-- 	{twigs=2, rope=1, goldnugget=1}, rtb, 's_1')
-- set_img(spear_gungnir, "spear_forge_gungnir")

-- local ham = _G.WARGON.add_recipe('tp_hambat', 
-- 	{pigskin=1, twigs=2, meat=3}, rtb, 's_2')
-- set_img(ham, "ham_bat_spiralcut")

-- local wood = _G.WARGON.add_recipe('tp_woodarmor', 
-- 	{log=8, rope=2, houndstooth=2}, rtb, 's_2')
-- set_img(wood, "armor_wood_fangedcollar")

-- local cane = _G.WARGON.add_recipe('tp_cane', 
-- 	{cane=1, thulecite_pieces=5, rope=1}, rtb, 's_2')
-- set_img(cane, "cane_ancient")
-- cane.wargon_test = tech_prince_test

-- local staff_trinity = _G.WARGON.add_recipe('tp_staff_trinity',
-- 	{spear=1, redgem=1, bluegem=1}, rtb, 'm_2')
-- set_img(staff_trinity, "spear_bee")
-- staff_trinity.wargon_test = tech_prince_test

-- local pack_crab = _G.WARGON.add_recipe('tp_pack_crab',
-- 	{papyrus=2, rope=1, lobster=1}, rtb, 's_1')
-- set_img(pack_crab, "backpack_crab")
-- pack_crab.wargon_test = tech_prince_test

-- local pack_rabbit = _G.WARGON.add_recipe('tp_pack_rabbit',
-- 	{papyrus=2, rope=1, manrabbit_tail=4}, rtb, 's_1')
-- set_img(pack_rabbit, "backpack_rabbit")
-- pack_rabbit.wargon_test = tech_prince_test

-- local pack_beefalo = _G.WARGON.add_recipe('tp_pack_beefalo',
-- 	{papyrus=2, rope=1, beefalowool=6}, rtb, 's_1')
-- set_img(pack_beefalo, 'backpack_beefalo')
-- pack_beefalo.wargon_test = tech_prince_test

-- local pack_catcoon = _G.WARGON.add_recipe('tp_pack_catcoon',
-- 	{papyrus=2, rope=1, coontail=4}, rtb, 's_1')
-- set_img(pack_catcoon, 'backpack_catcoon')
-- pack_catcoon.wargon_test = tech_prince_test

-- local pack_hound = _G.WARGON.add_recipe('tp_pack_hound',
-- 	{papyrus=2, rope=1, houndstooth=10}, rtb, 's_1')
-- set_img(pack_hound, 'backpack_hound')
-- pack_hound.wargon_test = tech_prince_test

-- local pack_dragonfly = _G.WARGON.add_recipe('tp_pack_dragonfly',
-- 	{papyrus=2, rope=1, dragon_scales=1}, rtb, 's_1')
-- set_img(pack_dragonfly, "backpack_dragonfly")
-- pack_dragonfly.wargon_test = tech_prince_test

-- local pack_bearger = _G.WARGON.add_recipe('tp_pack_bearger',
-- 	{papyrus=2, rope=1, bearger_fur=1}, rtb, 's_1')
-- set_img(pack_bearger, 'backcub')
-- pack_bearger.wargon_test = tech_prince_test

-- local pack_deerclops = _G.WARGON.add_recipe('tp_pack_deerclops',
-- 	{papyrus=2, rope=1, deerclops_eyeball=1}, rtb, 's_1')
-- set_img(pack_deerclops, 'backpack_deerclops')
-- pack_deerclops.wargon_test = tech_prince_test

-- local pack_giant = _G.WARGON.add_recipe('tp_pack_giant',
-- 	{papyrus=2, rope=1, bell=1}, rtb, 's_1')
-- set_img(pack_giant, 'giantsfoot')
-- pack_giant.wargon_test = tech_prince_test

-- local scroll_rec = {
-- 	tentacle 	= {"tentaclespots", 1, "s_3"},
-- 	bird 		= {"feather_robin", 1, "s_1"},
-- 	lightning 	= {"redgem", 1, "m_3"},
-- 	sleep 		= {"nightmarefuel", 1, "m_2"},
-- 	grow 		= {"seeds", 1, "s_1"},
-- 	volcano 	= {"obsidian", 1, "s_3"},
-- }
-- create_scroll_rec(scroll_rec)
-- local scroll_pig_rec = {
-- 	-- pig_leader 	= {'meat', 1, "none"},
-- 	pig_armor 	= {"footballhat", 1, "none"},
-- 	pig_armorex = {"armorwood", 1, "none"},
-- 	pig_speed  	= {"coffeebeans", 1, "none"},
-- 	pig_damage  = {"hambat", 1, "none"},
-- 	pig_heal	= {"bandage", 1, "none"},
-- 	pig_teleport= {"butterflywings", 1, "none"},
-- 	pig_health 	= {"dragonfruit", 1, 'none'},
-- }
-- create_scroll_rec(scroll_pig_rec)

-- local beefalo_sp = _G.WARGON.add_recipe('beefalo_sp', 
-- 	{beefalowool=20, horn=2}, 'mag', 'none')
-- beefalo_sp.image = 'horn.tex'
-- beefalo_sp.wargon_test = mad_prince_test

-- sw
-- local octopus = _G.WARGON.add_recipe("tp_octopus",
-- 	{fabric=4, rope=1, coral=4}, 'ref', 'none')
-- set_img(octopus, 'tp_octopus')
-- set_octopus_test(octopus)

-- tree_line
-- local gingko_spaling = _G.WARGON.add_recipe('tp_gingko_spaling',
-- 	{tp_gingko_leaf={1, get_img('tp_gingko_leaf')}, poop=1}, 
-- 	rtb, 's_2', nil, "tp_gingko_spaling_placer")
-- set_img(gingko_spaling, 'tp_gingko_spaling')

-- local war_spaling = _G.WARGON.add_recipe('tp_war_tree_spaling',
-- 	{tp_gingko_leaf={2, get_img('tp_gingko_leaf')}, poop=1}, 
-- 	rtb, 's_2', nil, 'tp_war_tree_spaling_placer')
-- set_img(war_spaling, 'tp_war_tree_spaling')

-- local defense_spaling = _G.WARGON.add_recipe('tp_defense_tree_spaling',
-- 	{tp_gingko_leaf={3, get_img('tp_gingko_leaf')}, poop=1}, 
-- 	rtb, 's_2', nil, 'tp_defense_tree_spaling_placer')
-- set_img(defense_spaling, 'tp_defense_tree_spaling')

-- local life_spaling = _G.WARGON.add_recipe('tp_life_tree_spaling',
-- 	{tp_gingko_leaf={4, get_img('tp_gingko_leaf')}, poop=1}, 
-- 	rtb, 's_2', nil, 'tp_life_tree_spaling_placer')
-- set_img(life_spaling, 'tp_war_tree_spaling')

-- local gingko = _G.WARGON.add_recipe('tp_gingko', 
-- 	{tp_gingko_leaf={1, get_img('tp_gingko_leaf')}, poop=1},
-- 	rtb, 'none')
-- set_img(gingko, "tp_gingko_spaling")

-- local war_seed = _G.WARGON.add_recipe('tp_war_tree_seed',
-- 	{tp_gingko_leaf={2, get_img('tp_gingko_leaf')}, poop=1},
-- 	rtb, 'none')
-- set_img(war_seed, "tp_war_tree_spaling")

-- local defense_seed = _G.WARGON.add_recipe('tp_defense_tree_seed',
-- 	{tp_gingko_leaf={2, get_img('tp_gingko_leaf')}, poop=1},
-- 	rtb, 'none')
-- set_img(defense_seed, "tp_defense_tree_spaling")

-- local life_seed = _G.WARGON.add_recipe('tp_life_tree_seed',
-- 	{tp_gingko_leaf={2, get_img('tp_gingko_leaf')}, poop=1},
-- 	rtb, 'none')
-- set_img(life_seed, "tp_war_tree_spaling")

-- local spear_wind = _G.WARGON.add_recipe('tp_spear_wind', 
-- 	{
-- 		tp_spear_lance={1, get_img('spear_forge_lance')}, 
-- 		tp_gingko_leaf={6, get_img('tp_gingko_leaf')}
-- 	}, 
-- 	rtb, 's_2')
-- set_img(spear_wind, "tp_spear_wind")

-- local oak_armor = _G.WARGON.add_recipe('tp_oak_armor',
-- 	{armorwood=1, tp_gingko_leaf={6, get_img('tp_gingko_leaf')} }, 
-- 	rtb, 's_2')
-- set_img(oak_armor, "armor_wood_haramaki")

-- local forest_gun = _G.WARGON.add_recipe('tp_forest_gun',
-- 	{gears=5, gunpowder=5, tp_gingko_leaf={20, get_img('tp_gingko_leaf')} }, 
-- 	rtb, 's_2')
-- set_img(forest_gun, "tp_forest_gun")

-- local war_seed = _G.WARGON.add_recipe('tp_war_tree_seed',
-- 	{tp_gingko_leaf={2, get_img('tp_gingko_leaf')}, pinecone=2}, 'ref', 'm_3')
-- war_seed.image = "pinecone.tex"

-- local defense_seed = _G.WARGON.add_recipe('tp_defense_tree_seed',
-- 	{tp_gingko_leaf={2, get_img('tp_gingko_leaf')}, acorn=2}, 'ref', 'm_3')
-- defense_seed.image = "acorn.tex"

-- local ballhat = _G.WARGON.add_recipe('tp_ballhat', 
-- 	{pigskin=1, rope=2, tp_alloy={1, get_img('tp_alloy')} }, rtb, 's_2')
-- set_img(ballhat, "footballhat_combathelm")
-- ballhat.wargon_test = tech_prince_test

-- local spear_ice = _G.WARGON.add_recipe('tp_spear_ice', 
-- 	{
-- 		tp_spear_lance={1, get_img('spear_forge_lance')}, 
-- 		tp_alloy={1, get_img('tp_alloy')}, 
-- 		bluegem=1
-- 	}, rtb, 's_2')
-- set_img(spear_ice, 'tp_spear_ice')

-- local spear_fire = _G.WARGON.add_recipe('tp_spear_fire',
-- 	{
-- 		tp_spear_lance={1, get_img('spear_forge_lance')}, 
-- 		tp_alloy={1, get_img('tp_alloy')}, 
-- 		redgem=1
-- 	}, rtb, 's_2')
-- set_img(spear_fire, 'tp_spear_fire')

-- local spear_thunder = _G.WARGON.add_recipe('tp_spear_thunder',
-- 	{
-- 		tp_spear_lance={1, get_img('spear_forge_lance')}, 
-- 		tp_alloy={1, get_img('tp_alloy')}, 
-- 		purplegem=1
-- 	}, rtb, 's_2')
-- set_img(spear_thunder, 'tp_spear_thunder')

-- local spear_poison = _G.WARGON.add_recipe('tp_spear_poison',
-- 	{
-- 		tp_spear_gungnir={1, get_img('spear_forge_gungnir')}, 
-- 		tp_alloy={3, get_img('tp_alloy')}, 
-- 		greengem=1
-- 	}, rtb, 's_2')
-- set_img(spear_poison, 'tp_spear_poison')

-- local spear_shadow = _G.WARGON.add_recipe('tp_spear_shadow',
-- 	{
-- 		tp_spear_gungnir={1, get_img('spear_forge_gungnir')}, 
-- 		tp_alloy={3, get_img('tp_alloy')}, 
-- 		yellowgem=1
-- 	}, rtb, 's_2')
-- set_img(spear_shadow, 'tp_spear_shadow')

-- local spear_blood = _G.WARGON.add_recipe('tp_spear_blood',
-- 	{
-- 		tp_spear_gungnir={1, get_img('spear_forge_gungnir')}, 
-- 		tp_alloy={3, get_img('tp_alloy')}, 
-- 		orangegem=1
-- 	}, rtb, 's_2')
-- set_img(spear_blood, 'tp_spear_blood')

-- local ruinbat = _G.WARGON.add_recipe('tp_ruinbat', 
-- 	{	
-- 		thulecite=4, livinglog=3, 
-- 		tp_alloy={3, get_img('tp_alloy')} 
-- 	}, rtb, 'a_4', nil)
-- set_img(ruinbat, "ruins_bat_heavy")

-- local cutlass = _G.WARGON.add_recipe('tp_cutlass', 
-- 	{
-- 		dead_swordfish=1, goldnugget=2,
-- 		tp_alloy={3, get_img('tp_alloy')} 
-- 	}, rtb, 's_2')
-- set_img(cutlass, "tp_cutlass")

-- pig_line
-- local grass_pigking = _G.WARGON.add_recipe('tp_grass_pigking',
-- 	{cutgrass=20, rope=2, pigskin=4}, rtb, 'none')
-- set_img(grass_pigking, 'tp_grass_pigking')
-- set_pig_test2(grass_pigking)

-- local shadow_statue = _G.WARGON.add_recipe("tp_shadow_statue",
-- 	{
-- 		tp_alloy = {2, get_img("tp_alloy")},
-- 		thulecite = 2,
-- 		nightmarefuel = 2,
-- 	}, rtb, 'lost', nil, 'tp_shadow_statue_placer')
-- set_img(shadow_statue, 'tp_shadow_statue')
-- local pig_book = _G.WARGON.add_recipe('tp_pig_book', 
-- 	{papyrus=4, nightmarefuel=4, pigskin=4}, rtb, 'none')
-- set_img(pig_book, 'pig_book')
-- set_pig_test(pig_book)

-- local pig_lamp = _G.WARGON.add_recipe('tp_pig_lamp', 
-- 	{tarlamp=1, purplegem=4, obsidian=4}, rtb, 'none')
-- set_img(pig_lamp, 'pig_lamp')
-- set_pig_test(pig_lamp)

-- local brave_amulet = _G.WARGON.add_recipe('tp_brave_amulet',
-- 	{greenamulet=1, yellowamulet=1, orangeamulet=1}, rtb, 'none')
-- set_img(brave_amulet, "amulet_red_occulteye")
-- set_pig_test(brave_amulet)

-- local unreal_sword = _G.WARGON.add_recipe('tp_unreal_sword',
-- 	{
-- 		nightmarefuel=5, purplegem=3,
-- 		minotaurhorn=1, 
-- 	}, rtb, 'none')
-- set_img(unreal_sword, 'nightsword_sharp')
-- set_pig_test(unreal_sword)

-- local chest = _G.WARGON.add_recipe('tp_chest', 
-- 	{boards=3, nightmarefuel=9}, rtb, 'lost',
-- 	nil, "tp_chest_placer")
-- chest.atlas = "images/inventoryimages/treasure_chest_sacred.xml"
-- chest.image = "treasure_chest_sacred.tex"
-- set_pig_test(chest)
		
-- local rider_sp = _G.WARGON.add_recipe('rider_sp',
-- 	{horn=1}, rtb, 'none')
-- rider_sp.image = "horn.tex"

end)
