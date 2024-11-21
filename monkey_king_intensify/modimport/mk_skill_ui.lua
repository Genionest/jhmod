local mk_morph_ui = require "widgets/mk_morph_ui"
local mk_cloud_ui = require "widgets/mk_cloud_ui"
local mk_monkey_ui = require "widgets/mk_monkey_ui"
local mk_back_ui = require "widgets/mk_back_ui"
local mk_mana_ui = require "widgets/mk_mana_ui"
local mk_jgbsp_ui = require "widgets/mk_jgbsp_ui"
local mk_frozen_ui = require "widgets/mk_frozen_ui"

local function addMKUI(self)
	if self.owner and self.owner.prefab == 'monkey_king' then
        self.mk_morph_button = self:AddChild(mk_morph_ui(self.owner))
        self.mk_morph_button:SetPosition(-120, 90, 0)
        -- if else_enable then
        self.mk_cloud_button = self:AddChild(mk_cloud_ui(self.owner))
        self.mk_cloud_button:SetPosition(-190, 90, 0)
        self.mk_monkey_button = self:AddChild(mk_monkey_ui(self.owner))
        self.mk_monkey_button:SetPosition(-260, 90, 0)
        self.mk_back_button = self:AddChild(mk_back_ui(self.owner))
        self.mk_back_button:SetPosition(-260, 20, 0)
        self.mk_jgbsp_button = self:AddChild(mk_jgbsp_ui(self.owner))
    	self.mk_jgbsp_button:SetPosition(-330, 90, 0)
    	self.mk_frozen_button = self:AddChild(mk_frozen_ui(self.owner))
    	self.mk_frozen_button:SetPosition(-330, 20, 0)
	    -- end
        self.mk_back_button:SetPercent(
            self.owner.components.mkbacktimer:GetPercent())
        self.mk_monkey_button:SetPercent(
            self.owner.components.mkmonkeytimer:GetPercent())
        self.mk_morph_button:SetPercent(
            self.owner.components.mkmorphtimer:GetPercent())
        self.mk_cloud_button:SetPercent(
            self.owner.components.mkcloudtimer:GetPercent())
        self.mk_jgbsp_button:SetPercent(
            self.owner.components.mkjgbsptimer:GetPercent())
        self.mk_frozen_button:SetPercent(
            self.owner.components.mkfrozentimer:GetPercent())
        self.inst:ListenForEvent("mk_timer_delta", function(inst, data)
            print("listen mk_timer data is", data.name, data.percent)
            print("mk_"..data.name.." setpercent", data.percent)
            self["mk_"..data.name.."_button"]:SetPercent(data.percent)
            -- if data.name == "back" then
            --     print("mk_back setpercent", data.percent)
            --     self.mk_back_button:SetPercent(data.percent)
            -- elseif data.name == "monkey" then
            --     print("mk_monkey setpercent", data.percent)
            --     self.mk_monkey_button:SetPercent(data.percent)
            -- elseif data.name == "morph" then
            --     print("mk_morph setpercent", data.percent)
            --     self.mk_morph_button:SetPercent(data.percent)
            -- elseif data.name == "cloud" then
            --     print("mk_cloud setpercent", data.percent)
            --     self.mk_cloud_button:SetPercent(data.percent)
            -- elseif data.name == "jgbsp" then
            --     print("mk_jgbsp setpercent", data.percent)
            --     self.mk_jgbsp_button:SetPercent(data.percent)
            -- elseif data.name == "frozen" then
            --     print("mk_frozen setpercent", data.percent)
            --     self.mk_frozen_button:SetPercent(data.percent)
            -- end
        end, self.owner)
        -- mana
        self.mk_mana = self:AddChild(mk_mana_ui(self.owner))
        self.mk_mana:SetPosition(-190, 20, 0)
        local mana_cmp = self.owner.components.monkeymana
        self.mk_mana:SetPercent(mana_cmp:GetPercent(), 
        	mana_cmp:GetMax(), 
        	mana_cmp:GetPercent()
        	)
    	
    	self.inst:ListenForEvent("monkey_mana_delta", function(inst, data)
    		self:MonkeyManaDelta(data)
    	end, self.owner)
    end

    function self:MonkeyManaDelta(data)
    	if self.owner.prefab ~= "monkey_king" then
    		return
    	end
    	self.mk_mana:SetPercent(data.newpercent, 
    		self.owner.components.monkeymana:GetMax(), 
    		self.owner.components.monkeymana:GetPercent())
    	if not data.overtime then
    		if data.newpercent > data.oldpercent then
    			self.mk_mana:PulseGreen()
    			-- TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_up")
    		elseif data.newpercent < data.oldpercent then
    			self.mk_mana:PulseRed()
    			-- TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_down")
    		end
    	end
    end
    -- function self:MKBackUIDelta(data)
    --     print("data.percent is", data.percent)
    --     self.mk_back_button:SetPercent(data.percent)
    -- end
end

local function addUITimer(inst)
    inst:AddComponent("mkbacktimer")
    inst:AddComponent("mkmonkeytimer")
    inst:AddComponent("mkmorphtimer")
    inst:AddComponent("mkcloudtimer")
    inst:AddComponent("mkjgbsptimer")
    inst:AddComponent("mkfrozentimer")
end

AddClassPostConstruct("widgets/statusdisplays", addMKUI)
AddPrefabPostInit("monkey_king", addUITimer)