local Widget = require "widgets/widget"
local Sample = require "widgets/mk_sample_ui2"

local Mk_Skill_UI = Class(Widget, function(self, owner)
	Widget._ctor(self, "Mk_Skill_UI")
	self.owner = owner

	self.morph = self:AddChild(Sample(owner, "morph"))
	self.monkey = self:AddChild(Sample(owner, "monkey"))
	self.back = self:AddChild(Sample(owner, "back"))
	self.cloud = self:AddChild(Sample(owner, "cloud"))
	self.frozen = self:AddChild(Sample(owner, "frozen"))
	self.jgbsp = self:AddChild(Sample(owner, "jgbsp", "jgb"))
	self.morph:SetPosition(0, 0, 0)
	self.monkey:SetPosition(0, 70, 0)
	self.back:SetPosition(-70, 0, 0)
	self.cloud:SetPosition(-70, 70, 0)
	self.frozen:SetPosition(-140, 0, 0)
	self.jgbsp:SetPosition(-140, 70, 0)
	self.morph:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.morph.skill))
	self.monkey:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.monkey.skill))
	self.back:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.back.skill))
	self.cloud:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.cloud.skill))
	self.frozen:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.frozen.skill))
	self.jgbsp:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.jgbsp.skill))

	self.inst:ListenForEvent("mk_skill_delta", function(inst, data)
		self:SetSkillPercent(data)
	end, self.owner)
end)

function Mk_Skill_UI:SetSkillPercent(data)
	if data.name and data.percent then
		self[data.name]:SetPercent(data.percent)
	end
end

return Mk_Skill_UI