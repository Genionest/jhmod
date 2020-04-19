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
	self.page = 1
	self.pagemax = 2
	GetPlayer():ListenForEvent("OpenBuling_cuiqu",function()
		self:Open()
	end)
	GetPlayer():ListenForEvent("CloseBuling_cuiqu",function()
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
	--[[翻页
	
	self.jiantou1 = self.image:AddChild(ImageButton("images/bulingui/turnarrow_icon.xml", "turnarrow_icon.tex"))--上一页
	self.jiantou1:SetPosition(-120, -200, 0)
	self.jiantou1:SetOnClick(function()
		self.page = self.page - 1
		if self.page < 1 then self.page = 1 end
		self:flip()
	end)
	self.jiantou2 = self.image:AddChild(ImageButton("images/hud.xml", "turnarrow_icon.tex"))--下一页
	self.jiantou2:SetPosition(120, -200, 0)
	self.jiantou2:SetOnClick(function()
		self.page = self.page + 1
		if self.page > self.pagemax then self.page = self.pagemax end
		self:flip()
	end)]]
	self:flip()
end)
function buling_hechenglist:flip()
	self:CK()
	if self.page == 1 then
		self:page1()
	elseif self.page == 2 then
		self:page2()
	end
	--[[if self.page == 1 then
		self.jiantou1:Disable()
		else
		self.jiantou1:Enable()
	end
	if self.page == self.pagemax then
		self.jiantou2:Disable()
		else
		self.jiantou2:Enable()
	end]]
end
function buling_hechenglist:page1()
	--塞德玻璃
	self.item1 = self.image:AddChild(ImageButton("images/inventoryimages/buling_glass.xml", "buling_glass.tex"))
	self.item1:SetPosition(-120, 190, 0)
	self.item1:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_glass.xml", "buling_glass.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 50,STRINGS.NAMES.BULING_GLASS))
		self.text1:SetPosition(50, 100, 0)
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 25,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_GLASS))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/hud.xml", "turnarrow_icon.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_glass.xml", "buling_glass.tex"))
	end)
	--面粉
	self.item2 = self.image:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
	self.item2:SetPosition(-40, 190, 0)
	self.item2:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 50,STRINGS.NAMES.BULING_FLOUR))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_FLOUR))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_seed_wheat.xml", "buling_seed_wheat.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/hud.xml", "turnarrow_icon.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
	end)
	--种子
	self.item3 = self.image:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
	self.item3:SetPosition(40, 190, 0)
	self.item3:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages.xml", "seeds.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 50,STRINGS.NAMES.SEEDS))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 25,STRINGS.SEEDS_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao2 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "durian_seeds.tex"))
		self.cailiao3 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "dragonfruit_seeds.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "radish_seeds.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/hud.xml", "turnarrow_icon.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
	end)
	--岩石
	self.item4 = self.image:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
	self.item4:SetPosition(120, 190, 0)
	self.item4:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages.xml", "rocks.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.ROCKS))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.ROCK_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "flint.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/hud.xml", "turnarrow_icon.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
	end)
	--沙子
	self.item5 = self.image:AddChild(ImageButton("images/inventoryimages.xml", "sand.tex"))
	self.item5:SetPosition(-120, 110, 0)
	self.item5:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages.xml", "sand.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.SAND))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.ROCK_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/hud.xml", "turnarrow_icon.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "sand.tex"))
	end)
	--[[
	self.item6 = self.image:AddChild(ImageButton("images/inventoryimages/buling_hongguzhou.xml", "buling_hongguzhou.tex"))
	self.item6:SetPosition(-40, 110, 0)
	self.item6:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_hongguzhou.xml", "buling_hongguzhou.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_HONGGUZHOU))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_HONGGUZHOU))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "red_cap.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_xifan.xml", "buling_xifan.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_cook_guo.xml", "buling_cook_guo.tex"))
	end)

	self.item7 = self.image:AddChild(ImageButton("images/inventoryimages/buling_languzhou.xml", "buling_languzhou.tex"))
	self.item7:SetPosition(40, 110, 0)
	self.item7:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_languzhou.xml", "buling_languzhou.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_LANGUZHOU))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_LANGUZHOU))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "blue_cap.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_xifan.xml", "buling_xifan.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_cook_guo.xml", "buling_cook_guo.tex"))
	end)

	self.item8 = self.image:AddChild(ImageButton("images/inventoryimages/buling_lvguzhou.xml", "buling_lvguzhou.tex"))
	self.item8:SetPosition(120, 110, 0)
	self.item8:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_lvguzhou.xml", "buling_lvguzhou.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_LVGUZHOU))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_LVGUZHOU))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "green_cap.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_xifan.xml", "buling_xifan.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_cook_guo.xml", "buling_cook_guo.tex"))
	end)

	self.item9 = self.image:AddChild(ImageButton("images/inventoryimages/buling_sangubao.xml", "buling_sangubao.tex"))
	self.item9:SetPosition(-120, 30, 0)
	self.item9:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_sangubao.xml", "buling_sangubao.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_SANGUBAO))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 20,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_SANGUBAO))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "red_cap.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "green_cap.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "blue_cap.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_xifan.xml", "buling_xifan.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_cook_zheng.xml", "buling_cook_zheng.tex"))
	end)

	self.item10 = self.image:AddChild(ImageButton("images/inventoryimages/buling_aoliao.xml", "buling_aoliao.tex"))
	self.item10:SetPosition(-40, 30, 0)
	self.item10:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_aoliao.xml", "buling_aoliao.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_AOLIAO))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_AOLIAO))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "coffeebeans_cooked.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "coffeebeans_cooked.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_cook_kao.xml", "buling_cook_kao.tex"))
	end)

	self.item11 = self.image:AddChild(ImageButton("images/inventoryimages/buling_luobubao.xml", "buling_luobubao.tex"))
	self.item11:SetPosition(40, 30, 0)
	self.item11:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_luobubao.xml", "buling_luobubao.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_LUOBUBAO))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_LUOBUBAO))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "carrot.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "carrot.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "carrot.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_xifan.xml", "buling_xifan.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_cook_guo.xml", "buling_cook_guo.tex"))
	end)

	self.item12 = self.image:AddChild(ImageButton("images/inventoryimages/buling_jiangguomusi.xml", "buling_jiangguomusi.tex"))
	self.item12:SetPosition(120, 30, 0)
	self.item12:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_jiangguomusi.xml", "buling_jiangguomusi.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 45,STRINGS.NAMES.BULING_JIANGGUOMUSI))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_JIANGGUOMUSI))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "berries.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "coconut_cooked.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "coconut_cooked.tex"))
	end)

	self.item13 = self.image:AddChild(ImageButton("images/inventoryimages/buling_baojiangdangao.xml", "buling_baojiangdangao.tex"))
	self.item13:SetPosition(-120, -50, 0)
	self.item13:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_baojiangdangao.xml", "buling_baojiangdangao.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_BAOJIANGDANGAO))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_BAOJIANGDANGAO))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "berries_cooked.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_bread.xml", "buling_bread.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "honey.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_bread.xml", "buling_bread.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_cook_kao.xml", "buling_cook_kao.tex"))
	end)

	self.item14 = self.image:AddChild(ImageButton("images/inventoryimages/buling_bingkaxianbing.xml", "buling_bingkaxianbing.tex"))
	self.item14:SetPosition(-40, -50, 0)
	self.item14:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_bingkaxianbing.xml", "buling_bingkaxianbing.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_BINGKAXIANBING))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_BINGKAXIANBING))
		self.text2:SetPosition(80, -50, 0)
		
		
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "ratatouille.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_cook_kao.xml", "buling_cook_kao.tex"))
	end)

	self.item15 = self.image:AddChild(ImageButton("images/inventoryimages/buling_kaodigua.xml", "buling_kaodigua.tex"))
	self.item15:SetPosition(40, -50, 0)
	self.item15:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_kaodigua.xml", "buling_kaodigua.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_KAODIGUA))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 25,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_KAODIGUA))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "sweet_potato.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_cook_guo.xml", "buling_cook_guo.tex"))
	end)

	self.item16 = self.image:AddChild(ImageButton("images/inventoryimages/buling_kaolengmian.xml", "buling_kaolengmian.tex"))
	self.item16:SetPosition(120, -50, 0)
	self.item16:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_kaolengmian.xml", "buling_kaolengmian.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_KAOLENGMIAN))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_KAOLENGMIAN))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "bird_egg.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_cook_kao.xml", "buling_cook_kao.tex"))
	end)

	self.item17 = self.image:AddChild(ImageButton("images/inventoryimages/buling_sanmingzhi.xml", "buling_sanmingzhi.tex"))
	self.item17:SetPosition(-120, -130, 0)
	self.item17:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_sanmingzhi.xml", "buling_sanmingzhi.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_SANMINGZHI))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 25,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_SANMINGZHI))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages/buling_bread.xml", "buling_bread.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "cactus_meat.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "flowersalad.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "cactus_meat.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_bread.xml", "buling_bread.tex"))
	end)

	self.item18 = self.image:AddChild(ImageButton("images/inventoryimages/buling_jianbingguozi.xml", "buling_jianbingguozi.tex"))
	self.item18:SetPosition(-40, -130, 0)
	self.item18:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_jianbingguozi.xml", "buling_jianbingguozi.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_JIANBINGGUOZI))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_JIANBINGGUOZI))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "bird_egg.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "plantmeat.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "bird_egg.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_cook_kao.xml", "buling_cook_kao.tex"))
	end)

	self.item19 = self.image:AddChild(ImageButton("images/inventoryimages/buling_qiancengbing.xml", "buling_qiancengbing.tex"))
	self.item19:SetPosition(40, -130, 0)
	self.item19:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_qiancengbing.xml", "buling_qiancengbing.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_QIANCENGBING))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 25,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_QIANCENGBING))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "plantmeat.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "honey.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "plantmeat.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_cook_kao.xml", "buling_cook_kao.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
	end)

	self.item20 = self.image:AddChild(ImageButton("images/inventoryimages/buling_xiangcaobuding.xml", "buling_xiangcaobuding.tex"))
	self.item20:SetPosition(120, -130, 0)
	self.item20:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_xiangcaobuding.xml", "buling_xiangcaobuding.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_XIANGCAOBUDING))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 25,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_XIANGCAOBUDING))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "tallbirdegg.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "petals.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "goatmilk.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "honey.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages/buling_flour.xml", "buling_flour.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages/buling_cook_zheng.xml", "buling_cook_zheng.tex"))
	end)]]
end
function buling_hechenglist:Close()
	--if self.openui == true then
		self.openui = false
		self:Hide()
	--end
end
function buling_hechenglist:Open()
	--if self.openui == false then
		print("不灵打开ui")
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
function buling_hechenglist:CK()
	if self.item1 then self.item1:Kill() end
	if self.item2 then self.item2:Kill() end
	if self.item3 then self.item3:Kill() end
	if self.item4 then self.item4:Kill() end
	if self.item5 then self.item5:Kill() end
	if self.item6 then self.item6:Kill() end
	if self.item7 then self.item7:Kill() end
	if self.item8 then self.item8:Kill() end
	if self.item9 then self.item9:Kill() end
	if self.item10 then self.item10:Kill() end
	if self.item11 then self.item11:Kill() end
	if self.item12 then self.item12:Kill() end
	if self.item13 then self.item13:Kill() end
	if self.item14 then self.item14:Kill() end
	if self.item15 then self.item15:Kill() end
	if self.item16 then self.item16:Kill() end
	if self.item17 then self.item17:Kill() end
	if self.item18 then self.item18:Kill() end
	if self.item19 then self.item19:Kill() end
	if self.item20 then self.item20:Kill() end

end
return buling_hechenglist