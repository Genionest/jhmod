-- 快速收获
local state = State{
    name = "fast_harvest",
    tags = {"doing", "busy"},       
    onenter = function(inst)
        inst.AnimState:PlayAnimation("atk")
        inst.components.locomotor:StopMoving()
        inst.sg:SetTimeout(8*FRAMES)            
    end,
    timeline=
    {
        TimeEvent(4*FRAMES, function( inst )
            inst.sg:RemoveStateTag("busy")
        end),
        TimeEvent(10*FRAMES, function( inst )
            inst.sg:RemoveStateTag("doing")
            inst.sg:AddStateTag("idle")
        end),
    },
    ontimeout = function(inst)
        inst:PushEvent("wg_fast_harvest")
        inst:PerformBufferedAction()
	end,
    events=
    {
        EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end end ),
    },
}
AddStategraphState("wilson", state)
AddStategraphState("wilsonboating", state)

local function fast_harvest(inst, action)
    if action.target.components.pickable then 
        if action.target:HasTag("wg_can_fast_harvest") then
            if inst:HasTag("wg_fast_harvester") then
                return "fast_harvest"
            end
        end
        if action.target.components.pickable.quickpick then
            return "doshortaction"
        end
        return "dolongaction"
    end
end
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.PICK, fast_harvest))
AddStategraphActionHandler("wilsonboating", ActionHandler(ACTIONS.PICK, fast_harvest))

local crops = {
	"grass","sapling","reeds","reeds_water","marsh_bush","berrybush",
    "slow_farmplot","fast_farmplot","red_mushroom","green_mushroom",
    "blue_mushroom","flower_cave","flower_cave_double",
    "flower_cave_triple","plant_normal","grass_water",
    "seaweed_planted","lotus","coffeebush", "limpetrock", "berrybush2"    
}
for k, v in pairs(crops) do
	AddPrefabPostInit(v, function(inst)
		inst:AddTag("wg_can_fast_harvest")
	end)
end