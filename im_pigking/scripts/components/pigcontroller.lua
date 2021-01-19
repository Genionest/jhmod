local FollowImageButton = require "widgets/follow_image_button"

local PigController = Class(function(self, inst)
	self.inst = inst
	self.tasks = {}
	self.offset = Vector3(0, -400, 0)
end)

function PigController:Follow(doer)
	doer.components.leader:AddFollower(self.inst)
	self.inst.components.follower:AddLoyaltyTime(1200)
end

function PigController:NoFollow()
	self.inst.components.follower:SetLeader(nil)
end

function PigController:AddTagInTime(tag, time)
	if self.tasks[tag] then
		self.tasks[tag]:Cancel()
		self.tasks[tag] = nil
	end
	self.inst:AddTag(tag)
	self.tasks[tag] = self.inst:DoTaskInTime(time, function()
		self.inst:RemoveTag(tag)
	end)
end

function PigController:GiveUp()
	self.inst.components.combat:SetTarget(nil)
	self.inst:RemoveTag("must_attack")
	self.inst:RemoveTag("must_chop_tree")
end


local btns = {
	{
		img = "nightstick.tex",
		fn = function(skill, cmp)
			skill:UseSkill("thunder_fist")
			cmp:Off()
		end,
	},
	{
		img = "ruinshat.tex",
		fn = function(skill, cmp)
			skill:UseSkill("sheild")
			cmp:Off()
		end,
	},
}
function PigController:On()
	if not self.widget then
		self.widget = GetPlayer().HUD:AddChild(FollowImageButton(
			"images/inventoryimages.xml", "axe.tex"
		))
		self.widget:SetOffset(self.offset)
		self.widget:SetTarget(self.inst)
		self.widget:SetButtons(btns, self.inst.components.pigskill, self)
		-- self.widget:SetOnClick(function()
		-- 	self:AddTagInTime("must_chop_tree", TUNING.PIGKING.time)
		-- 	self:Off()
		-- end)
		self.on_task = self.inst:DoTaskInTime(5, function()
			self:Off()
		end)
	end
end

function PigController:Off()
	if self.on_task then
		self.on_task:Cancel()
		self.on_task = nil
	end
	if self.widget then
		self.widget:Kill()
		self.widget = nil
	end
end

function PigController:OnRemoveEntity()
	self:Off()
end

return PigController