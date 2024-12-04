local Util = require "extension.lib.wg_util"
local PrefabUtil = require "extension.lib.prefab_util"

require("brains/wargbrain")
require "stategraphs/SGwarg"

SetSharedLootTable('tp_blue_warg',
{
    {'bluegem',             1.00},
    {'bluegem',             1.00},
    {'bluegem',             0.50},
    {'bluegem',             0.50},
    
    {'houndstooth',             1.00},
    {'houndstooth',             0.66},
    {'houndstooth',             0.33},
    {'tp_beast_essence',             1.00},
})
SetSharedLootTable('tp_red_warg',
{
    {'redgem',             1.00},
    {'redgem',             1.00},
    {'redgem',             0.50},
    {'redgem',             0.50},
    
    {'houndstooth',             1.00},
    {'houndstooth',             0.66},
    {'houndstooth',             0.33},
    {'tp_beast_essence',             1.00},
})

local function RetargetFn(inst)
	if inst.sg:HasStateTag("hidden") then return end
    return FindEntity(inst, TUNING.WARG_TARGETRANGE, function(guy)
        return inst.components.combat:CanTarget(guy) 
        and not guy:HasTag("wall") 
        and not guy:HasTag("warg") 
        and not guy:HasTag("hound")
    end)
end

local function KeepTargetFn(inst, target)
	if inst.sg:HasStateTag("hidden") then return end
    if target then
        return distsq(inst:GetPosition(), target:GetPosition()) < 40*40
        and not target.components.health:IsDead()
        and inst.components.combat:CanTarget(target)
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
	inst.components.combat:ShareTarget(data.attacker, TUNING.WARG_MAXHELPERS, function(dude)
	        return dude:HasTag("warg") or dude:HasTag("hound") 
	        and not dude.components.health:IsDead()
		end, TUNING.WARG_TARGETRANGE)
	-- if data.damage and (data.damage<30 and math.random() < .2)
	-- or (data.damage>=30 and math.random() < .5) then
	-- 	if inst:HasTag("tp_blue_warg") then
	-- 		inst.components.lootdropper:SpawnLootPrefab("bluegem")
	-- 	elseif inst:HasTag("tp_red_warg") then
	-- 		inst.components.lootdropper:SpawnLootPrefab("redgem")
	-- 	end
	-- end
end

local function MakeWarg(name, bank, build, tag, loot)
	local function fn()
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		local sound = inst.entity:AddSoundEmitter()
		local shadow = inst.entity:AddDynamicShadow()
		shadow:SetSize( 2.5, 1.5 )

		local s = 1
		trans:SetScale(s,s,s)

		trans:SetSixFaced()
		MakeCharacterPhysics(inst, 1000, 2)
		MakePoisonableCharacter(inst)

		anim:SetBank(bank)
		anim:SetBuild(build)
		anim:PlayAnimation("idle")

		inst:AddTag("monster")
		inst:AddTag("warg")
		inst:AddTag("scarytoprey")
		inst:AddTag("houndfriend")
		inst:AddTag("largecreature")
		inst:AddTag(tag)

		inst.has_friend = true

		inst:AddComponent("inspectable")

		inst:AddComponent("leader")

		inst:AddComponent("locomotor")
		inst.components.locomotor.runspeed = TUNING.WARG_RUNSPEED
	    inst.components.locomotor:SetShouldRun(true)

		inst:AddComponent("combat")
	    inst.components.combat:SetDefaultDamage(TUNING.WARG_DAMAGE)
	    inst.components.combat:SetRange(TUNING.WARG_ATTACKRANGE)
	    inst.components.combat:SetAttackPeriod(TUNING.WARG_ATTACKPERIOD)
	    inst.components.combat:SetRetargetFunction(1, RetargetFn)
	    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
	    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/vargr/hit")
		inst.components.combat.dmg_type = "slash"
		inst.components.combat:SetDmgTypeAbsorb("strike", .8)
		inst.components.combat:SetDmgTypeAbsorb("spike", 1.1)
		inst.components.combat:SetDmgTypeAbsorb("slash", .9)
		inst.components.combat:SetDmgTypeAbsorb("thump", 1.2)
		inst.components.combat:SetDmgTypeAbsorb("fire", .8)
		inst.components.combat:SetDmgTypeAbsorb("ice", .8)
		inst.components.combat:SetDmgTypeAbsorb("shadow", .8)
		inst.components.combat:SetDmgTypeAbsorb("electric", .7)
	    inst:ListenForEvent("attacked", OnAttacked)

		inst:AddComponent("health")
	    inst.components.health:SetMaxHealth(TUNING.WARG_HEALTH*2)

		inst:AddComponent("lootdropper")
	    inst.components.lootdropper:SetChanceLootTable(name) 

	    -- inst:AddComponent("sleeper")

		MakeLargeFreezableCharacter(inst)
		-- MakeLargeBurnableCharacter(inst, "swap_fire")

        inst:AddComponent("tp_creature_equip")
        inst:DoTaskInTime(0, function()
            inst.components.tp_creature_equip:Random()
        end)

        inst.percent = .9
        inst:ListenForEvent("healthdelta", function(inst, data)
            if data.newpercent and data.newpercent<=inst.percent then
                inst.components.lootdropper:SpawnLootPrefab(loot)
                inst.percent = inst.percent-.1
            end
        end)

		inst.OnSave = function(inst, data)
			if data then 
				data.has_friend = inst.has_friend 
                data.percent = inst.percent
			end
		end
		inst.OnLoad = function(inst, data)
			if data then
				inst.has_friend = data.has_friend
                inst.percent = data.percent or 0
			end
		end

		inst.spawned = 1
		inst.spawn_hound = function(inst)
			local x, y, z = inst:GetPosition():Get()
			local ents = TheSim:FindEntities(x, y, z, 20, {"hound"} )
			if #ents < 3 then
				for i = 1, inst.spawned do
					local hound = SpawnPrefab("hound")
					hound.components.follower:SetLeader(inst)
					hound.Transform:SetPosition(inst:GetPosition():Get())
				end
				inst.spawned = math.min(3,inst.spawned + 1)
			end
		end
		-- boss房门
		inst:DoTaskInTime(0, function()
			local door = FindEntity(inst, 100, nil, {"interior_door"})
			if door then
				door:AddTag("NOCLICK")
			end
		end)
		inst:ListenForEvent("death", function(inst, data)
			local door = FindEntity(inst, 100, nil, {"interior_door"})
			if door then
				door:RemoveTag("NOCLICK")
			end
		end)

		inst:SetStateGraph("SGtp_warg")
		inst:SetBrain(require("brains/wargbrain"))
		-- inst:DoTaskInTime(0, function()
		-- 	if c_countprefabs(name) > 3 then
		-- 		inst:Remove()
		-- 	end
		-- end)

		return inst
	end
	return Prefab("common/"..name, fn, {
        Asset("ANIM", "anim/"..name..".zip"),
    })
end

local function MakeSpawner(name, warg)
	local function fn()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        
        inst:DoTaskInTime(0, function()
			-- local warg = math.random() < .5 and "tp_blue_warg" or "tp_red_warg"
			if c_find(warg) == nil then
				local boss = SpawnPrefab(warg)
                boss.Transform:SetPosition(inst:GetPosition():Get())
				boss.has_friend = false
			end
			inst:Remove()
		end)

		return inst
	end
	return Prefab("common/"..name, fn, {})
end

Util:AddString("tp_red_warg", "宝石座狼", "由宝石镶嵌而成的身体")
Util:AddString("tp_blue_warg", "宝石座狼", "由宝石镶嵌而成的身体")

local boss_room = deepcopy(require "prefabs/tp_boss_room")
PrefabUtil:SetPrefabName(boss_room, "tp_blue_warg_room")
PrefabUtil:HookPrefabFn(boss_room, function(inst)
    inst.boss_name = "tp_blue_warg"
    inst.AnimState:SetBank("vampbat_den")
    inst.AnimState:SetBuild("vamp_bat_entrance")
    inst.AnimState:PlayAnimation("idle")
	inst.cave = true
	inst:DoTaskInTime(0, function()
		inst.components.wg_start:AddFn(function()
            -- SpawnPrefab("tp_boss_obstacle_spawner").Transform:SetPosition(inst:GetPosition():Get())
        end)
    end)
end)
-- table.insert(prefs, boss_room)
Util:AddString(boss_room.name, "洞穴", "我该去里面探险一下吗?")

local boss_room2 = deepcopy(boss_room)
PrefabUtil:SetPrefabName(boss_room2, "tp_red_warg_room")
PrefabUtil:HookPrefabFn(boss_room2, function(inst)
    inst.boss_name = "tp_red_warg"
end)
-- table.insert(prefs, boss_room2)
Util:AddString(boss_room2.name, "洞穴", "我该去里面探险一下吗?")

return 
	MakeWarg("tp_blue_warg", "tp_blue_warg", "tp_blue_warg", "tp_blue_warg", "bluegem"),
	MakeWarg("tp_red_warg", "tp_red_warg", "tp_red_warg", "tp_red_warg", "redgem"),
	-- MakeSpawner("tp_warg_spawner"),
	MakeSpawner("tp_blue_warg_spawner", "tp_blue_warg"),
	MakeSpawner("tp_red_warg_spawner", "tp_red_warg"),
	boss_room, boss_room2