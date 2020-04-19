local function applyupgrades(self)
	self.inst.components.health.maxhealth = 75+self.buffhealth
	self.inst.components.hunger.max = 100+self.buffhunger
	self.inst.components.sanity.max = 300+self.buffsanity
	self.inst.components.health:DoDelta(0)
end
local function appsanwei(self)
	local inst = self.inst
	inst.components.sanity.current = self.sanity
	inst.components.hunger.current = self.hunger
	inst.components.health.currenthealth = self.health
	print("opopop")
end
local buling_buff = Class(function(self, inst)
    self.inst = inst
	self.interval = 1
	
	self.buff_modifiers_add_timer = {}
	self.buff_modifiers_add_buffhealth = {}
	self.buff_modifiers_add_buffhunger = {}
	self.buff_modifiers_add_buffsanity = {}
	self.buffhealth = 0
	self.buffhunger = 0
	self.buffsanity = 0
	self.sanity = inst.components.sanity.current
	self.hunger = inst.components.hunger.current
	self.health = inst.components.health.currenthealth
	self.buff_modifiers_add = {
		['buling_meiwei'] = function(self) self.inst.components.sanity:DoDelta(.5) end,
		['buling_baofu'] = function(self) self.inst.components.hunger:DoDelta(.5) end,
		['buling_yangsheng'] = function(self) self.inst.components.health:DoDelta(.5) end,
		['buling_chaotishen'] = function(self) self.inst.components.sanity:DoDelta(5) end,
		['buling_chaobaofu'] = function(self) self.inst.components.hunger:DoDelta(5) end,
		['buling_chaomeiwei'] = function(self) self.inst.components.health:DoDelta(4) end,
		['buling_yeshi'] = function(self) 
			if GetClock() and GetWorld() and GetWorld().components.colourcubemanager then
				GetClock():SetNightVision(true)
				GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/mole_vision_on_cc.tex", 2) 
				if self.buff_modifiers_add_timer['buling_yeshi'] <= 5 then
					if GetClock() then
						GetClock():SetNightVision(false)
					end
					if GetWorld() and GetWorld().components.colourcubemanager then
						GetWorld().components.colourcubemanager:SetOverrideColourCube(nil, .5)
					end
				end
			end
		end,
	}
	self:Starbuff()
end)
function buling_buff:taskbufffn()
	for k,v in pairs(self.buff_modifiers_add_timer) do
		if self.buff_modifiers_add_timer[k] and self.buff_modifiers_add_timer[k] > 0 then
			self.buff_modifiers_add_timer[k] = self.buff_modifiers_add_timer[k] - self.interval
			--print(self.buff_modifiers_add_timer[k])
			if self.buff_modifiers_add[k] ~= nil then self.buff_modifiers_add[k](self) end
		elseif self.buff_modifiers_add_timer[k] and self.buff_modifiers_add_timer[k] <= 0 then
			self.buff_modifiers_add_buffhealth[k] = 0
			self.buff_modifiers_add_buffhunger[k] = 0
			self.buff_modifiers_add_buffsanity[k] = 0
		end
	end
	local buffhealth = 0
	local buffhunger = 0
	local buffsanity = 0
	for k,v in pairs(self.buff_modifiers_add_buffhealth) do
		buffhealth = buffhealth + self.buff_modifiers_add_buffhealth[k]
	end
	for k,v in pairs(self.buff_modifiers_add_buffhunger) do
		buffhunger = buffhunger + self.buff_modifiers_add_buffhunger[k]
	end
	for k,v in pairs(self.buff_modifiers_add_buffsanity) do
		buffsanity = buffsanity + self.buff_modifiers_add_buffsanity[k]
	end
	self.buffhealth = buffhealth
	self.buffhunger = buffhunger
	self.buffsanity = buffsanity
	applyupgrades(self)
end
function buling_buff:Starbuff()
	self.taskbuff = self.inst:DoPeriodicTask(self.interval,function()
		self:taskbufffn()
	end)
end
function buling_buff:Addbulingbuff_Additive(key, timer,buffhealth,buffhunger,buffsanity)
    if timer  then
        self.buff_modifiers_add_timer[key] = timer
		self.buff_modifiers_add_buffhealth[key] = buffhealth or 0
		self.buff_modifiers_add_buffhunger[key] = buffhunger or 0
		self.buff_modifiers_add_buffsanity[key] = buffsanity or 0
    end
end
function buling_buff:zzSave(...)--多谢猪哥
        local data = {}
        for _, v in ipairs(arg) do  --保存字段
            data[v] = self[v]
        end
        return data
end
function buling_buff:zzLoad(data)--载入字段
	if not data then
		return
	end
	for k, v in pairs(data) do
		self[k] = v or 0
	end
end
function buling_buff:OnSave()
	local inst = self.inst
	self.sanity = inst.components.sanity.current
	self.hunger = inst.components.hunger.current
	self.health = inst.components.health.currenthealth
	return self:zzSave('buff_modifiers_add_timer','buff_modifiers_add_buffhealth','buff_modifiers_add_buffhunger','buff_modifiers_add_buffsanity','sanity','hunger','health')
end   
      
function buling_buff:OnLoad(data)
    self:zzLoad(data)
	self:taskbufffn()
	applyupgrades(self)
	self.inst:DoTaskInTime(.1,function()
		appsanwei(self)
	end)
	
end

return buling_buff