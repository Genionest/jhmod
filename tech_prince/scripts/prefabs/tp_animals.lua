-- local leifs = "leif", "leif_build", "idle_loop"}

-- local function leif_san_fn()
-- end

-- local function leif_on_burnt()
-- end

-- local function leif_on_attacked()
-- end

-- local function fn()
-- 	-- anims, float_anim, phy, shadows, faced, fn
-- 	local inst = WARGON.make_prefab(leifs, nil, {'char', 1000, .5}, {4, 1.5}, 4)
-- 	WARGON.add_tags(inst, {
-- 		"leif", "tree", "largecreature",
-- 		})
-- 	WARGON.CMP.add_cmps(inst, {
-- 		loco = {walk=1.5},
-- 		san_aoe = {fn=leif_san_fn},
-- 		health = {max=TUNING.LEIF_HEALTH},
-- 		combat = {dmg=TUNING.LEIF_DAMAGE, symbol="marker", per=TUNING.LEIF_ATTACK_PERIOD, player=.33},
-- 		sleep = {resist=3},
-- 		loot = {loot={"livinglog", "livinglog", "livinglog"}},
-- 		inspect = {},
-- 	})
-- 	WARGON.make_burn(inst, "c_large", "maker")
-- 	inst.components.burnable.flammability = TUNING.LEIF_FLAMMABILITY
--     inst.components.burnable:SetOnBurntFn(leif_on_burnt)
--     inst.components.propagator.acceptsheat = true
--     WARGON.make_free(inst, 'huge', 'marker')
--     WARGON.add_listen(inst, {
--     	attacked = leif_on_attacked,
-- 	})
--     inst:SetBrain(WARGON.BRAIN.create_brain())
--     inst:AddComponent("wargonbrain")
--     inst.components.wargonbrain:AddTags({""})

-- 	return inst
-- end

