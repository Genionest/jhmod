local Util = require "extension.lib.wg_util"
local Kit = require "extension.lib.wargon"
local AssetMaster = Sample.AssetMaster
local AssetUtil = require "extension.lib.asset_util"

local WORKING_TIME = 10

local WgWorkbench = Class(function(self, inst)
    self.inst = inst
    self.product = nil
    self.max = 100
    self.current = 0
    self.ingds = nil
    self.stack = nil
    self.inst:ListenForEvent("itemget", function(inst, data)
        if self.current <= 0 and self.task == nil then
            self:ConsumeIngredients()
        end
    end)
end)

function WgWorkbench:CountIngredients()
    local ingds = self.ingds
    local cmp = self.inst.components.container
    if cmp and ingds and self.product then
        for _, ingd in pairs(ingds) do
            if cmp:Has(ingd:GetName(), ingd:GetStack()) then

            else
                return
            end
        end
        return true
    end
end

function WgWorkbench:Consume()
    if self:CountIngredients() then
        for k, v in pairs(self.ingds) do
            self.inst.components.container:ConsumeByName(k, v)
        end
        self:SetVal(WORKING_TIME)
        self:Start()
    else
        self:Stop()
    end
end

function WgWorkbench:ConsumeIngredients()
    local ingds = self.ingds
    local cmp = self.inst.components.container
    if cmp and ingds and self.product then
        local can = true
        for _, ingd in pairs(ingds) do
            if cmp:Has(ingd:GetName(), ingd:GetStack()) then
            else
                can = false
                break
            end
        end
        if can then
            for _, ingd in pairs(ingds) do
                cmp:ConsumeByName(ingd:GetName(), ingd:GetStack())
            end
            self:SetVal(WORKING_TIME)
            self:Start()
        else
            -- self:Stop()
        end
    end
end

function WgWorkbench:CheckNext()
    local ingds = self.ingds
    local cmp = self.inst.components.container
    if cmp and ingds and self.product then
        local can = true
        for _, ingd in pairs(ingds) do
            if cmp:Has(ingd:GetName(), ingd:GetStack()) then
            else
                can = false
                break
            end
        end
        if can then
            for _, ingd in pairs(ingds) do
                cmp:ConsumeByName(ingd:GetName(), ingd:GetStack())
            end
            self:SetVal(WORKING_TIME)
            self:Start()
        else
            self:Stop()
        end
    end
end

function WgWorkbench:Start()
    if self.task == nil then
        self.task = self.inst:DoPeriodicTask(1, function()
            if not self.consume_test
            or self.consume_test(self.inst) then
                self:DoDelta(-1)
                if self.consume_fn then
                    self.consume_fn(self.inst)
                end
                if self.running == nil and self.task then
                    self.running = true
                    if self.run_start then
                        self.run_start(self.inst)
                    end
                    self.inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/smelter/move_1")
                    self.inst.SoundEmitter:KillSound("snd")
                    self.inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/smelter/smelt_LP", "snd")
                end
            else
                if self.running then
                    self.running = nil
                    if self.run_stop then
                        self.run_stop(self.inst)
                    end
                end
            end
        end)
    end
end

function WgWorkbench:Stop()
    if self.task then
        self.task:Cancel()
        self.task = nil
        -- if self.running then
        --     self.inst:DoTaskInTime(0, function()
        --         self.running = nil
        --         if self.run_stop then
        --             self.run_stop(self.inst)
        --         end
        --     end)
        -- end
    end
    if self.running then
        if self.run_stop then
            self.run_stop(self.inst)
        end
        self.inst.SoundEmitter:KillSound("snd")
    end
    self.running = nil
end

function WgWorkbench:DoDelta(dt)
    local old = self.current
    self.current = math.min(self.max , math.max(0, self.current+dt))
    if old>0 and self.current<=0 then
        self:DoneWork()
    end
end

function WgWorkbench:DoneWork()
    local item = SpawnPrefab(self.product)
    item.Transform:SetPosition(self.inst:GetPosition():Get())
    if item.components.stackable and self.stack then
        item.components.stackable:SetStackSize(self.stack)
    end
    local ent = FindEntity(self.inst, 5, function(target, inst)
        return not target.components.container:IsFull() 
    end, {"ak_storage_bin"})
    if ent then
        ent.components.container:GiveItem(item)
        -- fx
    else
        if self.inst.components.lootdropper then
            self.inst.components.lootdropper:DropLootPrefab(item)
        else
            Kit:throw_item(item)
        end
    end
    -- self:ConsumeIngredients()
    self:CheckNext()
end

function WgWorkbench:DoWork(product, ingds, stack)
    assert(product, "product can't be nil")
    assert(ingds, "ingds can't be nil")

    if self.task==nil and (not self.test or self.test(self.inst)) then
        self.product = product
        self.ingds = ingds
        self.stack = stack
        self:ConsumeIngredients()
    end
end

function WgWorkbench:SetVal(amount)

    self:DoDelta(amount-self.current)
end

function WgWorkbench:GetProductUimg()
    local product = self.product
    local Uimg
    if AssetMaster:HasAssetData(product) then
        Uimg = AssetMaster:GetUimg(product)
    else
        -- 不存在则为原版物品
        Uimg = AssetUtil:MakeImg(product)
    end
    return Uimg
end

function WgWorkbench:OnSave()
    return {
        product = self.product,
        ingds = deepcopy(self.ingds),
        stack = self.stack,
        current = self.current,
    }
end

function WgWorkbench:OnLoad(data)
    if data then
        self.product = data.product
        self.ingds = deepcopy(data.ingds or data.ingd)
        self.stack = data.stack
        self.current = data.current or 0
        if self.current > 0 then
            self:Start()
        end
    end
end

function WgWorkbench:GetWargonString()
    local product
    if self.product then
        product = Util:GetScreenName(self.product)
    else
        product = "无"
    end
    local s = string.format("制造物:%s", product)
    if self.stack then
        s = s..string.format("\n造物堆叠:%d", self.stack)
    end
    s = s..string.format("\n剩余制造时间:%ds", self.current)
    s = s..string.format("\n正在运行:%s", self.task and "是" or "否")
    return s
end

return WgWorkbench