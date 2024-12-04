local t = {
    tp_scroll_bird = {"百鸟卷轴", "召唤一群鸟"}, 
tp_scroll_grow = {"生长卷轴", "催熟周围的作物"}, 
tp_scroll_lightning = {"闪电卷轴", "召唤闪电"}, 
tp_scroll_sleep = {"睡眠卷轴", "催眠周围的生物"}, 
tp_scroll_tentacle = {"触手卷轴", "召唤触手"}, 
tp_scroll_volcano = {"火山卷轴", "召唤陨石"}, 
}

local t2 = {
    tp_plantable_reeds = {'芦苇之茎', '种植出芦苇'},
	tp_plantable_flower_cave = {'荧光之茎', '种植出荧光果'},
	tp_plantable_grass_water = {'水草之茎', '种植出水草'},
	tp_plantable_mangrove = {'红树之茎', '种植出红树'},
}

for k, v in pairs(t2) do
    print(string.format([[
Util:AddString("%s", "%s", "%s")]], k, v[1], v[2]))
end