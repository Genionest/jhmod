local wendys = {"wilson", "wendy", "idle_loop"}

local function on_talk(inst)
	WARGON.play_snd(inst, "dontstarve/characters/wendy//talk_LP", "talk")
	inst.AnimState:PlayAnimation("dial_loop")
	inst.AnimState:PushAnimation("idle_loop")
end

local function talk_str(inst, wendy_str)
	if type(wendy_str) == "string" then
    	inst.components.talker:Say(wendy_str)
    elseif type(wendy_str) == "table" then
    	inst:StartThread(function()
	    	for k, v in pairs(wendy_str) do
	    		inst.components.talker:Say(v)
	    		Sleep(1.5)
	    	end
    	end)
    end
end

local function MakeReporter(name, talk_fn)
	local function fn()
		local inst = WARGON.make_prefab(wendys, nil, nil, nil, 4, nil)
		WARGON.CMP.add_cmps(inst, {
			talk = {talk=on_talk},
			inspect = {},
		})
		inst.AnimState:Hide("ARM_carry")
		WARGON.EQUIP.hat_on(inst, "hat_walrus")
		WARGON.EQUIP.body_on(inst, "armor_sweatervest")
		if talk_fn then
			talk_fn(inst)
		end
		inst:SetPrefabName("tp_reporter")
		-- inst.AnimState:OverrideSymbol("swap_hat", "hat_walrus", "swap_hat")
	 --    inst.AnimState:OverrideSymbol("swap_body", "armor_sweatervest", "swap_body")
	    -- WARGON.do_task(inst, 0, function()
	    -- 	local wendy_str = STRINGS.TP_STR.tp_wendy_str
	    -- 	if type(wendy_str) == "string" then
		   --  	inst.components.talker:Say(wendy_str)
		   --  elseif type(wendy_str) == "table" then
		   --  	inst:StartThread(function()
			  --   	for k, v in pairs(wendy_str) do
			  --   		inst.components.talker:Say(v)
			  --   		Sleep(1.5)
			  --   	end
		   --  	end)
		   --  end
		   --  WARGON.do_task(inst, 2*4+.1, function()
		   --  	-- WARGON.make_spawn(inst, "tp_thumper_bp")
		   --  	c_give("tp_thumper_bp")
		   --  	WARGON.make_fx(inst, "maxwell_smoke")
		   --  	inst:Remove()
		   --  end)
	    -- end)

		return inst
	end
	return Prefab(name, fn, {})
end

local function reporter_1(inst)
	local wendy_str = STRINGS.TP_STR.tp_wendy_str
	talk_str(inst, wendy_str)
	WARGON.do_task(inst, 1.5*#wendy_str+.1, function()
		c_give("tp_thumper_bp")
		WARGON.make_fx(inst, "maxwell_smoke")
		inst:Remove()
	end)
end

local function reporter_2(inst)
	local wendy_str = STRINGS.TP_STR.tp_wendy_str2
	talk_str(inst, wendy_str)
	WARGON.do_task(inst, 1.5*#wendy_str+.1, function()
		c_give("tp_gift")
		WARGON.make_fx(inst, "maxwell_smoke")
		inst:Remove()
	end)
end

local function reporter_3(inst)
	local wendy_str = STRINGS.TP_STR.tp_wendy_str3
	talk_str(inst, wendy_str)
	WARGON.do_task(inst, 1.5*#wendy_str+.1, function()
		c_give("tp_gift")
		WARGON.make_fx(inst, "maxwell_smoke")
		inst:Remove()
	end)
end

local function reporter_4(inst)
	local wendy_str = STRINGS.TP_STR.tp_wendy_str4
	talk_str(inst, wendy_str)
	WARGON.do_task(inst, 1.5*#wendy_str+.1, function()
		-- c_give("tp_egg_tool_bp")
		c_give("tp_intro")
		-- c_give("tp_diving_mask")
		c_give("tp_update")
		WARGON.make_fx(inst, "maxwell_smoke")
		inst:Remove()
	end)
end

local function reporter_5(inst)
	local wendy_str = STRINGS.TP_STR.tp_wendy_str5
	talk_str(inst, wendy_str)
	WARGON.do_task(inst, 1.5*#wendy_str+.1, function()
		WARGON.make_fx(inst, "maxwell_smoke")
		inst:Remove()
	end)
end

local function reporter_6(inst)
	local wendy_str = STRINGS.TP_STR.tp_wendy_str6
	talk_str(inst, wendy_str)
	WARGON.do_task(inst, 1.5*#wendy_str+.1, function()
		WARGON.make_fx(inst, "maxwell_smoke")
		inst:Remove()
	end)
end

local function reporter_7(inst)
	local wendy_str = STRINGS.TP_STR.tp_wendy_str7
	talk_str(inst, wendy_str)
	WARGON.do_task(inst, 2*#wendy_str+.1, function()
		-- c_give("tp_update")
		WARGON.make_fx(inst, "maxwell_smoke")
		inst:Remove()
	end)
end

return
	-- Prefab("tp_reporter", fn, {})
	MakeReporter("tp_reporter", reporter_1),
	MakeReporter("tp_reporter2", reporter_2),
	MakeReporter("tp_reporter3", reporter_3),
	MakeReporter("tp_reporter4", reporter_4),
	MakeReporter("tp_reporter5", reporter_5),
	MakeReporter("tp_reporter6", reporter_6),
	MakeReporter("tp_reporter7", reporter_7)