local SampleTimer = require "components/mksampletimer"

local CloudTimer = Class(SampleTimer, function(self, inst)
	SampleTimer._ctor(self, inst)
	self.max = 100
	self.current = self.max
	self.name = "cloud"
end)

return CloudTimer