local perd_anim = {'perd', 'perd', 'idle_loop'}
local perd_phy = {'char', 50, .5}
local perd_shadow = {1.5, .75}
local loot = {"drumstick", "drumstick",}

local function is_plant(item)
	return item.components.pickable
       and item.components.pickable:CanBePicked()
       and (item.components.pickable.product == "twigs"
       or item.components.pickable.product == "cutgrass"
       or item.components.pickable.product == "berries")
end

local function is_tp_bush(item)
	-- return item.prefab == 'tp_bush'
	-- return item.components.pickable and item:HasTag('bush')
	-- 	and item.components.pickable:CanBePicked()
	return item:HasTag('bush')
end

local function perd_go_home(inst, data)
	if inst.components.inventory then
		inst.components.inventory:DropEverything()
	end
end

local function MakePerd(name, anims, pick_fn, home_fn)
	local function fn()
		local inst = WARGON.make_prefab(anims, nil, perd_phy, perd_shadow, 4)
		WARGON_CMP_EX.add_cmps(inst, {
			loco = {run=TUNING.PERD_RUN_SPEED, walk=TUNING.PERD_WALK_SPEED},
			sleep = {wake=function() return true end},
			combat = {symbol='pig_torso', dmg=TUNING.PERD_DAMAGE, per=TUNING.PERD_ATTACK_PERIOD},
			health = {max=TUNING.PERD_HEALTH},
			inv = {},
			inspect = {},
			loot = {loot=loot},
			eat = {typ='veggie'},
			homeseeker = {},
		})
		-- inst.AnimState:Show('hat')
		WARGON.EQUIP.hat_on(inst, "strawhat_cowboy")
		WARGON.add_tags(inst, {'character', 'berrythief'})
		WARGON.make_burn(inst, 'c_med', 'pig_torso')
		WARGON.make_free(inst, 'med', 'pig_torso')
		inst:ListenForEvent('nighttime', function()
			inst:PushEvent('tp_perd_store')
		end, GetWorld())
		inst:SetBrain(WARGON_BRAIN_EX.animal_brain(pick_fn, home_fn))
		inst:SetStateGraph('SGtp_perd')
		-- inst.AnimState:SetMultColour(colour[1], colour[2], colour[3], colour[4])

		return inst
	end
	return Prefab("common/animals/"..name, fn, {})
end

return MakePerd('tp_perd', perd_anim, is_plant, is_tp_bush)