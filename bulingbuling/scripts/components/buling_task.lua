local taskitemlist = {
[5] = {"buling_zhongziding",1},
[7] = {"buling_planttable_item",1},
[10] = {"guguguguugugug",1},
}
local function buling_planet()
	local world = GetWorld()
	if world and SaveGameIndex:GetCurrentMode() == "desertplanet"then
		world:DoTaskInTime(1,function()
			GetSeasonManager():StartSummer()
		end)
	end
	if world and SaveGameIndex:GetCurrentMode() == "edenplanet"then
		world:DoTaskInTime(1,function()
			GetSeasonManager():StartHumid()
		end)
	end
end
local buling_task = Class(function(self, inst, activcb)
    self.inst = inst
    self.tasknum = 1
	buling_planet()
end)
function buling_task:Getitem()
	if taskitemlist[self.tasknum] then
		return taskitemlist[self.tasknum][1]
	else
		return taskitemlist[self.tasknum]
	end
end
function buling_task:Getitemnum()
	return taskitemlist[self.tasknum][2]
end
function buling_task:nexttask()
	if self:Getitem() == nil then
		self.tasknum = self.tasknum + 1
	end
end
function buling_task:itemnexttask()
	if self:Getitem() ~= nil then
		if self.inst.components.inventory:Has(taskitemlist[self.tasknum][1],taskitemlist[self.tasknum][2]) then
			--self.inst.components.inventory:ConsumeByName(taskitemlist[self.tasknum][1],taskitemlist[self.tasknum][2])
			self.tasknum = self.tasknum + 1
		end
	end
end
function buling_task:zzSave(...)--多谢猪哥
        local data = {}
        for _, v in ipairs(arg) do  --保存字段
            data[v] = self[v]
        end
        return data
end
function buling_task:zzLoad(data)--载入字段
	if not data then
		return
	end
	for k, v in pairs(data) do
		self[k] = v or 0
	end
end
function buling_task:OnSave()
	return self:zzSave('tasknum')
end   
      
function buling_task:OnLoad(data)
    self:zzLoad(data)
end
return buling_task
