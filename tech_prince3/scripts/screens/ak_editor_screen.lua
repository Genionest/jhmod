local TextEdit = require "widgets/textedit"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Text = require "widgets.text"

local VALID_CHARS = [[ abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,:;[]\@!#$%&()'*+-/=?^_{|}~"]]

local AkEditorScreen = Class(Screen, function(self, machine)
    self.machine = machine
    local id = ""
    if self.machine.components.ak_editor then
        id = self.machine.components.ak_editor:GetText() or id
    end
    SetPause(true)
    Screen._ctor(self, "AkEditorScreen")
    self.root = self:AddChild(Widget("ROOT"))
    self.root = self:AddChild(Widget("ROOT"))
	self.root:SetVAnchor(ANCHOR_MIDDLE)
	self.root:SetHAnchor(ANCHOR_MIDDLE)
	self.root:SetPosition(0, 0, 0)
	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.bg = self.root:AddChild(
		Image("images/fepanels.xml", "panel_saveslots.tex")
	)
	self.bg:SetScale(.9, .7, 1)

    self.title = self.root:AddChild(Text(TITLEFONT, 45))
    self.title:SetString("设置文本标识")
    self.title:SetPosition(0, 100, 0)

    self.editor_bg = self.root:AddChild( Image() )
	self.editor_bg:SetTexture( "images/ui.xml", "textbox_long.tex" )
    self.editor_bg:SetScale(.5, .8)

    self.editor = self.root:AddChild(
        TextEdit( DEFAULTFONT, 40, id )
    )
    self.editor.OnTextEntered = function() 
        self:OnTextEntered() 
    end
    self.editor:SetFocusedImage( self.editor_bg, 
        "images/ui.xml", "textbox_long_over.tex", "textbox_long.tex" )
    self.editor:SetCharacterFilter( VALID_CHARS )


    self.exit = self.root:AddChild(ImageButton())
    self.exit:SetText("退出")
    self.exit:SetPosition(100, -100, 0)
    self.exit:SetScale(.8)
    self.exit:SetOnClick(function()
        self:Exit()
    end)
    
    self.sure = self.root:AddChild(ImageButton())
    self.sure:SetText("确认")
    self.sure:SetPosition(-100, -100, 0)
    self.sure:SetScale(.8)
    self.sure:SetOnClick(function()
        self:OnTextEntered()
    end)
end)

function AkEditorScreen:Exit()
    TheFrontEnd:PopScreen(self)
    SetPause(false)
end

function AkEditorScreen:OnTextEntered()
    local str = self.editor:GetString()
    if self.machine.components.ak_editor then
        self.machine.components.ak_editor:SetText(str)
    end
    self:Exit()
end

return AkEditorScreen