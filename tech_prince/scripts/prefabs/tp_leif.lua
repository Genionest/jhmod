local TpLevel = require "screens/tp_level_panel"

local leifs = {}
local leif_phy = {"char"}

-- local function leif_talk_words(inst, strs)
-- end

local function leif_trader_test(inst, item, giver)
	return item.prefab == "tp_gingko_leaf"
end

local function leif_trader_refuse(inst, giver, item)
end

local function leif_trader_accept(inst, giver, item)
    -- "jungletreeseed" "teatree_nut" "coconut"
    if giver.components.poisonable
    and giver.components.poisonable:IsPoisoned() then
        giver.components.poisonable:Cure()
    end
    -- else
        local gift = WARGON.is_dlc(2) and "pinecone" or WARGON.is_dlc(3) and "acron" or "jungletreeseed"
        local gift2 = WARGON.is_dlc(2) and "teatree_nut" or WARGON.is_dlc(3) and "coconut" or "teatree_nut"
        local spalings = {
            "tp_war_tree_seed",
            "tp_defense_tree_seed",
            "tp_life_tree_seed",
            "tp_gingko",
            "tp_gingko",
            "tp_gingko",
            "tp_gingko",
            "tp_gingko",
            "tp_gingko",
            gift,
            gift2,
        }
        inst.components.lootdropper:SpawnLootPrefab(spalings[math.random(10)])
    -- end
    inst.AnimState:PlayAnimation("panic_pre", false)
    inst.AnimState:PushAnimation("panic_loop", false)
    inst.AnimState:PushAnimation("panic_post", false)
    inst.AnimState:PushAnimation("idle_loop", true)
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()

	shadow:SetSize( 4, 1.5 )
    inst.Transform:SetFourFaced()
    MakeCharacterPhysics(inst, 1000, .5)

    WARGON.make_map(inst, "tp_epic.tex")

    anim:SetBank("leif")
    anim:SetBuild("leif_lumpy_build")
    anim:PlayAnimation("idle_loop", true)

    inst:AddTag("teleportato_part")

    -- MakeLargeBurnableCharacter(inst, "marker")
    -- inst.components.burnable.flammability = TUNING.LEIF_FLAMMABILITY
    -- inst.components.burnable:SetOnBurntFn(OnBurnt)
    -- inst.components.propagator.acceptsheat = true

    inst:AddComponent("inspectable")
    WARGON.CMP.add_cmps(inst, {
    	trader = {test=leif_trader_test, refuse=leif_trader_refuse,
            accept=leif_trader_accept},
        loot = {},
        -- tpuse = {},
	})
    -- inst.components.tpuse.use = function(inst, doer)
    --     TheFrontEnd:PushScreen(TpLevel())
    -- end

    return inst
end

return Prefab("common/tp_leif", fn, {})