local SkillManager = Class(function(self, inst)
	self.inst = inst
	self.skill = {
		none = nil,
	}
	self.skill_mana = {
		none = 0,
	}
	self.can = true
end)

function SkillManager:Turn(on)
	self.can = on
end

function SkillManager:IsEnabled()
	return self.can
end

function SkillManager:AddSkill(k, fn)
	self.skill[k] = fn
	-- print("skillmanager addskill:", k, need)
	-- self.skill[k].fn = mk_fn
	-- self.skill[k].mana = need
end

function SkillManager:GetSkill(k)
	return self.skill[k]
end

function SkillManager:SetSkillMana(k, amount)
	self.skill_mana[k] = amount
end

function SkillManager:GetSkillMana(k)
	return self.skill_mana[k]
	-- print("skillmanager getskillmana:", k, self.skill[k].mana)
	-- return self.skill[k].mana
end

return SkillManager