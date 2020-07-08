local GroundPounder = require "components/groundpounder"

local TpGroundPounder = Class(GroundPounder, function(self, inst)
	GroundPounder._ctor(self, inst)
	table.insert(self.noTags, "player")
	self.range = 3
end)

-- function TpGroundPounder:DestroyPoints(points, breakobjects, dodamage)
-- 	local getEnts = breakobjects or dodamage

-- 	for k,v in pairs(points) do

-- 		local ents = nil
-- 		if getEnts then
-- 			ents = TheSim:FindEntities(v.x, v.y, v.z, self.range, nil, self.noTags)
-- 		end
-- 		if ents and breakobjects then
-- 		    -- first check to see if there's crops here, we want to work their farm
-- 		    for k2,v2 in pairs(ents) do
-- 		        if v2 and self.burner and v2.components.burnable and not v2:HasTag("fire") and not v2:HasTag("burnt") then
-- 		        	v2.components.burnable:Ignite()
-- 		        end
-- 		    	-- Don't net any insects when we do work
-- 		        if v2 and self.destroyer and v2.components.workable and v2.components.workable.workleft > 0 and v2.components.workable.action ~= ACTIONS.NET then
-- 	        	    v2.components.workable:Destroy(self.inst)
-- 			end
-- 		        if v2 and self.destroyer and v2.components.crop then
-- 			    	print("Has Crop:",v2)
-- 	        	    v2.components.crop:ForceHarvest()
-- 				end
-- 		    end
-- 		end
-- 		if ents and dodamage then
-- 		    for k2,v2 in pairs(ents) do
-- 		    	if not self.ignoreEnts then 
-- 		    		self.ignoreEnts = {}
-- 		    	end 
-- 		    	if not self.ignoreEnts[v2.GUID] then --If this entity hasn't already been hurt by this groundpound

-- 			        if v2 and v2.components.health and not v2.components.health:IsDead() and 
-- 			        self.inst.components.combat:CanTarget(v2) then
-- 			            self.inst.components.combat:DoAttack(v2, nil, nil, nil, self.groundpounddamagemult)
-- 			        end
-- 			        self.ignoreEnts[v2.GUID] = true --Keep track of which entities have been hit 
-- 			    end 
-- 		    end
-- 		end

-- 		local map = GetMap()
-- 		if map then
-- 			local ground = map:GetTileAtPoint(v.x, 0, v.z)

-- 			if ground == GROUND.IMPASSABLE or map:IsWater(ground) then
-- 				--Maybe do some water fx here?
-- 			else
-- 				if self.groundpoundfx then 
-- 					SpawnPrefab(self.groundpoundfx).Transform:SetPosition(v.x, 0, v.z)
-- 				end 
-- 			end
-- 		end
		
-- 	end
-- end

return TpGroundPounder
