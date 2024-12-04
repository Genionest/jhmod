local function genCircEdgePositions(num)
	assert(num>0)
	local positions = {}
	for i = 1, num do
	   	local a = (3.14159*2/num) * i
		table.insert(positions, {x=math.sin(a),y=math.cos(a)})
	end
	return positions
end	

local t = genCircEdgePositions(55)
print("{")
for k, v in pairs(t) do
    print(string.format("\t{%.2f, %.2f},", v.x, v.y))
end
print("}")