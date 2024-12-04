local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local AkIntroScreen = require "screens/ak_intro_screen"
local Badge = require "widgets/badge"
local AssetUtil = require "extension.lib.asset_util"
local ManaBadge = require "widgets.mana_badge"
local TasteBadge = require "widgets.taste_badge"
local LevelBadge = require "widgets.level_badge"

AddClassPostConstruct("widgets/statusdisplays", function(self)

    self.ak_btn_info = {
        {
            txt = "介绍",
            atlas = "ak_structures",
            img = "ak_super_calculator",
            fn = function()
                TheFrontEnd:PushScreen(AkIntroScreen(Sample.Intro))
            end,
        },
    }

    self.ak_version_txt = self:AddChild(Text(TITLEFONT, 30))
    self.ak_version_txt:SetString("v"..Sample.version)	
    self.ak_version_txt:SetPosition(-180, 0, 0)

    self.ak_buttons = {}
    for k, v in pairs(self.ak_btn_info) do
        local Uimg = AssetUtil:MakeImg(v.atlas, v.img)
        self.ak_buttons[k] = self:AddChild(ImageButton(
            Uimg:GetImage()
        ))
        local dt_x, dt_y = 70*(k%3), 70-70*math.ceil(k/3)
        self.ak_buttons[k]:SetPosition(-400+dt_x, 140+dt_y, 0)
        self.ak_buttons[k].ak_txt = self.ak_buttons[k]:AddChild(Text(TITLEFONT, 20))
        self.ak_buttons[k].ak_txt:SetString(v.txt)
        self.ak_buttons[k].ak_txt:SetPosition(0, -30, 0)
        self.ak_buttons[k]:SetOnClick(function()
            if v.fn then
                v.fn()
            end
        end)
    end

    local function add_attr_badge(badge, event, max_fn)
        local function on_delta(inst, data)
            local max = max_fn(self.owner)
			badge:SetPercent(data.new_p, max)
			if not data.no_flash and data.new_p and data.old_p then
				if data.new_p > data.old_p then
					badge:PulseGreen()
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_up")
					badge:Show()
				elseif data.new_p < data.old_p then
					badge:PulseRed()
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_down")
					if data.new_p <= 0 then
						badge:Hide()
					end
				end
			end
		end
		self.inst:ListenForEvent(event, on_delta, self.owner)
    end

    local dx, dy = 60, 70
    local x, y = -65, -50
    -- level
    if self.owner.components.tp_level then
		self.tp_level = self:AddChild(LevelBadge(self.owner))
		self.tp_level:SetPosition(x, y, 0)
		self.tp_level:SetPercent(self.owner.components.tp_level:GetPercent(), 
			self.owner.components.tp_level.need)
		-- if self.owner.components.tp_level:IsEmpty() then
		-- 	self.tp_level:Hide()
		-- end
		add_attr_badge(self.tp_level, "tp_exp_delta", function(owner)
            return owner.components.tp_level.need
        end)
        self.owner.components.tp_level:ExpDelta(0)
	end
    -- mana
    x, y = x-dx, y
    if self.owner.components.tp_mana then
		self.tp_mana = self:AddChild(ManaBadge(self.owner))
		self.tp_mana:SetPosition(x, y, 0)
		self.tp_mana:SetPercent(self.owner.components.tp_mana:GetPercent(), 
			self.owner.components.tp_mana:GetMax())
		-- if self.owner.components.tp_mana:IsEmpty() then
		-- 	self.tp_mana:Hide()
		-- end
		add_attr_badge(self.tp_mana, "tp_mana_delta", function(owner)
            return self.owner.components.tp_mana:GetMax()
        end)
        self.owner.components.tp_mana:DoDelta(0)
	end
    -- taste
    x, y = x-dx, y
    if self.owner.components.tp_taste then
		self.tp_taste = self:AddChild(TasteBadge(self.owner))
		self.tp_taste:SetPosition(x, y, 0)
		self.tp_taste:SetPercent(self.owner.components.tp_taste:GetPercent(), 
			self.owner.components.tp_taste:GetMax())
		-- if self.owner.components.tp_taste:IsEmpty() then
		-- 	self.tp_taste:Hide()
		-- end
		add_attr_badge(self.tp_taste, "tp_taste_delta", function(owner)
            return owner.components.tp_taste:GetMax()
        end)
        self.owner.components.tp_taste:DoDelta(0)
	end
    
end)
