local Badge = require "widgets/badge"

local MadValueBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "beaver_meter", owner)
end)

return MadValueBadge