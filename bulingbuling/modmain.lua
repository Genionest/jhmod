local require = GLOBAL.require
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local Recipe = GLOBAL.Recipe
local STRINGS = GLOBAL.STRINGS
local ACTIONS = GLOBAL.ACTIONS
local TECH = GLOBAL.TECH
local SpawnPrefab = GLOBAL.SpawnPrefab
GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
PrefabFiles = {
	"bulingbuling",
	"buling_box",
	"buling_boat",
	"buling_plant",
	"buling_item",
	"buling_bee",
	"buling_hulk",
	"buling_zaxiang",
	"buling_system",
	"buling_food",
	"buling_weapon",
	"buling_firerain",
	"buling_carrier",
}


Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/bulingbuling.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/bulingbuling.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/bulingbuling.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/bulingbuling.xml" ),
	
	Asset( "IMAGE", "images/selectscreen_portraits/bulingbuling_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/bulingbuling_silho.xml" ),

    Asset( "IMAGE", "bigportraits/bulingbuling.tex" ),
    Asset( "ATLAS", "bigportraits/bulingbuling.xml" ),
	
	Asset( "IMAGE", "images/map_icons/bulingbuling.tex" ),
	Asset( "ATLAS", "images/map_icons/bulingbuling.xml" ),
	
	Asset( "ATLAS", "images/bulingui/buling_close.xml" ),
	Asset( "ATLAS", "images/bulingui/bulingui.xml" ),
	Asset( "ATLAS", "images/bulingui/buling_button.xml" ),
	Asset( "ATLAS", "images/bulingui/turnarrow_icon.xml" ),
	Asset( "ATLAS", "images/bulinggongye.xml" ),
	

	--Asset("ANIM", "anim/shadow_insanity1_basic.zip"),
	Asset("ANIM", "anim/generating_buling.zip"),
}
STRINGS.NAMES.BULINGBULING = "BulingBuling"
AddMinimapAtlas("images/map_icons/bulingbuling.xml")
AddModCharacter("bulingbuling","FEMALE")
modimport "scripts/string_bulingbuling.lua"
modimport "scripts/hamletislandconnector.lua"
modimport("scripts/buling_postinits/screens.lua")
local classpostinitfiles = {
	"loadgamescreen",
	"slotdetailsscreen",
}
for k, class in ipairs(classpostinitfiles) do
	local data = GLOBAL.require("buling_postinits/classes/"..class)
	if data.fullname and data.fn then
		AddClassPostConstruct(data.fullname, data.fn)
	end
end
--前往其他世界
AddGlobalClassPostConstruct("saveindex", "SaveIndex", function(self)
	function self:GoToDimension(dimname, x, y, z, save)
		self:SaveCurrent(function()
			--Records player data
			local playerdata = {}
			local player = GetPlayer()
			if player then
				if x or y or z then
					player.components.teleportonload:SetTarget(x,y,z)
				end
				playerdata = player:GetSaveRecord().data
				playerdata.leader = nil
				playerdata.sanitymonsterspawner = nil
			end
			local modename = dimname
			--Ensures dimension designations are present (modename is mostly redundant, but whatever)

			--Sets new mode
			self.data.slots[self.current_slot].current_mode = modename
			
			--Ensures mode data table is present
			if not self.data.slots[self.current_slot].modes[modename] then
				self.data.slots[self.current_slot].modes[modename] = {}
			end

			--Ensures mode data is present
			self.data.slots[self.current_slot].modes[modename].files = self.data.slots[self.current_slot].modes[modename].files or {}

			--Sets mode data
			self.data.slots[self.current_slot].modes[modename].world = 1
			
			--Generates save name
			local savename = self:GetSaveGameName(modename, self.current_slot)

			--Records player data to mode data
			--self.data.slots[self.current_slot].modes[modename].playerdata = playerdata
			local planet = ""
			--if modename == "stormplanet" then planet = "STORMPLANET" end
			local Levels = require("map/levels")
			for i,level in ipairs(Levels.custom_levels) do
				if level.id == modename  then
					self.data.slots[self.current_slot].modes[modename].playerdata = nil
					self.data.slots[self.current_slot].modes[modename].playerdata = playerdata
					self.data.slots[self.current_slot].modes[modename].options = {
						level_id = i
					}
					break
				end
			end
			--Clears mode data file name entry
			self.data.slots[self.current_slot].modes[modename].file = nil
			
			--Checks if save exists
			TheSim:CheckPersistentStringExists(savename, function(exists)
				if exists then
					--Records save name to mode data
					self.data.slots[self.current_slot].modes[modename].file = savename
				end
			end)

			--Save
			self:Save(function()
				SetPause(false)
				StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot()}, true)
			end)
		end)
	end
end)
GLOBAL.SaveIndex.IsModeShipwrecked = function(self,slot) 
	return self:GetCurrentMode(slot) == "shipwrecked" or self:GetCurrentMode(slot) == "volcano" or self:GetCurrentMode(slot) == "stormplanet" or self:GetCurrentMode(slot) == "bossfight" 
end
GLOBAL.SaveIndex.IsModePorkland = function(self,slot) 
	return self:GetCurrentMode(slot) == "porkland" or self:GetCurrentMode(slot) == "edenplanet" 
end
--ui
local uilist= {
"buling_hechenglist_food",
"buling_hechenglist_plant",
"buling_hechenglist",
"buling_system",
"buling_hechenglist_extraction",
}
for k,v in pairs(uilist) do
	local bulingui = GLOBAL.require ("widgets/"..v)
	local function Addbulingui(self)
		controls = self
		if controls and GetPlayer().prefab == "bulingbuling" then 
			if controls.containerroot then
				controls.bulingui = controls.containerroot:AddChild(bulingui())
			end
		else
			return
		end
		controls.bulingui:Hide()
	end
	AddClassPostConstruct( "widgets/controls", Addbulingui )
end
--action
local BULING_STSTEM = GLOBAL.Action({},0,false,false,1)
BULING_STSTEM.id = "BULING_STSTEM"
BULING_STSTEM.str = STRINGS.BULING_STSTEM
BULING_STSTEM.fn = function(act) 
	if act.doer then 
		GetPlayer():PushEvent("OpenBuling_system")
	end 
	return true	
end
AddAction(BULING_STSTEM)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.BULING_STSTEM, "doshortaction"))
AddStategraphActionHandler("wilsonboating", ActionHandler(ACTIONS.BULING_STSTEM, "doshortaction"))
