local AssetUtil = require "extension/lib/asset_util"
local Info = Sample.Info

local AnimData = Class(function(self)
end)

--[[
动画处理类，用于设置动画，或返回设置动画所需的内容  
bank (string)对应scml里的动画群组  
build (string)对应scml的名字  
animation (string)对应scml里动画群组下的一个动画  
water (string)对应scml里动画群组下的一个动画，水中的动画
]]
local function Anim(bank, build, animation, water)
	local self = AnimData()
	assert(type(bank)=="string", "arguments \"bank\" must be string.")
	assert(type(build)=="string", "arguments \"build\" must be string.")
	assert(type(animation)=="string", "arguments \"animation\" must be string.")
	
	self.bank = bank
	self.build = build
	self.animation = animation
	self.water = water

	return self
end

function AnimData:GetAnimation(include_water)
    if include_water then
        return self.bank, self.build, self.animation, self.water
    else
        return self.bank, self.build, self.animation
    end
end

local ImgData = Class(function(self)
end)

--[[
图片路径处理类，用于返回图片资源路径  
atlas 图片资源1  
img 图片资源2  
no_resolve (bool)在获取时是否解析  
]]
local function Img(atlas, img, no_resolve)
	local self = ImgData()
	assert(atlas~=nil, "arguments \"atlas\" can't be nil.")
	self.resolved = no_resolve
	self.atlas = atlas
	self.image = img or atlas
	return self
end

function ImgData:GetImage(no_tex)
    if not self.resolved then
        self.resolved = true
        self.atlas, self.image = AssetUtil:ResolveImgPath(self.atlas, self.image)
    end
    local image = self.image
    if no_tex then
        image = string.sub(image, 1, -5)
    end
    return self.atlas, image
end

local SymbolData = Class(function(self)
end)

--[[
替换动画部件  
Usymbol (Symbol)动画部件替换处理类  
inst (EntityScript)需要进行替换的entity，对于UIAnim，可以传入widget.inst  
]]
local function Symbol(symbol, build, symbol2)
	local self = SymbolData()
	
	assert(type(symbol)=="string", "arguments \"symbol\" must be string.")
	assert(type(build)=="string", "arguments \"build\" must be string.")
	assert(type(symbol2)=="string", "arguments \"symbol2\" must be string.")
	
	self.symbol = symbol
	self.build = build
	self.symbol2 = symbol2

	return self
end

function SymbolData:GetSymbol()
    return self.symbol, self.build, self.symbol2
end

local AssetData = Class(function(self)
end)

--[[
资源数据，包含动画，图片，动画部件替换的资源  
name (string)所属物体名  
Uanim (Anim)动画处理类  
Uimg (Img)图片处理类  
Usymbol (Symbol)动画部件替换处理类  
map (string)地图图标  
DSassets (table{Asset})饥荒资源类列表  
replace (string)用于让AssetMaster用其他资源绑定本物体名  
]]
local function AssetPack(name, Uanim, Uimg, Usymbol, map, DSassets, replace)
	local self = AssetData()	
	self.name = name
	self.anim = Uanim
	self.img = Uimg
	self.symbol = Usymbol
	self.map = map
	self.DSassets = DSassets
	self.replace = replace

	return self
end

function AssetData:GetUimg()
	return self.img
end

function AssetData:__tostring()
	return string.format("AssetData(%s)", self.name)
end

--[[
资源管理者，集中管理AssetData  
]]
local AssetMaster = {
    assets = {},
	replace = {}
}

--[[
添加资源数据  
asset_data (AssetData)需要添加的资源数据
]]
function AssetMaster:AddAssetData(asset_data)
    local name = asset_data.name
    if asset_data.replace then
        -- 替代
		self.replace[name] = asset_data.replace
        -- local replace = asset_data.replace
        -- local replace_asset = self.assets[replace]
        -- assert(replace_asset, string.format("can't find AssetData named \"%s\" to replace AssetUtil.AssetData named \"%s\"", replace, name))
        -- self.assets[name] = replace_asset
    else
        self.assets[name] = asset_data
    end
end

--[[
获取对应物体名的资源数据  
(AssetData) 返回这个资源数据
]]
function AssetMaster:GetAssetData(name)
	if self.replace[name] then
		-- 替代
		return self:GetAssetData(self.replace[name])
	end
    local asset_data = self.assets[name]
    return asset_data
end

--[[
判断是否存在对应物体名的资源数据  
(bool) 返回bool  
]]
function AssetMaster:HasAssetData(name)
	local replace = self.replace[name]
	if replace then
		-- 替代
		return self.assets[replace] ~= nil
	end
	return self.assets[name] ~= nil
end

--[[
返回图片资源类  
(Img) Uimg  
name (string)资源名  
]]
function AssetMaster:GetUimg(name)
	local asset_data = self:GetAssetData(name)
    assert(asset_data~=nil, string.format("can't find AssetData named \"%s\"", name))

    local Uimg = asset_data.img
	assert(Uimg~=nil, string.format("AssetData named \"%s\" don't have attribute Uimg", name))
	return Uimg
end

--[[
返回设置动画需要的内容  
(string)bank, (string)build, (strsing)animation, (string/nil)water  
name (string)资源名  
include_water (bool)是否包含水中动画  
]]
function AssetMaster:GetAnimation(name, include_water)
    local asset_data = self:GetAssetData(name)
    assert(asset_data~=nil, string.format("can't find AssetData named \"%s\"", name))
    local Uanim = asset_data.anim
	assert(Uanim~=nil, string.format("AssetData named \"%s\" don't have attribute Uanim", name))
    return Uanim:GetAnimation(include_water)
end

--[[
获取图片资源路径    
(string)atlas, (string)image 返回这两个资源路径  
name (string)资源名  
no_tex (bool)返回的image是否包含.tex后缀  
]]
function AssetMaster:GetImage(name, no_tex)
    local asset_data = self:GetAssetData(name)
    assert(asset_data~=nil, string.format("can't find AssetData named \"%s\"", name))
    local Uimg = asset_data.img
	assert(Uimg~=nil, string.format("AssetData named \"%s\" don't have attribute Uimg", name))
    return Uimg:GetImage(no_tex)
end

--[[
获取动画替换需要的三个内容  
(string)symbol, (string)build, (string)symbol2  
name (string)资源名  
]]
function AssetMaster:GetSymbol(name)
    local asset_data = self:GetAssetData(name)
    assert(asset_data~=nil, string.format("can't find AssetData named \"%s\"", name))
    local Usymbol = asset_data.symbol
	assert(Usymbol~=nil, string.format("AssetData named \"%s\" don't have attribute Usymbol", name))
	return Usymbol:GetSymbol()
end

--[[
获取地图图标  
(string) 地图图标  
name (string)资源名  
]]
function AssetMaster:GetMap(name)
	local asset_data = self:GetAssetData(name)
    assert(asset_data~=nil, string.format("can't find AssetData named \"%s\"", name))
	local map = asset_data.map
	return map
end

--[[
获取资源列表  
(table{Asset}) 资源列表  
name (string)资源名  
]]
function AssetMaster:GetDSAssets(name)
	local asset_data = self:GetAssetData(name)
    assert(asset_data~=nil, string.format("can't find AssetData named \"%s\"", name))
	local DSassets = asset_data.DSassets
	if DSassets then
		assert(type(DSassets)=="table", string.format("DSassets of AssetData(%s) must be table or nil", name))
	else
		print(string.format("DSassets of AssetData(%s) is nil", name))
	end
	return DSassets
end

local assets = {
item = {
	AssetPack("log", 
		Anim("log", "log", "idle", "idle_water"),
		Img("log")
	),
    AssetPack("cane", 
        Anim("cane", "cane", "idle", "idle_water"),
        Img("cane"),
        Symbol("swap_object", "swap_cane", "swap_cane", "hands")
    ),
    AssetPack("batbat",
        Anim("batbat", "batbat", "idle", "idle_water"),
        Img("batbat"),
        Symbol("swap_object", "swap_batbat", "swap_batbat", "hands")
    ),
    AssetPack("axe",
        Anim("axe", "axe", "idle", "idle_water"),
        Img("axe"),
        Symbol("swap_object", "swap_axe", "swap_axe", "hands")
    ),
    AssetPack("pickaxe",
        Anim("pickaxe", "pickaxe", "idle", "idle_water"),
        Img("pickaxe"),
        Symbol("swap_object", "swap_pickaxe", "swap_pickaxe", "hands")
    ),
    AssetPack("hammer",
        Anim("hammer", "hammer", "idle", "idle_water"),
        Img("hammer"),
        Symbol("swap_object", "swap_hammer", "swap_hammer", "hands")
    ),
    AssetPack("shovel",
        Anim("shovel", "shovel", "idle", "idle_water"),
        Img("shovel"),
        Symbol("swap_object", "swap_shovel", "swap_shovel", "hands")
    ),
    AssetPack("machete",
        Anim("machete", "machete", "idle", "idle_water"),
        Img("machete"),
        Symbol("swap_object", "swap_machete", "swap_machete", "hands")
    ),
    AssetPack("bugnet",
        Anim("bugnet", "bugnet", "idle", "idle_water"),
        Img("bugnet"),
        Symbol("swap_object", "swap_bugnet", "swap_bugnet", "hands")
    ),
	AssetPack("nightsword",
		Anim("nightmaresword", "nightmaresword", "idle"), 
		Img("nightsword"), 
		Symbol("swap_object", "swap_nightmaresword", "swap_nightmaresword")
	),
    AssetPack("book_gardening",
        Anim("books", "books", "book_gardening", "book_gardening_water"),
        Img("book_gardening")
    ),
    AssetPack("tp_mult_tool", nil, nil, nil, nil, nil, "axe"),
    AssetPack("tp_alloy",
        Anim("tp_alloy", "tp_alloy", "idle", "idle_water"),
        Img("ak_items", "ak_alloy_blue"),
        nil,
        nil, 
        {
            Asset("ANIM", "anim/tp_alloy.zip"),
        }
    ),
	AssetPack("tp_alloy_red",
        Anim("tp_alloy_red", "tp_alloy_red", "idle", "idle_water"),
        Img("ak_items", "ak_alloy_red"),
        nil,
        nil, 
        {
            Asset("ANIM", "anim/tp_alloy_red.zip"),
        }
    ),
	AssetPack("tp_alloy_great",
        Anim("tp_alloy_great", "tp_alloy_great", "idle", "idle_water"),
        Img("ak_items", "ak_alloy_purple"),
        nil,
        nil, 
        {
            Asset("ANIM", "anim/tp_alloy_great.zip"),
        }
    ),
	AssetPack("tp_alloy_enchant",
        Anim("ak_platinum", "ak_platinum", "idle", "idle_water"),
        Img("ak_items", "ak_platinum"),
        nil,
        nil, 
        {
            Asset("ANIM", "anim/ak_platinum.zip"),
        }
    ),
    AssetPack("tp_hat_winter", 
        Anim("flowerhat", "flowerhat_holly_wreath", "anim", "idle_water"),
        Img("flowerhat_holly_wreath"),
        Symbol("swap_hat", "flowerhat_holly_wreath", "swap_hat", "head2")
    ),
    AssetPack("tp_hat_dodge", 
		Anim("flowerhat", "flowerhat_crown", "anim", "idle_water"),
		Img("flowerhat_crown"),
		Symbol("swap_hat", "flowerhat_crown", "swap_hat", "head2")
	),
	AssetPack("tp_hat_pigking", 
		Anim("beefalohat", "beefalohat_pigking", "anim", "idle_water"),
		Img("beefalohat_pigking"),
		Symbol("swap_hat", "beefalohat_pigking", "swap_hat", "head2")
	),
    AssetPack("ak_ssd", 
		Anim("ak_items", "ak_items", "ak_ssd"),
		Img("ak_items", "ak_ssd")
	),
    AssetPack("tp_epic", 
		Anim("sam_items", "sam_items", "tp_epic"),
		Img("sam_items", "tp_epic")
	),
	AssetPack("tp_epic_red", 
		Anim("sam_items", "sam_items", "tp_epic_red"),
		Img("sam_items", "tp_epic_red")
	),
    AssetPack("tp_advance_chip", 
		Anim("sam_items", "sam_items", "tp_advance_chip"),
		Img("sam_items", "tp_advance_chip")
	),
    AssetPack("tp_advance_chip2", 
		Anim("sam_items", "sam_items", "tp_advance_chip2"),
		Img("sam_items", "tp_advance_chip2")
	),
    AssetPack("ak_fix_powder", 
		Anim("ak_fix_powder", "ak_fix_powder", "idle", "idle_water"),
		Img("ak_items", "ak_fix_powder"), 
		nil, nil, {
			Asset("ANIM", "anim/ak_fix_powder.zip"),
		}
	),
    AssetPack("tp_treasure_map", 
		Anim("stash_map", "stash_map", "idle", "idle_water"),
		Img("stash_map")
	),
	AssetPack("tp_level_map", nil, nil, nil, nil, nil, "tp_treasure_map"),
	AssetPack("tp_advance_map", nil, nil, nil, nil, nil, "tp_treasure_map"),
	AssetPack("ak_dimensional", 
		Anim("ak_items", "ak_items", "ak_dimensional"),
		Img("ak_items", "ak_dimensional")
	),
	AssetPack("tp_engine",
		Anim("sam_items", "sam_items", "tp_engine"),
		Img("sam_items", "tp_engine")
	),
	AssetPack("tp_grass_pigking",
		Anim("topiary_pigking", "topiary_pigking", "idle"),
		Img("sam_items", "tp_grass_pigking")
	),
	AssetPack("tp_gift",
		Anim("sam_items", "sam_items", "tp_gift"),
		Img("sam_items", "tp_gift")
	),
	AssetPack("ak_candy_bag", 
		Anim("candybag", "wg_candybag", "anim"),
		Img("ak_items", "ak_candy_bag"),
		nil, nil, {
			Asset("ANIM", "anim/wg_candybag.zip"),
		}
	),
	AssetPack("tp_sign_staff", 
		Anim("tp_sign_staff", "tp_sign_staff", "idle", "idle_water"),
		Img("tp_weapons", "tp_sign_staff"),
		Symbol("swap_object", "tp_sign_staff", "swap_object"), 
		nil, {
			Asset("ANIM", "anim/tp_sign_staff.zip"),
		}
	),
	AssetPack("tp_cane_dodge", 
		Anim("cane", "cane_ancient", "idle", "idle_water"),
		Img("cane_ancient"),
		Symbol("swap_object", "swap_cane_ancient", "swap_cane")
	),
	AssetPack("tp_recover_bottle",
		Anim("tp_items3", "tp_items3", "f14"),
		Img("tp_items3", "items_14")
	),
	AssetPack("tp_beast_essence",
		Anim("tp_items3", "tp_items3", "f0"),
		Img("tp_items3", "items_0")
	),
},
ornament = {
	AssetPack("ak_ornament_boss_antlion",
		Anim("winter_ornaments", "winter_ornaments", "boss_antlion"),
		Img("winter_ornaments", "winter_ornament_boss_antlion")
	),
	AssetPack("ak_ornament_boss_bearger",
		Anim("winter_ornaments", "winter_ornaments", "boss_bearger"),
		Img("winter_ornaments", "winter_ornament_boss_bearger")
	),
	AssetPack("ak_ornament_boss_beequeen",
		Anim("winter_ornaments", "winter_ornaments", "boss_beequeen"),
		Img("winter_ornaments", "winter_ornament_boss_beequeen")
	),
	AssetPack("ak_ornament_boss_celestialchampion1",
		Anim("winter_ornaments2021", "winter_ornaments2021", "boss_celestialchampion1"),
		Img("winter_ornaments", "winter_ornament_boss_celestialchampion1")
	),
	AssetPack("ak_ornament_boss_celestialchampion2",
		Anim("winter_ornaments2021", "winter_ornaments2021", "boss_celestialchampion2"),
		Img("winter_ornaments", "winter_ornament_boss_celestialchampion2")
	),
	AssetPack("ak_ornament_boss_celestialchampion3",
		Anim("winter_ornaments2021", "winter_ornaments2021", "boss_celestialchampion3"),
		Img("winter_ornaments", "winter_ornament_boss_celestialchampion3")
	),
	AssetPack("ak_ornament_boss_celestialchampion4",
		Anim("winter_ornaments2021", "winter_ornaments2021", "boss_celestialchampion4"),
		Img("winter_ornaments", "winter_ornament_boss_celestialchampion4")
	),
	AssetPack("ak_ornament_boss_crabking",
		Anim("winter_ornaments2020", "winter_ornaments2020", "boss_crabking"),
		Img("winter_ornaments", "winter_ornament_boss_crabking")
	),
	AssetPack("ak_ornament_boss_crabkingpearl",
		Anim("winter_ornaments2020", "winter_ornaments2020", "boss_crabkingpearl"),
		Img("winter_ornaments", "winter_ornament_boss_crabkingpearl")
	),
	AssetPack("ak_ornament_boss_deerclops",
		Anim("winter_ornaments", "winter_ornaments", "boss_deerclops"),
		Img("winter_ornaments", "winter_ornament_boss_deerclops")
	),
	AssetPack("ak_ornament_boss_dragonfly",
		Anim("winter_ornaments", "winter_ornaments", "boss_dragonfly"),
		Img("winter_ornaments", "winter_ornament_boss_dragonfly")
	),
	AssetPack("ak_ornament_boss_eyeofterror1",
		Anim("winter_ornaments2021", "winter_ornaments2021", "boss_eyeofterror1"),
		Img("winter_ornaments", "winter_ornament_boss_eyeofterror1")
	),
	AssetPack("ak_ornament_boss_eyeofterror2",
		Anim("winter_ornaments2021", "winter_ornaments2021", "boss_eyeofterror2"),
		Img("winter_ornaments", "winter_ornament_boss_eyeofterror2")
	),
	AssetPack("ak_ornament_boss_fuelweaver",
		Anim("winter_ornaments", "winter_ornaments", "boss_fuelweaver"),
		Img("winter_ornaments", "winter_ornament_boss_fuelweaver")
	),
	AssetPack("ak_ornament_boss_hermithouse",
		Anim("winter_ornaments2020", "winter_ornaments2020", "boss_hermithouse"),
		Img("winter_ornaments", "winter_ornament_boss_hermithouse")
	),
	AssetPack("ak_ornament_boss_klaus",
		Anim("winter_ornaments", "winter_ornaments", "boss_klaus"),
		Img("winter_ornaments", "winter_ornament_boss_klaus")
	),
	AssetPack("ak_ornament_boss_krampus",
		Anim("winter_ornaments", "winter_ornaments", "boss_krampus"),
		Img("winter_ornaments", "winter_ornament_boss_krampus")
	),
	AssetPack("ak_ornament_boss_malbatross",
		Anim("winter_ornaments2019", "winter_ornaments2019", "boss_malbatross"),
		Img("winter_ornaments", "winter_ornament_boss_malbatross")
	),
	AssetPack("ak_ornament_boss_minotaur",
		Anim("winter_ornaments2020", "winter_ornaments2020", "boss_minotaur"),
		Img("winter_ornaments", "winter_ornament_boss_minotaur")
	),
	AssetPack("ak_ornament_boss_moose",
		Anim("winter_ornaments", "winter_ornaments", "boss_moose"),
		Img("winter_ornaments", "winter_ornament_boss_moose")
	),
	AssetPack("ak_ornament_boss_noeyeblue",
		Anim("winter_ornaments", "winter_ornaments", "boss_noeyeblue"),
		Img("winter_ornaments", "winter_ornament_boss_noeyeblue")
	),
	AssetPack("ak_ornament_boss_noeyered",
		Anim("winter_ornaments", "winter_ornaments", "boss_noeyered"),
		Img("winter_ornaments", "winter_ornament_boss_noeyered")
	),
	AssetPack("ak_ornament_boss_pearl",
		Anim("winter_ornaments2020", "winter_ornaments2020", "boss_pearl"),
		Img("winter_ornaments", "winter_ornament_boss_pearl")
	),
	AssetPack("ak_ornament_boss_toadstool",
		Anim("winter_ornaments", "winter_ornaments", "boss_toadstool"),
		Img("winter_ornaments", "winter_ornament_boss_toadstool")
	),
	AssetPack("ak_ornament_boss_toadstool_misery",
		Anim("winter_ornaments2020", "winter_ornaments2020", "boss_toadstool_misery"),
		Img("winter_ornaments", "winter_ornament_boss_toadstool_misery")
	),
	AssetPack("ak_ornament_boss_wagstaff",
		Anim("winter_ornaments2021", "winter_ornaments2021", "boss_wagstaff"),
		Img("winter_ornaments", "winter_ornament_boss_wagstaff")
	),
	AssetPack("ak_ornament_fancy1",
		Anim("winter_ornaments", "winter_ornaments", "fancy1"),
		Img("winter_ornaments", "winter_ornament_fancy1")
	),
	AssetPack("ak_ornament_fancy2",
		Anim("winter_ornaments", "winter_ornaments", "fancy2"),
		Img("winter_ornaments", "winter_ornament_fancy2")
	),
	AssetPack("ak_ornament_fancy3",
		Anim("winter_ornaments", "winter_ornaments", "fancy3"),
		Img("winter_ornaments", "winter_ornament_fancy3")
	),
	AssetPack("ak_ornament_fancy4",
		Anim("winter_ornaments", "winter_ornaments", "fancy4"),
		Img("winter_ornaments", "winter_ornament_fancy4")
	),
	AssetPack("ak_ornament_fancy5",
		Anim("winter_ornaments", "winter_ornaments", "fancy5"),
		Img("winter_ornaments", "winter_ornament_fancy5")
	),
	AssetPack("ak_ornament_fancy6",
		Anim("winter_ornaments", "winter_ornaments", "fancy6"),
		Img("winter_ornaments", "winter_ornament_fancy6")
	),
	AssetPack("ak_ornament_fancy7",
		Anim("winter_ornaments", "winter_ornaments", "fancy7"),
		Img("winter_ornaments", "winter_ornament_fancy7")
	),
	AssetPack("ak_ornament_fancy8",
		Anim("winter_ornaments", "winter_ornaments", "fancy8"),
		Img("winter_ornaments", "winter_ornament_fancy8")
	),
	AssetPack("ak_ornament_festivalevents1",
		Anim("winter_ornaments2018", "winter_ornaments2018", "festivalevents1"),
		Img("winter_ornaments", "winter_ornament_festivalevents1")
	),
	AssetPack("ak_ornament_festivalevents2",
		Anim("winter_ornaments2018", "winter_ornaments2018", "festivalevents2"),
		Img("winter_ornaments", "winter_ornament_festivalevents2")
	),
	AssetPack("ak_ornament_festivalevents3",
		Anim("winter_ornaments2018", "winter_ornaments2018", "festivalevents3"),
		Img("winter_ornaments", "winter_ornament_festivalevents3")
	),
	AssetPack("ak_ornament_festivalevents4",
		Anim("winter_ornaments2018", "winter_ornaments2018", "festivalevents4"),
		Img("winter_ornaments", "winter_ornament_festivalevents4")
	),
	AssetPack("ak_ornament_festivalevents5",
		Anim("winter_ornaments2018", "winter_ornaments2018", "festivalevents5"),
		Img("winter_ornaments", "winter_ornament_festivalevents5")
	),
	AssetPack("ak_ornament_light1",
		Anim("winter_ornaments", "winter_ornaments", "light1_off"),
		Img("winter_ornaments", "winter_ornament_light1")
	),
	AssetPack("ak_ornament_light2",
		Anim("winter_ornaments", "winter_ornaments", "light2_off"),
		Img("winter_ornaments", "winter_ornament_light2")
	),
	AssetPack("ak_ornament_light3",
		Anim("winter_ornaments", "winter_ornaments", "light3_off"),
		Img("winter_ornaments", "winter_ornament_light3")
	),
	AssetPack("ak_ornament_light4",
		Anim("winter_ornaments", "winter_ornaments", "light4_off"),
		Img("winter_ornaments", "winter_ornament_light4")
	),
	AssetPack("ak_ornament_light5",
		Anim("winter_ornaments", "winter_ornaments", "light5_off"),
		Img("winter_ornaments", "winter_ornament_light5")
	),
	AssetPack("ak_ornament_light6",
		Anim("winter_ornaments", "winter_ornaments", "light6_off"),
		Img("winter_ornaments", "winter_ornament_light6")
	),
	AssetPack("ak_ornament_light7",
		Anim("winter_ornaments", "winter_ornaments", "light7_off"),
		Img("winter_ornaments", "winter_ornament_light7")
	),
	AssetPack("ak_ornament_light8",
		Anim("winter_ornaments", "winter_ornaments", "light8_off"),
		Img("winter_ornaments", "winter_ornament_light8")
	),
	AssetPack("ak_ornament_plain1",
		Anim("winter_ornaments", "winter_ornaments", "plain1"),
		Img("winter_ornaments", "winter_ornament_plain1")
	),
	AssetPack("ak_ornament_plain10",
		Anim("winter_ornaments", "winter_ornaments", "plain10"),
		Img("winter_ornaments", "winter_ornament_plain10")
	),
	AssetPack("ak_ornament_plain11",
		Anim("winter_ornaments", "winter_ornaments", "plain11"),
		Img("winter_ornaments", "winter_ornament_plain11")
	),
	AssetPack("ak_ornament_plain12",
		Anim("winter_ornaments", "winter_ornaments", "plain12"),
		Img("winter_ornaments", "winter_ornament_plain12")
	),
	AssetPack("ak_ornament_plain2",
		Anim("winter_ornaments", "winter_ornaments", "plain2"),
		Img("winter_ornaments", "winter_ornament_plain2")
	),
	AssetPack("ak_ornament_plain3",
		Anim("winter_ornaments", "winter_ornaments", "plain3"),
		Img("winter_ornaments", "winter_ornament_plain3")
	),
	AssetPack("ak_ornament_plain4",
		Anim("winter_ornaments", "winter_ornaments", "plain4"),
		Img("winter_ornaments", "winter_ornament_plain4")
	),
	AssetPack("ak_ornament_plain5",
		Anim("winter_ornaments", "winter_ornaments", "plain5"),
		Img("winter_ornaments", "winter_ornament_plain5")
	),
	AssetPack("ak_ornament_plain6",
		Anim("winter_ornaments", "winter_ornaments", "plain6"),
		Img("winter_ornaments", "winter_ornament_plain6")
	),
	AssetPack("ak_ornament_plain7",
		Anim("winter_ornaments", "winter_ornaments", "plain7"),
		Img("winter_ornaments", "winter_ornament_plain7")
	),
	AssetPack("ak_ornament_plain8",
		Anim("winter_ornaments", "winter_ornaments", "plain8"),
		Img("winter_ornaments", "winter_ornament_plain8")
	),
	AssetPack("ak_ornament_plain9",
		Anim("winter_ornaments", "winter_ornaments", "plain9"),
		Img("winter_ornaments", "winter_ornament_plain9")
	),
},
blueprint = {
	AssetPack("blueprint", 
		Anim("blueprint", "blueprint", "idle", "idle_water"),
		Img("blueprint")
	),
	AssetPack("tp_forest_dragon_bp", nil, nil, nil, nil, nil, "blueprint"),
},
scroll = {
	AssetPack("tp_scroll_templar", 
		Anim("papyrus", "papyrus", "idle", "idle_water"),
		Img("sam_items", "tp_scroll_templar"),
		nil, nil, nil, nil
	),
	AssetPack("tp_scroll_rider", 
		Anim("papyrus", "papyrus", "idle", "idle_water"),
		Img("sam_items", "tp_scroll_rider"),
		nil, nil, nil, nil
	),
	AssetPack("tp_scroll_harvest", 
		Anim("papyrus", "papyrus", "idle", "idle_water"),
		Img("sam_items", "tp_scroll_harvest"),
		nil, nil, nil, nil
	),
	AssetPack("tp_scroll_pig_health",
		Anim("papyrus", "papyrus", "idle"),
		Img("ak_scrolls", "ak_scroll_pig_health")
	),
	AssetPack("tp_scroll_pig_heal",
		Anim("papyrus", "papyrus", "idle"),
		Img("ak_scrolls", "ak_scroll_pig_heal")
	),
	AssetPack("tp_scroll_pig_damage",
		Anim("papyrus", "papyrus", "idle"),
		Img("ak_scrolls", "ak_scroll_pig_damage")
	),
	AssetPack("tp_scroll_pig_armorex",
		Anim("papyrus", "papyrus", "idle"),
		Img("ak_scrolls", "ak_scroll_pig_armorex")
	),
	AssetPack("tp_scroll_pig_wind",
		Anim("papyrus", "papyrus", "idle"),
		Img("ak_scrolls", "ak_scroll_pig_wind")
	),
	AssetPack("tp_scroll_pig_speed",
		Anim("papyrus", "papyrus", "idle"),
		Img("ak_scrolls", "ak_scroll_pig_speed")
	),
	AssetPack("tp_scroll_wind",
		Anim("papyrus", "papyrus", "idle"),
		Img("ak_scrolls", "ak_scroll_wind")
	),
	AssetPack("tp_scroll_grow",
		Anim("papyrus", "papyrus", "idle"),
		Img("ak_scrolls", "ak_scroll_grow")
	),
	AssetPack("tp_scroll_lightning",
		Anim("papyrus", "papyrus", "idle"),
		Img("ak_scrolls", "ak_scroll_lightning")
	),
	AssetPack("tp_scroll_tentacle",
		Anim("papyrus", "papyrus", "idle"),
		Img("ak_scrolls", "ak_scroll_tentacle")
	),
	AssetPack("tp_scroll_sleep",
		Anim("papyrus", "papyrus", "idle"),
		Img("ak_scrolls", "ak_scroll_sleep")
	),
	AssetPack("tp_scroll_volcano",
		Anim("papyrus", "papyrus", "idle"),
		Img("ak_scrolls", "ak_scroll_volcano")
	),
	AssetPack("tp_scroll_bird",
		Anim("papyrus", "papyrus", "idle"),
		Img("ak_scrolls", "ak_scroll_bird")
	),
	AssetPack("tp_scroll_back", nil, nil, nil, nil, nil, "tp_scroll_templar"),
	AssetPack("tp_scroll_fire_atk", nil, nil, nil, nil, nil, "tp_scroll_templar"),
	AssetPack("tp_scroll_ice_atk", nil, nil, nil, nil, nil, "tp_scroll_templar"),
	AssetPack("tp_scroll_electric_atk", nil, nil, nil, nil, nil, "tp_scroll_templar"),
	AssetPack("tp_scroll_shadow_atk", nil, nil, nil, nil, nil, "tp_scroll_templar"),
},
potion = {
	AssetPack("tp_potion_vigor",
		Anim("tp_potion_2", "tp_potion_2", "crazy"),
		Img("tp_potions", "tp_potion_crazy")
	),
	AssetPack("tp_potion_fire_atk",
		Anim("tp_potion_2", "tp_potion_2", "warm"),
		Img("tp_potions", "tp_potion_warm")
	),
	AssetPack("tp_potion_ice_atk",
		Anim("tp_potion_frozen", "tp_potion_frozen", "idle"),
		Img("tp_potions", "tp_potion_frozen")
	),
	AssetPack("tp_potion_health",
		Anim("tp_potion", "tp_potion", "health_small"),
		Img("tp_potions", "tp_potion_health_small")
	),
	AssetPack("tp_potion_shine",
		Anim("tp_potion", "tp_potion", "shine"),
		Img("tp_potions", "tp_potion_shine")
	),
	AssetPack("tp_potion_shadow_atk",
		Anim("tp_potion_holy", "tp_potion_holy", "idle"),
		Img("tp_potions", "tp_potion_holy")
	),
	AssetPack("tp_potion_horror",
		Anim("tp_potion_2", "tp_potion_2", "horror"),
		Img("tp_potions", "tp_potion_horror")
	),
	AssetPack("tp_potion_warth",
		Anim("tp_potion", "tp_potion", "warth"),
		Img("tp_potions", "tp_potion_warth")
	),
	AssetPack("tp_potion_poison_atk",
		Anim("tp_potion_2", "tp_potion_2", "detoxify"),
		Img("tp_potions", "tp_potion_detoxify")
	),
	AssetPack("tp_potion_electric_atk",
		Anim("tp_potion_2", "tp_potion_2", "cool"),
		Img("tp_potions", "tp_potion_cool")
	),
	AssetPack("tp_potion_shadow",
		Anim("tp_potion_2", "tp_potion_2", "shadow"),
		Img("tp_potions", "tp_potion_shadow")
	),
	AssetPack("tp_potion_killer",
		Anim("tp_potion_2", "tp_potion_2", "killer"),
		Img("tp_potions", "tp_potion_killer")
	),
	AssetPack("tp_potion_mana",
		Anim("tp_potion", "tp_potion", "sanity_small"),
		Img("tp_potions", "tp_potion_sanity_small")
	),
	AssetPack("tp_potion_blood_atk",
		Anim("tp_potion_fire", "tp_potion_fire", "idle"),
		Img("tp_potions", "tp_potion_fire")
	),
	AssetPack("tp_potion_smell",
		Anim("tp_potion_2", "tp_potion_2", "smell"),
		Img("tp_potions", "tp_potion_smell")
	),
	AssetPack("tp_potion_defense",
		Anim("tp_potion_2", "tp_potion_2", "iron"),
		Img("tp_potions", "tp_potion_iron")
	),
	AssetPack("tp_potion_metal",
		Anim("tp_potion_2", "tp_potion_2", "metal"),
		Img("tp_potions", "tp_potion_metal")
	),
	AssetPack("tp_potion_dry",
		Anim("tp_potion_2", "tp_potion_2", "dry"),
		Img("tp_potions", "tp_potion_dry")
	),
	AssetPack("tp_potion_brave",
		Anim("tp_potion", "tp_potion", "brave_small"),
		Img("tp_potions", "tp_potion_brave_small")
	),
},
seed = {
	AssetPack("tp_plantable_grass_water",
		Anim("tp_plantable", "tp_plantable", "reeds"),
		Img("tp_potions", "tp_plantable_grass_water")
	),
	AssetPack("tp_plantable_reeds",
		Anim("tp_plantable", "tp_plantable", "reeds"),
		Img("tp_potions", "tp_plantable_reeds")
	),
	AssetPack("tp_plantable_flower_cave",
		Anim("tp_plantable", "tp_plantable", "reeds"),
		Img("tp_potions", "tp_plantable_flower_cave")
	),
	AssetPack("tp_plantable_mangrove",
		Anim("tp_plantable", "tp_plantable", "reeds"),
		Img("tp_potions", "tp_plantable_mangrove")
	),
	AssetPack("tp_plantable_reeds_water",
		Anim("tp_plantable", "tp_plantable", "reeds"),
		Img("tp_potions", "tp_plantable_reeds")
	),
},
weapon = {
    AssetPack("tp_spear_night", 
		Anim("spear", "spear_northern", "idle", "idle_water"),
		Img("spear_northern"),
		Symbol("swap_object", "swap_spear_northern", "swap_spear")
	),
    AssetPack("tp_spear_sharp", 
		Anim("spear", "spear_simple", "idle", "idle_water"),
		Img("spear_simple"),
		Symbol("swap_object", "swap_spear_simple", "swap_spear")	
	),
	AssetPack("tp_spear_enchant",
		Anim("spear", "spear_forge_gungnir", "idle", "idle_water"),
		Img("spear_forge_gungnir"),
		Symbol("swap_object", "swap_spear_forge_gungnir", "swap_spear_gungnir")
	),
    AssetPack("tp_spear_hockey", 
		Anim("spear", "spear_hockey", "idle", "idle_water"),
		Img("spear_hockey"),
		Symbol("swap_object", "swap_spear_hockey", "swap_spear")
	),
	AssetPack("tp_flash_knife",
		Anim("tp_flash_knife", "tp_flash_knife", "idle", "idle_water"),
		Img("sam_weapons", "tp_flash_knife"),
		Symbol("swap_object", "tp_flash_knife", "swap_object"),
		nil, {
			Asset("ANIM", "anim/tp_flash_knife.zip"),
		}
	),
	AssetPack("tp_forest_dragon",
		Anim("ak_forest_dragon", "ak_forest_dragon", "idle", "idle_water"),
		Img("tp_weapons", "tp_forest_dragon"),
		Symbol("swap_object", "ak_forest_dragon", "swap_object"),
		nil, {
			Asset("ANIM", "anim/ak_forest_dragon.zip"),
		}
	),
	AssetPack("tp_spear_resource",
		Anim("tp_spear_bag", "tp_spear_bag", "idle", "idle_water"),
		Img("tp_weapons", "tp_spear_bag"),
		Symbol("swap_object", "tp_spear_bag", "swap_object"),
		nil, {
			Asset("ANIM", "anim/tp_spear_bag.zip"),
		}
	),
	AssetPack("tp_spear_hurt",
		Anim("tp_spear_potion", "tp_spear_potion", "idle", "idle_water"),
		Img("tp_weapons", "tp_spear_potion"),
		Symbol("swap_object", "tp_spear_potion", "swap_object"),
		nil, {
			Asset("ANIM", "anim/tp_spear_potion.zip"),
		}
	),
	AssetPack("tp_spear_jax",
		Anim("tp_spear_turret", "tp_spear_turret", "idle", "idle_water"),
		Img("tp_weapons", "tp_spear_turret"),
		Symbol("swap_object", "tp_spear_turret", "swap_object"),
		nil, {
			Asset("ANIM", "anim/tp_spear_turret.zip"),
		}
	),
	AssetPack("tp_spear_jarvaniv",
		Anim("tp_spear_combat", "tp_spear_combat", "idle", "idle_water"),
		Img("tp_weapons", "tp_spear_combat"),
		Symbol("swap_object", "tp_spear_combat", "swap_object"),
		nil, {
			Asset("ANIM", "anim/tp_spear_combat.zip"),
		}
	),
	AssetPack("tp_spear_garen",
		Anim("tp_spear_shine", "tp_spear_shine", "idle", "idle_water"),
		Img("tp_weapons", "tp_spear_shine"),
		Symbol("swap_object", "tp_spear_shine", "swap_object"),
		nil, {
			Asset("ANIM", "anim/tp_spear_shine.zip"),
		}
	),
    AssetPack("tp_spear_speed2", nil, nil, nil, nil, nil, "tp_spear_speed"),
    AssetPack("tp_spear_speed3", nil, nil, nil, nil, nil, "tp_spear_speed"),
	AssetPack("tp_spear_conqueror2", nil, nil, nil, nil, nil, "tp_spear_conqueror"),
    AssetPack("tp_spear_conqueror3", nil, nil, nil, nil, nil, "tp_spear_conqueror"),
    AssetPack("tp_spear_darius", nil, nil, nil, nil, nil, "tp_spear_conqueror"),
    AssetPack("tp_forest_dragon2", nil, nil, nil, nil, nil, "tp_forest_dragon"),
    AssetPack("tp_forest_dragon3", nil, nil, nil, nil, nil, "tp_forest_dragon"),
    AssetPack("tp_spear_monk", nil, nil, nil, nil, nil, "tp_spear_fire"),
    AssetPack("tp_spear_zed", nil, nil, nil, nil, nil, "tp_spear_ice"),
},
armor = {
    AssetPack("tp_armor_health", 
        Anim("armor_wood_lamellar", "armor_wood_lamellar", "anim", "idle_water"),
        Img("armor_wood_lamellar"),
        Symbol("swap_body", "armor_wood_lamellar", "swap_body", "body")
    ),
    AssetPack("tp_armor_cloak",
        Anim("armor_grass", "armor_grass_cloak", "anim", "idle_water"),
        Img("armor_grass_cloak"),
        Symbol("swap_body", "armor_grass_cloak", "swap_body", "body")  
    ),
	AssetPack("tp_armor_ancient",
        Anim("armor_ruins", "armor_ruins_tusk", "anim", "idle_water"),
        Img("armor_ruins_tusk"),
        Symbol("swap_body", "armor_ruins_tusk", "swap_body", "body")  
    ),
	AssetPack("tp_armor_ice",
		Anim("armor_wood_lamellar", "tp_armor_cool", "anim", "idle_water"),
		Img("tp_armors", "tp_armor_cool"),
		Symbol("swap_body", "tp_armor_cool", "swap_body"),
		nil, {
			Asset("ANIM", "anim/".."tp_armor_cool"..".zip"),
		}
	),
	AssetPack("tp_armor_fire",
		Anim("armor_wood_lamellar", "tp_armor_warm", "anim", "idle_water"),
		Img("tp_armors", "tp_armor_warm"),
		Symbol("swap_body", "tp_armor_warm", "swap_body"),
		nil, {
			Asset("ANIM", "anim/".."tp_armor_warm"..".zip"),
		}
	),
	AssetPack("tp_armor_strong",
		Anim("armor_marble", "armor_marble", "anim", "idle_water"),
		Img("armor_marble"),
		Symbol("swap_body", "armor_marble", "swap_body")
	),
	AssetPack("tp_armor_jarvaniv",
		Anim("armor_wood_lamellar","tp_armor_health","anim", "idle_water"),
		Img("tp_armors", "tp_armor_health"),
		Symbol("swap_body", "tp_armor_health","swap_body"),
		nil, {
			Asset("ANIM", "anim/tp_armor_health.zip"),
		}
	),
	AssetPack("tp_armor_zed",
		Anim("armor_wood_lamellar","tp_armor_shadow","anim", "idle_water"),
		Img("tp_armors", "tp_armor_shadow"),
		Symbol("swap_body", "tp_armor_shadow","swap_body"),
		nil, {
			Asset("ANIM", "anim/tp_armor_shadow.zip"),
		}
	),
	AssetPack("tp_cloak_resist", nil, nil, nil, nil, nil, "tp_armor_zed"),
	AssetPack("tp_cloak_garen", nil, nil, nil, nil, nil, "tp_armor_zed"),
	AssetPack("tp_cloak_food", nil, nil, nil, nil, nil, "tp_armor_zed"),
	AssetPack("tp_cloak_jax", nil, nil, nil, nil, nil, "tp_armor_zed"),
	AssetPack("tp_cloak_darius", nil, nil, nil, nil, nil, "tp_armor_zed"),
	AssetPack("tp_cloak_frozen", nil, nil, nil, nil, nil, "tp_armor_zed"),
	AssetPack("tp_armor_strong2", nil, nil, nil, nil, nil, "tp_armor_strong"),
	AssetPack("tp_armor_strong3", nil, nil, nil, nil, nil, "tp_armor_strong"),
	AssetPack("tp_armor_monk", nil, nil, nil, nil, nil, "tp_armor_fire"),
	AssetPack("tp_armor_zed", nil, nil, nil, nil, nil, "tp_armor_ice"),
},
helm = {
    AssetPack("tp_helm_combat", 
        Anim("footballhat", "footballhat_combathelm", "anim", "idle_water"),
        Img("footballhat_combathelm"),
        Symbol("swap_hat", "footballhat_combathelm", "swap_hat", "head")
    ),
    AssetPack("tp_helm_baseball", 
		Anim("footballhat", "footballhat_hockey", "anim", "idle_water"),
		Img("footballhat_hockey"),
		Symbol("swap_hat", "footballhat_hockey", "swap_hat", "head")
	),
	AssetPack("tp_helm_ancient", 
        Anim("ruinshat", "ruinshat_arcane", "anim", "idle_water"),
        Img("ruinshat_arcane"),
        Symbol("swap_hat", "ruinshat_arcane", "swap_hat", "head")
    ),
	AssetPack("tp_helm_cool",
		Anim("tp_hat_cool", "tp_hat_cool", "anim", "idle_water"),
		Img("tp_hats", "tp_hat_cool"),
		Symbol("swap_hat", "tp_hat_cool", "swap_hat"),
		nil, {
			Asset("ANIM", "anim/".."tp_hat_cool"..".zip"),
		}
	),
	AssetPack("tp_helm_warm",
		Anim("tp_hat_warm", "tp_hat_warm", "anim", "idle_water"),
		Img("tp_hats", "tp_hat_warm"),
		Symbol("swap_hat", "tp_hat_warm", "swap_hat"),
		nil, {
			Asset("ANIM", "anim/".."tp_hat_warm"..".zip"),
		}
	),
	AssetPack("tp_helm_jarvaniv",
		Anim("tp_hat_health", "tp_hat_health", "anim", "idle_water"),
		Img("tp_hats", "tp_hat_health"),
		Symbol("swap_hat", "tp_hat_health", "swap_hat"),
		nil, {
			Asset("ANIM", "anim/tp_hat_health.zip"),
		}
	),
	AssetPack("tp_helm_garen", nil, nil, nil, nil, nil, "tp_helm_warm"),
	AssetPack("tp_helm_jax", nil, nil, nil, nil, nil, "tp_helm_warm"),
	AssetPack("tp_helm_darius", nil, nil, nil, nil, nil, "tp_helm_warm"),
	AssetPack("tp_helm_monk", nil, nil, nil, nil, nil, "tp_helm_warm"),	
	AssetPack("tp_helm_zed", nil, nil, nil, nil, nil, "tp_helm_cool"),	
},
pack = {
	AssetPack("backpack", 
		Anim("backpack1", "swap_backpack", "anim"),
		Img("backpack"),
		Symbol("swap_body", "swap_backpack", "swap_body"),
		"backpack.png", nil, nil		
	),
	AssetPack("tp_pack_crab", 
		Anim("backpack1", "backpack_crab", "anim"),
		Img("backpack_crab"),
		Symbol("swap_body", "backpack_crab", "swap_body"),
		"backpack_crab.png", nil, nil
	),
	AssetPack("tp_pack_rabbit", 
		Anim("backpack1", "backpack_rabbit", "anim"),
		Img("backpack_rabbit"),
		Symbol("swap_body", "backpack_rabbit", "swap_body"),
		"backpack_rabbit.png", nil, nil
	),
	AssetPack("tp_pack_beefalo", 
		Anim("backpack1", "backpack_beefalo", "anim"),
		Img("backpack_beefalo"),
		Symbol("swap_body", "backpack_beefalo", "swap_body"),
		"backpack_beefalo.png", nil, nil
	),
	AssetPack("tp_pack_smallbird", 
		Anim("backpack1", "backpack_smallbird", "anim"),
		Img("backpack_smallbird"),
		Symbol("swap_body", "backpack_smallbird", "swap_body"),
		"backpack_smallbird.png", nil, nil
	),
	AssetPack("tp_pack_mandrake", 
		Anim("backpack1", "backpack_mandrake", "anim"),
		Img("backpack_mandrake"),
		Symbol("swap_body", "backpack_mandrake", "swap_body"),
		"backpack_mandrake.png", nil, nil
	),
},
structure = {
    AssetPack("tent",
        Anim("tent", "tent", "idle"),
        Img("tent"),
        nil,
        "tent.png"
    ),
	AssetPack("tp_desk", 
		Anim("tp_desk", "tp_desk", "idle"),
		Img("tp_items", "tp_desk"),
		nil, 
		"tp_desk.tex",
		{
			Asset("ANIM", "anim/tp_desk.zip"),
		}
	),
	AssetPack("tp_lab", 
		Anim("tp_lab", "tp_lab", "idle"),
		Img("tp_items", "tp_lab"),
		nil, 
		"tp_lab.tex",
		{
			Asset("ANIM", "anim/tp_lab.zip"),
		}
	),
    AssetPack("tp_furnace",
        Anim("tp_furnace", "tp_furnace", "idle"),
        Img("tp_furnace"),
        nil,
        "tp_furnace.tex", 
        {
            Asset("ANIM", "anim/tp_furnace.zip"),
            Asset("ATLAS", "images/inventoryimages/tp_furnace.xml"),
            Asset("IMAGE", "images/inventoryimages/tp_furnace.tex"),
        }
    ),
	-- structures
	AssetPack("ak_loader",
		Anim("ak_loader", "ak_loader", "off"),
		Img("ak_structures", "ak_loader"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_loader.zip"),
		}
	),
	AssetPack("ak_water_sieve",
		Anim("ak_water_sieve", "ak_water_sieve", "ui"),
		Img("ak_structures", "ak_water_sieve"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_water_sieve.zip"),
		}
	),
	AssetPack("ak_ice_maker",
		Anim("ak_ice_maker", "ak_ice_maker", "ui"),
		Img("ak_structures", "ak_ice_maker"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_ice_maker.zip"),
		}
	),
	AssetPack("ak_shadow_bed",
		Anim("ak_shadow_bed", "ak_shadow_bed", "off"),
		Img("ak_structures", "ak_shadow_bed"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_shadow_bed.zip"),
		}
	),
	AssetPack("ak_farm_brick",
		Anim("ak_structures", "ak_structures", "ak_farm_brick"),
		Img("ak_structures", "ak_farm_brick"),
		nil, nil, nil
	),
	AssetPack("ak_scanner",
		Anim("ak_scanner", "ak_scanner", "off"),
		Img("ak_structures", "ak_scanner"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_scanner.zip"),
		}
	),
	AssetPack("ak_electrolyzer",
		Anim("ak_electrolyzer", "ak_electrolyzer", "off"),
		Img("ak_structures", "ak_electrolyzer"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_electrolyzer.zip"),
		}
	),
	AssetPack("ak_gem_refiner",
		Anim("ak_gem_refiner", "ak_gem_refiner", "off"),
		Img("ak_structures", "ak_gem_refiner"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_gem_refiner.zip"),
		}
	),
	AssetPack("ak_work_bench",
		Anim("ak_work_bench", "ak_work_bench", "off"),
		Img("ak_structures", "ak_work_bench"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_work_bench.zip"),
		}
	),
	AssetPack("ak_liquid_pump",
		Anim("ak_liquid_pump", "ak_liquid_pump", "off"),
		Img("ak_structures", "ak_liquid_pump"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_liquid_pump.zip"),
		}
	),
	AssetPack("ak_transport_center",
		Anim("ak_transport_center", "ak_transport_center", "off"),
		Img("ak_structures", "ak_transport_center"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_transport_center.zip"),
		}
	),
	AssetPack("ak_auto_harvester",
		Anim("ak_auto_harvester", "ak_auto_harvester", "off"),
		Img("ak_structures", "ak_auto_harvester"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_auto_harvester.zip"),
		}
	),
	AssetPack("ak_desalinator",
		Anim("ak_desalinator", "ak_desalinator", "off"),
		Img("ak_structures", "ak_desalinator"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_desalinator.zip"),
		}
	),
	AssetPack("ak_farmer_station",
		Anim("ak_farmer_station", "ak_farmer_station", "off"),
		Img("ak_structures", "ak_farmer_station"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_farmer_station.zip"),
		}
	),
	AssetPack("ak_jumbo_battery",
		Anim("ak_jumbo_battery", "ak_jumbo_battery", "off"),
		Img("ak_structures", "ak_jumbo_battery"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_jumbo_battery.zip"),
		}
	),
	AssetPack("ak_virtual_orrery",
		Anim("ak_virtual_orrery", "ak_virtual_orrery", "off"),
		Img("ak_structures", "ak_virtual_orrery"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_virtual_orrery.zip"),
		}
	),
	AssetPack("ak_power_shutoff",
		Anim("ak_power_shutoff", "ak_power_shutoff", "off"),
		Img("ak_structures", "ak_power_shutoff"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_power_shutoff.zip"),
		}
	),
	AssetPack("ak_oxygen_mask_dock",
		Anim("ak_structures_c", "ak_structures_c", "ak_oxygen_mask_dock"),
		Img("ak_structures", "ak_oxygen_mask_dock"),
		nil, nil, nil
	),
	AssetPack("ak_stone_breaker",
		Anim("ak_stone_breaker", "ak_stone_breaker", "off"),
		Img("ak_structures", "ak_stone_breaker"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_stone_breaker.zip"),
		}
	),
	AssetPack("ak_large_power_transformer",
		Anim("ak_structures_c", "ak_structures_c", "ak_large_power_transformer"),
		Img("ak_structures", "ak_large_power_transformer"),
		nil, nil, nil
	),
	AssetPack("ak_kiln",
		Anim("ak_kiln", "ak_kiln", "off"),
		Img("ak_structures", "ak_kiln"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_kiln.zip"),
		}
	),
	AssetPack("ak_pharmacy",
		Anim("ak_pharmacy", "ak_pharmacy", "off"),
		Img("ak_structures", "ak_pharmacy"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_pharmacy.zip"),
		}
	),
	AssetPack("ak_rocket_storage",
		Anim("ak_rocket_storage", "ak_rocket_storage", "grounded"),
		Img("ak_structures", "ak_rocket_storage"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_rocket_storage.zip"),
		}
	),
	AssetPack("ak_lamp",
		Anim("ak_lamp", "ak_lamp", "off"),
		Img("ak_structures", "ak_lamp"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_lamp.zip"),
		}
	),
	AssetPack("ak_coffee_machine",
		Anim("ak_coffee_machine", "ak_coffee_machine", "off"),
		Img("ak_structures", "ak_coffee_machine"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_coffee_machine.zip"),
		}
	),
	AssetPack("ak_textile_machine",
		Anim("ak_textile_machine", "ak_textile_machine", "off"),
		Img("ak_structures", "ak_textile_machine"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_textile_machine.zip"),
		}
	),
	AssetPack("ak_mesh_tile",
		Anim("ak_structures_b", "ak_structures_b", "ak_mesh_tile"),
		Img("ak_structures", "ak_mesh_tile"),
		nil, nil, nil
	),
	AssetPack("ak_gas_pump",
		Anim("ak_structures_c", "ak_structures_c", "ak_gas_pump"),
		Img("ak_structures", "ak_gas_pump"),
		nil, nil, nil
	),
	AssetPack("ak_wool_shearing_machine",
		Anim("ak_wool_shearing_machine", "ak_wool_shearing_machine", "off"),
		Img("ak_structures", "ak_wool_shearing_machine"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_wool_shearing_machine.zip"),
		}
	),
	AssetPack("ak_juicer",
		Anim("ak_structures", "ak_structures", "ak_juicer"),
		Img("ak_structures", "ak_juicer"),
		nil, nil, nil
	),
	AssetPack("ak_magic_table",
		Anim("ak_magic_table", "ak_magic_table", "off"),
		Img("ak_structures", "ak_magic_table"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_magic_table.zip"),
		}
	),
	AssetPack("ak_algae_terrarium",
		Anim("ak_algae_terrarium", "ak_algae_terrarium", "off"),
		Img("ak_structures", "ak_algae_terrarium"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_algae_terrarium.zip"),
		}
	),
	AssetPack("ak_clear_station",
		Anim("ak_structures", "ak_structures", "ak_clear_station"),
		Img("ak_structures", "ak_clear_station"),
		nil, nil, nil
	),
	AssetPack("ak_wood_generator",
		Anim("ak_wood_generator", "ak_wood_generator", "off"),
		Img("ak_structures", "ak_wood_generator"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_wood_generator.zip"),
		}
	),
	AssetPack("ak_coal_generator",
		Anim("ak_coal_generator", "ak_coal_generator", "off"),
		Img("ak_structures", "ak_coal_generator"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_coal_generator.zip"),
		}
	),
	AssetPack("ak_fertilizer_maker",
		Anim("ak_fertilizer_maker", "ak_fertilizer_maker", "off"),
		Img("ak_structures", "ak_fertilizer_maker"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_fertilizer_maker.zip"),
		}
	),
	AssetPack("ak_triage_table",
		Anim("ak_triage_table", "ak_triage_table", "off"),
		Img("ak_structures", "ak_triage_table"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_triage_table.zip"),
		}
	),
	AssetPack("ak_rocket_control_station",
		Anim("ak_structures_c", "ak_structures_c", "ak_rocket_control_station"),
		Img("ak_structures", "ak_rocket_control_station"),
		nil, nil, nil
	),
	AssetPack("ak_incubator",
		Anim("ak_structures_c", "ak_structures_c", "ak_incubator"),
		Img("ak_structures", "ak_incubator"),
		nil, nil, nil
	),
	AssetPack("ak_transporter",
		Anim("ak_transporter", "ak_transporter", "off"),
		Img("ak_structures", "ak_transporter"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_transporter.zip"),
		}
	),
	AssetPack("ak_oil_well",
		Anim("ak_oil_well", "ak_oil_well", "off"),
		Img("ak_structures", "ak_oil_well"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_oil_well.zip"),
		}
	),
	AssetPack("ak_plant_brick",
		Anim("ak_structures_b", "ak_structures_b", "ak_plant_brick"),
		Img("ak_structures", "ak_plant_brick"),
		nil, nil, nil
	),
	AssetPack("ak_smithing_table",
		Anim("ak_smithing_table", "ak_smithing_table", "off"),
		Img("ak_structures", "ak_smithing_table"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_smithing_table.zip"),
		}
	),
	AssetPack("ak_fridge",
		Anim("ak_fridge", "ak_fridge", "off"),
		Img("ak_structures", "ak_fridge"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_fridge.zip"),
		}
	),
	AssetPack("ak_super_calculator",
		Anim("ak_super_calculator", "ak_super_calculator", "off"),
		Img("ak_structures", "ak_super_calculator"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_super_calculator.zip"),
		}
	),
	AssetPack("ak_storage_bin",
		Anim("ak_structures_c", "ak_structures_c", "ak_storage_bin"),
		Img("ak_structures", "ak_storage_bin"),
		nil, nil, nil
	),
	AssetPack("ak_gas_reservoir",
		Anim("ak_structures_c", "ak_structures_c", "ak_gas_reservoir"),
		Img("ak_structures", "ak_gas_reservoir"),
		nil, nil, nil
	),
	AssetPack("ak_atmo_suit_dock",
		Anim("ak_structures_c", "ak_structures_c", "ak_atmo_suit_dock"),
		Img("ak_structures", "ak_atmo_suit_dock"),
		nil, nil, nil
	),
	AssetPack("ak_smart_storage_bin",
		Anim("ak_structures_c", "ak_structures_c", "ak_smart_storage_bin"),
		Img("ak_structures", "ak_smart_storage_bin"),
		nil, nil, nil
	),
	AssetPack("ak_hot_furnace",
		Anim("ak_hot_furnace", "ak_hot_furnace", "off"),
		Img("ak_structures", "ak_hot_furnace"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_hot_furnace.zip"),
		}
	),
	AssetPack("ak_refrigerator",
		Anim("ak_refrigerator", "ak_refrigerator", "off"),
		Img("ak_structures", "ak_refrigerator"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_refrigerator.zip"),
		}
	),
	AssetPack("ak_smart_battery",
		Anim("ak_structures_c", "ak_structures_c", "ak_smart_battery"),
		Img("ak_structures", "ak_smart_battery"),
		nil, nil, nil
	),
	AssetPack("ak_molecule_furnace",
		Anim("ak_molecule_furnace", "ak_molecule_furnace", "off"),
		Img("ak_structures", "ak_molecule_furnace"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_molecule_furnace.zip"),
		}
	),
	AssetPack("ak_mini_liquid_pump",
		Anim("ak_structures_c", "ak_structures_c", "ak_mini_liquid_pump"),
		Img("ak_structures", "ak_mini_liquid_pump"),
		nil, nil, nil
	),
	AssetPack("ak_research_center",
		Anim("ak_research_center", "ak_research_center", "off"),
		Img("ak_structures", "ak_research_center"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_research_center.zip"),
		}
	),
	AssetPack("ak_mini_gas_pump",
		Anim("ak_structures_c", "ak_structures_c", "ak_mini_gas_pump"),
		Img("ak_structures", "ak_mini_gas_pump"),
		nil, nil, nil
	),
	AssetPack("ak_liquid_reservoir",
		Anim("ak_structures_c", "ak_structures_c", "ak_liquid_reservoir"),
		Img("ak_structures", "ak_liquid_reservoir"),
		nil, nil, nil
	),
	AssetPack("ak_heavi_watt_joint_plate",
		Anim("ak_structures_c", "ak_structures_c", "ak_heavi_watt_joint_plate"),
		Img("ak_structures", "ak_heavi_watt_joint_plate"),
		nil, nil, nil
	),
	AssetPack("ak_bottle_emptier",
		Anim("ak_structures_c", "ak_structures_c", "ak_bottle_emptier"),
		Img("ak_structures", "ak_bottle_emptier"),
		nil, nil, nil
	),
	AssetPack("ak_plasticator",
		Anim("ak_plasticator", "ak_plasticator", "off"),
		Img("ak_structures", "ak_plasticator"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_plasticator.zip"),
		}
	),
	AssetPack("ak_deodorizer",
		Anim("ak_structures_c", "ak_structures_c", "ak_deodorizer"),
		Img("ak_structures", "ak_deodorizer"),
		nil, nil, nil
	),
	AssetPack("ak_egg_desk",
		Anim("ak_egg_desk", "ak_egg_desk", "off"),
		Img("ak_structures", "ak_egg_desk"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_egg_desk.zip"),
		}
	),
	AssetPack("ak_oven",
		Anim("ak_oven", "ak_oven", "off"),
		Img("ak_structures", "ak_oven"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_oven.zip"),
		}
	),
	AssetPack("ak_planter_box",
		Anim("ak_structures_c", "ak_structures_c", "ak_planter_box"),
		Img("ak_structures", "ak_planter_box"),
		nil, nil, nil
	),
	AssetPack("ak_algae_distiller",
		Anim("ak_algae_distiller", "ak_algae_distiller", "off"),
		Img("ak_structures", "ak_algae_distiller"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_algae_distiller.zip"),
		}
	),
	AssetPack("ak_compost",
		Anim("ak_compost", "ak_compost", "off"),
		Img("ak_structures", "ak_compost"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_compost.zip"),
		}
	),
	AssetPack("ak_pitcher_pump",
		Anim("ak_pitcher_pump", "ak_pitcher_pump", "off"),
		Img("ak_structures", "ak_pitcher_pump"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_pitcher_pump.zip"),
		}
	),
	AssetPack("ak_carbon_skimmer",
		Anim("ak_carbon_skimmer", "ak_carbon_skimmer", "off"),
		Img("ak_structures", "ak_carbon_skimmer"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_carbon_skimmer.zip"),
		}
	),
	AssetPack("ak_oxygen_diffuser",
		Anim("ak_oxygen_diffuser", "ak_oxygen_diffuser", "off"),
		Img("ak_structures", "ak_oxygen_diffuser"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_oxygen_diffuser.zip"),
		}
	),
	AssetPack("ak_natural_gas_generator",
		Anim("ak_natural_gas_generator", "ak_natural_gas_generator", "off"),
		Img("ak_structures", "ak_natural_gas_generator"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_natural_gas_generator.zip"),
		}
	),
	AssetPack("ak_feeder",
		Anim("ak_structures_c", "ak_structures_c", "ak_feeder"),
		Img("ak_structures", "ak_feeder"),
		nil, nil, nil
	),
	AssetPack("ak_jet_suit_dock",
		Anim("ak_structures_c", "ak_structures_c", "ak_jet_suit_dock"),
		Img("ak_structures", "ak_jet_suit_dock"),
		nil, nil, nil
	),
	AssetPack("ak_battery",
		Anim("ak_battery", "ak_battery", "off"),
		Img("ak_structures", "ak_battery"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_battery.zip"),
		}
	),
	AssetPack("ak_electric_wire",
		Anim("ak_electric_wire", "ak_electric_wire", "off"),
		Img("ak_structures", "ak_electric_wire"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_electric_wire.zip"),
		}
	),
	AssetPack("ak_metal_refiner",
		Anim("ak_metal_refiner", "ak_metal_refiner", "off"),
		Img("ak_structures", "ak_metal_refiner"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_metal_refiner.zip"),
		}
	),
	AssetPack("ak_ore_scrubber",
		Anim("ak_ore_scrubber", "ak_ore_scrubber", "off"),
		Img("ak_structures", "ak_ore_scrubber"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_ore_scrubber.zip"),
		}
	),
	AssetPack("ak_tar_generator",
		Anim("ak_tar_generator", "ak_tar_generator", "off"),
		Img("ak_structures", "ak_tar_generator"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_tar_generator.zip"),
		}
	),
	AssetPack("ak_manual_generator",
		Anim("ak_manual_generator", "ak_manual_generator", "off"),
		Img("ak_structures", "ak_manual_generator"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_manual_generator.zip"),
		}
	),
	AssetPack("ak_hydrogen_generator",
		Anim("ak_hydrogen_generator", "ak_hydrogen_generator", "off"),
		Img("ak_structures", "ak_hydrogen_generator"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_hydrogen_generator.zip"),
		}
	),
	AssetPack("ak_oil_refinery",
		Anim("ak_oil_refinery", "ak_oil_refinery", "off"),
		Img("ak_structures", "ak_oil_refinery"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_oil_refinery.zip"),
		}
	),
	AssetPack("ak_dispensary",
		Anim("ak_dispensary", "ak_dispensary", "off"),
		Img("ak_structures", "ak_dispensary"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_dispensary.zip"),
		}
	),
	AssetPack("ak_park_sign",
		Anim("ak_structures_b", "ak_structures_b", "ak_park_sign"),
		Img("ak_structures", "ak_park_sign"),
		nil, nil, nil
	),
	AssetPack("ak_rocket_head",
		Anim("ak_rocket_head", "ak_rocket_head", "ui"),
		Img("ak_structures", "ak_rocket_head"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_rocket_head.zip"),
		}
	),
	AssetPack("ak_shadow_portal",
		Anim("ak_shadow_portal", "ak_shadow_portal", "idle"),
		Img("ak_structures", "ak_shadow_portal"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_shadow_portal.zip"),
		}
	),
	AssetPack("ak_food_compressor",
		Anim("ak_food_compressor", "ak_food_compressor", "off"),
		Img("ak_structures", "ak_food_compressor"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_food_compressor.zip"),
		}
	),
	AssetPack("ak_telescope_mount",
		Anim("ak_telescope_mount", "ak_telescope_mount", "off"),
		Img("ak_structures", "ak_telescope_mount"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_telescope_mount.zip"),
		}
	),
	AssetPack("ak_calorifier",
		Anim("ak_calorifier", "ak_calorifier", "off"),
		Img("ak_structures", "ak_calorifier"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_calorifier.zip"),
		}
	),
	AssetPack("ak_great_bed",
		Anim("ak_great_bed", "ak_great_bed", "off"),
		Img("ak_structures", "ak_great_bed"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_great_bed.zip"),
		}
	),
	AssetPack("ak_sun_generator",
		Anim("ak_sun_generator", "ak_sun_generator", "off"),
		Img("ak_structures", "ak_sun_generator"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_sun_generator.zip"),
		}
	),
	AssetPack("ak_robot_worker",
		Anim("ak_robot_worker", "ak_robot_worker", "off"),
		Img("ak_structures", "ak_robot_worker"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_robot_worker.zip"),
		}
	),
	AssetPack("ak_fan",
		Anim("ak_fan", "ak_fan", "off"),
		Img("ak_structures", "ak_fan"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_fan.zip"),
		}
	),
	AssetPack("ak_level_eraser",
		Anim("ak_level_eraser", "ak_level_eraser", "off"),
		Img("ak_structures", "ak_level_eraser"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_level_eraser.zip"),
		}
	),
	AssetPack("ak_docile_table",
		Anim("ak_docile_table", "ak_docile_table", "off"),
		Img("ak_structures", "ak_docile_table"),
		nil, nil, 
		{
			Asset("ANIM", "anim/ak_docile_table.zip"),
		}
	),
	AssetPack("ak_shop",
		Anim("ak_structures_d", "ak_structures_d", "ak_shop"),
		Img("ak_structures_2", "ak_shop"),
		nil, nil, nil
	),
	AssetPack("ak_office_table",
		Anim("ak_structures_d", "ak_structures_d", "ak_office_table"),
		Img("ak_structures_2", "ak_office_table"),
		nil, nil, nil
	),
	AssetPack("ak_rocket_circle",
		Anim("ak_structures_d", "ak_structures_d", "ak_rocket_circle"),
		Img("ak_structures_2", "ak_rocket_circle"),
		nil, nil, nil
	),
	AssetPack("tp_chest",
		Anim("tp_items3", "tp_items3", "f2"),
		Img("tp_items3", "items_2"),
		nil, nil, nil
	),
	AssetPack("tp_chest2",
		Anim("tp_items3", "tp_items3", "f3"),
		Img("tp_items3", "items_3"),
		nil, nil, nil
	),
	AssetPack("tp_chest3",
		Anim("tp_items3", "tp_items3", "f1"),
		Img("tp_items3", "items_1"),
		nil, nil, nil
	),
},
creature = {
},
other = {
	AssetPack("tp_spear_speed3_fx", nil, nil, nil, nil, nil, "ak_shop"),
}, 
vehicle = {
	AssetPack("tp_rook", 
		Anim("rook", "rook_build", "idle"),
		Img("ak_icons", "ak_rook_head"),
		nil,
		"tp_rook.tex"
	),
	AssetPack("tp_coal_beast", 
		Anim("rook", "rook_build", "idle"),
		Img("sam_icons", "tp_coal_beast"),
		nil,
		"tp_coal_beast.tex"
	),
	AssetPack("tp_fant", 
		Anim("rook", "rook_build", "idle"),
		Img("sam_icons", "tp_fant"),
		nil,
		"tp_fant.tex"
	),
},
}

-- 蓝图
local blueprint_tbl = Info.LockStructure
for k, v in pairs(blueprint_tbl) do
	table.insert(assets.blueprint, AssetPack(v.."_bp", nil, nil, nil, nil, nil, "blueprint"))
end
-- 注能矿
for k, v in pairs({
	"orange", "black", "grey", "white", "blue", 
    "red", "green", "yellow", "purple", "cyan", "pink",
}) do
	table.insert(assets.item, AssetPack("tp_infused_nugget_"..v, 
		Anim("tp_infused_nugget", "tp_infused_nugget", v),
		Img("tp_infused_nugget", v)
	) )
end

-- 武器
local weapon_tbl = {
	"tp_spear_lance",
	"tp_spear_speed",
	"tp_spear_conqueror",
	"tp_spear_ice",
	"tp_spear_fire",
	"tp_spear_thunder",
	"tp_spear_poison",
	"tp_spear_blood",
	"tp_spear_shadow",
}
for k, v in pairs(weapon_tbl) do
	table.insert(assets.weapon, AssetPack(v,
		Anim(v, v, "idle", "idle_water"),
		Img("tp_weapons", v),
		Symbol("swap_object", v, "swap_object"),
		nil, {
			Asset("ANIM", "anim/"..v..".zip"),
		}
	))
end

local armor_tbl = {
}
for k, v in pairs(armor_tbl) do
	table.insert(assets.armor, AssetPack(v,
		Anim("armor_wood_lamellar", v, "anim", "idle_water"),
		Img("tp_armors", v),
		Symbol("swap_body", v, "swap_body"),
		nil, {
			Asset("ANIM", "anim/"..v..".zip"),
		}
	))
end

local helm_tbl = {
}
for k, v in pairs(helm_tbl) do
	table.insert(assets.helm, AssetPack(v,
		Anim(v, v, "anim", "idle_water"),
		Img("tp_hats", v),
		Symbol("swap_hat", v, "swap_hat"),
		nil, {
			Asset("ANIM", "anim/"..v..".zip"),
		}
	))
end

for kind, asset_tbl in pairs(assets) do
    for _, asset in pairs(asset_tbl) do
        AssetMaster:AddAssetData(asset)
    end
end

Sample.AssetMaster = AssetMaster
-- return AssetMaster