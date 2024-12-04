local info = {}

info.Boss = {
    "deerclops",
	"moose",
	"dragonfly",
	"bearger",
	"minotaur",
	"twister",
	"tigershark",
	"kraken",
	"pugalisk",
	"antqueen",
	"ancient_herald",
	"ancient_hulk",
}

info.Epic = {
    "leif",
	"leif_sparse",
	"spiderqueen",
	"treeguard",
    "warg",
}

info.CreatureEquipMonster = {
    "pigman",
    "pigguard",
    "wildbore",
    "merm",
    "spider",
    "spider_warrior",
    "spider_hider",
    "spider_spitter",
    "spider_dropper",
    "hound",
    "icehound",
    "firehound",
    "koalefant",
    "koalefant_summer",
    "worm",
    "monkey",
    "bunnyman",
    "tallbird",
    "beefalo",
    "tentacle",
    "nightmarebeak",
    "crawlingnightmare",
    "terrorbeak",
    "crawlinghorror",
    "knight",
    "knight_nightmare",
    "bishop",
    "bishop_nightmare",
    "rook",
    "rook_nightmare",
    -- sw
    "crocodog",
    "dragoon",
    "snake",
    "snake_poison",
    -- ham
    "vampirebat",
    "mean_flytrap",
    "adult_flytrap",
    "spider_monkey",
    -- 河鹿
    "hippopotamoose",
    "antman",
    "antman_warrior",
}

for k, v in pairs(info.Boss) do
    table.insert(info.CreatureEquipMonster, v)
end
for k, v in pairs(info.Epic) do
    table.insert(info.CreatureEquipMonster, v)
end

info.ProfessionMonster = {
    "pigman",
    "pigguard",
    "wildbore",
    "merm",
    "spider",
    "spider_warrior",
    "spider_hider",
    "spider_spitter",
    "spider_dropper",
    "hound",
    "icehound",
    "firehound",
    "worm",
    -- sw
    "crocodog",
    "dragoon",
    "snake",
    "snake_poison",
    -- ham
    "vampirebat",
    "mean_flytrap",
    "adult_flytrap",
    "spider_monkey",
    -- 河鹿
    "hippopotamoose",
    "antman",
    "antman_warrior",
}

info.MonsterStrengthen = {
    Corrections = {2/3, 1, 3/2},  -- 难度补正
    MonsterEquipNum = {
        {1,0,0}, {2,0,0}, {0,1,0}, {1,1,0},
        {2,1,0}, {0,2,0}, {1,2,0},
        {2,2,0}, {0,2,1}, {1,2,1},
    },
    LargeEquipNum = {
        {1,1,0}, {2,1,0}, {0,2,0}, {1,2,0},
        {2,2,0}, {0,3,0}, {1,3,0},
        {2,3,0}, {0,3,1}, {1,3,1},
    },
    BossEquipNum = {
        {1,0,1}, {2,0,1}, {0,1,1}, {1,1,1},
        {2,1,1}, {0,2,1}, {1,2,1},
        {2,2,1}, {0,3,1}, {0,4,1},
    },
    EquipNumAddDay = 10,
    MaxDay = 90,
    CaveAddDay = 20,
    -- hp_mod函数：
    -- if day<=30: return (2/300*day)
    -- if 30<day<=90: return (30*2/300*+0.01*(day-30))
    HpFuncConst = {30, 2/300, 0.01},
    -- absorb函数：
    -- if day<=90: 
    -- if noraml return 60/90*day
    -- if large return 50/90*day
    -- if epic return 70/90*day
    AbsorbFuncConst = {30/90, 50/90, 70/90},
    -- damage函数：
    -- if day<=90: 
    -- if not is_boss: return 1*1/3*day else: return 3*1/3*day
    DamageFuncConst = {1, 3, 1/3},
    -- dmg_mod函数:
    -- if day<=30: return (2/300*day)
    -- if 30<day<=90: return (30*2/300+0.01*(day-30))
    DmgModFuncConst = {30, 2/300, 0.01},
    -- penetrate函数:
    -- if day<=90:
    -- if normal: return 40/90*day 
    -- if large: return 60/90*day
    -- if epic: return 80/90*day
    PenetrateFuncConst = {40/90, 60/90, 80/90},
    EpicEquipHpRate = 2,
    EpicEquipDmgRate = 2,
    ProfessionGetRate = .2,
}

info.MonsterStrengthenFns = {
    HpFunc = function(inst, day)
        local HpFuncConst = info.MonsterStrengthen.HpFuncConst
        local hp_mod
        if day <= HpFuncConst[1] then
            hp_mod = (HpFuncConst[2]*day)
        else
            hp_mod = (HpFuncConst[1]*HpFuncConst[2]+HpFuncConst[3]*(day-HpFuncConst[1]))
        end
        return hp_mod
    end,
    AbsorbFunc = function(inst, day)
        local AbsorbFuncConst = info.MonsterStrengthen.AbsorbFuncConst
        local DefenseAddPerDay = AbsorbFuncConst[1]
        if inst:HasTag("epic") then
            DefenseAddPerDay = AbsorbFuncConst[3]
        elseif inst:HasTag("largecreature") then
            DefenseAddPerDay = AbsorbFuncConst[2]
        end
        local defense_mod = DefenseAddPerDay*day
        return defense_mod
    end,
    DamageFunc = function(inst, day)
        local DamageFuncConst = info.MonsterStrengthen.DamageFuncConst
        local mod = inst:HasTag("epic") and DamageFuncConst[2] or DamageFuncConst[1]
        local ex_dmg = DamageFuncConst[3]*mod*day
        return ex_dmg
    end,
    DmgModFunc = function(inst, day)
        local DmgModFuncConst = info.MonsterStrengthen.DmgModFuncConst
        local dmg_mod
        if day<=DmgModFuncConst[1] then
            dmg_mod = DmgModFuncConst[2]*day
        else
            dmg_mod = DmgModFuncConst[1]*DmgModFuncConst[2]+DmgModFuncConst[3]*(day-DmgModFuncConst[1])
        end
        return dmg_mod
    end,
    PenetrateFunc = function(inst, day)
        local PenetrateFuncConst = info.MonsterStrengthen.PenetrateFuncConst
        local penetrate
        if inst:HasTag("epic") then
            penetrate = PenetrateFuncConst[3]*day
        elseif inst:HasTag("largecreature") then
            penetrate = PenetrateFuncConst[2]*day
        else
            penetrate = PenetrateFuncConst[1]*day
        end
        return penetrate
    end,
    GetEquipNum = function(inst, day)
        local MonsterEquipNum = info.MonsterStrengthen.MonsterEquipNum
        local BossEquipNum = info.MonsterStrengthen.BossEquipNum
        local LargeEquipNum = info.MonsterStrengthen.LargeEquipNum
        local EquipNumAddDay = info.MonsterStrengthen.EquipNumAddDay

        local equip_num = MonsterEquipNum
        if inst:HasTag("epic") then
            equip_num = BossEquipNum
        elseif inst:HasTag("largecreature") then
            equip_num = LargeEquipNum
        end
        local phase = math.ceil((day)/EquipNumAddDay)  -- 保证day不为0
        return equip_num[phase][1], equip_num[phase][2], equip_num[phase][3]
    end
}

info.Level = {
    PhaseMaxLevel = 10,
    MaxPhase = 3,
}

info.DmgTypeList = {
    {"strike", "打"},
    {"spike", "刺"},
    {"slash", "斩"},
    {"thump", "捶"},
    {"fire", "火"},
    {"ice", "冰"},
    {"shadow", "暗"},
    {"holly", "圣"},
    {"electric", "雷"},
    {"poison", "毒"},
    {"wind", "风"},
    {"blood", "血"},
}

info.Attr = {
    BaseMana = 100,  -- 基础法力值
    BaseVigor = 100,  -- 基础耐力值
    VigorDmgModifier = .8,  -- 耐力伤害降低
    EatTime = 10,  -- 消化时间
    BaseLoadWeight = 30,
    PlayerAttrStr = {
        health = "健康",
        endurance = "耐力",
        stamina = "体力",
        attention = "专注",
        strengthen = "强壮",
        agility = "敏捷",
        faith = "信仰",
        intelligence = "智力",
        lucky = "幸运",
    }
}

info.Exp = {
    GrowthAmount = 1,
    GrowthMult = 1.1,
    Monster = 1,
    LargeCreature = 3,
    Epic = 5,
    WorldBoss = 10,
    MonsterLevelDinominator = 3,  -- 怪物等级折算人物等级需要除以的分母
    WorldBossReplyExpDinominator = 3/2,  -- 击杀boss补偿经验需要除以的分母
    Food = .3,  -- 食物的每个属性大于阈值后能带来的经验
    Pick = .025,  -- 采摘一个作物带来的经验
    -- 击杀装备更多的生物会获得更多的经验收益
    GreatEquipExpMult = 2,
    LargeEquipExpMult = 1,
    SmallEquipExpMult = .5,
}

info.BossAppearDay = {
    Templar = 5,
    SignRider = 10,
    WerepigKingBase = 10,
    WerepigKingBonus = 10,
}

info.Weapon = {
    WeaponDamage = {34, 68, 102, 136},
    WeaponUse = {150, 300, 450, 600},
    SpearConquerorConst = {5, .05, .25},
}

info.Armor = {
    ArmorAmount = {
        450, 1500, 4000, 7000, 10000
    },
    ArmorAbsorption = {
        .5, .6, .7, .8, .9
    },
}

info.FoodArmorWoodConst = {2}
info.FoodArmorWood2Const = {.1, 5}
info.FoodArmorWood3Const = {.4, 4}
info.FoodEffect = {
    HealthValueLimit = 6,
    SanityValueLimit = 6,
    HungerValueLimit = 6,
}

info.ArmorBrokenRate = .75

info.LockStructure = {
	"tp_furnace",
    "ak_smithing_table",
	-- "ak_research_center",
    "ak_sun_generator",
    "ak_large_power_transformer",
    "ak_smart_battery",
    "ak_lamp",
    "ak_power_shutoff",
    "ak_food_compressor",
    "ak_compost",
    "ak_triage_table",
    "ak_farmer_station",
    "ak_auto_harvester",
    "ak_loader",
    "ak_park_sign",
    "ak_farm_brick",
    "ak_clear_station",
    "ak_robot_worker",
    "ak_transporter",
    "ak_transport_center",
	"tp_rook",
	"tp_coal_beast",
    "tp_fant",
	"tp_desk",
	"tp_lab",
}

info.GiftList = {
    -- general
    normal = {
        "tp_spear_lance",
        "tp_spear_night",
        "tp_spear_sharp",
        "tp_spear_enchant",
        "tp_armor_health",
        "tp_armor_cloak",
        "tp_helm_baseball",
        "tp_helm_combat",
    },
    -- rare
    rare = {
        "tp_spear_fire",
        "tp_spear_ice",
        "tp_spear_thunder",
        "tp_armor_fire",
        "tp_armor_ice",
        "tp_helm_warm",
        "tp_helm_cool",
        "tp_flash_knife",
    },
    -- unique
    unrare = {
        "tp_spear_blood",
        "tp_spear_poison",
        "tp_spear_shadow",
        "tp_armor_ancient",
        "tp_helm_ancient",
        "tp_forest_dragon_bp",
    },
    rock = {
        
    },
}

info.Character = {
    common = {
        BaseMana = 100,
        PerLevelMana = 10,
        TasteNeedLevel = 5,
        BaseTaste = 1,
    },
    wilson = {
        Phase2HungerRate = .2,
        Phase3SanityRate = .25,
        SpeedDmgMod = .1,
    },
    wathgrithr = {
        Phase1CombatAttrMod = .15,
        -- Phase2CombatAttrMod = .2,
        Phase3CombatAttrMod = .2,
        LifeStealRate = .1,
    },
    wolfgang = {
        NormalRecoverRate = .3,
        MightyRecoverRate = .5,
        WimpyRecoverRate = .2,
        Phase2RecoverRate = .05,
        Phase3RecoverRate = .1,
        Phase3HungerRate = .25,
    },
}

info.GeneralBossLoot = {
    "ak_ssd", "ak_ssd", "tp_epic", "tp_epic", "tp_epic", 
    -- "tp_gift", 
    -- "tp_alloy_enchant2",
}

info.BossGiftList = {
    deerclops = {
        "tp_spear_ice", "tp_armor_ice", "tp_helm_cool",  
    },
}

return info