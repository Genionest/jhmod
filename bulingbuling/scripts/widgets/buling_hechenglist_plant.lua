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


buling_hechenglist_plant = Class(Widget, function(self,owner)
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
	GetPlayer():ListenForEvent("OpenBuling_planttable",function()
		self:Open()
	end)
	GetPlayer():ListenForEvent("CloseBuling_planttable",function()
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
	self.buling_seed_zhongziding = self.image:AddChild(ImageButton("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
	self.buling_seed_zhongziding:SetPosition(-120, 190, 0)
	self.buling_seed_zhongziding:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_zhongziding.xml", "buling_zhongziding.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_ZHONGZIDING))
		self.text1:SetPosition(50, 100, 0)
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_ZHONGZIDING_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
		
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "goldnugget.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
	end)
	--燧石种子
	self.buling_seed_flint = self.image:AddChild(ImageButton("images/inventoryimages/buling_seed_flint.xml", "buling_seed_flint.tex"))
	self.buling_seed_flint:SetPosition(-40, 190, 0)
	self.buling_seed_flint:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_seed_flint.xml", "buling_seed_flint.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_SEED_FLINT))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_SEED_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "flint.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "flint.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "flint.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "flint.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "flint.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages.xml", "flint.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages.xml", "flint.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages.xml", "flint.tex"))
	end)
	--硝石种子
	self.buling_seed_nitre = self.image:AddChild(ImageButton("images/inventoryimages/buling_seed_nitre.xml", "buling_seed_nitre.tex"))
	self.buling_seed_nitre:SetPosition(40, 190, 0)
	self.buling_seed_nitre:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_seed_nitre.xml", "buling_seed_nitre.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_SEED_NITRE))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_SEED_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "nitre.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "nitre.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "nitre.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "nitre.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "nitre.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages.xml", "nitre.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages.xml", "nitre.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages.xml", "nitre.tex"))
	end)
	--岩石种子
	self.buling_seed_rock = self.image:AddChild(ImageButton("images/inventoryimages/buling_seed_rock.xml", "buling_seed_rock.tex"))
	self.buling_seed_rock:SetPosition(120, 190, 0)
	self.buling_seed_rock:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_seed_rock.xml", "buling_seed_rock.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_SEED_ROCK))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_SEED_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
	end)
	--黄金种子
	self.buling_seed_gold = self.image:AddChild(ImageButton("images/inventoryimages/buling_seed_gold.xml", "buling_seed_gold.tex"))
	self.buling_seed_gold:SetPosition(-120, 110, 0)
	self.buling_seed_gold:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_seed_gold.xml", "buling_seed_gold.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_SEED_GOLD))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_SEED_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "goldnugget.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "goldnugget.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "goldnugget.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "goldnugget.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "goldnugget.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages.xml", "goldnugget.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages.xml", "goldnugget.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages.xml", "goldnugget.tex"))
	end)
	--大理石种子
	self.buling_seed_marble = self.image:AddChild(ImageButton("images/inventoryimages/buling_seed_marble.xml", "buling_seed_marble.tex"))
	self.buling_seed_marble:SetPosition(-40, 110, 0)
	self.buling_seed_marble:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_seed_marble.xml", "buling_seed_marble.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_SEED_MARBLE))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_SEED_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "sand.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "sand.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages.xml", "sand.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages.xml", "rocks.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages.xml", "sand.tex"))
	end)
	--十胜石种子
	self.buling_seed_obsidian = self.image:AddChild(ImageButton("images/inventoryimages/buling_seed_obsidian.xml", "buling_seed_obsidian.tex"))
	self.buling_seed_obsidian:SetPosition(40, 110, 0)
	self.buling_seed_obsidian:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_seed_obsidian.xml", "buling_seed_obsidian.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_SEED_OBSIDIAN))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.BULING_SEED_SHUOMING))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "gunpowder.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "redgem.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "gunpowder.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "ash.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "ash.tex"))
		self.cailiao7 = self.gezi7:AddChild(ImageButton("images/inventoryimages.xml", "gunpowder.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages.xml", "ash.tex"))
		self.cailiao9 = self.gezi9:AddChild(ImageButton("images/inventoryimages.xml", "gunpowder.tex"))
	end)
	--小麦种子
	self.buling_seed_wheat = self.image:AddChild(ImageButton("images/inventoryimages/buling_seed_wheat.xml", "buling_seed_wheat.tex"))
	self.buling_seed_wheat:SetPosition(120, 110, 0)
	self.buling_seed_wheat:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_seed_wheat.xml", "buling_seed_wheat.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_SEED_WHEAT))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_SEED_WHEAT))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao1 = self.gezi1:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao3 = self.gezi3:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "seeds.tex"))
	end)
	--肥料
	self.buling_seed_wheat = self.image:AddChild(ImageButton("images/inventoryimages/buling_manure.xml", "buling_manure.tex"))
	self.buling_seed_wheat:SetPosition(-120, 30, 0)
	self.buling_seed_wheat:SetOnClick(
	function ()
		self:QK()
		self.tubiao = self.image2:AddChild(Image("images/inventoryimages/buling_manure.xml", "buling_manure.tex"))
		self.tubiao:SetPosition(-100, 100, 0)
		
		self.text1 = self.image2:AddChild(Text(BODYTEXTFONT, 60,STRINGS.NAMES.BULING_MANURE))
		self.text1:SetPosition(50, 100, 0)
		
		self.text2 = self.image2:AddChild(Text(BODYTEXTFONT, 30,STRINGS.CHARACTERS.GENERIC.DESCRIBE.BULING_MANURE))
		self.text2:SetPosition(80, -50, 0)
			
		self.cailiao2 = self.gezi2:AddChild(ImageButton("images/inventoryimages.xml", "ash.tex"))
		self.cailiao4 = self.gezi4:AddChild(ImageButton("images/inventoryimages.xml", "ash.tex"))
		self.cailiao5 = self.gezi5:AddChild(ImageButton("images/inventoryimages.xml", "nitre.tex"))
		self.cailiao6 = self.gezi6:AddChild(ImageButton("images/inventoryimages.xml", "ash.tex"))
		self.cailiao8 = self.gezi8:AddChild(ImageButton("images/inventoryimages.xml", "ash.tex"))
	end)
end)
function buling_hechenglist_plant:Close()
	self.openui = false
	self:Hide()
end
function buling_hechenglist_plant:Open()
	self.openui = true
	self:Show()
end

function buling_hechenglist_plant:QK()
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
return buling_hechenglist_plant