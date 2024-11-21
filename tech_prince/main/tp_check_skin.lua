local function check_skin()
	local skin_mod = "workshop-1485194313"
	for k, v in pairs(ModManager.modnames) do
		if v == skin_mod then
			return true
		end
	end
	return false
end

if check_skin() then

_G.WARGON.HAS_SKIN = true
AddPrefabPostInit("wilson", function(inst)
    inst:add_listener("tp_morph", function(inst, data)
        local builds = {
            v = "wilson_victorian",
            m = "wilson_madscience",
        }
        if data.cur and builds[data.cur] then
            inst.AnimState:SetBuild(builds[data.cur])
        end
    end)
end)

AddPrefabPostInit("tp_sign_rider", function(inst)
    inst.AnimState:SetBuild("wathgrithr_gladiator")
end)
AddPrefabPostInit("tp_sign_rider_2", function(inst)
    inst.AnimState:SetBuild("waxwell_gladiator")
end)
AddPrefabPostInit("tp_sign_rider_3", function(inst)
    inst.AnimState:SetBuild("woodie_gladiator")
end)
AddPrefabPostInit("tp_sign_rider_4", function(inst)
    inst.AnimState:SetBuild("wolfgang_gladiator")
end)

end