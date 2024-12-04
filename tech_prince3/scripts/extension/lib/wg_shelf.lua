local WgShelf = Class(function(self, title, unit)
	self.shelf = {}
	self.title = title or ""
	self.unit = unit or 10
	self.cur = 1
	self.max = 0
	self.point = {}
end)

function WgShelf:ClearShelf()
	self.shelf = {}
	self.cur = 1
	self.max = 0
	self.point = {}
end

function WgShelf:AddBar()
	table.insert(self.shelf, {})
	self.max = self.max + 1
	self.point[self.max] = 1
end

function WgShelf:AddItem(item)
	if self.max <= 0 then
		self:AddBar()
	end
	if #self.shelf[self.max] >= self.unit then
		self:AddBar()
	end
	table.insert(self.shelf[self.max], item)
end

function WgShelf:PageTurn(dt)
	self.cur = math.max(1, math.min(self.max, self.cur+dt))
	-- 翻页后指针归为1
	-- self.point = 1
end

function WgShelf:SetPoint(p)
	self.point[self.cur] = p
end

function WgShelf:GetPoint()
	return self.point[self.cur]
end

function WgShelf:GetItems()
	if self.max <= 0 then
		return {}
	else
		return self.shelf[self.cur]
	end
end

function WgShelf:GetAllItems()
	local t = {}
	for k, v in pairs(self.shelf) do
		for k2, v2 in pairs(v) do
			table.insert(t, v2)
		end
	end
	return t
end

function WgShelf:GetItem()
	if self.max > 0 then
		-- 获取具体某一页的坐标
		local point = self.point[self.cur]
		return self.shelf[self.cur][point]
	end
end

function WgShelf:FindItem(page_name)
	for k, v in pairs(self.shelf) do
		for k2, v2 in pairs(v) do
			if v2.title == page_name then
				return v2
			end
		end
	end
end

function WgShelf:GetCurPageItemList()
	return self:GetItems()
end

function WgShelf:GetCurPagePointItem()
	return self:GetItem()
end

function WgShelf:GetAllPageItemMatrix()
	return self.shelf
end

function WgShelf:GetAllPageItemList()
	return self:GetAllItems()
end

function WgShelf:__tostring()
	return string.format("WgShelf %s",self.title)
end

return WgShelf