require("stategraphs/commonstates")
local _SG = WARGON.SG
local actionhandlers = {}
_SG.add_acthd(actionhandlers, {
	{ACTIONS.GOHOME, 'gohome'},
	{ACTIONS.EAT, 'eat'},
	{ACTIONS.PICKUP, 'pickup'},
	{ACTIONS.EQUIP, 'pickup'},
	{ACTIONS.CHOP, 'chop'},
	{ACTIONS.HACK, 'chop'},
	{ACTIONS.PLANT, 'pickup'},
})
local events = {}
_SG.add_handlers(events, {'step', 'loco', 'hit', 'death'})
-- add_ehd(events, {})
local states = {}
_SG.add_states(states, {
	{'idle', {}},
	{'combat', {}},
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
	{'act', {
		name = 'chop',
		anim = 'atk',
		time = 13,
		tags = {'chopping'},
	}},
})
return StateGraph("tp_pig_worker", states, events, 'idle', actionhandlers)