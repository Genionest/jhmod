local function add_sg_handler(sg, hd)
	AddStategraphActionHandler(sg, hd)
end

local function add_sg_state(sg, state)
	AddStategraphState(sg, state)
end

local function add_sg_event(sg, event)
	AddStategraphEvent(sg, event)
end

local function add_sg_post(sg, fn)
	AddStategraphPostInit(sg, fn)
end

-- require "commonstates"
-- 要在有上面这句的环境里运行
local function state_simple(states, name, anim, tags, finishstate)
	CommonStates.AddSimpleState(states, name, anim, tags, finishstate)
end

local function state_idle(states, anim, funny)
	CommonStates.AddIdle(states, funny, anim)
end

local function state_action(states, name, anim, time, tags, finishstate)
	CommonStates.AddSimpleActionState(states, name, anim, time*FRAMES, tags, finishstate)
end

local function state_short(states, name, anim, timeout)
	timeout = timeout or 6
	CommonStates.AddShortAction(states, name, anim, timeout*FRAMES)
end

local function connect_tbl(tbl1, tbl2)
	if tbl1 and tbl2 then
	local tbl = {}
		for i, v in pairs(tbl2) do
			if type(tbl1) == 'table' then
				tbl[v] = tbl1[i]
			else
				tbl[v] = tbl1
			end
		end
		return tbl
	end
end

local function loco_anim(anim, loco)
	local anims = {}
	local group = {
		'start'..loco,
		loco,
		'stop'..loco,
	}
	anims = connect_tbl(anim, group)
	return anims
end

local function trans_tbl(tbl, fn)
	if tbl then
	local ntbl = {}
		for i, v in pairs(tbl) do
			if type(v) == 'table' then
				local e = fn(v[1], v[2])
				table.insert(ntbl, e)
			else
				local e = fn(tbl[1], tbl[2])
				table.insert(ntbl, e)
				break
			end
		end
		return ntbl
	end
end

local function c_time_event(time, fn)
	return TimeEvent(time*FRAMES, fn)
end

local function add_tl(tls)
	return trans_tbl(tls, c_time_event)
end

local function create_tl(timeline)
	for i, v in pairs(timeline) do
		timeline[i] = add_tl(v)
	end
end

local function change_tbl(tbl1, tbl2)
	local tbl3 = {}
	for i, v in pairs(tbl1) do
		tbl3[tbl2[i]] = v
	end
	return tbl3
end

local function state_run(states, anim, timeline)
	local run_anim = nil
	if anim then
		run_anim = loco_anim(anim, 'run')
	end
	local timelines = nil
	if timeline then
		create_tl(timeline)
		local tbl2 = {
			run_pre = 'starttimeline', 
			run = 'runtimeline', 
			run_pst = 'endtimeline'
		}
		timelines = change_tbl(timeline, tbl2)
	end
	CommonStates.AddRunStates(states, timelines, run_anim)
end

local function state_walk(states, anim, timeline)
	local walk_anim = nil
	if anim then
		walk_anim = loco_anim(anim, 'walk')
	end
	local timelines = nil
	if timeline then
		create_tl(timeline)
		local tbl2 = {
			walk_pre = 'starttimeline', 
			walk = 'walktimeline', 
			walk_pst = 'endtimeline'
		}
		timelines = change_tbl(timeline, tbl2)
	end
	CommonStates.AddWalkStates(states, timelines, walk_anim)
end

local function state_sleep(states, timeline, anim)
	local sleep_anim = nil
	if anim then
		local group = {'sleep_pre', 'sleep_loop', 'sleep_pst'}
		sleep_anim = connect_tbl(anim, group)
	end
	local timelines = nil
	if timeline then
		create_tl(timeline)
		local tbl2 = {
			sleep_pre = 'starttimeline', 
			sleep = 'sleeptimeline', 
			wake = 'waketimeline'
		}
		timelines = change_tbl(timeline, tbl2)
	end
	CommonStates.AddSleepStates(states, timelines, anim)
end

local function state_frozen(states, timeline, anim)
	local frozen_anim = nil
	if anim then
		local group = {'frozen', 'frozen_pst'}
		frozen_anim = connect_tbl(anim, group)
	end
	local timelines = nil
	if timeline then
		create_tl(timeline)
		local tbl2 = {frozen = 'frozentimeline'}
		timelines = change_tbl(timeline, tbl2)
	end
	CommonStates.AddFrozenStates(states, timelines, frozen_anim)
end

local function state_combat(states, timeline, anim)
	local combat_anim = nil
	if anim then
		local tbl = {'hit', 'attack', 'death'}
		combat_anim = connect_tbl(anim, tbl)
	end
	local timelines = nil
	if timeline then
		create_tl(timeline)
		local tbl2 = {
			hit = 'hittimeline', 
			atk = 'attacktimeline', 
			death = 'deathtimeline'
		}
		timelines = change_tbl(timeline, tbl2)
	end
	CommonStates.AddCombatStates(states, timelines, combat_anim)
end

local function add_state(states, state, data)
	if state == "simple" then
		state_simple(states, data.name, data.anim, data.tags, data.finish)
	elseif state == 'idle' then
		state_idle(states, data.anim, data.funny)
	elseif state == 'act' then
		state_action(states, data.name, data.anim, data.time, data.tags, data.finish)
	elseif state == 'short' then
		state_short(states, data.name, data.anim, data.time)
		-- name, anim, time
	elseif state == 'run' then
		state_run(states, data.anim, data.tl)
		-- anim 3, timeline 3
	elseif state == 'walk' then
		state_walk(states, data.anim, data.tl)
		-- anim 3, timeline 3
	elseif state == 'sleep' then
		state_sleep(states, data.tl, data.anim)
		-- anim 3, timeline 3
	elseif state == 'frozen' then
		state_frozen(states, data.tl, data.anim)
		-- anim 2, timeline 1
	elseif state == 'combat' then
		state_combat(states, data.tl, data.anim)
		-- anim 3, timeline 3
	end
end

local function add_states(states, datas)
	for i, v in pairs(datas) do
		add_state(states, v[1], v[2])
	end
end

local function add_handler(events, event)
	local ch = nil
	if event == "step" then
		ch = CommonHandlers.OnStep()
	elseif event == "sleep" then
		ch = CommonHandlers.OnSleep()
	elseif event == "frozen" then
		ch = CommonHandlers.OnFreeze()
	elseif event == "hit" then
		ch = CommonHandlers.OnAttacked()
	elseif event == "atk" then
		ch = CommonHandlers.OnAttack()
	elseif event == "death" then
		ch = CommonHandlers.OnDeath()
	elseif event == "loco" then
		ch = CommonHandlers.OnLocomote(true, true)
	elseif event == "run" then
		ch = CommonHandlers.OnLocomote(true, false)
	elseif event == "walk" then
		ch = CommonHandlers.OnLocomote(false, true)
	end
	table.insert(events, ch)
end

local function add_handlers(events, event_tbl)
	for i, v in pairs(event_tbl) do
		add_handler(events, v)
	end
end

local function c_action_handler(act, acthds)
	return ActionHandler(act, acthds)
end

local function add_acthd(actionhds, acthds)
	local tbl = trans_tbl(acthds, c_action_handler)
	for i, v in pairs(tbl) do
		table.insert(actionhds, v)
	end
end

local function c_event_handler(e, fn)
	return EventHandler(e, fn)
end

local function add_ehd(events, ehds)
	local tbl = trans_tbl(ehds, c_event_handler)
	for i, v in pairs(tbl) do
		table.insert(events, v)
	end
end

local function sp_player_build_sg_fn(sg)
	local tbl = {
		bigfoot_sp 	= "tp_spawn",
		morph_sp 	= "science_morph",
		callbeast_sp = "tp_call_beasts",
	}
	local old_handler = sg.actionhandlers[ACTIONS.BUILD].deststate
    sg.actionhandlers[ACTIONS.BUILD].deststate = function(inst, action)
        if not inst.sg:HasStateTag('busy') then
            if action.doer and action.doer.prefab == "wilson" then
	            if action.recipe and tbl[action.recipe] then
	            	print(tbl[action.recipe])
	            	return tbl[action.recipe]
	            end
	        end
            return old_handler(inst, action)
        end
    end
end

local function sp_wilson_build_sg()
	add_sg_post("wilson", sp_player_build_sg_fn)
	add_sg_post("wilsonboat", sp_player_build_sg_fn)
end

local function animal_sg(sg_name)
	require "stategraphs/commonstates"

	local actionhandlers = {}
	add_acthd(actionhandlers, {
		{ACTIONS.GOHOME, 'gohome'},
		{ACTIONS.EAT, 'eat'},
		{ACTIONS.PICK, 'pick'},
	})
	local events = {}
	add_handlers(events, {'step', 'loco', 'sleep', 'frozen'})
	add_ehd(events, {
		{'attacked', function(inst) 
			if inst.components.health and inst.components.health:GetPercent()>0 then
				inst.sg:GoToState('hit')
			end
		end},
		{'death', function(inst) inst.sg:GoToState('death') end},
		{'doattack', function(inst)
			if inst.components.health and inst.components.health:GetPercent()>0 then
				inst.sg:GoToState('attack')
			end
		end},
	})
	local states = {}
	add_states(states, {
		{'idle', {}},  -- 不能用nil，必须用空表
		{'combat', {
			tl = {
				atk = {20, function(inst)
					inst.components.combat:DoAttack()
				end}, 
			},
		}},
		{'simple', {
			name = 'appear',
			tags = {'busy'},
			anim = 'appear',
		}},
		{'act', {
			name = 'eat',
			tags = {'busy'},
			anim = 'eat',
			time = 10,
		}},
		{'walk', {
			tl = {
				walk = {
					{0, PlayFootstep},
					{12, PlayFootstep},
				},
			},
		}},
		{'run', {
			tl = {
				run = {
					{0, PlayFootstep},
					{10, PlayFootstep},
				},
			},
		}},
		{'sleep', {}},
		{'act', {
			name = 'gohome',
			anim = 'hit',
			time = 4,
			tags = {'busy'},
		}},
		{'act', {
			name = 'pick',
			anim = 'take',
			time = 9,
			tags = {'busy'},
		}},
		{'frozen', {}},
	})
	return StateGraph(sg_name, states, events, 'idle', actionhandlers)
end

local function member_sg(sg_name)
	require("stategraphs/commonstates")
	local actionhandlers = {}
	add_acthd(actionhandlers, {
		{ACTIONS.GOHOME, 'gohome'},
		{ACTIONS.EAT, 'eat'},
		{ACTIONS.PICKUP, 'pickup'},
		{ACTIONS.EQUIP, 'pickup'},
	})
	local events = {}
	add_handlers(events, {'step', 'loco', 'frozen', 'atk', 'hit', 'death'})
	-- add_ehd(events, {})
	local states = {}
	add_states(states, {
		{'idle', {}},
		{'frozen', {}},
		{'combat', {
			tl = {
				atk = {13, function(inst)
					inst.components.combat:DoAttack()
					inst.sg:RemoveStateTag('attack')
					inst.sg:RemoveStateTag('busy')
				end},
			},
		}},
		{'act', {
			name = 'eat',
			anim = 'eat',
			tags = {'busy'},
			time = 10,
		}},
		{'walk', {
			tl = {
				walk = {
					{0, PlayFootstep},
					{12, PlayFootstep},
				},
			},
		}},
		{'run', {
			tl = {
				run = {
					{0, PlayFootstep},
					{10, PlayFootstep},
				},
			},
		}},
		{'sleep', {}},
		{'simple', {
			name = 'refuse',
			anim = 'pig_reject',
			tags = {'busy'},
		}},
		{'frozen', {}},
		{'act', {
			name = 'pickup',
			anim = 'pig_pickup',
			time = 10,
			tags = {'busy'},
		}},
		{'act', {
			name = 'gohome',
			anim = 'pig_pickup',
			time = 4,
			tags = {'busy'},
		}},
	})
	return StateGraph(sg_name, states, events, 'idle', actionhandlers)
end

GLOBAL.WARGON_SG_EX = {
	add_sg_handler 	= add_sg_handler,
	add_sg_state 	= add_sg_state,
	add_sg_event 	= add_sg_event,
	add_sg_post 	= add_sg_post,
	add_handlers 	= add_handlers,
	add_states 		= add_states,
	add_acthd 		= add_acthd,
	create_tl 		= create_tl,
	animal_sg 		= animal_sg,
	member_sg 		= member_sg,
	-- unique
	sp_wilson_build_sg = sp_wilson_build_sg,
}

GLOBAL.WARGON.SG = GLOBAL.WARGON_SG_EX