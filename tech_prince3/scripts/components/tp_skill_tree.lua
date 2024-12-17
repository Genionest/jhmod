local WgShelf = require "extension/lib/wg_shelf"
local SkillTreeManager = Sample.SkillTreeManager

local TpSkillTree = Class(function(self, inst)
    self.inst = inst
    self.ids = {}
    self.skill_tree = nil
end)

function TpSkillTree:HasId(id)
    if table.contains(self.ids, id) then
        return true
    end
end

function TpSkillTree:HasIds(ids)
    local ret = true
    for k, v in pairs(ids) do
        if not self:HasId(v) then
            ret = false
        end
    end
    return ret
end

function TpSkillTree:AddId(id)
    if not self:HasId(id) then
        table.insert(self.ids, id)
        -- SkillTreeManager:UnlockSkill(id, self.inst)
        -- local data = SkillTreeManager:GetDataById(id)
        -- data:Unlock(self.inst)
    end
end

function TpSkillTree:UnlockSkill(id)
    if not self:HasId(id) then
        self:AddId(id)
        -- SkillTreeManager:TriggerSkill(id, self.inst)
        -- SkillTreeManager:ForeverEffectSkill(id, self.inst)
        local data = SkillTreeManager:GetDataById(id)
        -- data:Trigger(self.inst)
        data.fn(self.inst, self, id, data)
        if data.fn2 then
            data.fn2(self.inst, self, id, data)
        end
        -- self:ShowSkillDesc(id)
    end
end


--[[for k, v in pairs(GetPlayer().components.tp_skill_tree.ids) do print(k, v) end]]
--[[print(GetPlayer().components.tp_skill_tree.ids)]]
function TpSkillTree:ShowSkillDesc(id)
    -- if id == nil then
    --     -- 通过等级解锁天赋时可以不传入id
    --     local tp_level = self.inst.components.tp_level
    --     id = string.format("P%dL%d", tp_level.phase, tp_level.level)
    -- end
    -- self:AddId(id)
end

function TpSkillTree:GetScreenData()
    -- local datas = SkillTreeManager:GetDatasByKind(self.inst.prefab)
    local datas = {}
    for k, v in pairs(self.ids) do
        local data = SkillTreeManager:GetDataById(v)
        table.insert(datas, data)
    end
    local shelfs = WgShelf("天赋树", 20)
    -- shelfs.GetBalance = function(self, screen)
    --     return screen.owner.components.ak_level:GetEssences()
    -- end
    -- shelfs.GetLevel = function(self, screen)
    --     return screen.owner.components.ak_level.current
    -- end
    for k, v in pairs({datas}) do

        shelfs:AddBar()
        local shelf = WgShelf("", 20)
        for k2, v2 in pairs(v) do
            shelf:AddItem(v2)
        end
        shelfs:AddItem(shelf)
    end
    return shelfs
end

function TpSkillTree:OnSave()
    return {
        ids = self.ids,
    }
end

function TpSkillTree:OnLoad(data)
    if data then
        self.ids = data.ids or {}
        for i, id in pairs(data.ids) do
            local data = SkillTreeManager:GetDataById(id)
            -- SkillTreeManager:LoadSkill(id, self.inst)
            data.fn(self.inst, self, id, data)
        end
    end
end

return TpSkillTree