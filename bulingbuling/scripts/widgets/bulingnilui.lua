local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text" 
local TextButton = require "widgets/textbutton" 
require "util"


NilUi = Class(Screen, function(self,owner)
	Widget._ctor(self, "zhanglao")
    self.owner = owner
	GetPlayer():ListenForEvent("openai",function() self:AI()  end)
	GetPlayer():ListenForEvent("openlingjian",function() self:LJ()  end)
    SetPause(true,"pause")
   
end)
function NilUi:AI()
		self.gf = self:AddChild(require("widgets/bulingai")(self))
		self.gf:SetPosition(0, 0, 0)
end
function NilUi:LJ()
		self.LJ = self:AddChild(require("widgets/bulinglingjian")(self))
		self.LJ:SetPosition(0, 0, 0)
		self.LJ.IsUIShow = true
end
return NilUi