local panel_data = {
	{
		{
			anims = {"tp_furnace", "tp_furnace", "idle"},
			prefab = "tp_smelter",
		},
		{
			anims = {"leif", "leif_lumpy_build", "idle_loop"},
			prefab = "tp_leif",
			scale = .1,
		},
		{
			anims = {'topiary', 'topiary_pigking_build', 'idle'},
			prefab = "tp_grass_pigking",
			fn = function(anim)
				anim:Hide("snow")
			end,
			scale = .1,
		},
		{
			anims = {'egg', 'tallbird_egg', 'egg'},
			prefab = "tp_pot_bird_egg",
		},
		{
			anims = {"tp_red_warg", "tp_red_warg", "idle_loop"},
			prefab = "tp_red_warg",
			scale = .2,
		},
		{
			anims = {"tp_blue_warg", "tp_blue_warg", "idle_loop"},
			prefab = "tp_blue_warg",
			scale = .2,
		},
		{
			anims = {"wilson", "wes", "idle_loop"},
			prefab = "tp_fake_knight_sleep",
			fn = function(anim)
				WARGON.EQUIP.body_on(anim, "armor_metalplate", "swap_body")
				WARGON.EQUIP.hat_on(anim, "hat_metalplate", nil, true)
				WARGON.EQUIP.object_on(anim, "swap_halberd", "swap_halberd")
			end,
		},
		{
			anims = {"wilson", "wendy", "idle_loop"},
			prefab = "tp_hornet_sleep",
			fn = function(anim)
				WARGON.EQUIP.body_on(anim, "armor_vortex_cloak", "swap_body")
				WARGON.EQUIP.hat_on(anim, "hat_bandit", nil, true)
				WARGON.EQUIP.object_on(anim, "tp_spear_lance", "swap_object")
			end,
		},
	},
	{
		{
			anims = {"wilson", "wathgrithr", "idle_loop"},
			prefab = "tp_combat_lord_sleep",
			fn = function(anim)
				WARGON.EQUIP.body_on(anim, "armor_wood_fangedcollar", "swap_body")
				WARGON.EQUIP.hat_on(anim, "footballhat_combathelm", nil, true)
				WARGON.EQUIP.object_on(anim, "swap_spear_forge_gungnir", "swap_spear_gungnir")
			end,
		},
		{
			anims = {"wilson", "waxwell", "idle_loop"},
			prefab = "tp_soul_student_sleep",
			fn = function(anim)
				WARGON.EQUIP.hat_on(anim, "tophat_witch_pyre", nil, true)
				WARGON.EQUIP.object_on(anim, "swap_firestaff_meteor", "swap_redstaff")
			end,
		},
		{
			anims = {'pigman', 'werepig_build', 'idle_loop'},
			prefab = "tp_werepig_king",
			fn = function(anim)
				WARGON.EQUIP.hat_on(anim, 'beefalohat_pigking')
			end,
		},
		{
			anims = {'pigman', 'werepig_build', 'idle_loop'},
			prefab = "tp_blood_lord",
			fn = function(anim)
				WARGON.EQUIP.hat_on(anim, 'beefalohat_pigking')
				anim:SetMultColour(1, .1, .1, 1)
			end,
		},
		{
			anims = {'pigman', 'werepig_build', 'idle_loop'},
			prefab = "tp_thunder_lord",
			fn = function(anim)
				WARGON.EQUIP.hat_on(anim, 'beefalohat_pigking')
				anim:SetMultColour(.1, .1, 1, 1)
			end,
		},
		{
			anims = {'pigman', 'werepig_build', 'idle_loop'},
			prefab = "tp_ice_lord",
			fn = function(anim)
				WARGON.EQUIP.hat_on(anim, 'beefalohat_pigking')
				anim:SetMultColour(.1, 1, 1, 1)
			end,
		},
		{
			anims = {'pigman', 'werepig_build', 'idle_loop'},
			prefab = "tp_fire_lord",
			fn = function(anim)
				WARGON.EQUIP.hat_on(anim, 'beefalohat_pigking')
				anim:SetMultColour(1, 1, .1, 1)
			end,
		},
		{
			anims = {'pigman', 'werepig_build', 'idle_loop'},
			prefab = "tp_poison_lord",
			fn = function(anim)
				WARGON.EQUIP.hat_on(anim, 'beefalohat_pigking')
				anim:SetMultColour(.1, 1, .1, 1)
			end,
		},
	},
	{
		{
			anims = {'pigman', 'werepig_build', 'idle_loop'},
			prefab = "tp_shadow_lord",
			fn = function(anim)
				WARGON.EQUIP.hat_on(anim, 'beefalohat_pigking')
				anim:SetMultColour(1, .1, 1, 1)
			end,
		},
		{
			anims = {"oasis_tile", "oasis_tile", "idle"},
			prefab = "tp_moon_lake",
			-- prefab = "tp_moon_sea_handler",
			scale = .1,
		},
		{
			anims = {"wilsonbeefalo", 
				"wathgrithr",
				"idle_loop"
			},
			prefab = "tp_sign_rider",
			fn = function(anim)
				if WARGON.HAS_SKIN then
					anim:SetBuild("wathgrithr_gladiator")
				end
				anim:AddOverrideBuild("beefalo_build")
				anim:Hide("HEAT")
				WARGON.EQUIP.object_on(anim, "tp_sign_staff", "swap_object")
			end,
		},
	},
}

local function AnimClass(name, anims, scale, fn)
	local a_class = {
		name = name,
		-- bank = anims[1],
		-- build = anims[2],
		-- anim = anims[3],
		anim = WgAnim(anims),
		scale = scale,
		fn = fn,
		fix = function(t, anim)
			if t.fn then
				t.fn(anim)
			end
		end,
		get_name = function(t)
			return STRINGS.NAMES[string.upper(t.name)] or ""
		end,
		get_num = function(t)
			return c_countprefabs(t.name, true)
		end,
		get_string = function(t)
			return t:get_name()..": "..t:get_num()
		end,
		set_anim = function(t, anim)
			t.anim:SetAnim(anim)
		end,
	}
	return a_class
end

local function AnimManagerClass()
	local a_class = {
		anims = {},
		add_bar = function(t)
			table.insert(t.anims, {})
		end,
		add_anim = function(t, n, anim)
			table.insert(t.anims[n], anim)
		end,
		get_bar = function(t, n)
			return t.anims[n]
		end,
		get_max_page = function(t)
			return #t.anims
		end,
	}
	return a_class
end

local anim_manager = AnimManagerClass()
for k,v in pairs(panel_data) do
	anim_manager:add_bar()
	for k2, v2 in pairs(v) do
		anim_manager:add_anim(k, AnimClass(v2.prefab, v2.anims, v2.scale, v2.fn))
	end
end

local function CheckPanelDataClass()
	local a_class = {
		title = "搜索世界",
		cur_page = 1,
		max_page = 1,
		anim_manager = AnimManagerClass(),
		get_anims = function(t)
			return t.anim_manager:get_bar(t.cur_page)
		end,
		get_title = function(t)
			return t.title
		end,
		page_turn = function(t, dt)
			t.cur_page = math.min(t.max_page, math.max(1, t.cur_page+dt))
		end,
	}
	return a_class
end

local check_panel_data = CheckPanelDataClass()
check_panel_data.anim_manager = anim_manager
check_panel_data.max_page = anim_manager:get_max_page()
GLOBAL.WARGON.DATA.check_panel_data = check_panel_data