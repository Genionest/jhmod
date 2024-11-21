AddComponentPostInit('builder', function(self)
	local old_can = self.CanBuild
	function self:CanBuild(recname,...)
    	if self.freebuildmode then
        	return true
    	end

    	local recipe = GetRecipe(recname)
    	if recipe and recipe.wargon_test and not recipe.wargon_test(self.inst) then
    		return false
    	end
    	return old_can(self,recname,...)
    end
end)