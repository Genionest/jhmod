local papyrus = {"papyrus", "papyrus", "idle"}

local function onfinished(inst)
	inst:Remove()
end

local function MakeScroll(name, anims, fn_name, img)
	local function fn()
		local inst = WARGON.make_prefab(anims, nil, "inv")
		WARGON_CMP_EX.add_cmps(inst, 
		{
			invitem = {img=img},
			inspect = {},
			book = {fn = WARGON_SCROLL_FN[fn_name], act="map"},
			finite = {use=1, max=1, fn=onfinished}
		})

	    return inst
	end
	return Prefab("common/inventory/"..name, fn, {})
end

return MakeScroll("scroll_sleep", papyrus, "sleep", "papyrus"),
	MakeScroll("scroll_grow", papyrus, "grow", "papyrus"),
	MakeScroll("scroll_lightning", papyrus, "lightning", "papyrus"),
	MakeScroll("scroll_bird", papyrus, "bird", "papyrus"),
	MakeScroll("scroll_tentacle", papyrus, "tentacle", "papyrus"),
	MakeScroll("scroll_volcano", papyrus, "volcano", "papyrus")