local WargRider = Class(function(self, inst)
	self.inst = inst
	self.riding = nil
	self.warg = nil
	self.mount = {}
end)

-- local symbol_tbl = {
-- 	"HAT",
-- 	"SWAP_FACE",
-- 	"BEARD",
-- 	"beard",
-- 	-- "Layer 151",
-- 	"Layer 204",
-- 	"hairfront",
-- 	"HEAD_HAT",
-- 	"head",
-- 	"HAIR_HAT",
-- 	"hair",
-- 	"SWAP_BODY",
-- 	"skirt",
-- 	"torso",
-- 	"foot",
-- 	"leg",
-- 	"hand",
-- 	"player_hand",
-- 	"arm_upper",
-- 	"arm_lower",
-- 	"ARM_normal",
-- 	-- "ARM_carry",
-- 	"HAIR_pigtails",
-- 	"tail",
-- }

function WargRider:IsRiding()
	return self.riding
end

function WargRider:GetMount()
	if #self.mount >= 2 then
		return self.mount
	else
		return nil
	end
end

function WargRider:HandlerPlayerAnim(is_show)
	-- local is_hide = not is_show
	-- for i = 1, #symbol_tbl do
	-- 	if is_hide then
	-- 		self.inst.AnimState:Hide(symbol_tbl[i])
	-- 	else
	-- 		self.inst.AnimState:Show(symbol_tbl[i])
	-- 	end
	-- end
	-- local fx = self.mount[3]
	-- if fx then
	-- 	if is_hide then
	-- 		fx.entity:Show()
	-- 	else
	-- 		fx.entity:Hide()
	-- 	end
	-- end
end

function WargRider:PlayAllMountAnim(anim, is_loop)
	for _, v in pairs(self.mount) do
		if is_loop ~= nil then
			v.AnimState:PlayAnimation(anim, is_loop)
		else
			v.AnimState:PlayAnimation(anim)
		end
	end
end

function WargRider:PushAllMountAnim(anim, is_loop)
	for _, v in pairs(self.mount) do
		if is_loop ~= nil then
			v.AnimState:PushAnimation(anim, is_loop)
		else
			v.AnimState:PushAnimation(anim, is_loop)
		end
	end
end

function WargRider:SetAllMountRotation()
	local rot = self.inst.Transform:GetRotation()
	print("rotation is", rot)
	print("camera is  ", TheCamera.heading)
	for _, v in pairs(self.mount) do
		v.Transform:SetRotation(rot)
	end
	-- 135 -135 179 -90
	-- rot = math.floor(rot)
	-- if rot == 135 or rot == -135 or rot == 179 or rot == -90 then
	-- 	self.mount[1].Transform:SetPosition(0.1, 0, 0.1)
	-- 	self.mount[2].Transform:SetPosition(0, 0, 0)
	-- else
	-- 	self.mount[1].Transform:SetPosition(0, 0, 0)
	-- 	self.mount[2].Transform:SetPosition(0.1, 0, 0.1)
	-- end
	local pos = {x=0,y=0,z=0}
	local camera = TheCamera.heading
	camera = math.floor(camera)
	camera = math.fmod(camera, 360)
	if camera == 0 or camera == 45 then
		pos.z = .1
	elseif camera == 90 or camera == 135 then
		pos.x = .1
	elseif camera == 180 or camera == 225 then
		pos.z = -.1
	elseif camera == 270 or 315 then
		pos.x = -.1
	end
	self.mount[1].Transform:SetPosition(pos.x, pos.y, pos.z)
	self.mount[2].Transform:SetPosition(0,0,0)
end

function WargRider:Mount(target)
	print("a--1")
	self.inst.AnimState:SetBank("wilsonbeefalo")
	-- self.inst.AnimState:SetBank("")  -- 变为空白
	-- self.inst.AnimState:AddOverrideBuild("warg_build")
	self.inst.Transform:SetSixFaced()
	self.inst.DynamicShadow:SetSize( 2.5, 1.5 )
	local x, y, z = target.Transform:GetWorldPosition()
	-- self.inst.Transform:SetPosition(x, y, z)
	self.inst:AddChild(target)
	target.Transform:SetPosition(0, 0, 0)
	target.Transform:SetRotation(0)
	target:RemoveFromScene()
	self.warg = target
	self.inst.Physics:Teleport(x, y, z)
	print("a--2")
	local fx = SpawnPrefab("ride_warg_body_fx")
	local fx2 = SpawnPrefab("ride_warg_head_fx")
	self.inst:AddChild(fx)
	self.inst:AddChild(fx2)
	-- fx.Transform:SetPosition(-0.1,0,-0.1)
	-- fx2.Transform:SetPosition(0.1,0,.1)
	print("a--3")
	self.mount = {fx, fx2}
	self:SetAllMountRotation()
	self.riding = true
	self.inst.components.locomotor.runspeed = 10
	self.inst.components.combat:SetRange(5,5)
	self.inst.components.combat:SetDefaultDamage(50)
	print("a--4")
end

function WargRider:DisMount()
	if not self.riding then
		return 
	end
	self.riding = false
	self.inst.AnimState:SetBank("wilson")
	self.inst.Transform:SetFourFaced()
	self.inst.DynamicShadow:SetSize(1.3, .6)
	self.inst.components.locomotor.runspeed = 6
	self.inst.components.combat:SetRange(3,3)
	self.inst.components.combat:SetDefaultDamage(34)
	self.inst:RemoveChild(self.warg)
	self.warg:ReturnToScene()
	if self.warg.Physcis then
		self.warg.Physics:Teleport(self.inst.Transform:GetWorldPosition())
	else
		self.warg.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
	end
	self.warg.Transform:SetRotation(self.inst.Transform:GetRotation())
	self.warg = nil
	if #self.mount > 0 then
		for i, v in pairs(self.mount) do
			v:Remove()
		end
	end
	self.mount = {}
end

function WargRider:OnSave() 
	if #self.mount > 0 then
		for i, v in pairs(self.mount) do
			self.inst:RemoveChild(v)
			v:Remove()
		end
	end
	self.mount = {}
	local data = {}
	if self.warg then
		data.warg = self.warg:GetSaveRecord()
	end
	data.riding = self.riding
	return data
end

function WargRider:OnLoad(data)
	if data and data.riding and data.warg then
		local warg = SpawnSaveRecord(data.warg)
		self:Mount(warg)
		-- self:HandlerPlayerAnim(false)
	end
end

-- function WargRider:CollectSceneActions(doer, actions, right)
-- 	if right and doer.components.wargrider:IsRiding() and
-- 	self.inst == doer then
-- 		table.insert(actions, ACTIONS.DISRIDE_WARG)
-- 	end
-- end

return WargRider