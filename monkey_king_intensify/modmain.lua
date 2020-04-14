GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
require "recipe"
if ( GLOBAL.IsDLCEnabled(3) ) then
	require "recipecategory"
end
PrefabFiles = {
	"forbid_scrolls",
	"monkey_beardhair",
}
Assets = {
	Asset("ATLAS", "images/inventoryimages/cold_forbid_scroll.xml"),
	Asset("ATLAS", "images/inventoryimages/fire_forbid_scroll.xml"),
	Asset("ATLAS", "images/inventoryimages/monkey_beardhair.xml"),
}
local names = STRINGS.NAMES
local desc = STRINGS.RECIPE_DESC
local generic = STRINGS.CHARACTERS.GENERIC.DESCRIBE
names.COLD_FORBID_SCROLL = "避寒决"
generic.COLD_FORBID_SCROLL = "避寒决"
names.FIRE_FORBID_SCROLL = "避火决"
generic.FIRE_FORBID_SCROLL = "避火决"
names.MONKEY_BEARDHAIR = "猴毛"
generic.MONKEY_BEARDHAIR = "菩萨与我的救命毫毛"

local language = GetModConfigData("language")
local else_enable = GetModConfigData("else_enable")

local function addMana(inst)
	inst:AddComponent("monkeymana")
end

local mk_morph_ui = require "widgets/mk_morph_ui"
local mk_cloud_ui = require "widgets/mk_cloud_ui"
local mk_monkey_ui = require "widgets/mk_monkey_ui"
local mk_back_ui = require "widgets/mk_back_ui"
local mk_mana_ui = require "widgets/mk_mana_ui"

local function addMKUI(self)
	if self.owner and self.owner.prefab == 'monkey_king' then
        self.mk_morph_button = self:AddChild(mk_morph_ui(self.owner))
        self.mk_morph_button:SetPosition(-120, 90, 0)
        if else_enable then
	        self.mk_cloud_button = self:AddChild(mk_cloud_ui(self.owner))
	        self.mk_cloud_button:SetPosition(-190, 90, 0)
	        self.mk_monkey_button = self:AddChild(mk_monkey_ui(self.owner))
	        self.mk_monkey_button:SetPosition(-260, 90, 0)
	        self.mk_back_button = self:AddChild(mk_back_ui(self.owner))
	        self.mk_back_button:SetPosition(-260, 20, 0)
	    end
        -- mana
        self.mk_mana = self:AddChild(mk_mana_ui(self.owner))
        self.mk_mana:SetPosition(-190, 20, 0)
        local mana_cmp = self.owner.components.monkeymana
        self.mk_mana:SetPercent(mana_cmp:GetPercent(), 
        	mana_cmp:GetMax(), 
        	mana_cmp:GetPercent()
        	)
    	
    	self.inst:ListenForEvent("monkey_mana_delta", function(inst, data)
    		self:MonkeyManaDelta(data)
    	end, self.owner)
    end

    function self:MonkeyManaDelta(data)
    	if self.owner.prefab ~= "monkey_king" then
    		return
    	end
    	self.mk_mana:SetPercent(data.newpercent, 
    		self.owner.components.monkeymana:GetMax(), 
    		self.owner.components.monkeymana:GetPercent())
    	if not data.overtime then
    		if data.newpercent > data.oldpercent then
    			self.mk_mana:PulseGreen()
    			-- TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_up")
    		elseif data.newpercent < data.oldpercent then
    			self.mk_mana:PulseRed()
    			-- TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_down")
    		end
    	end
    end
end

local morph_key = GetModConfigData("morph_key")
local cloud_key = GetModConfigData("cloud_key")
local spawn_key = GetModConfigData("spawn_key")
local back_key = GetModConfigData("back_key")

local mk_morph = require "screens/mk_morph"

-- 变身
local function setChangeBody(inst)
	inst:AddComponent("morph")
	if morph_key ~= 0 then
		TheInput:AddKeyDownHandler(morph_key, function()
			TheFrontEnd:PushScreen(mk_morph())
		end)
	end
end

-- 猴子猴孙
local function canSpawnMonkey(inst)
	-- 猴儿们
	if spawn_key ~= 0 then
		TheInput:AddKeyDownHandler(spawn_key, function()
			inst.components.monkeyspawner:Spawn()
		end)
	end
end

local function canRemoveMonkey(inst)
	-- 收
	if back_key then
		TheInput:AddKeyDownHandler(back_key, function()
			inst.components.monkeyspawner:BackMonkeys()
		end)
	end
end

local function manyMonkey(inst)
	inst:AddComponent("monkeyspawner")
	canSpawnMonkey(inst)
	canRemoveMonkey(inst)
    local rcp = Recipe("monkey_beardhair",
    	{Ingredient("decrease_health", 5)},
    	RECIPETABS.SURVIVAL, 
    	TECH.NONE, 
    	RECIPE_GAME_TYPE.COMMON)
    rcp.atlas = "images/inventoryimages/monkey_beardhair.xml"
    rcp.image = "monkey_beardhair.tex"
end

local function setPrimeape(inst)
	inst:AddComponent("monkeyspawn")
end

-- 腾云驾雾
local function spawnCloud(inst)
	inst.CloudSpawn = function(inst)
		if inst.components.monkeymana:EnoughMana(100) then
			inst.components.talker:Say("筋斗云~~~~")
			local pt = inst:GetPosition()
			SpawnPrefab("small_puff").Transform:SetPosition(pt:Get())
			local cloud = SpawnPrefab("mk_cloud")
			cloud.Transform:SetPosition(pt:Get())
			cloud.components.fueled.currentfuel = 10
			-- inst.components.monkeymana:DoDelta(-100)
		else
			inst.components.talker:Say("俺还是去找点蘑菇吃吧")
		end
	end
	if cloud_key ~= 0 then
		TheInput:AddKeyDownHandler(cloud_key, function()
			inst:CloudSpawn()
		end)
	end
end

--避
local function fire_forbid(inst)
	local rcp1 = Recipe(
		"fire_forbid_scroll",
		{Ingredient("bluegem", 1), Ingredient("papyrus", 1)},
		RECIPETABS.MAGIC,
		TECH.NONE,
		RECIPE_GAME_TYPE.COMMON
	)
	rcp1.atlas = "images/inventoryimages/fire_forbid_scroll.xml"
	rcp1.image = "fire_forbid_scroll.tex"
end

local function cold_forbid(inst)
	local rcp2 = Recipe(
		"cold_forbid_scroll",
		{Ingredient("redgem", 1), Ingredient("papyrus", 1)},
		RECIPETABS.MAGIC,
		TECH.NONE,
		RECIPE_GAME_TYPE.COMMON
	)
	rcp2.atlas = "images/inventoryimages/cold_forbid_scroll.xml"
	rcp2.image = "cold_forbid_scroll.tex"
end

local function health_fix(self)
	local old_fn = self.DoDelta
	function self:DoDelta(amount, overtime, cause, ...)
		if self.inst:HasTag("monkey_king_fire_forbid")
		and (cause == "hot" or cause == "fire") then
			return
		end
		if self.inst:HasTag("monkey_king_cold_forbid")
		and cause == "cold" then
			return
		end
		old_fn(self, amount, overtime, cause, ...)
	end
end

-- 突刺修改
local function changeMkLunge(sg)
	if not sg.states["mk_lunge"] then  -- nil警告
		return
	end
	sg.states["mk_lunge"].onenter = function(inst)
		local buffaction = inst:GetBufferedAction()
	    local weapon = inst.components.combat:GetWeapon()
	    if not (buffaction and weapon and weapon.DoLunge) then
	        inst.sg:GoToState('idle')
	    else
	        if inst.components.monkeymana and inst.prefab == 'monkey_king' then
	            if inst:HasTag('skill_boost_mk') then
	                local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
	                if hat and hat.prefab == 'golden_hat_mk' then
	                    -- hat.components.fueled:DoDelta(-24)
	              --       if inst.components.monkeymana:GetCurrent() >= 20 then
			            --     inst.components.monkeymana:DoDelta(-20, true)
			            -- else
			            -- 	inst.components.hunger:DoDelta(-20)
			            -- end
			            if not inst.components.monkeymana:EnoughMana(20) then
			            	inst.components.hunger:DoDelta(-20)
			            end
	                end
	            else
	            	-- if inst.components.monkeymana:GetCurrent() >= 40 then
		            --     inst.components.monkeymana:DoDelta(-40)
		            -- else
		            -- 	inst.components.hunger:DoDelta(-40)
		            -- end
		            if not inst.components.monkeymana:EnoughMana(40) then
		            	inst.components.hunger:DoDelta(-40)
		            end
	            end
	        end
	        weapon.components.myth_rechargeable:StartRecharging()
	        inst.AnimState:PlayAnimation("lunge_pst")
	        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
	        --inst.SoundEmitter:PlaySound("monkey_sound/monkey_sound/fireball") --这个
	        inst.Physics:SetMotorVelOverride(30,0,0)
	        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
	        inst.components.bloomer:PushBloom("lunge", "shaders/anim.ksh", -2)
	        inst.components.colouradder:PushColour("lunge", 1, 1, 0, 0)
	        inst.sg.statemem.flash = 1

	        local targetpos = buffaction.pos

	        local pos = inst:GetPosition()
	        if pos.x ~= targetpos.x or pos.z ~= targetpos.z then
	            inst:ForceFacePoint(targetpos:Get())
	        end
			local angle = (inst.Transform:GetRotation() + 90) * DEGREES  
			local step = .75
			local offset = 0.25
			local dist = (10 + .5) * step + offset				
	        weapon:DoLunge(inst, pos, targetpos)

	        inst:PerformBufferedAction()
	    end
	end
end

-- 火眼修改
local function changeFireEye(inst)
	local old_fn = inst.TriggerFireEye
	inst.TriggerFireEye = function(inst)
		old_fn(inst)
		if inst.fireeye_hunger_task then
			inst.fireeye_hunger_task:Cancel()
			inst.fireeye_hunger_task = nil
			if inst.components.monkeymana:GetCurrent() > 3 then
				inst.components.monkeymana:DoDelta(inst:HasTag('fireeye_boost_mk') and 0 or -5,true)
			else
				inst.components.hunger:DoDelta(inst:HasTag('fireeye_boost_mk') and 0 or -4,true)
			end
			inst.fireeye_hunger_task = inst:DoPeriodicTask(1, function()
				if inst.components.monkeymana:GetCurrent() > 3 then
					inst.components.monkeymana:DoDelta(inst:HasTag('fireeye_boost_mk') and 0 or -5,true)
				else
					inst.components.hunger:DoDelta(inst:HasTag('fireeye_boost_mk') and 0 or -4,true)
				end
			end)
		end
	end
end

-- 饮酒修改
local function eatWine(inst)
	-- 素酒
	local old_fn = inst.components.eater.oneatfn
	inst.components.eater:SetOnEatFn(function(inst, food)
		old_fn(inst, food)
		if food.prefab == "peach_wine" then
			inst.components.monkeymana:DoDelta(100)
		end
	end)
	-- 酒葫芦
	if ACTIONS.DRINK then
		local old_fn2 = ACTIONS.MK_DRINK.fn 
		ACTIONS.MK_DRINK.fn= function(act)
			if act.doer.components.monkeymana then
				act.doer.components.monkeymana:DoDelta(100)
			end
			old_fn2(act)
			return true
		end 
	end
end

AddPrefabPostInit("monkey_king", addMana)
AddPrefabPostInit("monkey_king", setChangeBody)
if else_enable then
AddClassPostConstruct("widgets/statusdisplays", addMKUI)
AddPrefabPostInit("primeape", setPrimeape)
AddPrefabPostInit("monkey_king", manyMonkey)
AddPrefabPostInit("monkey_king", spawnCloud)
AddPrefabPostInit("monkey_king", fire_forbid)
AddPrefabPostInit("monkey_king", cold_forbid)
AddComponentPostInit("health", health_fix)
AddStategraphPostInit("wilson", changeMkLunge)
AddPrefabPostInit("monkey_king", changeFireEye)
AddPrefabPostInit("monkey_king", eatWine)
end