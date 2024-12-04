local BuffManager = Sample.BuffManager
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local AssetUtil = require "extension/lib/asset_util"

local WgBuffSlot = Class(Widget, function(self)
    Widget._ctor(self, "WgBuffSlot")
    self.bg = self:AddChild(UIAnim())
    self.bg:GetAnimState():SetBank("spoiled_meter")
    self.bg:GetAnimState():SetBuild("spoiled_meter")
    self.bg:GetAnimState():SetPercent("anim", 0)
    self.bg:SetClickable(false) 
    
    self.image = self:AddChild(Image(
        AssetUtil:GetImage(AssetUtil:MakeImg("ash")) ))
    self.stack = self:AddChild(Text(NUMBERFONT, 50))
    self.desc = ""
    self.timer = self:AddChild(Text(NUMBERFONT, 40))
    self.timer:SetPosition(0, 60, 0)
    self.GetWargonString = function()
        return self.desc
    end
end)

function WgBuffSlot:SetByData(data)
    self.id = data.id
    if data.is_debuff then
        self.bg:GetAnimState():SetMultColour(1, .1, .1, 1)
    else
        self.bg:GetAnimState():SetMultColour(1, 1, 1, 1)
    end
    if data.img then
        -- local atlas, img = AssetUtil:GetImage(data.img)
        local atlas, img = data.img:GetImage()
        self.image:SetTexture(atlas, img)
    end
    if data.percent then
        self:SetPercent(data.percent)
    end
    if data.desc then
        self.desc = data.desc
    end
    if data.time then
        self:SetTime(data.time)
    end
    self:SetStack(data.stack)
end

function WgBuffSlot:SetStack(stack)
    if stack then
        self.stack:SetString("x"..tostring(stack))
    else
        self.stack:SetString("")
    end
end

function WgBuffSlot:SetTime(time)
    self.timer:SetString(string.format("%.1fs", time or 0))
end

function WgBuffSlot:SetPercent(percent)
    if percent then
        self.bg:GetAnimState():SetPercent("anim", 1-percent)
    end
end

function WgBuffSlot:OnGainFocus()
    WgBuffSlot._base:OnGainFocus(self)
    if self.gain_focus then
        self:gain_focus()
    end
end

function WgBuffSlot:OnLoseFocus()
    WgBuffSlot._base:OnLoseFocus()
    if self.lose_focus then
        self:lose_focus()
    end
end

local uipos = {}
for i = 0, 1 do
    for j = 0, 8 do
        table.insert(uipos, Vector3(j*40, i*-40, 0))
    end
end
local MAX_SLOT_NUM = #uipos

local WgBuffBar = Class(Widget, function(self, owner)
    Widget._ctor(self, "WgBuffBar")
    self.owner = owner
    self.root = self:AddChild(Widget("ROOT"))

    -- 统计显示的buff数量
    self.buff_num = 0
    self.buff_bar = {}
    self.buff_list = {}
    self.buff_buffer = {}
    self.buff_root = self:AddChild(Widget("BUFF_ROOT"))
    self.tip = self:AddChild(Text(TITLEFONT, 30))

    self.inst:ListenForEvent("wg_add_buff", function(inst, data)
        -- 这里面要添加img，stack，percent，is_debuff
        self:AddBuffById(data.id)
    end, owner)
    self.inst:ListenForEvent("wg_rm_buff", function(inst, data)
        self:ClearBuff(data)
    end, owner)
    self.inst:ListenForEvent("wg_buff_time_delta", function(inst, data)
        self:SetBuffPercent(data)
    end, owner)
    self.inst:ListenForEvent("wg_buff_stack_delta", function(inst, data)
        self:SetBuffStack(data)
    end, owner)
end)

function WgBuffBar:AddBuffById(id)
    local data = {id = id}
    local buff_data = BuffManager:GetDataById(data.id)
    -- 显示图片的才加入
    if not buff_data:IsHidden() and self.owner.components.wg_buff then
        data.percent = self.owner.components.wg_buff:GetBuffPercent(data.id)
        data.stack = self.owner.components.wg_buff:GetBuffStack(data.id)
        data.desc = self.owner.components.wg_buff:GetBuffDescription(data.id)
        data.is_debuff = buff_data:IsDebuff()
        data.img = buff_data.img
        self:AddBuff(data)
    end
end

function WgBuffBar:AddBuff(data)
    -- 之前没有这个buff
    if data.img and self.buff_list[data.id] == nil then
        -- buff_bar满没有，没满加一个buff_slot
        self.buff_num = self.buff_num + 1
        if self.buff_num <= MAX_SLOT_NUM then
            local idx = self.buff_num
            -- 动态添加
            if self.buff_bar[idx] == nil then
                self.buff_bar[idx] = self.buff_root:AddChild(WgBuffSlot())
                self.buff_bar[idx]:SetPosition(uipos[idx])
                self.buff_bar[idx]:SetScale(.5, .5, .5)
            end
            -- 改变信息
            self.buff_bar[idx]:SetByData(data)
            -- 重见天日
            self.buff_bar[idx]:Show()
            self:SetBuffSlotFocus(idx)
            self.buff_list[data.id] = self.buff_bar[idx]
        else
            -- buff_num是记录显示的buff数
            self.buff_num = MAX_SLOT_NUM
            -- 多的暂存起来，重新获得时，也会随着改变
            self.buff_buffer[data.id] = data
        end
        -- 之前有这个buff，主要是修改percent和stack
    else
        local buff_slot = self:GetBuffSlotById(data.id)
        buff_slot:SetPercent(data.percent)
        buff_slot:SetTime(data.time)
        buff_slot:SetStack(data.stack)
    end
end

function WgBuffBar:ClearBuff(data)
    local buff_slot = self.buff_list[data.id]
    self.buff_buffer[data.id] = nil
    if buff_slot then
        buff_slot:Hide()
        self.buff_list[data.id] = nil
        self.buff_num = self.buff_num - 1
        self:Reset()
        local cnt = self.buff_num
        for k, v in pairs(self.buff_buffer) do
            self:AddBuff(v)
            -- 装不下的就不重复放入buff_buffer了
            cnt = cnt + 1
            if cnt > MAX_SLOT_NUM then
                break
            end
        end
    end
end

function WgBuffBar:Reset()
    local len = #self.buff_bar
    for i = 1, len-1 do
        local left_slot = self.buff_bar[i]
        local right_slot = self.buff_bar[i+1]
        -- 左边隐藏，右边显示，就互换
        if left_slot and right_slot 
        and not left_slot.shown and right_slot.shown then
            self.buff_bar[i] = right_slot
            self.buff_bar[i+1] = left_slot
            -- 需要改变focus
            right_slot:SetPosition(uipos[i])
            self:SetBuffSlotFocus(i)
            left_slot:SetPosition(uipos[i+1])
            self:SetBuffSlotFocus(i+1)
        end
    end
end

function WgBuffBar:SetBuffSlotFocus(idx)
    self.buff_bar[idx].gain_focus = function()
        -- self.tip:Show()
        -- self.tip:SetString(self.buff_bar[idx].desc)
        -- self.tip:SetPosition(uipos[idx])
    end
    self.buff_bar[idx].lose_focus = function()
        -- self.tip:Hide()
    end
end

function WgBuffBar:GetBuffSlotById(id)
    return self.buff_list[id]
end

function WgBuffBar:SetBuffPercent(data)
    local buff_slot = self:GetBuffSlotById(data.id)
    -- 这个buff可能没有图像，不一定存在与buff栏
    if buff_slot then
        buff_slot:SetPercent(data.percent)
        buff_slot:SetTime(data.time)
    end
end

function WgBuffBar:SetBuffStack(data)
    local buff_slot = self:GetBuffSlotById(data.id)
    if buff_slot then
        buff_slot:SetStack(data.stack)
    end
end

-- 重载时初始化所有buff
function WgBuffBar:Init()
    if self.owner.components.wg_buff then
        local buffs = self.owner.components.wg_buff.buffs
        for k, v in pairs(buffs) do
            self:AddBuffById(k)
        end
    end
end

return WgBuffBar