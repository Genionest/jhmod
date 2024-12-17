local Util = require "extension.lib.wg_util"
local EntUtil = require "extension.lib.ent_util"
local Sounds = require "extension.datas.sounds"
local BuffManager = Sample.BuffManager
local Info = Sample.Info

local TpForgeWeapon = Class(function(self, inst)
    self.inst = inst
    local attackwear = inst.components.weapon and inst.components.weapon.attackwear
    self.attackwear = attackwear or 1
    self.level = 1
    self.forge_level_dmg = 10
    self.forge_material = "tp_infused_nugget_black"
    self.element = nil
    self.element_dmg = 10
    self.factors = nil
    -- 武器攻击力的属性收益
	self.inst.components.weapon:WgAddWeaponDamageFn(function(inst, dmg)
        dmg = dmg + (self.level-1) * self.forge_level_dmg
		if self.factors then
			local owner = inst.components.equippable and inst.components.equippable.owner
			if owner and owner.components.tp_player_attr then
				for attr, factor in pairs(self.factors) do
                    -- 质变后的属性收益降低为60%
                    if self.element then
                        factor = factor * .6
                    end
					local amt = owner.components.tp_player_attr:GetAttrFactor(attr)
					dmg = dmg + (amt * factor * self.level)
				end
			end
		end
		return dmg
	end)

    self.inst.components.weapon:WgAddWeaponAttackFn(function(inst, owner, target)
        -- 武器质变的额外伤害 
        if self.element then
            local element = self.element 
            local base_dmg
            base_dmg = self.element_dmg
            EntUtil:get_attacked(target, owner, base_dmg*self.level, nil, 
                EntUtil:add_stimuli(nil, element, "pure") )
            
            -- local rand = math.random()
            -- if rand < 0.1 then
            --     if element == "fire" then
            --         EntUtil:ignite(target)
            --     elseif element == "ice" then
            --         EntUtil:frozen(target)
            --     elseif element == "poison" then
            --         EntUtil:poison(target)
            --     elseif element == "electric" then
            --         BuffManager:AddBuff(target, "electric")
            --     elseif element == "blood" then
            --         BuffManager:AddBuff(target, "blood")
            --     elseif element == "wind" then
            --         BuffManager:AddBuff(target, "wind")
            --     elseif element == "shadow" then
            --         local pt = target:GetPosition()
            --         local st_pt =  FindWalkableOffset(pt or owner:GetPosition(), math.random()*2*PI, 2, 3)
            --         if st_pt then
            --             inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
            --             inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")            
            --             st_pt = st_pt + pt
            --             local st = SpawnPrefab("shadowtentacle")
            --             --print(st_pt.x, st_pt.y, st_pt.z)
            --             st.Transform:SetPosition(st_pt.x, st_pt.y, st_pt.z)
            --             st.components.combat:SetTarget(target)
            --         end
            --     elseif element == "holly" then
            --         owner.components.health:DoDelta(10)
            --     end
            -- end
        end
    end)
end)

function TpForgeWeapon:SetAttrFactor(attr, factor)
    if self.factors == nil then
        self.factors = {}
    end
    self.factors[attr] = factor
end

function TpForgeWeapon:LevelUp()
    self.level = self.level + 1
    self.inst.components.weapon.attackwear = self.attackware / self.level
end

function TpForgeWeapon:CanForge(material)
    if material.prefab == self.forge_material then
        if self.level < 4 then
            local n = 1
            if self.forge_material == "tp_infused_nugget_black" then
                n = self.level
            end
            if material.components.stackable:StackSize() >= n then
                return true
            end
        end
    end
end

function TpForgeWeapon:Forge(material)
    local n = 1
    if self.forge_material == "tp_infused_nugget_black" then
        n = self.level
    end
    material.components.stackable:Get(n):Remove()
    self:LevelUp()
end

function TpForgeWeapon:CanBeElemental()
    local dmg_type = self.inst.components.weapon.dmg_type
    if EntUtil:is_physics_dmg(dmg_type) then
        if self.element == nil then
            return true
        end
    end 
end

function TpForgeWeapon:SetElement(element)
    self.element = element
end

function TpForgeWeapon:OnSave()
    return {
        level = self.level,
        element = self.element,
    }
end

function TpForgeWeapon:OnLoad(data)
    if data then
        self.level = data.level or 1
        self.element = data.element
    end
end

function TpForgeWeapon:GetWargonString()
    local s = string.format("锻造:%d级,", self.level)
    if self.level >= 4 then
        s = s .. "材料:无"
    else
        -- if self.forge_material == "tp_infused_nugget_black" then
        --     s = s .. string.format("材料:%sx%d", 
        --         Util:GetScreenName(self.forge_material), self.level)
        -- else
            s = s .. string.format("材料:%sx1", 
                Util:GetScreenName(self.forge_material))
        -- end
    end
    s = s..string.format("\n耐久消耗率:%d%%", 1/self.level*100)
    if self.element then
        s = s .. string.format("\n质变属性:%s", STRINGS.TP_DMG_TYPE[self.element])
    end
    if self.factors then
        s = s .. "\n属性收益:"
        for attr, factor in pairs(self.factors) do
            local rate = factor*self.level
            if self.element then
                rate = rate * .6
            end
            s = s .. string.format("%s(%d%%),", 
                Info.Attr.PlayerAttrStr[attr], rate*100)
        end
    end
    return s
end

function TpForgeWeapon:GetWargonStringColour()
    return {255/255, 140/255, 0/255, 1}
end

return TpForgeWeapon