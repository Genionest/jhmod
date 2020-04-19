-- Ocean generation screen

local function fn(self, profile, cb, world_gen_options)
	local cave_level = (world_gen_options.level_type == "stormplanet" or  world_gen_options.level_type == "desertplanet" or world_gen_options.level_type == "edenplanet") and world_gen_options.level_world
	print("去外星")
	if cave_level == 1 or cave_level == 4 then
		--TheSim:LoadPrefabs {"MOD_"..UW_GLOBALS.MODNAME}
		TheSim:LoadPrefabs {"MOD_"..modname}
		
		--self.bg:SetTint(UW_TUNING.CITD_BGCOLOURS[1],UW_TUNING.CITD_BGCOLOURS[2],UW_TUNING.CITD_BGCOLOURS[3], 1)
		self.bg:SetTint(1, 1, 1, 1)
		self.worldanim:GetAnimState():SetBuild("generating_buling")
		self.worldanim:GetAnimState():SetBank("generating_hamlet")
		self.worldanim:GetAnimState():PlayAnimation("idle", true)
		
		self.worldgentext:SetString(STRINGS.UI.WORLDGEN.BLTITLE)
	
		self.verbs =  shuffleArray(STRINGS.UI.WORLDGEN.BL_VERBS)
		self.nouns = shuffleArray(STRINGS.UI.WORLDGEN.BL_NOUNS)
	
    	self.verbidx = 1
    	self.nounidx = 1

    	TheFrontEnd:GetSound():KillSound("worldgensound")
    	--TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/uwGen", "worldgensound") --@LSZ I'm working on it
    	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/caveGen", "worldgensound") 
	end

end
do
    local WorldGenScreen = require "screens/worldgenscreen"
    local mt = getmetatable(WorldGenScreen)

    local old_ctor = WorldGenScreen._ctor
    WorldGenScreen._ctor = function(...)
        old_ctor(...)
        fn(...)
    end
    local old_call = mt.__call
    mt.__call = function(class, ...)
        local self = old_call(class, ...)
        fn(self, ...)
        return self
    end
end