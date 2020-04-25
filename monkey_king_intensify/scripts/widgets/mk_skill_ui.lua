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
  		skill_fn_common(inst, skill_name)
  --   	-- mana
		-- inst.components.monkeymana:DoDelta(20)
  --   	-- fx
  --   	mk_do_magic(inst)
    end
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
	cloud.components.fueled.currentfuel = 10
	skill_fn_common(inst, skill_name)
	-- -- mana
	-- inst.components.monkeymana:DoDelta(100)
	-- -- fx
	-- mk_do_magic(inst)
end

local function frozen_skill(inst, skill_name)
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
    and not inst.components.inventory:EquipHasTag('mk_jgb')
    and inst.components.monkeymana:GetCurrent() >= 100 then
        SpawnPrefab("mk_jgb_rec").Transform:SetPosition(inst:GetPosition():Get())
        skill_fn_common(inst, skill_name)
        -- -- mana
        -- inst.components.monkeymana:DoDelta(-100)
        -- -- fx
        -- mk_do_magic(inst)
    end
end
--[[
]]

local Mk_Skill_UI = Class(Widget, function(self, owner)
	Widget._ctor(self, "Mk_Skill_UI")
	self.owner = owner

	self.morph = self:AddChild(Sample(owner, "morph", "七十二变"))
	self.monkey = self:AddChild(Sample(owner, "monkey", "猴子猴孙"))
	self.back = self:AddChild(Sample(owner, "back", "回来吧"))
	self.cloud = self:AddChild(Sample(owner, "cloud", "腾云驾雾"))
	self.frozen = self:AddChild(Sample(owner, "frozen", "定身法"))
	self.jgbsp = self:AddChild(Sample(owner, "jgbsp", "金箍棒来", "jgb"))
	self.morph.mk_fn = morph_skill
	self.monkey.mk_fn = monkey_skill
	self.back.mk_fn = back_skill
	self.cloud.mk_fn = cloud_skill
	self.frozen.mk_fn = frozen_skill
	self.jgbsp.mk_fn = jgbsp_skill
	self.morph:SetPosition(0, 0, 0)
	self.monkey:SetPosition(0, 70, 0)
	self.back:SetPosition(-70, 0, 0)
	self.cloud:SetPosition(-70, 70, 0)
	self.frozen:SetPosition(-140, 0, 0)
	self.jgbsp:SetPosition(-140, 70, 0)
	self.morph:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.morph.skill))
	self.monkey:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.monkey.skill))
	self.back:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.back.skill))
	self.cloud:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.cloud.skill))
	self.frozen:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.frozen.skill))
	self.jgbsp:SetPercent(self.owner.components.mkskilltimer:GetPercent(self.jgbsp.skill))

	self.inst:ListenForEvent("mk_skill_delta", function(inst, data)
		self:SetSkillPercent(data)
	end, self.owner)
end)

function Mk_Skill_UI:SetSkillPercent(data)
	if data.name and data.percent then
		print("mk_skill_ui setskillpercent")
		if self[data.name] then
			self[data.name]:SetPercent(data.percent)
		end
	end
end

return Mk_Skill_UI