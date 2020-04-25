local SkillFx = Class(function(self, inst)
	self.inst = inst
end)

function SkillFx:StaffFx()
	local inst = self.inst
	inst.stafffx2 = SpawnPrefab("staffcastfx")           
    local pos = inst:GetPosition()
    inst.stafffx2.Transform:SetPosition(pos.x, pos.y, pos.z)
    inst.stafffx2.Transform:SetRotation(inst.Transform:GetRotation())
    inst.stafffx2.AnimState:SetMultColour(.5, 0, 0, 1)
end

function SkillFx:StaffLight()
	local inst = self.inst
	inst.stafflight2 = SpawnPrefab("staff_castinglight")
    local pos = inst:GetPosition()
    local colour = {.5,0,0}
    inst.stafflight2.Transform:SetPosition(pos.x, pos.y, pos.z)
    inst.stafflight2.setupfn(inst.stafflight2, colour, 1.9, .33)
end

function SkillFx:ShadowFx()
	local inst = self.inst
	local pos = inst:GetPosition()
	SpawnPrefab("statue_transition").Transform:SetPosition(pos:Get())
	SpawnPrefab("statue_transition_2").Transform:SetPosition(pos:Get())
end

function SkillFx:CloneFx(body)
	local inst = self.inst
	local pos = inst:GetPosition()
	local dx = 3 + math.random()
	local dz = 3 + math.random()
	if math.random() < .5 then dx = -dx end
	if math.random() < .5 then dz = -dz end
	SpawnPrefab("collapse_small").Transform:SetPosition(pos.x+dx, pos.y, pos.z+dx)
	local fx = SpawnPrefab("mk_morph_fx")
	fx.Transform:SetPosition(pos.x+dx, pos.y, pos.z+dx)
	fx.morph_body = body
	fx.monkeyking = inst
end

return SkillFx