local attr = {
	max_hp = {250, 100, 450},
	armor = {0, .1, .2},
	dmg = {0, .1, .2},
	speed = {0, .1, .2},
}

local PigTechTree = Class(function(self, inst)
	self.inst = inst
	self.attr = {}
	for k, v in pairs(attr) do
		self.attr[k] = v[1]
	end
end)

function PigTechTree:AddAttr(name)
	if self.attr[name] < attr[name][3] then
		self.attr[name] = self.attr[name] + attr[name][2]
		self.inst:PushEvent("pig_tech_tree_change", {
			name = name,
			value = self.attr[name],	
		})
	end
end

function PigTechTree:GetAttr(name)
	return self.attr[name]
end

function PigTechTree:OnSave()
	local data = deepcopy(self.attr)
	return data
end

function PigTechTree:OnLoad(data)
	if data then
		for k, v in pairs(data) do
			self.attr[k] = v
		end
	end
end

return PigTechTree