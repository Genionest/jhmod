local function handler_cmp_action(typ, cmp, fn)
	AddComponentPostInit(cmp, function(self)
		if typ == "scene" then
			self:CollectSceneActions = function(doer, actions, right)
				return fn(self, doer, actions, right)
			end
		end
	end)
end

local function cmp_action(typ, cmp, fn)
	handler_cmp_actino(typ, cmp, fn)
end

local GLOBAL.WARGON_ACTION_EX = {
	cmp_action = cmp_action,
}
local GLOBAL.WARGON.ACTION = GLOBAL.WARGON_ACTION_EX