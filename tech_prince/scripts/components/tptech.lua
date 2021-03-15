local TpTech = Class(function(self, inst)
	self.inst = inst
	self.unlock = {}
	self.near = false
	self.tech = nil
	self.inst:StartUpdatingComponent(self)    
end)

function TpTech:AddTech(tech)
	for k, v in pairs(self.unlock) do
		if v == tech then
			return
		end
	end
	table.insert(self.unlock, tech)
end

function TpTech:Has(techtree)
	for k, v in pairs(self.unlock) do
		if v == techtree then
			return true
		end
	end
	return false
end

-- function TpTech:RefreshRecipe(is_near, techtree)
function TpTech:RefreshRecipe(techtree)
	local recipes = GetAllRecipes(true)
	for k, v in pairs(recipes) do
		if v.tp_tech then
			-- if is_near and self.unlock then
			if techtree and techtree == v.tp_tech then
				v.level.SCIENCE = 0
			else
				v.level.SCIENCE = 9
			end
		end
	end
end

function TpTech:OnUpdate(dt)
	local inst = self.inst
	local range = TUNING.RESEARCH_MACHINE_DIST
	local machine = WARGON.find(inst, range, nil, {"tp_tech_machine"})
	-- local is_near = false
	local can_re = false
	local techtree = nil
	if machine then
		-- is_near = true
		techtree = machine.components.tptechmachine.tech
	end
	-- if is_near ~= self.near then
	if self.tech ~= techtree then
		-- self.near = is_near
		local can_re = false
		-- techtree 接近或远离，self.tech 原来的科技
		if self.tech == nil and self:Has(techtree) 
		or self:Has(self.tech) then
			can_re = true
		end
		self.tech = techtree
		if can_re then
			-- self:RefreshRecipe(is_near, techtree)
			self:RefreshRecipe(techtree)
			inst:PushEvent("techtreechange", {tp_reason=techtree})
		-- inst:PushEvent("techtreechange", {tp_reason="pigking"})
		end
	end
end

function TpTech:OnSave()
	return {unlock = self.unlock}
end

function TpTech:OnLoad(data)
	if data then
		if type(data.unlock) == "table" then
			self.unlock = data.unlock
		elseif data.unlock == true then
			self.unlock = {'pigking'}
		else
			self.unlock = {}
		end
	end
end

return TpTech