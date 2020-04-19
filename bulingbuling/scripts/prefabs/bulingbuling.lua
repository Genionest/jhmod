local MakePlayerCharacter = require "prefabs/player_common"
local assets = {
	Asset( "ANIM", "anim/bulingbuling.zip" ),
}
local prefabs = {
}
--初始自带物品
local start_inv = {
	"seedm",
	'buling_system',
}
local function dorainsparks(inst, dt)
    if (inst.components.moisture and inst.components.moisture:GetMoisture() > 0) then
    	inst.spark_time = inst.spark_time - dt

    	if inst.spark_time <= 0 then
    		inst.spark_time = 3+math.random()*2

    		local pos = Vector3(inst.Transform:GetWorldPosition())
    		local damage = nil
    		if GetSeasonManager():IsRaining() and inst.components.inventory:GetEquippedMoistureRate(EQUIPSLOTS.HEAD) <= 0 and inst.components.moisture:GetDelta() > 0 then
	    		local waterproofmult = (inst.components.moisture and inst.components.moisture.sheltered and inst.components.inventory) and (1 - (inst.components.inventory:GetWaterproofness() + inst.components.moisture.shelter_waterproofness)) or (inst.components.inventory and (1 - inst.components.inventory:GetWaterproofness()) or 1)
	    		damage = waterproofmult > 0 and math.min(TUNING.WX78_MIN_MOISTURE_DAMAGE, TUNING.WX78_MAX_MOISTURE_DAMAGE * waterproofmult) or 0
	    		inst.components.health:DoDelta(damage, false, "rain")
				pos.y = pos.y + 1 + math.random()*1.5
	    	else 
	    		if inst.components.moisture:GetDelta() >= 0 then 
	    			inst.components.health:DoDelta(TUNING.WX78_MAX_MOISTURE_DAMAGE, false, "water")
	    		else
	    			inst.components.health:DoDelta(TUNING.WX78_MOISTURE_DRYING_DAMAGE, false, "water")
	    		end
				pos.y = pos.y + .25 + math.random()*2
	    	end
    	end
    end

end
local function OnAttack(inst,data)
	local damage = 10
	if data.weapon and data.weapon.components.weapon then
		damage = data.weapon.components.weapon.damage
	end
	data.target.components.health:DoDelta(-damage)
	if data.target and data.target.components.health then
		data.target:PushEvent("attacked", { attacker = inst, damage = 0,stimuli = "dark" })
	end
end
local function buling_recipes()
	local buling_manual = Recipe("buling_manual", {Ingredient("log", 4),Ingredient("boards", 1)}, RECIPETABS.BLTAB,TECH.NONE,nil,"buling_manual_placer",2)
	buling_manual.atlas = "images/inventoryimages/buling_manual.xml"
	buling_manual.image = "buling_manual.tex"
	
	local buling_weaponchest = Recipe("buling_weaponchest_item", {Ingredient("buling_zhongziding", 8,"images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"),Ingredient("buling_glass", 4,"images/inventoryimages/buling_glass.xml", "buling_glass.tex"),Ingredient("buling_manual", 1,"images/inventoryimages/buling_manual.xml", "buling_manual.tex")}, RECIPETABS.BLTAB,TECH.NONE,nil)
	buling_weaponchest.atlas = "images/inventoryimages/buling_seedchest.xml"
	buling_weaponchest.image = "buling_seedchest.tex"
	
	local buling_wakuang = Recipe("buling_wakuang_item", {Ingredient("boards", 8),Ingredient("goldenpickaxe", 1),Ingredient("gears", 4)}, RECIPETABS.BLTAB,TECH.NONE,nil)
	buling_wakuang.atlas = "images/inventoryimages/buling_wakuang.xml"
	buling_wakuang.image = "buling_wakuang.tex"
	--local pig_shop_produce = Recipe("pig_shop_produce", {Ingredient("log", 4),Ingredient("boards", 1)}, RECIPETABS.BLTAB,TECH.NONE,nil,"buling_manual_placer",2,true)
end
local function applyupgrades(inst)
	inst.components.health.maxhealth = 75+inst.components.buling_buff.buffhealth
	inst.components.hunger.max = 100+inst.components.buling_buff.buffhunger
	inst.components.sanity.max = 300+inst.components.buling_buff.buffsanity
end
local fn = function(inst)
	inst.spark_time = 3
	RECIPETABS['BLTAB'] = {str = STRINGS.BUINGKEJI, sort=128, icon = "bulinggongye.tex", icon_atlas = "images/bulinggongye.xml"}
	inst.soundsname = "willow"
	buling_recipes()
	inst:AddTag("insomniac")
	inst:AddComponent("buling_task")
	inst:AddComponent("buling_buff")
	inst:AddComponent("teleportonload")
	inst.components.builder.science_bonus = 2
	inst.components.health:SetMaxHealth(75)
	inst.components.hunger:SetMax(100)
	inst.components.sanity:SetMax(300)
	--applyupgrades(inst)
	inst.components.eater:SetVegetarian(true)
	inst.components.eater.stale_hunger = TUNING.WICKERBOTTOM_STALE_FOOD_HUNGER
    inst.components.eater.stale_health = TUNING.WICKERBOTTOM_STALE_FOOD_HEALTH
    inst.components.eater.spoiled_hunger = TUNING.WICKERBOTTOM_SPOILED_FOOD_HUNGER
    inst.components.eater.spoiled_health = TUNING.WICKERBOTTOM_SPOILED_FOOD_HEALTH
	inst.MiniMapEntity:SetIcon( "bulingbuling.tex" )
	inst.components.combat:AddDamageModifier("bulingbuling", -0.9)
	inst.components.sanity.night_drain_mult = 1.5
    inst.components.sanity.neg_aura_mult = 1.5
	--inst:ListenForEvent("onattackother", OnAttack)
	inst:DoPeriodicTask(1/10, function() dorainsparks(inst, 1/10) end)
	--
	local oldOnDismount = inst.components.driver.OnDismount
	local oldOnMount = inst.components.driver.OnMount
	inst.components.driver.OnDismount = function(self,death, pos, boat_to_boat)	
		if inst.components.driver.vehicle:HasTag("buling_carrier") then
			inst.components.driver.vehicle.bulingdrop(inst.components.driver.vehicle,inst)
			inst.sg:GoToState("jumpoffboatstart", pos)
		else
			oldOnDismount(self,death, pos, boat_to_boat)
		end
	end
	inst.components.driver.OnMount = function(self,carrier)
		if carrier:HasTag("buling_carrier") then
		else
			oldOnMount(self,carrier)
		end
	end
end

return MakePlayerCharacter("bulingbuling", prefabs, assets, fn, start_inv)
