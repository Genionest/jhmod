local GroundPounder = require "components/groundpounder"

local TpGroundPounder = Class(GroundPounder, function(self, inst)
	GroundPounder._ctor(self, inst)
	table.insert(self.noTags, "player")
end)

return TpGroundPounder
