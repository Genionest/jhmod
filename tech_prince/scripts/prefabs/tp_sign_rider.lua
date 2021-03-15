-- local assets = WARGON.HAS_SKIN and {} or {
-- local assets = {
-- 	Asset("ANIM", "anim/wathgrithr.zip"),
-- 	Asset("ANIM", "anim/wolfgang.zip"),
--     Asset("ANIM", "anim/wolfgang_skinny.zip"),
--     Asset("ANIM", "anim/wolfgang_mighty.zip"),
--     Asset("ANIM", "anim/player_mount_wolfgang.zip"),
--     Asset("ANIM", "anim/player_wolfgang.zip"),
--     Asset("ANIM", "anim/waxwell.zip"),
-- 	Asset("ANIM", "anim/woodie.zip"),
-- }
local assets = {}

local sign_riders = {
	"wilsonbeefalo", 
	"wathgrithr",
	"idle_loop"}
local rider_1 = {
	-- WARGON.HAS_SKIN and "wathgrithr_gladiator" or "wathgrithr", 
	"wathgrithr",
	"beefalo_personality_ornery",
}
local rider_2 = {
	-- WARGON.HAS_SKIN and "waxwell_gladiator" or "waxwell",
	"waxwell",
	"beefalo_personality_docile",
}
local rider_3 = {
	-- WARGON.HAS_SKIN and "woodie_gladiator" or "woodie",
	"woodie",
	"beefalo_build",
}
local rider_4 = {
	-- WARGON.HAS_SKIN and "wolfgang_gladiator" or "wolfgang",
	"wolfgang",
	"beefalo_personality_pudgy",
}
local sign_rider_phy = {'char', 100, .5}
local sign_rider_shadow = {6, 2}
local signs = {"sign_home", "sign_home", "place"}

local function sign_rider_combat_re(inst)
	return WARGON.find(inst, 16*1.33, function(guy)
        return inst.components.combat:CanTarget(guy)
           and (not guy:HasTag("beefalo") or guy:HasTag("player"))
           and not guy:HasTag("alwaysblock")
    end)
end

local function sign_rider_combat_keep(inst, target)
	return inst.components.combat:CanTarget(target)
       and not target:HasTag("beefalo")
       and not target:HasTag("player")
end

local function sign_rider_on_hit(inst, data)
	if data.attacker then
		inst.components.combat:SetTarget(data.attacker)
	    inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
	    	return dude:HasTag("beefalo")
	    		and not dude:IsInLimbo()
	    		and not (dude.components.health:IsDead() or dude:HasTag("player"))
	    end, 5)
	    if math.random() < .2 then
	    	print("tp_fx_sign_three")
	    	local fx = WARGON.make_fx(inst, "tp_fx_sign_three")
	    	fx.master = inst
	    	fx.target = data.attacker
	    end
	end
end

local function sign_rider_on_new_target(inst, data)
	if data.target then
		inst.components.combat:ShareTarget(data.target, 30, function(dude)
			return dude:HasTag("tp_sign_rider")
		end, 5)
		-- for i = 1, 4 do
		-- 	local rider = nil
		-- 	if i <= 1 then
		-- 		rider = c_find("tp_sign_rider")
		-- 	else
		-- 		rider = c_find("tp_sign_rider_"..i)
		-- 	end
		-- 	if rider ~= inst then
		-- 	end
		-- end
	end
end

local function sign_rider_san_aoe(inst, observer)
	return -TUNING.SANITYAURA_LARGE
end

local function sign_weapon_drop(inst)
	inst:Remove()
end

local function sign_rider_equip_weapon(inst)
	if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
		local weapon = CreateEntity()
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(150)
        weapon.components.weapon:SetRange(7, 10)
        weapon.components.weapon:SetProjectile("tp_sign_proj")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(sign_weapon_drop)
        weapon:AddComponent("equippable")
        
        inst.components.inventory:Equip(weapon)
	end
end

local function MakeRider(name, builds, loot_prefabs)
	local function fn()
		local inst = WARGON.make_prefab(sign_riders, nil, sign_rider_phy, sign_rider_shadow, 6)
		-- inst.AnimState:AddOverrideBuild('beefalo_build')
		inst.AnimState:SetBuild(builds[1])
		inst.AnimState:AddOverrideBuild("beefalo_build")
		inst.AnimState:AddOverrideBuild(builds[2])
		inst.AnimState:Hide("head")
		WARGON.CMP.add_cmps(inst, {
			inspect = {},
			loco = {walk=2, run=7},
			combat = {dmg=150, range=7, per=2,
				re={time=3, fn=sign_rider_combat_re},
				keep=sign_rider_combat_keep,
				player=.5},
			health = {max=2500, regen={5, 20}, fire=0},
			loot = {loot=loot_prefabs},
			-- san_aoe = {fn=sign_rider_san_aoe},
			inv = {},
			})
		-- WARGON.make_map(inst, 'tent.png')
		WARGON.add_tags(inst, {
			"beefalo", "epic", "largecreature", "scarytoprey", "tp_sign_rider",
			})
		WARGON.add_listen(inst, {
			attacked = sign_rider_on_hit,
			newcombattarget = sign_rider_on_new_target,
			})
		WARGON.EQUIP.object_on(inst, "tp_sign_staff", "swap_object")
		inst:SetBrain(require "brains/tp_sign_rider_brain")
		inst:SetStateGraph('SGtp_sign_rider')
		WARGON.do_task(inst, 0, sign_rider_equip_weapon)
		inst.atk_num = 0
		-- if name == "tp_sign_rider" then
		-- 	inst:ListenForEvent("death", function()
		-- 		WARGON.make_spawn(inst, "tp_angry_remove")
		-- 	end)
		-- end

		return inst
	end
	return Prefab("common/"..name, fn, {})
end

local function sign_proj_hit(inst)
	inst:Remove()
end

local function proj()
	local inst = WARGON.make_prefab({}, nil, 'inv')
	RemovePhysicsColliders(inst)
	inst:AddTag('projectile')
	WARGON.no_save(inst)
	WARGON.CMP.add_cmps(inst, {
		proj = {speed=20, hit=sign_proj_hit},
		})
	inst.components.projectile:SetHitDist(3)
	WARGON.per_task(inst, .1, function()
		local fx = WARGON.make_fx(inst, 'tp_fx_sign')
		WARGON.do_task(fx, .5, function()
			fx:Remove()
		end)
	end)

	return inst
end

return 
	-- Prefab('common/tp_sign_rider', fn, assets),
	MakeRider("tp_sign_rider", rider_1, {"tp_sign_staff"}),
	MakeRider("tp_sign_rider_2", rider_2, {"tp_epic", "tp_epic", "tp_epic", "tp_epic", "tp_epic", }),
	MakeRider("tp_sign_rider_3", rider_3, {"tp_boss_loot"}),
	MakeRider("tp_sign_rider_4", rider_4, {"tp_angry_remove"}),
	Prefab('common/inventory/tp_sign_proj', proj, assets)