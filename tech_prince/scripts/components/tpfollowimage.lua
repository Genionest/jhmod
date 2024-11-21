local TpImg = require "widgets/tp_follow_image"

local TpFollowImage = Class(function(self, inst)
	self.inst = inst
end)

function TpFollowImage:SetImage(atlas, img)
	WARGON.do_task(self.inst, .1, function()
		if self.widget == nil then
			if GetPlayer().HUD then
				self.widget = GetPlayer().HUD:AddChild(TpImg(atlas, img))
				self.widget:SetOffset(self.offset or Vector3(0, -80, 0))
				self.widget:SetTarget(self.inst)
			end
		end
	end)
end

function TpFollowImage:Kill()
	if self.widget then
		self.widget:Kill()
		self.widget = nil
	end
end

function TpFollowImage:OnRemoveEntity()
	self:Kill()
end

return TpFollowImage