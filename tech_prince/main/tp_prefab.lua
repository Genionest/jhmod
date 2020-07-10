AddPrefabPostInit("wilson", function(inst)
	inst:AddComponent("sciencemorph")
	inst:AddComponent("tpcallbeast")
	inst:AddComponent("tpmadvalue")
	inst:AddComponent("tpbuff")
	inst:AddComponent("tplevel")
	inst.components.tplevel:ApplyUpGrade()
	inst:AddComponent("tptech")
	inst:AddComponent("tpriderspawner")
	-- inst:AddComponent("tpnutspawner")
	local old_save = inst.OnSave
	inst.OnSave = function(inst, data)
		old_save(inst, data)
		data.tp_morph = inst.components.sciencemorph.cur

	end
	local old_load = inst.OnLoad
	inst.OnLoad = function(inst, data)
		old_load(inst, data)
		if data.tp_morph then
			inst.components.sciencemorph:Morph(data.tp_morph)
		end
	end
	local gifts = {'tp_gift'}
	inst.components.inventory.starting_inventory = gifts
	WARGON.key_down(KEY_R, function()
		local shark = c_find("tigershark")
		if shark then
			inst.Transform:SetPosition(shark:GetPosition():Get())
		end
	end)
end)

AddPrefabPostInit("sewing_kit", function(inst)
	local old_fn = inst.components.sewing.onsewn
	inst.components.sewing.onsewn = function(inst, target, doer)
		old_fn(inst, target, doer)
		if target:HasTag("tp_tent") then
			local use = target.components.finiteuses:GetUses()
			local total = target.components.finiteuses.total
			if use <= target.components.finiteuses.total then
				target.components.finiteuses:SetUses(math.min(use+5, total))
			end
			target.components.fueled:SetPercent(.9)
		end
	end
end)
 
-- 防止和Wilson一起在天上
-- AddPrefabPostInit("flower", function(inst)
-- 	WARGON.do_task(inst, 0, function()
-- 		local pt = inst:GetPosition()
-- 		inst.Transform:SetPosition(pt.x, 0, pt.z)
-- 	end)
-- end)

AddPrefabPostInit("acorn", function(inst)
	inst:AddComponent('tpammo')
end)

AddPrefabPostInit("birchnutdrake", function(inst)
	local old_target_fn = inst.components.combat.targetfn
	inst.components.combat.targetfn = function(inst)
		local guy = old_target_fn(inst)
		if guy and not guy:HasTag("tp_oak_armor") 
		and not (inst:HasTag("tp_defense_tree_nut") and guy:HasTag("player")) then
			return guy
		end
	end
end)

AddPrefabPostInit("pigman", function(inst)
	inst:AddComponent("tpbuff")
end)

local function add_prefab_tag(name, tag)
	AddPrefabPostInit(name, function(inst)
		if type(tag) == "table" then
			for k, v in pairs(tag) do
				inst:AddTag(v)
			end
		else
			inst:AddTag(tag)
		end
	end)
end

add_prefab_tag("log", "tp_chop_pig_item")
add_prefab_tag("cork", "tp_chop_pig_item")
add_prefab_tag("livinglog", "tp_chop_pig_item")
add_prefab_tag("bamboo", "tp_hack_pig_item")
add_prefab_tag("vine", "tp_hack_pig_item")
add_prefab_tag("cutgrass", "tp_hack_pig_item")
-- add_prefab_tag("seeds", "tp_farm_pig_item")
AddPrefabPostInitAny(function(inst)
	if string.find(inst.prefab, 'seeds') then
		inst:AddTag("tp_farm_pig_item")
	end
	if inst:HasTag("smallcreature") and inst:HasTag("canbetrapped") then
		inst:AddTag("tp_strawhat_target")
	end
end)

local trees = {
	"evergreen", "evergreen_sparse",
	"deciduoustree", "rainforesttree", "teatree",
	"clawpalmtree", "jungletree", "palmtree", 
	"gingko_tree",
}
for k, v in pairs(trees) do
	add_prefab_tag(v, 'tp_chop_pig_target')
end

local hackables = {
	"bambootree", "bush_vine", "grass_tall",
}
for k, v in pairs(hackables) do
	add_prefab_tag(v, 'tp_hack_pig_target')
end

local farms = {
	'fast_farmplot', 'slow_farmplot',
}
for k, v in pairs(farms) do
	add_prefab_tag(v, 'tp_farm_pig_target')
end

local strawhat_targets = {
	"pigman", "bunnyman", "perd", "beefalo", "primeape",
}
for k, v in pairs(strawhat_targets) do
	add_prefab_tag(v, 'tp_strawhat_target')
end
add_prefab_tag('perd', 'tp_strawhat_perd')
add_prefab_tag('beefalo', 'tp_strawhat_beefalo')

AddPrefabPostInit('rowboat', function(inst)
	inst:ListenForEvent('onbuilt', function()
		if GetPlayer():HasTag("tech_prince") then
			local sail = SpawnPrefab("sail")
			local torch = SpawnPrefab("boat_torch")
			inst.components.container:Equip(sail)
			inst.components.container:Equip(torch)
		end
	end)
end)

AddPrefabPostInit('pigking', function(inst)
	inst:AddTag("tp_pigking_tech")
end)

local boss_meat = {
	"deerclops_eyeball",
	"minotaurhorn",
	"tigereye",
}

for k, v in pairs(boss_meat) do
	add_prefab_tag(v, "tplevel_food")
end

add_prefab_tag('snakebonesoup', 'tplevel_food_small')

add_prefab_tag('pinecone', 'tp_war_tree_gift')

AddPrefabPostInit('leif', function(inst)
	local function leif_test(inst, item)
		return item:HasTag("tp_war_tree_gift") and inst:HasTag("tp_war_tree")
	end
	local function leif_accept(inst, giver, item)
		if giver == inst.components.combat.target then
			inst.components.combat:SetTarget(nil)
		else
			inst.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
			giver.components.leader:AddFollower(inst)
		    inst.components.follower:AddLoyaltyTime(30*16)
		end
	end
    WARGON.CMP.add_cmps(inst, {
    	follow = {max=TUNING.PIG_LOYALTY_MAXTIME},
    	trader = {accept=leif_accept, test=leif_test},
    	})
    local old_save = inst.OnSave
    local old_load = inst.OnLoad
    inst.OnSave = function(inst, data)
    	if old_save then old_save(inst, data) end
    	if data and inst:HasTag("tp_war_tree") then
    		data.war_tree = true
    	end
	end
	inst.OnLoad = function(inst, data)
		if old_load then old_load(inst, data) end
		if data and data.war_tree then
			inst:AddTag("tp_war_tree")
		end
	end
end)

AddPrefabPostInit("perd", function(inst)
	local old_save = inst.OnSave
    local old_load = inst.OnLoad
    inst.OnSave = function(inst, data)
    	if old_save then old_save(inst, data) end
    	if data and inst.tp_perd then
    		data.tp_perd = inst.tp_perd
    	end
	end
	inst.OnLoad = function(inst, data)
		if old_load then old_load(inst, data) end
		if data and data.tp_perd then
			inst.tp_perd = data.tp_perd
			inst:SetBrain(require "brains/tp_perd_brain")
			inst.AnimState:Show("HAT")
			inst.AnimState:OverrideSymbol("swap_hat", "strawhat_cowboy", "swap_hat")
		end
	end
end)

AddPrefabPostInit("beefalo", function(inst)
	inst:ListenForEvent("death", function(inst)

	end)
end)

AddPrefabPostInit("deerclops", function(inst)
	if inst.components.freezable then
		inst:RemoveComponent("freezable")
	end	
	inst:ListenForEvent("attacked", function(inst)
		if inst.tp_task == nil then
			inst.tp_task = WARGON.per_task(inst, .2, function()
				WARGON.make_fx(inst, "tp_fx_snow_ball_shoot")
			end)
			WARGON.do_task(inst, 2, function()
				if inst.tp_task then
					inst.tp_task:Cancel()
					inst.tp_task = nil
				end
			end)
		end
	end)
end)

AddPrefabPostInit("dragonfly", function(inst)
	inst.components.groundpounder.destroyer = true
	inst.components.groundpounder.destructionRings = 1
	inst:AddTag("groundpoundimmune")
end)

AddPrefabPostInit("bearger", function(inst)
	if inst.components.freezable then
		inst:RemoveComponent("freezable")
	end	
end)

AddPrefabPostInit("moose", function(inst)
	if inst.components.freezable then
		inst:RemoveComponent("freezable")
	end	
end)

AddPrefabPostInit("minotaur", function(inst)
	if inst.components.freezable then
		inst:RemoveComponent("freezable")
	end	
end)

AddPrefabPostInit("kraken", function(inst)
	inst.components.health:SetMaxHealth(3000)
end)

AddPrefabPostInit("pugalisk", function(inst)
	inst:ListenForEvent("healthdelta", function(inst, data)
		inst.components.health:SetInvincible(true)
		WARGON.do_task(inst, 1, function()
			inst.components.health:SetInvincible(false)
		end)
	end)
end)

AddPrefabPostInit("pugalisk_body", function(inst)
	local function redirect_health(inst, amount, overtime, cause, ignore_invincible)
	    local originalinst = inst
	    if inst.startpt then
	        inst = inst.startpt
	    end
	    if amount < 0 and( (inst.components.segmented and inst.components.segmented.vulnerablesegments == 0) or inst:HasTag("tail") or inst:HasTag("head") ) then
	        print("invulnerable",cause,GetPlayer().prefab)
	        if cause == GetPlayer().prefab then
	            GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_PUGALISK_INVULNERABLE"))        
	        end
	        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal",nil,.25)
	        inst.SoundEmitter:PlaySound("dontstarve/wilson/hit_metal")

	    elseif amount and inst.host and not inst.host.tp_invincible then

	        local fx = SpawnPrefab("snake_scales_fx")
	        fx.Transform:SetScale(1.5,1.5,1.5)
	        local pt= Vector3(originalinst.Transform:GetWorldPosition())
	        fx.Transform:SetPosition(pt.x,pt.y + 2 + math.random()*2,pt.z)

	        inst:PushEvent("dohitanim")
	        inst.host.components.health:DoDelta(amount, overtime, cause, false, true)
	        inst.host:PushEvent("attacked")
	    end    
	end
	inst.components.health.redirect = redirect_health
end)

AddPrefabPostInit("pillar_ruins", function(inst)
	local function on_hammered(inst, worker)
		local shadow = WARGON.make_spawn(inst, "fissure_lower")
		shadow:AddTag("tp_shadow_light")
		SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst:Remove()
	end
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(on_hammered)
end)

AddPrefabPostInit("campfire", function(inst)
	local function onhammered(inst, worker)
		local ash = SpawnPrefab("ash")
		ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
		SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst:Remove()
	end
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
end)

AddPrefabPostInit("fissure_lower", function(inst)
	local function spawnchildren(inst)
	    if inst.components.childspawner then
	        inst.components.childspawner:StartSpawning()
	        inst.components.childspawner:StopRegen()
	    end 
	end
	local function spawnfx(inst)
	    if not inst.fx then
	        inst.fx = SpawnPrefab(inst.fxprefab)
	        local pos = inst:GetPosition()
	        inst.fx.Transform:SetPosition(pos.x, -0.1, pos.z)
	    end
	end
	local function nightmare_state(inst, instant)
        ChangeToObstaclePhysics(inst)
        inst.Light:Enable(true)
        inst.components.lighttweener:StartTween(nil, 5, nil, nil, nil, (instant and 0) or 0.5)
        inst.SoundEmitter:KillSound("loop")
        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open")
        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_LP", "loop")
        if not instant then
            inst.AnimState:PlayAnimation("open_2")
            inst.AnimState:PushAnimation("idle_open")

            inst.fx.AnimState:PlayAnimation("open_2")
            inst.fx.AnimState:PushAnimation("idle_open")
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open")
        else
            inst.AnimState:PlayAnimation("idle_open")

            inst.fx.AnimState:PlayAnimation("idle_open")
        end
        spawnchildren(inst)
    end
	WARGON.do_task(inst, 0, function()
		if inst:HasTag("tp_shadow_light") then
			spawnfx(inst)
		    inst.state = "nightmare"
		    inst:DoTaskInTime(math.random() * 2, nightmare_state)
		end
	end)
end)

AddPrefabPostInit("tigershark", function(inst)
	if inst.components.freezable then
		inst:RemoveComponent("freezable")
	end	
end)

AddPrefabPostInit("beefalohat", function(inst)
	local old_equip = inst.components.equippable.onequipfn
	local old_unequip = inst.components.equippable.onunequipfn
	inst.components.equippable:SetOnUnequip(function(inst, owner)
		old_unequip(inst, owner)
		local pack = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if pack and pack.prefab == "tp_pack_beefalo" then
			owner:AddTag("beefalo")
		end
	end)
end)