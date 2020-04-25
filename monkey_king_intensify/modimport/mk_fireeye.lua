-- 火眼修改
local function changeFireEye(inst)
	local old_fn = inst.TriggerFireEye
	inst.TriggerFireEye = function(inst)
		old_fn(inst)
		if inst.fireeye_hunger_task then
			inst.fireeye_hunger_task:Cancel()
			inst.fireeye_hunger_task = nil
			if inst.components.monkeymana:GetCurrent() > 3 then
				inst.components.monkeymana:DoDelta(inst:HasTag('fireeye_boost_mk') and 0 or -4,true)
			else
				inst.components.hunger:DoDelta(inst:HasTag('fireeye_boost_mk') and 0 or -3,true)
			end
			inst.fireeye_hunger_task = inst:DoPeriodicTask(1, function()
				if inst.components.monkeymana:GetCurrent() > 3 then
					inst.components.monkeymana:DoDelta(inst:HasTag('fireeye_boost_mk') and 0 or -4,true)
				else
					inst.components.hunger:DoDelta(inst:HasTag('fireeye_boost_mk') and 0 or -3,true)
				end
			end)
		end
	end
end

AddPrefabPostInit("monkey_king", changeFireEye)