local TpLevel = Class(function(self, inst)
	self.inst = inst
	self.level = 1
	self.max = 10
	self.exp = 0
	local old_eat = inst.components.eater.oneatfn
	inst.components.eater.oneatfn = function(inst, food)
		if old_eat then old_eat(inst, food) end
		if food:HasTag("tplevel_food") then
			inst.components.tplevel:LevelUp()
		end
		if food:HasTag("tplevel_food_small") then
			inst.components.tplevel:ExpUp()
		end
	end
end)

local levels = {
	{health=100, san=100, hunger=100, dmg=-.25},  -- 1
	{health=125, san=100, hunger=100, dmg=-.25},
	{health=125, san=125, hunger=100, dmg=-.25},
	{health=125, san=125, hunger=125, dmg=-.25},
	{health=125, san=125, hunger=125, dmg=0.00},
	{health=150, san=125, hunger=125, dmg=0.00},
	{health=150, san=150, hunger=125, dmg=0.00},
	{health=150, san=150, hunger=150, dmg=0.00},
	{health=150, san=175, hunger=150, dmg=0.00},
	{health=150, san=200, hunger=150, dmg=0.00},
}

function TpLevel:ApplyUpGrade()
	local inst = self.inst
	local attribute = levels[self.level]
	if attribute.health then
		inst.components.health:DoDelta(1000)
		inst.components.health:SetMaxHealth(attribute.health)
		inst.components.health:DoDelta(0)
	end
	if attribute.hunger then
		inst.components.hunger:DoDelta(1000)
		inst.components.hunger:SetMax(attribute.hunger)
		inst.components.hunger:DoDelta(0)
	end
	if attribute.san then
		inst.components.sanity:DoDelta(1000)
		inst.components.sanity:SetMax(attribute.san)
		inst.components.sanity:DoDelta(0)
	end
	if attribute.dmg then
		inst.components.combat:AddDamageModifier("tplevel", attribute.dmg)
	end
end

function TpLevel:ExpUp()
	local cur = self.exp + 1
	self.exp = math.max(0, cur)
	if self.exp >= 20 then
		self.exp = 0
		self:LevelUp()
	end
end

function TpLevel:LevelUp()
	if self.level < self.max then
		local cur = self.level + 1
		self.level = math.max(1, cur)
		self:ApplyUpGrade()
		WARGON.make_fx(self.inst, "multifirework_fx")
	end
end

function TpLevel:OnSave()
	return {level=self.level, exp=self.exp}
end

function TpLevel:OnLoad(data)
	if data then
		self.level = data.level or 1
		self.exp = data.exp or 0
		self:ApplyUpGrade()
	end
end

return TpLevel