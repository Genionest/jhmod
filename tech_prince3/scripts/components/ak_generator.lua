local FxManager = Sample.FxManager

local AkGenerator = Class(function(self, inst)
    
    self.inst = inst
    self.inst:AddTag("ak_generator")

    self.anims = {
        "off", "working_pre", "working_loop", "working_pst"
    }
    self.power = 100
    self.max = 100
    self.current = 0

    self.on = true
    self.sound_timer = 0

    inst:ListenForEvent("ak_generator_start", function()
        inst.AnimState:PlayAnimation(self.anims[2])
        inst.AnimState:PushAnimation(self.anims[3], true)
    end)
    inst:ListenForEvent("ak_generator_stop", function()
        inst.AnimState:PlayAnimation(self.anims[4])
        inst.AnimState:PushAnimation(self.anims[1])
    end)
    inst:ListenForEvent("ak_generator_on", function()
        if not self:IsEmpty() then
            inst.AnimState:PlayAnimation(self.anims[2])
            inst.AnimState:PushAnimation(self.anims[3], true)
        end
    end)
    inst:ListenForEvent("ak_generator_off", function()
        inst.AnimState:PlayAnimation(self.anims[4])
        inst.AnimState:PushAnimation(self.anims[1])
    end)
    inst:AddComponent("ak_electrical")
    inst.components.ak_electrical.type = "generator"
end)

function AkGenerator:Start()

    self.inst:PushEvent("ak_generator_start")
    if self.task == nil then
        self.task = self.inst:DoPeriodicTask(1, function()
            if self.on then
                self:DoDelta(-1)
                if self.consume_fn then
                    self.consume_fn(self.inst)
                end
            end
        end)
    end
end

function AkGenerator:Stop()

    self.inst:PushEvent("ak_generator_stop")
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

-- 
function AkGenerator:IsSupplying()
    return self.task ~= nil and self.on
end

function AkGenerator:IsRunning()
    return self.task ~= nil
end

function AkGenerator:SetMax(amount)
    self.max = amount
end

function AkGenerator:IsEmpty()
    return self.current<=0
end

function AkGenerator:GetCost()
    return self.max - self.current
end

function AkGenerator:DoDelta(dt)
    self.current = self.current + dt
    self.current = math.max(0, self.current)
    self.current = math.min(self.max, self.current)

    -- X, 改为由smart_battery去start
    -- if self.task == nil and self.current > 0 and self.on then
    -- self.on只控制dodelta，取消task的话，需要电的时候它不会重新启动task
    if self.task == nil and self.current > 0 then

        self:Start()
    end
    -- if self.task and (not self.on or self.current <= 0) then
    if self.task and (self.current <= 0) then

        self:Stop()
    end
end

function AkGenerator:Animation()
    if self.inst.AnimState:IsCurrentAnimation(self.anims[1]) then
        self.inst.AnimState:PlayAnimation(self.anims[2])
        self.inst.AnimState:PushAnimation(self.anims[3], false)
        self.inst.AnimState:PushAnimation(self.anims[4], false)
        self.inst.AnimState:PushAnimation(self.anims[1], false)
    end
end

function AkGenerator:FindGenerator()
    local generator = nil

    if not self:IsEmpty() then
        generator = self.inst
    end
    return generator
end

function AkGenerator:GetMachine()
    local x, y, z = self.inst:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 15, {"ak_electric"})

    return ents
end

function AkGenerator:SpawnFX()
    FxManager:MakeFx("lightning_rod_fx", self.inst)
end

function AkGenerator:PowerSupply()
    local generator = self:FindGenerator()
    if generator then

        local ents = self:GetMachine()
        for k, v in pairs(ents) do
            local need = v.components.ak_electric:GetCost()
            if need >= 10 then
                local cmp = generator.components.ak_generator

                cmp:Animation()

                local cost = math.min(cmp.current, need)
                cmp:DoDelta(-cost)

                self:SpawnFX()
                v.components.ak_electric:DoDelta(cost)
            end

            if generator.components.ak_generator:IsEmpty() then
                break
            end
        end
    end
end

function AkGenerator:OnSave()
    return {
        current = self.current,
    }
end

function AkGenerator:OnLoad(data)
    if data then
        self.current = data.current or 0
        self:DoDelta(0)
    end
end

function AkGenerator:GetWargonString()

    local s = string.format("发电功率:%d\n发电时间:%d/%d\n发电信号:%s\n正在运行:%s", 
        self.power, self.current, self.max, self.on and "是" or "否", self.task and "是" or "否")
    return s
end

return AkGenerator