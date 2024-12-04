local Sounds = require "extension/datas/sounds"

local WgMachine = Class(function(self,inst)
    self.inst = inst
    self.right = true
end)

function WgMachine:Test(doer)
    -- 被淹没不可操作
    if self.inst:HasTag("flooded") then
        return
    end
    if self.test then
        return self.test(self.inst, doer)
    end
    return true
end

function WgMachine:Use(doer)
    if self.fn then
        self.fn(self.inst, doer)
    end
    if doer.SoundEmitter then
        doer.SoundEmitter:PlaySound(Sounds["turn_on"])
    end
end

function WgMachine:CollectSceneActions(doer, actions, right)
    if right == self.right and self:Test(doer) then
        table.insert(actions, ACTIONS.WG_OPERATE)
    end
end

return WgMachine