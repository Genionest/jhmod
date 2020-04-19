-- Slot details update
local function fn(inst)

	inst.BuildMenu_pre_mand = inst.BuildMenu	
	inst.BuildMenu = function(self)
		self:BuildMenu_pre_mand()

		local slotnum = self.saveslot
		local day = SaveGameIndex:GetSlotDay(slotnum)
		
		local level = SaveGameIndex:GetCurrentCaveLevel(slotnum)
		local levels = require("map/levels")
		
		if not (slotnum and day and level and levels) then
			return
		end
		
		if SaveGameIndex.data.slots[slotnum].current_mode == "stormplanet" then
			self.text:SetString(("风暴行星"))
		end
		if SaveGameIndex.data.slots[slotnum].current_mode == "desertplanet"then
			self.text:SetString(("热砂行星"))
		end
		if SaveGameIndex.data.slots[slotnum].current_mode == "edenplanet"then
			self.text:SetString(("伊甸行星"))
		end
	end
end

return {fullname = "screens/slotdetailsscreen", fn = fn}