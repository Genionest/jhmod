local function tp_potion_shadow_on_attack(inst, data)
	if inst.components.tpbuff then
		inst.components.tpbuff:DoneBuff("tp_potion_shadow")
	end
end

local function create_speech(inst, str, colour)
	local fx = SpawnPrefab("tp_fx_speech")
	fx.Transform:SetPosition(0,0,0)
	fx.tp_str = str
	fx.tp_colour = {x=colour[1], y=colour[2], z=colour[3]}
	inst:AddChild(fx)
end

local buffs = {
	tp_ballhat = {
		time = 30,
		add = function(inst, cmp)
			inst.components.combat:AddDamageModifier("tp_ballhat", .2)
			if cmp.fxs["tp_ballhat"] == nil then
				cmp.fxs["tp_ballhat"] = WARGON.make_fx(inst, "tp_fx_alive_sparklefx", true)
			end
		end,	
		rm = function(inst, cmp)
			inst.components.combat:RemoveDamageModifier("tp_ballhat")
			if cmp.fxs["tp_ballhat"] then
				cmp.fxs["tp_ballhat"]:Remove()
				cmp.fxs["tp_ballhat"] = nil
			end
		end,
		img = "footballhat_combathelm#",
	},
	scroll_pig_armorex = {
		time = 80,
		add = function(inst, cmp)
			inst.components.health.absorb = .8
			if cmp.fxs["scroll_pig_armorex"] == nil then
				cmp.fxs["scroll_pig_armorex"] = SpawnPrefab('tp_fx_scroll_pig_buff')
				cmp.fxs["scroll_pig_armorex"].fx_name = "tp_fx_scroll_pig_armorex"
				inst:AddChild(cmp.fxs["scroll_pig_armorex"])
				cmp.fxs["scroll_pig_armorex"].Transform:SetPosition(0,0,0)
			end
		end,
		rm = function(inst, cmp)
			inst.components.health.absorb = 0
			if cmp.fxs["scroll_pig_armorex"] then
				cmp.fxs["scroll_pig_armorex"]:Remove()
				cmp.fxs["scroll_pig_armorex"] = nil
			end
		end,
	},
	scroll_pig_damage = {
		time = 80,
		add = function(inst, cmp)
			inst.components.combat:AddDamageModifier('scroll_pig_damage', 1)
			if cmp.fxs["scroll_pig_damage"] == nil then
				cmp.fxs["scroll_pig_damage"] = SpawnPrefab('tp_fx_scroll_pig_buff')
				cmp.fxs["scroll_pig_damage"].fx_name = 'tp_fx_scroll_pig_damage'
				inst:AddChild(cmp.fxs["scroll_pig_damage"])
				cmp.fxs["scroll_pig_damage"].Transform:SetPosition(0,0,0)
			end
		end,
		rm = function(inst, cmp)
			inst.components.combat:RemoveDamageModifier('scroll_pig_damage')
			if cmp.fxs["scroll_pig_damage"] then
				cmp.fxs["scroll_pig_damage"]:Remove()
				cmp.fxs["scroll_pig_damage"] = nil
			end
		end,
	},
	scroll_pig_speed = {
		time = 80,
		add = function(inst, cmp)
			inst.components.locomotor:AddSpeedModifier_Mult('scroll_pig_speed', .5)
			if cmp.fxs["scroll_pig_speed"] == nil then
				cmp.fxs["scroll_pig_speed"] = SpawnPrefab('tp_fx_scroll_pig_buff')
				cmp.fxs["scroll_pig_speed"].fx_name = 'tp_fx_scroll_pig_speed'
				inst:AddChild(cmp.fxs["scroll_pig_speed"])
				cmp.fxs["scroll_pig_speed"].Transform:SetPosition(0,0,0)
			end
		end,
		rm = function(inst, cmp)
			inst.components.locomotor:RemoveSpeedModifier_Mult('scroll_pig_speed')
			if cmp.fxs["scroll_pig_speed"] then
				cmp.fxs["scroll_pig_speed"]:Remove()
				cmp.fxs["scroll_pig_speed"] = nil
			end
		end,
	},
	scroll_pig_heal = {
		time = 80,
		add = function(inst, cmp)
			inst.components.health:DoDelta(500)
			inst.components.health:StartRegen(50, 1)
			if cmp.fxs["scroll_pig_heal"] == nil then
				cmp.fxs["scroll_pig_heal"] = SpawnPrefab('tp_fx_scroll_pig_buff')
				cmp.fxs["scroll_pig_heal"].fx_name = 'tp_fx_scroll_pig_heal'
				inst:AddChild(cmp.fxs["scroll_pig_heal"])
				cmp.fxs["scroll_pig_heal"].Transform:SetPosition(0,0,0)
			end
		end,
		rm = function(inst, cmp)
			inst.components.health:StopRegen()
			if cmp.fxs["scroll_pig_heal"] then
				cmp.fxs["scroll_pig_heal"]:Remove()
				cmp.fxs["scroll_pig_heal"] = nil
			end
		end,
	},
	scroll_pig_health = {
		time = 180,
		add = function(inst, cmp)
			inst.components.health:SetMaxHealth(600)
			inst.components.health:DoDelta(0)
			if cmp.fxs["scroll_pig_health"] == nil then
				cmp.fxs["scroll_pig_health"] = SpawnPrefab('tp_fx_scroll_pig_buff')
				cmp.fxs["scroll_pig_health"].fx_name = 'tp_fx_scroll_pig_health'
				inst:AddChild(cmp.fxs["scroll_pig_health"])
				cmp.fxs["scroll_pig_health"].Transform:SetPosition(0,0,0)
			end
		end,
		rm = function(inst, cmp)
			local cur = inst.components.health.currenthealth
			local max_hp = 350
			if inst:HasTag("werepig") then
				max_hp = 450
			end
			inst.components.health:SetMaxHealth(max_hp)
			inst.components.health.currenthealth = cur
			inst.components.health:DoDelta(0)
			if cmp.fxs["scroll_pig_health"] then
				cmp.fxs["scroll_pig_health"]:Remove()
				cmp.fxs["scroll_pig_health"] = nil
			end
		end,
	},
	scroll_wind = {
		time = 240,
		add = function(inst, cmp)
			inst.components.locomotor:AddSpeedModifier_Mult("scroll_wind", .3)
			if cmp.tasks["scroll_wind"] == nil then
				cmp.tasks["scroll_wind"] = WARGON.per_task(inst, .5, function()
					if inst.sg:HasStateTag("moving") then
						local fx = WARGON.make_fx(inst, "tp_fx_leaf_"..math.random(4))
					end
				end)
			end
		end,
		rm = function(inst, cmp)
			inst.components.locomotor:RemoveSpeedModifier_Mult("scroll_wind")
			if cmp.tasks["scroll_wind"] then
				cmp.tasks["scroll_wind"]:Cancel()
				cmp.tasks["scroll_wind"] = nil
			end
		end,
		img = "scroll_wind#",
	},
	tp_pack_catcoon = {
		time = 1,
		add = function(inst, cmp)
			inst.components.locomotor:AddSpeedModifier_Mult("tp_pack_catcoon", .3)
			if cmp.tasks["tp_pack_catcoon"] == nil then
				cmp.tasks["tp_pack_catcoon"] = WARGON.per_task(inst, .1, function()
					if inst.sg:HasStateTag("moving") then
						local fx = WARGON.make_fx(inst, "tp_fx_wilson_run")
						fx.master = inst
					end
				end)
			end
		end,
		rm = function(inst, cmp)
			inst.components.locomotor:RemoveSpeedModifier_Mult("tp_pack_catcoon")
			if cmp.tasks["tp_pack_catcoon"] then
				cmp.tasks["tp_pack_catcoon"]:Cancel()
				cmp.tasks["tp_pack_catcoon"] = nil
			end
		end,
	},
	tp_spear_speed = {
		time = 3,
		add = function(inst, cmp)
			inst.components.locomotor:AddSpeedModifier_Mult("tp_spear_speed", .25)
			if cmp.tasks["tp_spear_speed"] == nil then
				-- cmp.tasks["tp_spear_speed"] = 
			end
		end,
		rm = function(inst, cmp)
			inst.components.locomotor:RemoveSpeedModifier_Mult("tp_spear_speed")
			if cmp.tasks["tp_spear_speed"] then
				cmp.tasks["tp_spear_speed"]:Cancel()
				cmp.tasks["tp_spear_speed"] = nil
			end
		end,
		img = "tp_spear_speed#",
	},
	tp_potion_health_small = {
		time = 10,
		add = function(inst, cmp)
			if cmp.tasks["tp_potion_health_small"] == nil then
				cmp.tasks["tp_potion_health_small"] = WARGON.per_task(inst, 1, function()
					if inst.components.health then
						inst.components.health:DoDelta(3)
					end
				end)
			end
		end,
		rm = function(inst, cmp)
			if cmp.tasks["tp_potion_health_small"] then
				cmp.tasks["tp_potion_health_small"]:Cancel()
				cmp.tasks["tp_potion_health_small"] = nil
			end
		end,
		img = "tp_potion_health_small#",
	},
	tp_potion_sanity_small = {
		time = 10,
		add = function(inst, cmp)
			if cmp.tasks["tp_potion_sanity_small"] == nil then
				cmp.tasks["tp_potion_sanity_small"] = WARGON.per_task(inst, 1, function()
					if inst.components.sanity then
						inst.components.sanity:DoDelta(3)
					end
				end)
			end
		end,
		rm = function(inst, cmp)
			if cmp.tasks["tp_potion_sanity_small"] then
				cmp.tasks["tp_potion_sanity_small"]:Cancel()
				cmp.tasks["tp_potion_sanity_small"] = nil
			end
		end,
		img = "tp_potion_sanity_small#",
	},
	tp_potion_crazy = {
		time = 60,
		add = function(inst, cmp)
			WARGON.add_speed_rate(inst, "tp_potion_crazy", .2)
			if cmp.tasks["tp_potion_crazy"] == nil then
				cmp.tasks["tp_potion_crazy"] = WARGON.per_task(inst, 2, function()
					if inst.components.sanity then
						inst.components.sanity:DoDelta(-1, true)
					end
				end)
			end
		end,
		rm = function(inst, cmp)
			WARGON.remove_speed_rate(inst, "tp_potion_crazy")
			if cmp.tasks["tp_potion_crazy"] then
				cmp.tasks["tp_potion_crazy"]:Cancel()
				cmp.tasks["tp_potion_crazy"] = nil
			end
		end,
		img = "tp_potion_crazy#",
	},
	tp_potion_shine = {
		time = 480,
		add = function(inst, cmp)
			if cmp.fxs["tp_potion_shine"] == nil then
				cmp.fxs["tp_potion_shine"] = SpawnPrefab("tp_fx_light")
				inst:AddChild(cmp.fxs["tp_potion_shine"])
			end
		end,
		rm = function(inst, cmp)
			if cmp.fxs["tp_potion_shine"] then
				cmp.fxs["tp_potion_shine"]:Remove()
				cmp.fxs["tp_potion_shine"] = nil
			end
		end,
		img = "tp_potion_shine#",
	},
	tp_potion_dry = {
		time = 480,
		add = function(inst, cmp)
			inst.components.moisture.baseDryingRate = 0.9
		end,
		rm = function(inst, cmp)
			inst.components.moisture.baseDryingRate = 0
		end,
		img = "tp_potion_dry#",
	},
	tp_potion_smell = {
		time = 480,
		add = function(inst, cmp)
			inst:AddTag("houndfriend")
			inst:AddTagNum("beefalo", 1)
		end,
		rm = function(inst, cmp)
			inst:RemoveTag("houndfriend")
			inst:AddTagNum("beefalo", -1)
		end,
		img = "tp_potion_smell#",
	},
	tp_potion_warth = {
		time = 60,
		add = function(inst, cmp)
			local fx = SpawnPrefab("tp_fx_speech")
			fx.Transform:SetPosition(0,0,0)
			fx.tp_str = "阿\n攻"
			fx.tp_colour = {x=1, y=0, z=0}
			inst:AddChild(fx)
			WARGON.add_dmg_rate(inst, "tp_potion_warth", .2)
			if cmp.tasks["tp_potion_warth"] == nil then
				cmp.tasks["tp_potion_warth"] = WARGON.per_task(inst, 2, function()
					if inst.components.sanity then
						inst.components.sanity:DoDelta(-1, true)
					end
				end)
			end
		end,
		rm = function(inst, cmp)
			WARGON.remove_dmg_rate(inst, "tp_potion_warth")
			if cmp.tasks["tp_potion_warth"] then
				cmp.tasks["tp_potion_warth"]:Cancel()
				cmp.tasks["tp_potion_warth"] = nil
			end
		end,
		img = "tp_potion_warth#",
	},
	tp_potion_killer = {
		time = 60,
		add = function(inst, cmp)
			local fx = SpawnPrefab("tp_fx_speech")
			fx.Transform:SetPosition(0,0,0)
			fx.tp_str = "夜\n叉\n戮"
			fx.tp_colour = {x=1, y=0, z=0}
			inst:AddChild(fx)
			WARGON.add_dmg_rate(inst, "tp_potion_killer", .6)
			if inst:HasTag("player") then
				if inst.components.tpbody then
					inst.components.tpbody.health_penalty = 1
				end
				if inst.components.health then
					inst.components.health:RecalculatePenalty()
				end
			end
		end,
		rm = function(inst, cmp)
			WARGON.remove_dmg_rate(inst, "tp_potion_killer")
			if inst.components.tpbody then
				inst.components.tpbody.health_penalty = 0
			end
			if inst.components.health then
				inst.components.health:RecalculatePenalty()
			end
		end,
		img = "tp_potion_killer#",
	},
	tp_potion_shadow = {
		time = 60,
		add = function(inst, cmp)
			local fx = SpawnPrefab("tp_fx_speech")
			fx.Transform:SetPosition(0,0,0)
			fx.tp_str = "月\n隐"
			fx.tp_colour = {x=0, y=1, z=1}
			inst:AddChild(fx)
			if inst:HasTag("player") then
				inst:AddTagNum("notarget", 1)
				inst.AnimState:SetMultColour(1, 1, 1, .5)
				inst:ListenForEvent("onhitother", tp_potion_shadow_on_attack)
				if cmp.tasks["tp_potion_shadow"] == nil then
					cmp.tasks["tp_potion_shadow"] = WARGON.per_task(inst, 2, function()
						if inst.components.sanity then
							inst.components.sanity:DoDelta(-1, true)
						end
					end)
				end
			end
		end,
		rm = function(inst, cmp)
			inst:AddTagNum("notarget", -1)
			inst.AnimState:SetMultColour(1, 1, 1, 1)
			inst:RemoveEventCallback("onhitother", tp_potion_shadow_on_attack)
			if cmp.tasks["tp_potion_shadow"] then
				cmp.tasks["tp_potion_shadow"]:Cancel()
				cmp.tasks["tp_potion_shadow"] = nil
			end
		end,
		img = "tp_potion_shadow#",
	},
	tp_potion_iron = {
		time = 60,
		add = function(inst, cmp)
			local fx = SpawnPrefab("tp_fx_speech")
			fx.Transform:SetPosition(0,0,0)
			fx.tp_str = "哞\n护"
			fx.tp_colour = {x=0, y=0, z=1}
			inst:AddChild(fx)
			if inst.components.tpbody then
				inst.components.tpbody:AddAbsorbModifier("tp_potion_iron", .2)
			end
			if cmp.tasks["tp_potion_iron"] == nil then
				cmp.tasks["tp_potion_iron"] = WARGON.per_task(inst, 2, function()
					if inst.components.sanity then
						inst.components.sanity:DoDelta(-1, true)
					end
				end)
			end
		end,
		rm = function(inst, cmp)
			if inst.components.tpbody then
				inst.components.tpbody:RemoveAbsorbModifier("tp_potion_iron")
			end
			if cmp.tasks["tp_potion_iron"] then
				cmp.tasks["tp_potion_iron"]:Cancel()
				cmp.tasks["tp_potion_iron"] = nil
			end
		end,
		img = "tp_potion_iron#",
	},
	tp_potion_metal = {
		time = 60,
		add = function(inst, cmp)
			local fx = SpawnPrefab("tp_fx_speech")
			fx.Transform:SetPosition(0,0,0)
			fx.tp_str = "刚\n躯"
			fx.tp_colour = {x=1, y=1, z=0}
			inst:AddChild(fx)
			inst:AddTagNum("not_hit_stunned", 1)
			if cmp.tasks["tp_potion_metal"] == nil then
				cmp.tasks["tp_potion_metal"] = WARGON.per_task(inst, 2, function()
					if inst.components.sanity then
						inst.components.sanity:DoDelta(-1, true)
					end
				end)
			end
		end,
		rm = function(inst, cmp)
			inst:AddTagNum("not_hit_stunned", -1)
			if cmp.tasks["tp_potion_metal"] then
				cmp.tasks["tp_potion_metal"]:Cancel()
				cmp.tasks["tp_potion_metal"] = nil
			end
		end,
		img = "tp_potion_metal#",
	},
	tp_potion_cool = {
		time = 480,
		add = function(inst, cmp)
			if cmp.tasks["tp_potion_cool"] == nil then
				cmp.tasks["tp_potion_cool"] = SpawnPrefab("tp_fx_cool")
				inst:AddChild(cmp.tasks["tp_potion_cool"])
				cmp.tasks["tp_potion_cool"]:set_pos(0,0,0)
			end
		end,
		rm = function(inst, cmp)
			if cmp.tasks["tp_potion_cool"] then
				cmp.tasks["tp_potion_cool"]:Remove()
				cmp.tasks["tp_potion_cool"] = nil
			end
		end,
		img = "tp_potion_cool",
	},
	tp_potion_warm = {
		time = 480,
		add = function(inst, cmp)
			if cmp.tasks["tp_potion_warm"] == nil then
				cmp.tasks["tp_potion_warm"] = SpawnPrefab("tp_fx_warm")
				inst:AddChild(cmp.tasks["tp_potion_warm"])
				cmp.tasks["tp_potion_warm"]:set_pos(0,0,0)
			end
		end,
		rm = function(inst, cmp)
			if cmp.tasks["tp_potion_warm"] then
				cmp.tasks["tp_potion_warm"]:Remove()
				cmp.tasks["tp_potion_warm"] = nil
			end
		end,
		img = "tp_potion_warm#",
	},
	tp_fast_work = {
		time = 10,
		add = function(inst, cmp)
			inst:AddTag("tp_fast_work")
			if cmp.tasks["tp_fast_work"] == nil then
				cmp.tasks["tp_fast_work"] = inst:per_task(1, function()
					if inst.components.hunger then
						inst.components.hunger:DoDelta(-1, true)
					end
				end)
			end
		end,
		rm = function(inst, cmp)
			inst:RemoveTag("tp_fast_work")
			if cmp.tasks["tp_fast_work"] then
				cmp.tasks["tp_fast_work"]:Cancel()
				cmp.tasks["tp_fast_work"] = nil
			end
		end,
		img = "shovel",
	},
	tp_spear_combat = {
		time = 5,
		add = function(inst, cmp)
			cmp.tp_spear_combat_num = cmp.tp_spear_combat_num or 0
			cmp.tp_spear_combat_num = math.min(cmp.tp_spear_combat_num+1,5)
			local rate = cmp.tp_spear_combat_num * .1
			inst:add_dmg_rate("tp_spear_combat", rate)
		end,
		rm = function(inst, cmp)
			cmp.tp_spear_combat_num = 0
			inst:rm_dmg_rate("tp_spear_combat")
		end,
		img = "tp_spear_combat#",
	},
	tp_spear_conqueror = {
		time = 5,
		add = function(inst, cmp)
			cmp.tp_spear_conqueror_num = cmp.tp_spear_conqueror_num or 0
			cmp.tp_spear_conqueror_num = math.min(cmp.tp_spear_conqueror_num+1,5)
			if cmp.tp_spear_conqueror_num >= 5 then
				cmp:AddBuff("tp_spear_conqueror_buff")
			end
		end,
		rm = function(inst, cmp)
			cmp.tp_spear_conqueror_num = 0
		end,
	},
	tp_spear_conqueror_buff = {
		time = 5,
		add = function(inst, cmp)
			-- inst:add_dmg_rate("tp_spear_conqueror", .15)
			inst:AddTag("tp_spear_conqueror")
		end,
		rm = function(inst, cmp)
			-- inst:rm_dmg_rate("tp_spear_conqueror")
			inst:RemoveTag("tp_spear_conqueror")
		end,
		img = "tp_spear_conqueror#",
	},
	-------------- debuff list --------------------------------
	tp_wound = {
		time = 5,
		add = function(inst, cmp)
			inst:AddTag("tp_wound")
			if cmp.fxs["tp_wound"] == nil then
				create_speech(inst, "重\n伤", {.8,0,0})
				cmp.fxs["tp_wound"] = SpawnPrefab("poisonbubble")
				WARGON.set_scale(cmp.fxs["tp_wound"], .5)
				inst:AddChild(cmp.fxs["tp_wound"])
				cmp.fxs["tp_wound"].Transform:SetPosition(0, 0, 0)
				cmp.fxs["tp_wound"].AnimState:SetMultColour(1,.1,.1,1)
				WARGON.no_save(cmp.fxs["tp_wound"])
			end
		end,
		rm = function(inst, cmp)
			inst:RemoveTag("tp_wound")
			if cmp.fxs["tp_wound"] then
				cmp.fxs["tp_wound"]:Remove()
				cmp.fxs["tp_wound"] = nil
			end
		end,
		debuff = true,
		img = "spidergland",
	},
	tp_hurt = {
		time = 10,
		add = function(inst, cmp)
			if cmp.tasks["tp_hurt"] == nil then
				create_speech(inst, "流\n血", {.8,0,0})
				cmp.tasks["tp_hurt"] = WARGON.per_task(inst, 1, function()
					local mult = inst.components.health.poison_damage_scale
					local dt = 2 * mult
					inst.components.health:DoDelta(-dt, false, "tp_hurt")
					local fx = WARGON.make_fx(inst, "poisonbubble")
					fx.AnimState:SetMultColour(1,.1,.1,1)
					WARGON.no_save(fx)
					WARGON.do_task(fx, 1, function()
						fx:Remove()
					end)
				end)
			end
		end,
		rm = function(inst, cmp)
			if cmp.tasks["tp_hurt"] then
				cmp.tasks["tp_hurt"]:Cancel()
				cmp.tasks["tp_hurt"] = nil
			end
		end,
		debuff = true,
		img = "health_down",
	},
	tp_armor_broken = {
		time = 5,
		add = function(inst, cmp)
			inst:AddTag("tp_armor_broken")
			if cmp.fxs["tp_armor_broken"] == nil then
				create_speech(inst, "破\n甲", {0,0,.8})
				cmp.fxs["tp_armor_broken"] = SpawnPrefab("tp_fx_armor_broken")
				inst:AddChild(cmp.fxs["tp_armor_broken"])
				cmp.fxs["tp_armor_broken"].Transform:SetPosition(0, 0, 0)
				if cmp.fxs["tp_armor_broken"].components.tpfollowimage then
					cmp.fxs["tp_armor_broken"].components.tpfollowimage:SetImage(
						"images/inventoryimages/tp_armor_broken.xml",
						"tp_armor_broken.tex")
				end
			end
		end,
		rm = function(inst, cmp)
			inst:RemoveTag("tp_armor_broken")
			if cmp.fxs["tp_armor_broken"] then
				cmp.fxs["tp_armor_broken"]:Remove()
				cmp.fxs["tp_armor_broken"] = nil
			end
		end,
		debuff = true,
		img = "tp_armor_broken#",
	}
}

GLOBAL.WARGON.DATA.tp_data_buff = {
    buffs = buffs,
}

local function BuffClass(name, time, add, rm, img, is_debuff)
	local class = {
		name = name,
		time = time,
		add = add,
		rm = rm,
		img = img and WgImg(img),
		is_debuff = is_debuff,
	}
	return class
end

local function BuffManagerClass()
	local class = {
		buffs = {},
		add_buff = function(self, buff)
			self.buffs[buff.name] = buff
		end,
		get_buff = function(self, buff_name)
			return self.buffs[buff_name]
		end,
		call_buff_add = function(self, buff_name, ...)
			self.buffs[buff_name].add(...)
		end,
		call_buff_rm = function(self, buff_name, ...)
			self.buffs[buff_name].rm(...)
		end,
		get_buff_time = function(self, buff_name)
			return self.buffs[buff_name].time
		end,
		get_buff_img_table = function(self, buff_name)
			local wgimg = self.buffs[buff_name].img
			if wgimg then
				return {wgimg.atlas, wgimg.img}
			end
		end,
		is_debuff = function(self, buff_name)
			return self.buffs[buff_name].is_debuff
		end,
	}
	return class
end

local buff_manager = BuffManagerClass()
for k, v in pairs(buffs) do
	local buff_class = BuffClass(k, v.time, v.add, v.rm, v.img, v.debuff)
	buff_manager:add_buff(buff_class)
end

GLOBAL.WARGON.DATA.tp_data_buff.buff_manager = buff_manager
