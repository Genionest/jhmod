local SampleTimer = require "components/mksampletimer"

local BackTimer = Class(SampleTimer, function(self, inst)
	SampleTimer._ctor(self, inst)
	self.max = 10
	self.current = self.max
	self.name = "back"
end)

return BackTimer