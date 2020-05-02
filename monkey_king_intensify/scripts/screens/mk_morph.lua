local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"

local function fxNmorph(inst, body)
	-- 先生成分身施法，再变身
	inst.components.mkskillfx:CloneFx(body)
	-- local pos = inst:GetPosition()
	-- SpawnPrefab("statue_transition").Transform:SetPosition(pos:Get())
	-- SpawnPrefab("statue_transition_2").Transform:SetPosition(pos:Get())
	-- local dx = 3 + math.random()
	-- local dz = 3 + math.random()
	-- if math.random() < .5 then dx = -dx end
	-- if math.random() < .5 then dz = -dz end
	-- SpawnPrefab("collapse_small").Transform:SetPosition(pos.x+dx, pos.y, pos.z+dx)
	-- local fx = SpawnPrefab("mk_morph_fx")
	-- fx.Transform:SetPosition(pos.x+dx, pos.y, pos.z+dx)
	-- fx.morph_body = body
end

local function AddMorph(inst, body)
	if body ~= inst.components.morph:GetCurrent()
	and inst.components.morph:CanMorph() then
	-- and inst.components.driver
	-- and not inst.components.driver:GetIsDriving()
	-- and inst.components.rider
	-- and not inst.components.rider:IsRiding()
	-- and not inst:HasTag("notarget")
	-- and not inst:HasTag("ironlord") then
		-- inst.components.morph:Morph(body)
		fxNmorph(inst, body)
	end
	inst.components.mkskillmanager:Turn(true)
end

local function OriginalMorph(inst)
	if inst.components.morph:GetCurrent() ~= "monkey"
	and inst.components.morph:CanMorph() then
		-- inst.components.morph:UnMorph() 
		fxNmorph(inst, "monkey")
	end
	inst.components.mkskillmanager:Turn(true)
end

-- local img_atlas = "images/inventoryiamges.xml"
-- local img_atlas2 = "images/inventoryiamges_2.xml"
local function MakeButton(atlas)
	return ImageButton("images/buttons/btn_"..atlas..".xml",
		"btn_"..atlas..".tex")
end

local function SetButton(self, body, title, pos, master)
	self:SetOnClick(function() 
		AddMorph(GetPlayer(), body)
		TheFrontEnd:PopScreen(master) 
	end)
	self:SetPosition(pos[1], pos[2], 0)
	self:SetScale(1.5, 1.5, 1.5)
	-- self.txt = self:AddChild(Text(BUTTONFONT, 40))
	-- self.txt:SetString(title)
	-- self.txt:SetVAlign(ANCHOR_MIDDLE)
	-- self.txt:SetColour(0,0,0,1)
end

local function GetPos(x, y)
	-- -150, 130
	x = x + 100
	if x > 300-150 then
		x = -150
		y = y - 100
	end
	return x, y
end

local mk_morph = Class(Screen, function(self)
	Screen._ctor(self, "mk_morph")
	self.root = self:AddChild(Widget("ROOT"))
	self.root:SetVAnchor(ANCHOR_TOP)  -- 垂直坐标锚点设置
	self.root:SetHAnchor(ANCHOR_MIDDLE)  -- 水平坐标锚点设置
	self.root:SetPosition(50, -200, 0)  -- 坐标锚点偏移设置
	-- self.root:SetPosition(0, -300, 0)
	-- self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)  -- 设置缩放模式
	self.root:SetScale(.5, .5, .5)
	self.bg = self.root:AddChild(  -- 背景图片
		Image("images/fepanels.xml", "panel_saveslots.tex")
	)
	self.bg:SetScale(1.2, 1.2, 1)

--	-160,0		0,0			160,0
--	-160,-80	-160,-80	160,-80
	local x, y = -150, 150
	-- title
	self.title = self.root:AddChild(
		Text(TITLEFONT, 60)
	)
	self.title:SetPosition(0, y+100, 0)
	self.title:SetRegionSize(500, 500)
	self.title:SetString("七十二变")
	self.title:SetVAlign(ANCHOR_MIDDLE)
	self.btn0 = self.root:AddChild(MakeButton("close"))
	self.btn0:SetOnClick(function() 
		TheFrontEnd:PopScreen(self) 
		GetPlayer().components.mkskillmanager:Turn(true)
	end)
	self.btn0:SetPosition(x+300, y+90, 0)
	self.btn0:SetScale(1, 1, 1)
	-- self.btn0:SetScale(.8,.8,.8)
	-- self.txt0 = self.btn0:AddChild(Text(BUTTONFONT, 40))
	-- self.txt0:SetString("关闭")
	-- self.txt0:SetVAlign(ANCHOR_MIDDLE)
	-- self.txt0:SetColour(0,0,0,1)
	-- self.btn1 = self.root:AddChild(ImageButton(
	-- 	"images/buttons/btn_bees.xml",
	-- 	"btn_bees.tex"
	-- ))
	self.btn1 = self.root:AddChild(MakeButton("bees"))
	-- self.btn1:SetScale(2, 2, 2)
	SetButton(self.btn1, "bees", "蜜蜂", {x, y}, self)
	-- SetButton(self.btn1, "bees", "蜜蜂", {x, y}, self)
	x, y = GetPos(x, y)

	-- self.btn1:SetOnClick(function() 
	-- 	AddMorph(GetPlayer(), "bees")
	-- 	TheFrontEnd:PopScreen(self) 
	-- end)
	-- self.btn1:SetPosition(-160, 0, 0)
	-- self.txt1 = self.btn1:AddChild(Text(BUTTONFONT, 40))
	-- self.txt1:SetString("蜜蜂")
	-- self.txt1:SetVAlign(ANCHOR_MIDDLE)
	-- self.txt1:SetColour(0,0,0,1)

	-- self.btn2 = self.root:AddChild(ImageButton())
	self.btn2 = self.root:AddChild(MakeButton("pig"))
	SetButton(self.btn2, "pig", "猪人", {x, y}, self)
	x, y = GetPos(x, y)

	-- self.btn2:SetOnClick(function() 
	-- 	AddMorph(GetPlayer(), "pigman")
	-- 	TheFrontEnd:PopScreen(self)
	-- end)
	-- self.btn2:SetPosition(0,0,0)
	-- self.txt2 = self.btn2:AddChild(Text(BUTTONFONT, 40))
	-- self.txt2:SetString("猪人")
	-- self.txt2:SetVAlign(ANCHOR_MIDDLE)
	-- self.txt2:SetColour(0,0,0,1)

	-- self.btn3 = self.root:AddChild(ImageButton())
	self.btn3 = self.root:AddChild(MakeButton("merm"))
	SetButton(self.btn3, "merm", "鱼人", {x, y}, self)
	x, y = GetPos(x, y)

	-- self.btn3:SetOnClick(function() 
	-- 	AddMorph(GetPlayer(), "merm") 
	-- 	TheFrontEnd:PopScreen(self)
	-- end)
	-- self.btn3:SetPosition(160, 0, 0)
	-- self.txt3 = self.btn3:AddChild(Text(BUTTONFONT, 40))
	-- self.txt3:SetString("鱼人")
	-- self.txt3:SetVAlign(ANCHOR_MIDDLE)
	-- self.txt3:SetColour(0,0,0,1)

	self.btn4 = self.root:AddChild(MakeButton("hound"))
	SetButton(self.btn4, "hound", "猎犬", {x, y}, self)
	x, y = GetPos(x, y)

	-- self.btn4:SetOnClick(function() 
	-- 	AddMorph(GetPlayer(), "hound") 
	-- 	TheFrontEnd:PopScreen(self)
	-- end)
	-- self.btn4:SetPosition(-160, -80, 0)
	-- self.txt4 = self.btn4:AddChild(Text(BUTTONFONT, 40))
	-- self.txt4:SetString("猎犬")
	-- self.txt4:SetVAlign(ANCHOR_MIDDLE)
	-- self.txt4:SetColour(0,0,0,1)

	self.btn5 = self.root:AddChild(MakeButton("spider"))
	SetButton(self.btn5, "spider", "蜘蛛", {x, y}, self)
	x, y = GetPos(x, y)

	-- self.btn5:SetOnClick(function() 
	-- 	AddMorph(GetPlayer(), "spider") 
	-- 	TheFrontEnd:PopScreen(self)
	-- end)
	-- self.btn5:SetPosition(0, -80, 0)
	-- self.txt5 = self.btn5:AddChild(Text(BUTTONFONT, 40))
	-- self.txt5:SetString("蜘蛛")
	-- self.txt5:SetVAlign(ANCHOR_MIDDLE)
	-- self.txt5:SetColour(0,0,0,1)

	self.btn6 = self.root:AddChild(MakeButton("beefalo"))
	SetButton(self.btn6, "beefalo", "牛牛", {x, y}, self)
	x, y = GetPos(x, y)

	-- self.btn6:SetOnClick(function() 
	-- 	AddMorph(GetPlayer(), "beefalo")
	-- 	TheFrontEnd:PopScreen(self)
	-- end)
	-- self.btn6:SetPosition(160, -80, 0)
	-- self.txt6 = self.btn6:AddChild(Text(BUTTONFONT, 40))
	-- self.txt6:SetString("牛牛")
	-- self.txt6:SetVAlign(ANCHOR_MIDDLE)
	-- self.txt6:SetColour(0,0,0,1)

	self.btn7 = self.root:AddChild(MakeButton("tallbird"))
	SetButton(self.btn7, "tallbird", "高鸟", {x, y}, self)
	x, y = GetPos(x, y)

	-- self.btn7:SetOnClick(function() 
	-- 	AddMorph(GetPlayer(), "tallbird")
	-- 	TheFrontEnd:PopScreen(self)
	-- end)
	-- self.btn7:SetPosition(-160, -160, 0)
	-- self.txt7 = self.btn7:AddChild(Text(BUTTONFONT, 40))
	-- self.txt7:SetString("高鸟")
	-- self.txt7:SetVAlign(ANCHOR_MIDDLE)
	-- self.txt7:SetColour(0,0,0,1)

	self.btn8 = self.root:AddChild(MakeButton("rabbit"))
	SetButton(self.btn8, "rabbit", "兔子", {x, y}, self)
	x, y = GetPos(x, y)

	self.btn9 = self.root:AddChild(MakeButton("butterfly"))
	SetButton(self.btn9, "butterfly", "蝴蝶", {x, y}, self)
	x, y = GetPos(x, y)

	self.btn10 = self.root:AddChild(MakeButton("frog"))
	SetButton(self.btn10, "frog", "青蛙", {x, y}, self)
	x, y = GetPos(x, y)

	self.btn11 = self.root:AddChild(MakeButton("perd"))
	SetButton(self.btn11, "perd", "火鸡", {x, y}, self)
	x, y = GetPos(x, y)

	self.btn12 = self.root:AddChild(MakeButton("goat"))
	SetButton(self.btn12, "goat", "电羊", {x, y}, self)
	x, y = GetPos(x, y)

	self.btn13 = self.root:AddChild(MakeButton("walrus"))
	SetButton(self.btn13, "walrus", "海象", {x, y}, self)
	x, y = GetPos(x, y)

	self.btn14 = self.root:AddChild(MakeButton("penguin"))
	SetButton(self.btn14, "penguin", "企鹅", {x, y}, self)
	x, y = GetPos(x, y)

	self.btn15 = self.root:AddChild(MakeButton("koalefant"))
	SetButton(self.btn15, "koalefant", "大象", {x, y}, self)
	x, y = GetPos(x, y)

	self.btn16 = self.root:AddChild(MakeButton("catcoon"))
	SetButton(self.btn16, "catcoon", "浣熊", {x, y}, self)
	x, y = GetPos(x, y)

	self.btn111 = self.root:AddChild(MakeButton("monkey"))
	self.btn111:SetOnClick(function() 
		-- AddMorph(GetPlayer(), "")
		OriginalMorph(GetPlayer()) 
		TheFrontEnd:PopScreen(self)
	end)
	-- self.btn111:SetPosition(0, -160, 0)
	self.btn111:SetPosition(x, y, 0)
	self.btn111:SetScale(1.5, 1.5, 1.5)
	-- self.btn111.txt = self.btn111:AddChild(Text(BUTTONFONT, 40))
	-- self.btn111.txt:SetString("还原")
	-- self.btn111.txt:SetVAlign(ANCHOR_MIDDLE)
	-- self.btn111.txt:SetColour(0,0,0,1)

end)

return mk_morph