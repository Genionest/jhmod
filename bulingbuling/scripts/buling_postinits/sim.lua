local function fn(inst)
	local world = GetWorld()
	if world and SaveGameIndex:GetCurrentMode() == "stormplanet"then
		world:AddTag("mandrua")
		if world.components.quaker then
			world:RemoveComponent("quaker")
		end
	end
end

return fn