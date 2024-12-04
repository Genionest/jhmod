--[[
3下打死蜘蛛
血量/(1-防御)
攻击*倍率*(1/(1-护甲穿透))

hp_mod函数：
if day<=30: return (2/300*day)
if 30<day<=90: return (30*2/300*+0.01*(day-30))

absorb函数：
if day<=90: return 1/300*day

防御属性计算：
(hp+equip.hp)*hp_mod/(1-absorb+equip_absorb)
(hp+equip.hp*2)*hp_mod/(1-absorb+equip_absorb) (boss)

damage函数：
if day<=90: 
if is_boss: return 3*1/3*day else: return 1*1/3*day

dmg_mod函数:
if day<=30: return (2/300*day)
if 30<day<=90: return (30*2/300+0.01*(day-30))

攻击属性计算：
(damage+exDamage+equip.damage)*(dmg_mod)
(damage+exDamage*3)*(dmg_mod+equip.dmg_mod) (boss)

蜘蛛：
{def=144, dmg=25, day=1,},
{def=157, dmg=30, day=10,},
{def=225, dmg=46, day=20,},
{def=316, dmg=58, day=30,},
{def=455, dmg=75, day=40,},
{def=591, dmg=94, day=50,},
{def=768, dmg=107, day=60,},
{def=999, dmg=121, day=70,},
{def=1313, dmg=142, day=80,},
{def=1753, dmg=157, day=90,},

boss:
{def=3438, dmg=86, day=1,},
{def=3766, dmg=96, day=10,},
{def=4440, dmg=108, day=20,},
{def=5283, dmg=133, day=30,},
{def=7138, dmg=153, day=40,},
{def=7782, dmg=178, day=50,},
{def=10058, dmg=191, day=60,},
{def=12357, dmg=219, day=70,},
{def=17795, dmg=249, day=80,},
{def=24496, dmg=280, day=90,},

基础防御=蜘蛛攻击属性*7.5
基础伤害=蜘蛛防御属性/3

玩家：
防御属性：血量+护甲=基础防御*4 (单甲)
        血量+护甲=基础防御*7 (双甲)
攻击属性：1*基础伤害 (前期)
        1.5*基础伤害 (中期)
        2*基础伤害 (后期)

怪物基础属性+装备
怪物额外属性：
0.1防御, 20%额外血量，10点攻击，20%攻击系数 （前）
0.2防御，50%额外血量，20点攻击，50%攻击系数 （中）
0.3防御，80%额外血量，30点攻击，80%攻击系数 （后） 

装备数量：
小怪：
1min 0large, 0min 1large, 1min 1large (前)
2min 1large, 1min 2large, 2min 2large (中)
3min 2large, 2min 3large, 3min 3large (后)

boss:
0min 1large, 1min 1large, 0min 2large (前)
2min 2large, 0min 3large, 2min 3large (中)
1min 4large, 1min 5large, 0min 6large (后)

前期：0-30天
中期：30-60天
后期：60-90+天
0-20, 21-35, 36-55, 56-70, 70-90

经验值：
初始为level-1，升到level-2需要5exp
N为level-(n-1)升到level-n的exp，
level-n升到level-(n+1)需要(N+4)*1.1的exp

人物属性：(及格线)
{def=750, dmg=48, day=1,},
{def=900, dmg=52, day=10,},
{def=1380, dmg=75, day=20,},
{def=1740, dmg=105, day=30,},
{def=2250, dmg=152, day=40,},
{def=2820, dmg=197, day=50,},
{def=3210, dmg=256, day=60,},
{def=3630, dmg=333, day=70,},
{def=4260, dmg=438, day=80,},
{def=4710, dmg=584, day=90,},

[absorb=0.4, wepaon=34]
{hp=450, dmg_mod=1.41, day=1},
{hp=540, dmg_mod=1.53, day=10},
[absorb=0.6, weapon=51]
{hp=552, dmg_mod=1.47, day=20},
{hp=696, dmg_mod=2.06, day=30},
[absorb=0.6, weapon=85]
{hp=900, dmg_mod=1.79, day=40},
{hp=1128, dmg_mod=2.32, day=50},
{hp=1284, dmg_mod=3.01, day=60},
[absorb=0.7, weapon=85]
{hp=675, dmg_mod=1.79, day=40},
{hp=846, dmg_mod=2.32, day=50},
{hp=963, dmg_mod=3.01, day=60},
[absorb=0.7, weapon=136]
{hp=1089, dmg_mod=2.45, day=70},
{hp=1278, dmg_mod=3.22, day=80},
{hp=1413, dmg_mod=4.29, day=90},
[absorb=0.8, weapon=136]
{hp=726, dmg_mod=2.45, day=70},
{hp=852, dmg_mod=3.22, day=80},
{hp=942, dmg_mod=4.29, day=90},

[absorb=0.5, dmg_mult=2/90*day]
{armor=375, weapon=2160, day=1},
{armor=450, weapon=234, day=10},
[absorb=0.6, dmg_mult=2/90*day]
{armor=828, weapon=169, day=20},
{armor=1044, weapon=157, day=30},
[absorb=0.7, dmg_mult=2/90*day]
{armor=1575, weapon=171, day=40},
{armor=1974, weapon=177, day=50},
{armor=2247, weapon=192, day=60},
[absorb=0.8, dmg_mult=2/90*day]
{armor=2904, weapon=214, day=70},
{armor=3408, weapon=246, day=80},
{armor=3768, weapon=292, day=90},

公用装备前期+50hp, 中期+100hp，后期+200hp
公用装备前期42dmg，中期68dmg，后期102dmg

wilson: 中期装备+200hp, absorb=0.7，武器dmg=150，卷轴buff
{hp={300, 500}, dmg_mod={0, 1.0}, max_level=10 },
{hp={500, 750}, dmg_mod={1.0, 2.0}, max_level=20},
{hp={750, 950}, dmg_mod={2.0, 3.0}, max_level=30},

wathgrithr: 前期续航强，absorb=0.6, 武器dmg=34-68
{hp={400, 700}, dmg_mod={.25, 1.75}, max_level=10 },
{hp={700, 900}, dmg_mod={1.5, 2.5}, max_level=20},
{hp={900, 1000}, dmg_mod={2.5, 3.0}, max_level=30},

wickbottom: 后期远程武器，absorb=0.8, 武器dmg=200
{hp={200, 350}, dmg_mod={0, 0.9}, max_level=10 },
{hp={350, 600}, dmg_mod={0.9, 1.8}, max_level=20},
{hp={600, 950}, dmg_mod={1.8, 3.6}, max_level=30},


女武神吸血提升若干倍，前期可获得征服者，
lv3+攻击，lv5征服者, lv7+防御，phase2肉食者+杀怪吸血
可以制造哈迪斯pro，+穿透*n
哈迪斯，+穿透，

大力士血量高，受到攻击会回血，回血强，霸体
可以制造赫拉克勒斯pro，生命值达标后，攻击力=生命值*0.n

赫拉克勒斯，++生命
反甲，防御较低，反弹伤害

阿努比斯，每杀死一种单位，+1攻击力


元素之力，每过一天增加2%几率

]]