local Anims = {
	spider_queen = {"spider_queen", "spider_queen_build", "idle"}
}
local spider_queens = {"spider_queen", "spider_queen_build", "idle"}
local phys = {"char", 1000, 1}
local shadows = {7, 3}

local function fool_spider_combat_re(inst)
	return WARGON.find(inst, 16*1.33, function(guy)
        return inst.components.combat:CanTarget(guy)
           and guy:HasTag("player")
    end)
end

local function fool_spider_combat_keep(inst, target)
	return inst.components.combat:CanTarget(target)
       -- and target:HasTag("player")
end

local function fool_spider_on_attacked(inst, data)
	if data.attacker then
		inst.components.combat:SetTarget(data.attacker)
		inst.components.combat:ShareTarget(data.attacker, 30, function(dude) 
	    	return dude:HasTag("spider") and not dude:HasTag("player") 
	    end, 5)
	end
end

local function fool_spider_on_hit_other(inst, data)
	if data.target.components.tpmadvalue then
		data.target.components.tpmadvalue:DoDelta(10)
	end
end

local function fool_spider_spawn_spider(inst)
	inst.spawned = inst.spawned + 1
	local lake = WARGON.find(inst, 20, nil, {"tp_moon_lake"})
	if lake then
		for i = 1, 8 do
			local pos = WARGON.around_land(lake, math.random(3))
			if pos then
				local spider = WARGON.make_spawn(pos, "spider_dropper")
				spider.sg:GoToState("dropper_enter")
				local target = inst.components.combat.target
				if target then
					spider.components.combat:SetTarget(target)
				end
			end
		end
	end
end

local function fool_spider_on_health_delta(inst, data)
	if data then
		if data.oldpercent > .66 and data.newpercent < .66
		and inst.spawned == 1 then
			fool_spider_spawn_spider(inst)
		elseif data.oldpercent > .33 and data.newpercent < .33
		and inst.spawned == 2 then
			fool_spider_spawn_spider(inst)
		end
	end
	if inst.spawned == 0 then
		fool_spider_spawn_spider(inst)
	end
end

local function fool_spider_on_death(inst)
	local ents = WARGON.finds(inst, 100, {"tp_unreal_rock"})
	for k, v in pairs(ents) do
		if v then
			v:Remove()
		end
	end
end

local function fn()
	local inst = WARGON.make_prefab(Anims.spider_queen, nil, phys, shadows, 4)
	-- local inst = WARGON.make_prefab(spider_queens, nil, phys, shadows, 4)
	inst.AnimState:SetMultColour(.1, .1, 1, 1)
	inst:AddTag("tp_sign_damage")
	inst:AddTag("epic")
	inst:AddTag("tp_only_player_attack")
	WARGON.add_tags(inst, {
		"monster", "spider", "spiderqueen",
		})
	WARGON.CMP.add_cmps(inst, {
		inspect = {},
		health = {max=3000, fire=0, regen={20, 5}},
		loco = {walk=2, run=6},
		combat = {
			dmg=150, player=.5, per=3, range={3,5},
			re={time=3, fn=fool_spider_combat_re},
			keep=fool_spider_combat_keep,
		},
		loot = {loot={
			"tp_epic", "tp_epic", "tp_epic", "tp_epic", "tp_epic", 
			-- "tp_alloy", "redgem", "redgem",
			"tp_lab_bp"}, },
		san_aoe = {value=-TUNING.SANITYAURA_HUGE},
	})
	WARGON.add_listen(inst, {
		attacked = fool_spider_on_attacked,
		onhitother = fool_spider_on_hit_other,
		healthdelta = fool_spider_on_health_delta,
		death = fool_spider_on_death,
	})
	inst.spawned = 0
	inst.OnSave = function(inst, data)
		if data then
			data.spawned = inst.spawned
		end
	end
	inst.OnLoad = function(inst, data)
		if data then
			inst.spawned = data.spawned or 0
		end
	end
	inst:SetBrain(require "brains/tp_sign_rider_brain")
	inst:SetStateGraph("SGtp_fool_spider")

	return inst
end

return Prefab("common/tp_fool_spider", fn, {})