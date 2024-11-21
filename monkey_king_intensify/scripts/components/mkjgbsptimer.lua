local SampleTimer = require "components/mksampletimer"

local JGBSpTimer = Class(SampleTimer, function(self, inst)
	SampleTimer._ctor(self, inst)
	self.max = 60
	self.current = self.max
	self.name = "jgbsp"
end)

return JGBSpTimer