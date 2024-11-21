local mk_mana_ui = require "widgets/mk_mana_ui"

local function add_mk_mana(inst)
	inst:AddComponent("monkeymana")
end

local function add_mk_mana_ui(self)
    -- 不是猴哥不加
    if self.owner.prefab ~= "monkey_king" then return end
	self.mk_mana = self:AddChild(mk_mana_ui(self.owner))
    self.mk_mana:SetPosition(-120, 90, 0)
    local mana_cmp = self.owner.components.monkeymana
    self.mk_mana:SetPercent(mana_cmp:GetPercent(), 
    	mana_cmp:GetMax(), 
    	mana_cmp:GetPercent()
    	)
	
	self.inst:ListenForEvent("monkey_mana_delta", function(inst, data)
		self:MonkeyManaDelta(data)
	end, self.owner)

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
end

AddPrefabPostInit("monkey_king", add_mk_mana)
AddClassPostConstruct("widgets/statusdisplays", add_mk_mana_ui)