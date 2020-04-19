local Widget = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text" 
local TextButton = require "widgets/textbutton" 
local UIAnim = require "widgets/uianim"
require "util"


buling_hechenglist = Class(Widget, function(self,owner)
	Widget._ctor(self, "yanjiu")
    self.owner = owner
	self.cailiaobuzu = 0
	self.IsUIShow =false
    SetPause(true,"pause")
    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	GetPlayer():ListenForEvent("OpenBuling_manual",function()
		self:Open()
	end)
	GetPlayer():ListenForEvent("CloseBuling_manual",function()
		self:Close()
	end)
	--背景
	self.image = self:AddChild(Image("images/globalpanels.xml", "panel_skinny.tex"))
	--self.image:SetPosition(650, 365, 0)
	self.image:SetPosition(-350, 0, 0)
	self.image2 = self:AddChild(Image("images/globalpanels.xml", "presetbox.tex"))
	self.image2:SetPosition(350, 0, 0)
	--格子
	self.gezi5 = self.image2:AddChild(Image("images/hud.xml", "inv_slot.tex"))
	self.gezi5:SetPosition(-100, -65, 0)
	self.gezi5:SetScale(0.7, 0.7, 0)
	
	self.gezi1 = self.gezi5:AddChild(Image("images/hud.xml", "inv_slot.tex"))
	self.gezi1:SetPosition(-70, 70, 0)
	--self.gezi1:SetScale(0.7, 0.7, 0)
	
	self.gezi2 = self.gezi5:AddChild(Image("images/hud.xml", "inv_slot.tex"))
	self.gezi2:SetPosition(0, 70, 0)
	--self.gezi2:SetScale(0.7, 0.7, 0)
	
	self.gezi3 = self.gezi5:AddChild(Image("images/hud.xml", "inv_slot.tex"))
	self.gezi3:SetPosition(70, 70, 0)
	--self.gezi3:SetScale(0.7, 0.7, 0)
	
	self.gezi4 = self.gezi5:AddChild(Image("images/hud.xml", "inv_slot.tex"))
	self.gezi4:SetPosition(-70, 0, 0)
	--self.gezi4:SetScale(0.7, 0.7, 0)
	
	self.gezi6 = self.gezi5:AddChild(Image("images/hud.xml", "inv_slot.tex"))
	self.gezi6:SetPosition(70, 0, 0)
	--self.gezi6:SetScale(0.7, 0.7, 0)
	
	self.gezi7 = self.gezi5:AddChild(Image("images/hud.xml", "inv_slot.tex"))
	self.gezi7:SetPosition(-70, -70, 0)
	--self.gezi7:SetScale(0.7, 0.7, 0)
	
	self.gezi8 = self.gezi5:AddChild(Image("images/hud.xml", "inv_slot.tex"))
	self.gezi8:SetPosition(0, -70, 0)
	--self.gezi8:SetScale(0.7, 0.7, 0)
	
	self.gezi9 = self.gezi5:AddChild(Image("images/hud.xml", "inv_slot.tex"))
	self.gezi9:SetPosition(70, -70, 0)
	--self.gezi9:SetScale(0.7, 0.7, 0)
	--关闭
	self.closebutton = self:AddChild(ImageButton())
	--self.closebutton:SetText(STRINGS.DAIMIAO_CLOSE)
	self.closebutton:SetPosition(860, 150, 0)
	self.closebutton:SetOnClick(
	function ()
		self:Close()
	end)
	--图标
	--塞德锭
	self.buling_zhongziding = self.image:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	self.buling_zhongziding:SetPosition(-120, 190, 0)
	self.buling_zhongziding:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_ZHONGZIDING))
		self.text1:SetPosition(50, 100, 0)
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_ZHONGZIDING_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "goldnugget.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
	end)
	--植物改良桌
	self.buling_planttable = self.image:AddChild(ImageButton("images/inventoryimages/buling_planttable.xml", "buling_planttable.tex"))
	self.buling_planttable:SetPosition(-40, 190, 0)
	self.buling_planttable:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_planttable.xml", "buling_planttable.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_PLANTTABLE_ITEM))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_PLANTTABLE_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "boards.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "boards.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
	--不灵萃取机
	self.buling_ronglu = self.image:AddChild(ImageButton("images/inventoryimages/buling_ronglu.xml", "buling_ronglu.tex"))
	self.buling_ronglu:SetPosition(40, 190, 0)
	self.buling_ronglu:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_ronglu.xml", "buling_ronglu.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_RONGLU_ITEM))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_RONGLU_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "cutstone.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "cutstone.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "cutstone.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "cutstone.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages_2.xml", "transistor.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "cutstone.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
	--电力中继器
	self.buling_zhongjiqi = self.image:AddChild(ImageButton("images/inventoryimages/buling_zhongjiqi.xml", "buling_zhongjiqi.tex"))
	self.buling_zhongjiqi:SetPosition(120, 190, 0)
	self.buling_zhongjiqi:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_zhongjiqi.xml", "buling_zhongjiqi.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_ZHONGJIQI))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 20,STRINGS.BULING_ZHONGJIQI_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages_2.xml", "transistor.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages_2.xml", "transistor.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
	--生存发电机
	self.buling_shengcun = self.image:AddChild(ImageButton("images/inventoryimages/buling_shengcun.xml", "buling_shengcun.tex"))
	self.buling_shengcun:SetPosition(-120, 110, 0)
	self.buling_shengcun:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_shengcun.xml", "buling_shengcun.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_SHENGCUN))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 20,STRINGS.BULING_SHENGCUN_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages/buling_ronglu.xml", "buling_ronglu.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_zhongjiqi.xml", "buling_zhongjiqi.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
	--不灵炮塔
	self.buling_paotai = self.image:AddChild(ImageButton("images/inventoryimages/buling_paotai.xml", "buling_paotai.tex"))
	self.buling_paotai:SetPosition(-40, 110, 0)
	self.buling_paotai:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_paotai.xml", "buling_paotai.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_PAOTAI_ITEM))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_PAOTAI_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "gears.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "log.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages.xml", "log.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
	--不灵雷达
	self.leida = self.image:AddChild(ImageButton("images/inventoryimages/buling_leida.xml", "buling_leida.tex"))
	self.leida:SetPosition(40, 110, 0)
	self.leida:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_leida.xml", "buling_leida.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_RADAR_ITEMFN))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 20,STRINGS.BULING_RADAR_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "compass.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_zhongjiqi.xml", "buling_zhongjiqi.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
	--不灵采集者
	self.caijizhe = self.image:AddChild(ImageButton("images/inventoryimages/buling_shouge.xml", "buling_shouge.tex"))
	self.caijizhe:SetPosition(120, 110, 0)
	self.caijizhe:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_shouge.xml", "buling_shouge.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_CROPBOX_ITEM))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 20,STRINGS.BULING_CROPBOX_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "goldenshovel.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "gears.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "goldenshovel.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_zhongjiqi.xml", "buling_zhongjiqi.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
	--不灵电灯
	self.diandeng = self.image:AddChild(ImageButton("images/inventoryimages/buling_diandeng.xml", "buling_diandeng.tex"))
	self.diandeng:SetPosition(-120, 30, 0)
	self.diandeng:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_diandeng.xml", "buling_diandeng.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_DIANDENG))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_DIANDENG_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages/buling_glass.xml", "buling_glass.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "torch.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
	--人力发电机
	self.gailiang = self.image:AddChild(ImageButton("images/inventoryimages/buling_huosai.xml", "buling_huosai.tex"))
	self.gailiang:SetPosition(-40, 30, 0)
	self.gailiang:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_huosai.xml", "buling_huosai.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_HUOSAI))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_HUOSAI))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "cutstone.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "gears.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "cutstone.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages.xml", "cutstone.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages.xml", "cutstone.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages.xml", "cutstone.tex"))
	end)
	--作物管家
	self.peiyu = self.image:AddChild(ImageButton("images/inventoryimages/buling_seedbox.xml", "buling_seedbox.tex"))
	self.peiyu:SetPosition(40, 30, 0)
	self.peiyu:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_seedbox.xml", "buling_seedbox.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_SEEDBOX_ITEM))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 20,STRINGS.BULING_SEEDBOX_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages/buling_glass.xml", "buling_glass.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages/buling_glass.xml", "buling_glass.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "fertilizer.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
	--太阳能发电机
	self.tiezha = self.image:AddChild(ImageButton("images/inventoryimages/buling_taiyangneng.xml", "buling_taiyangneng.tex"))
	self.tiezha:SetPosition(120, 30, 0)
	self.tiezha:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_taiyangneng.xml", "buling_taiyangneng.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 45,STRINGS.NAMES.BULING_SOLARENERGY))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_SOLARENERGY_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages/buling_glass.xml", "buling_glass.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages/buling_glass.xml", "buling_glass.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages/buling_glass.xml", "buling_glass.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_zhongjiqi.xml", "buling_zhongjiqi.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
	--电动镐
	self.pickaxe = self.image:AddChild(ImageButton("images/inventoryimages/buling_diandonggao.xml", "buling_diandonggao.tex"))
	self.pickaxe:SetPosition(-120, -50, 0)
	self.pickaxe:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_diandonggao.xml", "buling_diandonggao.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_DIANDONGGAO))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_TOOL_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages/buling_zhongjiqi.xml", "buling_zhongjiqi.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages_2.xml", "twigs.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages_2.xml", "twigs.tex"))
	end)
	--电力斧
	self.axe = self.image:AddChild(ImageButton("images/inventoryimages/buling_dianlifu.xml", "buling_dianlifu.tex"))
	self.axe:SetPosition(-40, -50, 0)
	self.axe:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_dianlifu.xml", "buling_dianlifu.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_DIANLIFU))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_TOOL_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
		
		
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages/buling_zhongjiqi.xml", "buling_zhongjiqi.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages_2.xml", "twigs.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages_2.xml", "twigs.tex"))
	end)
	--电动剪
	self.jiandao = self.image:AddChild(ImageButton("images/inventoryimages/buling_diandongjian.xml", "buling_diandongjian.tex"))
	self.jiandao:SetPosition(40, -50, 0)
	self.jiandao:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_diandongjian.xml", "buling_diandongjian.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_JIANDAO))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_TOOL_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_zhongjiqi.xml", "buling_zhongjiqi.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages_2.xml", "twigs.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages_2.xml", "twigs.tex"))
	end)
	--充电机
	self.tieding = self.image:AddChild(ImageButton("images/inventoryimages/buling_chongdian.xml", "buling_chongdian.tex"))
	self.tieding:SetPosition(120, -50, 0)
	self.tieding:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_chongdian.xml", "buling_chongdian.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_CHONGDIANQI))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_CHONGDIANQI_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages/buling_zhongjiqi.xml", "buling_zhongjiqi.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
	--齿轮
	self.yaogao = self.image:AddChild(ImageButton("images/inventoryimages.xml", "gears.tex"))
	self.yaogao:SetPosition(-120, -130, 0)
	self.yaogao:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages.xml", "gears.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.GEARS))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 20,STRINGS.GEARS_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
	--扳手
	self.fengla = self.image:AddChild(ImageButton("images/inventoryimages/buling_banshou.xml", "buling_banshou.tex"))
	self.fengla:SetPosition(-40, -130, 0)
	self.fengla:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_banshou.xml", "buling_banshou.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_BANSHOU))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_BANSHOU_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages_2.xml", "twigs.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages_2.xml", "twigs.tex"))
	end)
	--合金箱
	self.buling_chest = self.image:AddChild(ImageButton("images/inventoryimages/buling_chest.xml", "buling_chest.tex"))
	self.buling_chest:SetPosition(40, -130, 0)
	self.buling_chest:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_chest.xml", "buling_chest.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_CHEST))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_CHEST_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
	--料理台
	self.buling_cooktable = self.image:AddChild(ImageButton("images/inventoryimages/buling_cooktable.xml", "buling_cooktable.tex"))
	self.buling_cooktable:SetPosition(120, -130, 0)
	self.buling_cooktable:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_cooktable.xml", "buling_cooktable.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_COOKTABLE))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_COOKTABLE))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	end)
end)
function buling_hechenglist:Close()
	--if self.openui == true then
		self.openui = false
		self:Hide()
	--end
end
function buling_hechenglist:Open()
	--if self.openui == false then
		self.openui = true
		self:Show()
	--end
end

function buling_hechenglist:QK()
	if self.tubiao then self.tubiao:Kill() end
	if self.text1 then self.text1:Kill() end
	if self.text2 then self.text2:Kill() end
	if self.cailiao1 then self.cailiao1:Kill() end
	if self.cailiao2 then self.cailiao2:Kill() end
	if self.cailiao3 then self.cailiao3:Kill() end
	if self.cailiao4 then self.cailiao4:Kill() end
	if self.cailiao5 then self.cailiao5:Kill() end
	if self.cailiao6 then self.cailiao6:Kill() end
	if self.cailiao7 then self.cailiao7:Kill() end
	if self.cailiao8 then self.cailiao8:Kill() end
	if self.cailiao9 then self.cailiao9:Kill() end
end
return buling_hechenglist