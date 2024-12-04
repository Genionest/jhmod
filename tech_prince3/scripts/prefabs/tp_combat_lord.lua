local FxManager = Sample.FxManager
local Info = Sample.Info
local Kit = require "extension.lib.wargon"

local BossConst = {
    2500, -- max_hp
    100, -- dmg
    50, -- exp
}
local BossConst2 = {
    1300, -- max_hp
    50, -- dmg
    30, -- exp
}

local function combat_re(inst)
	return FindEntity(inst, 16*1.33, function(guy)
        return inst.components.combat:CanTarget(guy)
           and guy:HasTag("player")
    end)
end

local function combat_keep(inst, target)
	return inst.components.combat:CanTarget(target)
       -- and target:HasTag("player")
end

local function on_attacked(inst, data)
	if data.attacker then
		inst.components.combat:SetTarget(data.attacker)
        inst.components.combat:ShareTarget(data.attacker, 30, function(dude) 
	    	return dude:HasTag("tp_combat_lord") 
	    end, 5)
	end
end

local function close_door(inst)
	local door = FindEntity(inst, 100, nil, {"interior_door"})
	if door then
		door:AddTag("NOCLICK")
	end
end

local function open_door(inst)
	if inst.prefab ~= "tp_combat_lord" then
        local x, y, z = inst:GetPosition():Get()
        local lords = TheSim:FindEntities(x, y, z, 100, {"tp_combat_lord"})
		local can_open = true
		for k, v in pairs(lords) do
			if v.components.health
			and not v.components.health:IsDead() then
				can_open = false
			end
		end
		if can_open then
			local door = FindEntity(inst, 100, nil, {"interior_door"})
			if door then
				door:RemoveTag("NOCLICK")
			end
		end
	end
end

local function combat_lord_on_hit_other(inst, data)
	-- data.target:add_buff("recover_debuff")
end

local function combat_lord_on_death(inst, data)
	if inst.prefab == "tp_combat_lord" then
		for i = 2, 3 do
			inst:DoTaskInTime(i, function()
				local pos = Kit:find_walk_pos(inst, 4)
				if pos then
				    FxManager:MakeFx("statue_transition", pos)
					local lord = SpawnPrefab("tp_combat_lord"..i)
                    lord.Transform:SetPosition(pos:Get())
					local target = inst.components.combat.target
					if target then
						lord.components.combat:SetTarget(target)
					end
				end
			end)
		end
		inst.spawn_friend = false
	end
end

local function combat_lord_can_attacked(inst, attacker)
	return not inst.components.health:IsInvincible()
end

local function catch_spear(inst)
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_object", "swap_spear_wathgrithr", "swap_spear_wathgrithr")
	inst:RemoveTag("spear_thrown")
    -- inst:DoTaskInTime(1, function()
    --     inst.sg:GoToState("tp_tou_start")
    -- end)
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    trans:SetFourFaced()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeCharacterPhysics(inst, 75, .5)
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wathgrithr")
    inst.AnimState:PlayAnimation("idle")
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(1.3, .6)
    
    MakeMediumBurnableCharacter(inst, "body")
    MakeLargeFreezableCharacter(inst)
    MakePoisonableCharacter(inst, nil, nil, 0, 0, 0)

    inst:AddTag("epic")
    inst:AddTag("tp_room_boss")
    inst:AddComponent("inspectable")
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(BossConst[1])
    inst.components.health:StartRegen(20, 5)
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(BossConst[2])
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat:SetRange(12, 3)
    inst.components.combat:SetRetargetFunction(3, combat_re)
    inst.components.combat:SetKeepTargetFunction(combat_keep)
    inst.components.combat.dmg_type = "strike"
    inst.components.combat:SetDmgTypeAbsorb("strike", .8)
    inst.components.combat:SetDmgTypeAbsorb("spike", .8)
    inst.components.combat:SetDmgTypeAbsorb("slash", .8)
    inst.components.combat:SetDmgTypeAbsorb("thump", .8)
    inst.components.combat:SetDmgTypeAbsorb("electric", 1.1)
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({
        unpack(Info.GeneralBossLoot)
    })
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    inst.AnimState:Hide("HEAD")
    inst.AnimState:Show("HEAD_HAIR")
    inst.AnimState:Hide("HAIRFRONT")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_ruins", "swap_hat")
    inst.AnimState:OverrideSymbol("swap_body", "armor_ruins", "swap_body")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_object", "swap_spear_wathgrithr", "swap_spear_wathgrithr")

    inst:AddTag("groundpoundimmune")
    inst:AddComponent("groundpounder")
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 3
    inst.components.groundpounder.destructionRings = 4
    inst.components.groundpounder.numRings = 5
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 3
    inst.components.groundpounder.destructionRings = 4
    inst.components.groundpounder.numRings = 5
    -- inst.components.groundpounder.groundpoundfx = "groundpoundring_fx"
    inst.components.combat.canbeattackedfn = combat_lord_can_attacked
    inst.catch_spear = catch_spear
    -- 战矛扔出去之后不能攻击
    local can_attack = inst.components.combat.CanAttack
    inst.components.combat.CanAttack = function(cmp, target)
        if inst:HasTag("spear_thrown") then
            return false
        end
        return can_attack(cmp, target)
    end
    inst:SetBrain(require "brains/tp_creature_brain2")
	inst:SetStateGraph("SGtp_combat_lord")
	
    inst:DoTaskInTime(0, function()
		close_door(inst)
	end)
	inst:ListenForEvent("death", open_door)
	inst:ListenForEvent("death", combat_lord_on_death)

    inst.components.combat.onkilledbyother = function(inst, attacker)
        if attacker.components.tp_level then
            attacker.components.tp_level:ExpDelta(BossConst[3])
        end
    end

    return inst
end

local function fn2()
    local inst = fn()
    inst.AnimState:SetBuild("wendy")
    return inst
end

local function fn3()
    local inst = fn()
    inst.AnimState:SetBuild("willow")
    return inst
end

local function fn4()
    local inst = fn()
    inst.AnimState:SetBuild("willow")
    inst.components.health:SetMaxHealth(BossConst2[1])
    inst.components.combat:SetDefaultDamage(BossConst2[2])
    inst.components.combat.onkilledbyother = function(inst, attacker)
        if attacker.components.tp_level then
            attacker.components.tp_level:ExpDelta(BossConst2[3])
        end
    end
    return inst
end

local proj = function()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.AnimState:SetBank("boomerang")
    inst.AnimState:SetBuild("boomerang")
    inst.AnimState:PlayAnimation("spin_loop", true)
    MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
	inst:AddTag('projectile')
    inst.persists = false
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(30)
    inst:AddComponent("wg_projectile")
    inst.components.wg_projectile:SetSpeed(10)
    inst.components.wg_projectile:SetOnThrownFn(function(inst, owner, target) end)
    inst.components.wg_projectile:SetOnMissFn(function(inst, owner, target) 
        catch_spear(owner)
        inst:Remove()
    end)
    inst.components.wg_projectile:SetOnHitFn(function(inst, owner, target)
        inst.components.wg_projectile.onmiss(inst, owner, target)
    end)
    inst.components.wg_projectile:SetLaunchOffset(Vector3(0, 2, 0))
    inst.components.wg_projectile.test = function(inst, target, doer)
        return true
    end
    inst.components.wg_projectile:SetOnCaughtFn(function(inst, catcher)
    end)
	-- inst.components.wg_projectile:SetHitDist(3)

	return inst
end

local PrefabUtil = require "extension.lib.prefab_util"
local room = deepcopy(require "prefabs/tp_boss_room")
PrefabUtil:SetPrefabName(room, "tp_combat_lord_room")
PrefabUtil:HookPrefabFn(room, function(inst)
    inst.boss_name = "tp_combat_lord"
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wathgrithr")
    inst.AnimState:PlayAnimation("sleep")
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    inst.AnimState:Hide("HEAD")
    inst.AnimState:Show("HEAD_HAIR")
    inst.AnimState:Hide("HAIRFRONT")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_ruins", "swap_hat")
    inst.AnimState:OverrideSymbol("swap_body", "armor_ruins", "swap_body")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_object", "swap_spear_wathgrithr", "swap_spear_wathgrithr")

    inst:DoTaskInTime(0, function()
        local pos = inst:GetPosition()
        SpawnPrefab("tp_boss_room_hut").Transform:SetPosition(inst:GetPosition():Get())
        SpawnPrefab("tp_boss_room_rug").Transform:SetPosition(inst:GetPosition():Get())
        inst.components.wg_start:AddFn(function()
            -- SpawnPrefab("tp_boss_obstacle_spawner").Transform:SetPosition(inst:GetPosition():Get())
        end)
        pos.y = pos.y+.1
        inst.Transform:SetPosition(pos:Get())
    end)
end)

local room2 = deepcopy(room)
PrefabUtil:SetPrefabName(room2, "tp_combat_lord4_room")
PrefabUtil:HookPrefabFn(room2, function(inst)
    inst.boss_name = "tp_combat_lord4"
    inst.AnimState:SetBuild("willow")
end)

local Util = require "extension.lib.wg_util"
Util:AddString("tp_combat_lord", "锯齿领主", "锯齿的领主")
Util:AddString("tp_combat_lord2", "锯齿领主", "锯齿的领主")
Util:AddString("tp_combat_lord3", "锯齿领主", "锯齿的领主")
Util:AddString("tp_combat_lord4", "锯齿先锋", "锯齿的先锋")
Util:AddString("tp_combat_lord_room", "锯齿领主的梦境", "里面应该有什么大宝贝")
Util:AddString("tp_combat_lord4_room", "锯齿先锋的梦境", "里面应该有什么大宝贝")

return Prefab("tp_combat_lord", fn, {}),
Prefab("tp_combat_lord2", fn2, {}),
Prefab("tp_combat_lord3", fn3, {}),
Prefab("tp_combat_lord4", fn4, {}),
Prefab("tp_combat_lord_proj", proj, {}),
    room, room2