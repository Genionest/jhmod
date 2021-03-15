local items = {
	{
		{
			name = "tp_alloy",
			price = 20,
			img = "tp_alloy#",
		},
		{
			name = "tp_gingko_leaf",
			price = 15,
			img = "tp_gingko_leaf#",
		},
		{
			name = "tp_spear_lance",
			price = 50,
			img = "spear_forge_lance#",
		},
		{
			name = "tp_spear_gungnir",
			price = 50,
			img = "spear_forge_gungnir#",
		},
		{
			name = "tp_spear_wrestle",
			price = 50,
			img = "spear_wathgrithr_wrestle#",
		},
		{
			name = "tp_armor_lamellar",
			price = 55,
			img = "armor_wood_lamellar#",
		},
		{
			name = "tp_hat_helm",
			price = 55,
			img = "footballhat_combathelm2#",
		},
		{
			name = "scroll_grow",
			price = 55,
			img = "scroll_grow#",
		},
		{
			name = "scroll_pig_teleport",
			price = 15,
			img = "scroll_pig_teleport#",
		},
		{
			name = "scroll_pigman",
			price = 40,
			img = "scroll_pigman#",
		},
		{
			name = "scroll_bunnyman",
			price = 40,
			img = "scroll_bunnyman#",
		},
		{
			name = "tp_potion_dry",
			price = 35,
			img = "tp_potion_dry#",
		},
		{
			name = "tp_potion_crazy",
			price = 60,
			img = "tp_potion_crazy#",
		},
		{
			name = "tp_potion_smell",
			price = 30,
			img = "tp_potion_smell#",
		},
		{
			name = "tp_potion_shine",
			price = 65,
			img = "tp_potion_shine#",
		},
		{
			name = "tp_gift",
			price = 1000,
			img = "tp_gift#",
		},
	},
	{
		{
			name = "tp_war_tree_seed",
			price = 55,
			img = "tp_war_tree_spaling#",
		},
		{
			name = "tp_defense_tree_seed",
			price = 55,
			img = "tp_defense_tree_spaling#",
		},
		{
			name = "tp_potion_warm",
			price = 45,
			img = "tp_potion_warm#",
		},
		{
			name = "tp_potion_cool",
			price = 45,
			img = "tp_potion_cool#",
		},
		{
			name = "tp_spear_fire",
			price = 175,
			img = "tp_spear_fire#",
		},
		{
			name = "tp_spear_lightning",
			price = 175,
			img = "tp_spear_lightning#",
		},
		{
			name = "tp_armor_health",
			price = 205,
			img = "tp_armor_health#",
		},
		{
			name = "tp_armor_firm",
			price = 205,
			img = "tp_armor_firm#",
		},
		{
			name = "tp_hat_health",
			price = 225,
			img = "tp_hat_health#",
		},
		{
			name = "tp_epic",
			price = 1000,
			img = "tp_epic#",
		},
	},
}

local function TitleClass()
	local title_class = {
		titles = {},
		add_title = function(t, title, n)
			n = n or 1
			for i = 1, n do
				table.insert(t.titles, title)
			end
		end,
		get_title = function(t, page)
			return t.titles[page]
		end,
		get_max_pages = function(t)
			return #t.titles
		end,
	}
	return title_class
end

local function GoodsClass(name, img, price)
	local goods_class = {
		name = name,
		img = WgImg(img),
		price = price,
		get_price = function(t)
			return "$"..t.price
		end,
		get_name = function(t)
			return STRINGS.NAMES[string.upper(t.name)]
		end,
	}
	return goods_class
end

local function GoodsManagerClass()
	local goods_manager_class = {
		goods_house = {},
		add_bar = function(t)
			table.insert(t.goods_house, {})
		end,
		add_goods = function(t, n, goods)
			table.insert(t.goods_house[n], goods)
		end,
		get_bar = function(t, n)
			return t.goods_house[n]
		end,
	}
	return goods_manager_class
end

local function BuySystemClass()
	local buy_system_class = {
		get_balance = function(t)
			local tpbuy = GetPlayer().components.tpbuy
			if tpbuy then
				return tpbuy:CountMoney() or 0
			end
		end,
		buy_item = function(t, item, price)
			local tpbuy = GetPlayer().components.tpbuy
			if tpbuy and tpbuy:CanBuy(price) then
				local goods = SpawnPrefab(item)
				if goods.components.inventoryitem then
					GetPlayer().components.inventory:GiveItem(goods)
					GetPlayer().components.tpbuy:Buy(price)
				end
			end
		end,
	}
	return buy_system_class
end

local function SalePanelDataClass()
	local sale_panel_data_class = {
		cur_page = 1,
		max_page = 1,
		title_manager = TitleClass(),
		goods_manager = GoodsManagerClass(),
		buy_system = BuySystemClass(),
		get_title = function(t)
			return t.title_manager:get_title(t.cur_page)
		end,
		get_goods_bar = function(t)
			return t.goods_manager:get_bar(t.cur_page)
		end,
		page_turn = function(t, dt)
			t.cur_page = math.min(t.max_page, math.max(1, t.cur_page+dt))
		end,
		get_balance = function(t)
			return t.buy_system:get_balance()
		end,
		get_balance_string = function(t)
			return "您的余额："..t:get_balance()
		end,
		buy_item = function(t, goods)
			t.buy_system:buy_item(goods.name, goods.price)
		end,
	}
	return sale_panel_data_class
end

local title_manager = TitleClass()
title_manager:add_title("点击购买你想要的物品", 2)

local goods_manager = GoodsManagerClass()
for k, v in pairs(items) do
	goods_manager:add_bar()
	for k2, v2 in pairs(v) do
		goods_manager:add_goods(k, GoodsClass(v2.name, v2.img, v2.price) )
	end
end

local sale_panel_data = SalePanelDataClass()
sale_panel_data.title_manager = title_manager
sale_panel_data.goods_manager = goods_manager
-- sale_panel_data.buy_system = BuySystemClass()
sale_panel_data.max_page = title_manager:get_max_pages()
WARGON.DATA.sale_panel_data = sale_panel_data