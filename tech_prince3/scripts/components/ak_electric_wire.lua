local FxManager = Sample.FxManager

local AkElectricWire = Class(function(self, inst)
    self.inst = inst
    self.inst:AddTag("ak_electric_wire")





    self.anims = {
        "off", "working_pre", "working_loop", "working_pst"
    }
    self.cur_load = 0
    self.max_load = 0
    self.timer = 0


    inst:ListenForEvent("ak_over_load_end", function(inst, data)

        if self.fx then
            self.fx:WgRecycle()
            self.fx = nil
        end



    end)
    inst:AddComponent("ak_electrical")
    inst.components.ak_electrical.type = "wire"
end)

function AkElectricWire:Overload()
    self.timer = self.timer + 1
    if self.timer >= 10 then
        if self.inst.components.workable then
            self.inst.components.workable:Destroy(self.inst)
        end
    end

    if self.fx == nil then
        self.fx = FxManager:MakeFx("over_load", self.inst)
        self.inst:AddChild(self.fx)
    end











end

function AkElectricWire:Animation()
    if self.inst.AnimState:IsCurrentAnimation(self.anims[1]) then
        self.inst.AnimState:PlayAnimation(self.anims[2])
        self.inst.AnimState:PushAnimation(self.anims[3], false)
        self.inst.AnimState:PushAnimation(self.anims[4], false)
        self.inst.AnimState:PushAnimation(self.anims[1], false)
    end
end

function AkElectricWire:FindGenerator()
    local generator = nil

    if self.generator and self.generator:IsValid()
    and not self.generator.components.ak_generator:IsEmpty() then
        generator = self.generator
    else

        local x, y, z = self.inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 15, {"ak_generator"})
        for k, v in pairs(ents) do
            if not v.components.ak_generator:IsEmpty() then
                generator = v
                break
            end
        end

        if not generator then
            local x, y, z = self.inst:GetPosition():Get()
            local ents = TheSim:FindEntities(x, y, z, 15, {"ak_electric_wire"})
            for k, v in pairs(ents) do
                local machine = v.components.ak_electric_wire.generator

                if machine and machine:IsValid()
                and machine.components.ak_generator
                and not machine.components.ak_generator:IsEmpty() then
                    generator = machine
                    break
                end
            end
        end
    end

    self.generator = generator
    return generator
end

function AkElectricWire:GetMachine()
    local x, y, z = self.inst:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 15, {"ak_electric"})
    return ents
end
























function AkElectricWire:PowerSupply()
    local generator = self:FindGenerator()
    if generator then

        local ents = self:GetMachine()
        for k, v in pairs(ents) do
            local need = v.components.ak_electric:GetCost()
            if need >= 10 then
                local cmp = generator.components.ak_generator

                cmp:Animation()
                self:Animation()

                local cost = math.min(cmp.current, need)
                cmp:DoDelta(-cost)


                FxManager:MakeFx("lightning_rod_fx", v)
                v.components.ak_electric:DoDelta(cost)
            end

            if generator.components.ak_generator:IsEmpty() then
                break
            end
        end
    end
end

function AkElectricWire:OnSave()
    return {
        timer = self.timer,
    }
end

function AkElectricWire:OnLoad(data)
    if data then
        self.timer = data.timer or 0
    end
end

function AkElectricWire:GetWargonString()





    local s = string.format("当前过载:%d/%d", self.cur_load, self.max_load)
    s = s..string.format("\n过载时间:%d/10", self.timer)
    return s
end

return AkElectricWire