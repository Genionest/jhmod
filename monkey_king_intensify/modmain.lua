GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
require "recipe"
if ( GLOBAL.IsDLCEnabled(3) ) then
	require "recipecategory"
end
PrefabFiles = {
	"forbid_scrolls",
	"monkey_beardhair",
	"mk_morph_fx",
	"nature_field",
}
Assets = {
	Asset("ATLAS", "images/inventoryimages/cold_forbid_scroll.xml"),
	Asset("ATLAS", "images/inventoryimages/fire_forbid_scroll.xml"),
	Asset("ATLAS", "images/inventoryimages/monkey_beardhair.xml"),
	Asset("ANIM", "anim/monkey_mana.zip"),
	Asset("ANIM", "anim/mk_skill_ui.zip"),
	-- Asset("ANIM", "anim/coolfield.zip"),
	-- Asset("ANIM", "anim/warmfield.zip"),
}
local names = STRINGS.NAMES
local desc = STRINGS.RECIPE_DESC
local generic = STRINGS.CHARACTERS.GENERIC.DESCRIBE
names.COLD_FORBID_SCROLL = "避寒决"
generic.COLD_FORBID_SCROLL = "避寒决"
names.FIRE_FORBID_SCROLL = "避火决"
generic.FIRE_FORBID_SCROLL = "避火决"
names.MONKEY_BEARDHAIR = "猴毛"
generic.MONKEY_BEARDHAIR = "菩萨与我的救命毫毛"

local language = GetModConfigData("language")
local else_enable = GetModConfigData("else_enable")

-- local function addMana(inst)
-- 	inst:AddComponent("monkeymana")
-- end

-- AddPrefabPostInit("monkey_king", addMana)

modimport "modimport/mk_mana.lua"
-- modimport "modimport/mk_morph.lua"
-- if else_enable then
-- modimport "modimport/mk_cloud.lua"
-- modimport "modimport/mk_monkey.lua"
-- modimport "modimport/mk_skill_ui.lua"
modimport "modimport/mk_add_skill.lua"
modimport "modimport/mk_fireeye.lua"
-- modimport "modimport/mk_forbid.lua"
modimport "modimport/mk_lunge.lua"
modimport "modimport/mk_sg.lua"
modimport "modimport/mk_wine.lua"
-- end