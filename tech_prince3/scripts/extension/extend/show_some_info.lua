local Util = require "extension.lib.wg_util"

local fuel_type = {
    ["BURNABLE"] = "可燃",
    ["MAGIC"] = "魔法",
    ["USAGE"] = "使用",
    ["CAVE"] = "洞穴",
    ["SPIDERHAT"] = "蜘蛛",
    ["NIGHTMARE"] = "梦魇",
    ["ONEMANBAND"] = "独奏",
    ["PIGTORCH"] = "猪火",
    ["CHEMICAL"] = "化学",
    ["MECHANICAL"] = "机械",
    ["CORK"] = "软木",
    ["MOLEHAT"] = "鼹鼠",
    ["ANCIENT_REMNANT"] = "遗迹",
    ["NONE"] = "无",
    ["TAR"] = "焦油",
}

local food_type = {
    ["MEAT"] = "肉",
    ["WOOD"] = "木头",
    ["VEGGIE"] = "蔬菜",
    ["ROUGHAGE"] = "粗料",
    ["ELEMENTAL"] = "元素",
    ["GEARS"] = "齿轮",
    ["HORRIBLE"] = "恐怖",
    ["GENERIC"] = "普通",
    ["SEEDS"] = "种子",
    ["GOLDDUST"] = "金子",
}

local equip_str = {
    [EQUIPSLOTS.HANDS] = "手",
    [EQUIPSLOTS.BODY] = "身",
    [EQUIPSLOTS.HEAD] = "头",
}

local ruins_phase = {
    ["clam"] = "平静",
    ["warn"] = "预警",
    ["nightmare"] = "暴动",
}

local fns = {

{
    "health",
    function(self)
        local recover = self.tp_recover or 0
        local s = string.format("生命:%d/%d,回复:%+d%%", 
            self.currenthealth, self:GetMaxHealth(), recover*100)
        -- s = Util:SplitSentence(s, 17, true)
        if self.inst.components.tp_val_sheild then
            s = s..string.format(",护盾:%d", 
                self.inst.components.tp_val_sheild:GetCurrent())
        end
        return s
    end,
},
{
    "sanity",
    function(self)
        local s = string.format("理智:%d/%d", 
            self.current, self:GetMaxSanity())
        -- s = Util:SplitSentence(s, 17, true)
        return s
    end,
},
{
    "hunger",
    function(self)
        local s = string.format("饥饿:%d/%d", 
			self.current, self.max)
		-- s = Util:SplitSentence(s, 17, true)
		return s
    end,
},
{
    "combat",
    function(self)
        if self.inst:HasTag("wall") then
            return
        end
        local defense = self.tp_defense or 0
        local def_ab = 1-100/(100+defense)
        local dmg_mult = self:GetDamageModifier()
        local penetrate = self.tp_penetrate or 0
        local atk_spd = self:GetPeriodModifier()
        local crit = self.tp_crit or 0
        local weapon = self:GetWeapon()
        local dmg
        if weapon then
            dmg = weapon.components.weapon:GetDamage() * dmg_mult
        else
            dmg = self.defaultdamage * dmg_mult
        end
        local s = string.format("伤害:%d,攻速:%d%%",
            dmg, atk_spd*100, crit*100)
        s = s..string.format("防御:%d(%d%%),穿透:%d",
            defense, def_ab*100, penetrate)
        if WG_TEST then
            local evade = self.tp_evade or 0
            local evd_ab = 1-150/(150+evade)
            local hit_rate = self.tp_hit_rate or 0
            s = s..string.format("\n闪避:%d(%d%%),命中:%d", 
                evade, evd_ab*100, hit_rate)
        end
        -- s = Util:SplitSentence(s, 17, true)
        return s
    end,
},

}

local fns2 = {
{
    "locomotor",
    function(self)
        local s = string.format("走:%d,跑:%d", 
            self:GetWalkSpeed(), self:GetRunSpeed())
        return s
    end
},
{
    "domesticatable",
    function(self)
        local s = string.format("驯服:%d%%,顺从:%d",
            self.domestication*100, self.obedience)
        return s
    end,
},
{
    "pickable",
    function(self)
        local s = string.format("可采摘(%s)",
            Util:GetScreenName(self.product))
        return s
    end,
},
{
    "harvestable",
    function(self)
        local s = string.format("可收获(%s):%d/%d",
            Util:GetScreenName(self.product), self.produce, self.maxproduce)
        return s
    end,
},
{
    "workable",
    function(self)
        local s = string.format("可工作(%s):%d",
            GetActionString(self.action.id), self.workleft )
        return s
    end,
},
{
    "hackable",
    function(self)
        local s = string.format("可砍伐:%d",
            self.hacksleft )
        return s
    end,
},
{
    "shearable",
    function(self)
        local s = string.format("可剪除(%s)", 
            Util:GetScreenName(self.product))
        return s
    end
},
{
    "tool",
    function(self)
        if self.action then
            local s = "工具:"
            for act, num in pairs(self.action) do
                s = s..string.format("%s(%d),",
                    GetActionString(act.id), num)
            end
            return s
        end
    end,
},
{
    "finiteuses",
    function(self)
        local s = string.format("使用次数:%d/%d",
            self.current, self.total)
        return s
    end,
},
{
    "fueled",
    function(self)
        local s = string.format("需要燃料(%s",
            fuel_type[self.currentfuel] or "未知")
        if self.secondaryfueltype then
            s = s..(fuel_type[self.secondaryfueltype] or "未知")
        end
        s = s..string.format("):%d/%d", 
            self.currentfuel, self.maxfuel)
        return s
    end,
},
{
    "fuel",
    function(self)
        local s = string.format("燃料(%s):%d",
            fuel_type[self.fueltype] or "未知", self.fuelvalue)
        return s
    end,
},
{
    "repairable",
    function(self)
        local s = string.format("可修复:%s",
            Util:GetScreenName(self.repairmaterial))
        return s
    end,
},
{
    "repairer",
    function(self)
        local s = string.format("修复(%s):",
            Util:GetScreenName(self.repairmaterial))
        if self.workrepairvalue then
            s = s..string.format("工具(%d),", self.workrepairvalue)
        end
        if self.healthrepairvalue then
            s = s..string.format("生命(%d)", self.healthrepairvalue)
        end
        if self.perishrepairvalue then
            s = s..string.format("保险(%d),", self.perishrepairvalue)
        end
        if self.finiteusesrepairvalue then
            s = s..string.format("使用(%d)", self.finiteusesrepairvalue)
        end
        return s
    end,
},
{
    "perishable",
    function(self)
        local s = string.format("过期时间:%d/%d",
            self.perishremainingtime, self.perishtime)
        if self.onperishreplacement then
            s = s..string.format("(%s)",
                Util:GetScreenName(self.onperishreplacement))
        end
        return s
    end,
},
{
    "cooldown",
    function(self)
        local s = string.format("冷却:%d",
            self.cooldown_duration)
        if self.charged then
            s = s.."(已冷却)"
        else
            s = s.."(未冷却)"
        end
        return s
    end,
},
{
    "healer",
    function(self)
        local s = string.format("治疗物:%d",
            self.health)
        return s
    end,
},
{
    "stewer",
    function(self)
        if self.product then
            local s = string.format("煮菜(%s),", 
                Util:GetScreenName(self.product))
            if self.targettime then
                s = s..string.format("时间:%ds",
                    self.targettime - GetTime())
            end
            return s
        end
    end,
},
{
    "dryer",
    function(self)
        if self.product then
            local s = string.format("干燥物(%s),", 
                Util:GetScreenName(self.product))
            if self.targettime and not self.paused then
                s = s..string.format("时间:%ds", 
                    self.targettime - GetTime())
            end
            return s
        end
    end,
},
{
    "edible",
    function(self)
        local s = string.format("食物(%s):生命%+d,理智%+d,饥饿+%d", 
            food_type[self.foodtype] or "未知", 
            self.healthvalue, self.hungervalue, self.sanityvalue)
        return s
    end,
},
{
    "hatchable",
    function(self)
        local s = string.format("可孵化:%d/%d",
            self.progress, self.hatchtime)
        return s
    end,
},
{
    "teacher",
    function(self)
        local s = string.format("可学习:%s", 
            Util:GetScreenName(self.recipe))
        return s
    end,
},
{
    "waterproofer",
    function(self)
        local s = string.format("防雨:%d%%", 
            self.effectiveness*100)
        return s
    end,
},
{
    "insulator",
    function(self)
        local s = string.format("防寒:%d,隔热:%d",
            self.winter_insulation, self.summer_insulation)
        return s
    end,
},
{
    "dapperness",
    function(self)
        local s = string.format("理智恢复:%.2f",
            self.dapperness)
        return s        
    end,
},
{
    "equippable",
    function(self)
        local s = string.format("装备(%s),",
            equip_str[self.equipslot] or "未知")
        if self.dapperness and self.dapperness ~= 0 then
            s = s..string.format("理智:%+.2f,", self.dapperness)
        end
        if self.walkspeedmult then
            s = s..string.format("移速:%+d%%", self.walkspeedmult*100)
        end
        return s
    end,
},
{
    "explosive",
    function(self)
        local s = string.format("爆炸半径:%d,伤害:%d",
            self.explosiverange, self.explosivedamage)
        return s
    end,
},
{
    "obsidiantool",
    function(self)
        local s = string.format("黑曜石工具:%d/%d",
            self.charge, self.maxcharge)
        return s
    end,
},
{
    "appeasement",
    function(self)
        local s = string.format("平息火山:%d",
            self.appeasementvalue)
        return s
    end,
},
{
    "tradable",
    function(self)
        local s = string.format("价值:%d",
            self.goldvalue)
        return s
    end,
},
{
    "inventory",
    function(self)
        local s = string.format("物品栏:%d/%d",
            self:NumItems(), self.maxslots)
        return s
    end,
},
{
    "container",
    function(self)
        local s = string.format("容器:%d/%d",
            self:NumItems(), self.numslots)
    end,
},
{
    "childspawner",
    function(self)
        if self.childname then
            local s = string.format("可生成(%s):%d/%d",
                Util:GetScreenName(self.childname), self.numchildrenoutside, self.childreninside)
            return s
        end
    end,
},
{
    "spawner",
    function(self)
        if self.child then
            local name = self.child.prefab
            local s = string.format("可生成(%s):%s",
                Util:GetScreenName(name), self:IsOccupied() and "已占用" or "未占用")
            return s
        end
    end,
},

}

local extra_info = GetModConfigData("extra_info")

local function get_cmp_string(inst)
    local cmp = inst.components
    if cmp == nil then
        return
    end
    local s
    for k, v in pairs(fns) do
        local cmp = inst.components[v[1]]
        if cmp then
            local str = v[2](cmp) or ""
            if s == nil then
                s = str
            else
                s = s.."\n"..str
            end
        end
    end
    if extra_info then
        for k, v in pairs(fns2) do
            local cmp = inst.components[v[1]]
            if cmp then
                local str = v[2](cmp) or ""
                if s == nil then
                    s = str
                else
                    s = s.."\n"..str
                end
            end
        end
    end

    return s
end
local function fn(inst)
    inst.WgGetCmpStrings = get_cmp_string
end
AddPrefabPostInitAny(fn)

local moon_type = {
    ["new"] = "新月",
    ["quarter"] = "上弦月",
    ["half"] = "半月",
    ["threequarter"] = "下弦月",
    ["full"] = "满月",
}
local season_type = {
    ["spring"] = "春",
    ["summer"] = "夏",
    ["autumn"] = "秋",
    ["winter"] = "冬",
}
local function fn(widget)
    local world = GetWorld()
    -- 月亮
    local clock = GetClock()
    local moon = clock:GetMoonPhase()
    local s = string.format("月相:%s", moon_type[moon])
    local day = clock:GetNumCycles()
    local gap = day + 1
    if gap == 9 or gap == 10 then
         gap = 0
    else
        gap = (gap-10) % 18
        if gap == 17 or gap == 0 then
            gap = 0
        else
            gap = 17 - gap
        end
    end
    s = s..string.format(",距离满月:%d天", gap)
    -- 季节
    local season_mgr = GetSeasonManager()
    local season = season_mgr:GetSeason()
    local length = season_mgr:GetSeasonLength()
    local left = season_mgr:GetDaysLeftInSeason()
    s = s..string.format("\n季节:%s,剩余:%d,总天数:%d", 
        season_type[season] or season, left, length)
    -- 猎犬袭击
    local hounded = world.components.hounded
    if hounded then
        local num = hounded.houndstorelease
        local time = hounded.timetoattack
        local min = time / 60
        local sec = time % 60
        s = s..string.format("\n猎犬袭击:%d只,等待:%dm%ds", num, min, sec)
    end
    -- 地震
    local quaker = world.components.quaker
    if quaker then
        local time = quaker.quaketime
        local min = time / 60
        local sec = time % 60
        s = s..string.format("\n地震:%dm%ds", min, sec)
    end
    -- 远古暴动
    local nightmareclock = world.components.nightmareclock
    if nightmareclock then
        local time = nightmareclock:GetTimeLeftInEra()
        local min = time / 60
        local sec = time % 60
        s = s..string.format("阶段:%s,剩余:%dm%ds", 
            ruins_phase[nightmareclock.phase], min, sec)
    end
    -- 火山
    local volcanomanager = world.components.volcanomanager
    if volcanomanager then
    end
    -- 虎鲨
    local tigersharker = world.components.tigersharker
    if tigersharker then
    end
    -- 蝙蝠袭击
    local batted = world.components.batted
    if batted then
    end
    -- 大鸟
    local rocmanager = world.components.rocmanager
    if rocmanager then
    end
    -- boss
    local basehassler = world.components.basehassler
    if basehassler then
        for k,v in pairs(basehassler.hasslers) do
            if basehassler:GetHasslerState(k) ~= "DORMANT" then
                local time = basehassler.hasslers[k].timer or 0
                local hour = time / 3600
                local min = (time%3600) / 60
                local sec = time % 60
                s = s..string.format("\nBoss:%s,等待:%dh%dm%ds", 
                    Util:GetScreenName(k), hour, min, sec) 
            end
        end
    end

    return s
end
if extra_info then
    AddClassPostConstruct("widgets/uiclock", function(self)
        self.GetWargonString = fn
        self.moonanim.GetWargonString = fn
        self.anim.GetWargonString = fn
        -- self.text_upper.GetWargonString = fn
        -- self.text_lower.GetWargonString = fn
        -- self.hovertext_upper.GetWargonString = fn
        -- self.hovertext_lower.GetWargonString = fn
        -- for k, v in pairs(self.segs) do
        --     v.GetWargonString = fn
        -- end
        -- self.rim.GetWargonString = fn
        -- self.hands.GetWargonString = fn
        -- self.face.GetWargonString = fn
    end)
end