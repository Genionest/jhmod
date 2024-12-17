require "prefabutil"
local AkEditorScreen = require "screens.ak_editor_screen"

local assets =
{
	-- Asset("ANIM", "anim/campfire.zip"),
    -- Asset("INV_IMAGE", "campfire"),
    Asset("ANIM", "anim/tp_campfire.zip"),
}

local prefabs =
{
    -- "campfirefire",
}    

local function onignite(inst)
    if not inst.components.cooker then
        inst:AddComponent("cooker")
    end
end

local function onextinguish(inst)
    if inst.components.cooker then
        inst:RemoveComponent("cooker")
    end
    if inst.components.fueled then
        inst.components.fueled:InitializeFuelLevel(0)
    end
end

local function destroy(inst)
	local time_to_wait = 1
	local time_to_erode = 1
	local tick_time = TheSim:GetTickTime()

	if inst.DynamicShadow then
        inst.DynamicShadow:Enable(false)
    end

	inst:StartThread( function()
		local ticks = 0
		while ticks * tick_time < time_to_wait do
			ticks = ticks + 1
			Yield()
		end

		ticks = 0
		while ticks * tick_time < time_to_erode do
			local erode_amount = ticks * tick_time / time_to_erode
			inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
			ticks = ticks + 1
			Yield()
		end
		inst:Remove()
	end)
end

local function OnSave(inst, data)
    data.queued_charcoal = inst.queued_charcoal or nil
end

local function OnLoad(inst, data)
    if data ~= nil and data.queued_charcoal then
        inst.queued_charcoal = true
    end
end

local function fn(Sim)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "tp_campfire.tex" )
	minimap:SetPriority( 1 )

    anim:SetBank("firepit")
    anim:SetBuild("tp_campfire")
    anim:PlayAnimation("idle",false)
  
    -- inst:AddTag("campfire")
    
    -- MakeObstaclePhysics(inst, .2)    
    -----------------------

    -----------------------
    -- inst:AddComponent("propagator")
    -----------------------
    
    inst:AddComponent("burnable")
    -- 防止跳时间后熄火
    inst.components.burnable.LongUpdate = function()
    end
    --inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:AddBurnFX("tp_campfire_fire", Vector3(0,.4,0) )
    inst.components.burnable:MakeNotWildfireStarter()
    -- inst:ListenForEvent("onextinguish", onextinguish)
    inst:ListenForEvent("onignite", onignite)

    -------------------------
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.FIREPIT_FUEL_MAX
    inst.components.fueled.accepting = true
    
    inst.components.fueled:SetSections(4)
    inst.components.fueled.bonusmult = TUNING.FIREPIT_BONUS_MULT
    inst.components.fueled.ontakefuelfn = function() 
        inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel") 
        -- 自动存档
        GetPlayer().components.autosaver:DoSave()

        -- local ent = FindEntity(inst, 4, function(target, inst)end, {"tp_puppet"})
        -- if not ent then
        --     GetPlayer().components.tp_puppet_mgr:SpawnPuppet(inst:GetPosition())
        -- end
    end
    inst.components.fueled.unlimited_fuel = true
    inst.components.fueled:SetUpdateFn( function()
        -- local rate = 1 
        -- if GetSeasonManager() and GetSeasonManager():IsRaining() then
        --     inst.components.fueled.rate = 1 + TUNING.FIREPIT_RAIN_RATE*GetSeasonManager():GetPrecipitationRate()
        -- end
        -- if inst:GetIsFlooded() then 
        --     rate = rate + TUNING.FIREPIT_FLOOD_RATE
        -- end 
        -- rate = rate +  GetSeasonManager():GetHurricaneWindSpeed() * TUNING.FIREPIT_WIND_RATE

        -- inst.components.fueled.rate = rate 
        if inst.components.burnable and inst.components.fueled then
            inst.components.burnable:SetFXLevel(3, .5)
        end
    end)
    
    inst.components.fueled:SetSectionCallback( function(section)
        -- if section == 0 then
        --     inst.components.burnable:Extinguish()

        --     if inst.queued_charcoal then
        --         local charcoal = inst.components.lootdropper:SpawnLootPrefab("charcoal")
        --         inst.queued_charcoal = nil

        --         local interior = GetInteriorSpawner():getPropInterior(inst)
        --         if interior then
        --             GetInteriorSpawner():AddPrefabToInterior(charcoal, interior)
        --         end
        --     end
        -- else
        
            
        --     if section == inst.components.fueled.sections then
        --         inst.queued_charcoal = true
        --     end
        -- end
        
        
        inst:AddTag("tp_campfire_burning")
        if not inst.components.burnable:IsBurning() then
            inst.components.burnable:Ignite()
        end
        
        inst.components.burnable:SetFXLevel(3, .5)
    end)
        
    inst.components.fueled:InitializeFuelLevel(0)

    -----------------------------
    
    inst:AddComponent("inspectable")
    -- inst.components.inspectable.getstatus = function(inst)
    --     local sec = inst.components.fueled:GetCurrentSection()
    --     if sec == 0 then 
    --         return "OUT"
    --     elseif sec <= 4 then
    --         local t= {"EMBERS","LOW","NORMAL","HIGH"} 
    --         return t[sec]
    --     end
    -- end
    
    --------------------
    
    -- inst.components.burnable:Ignite()
    -- inst:ListenForEvent( "onbuilt", function()
    --     anim:PlayAnimation("place")
    --     anim:PushAnimation("idle",false)
    --     inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    -- end)

    -- inst.OnSave = OnSave
    -- inst.OnLoad = OnLoad
    inst:AddComponent("tp_transporter")
    inst:AddComponent("ak_editor")
    inst.components.ak_editor:SetText("text")
    inst:AddComponent("wg_useable")
    inst.components.wg_useable.right = false
    inst.components.wg_useable.use = function(inst, doer)
        TheFrontEnd:PushScreen(AkEditorScreen(inst))
    end
    inst:AddComponent("wg_machine")
    inst.components.wg_machine.fn = function(inst, doer)
        inst.components.tp_transporter:DoTransport()
    end
    inst.components.wg_machine.test = function(inst, doer)
        local hounded = GetWorld().components.hounded
        local danger = FindEntity(inst, 10, function(target) 
            return target:HasTag("monster") 
                or target.components.combat 
                and target.components.combat.target == inst             
            end
        )
        
        if hounded and (hounded.warning or hounded.timetoattack <= 0) then
            danger = true
        end
        
        if danger then
            -- if doer.components.talker then
            --     doer.components.talker:Say("无法使用营火")
            -- end
            return
        end

        return inst:HasTag("tp_campfire_burning")
    end
    
    return inst
end

local Util = require "extension.lib.wg_util"
-- Util:AddString("tp_campfire", "无尽营火", "生生不息的火焰,是生命的本源;为其添火,即可召唤不灭人偶;可在燃烧的无尽营火之间传送")
Util:AddString("tp_campfire", "无尽营火", "生生不息的火焰,是生命的本源;为其添火,会进行存档;可在燃烧的无尽营火之间传送")

return Prefab( "common/objects/tp_campfire", fn, assets, prefabs),
		MakePlacer( "common/tp_campfire_placer", "campfire", "campfire", "preview" ) 
