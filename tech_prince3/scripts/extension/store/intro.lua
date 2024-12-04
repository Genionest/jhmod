local Info = Sample.Info
local Util = require "extension.lib.wg_util"

local shelfs = {
    {
        "人物",
        {
            "经验",
            string.format("击杀强化过的生物会获得经验,普通怪物增加%d点经验,大型怪物增加%d点经验,史诗级生物增加%d点经验,世界Boss增加%d点经验。",
                Info.Exp.Monster, Info.Exp.LargeCreature, Info.Exp.Epic, Info.Exp.WorldBoss),
            string.format("提升1次经验等级可以获得1给用于升级的精华"),
            -- string.format("怪物拥有的装备会提升击杀它获得的经验,计算公式为基本经验x[1+(二星装数量)x%d+(一星装数量)x%d+(无星装数量)x%d]", 
            --     Info.Exp.GreatEquipExpMult, Info.Exp.LargeEquipExpMult, Info.Exp.SmallEquipExpMult),
            "怪物拥有的装备会提升击杀它获得的经验,装备越好经验越高",
            string.format("食用回复属性比较高的菜肴也会增加经验,生命回复不小于%d增加1点经验,理智回复不小于%d增加1点经验,饥饿回复不小于%d增加1点经验",
                TUNING.HEALING_HUGE, TUNING.SANITY_HUGE, TUNING.CALORIES_HUGE),
            string.format("击杀世界Boss时,如果世界Boss的等级除以%d后大于你的经验等级,额外增加X点经验,X为你升到这一经验等级需要的经验乘以%.2f。",
                Info.Exp.MonsterLevelDinominator, 1/Info.Exp.WorldBossReplyExpDinominator),
            -- string.format("人物拥有%d阶段,每个阶段最多提升%d级,每次升级都会提升属性,且升到特定等级会有额外奖励。",
            --     Info.Level.MaxPhase, Info.Level.PhaseMaxLevel),
            -- "人物进阶需要达到当前阶段最大等级,即当前阶段x10,此时再使用进阶芯片即可进阶",
            -- "进阶芯片击杀野猪王或者世界boss都会掉落",
            -- "人物进入到新的阶段后,会获得锻造新装备的工作台蓝图",
            -- "人物每次升级都会回复一定的三围",
        },
        {
            "魔法值",
            "玩家会拥有魔法值,一些装备技能会需要消耗魔法值",
            -- string.format("玩家初始拥有%d魔法值,每级会提升%d的魔法值上限", 
            --     Info.Character.common.BaseMana, Info.Character.common.PerLevelMana),
            -- "玩家可以通过炼药台制作魔法药剂,食用魔法药剂可以回复魔法值",
        },
        {
            "精力值",
            "玩家会拥有精力值,进行攻击时会消耗精力值",
            "精力值空时,玩家将无法进行攻击",
            "武器会有精力增加的属性,攻击时会额外消耗此数量精力值",
            "可以通过升级提升精力值上限",
        },
        {
            "异常状态",
            "玩家过冷时,受到冰属性伤害增加",
            "玩家过热时,受到火属性伤害增加",
            "玩家在疯狂状态时,受到的暗属性伤害增加",
            "玩家在潮湿状态时,受到的电属性伤害增加",
        },
        {
            "饥饿",
            "玩家初始的饥饿速度更快",
            "可以通过升级降低饥饿速度",
        },
        {
            "消化",
            "玩家吃掉一个食物,需要时间取消化",
            "消化完成前,吃其他食物不会回复三维",
            "回复较低的食物需要的消化时间会短一些",
            "可以通过升级降低消化时间",
        },
        {
            "负重",
            "玩家拥有一个负重上限",
            "物品栏每个拥有物品的格子(包括背包)和饰品栏的每个饰品都会增加玩家的重量",
            "重量超过一定百分比,会降低移速和攻速,重量越高,移速越慢,攻速降低会比较少",
            "可以通过升级提升负重",
        },
        {
            "伤害类型",
            "生物的攻击一般会有某种伤害类型",
            "武器一般会有某种伤害类型",
            "生物对不同的伤害类型有各自的伤害吸收比率",
            "护甲对不同的伤害类型有各自的伤害吸收比率",
        },
        -- {
        --     "品尝值",
        --     "食物可以通过食物压制器获得词条",
        --     "食物的词条需要消耗品尝值来触发",
        --     string.format("玩家开始拥有%d点品尝值,每%d级提升1点品尝值", 
        --         Info.Character.common.BaseTaste, Info.Character.common.TasteNeedLevel),
        --     "每当白天、黄昏、夜晚来临时,回满品尝值",
        -- },
        -- {
        --     "装备等级",
        --     "拥有等级的装备击杀生物会获得经验,击杀的生物生命上限越高,获得经验越多,修复时也会获得经验",
        -- },
        {
            "装备技能",
            "左下角是装备的技能栏,装备上拥有技能的装备后,会在技能栏显示,无论被动技能还是主动技能",
        },
        {
            "关于海难",
            "船体不再替玩家承受伤害",
        },
    },
    {
        "装备",
        {
            "锻造",
            "武器会拥有锻造等级和属性收益",
            "属性收益会根据玩家的对应的属性值提升而提高攻击力",
            "锻造等级的提升会提升武器攻击力和属性收益",
            "武器可以质变属性,只有物理伤害类型的武器可以质变",
            "质变后的属性收益降低为60%,但攻击会造成额外的属性伤害,这一属性伤害会锻造等级提升",
            "质变后攻击还会有概率造成对应属性的特殊效果",
            "火:点燃敌人",
            "冰:增加敌人冰冻层数",
            "毒:敌人中毒",
            "雷:敌人进入导电状态",
            "血:增加敌人出血层数",
            "风:增加敌人风扰层数",
            "影:召唤暗影触手",
            "圣:回复生命",
        },
    },
    -- {
    --     "角色",
    --     {
    --         "威尔逊",
    --         -- "威尔逊是一个中期发力的角色(敌人30-60级,自己阶段2)",
    --         "威尔逊拥有强大的移速对抗敌人",
    --         "威尔逊5级之后可以长胡须",
    --         string.format("阶段2,饥饿速度增加%d%%,每提升100%%的移速,提升%d%%攻击", 
    --             Info.Character.wilson.Phase2HungerRate*100, 
    --             Info.Character.wilson.SpeedDmgMod*100),
    --         string.format("阶段3,理智降低速度增加%d%%,自带一本科技和魔法一本科技",
    --             Info.Character.wilson.Phase3SanityRate*100),
    --     },
    --     {
    --         "女武神",
    --         -- "女武神是一个前期发力的角色(敌人1-30级,自己阶段1)",
    --         "女武神拥有强大的吸血能力",
    --         string.format("女武神3级之后解锁专属装备制造,5级之后获得%d%%的吸血和%d%%的防御、穿透、命中加成",
    --             Info.Character.wathgrithr.LifeStealRate*100, Info.Character.wathgrithr.Phase1CombatAttrMod*100),
    --         "阶段2,杀死怪物回复理智和生命,只能吃肉",
    --         string.format("阶段3,防御、穿透、命中加成提升至%d%%", 
    --             Info.Character.wathgrithr.Phase3CombatAttrMod*100)
    --     },
    --     {
    --         "老奶奶",
    --         -- "老奶奶是一个后期发力的角色(敌人60-90级,自己阶段3)",
    --         "老奶奶拥有强大的远程攻击能力",
    --         "老奶奶2级之后自带一本,升到5级和8级时获得3本书",
    --         "阶段2,解锁书籍制造,失眠",
    --         "阶段3,不适应不新鲜的食物",
    --     },
    --     {
    --         "大力士",
    --         -- "大力士是一个前期发力的角色(敌人1-30级,自己阶段1)",
    --         "大力士拥有强大的回复能力",
    --         string.format("大力士3级获得%d%%生命回复收益", Info.Character.wolfgang.NormalRecoverRate*100),
    --         string.format("大力士5级后饥饿会影响性能(包括生命回复收益,最高%d%%,最低%d%%)", 
    --             Info.Character.wolfgang.WimpyRecoverRate*100, Info.Character.wolfgang.MightyRecoverRate*100),
    --         string.format("阶段2,大力士变得胆小,额外获得%d%%生命回复收益", Info.Character.wolfgang.Phase2RecoverRate*100),
    --         string.format("阶段3,大力士饥饿速度增加%d%%,额外获得的生命回复收益提升至%d%%", 
    --             Info.Character.wolfgang.Phase3HungerRate*100, Info.Character.wolfgang.Phase3RecoverRate*100),
    --     },
    -- },
    {
        "生物",
        {
            "生物强化",
            string.format("一些生物会获得强化,也会拥有等级,等级会提升属性,生物诞生的天数越晚,等级就越高。洞穴里的生物会额外获得%d天以后的等级。等级最高%d级",
                Info.MonsterStrengthen.CaveAddDay, Info.MonsterStrengthen.MaxDay),
            -- string.format("此外生物还会得到装备,装备也有提升属性,并带来额外的效果,每过%d天,新诞生的生物会获得更多或更强的装备,史诗生物装备提升的效率会更高。",
            --     Info.MonsterStrengthen.EquipNumAddDay),
            "此外生物还会得到装备,装备也有提升属性,并带来额外的效果,每过一定天数,新诞生的生物会获得更多或更强的装备,史诗生物装备提升的效率会更高。",
            string.format("装备的攻击力对史诗生物是%d倍提升,装备的生命值对史诗生物是%d倍提升。",
                Info.MonsterStrengthen.EpicEquipDmgRate, Info.MonsterStrengthen.EpicEquipHpRate),
            -- string.format("一些生物还会获得元素,不同的元素会带来不同的效果,生物在诞生时会有%d%%乘以天数的概率获得元素",
            --     Info.MonsterStrengthen.ProfessionGetRate),
        },
        {
            "巨鹿",
            "巨鹿受到攻击后,会掉落魔法雪球,雪球会回复巨鹿的血量,冰冻并降温其他单位",
        },
        {
            "春鸭",
            "春鸭现在变为范围攻击了",
            "春鸭会吼叫击落攻击目标身上所有物品,并召唤一阵旋风攻击敌人",
        },
        {
            "龙蝇",
            "龙蝇三连击会摧毁建筑并召唤陨石",
        },
        {
            "熊獾",
            "熊獾拍地板的伤害范围扩大,并且会召唤两个幻影熊再次拍地板",
        },
        {
            "犀牛",
            "犀牛现在更难冰冻了",
            "犀牛冲撞时会召唤多个影子随同自己一同冲撞",
        },
        {
            "其他Boss",
            "其他Boss在战吼或几次攻击后会随机触发一个巨人国Boss的特殊能力",
        },
        {
            "圣堂武士",
            string.format("%d天后,地图上会生成一个%s,boss会释放法术召唤一圈战矛攻击敌人,并恢复自身血量", 
                Info.BossAppearDay.Templar, "圣堂武士"),
        },
        {
            "路牌骑士",
            string.format("%d天后,会有一只牦牛进化成%s,boss会召唤路牌进行滚远程攻击,受到攻击时有几率召唤路牌反击敌人,boss会召唤一个路牌阵,令阵中的生物死亡,皮弗娄牛则回复生命,玩家则受到诅咒", 
                Info.BossAppearDay.SignRider, "路牌骑士"),
        },
        {
            "野猪王",
            string.format("猪王村会出现一个%s,%d天后,他会变成%s,将其击败后,%s会再次出现,并在之后变成新形态的%s",
                "王位觊觎者", Info.BossAppearDay.WerepigKingBase+Info.BossAppearDay.WerepigKingBonus,
                "野猪王", "王位觊觎者", "野猪王"),
        },
        {
            "洞穴之影",
            string.format("洞穴入口开凿时会出现3个洞穴之影"),
        },
        {
            "宝石座狼",
            "戈壁会出现红色和蓝色的宝石座狼,攻击它们会掉落对应颜色的宝石",
        },
    },
    


}

local WgShelf = require "extension.lib.wg_shelf"

local BookData = Class(WgShelf, function(self, title)
	WgShelf._ctor(self, title, 11)
	self.limit = 18
end)

function BookData:AddItem(str)
	if self.max <= 0 then
		self:AddBar()
	end
	if #self.shelf[self.max] >= self.unit then
		self:AddBar()
	end
    local t = Util:SplitSentence(str, self.limit)
    for k, v in pairs(t) do
        table.insert(self.shelf[self.max], v)
    end

end

function BookData:GetString()
	local str = nil
	for k, v in pairs(self:GetItems()) do
		if not str then
			str = v.."\n"
		else
			str = str..v.."\n"
		end
	end
	str = string.sub(str, 1, -2)
	return str
end

function BookData:__tostring()
	return string.format("BookData %s",self.title)
end

local AkIntroData = Class(WgShelf, function(self)
	WgShelf._ctor(self, "介绍", 8)
end)

function AkIntroData:Print()
    print("Menu")
	for k, v in pairs(self:GetItems()) do
		print(v.title)
	end
	print("Mini Menu")
	for k, v in pairs(self:GetItem():GetItems()) do
		print(v.title)
	end
	print("Book")
	local book = self:GetItem():GetItem()
	print(book:GetString())
end

function AkIntroData:ShelfPageTurn(dt)
	local shelf = self:GetItem()
	shelf:PageTurn(dt)
end

function AkIntroData:BookPageTurn(dt)
	local book = self:GetItem():GetItem()
	book:PageTurn(dt)
end

local ak_intro_data = AkIntroData()

for k, v in pairs(shelfs) do
	local shelf = nil
	for k2, v2 in pairs(v) do
		if k2 == 1 then
			shelf = WgShelf(v2, 10)
		else
			local book = BookData(v2[1])
			for k3, v3 in pairs(v2) do
				if k3 > 1 then
					book:AddItem(v3)
				end
			end
			shelf:AddItem(book)
		end
	end
	ak_intro_data:AddItem(shelf)
end

Sample.Intro = ak_intro_data