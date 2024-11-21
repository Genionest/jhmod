require "class"

local function morphFx(inst, is_back)
	if is_back then
		inst.components.talker:Say("瞧瞧俺是谁")
	else
		inst.components.talker:Say("七十二变")
	end
	inst.components.mkskillfx:ShadowFx()
	-- local pos = inst:GetPosition()
	-- SpawnPrefab("statue_transition").Transform:SetPosition(pos:Get())
	-- SpawnPrefab("statue_transition_2").Transform:SetPosition(pos:Get())
	-- local dx = 3 + math.random()
	-- local dz = 3 + math.random()
	-- if math.random() < .5 then dx = -dx end
	-- if math.random() < .5 then dz = -dz end
	-- SpawnPrefab("collapse_small").Transform:SetPosition(pos.x+dx, pos.y, pos.z+dx)
	-- SpawnPrefab("mk_morph_fx").Transform:SetPosition(pos.x+dx, pos.y, pos.z+dx)
end

local tags = {
	["monkey"] = {"character"},
	["pig"] = {"character"},
	["merm"] = {"merm", "character"},
	["spider"] = {"monster"},
	["hound"] = {"hound", "monster"},
	["bees"] = {"bees", "insect", "flying"},
	["beefalo"] = {"beefalo"},
	["tallbird"] = {"tallbird"},
	["rabbit"] = {"rabbit"},  -- 兔子
	["butterfly"] = {"butterfly", "flying", "insect"},  -- 蝴蝶
	["frog"] = {"frog"},  -- 青蛙
	["perd"] = {"berrythief"},  -- 火鸡
	["goat"] = {"lightninggoat", "lightningrod"},  -- 电羊
	["walrus"] = {"walrus", "character", "houndfriend"},  -- 海象
	["penguin"] = {},  -- 企鹅
	["koalefant"] = {"koalefant"},  -- 大象
	["catcoon"] = {"catcoon"},  -- 浣熊
	-- 蚊子
}

local anims = {
	["monkey"] = {"wilson", "monkey_king"},
	["pig"] = {"pigman", "pig_build"},
	["merm"] = {"pigman", "merm_build"},
	["spider"] = {"spider", "spider_build"},
	["hound"] = {"hound", "hound"},
	["bees"] = {"bee", "bee_build"},
	["beefalo"] = {"beefalo", "beefalo_build"},
	["tallbird"] = {"tallbird", "ds_tallbird_basic"},
	["rabbit"] = {"rabbit", "rabbit_build"},
	["butterfly"] = {"butterfly", "butterfly_basic"},
	["frog"] = {"frog", "frog_build"},
	["perd"] = {"perd", "perd"},
	["goat"] = {"lightning_goat", "lightning_goat_build"},
	["walrus"] = {"walrus", "walrus_build"},
	["penguin"] = {"penguin", "penguin_build"},
	["koalefant"] = {"koalefant", "koalefant_summer_build"},
	["catcoon"] = {"catcoon", "catcoon_build"}
}

local graphs = {
	["monkey"] = "SGwilson",
	["pig"] = "SGmorph_pig",
	["merm"] = "SGmorph_merm",
	["spider"] = "SGmorph_spider",
	["hound"] = "SGmorph_hound",
	["bees"] = "SGmorph_bees",
	["beefalo"] = "SGmorph_beefalo",
	["tallbird"] = "SGmorph_tallbird",
	["rabbit"] = "SGmorph_rabbit",
	["butterfly"] = "SGmorph_butterfly",
	["frog"] = "SGmorph_frog",
	["perd"] = "SGmorph_perd",
	["goat"] = "SGmorph_goat",
	["walrus"] = "SGmorph_walrus",
}

-- local function handlerTags(inst, t, is_add)
-- 	for i = 1, #t do
-- 		if is_add then
-- 			if not inst:HasTag(t[i]) then inst:AddTag(t[i]) end
-- 		else
-- 			if inst:HasTag(t[i]) then inst:RemoveTag(t[i]) end
-- 		end
-- 	end
-- end

local function loseEquipped(inst, body, old_body)
	if old_body == "monkey" and body ~= "monkey" then
		local inv = inst.components.inventory
		for i, v in pairs(EQUIPSLOTS) do
			local item = inv:GetEquippedItem(v)
			if v == "head" and item and item.prefab == "walrushat"
			and body == "walrus" then
				inst.AnimState:ClearOverrideSymbol("swap_hat")
				inst.AnimState:Show("HEAD")
			else
				inv:DropItem(item)
			end
		end
	end
end

local function handlerTags(inst, body, old_body)
	local add_t = tags[body]
	local mov_t = tags[old_body]
	for _, v in pairs(mov_t) do
		if v then
			inst:RemoveTag(v)
		end
	end
	for _, v in pairs(add_t) do
		if v then
			inst:AddTag(v)
		end
	end
end

local function GetBodyWords(word, body, old_body)
	if string.find(word, body) and not string.find(word, old_body) then
		return 1
	elseif not string.find(word, body) and string.find(word, old_body) then
		return 2
	end
end

-- local function GetMorph2Fly(body, old_body)
-- 	local fly_wd = "bees|butterfly|"
-- 	if string.find(fly_wd, body) and not string.find(fly_wd, old_body) then
-- 		return "fly"
-- 	elseif not string.find(fly_wd, body) and string.find(fly_wd, old_body) then
-- 		return "nofly"
-- 	end
-- end

local function ChangePhysics(inst, body, old_body)
	-- if GetMorph2Fly(body, old_body) == "fly" then
	if GetBodyWords("bees|butterfly|frog|", body, old_body) == 1 then
		if MK_INTENSIFY_UTIL.IsInDLC(3) then
			MK_INTENSIFY_UTIL.ChangePhysics(inst, {"world","obs","char","wav","wall"})
			MK_INTENSIFY_UTIL.ChangeKeepLand(inst, false)
		end
		-- MK_INTENSIFY_UTIL.ChangePhysics(inst, {"ground"})
	-- elseif GetMorph2Fly(body, old_body) == "nofly" then
	elseif GetBodyWords("bees|butterfly|frog|", body, old_body) == 2 then
		if MK_INTENSIFY_UTIL.IsInDLC(3) then
			MK_INTENSIFY_UTIL.ChangePhysics(inst, {"world","water","obs","char","wav","wall"})	
			MK_INTENSIFY_UTIL.ChangeKeepLand(inst, true)
		end
	end
end
	
local function ChangeHUD(inst, body, old_body)
	if body ~= "monkey" and old_body == "monkey" then
		MK_INTENSIFY_UTIL.ChangePlayerHUD(false, {"inv", "craft"})
	elseif body == "monkey" and old_body ~= "monkey" then
		MK_INTENSIFY_UTIL.ChangePlayerHUD(true, {"inv", "craft"})
	end
end

local function GetMorph2Faced(body, old_body)
	local six_face_wd = "beefalo|"
	local two_face_wd = "butterfly|"
	if string.find(six_face_wd, body) then
		return 6
	elseif string.find(two_face_wd, body) then
		return 2
	else
		return 4
	end
end

local function ChangeFaced(inst, body, old_body)
	if GetMorph2Faced(body, old_body) == 6 then
		inst.Transform:SetSixFaced()
	elseif GetMorph2Faced(body, old_body) == 4 then
		inst.Transform:SetFourFaced()
	elseif GetMorph2Faced(body, old_body) == 2 then
		inst.Transform:SetTwoFaced()
	end
end

local function FixAnim(inst, body, old_body)
	local layers = {
		beefalo = "HEAT",
		tallbird = "beakfull",
		goat = "fx"
	}
	if layers[body] then
		inst.AnimState:Hide(layers[body])
	end
	if layers[old_body] then
		inst.AnimState:Show(layers[old_body])
	end
	-- if body == "beefalo" then
	-- 	inst.AnimState:Hide("HEAT")
	-- elseif body == "tallbird" then
	-- 	inst.AnimState:Hide("beakfull")
	-- end
	-- if old_body == "beefalo" then
	-- 	inst.AnimState:Show("HEAT")
	-- elseif old_body == "tallbird" then
	-- 	inst.AnimState:Show("beakfull")
	-- end
end

-- local function GetMorph2Thief(body, old_body)
-- 	local thief_wd = "frog|"
-- 	if string.find(thief_wd, body) and not string.find(thief_wd, old_body) then
-- 		return "thief"
-- 	elseif not string.find(thief_wd, body) and string.find(thief_wd, old_body) then
-- 		return "nothief"
-- 	end
-- end

local function on_water_change(inst, onwater)
	if onwater then
		inst.sg:GoToState("submerge")
		-- inst.AnimState:SetBank("frog_water")
		inst.DynamicShadow:Enable(false)
	else
		inst.sg:GoToState("emerge")
		-- inst.AnimState:SetBank("frog")
		inst.DynamicShadow:Enable(true)
	end
end

local function ChangeByFrog(inst, body, old_body)
-- local function ChangeThief(inst, body, old_body)
	-- if GetMorph2Thief(body, old_body) == "thief" then
	if GetBodyWords("frog|", body, old_body) == 1 then
		if inst.components.thief == nil then
			inst:AddComponent("thief")
		end
		inst:AddTag("monkey_king_thief")
		if MK_INTENSIFY_UTIL.IsInDLC(3) then
			if inst.components.tiletracker == nil then
				inst:AddComponent("tiletracker")
			end
			inst.components.tiletracker:SetOnWaterChangeFn(on_water_change)
		end
	-- elseif GetMorph2Thief(body, old_body) == "nothief" then
	elseif GetBodyWords("frog|", body, old_body) == 2 then
		if inst.components.thief then
			inst:RemoveComponent("thief")
		end
		inst:RemoveTag("monkey_king_thief")
		if MK_INTENSIFY_UTIL.IsInDLC(3) then
			if inst.components.tiletracker then
				inst.components.tiletracker:SetOnWaterChangeFn(nil)
			end
			inst.DynamicShadow:Enable(true)
		end
	end
end

local function ChangeByWalrus(inst, body, old_body)
	if GetBodyWords("walrus|", body, old_body) == 1 then
		inst.Transform:SetScale(1.5, 1.5, 1.5)
	elseif GetBodyWords("walrus|", body, old_body) == 2 then
		inst.Transform:SetScale(1, 1, 1)
		-- if body == "monkey" and 
		local hat = inst.components.inventory:GetEquippedItem("head")
		if hat and hat.prefab == "walrushat" then
			-- inst.AnimState:Hide("HEAD")
			inst.components.inventory:DropItem(hat)
		end
		-- end
	end
end

-- local function GetMorph2Combat(body, old_body)
-- 	local no_attack_wd = "rabbit|butterfly|"
-- 	if string.find(no_attack_wd, body) and not string.find(no_attack_wd, old_body) then
-- 		return "noattack"
-- 	elseif not string.find(no_attack_wd, body) and string.find(no_attack_wd, old_body) then
-- 		return "attack"
-- 	end
-- end

local function ChangeCombat(inst, body, old_body)
	-- if GetMorph2Combat(body, old_body) == "noattack" then
	if GetBodyWords("rabbit|butterfly|") == 1 then
		-- inst:RemoveTag("scarytoprey")
		inst:AddTag("monkey_king_cant_attack")
	-- elseif GetMorph2Combat(body, old_body) == "attack" then
	elseif GetBodyWords("rabbit|butterfly|") == 2 then
		-- inst:AddTag("scarytoprey")
		inst:RemoveTag("monkey_king_cant_attack")
	end
end

local function RemoveFx(inst, body, old_body)
	if old_body == "goat" and inst:HasTag("monkey_king_charged") then
		if inst.morph_charged_fx and inst.morph_charged_fx.killfx then
			inst.morph_charged_fx:killfx(inst.morph_charged_fx)
		end
	end
end

local function ChangeInsulation(inst, body, old_body)
	if GetBodyWords("beefalo|", body, old_body) == 1 then
		if inst.components.mkmorphinsulator == nil then
			inst:AddComponent("mkmorphinsulator")
			inst.components.mkmorphinsulator:SetWinterInsulation(30*4)
		end
	elseif GetBodyWords("beefalo|", body, old_body) == 2 then
		if inst.components.mkmorphinsulator then
			inst:RemoveComponent("mkmorphinsulator")
		end
	end
end

local function ChangeAnim(inst, body, old_body)
	if body == "rabbit" 
	and GetSeasonManager():GetSeasonString() == "winter" then
		inst.AnimState:SetBuild("rabbit_winter_build")
	elseif body == "bees"
	and (GetSeasonManager():GetSeasonString() == "spring"
	or GetSeasonManager():GetSeasonString() == "green") then
		inst.AnimState:SetBuild("bee_angry_build")
	elseif body == "butterfly" and MK_INTENSIFY_UTIL.IsInDLC(2) then
		inst.AnimState:SetBuild("butterfly_tropical_basic")
	elseif body == "frog" and MK_INTENSIFY_UTIL.IsInDLC(3) then
		inst.AnimState:SetBuild("frog_treefrog_build")
	elseif body == "beefalo" 
	and (GetSeasonManager():GetSeasonString() == "spring") then
		inst.AnimState:Show("HEAT")
	elseif body == "koalefant" 
	and GetSeasonManager():GetSeasonString() == "winter" then
		inst.AnimState:SetBuild("koalefant_winter_build")
	end
end

local function WithMorphChanged(inst, body, old_body)
	loseEquipped(inst, body, old_body)
	handlerTags(inst, body, old_body)
	ChangePhysics(inst, body, old_body)
	ChangeHUD(inst, body, old_body)
	ChangeFaced(inst, body, old_body)
	FixAnim(inst, body, old_body)
	-- ChangeThief(inst, body, old_body)
	ChangeByFrog(inst, body, old_body)
	ChangeByWalrus(inst, body, old_body)
	RemoveFx(inst, body, old_body)
	ChangeInsulation(inst, body, old_body)
	ChangeAnim(inst, body, old_body)
end

local function MorphActionButton(inst)
	local action_target = FindEntity(inst, 6, function(item)
		if (item.components.door and not item.components.door.disabled 
		and (not item.components.burnable or not item.components.burnable:IsBurning())) 
		or (item.components.edible and inst.components.eater:CanEat(item)) 
		or (item.components.workable and item.components.workable.workable 
		and item.components.workable.action==ACTIONS.CHOP) 
		or (item.components.hackable and item.components.hackable:CanBeHacked() 
		and inst.components.worker:CanDoAction(ACTIONS.HACK)) then
			return true
		end
	end)
	if not inst.sg:HasStateTag("busy") and action_target then
		if action_target.components.door 
		and not action_target.components.door.disabled
		and (not action_target.components.burnable 
		or not action_target.components.burnable:IsBurning()) then
			return BufferedAction(inst, action_target, ACTIONS.USEDOOR)
		elseif (action_target.components.edible
		and inst.components.eater:CanEat(action_target)) then
			return BufferedAction(inst, action_target, ACTIONS.EAT)
		elseif action_target.components.workable
		and action_target.components.workable.action==ACTIONS.CHOP
		and action_target.components.workable.workleft > 0 then
			return BufferedAction(inst, action_target, ACTIONS.CHOP)
		elseif action_target.components.hackable
		and action_target.components.hackable:CanBeHacked()
		and action_target.components.hackable.hacksleft > 0 then
			return BufferedAction(inst, action_target, ACTIONS.HACK)
		end
	end
end

local function MorphActionButton2(inst)
	local action_target = FindEntity(inst, 6, function(item)
		if item.components.edible and inst.components.eater:CanEat(item) then
			return true
		end
	end)
	if not inst.sg:HasStateTag("busy") and action_target then
		if (action_target.components.edible
		and inst.components.eater:CanEat(action_target)) then
			return BufferedAction(inst, action_target, ACTIONS.EAT)
		end
	end
end

local function MorphActionButton3(inst)
	local action_target = FindEntity(inst, 6, function(item)
		if (item.components.edible and inst.components.eater:CanEat(item))
		or (item.components.pickable 
		and item.components.pickable:CanBePicked()
        and item.components.pickable.product == "berries") then
			return true
		end
	end)
	if not inst.sg:HasStateTag("busy") and action_target then
		if (action_target.components.edible
		and inst.components.eater:CanEat(action_target)) then
			return BufferedAction(inst, action_target, ACTIONS.EAT)
		elseif (action_target.components.pickable 
		and action_target.components.pickable:CanBePicked()
        and action_target.components.pickable.product == "berries") then
			return BufferedAction(inst, action_target, ACTIONS.PICK)
		end
	end
end

local function LeftClickPicker(inst, target_ent, pos)
	if target_ent and target_ent.components.door
	and not target_ent.components.door.disabled
	and (not target_ent.components.burnable
	or not target_ent.components.burnable:IsBurning()) then
		return inst.components.playeractionpicker:SortActionList({ACTIONS.USEDOOR}, target_ent, nil)
	end
	if inst.components.combat:CanTarget(target_ent)
	and not inst:HasTag("monkey_king_cant_attack") then
		return inst.components.playeractionpicker:SortActionList({ACTIONS.ATTACK}, target_ent, nil)
	end
	if target_ent and target_ent.components.edible
	and inst.components.eater:CanEat(target_ent) then
		return inst.components.playeractionpicker:SortActionList({ACTIONS.EAT}, target_ent, nil)
	end
	if target_ent and target_ent.components.workable 
	and target_ent.components.workable
	and target_ent.components.workable.workable
	and target_ent.components.workable.workleft > 0
	and target_ent.components.workable.action==ACTIONS.CHOP then
		return inst.components.playeractionpicker:SortActionList({ACTIONS.CHOP}, target_ent, nil)
	end
	if target_ent and target_ent.components.hackable
	and target_ent.components.hackable:CanBeHacked()
	and target_ent.components.hackable.hacksleft > 0
	and inst.components.worker:CanDoAction(ACTIONS.HACK) then
		return inst.components.playeractionpicker:SortActionList({ACTIONS.HACK}, target_ent, nil)
	end
end

local function LeftClickPicker2(inst, target_ent, pos)
	if inst.components.combat:CanTarget(target_ent)
	and not inst:HasTag("monkey_king_cant_attack") then
		return inst.components.playeractionpicker:SortActionList({ACTIONS.ATTACK}, target_ent, nil)
	end
	if target_ent and target_ent.components.edible
	and inst.components.eater:CanEat(target_ent) then
		return inst.components.playeractionpicker:SortActionList({ACTIONS.EAT}, target_ent, nil)
	end
end

local function LeftClickPicker3(inst, target_ent, pos)
	if inst.components.combat:CanTarget(target_ent)
	and not inst:HasTag("monkey_king_cant_attack") then
		return inst.components.playeractionpicker:SortActionList({ACTIONS.ATTACK}, target_ent, nil)
	end
	if target_ent and target_ent.components.edible
	and inst.components.eater:CanEat(target_ent) then
		return inst.components.playeractionpicker:SortActionList({ACTIONS.EAT}, target_ent, nil)
	end
	if target_ent and target_ent.components.pickable 
	and target_ent.components.pickable:CanBePicked()
    and target_ent.components.pickable.product == "berries" then
    	return inst.components.playeractionpicker:SortActionList({ACTIONS.PICK}, target_ent, nil)
	end
end

local function RightClickPicker(inst, target_ent, pos)
	return {}
end

local Morph = Class(function(self, inst)
	self.inst = inst
	self.is_morph = false
	self.morph_cur = "monkey"
	inst:ListenForEvent("death", function()
		self:UnMorph()
	end)
end)

function Morph:GetCurrent()
	return self.morph_cur
end

function Morph:CanMorph()
	local inst = self.inst
	if inst.components.driver
	and not inst.components.driver:GetIsDriving()
	and inst.components.rider
	and not inst.components.rider:IsRiding()
	and not inst:HasTag("notarget")
	and not inst:HasTag("ironlord")
	and inst:GetIsOnLand() then
		return true
	end
end

function Morph:IsHunmanBody(body)
	return body == "pigman" or body == "merm"
end

function Morph:GetBodyAction(body)
	if body == "pigman" or body == "merm" then
		return "human"
	elseif body == "perd" then
		return "perd"
	else
		return "animal"
	end
end

function Morph:Morph(body)
	local old_body = self.morph_cur
	if old_body ~= body
	-- and self.inst.components.monkeymana:GetCurrent()>=20 
	then
		self.morph_cur = body
		self.inst.AnimState:SetBank(anims[body][1])
		self.inst.AnimState:SetBuild(anims[body][2])
		-- self.inst:SetStateGraph(graphs[body])
		self.inst:SetStateGraph("SGmorph_"..body)
		self.inst.components.talker:IgnoreAll()
		-- self.inst.components.inventory:DropEverything()
		self.inst:AddComponent("worker")
		self.inst.components.worker:SetAction(ACTIONS.CHOP, 1)
		self.inst.components.worker:SetAction(ACTIONS.HACK, 1)
		-- if self:IsHunmanBody(body) then
		if self:GetBodyAction(body) == "human" then
			self.inst.components.playercontroller.actionbuttonoverride = MorphActionButton
			self.inst.components.playeractionpicker.leftclickoverride = LeftClickPicker
		elseif self:GetBodyAction(body) == "animal" then
			self.inst.components.playercontroller.actionbuttonoverride = MorphActionButton2
			self.inst.components.playeractionpicker.leftclickoverride = LeftClickPicker2
		elseif self:GetBodyAction(body) == "perd" then
			self.inst.components.playercontroller.actionbuttonoverride = MorphActionButton3
			self.inst.components.playeractionpicker.leftclickoverride = LeftClickPicker3
		end
		self.inst.components.playeractionpicker.rightclickoverride = RightClickPicker
		-- with morph change
		WithMorphChanged(self.inst, body, old_body)
		-- loseEquipped(self.inst)
		-- handlerTags(self.inst, tags[old_body], false)
		-- handlerTags(self.inst, tags[body], true)
		-- -- hud
		-- ChangeHUD(false)
		-- -- physics
		-- ChangePhysics(self.inst, self.morph_cur, old_body)
		-- mana
		self.inst.components.monkeymana:DoDelta(-20)
		-- fx
		morphFx(self.inst, false)
		-- ui
		-- self.inst.components.mkmorphtimer:SetPercent(0)
	end
end

function Morph:UnMorph()
	local old_body = self.morph_cur
	if old_body ~= "monkey"
	-- and self.inst.components.monkeymana:GetCurrent()>=20 
	then
		self.morph_cur = "monkey"
		self.inst.AnimState:SetBank(anims["monkey"][1])
		self.inst.AnimState:SetBuild(anims["monkey"][2])
		self.inst:SetStateGraph("SGwilson")
		self.inst.components.talker:StopIgnoringAll()
		self.inst:RemoveComponent("worker")
		self.inst.components.playercontroller.actionbuttonoverride = nil
		self.inst.components.playeractionpicker.leftclickoverride = nil
		self.inst.components.playeractionpicker.rightclickoverride = nil
		-- with morph change
		WithMorphChanged(self.inst, "monkey", old_body)
		-- handlerTags(self.inst, tags[old_body], false)
		-- handlerTags(self.inst, tags["monkey"], true)
		-- -- hud
		-- ChangeHUD(true)
		-- -- physics
		-- ChangePhysics(self.inst, "monkey", old_body)
		-- mana
		self.inst.components.monkeymana:DoDelta(-20)
		-- fx
		morphFx(self.inst, true)
		-- ui
		-- self.inst.components.mkmorphtimer:SetPercent(0)
	end
end

function Morph:GetDebugString()
	return string.format("%s / ", self.morph_cur)
end

return Morph