local function fn(inst)

	inst.MakeSaveTile_pre_buling = inst.MakeSaveTile
	inst.MakeSaveTile = function(self, slotnum)
		local widget = self:MakeSaveTile_pre_buling(slotnum)
		local day = SaveGameIndex:GetSlotDay(slotnum)
		
		local level = SaveGameIndex:GetCurrentCaveLevel(slotnum)
		local levels = require("map/levels")
		
		if not (slotnum and day and level and levels and widget) then
			return
		end
		if SaveGameIndex.data.slots[slotnum].current_mode == "stormplanet"then
			widget.text:SetString(("风暴行星"))
		end
		if SaveGameIndex.data.slots[slotnum].current_mode == "desertplanet"then
			widget.text:SetString(("热砂行星"))
		end
		if SaveGameIndex.data.slots[slotnum].current_mode == "edenplanet"then
			widget.text:SetString(("伊甸行星"))
		end
		
		return widget
	end
end

return {fullname = "screens/loadgamescreen", fn = fn}