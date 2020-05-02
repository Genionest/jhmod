local Widget = require "widgets/widget"
local Sample = require "widgets/mk_sample_ui2"
local mk_morph = require "screens/mk_morph"

-- mk_skills
local function skill_fn_common(inst, skill)
	local cost = inst.components.mkskillmanager:GetSkillMana(skill)
	inst.sg:GoToState("mk_do_magic")
	inst.components.monkeymana:DoDelta(-cost)
	local body = inst.components.morph:GetCurrent()
	if body ~= "monkey" then
		inst.components.mkskillfx:CloneFx(body)
	end
end

-- local function has_enough_mana(inst)
local function has_enough_mana(inst, skill)
	-- local need = amount
	local need = inst.components.mkskillmanager:GetSkillMana(skill)
	local current = inst.components.monkeymana:GetCurrent()
	return current >= need
end

local function morph_skill(inst, skill_name)
	-- local skill_name = "morph"
	if not has_enough_mana(inst, skill_name) then return end
	TheFrontEnd:PushScreen(mk_morph())
end
local function monkey_skill(inst, skill_name)
	-- local skill_name = "monkey"
	if not has_enough_mana(inst, skill_name) then return end
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
  --   	-- mana
		-- inst.components.monkeymana:DoDelta(20)
  --   	-- fx
  --   	mk_do_magic(inst)
    end
	skill_fn_common(inst, skill_name)
end

local function back_skill(inst, skill_name)
	-- local skill_name = "back"
	if not has_enough_mana(inst, skill_name) then return end
	inst.components.talker:Say("收————")
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 15, {"primeape", "spawn_monkey"})
	for i, v in pairs(ents) do
		if v.components.monkeyspawn then
			v.components.monkeyspawn:Back()
		end
	end
	skill_fn_common(inst, skill_name)
	-- -- mana
	-- self.inst.components.monkeymana:DoDelta(20)
	-- -- fx
	-- mk_do_magic(inst)
end

local function cloud_skill(inst, skill_name)
	-- local skill_name = "cloud"
	if not has_enough_mana(inst, skill_name) then return end
	inst.components.talker:Say("筋斗云~~~~")
	local pt = inst:GetPosition()
	SpawnPrefab("collapse_small").Transform:SetPosition(pt:Get())
	local cloud = SpawnPrefab("mk_cloud")
	cloud.Transform:SetPosition(pt:Get())
	cloud.components.fueled.currentfuel = 6
	skill_fn_common(inst, skill_name)
	-- -- mana
	-- inst.components.monkeymana:DoDelta(100)
	-- -- fx
	-- mk_do_magic(inst)
end

local function frozen_skill(inst, skill_name)
	local function frozenPrefab(target)
	    if not target:IsValid() or target.prefab == "monkey_king" then
	        return
	    end
	    if target.components.freezable then
	        target.components.freezable:AddColdness(2)
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

	if not has_enough_mana(inst, skill_name) then return end
    inst.components.talker:Say("定————")
    local x, y, z = inst.Transform:GetWorldPosition()
    local targets = TheSim:FindEntities(x, y, z, 10)
    for i, v in pairs(targets) do
        frozenPrefab(v)
    end
    skill_fn_common(inst, skill_name)
    -- -- fx
    -- mk_do_magic(inst)
end

local function jgbsp_skill(inst, skill_name)
	if not has_enough_mana(inst, skill_name) then return end
	if not inst.components.inventory:Has('mk_jgb',1) 
    and not inst.components.inventory:EquipHasTag('mk_jgb') then
    	inst.components.talker:Say("金箍棒速来")
        SpawnPrefab("mk_jgb_rec").Transform:SetPosition(inst:GetPosition():Get())
        skill_fn_common(inst, skill_name)
        -- -- mana
        -- inst.components.monkeymana:DoDelta(-100)
        -- -- fx
        -- mk_do_magic(inst)
    end
end

local function coldf_skill(inst, skill_name)
	if not has_enough_mana(inst, skill_name) then return end
	inst.components.talker:Say("冰霜退散")
	inst.components.natureforbid:StartForbid("coldf")
	skill_fn_common(inst, skill_name)
end

local function firef_skill(inst, skill_name)
	if not has_enough_mana(inst, skill_name) then return end
	inst.components.talker:Say("火焰退散")
	inst.components.natureforbid:StartForbid("firef")
	skill_fn_common(inst, skill_name)
end

local function war_skill(inst, skill_name)
	local function StrikePrefab(target)
		if not target:IsValid() or target.prefab == "monkey_king" then
			return
		end
		local x, y, z = target.Transform:GetWorldPosition()
		local r = 6
		local arc = math.random(180)
		local g = arc + math.random(4)*90
		local striker = SpawnPrefab("mk_striker")
		if striker then
			striker.Transform:SetPosition(x+r*math.cos(g*math.pi/180),0,z+r*math.sin(g*math.pi/180))
			SpawnPrefab("mk_striker_fx").Transform:SetPosition(striker.Transform:GetWorldPosition())
			striker:ForceFacePoint(x, 0, z)
			if striker.Attack then
				striker:Attack(inst, target)
			end
		end
	end

	if not has_enough_mana(inst, skill_name) then return end
	inst.components.talker:Say("定叫尔等灰飞烟灭!")
	local x, y, z = inst.Transform:GetWorldPosition()
	local targets = TheSim:FindEntities(x, y, z, 15)
	local count = 0
	inst:StartThread(function()
		for i, v in pairs(targets) do
			if inst.components.combat:CanTarget(v)
			and not (v.components.follower
			and v.components.follower.leader == inst)
			and not v:HasTag("wall") then
				print(v.prefab)
				count = count + 1
				if count > 8 then
					break
				end
		        StrikePrefab(v)
		        Sleep(.15)
			end
	    end
	end)
	skill_fn_common(inst, skill_name)
end
--[[
]]

local Mk_Skill_UI = Class(Widget, function(self, owner)
	Widget._ctor(self, "Mk_Skill_UI")
	self.owner = owner

	self.morph = self:AddChild(Sample(owner, "morph", "七十二变"))
	self.morph.mk_fn = morph_skill
	self.morph:SetPosition(0, 0, 0)
	self.morph:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.morph.skill))
	if MK_INTENSIFY_CONSTANT.other_skill then
	self.monkey = self:AddChild(Sample(owner, "monkey", "猴子猴孙"))
	self.back = self:AddChild(Sample(owner, "back", "收"))
	self.cloud = self:AddChild(Sample(owner, "cloud", "腾云驾雾"))
	self.frozen = self:AddChild(Sample(owner, "frozen", "定身法"))
	self.jgbsp = self:AddChild(Sample(owner, "jgbsp", "金箍棒来", "jgb"))
	-- self.coldf = self:AddChild(Sample(owner, "coldf", "避寒决"))
	self.firef = self:AddChild(Sample(owner, "firef", "避火诀"))
	self.war = self:AddChild(Sample(owner, "war", "大闹天宫"))
	self.monkey.mk_fn = monkey_skill
	self.back.mk_fn = back_skill
	self.cloud.mk_fn = cloud_skill
	self.frozen.mk_fn = frozen_skill
	self.jgbsp.mk_fn = jgbsp_skill
	-- self.coldf.mk_fn = coldf_skill
	self.firef.mk_fn = firef_skill
	self.war.mk_fn = war_skill
	self.cloud:SetPosition(0, 70, 0)
	self.back:SetPosition(-70, 0, 0)
	self.monkey:SetPosition(-70, 70, 0)
	self.frozen:SetPosition(-140, 0, 0)
	self.jgbsp:SetPosition(-140, 70, 0)
	-- self.coldf:SetPosition(-210, 0, 0)
	self.firef:SetPosition(-210, 0, 0)
	self.war:SetPosition(-210, 70, 0)
	self.monkey:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.monkey.skill))
	self.back:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.back.skill))
	self.cloud:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.cloud.skill))
	self.frozen:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.frozen.skill))
	self.jgbsp:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.jgbsp.skill))
	-- self.coldf:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.coldf.skill))
	self.firef:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.firef.skill))
	self.war:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.war.skill))
	end

	self.inst:ListenForEvent("mk_skill_delta", function(inst, data)
		self:SetSkillPercent(data)
	end, self.owner)
end)

function Mk_Skill_UI:SetSkillPercent(data)
	if data.name and data.percent then
		-- print("mk_skill_ui setskillpercent")
		if self[data.name] then
			self[data.name]:SetPercent(data.percent)
		end
	end
end

return Mk_Skill_UI