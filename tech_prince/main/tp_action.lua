local function add_player_action_sg(action, state, noboating)
    AddAction(action)
    AddStategraphActionHandler("wilson", ActionHandler(action, state))
    if not noboating then
	    AddStategraphActionHandler("wilsonboating", ActionHandler(action, state))
    end
end

local reng = Action({},2, false, true, 20, true)
reng.id = "TP_RENG"
reng.str = STRINGS.TP_STR.tp_reng
reng.fn = function(act)
	if act.target.components.combat and act.doer.components.inventory then
		local item = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if item and item.components.weapon and item.components.tpproj then
			local projectile = act.doer.components.inventory:DropItem(item, false, nil, nil, true) 
			if projectile then
				projectile.components.tpproj:Throw(act.doer, act.target)
				if projectile.components.finiteuses then
					projectile.components.finiteuses:Use()
				end
			end
			return true
		end
	end
end

local function move_act_fn(act)
	local weapon = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if act.target and not act.pos then
		act.pos = act.target:GetPosition()
	end
	if act.doer then
	end
	if weapon and weapon.components.tpmove and weapon.components.tpmove.onmove then
		weapon.components.tpmove.onmove(weapon)
	end
end

local tou = Action({},0, false, true, 20, true)
tou.id = "TP_TOU"
tou.str = STRINGS.TP_STR.tp_tou
tou.fn = function(act)
	move_act_fn(act)
	return true
end

local hua = Action({}, 0, false, true, 20, nil, true)
-- local hua = Action({}, 2, false, true, 20, true)
hua.id = "TP_HUA"
hua.str = STRINGS.TP_STR.tp_hua
hua.fn = function(act) 
	move_act_fn(act)
	return true
end

-- local za = Action({}, 0, nil, true, 6, true)
local za = Action({}, 0, nil, nil, 6, nil, true)
za.id = "TP_ZA"
za.str = STRINGS.TP_STR.tp_za
za.fn = function(act)
	move_act_fn(act)
	return true
end

local ci = Action({}, 0, nil, nil, 20, nil, true)
-- local ci = Action({}, 0, nil, true, 20, true)
ci.id = "TP_CI"
ci.str = STRINGS.TP_STR.tp_ci
ci.fn = function(act)
	move_act_fn(act)
	return true
end

local cui_feng = Action({},0, false, true, 10, true)
cui_feng.id = "TP_CUI_FENG"
cui_feng.str = STRINGS.TP_STR.tp_cui_feng
cui_feng.fn = function(act)
	local weapon = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if act.target and not act.pos then
		act.pos = act.target:GetPosition()
	end
	if act.doer then
	end
	if weapon and weapon.components.tprecharge and weapon.components.tprecharge then
		weapon.components.tprecharge:SetRechargeTime()
	end
	return true
end

local wind_attack = Action({},0,false,true,20,true)
wind_attack.id = "TP_WIND_ATTACK"
wind_attack.str = STRINGS.TP_STR.tp_wind_attack
wind_attack.fn = function(act)
	move_act_fn(act)
	if act.target then
		act.target:RemoveTag("tp_wind_attack_target")
	end
	return true
end

local rotate = Action({},0,false,true,20,true)
rotate.id = "TP_ROTATE"
rotate.str = STRINGS.TP_STR.tp_rotate
rotate.fn = function(act)
	move_act_fn(act)
	return true
end

local zhuan = Action({},0,false,true,20,true)
zhuan.id = "TP_ZHUAN"
zhuan.str = STRINGS.TP_STR.tp_zhuan
zhuan.fn = function(act)
	move_act_fn(act)
	return true
end

local bang = Action({},0,false,true,30,true)
bang.id = "TP_BANGALORE"
bang.str = STRINGS.TP_STR.tp_bangalore
bang.fn = function(act)
	move_act_fn(act)
	return true
end

-- local deng = Action({}, 0, nil, true, 10, true)
local deng = Action({}, 1)
deng.id = "TP_DENG"
deng.str = "登云"
deng.fn = function(act)
	if act.doer and act.doer.components.flyer then
		act.doer.components.flyer:Mount()
		return true
	end
end

local load_ammo = Action({}, 10)
load_ammo.id = "TP_LOAD_AMMO"
load_ammo.str = STRINGS.TP_STR.tp_load_ammo
load_ammo.fn = function(act)
	if act.invobject and act.target then
		local inv = act.invobject
		local target = act.target
		if inv.components.stackable and target.components.tpbullets then
			for i = 1, inv.components.stackable:StackSize() do
				if target.components.tpbullets:IsFull() then
					break
				end
				local item = inv.components.stackable:Get()
				target.components.tpbullets:Add(1, item.prefab)
				item:Remove()
				-- target.components.tpbullets:DoDelta(1)
			end
			return true
		end
	end
end

local sea_sleep = Action({mount_enabled=true})
sea_sleep.id = "TP_SEA_SLEEP"
sea_sleep.str = STRINGS.TP_STR.tp_sea_sleep
sea_sleep.fn = function(act)
	local bag = nil
	if act.target and act.target.components.sleepingbag then 
		bag = act.target 
	end
	if act.invobject and act.invobject.components.sleepingbag then 
		ag = act.invobject 
	end
	if bag and act.doer then
		bag.components.sleepingbag:DoSleep(act.doer)
		return true
	end
end

local sea_dry = Action({mount_enabled=true})
sea_dry.id = "TP_SEA_DRY"
sea_dry.str = STRINGS.TP_STR.tp_sea_dry
sea_dry.fn = function(act)
	if act.target.components.dryer then
		local ingredient = act.doer.components.inventory:RemoveItem(act.invobject)
		
		if not act.target.components.dryer:StartDrying(ingredient) then
			act.doer.components.inventory:GiveItem(ingredient,nil, Vector3(TheSim:GetScreenPos(act.target.Transform:GetWorldPosition()) ))
			return false
		end
		return true
	end
end

local diving = Action({})
diving.id = "TP_DIVING"
diving.str = STRINGS.TP_STR.tp_diving
diving.fn = function(act)
	if act.target and act.doer then
		if act.target.components.tpdivable then
			act.target.components.tpdivable:Diving(act.doer)
		end
		return true
	end
end

local use = Action({})
use.id = "TP_USE"
use.str = STRINGS.TP_STR.tp_use
use.fn = function(act)
	if act.target and act.doer then
		if act.target.components.tpuse then
			act.target.components.tpuse:Use(act.doer)
		end
		return true
	end
end

local inter = Action({mount_enabled=true}, .5)
inter.id = "TP_INTER"
inter.str = STRINGS.TP_STR.tp_inter
inter.fn = function(act)
	if act.target and act.invobject and act.doer then
		if act.target.components.tpinter then
			act.target.components.tpinter:Interact(act.invobject, act.doer)
			return true
		end
	end
end

add_player_action_sg(reng, "tp_reng")
add_player_action_sg(tou, "tp_tou_start", true)
add_player_action_sg(hua, "tp_hua_start", true)
add_player_action_sg(za, "tp_za", true)
add_player_action_sg(ci, "tp_ci_start", true)
add_player_action_sg(cui_feng, "tp_cui_feng")
add_player_action_sg(wind_attack, "tp_wind_attack", true)
add_player_action_sg(rotate, "tp_rotate")
add_player_action_sg(bang, "tp_bangalore")
add_player_action_sg(deng, "give")
add_player_action_sg(load_ammo, "give")
add_player_action_sg(sea_sleep, "give")
add_player_action_sg(sea_dry, "give")
add_player_action_sg(diving, "tp_diving", true)
add_player_action_sg(use, "give")
add_player_action_sg(zhuan, "tp_zhuan")
add_player_action_sg(inter, "give")

local tp_perd_store = Action({})
tp_perd_store.id = "TP_PERD_STORE"
tp_perd_store.str = "TP_PERD_STORE"
tp_perd_store.fn = function(act)
	-- if act.doer and act.target then
	if act.doer then
		if act.doer.components.inventory then
			act.doer.components.inventory:DropEverything()
		end
	end
	return true
end
AddAction(tp_perd_store)
AddStategraphActionHandler("perd", 
    ActionHandler(tp_perd_store, "pick")
)

local tp_change = Action({}, 2.5)
tp_change.id = "TP_CHANGE"
tp_change.str = STRINGS.TP_STR.tp_change
tp_change.fn = function(act)
	if act.target then
		if act.target.components.tpbepot then
			act.target.components.tpbepot:BePot()
		elseif act.target.components.tpbebird then
			act.target.components.tpbebird:BeBird()
		end
		return true
	end
end
add_player_action_sg(tp_change, "give")

local old_fn = ACTIONS.HARVEST.fn
ACTIONS.HARVEST.fn = function(act)
	if act.target.components.tpmelter then
		return act.target.components.tpmelter:Harvest(act.doer)
	elseif act.target.components.tpstewer then
		return act.target.components.tpstewer:Harvest(act.doer)
	end
	return old_fn(act)
end
