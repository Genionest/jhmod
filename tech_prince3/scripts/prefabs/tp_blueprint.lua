local Util = require "extension.lib.wg_util"
local Info = Sample.Info

local function onload(inst, data)
	if data then
		if data.recipetouse then
			inst.recipetouse = data.recipetouse
			inst.components.teacher:SetRecipe(inst.recipetouse)
	    	inst.components.named:SetName((STRINGS.NAMES[string.upper(inst.recipetouse)] or STRINGS.NAMES.UNKNOWN).." "..STRINGS.NAMES.BLUEPRINT)
	    end
	end
end

local function onsave(inst, data)
	if inst.recipetouse then
		data.recipetouse = inst.recipetouse
	end
end

local function selectrecipe_any(recipes)
	if next(recipes) then
		return recipes[math.random(1, #recipes)]
	end
end

local function OnTeach(inst, learner)
	if learner.SoundEmitter then
		learner.SoundEmitter:PlaySound("dontstarve/HUD/get_gold")    
	end
end

local function fn()

	local inst = CreateEntity()
	inst.entity:AddTransform()
    MakeInventoryPhysics(inst)
	inst.entity:AddAnimState()
    inst.AnimState:SetBank("blueprint")
	inst.AnimState:SetBuild("blueprint")
	inst.AnimState:PlayAnimation("idle")
	
	if rawget(_G, 'MakeInventoryFloatable') then
        MakeInventoryFloatable(inst, 'idle_water', 'idle')
    end
    
    inst:AddComponent("inspectable")    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("blueprint")
    inst:AddComponent("named")
    inst:AddComponent("teacher")
    inst.components.teacher.onteach = OnTeach
    
    inst.OnLoad = onload
    inst.OnSave = onsave

   	return inst
end

local function MakeAnyBlueprint()
	local inst = fn()

	local recipes = {}
    local player = GetPlayer()   
    for k,v in pairs(GetAllRecipes()) do
    	if v and not player.components.builder:KnowsRecipe(v.name) then
    		table.insert(recipes, v)  		
    	end
    end
    local r = selectrecipe_any(recipes)
    
    if r then
		if not inst.recipetouse then
			inst.recipetouse = r.name or "Unknown"
		end

		inst.components.teacher:SetRecipe(inst.recipetouse)
		inst.components.named:SetName(STRINGS.NAMES[string.upper(inst.recipetouse)].." "..STRINGS.NAMES.BLUEPRINT)
	end
	
    return inst
end

local function MakeAnySpecificBlueprint(specific_item)
	local ctor = function()
		local inst = fn()

		local recipes = {}
	    local player = GetPlayer()   
	    for k,v in pairs(GetAllKnownRecipes()) do
	    	if v and ((specific_item ~= nil and v.name == specific_item) or
	    			 (specific_item == nil and not player.components.builder:KnowsRecipe(v.name)) )then	    		
	    		table.insert(recipes, v)  		
	    	end
	    end
	    local r = selectrecipe_any(recipes)
		if r then
		    if not inst.recipetouse then
			    inst.recipetouse = r.name
			end
		    inst.components.teacher:SetRecipe(inst.recipetouse)
		    inst.components.named:SetName(STRINGS.NAMES[string.upper(inst.recipetouse)].." "..STRINGS.NAMES.BLUEPRINT)
		end
	    return inst
	end
	return ctor
end

local function MakeSpecificBlueprint(recipetab)
	local ctor = function()
		local inst = fn()

		local recipes = {}
	    local player = GetPlayer()   
	    for k,v in pairs(GetAllRecipes()) do
	    	if v and v.tab == recipetab and not player.components.builder:KnowsRecipe(v.name) then
	    		table.insert(recipes, v)
	    	end
	    end
	    local r = selectrecipe_any(recipes)
	    if r then
			if not inst.recipetouse then
			    inst.recipetouse = r.name
			end
			inst.components.teacher:SetRecipe(inst.recipetouse)
			inst.components.named:SetName(STRINGS.NAMES[string.upper(inst.recipetouse)].." "..STRINGS.NAMES.BLUEPRINT)
		end
	    return inst
	end
	return ctor
end

local prefabs = {}
local tp_bps = Info.LockStructure
for k, v in pairs(tp_bps) do
	table.insert(prefabs,Prefab(v.."_bp",MakeAnySpecificBlueprint(v)))
	Util:AddString(v.."_bp", Util:GetScreenName(v).."蓝图", "解锁制造配方")
end

return unpack(prefabs) 