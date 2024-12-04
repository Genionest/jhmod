local Util = require "extension.lib.wg_util"

local WgActionTool = Class(function(self, inst)
    self.inst = inst
    self.right = true
    self.effect_fn = nil
    self.get_action_fn = nil
    self.click_fn = nil
    self.click_no_action = nil  -- 按键或点击直接触发click_fn,不进行动作收集
    self.raw_skill_fn = nil  -- 直接触发的
    self.cd = nil
    self.mana = nil
    self.vigor = nil
end)

function WgActionTool:SetRawSkillFn(fn)
    self.raw_skill_fn = fn
end

function WgActionTool:ClickSkillButton(doer)
    -- 对于净化类技能而言, 需要能够直接释放
    if self.raw_skill_fn then
        self.raw_skill_fn(self.inst, doer)
    elseif self.inst.components.equippable:IsEquipped() then
        if self:Test(doer) then
            self.inst.components.wg_action_tool:Click(doer)
        end
    end
end

function WgActionTool:GetSkillDesc(doer)
    local str
    if self.sleep and not self.inst:HasTag("skill_wake") then
        return "需要激活技能"
    end
    if self.desc == nil then
        str = Util:GetDescription(self.inst.prefab)
    elseif type(self.desc) == "function" then
        str = self.desc(self.inst, doer)
    else
        str = self.desc
    end
    if self.mana then
        str = str .. string.format("\n需求%d点法力", self:GetRequire("mana", doer))
    end
    if self.vigor then
        str = str .. string.format("\n消耗%d精力", self.vigor)
    end
    return Util:SplitSentence(str, 17, true)
end

function WgActionTool:ChangeImage(img) 
end

function WgActionTool:SetDescription(desc)
    self.desc = desc
end

function WgActionTool:SetDefaultClickFn()
--     self.click_fn = function(inst, doer)
--         if self.get_action_fn or self. then
--             if inst.components.equippable:IsEquipped() then
--                 if inst.components.wg_action_tool
--                 and inst.components.wg_action_tool:Test(doer) then
--                     inst.components.wg_action_tool:PushAction(doer)
--                 end
--             end
--         else
--         end
--     end
end

function WgActionTool:SetClickFn(fn)
    self.click_fn = fn
end

function WgActionTool:SetSkillType(skill_type)
    if skill_type then
        self[skill_type] = true
    end
end

function WgActionTool:RegisterSkillInfo(data)
    data = data or {}

    self.inst:AddTag("wg_equip_skill")
    if data.fn then
        self:SetClickFn(data.fn)
    -- else
        -- self:SetDefaultClickFn()
    end
    if data.desc then
        self:SetDescription(data.desc)
    end
    if data.cd then
        self.cd = data.cd
    end
    if data.mana then
        self.mana = data.mana
    end
    if data.vigor then
        self.vigor = data.vigor
    end
    if data.sleep then
        self.sleep = data.sleep
    end
    -- -- local name = data.name  -- 这个时候self.inst.prefab还没有得到
    -- self.inst:AddTag("wg_equip_skill")
    -- self.desc = data.desc
end

function WgActionTool:GetRequire(attr, doer)
    if attr == "mana" then
        if doer and doer.components.tp_val_hollow
        and doer.components.tp_val_hollow:CanReduceManaCost() then
            return self.mana * .2
        end
        return self.mana
    end
end

function WgActionTool:CostRequire(attr, doer)
    if attr == "mana" then
        doer.components.tp_val_mana:DoDelta(-self:GetRequire("mana", doer))
        if doer and doer.components.tp_val_hollow
        and doer.components.tp_val_hollow:CanReduceManaCost() then
            doer.components.tp_val_hollow:EffectReduceManaCost()
        end
    end
end

function WgActionTool:Test(doer)
    -- 正在工作
    if doer.sg:HasStateTag("doing")
    -- 钢羊粘液
    or doer.sg:HasStateTag("pinned") then
        return
    end
    -- 骑牛
    if not self.riding_enabled 
    and doer.components.rider:IsRiding()
    then
        return
    end
    -- 驾车
    if not self.vehicle_enabled 
    and doer.components.wg_vehicle_owner
    and doer.components.wg_vehicle_owner:IsDriving()
    then
        return
    end
    -- 驾驶船
    if self.no_drving
    and doer.components.driver:GetIsDriving()
    then
        return
    end
    -- purify表净化技能
    if not self.purify
    and (doer:HasTag("wg_slience")
    or doer:HasTag("wg_sneer")
    or (doer.components.freezable 
    and doer.components.freezable:IsFrozen())) then
        return
    end
    -- move表位移技能
    if self.move 
    and doer:HasTag("wg_imprison") then
        return
    end
    -- 需要激活
    if self.sleep
    and not self.inst:HasTag("skill_wake") then
        return
    end
    -- 冷却
    if self.cd and self.inst.components.wg_recharge 
    and not self.inst.components.wg_recharge:IsRecharged() then
        return
    end
    -- 魔法
    if self.mana and doer.components.tp_val_mana
    and doer.components.tp_val_mana:GetCurrent() < self:GetRequire("mana", doer) then
        return
    end
    -- 精力
    if self.vigor and doer.components.tp_val_vigor
    and doer.components.tp_val_vigor:IsEmpty() then
        return
    end
    if self.test then
        if not self.test(self.inst, doer) then
            return
        end
    end
    return true
end

function WgActionTool:Click(doer)
    if self.click_fn and self.click_no_action then
        self.click_fn(self.inst, doer)
        doer:PushEvent("tp_equip_skill", {owner=doer, equip=self.inst})
    else
        local ba = self:GetBufferedAction()
        -- assert(ba, "buffered_action can't be nil")
        -- local player = self.inst.components.equippable.owner
        local player = doer
        if ba and player then
            if self.on_push then
                self.on_push(self.inst, doer, ba)
            end
            player:PushBufferedAction(ba)
            doer:PushEvent("tp_equip_skill", {owner=doer, equip=self.inst})
        else
        end
    end
end

function WgActionTool:DoSkillEffect(act)
    assert(self.effect_fn, string.format("%s effect_fn can't be nil", tostring(self.inst)) )
    -- 冷却
    if self.cd and self.inst.components.wg_recharge then
        self.inst.components.wg_recharge:SetRechargeTime(self.cd)
    end
    -- 魔法
    if self.mana and act.doer.components.tp_val_mana then
        self:CostRequire("mana", act.doer)
    end
    -- 精力
    if self.vigor and act.doer.components.tp_val_vigor then
        act.doer.components.tp_val_vigor:DoDelta(-self.vigor)
    end
    self.effect_fn(self.inst, act.doer, act.target, act.pos)
end

function WgActionTool:CheckReticule()
    -- 如果技能没有显示
    if self.inst.components.wg_reticule 
    and not self.inst.components.wg_reticule:IsShown() then
        return 
    end
    return true
end

function WgActionTool:GetActionData()
    local pos = TheInput:GetWorldPosition()
    local target = TheInput:GetWorldEntityUnderMouse()
    local doer = self.inst.components.equippable.owner
    local data = {
        doer = doer, target = target, pos = pos,
    }
    return data
end

-- 获取action
function WgActionTool:GetBufferedAction()
    local fn = self.get_action_fn
    if fn then
        local data = self:GetActionData()
        local action = fn(self.inst, data)
        if action and action.distance then
            if data.pos==nil and data.target==nil then
                return
            end
            -- 计算距离
            local pos = data.pos or data.target:GetPosition()
            local pos2 = data.doer:GetPosition()
            if action.distance*action.distance<distsq(pos, pos2) then
                return
            end
        end
        if action then
            local ba = BufferedAction(data.doer, data.target, action, self.inst, data.pos)
            return ba
        end
    end
end

function WgActionTool:CollectActions(data, actions)
    if self.get_action_fn then
        local action = self.get_action_fn(self.inst, data)
        if action then
            table.insert(actions, action)
        end
    end
end

function WgActionTool:CollectPointActions(doer, pos, actions, right)
    if right == self.right and self:Test(doer) and self:CheckReticule() then
        local data = { doer=doer, pos=pos }
        self:CollectActions(data, actions)
	end
end

function WgActionTool:CollectEquippedActions(doer, target, actions, right)
    if right == self.right and self:Test(doer) and self:CheckReticule() then
        local data = { doer=doer, target=target }
        self:CollectActions(data, actions)
	end
end

local colours = {
    {1, 1, 1, 1},
    {135/255, 206/255, 235/255, 1},
    {138/255, 43/255, 226/255, 1},
    {255/255, 128/255, 0, 1},
    {255/255, 215/255, 0, 1},
}
function WgActionTool:GetSkillDescColour(doer)
    if self.quality then
        return colours[self.quality]
    end
end

return WgActionTool