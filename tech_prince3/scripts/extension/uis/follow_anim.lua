local FollowText = require "widgets/followtext"
local UIAnim = require "widgets/uianim"

local FollowAnim = Class(FollowText, function(self, atlas, image)
	FollowText._ctor(self, TALKINGFONT, 35)
	self.wg_anim = self:AddChild(UIAnim())
end)

return FollowAnim