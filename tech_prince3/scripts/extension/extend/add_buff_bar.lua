local BuffBar = require "extension.uis.buff_bar"
AddClassPostConstruct("widgets/inventorybar", function(self)
	if self.buff_bar_fix then return end self.buff_bar_fix = true

	self.buff_bar = self.root:AddChild(
		BuffBar(self.owner))
	self.buff_bar:SetPosition(0, 220, 0)
	self.buff_bar:SetScale(2, 2, 2)
	-- 重载时添加buff
	self.buff_bar:Init()
end)