local AkEditor = Class(function(self, inst)
    self.inst = inst
    self.text = nil
end)

function AkEditor:SetText(text)
    self.text = text
end

function AkEditor:GetText()
    return self.text
end

function AkEditor:OnSave()
    return {
        text = self.text
    }
end

function AkEditor:OnLoad(data)
    if data then
        self.text = data.text
    end
end

function AkEditor:GetWargonString()
    if self.text then
        return string.format("文本：%s", self.text)
    end
end

return AkEditor