local function ChangePlayerHUD(show, hud_tbl)
	local player = GetPlayer()
	if player and player.HUD and player.HUD.controls then
		local hud = player.HUD
		local ctrl = hud.controls
		local wid_tbl = {
			ctrl.inv,
			ctrl.crafttabs,
		}
		for i, v in pairs(wid_tbl) do
			if show and v and v.Show then
				v:Show()
			elseif not show and v and v.Hide then
				v:Hide()
			end
		end
	end
end

-- in 1 or 2 or 3
-- inv:{"world", "obs", [] ["wall"]} {"item"}
-- char:{"world", "obs", "char", ["wav"]} {"char"}
-- /{getworld, getwater, "obs", "char", "wav", "wall"} {"char"}(dlc3)
-- gho:{"world", "char",["wav"]} {"char"}
-- obs:{"item", "char", ["wav"], ["wall"]} {"obs"}
-- in 2 or 3
-- under:{"world"} {"char"}/{getworld, getwater} {"char"}(dlc3)
-- amph:{"obs", "char", "wav", ["wall"]} {"char"}
-- amphgho:{"ground", "char", "wav", ["wall"]} {"char"}
-- in 3
-- spgho:{getworld, "char", "wav"} {"char"}
local function ChangePhysics(inst, col_tbl, col_my)
	local phy = inst.Physics or inst.entity:AddPhysics()
	phy:ClearCollisionMask()
	for _, v in pairs(col_tbl) do
		if v == "world" then
			phy:CollidesWith(GetWorldCollision~=nil and GetWorldCollision() or COLLISION.WORLD)
		elseif v == "water" then
			phy:CollidesWith(GetWaterCollision~=nil and GetWaterCollision() or COLLISION.WORLD)
		elseif v == "ground" then  -- 大陆，土地
			phy:CollidesWith(COLLISION.GROUND)
		elseif v == "obs" then
			phy:CollidesWith(COLLISION.OBSTACLES)
		elseif v == "char" then
			phy:CollidesWith(COLLISION.CHARACTERS)
		elseif v == "fly" then  -- 飞行昆虫
			phy:CollidesWith(COLLISION.FLYERS)
		elseif v == "item" then
			phy:CollidesWith(COLLISION.ITEMS)
		elseif v == "wav" then  -- 应该是海洋的边界
			if COLLISION.WAVES ~= nil then
				phy:CollidesWith(COLLISION.WAVES)
			end
		elseif v == "wall" then
			if COLLISION.INTWALL ~= nil then
				phy:CollidesWith(COLLISION.INTWALL)
			end
		end
	end
	-- if col_my == "item" then
	-- 	phy:SetCollisionGroup(COLLISION.ITEMS)
	-- elseif col_my == "char" then
	-- 	phy:SetCollisionGroup(COLLISION.CHARACTERS)
	-- elseif col_my == "obs" then
	-- 	phy:SetCollisionGroup(COLLISION.OBSTACLES)
	-- elseif col_my == "fly" then
	-- 	phy:SetCollisionGroup(COLLISION.FLYERS)
	-- end
end

local function ChangeKeepLand(inst, enable)
	if not enable then
		inst:AddTag("monkey_king_nokeepland")
	else
		inst:RemoveTag("monkey_king_nokeepland")
	end
end

local function IsInDLC(num)
	if num == 1 then
		return SaveGameIndex:IsModeSurvival()
	elseif num == 2 then
		return SaveGameIndex:IsModeShipwrecked()
	elseif num == 3 then
		return SaveGameIndex:IsModePorkland()
	end
end

local function IsMK()
	if GetPlayer() then
		return GetPlayer().prefab == "monkey_king"
	end
end

local function IsInLand(inst)
	return inst:GetIsOnLand()
end

local function IsInWater(inst)
	return inst:GetIsOnWater()
end

GLOBAL.MK_INTENSIFY_UTIL = {
	ChangePlayerHUD = ChangePlayerHUD,
	ChangePhysics = ChangePhysics,
	ChangeKeepLand = ChangeKeepLand,
	IsInDLC = IsInDLC,
	IsMK = IsMK,
	IsInLand = IsInLand,
	IsInWater = IsInWater,
}

local function keepland_fix(self)
	local old_fn = self.OnUpdate
	function self:OnUpdate(dt, ...)
		if self.inst 
		and self.inst:HasTag("monkey_king_nokeepland") then
			return
		else
			old_fn(self, dt, ...)
		end
	end
end

AddComponentPostInit("keeponland", keepland_fix)