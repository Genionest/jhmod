local cloud_key = GetModConfigData("cloud_key")
-- 腾云驾雾
local function spawnCloud(inst)
	inst.CloudSpawn = function(inst)
		if inst.components.monkeymana:EnoughMana(100) then
			inst.components.talker:Say("筋斗云~~~~")
			local pt = inst:GetPosition()
			SpawnPrefab("collapse_small").Transform:SetPosition(pt:Get())
			local cloud = SpawnPrefab("mk_cloud")
			cloud.Transform:SetPosition(pt:Get())
			cloud.components.fueled.currentfuel = 10
			-- fx
			inst:mk_do_magic()
			-- ui
			inst.components.mkcloudtimer:SetPercent(0)
		else
			inst.components.talker:Say("俺还是去找点蘑菇吃吧")
		end
	end
	if cloud_key ~= 0 then
		TheInput:AddKeyDownHandler(cloud_key, function()
			inst:CloudSpawn()
		end)
	end
end

AddPrefabPostInit("monkey_king", spawnCloud)