local Kit = require "extension.lib.wargon"
local EntUtil = require "extension.lib.ent_util"
local Info = Sample.Info
local FxManager = Sample.FxManager

local function fn(inst)
    inst:AddTag("world_boss")
    inst.components.lootdropper:AddChanceLoot("ak_ssd", 1)
    inst.components.lootdropper:AddChanceLoot("ak_ssd", 1)
    -- inst.components.lootdropper:AddChanceLoot("ak_ssd", 1)
    -- inst.components.lootdropper:AddChanceLoot("ak_ssd", 1)
    inst.components.lootdropper:AddChanceLoot("tp_epic", 1)
    inst.components.lootdropper:AddChanceLoot("tp_epic", 1)
    inst.components.lootdropper:AddChanceLoot("tp_gift", 1)
    -- inst.components.lootdropper:AddChanceLoot("tp_advance_chip", 1)
    -- inst.components.lootdropper:AddChanceLoot("tp_alloy_enchant2", 1)
end
for k, v in pairs(Info.Boss) do
    AddPrefabPostInit(v, fn)
end

for k, v in pairs(Info.Epic) do
    AddPrefabPostInit(v, function(inst)
        inst:AddTag("epic")
        inst.components.lootdropper:AddChanceLoot("ak_ssd", .33)
        inst.components.lootdropper:AddChanceLoot("tp_epic", .33)
        -- inst.components.lootdropper:AddChanceLoot("tp_alloy_enchant2", 1)
    end)
end

local function fn(inst)
    inst:ListenForEvent("attacked", function(inst, data)
        if EntUtil:can_thorns(data) then
            FxManager:MakeFx("snow_ball_dropper", inst, {owner=inst})
        end
    end)
end
AddPrefabPostInit("deerclops", fn)

local function fn(inst)
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.destructionRings = 1
    -- 龙蝇的伤害不会随着周围生物的数量提升, 这是个bug
    local cmp = inst.components.groundpounder
    function cmp:DestroyPoints(points, breakobjects, dodamage)
        local getEnts = breakobjects or dodamage
        for k,v in pairs(points) do
            local ents = nil
            if getEnts then
                ents = TheSim:FindEntities(v.x, v.y, v.z, 3, nil, self.noTags)
            end
            if ents and breakobjects then
                -- first check to see if there's crops here, we want to work their farm
                for k2,v2 in pairs(ents) do
                    if v2 and self.burner and v2.components.burnable and not v2:HasTag("fire") and not v2:HasTag("burnt") then
                        v2.components.burnable:Ignite()
                    end
                    -- Don't net any insects when we do work
                    if v2 and self.destroyer and v2.components.workable and v2.components.workable.workleft > 0 and v2.components.workable.action ~= ACTIONS.NET then
                        v2.components.workable:Destroy(self.inst)
                end
                    if v2 and self.destroyer and v2.components.crop then
                        print("Has Crop:",v2)
                        v2.components.crop:ForceHarvest()
                    end
                end
            end
            if ents and dodamage then
                for k2,v2 in pairs(ents) do
                    if not self.ignoreEnts then 
                        self.ignoreEnts = {}
                    end 
                    if not self.ignoreEnts[v2.GUID] then --If this entity hasn't already been hurt by this groundpound
                        if v2 and v2.components.health and not v2.components.health:IsDead() and 
                        self.inst.components.combat:CanTarget(v2) then
                            EntUtil:get_attacked(v2, inst, 0, nil, nil, true)
                            -- self.inst.components.combat:DoAttack(v2, nil, nil, nil, self.groundpounddamagemult)
                        end
                        self.ignoreEnts[v2.GUID] = true --Keep track of which entities have been hit 
                    end 
                end
            end
            local map = GetMap()
            if map then
                local ground = map:GetTileAtPoint(v.x, 0, v.z)
                if ground == GROUND.IMPASSABLE or map:IsWater(ground) then
                    --Maybe do some water fx here?
                else
                    if self.groundpoundfx then 
                        SpawnPrefab(self.groundpoundfx).Transform:SetPosition(v.x, 0, v.z)
                    end 
                end
            end
        end
    end
end
AddPrefabPostInit("dragonfly", fn)

local function fn(sg)
    local old_timeline = sg.states["taunt"].timeline
    table.insert(old_timeline, TimeEvent(0*FRAMES, function(inst)
        if inst:HasTag("wg_slience") then
            return
        end
        local delay = 0.0
        for i = 1, 6 do
            inst:DoTaskInTime(delay, function(inst)
                local target = inst.components.combat.target or inst
                local pos = Vector3(target.Transform:GetWorldPosition())
                local x, y, z = TUNING.VOLCANOBOOK_FIRERAIN_RADIUS * UnitRand() + pos.x, pos.y, TUNING.VOLCANOBOOK_FIRERAIN_RADIUS * UnitRand() + pos.z
                local firerain = SpawnPrefab("firerain")
                firerain.Transform:SetPosition(x, y, z)
                firerain:StartStep()
                firerain.tp_owner = inst
            end)
            delay = delay + TUNING.VOLCANOBOOK_FIRERAIN_DELAY
        end
    end) )
end
AddStategraphPostInit("dragonfly", fn)

AddPrefabPostInit("mossling", function(inst)
    inst.components.combat.canbeattackedfn = function(inst, attacker)
        return not attacker:HasTag("moose")
    end
end)
AddPrefabPostInit("moose", function(inst)
    inst.components.combat:SetAreaDamage(TUNING.DEERCLOPS_AOE_RANGE, TUNING.DEERCLOPS_AOE_SCALE)
end)
local function fn(sg)
    local old_timeline = sg.states["disarm"].timeline
    table.insert(old_timeline, TimeEvent(15*FRAMES, function(inst)
        if inst:HasTag("wg_slience") then
            return
        end
        local function getspawnlocation(inst, target)
            local tarPos = target:GetPosition()
            local pos = inst:GetPosition()
            local vec = tarPos - pos
            vec = vec:Normalize()
            local dist = pos:Dist(tarPos)
            return pos + (vec * (dist * .15))
        end
        local target = inst.components.combat.target
        if target and not target:HasTag("tp_wind_power")
        and EntUtil:is_alive(inst) then
            if target.components.inventory then
                target.components.inventory:DropEverything()
            end
            local tornado = SpawnPrefab("tornado")
            tornado.WINDSTAFF_CASTER = inst
            tornado:ListenForEvent("death", inst.Remove, inst)
            local totalRadius = target.Physics and target.Physics:GetRadius() or 0.5 + tornado.Physics:GetRadius() + 0.5
            local targetPos = target:GetPosition() + (TheCamera:GetDownVec() * totalRadius)
            tornado.Transform:SetPosition(getspawnlocation(inst, target):Get())
            tornado.components.knownlocations:RememberLocation("target", targetPos)
        end
    end) )
end
AddStategraphPostInit("moose", fn)

local function fn(inst)
    local cmp = inst.components.groundpounder
    local GroundPound = cmp.GroundPound
    function cmp:GroundPound(pt)
        GroundPound(self, pt)
        if not inst:HasTag("wg_slience") then
            local fx = FxManager:MakeFx("bearger_line", inst, {owner=inst})
        end
    end
    function cmp:DestroyPoints(points, breakobjects, dodamage)
        local getEnts = breakobjects or dodamage
        for k,v in pairs(points) do
            local ents = nil
            if getEnts then
                ents = TheSim:FindEntities(v.x, v.y, v.z, 3, nil, self.noTags)
            end
            if ents and breakobjects then
                -- first check to see if there's crops here, we want to work their farm
                for k2,v2 in pairs(ents) do
                    if v2 and self.burner and v2.components.burnable and not v2:HasTag("fire") and not v2:HasTag("burnt") then
                        v2.components.burnable:Ignite()
                    end
                    -- Don't net any insects when we do work
                    if v2 and self.destroyer and v2.components.workable and v2.components.workable.workleft > 0 and v2.components.workable.action ~= ACTIONS.NET then
                        v2.components.workable:Destroy(self.inst)
                end
                    if v2 and self.destroyer and v2.components.crop then
                        print("Has Crop:",v2)
                        v2.components.crop:ForceHarvest()
                    end
                end
            end
            if ents and dodamage then
                for k2,v2 in pairs(ents) do
                    if not self.ignoreEnts then 
                        self.ignoreEnts = {}
                    end 
                    if not self.ignoreEnts[v2.GUID] then --If this entity hasn't already been hurt by this groundpound
                        if v2 and v2.components.health and not v2.components.health:IsDead() and 
                        self.inst.components.combat:CanTarget(v2) then
                            EntUtil:get_attacked(v2, inst, 0, nil, nil, true)
                            -- self.inst.components.combat:DoAttack(v2, nil, nil, nil, self.groundpounddamagemult)
                        end
                        self.ignoreEnts[v2.GUID] = true --Keep track of which entities have been hit 
                    end 
                end
            end
            local map = GetMap()
            if map then
                local ground = map:GetTileAtPoint(v.x, 0, v.z)
                if ground == GROUND.IMPASSABLE or map:IsWater(ground) then
                    --Maybe do some water fx here?
                else
                    if self.groundpoundfx then 
                        SpawnPrefab(self.groundpoundfx).Transform:SetPosition(v.x, 0, v.z)
                    end 
                end
            end
        end
    end
end
AddPrefabPostInit("bearger", fn)

local function fn(inst)
    MakeHugeFreezableCharacter(inst, "innerds")
    inst.tp_fxs = {}
    inst:DoTaskInTime(0, function()
        inst.Transform:SetRotation(0)
        local vals = {
            {6, -70}, {5, -35}, {5, 0}, {5, 35}, {6, 70}
        }
        for i = 1, 5 do
            local radius = vals[i][1]
            local angle = 0
            local rot = angle + vals[i][2]*PI/180
            local x = 0 + math.cos(rot)*radius
            local z = 0 + math.sin(rot)*radius
            local pt = Vector3(x, 0, z)
            local fx = FxManager:MakeFx("minotaur_shadow", pt, {owner=inst})
            inst:AddChild(fx)
            table.insert(inst.tp_fxs, fx)
            fx:Hide()
        end
    end)
    inst.tp_turn_on = function(inst)
        for _, fx in pairs(inst.tp_fxs) do
            fx:Show()
        end
        if inst.tp_task == nil then
            inst.tp_enemies = {}
            inst.tp_task2 = inst:DoPeriodicTask(.5, function()
                inst.tp_enemies = {}
            end)
            inst.tp_task = inst:DoPeriodicTask(.1, function()
                for _, fx in pairs(inst.tp_fxs) do
                    local dmg = 50
                    local mult = inst.components.combat:GetDamageModifier()
                    EntUtil:make_area_dmg2(fx, 4, inst, dmg*mult, nil, 
                        EntUtil:add_stimuli(nil, "pure"), {
                            -- calc=true,
                            test = function(v, attacker, weapon)
                                return inst.tp_enemies[v] == nil
                            end,
                            fn = function(v, attacker, weapon)
                                inst.tp_enemies[v] = true
                            end,
                        }
                    )
                end
            end)
        end
    end
    inst.tp_turn_off = function(inst)
        for _, fx in pairs(inst.tp_fxs) do
            fx:Hide()
        end
        if inst.tp_task then
            inst.tp_task:Cancel()
            inst.tp_task = nil
        end
        if inst.tp_task2 then
            inst.tp_task2:Cancel()
            inst.tp_task2 = nil
        end
        inst.tp_enemies = nil
    end
end
AddPrefabPostInit("minotaur", fn)

local function fn(sg)
    local onenter = sg.states["run"].onenter
    sg.states["run"].onenter = function(inst, ...)
        onenter(inst, ...)
        if inst.tp_task3 then
            inst.tp_task3:Cancel()
            inst.tp_task3 = nil
        end
        if not inst:HasTag("wg_slience") then
            inst:tp_turn_on()
        end
    end
    local onexit = sg.states["run"].onexit
    sg.states["run"].onexit = function(inst, ...)
        if onexit then
            onexit(inst, ...)
        end
        if inst.tp_task3 == nil then
            inst.tp_task3 = inst:DoTaskInTime(.3, function()
                inst:tp_turn_off()
            end)
        end
    end
    local onenter2 = sg.states["run_stop"].onenter
    sg.states["run_stop"].onenter = function(inst, ...)
        onenter2(inst, ...)
        inst:tp_turn_off()
    end
end
AddStategraphPostInit("minotaur", fn)

local rog_boss ={
    deerclops=1, dragonfly=1, moose=1, bearger=1, minotaur=1
}
for k, v in pairs(rog_boss) do
    AddPrefabPostInit(k, function(inst)
        inst.components.lootdropper:AddChanceLoot("tp_beast_essence", 1)
    end)
end

local function boss_power(inst)
    local n = math.random(5)
    local boss 
    for k, v in pairs(rog_boss) do
        n = n-1
        if n <= 0 then
            boss = k
            break
        end
    end
    if not inst:HasTag("wg_slience") then
        FxManager:MakeFx(boss.."_power", inst, {owner=inst})
    end
end

local function fn(inst)
    inst.tp_atk = 0
    inst:ListenForEvent("doattack", function(inst, data)
        if data and not (data.stimuli 
        and EntUtil:in_stimuli(data.stimuli, "pure")) then
            inst.tp_atk = inst.tp_atk + 1
            if inst.tp_atk >= 3 then
                inst.tp_atk = 0
                boss_power(inst)
            end
        end
    end)
end
for k, v in pairs(Info.Boss) do
    if rog_boss[v] == nil then
        AddPrefabPostInit(v, fn)
    end
end

local other_boss_sg = {
    "antqueen", "kraken", "tigershark_ground", "twister", "ancient_herald",
    "ancient_hulk",
}
local function fn(sg)
    if sg.states["taunt"] then
        local old_timeline = sg.states["taunt"].timeline
        if old_timeline then
            table.insert(old_timeline, TimeEvent(0 * FRAMES, function(inst) 
                boss_power(inst)
                inst.tp_atk = 0
            end))
        end
    end
end
for k, v in pairs(other_boss_sg) do
    AddStategraphPostInit(v, fn)
end