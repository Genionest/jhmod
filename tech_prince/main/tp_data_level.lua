local attrs_table = {
	{
		{
			"生命上限",
			"提升你的最大\n生命值",
			WgImg("lightbulb"),
			WgAnim({"health", "health", "anim"}),
		},
		{
			"理智上限",
			"提升你的最大\n理智值",
			WgImg("lightbulb"),
			WgAnim({"sanity", "sanity", "anim"}),
		},
		{
			"饥饿上限",
			"提升你的最大\n饥饿值",
			WgImg("lightbulb"),
			WgAnim({"hunger", "hunger", "anim"}),
		},
		{
			"伤害系数",
			"提升你造成的\n伤害",
			WgImg("spear"),
		},
		{
			"速度系数",
			"提升你的移动\n速度",
			WgImg("cane"),
		},
		{
			"食物回复",
			"提升食物的回\n复效果",
			WgImg("cookpot"),
		},
		{
			"饥饿倍率",
			"降低饥饿的速\n度",
			WgImg("bonestew"),
		},
		{
			"承受伤害",
			"降低你受到的\n伤害",
			WgImg("footballhat"),
		},
		{
			"恐惧降智",
			"降低夜晚和遇\n到怪物时的降\n低理智效果",
			WgImg("sanity_down"),
		},
		{
			"异常减免",
			"降低烧伤，毒\n伤和流血时的\n扣血效果",
			WgImg("health_down"),
		},
		{
			"熔炉武器",
			"提升部分熔炉\n武器的额外伤\n害",
			WgImg("spear_forge_lance#"),
		},
		{
			"诅咒上限",
			"提升你的最大\n诅咒值",
			WgImg("lightbulb"),
			WgAnim({"beaver_meter", "beaver_meter", "anim"})
		},
		{
			"攻速倍率",
			"降低你两次攻\n击的间隔时间",
			WgImg("cutlass"),
		},
		{
			"额外幸运",
			"提升部分战利\n品的掉落几率",
			WgImg("woodlegshat"),
		},
	},
}

local attr_fns = {
	{
		{
			id = "health",
			cal = function(self, player, is_dec)
				local max = player.components.health.maxhealth
				local measure = max + self.buffer.health
				local threshold = 150
				local dt = (measure < threshold) and 5 or 1
				if is_dec then
					dt = (measure > threshold) and -1 or -5
				end
				self.buffer.health = self.buffer.health + dt
			end,
			show = function(self, player)
				return player.components.health.maxhealth + self.buffer.health
			end,
		},
		{
			id = "sanity",
			cal = function(self, player, is_dec)
				local max = player.components.sanity.max
				local measure = max + self.buffer.sanity
				local threshold = 200
				local dt = (measure < threshold) and 5 or 1
				if is_dec then
					dt = (measure > threshold) and -1 or -5
				end
				self.buffer.sanity = self.buffer.sanity + dt
			end,
			show = function(self, player)
				return player.components.sanity.max + self.buffer.sanity
			end,
		},
		{
			id = "hunger",
			cal = function(self, player, is_dec)
				local max = player.components.hunger.max
				local measure = max + self.buffer.hunger
				local threshold = 150
				local dt = (measure < threshold) and 5 or 1
				if is_dec then
					dt = (measure > threshold) and -1 or -5
				end
				self.buffer.hunger = self.buffer.hunger + dt
			end,
			show = function(self, player)
				return player.components.hunger.max + self.buffer.hunger
			end,
		},
		{
			id = "damage",
			cal = function(self, player, is_dec)
				local rate = player.components.combat.attack_damage_modifiers["tplevel"] or 0
				local measure = rate + self.buffer.damage
				local threshold = 0
				local dt = (measure < threshold) and 5 or 1
				if is_dec then
					dt = (measure > threshold) and -1 or -5
				end
				self.buffer.damage = (self.buffer.damage*100+dt)/100
			end,
			show = function(self, player)
				local rate = player.components.combat.attack_damage_modifiers["tplevel"] or 0
				local number = rate + self.buffer.damage
				local word = tostring(100+number*100).."%"
				return word
			end,
		},
		{
			id = "speed",
			cal = function(self, player, is_dec)
				local rate = player.components.locomotor.speed_modifiers_mult["tplevel"] or 0
				local measure = rate + self.buffer.speed
				local threshold = 0
				local dt = (measure < threshold) and 5 or 1
				if is_dec then
					dt = (measure > threshold) and -1 or -5
				end
				self.buffer.speed = (self.buffer.speed*100 + dt)/100
			end,
			show = function(self, player)
				local rate = player.components.locomotor.speed_modifiers_mult["tplevel"] or 0
				local number = rate + self.buffer.speed
				local word = tostring(100+number*100).."%"
				return word
			end,
		},
		{
			id = "eater",
			cal = function(self, player, is_dec)
				local rate = player.components.eater.hungerabsorption or 1
				local measure = rate + self.buffer.eater
				local threshold = 1
				local dt = (measure < threshold) and 5 or 1
				if is_dec then
					dt = (measure > threshold) and -1 or -5
				end
				self.buffer.eater = (self.buffer.eater*100 + dt)/100
			end,
			show = function(self, player)
				local rate = player.components.eater.hungerabsorption or 1
				local number = rate + self.buffer.eater
				local word = tostring(100*number).."%"
				return word
			end,
		},
		{
			id = "hungry",
			cal = function(self, player, is_dec)
				local rate = player.components.hunger.burn_rate_modifiers["tplevel"] or 0
				local measure = rate + self.buffer.hungry
				local threshold = 0
				local dt = (measure > threshold) and -5 or -1
				if is_dec then
					dt = (measure < threshold) and 1 or 5
				end
				self.buffer.hungry = (self.buffer.hungry*100 + dt)/100
			end,
			dom = function(self, player)
				local rate = player.components.hunger.burn_rate_modifiers["tplevel"] or 0
				return rate + self.buffer.hungry > -.9
			end,
			show = function(self, player)
				local rate = player.components.hunger.burn_rate_modifiers["tplevel"] or 0
				local number = rate + self.buffer.hungry
				local word = tostring(100+number*100).."%"
				return word
			end,
		},
		{
			id = "absorb",
			cal = function(self, player, is_dec)
				local rate = player.components.tpbody and player.components.tpbody.absorb_mods["tplevel"] or 0
				local measure = rate + self.buffer.absorb
				local threshold = 0
				local dt = (measure < threshold) and 5 or 1
				if is_dec then
					dt = (measure > threshold) and -1 or -5
				end
				self.buffer.absorb = (self.buffer.absorb*100 + dt)/100
			end,
			dom = function(self, player)
				local rate = player.components.tpbody and player.components.tpbody.absorb_mods["tplevel"] or 0
				return rate + self.buffer.absorb < 0.9
			end,
			show = function(self, player)
				local rate = player.components.tpbody and player.components.tpbody.absorb_mods["tplevel"] or 0
				local number = (rate+self.buffer.absorb)
				local word = tostring(100-number*100).."%"
				return word
			end,
		},
		{
			id = "horror",
			cal = function(self, player, is_dec)
				local rate = player.components.sanity.neg_aura_mult or 1
				local measure = rate + self.buffer.horror
				local threshold = 1
				local dt = (measure > threshold) and -5 or -1
				if is_dec then
					dt = (measure < threshold) and 1 or 5
				end
				self.buffer.horror = (self.buffer.horror*100+dt)/100
			end,
			dom = function(self, player)
				local rate = player.components.sanity.neg_aura_mult or 1
				return rate + self.buffer.horror > .1
			end,
			show = function(self, player)
				local rate = player.components.sanity.neg_aura_mult or 1
				local number = rate + self.buffer.horror
				local word = tostring(number*100).."%"
				return word
			end,
		},
		{
			id = "nature",
			cal = function(self, player, is_dec)
				local rate = player.components.health.poison_damage_scale or 1
				local measure = rate + self.buffer.nature
				local threshold = 1
				local dt = (measure > threshold) and -5 or -1
				if is_dec then
					dt = (measure < threshold) and 1 or 5
				end
				self.buffer.nature = (self.buffer.nature*100+dt)/100
			end,
			dom = function(self, player)
				local rate = player.components.health.poison_damage_scale or 1
				return rate + self.buffer.nature > .1
			end,
			show = function(self, player)
				local rate = player.components.health.poison_damage_scale or 1
				local number = rate + self.buffer.nature
				local word = tostring(number*100).."%"
				return word
			end,
		},
		{
			id = "forge",
			cal = function(self, player, is_dec)
				local dmg = player.components.tplevel and player.components.tplevel.attr.forge or 0
				local measure = dmg + self.buffer.forge
				local threshold = 20
				local dt = (measure < threshold) and 5 or 1
				if is_dec then
					dt = (measure > threshold) and -1 or -5
				end
				self.buffer.forge = self.buffer.forge + dt
			end,
			show = function(self, player)
				local dmg = player.components.tplevel and player.components.tplevel.attr.forge or 0
				return dmg + self.buffer.forge
			end,
		},
		{
			id = "madval",
			cal = function(self, player, is_dec)
				local max = player.components.tpmadvalue and player.components.tpmadvalue.max or 100
				local measure = max + self.buffer.madval
				local threshold = 200
				local dt = (measure < threshold) and 5 or 1
				if is_dec then
					dt = (measure > threshold) and -1 or -5
				end
				self.buffer.madval = self.buffer.madval + dt
			end,
			show = function(self, player)
				local max = player.components.tpmadvalue and player.components.tpmadvalue.max or 100
				return max + self.buffer.madval
			end,
		},
		{
			id = "attack_period",
			cal = function(self, player, is_dec)
				-- local rate = player.components.combat.attack_period_modifiers["tplevel"]
				local dt = is_dec and -1 or 1
				self.buffer.attack_period = self.buffer.attack_period + dt
			end,
			dom = function(self, player)
				local rate = player.components.combat.attack_period_modifiers["tplevel"] or 0
				return -rate*100 + self.buffer.attack_period < 90
			end,
			show = function(self, player)
				local rate = player.components.combat.attack_period_modifiers["tplevel"] or 0
				local number = ( -rate*100 + self.buffer.attack_period )
				local word = tostring(number).."%"
				return word
			end,
		},
		{
			id = "lucky",
			cal = function(self, player, is_dec)
				local rate =  player.components.tpbody and player.components.tpbody.lucky or 0
				local dt = is_dec and -1 or 1
				self.buffer.lucky = self.buffer.lucky + dt
			end,
			dom = function(self, player)
				local rate =  player.components.tpbody and player.components.tpbody.lucky or 0
				return rate + self.buffer.lucky < 90
			end,
			show = function(self, player)
				local rate =  player.components.tpbody and player.components.tpbody.lucky or 0
				local number = rate + self.buffer.lucky
				local word = tostring(number).."%"
				return word
			end,
		},
	},
}

local function AttrClass(name, tip, wgimg, wganim)
	local class = {
		name = name,
		tip = tip,
		img = wgimg,
		anim = wganim,
		get_name = function(self)
			return self.name
		end,
		get_tip = function(self)
			return self.tip
		end,
		get_img = function(self)
			return self.img:GetImg()
		end,
		get_anim = function(self)
			if self.anim then
				return self.anim:GetAnim()
			end
		end,
	}
	return class
end

local function AttrManagerClass()
	local class = {
		attrs = {},
		add_bar = function(self)
			table.insert(self.attrs, {})
		end,
		add_attr = function(self, k, attr)
			table.insert(self.attrs[k], attr)
		end,
		get_attrs = function(self, k)
			return self.attrs[k]
		end,
		get_attr = function(self, bar, k)
			return self.attrs[bar][k]
		end,
	}
	return class
end

local function AttrFuncClass(id, cal, dom, show)
	local class = {
		id = id,
		cal = cal,
		dom = dom,
		show = show,
		get_id = function(self)
			return self.id
		end,
		get_cal = function(self)
			return self.cal
		end,
		get_dom = function(self)
			return self.dom
		end,
		get_show = function(self)
			return self.show
		end,
	}
	return class
end

local function AttrFuncManagerClass()
	local class = {
		fns = {},
		add_bar = function(self)
			table.insert(self.fns, {})
		end,
		add_attr_fn = function(self, k, attr_fn)
			table.insert(self.fns[k], attr_fn)
		end,
		get_attr_fn = function(self, bar, k)
			return self.fns[bar][k]
		end,
		get_id = function(self, bar, k)
			-- return self:get_attr_fn(bar, k).id
			local attr_fn = self:get_attr_fn(bar, k)
			return attr_fn:get_id()
		end,
		get_cal = function(self, bar, k)
			local attr_fn = self:get_attr_fn(bar, k)
			return attr_fn:get_cal()
		end,
		get_dom = function(self, bar, k)
			local attr_fn = self:get_attr_fn(bar, k)
			return attr_fn:get_dom()
		end,
		get_show = function(self, bar, k)
			local attr_fn = self:get_attr_fn(bar, k)
			return attr_fn:get_show()
		end,
	}
	return class
end

local function TitleClass()
	local class = {
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
	return class
end

local function LevelSystemClass()
	local class = {
		cur_page = 1,
		max_page = 1,
		title_manager = TitleClass(),
		attr_manager = AttrManagerClass(),
		buffer = {},
		fn_manager = AttrFuncManagerClass(),
		essences = 0,
		cost = 0,
		get_title = function(self)
			return self.title_manager:get_title(self.cur_page)
		end,
		get_attrs = function(self)
			return self.attr_manager:get_attrs(self.cur_page)
		end,
		init = function(self)
			local n = GetPlayer().components.tplevel:GetEssence()
			self.essences = n
			self.cost = 0
			for k, v in pairs(self.buffer) do
				self.buffer[k] = 0
			end
		end,
		get_essence = function(self)
			return self.essences
		end,
		get_essence_string = function(self)
			local n = self:get_essence()
			return "剩余的生命精华数: "..n
		end,
		get_level_string = function(self)
			local level = self.cost + GetPlayer().components.tplevel:GetLevel()
			return "当前等级: "..level
		end,
		can_level_up = function(self)
			return self:get_essence() > 0
		end,
		can_level_ret = function(self, k)
			-- local id = self.fns[self.cur_page][k].id
			local id = self.fn_manager:get_id(self.cur_page, k)
			return self.cost > 0 and self.buffer[id] ~= 0  -- 有些是小于0的
		end,
		with_level_up = function(self)
			self.essences = self.essences - 1
			self.cost = self.cost + 1
		end,
		with_level_ret = function(self)
			self.essences = self.essences + 1
			self.cost = self.cost - 1
		end,
		on_click_add = function(self, k)
			if self:can_level_up() then
				local player = GetPlayer()
				-- local dom = self.fns[self.cur_page][k].dom
				local dom = self.fn_manager:get_dom(self.cur_page, k)
				if not dom or dom(self, player) then
					-- self.fns[self.cur_page][k].cal(self, player)
					local cal = self.fn_manager:get_cal(self.cur_page, k)
					cal(self, player)
					self.with_level_up(self)
				end
			end
		end,
		on_click_dec = function(self, k)
			if self:can_level_ret(k) then
				local player = GetPlayer()
				-- self.fns[self.cur_page][k].cal(self, player, true)
				local cal = self.fn_manager:get_cal(self.cur_page, k)
				cal(self, player, true)
				self.with_level_ret(self)
			end
		end,
		get_attr_num = function(self, k)
			local player = GetPlayer()
			-- local attrs = self:get_attrs()
			-- local attr = attrs[k]
			local attr = self.attr_manager:get_attr(self.cur_page, k)
			local name = attr:get_name()
			-- local word = self.fns[self.cur_page][k].show(self, player)
			local show_fn = self.fn_manager:get_show(self.cur_page, k)
			local word = show_fn(self, player)
			return name.."\n"..word
		end,
		get_attr_tip = function(self, k)
			local attrs = self:get_attrs()
			local attr = attrs[k]
			local tip = attr:get_tip()
			return tip
		end,
		level_up = function(self)
			if self.cost > 0 then
				local player = GetPlayer()
				if player.components.tplevel then
					for k, v in pairs(self.buffer) do
						player.components.tplevel.attr[k] = player.components.tplevel.attr[k] + v
					end
					player.components.tplevel:Apply()
					WARGON.make_fx(player, "multifirework_fx")
					player.components.inventory:ConsumeByName("tp_epic", self.cost)
					player.components.tplevel:LevelUp(self.cost)
				end
			end
		end,
		page_turn = function(self, dt)
			self.cur_page = math.min(self.max_page, math.max(1, self.cur_page+dt))
		end,
		get_tip = function(self)
			return "按下CTRL时点击可以返还未确认的升级点"
		end,
	}
	return class
end

local attr_manager = AttrManagerClass()
for k,v in pairs(attrs_table) do
	attr_manager:add_bar()
	for k2, v2 in pairs(v) do
		attr_manager:add_attr( k, AttrClass(unpack(v2)) )
	end
end

local attr_func_manager = AttrFuncManagerClass()
for k, v in pairs(attr_fns) do
	attr_func_manager:add_bar()
	for k2, v2 in pairs(v) do
		attr_func_manager:add_attr_fn(k, AttrFuncClass(v2.id, v2.cal, v2.dom, v2.show))
	end
end

local buffer = {
	health = 0,
	sanity = 0,
	hunger = 0,
	damage = 0,
	speed  = 0,
	eater  = 0,
	hungry = 0,
	absorb = 0,
	horror = 0,
	nature = 0,
	forge  = 0,
	madval = 0,
	lucky  = 0,
	attack_period = 0,
	---------
}

local title_manager = TitleClass()
title_manager:add_title("基础属性")

local level_system = LevelSystemClass()
level_system.title_manager = title_manager
level_system.max_page = title_manager:get_max_pages()
level_system.attr_manager = attr_manager
level_system.fn_manager = attr_func_manager
level_system.buffer = buffer
GLOBAL.WARGON.DATA.tp_data_level = level_system