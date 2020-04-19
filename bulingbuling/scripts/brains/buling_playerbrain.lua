require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/follow"
require "behaviours/doaction"
require "behaviours/minperiod"
require "behaviours/panic"
require "behaviours/runaway"



local SEE_DIST = 30
local TOOCLOSE = 6
local MIN_FOLLOW_DIST = 5
local TARGET_FOLLOW_DIST = 7
local MAX_FOLLOW_DIST = 10

local RUN_AWAY_DIST = 7
local STOP_RUN_AWAY_DIST = 15

local SEE_FOOD_DIST = 10

local MAX_WANDER_DIST = 20

local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 40

local TIME_BETWEEN_EATING = 30

local LEASH_RETURN_DIST = 15
local LEASH_MAX_DIST = 20
local function HasStateTags(inst, tags)
    for k,v in pairs(tags) do
        if inst.sg:HasStateTag(v) then
            return true
        end
    end
end
local ValidFoodsToPick = 
{
    "berries",
    "cave_banana",
    "carrot",   
    "red_cap",
    "blue_cap",
    "green_cap", 
	"twigs",
	"petals",
	"cutgrass",
}

local function ItemIsInList(item, list)
    for k,v in pairs(list) do
        if v == item or k == item then
            return true
        end
    end
end
local function StartWorkingCondition(inst, actiontags)
    return  not HasStateTags(inst, actiontags)
end

local function GetEntsToSteal(inst)
	local player = GetPlayer()
	local pt = inst:GetPosition()
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, SEE_DIST, nil, {"aquatic", "irreplaceable", "prey", "bird", "FX"})

	for _, item in pairs(ents) do
		if item.components.inventoryitem and 
			item.components.inventoryitem.canbepickedup and 
			not item.components.inventoryitem:IsHeld() and
			item:IsOnValidGround() and 			
			not item.onshelf then

			if not item.components.shelfer or item.components.shelfer.shelf:HasTag("playercrafted") then
				return item			
			end
		end
	end
end
local function FindObjectToWorkAction(inst, action)
    if inst.sg:HasStateTag("working") then
        return 
    end
    
    local target = nil
    local notags = {"FX", "NOCLICK", "DECOR","INLIMBO"}
    if action == ACTIONS.HACK then
        target = FindEntity(inst, 10, function(item) return item.components.hackable and item.components.hackable.hacksleft > 0 end, nil, notags)
	elseif action == ACTIONS.DIG then
		target = FindEntity(inst, 10, function(item) return item.components.workable and item.components.workable.action == action and item:HasTag("stump") and not item.components.hackable end, nil, notags)
    else
        target = FindEntity(inst, 10, function(item) return item.components.workable and item.components.workable.action == action end, nil, notags)
    end
    if target then
        --print(GetTime(), target)
        return BufferedAction(inst, target, action)
    end
end
local function StealAction(inst)
	if not inst.components.inventory:IsFull() then
		local item = GetEntsToSteal(inst)
		if item then
			return BufferedAction(inst, item, ACTIONS.PICKUP)
		end
	end
end
local function EatFoodAction(inst)

    local target = nil

    if inst.sg:HasStateTag("busy") or 
    (inst.components.eater:TimeSinceLastEating() and inst.components.eater:TimeSinceLastEating() < TIME_BETWEEN_EATING) or
    (inst.components.inventory and inst.components.inventory:IsFull()) then
        return
    end

    if inst.components.inventory and inst.components.eater then

        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        if target then return BufferedAction(inst,target,ACTIONS.EAT) end
    end

    --Get the stuff around you and store it in ents
    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, SEE_FOOD_DIST)  


    --If you're not wearing a hat, look for a hat to wear!
    if not target then
        for _,item in ipairs(ents) do
            if (not item:HasTag("aquatic")) and 
             item.components.equippable and 
             item.components.equippable.equipslot == EQUIPSLOTS.HEAD and
             (inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)) and
             (item.components.inventoryitem and not (item.components.inventoryitem:IsHeld() or not item.components.inventoryitem.canbepickedup)) and
             item:IsOnValidGround() then
                target = item
                break
            end
        end
    end

    if target then
        --Alright, yeah! That's - no that's a pretty good job!
        return BufferedAction(inst,target,ACTIONS.PICKUP)
    end

    --Look for food on the ground, pick it up
    if not target then
        for i,item in ipairs(ents) do
            if item:GetTimeAlive() > 8 and inst.components.eater:CanEat(item) and not (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) and not item:HasTag("aquatic") and item:IsOnValidGround() then
                target = item
                break
            end
        end
    end

    if target then
        return BufferedAction(inst,target,ACTIONS.PICKUP)
    end

    --Look for harvestable items, pick them.
    if not target then
        for i,item in ipairs(ents) do
            if item.components.pickable and item.components.pickable.caninteractwith and item.components.pickable:CanBePicked() and not item:HasTag("aquatic") 
            and (ItemIsInList(item.components.pickable.product, ValidFoodsToPick) or item.prefab == "worm") then
                target = item
                break
            end
        end
    end

    if target then
        return BufferedAction(inst, target, ACTIONS.PICK)
    end

    --Look for crops items, harvest them.
    if not target then
        for i,item in ipairs(ents) do
            if item.components.crop and item.components.crop:IsReadyForHarvest() and not item:HasTag("aquatic")  then
                target = item
                break
            end
        end
    end

    if target then
        return BufferedAction(inst, target, ACTIONS.HARVEST)
    end

    if not inst.curious or inst.components.combat.target then
        return
    end

    ---At the very end, look for a random item to pick up and do that.
    if not target then

        for i,item in ipairs(ents) do
            if item.components.inventoryitem and item.components.inventoryitem.canbepickedup and not item:HasTag("irreplaceable") and not
                item.components.inventoryitem:IsHeld() and not item:HasTag("aquatic") and
                item:IsOnValidGround() then
                target = item
                break
            end
        end
    end

    if target then
        inst.curious = false
        inst:DoTaskInTime(10, function() inst.curious = true end)
        return BufferedAction(inst,target,ACTIONS.PICKUP)
    end

end
local function EmptyChest(inst)
	local notags = {"FX", "NOCLICK", "DECOR","INLIMBO"}
	if not inst.components.inventory:IsFull() and inst:HasTag("pirate") then
		local target = FindEntity(inst, SEE_DIST, function(item) 
			if (item.components.workable and item.components.workable.workleft > 0 and  item:HasTag("structure") ) then
					return true 
				end
			end, nil, notags)
		if target then
			return BufferedAction(inst, target, ACTIONS.HAMMER)
		end
	end
end
local function BuildChest(inst)
	print("找家")
	local notags = {"FX", "NOCLICK", "DECOR","INLIMBO"}
		local target = FindEntity(inst, 100, function(item) 
			if item:HasTag("buling_yingdi") then
			
					return true 
				end
			end, nil, notags)
		if target then
			print("选家")
			inst.components.follower.leader = target
			elseif not inst:HasTag("cd") then
			inst:AddTag("cd")
			inst:DoTaskInTime(5,function() if inst:HasTag("cd") then inst:RemoveTag("cd") end end)
			local firerain = SpawnPrefab("firerain")
			local pt = Vector3(inst.Transform:GetWorldPosition())
			firerain.Transform:SetPosition(pt.x+8, pt.y, pt.z+8)
			firerain:StartStep()
			local jidi = SpawnPrefab("buling_jidi")
			jidi.Transform:SetPosition(pt.x+8, pt.y, pt.z+8)
			jidi:Hide()
			jidi:DoTaskInTime(1.9,function()
			jidi:Show()
			local pos = Vector3(jidi.Transform:GetWorldPosition())
			local ents = TheSim:FindEntities(pos.x,pos.y,pos.z,15)
				for k,v in pairs(ents) do
					if v and v.prefab == "lavapool"  then
						v:Remove()
					end
				end
			end)
		end
end
local function GoHomeAction(inst)
    if inst.components.follower.leader ~= nil and not inst.sg:HasStateTag("trapped") and not inst.components.follower.leader.components.inventory:IsFull() then
        return BufferedAction(inst, inst.components.follower.leader, ACTIONS.GOHOME)
    end
end
local MIN_FOLLOW = 10
local MAX_FOLLOW = 20
local MED_FOLLOW = 15

local MIN_RUNAWAY = 8
local MAX_RUNAWAY = MED_FOLLOW

local buling_playerbrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
	self.greed = 2 + math.random(4)
end)

function buling_playerbrain:OnStart()
	local clock = GetClock()

	local root = PriorityNode(
	{	
		WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
		ChaseAndAttack(self.inst, 100),	
		WhileNode(function() return  self.inst.components.follower.leader == nil end, "造家",
            DoAction(self.inst, BuildChest)),
		WhileNode(function() return  self.inst.components.combat.target == nil end, "捡东西",
            DoAction(self.inst, StealAction)),
		WhileNode(function() return self.inst.components.inventory:IsFull() and self.inst.components.follower.leader ~= nil end, "回家放东西",
            DoAction(self.inst, GoHomeAction)),
		WhileNode(function() return  self.inst.components.combat.target == nil end, "抢东西",
            DoAction(self.inst, EatFoodAction)),
		WhileNode(function() return StartWorkingCondition(self.inst, {"digging", "predig"})end, "挖树",
            DoAction(self.inst, function() return self.inst.components.combat.target == nil and FindObjectToWorkAction(self.inst, ACTIONS.DIG) end)),
		WhileNode(function() return StartWorkingCondition(self.inst, {"chopping", "prechop"})end, "砍树",
            DoAction(self.inst, function() return self.inst.components.combat.target == nil and FindObjectToWorkAction(self.inst, ACTIONS.CHOP) end)),
		WhileNode(function() return StartWorkingCondition(self.inst, {"mining", "premine"})end, "挖矿",
            DoAction(self.inst, function() return self.inst.components.combat.target == nil and FindObjectToWorkAction(self.inst, ACTIONS.MINE) end)),
		WhileNode(function() return StartWorkingCondition(self.inst, {"hacking", "prehack"})end, "劈砍",
            DoAction(self.inst, function() return self.inst.components.combat.target == nil and FindObjectToWorkAction(self.inst, ACTIONS.HACK) end)),
		WhileNode(function() return  self.inst.components.combat.target == nil end, "锤建筑",
            DoAction(self.inst, EmptyChest)),
		WhileNode(function() return clock and not clock:IsNight() end, "IsNotNight",
		Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)),
		Follow(self.inst, function() return self.inst.components.follower.leader end, 1, 20, 40, true),			
		--[[IfNode( function() return self.inst.components.inventory:NumItems() >= self.greed and not self.inst.sg:HasStateTag("busy") end, "donestealing",
			ActionNode(function() self.inst.sg:GoToState("exit") return SUCCESS end, "leave" )),]]
								
	}, .1+math.random(0,0.5))
	self.bt = BT(self.inst, root)
   
end

return buling_playerbrain
