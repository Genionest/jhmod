local Sounds = require "extension.datas.sounds"

local EntUtil = {}

-- 非实体的标签
EntUtil.not_entity_tags = {
    "falling", "FX", "NOCLICK", "DECOR", "INLIMBO", 
}

-- 非敌对生物的标签
EntUtil.not_enemy_tags = {
    "falling", "FX", "NOCLICK", "DECOR", "INLIMBO", 
    "eyeturret", "companion", "player", "wall",
}

--[[
获取目标位置  
(Vector3)/(number)x,(number)y,(number)z 返回对应的位置  
pt, (EntityScript/Vector3)需要获取位置的目标  
is_v, 为true则返回类型为Vector3，否则返回x,y,z  
]]
local function GetPos(pt, is_v)
    assert(type(pt)=="table", "arguments \"pt\" must be table.")
    if pt.Get then
		if is_v then
			return pt 
		else
			return pt:Get()
		end
    elseif pt.GetPosition then
		if is_v then
			return pt:GetPosition() 
		else
			return pt:GetPosition():Get()
		end
    else
        assert(nil, string.format("arguments \"pt\"(%s) is invalid.", tostring(pt)))
    end
end

--[[
判断实体是否存活  
(bool) 返回bool
inst (EntityScript)目标实体
]]
function EntUtil:is_alive(inst)
	if inst.components.health and not inst.components.health:IsDead()
	and inst:IsValid() then
		return true
	end
end

--[[
令实体受到攻击，需要事先判断其是否可以被攻击  
victim (EntityScript)受伤实体  
attacker (EntityScript)伤害来源  
damage (number/func)伤害数值/伤害函数func(victim,attacker,weapon,reason,dmg)  
weapon (EntityScript)武器，可以为nil  
reason (string)原因，可以为nil  
calc (bool)为true则会让伤害来源计算伤害并附加damage的伤害  
mult (number)计算伤害时的倍率，有这个默认calc为true    
]]
function EntUtil:get_attacked(victim, attacker, damage, weapon, reason, calc, mult)
    local dmg = 0
    if mult or calc then
        dmg = attacker.components.combat:CalcDamage(victim, weapon, mult, reason)
    end
	if type(damage) == "number" then
		dmg = dmg + damage
	elseif type(damage) == "function" then
		dmg = dmg + damage(victim, attacker, weapon, reason, dmg)
	end
    victim.components.combat:GetAttacked(attacker, dmg, weapon, reason)
end

--[[
检测目标能否被攻击，
检测其是否包含非敌人标签，是否为主体的随从，是否可被主体攻击，主体一般是player  
(bool) 返回bool  
attacker 攻击主体  
target 攻击目标  
]]
function EntUtil:check_combat_target(attacker, target)
    local can = true
    for k, v in pairs(self.not_enemy_tags) do
        if target:HasTag(v) then
            can = false
        end
    end
    if can then
		if not target.components.follower or target.components.follower.leader ~= attacker then
			if attacker.components.combat
			and attacker.components.combat:CanTarget(target) then
				return true
			end
		end
	end
end

--[[
检测目标能否被攻击  
检测其是否包含非实体标签，是否和主体是同类, 是否为主体的随从，是否可被主体攻击，主体一般是非player  
(bool) 返回bool，  
attacker 攻击主体  
target 攻击目标  
]]
function EntUtil:check_combat_target2(attacker, target)
    local can = true
    for k, v in pairs(self.not_entity_tags) do
        if target:HasTag(v) then
            can = false
        end
    end
	if attacker.components.combat.target ~= target 
	and self:check_congeneric(target) then
		can = false
	end
    if can then
		if not target.components.follower or target.components.follower.leader ~= attacker then
			if attacker.components.combat
			and attacker.components.combat:CanTarget(target) then
				return true
			end
		end
	end
end

--[[
造成范围伤害，主体一般是player  
pos (Vector3)中心位置  
range 攻击范围  
attacker 攻击主体  
damage (number/func)伤害数值/伤害函数func(victim,attacker,weapon,reason)  
weapon 武器，可以为nil  
reason 原因，可以为nil  
data 其他数据 {tags,no_tags,calc(bool),fn(func(v,attacker,weapon)),test(func(v,attacker,weapon)),mult(number),angle(number)}  
]]
function EntUtil:make_area_dmg(pos, range, attacker, damage, weapon, reason, data)
    data = data or {}
    local x, y, z = GetPos(pos)
    local ents = TheSim:FindEntities(x, y, z, range, data.tags, data.no_tags)
    for k, v in pairs(ents) do
        if self:check_combat_target(attacker, v)
		and (not data.test or data.test(v, attacker, weapon)) then
			local can = true
			-- data.angle表示角度判断, 需要pos是attacker, angle表示在attacker正前面多少角度内
			if data.angle then
				local angle = attacker.Transform:GetRotation()
				angle = angle%360
				local angle2 = v:GetAngleToPoint(pos:Get())%360
				if math.abs(angle-angle2)<data.angle/2 then
					can = false
				end
			end
			if can then
				self:get_attacked(v, attacker, damage, weapon, reason, data.calc, data.mult)
				if data.fn then data.fn(v, attacker, weapon) end
			end
        end
    end
end

--[[
造成范围伤害，主体一般是非player  
pos (Vector3)中心位置  
range 攻击范围  
damage (number/func)伤害数值/伤害函数func(inst,attacker,weapon,reason)  
damage 伤害数值  
weapon 武器，可以为nil  
reason 原因，可以为nil  
data 其他数据 {tags,no_tags,calc(bool),fn(func(v,attacker,weapon)),  test(func(v,attacker,weapon)),mult(number)}  
]]
function EntUtil:make_area_dmg2(pos, range, attacker, damage, weapon, reason, data)
    data = data or {}
    local x, y, z = GetPos(pos)
	local no_tags = data.no_tags or {}
	for k, v in pairs(self.not_entity_tags) do
		table.insert(no_tags, v)
	end
    local ents = TheSim:FindEntities(x, y, z, range, data.tags, no_tags)
    for k, v in pairs(ents) do
        if self:check_combat_target2(attacker, v)
		and (not data.test or data.test(v, attacker, weapon)) then
            self:get_attacked(v, attacker, damage, weapon, reason, data.calc, data.mult)
            if data.fn then data.fn(v, attacker, weapon) end
        end
    end
end

--[[
执行突刺  
weapon (entity) 武器  
doer (entity) 攻击者  
range (number) 攻击范围  
damage (number) 伤害  
stimuli (string) 伤害类型  
data (table) 伤害附加数据  
over_fn (func) 突刺结束时执行的函数  
]]
function EntUtil:do_lunge(weapon, doer, range, damage, stimuli, data, over_fn)
	weapon.enemies = {}
    doer:PushEvent("start_lunge", {weapon=weapon})
	weapon:PushEvent("weapon_start_lunge", {owner=doer})
    if doer.lunge_task == nil then
		doer.lunge_task = doer:DoPeriodicTask(.05, function()
			EntUtil:make_area_dmg(doer, range, doer, damage, weapon, stimuli, data)
		end)
	end
    if doer.lunge_event_fn == nil then
        doer.lunge_event_fn = EntUtil:listen_for_event(doer, "stop_lunge", function(weapon, data)
			if doer.lunge_task then
                doer.lunge_task:Cancel()
                doer.lunge_task = nil
            end
			if over_fn then
				over_fn(weapon, doer)
			end
        end)
    end
end

--[[
执行回旋斩击  
weapon (entity) 武器  
doer (entity) 攻击者  
range (number) 攻击范围  
damage (number) 伤害  
stimuli (string) 伤害类型  
data (table) 伤害附加数据  
ignore (bool) 推送事件时的参数  
]]
function EntUtil:do_cyclone_slash(weapon, doer, range, damage, stimuli, data, ignore)
    doer.SoundEmitter:PlaySound(Sounds.cyclone_slash)
    EntUtil:make_area_dmg(doer, range, doer, damage, weapon, stimuli, data)
    doer:PushEvent("cyclone_slash", {weapon=weapon, ignore=ignore})
	weapon:PushEvent("weapon_cyclone_slash", {owner=doer, ignore=ignore})
end

-- local stimuli_part = {
-- 	"pure", "thorns", "not_crit", "not_life_steal",
-- 	"not_evade",
-- }

--[[
是否包含某类伤害原因  
(bool) 返回bool  
stimuli (table/string)总伤害原因  
... (string)检查是否包含的伤害原因  
]]
function EntUtil:in_stimuli(stimuli, ...)
	local part = {...}
	if stimuli then
		if type(stimuli) == "string" then
			if #part == 1 then
				return stimuli == part[1]
			end
			return false
		end
		if type(stimuli) == "table" then
			for k, v in pairs(part) do
				if not stimuli[v] then
					return false
				end
			end
			return true
		end
		assert(nil, string.format("stimuli must be string or table, but get %s", tostring(stimuli)))
		-- for i=1, #stimuli do
		-- 	if string.byte(stimuli, i)==string.byte("a", 1) then
		-- 		return stimuli_part[i]==part
		-- 	end
		-- end
	end
end

--[[
添加伤害原因  
(string) 返回添加后的伤害原因  
stimuli (table/string)需要修改的伤害原因，可以为nil  
... (string)需要添加的部分  
]]
function EntUtil:add_stimuli(stimuli, ...)
	if stimuli == nil then
		-- stimuli = string.rep("b", #stimuli_part)
		stimuli = {}
	end
	if type(stimuli) == "string" then
		local t = {stimuli=true}
		stimuli = t
	end
	for k, v in pairs({...}) do
		stimuli[v] = true
	end
	-- assert(#stimuli==#stimuli_part, "stimuli format is fault")
	-- for i=1, #stimuli do
	-- 	if stimuli_part[i]==part then
	-- 		-- string.gsub(stimuli)
	-- 		stimuli = string.sub(stimuli, 1, i-1).."a"..string.sub(stimuli, i+1, -1)
	-- 	end
	-- end
	return stimuli
end

--[[
检查伤害原因是否为物理伤害, 返回bool
stimuli (table/string)总伤害原因，可以为nil  
]]
function EntUtil:is_physics_dmg(stimuli)
	if stimuli == nil then
		stimuli = {}
	end
	if type(stimuli) == "string" then
		local t = {stimuli=true}
		stimuli = t
	end
	local physics_dmg_type = {
		"strike", "spike", "slash", "thump"
	}
	for k, v in pairs(physics_dmg_type) do
		if stimuli[v] then
			return true
		end
	end
	return false
end

--[[
检查伤害原因是否为元素伤害, 返回bool  
stimuli (table/string)总伤害原因，可以为nil  
]]
function EntUtil:is_element_dmg(stimuli)
	if stimuli == nil then
		stimuli = {}
	end
	if type(stimuli) == "string" then
		local t = {stimuli=true}
		stimuli = t
	end
	local element_dmg_type = {
		"fire", "ice", "electric", "poison", "shadow", "blood", "holly", "wind"
	}
	for k, v in pairs(element_dmg_type) do
		if stimuli[v] then
			return true
		end
	end
	return false
end

--[[
获取其伤害类型,  
stimuli (table/string)总伤害原因，可以为nil  
]]
function EntUtil:get_dmg_stimuli(stimuli)
	if stimuli == nil then
		stimuli = {}
	end
	if type(stimuli) == "string" then
		local t = {stimuli=true}
		stimuli = t
	end
	-- print("stimuli:")
    -- for k, v in pairs(stimuli) do
    --     print(k,v)
    -- end
	for k, v in pairs(STRINGS.TP_DMG_TYPE) do
		if self:in_stimuli(stimuli, k) then
			return k
		end
	end
end

--[[
是否能够造成伤害效果，返回bool,  
stimuli (table/string)总伤害原因，可以为nil  
]]
function EntUtil:can_dmg_effect(stimuli)
	if not self:in_stimuli(stimuli, "pure")
	and self:in_stimuli(stimuli, "atk") then
		return true
	end
end

--[[
是否能够触发额外伤害，返回bool,  
stimuli (table/string)总伤害原因，可以为nil  
]]
function EntUtil:can_extra_dmg(stimuli)
	if self:can_dmg_effect(stimuli) then
		return true
	end
end

--[[
是否能够反伤，返回bool,  
data 伤害数据，{attacker, stimuli, damage}
]]
function EntUtil:can_thorns(data)
	if data.attacker and data.attacker.components.combat then
		if not data.attacker:HasTag("not_reflection") then
			if data.attacker.components.health then
				if data.damage and data.damage > 0 then
					if data.stimuli ~= "thorns"
					and not self:in_stimuli(data.stimuli, "pure")
					and not self:in_stimuli(data.stimuli, "thorns") then
						return true
					end
				end
			end
		end
	end
end


--[[
判断主体与客体是否为同类，返回bool
是否相同prefab，是否同为猎犬、蜘蛛、蜜蜂、发条生物、疯猪
inst 主体  
target 客体
]]
function EntUtil:check_congeneric(inst, target)
    local v = inst
	if v ~= target and ((v.prefab==target.prefab)
	or (v.creature_kind ~= nil and v.creature_kind==target.creature_kind)
	or (v:HasTag("hound") and target:HasTag("hound")) 
	or (v:HasTag("spider") and target:HasTag("spider")) 
	or (v:HasTag("chess") and target:HasTag("chess"))
	or (v:HasTag("bee") and target:HasTag("bee")) )
	and (v:HasTag("werepig")==target:HasTag("werepig")) then
		return true
	end
end

--[[
判断主体与客体是否友好，返回bool  
inst 主体(一般为玩家)  
target 客体  
]]
function EntUtil:check_friendly(inst, target)
	for k, v in pairs(self.not_entity_tags) do
		if target:HasTag(v) then
			return false
		end
	end
	if inst.components.health == nil
	or inst.components.combat == nil then
		return false
	end
	local tags = {"eyeturret", "companion",}
	for k, v in pairs(tags) do
		if target:HasTag(v) then
			return true
		end
	end
	if target.components.follower 
	and target.components.follower.leader == inst then
		return true
	end
end

--[[
点燃目标  
target 需要点燃的目标  
attacker 被target仇恨的对象，可以为nil
]]
function EntUtil:ignite(target, attacker)
    if target.components.burnable and not target.components.burnable:IsBurning() then
        if target.components.freezable and target.components.freezable:IsFrozen() then           
            target.components.freezable:Unfreeze()            
        else            
            if target.components.fueled and target:HasTag("campfire") and target:HasTag("structure") then
                -- Rather than worrying about adding fuel cmp here, just spawn some fuel and immediately feed it to the fire
                local fuel = SpawnPrefab("cutgrass")
                if fuel then target.components.fueled:TakeFuelItem(fuel) end
            else
                target.components.burnable:Ignite(true)
            end
        end   
    end
    if target:HasTag("aquatic") and not target.components.burnable then 
        local pt = target:GetPosition()
        local smoke = SpawnPrefab("smoke_out")
        smoke.Transform:SetPosition(pt:Get())
         if target.SoundEmitter then 
            target.SoundEmitter:PlaySound("dontstarve_DLC002/common/fire_weapon_out") 
        end 
    end 
    if target.components.freezable then
        target.components.freezable:AddColdness(-1) --Does this break ice staff?
        if target.components.freezable:IsFrozen() then
            target.components.freezable:Unfreeze()            
        end
    end
    if target.components.sleeper and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end
    if target:HasTag("player") then
    	target.components.health:DoFireDamage(4, nil, true)
    end
    if attacker then
	    target:PushEvent("attacked", { attacker = attacker, damage = 0 })
    end
end

--[[
冰冻目标  
target 需要冰冻的目标  
attacker 被target仇恨的对象，可以为nil  
num 冰冻等级
]]
function EntUtil:frozen(target, attacker, num)
    if not target:IsValid() then
        return
    end
    if target.components.sleeper and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end
    if target.components.burnable then
        if target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        elseif target.components.burnable:IsSmoldering() then
            target.components.burnable:SmotherSmolder()
        end
    end
    if attacker then
	    if target.sg ~= nil and not target.sg:HasStateTag("frozen") then
	        target:PushEvent("attacked", { attacker = attacker, damage = 0 })
	    end
    end
    if target.components.freezable then
        target.components.freezable:AddColdness(num or 1)
        target.components.freezable:SpawnShatterFX()
    end
end

--[[
令目标中毒  
target 需要中毒的目标
]]
function EntUtil:poison(target)
    if target.components.poisonable and target:HasTag("poisonable") then
        target.components.poisonable:Poison()
    end 
end

--[[
检查目标是否被点燃，返回bool  
target 需要检查的目标
]]
function EntUtil:is_burning(target)
    return target.components.burnable and target.components.burnable:IsBurning()
end

--[[
检查目标是否被冰冻，返回bool  
target 需要检查的目标
]]
function EntUtil:is_frozen(target)
    return target.components.freezable and target.components.freezable:IsFrozen()
end

--[[
检查目标是否中毒，返回bool  
target 需要检查的目标
]]
function EntUtil:is_poisoned(target)
    return target.components.poisonable and target.components.poisonable:IsPoisoned()
end

--[[
令目标睡眠  
target 需要睡眠的目标  
num 睡眠度，默认为10  
time 睡眠时间，默认为20  
]]
function EntUtil:sleep(target, num, time)
    if target.components.sleeper then
	    target.components.sleeper:AddSleepiness(num or 10, time or 20)
	end
end

--[[
睡眠帐篷  
tent 被睡眠的帐篷  
sleeper 睡眠者  
fn 睡眠后触发的函数  
]]
function EntUtil:sleep_tent(tent, sleeper, fn)
    local inst = tent
    if GetClock():IsDay() then
		local tosay = "ANNOUNCE_NODAYSLEEP"
		if GetWorld():IsCave() then
			tosay = "ANNOUNCE_NODAYSLEEP_CAVE"
		end
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, tosay))
			return
		end
	end
	if inst:HasTag("fire") then
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NOSLEEPONFIRE"))
		end
		return
	end
	local hounded = GetWorld().components.hounded
	local notags = {"FX", "NOCLICK","INLIMBO"}
	local danger = FindEntity(inst, 10, function(target) 
		return
			(target:HasTag("monster") and not target:HasTag("player") and not sleeper:HasTag("spiderwhisperer"))
			or (target:HasTag("monster") and not target:HasTag("player") and sleeper:HasTag("spiderwhisperer") and not target:HasTag("spider"))
			or (target:HasTag("pig") and not target:HasTag("player") and sleeper:HasTag("spiderwhisperer"))
			or (target.components.combat and target.components.combat.target == sleeper)
	end, nil, notags)
	if hounded and (hounded.warning or hounded.timetoattack <= 0) then
		danger = true
	end
	if danger then
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NODANGERSLEEP"))
		end
		return
	end
	if sleeper.components.hunger.current < TUNING.CALORIES_MED then
		sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NOHUNGERSLEEP"))
		return
	end
	sleeper.components.health:SetInvincible(true)
	sleeper.components.playercontroller:Enable(false)
	GetPlayer().HUD:Hide()
	TheFrontEnd:Fade(false,1)
	inst:DoTaskInTime(1.2, function() 
		GetPlayer().HUD:Show()
		TheFrontEnd:Fade(true,1) 
		if GetClock():IsDay() then
			local tosay = "ANNOUNCE_NODAYSLEEP"
			if GetWorld():IsCave() then
				tosay = "ANNOUNCE_NODAYSLEEP_CAVE"
			end
			if sleeper.components.talker then				
				sleeper.components.talker:Say(GetString(sleeper.prefab, tosay))
				sleeper.components.health:SetInvincible(false)
				sleeper.components.playercontroller:Enable(true)
				return
			end
		end
		if sleeper.components.sanity then
			sleeper.components.sanity:DoDelta(TUNING.SANITY_HUGE)
		end
		if sleeper.components.hunger then
			sleeper.components.hunger:DoDelta(-TUNING.CALORIES_HUGE, false, true)
		end
		if sleeper.components.health then
			sleeper.components.health:DoDelta(TUNING.HEALING_HUGE, false, "tent", true)
		end
		if sleeper.components.temperature and sleeper.components.temperature.current < TUNING.TARGET_SLEEP_TEMP then
			sleeper.components.temperature:SetTemperature(TUNING.TARGET_SLEEP_TEMP)
		end		
		local moisture_start = nil
		if sleeper.components.moisture and sleeper.components.moisture:GetMoisture() > 0 then
			moisture_start = sleeper.components.moisture.moisture
		end
		-- if inst.components.finiteuses then
		-- 	inst.components.finiteuses:Use()
		-- end
		GetClock():MakeNextDay()
		if moisture_start then
			sleeper.components.moisture.moisture = moisture_start - TUNING.SLEEP_MOISTURE_DELTA
			if sleeper.components.moisture.moisture < 0 then sleeper.components.moisture.moisture = 0 end
		end
		sleeper.components.health:SetInvincible(false)
		sleeper.components.playercontroller:Enable(true)
		sleeper.sg:GoToState("wakeup")	
        if fn then fn(inst, sleeper) end
	end)
end

--[[
添加移速倍率  
inst 操作主体  
... key键, mod倍率, time时间  
]]
function EntUtil:add_speed_mod(inst, ...)
	if inst.components.locomotor then
		inst.components.locomotor:AddSpeedModifier_Mult(...)
	end
end

--[[
移除移速倍率  
inst 操作主体  
... key键  
]]
function EntUtil:rm_speed_mod(inst, ...)
	if inst.components.locomotor then
		inst.components.locomotor:RemoveSpeedModifier_Mult(...)
	end
end

--[[
添加移速增量  
inst 操作主体  
... key键, mod增量, time时间  
]]
function EntUtil:add_speed_amt(inst, ...)
	if inst.components.locomotor then
		inst.components.locomotor:AddSpeedModifier_Additive(...)
	end
end

--[[
移除移速增量  
inst 操作主体  
... key键  
]]
function EntUtil:rm_speed_amt(inst, ...)
	if inst.components.locomotor then
		inst.components.locomotor:RemoveSpeedModifier_Additive(...)
	end
end

--[[
增加伤害倍率  
inst 操作主体  
key 变化率对应的键  
mod 变化率  
time 有效时间  
]]
function EntUtil:add_damage_mod(inst, key, mod, time)
	if inst.components.combat then
		inst.components.combat:AddDamageModifier(key, mod, time)
		if time then
            local cmp = inst.components.combat
			if cmp["dmg_timer_"..key] then
				cmp["dmg_timer_"..key]:Cancel()
				cmp["dmg_timer_"..key] = nil
			end
			cmp["dmg_timer_"..key] = inst:DoTaskInTime(time, function()
				if cmp["dmg_timer_"..key] then
					cmp["dmg_timer_"..key]:Cancel()
					cmp["dmg_timer_"..key] = nil
				end
			end)
		end
	end
end

--[[
移除伤害倍率  
inst 操作主体  
key 变化率对应的键  
]]
function EntUtil:rm_damage_mod(inst, key)
	if inst.components.combat then
		inst.components.combat:RemoveDamageModifier(key)
        local cmp = inst.components.combat
		if cmp["dmg_timer_"..key] then
			cmp["dmg_timer_"..key]:Cancel()
			cmp["dmg_timer_"..key] = nil
		end
	end
end

--[[
添加攻速倍率  
inst 操作主体  
... key键, mod倍率, time时间  
]]
function EntUtil:add_attack_speed_mod(inst, ...)
    if inst.components.combat then
        inst.components.combat:AddPeriodModifier(...)
    end
end

--[[
移除攻速倍率  
inst 操作主体  
... key键  
]]
function EntUtil:rm_attack_speed_mod(inst, ...)
    if inst.components.combat then
        inst.components.combat:RemovePeriodModifier(...)
    end
end

-- function EntUtil:add_absorb_mod(inst, ...)
-- 	if inst.components.health then
-- 		inst.components.health:WgAddAbsorbModifier(...)
-- 	end
-- end

-- function EntUtil:rm_absorb_mod(inst, ...)
-- 	if inst.components.health then
-- 		inst.components.health:WgRemoveAbsorbModifier(...)
-- 	end
-- end

--[[
添加饥饿倍率  
inst 操作主体  
... key键, mod倍率, time时间  
]]
function EntUtil:add_hunger_mod(inst, ...)
	if inst.components.hunger then
		inst.components.hunger:AddBurnRateModifier(...)
	end
end

--[[
移除饥饿倍率  
inst 操作主体  
... key键  
]]
function EntUtil:rm_hunger_mod(inst, ...)
	if inst.components.hunger then
		inst.components.hunger:RemoveBurnRateModifier(...)
	end
end

--[[
添加理智降低倍率  
inst 操作主体  
... key键, mod倍率, time时间  
]]
function EntUtil:add_sanity_mod(inst, ...)
	if inst.components.sanity then
		inst.components.sanity:AddRateModifier(...)
	end
end

--[[
移除理智降低倍率  
inst 操作主体  
... key键  
]]
function EntUtil:rm_sanity_mod(inst, ...)
	if inst.components.sanity then
		inst.components.sanity:RemoveRateModifier(...)
	end
end

--[[
添加tag，带计数  
inst (EntityScript)操作主体  
tag (string)标签  
]]
function EntUtil:add_tag(inst, tag)
	if inst.wg_tags == nil then
		inst.wg_tags = {}
	end
	local n = inst.wg_tags[tag] or 0
	inst.wg_tags[tag] = n+1
	if inst.wg_tags[tag] > 0 then
		inst:AddTag(tag, true)
	end
end

--[[
移除tag，带计数  
inst (EntityScript)操作主体  
tag (string)标签  
]]
function EntUtil:remove_tag(inst, tag)
	if inst.wg_tags == nil then
		inst.wg_tags = {}
	end
	local n = inst.wg_tags[tag] or 0
	inst.wg_tags[tag] = math.max(0, n-1)
	if inst.wg_tags[tag] <= 0 then
		inst:RemoveTag(tag, true)
	end
end

--[[
监听事件，返回监听函数  
(func) 返回监听函数  
inst (EntityScript)操作主体  
event (string)监听的目标事件  
fn (func)监听函数  
source (EntityScript)监听源  
]]
function EntUtil:listen_for_event(inst, event, fn, source)
	inst:ListenForEvent(event, fn, source)
	return fn
end

--[[
设置容器  
inst (EntityScript)操作主体  
cont_type (string)容器类型(pack/small_pack/chest/big_chest/cookpot)  
]]
function EntUtil:set_container(inst, cont_type)
	if inst.components.container == nil then
		inst:AddComponent("container")
	end
	if cont_type == "pack" then
		local slotpos = {}
		for y = 0, 3 do
			table.insert(slotpos, Vector3(-162, -y*75 + 114 ,0))
			table.insert(slotpos, Vector3(-162 +75, -y*75 + 114 ,0))
		end
		inst.components.container:SetNumSlots(#slotpos)
	    inst.components.container.widgetslotpos = slotpos
	    inst.components.container.widgetanimbank = "ui_backpack_2x4"
	    inst.components.container.widgetanimbuild = "ui_backpack_2x4"
	    inst.components.container.widgetpos = Vector3(-5,-70,0)
	    inst.components.container.side_widget = true
	elseif cont_type == "small_pack" then
		local slotpos = {}
		for y = 0, 3 do
			table.insert(slotpos, Vector3(-162 +(75/2), -y*75 + 114 ,0))
		end
		inst.components.container:SetNumSlots(#slotpos)
	    inst.components.container.widgetslotpos = slotpos
	    inst.components.container.widgetanimbank = "ui_thatchpack_1x4"
	    inst.components.container.widgetanimbuild = "ui_thatchpack_1x4"
	    inst.components.container.widgetpos = Vector3(-5,-70,0)
	    inst.components.container.side_widget = true
	elseif cont_type == "big_chest" then
		local root_slotpos = {}
		for y = 2.5, -0.5, -1 do
			for x = 0, 2 do
				table.insert(root_slotpos, Vector3(75*x-75*2+75, 75*y-75*2+75,0))
			end
		end
		inst.components.container:SetNumSlots(#root_slotpos, true)
		inst.components.container.widgetslotpos = root_slotpos
		inst.components.container.widgetpos = Vector3(75, 200, 0)
	    inst.components.container.widgetanimbank = "ui_chester_shadow_3x4"
	    inst.components.container.widgetanimbuild = "ui_chester_shadow_3x4"	
		inst.components.container.side_align_tip = 160
	elseif cont_type == "cookpot" then
		local slotpos = {	
			Vector3(0,64+32+8+4,0), 
			Vector3(0,32+4,0),
			Vector3(0,-(32+4),0), 
			Vector3(0,-(64+32+8+4),0)
		}
		inst.components.container:SetNumSlots(#slotpos)
	    inst.components.container.widgetslotpos = slotpos
	    inst.components.container.widgetanimbank = "ui_cookpot_1x4"
	    inst.components.container.widgetanimbuild = "ui_cookpot_1x4"
	    inst.components.container.widgetpos = Vector3(200,0,0)
	    inst.components.container.side_align_tip = 100
	    -- inst.components.container.widgetbuttoninfo = widgetbuttoninfo
	    inst.components.container.acceptsstacks = false
	elseif cont_type == "chest" then
		local slotpos = {}
		for y = 2, 0, -1 do
			for x = 0, 2 do
				table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80, 0))
			end
		end
		inst.components.container:SetNumSlots(#slotpos)
		inst.components.container.widgetslotpos = slotpos
		inst.components.container.widgetanimbank = "ui_chest_3x3"
		inst.components.container.widgetanimbuild = "ui_chest_3x3"
		inst.components.container.widgetpos = Vector3(0, 200, 0)
		inst.components.container.side_align_tip = 160
	end
end

--[[
晃动镜头  
inst (EntityScript) 操作主体  
dist (number) 距离(如果玩家在距离内，则晃动)  
]]
function EntUtil:shake_camera(inst, dist)
	local player = GetClosestInstWithTag("player", inst, dist)
    if player then
        player.components.playercontroller:ShakeCamera(inst, "FULL", 0.7, 0.02, 3, dist)
    end
end

--[[
导入prefab文件,获取指定名字的prefab对象,返回其深复制  
(Prefab)返回深复制的prefab对象  
file (string)文件路径  
pref_name (string)指定名字  
]]
function EntUtil:deepcopy_prefab(file, pref_name)
	local pref_tbl = { loadfile(file)() }
	for k, v in pairs(pref_tbl) do
		if v.name == pref_name then
			return deepcopy(v)
		end
	end
end

--[[
给予玩家物品,并附带获取特效  
item (EntityScript)物品  
player (EntityScript)玩家  
pos (Vector3)位置  
]]
function EntUtil:give_player_item(item, player, pos)
	player = player or GetPlayer()
	pos = pos and GetPos(pos, true) or player:GetPosition()
	player.components.inventory:GiveItem(item, nil, Vector3(TheSim:GetScreenPos(pos:Get())))
end

return EntUtil