local TpBuy = Class(function(self, inst)
	self.inst = inst
	self.coin = 0
end)

local coin_name = {
	"oinc",
	"oinc10",
	"oinc100",
}

function TpBuy:CountCoin()
	local inventory = self.inst.components.inventory
	local coin = {0, 0, 0}
	if inventory then
		for k, v in pairs(coin_name) do
			coin[k] = inventory:Count(v)
		end
		-- coin[1] = inventory:Count("oinc")
		-- coin[2] = inventory:Count("oinc10")
		-- coin[3] = inventory:Count("oinc100")
	end
	return coin
end

function TpBuy:CountMoney()
	local coin = self:CountCoin()
	local money = 0
	money = money + coin[1] + 10*coin[2] + 100*coin[3]
	return money
end

function TpBuy:CanBuy(price)
	local money = self:CountMoney()
	return money >= price
end

function TpBuy:NeedCoin(price)
	local coin = {}
	coin[1] = price%10
	coin[2] = ( math.floor(price/10) )%10
	coin[3] = math.floor( price/100 )
	return coin
end

function TpBuy:RunOut()
	local coins = self:CountCoin()
	for i = 1, 3 do
		if coins[i] > 0 then
			-- local coin_value = math.pow(10, i-1)
			-- local coin_pst = coin_value > 1 and coin_value
			-- local coin_name = coin_pst and "oinc"..tostring(coin_pst) or "oinc"
			-- self.inst.components.inventory:ConsumeByName(coin_name, coins[i])
			self.inst.components.inventory:ConsumeByName(coin_name[i], coins[i])
		end
	end
end

function TpBuy:PayCoin(coin, num)

end

function TpBuy:Buy(price)
	local money = self:CountMoney()
	if money >= price then
		-- self:RunOut() -- 这个改变了后面的countmoney
		-- local balance = money - price
		-- local count_balance = balance
		-- print("TpBuy", money, price, balance)
		-- local unit = 1
		-- for i = 1, 3 do
		-- 	local temp = unit * 10
		-- 	local num = math.floor( (balance % temp)/unit )
		-- 	if num > 0 then
		-- 		local coin_value = unit
		-- 		local coin_pst = coin_value > 1 and coin_value
		-- 		local coin_name = coin_pst and "oinc"..tostring(coin_pst) or "oinc"
		-- 		print("TpBuy", num, coin_name)
		-- 		local coin = SpawnPrefab(coin_name)
		-- 		if coin.components.stackable then
		-- 			coin.components.stackable:SetStackSize(num)
		-- 		end
		-- 		self.inst.components.inventory:GiveItem(coin)
		-- 	end
		-- 	unit = temp
		-- end
		local coins = self:CountCoin()
		local need_coins = self:NeedCoin(price)
		-- local balance = {0, 0}
		for i = 1, 3 do
			if need_coins[i] > coins[i] then  -- 如果钱足够，那么百位数必不会小于需求
				need_coins[i+1] = need_coins[i+1] + 1
				-- balance[i] = 10-need_coins[i]
				local balance = 10 - need_coins[i]
				c_give(coin_name[i], balance)
			else
				self.inst.components.inventory:ConsumeByName(coin_name[i], need_coins[i])
			end
		end
	else
		print("not enough money")
	end
end

return TpBuy