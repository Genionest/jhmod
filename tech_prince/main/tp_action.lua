local function add_player_action_sg(action, state, noboating)
    AddAction(action)
    AddStategraphActionHandler("wilson", ActionHandler(action, state))
    if noboating then return end
    AddStategraphActionHandler("wilsonboating", ActionHandler(action, state))
end

local reng = Action({},0, false, true, 20, true)
reng.id = "TP_RENG"
reng.str = "扔"
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

local tou = Action({},0, false, true, 20, true)
tou.id = "TP_TOU"
tou.str = "投"
tou.fn = function(act)
	local thrown = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if act.target and not act.pos then
		act.pos = act.target:GetPosition()
	end
	if thrown and thrown.components.tpthrow then
		thrown.components.tpthrow:Throw(act.pos, act.doer)
		return true
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

local hua = Action({}, 0, false, true, 20, true)
hua.id = "TP_HUA"
hua.str = "滑"
hua.fn = function(act) 
	move_act_fn(act)
	return true
end

local za = Action({}, 0, nil, true, 10, true)
za.id = "TP_ZA"
za.str = "跳砸"
za.fn = function(act)
	move_act_fn(act)
	return true
end

local ci = Action({}, 0, nil, true, 20, true)
ci.id = "TP_CI"
ci.str = "突刺"
ci.fn = function(act)
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

add_player_action_sg(reng, "tp_reng")
add_player_action_sg(tou, "tp_tou")
add_player_action_sg(hua, "tp_hua_start")
add_player_action_sg(za, "tp_za")
add_player_action_sg(ci, "tp_ci_start")
add_player_action_sg(deng, "give")