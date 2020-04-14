require "behaviours/wander"
require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/findlight"
require "behaviours/panic"
require "behaviours/chattynode"
require "behaviours/leash"

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 5
local MAX_FOLLOW_DIST = 9
local MAX_WANDER_DIST = 20

local LEASH_RETURN_DIST = 10
local LEASH_MAX_DIST = 30

local START_FACE_DIST = 6
local KEEP_FACE_DIST = 8
local START_RUN_DIST = 3
local STOP_RUN_DIST = 5
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30
local SEE_LIGHT_DIST = 20
local TRADE_DIST = 20
local SEE_TREE_DIST = 15
local SEE_TARGET_DIST = 20
local SEE_FOOD_DIST = 10

local KEEP_CHOPPING_DIST = 10

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8

local function FindGold(inst)
	local target = nil
	if not inst:HasTag("agong") then
		target = FindEntity(inst, SEE_FOOD_DIST, 
			function(item)
				return item.prefab == "goldnugget"
			end)
	end
	if target then
		return BufferedAction(inst, target, ACTIONS.PICKUP)
	end
end

-- local function GetKingdomPos(inst)
-- 	local pigking = c_find("pigking")
-- 	return Point(pigking.Transform:GetWorldPosition())
-- end

local PigkingGamerBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function PigkingGamerBrain:OnStart()
	local root = PriorityNode({
		WhileNode(function()
			return self.inst:HasTag("game_start")
		end, "Game Start",
			PriorityNode({
				ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),
				DoAction(self.inst, FindGold ),
				-- Wander(self.inst, GetKingdomPos, MAX_WANDER_DIST)
			}, .5)
		)
	}, .5)
	self.bt = BT(self.inst, root)
end

return PigkingGamerBrain