local TpTrinity = Class(function(self, inst)
	self.inst = inst
	self.builds = {}
	self.images = {}
	self.fns = {}
	self.cur = 1
end)

function TpTrinity:SetBuild(builds)
	self.builds = builds
end

function TpTrinity:SetImage(images)
	self.images = images
end

function TpTrinity:SetFn(fns)
	self.fns = fns
end

function TpTrinity:GetCur()
	return self.cur
end

function TpTrinity:ChangeCur()
	self.cur = self.cur + 1
	if self.cur > #self.builds then
		self.cur = 1
	end
end

function TpTrinity:Change(cur, original)
	if cur == nil then
		self:ChangeCur()
	else
		self.cur = cur
	end
	if self.inst.components.inventoryitem then
		local atlas, img = self:GetImage()
		local the_atlas = "images/inventoryimages/"..atlas..".xml"
		if original == 1 then
			the_atlas = "images/inventoryimages.xml"
		elseif original == 2 then
			the_atlas = "images/inventoryimages_2.xml"
		end
		self.inst.components.inventoryitem.atlasname = the_atlas
		self.inst.components.inventoryitem:ChangeImageName(img)
		if self.inst.components.equippable then
			local owner = self.inst.components.inventoryitem.owner
			local bank, build = self:GetBuild()
			WARGON.EQUIP.object_on(owner, bank, build)
		end
	end
	local fn = self:GetFn()
	if fn then
		fn(self.inst)
	end
end

function TpTrinity:GetFn()
	return self.fns[self.cur]
end

function TpTrinity:GetImage()
	if type(self.images[self.cur]) == "table" then
		return self.images[self.cur][1], self.images[self.cur][2]
	else
		return self.images[self.cur], self.images[self.cur]
	end
end

function TpTrinity:GetBuild()
	return self.builds[self.cur][1], self.builds[self.cur][2]
end

return TpTrinity