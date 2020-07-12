GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local key = GetModConfigData("key")
local scale = GetModConfigData("scale")

AddPlayerPostInit(function(player)
	TheInput:AddKeyDownHandler(96+key, function()
		if player.quickly_time_speed then
			player.quickly_time_speed = false
			SetDefaultTimeScale(1)
		else
			player.quickly_time_speed = true
			SetDefaultTimeScale(scale)
		end
	end)
end)
