local Sounds = require "extension/datas/sounds"

local WgUseable = Class(function(self, inst)
	self.inst = inst
	self.right = true
end)

function WgUseable:CanUse(doer)
	if self.test then
		return self.test(self.inst, doer)
	end
	return true
end

function WgUseable:Use(doer)
	if self.use then
		self.use(self.inst, doer)
	end
	if doer.SoundEmitter then
		if self.sound then
			doer.SoundEmitter:PlaySound(self.sound)
		else
			doer.SoundEmitter:PlaySound(Sounds["get_item"])
		end
	end
end

function WgUseable:CollectSceneActions(doer, actions, right)
	if (not right == not self.right) and self:CanUse(doer) then
		table.insert(actions, ACTIONS.WG_USE)
	end
end

function WgUseable:CollectInventoryActions(doer, actions, right)
	-- 不判断right就是右键
	if self:CanUse(doer) then
		table.insert(actions, ACTIONS.WG_USE)
	end
end

return WgUseable