-- 毒免
AddComponentPostInit("poisonable", function(self)
    local CanBePoisoned = self.CanBePoisoned
	function self:CanBePoisoned()
        if self.inst:HasTag("tp_not_poisonable") then
			print("not poisonable")
			return 
		end
		return CanBePoisoned(self)
	end
end)

local function fn(self)
    -- 火伤增加
    -- self.tp_fire_damage_mod = 1
    local DoFireDamage = self.DoFireDamage
    function self:DoFireDamage(amount, ...)
        if self.inst:HasTag("tp_not_fire_damage") then
            -- 火伤免疫
            return
        end
        -- amount = amount * self.tp_fire_damage_mod
        DoFireDamage(self, amount, ...)
    end
    -- 毒伤增加
    -- self.tp_poison_damage_mod = 1
    local DoPoisonDamage = self.DoPoisonDamage
    function self:DoPoisonDamage(amount, ...)
        if self.inst:HasTag("tp_not_poison_damage") then
            -- 毒伤免疫
            return
        end
        -- amount = amount * self.tp_poison_damage_mod
        DoPoisonDamage(self, amount, ...)
    end
end
AddComponentPostInit("health", fn)

-- 冰冻免疫
AddComponentPostInit("freezable", function(self)
    local AddColdness = self.AddColdness
    function self:AddColdness(...)
        if not self.inst:HasTag("tp_not_freezable") then
            AddColdness(self, ...)
        end
    end
end)

-- 不会被点燃
AddComponentPostInit("burnable", function(self)
    local Ignite = self.Ignite
    function self:Ignite(...)
        if self.inst:HasTag("tp_not_burnable") then
            return
        end
        Ignite(self, ...)
    end
end)