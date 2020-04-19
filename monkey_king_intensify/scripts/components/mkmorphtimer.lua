local SampleTimer = require "components/mksampletimer"

local MorphTimer = Class(SampleTimer, function(self, inst)
	SampleTimer._ctor(self, inst)
	self.max = 20
	self.current = self.max
	self.name = "morph"
end)

return MorphTimer