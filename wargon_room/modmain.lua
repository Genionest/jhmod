-- 已经GLOBAL过了
local function toPosition(pos)
	local pt = GetPlayer():GetPosition()
	return pt.x+pos[1], pt.y+pos[2], pt.z+pos[3]
end

local function setChest(item_tbl, pos)
	local chest = SpawnPrefab("treasurechest")
	-- print(pos[1], pos[2], pos[3])
	chest.Transform:SetPosition(toPosition(pos))
	for i, v in pairs(item_tbl) do
		local item = SpawnPrefab(i)
		if item.components.stackable then
			item.components.stackable:SetStackSize(v)
		end
		chest.components.container:GiveItem(item)
	end
end

local function setBackpack(pos)
	local pack = SpawnPrefab("backpack")
	pack.Transform:SetPosition(toPosition(pos))
end

function threeChest(player)
	print("GetTime = ", GetTime())
	if GetTime() < 1 then 
		return
	end
	-- local pt = player:GetPosition()
	-- local x, y, z = pt:Get()
	local item_tbl = {
		["log"] = 20,
		["cutgrass"] = 40,
		["twigs"] = 40,
		["flint"] = 40,
		["goldnugget"] = 20,
		["rocks"] = 40,
		["meat_dried"] = 5,
	}
	local item_tbl2 = {
		["axe"] = 1,
		["shovel"] = 1,
		["pickaxe"] = 1,
		["hammer"] = 1,
	}
	local item_tbl3 = {
		["tophat"] = 1,
		["minerhat"] = 1,
		["cane"] = 1,
		["raincoat"] = 1,
	}
	setChest(item_tbl, {2+math.random(2), 0, 0})
	setChest(item_tbl2, {2+math.random(2), 0, 2+math.random(2)})
	setChest(item_tbl3, {-2+math.random(2), 0, 2+math.random(2)})
	setBackpack({1, 0, -4})
end

-- AddSimPostInit(threeChest)