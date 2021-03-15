local function tp_health_equip_complete(inst)
	if inst:HasTag("tp_hat_health") and inst:HasTag("tp_armor_health")
	and inst:HasTag("tp_spear_blood") then
		if inst.tp_health_equip_task == nil then
			inst.tp_health_equip_task = WARGON.per_task(inst, 4, function()
				if inst.components.health then
					inst.components.health:DoDelta(2, true, "tp_health_equip")
				end
			end)
		end
	end
end

local function tp_health_equip_incomplete(inst)
	if inst.tp_health_equip_task then
		inst.tp_health_equip_task:Cancel()
		inst.tp_health_equip_task = nil
	end
end

GLOBAL.WARGON.EQUIP.tp_health_equip_complete = tp_health_equip_complete
GLOBAL.WARGON.EQUIP.tp_health_equip_incomplete = tp_health_equip_incomplete

WgImg = Class(function(self, img)
	self.atlas, self.img = WARGON.resolve_img_path(img)
end)

function WgImg:GetImg()
	return self.atlas, self.img
end

WgAnim = Class(function(self, anims, is_loop)
	self.bank = anims[1]
	self.build = anims[2]
	self.anim = anims[3]
	self.is_loop = is_loop
end)

function WgAnim:SetAnim(anim)
	anim:SetBank(self.bank)
	anim:SetBuild(self.build)
	anim:PlayAnimation(self.anim, self.is_loop)
end

function WgAnim:GetAnim()
	return {self.bank, self.build, self.anim}
end