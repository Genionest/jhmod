local FollowText = require "widgets/followtext"
local Image = require "widgets/image"

local TpFollowImage = Class(FollowText, function(self, atlas, image)
	FollowText._ctor(self, TALKINGFONT, 35)
	self.tp_image = self:AddChild(Image(atlas, image))
end)

return TpFollowImage