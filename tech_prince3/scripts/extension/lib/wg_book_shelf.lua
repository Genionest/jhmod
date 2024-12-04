local WgShelf = require "extension.lib.wg_shelf"
local Util = require "extension.lib.wg_util"

local BookData = Class(WgShelf, function(self, title)
	WgShelf._ctor(self, title, 11)
	self.limit = 18
end)

function BookData:AddItem(str)
	if self.max <= 0 then
		self:AddBar()
	end
	if #self.shelf[self.max] >= self.unit then
		self:AddBar()
	end
    local t = Util:SplitSentence(str, self.limit)
    for k, v in pairs(t) do
        table.insert(self.shelf[self.max], v)
    end

end

function BookData:GetString()
	local str = nil
	for k, v in pairs(self:GetItems()) do
		if not str then
			str = v.."\n"
		else
			str = str..v.."\n"
		end
	end
	str = string.sub(str, 1, -2)
	return str
end

function BookData:__tostring()
	return string.format("BookData %s",self.title)
end

local BookShelf = Class(WgShelf, function(self, name)
	WgShelf._ctor(self, name, 8)
end)

function BookShelf:Print()
    print("Menu")
	for k, v in pairs(self:GetItems()) do
		print(v.title)
	end
	print("Mini Menu")
	for k, v in pairs(self:GetItem():GetItems()) do
		print(v.title)
	end
	print("Book")
	local book = self:GetItem():GetItem()
	print(book:GetString())
end

function BookShelf:ShelfPageTurn(dt)
	local shelf = self:GetItem()
	shelf:PageTurn(dt)
end

function BookShelf:BookPageTurn(dt)
	local book = self:GetItem():GetItem()
	book:PageTurn(dt)
end

function BookShelf:AddShelfs(shelfs)
    for k, v in pairs(shelfs) do
        local shelf = nil
        for k2, v2 in pairs(v) do
            if k2 == 1 then
                shelf = WgShelf(v2, 10)
            else
                local book = BookData(v2[1])
                for k3, v3 in pairs(v2) do
                    if k3 > 1 then
                        book:AddItem(v3)
                    end
                end
                shelf:AddItem(book)
            end
        end
        self:AddItem(shelf)
    end
end

function BookShelf:__tostring()
    return string.format("BookShelf %s",self.title)
end

return BookShelf