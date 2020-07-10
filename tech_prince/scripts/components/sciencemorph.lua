local ScienceMorph = Class(function(self, inst)
	self.inst = inst
	self.builds = {
		v = "wilson_victorian",
		m = "wilson_madscience",
		w = "wilson",
	}
	self.cur = 'w'
	self.fx = nil
	inst:ListenForEvent("tp_madvalue_empty", function()
		self:UnMad()
	end)
end)

function ScienceMorph:WithChange(tags, no_tags, sci, hunger, mag)
	if type(tags) == "table" then
		for i, v in pairs(tags) do
			self.inst:AddTag(v)
		end
	elseif type(tags) == "string" then
		self.inst:AddTag(tags)
	end
	if type(no_tags) == "table" then
		for i, v in pairs(no_tags) do
			self.inst:RemoveTag(v)
		end
	elseif type(no_tags) == "string" then
		self.inst:RemoveTag(no_tags)
	end
	self.inst.components.builder.science_bonus = sci
	self.inst.components.builder.magic_bonus = mag
	self.inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE*hunger)
end

function ScienceMorph:Morph(sym)
	local old = self.cur
    if not sym then
		if self.cur ~= "w" then
			self.cur = "w"
		elseif self.cur ~= "v" then
			self.cur = "v"
		end
		local clock = GetWorld().components.clock
	    if (clock:IsNight() and clock:GetMoonPhase() == "full") then
	    	self.cur = "m"
	    	self.inst.components.tpmadvalue:SetPercent(1)
	    end
	else
    	self.cur = sym
    end
	self.inst:DoTaskInTime(.5, function()
		self:SetBuild()
	end)
end

function ScienceMorph:UnMad()
	if self.cur == "m" then
		self.inst.sg:GoToState("science_morph2")
		self:Morph("w")
	end
end

local function fly_do_trail(inst)
    local owner = inst
    if not owner.entity:IsVisible() then
        return
    end

    local x, y, z = owner.Transform:GetWorldPosition()
    if owner.sg ~= nil and owner.sg:HasStateTag("moving") then
        local theta = -owner.Transform:GetRotation() * DEGREES
        local speed = owner.components.locomotor:GetRunSpeed() * .1
        x = x + speed * math.cos(theta)
        z = z + speed * math.sin(theta)
    end
	local map = GetWorld().Map
    local offset = FindValidPositionByFan(
        math.random() * 2 * PI,
         .5 + math.random() * .5,
        4,
        function(offset)
            local pt = Vector3(x + offset.x, 0, z + offset.z)
            return map:GetTileAtPoint(pt:Get())	
                and #TheSim:FindEntities(pt.x, 0, pt.z, .7, { "shadowtrail" }) <= 0 
        end
    )
    if offset ~= nil then
		SpawnPrefab("tp_shadow_fx").Transform:SetPosition(x + offset.x, 0, z + offset.z)
    end
end

function ScienceMorph:SetFx()
	if self.fx then
		self.fx:Remove()
		self.fx = nil
	end
	if self.fx_task then
		self.fx_task:Cancel()
		self.fx_task = nil
	end
	if self.cur == "v" then
		self.fx = SpawnPrefab("tp_sparkle_fx")
		self.fx.entity:AddFollower()
		self.fx.Follower:FollowSymbol(self.inst.GUID, "swap_hat", 0, 0, 0)
	elseif self.cur == "m" then
		self.fx_task = WARGON.per_task(self.inst, 6*FRAMES, fly_do_trail, 2*FRAMES)
	end
end

function ScienceMorph:GetBuild()
	return self.builds[self.cur]
end

function ScienceMorph:SetBuild()
	self.inst.AnimState:SetBuild(self.builds[self.cur])
	if self.cur == "v" then
		self:WithChange('tech_prince', 'mad_prince', 1, 2, 0)
		self:SetFx()
		self.inst.components.sanity.dapperness = TUNING.DAPPERNESS_MED_LARGE
		self.inst.components.tpmadvalue:Stop()
		self.inst.components.locomotor:AddSpeedModifier_Additive("mad_prince", 0)
	elseif self.cur == "m" then
		self:WithChange('mad_prince', 'tech_prince', 0, 1, 2)
		self:SetFx()
		self.inst.components.sanity.dapperness = -TUNING.DAPPERNESS_MED_LARGE
		self.inst.components.tpmadvalue:Start()
		self.inst.components.locomotor:AddSpeedModifier_Additive("mad_prince", .25)
	elseif self.cur == "w" then
		self:SetFx()
		self:WithChange(nil, {'tech_prince', 'mad_prince'}, 0, 1, 0)
		self.inst.components.sanity.dapperness = 0
		self.inst.components.tpmadvalue:Stop()
		self.inst.components.locomotor:AddSpeedModifier_Additive("mad_prince", 0)
	end
	self.inst:PushEvent("tp_morph", {cur=self.cur})
end

return ScienceMorph