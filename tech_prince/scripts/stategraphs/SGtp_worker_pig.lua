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
_SG.add_handlers(events, {'step', 'loco', 'frozen', 'atk', 'hit', 'death'})
-- add_ehd(events, {})
local states = {}
_SG.add_states(states, {
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
	{'chop', {
		name = 'chop',
		anim = 'atk',
		time = 13,
		tags = {'busy'},
	}},
})
return StateGraph("tp_worker_pig", states, events, 'idle', actionhandlers)