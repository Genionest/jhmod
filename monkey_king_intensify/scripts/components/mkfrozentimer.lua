local SampleTimer = require "components/mksampletimer"

local FrozenTimer = Class(SampleTimer, function(self, inst)
	SampleTimer._ctor(self, inst)
	self.max = 50
	self.current = self.max
	self.name = "frozen"
end)

return FrozenTimer