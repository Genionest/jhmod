local FollowText = require "widgets/followtext"
local Image = require "widgets/image"

local FollowImage = Class(FollowText, function(self, atlas, image)
	FollowText._ctor(self, TALKINGFONT, 35)
	self.wg_image = self:AddChild(Image(atlas, image))
end)

function FollowImage:GetWidget()
	return self.wg_image
end

return FollowImage