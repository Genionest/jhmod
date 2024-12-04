local WgInfo = Class(function(self, inst)
    self.inst = inst
    self.info = nil
end)

function WgInfo:GetWargonString()
    if type(self.info) == "function" then
        return self.info(self.inst)
    else
        return self.info
    end
end

function WgInfo:GetWargonStringColour()
    if type(self.colour) == "function" then
        return self.colour(self.inst)
    else
        return self.colour
    end
end

return WgInfo