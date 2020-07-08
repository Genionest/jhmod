local werepigs = {'pigman', 'werepig_build', 'idle_loop'}
local werepig_phy = {'char', 50, .5}
local werepig_shadow = {1.5, 7.5}

local function werepig_king_combat_re(inst)
	return WARGON.find(inst, 16*1.33, function(guy)
        return inst.components.combat:CanTarget(guy)
           and not guy:HasTag("werepig")
           and not (guy.sg and guy.sg:HasStateTag("transform") )
           and not guy:HasTag("alwaysblock")
    end)
end

local function werepig_king_combat_keep(inst, target)
	return inst.components.combat:CanTarget(target)
       and not target:HasTag("werepig")
       and not (target.sg and target.sg:HasStateTag("transform") )
end

local function werepig_king_on_hit(inst, data)
	local attacker = data.attacker
    inst:ClearBufferedAction()

    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, 30, function(dude) 
    	return dude:HasTag("werepig") 
    end, 5)
end

local function werepig_king_on_new_target(inst, data)
	if data.target then
		inst.components.combat:ShareTarget(data.target, 30, function(dude)
			return dude:HasTag("werepig")
		end, 5)
	end
end

local function werepig_king_san_aoe(inst, observer)
	return -TUNING.SANITYAURA_LARGE
end

local function werepig_king_on_save(inst, data)
end

local function werepig_king_on_load(inst, data)
end

local function werepig_king_load_post_pass(inst, ents, data)
end

local function fn()
	local inst = WARGON.make_prefab(werepigs, nil, werepig_phy, werepig_shadow, 4)
	WARGON.CMP.add_cmps(inst, {
		loco = {run=7, walk=4},
		combat = {dmg=75, symbol='pig_torso', per=3,
			re={time=3, fn=werepig_king_combat_re},
			keep=werepig_king_combat_keep},
		health = {max=2250, regen={5, 20}},
		loot = {loot={'tp_pigking_hat'}},
		san_aoe = {fn=werepig_king_san_aoe},
		inspect = {},
		tpwerepigspawner = {},
		leader = {},
		})
	-- WARGON.make_map(inst, 'tent.png')
	WARGON.add_tags(inst, {
		'character', 'pig', 'scarytopery', 'werepig', 'epic',
		})
	WARGON.add_listen(inst, {
		attacked = werepig_king_on_hit,
		newcombattarget = werepig_king_on_new_target,
		})
	-- inst.AnimState:Show('hat')
	WARGON.EQUIP.hat_on(inst, 'beefalohat_pigking')
	WARGON.set_scale(inst, 1.5)
	inst.atk_num = 1
	-- inst.OnSave = werepig_king_on_save
	-- inst.OnLoad = werepig_king_on_load
	-- inst.LoadPostPass = werepig_king_load_post_pass
	inst:SetBrain(require 'brains/tp_werepig_king_brain')
	inst:SetStateGraph('SGtp_werepig_king')

	return inst
end

return Prefab('common/monster/tp_werepig_king', fn, {})