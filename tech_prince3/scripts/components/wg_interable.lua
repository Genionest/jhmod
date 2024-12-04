local Sounds = require "extension/datas/sounds"

local WgInterable = Class(function(self, inst)
	self.inst = inst
end)

function WgInterable:SetFn(fn)
	self.interact_fn = fn
end

function WgInterable:SetTestFn(fn)
	self.test = fn
end

function WgInterable:CanInteract(item, doer)
	if self.test then
		return self.test(self.inst, item, doer)
	end
	return true
end

function WgInterable:Interact(item, doer)
	if self.interact_fn then
		self.interact_fn(self.inst, item, doer)
	end
	if item.components.wg_interable_item
	and item.components.wg_interable_item.interact_fn then
		item.components.wg_interable_item.interact_fn(item, self.inst, doer)
	end
	if doer.SoundEmitter then
		doer.SoundEmitter:PlaySound(Sounds["get_item"])
	end
end

return WgInterable