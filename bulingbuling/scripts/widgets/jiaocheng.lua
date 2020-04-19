local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text" 
local TextButton = require "widgets/textbutton" 
jiaodaodengji = 1
local jiaodao 
require "util"
local zxml = "images/ui/mand.xml"
local ztex = "mand.tex"
jiaocheng = Class(Widget, function(self)
	Widget._ctor(self, "jiaocheng ")

	self.IsUIShow =false
    SetPause(true,"pause")
    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.banhua = {}
	self.miaomiaomiao = true
	self.image = self:AddChild(Image(zxml,ztex ))
	self.image:SetPosition(-290, 20, 0)
	self.image2 = self:AddChild(Image("images/ui/messageback.xml", "messageback.tex"))
	self.image2:SetPosition(0, -160, 0)
	self.text = self:AddChild(Text(BODYTEXTFONT, 30,"曼德拉族长"))
	self.text:SetPosition(-340, -60, 0)
    
    self.text2 = self:AddChild(Text(BODYTEXTFONT, 30,"愿曼德格拉护佑你，冒险者")) 
    self.text2:SetPosition(0, -140, 0)
	--离开
	self.likai = self:AddChild(ImageButton("images/ui/talk.xml", "talk.tex"))
	self.likai:SetPosition(100, -220, 0)
	self.likai:SetText("继续")
	self.likai:SetOnClick(
	function ()
	--TheFrontEnd:PopScreen()
	if jiaodaodengji == 1 then jiaodao = "这里是S.E.F，欢迎使用本公司的产品，Miss不灵" self.likai:SetText("继续") jiaodaodengji = 2 
	elseif jiaodaodengji == 2 then jiaodao = "判断当前情况，确定Miss不灵进入遇难模式\关键字遇难，开始搜索"self.likai:SetText("继续") jiaodaodengji = 3 
	elseif jiaodaodengji == 3 then jiaodao = "搜索完成，确定采取Miss不灵的第32504条记录\n《吃撑了研究一下野外求生》" self.likai:SetText("(继续)")jiaodaodengji = 4 
	elseif jiaodaodengji == 4 then jiaodao = "" self.likai:SetText("离开泥土？")jiaodaodengji = 5 
	elseif jiaodaodengji == 5 then jiaodao = "曼德拉之民平常生活在土壤中，但是这样也仅仅是活着而已，不离开大地终究无法发展" self.likai:SetText("？？？算了就当村子人口吧") jiaodaodengji = 6 
	elseif jiaodaodengji == 6 then jiaodao = "虽然你好像理解错了，不过也没差就是了" self.likai:SetText("(继续)") jiaodaodengji = 7 
	elseif jiaodaodengji == 7 then jiaodao = "曼德拉度代表着村庄的发展度，曼德拉度越高说明村庄的发展前景很好" self.likai:SetText("(继续)") jiaodaodengji = 8 
	elseif jiaodaodengji == 8 then jiaodao = "提升曼德拉度就只有拜托你帮忙建设村子啦，可以来我这里交接任务提高曼德拉度" self.likai:SetText("(继续)") jiaodaodengji = 9 
	elseif jiaodaodengji == 9 then jiaodao = "最后是食物，每天一个曼德拉之民会消耗10点食物\n如果食物不够我以外的曼德拉之民将拒绝来到地面上" self.likai:SetText("（我是不是不该种那棵树的。。）") jiaodaodengji = 10 
	elseif jiaodaodengji == 10 then jiaodao = "那么现在先来解决食物的问题吧" ztex = "images/ui/mand-1.xml" ztex = "mand-1.tex"
	self.likai:SetText("哎？") jiaodaodengji = 11 
	elseif jiaodaodengji == 11 then jiaodao = "来，拿着这个曼德拉蛋糕还有这个农场工作台"
    GetPlayer().components.inventory:GiveItem(SpawnPrefab("manddou"))
	GetPlayer().components.inventory:GiveItem(SpawnPrefab("farmtool"))
	self.likai:SetText("这是干啥的？") jiaodaodengji = 12 
	elseif jiaodaodengji == 12 then jiaodao = "先把这个曼德拉蛋糕交给一只曼德拉之民\n她就愿意跟着你啦，然后把她带到你中意的地方,嘿嘿" self.likai:SetText("(吞口水)") jiaodaodengji = 13 
	elseif jiaodaodengji == 13 then jiaodao = "再把这个农场工作台交给她，她就会开始建造农场然后住里面干活啦" self.likai:SetText("？？？") jiaodaodengji = 14 
	elseif jiaodaodengji == 14 then jiaodao = "赶紧去吧，别呆着了" self.likai:SetText("好，好的")  jiaodaodengji = 15 
	elseif jiaodaodengji == 16 then jiaodao = "啊，已经建好了吗"
	elseif jiaodaodengji == 15 then jiaodao = "呆着干嘛，快去！"  self.likai:SetText("呃。。。。。") 
	
	SetPause(false, "console")
	self:Hide()
	self.IsUIShow =false 
	--TheFrontEnd:PopScreen()
	
	local x,y,z = GetPlayer().Transform:GetWorldPosition()
	local ents =  TheSim:FindEntities(x,y,z,30)
    for k,v in pairs(ents) do
      if v.prefab == "jiaocheng" then
	  local brain = require "brains/frogbrain"
             v:SetBrain(brain)
			 v:RestartBrain()
      end
	  
	  end
	  
	end
	self.text2:Kill()
    self.text2 = self:AddChild(Text(BODYTEXTFONT, 30,jiaodao)) 
    self.text2:SetPosition(0, -140, 0)
end)
--self:StartUpdating()
end)
function jiaocheng:Close()
	SetPause(false, "console")
	self:Hide()
	self.IsUIShow =false
	--TheFrontEnd:PopScreen()
	
	local x,y,z = GetPlayer().Transform:GetWorldPosition()
	local ents =  TheSim:FindEntities(x,y,z,30)
    for k,v in pairs(ents) do
      if v.prefab == "jiaocheng" then
	  local brain = require "brains/frogbrain"
             v:SetBrain(brain)
			 v:RestartBrain()
      end end
	
end
--[[function jiaocheng:OnUpdate(dt)
	self.image2:SetChild(Image(zxml,ztex ))

end]]
function jiaocheng :OnControl(control, down)
	if jiaocheng ._base.OnControl(self,control, down) then
		return true
	end
	if not down then
		if control == CONTROL_PAUSE or control == CONTROL_CANCEL then
			self:Close()
		return true
		end
	end
	return false
end

return jiaocheng 