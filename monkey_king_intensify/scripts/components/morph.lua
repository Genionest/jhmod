require "class"

local function loseEquipped(inst)
	local inv = inst.components.inventory
	for i, v in pairs(EQUIPSLOTS) do
		local item = inv:GetEquippedItem(v)
		inv:DropItem(item)
	end
end

local function handlerTags(inst, t, is_add)
	for i = 1, #t do
		if is_add then
			if not inst:HasTag(t[i]) then inst:AddTag(t[i]) end
		else
			if inst:HasTag(t[i]) then inst:RemoveTag(t[i]) end
		end
	end
end

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
	["monkey"] = {"scarytoprey", "character"},
	["pigman"] = {"pigman", "scarytoprey", "character"},
	["merm"] = {"merm", "scarytoprey", "character"},
	["spider"] = {"monster", "scarytoprey"},
	["hound"] = {"hound", "scarytoprey", "monster"},
	["bee"] = {"bee", "insect", "flying", "scarytoprey"},
}

local anims = {
	["monkey"] = {"wilson", "monkey_king"},
	["pigman"] = {"pigman", "pig_build"},
	["merm"] = {"pigman", "merm_build"},
	["spider"] = {"spider", "spider_build"},
	["hound"] = {"hound", "hound"},
	["bee"] = {"bee", "bee_build"},
}

local graphs = {
	["monkey"] = "SGwilson",
	["pigman"] = "SGmorph_pig",
	["merm"] = "SGmorph_merm",
	["spider"] = "SGmorph_spider",
	["hound"] = "SGmorph_hound",
	["bee"] = "SGmorph_bee",
}

local physics = {
	monkey = function(inst)
		MakeCharacterPhysics(inst, 75, .5)
	end,
	bee = function(inst)
		MakeCharacterPhysics(inst, 1, .5)
		inst.Physics:SetCollisionGroup(COLLISION.FLYERS)
		inst.Physics:ClearCollisionMask()
	end,
}

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

local function LeftClickPicker(inst, target_ent, pos)
	if target_ent and target_ent.components.door
	and not target_ent.components.door.disabled
	and (not target_ent.components.burnable
	or not target_ent.components.burnable:IsBurning()) then
		return inst.components.playeractionpicker:SortActionList({ACTIONS.USEDOOR}, target_ent, nil)
	end
	if inst.components.combat:CanTarget(target_ent) then
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
	if inst.components.combat:CanTarget(target_ent) then
		return inst.components.playeractionpicker:SortActionList({ACTIONS.ATTACK}, target_ent, nil)
	end
	if target_ent and target_ent.components.edible
	and inst.components.eater:CanEat(target_ent) then
		return inst.components.playeractionpicker:SortActionList({ACTIONS.EAT}, target_ent, nil)
	end
end

local function RightClickPicker(inst, target_ent, pos)
	return {}
end

local Morph = Class(function(self, inst)
	self.inst = inst
	self.is_morph = false
	self.morph_cur = "monkey"
end)

function Morph:GetCurrent()
	return self.morph_cur
end

function Morph:IsHunmanBody(body)
	return body == "pigman" or body == "merm"
end

function Morph:Morph(body)
	local old_body = self.morph_cur
	if old_body ~= body
	and self.inst.components.monkeymana:GetCurrent()>=20 then
		self.morph_cur = body
		handlerTags(self.inst, tags[old_body], false)
		handlerTags(self.inst, tags[body], true)
		self.inst.AnimState:SetBank(anims[body][1])
		self.inst.AnimState:SetBuild(anims[body][2])
		self.inst:SetStateGraph(graphs[body])
		self.inst.components.talker:IgnoreAll()
		loseEquipped(self.inst)
		-- self.inst.components.inventory:DropEverything()
		self.inst:AddComponent("worker")
		self.inst.components.worker:SetAction(ACTIONS.CHOP, 1)
		self.inst.components.worker:SetAction(ACTIONS.HACK, 1)
		if self:IsHunmanBody(body) then
			self.inst.components.playercontroller.actionbuttonoverride = MorphActionButton
			self.inst.components.playeractionpicker.leftclickoverride = LeftClickPicker
		else
			self.inst.components.playercontroller.actionbuttonoverride = MorphActionButton2
			self.inst.components.playeractionpicker.leftclickoverride = LeftClickPicker2
		end
		self.inst.components.playeractionpicker.rightclickoverride = RightClickPicker
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
	and self.inst.components.monkeymana:GetCurrent()>=20 then
		self.morph_cur = "monkey"
		handlerTags(self.inst, tags[old_body], false)
		handlerTags(self.inst, tags["monkey"], true)
		self.inst.AnimState:SetBank(anims["monkey"][1])
		self.inst.AnimState:SetBuild(anims["monkey"][2])
		self.inst:SetStateGraph(graphs["monkey"])
		self.inst.components.talker:StopIgnoringAll()
		self.inst:RemoveComponent("worker")
		self.inst.components.playercontroller.actionbuttonoverride = nil
		self.inst.components.playeractionpicker.leftclickoverride = nil
		self.inst.components.playeractionpicker.rightclickoverride = nil
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