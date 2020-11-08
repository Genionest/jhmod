AddGlobalClassPostConstruct('entityscript', 'EntityScript', function(self)
	function self:add_tags(tags)
		WARGON.add_tags(self, tags)
	end
	function self:rm_tags(tags)
		WARGON.remove_tags(self, tags)
	end
	function self:wg_find(range, fn, tags, no_tags)
		return FindEntity(self, range, fn, tags, no_tags)
	end
	function self:wg_finds(range, tags, no_tags)
		local x, y, z = self:GetPosition():Get()
		return TheSim:FindEntities(x, y, z, range, tags, no_tags)
	end
	function self:wg_find_close(tag, range)
		return WARGON.find_close(self, tag, range)
	end
	function self:on_water(pt)
		return WARGON.on_water(self, pt)
	end
	function self:on_land(pt)
		return WARGON.on_land(self, pt)
	end
	function self:add_cmp(cmp, data)
		WARGON.CMP.add_cmps(self, {
			[cmp] = data or {},
		})
	end
	function self:add_cmps(data)
		WARGON.CMP.add_cmps(self, data)
	end
	function self:rm_cmp(cmp)
		self:RemoveComponent(cmp)
	end
	function self:add_listener(...)
		self:ListenForEvent(...)
	end
	function self:rm_listener(...)
		self:RemoveEventCallback(...)
	end
	function self:do_task(...)
		return self:DoTaskInTime(...)
	end
	function self:per_task(...)
		return self:DoPeriodicTask(...)
	end
	function self:around_land(...)
		return WARGON.around_land(self, ...)
	end
	function self:no_save()
		self.persists = false
	end
	function self:area_dmg(range,attacker,dmg,tags,no_tags,reason,fn)
		no_tags = no_tags or {}
		for k, v in pairs({"FX", "NOCLICK", "INLIMBO"}) do
			table.insert(no_tags, v)
		end
		local ents = WARGON.finds(inst, range, tags, no_tags)
		local attacker = attacker or inst
		for i, v in pairs(ents) do
			if attacker then
				if not v.components.follower or v.components.follower.leader ~= attacker then
					if v.components.combat and v.components.health
					and attacker.components.combat:CanTarget(v) then
						v.components.combat:GetAttacked(attacker, dmg, inst, reason)
						if fn then fn(inst, attacker, v) end
					end
				end
			end
		end
	end
	function self:player_area_dmg(range,attacker,dmg,tags,no_tags,reason,fn)
		no_tags = no_tags or {}
		for k, v in pairs({"player", "wall"}) do
			table.insert(no_tags, v)
		end
		self:area_dmg(range,attacker,dmg,tags,no_tags,reason,fn)
	end
	function self:get_fire(attacker)
		WARGON.fire_prefab(self, attacker)
	end
	function self:get_frozen(attacker, num)
		WARGON.frozen_prefab(self, attacker, num)
	end
	function self:get_poison()
		WARGON.poison_prefab(self)
	end
	function self:get_sleep()
		WARGON.sleep_prefab(self)
	end
	function self:pigking_throw(nug)
		WARGON.pigking_throw(self, nug)
	end
	function self:set_scale(...)
		WARGON.set_scale(self, ...)
	end
	function self:set_pos(...)
		WARGON.set_pos(self, ...)
	end
	function self:transfer(target)
		local pos = target:GetPosition()
		self:set_pos(pos:Get())
	end
	function self:add_speed_rate(...)
		WARGON.add_speed_rate(self, ...)
	end
	function self:rm_speed_rate(...)
		WARGON.remove_speed_rate(self, ...)
	end
	function self:add_dmg_rate(...)
		WARGON.add_dmg_rate(self, ...)
	end
	function self:rm_dmg_rate(...)
		WARGON.remove_dmg_rate(self, ...)
	end
	function self:add_hunger_rate(...)
		WARGON.add_hunger_rate(self, ...)
	end
	function self:rm_hunger_rate(...)
		WARGON.remove_hunger_rate(self, ...)
	end
	function self:add_san_rate(...)
		WARGON.add_san_rate(self, ...)
	end
	function self:rm_san_rate(...)
		WARGON.remove_san_rate(self, ...)
	end
	function self:get_tile()
		local pt = self:GetPosition()
		return GetGroundTypeAtPosition(pt)
	end
	function self:is_monster(...)
		return WARGON.is_monster(self)
	end
	function self:has_tag(tags)
		return WARGON.has_tag(self, tags)
	end
	function self:has_tags(tags)
		return WARGON.has_tags(self, tags)
	end
	function self:get_dist(target)
		return WARGON.get_dist(self, target)
	end
	function self:face_target(target)
		WARGON.face_target(self, target)
	end
	function self:anim_hat_on(...)
		WARGON.EQUIP.hat_on(self, ...)
	end
	function self:anim_hat_open(...)
		WARGON.EQUIP.hat_open(self, ...)
	end
	function self:anim_hat_off(...)
		WARGON.EQUIP.hat_off(self, ...)
	end
	function self:anim_body_on(...)
		WARGON.EQUIP.body_on(self, ...)
	end
	function self:anim_body_off(...)
		WARGON.EQUIP.body_off(self, ...)
	end
	function self:anim_object_on(...)
		WARGON.EQUIP.object_on(self, ...)
	end
	function self:anim_object_off(...)
		WARGON.EQUIP.object_off(self, ...)
	end
	function self:equip_temp_weapon(...)
		WARGON.EQUIP.equip_temp_weapon(self, ...)
	end
	function self:get_equip_item(slot)
		if self.components.inventory then
			local slots = {
				head = EQUIPSLOTS.HEAD,
				body = EQUIPSLOTS.BODY,
				hand = EQUIPSLOTS.HANDS,
			}
			slot = slots[slot] or slot
			local item = self.components.inventory:GetEquippedItem(slot)
			return item
		end
	end
end)