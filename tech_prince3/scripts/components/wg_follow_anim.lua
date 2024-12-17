local w_math_g = math
local w_v1_g = 1
local w_string_g = string
local w_require_g = require
local w_v0_g = 0
local w_input_g = TheInput
local w_blog_g = ""
local w_B_g = "b"
local w_true_g = true
local w_wargon_g = {}
local w_v08_g = .8
local w_Class_g = Class
local w_v2_g = w_v1_g+w_v0_g*w_v1_g+w_v0_g+w_v1_g
local w_v06_g = .6
local w_Image_g = w_require_g("widgets/image")
local w_v3_g = w_v0_g+w_v1_g*w_v2_g+w_v1_g*w_v0_g+w_v0_g*w_v2_g+w_v1_g*w_v1_g
local w_v10_g = w_v3_g*w_v0_g+w_v3_g*w_v3_g+w_v1_g+w_v2_g-w_v1_g-w_v1_g
local w_v30_g = w_v3_g*w_v3_g*w_v3_g+w_v3_g
local w_v101_g = w_wargon_g["get_attacked"] and w_wargon_g["get_attack_speed"] and 45*23+32*41-26*54-32*61+11*35+92 or w_wargon_g["get_tile"] and w_wargon_g["on_water"] and 35*64-73-55*47+30*27-20*11-72 or 54*34+23*66+34*54+32*64+97*53-35*98-43*87-81*73+341
local w_v100_g = w_v10_g*w_v10_g
local w_line_g = "\n"
local w_nil_g = nil
local w_table_g = table
local w_v05_g = .5
local w_v30_g = w_v3_g*w_v3_g*w_v3_g+w_v3_g
local w_vector_g = Vector3
local w_v03_g = .3
local w_v25_g = w_v30_g-w_v3_g -w_v2_g-w_v1_g*w_v2_g*w_v0_g
local w_get_player_g = GetPlayer
local w_FollowAnim_g = w_require_g("extension/uis/follow_anim")
local w_v02_g = .2
local w_print_g = print
local w_A_g = "a"
local w_v465_g = w_v100_g*(w_v2_g+w_v1_g+w_v0_g)+w_v100_g+w_v30_g*w_v2_g + w_v3_g*2-w_v1_g

local w_WgFollowAnim_g = w_Class_g(function(w_self_g, w_inst_g)
	w_self_g["inst"] = w_inst_g
	-- :SetAnim(bank, build, anim, fn)
	w_self_g["SetAnim"] = function(w_self_g, w_bank_g, w_build_g, w_anim_g, w_fn_g)
		w_self_g["inst"]["DoTaskInTime"](w_self_g["inst"], 0, function()
			if w_self_g["widget"] == w_nil_g then
				local w_player_g = w_get_player_g()
				if w_player_g["HUD"] then
					w_self_g["widget"] = w_player_g["HUD"]["AddChild"](w_player_g["HUD"], w_FollowAnim_g())
                    w_self_g["widget"]["wg_anim"]["GetAnimState"](w_self_g["widget"]["wg_anim"])["SetBank"](w_bank_g)
                    w_self_g["widget"]["wg_anim"]["GetAnimState"](w_self_g["widget"]["wg_anim"])["SetBuild"](w_build_g)
                    w_self_g["widget"]["wg_anim"]["GetAnimState"](w_self_g["widget"]["wg_anim"])["PlayAnimation"](w_anim_g)
					w_self_g["widget"]["SetOffset"](w_self_g["widget"], w_self_g["offset"] or w_vector_g(0, -80, 0))
					w_self_g["widget"]["SetTarget"](w_self_g["widget"], w_self_g["inst"])
					if w_fn_g then
						w_fn_g(w_self_g["widget"])
					end
					if w_self_g["execute"] then
						w_self_g["execute"](w_self_g["widget"])
						w_self_g["execute"] = w_nil_g
					end
				end
			else
                w_self_g["widget"]["wg_anim"]["GetAnimState"](w_self_g["widget"]["wg_anim"])["SetBank"](w_bank_g)
                w_self_g["widget"]["wg_anim"]["GetAnimState"](w_self_g["widget"]["wg_anim"])["SetBuild"](w_build_g)
                w_self_g["widget"]["wg_anim"]["GetAnimState"](w_self_g["widget"]["wg_anim"])["PlayAnimation"](w_anim_g)
			end
			if not w_self_g["widget"]["shown"] then
				w_self_g["widget"]:Show()
			end
		end)
	end
	-- :SetScale(...)
	w_self_g["SetScale"] = function(w_self_g, ...)
		if w_self_g["widget"] then
			w_self_g["widget"]["wg_anim"]["SetScale"](w_self_g["widget"]["wg_anim"], ...)
		end
	end
	w_self_g["Execute"] = function(w_self_g, w_fn_g)
		if w_self_g["widget"] then
			w_fn_g(w_self_g["widget"])
		else
			w_self_g["execute"] = w_fn_g
		end
	end
	-- :Show()
	w_self_g["Show"] = function(w_self_g)
		if w_self_g["widget"] and not w_self_g["widget"]["shown"] then
			w_self_g["widget"]["Show"](w_self_g["widget"])
		end
	end
	-- :Hide()
	w_self_g["Hide"] = function(w_self_g)
		if w_self_g["widget"] and w_self_g["widget"]["shown"] then
			w_self_g["widget"]["Hide"](w_self_g["widget"])
		end
	end
	-- :Kill()
	w_self_g["Kill"] = function(w_self_g)
		if w_self_g["widget"] then
			-- w_self_g["widget"]:KillAllChildren()
			w_self_g["widget"]["Kill"](w_self_g["widget"])
			w_self_g["widget"] = w_nil_g
		end
	end
	-- :OnRemoveEntity()
	w_self_g["OnRemoveEntity"] = function(w_self_g)
		w_self_g["Kill"](w_self_g)
	end
end)

return w_WgFollowAnim_g
