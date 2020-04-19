local mk_morph = require "screens/mk_morph"

local function skill_fn_common(inst, num)
	inst.sg:GoToState("mk_do_magic")
	inst.components.monkeymana:DoDelta(-num)
end

local function has_enough_mana(inst, skill)
	local need = inst.components.mkskillmanager:GetSkillMana(skill)
	local current = inst.components.monkeymana:GetCurrent()
	return current >= need
end

local function skill_common(inst, skill, fn)
	if has_enough_mana(inst, skill) then
		fn(inst)
	end
end

local function morph_skill(inst)
	TheFrontEnd:PushScreen(mk_morph())
end

local function monkey_skill(inst)
	inst.components.talker:Say("变————")
	local theta = math.random() * 2 * PI
    local pt = inst:GetPosition()
    local radius = math.random(3, 6)
    local offset = FindWalkableOffset(pt, theta, radius, 12, true)
    if offset then
        local image = SpawnPrefab("primeape")
        local pos = pt + offset
        image.Transform:SetPosition(pos:Get())
        inst.components.leader:AddFollower(image)
    	image.components.follower:AddLoyaltyTime(35)
    	if image.components.monkeyspawn then
    		image.components.monkeyspawn:SetTime(30)
    	end
        SpawnPrefab("statue_transition").Transform:SetPosition(pos:Get())
    	SpawnPrefab("statue_transition_2").Transform:SetPosition(pos:Get())
        if image:GetIsOnWater() then
            image.components.monkeyspawn:Back()
            inst.components.talker:Say("孩儿们不会水")
        end
        inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_appear")
  		skill_fn_common(inst, 20)
  --   	-- mana
		-- inst.components.monkeymana:DoDelta(20)
  --   	-- fx
  --   	mk_do_magic(inst)
    end
end

local function back_skill(inst)
	inst.components.talker:Say("收————")
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 15, {"primeape", "spawn_monkey"})
	for i, v in pairs(ents) do
		if v.components.monkeyspawn then
			v.components.monkeyspawn:Back()
		end
	end
	skill_fn_common(inst, 20)
	-- -- mana
	-- self.inst.components.monkeymana:DoDelta(20)
	-- -- fx
	-- mk_do_magic(inst)
end

local function cloud_skill(inst)
	inst.components.talker:Say("筋斗云~~~~")
	local pt = inst:GetPosition()
	SpawnPrefab("collapse_small").Transform:SetPosition(pt:Get())
	local cloud = SpawnPrefab("mk_cloud")
	cloud.Transform:SetPosition(pt:Get())
	cloud.components.fueled.currentfuel = 10
	skill_fn_common(inst, 100)
	-- -- mana
	-- inst.components.monkeymana:DoDelta(100)
	-- -- fx
	-- mk_do_magic(inst)
end

local function frozen_skill(inst)
	local function frozenPrefab(target)
	    if not target:IsValid() or target:HasTag("player") then
	        return
	    end
	    if target.components.freezable then
	        target.components.freezable:AddColdness(4)
	        target.components.freezable:SpawnShatterFX()
	        -- 能冻住才有这些
	        if target.components.burnable then
	            if target.components.burnable:IsBurning() then
	                target.components.burnable:Extinguish()
	            elseif target.components.burnable:IsSmoldering() then
	                target.components.burnable:SmotherSmolder()
	            end
	        end
	        if target.components.sleeper and target.components.sleeper:IsAsleep() then
	            target.components.sleeper:WakeUp()
	        end
	    end
	end

    inst.components.talker:Say("定————")
    local x, y, z = inst.Transform:GetWorldPosition()
    local targets = TheSim:FindEntities(x, y, z, 10)
    for i, v in pairs(targets) do
        frozenPrefab(v)
    end
    skill_fn_common(inst, 100)
    -- -- fx
    -- mk_do_magic(inst)
end

local function jgbsp_skill(inst)
	if not inst.components.inventory:Has('mk_jgb',1) 
    and not inst.components.inventory:EquipHasTag('mk_jgb')
    and inst.components.monkeymana:GetCurrent() >= 100 then
        SpawnPrefab("mk_jgb_rec").Transform:SetPosition(inst:GetPosition():Get())
        skill_fn_common(inst, 100)
        -- -- mana
        -- inst.components.monkeymana:DoDelta(-100)
        -- -- fx
        -- mk_do_magic(inst)
    end
end

local function add_skillmanager(inst)
	inst:AddComponent("morph")
	-- inst:AddComponent("monkeyspawner")
	inst:AddComponent("mkskillmanager")
	inst.components.mkskillmanager:SetSkillMana("morph", 20)
	inst.components.mkskillmanager:SetSkillMana("monkey", 10)
	inst.components.mkskillmanager:SetSkillMana("back", 20)
	inst.components.mkskillmanager:SetSkillMana("cloud", 100)
	inst.components.mkskillmanager:SetSkillMana("frozen", 100)
	inst.components.mkskillmanager:SetSkillMana("jgbsp", 100)
	inst.components.mkskillmanager:AddSkill("morph", skill_common(inst,"morph",morph_skill))
	inst.components.mkskillmanager:AddSkill("monkey", skill_common(inst,"monkey",monkey_skill))
	inst.components.mkskillmanager:AddSkill("back", skill_common(inst,"back",back_skill))
	inst.components.mkskillmanager:AddSkill("cloud", skill_common(inst,"cloud",cloud_skill))
	inst.components.mkskillmanager:AddSkill("frozen", skill_common(inst,"frozen",frozen_skill))
	inst.components.mkskillmanager:AddSkill("jgbsp", skill_common(inst,"jgbsp",jgbsp_skill))
end

local skill_ui = require "widgets/mk_skill_ui"
local function add_skillUI(self)
	self.mk_skill_ui = self:AddChild(skill_ui())
	self.mk_skill_ui:SetPosition(190, 20, 0)
end

local function fix_primeape(inst)
	inst:AddComponent("monkeyspawn")
end

AddPrefabPostInit("monkey_king", add_skillmanager)
AddClassPostConstruct("widgets/statusdisplays", add_skillUI)
AddPrefabPostInit("primeape", fix_primeape)