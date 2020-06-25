AddPrefabPostInit("wilson", function(inst)
	inst:AddComponent("sciencemorph")
	inst:AddComponent("tpcallbeast")
	inst:AddComponent("tpmadvalue")
	inst:AddComponent("tpbuff")
	-- inst:AddComponent("tpnutspawner")
	local old_save = inst.OnSave
	inst.OnSave = function(inst, data)
		old_save(inst, data)
		data.tp_morph = inst.components.sciencemorph.cur
	end
	local old_load = inst.OnLoad
	inst.OnLoad = function(inst, data)
		old_load(inst, data)
		if data.tp_morph then
			inst.components.sciencemorph:Morph(data.tp_morph)
		end
	end
end)

AddPrefabPostInit("sewing_kit", function(inst)
	local old_fn = inst.components.sewing.onsewn
	inst.components.sewing.onsewn = function(inst, target, doer)
		old_fn(inst, target, doer)
		if target:HasTag("tp_tent") then
			local use = target.components.finiteuses:GetUses()
			if use+5 <= target.components.finiteuses.total then
				target.components.finiteuses:SetUses(use+5)
			end
			target.components.fueled:SetPercent(.9)
		end
	end
end)
 
-- 防止和Wilson一起在天上
-- AddPrefabPostInit("flower", function(inst)
-- 	WARGON.do_task(inst, 0, function()
-- 		local pt = inst:GetPosition()
-- 		inst.Transform:SetPosition(pt.x, 0, pt.z)
-- 	end)
-- end)

AddPrefabPostInit("birchnutdrake", function(inst)
	local old_target_fn = inst.components.combat.targetfn
	inst.components.combat.targetfn = function(inst)
		local guy = old_target_fn(inst)
		if guy and not guy:HasTag("tp_oak_armor") 
		and not (inst:HasTag("tp_defense_tree_nut") and guy:HasTag("player")) then
			return guy
		end
	end
end)

local function add_prefab_tag(name, tag)
	AddPrefabPostInit(name, function(inst)
		if type(tag) == "table" then
			for k, v in pairs(tag) do
				inst:AddTag(v)
			end
		else
			inst:AddTag(tag)
		end
	end)
end

add_prefab_tag("log", "tp_chop_pig_item")
add_prefab_tag("cork", "tp_chop_pig_item")
add_prefab_tag("livinglog", "tp_chop_pig_item")
add_prefab_tag("bamboo", "tp_hack_pig_item")
add_prefab_tag("vine", "tp_hack_pig_item")
add_prefab_tag("seeds", "tp_farm_pig_item")