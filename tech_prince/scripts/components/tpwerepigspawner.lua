local TpWerePigSpawner = Class(function(self, inst)
	self.inst = inst
	self.followers = {}
	self.num_followers = 0
end)

function TpWerePigSpawner:RemoveFollower(follower)
	if follower and self.followers[follower] then
		self.followers[follower] = nil
		self.num_followers = self.num_followers - 1
	end
end

function TpWerePigSpawner:AddFollower(follower)
	if self.followers[follower] == nil then
		self.followers[follower] = true
		self.num_followers = self.num_followers + 1
		follower:ListenForEvent('death', function(inst, data)
			self:RemoveFollower(follower)
		end, self.inst)
		self.inst:ListenForEvent('death', function(inst, data)
			self:RemoveFollower(follower)
		end, follower)
	end
end

function TpWerePigSpawner:Spawn()
	local inst = self.inst
	if self.num_followers >= 5 then
		return
	end
	local pos = WARGON.around_land(inst, 15)
	if pos and WARGON.on_land(inst, pos) then
		local pig = WARGON.make_spawn(pos, 'pigman')
		pig.components.werebeast:SetWere()
		self:AddFollower(pig)
		pig.sg:GoToState('howl')
		WARGON.make_fx(pos, 'statue_transition')
		WARGON.make_fx(pos, 'statue_transition_2')
	end
end

function TpWerePigSpawner:BeastPig()
	local inst = self.inst
	local ents = WARGON.finds(inst, 15, {'pig'}, {'werepig'})
	for i, v in pairs(ents) do
		if v.components.werebeast
		and not v.components.werebeast:IsInWereState() then
			v.components.werebeast:SetWere()
		end
	end
end

function TpWerePigSpawner:OnSave()
	local saved = false
    local followers = {}
    for k,v in pairs(self.followers) do
        saved = true
        table.insert(followers, k.GUID)
    end
    if saved then
        return {followers = followers}, followers
    end
end

function TpWerePigSpawner:LoadPostPass(newents, savedata)
	if savedata and savedata.followers then
        for k,v in pairs(savedata.followers) do
            local targ = newents[v]
            if targ and targ.entity then
                self:AddFollower(targ.entity)
            end
        end
    end
end

return TpWerePigSpawner