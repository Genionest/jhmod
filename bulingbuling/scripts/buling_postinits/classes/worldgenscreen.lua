-- Ocean generation screen

local function fn(inst, profile, cb, world_gen_options)
	local cave_level = (world_gen_options.level_type == "stormplanet" or world_gen_options.level_type == "desertplanet"or world_gen_options.level_type == "edenplanet") and world_gen_options.level_world
	print("banhuanb")
	print("banhuanb:"..cave_level)
	--print("MOD_"..UW_GLOBALS.MODNAME)
	if cave_level == 1 or cave_level == 4 then
		--TheSim:LoadPrefabs {"MOD_"..UW_GLOBALS.MODNAME}
		TheSim:LoadPrefabs {"MOD_"..modname}
		
		--inst.bg:SetTint(UW_TUNING.CITD_BGCOLOURS[1],UW_TUNING.CITD_BGCOLOURS[2],UW_TUNING.CITD_BGCOLOURS[3], 1)
		inst.bg:SetTint(50, 50, 50, 1)
		inst.worldanim:GetAnimState():SetBuild("generating_buling")
		inst.worldanim:GetAnimState():SetBank("generating_buling")
		inst.worldanim:GetAnimState():PlayAnimation("idle", true)
		
		--inst.worldgentext:SetString(STRINGS.UI.WORLDGEN.UWTITLE)
	
		inst.verbs = shuffleArray(STRINGS.UI.WORLDGEN.BL_VERBS) 
		inst.nouns = shuffleArray(STRINGS.UI.WORLDGEN.BL_NOUNS)
	
    	inst.verbidx = 1
    	inst.nounidx = 1

    	TheFrontEnd:GetSound():KillSound("worldgensound")
    	--TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/uwGen", "worldgensound") --@LSZ I'm working on it
    	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/caveGen", "worldgensound") 
	end

end

return {fullname = "screens/worldgenscreen", fn = fn}