local Badge = require "widgets/badge"

local MadBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "beaver_meter", owner)
end)

AddClassPostConstruct("widgets/statusdisplays", function(self)
	if self.owner.prefab == "wilson" then
		self.madvalue = self:AddChild(MadBadge(self.owner))
	    self.madvalue:SetPosition(-80, -115, 0)
	    self.madvalue:SetPercent(self.owner.components.tpmadvalue:GetPercent(), 
	    	self.owner.components.tpmadvalue.max)
	    self.inst:ListenForEvent("tp_madvalue_delta", function(inst, data)
	    	self:MadValueDelta(data)
	    end, self.owner)

	    function self:MadValueDelta(data)
	    	self.madvalue:SetPercent(data.new_per, self.owner.components.tpmadvalue.max) 
			if not data.no_flash then
				if data.new_per > data.old_per then
					self.madvalue:PulseGreen()
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_up")
				elseif data.new_per < data.old_per then
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_down")
					self.madvalue:PulseRed()
				end
			end
	    end
	end
end)

AddClassPostConstruct("widgets/itemtile", function(self)
	local UIAnim = require "widgets/uianim"
	if self.item.components.tprecharge then
		self.tp_recharge_frame = self:AddChild(UIAnim())
		-- self.tp_recharge_frame:GetAnimState():SetBank("recharge_meter")
		-- self.tp_recharge_frame:GetAnimState():SetBuild("recharge_meter")
		self.tp_recharge_frame:GetAnimState():SetBank("recharge_meter_wargon")
		self.tp_recharge_frame:GetAnimState():SetBuild("recharge_meter_wargon")
		self.tp_recharge_frame:GetAnimState():PlayAnimation("frame")
		self.tp_recharge_frame:Hide()

		self.tp_recharge = self:AddChild(UIAnim())
		-- self.tp_recharge:GetAnimState():SetBank("recharge_meter")
		-- self.tp_recharge:GetAnimState():SetBuild("recharge_meter")
		self.tp_recharge:GetAnimState():SetBank("recharge_meter_wargon")
		self.tp_recharge:GetAnimState():SetBuild("recharge_meter_wargon")
		self.tp_recharge:SetClickable(false)

		self.inst:ListenForEvent("tp_recharge_change", function(item, data)
			self:SetTpRechargePercent(data.per)
		end, self.item)
	end
	if self.item.components.tpbullets then
		self:SetQuantity(self.item.components.tpbullets:GetNum())
		self.inst:ListenForEvent("tp_bullet_change", function(item, data)
			self:SetQuantity(self.item.components.tpbullets:GetNum())
			self:ScaleTo(self.basescale*2, self.basescale, .25)
		end, self.item)
	end
	function self:SetTpRechargePercent(p)
		if p < 1 then
			self.tp_recharge:GetAnimState():SetPercent("recharge", p)
			local owner = self.item.components.inventoryitem:GetGrandOwner()
			if self.item and not self.item == owner.components.inventory.activeitem then
				self.tp_recharge_frame:Show()
			end
		else
			if not self.tp_recharge:GetAnimState():IsCurrentAnimation("frame_pst") then
				self.tp_recharge:GetAnimState():PlayAnimation("frame_pst")
			end
			-- if self.tp_recharge_frame.shown then
			-- end
			self.tp_recharge_frame:Hide()
		end
	end
	local old_fn = self.StartDrag
	function self:StartDrag(...)
		old_fn(self, ...)
		if self.tp_recharge then
			self.tp_recharge:Hide()
		end
		if self.tp_recharge_frame then
			self.tp_recharge_frame:Hide()
		end
	end
end)

AddClassPostConstruct('widgets/recipepopup', function(self)
	local old_refresh = self.Refresh
	function self:Refresh()
		old_refresh(self)
		if self.recipe then
			for k, v in pairs(self.recipe.ingredients) do
				if v.image then
					local ing = self.ing[k]
					ing.ing:SetTexture(v.atlas, v.image)
				end
			end
		end
	end
end)

AddClassPostConstruct("brains/leifbrain", function(self)
	require "behaviours/chaseandattack"
	require "behaviours/runaway"
	require "behaviours/wander"
	require "behaviours/doaction"
	require "behaviours/attackwall"
	require "behaviours/follow"

	local MIN_FOLLOW_DIST = 2
	local TARGET_FOLLOW_DIST = 5
	local MAX_FOLLOW_DIST = 9

	local function GetLeader(inst)
	    return inst.components.follower.leader 
	end

	function self:OnStart()

	    local clock = GetClock()

	    local root =
	        PriorityNode(
	        {
	            AttackWall(self.inst),
	            ChaseAndAttack(self.inst),
	            Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
	            Wander(self.inst)            
	        },1)
	    
	    self.bt = BT(self.inst, root)
	end
end)

AddClassPostConstruct("screens/playerhud", function(self)
	local old_update_leaves = self.UpdateLeaves
	function self:UpdateLeaves(dt)
		if WARGON.is_dlc(3) then
			old_update_leaves(self, dt)
		else
			if self.leavesTop then
			    if not self.leavestop_intensity then
			    	self.leavestop_intensity = 0
			    end	 
				local player = GetPlayer()
				if player:HasTag("tp_spear_wind") then
					self.leavestop_intensity = math.min(1,self.leavestop_intensity+(1/30) )
				else			
				 	self.leavestop_intensity = math.max(0,self.leavestop_intensity-(1/30) )
				end	

				if self.leavestop_intensity == 0 then
			    	self.leavesTop:Hide()
			    else
			    	self.leavesTop:Show()
					if self.leavestop_intensity == 1 then
				    	if not self.leavesfullyin then
				    		self.leavesTop:GetAnimState():PlayAnimation("idle", true)	
				    		self.leavesfullyin = true
				    		-- GetPlayer():PushEvent("canopyin")
				    	else	
					    	if GetPlayer().sg:HasStateTag("moving") then
					    		if not self.leavesmoving then
					    			self.leavesmoving = true
					    			self.leavesTop:GetAnimState():PlayAnimation("run_pre")	
					    			self.leavesTop:GetAnimState():PushAnimation("run_loop", true)					    					    	
					    		end
					    	else
					    		if self.leavesmoving then
					    			self.leavesmoving = nil
					    			self.leavesTop:GetAnimState():PlayAnimation("run_pst")	
					    			self.leavesTop:GetAnimState():PushAnimation("idle", true)	
					    			self.leaves_olddir = nil
					    		end
					    	end
				    	end
				    else
				    	self.leavesfullyin = nil
				    	self.leavesmoving = nil
				    	self.leavesTop:GetAnimState():SetPercent("zoom_in", self.leavestop_intensity)
					end	    	
			    end	    
			end
		end
	end
end)