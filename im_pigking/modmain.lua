--[[
To do:
1.完成猪人个体ui
2.添加更多按钮：收草、树枝，捡木头，铲树根，上交物品，睡觉
3.添加技能：护盾，雷拳，神速
4.能把猪人房里的猪叫出来
]]
GLOBAL.setmetatable(env, {__index = function(t, k)
	return GLOBAL.rawget(GLOBAL, k)
end,})

PrefabFiles= {
}

Assets = {
}

local L = GetModConfigData("language")
local str = {
	follow = "跟随",
	follow_txt = "猪村的勇士们，听从我的号令",
	axe = "砍树",
	axe_txt = "要致富，先撸树",
	spear = "攻击",
	spear_txt = "兄弟们，干就完事了",
	giveup = "放弃",
	giveup_txt = "崩、撤、卖、遛",
	pigtech = "科技",
	dissolve = "解散",
	dissolve_txt = "大伙都散了吧",
	captain = "领航",
	captain_txt1 = "也许我差个船长的帽子",
	captain_txt2 = "扬帆，起航",
}
if L then
str = {
	follow = "Follow",
	follow_txt = "Follow me",
	axe = "Chop",
	axe_txt = "Chop Tree",
	spear = "Attack",
	spear_txt = "Attack enemy",
	giveup = "GiveUp",
	giveup_txt = "Give up",
	pigtech = "Tech",
	dissolve = "Dissolve",
	dissolve_txt = "Dissolve",
	captain = "Captain",
	captain_txt1 = "I need a captain hat",
	captain_txt2 = "I'm captain",
}
end

STRINGS.STR_PIGKING={}
for k, v in pairs(str) do
	STRINGS.STR_PIGKING[k] = v
end
-- local Day = GetModConfigData("pighouse")
-- local Time = GetModConfigData("time")
TUNING.PIGKING = {}
TUNING.PIGKING.time = GetModConfigData("time")
TUNING.PIGKING.day = GetModConfigData("pighouse")

local PagePoster = require "screens/page_poster"
AddPlayerPostInit(function(player)
	player:AddComponent("rememberui")
	player.components.combat:AddDamageModifier("pigking", -5)
	TheInput:AddKeyDownHandler(KEY_R, function()
		if TheInput:IsKeyDown(KEY_CTRL) then
			local pig = SpawnPrefab("pigman")
			local pos = player:GetPosition()
			pig.Transform:SetPosition(pos:Get())
		end
	end)
	-- TheInput:AddKeyDownHandler(KEY_G, function()
	-- 	if TheInput:IsKeyDown(KEY_CTRL) then 
	-- 		TheFrontEnd:PushScreen(PagePoster())
	-- 	end
	-- end)
end)

AddPrefabPostInit("world", function(inst)
	inst:AddComponent("pigtechtree")
end)

AddPrefabPostInit("pigman", function(inst)
	local target_fn = inst.components.combat.targetfn
	inst.components.combat.targetfn = function(inst)
		if inst:HasTag("must_attack") then
			return FindEntity(inst, TUNING.PIG_TARGET_DIST,
				function(guy)
					if not (guy:HasTag("pig") 
					or guy:HasTag("player") 
					or (guy.components.follower 
					and guy.components.follower.leader == inst.components.follower.leader))
					or guy:HasTag("werepig") then
						return inst.components.combat:CanTarget(guy)
					end
				end)
		else
			return target_fn(inst)
		end
	end
end)

AddPrefabPostInit("wildbore", function(inst)
	local target_fn = inst.components.combat.targetfn
	inst.components.combat.targetfn = function(inst)
		if inst:HasTag("must_attack") then
			return FindEntity(inst, TUNING.PIG_TARGET_DIST,
				function(guy)
					if not (guy:HasTag("pig") 
					or guy:HasTag("player") 
					or (guy.components.follower 
					and guy.components.follower.leader == inst.components.follower.leader))
					or guy:HasTag("werepig") then
						return inst.components.combat:CanTarget(guy)
					end
				end)
		else
			return target_fn(inst)
		end
	end
end)

local pigs = {
	"pigman",
	"wildbore",
}
for k, v in pairs(pigs) do
	AddPrefabPostInit(v, function(inst)
		local set_were = inst.components.werebeast.SetWere
		inst.components.werebeast.SetWere = function(cmp, time)
		end
		inst:AddComponent("pigattr")
		inst:AddComponent("pigskill")
		inst:AddComponent("pigcontroller")
		local get_status = inst.components.inspectable.getstatus
		inst.components.inspectable.getstatus = function(inst)
			inst.components.pigcontroller:On()
			return get_status(inst)
		end
	end)
end

AddPrefabPostInit("pighouse", function(inst)
	inst.components.spawner:Configure( "pigman", TUNING.TOTAL_DAY_TIME*TUNING.PIGKING.day)
	local get_status = inst.components.inspectable.getstatus
	inst.components.inspectable.getstatus = function(inst)
		inst.components.spawner:ReleaseChild()
		return get_status(inst)
	end
end)

AddPrefabPostInit("wildborehouse", function(inst)
	inst.components.spawner:Configure( "wildbore", TUNING.TOTAL_DAY_TIME*TUNING.PIGKING.day)
end)

local homes = {
	"pighouse",
	"wildborehouse",
}
for k, v in pairs(homes) do
	AddPrefabPostInit(v, function(inst)
		local get_status = inst.components.inspectable.getstatus
		inst.components.inspectable.getstatus = function(inst)
			inst.components.spawner:ReleaseChild()
			if not inst:HasTag("burnt") then
		        inst.Light:Enable(false)
		        inst.AnimState:PlayAnimation("idle", true)
		        inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lightoff")
		        inst.lightson = false
		    end
			return get_status(inst)
		end
	end)
end
-- AddComponentPostInit()
-- local ImageButton = require "widgets/imagebutton"
-- local Text = require "widgets/text"
-- local PigTechTreeScreen = require "screens/pig_tech_tree_screen"
-- local DragImage = require "widgets/drag_image"
local PigKeyboard = require "widgets/pig_keyboard"
-- local UIAnim = require "widgets/uianim"
-- local Menu = require "widgets/menu"
-- local LongRect = require "widgets/long_rect"
AddClassPostConstruct("screens/playerhud", function(self)
	-- self.pigking_anchor = self:AddChild(DragImage(
	-- 	"images/inventoryimages.xml", "log.tex"
	-- ))
	self.pig_keyboard = self:AddChild(PigKeyboard())
	if GetPlayer().components.rememberui then
		local pos = GetPlayer().components.rememberui.pos
		self.pig_keyboard:SetPosition(pos)
	end
	
	-- self.chest = self:AddChild(DragImage(
	-- 	"images/inventoryimages.xml", "log.tex"
	-- ))
	-- local anim = self.chest:AddChild(UIAnim())
	-- anim:GetAnimState():SetBank("ui_chest_3x3")
	-- anim:GetAnimState():SetBuild("ui_chest_3x3")
	-- anim:GetAnimState():PlayAnimation("open")
	-- anim:SetPosition(0, -100, 0)

	-- self.icon = self:AddChild(DragImage(
	-- 	"images/inventoryimages.xml", "log.tex"
	-- ))
	-- self.icon:SetPosition(200, 300, 0)
	-- self.anim = self.icon:AddChild(UIAnim())
	-- self.anim:GetAnimState():SetBank("ui_chest_3x3")
	-- self.anim:GetAnimState():SetBuild("ui_chest_3x3")
	-- self.anim:GetAnimState():PlayAnimation("open")
	-- self.icon2 = self:AddChild(DragImage(
	-- 	"images/inventoryimages.xml", "log.tex"
	-- ))
	-- self.icon2:SetPosition(200, 320, 0)
	-- self.icon2.word:Show()
	-- self.icon2:SetScale(3.4, 3.4, 0)
	-- self.anim2 = self.icon2:AddChild(UIAnim())
	-- self.anim2:GetAnimState():SetBank("effigy_topper")
	-- self.anim2:GetAnimState():SetBuild("effigy_topper")
	-- -- self.anim2:GetAnimState():PlayAnimation("anim")
	-- self.anim2:GetAnimState():SetPercent("anim", 0)

	-- self.icon3 = self:AddChild(DragImage(
	-- 	"images/hud.xml", "craft_bg.tex"
	-- ))
	-- self.icon3:SetRotation(90)
	-- self.icon3.word:SetRotation(-90)
	-- self.icon3.word:Show()
	-- self.icon3:SetPosition(690, 630, 0)
	-- self.icon3.label = self.icon3:AddChild(Image(
	-- 	"images/hud.xml", "craft_bg.tex"
	-- ))
	-- self.icon3.label:SetRotation(180)
	-- self.icon3.label:SetPosition(-48, 0, 0)
	-- 690, 630
	-- self.icon4 = self:AddChild(DragImage(
	-- 	"images/hud.xml", "craft_bg.tex"
	-- ))
	-- self.icon4:SetRotation(270)
	-- self.icon4.word:SetRotation(-270)
	-- self.icon4.word:Show()
	-- self.icon4:SetPosition(690, 678, 0)
	-- 690, 678
	-- self.rect = self:AddChild(LongRect())
	-- self.rect:SetPosition(1300, 300, 0)

	self.data = {
		{"IconSize", 1, .1},
		{"ChestSizeX", 1, .1},
		{"ChestSizeY", 1, .1},
		{"ChestPosX", 320, 5},
		{"LongRectX", 0, 5},
		{"LongRectY", 0, 5},
	}
	local function test()
		local D = {}
		for k, v in pairs(self.data) do
			D[k] = v[2]
		end
		-- self.icon2:SetScale(D[1], D[1], 0)
		-- self.icon:SetScale(D[2], D[3], 0)
		-- self.anim2:SetPosition()
		self.rect.word:SetPosition(D[5], D[6], 0)
	end
	local function click(n)
		-- print(n)
		if TheInput:IsKeyDown(KEY_CTRL) then
			self.data[n][2] = self.data[n][2] - self.data[n][3]
		else
			self.data[n][2] = self.data[n][2] + self.data[n][3]
		end
		test()
	end
	local menuitems = {}
	for k, v in pairs(self.data) do
		menuitems[k] = {
			text = v[1],
			cb = function()
				click(k)
			end,
		}
	end
	table.insert(menuitems, {
		text = "OutPut",
		cb = function()
			for k, v in pairs(self.data) do
				print(v[1], v[2])
			end
		end,
	})
	-- self.menu = self:AddChild(Menu(menuitems, 50, false))
	-- self.menu:SetPosition(900, 600, 0)
end)