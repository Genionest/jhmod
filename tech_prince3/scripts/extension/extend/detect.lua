local w_modimport_g = modimport
local w_global_g = GLOBAL
local w_math_g = math
local w_v1_g = 1
local w_string_g = string
local w_require_g = require
local w_v0_g = 0
local w_input_g = TheInput
local w_blog_g = ""
local w_B_g = "b"
local w_TheSim_g = TheSim
local w_wargon_g = {}
local w_v08_g = .8
local w_util_g = w_require_g("extension.lib.wg_util")
local w_env_g = env
local w_v2_g = w_v1_g+w_v0_g*w_v1_g+w_v0_g+w_v1_g
local w_v06_g = .6
local w_Image_g = w_require_g("widgets/image")
local w_tostring_g = tostring
local w_v3_g = w_v0_g+w_v1_g*w_v2_g+w_v1_g*w_v0_g+w_v0_g*w_v2_g+w_v1_g*w_v1_g
local w_line_g = "\n"
local w_v05_g = .5
local w_table_g = table
local w_v10_g = w_v3_g*w_v0_g+w_v3_g*w_v3_g+w_v1_g+w_v2_g-w_v1_g-w_v1_g
local w_v30_g = w_v3_g*w_v3_g*w_v3_g+w_v3_g
local w_v03_g = .3
local w_v100_g = w_v10_g*w_v10_g
local w_vp10_g = w_v0_g - w_v10_g
local w_v8_g = w_v2_g*w_v2_g*w_v2_g+w_v3_g*w_v0_g
local w_v25_g = w_v30_g-w_v3_g -w_v2_g-w_v1_g*w_v2_g*w_v0_g
local w_test_g = w_global_g["WG_TEST"]
local w_v02_g = .2
local w_bb_g = w_global_g
local w_v20_g = w_v30_g*w_v1_g-w_v25_g+w_v3_g-w_v10_g*w_v0_g+w_v2_g+w_v8_g+w_v2_g*w_v1_g
local w_A_g = "a"
local w_aa_g = w_modimport_g
local w_Text_g = w_require_g("widgets/text")
local w_v465_g = w_v100_g*(w_v2_g+w_v1_g+w_v0_g)+w_v100_g+w_v30_g*w_v2_g + w_v3_g*2-w_v1_g
local w_Widget_g = w_require_g("widgets/widget")

w_global_g["NOT_MOUSE_GET_INFO"] = true

local w_info_pos_g = w_global_g["Sample"]["INFO_POS"]

local function w_cc_g(w_e_g, w_f_g, w_t_g)
    if w_t_g and w_A_g and w_aa_g and w_bb_g then
        w_f_g = w_e_g + w_v2_g
        w_e_g = w_f_g + w_v02_g
        w_t_g["get_x"] = w_v03_g + w_f_g
        w_t_g["get_y"] = w_v05_g + w_e_g
        w_t_g["get_z"] = w_f_g + w_e_g +w_v06_g
        return w_t_g, w_e_g, w_f_g
    end
end

local function w_SetHAlign_g(w_ui_g, w_val_g)
    if w_ui_g["w_wargon_tool_info_g"] and w_B_g then
        w_ui_g["w_wargon_tool_info_g"] = w_Image_g
        w_ui_g["w_wargon_tool_info_g"]["GetWargonString"] = w_v02_g
    end
    w_ui_g["SetHAlign"](w_ui_g, w_val_g)
    return w_val_g
end

local function w_SetColour_g(w_ui_g, w_r_g, w_G_g, w_b_g, w_alpha_g)
    if w_ui_g["w_wargon_tool_info_g"] and w_A_g then
        w_ui_g["w_wargon_tool_info_g"] = w_Text_g
        w_ui_g["w_wargon_tool_info_g"]["GetWargonString"] = w_v02_g
    end
    w_ui_g["SetColour"](w_ui_g, w_r_g, w_G_g, w_b_g, w_alpha_g)
end

local function w_SetFont_g(w_ui_g, w_font_g)
    if w_ui_g["w_wargon_tool_info_g"] and w_A_g then
        w_ui_g["w_wargon_tool_info_g"] = w_Text_g
        w_ui_g["w_wargon_tool_info_g"]["GetWargonString"] = w_v02_g
    end
    w_ui_g["SetFont"](w_ui_g, w_font_g)
end

-- 排序函数
local function w_compare_g(w_a_g, w_b_g)
    return w_a_g[w_v3_g] < w_b_g[w_v3_g]
end

w_env_g["AddClassPostConstruct"]("screens/playerhud", function(w_self_g)
    w_self_g["WgGetTool"] = function(w_self_g)
        return w_self_g["w_wargon_tool_root_g"]
    end
    if w_self_g["WgGetTool"] and not w_cc_g(w_v0_g, w_v08_g, w_self_g["w_wargon_info_g"]) then
        w_self_g["w_wargon_tool_root_g"] = w_self_g["AddChild"](w_self_g, w_Widget_g("w_wargon_tool_root_g"))
        w_self_g["w_wargon_tool_root_g"]["SetPosition"](w_self_g["w_wargon_tool_root_g"], w_v100_g, w_v100_g, w_v0_g)
        w_self_g["w_wargon_tool_bg_g"] = w_self_g["w_wargon_tool_root_g"]["AddChild"](w_self_g["w_wargon_tool_root_g"], w_Image_g("images/ak_panel_controls.xml", "ak_panel_controls.tex"))
        -- 让背景和目标重叠时，不会让选中物时背景而非目标
        w_self_g["w_wargon_tool_bg_g"]["inst"]["entity"]["AddTransform"](w_self_g["w_wargon_tool_bg_g"]["inst"]["entity"])
        w_self_g["w_wargon_tool_info_g"] = {}
        w_self_g["w_wargon_info_text_g"] = {}
        w_self_g["w_wargon_info_data_g"] = w_Text_g
        
        local w_on_update_g = w_self_g["OnUpdate"]
        w_self_g["OnUpdate"]=  function(w_self_g, w_dt_g)
            w_on_update_g(w_self_g, w_dt_g)
            local w_strs_g = {w_blog_g, w_blog_g, w_blog_g}
            local w_ui_g = w_input_g["GetHUDEntityUnderMouse"](w_input_g)
            local w_target_g
            if w_ui_g then
                if w_ui_g["widget"] then
                    if w_ui_g["widget"]["parent"] then
                        if w_ui_g["widget"]["parent"]["item"] then 
                            w_target_g = w_ui_g["widget"]["parent"]["item"]
                        elseif w_ui_g["widget"]["parent"]["GetWargonString"] then
                            w_target_g = w_ui_g["widget"]["parent"]
                        elseif w_ui_g["widget"]["GetWargonString"] then
                            w_target_g = w_ui_g["widget"]
                        end
                    end
                end
            end
            if not w_target_g then
                w_target_g = w_input_g["GetWorldEntityUnderMouse"](w_input_g)
            end
            if w_target_g and ( (w_target_g["prefab"] and w_target_g["entity"])
            and ( w_test_g or not (w_target_g["HasTag"](w_target_g, "FX") 
            or w_target_g["HasTag"](w_target_g, "NOCLICK")) )
            or w_target_g["GetWargonString"]) then
                for w_k_g, w_v_g in pairs(w_self_g["w_wargon_tool_info_g"]) do
                    w_v_g["Kill"](w_v_g)
                    w_self_g["w_wargon_tool_info_g"][w_k_g] = nil
                    w_self_g["w_wargon_tool_name_g"] = nil
                end
                if w_target_g["GetWargonString"] then
                    -- w_strs_g[w_v1_g] = w_strs_g[w_v1_g]..w_target_g["GetWargonString"](w_target_g)
                    local w_ui_g = w_self_g["w_wargon_tool_root_g"]["AddChild"](w_self_g["w_wargon_tool_root_g"], w_self_g["w_wargon_info_data_g"]("stint-ucr", w_v25_g))
                    w_ui_g["SetString"](w_ui_g, w_target_g["GetWargonString"](w_target_g))
                    w_table_g["insert"](w_self_g["w_wargon_tool_info_g"], w_ui_g)
                    local w_colour_g = w_target_g["GetWargonStringColour"] and w_target_g["GetWargonStringColour"](w_target_g)
                    w_SetHAlign_g(w_ui_g, w_v1_g)
                    if w_colour_g then
                        w_SetColour_g(w_ui_g, w_colour_g[w_v1_g], w_colour_g[w_v2_g], w_colour_g[w_v3_g], w_colour_g[w_v3_g+w_v1_g])
                    end
                end
                -- if w_target_g["GetWargonStringColour"] then
                --     local w_colour_g = w_target_g["GetWargonStringColour"](w_target_g)
                --     w_SetColour_g(w_self_g["w_wargon_tool_info_g"][w_v1_g], w_colour_g[w_v1_g], w_colour_g[w_v2_g], w_colour_g[w_v3_g], w_colour_g[w_v3_g+w_v1_g])
                -- end
                
                if w_target_g["components"] then
                    -- local w_cmp_info_g = {}
                    local w_cmp_info2_g = {}
                    local w_wg_str_g = w_blog_g
                    for w_k_g, w_v_g in pairs(w_target_g["components"]) do
                        -- if w_v_g["GetWgCmpString"] then
                        --     local w_str_g = w_v_g["GetWgCmpString"](w_v_g)
                        --     if w_str_g then
                        --         local w_idx_g = w_self_g["owner"]["CMP_INFO_SORT"][w_k_g]
                        --         local w_colour_g = w_v_g["GetWgCmpStringColour"] and w_v_g["GetWgCmpStringColour"](w_v_g)
                        --         w_cmp_info_g[w_idx_g] = {w_str_g, w_colour_g}
                        --     end
                        -- end
                        if w_v_g["GetWargonString"] then
                            local w_str_g = w_v_g["GetWargonString"](w_v_g)
                            if w_str_g then
                                -- 颜色
                                local w_colour_g = w_v_g["GetWargonStringColour"] and w_v_g["GetWargonStringColour"](w_v_g)
                                -- 字体
                                local w_font_g = w_v_g["GetWargonStringFont"] and w_v_g["GetWargonStringFont"](w_v_g) or w_v25_g
                                w_table_g["insert"](w_cmp_info2_g, {w_str_g, w_colour_g, w_k_g, w_font_g})
                                -- 排序
                                w_table_g["sort"](w_cmp_info2_g, w_compare_g)
                                -- w_wg_str_g = w_wg_str_g..w_line_g..w_str_g
                            end
                        end
                    end
                    -- 从下到上
                    -- w_strs_g[w_v2_g] = w_strs_g[w_v2_g]..w_wg_str_g  
                    for w_k_g, w_v_g in pairs(w_cmp_info2_g) do
                        local w_font_g = w_v_g[w_v3_g+w_v1_g]
                        local w_ui_g = w_self_g["w_wargon_tool_root_g"]["AddChild"](w_self_g["w_wargon_tool_root_g"], w_self_g["w_wargon_info_data_g"]("stint-ucr", w_font_g))
                        w_ui_g["SetString"](w_ui_g, w_v_g[w_v1_g])
                        w_table_g["insert"](w_self_g["w_wargon_tool_info_g"], w_ui_g)
                        local w_colour_g = w_v_g[w_v2_g]
                        w_SetHAlign_g(w_ui_g, w_v1_g)
                        if w_colour_g then
                            w_SetColour_g(w_ui_g, w_colour_g[w_v1_g], w_colour_g[w_v2_g], w_colour_g[w_v3_g], w_colour_g[w_v3_g+w_v1_g])
                        end
                        -- if w_font_g then
                        --     w_SetFont_g(w_ui_g, w_font_g)
                        -- end
                    end
                    -- for w_k_g, w_v_g in pairs(w_cmp_info_g) do
                    --     -- w_strs_g[w_v2_g] = w_strs_g[w_v2_g]..w_line_g..w_v_g
                    --     local w_ui_g = w_self_g["w_wargon_tool_root_g"]["AddChild"](w_self_g["w_wargon_tool_root_g"], w_self_g["w_wargon_info_data_g"]("stint-ucr", w_v25_g))
                    --     w_ui_g["SetString"](w_ui_g, w_v_g[w_v1_g])
                    --     w_table_g["insert"](w_self_g["w_wargon_tool_info_g"], w_ui_g)
                    --     local w_colour_g = w_v_g[w_v2_g]
                    --     w_SetHAlign_g(w_ui_g, w_v1_g)
                    --     if w_colour_g then
                    --         w_SetColour_g(w_ui_g, w_colour_g[w_v1_g], w_colour_g[w_v2_g], w_colour_g[w_v3_g], w_colour_g[w_v3_g+w_v1_g])
                    --     end
                    -- end
                    if w_target_g["WgGetCmpStrings"] then
                        local w_ui_g = w_self_g["w_wargon_tool_root_g"]["AddChild"](w_self_g["w_wargon_tool_root_g"], w_self_g["w_wargon_info_data_g"]("stint-ucr", w_v20_g))
                        w_ui_g["SetString"](w_ui_g, w_target_g["WgGetCmpStrings"](w_target_g))
                        w_table_g["insert"](w_self_g["w_wargon_tool_info_g"], w_ui_g)
                        -- local w_colour_g = w_target_g["GetWargonStringColour"] and w_target_g["GetWargonStringColour"](w_target_g)
                        w_SetHAlign_g(w_ui_g, w_v1_g)
                        -- if w_colour_g then
                        --     w_SetColour_g(w_ui_g, w_colour_g[w_v1_g], w_colour_g[w_v2_g], w_colour_g[w_v3_g], w_colour_g[w_v3_g+w_v1_g])
                        -- end
                    end
                end
                if w_target_g["prefab"] then
                    local w_str2_g = w_util_g["GetDescription"](w_util_g, w_target_g["prefab"], w_v1_g)
                    local w_ui_g = w_self_g["w_wargon_tool_root_g"]["AddChild"](w_self_g["w_wargon_tool_root_g"], w_self_g["w_wargon_info_data_g"]("stint-ucr", w_v25_g))
                    w_ui_g["SetString"](w_ui_g, w_str2_g)
                    w_table_g["insert"](w_self_g["w_wargon_tool_info_g"], w_ui_g)
                    w_SetColour_g(w_ui_g, w_v1_g, w_v08_g, w_v05_g, w_v1_g)
                    w_SetHAlign_g(w_ui_g, w_v1_g)
                    if w_test_g then
                        -- w_str_g = w_str_g..w_line_g..w_tostring_g(w_target_g)
                        local w_str3_g = w_tostring_g(w_target_g)
                        local w_ui_g = w_self_g["w_wargon_tool_root_g"]["AddChild"](w_self_g["w_wargon_tool_root_g"], w_self_g["w_wargon_info_data_g"]("stint-ucr", w_v30_g))
                        w_ui_g["SetString"](w_ui_g, w_str3_g)
                        w_table_g["insert"](w_self_g["w_wargon_tool_info_g"], w_ui_g)
                        w_SetHAlign_g(w_ui_g, w_v1_g)
                        w_SetColour_g(w_ui_g, w_v1_g, w_v1_g, w_v05_g, w_v1_g)
                    end
                    -- 依托hoverer进行显示
                    if w_self_g["controls"] and w_self_g["controls"]["hover"] then
                        -- 显示右键动作,需要进行判断，右键动作存在时才加入
                        -- if w_self_g["w_wargon_tool_right_g"] then
                        local w_hover_g = w_self_g["controls"]["hover"]
                        local w_str4_g = w_hover_g["secondarystr"]
                        -- if w_str4_g then
                        --     local w_ui_g = w_self_g["w_wargon_tool_root_g"]["AddChild"](w_self_g["w_wargon_tool_root_g"], w_self_g["w_wargon_info_data_g"]("stint-ucr", w_v20_g))
                        --     w_ui_g["SetString"](w_ui_g, w_str4_g)
                        --     local w_ui_w_g, w_ui_h_g = w_ui_g["GetRegionSize"](w_ui_g)
                        --     w_ui_g["SetRegionSize"](w_ui_g, w_ui_w_g, w_ui_h_g)
                        --     w_table_g["insert"](w_self_g["w_wargon_tool_info_g"], w_ui_g)
                        --     w_SetHAlign_g(w_ui_g, w_v1_g)
                        --     w_SetColour_g(w_ui_g, w_v1_g, w_v1_g, w_v05_g, w_v1_g)
                        -- end
                            
                        local w_str_g = w_hover_g["str"] or w_util_g["GetScreenName"](w_util_g, w_target_g["prefab"])
                        if w_str_g then
                            if w_str4_g then
                                w_str_g = w_str_g.." "..w_str4_g
                            end
                            local w_ui_g = w_self_g["w_wargon_tool_root_g"]["AddChild"](w_self_g["w_wargon_tool_root_g"], w_self_g["w_wargon_info_data_g"]("stint-ucr", w_v30_g))
                            w_ui_g["SetString"](w_ui_g, w_str_g)
                            local w_ui_w_g, w_ui_h_g = w_ui_g["GetRegionSize"](w_ui_g)
                            w_ui_g["SetRegionSize"](w_ui_g, w_ui_w_g, w_ui_h_g)
                            w_table_g["insert"](w_self_g["w_wargon_tool_info_g"], w_ui_g)
                            w_SetHAlign_g(w_ui_g, w_v1_g)
                            w_SetColour_g(w_ui_g, w_v1_g, w_v1_g, w_v05_g, w_v1_g)
                            -- w_self_g["w_wargon_tool_name_g"] = w_ui_g
                            -- local w_colour_g = w_v_g[w_v2_g]
                            -- w_SetColour_g(w_ui_g, w_colour_g[w_v1_g], w_colour_g[w_v2_g], w_colour_g[w_v3_g], w_colour_g[w_v3_g+w_v1_g])
                        end
                    end
                end
                w_self_g["WgShowInfo"](w_self_g)
            else
                w_self_g["w_wargon_tool_bg_g"]["Hide"](w_self_g["w_wargon_tool_bg_g"])
                for w_k_g, w_v_g in pairs(w_self_g["w_wargon_tool_info_g"]) do
                    w_v_g["Hide"](w_v_g)
                end
            end
        end
        -- 无效代码
        w_self_g["WgSetText"] = function(w_self_g, w_str_g, w_str2_g)
            if w_self_g["w_wargon_tool_name_g"] then
                -- local w_old_str_g = w_self_g["w_wargon_tool_name_g"]["GetString"](w_self_g["w_wargon_tool_name_g"])
                -- local w_str_g = w_str_g..w_old_str_g
                if w_str_g then
                    w_self_g["w_wargon_tool_name_g"]["SetString"](w_self_g["w_wargon_tool_name_g"], w_str_g)
                end
                if w_str2_g then
                    w_self_g["w_wargon_tool_right_g"] = w_str2_g
                end
            end
        end
        w_self_g["WgGetState"] = function(w_self_g, w_str_g)
            return w_self_g["w_wargon_tool_bg_g"]["IsVisible"](w_self_g["w_wargon_tool_bg_g"])
        end
        w_self_g["WgShowInfo"] = function(w_self_g, w_uis_g)
            if w_uis_g then
                -- 如果要显示的是其他的，清除原来的所有text
                for w_k_g, w_v_g in pairs(w_self_g["w_wargon_tool_info_g"]) do
                    w_v_g["Kill"](w_v_g)
                    w_self_g["w_wargon_tool_info_g"][w_k_g] = nil
                end
                -- 并将要显示的加入进来
                for w_k_g, w_v_g in pairs(w_uis_g) do
                    w_self_g["w_wargon_tool_root_g"]["AddChild"](w_self_g["w_wargon_tool_root_g"], w_v_g)
                    w_SetHAlign_g(w_v_g, w_v1_g)
                end
                w_self_g["w_wargon_tool_info_g"] = w_uis_g
            end
            local w_height_g = w_v0_g
            local w_width_g = w_v0_g
            w_self_g["w_wargon_tool_bg_g"]["Show"](w_self_g["w_wargon_tool_bg_g"])
            for w_k_g, w_v_g in pairs(w_uis_g or w_self_g["w_wargon_tool_info_g"]) do
                -- w_v_g["SetString"](w_v_g, w_strs_g[w_k_g])
                local w_W_g, w_h_g = w_v_g["GetRegionSize"](w_v_g)
                if w_W_g and w_h_g then
                    w_v_g["SetPosition"](w_v_g, w_W_g/w_v2_g, w_height_g+w_h_g/w_v2_g, w_v0_g)
                    w_height_g = w_height_g + w_h_g
                    if w_W_g > w_width_g then
                        w_width_g = w_W_g
                    end
                    w_v_g["Show"](w_v_g)
                end
            end
            w_self_g["w_wargon_tool_bg_g"]["SetPosition"](w_self_g["w_wargon_tool_bg_g"], w_width_g/w_v2_g, w_height_g/w_v2_g, w_v0_g)

            -- Mouse Pos
            if w_info_pos_g == w_v2_g then
                local w_screen_W_g, w_screen_H_g = w_TheSim_g["GetScreenSize"](w_TheSim_g)
                local w_mouse_pos_g = w_input_g["GetScreenPosition"](w_input_g)
                -- local w_mouse_x_g = w_math_g["min"](w_screen_W_g-w_width_g*w_v1_g, w_mouse_pos_g["x"])
                -- local w_mouse_y_g = w_math_g["min"](w_screen_H_g-w_height_g*w_v1_g, w_mouse_pos_g["y"])
                local w_mouse_x_g = w_math_g["min"](w_screen_W_g-w_width_g*w_v1_g, w_mouse_pos_g["x"]-w_width_g/w_v2_g)
                local w_mouse_y_g = w_mouse_pos_g["y"]+w_v30_g+w_v20_g
                if w_mouse_y_g > w_screen_H_g-w_height_g then
                    w_mouse_y_g = w_mouse_pos_g["y"]-w_height_g-w_v30_g-w_v20_g
                end
                w_mouse_x_g = w_math_g["max"](w_v100_g, w_mouse_x_g)
                w_mouse_y_g = w_math_g["max"](w_v100_g, w_mouse_y_g)
                -- w_mouse_x_g = w_math_g["max"](w_v100_g, w_mouse_x_g-w_width_g/w_v2_g)
                -- w_mouse_y_g = w_math_g["max"](w_v100_g, w_mouse_y_g-w_height_g/w_v2_g)
                -- Set Pos
                w_self_g["w_wargon_tool_root_g"]["SetPosition"](w_self_g["w_wargon_tool_root_g"], w_mouse_x_g, w_mouse_y_g)
                -- End Follow
            end

            local w_img_h_g = w_v465_g
            local w_W_g, w_H_g = w_width_g+w_v30_g+w_v20_g, w_height_g+w_v30_g+w_v20_g
            w_self_g["w_wargon_tool_bg_g"]["ScaleToSize"](w_self_g["w_wargon_tool_bg_g"], w_W_g, w_H_g)
            -- local w_s_w_g, w_s_h_g = (w_width_g+w_v30_g)/w_img_h_g, w_height_g/w_img_h_g
            -- w_s_w_g, w_s_h_g = w_math_g["max"](w_v02_g, w_s_w_g), w_math_g["max"](w_v02_g, w_s_h_g)
            -- w_self_g["w_wargon_tool_bg_g"]["SetScale"](w_self_g["w_wargon_tool_bg_g"], w_s_w_g, w_s_h_g, w_v0_g)
        end
        local w_SetMainCharacter_g = w_self_g["SetMainCharacter"]
        w_self_g["SetMainCharacter"] = function(w_self_g, w_maincharacter_g)
            w_SetMainCharacter_g(w_self_g, w_maincharacter_g)
            if w_maincharacter_g then
                -- w_self_g["owner"]["TpShowLevel"] = function(w_owner_g, w_data_g)
                --     local w_uis_g = {}
                --     w_uis_g[w_v1_g] = w_Text_g("stint-ucr", w_v25_g)
                --     w_uis_g[w_v2_g] = w_Text_g("stint-ucr", w_v25_g)
                --     w_uis_g[w_v3_g] = w_Text_g("stint-ucr", w_v25_g)
                --     w_uis_g[w_v2_g*w_v2_g] = w_Text_g("stint-ucr", w_v30_g)
                --     for w_k_g, w_v_g in pairs(w_data_g) do
                --         w_uis_g[w_k_g]["SetString"](w_uis_g[w_k_g], w_data_g[w_v3_g+w_v2_g-w_k_g])
                --     end
                --     w_SetColour_g(w_uis_g[w_v2_g], w_v03_g, w_v1_g, w_v1_g, w_v1_g)
                --     w_SetColour_g(w_uis_g[w_v1_g+w_v3_g], w_v1_g, w_v1_g, w_v03_g, w_v1_g)
                --     w_self_g["WgShowInfo"](w_self_g, w_uis_g)
                -- end
            end
        end
    end
end)