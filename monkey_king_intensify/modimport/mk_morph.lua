local morph_key = GetModConfigData("morph_key")
local mk_morph = require "screens/mk_morph"
-- 变身
local function setChangeBody(inst)
	inst:AddComponent("morph")
	if morph_key ~= 0 then
		TheInput:AddKeyDownHandler(morph_key, function()
			TheFrontEnd:PushScreen(mk_morph())
		end)
	end
end

AddPrefabPostInit("monkey_king", setChangeBody)