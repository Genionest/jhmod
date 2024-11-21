if GLOBAL.WARGON.CONFIG.diff == 1 then
---------------- Mode Difficulty ------------------

-- Only player and pigman can attack boss
local bosses = {
	"deerclops",
	"moose",
	"dragonfly",
	"bearger",
	"minotaur",
	"twister",
	"tigershark",
	"kraken",
	"pugalisk",
	"antqueen",
	"ancient_herald",
	"ancient_hulk",
	-- "tp_werepig_king",
	-- "tp_sign_rider",
}
for k, v in pairs(bosses) do
	AddPrefabPostInit(v, function(inst)
        inst:AddTag("tp_only_player_attack")
        if inst.components.combat 
        and inst.components.combat.playerdamagepercent < 1 then
            inst.components.combat.playerdamagepercent = 1
        end
	end)
end

-- Kraken has more helath
AddPrefabPostInit("kraken", function(inst)
    -- local health = _G.WARGON.CONFIG.diff==1 and 5000 or 3000
    local health = 3000
	inst.components.health:SetMaxHealth(health)
end)

-- More powerful animals
local element_power = {
	"bee",
	"killerbee",
	"hound",
	"firehound",
	"icehound",
	"spider",
	"spider_hider",
	"spider_spitter",
	"spider_warrior",
	"spider_dropper",
	"tallbird",
	"tentacle",
	"merm",
	"worm",
	"bat",
}
for k, v in pairs(element_power) do
	AddPrefabPostInit(v, function(inst)
		inst:AddComponent("tppower")
		inst.components.tppower:SetPower(math.random(6))
	end)
end

-- Rocky will be internal strife
AddPrefabPostInit("rocky", function(inst)
    local function FindRocky(inst)
        return WARGON.find(inst, 15, function(guy)
            return guy:HasTag('rocky')
        end)
    end
    inst.components.combat:SetRetargetFunction(3, FindRocky)
end)

-- Sanity rock will become pig torch
AddPrefabPostInit("sanityrock", function(inst)
    WARGON.do_task(inst, 0, function()
        local pos = inst:GetPosition()
        inst:Remove()
        WARGON.make_spawn(pos, "pigtorch")
    end)
end)
AddPrefabPostInit("insanityrock", function(inst)
    WARGON.do_task(inst, 0, function()
        local pos = inst:GetPosition()
        inst:Remove()
        WARGON.make_spawn(pos, "pigtorch")
    end)
end)

-- Nightmare light can be destroyed
AddPrefabPostInit("nightmarelight", function(inst)
    local function on_hammered(inst, worker)
        -- local shadow = WARGON.make_spawn(inst, "fissure_lower")
        local shadow = WARGON.make_spawn(inst, "crawlinghorror")
        -- shadow:AddTag("tp_shadow_light")
        SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
    end
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(on_hammered)
end)

-- Warg's howl will strength hound
local wargs = {
    "warg",
    "tp_blue_warg",
    "tp_red_warg",
}
for k, warg in pairs(wargs) do
    AddPrefabPostInit(warg, function(inst)
        inst.tp_howl_fn = function(inst)
            local hounds = WARGON.finds(inst, 20, {"hound"}, {"warg"})
            for k, v in pairs(hounds) do
                if v and v.components.tpbuff then
                    v.components.tpbuff:AddBuff(buffs[math.random(#buffs)])
                end
            end
        end
    end)
end

-- Spawn four Knights of the Apocalypse
AddPrefabPostInit("rider_sp", function(inst)
    inst.riders = {
        "tp_sign_rider",
        "tp_sign_rider_2",
        "tp_sign_rider_3",
        "tp_sign_rider_4",
    }
end)

-- Snow ball of deerclops will cause damage and recover deerclops
AddPrefabPostInit("tp_fx_snow_ball", function(inst)
    inst.diff = true
end)

-- Werepig King's attack will cause more damage and recover itself
AddPrefabPostInit("tp_werepig_king", function(inst)
    inst.diff = true
end)

-- Only player and pigman can attack boss
AddComponentPostInit("combat", function(self)
    local old_can = self.CanBeAttacked
    function self:CanBeAttacked(attacker)
        if not (attacker:HasTag("player") 
        or attacker:HasTag("pig")) 
        and self.inst:HasTag("tp_only_player_attack") then
            return false
        end
        return old_can(self, attacker)
    end
end)

-- Boss Angry is more difficulty
AddComponentPostInit("tpangry", function(self)
    self.diff = true
end)

-- Bosses has more health
local tuning = GLOBAL.TUNING
tuning.DEERCLOPS_HEALTH 	    = 5000
tuning.DRAGONFLY_HEALTH 	    = 5000
tuning.BEARGER_HEALTH 		    = 5000
tuning.MOOSE_HEALTH 		    = 5000
tuning.MINOTAUR_HEALTH 		    = 5000
tuning.TWISTER_HEALTH 		    = 5000
tuning.TIGERSHARK_HEALTH 	    = 5000
tuning.ANTQUEEN_HEALTH 		    = 5000
tuning.PUGALISK_HEALTH 		    = 5000
tuning.ANCIENT_HERALD_HEALTH    = 5000
    
end