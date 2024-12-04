local s = [[local slotpos = {}
for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80, 0))
    end
end
inst:AddComponent("container")
inst.components.container:SetNumSlots(#slotpos)
inst.components.container.widgetslotpos = slotpos
inst.components.container.widgetanimbank = "ui_chest_3x3"
inst.components.container.widgetanimbuild = "ui_chest_3x3"
inst.components.container.widgetpos = Vector3(0, 200, 0)
inst.components.container.side_align_tip = 160
inst:ListenForEvent("onopen", function(inst, data)
    if inst.SoundEmitter then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
end)
inst:ListenForEvent("onclose", function(inst, data)
    if inst.SoundEmitter then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
end)]]

local function str2mult_line(s)
    local n = string.find(s, "\n")
    while n do
        local os = string.sub(s, 1, n-1)
        print(string.format("\"%s\",", os))
        s = string.sub(s, n+1, -1)
        n = string.find(s, "\n")
    end
    print(string.format("\"%s\",", s))
end

local a, b = 5, 5
local t = {0}
table.insert(t, a)
for i=1,30 do
    a = (a+4)*1.1
    table.insert(t, math.floor(a))
end

local function fn(n)
    local sum = 0
    for i = 1, n do
        sum = sum+t[i]
    end
    return sum
end

-- print(fn(5))
-- print(fn(10))
-- print(fn(15))
-- print(fn(20))
-- print(fn(25))
-- print(fn(30))

-- 50
-- 265
-- 748
-- 1662
-- 3268
-- 5991
