local SkillManager = Class(function(self, inst)
	self.inst = inst
	self.skill = {
		none = nil,
	}
	self.skill_mana = {
		none = 0,
	}
end)

function SkillManager:AddSkill(k, fn)
	self.skill[k] = fn
end

function SkillManager:GetSkill(k)
	return self.skill[k]
end

function SkillManager:SetSkillMana(k, amount)
	self.skill_mana[k] = amount
end

function SkillManager:GetSkillMana(k)
	return self.skill_mana[k]
end

return SkillManager