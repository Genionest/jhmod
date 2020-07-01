local function check_cmp(inst, cmp)
	if not inst.components[cmp] then
		inst:AddComponent(cmp)
	end
end

local function add_inventoryitem(inst, atlas, img, put, drop)
	check_cmp(inst, "inventoryitem")
	if atlas then inst.components.inventoryitem.atlasname = atlas end
	if img then inst.components.inventoryitem.imagename = img end
	if put then inst.components.inventoryitem:SetOnPutInInventoryFn(put) end
	if drop then inst.components.inventoryitem:SetOnDroppedFn(drop) end
end

local function add_inspectable(inst, getstatus)
	check_cmp(inst, "inspectable")
	if getstatus then inst.components.inspectable.getstatus = getstatus end
end

local function add_trader(inst, test, accept, refuse)
	check_cmp(inst, "trader")
	if test then inst.components.trader:SetAcceptTest(test) end
	if accept then inst.components.trader.onaccept = accept end
	if refuse then inst.components.trader.onrefuse = refuse end
end

local function add_tradable(inst, value)
	check_cmp(inst, "tradable")
	if value then inst.components.goldvalue = value end
end

local function add_stackable(inst, max)
	check_cmp(inst, "stackable")
	if max then inst.components.stackable.maxsize = max end
end

local function add_machine(inst, on, off, time, test)
	check_cmp(inst, "machine")
	if on then inst.components.machine.turnonfn = on end
	if off then inst.components.machine.turnofffn = off end
	if time then inst.components.machine.cooldowntime = time end
	if test then inst.components.machine.caninteractfn = test end
end

local function add_equippable(inst, slot, equip, unequip, pocket, effect)
	check_cmp(inst, "equippable")
	if slot then
		local slots = {
			hand = EQUIPSLOTS.HANDS,
			head = EQUIPSLOTS.HEAD,
			body = EQUIPSLOTS.BODY,
		}
		inst.components.equippable.equipslot = slots[slot]
	end
	if equip then inst.components.equippable:SetOnEquip(equip) end
	if unequip then inst.components.equippable:SetOnUnequip(unequip) end
	if pocket then inst.components.equippable:SetOnPocket(pocket) end
	if effect then
		if effect.bilei then inst.components.equippable.insulated = effect.bilei end  --避雷
		if effect.speed then inst.components.equippable.walkspeedmult = effect.speed end
		if effect.poison then inst.components.equippable.poisongasblocker = effect.poison end
		if effect.san then inst.components.equippable.dapperness = effect.san end
	end
end

local function add_book(inst, fn, test, act)
	check_cmp(inst, "book")
	if fn then inst.components.book.onread = fn end
	if test then inst.components.book.onreadtest = test end
	if act then
		local actions = {  -- 肯定不是在modmain环境里
			map = ACTIONS.READMAP,
		}
		inst.components.book:SetAction(actions[act] or act)
	end
end

local function add_finiteuses(inst, use, max, fn, act, num)
	check_cmp(inst, "finiteuses")
	if use then inst.components.finiteuses:SetUses(use) end
	if max then inst.components.finiteuses:SetMaxUses(max) end
	if fn then inst.components.finiteuses:SetOnFinished(fn) end
	if act and num then inst.components.finiteuses:SetConsumption(act, num) end
end

local function add_fuel(inst, typ, value)
	check_cmp(inst, "fuel")
	if typ then 
		if type(typ) == "string" then
			inst.components.fuel.fueltype = string.upper(typ)
		else
			inst.components.fuel.fueltype = string.upper(typ[1])
			inst.components.fuel.secondaryfueltype = string.upper(typ[2])
		end
	end
	if value then inst.components.fuel.fuelvalue = value end
end

local function add_fueled(inst, typ, time, fn, accept)
	check_cmp(inst, "fueled")
	if typ then 
		if type(typ) == "string" then
			inst.components.fueled.fueltype = string.upper(typ)
		else
			inst.components.fueled.fueltype = string.upper(typ[1])
			inst.components.fueled.secondaryfueltype = string.upper(typ[2])
		end
	end
	if time then inst.components.fueled:InitializeFuelLevel(time) end
	if fn then
		if fn.finish then inst.components.fueled:SetDepletedFn(fn.finish) end
		if fn.section then inst.components.fueled:SetSectionCallback(fn.section) end
		if fn.fuel then inst.components.fueled.ontakefuelfn = fn.fuel end
	end
	if accept then inst.components.fueled.accepting = accept end
end

local function add_armor(inst, armor, absorb)
	check_cmp(inst, "armor")
	if armor and absorb then inst.components.armor:InitCondition(armor, absorb) end
end

local function add_weapon(inst, dmg, range, fn, fx)
	check_cmp(inst, "weapon")
	if dmg then inst.components.weapon:SetDamage(dmg) end
	if range then
		if type(range) == 'table' then
			local range_atk = range.atk or range[1]
			local range_hit = range.hit or range[2] or range_atk
			inst.components.weapon:SetRange(range_atk, range_hit)
		else
			inst.components.weapon:SetRange(range)
		end
	end
	if fn then inst.components.weapon:SetOnAttack(fn~="nil" and fn or nil) end
	if fx then inst.components.weapon:SetProjectile(fx~="nil" and fx or nil) end
end

local function add_combat(inst, dmg, per, re, keep, hit, atk, symbol, player, range)
	check_cmp(inst, "combat")
	if dmg then inst.components.combat:SetDefaultDamage(dmg) end
	if per then inst.components.combat:SetAttackPeriod(per) end
	if re and re.time and re.fn then inst.components.combat:SetRetargetFunction(re.time, re.fn) end
	if keep then inst.components.combat:SetKeepTargetFunction(keep) end
	if hit then inst.components.combat:SetOnHit(hit) end
	if atk then inst.components.combat.onhitotherfn = atk end
	if symbol then inst.components.combat.hiteffectsymbol = symbol end
	if player then inst.components.combat.playerdamagepercent = player end
	if range then 
		if type(range) == 'table' then
			inst.components.combat:SetRange(range[1], range[2])
		else
			inst.components.combat:SetRange(range) 
		end
	end
end

local function add_health(inst, max, regen, absorb)
	check_cmp(inst, "health")
	if max then inst.components.health:SetMaxHealth(max) end
	if regen then
		local regen_num = regen.num or regen[1]
		local regen_per = regen.per or regen[2]
		inst.components.health:StartRegen(regen_num, regen_per) 
	end
	if absorb then inst.components.health:SetAbsorptionAmount(absorb) end
end

local function add_locomotor(inst, walk, run)
	check_cmp(inst, "locomotor")
	if walk then inst.components.locomotor.walkspeed = walk end
	if run then inst.components.locomotor.runspeed = run end
end

local function add_insulator(inst, value, typ)
	check_cmp(inst, "insulator")
	if value then inst.components.insulator.insulation = value end
	if typ then
		if typ == "summer" then
			inst.components.insulator:SetSummer()
		else
			inst.components.insulator:SetWinter()
		end
	end
end

local function add_waterproofer(inst, value)
	check_cmp(inst, "waterproofer")
	if value then inst.components.waterproofer:SetEffectiveness(value) end
end

local function add_tool(inst, act)
	check_cmp(inst, "tool")
	if act then
		if act.chop then inst.components.tool:SetAction(ACTIONS.CHOP, act.chop) end
		if act.mine then inst.components.tool:SetAction(ACTIONS.MINE, act.mine) end
		if act.ham then inst.components.tool:SetAction(ACTIONS.HAMMER, act.ham) end
		if act.dig then inst.components.tool:SetAction(ACTIONS.DIG, act.dig) end
		if act.hack then inst.components.tool:SetAction(ACTIONS.HACK, act.hack) end
		if act.shear then inst.components.tool:SetAction(ACTIONS.SHEAR, act.shear) end
		if act.play then inst.components.tool:SetAction(ACTIONS.PLAY, act.play) end
	end
end

local function add_sleeper(inst, wake, sleep, resist)
	check_cmp(inst, "sleeper")
	if wake then inst.components.sleeper:SetWakeTest(wake) end
	if sleep then inst.components.sleeper:SetSleepTest(sleep) end
	if resist then inst.components.sleeper:SetResistance(resist) end
end

local function add_inventory(inst, max)
	check_cmp(inst, "inventory")
	if max then
		inst.components.inventory:SetNumSlots(max)
	end
end

local function add_lootdropper(inst, loot, rand, ranum)
	check_cmp(inst, "lootdropper")
	if loot then inst.components.lootdropper:SetLoot(loot) end
	if rand then
		for i, v in pairs(rand) do
			inst.components.lootdropper:AddRandomLoot(i, v)
		end
	end
	if ranum then inst.components.lootdropper.numrandomloot = ranum end
end

local function set_can_eat(inst, typ)
	if typ == 'veggie' then
		inst.components.eater:SetVegetarian(inst:HasTag("player"))
	elseif typ == "meat" then
		inst.components.eater:SetCarnivore(inst:HasTag("player"))
	elseif typ == "insect" then
		inst.components.eater:SetInsectivore()
	elseif typ == "seed" then
		inst.components.eater:SetBird()
	elseif typ == "wood" then
		inst.components.eater:SetBeaver()
	elseif typ == "elem" then
		inst.components.eater:SetElemental(inst:HasTag("player"))
	elseif typ == "all" then
		inst.components.eater:SetOmnivore()
	end
end

local function add_eater(inst, typ, hor, absorb, eat, test)
	check_cmp(inst, "eater")
	set_can_eat(inst, typ)
	if hor then inst.components.eater:SetCanEatHorrible() end
	if absorb then inst.components.eater:SetAbsorptionModifiers(absorb[1], absorb[2], absorb[3]) end
	if eat then inst.components.eater:SetOnEatFn(eat) end
	if test then inst.components.eater:SetCanEatTestFn(test) end
end

local function add_talker(inst, talk, size, font, offset, colour)
	check_cmp(inst, "talker")
	if talk then inst.components.talker.ontalk = talk end
	inst.components.talker.fontsize = size or 35
	inst.components.talker.font = font or TALKINGFONT
	inst.components.talker.offset = offset or Vector3(0, -400, 0)
	if colour then
		inst.components.talker.colour = Vector3(colour[1], colour[2], colour[3])
	end
end

local function add_follower(inst, max)
	check_cmp(inst, "follower")
	if max then inst.components.follower.maxfollowtime = max end
end

local function add_sanityaura(inst, fn)
	check_cmp(inst, "sanityaura")
	if fn then inst.components.sanityaura.aurafn = fn end
end

local function add_projectile(inst, speed, throw, hit, can, catch, miss, offset)
	check_cmp(inst, "projectile")
	if speed then inst.components.projectile:SetSpeed(speed) end
	if throw then inst.components.projectile:SetOnThrownFn(throw) end
	if hit then inst.components.projectile:SetOnHitFn(hit) end
	if can then inst.components.projectile:SetCanCatch(can) end
	if catch then inst.components.projectile:SetCanCatch(catch) end
	if miss then inst.components.projectile:SetOnMissFn(miss) end
	if offset then inst.components.projectile:SetLaunchOffset(Vector3(offset[1], offset[2], offset[3])) end
end

local function add_throwable(inst, throw)
	check_cmp(inst, "throwable")
	if throw then inst.components.throwable.onthrown = throw end
end

local function add_instrument(inst, range, fn)
	check_cmp(inst, "instrument")
	if range then inst.components.instrument.range = range end
	if fn then inst.components.instrument:SetOnHeardFn(fn) end
end

local function add_perishable(inst, time, spoil)
	check_cmp(inst, "perishable")
	if time then inst.components.perishable:SetPerishTime(time) end
	if spoil then inst.components.perishable.onperishreplacement = spoil end
	inst.components.perishable:StartPerishing()
end

local function add_workable(inst, act, num, ham, hit)
	check_cmp(inst, "workable")
	if act then inst.components.workable:SetWorkAction(act) end
    if num then inst.components.workable:SetWorkLeft(num) end
	if ham then inst.components.workable:SetOnFinishCallback(ham) end
	if hit then inst.components.workable:SetOnWorkCallback(hit) end
end

local function add_groundpounder(inst, destroy, rings, num)
	check_cmp(inst, "groundpounder")
	if destroy then inst.components.groundpounder.destroyer = destroy end
    if rings then
    	if rings.dmg then inst.components.groundpounder.damageRings = rings.dmg end
		if rings.destroy then inst.components.groundpounder.destructionRings = rings.destroy end
	end
    if num then inst.components.groundpounder.numRings = num end
end	

local function add_spellcaster(inst, spell, test, can)
	check_cmp(inst, "spellcaster")
	if spell then inst.components.spellcaster:SetSpellFn(spell) end
	if test then inst.components.spellcaster:SetSpellTestFn(test) end
	if can then
		if can.target then inst.components.spellcaster.canuseontargets = can.target end
		if can.point then inst.components.spellcaster.canuseonpoint = can.point end
		if can.inv then inst.components.spellcaster.canusefrominventory = can.inv end
	end
end

local function add_useableitem(inst, str, test, use)
	check_cmp(inst, "useableitem")
	if str then inst.components.useableitem.verb = str end
	if test then inst.components.useableitem:SetCanInteractFn(test) end
	if use then inst.components.useableitem:SetOnUseFn(use) end
end

local function add_cooldown(inst, time, fn)
	check_cmp(inst, "cooldown")
	if time then inst.components.cooldown.cooldown_duration = time end
	if fn then inst.components.cooldown.onchargedfn = fn end
end

local function set_widgets(inst, slotpos, bank, build, pos, align)
	local default_slotpos = {}
	for y = 2, 0, -1 do
		for x = 0, 2 do
			table.insert(default_slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80, 0))
		end
	end
	inst.components.container.widgetslotpos = slotpos or default_slotpos
	inst.components.container.widgetanimbank = bank or "ui_chest_3x3"
	inst.components.container.widgetanimbuild = build or "ui_chest_3x3"
	inst.components.container.widgetpos = pos or Vector3(0, 200, 0)
	inst.components.container.side_align_tip = align or 160
end

local function add_container(inst, num, open, close, widgets, test)
	check_cmp(inst, "container")
	if num then inst.components.container:SetNumSlots(num) end
	if open then inst.components.container.onopenfn = open end
	if close then inst.components.container.onclosefn = close end
	if widgets then set_widgets(inst, unpack(widgets)) end
	if test then inst.components.container.itemtestfn = test end
end

local function add_deployable(inst, test, deploy)
	check_cmp(inst, "deployable")
	if test then inst.components.deployable.test = test end
	if deploy then inst.components.deployable.ondeploy = deploy end
end

local function add_playerprox(inst, dist, near, far)
	check_cmp(inst, "playerprox")
	if dist then inst.components.playerprox:SetDist(dist[1], dist[2]) end
	if near then inst.components.playerprox:SetOnPlayerNear(near) end
	if far then inst.components.playerprox:SetOnPlayerFar(far) end
end

local function add_spawner(inst, child, time, occupied, vacate)
	check_cmp(inst, "spawner")
	if child and time then inst.components.spawner:Configure(child, time) end
	if occupied then inst.components.spawner.onoccupied = occupied end
	if vacate then inst.components.spawner.onvacate = vacate end
end

local function add_worker(inst, action, num)
	check_cmp(inst, "worker")
	if action and num then
		inst.components.worker:SetAction(action, num)
	end
end

local function add_hunger(inst, max, rate, over)
	check_cmp(inst, 'hunger')
	if max then inst.components.hunger:SetMax(max) end
	if rate then inst.components.hunger:SetRate(rate) end
	if over then inst.components.hunger.overridestarvefn = over end
end

local function add_hatchable(inst, state, crake, hatch, fail)
	check_cmp(inst, 'hatchable')
	if state then inst.components.hatchable:SetOnState(state) end
	if crake then inst.components.hatchable:SetCrackTime(crake) end
	if hatch then inst.components.hatchable:SetHatchTime(hatch) end
	if fail then inst.components.hatchable:SetHatchFailTime(fail) end
end

local function add_component(inst, cmp, data)
	if cmp == "invitem" then
		add_inventoryitem(inst, data.atlas, data.img, data.put, data.drop)
	elseif cmp == "inspect" then
		add_inspectable(inst, data.fn)
	elseif cmp == "trader" then
		add_trader(inst, data.test, data.accept, data.refuse)
	elseif cmp == "trade" then
		add_tradable(inst, data.value)
	elseif cmp == "stack" then
		add_stackable(inst, data.max)
	elseif cmp == "machine" then
		add_machine(inst, data.on, data.off, data.time, data.test)
	elseif cmp == "equip" then
		add_equippable(inst, data.slot, data.equip, data.unequip, data.pocket, data.effect)
		-- effect={bilei, speed, poison, san}
	elseif cmp == "book" then
		add_book(inst, data.fn, data.test, data.act)
	elseif cmp == "finite" then
		add_finiteuses(inst, data.use, data.max, data.fn, data.act, data.num)
	elseif cmp == "fuel" then
		add_fuel(inst, data.typ, data.value)
	elseif cmp == "fueled" then
		add_fueled(inst, data.typ, data.time, data.fn, data.accept)  --fn={finish,section,fuel}
	elseif cmp == "armor" then
		add_armor(inst, data.armor, data.absorb)
	elseif cmp == "weapon" then
		add_weapon(inst, data.dmg, data.range, data.fn, data.fx)  --range={atk,hit}
	elseif cmp == "combat" then
		-- dmg, per, re, keep, hit, atk, symbol, player, range
		add_combat(inst, data.dmg, data.per, data.re, data.keep, data.hit, data.atk, data.symbol, data.player, data.range)  --re={time,fn}
	elseif cmp == "health" then
		add_health(inst, data.max, data.regen, data.absorb)  --regen={num,per}
	elseif cmp == "loco" then
		add_locomotor(inst, data.walk, data.run)
	elseif cmp == "insu" then  -- 防暑/防寒
		add_insulator(inst, data.value, data.typ)
	elseif cmp == "water" then  -- 防水
		add_waterproofer(inst, data.value)
	elseif cmp == "tool" then
		add_tool(inst, data.act)
		-- act={chop, mine, ham, dig, hack, shear, play}
	elseif cmp == "sleep" then
		add_sleeper(inst, data.wake, data.sleep, data.resist)
	elseif cmp == "inv" then
		add_inventory(inst, data.num)
	elseif cmp == "loot" then
		add_lootdropper(inst, data.loot, data.rand, data.ranum)
	elseif cmp == "eat" then
		add_eater(inst, data.typ)
	elseif cmp == "talk" then
		add_talker(inst, data.talk, data.size, data.font, data.offset, data.colour)
	elseif cmp == "follow" then
		add_follower(inst, data.max)
	elseif cmp == "san_aoe" then
		add_sanityaura(inst, data.fn)
	elseif cmp == "proj" then
		add_projectile(inst, data.speed, data.throw, data.hit, data.can, data.catch, data.miss, data.offset)
	elseif cmp == "throw" then
		add_throwable(inst, data.throw)
	elseif cmp == "instr" then
		add_instrument(inst, data.range, data.fn)
	elseif cmp == "perish" then
		add_perishable(inst, data.time, data.spoil)
	elseif cmp == "work" then
		add_workable(inst, data.act, data.num, data.ham, data.hit)
	elseif cmp == "pounder" then
		add_groundpounder(inst, data.destroy, data.rings, data.num) --rings={dmg,destroy}
	elseif cmp == "caster" then
		add_spellcaster(inst, data.spell, data.test, data.can) -- can={target,point,inv}
	elseif cmp == "use" then
		add_useableitem(inst, data.str, data.test, data.use)
	elseif cmp == "cd" then
		add_cooldown(inst, data.time, data.fn)
	elseif cmp == "cont" then
		add_container(inst, data.num, data.open, data.close, data.widgets, data.test)
	elseif cmp == "dep" then
		add_deployable(inst, data.test, data.deploy)
	elseif cmp == "near" then
		add_playerprox(inst, data.dist, data.near, data.far)
	elseif cmp == "spawn" then
		add_spawner(inst, data.child, data.time, data.occupied, data.vacate)
	elseif cmp == "worker" then
		add_worker(inst, data.action, data.num)
	elseif cmp == "hunger" then
		add_hunger(inst, data.max, data.rate, data.over)
	elseif cmp == "hatch" then
		add_hatchable(inst, data.state, data.crake, data.hatch, data.fail)
	else
		check_cmp(inst, cmp)
	end
end

local function add_cmps(inst, datas)
	for i, v in pairs(datas) do
		add_component(inst, i, v)
	end
end

GLOBAL.WARGON_CMP_EX = {
	add_cmps = add_cmps,
}

GLOBAL.WARGON.CMP = GLOBAL.WARGON_CMP_EX