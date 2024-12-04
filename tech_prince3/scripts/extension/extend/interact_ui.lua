local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local AkIntroScreen = require "screens/ak_intro_screen"
local TpSkillTreeScreen = require "screens/tp_skill_tree_screen"
local TpLevelScreen = require "screens/tp_level_screen"
local TpOrnamentScreen = require "screens/tp_ornament_screen"
local TpAttrScreen = require "screens.tp_attr_screen"
local Badge = require "widgets/badge"

local AssetUtil = require "extension.lib.asset_util"
local version = Sample.version

AddClassPostConstruct("widgets/statusdisplays", function(self)

    self.ak_btn_info = {
        {
            txt = "介绍",
            img = AssetUtil:MakeImg("ak_structures","ak_super_calculator"),
            fn = function()
                TheFrontEnd:PushScreen(AkIntroScreen(Sample.Intro))
            end,
        },
        {
            txt = "天赋树",
            img = AssetUtil:MakeImg("accomplishment_shrine"),
            fn = function()
                local data = self.owner.components.tp_skill_tree:GetScreenData()
                TheFrontEnd:PushScreen(TpSkillTreeScreen(data, self.owner))
            end,
        },
        {
            txt = "饰品",
            img = AssetUtil:MakeImg("piggyback"),
            fn = function(inst)
                local data = self.owner.components.tp_ornament:GetScreenData()
                TheFrontEnd:PushScreen(TpOrnamentScreen(data, self.owner))
            end,
        },
        {
            txt = "属性",
            img = AssetUtil:MakeImg("resurrectionstatue"),
            fn = function(inst)
                local data = self.owner.components.tp_player_attr:GetScreenData()
                TheFrontEnd:PushScreen(TpAttrScreen(data, self.owner))
            end,
        },
        -- {
        --     txt = "升级",
        --     img = AssetUtil:MakeImg("ak_structures","ak_level_eraser"),
        --     fn = function(inst)
        --         local data = Sample.LevelAttrSystem
        --         data:Init(self.owner)
        --         TheFrontEnd:PushScreen(TpLevelScreen(data, self.owner))
        --     end
        -- },
    }

    self.ak_version_txt = self:AddChild(Text(TITLEFONT, 30))
    self.ak_version_txt:SetString("v"..version)	
    self.ak_version_txt:SetPosition(-180, 60, 0)

    self.ak_buttons = {}
    for k, v in pairs(self.ak_btn_info) do
        -- local Uimg = AssetUtil:MakeImg(v.atlas, v.img)
        local Uimg = v.img
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

end)
