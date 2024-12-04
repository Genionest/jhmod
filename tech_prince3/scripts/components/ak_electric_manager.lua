local FxManager = Sample.FxManager

local Power = Class(function(self)
    self.g = 0
    self.b = 0
    self.b_c = 0
end)

function Power:init()
    self.g = 0
    self.b = 0
    self.b_c = 0
end

function Power:cost(dt)
    if self.g >= dt then
        self.g = self.g - dt
    elseif self.g + self.b >= dt then
        dt = dt - self.g
        self.g = 0
        self.b = self.b - dt
        self.b_c = self.b_c + dt
    end
end

function Power:get()
    return self.g + self.b
end




























local AkElectricManager = Class(function(self, inst)
    self.inst = inst
    self.temp_power = Power()
    self.power_system = {}
    self.task = inst:DoPeriodicTask(1, function()
        self:PowerSupply()
    end)
end)

function AkElectricManager:RemoveSystem(system)

    for k, v in pairs(self.power_system) do
        if v == system then
            table.remove(self.power_system, k)
        end
    end
    system = nil
end

function AkElectricManager:MergeSystem(system, target)

    local target_system = target.components.ak_electrical.system
    for group, t in pairs(target_system) do
        for machine, _ in pairs(t) do

            machine.components.ak_electrical.system = nil
            self:JoinSystem(machine, system)
        end
    end

    self:RemoveSystem(target_system)
    return system
end

function AkElectricManager:MergeAroundSystem(app, system)

    local x, y, z = app:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 15, {"ak_electric_wire"})
    for k, v in pairs(ents) do
        if v.components.ak_electrical 
        and v.components.ak_electrical.system
        and v.components.ak_electrical.system ~= system then
            system = self:MergeSystem(system, v)
        end
    end
    return system
end

function AkElectricManager:CreateSystem(app)

    local system = {

        generators = {},

        batterys = {},

        wires = {},

        appliances = {},
    }
    system.wires[app] = true













    table.insert(self.power_system, system)
    return system
end

function AkElectricManager:JoinSystem(app, system)

    app.components.ak_electrical.system = system
    system[app.components.ak_electrical.type.."s"][app] = true
end

function AkElectricManager:FindSystem(app)

    local x, y, z = app:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 15, {"ak_electric_wire"})
    for k, v in pairs(ents) do
        if v.components.ak_electrical 
        and v.components.ak_electrical.system then

            return v.components.ak_electrical.system
        end
    end
end

function AkElectricManager:ConnectAroundAppliances(app)

    local system = app.components.ak_electrical.system
    local x, y, z = app:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 15, {"ak_electrical"}, {"ak_electric_wire"})
    for k, v in pairs(ents) do
        if v.components.ak_electrical 
        and v.components.ak_electrical.system == nil then

            self:JoinSystem(v, system)
        end
    end
end

function AkElectricManager:CheckAndJoinSystem(app)












    if app.components.ak_electrical.system then

        return
    end
    
    if app.components.ak_electric_wire then


        local system = self:FindSystem(app)
        if system == nil then



            system = self:CreateSystem(app)
            self:JoinSystem(app, system)
        else


            local new_system = self:MergeAroundSystem(app, system)
            self:JoinSystem(app, new_system)
        end


        self:ConnectAroundAppliances(app)
    else

        local system = self:FindSystem(app)
        if system then

            self:JoinSystem(app, system)
        end
    end




























































































































end

function AkElectricManager:DisjoinSystem(app)

    local system = app.components.ak_electrical.system
    if system then
        system[app.components.ak_electrical.type.."s"][app] = nil
        app.components.ak_electrical.system = nil
    end
end

function AkElectricManager:CheckAndDisjoinSystem(app)






    local system = app.components.ak_electrical.system


    if app.components.ak_electric_wire then


        system.wires[app] = nil

        local machines = {}
        for group, t in pairs(system) do
            for ent, _ in pairs(t) do

                ent.components.ak_electrical.system = nil
                table.insert(machines, ent)
            end
        end

        self:RemoveSystem(system)
        app.components.ak_electrical.system = nil

        for k, v in pairs(machines) do
            self:CheckAndJoinSystem(v)
        end
















    else

        self:DisjoinSystem(app)
    end
    

    if system then

        local recycle = true
        for k, v in pairs(system) do
            for k2, v2 in pairs(v) do
                if v2 then
                    recycle = nil
                    break
                end
            end
        end
        if recycle then

            self:RemoveSystem(system)
        end
    end










































end

function AkElectricManager:PowerSupply()

    for k, v in pairs(self.power_system) do
        local power = self.temp_power
        power:init()


        for generator, _ in pairs(v.generators) do
            if generator:IsValid() and not generator:HasTag("flooded")
            and generator.components.ak_generator:IsSupplying() then
                power.g = power.g + generator.components.ak_generator.power

            end
        end

        for battery, _ in pairs(v.batterys) do
            if battery:IsValid()
            and not battery:HasTag("flooded") then
                power.b = power.b + battery.components.ak_battery.current
            end

        end


        local load = 0
        for appliance, _ in pairs(v.appliances) do
            if power:get() <= 0 then

                break
            end
            if appliance:IsValid() 
            and not appliance:HasTag("flooded") then
                local need = appliance.components.ak_electric:GetCost()


                local charge_p = appliance.components.ak_electric.charge_p or .7
                if appliance.components.ak_electric:GetPercent() < charge_p then
                    load = load + appliance.components.ak_electric.load
                    local cost = math.min(power:get(), need)
                    power:cost( cost )
                    appliance.components.ak_electric:DoDelta(cost)

                    FxManager:MakeFx("lightning_rod_fx", appliance)


                end
            end
        end


        for wire, _ in pairs(v.wires) do
            if wire:IsValid() and not wire:HasTag("flooded") then

                wire.components.ak_electric_wire.cur_load = load

                if load > wire.components.ak_electric_wire.max_load then


                    wire.components.ak_electric_wire:Overload()
                    wire:PushEvent("ak_over_load")
                else
                    wire:PushEvent("ak_over_load_end")
                end
            end
        end


        if power.g > 0 then

            for battery, _ in pairs(v.batterys) do
                if battery:IsValid()
                and not battery:HasTag("flooded") then
                    local need = battery.components.ak_battery:GetCost()
                    if need >= 10 then
                        local cost = math.min(power.g, need)
                        power.g = power.g - cost
                        battery.components.ak_battery:DoDelta(cost)

                        FxManager:MakeFx("lightning_rod_fx", battery)

                    end
                end
                if power.g <= 0 then

                    break
                end
            end
        end


        if power.b_c > 0 then

            for battery, _ in pairs(v.batterys) do
                if battery:IsValid() 
                and not battery:HasTag("flooded") then
                    local current = battery.components.ak_battery.current
                    local cost = math.min(current, power.b_c)
                    power.b_c = power.b_c - cost
                    battery.components.ak_battery:DoDelta(-cost)
                end

                if power.b_c <= 0 then

                    break
                end
            end
        end
    end
end






















function AkElectricManager:ShowSystem()
    for k, system in pairs(self.power_system) do
        print("system-"..k..":", system)
        for group, t in pairs(system) do
            print(group..":")
            for app, _ in pairs(t) do
                print(app)
            end
        end
    end
end

return AkElectricManager