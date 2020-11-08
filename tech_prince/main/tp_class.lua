local Badge = require "widgets/badge"
local TpComposed = require "screens/tp_composed_panel"
local ImageButton = require "widgets/imagebutton"
local TpUpdate = require "screens/tp_update_panel"
local Text = require "widgets/text"
local TpLevel = require "screens/tp_level_panel"
local TpCheck = require "screens/tp_check_panel"
local TpTeach = require "screens/tp_teach_panel"
local TpSale = require "screens/tp_sale_panel"
local TpBuffBar = require "widgets/tp_buff_bar"

local MadBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "beaver_meter", owner)
end)

AddClassPostConstruct("widgets/statusdisplays", function(self)
	local function add_word(ui, txt)
        ui.word = ui:AddChild(Text(TITLEFONT, 20))
        ui.word:SetPosition(0, -30, 0)
        ui.word:SetString(txt)
	end
	local function resolve_img_path(img)
		local atlas = "images/inventoryimages"
		if string.find(img, "#") then
			img = string.sub(img, 1, -2)
			atlas = atlas.."/"..img
		elseif img > "torch" then
			atlas = atlas.."_2"
		end
		return atlas..".xml", img..".tex"
	end
	local function get_position(start, pad, len, idx)
		local x, y = start[1], start[2]
		local pad_x, pad_y = pad[1], pad[2]
		local pos_x = x + (idx%len)*pad_x
		local pos_y = y + math.floor(idx/len)*pad_y
		return pos_x, pos_y
	end
	local function set_position(ui, x, y, z)
		local scale = WARGON.get_screen_size()
		ui:SetPosition(x*scale, y*scale, z)
	end
	if self.owner.prefab == "wilson" then
		self.madvalue = self:AddChild(MadBadge(self.owner))
		-- self.madvalue:Hide()
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
		-- version
		self.tp_version_txt = self:AddChild(Text(TITLEFONT, 30))
		self.tp_version_txt:SetString(WARGON.version)	
		self.tp_version_txt:SetPosition(-180, 0, 0)

		-- icons
		self.icons = {}
		local icons = {
			{
				img = "book_brimstone",
				txt = "更新公告",
				fn = function()
					TheFrontEnd:PushScreen(TpUpdate())
				end
			},
			{
				img = "book_meteor",
				txt = "合成图鉴",
				fn = function()
					TheFrontEnd:PushScreen(TpComposed())
				end,
			},
			{
				img = "book_gardening",
				txt = "等级提升",
				fn = function()
					TheFrontEnd:PushScreen(TpLevel())
				end,
			},
			{
				img = "book_birds",
				txt = "搜索世界",
				fn = function()
					TheFrontEnd:PushScreen(TpCheck())
				end,
			},
			{
				img = "book_sleep",
				txt = "帮助信息",
				fn = function()
					TheFrontEnd:PushScreen(TpTeach())
				end,
			},
			{
				img = "book_tentacles",
				txt = "充值商城",
				fn = function()
					if GetPlayer().components.tplevel 
					and GetPlayer().components.tplevel:GetLevel() >= 20 then
						TheFrontEnd:PushScreen(TpSale())
					else
						GetPlayer().components.talker:Say("需要20级才能打开")
					end
				end,
			},
		}
		for k, v in pairs(icons) do
			local wgimg = WgImg(v.img)
			self.icons[k] = self:AddChild(ImageButton(
				-- resolve_img_path( v.img )
				wgimg.atlas, wgimg.img
			))
			local pos_x, pos_y = get_position(
				{-260, 140}, {70, -70}, 3, k-1
			)
			self.icons[k]:SetPosition(pos_x, pos_y, 0)
			-- set_position(self.icons[k], pos_x, pos_y, 0)
			self.icons[k]:SetOnClick(function()
				local click_fn = v.fn
				click_fn()
			end)
			add_word(self.icons[k], v.txt)
		end
		
		-- Skill UI
		self.skills = {}
		local skills = {
			-- {
			-- 	img = "axe",
			-- 	txt = "Axe!",
			-- 	fn = function()
			-- 		local player = GetPlayer()
			-- 		if player.components.inventory:Has("flint", 1) then
			-- 			player.components.inventory:ConsumeByName("flint", 1)
			-- 			c_give("axe")
			-- 			player.components.sanity:DoDelta(-5)
			-- 		end
			-- 	end,
			-- },
			-- {
			-- 	img = "cane",
			-- 	txt = "Running",
			-- 	fn = function()
			-- 		local player = GetPlayer()
			-- 		if player.components.sanity.current > 5 then
			-- 			player:add_speed_rate("tp_skill_cane", .3, 3)
			-- 			player.components.sanity:DoDelta(-5, true)
			-- 		end
			-- 	end,
			-- },
			-- {
			-- 	img = "petals",
			-- 	txt = "Pick\nFlower",
			-- 	fn = function()
			-- 		local player = GetPlayer()
			-- 		player.components.hunger:DoDelta(-1, true)
			-- 		local flower = player:wg_find(3, function(item)
			-- 			return item.prefab == "flower"
			-- 		end, nil, {"fire"})
			-- 		if flower and flower.components.pickable then
			-- 			flower.components.pickable:Pick(player)
			-- 		end
			-- 	end,
			-- },
			-- {
			-- 	img = "cutgrass",
			-- 	txt = "Fast\nWorking",
			-- 	fn = function()
			-- 		local player = GetPlayer()
			-- 		player.components.tpbuff:AddBuff("tp_fast_work")
			-- 	end,
			-- },
			-- {
			-- 	img = "nightsword",
			-- 	txt = "Summon\nShadow",
			-- 	fn = function()
			-- 		local player = GetPlayer()
			-- 		player.components.health:DoDelta(-5)
			-- 		WARGON.make_spawn(player, "shadow_sp")
			-- 	end,
			-- },
		}
		for k, v in pairs(skills) do
			local wgimg = WgImg(v.img)
			self.skills[k] = self:AddChild(ImageButton(
				-- resolve_img_path( v.img )
				wgimg.atlas, wgimg.img
			))
			local pos_x, pos_y = get_position(
				{-1205, -580}, {70, 70}, 8, k-1
			)
			self.skills[k]:SetPosition(pos_x, pos_y, 0)
			set_position(self.skills[k], pos_x, pos_y, 0)
			self.skills[k]:SetOnClick(function()
				local click_fn = v.fn
				click_fn()
			end)
			add_word(self.skills[k], v.txt)
		end

		-- buff slots
		self.buff_bar = self:AddChild(TpBuffBar())
		-- self.buff_bar:SetPosition(-600, -580)
		set_position(self.buff_bar, -600, -580)
		self.inst:ListenForEvent("tp_add_buff", function(inst, data)
			-- print("tp_add_buff", data.buff)
			if data.img then
				print(data.buff, data.img, data.time, data.debuff)
				self.buff_bar:Add(data.buff, data.img, data.time, data.debuff)
			end
		end, self.owner)
		self.inst:ListenForEvent("tp_done_buff", function(inst, data)
			-- print("tp_done_buff", data.buff)
			self.buff_bar:Delete(data.buff)
		end, self.owner)
		-- for load bug
		-- local buff_data = WARGON.DATA.tp_data_buff.buffs
		local buff_manager = WARGON.DATA.tp_data_buff.buff_manager
		for k, v in pairs(self.owner.components.tpbuff.buff) do
			local buff_name = k
			local time = v.left - GetTime()
			-- local max_time = buff_data[buff_name].time
			-- local img = buff_data[buff_name].img
			-- local debuff = buff_data[buff_name].debuff
			local max_time = buff_manager:get_buff_time(buff_name)
			local img = buff_manager:get_buff_img(buff_name)
			local debuff = buff_manager:is_debuff(buff_name)
			if img then
				-- print(buff_name, img, time, debuff)
				-- 还原真正的百分比，而非以加载后的剩余时长为初始的100%
				local buff_slot = self.buff_bar:Add(buff_name, img, max_time, debuff)
				buff_slot:SetTime(time)
			end
		end
	end
end)

AddClassPostConstruct("widgets/itemtile", function(self)
	local UIAnim = require "widgets/uianim"
	if self.item.components.tprecharge then
		self.tp_recharge_frame = self:AddChild(UIAnim())
		self.tp_recharge_frame:GetAnimState():SetBank("recharge_meter_wargon")
		self.tp_recharge_frame:GetAnimState():SetBuild("recharge_meter_wargon")
		self.tp_recharge_frame:GetAnimState():PlayAnimation("frame")
		self.tp_recharge_frame:Hide()

		self.tp_recharge = self:AddChild(UIAnim())
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
			if self.item and owner.components.inventory 
			and not self.item == owner.components.inventory.activeitem then
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
	    return inst.components.follower and inst.components.follower.leader 
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

AddGlobalClassPostConstruct('entityscript', 'EntityScript', function(self)
	self.tp_tag_num = {}
	function self:AddTagNum(tag, n)
		if self.tp_tag_num[tag] == nil then
			self.tp_tag_num[tag] = 0
		end
		self.tp_tag_num[tag] = math.max(0, self.tp_tag_num[tag]+n)
		if self.tp_tag_num[tag] > 0 then
			self:AddTag(tag)
			print("entity add tag", tag)
		else
			self:RemoveTag(tag)
			print("entity rm tag", tag)
		end
	end
end)