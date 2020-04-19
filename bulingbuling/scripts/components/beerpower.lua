
local Beerpower = Class(function(self, inst)
	self.inst = inst
	self.power = 0--电力
	self.PowerMax=0--电力上限
	self.rate = 5--耗电速度
	self.work = false
	self.updatetask = nil
	self.workfn = nil
	self.duandianguanji = true
	self.beer = 0 --贝尔值
end)
--数字变动
function Beerpower:UpBeer(number)
	--print("boom")
	self.power = self.power - number
	if self.power < 0 then 
		self.power = 0
		self.work = false
		--self.inst:PushEvent("buling_workstop")
	end
	if self.power >self.PowerMax then
		self.power = self.PowerMax
	end
end

function Beerpower:Setworkfn(fn)
    self.workfn = fn
end
function Beerpower:SetNumber(PowerMax,rate,power)
    self.PowerMax = PowerMax or 0
	self.rate = rate or 0
	self.power = power or 0
end
--自动消耗
function Beerpower:StartPerishing()
--print("消耗")
	self.inst:PushEvent("buling_workstart")
	if self.work == false then
		self.work = true
	end
	if self.updatetask then
		self.updatetask:Cancel()
		self.updatetask = nil
	end
    self.updatetask = self.inst:DoPeriodicTask(5, function()
		--if self.canwork == true then
			self:UpBeer(self.rate)
		--end
	end)
	if self.power < self.rate and self.duandianguanji == true then
		self:StopPerishing()
	end
end
function Beerpower:StopPerishing()
--print("关闭")
	self.inst:PushEvent("buling_worksstop")
	if self.work == true then
		self.work = false
	end
	if self.updatetask then
		self.updatetask:Cancel()
		self.updatetask = nil
	end
end
function Beerpower:zzSave(...)--多谢猪哥
        local data = {}
        for _, v in ipairs(arg) do  --保存字段
            data[v] = self[v]
        end
        return data
end
function Beerpower:zzLoad(data)--载入字段
	if not data then
		return
	end
	for k, v in pairs(data) do
		self[k] = v or 0
	end
end
function Beerpower:OnSave()
	return self:zzSave('power', 'PowerMax', 'shanbi','beer')
end   
      
function Beerpower:OnLoad(data)
    self:zzLoad(data)
end
return Beerpower