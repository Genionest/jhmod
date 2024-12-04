-- 各种生物的伤害类型
--[[
伤害类型有 打,刺,斩,捶,火,冰,暗,圣,雷,毒,风,血.
一个生物的攻击有对应的伤害类型, 且只会拥有一种, 不会拥有多种
我给出一些生物, 你来给出合适的伤害类型
蜘蛛, 猪人, 鱼人, 猎犬, 牦牛, 凶鸵鸟, 小恶魔, 蝙蝠, 猿猴
发条骑士, 发条主教, 发条战车, 兔人, 影怪, 大触手, 大象, 海象, 刚羊, 巨虫
下面是boss单位
树人, 座狼, 蜘蛛女王, 冰雪巨鹿, 麋鹿巨鸭, 怒火龙蜓, 暴君熊, 米诺陶诺斯树
]]
local monster_dmg_type = {
    spider = "spike",
    spider_warrior = "spike",
    spider_spitter = "spike",
    spider_hider = "spike",
    spider_dropper = "spike",
    shadowwaxwell = "shadow",
    pigman = "strike",
    pigguard = "strike",
    merm = "strike",
    hound = "slash",
    icehound = "slash",
    firehound = "slash",
    beefalo = "thump",
    tallbird = "slash",
    krampus = "shadow",
    bat = "spike",
    monkey = "strike",
    bee = "spike",
    killerbee = "spike",
    frog = "strike",
    eyeplant = "strike",
    trap_teeth = "spike",
    knight = "strike",
    knight_nightmare = "strike",
    bishop = "electric",
    bishop_nightmare = "electric",
    rook = "thump",
    rook_nightmare = "thump",
    bunnyman = "spike",
    nightmarebeak = "shadow",
    crawlingnightmare = "shadow",
    terrorbeak = "shadow",
    crawlinghorror = "shadow",
    tentacle = "strike",
    koalefant = "thump",
    koalefant_summer = "thump",
    rocky = "strke",
    spat = "thump",
    worm = "slash",
    -- boss
    leif = "strike",
    leif_sparse = "strike",
    warg = "slash",
    spiderqueen = "poison",
    deerclops = "ice",
    moose = "wind",
    dragonfly = "fire",
    bearger = "strike",
    minotaur = "thump",
    -- other
    shadowtentacle = "shadow",
    bigshadowtentacle = "shadow",
    bigfooter = "thump",
}

for k, v in pairs(monster_dmg_type) do
    AddPrefabPostInit(k, function(inst)
        inst.components.combat.dmg_type = v 
    end) 
end


--[[
伤害类型有 打,刺,斩,捶,火,冰,暗,圣,雷,毒,风,血.
一个武器的攻击有对应的伤害类型, 且只会拥有一种, 不会拥有多种
我给出一些武器, 你来给出合适的伤害类型
长矛, 精致长矛, 火腿棒, 晨星锤, 触手棒, 蝙蝠棒, 回旋镖, 影刀, 铥矿棒
]]

local weapon_dmg_type = {
    axe = "slash",
    goldenaxe = "slash",
    pickaxe = "spike",
    goldenpickaxe = "spike",
    shovel = "strike",
    goldenshovel = "strike",
    machete = "slash",
    goldenmachete = "slash",
    hammer = "thump",
    spear = "spike",
    spear_wathgrithr = "spike",
    hambat = "strike",
    nightstick = "spike",
    tentacle_spike = "slash",
    batbat = "slash",
    boomerang = "spike",
    nightsword = "shadow",
    ruins_bat = "thump",
    blowdart_pipe = "spike",
    blowdart_fire = "fire",
}
for k, v in pairs(weapon_dmg_type) do
    AddPrefabPostInit(k, function(inst)
        inst.components.weapon:SetDmgType(v)
    end)
end