local EntUtil = require "extension.lib.ent_util"

--[[
伤害类型有 打,刺,斩,捶,火,冰,暗,圣,雷,毒,风,血.
每种伤害类型正常伤害吸收100%, 弱此属性则高于100%, 抗此属性则低于100%
一个生物可以有多种伤害类型的吸收率, 但不必全都有
我给出一些生物, 你来给出合适的吸收率
蜘蛛, 猪人, 鱼人, 猎犬, 牦牛, 凶鸵鸟, 小恶魔, 蝙蝠, 猿猴
发条骑士, 发条主教, 发条战车, 兔人, 影怪, 大触手, 大象, 海象, 刚羊, 巨虫
下面是boss单位
树人, 座狼, 蜘蛛女王, 巨鹿, 春鸭, 火蜻蜓, 秋熊, 远古犀牛
]]
local dmg_type_absorb_tbl = {
    spider = {
        spike = .8,
        slash = 1.1,
        fire = .9,
        poison = .7,
    },
    spider_warrior = {
        spike = .8,
        slash = 1.1,
        fire = .9,
        poison = .7,
    },
    spider_spitter = {
        spike = .8,
        slash = 1.1,
        fire = .9,
        poison = .7,
    },
    spider_hider = {
        spike = .8,
        slash = 1.1,
        fire = .9,
        poison = .7,
    },
    spider_dropper = {
        spike = .8,
        slash = 1.1,
        fire = .9,
        poison = .7,
    },
    shadowwaxwell = {
        strike = .8,
        spike = .8,
        slash = .8,
        thump = .8,
        shadow = .75,
        holly = 1.4,
    },
    pigman = {
        slash = .9,
        thump = .9,
        fire = 1.2,
        ice = .9,
        poison = .9,
    },
    pigguard = {
        slash = .9,
        thump = .9,
        fire = 1.2,
        ice = .9,
        poison = .9,
    },
    merm = {
        spike = .9,
        fire = .7,
        ice = 1.1,
        electric = 1.3,
    },
    hound = {
        strike = .9,
        slash = 1.1,
        thump = .9,
        ice = 1.1,
        poison = .8,
    },
    icehound = {
        strike = .9,
        slash = 1.1,
        thump = .9,
        ice = 1.1,
        poison = .8,
    },
    firehound = {
        strike = .9,
        slash = 1.1,
        thump = .9,
        ice = 1.1,
        poison = .8,
    },
    beefalo = {
        slash = .8,
        spike = .8,
        fire = 1.2,
        blood = 1.2,
    },
    tallbird = {
        thump = .9,
        ice = 1.1,
        poison = 1.1,
    },
    krampus = {
        spike = .9,
        fire = .9,
        shadow = .8,
        holly = 1.2,
    },
    bat = {
        slash = 1.1,
        fire = .9,
        poison = .8,
        wind = 1.2,
    },
    monkey = {
        slash = .9,
        thump = .8,
        fire = 1.1,
        ice = 1.1,
    },
    knight = {
        strike = .9,
        slash = .9,
        thump = .9,
        fire = 1.1,
        ice = 1.1,
        shadow = 1.2,
        holly = 1.2,
    },
    knight_nightmare = {
        strike = .9,
        slash = .9,
        thump = .9,
        fire = 1.1,
        ice = 1.1,
        shadow = .8,
        holly = 1.2,
    },
    bishop = {
        fire = 1.1,
        ice = 1.1,
        shadow = 1.2,
        holly = .9,
        electric = .8,
    },
    bishop_nightmare = {
        fire = 1.1,
        ice = 1.1,
        shadow = .8,
        holly = .9,
        electric = .8,
    },
    rook = {
        strike = .8,
        slash = .8,
        thump = .8,
        fire = 1.2,
        ice = 1.2,
        shadow = 1.1,
        holly = 1.1,
        electric = 1.2,
    },
    rook_nightmare = {
        strike = .8,
        slash = .8,
        thump = .8,
        fire = 1.2,
        ice = 1.2,
        shadow = .8,
        holly = 1.1,
        electric = 1.2,
    },
    bunnyman = {
        spike = .9,
        thump = 1.1,
        fire = 1.2,
        ice = .9,
        shadow = .8,
    },
    rocky = {
        strike = 1.5,
        thump = 1.5,
        fire = 1.5,
        ice = 1.5,
        shadow = 1.5,
        wind = 1.5,
    },
    nightmarebeak = {
        strike = .5,
        spike = .5,
        slash = .5,
        thump = .5,
        fire = .9,
        ice = .9,
        electric = .9,
        poison = .9,
        shadow = .7,
        holly = 1.3,
    },
    crawlingnightmare = {
        strike = .5,
        spike = .5,
        slash = .5,
        thump = .5,
        fire = .9,
        ice = .9,
        electric = .9,
        poison = .9,
        shadow = .7,
        holly = 1.3,
    },
    terrorbeak = {
        strike = .5,
        spike = .5,
        slash = .5,
        thump = .5,
        fire = .9,
        ice = .9,
        electric = .9,
        poison = .9,
        shadow = .7,
        holly = 1.3,
    },
    crawlinghorror = {
        strike = .5,
        spike = .5,
        slash = .5,
        thump = .5,
        fire = .9,
        ice = .9,
        electric = .9,
        poison = .9,
        shadow = .7,
        holly = 1.3,
    },
    tentacle = {
        strike = .8,
        slash = 1.1,
        fire = .8,
        ice = 1.1,
        poison = .8,
    },
    koalefant = {
        strike = .8,
        thump = .8,
        fire = .9,
        ice = .9,
        blood = 1.2,
    },
    koalefant_summer = {
        strike = .8,
        thump = .8,
        fire = .9,
        ice = .9,
        blood = 1.2,
    },
    walrus = {
        slash = .9,
        thump = 1.1,
        fire = 1.1,
        ice = .8,
        poison = 1.1,
    },
    spat = {
        strike = .9,
        slash = .8,
        fire = .8,
        ice = 1.1,
        electric = 1.2,
    },
    worm = {
        spike = 1.1,
        slash = 1.2,
        thump = .9,
        fire = 1.3,
        ice = 1.2,
    },
    -- BOSS
    leif = {
        spike = .8,
        slash = 1.2,
        thump = .8,
        fire = 1.4,
        ice = .9,
        electric = .7,
        poison = .7,
        wind = .6,
        blood = .7,
    },
    warg = {
        spike = .8,
        slash = .8,
        thump = 1.1,
        fire = 1.2,
        ice = .9,
        electric = .9,
        poison = .8,
        wind = .7,
    },
    spiderqueen = {
        spike = .8,
        slash = 1.1,
        thump = .8,
        fire = 1.1,
        ice = .8,
        electric = .9,
        poison = .5,
        wind = .7,
    },
    deerclops = {
        strike = .9,
        spike = .8,
        slash = .9,
        thump = .8,
        fire = .6,
        ice = .5,
        electric = .9,
    },
    moose = {
        strike = .8,
        spike = .9,
        slash = .8,
        thump = .9,
        fire = .7,
        ice = .8,
        electric = .9,
        poison = .8,
        wind = 1.1,
    },
    dragonfly = {
        spike = .9,
        slash = .8,
        thump = .9,
        fire = .3,
        ice = .9,
        poison = .8,
        wind = 1.1,
    },
    bearger = {
        strike = .7,
        spike = .7,
        slash = .7,
        thump = .5,
        fire = .8,
        ice = .9,
        electric = .9,
    },
    minotaur = {
        strike = .8,
        spike = .8,
        slash = .9,
        thump = 1.1,
        fire = 1.2,
        ice = 1.1,
        poison = 1.1,
        shadow = .8,
        holly = 1.2,
    },
}
-- 生物的各类型伤害吸收
for pref_name, tbl in pairs(dmg_type_absorb_tbl) do
    AddPrefabPostInit(pref_name, function(inst)
        for dmg_type, absorb in pairs(tbl) do
            inst.components.combat:SetDmgTypeAbsorb(dmg_type, absorb)
        end
    end)
end

-- 玩家的各类型伤害吸收
AddPlayerPostInit(function(inst)
    inst.components.combat:SetDmgTypeAbsorb("poison", 1.3)
    inst.components.combat:SetDmgTypeAbsorb("electric", 1.2)
    inst.components.combat:SetDmgTypeAbsorb("ice", 1)
    inst.components.combat:SetDmgTypeAbsorb("fire", 1)
    -- inst.components.combat:SetDmgTypeAbsorb("shadow", 1)
    -- 过热/过冷状态下, 增加受到的冰/火属性伤害
    inst:ListenForEvent("temperaturedelta", function(inst, data)
        if inst.components.temperature:IsFreezing() then
            inst.components.combat:SetDmgTypeAbsorb("ice", 1.2)
        else
            inst.components.combat:SetDmgTypeAbsorb("ice", 1)
        end
        if inst.components.temperature:IsOverheating() then
            inst.components.combat:SetDmgTypeAbsorb("fire", 1.2)
        else
            inst.components.combat:SetDmgTypeAbsorb("fire", 1)
        end
    end)
    -- 潮湿状态下, 增加受到的雷属性伤害
    inst:ListenForEvent("moisturechange", function(inst, data)
        if inst.components.moisture:GetMoisturePercent() > 0.7 then
            inst.components.combat:SetDmgTypeAbsorb("electric", 1.4)
        elseif inst.components.moisture:GetMoisturePercent() > 0.3 then
            inst.components.combat:SetDmgTypeAbsorb("electric", 1.3)
        else
            inst.components.combat:SetDmgTypeAbsorb("electric", 1.2)
        end
    end)
    -- 疯狂状态下, 增加受到的影属性伤害
    inst:ListenForEvent("goinsane", function(inst, data)
        inst.components.combat:AddDmgTypeAbsorb("shadow", .2)
    end)
    inst:ListenForEvent("gosane", function(inst, data)
        inst.components.combat:AddDmgTypeAbsorb("shadow", -.2)
    end)
end)

--[[
伤害类型有 打,刺,斩,捶,火,冰,暗,圣,雷,毒,风,血.
每种伤害类型最大伤害吸收100%, 正常伤害吸收为60%
伤害吸收较差则低于60%, 伤害吸收较好则高于60%
一个防具可以有多种伤害类型的吸收率, 但不必全都有
我给出一些防具, 你来给出合适的吸收率
草甲, 木甲, 头盔, 精致头盔, 大理石甲, 蜗壳甲, 蜗壳头盔, 影甲, 铥矿甲, 铥矿头盔, 火龙鳞甲
]]
local armor_dmg_type_absorb = {
    armorgrass = {
        strike = .4,
        spike = .5,
        slash = .4,
        fire = -.3,
    },
    armorwood = {
        strike = .6,
        spike = .6,
        slash = .5,
        fire = -.2,
        poison = .5,
        electric = .5,
        blood = .5,
    },
    footballhat = {
        strike = .6,
        spike = .6,
        slash = .5,
        fire = .4,
        ice = .4,
        poison = .5,
        blood = .5,
    },
    wathgrithrhat = {
        strike = .65,
        spike = .7,
        slash = .6,
        fire = .5,
        ice = .5,
        poison = .6,
    },
    armormarble = {
        strike = .7,
        spike = .7,
        slash = .7,
        thump = .7,
        fire = .4,
        ice = .4,
        electric = .5,
        blood = .5,
    },
    armorslurper = {
        strike = .7,
        spike = .7,
        slash = .7,
        thump = .7,
        poison = .5,
        wind = .7,
    },
    slurtlehat = {
        strike = .7,
        spike = .7,
        slash = .6,
        thump = .8,
        poison = .5,
    },
    armor_sanity = {
        fire = .6,
        ice = .6,
        poison = .6,
        electric = .6,
        shadow = .8,
        holly = -.2,
    },
    armorruins = {
        strike = .7,
        spike = .7,
        slash = .7,
        thump = .7,
        fire = .6,
        ice = .5,
        poison = .5,
        electric = .6,
        shadow = .4,
    },
    ruinshat = {
        strike = .7,
        spike = .7,
        slash = .7,
        thump = .7,
        fire = .6,
        ice = .5,
        poison = .5,
        electric = .6,
        shadow = .4,
    },
    armordragonfly = {
        strike = .7,
        slash = .6,
        thump = .6,
        fire = .9,
        ice = .5,
        electric = .7,
        poison = .5,
    }
}

for k, v in pairs(armor_dmg_type_absorb) do
    AddPrefabPostInit(k, function(inst)
        for dmg_type, absorb in pairs(v) do
            inst.components.armor:SetDmgTypeAbsorb(dmg_type, absorb)
        end
    end)
end