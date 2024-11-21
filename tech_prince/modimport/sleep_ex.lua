local function sleep_tent(inst, sleeper)
	if GetClock():IsDay() then
		local tosay = "ANNOUNCE_NODAYSLEEP"
		if GetWorld():IsCave() then
			tosay = "ANNOUNCE_NODAYSLEEP_CAVE"
		end
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, tosay))
			return
		end
	end

	if inst:HasTag("fire") then
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NOSLEEPONFIRE"))
		end
		return
	end
	
	local hounded = GetWorld().components.hounded
	local notags = {"FX", "NOCLICK","INLIMBO"}
	local danger = FindEntity(inst, 10, function(target) 
		return
			(target:HasTag("monster") and not target:HasTag("player") and not sleeper:HasTag("spiderwhisperer"))
			or (target:HasTag("monster") and not target:HasTag("player") and sleeper:HasTag("spiderwhisperer") and not target:HasTag("spider"))
			or (target:HasTag("pig") and not target:HasTag("player") and sleeper:HasTag("spiderwhisperer"))
			or (target.components.combat and target.components.combat.target == sleeper)
	end, nil, notags)
	
	if hounded and (hounded.warning or hounded.timetoattack <= 0) then
		danger = true
	end
	
	if danger then
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NODANGERSLEEP"))
		end
		return
	end

	if sleeper.components.hunger.current < TUNING.CALORIES_MED then
		sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NOHUNGERSLEEP"))
		return
	end
	
	sleeper.components.health:SetInvincible(true)
	sleeper.components.playercontroller:Enable(false)

	GetPlayer().HUD:Hide()
	TheFrontEnd:Fade(false,1)

	inst:DoTaskInTime(1.2, function() 
		
		GetPlayer().HUD:Show()
		TheFrontEnd:Fade(true,1) 
		
		if GetClock():IsDay() then

			local tosay = "ANNOUNCE_NODAYSLEEP"
			if GetWorld():IsCave() then
				tosay = "ANNOUNCE_NODAYSLEEP_CAVE"
			end

			if sleeper.components.talker then				
				sleeper.components.talker:Say(GetString(sleeper.prefab, tosay))
				sleeper.components.health:SetInvincible(false)
				sleeper.components.playercontroller:Enable(true)
				return
			end
		end
		
		if sleeper.components.sanity then
			sleeper.components.sanity:DoDelta(TUNING.SANITY_HUGE)
		end
		
		if sleeper.components.hunger then
			sleeper.components.hunger:DoDelta(-TUNING.CALORIES_HUGE, false, true)
		end
		
		if sleeper.components.health then
			sleeper.components.health:DoDelta(TUNING.HEALING_HUGE, false, "tent", true)
		end
		
		if sleeper.components.temperature and sleeper.components.temperature.current < TUNING.TARGET_SLEEP_TEMP then
			sleeper.components.temperature:SetTemperature(TUNING.TARGET_SLEEP_TEMP)
		end		
		
		local moisture_start = nil
		if sleeper.components.moisture and sleeper.components.moisture:GetMoisture() > 0 then
			moisture_start = sleeper.components.moisture.moisture
		end

		if inst.components.finiteuses then
			inst.components.finiteuses:Use()
		end
		GetClock():MakeNextDay()

		if moisture_start then
			sleeper.components.moisture.moisture = moisture_start - TUNING.SLEEP_MOISTURE_DELTA
			if sleeper.components.moisture.moisture < 0 then sleeper.components.moisture.moisture = 0 end
		end
		
		sleeper.components.health:SetInvincible(false)
		sleeper.components.playercontroller:Enable(true)
		sleeper.sg:GoToState("wakeup")	
	end)
end

local function sleep_tent2(inst, sleeper)
	if GetClock():IsDusk() or GetClock():IsNight() then
		local tosay = "ANNOUNCE_NONIGHTSIESTA"
		if GetWorld():IsCave() then
			tosay = "ANNOUNCE_NONIGHTSIESTA_CAVE"
		end
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, tosay))
			return
		end
	end

	if inst:HasTag("fire") then
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NOSLEEPONFIRE"))
		end
		return
	end
	
	local hounded = GetWorld().components.hounded

	local notags = {"FX", "NOCLICK","INLIMBO"}
	local danger = FindEntity(inst, 10, function(target, inst) 
		return 
			(target:HasTag("monster") and not target:HasTag("player") and not sleeper:HasTag("spiderwhisperer"))
			or (target:HasTag("monster") and not target:HasTag("player") and sleeper:HasTag("spiderwhisperer") and not target:HasTag("spider"))
			or (target:HasTag("pig") and not target:HasTag("player") and sleeper:HasTag("spiderwhisperer"))
			or (target.components.combat and target.components.combat.target == sleeper)
	end, nil, notags)
	
	if hounded and (hounded.warning or hounded.timetoattack <= 0) then
		danger = true
	end
	
	if danger then
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NODANGERSIESTA"))
		end
		return
	end

	if sleeper.components.hunger.current < TUNING.CALORIES_MED then
		sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NOHUNGERSIESTA"))
		return
	end
	
	sleeper.components.health:SetInvincible(true)
	sleeper.components.playercontroller:Enable(false)

	GetPlayer().HUD:Hide()
	TheFrontEnd:Fade(false,1)

	inst:DoTaskInTime(1.2, function() 
		
		GetPlayer().HUD:Show()
		TheFrontEnd:Fade(true,1) 
		
		if GetClock():IsDusk() or GetClock():IsNight() then
			local tosay = "ANNOUNCE_NONIGHTSIESTA"
			if GetWorld():IsCave() then
				tosay = "ANNOUNCE_NONIGHTSIESTA_CAVE"
			end
			if sleeper.components.talker then
				sleeper.components.talker:Say(GetString(sleeper.prefab, tosay))
				sleeper.components.health:SetInvincible(false)
				sleeper.components.playercontroller:Enable(true)
				return
			end
		end
		
		if sleeper.components.sanity then
			sleeper.components.sanity:DoDelta(TUNING.SANITY_HUGE)
		end
		
		if sleeper.components.hunger then
			sleeper.components.hunger:DoDelta(-TUNING.CALORIES_MED, false, true)
		end
		
		if sleeper.components.health then
			sleeper.components.health:DoDelta(TUNING.HEALING_HUGE, false, "siestahut", true)
		end
		
		if sleeper.components.temperature and sleeper.components.temperature.current > TUNING.TARGET_SLEEP_TEMP then
			sleeper.components.temperature:SetTemperature(TUNING.TARGET_SLEEP_TEMP - 20)
		end

		local moisture_start = nil
		if sleeper.components.moisture and sleeper.components.moisture:GetMoisture() > 0 then
			moisture_start = sleeper.components.moisture.moisture
		end
		
		if inst.components.finiteuses then
			inst.components.finiteuses:Use()
		end
		GetClock():MakeNextDusk()

		if moisture_start then
			sleeper.components.moisture.moisture = moisture_start - TUNING.SLEEP_MOISTURE_DELTA
			if sleeper.components.moisture.moisture < 0 then sleeper.components.moisture.moisture = 0 end
		end
		
		sleeper.components.health:SetInvincible(false)
		sleeper.components.playercontroller:Enable(true)
		sleeper.sg:GoToState("wakeup")	
	end)
end

local function sleep_bedroll(inst, sleeper)
	local br = nil
	if inst.components.stackable then
		br = inst.components.stackable:Get()
	else
		br = inst
	end
	
	if br then
		br.persists = false
		br:Remove()
	end
	
	GetPlayer().HUD:Hide()
	TheFrontEnd:Fade(false,1)
	inst:DoTaskInTime(1.2, function() 
		GetPlayer().HUD:Show()
		TheFrontEnd:Fade(true,1) 
		
		sleeper.sg:GoToState("wakeup")	
		if sleeper.components.hunger then
			sleeper.components.hunger:DoDelta(-TUNING.CALORIES_HUGE, false, true)
		end

		if sleeper.components.sanity then
			sleeper.components.sanity:DoDelta(TUNING.SANITY_LARGE, false)
		end

		GetClock():MakeNextDay()
	end)
end

local function sleep_bedroll2(inst, sleeper)
	local br = nil
	if inst.components.stackable then
		br = inst.components.stackable:Get()
	else
		br = inst
	end

	if br and br.components.finiteuses then
		if br.components.finiteuses:GetUses() <= 1 then
			br:Remove()
			br.persists = false
		end
	end
	GetPlayer().HUD:Hide()
	TheFrontEnd:Fade(false,1)
	inst:DoTaskInTime(1.2, function() 
		TheFrontEnd:Fade(true,1) 
		GetPlayer().HUD:Show()
		
		
		sleeper.sg:GoToState("wakeup")
		
		if sleeper.components.hunger then
			-- Check SGwilson, state "bedroll", if you change this value
			sleeper.components.hunger:DoDelta(-TUNING.CALORIES_HUGE, false, true)
		end

		if sleeper.components.sanity then
			sleeper.components.sanity:DoDelta(TUNING.SANITY_HUGE, false)
		end

		if sleeper.components.health then
			sleeper.components.health:DoDelta(TUNING.HEALING_MEDLARGE, false, "bedroll", true)
		end
		
		if sleeper.components.temperature then
			if sleeper.components.temperature.current < TUNING.TARGET_SLEEP_TEMP then
				sleeper.components.temperature:SetTemperature(TUNING.TARGET_SLEEP_TEMP)
			elseif sleeper.components.temperature.current > TUNING.TARGET_SLEEP_TEMP * 1.5 then
				sleeper.components.temperature:SetTemperature(sleeper.components.temperature.current + (TUNING.TARGET_SLEEP_TEMP * .5))
			end
		end

		GetClock():MakeNextDay()
	end)
end

GLOBAL.WARGON_SLEEP_EX = {
	sleep_tent 		= sleep_tent,
	sleep_tent2		= sleep_tent2,
	sleep_bedroll 	= sleep_bedroll,
	sleep_bedroll2	= sleep_bedroll2,
}

GLOBAL.WARGON.SLEEP = GLOBAL.WARGON_SLEEP_EX