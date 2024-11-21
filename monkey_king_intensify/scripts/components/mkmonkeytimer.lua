local SampleTimer = require "components/mksampletimer"

local MonkeyTimer = Class(SampleTimer, function(self, inst)
	SampleTimer._ctor(self, inst)
	self.max = 20
	self.current = self.max
	self.name = "monkey"
end)

return MonkeyTimer