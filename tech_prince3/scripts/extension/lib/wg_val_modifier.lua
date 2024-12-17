local WgValModifier = Class(function(self, cls)
    self.cls = cls
    self.member_modifier_tbl = nil
    self.member_buff_tbl = nil
    self.member_multiplier_tbl = nil
    self.member_factor_tbl = nil
end)

-- 将下划线命名法转换为帕斯卡命名法
local function snake_to_pascal(str)
    local result = str:gsub("_(%w)", function(c)
        return c:upper()
    end)
    -- 首字母大写
    return result:sub(1, 1):upper() .. result:sub(2)
end

function WgValModifier:AddMemberKeyMod(member, key, mod)
    if not self.member_modifier_tbl then
        self.member_modifier_tbl = {}
    end
    if not self.member_modifier_tbl[member] then
        self.member_modifier_tbl[member] = {}
    end
    self.member_modifier_tbl[member][key] = mod
    if not self.member_buff_tbl then
        self.member_buff_tbl = {}
    end
    self.member_buff_tbl[member] = self:GetMemberMod(member)
end

function WgValModifier:RmMemberKeyMod(member, key)
    if self.member_modifier_tbl and self.member_modifier_tbl[member] then
        self.member_modifier_tbl[member][key] = nil
        -- 清理空表
        if not next(self.member_modifier_tbl[member]) then
            self.member_modifier_tbl[member] = nil
            -- 如果member_modifier_tbl[member]没有了, member_buff_tbl[member]也要一起清理
            self.member_buff_tbl[member] = nil
            -- 清理空表
            if not next(self.member_modifier_tbl) then
                -- 如果member_modifier_tbl没有了, member_buff_tbl也要一起清理
                self.member_modifier_tbl = nil
                self.member_buff_tbl = nil
            end
        end
        if self.member_buff_tbl and self.member_buff_tbl[member] then
            self.member_buff_tbl[member] = self:GetMemberMod(member)
        end
    end
end

function WgValModifier:GetMemberMod(member)
    if self.member_modifier_tbl and self.member_modifier_tbl[member] then
        local val = 0
        for k, v in pairs(self.member_modifier_tbl[member]) do
            val = val + v
        end
        return val
    end
end

function WgValModifier:GetMemberBuff(member)
    if self.member_buff_tbl and self.member_buff_tbl[member] then
        return self.member_buff_tbl[member]
    end
end

function WgValModifier:GetMemberModByKey(member, key)
    if self.member_modifier_tbl and self.member_modifier_tbl[member] then
        return self.member_modifier_tbl[member][key]
    end
end


function WgValModifier:AddMemberKeyMult(member, key, mult)
    if not self.member_multiplier_tbl then
        self.member_multiplier_tbl = {}
    end
    if not self.member_multiplier_tbl[member] then
        self.member_multiplier_tbl[member] = {}
    end
    self.member_multiplier_tbl[member][key] = mult
    if not self.member_factor_tbl then
        self.member_factor_tbl = {}
    end
    self.member_factor_tbl[member] = self:GetMemberMult(member)
end

function WgValModifier:RmMemberKeyMult(member, key)
    if self.member_multiplier_tbl and self.member_multiplier_tbl[member] then
        self.member_multiplier_tbl[member][key] = nil
        -- 清理空表
        if not next(self.member_multiplier_tbl[member]) then
            self.member_multiplier_tbl[member] = nil
            -- 如果member_multiplier_tbl[member]没有了, member_factor_tbl[member]也要一起清理
            self.member_factor_tbl[member] = nil
            -- 清理空表
            if not next(self.member_multiplier_tbl) then
                -- 如果member_multiplier_tbl没有了, member_factor_tbl也要一起清理
                self.member_multiplier_tbl = nil
                self.member_factor_tbl = nil
            end
        end
        if self.member_factor_tbl and self.member_factor_tbl[member] then
            self.member_factor_tbl[member] = self:GetMemberMult(member)
        end
    end
end

function WgValModifier:GetMemberMult(member)
    if self.member_multiplier_tbl and self.member_multiplier_tbl[member] then
        local val = 1
        for k, v in pairs(self.member_multiplier_tbl[member]) do
            val = val + v
        end
        return val
    end
end

function WgValModifier:GetMemberFactor(member)
    if self.member_factor_tbl and self.member_factor_tbl[member] then
        return self.member_factor_tbl[member]
    end
end

function WgValModifier:GetMemberMultByKey(member, key)
    if self.member_multiplier_tbl and self.member_multiplier_tbl[member] then
        return self.member_multiplier_tbl[member][key]
    end
end

function WgValModifier:RegisterMember(member)
    local member_name = snake_to_pascal(member)
    self.cls["Add"..member_name.."Mod"] = function(cls, key, mod)
        self:AddMemberKeyMod(member, key, mod)
    end
    self.cls["Rm"..member_name.."Mod"] = function(cls, key)
        self:RmMemberKeyMod(member, key)
    end
    self.cls["Get"..member_name.."Mod"] = function(cls)
        -- return self:GetMemberMod(member)
        return self:GetMemberBuff(member)
    end
    self.cls["Get"..member_name.."ModByKey"] = function(cls, key)
        return self:GetMemberModByKey(member, key)
    end

    self.cls["Add"..member_name.."Mult"] = function(cls, key, mult)
        self:AddMemberKeyMult(member, key, mult)
    end
    self.cls["Rm"..member_name.."Mult"] = function(cls, key)
        self:RmMemberKeyMult(member, key)
    end
    self.cls["Get"..member_name.."Mult"] = function(cls)
        -- return self:GetMemberMult(member)
        return self:GetMemberFactor(member)
    end
    self.cls["Get"..member_name.."MultByKey"] = function(cls, key)
        return self:GetMemberMultByKey(member, key)
    end

    self.cls["Get"..member_name] = function(cls)
        local val = self.cls[member]
        local mod = self:GetMemberBuff(member)
        if mod then
            val = val + mod
        end
        local mult = self:GetMemberFactor(member)
        if mult then
            val = val * mult
        end
        return val
    end
end

function WgValModifier:RegisterCommon()
    self.cls["AddMemberMod"] = function(cls, member, key, mod)
        self:AddMemberKeyMod(member, key, mod)
    end
    self.cls["RmMemberMod"] = function(cls, member, key)
        self:RmMemberKeyMod(member, key)
    end
    self.cls["GetMemberMod"] = function(cls, member)
        return self:GetMemberMod(member)
    end
    self.cls["GetMemberModByKey"] = function(cls, member, key)
        return self:GetMemberModByKey(member, key)
    end

    self.cls["AddMemberMult"] = function(cls, member, key, mult)
        self:AddMemberKeyMult(member, key, mult)
    end
    self.cls["RmMemberMult"] = function(cls, member, key)
        self:RmMemberKeyMult(member, key)
    end
    self.cls["GetMemberMult"] = function(cls, member)
        return self:GetMemberMult(member)
    end
    self.cls["GetMemberMultByKey"] = function(cls, member, key)
        return self:GetMemberMultByKey(member, key)
    end

    self.cls["GetMember"] = function(cls, member)
        local val = self.cls[member]
        local mod = self:GetMemberBuff(member)
        if mod then
            val = val + mod
        end
        local mult = self:GetMemberFactor(member)
        if mult then
            val = val * mult
        end
        return val
    end
end

return WgValModifier