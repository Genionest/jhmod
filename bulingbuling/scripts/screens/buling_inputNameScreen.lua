require "util"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local NumericSpinner = require "widgets/numericspinner"
local TextEdit = require "widgets/textedit"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Menu = require "widgets/menu"

local VALID_CHARS = [[ abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,:;[]\@!#$%&()'*+-/=?^_{|}~"]]
-- fix syntax highlighting due to above list: "'
local MAX_LENGTH = 254

local CONSOLE_HISTORY = {}

local DW_InputBox = Class(Screen, function(self, title, text, buttons, fn, choicelist, timeout, valdchars, maxlength, normal)
	Screen._ctor(self, "DW_InputBox")
	self.timeout = timeout
	self.choicelist = choicelist
	self.fn = fn
	self:DoInit(self, title, text, buttons, valdchars, maxlength, normal)
end)

function DW_InputBox:OnUpdate( dt )
	if self.timeout then
		self.timeout.timeout = self.timeout.timeout - dt
		if self.timeout.timeout <= 0 then
			self.timeout.cb()
		end
	end
	return true
end

function DW_InputBox:OnBecomeActive()
	DW_InputBox._base.OnBecomeActive(self)

	self.box_edit:SetFocus()
	self.box_edit:SetEditing(true)
	TheFrontEnd:LockFocus(true)
end

function DW_InputBox:OnControl(control, down)
	if DW_InputBox._base.OnControl(self, control, down) then return true end

	if not down and (control == CONTROL_CANCEL or control == CONTROL_PAUSE) then 
		self:Close()
		return true
	end
end

function DW_InputBox:OnRawKey( key, down)
	if DW_InputBox._base.OnRawKey(self, key, down) then return true end
	
	if down then return end
	if not self.choicelist then return end
	
	if key == KEY_UP then
		local choice = self.choicelist
		local str = "NIL"
		if type(choice) == "table" then
			str = choice[math.random(#choice)]
		else
            str = choice
		end
		self.box_edit:SetString(tostring(str))
	else
		return false
	end
	
	return true
end

function DW_InputBox:GetString()
	local fnstr = self.box_edit:GetString()
    if fnstr then
    	return fnstr
    end
    return "NIL"
end

function DW_InputBox:Close()
	SetPause(false)
	TheFrontEnd:PopScreen(self)
end

function DW_InputBox:OnTextEntered()
	if self:GetString() == "" then return end
	if self.fn then
		if type(self.fn) == "function" then
			self.fn(self:GetString())
		--else
	    --    self.fn:PushEvent("DW_INPUT",{input = self:GetString()})
	    end
    end
    self:Close()
end

function DW_InputBox:DoInit(self, title, text, buttons, valdchars, maxlength, normal)
	SetPause(true,"inputbox")

	local label_width = 200
	local label_height = 50
	local label_offset = 450

	local space_between = 30
	local height_offset = -270

	local fontsize = 30
	
	local edit_width = 900
	local edit_bg_padding = 100

    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)
	
	self.root = self:AddChild(Widget(""))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_MIDDLE)
	self.root:SetPosition(0,0,0)

    self.bg = self.root:AddChild(Image("images/globalpanels.xml", "panel_upsell_small.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(1.2,1.2,1.2)

    self.title = self.root:AddChild(Text(TITLEFONT, 50))
    self.title:SetPosition(0, 135, 0)
    self.title:SetString(title)

    self.text = self.root:AddChild(Text(BODYTEXTFONT, 30))
    self.text:SetPosition(0, 5, 0)
    self.text:SetString(text)
    self.text:EnableWordWrap(true)
    self.text:SetRegionSize(500, 200)

    if buttons then
      	local button_w = 200
	    local space_between = 20
	    local spacing = button_w + space_between
        local spacing = 200

	    self.menu = self.root:AddChild(Menu(buttons, spacing, true))
	    self.menu:SetPosition(-(spacing*(#buttons-1))/2, -140, 0) 
	    self.buttons = buttons
    end
	
    self.edit_bg = self.root:AddChild( Image() )
	self.edit_bg:SetTexture( "images/ui.xml", "textbox_long.tex" )
	self.edit_bg:SetPosition( 0,-60,0)
	self.edit_bg:ScaleToSize( edit_width + edit_bg_padding, label_height )
	self.edit_bg:SetScale(.6,.5,.6)

	self.box_edit = self.root:AddChild( TextEdit( DEFAULTFONT, fontsize, "" ) )
	self.box_edit:SetPosition( 100,-60,0)
	self.box_edit:SetRegionSize( edit_width, label_height )
	self.box_edit:SetHAlign(ANCHOR_LEFT)
	self.box_edit:SetScale(.7,.6,.7)

	self.box_edit.OnTextEntered = function() self:OnTextEntered() end
	--self.box_edit:SetLeftMouseDown( function() self:SetFocus( self.box_edit ) end )
	self.box_edit:SetFocusedImage( self.edit_bg, "images/ui.xml", "textbox_long_over.tex", "textbox_long.tex" )
	self.box_edit:SetCharacterFilter(valdchars or VALID_CHARS )
	self.box_edit:SetTextLengthLimit(maxlength or MAX_LENGTH)

	self.box_edit:SetString(normal or "")
	self.history_idx = nil

	self.box_edit.validrawkeys[KEY_UP] = true

end

return DW_InputBox
