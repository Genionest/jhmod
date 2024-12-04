local WgStart = Class(function(self, inst)
    self.inst = inst
    -- self.on_start = nil
    self.init = nil
    self.fns = nil
    self.delay = 0
    self.inst:DoTaskInTime(self.delay, function()
        if not self.init then
            self.init = true
            if self.on_start then
                self.on_start(self.inst)
            end
            if self.fns then
                for _, fn in ipairs(self.fns) do
                    fn(self.inst)
                end
            end
        end
    end)
end)

function WgStart:AddFn(fn)
    if not self.fns then
        self.fns = {}
    end
    table.insert(self.fns, fn)
end

function WgStart:OnSave()
    return {
        init = self.init,
    }
end

function WgStart:OnLoad(data)
    if data then
        self.init = data.init
    end
end

return WgStart