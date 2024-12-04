local EntUtil = require "extension.lib.ent_util"

local AkTreeTable = Class(function(self, inst)
    self.inst = inst
end)

function AkTreeTable:Test()
    local x, y, z = self.inst:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 1, {"tree"}, 
        EntUtil.constants.not_entity_tags
    )
    return #ents<=0
end

function AkTreeTable:Plant(seed, doer)
    if seed and seed.components.deployable then
        if seed.components.stackable then
            seed = seed.components.stackable:Get()
        end
        local inst = self.inst
        local pos = inst:GetPosition()
        local pt = pos
        local deployer = doer
        local cmp = seed.components.deployable
        if cmp.ondeploy then
	        cmp.ondeploy(cmp.inst, pt, deployer)
		end
        if cmp.inst:HasTag("plant") and deployer:HasTag("plantkin") then
            if deployer.growplantfn then
                deployer.growplantfn(deployer)
            end
        end
    end
end

return AkTreeTable