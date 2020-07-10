local TpTech = Class(function(self, inst)
	self.inst = inst
	self.unlock = false
	self.near = false
	self.inst:StartUpdatingComponent(self)    
end)

function TpTech:RefreshRecipe(is_near)
	local recipes = GetAllRecipes(true)
	for k, v in pairs(recipes) do
		if v.pigking then
			-- print(v.name)
			if is_near and self.unlock then
				v.level.SCIENCE = 0
			else
				v.level.SCIENCE = 9
			end
		end
	end
end

function TpTech:OnUpdate(dt)
	if not self.unlock then
		return
	end
	local inst = self.inst
	local range = TUNING.RESEARCH_MACHINE_DIST
	local pigking = WARGON.find(inst, range, nil, {"tp_pigking_tech"})
	local is_near = false
	if pigking then
		is_near = true
	end
	-- if is_near ~= self.near then
	-- 	if is_near then
	-- 		inst:AddTag("pig_builder")
	-- 		inst.HUD.controls.crafttabs:UpdateRecipes()
	-- 	else
	-- 		inst:RemoveTag('pig_builder')
	-- 		inst.HUD.controls.crafttabs:UpdateRecipes()
	-- 	end
	-- 	self.near = is_near
	-- end
	if is_near ~= self.near then
		self:RefreshRecipe(is_near)
		self.near = is_near
		inst:PushEvent("techtreechange", {tp_reason="pigking"})
		-- inst.HUD.controls.crafttabs:UpdateRecipes()
	end
end

function TpTech:OnSave()
	return {unlock = self.unlock}
end

function TpTech:OnLoad(data)
	if data then
		self.unlock = data.unlock or false
	end
end

return TpTech